import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'avatar_repository.dart';

enum ChatRole { user, avatar }

class ChatMessage {
  final ChatRole role;
  final String text;
  final DateTime at;
  final bool isVoice;
  final Uint8List? audioBytes;
  const ChatMessage({
    required this.role,
    required this.text,
    required this.at,
    this.isVoice = false,
    this.audioBytes,
  });
}

class AvatarChatState {
  final List<ChatMessage> messages;
  final bool loading;
  final String? error;
  final String? conversationId;
  final bool isAudioPlaying;
  final DateTime? playingAt;
  final ChatRole? playingRole;

  const AvatarChatState({
    this.messages = const [],
    this.loading = false,
    this.error,
    this.conversationId,
    this.isAudioPlaying = false,
    this.playingAt,
    this.playingRole,
  });

  AvatarChatState copyWith({
    List<ChatMessage>? messages,
    bool? loading,
    String? error,
    String? conversationId,
    bool? isAudioPlaying,
    DateTime? playingAt,
    ChatRole? playingRole,
    bool clearError = false,
    bool clearPlaying = false,
  }) {
    return AvatarChatState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      conversationId: conversationId ?? this.conversationId,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
      playingAt: clearPlaying ? null : (playingAt ?? this.playingAt),
      playingRole: clearPlaying ? null : (playingRole ?? this.playingRole),
    );
  }
}

class AvatarChatController extends Notifier<AvatarChatState> {
  static const _character = 'khwarizmi';
  final _player = AudioPlayer();
  bool _audioContextSet = false;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<void>? _playerCompleteSub;

  @override
  AvatarChatState build() {
    _wirePlayerListeners();
    ref.onDispose(() {
      _playerStateSub?.cancel();
      _playerCompleteSub?.cancel();
      _player.dispose();
    });
    return const AvatarChatState();
  }

  void _wirePlayerListeners() {
    _playerStateSub = _player.onPlayerStateChanged.listen((event) {
      final playing = event == PlayerState.playing;
      if (state.isAudioPlaying != playing) {
        state = state.copyWith(isAudioPlaying: playing);
      }
    });
    _playerCompleteSub = _player.onPlayerComplete.listen((_) {
      state = state.copyWith(isAudioPlaying: false, clearPlaying: true);
    });
  }

  Future<void> _ensureAudioContext() async {
    if (_audioContextSet) return;
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {AVAudioSessionOptions.defaultToSpeaker},
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
            audioMode: AndroidAudioMode.normal,
          ),
        ),
      );
      _audioContextSet = true;
    } catch (e) {
      if (kDebugMode) debugPrint('Audio context set failed: $e');
    }
  }

  Future<void> playMessageAudio(ChatMessage msg) async {
    final bytes = msg.audioBytes;
    if (bytes == null || bytes.isEmpty) return;
    // Toggle: same message is playing → stop
    if (state.isAudioPlaying && state.playingAt == msg.at) {
      await stopAudio();
      return;
    }
    await _playBytes(bytes, at: msg.at, role: msg.role);
  }

  Future<void> stopAudio() async {
    try {
      await _player.stop();
    } catch (_) {}
    state = state.copyWith(isAudioPlaying: false, clearPlaying: true);
  }

  Future<void> _playBytes(Uint8List bytes, {DateTime? at, ChatRole? role}) async {
    try {
      await _ensureAudioContext();
      await _player.stop();
      await _player.setVolume(1.0);
      state = state.copyWith(playingAt: at, playingRole: role);
      // Android-те ылғи DeviceFileSource қолдану — BytesSource кейбір android-те үнсіз болады
      final dir = await Directory.systemTemp.createTemp('ortax_play_');
      final file = File('${dir.path}/audio.mp3');
      await file.writeAsBytes(bytes);
      if (kDebugMode) debugPrint('Playing audio from ${file.path} (${bytes.length} bytes)');
      await _player.play(DeviceFileSource(file.path));
    } catch (e) {
      if (kDebugMode) debugPrint('Audio playback failed: $e');
      try {
        await _player.play(BytesSource(bytes));
      } catch (e2) {
        if (kDebugMode) debugPrint('Audio playback fallback failed: $e2');
      }
    }
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.loading) return;

    final userMsg = ChatMessage(role: ChatRole.user, text: trimmed, at: DateTime.now());
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      loading: true,
      clearError: true,
    );

    try {
      final repo = ref.read(avatarRepositoryProvider);
      final res = await repo.ask(
        character: _character,
        question: trimmed,
        conversationId: state.conversationId,
      );
      final reply = ChatMessage(role: ChatRole.avatar, text: res.reply, at: DateTime.now());
      state = state.copyWith(
        messages: [...state.messages, reply],
        loading: false,
        conversationId: res.conversationId,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> sendVoice(File audioFile) async {
    if (state.loading) return;
    state = state.copyWith(loading: true, clearError: true);

    // Локалда жазылған дауысты bytes-қа оқу — replay үшін
    Uint8List? userAudioBytes;
    try {
      userAudioBytes = await audioFile.readAsBytes();
    } catch (_) {}

    try {
      final repo = ref.read(avatarRepositoryProvider);
      final res = await repo.askVoice(
        character: _character,
        audio: audioFile,
        conversationId: state.conversationId,
      );

      final replyAudio = res.audioBytes == null ? null : Uint8List.fromList(res.audioBytes!);

      final newMessages = <ChatMessage>[...state.messages];
      if (res.transcript.isNotEmpty) {
        newMessages.add(ChatMessage(
          role: ChatRole.user,
          text: res.transcript,
          at: DateTime.now(),
          isVoice: true,
          audioBytes: userAudioBytes,
        ));
      }
      final avatarMsgAt = DateTime.now();
      if (res.reply.isNotEmpty) {
        newMessages.add(ChatMessage(
          role: ChatRole.avatar,
          text: res.reply,
          at: avatarMsgAt,
          isVoice: replyAudio != null,
          audioBytes: replyAudio,
        ));
      }

      state = state.copyWith(
        messages: newMessages,
        loading: false,
        conversationId: res.conversationId,
      );

      if (replyAudio != null && replyAudio.isNotEmpty) {
        await _playBytes(replyAudio, at: avatarMsgAt, role: ChatRole.avatar);
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void clear() {
    state = const AvatarChatState();
  }

  /// Тарихтан таңдалған сессияны ағымдағы чатқа жүктеу.
  Future<void> loadConversation(String conversationId) async {
    await stopAudio();
    state = state.copyWith(loading: true, clearError: true);
    try {
      final repo = ref.read(avatarRepositoryProvider);
      final history = await repo.fetchSessionMessages(
        character: _character,
        conversationId: conversationId,
      );
      final mapped = history
          .map((m) => ChatMessage(
                role: m.role == 'assistant' ? ChatRole.avatar : ChatRole.user,
                text: m.content,
                at: m.createdAt,
              ))
          .toList();
      state = AvatarChatState(
        messages: mapped,
        loading: false,
        conversationId: conversationId,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  /// Жаңа әңгіме бастау — өткен conversationId-ден ажырау.
  void startNewConversation() {
    state = const AvatarChatState();
  }
}

final avatarChatProvider = NotifierProvider<AvatarChatController, AvatarChatState>(
  AvatarChatController.new,
);
