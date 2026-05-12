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

  const AvatarChatState({
    this.messages = const [],
    this.loading = false,
    this.error,
    this.conversationId,
    this.isAudioPlaying = false,
    this.playingAt,
  });

  AvatarChatState copyWith({
    List<ChatMessage>? messages,
    bool? loading,
    String? error,
    String? conversationId,
    bool? isAudioPlaying,
    DateTime? playingAt,
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
          android: const AudioContextAndroid(),
        ),
      );
      _audioContextSet = true;
    } catch (_) {
      // best-effort
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
    await _playBytes(bytes, at: msg.at);
  }

  Future<void> stopAudio() async {
    try {
      await _player.stop();
    } catch (_) {}
    state = state.copyWith(isAudioPlaying: false, clearPlaying: true);
  }

  Future<void> _playBytes(Uint8List bytes, {DateTime? at}) async {
    try {
      await _ensureAudioContext();
      final dir = await Directory.systemTemp.createTemp('ortax_play_');
      final file = File('${dir.path}/audio.mp3');
      await file.writeAsBytes(bytes);
      await _player.stop();
      state = state.copyWith(playingAt: at);
      await _player.play(DeviceFileSource(file.path));
    } catch (e) {
      if (kDebugMode) debugPrint('Audio playback failed: $e');
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
        await _playBytes(replyAudio, at: avatarMsgAt);
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void clear() {
    state = const AvatarChatState();
  }
}

final avatarChatProvider = NotifierProvider<AvatarChatController, AvatarChatState>(
  AvatarChatController.new,
);
