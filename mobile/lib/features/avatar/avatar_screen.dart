import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/ortax_colors.dart';
import '../../l10n/app_localizations.dart';
import 'avatar_chat_controller.dart';

class AvatarScreen extends ConsumerStatefulWidget {
  const AvatarScreen({super.key});

  @override
  ConsumerState<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends ConsumerState<AvatarScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _recorder = AudioRecorder();
  bool _recording = false;
  bool _showChat = false;

  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;
  bool _wasAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final c = VideoPlayerController.asset(
      'assets/avatar/video.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    try {
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(0); // ылғи дауыссыз
      await c.seekTo(Duration.zero);
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() {
        _videoCtrl = c;
        _videoReady = true;
      });
    } catch (_) {
      await c.dispose();
    }
  }

  @override
  void dispose() {
    // PopScope onPopInvokedWithResult-та stopAudio шақырылған
    _videoCtrl?.pause();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _recorder.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  void _syncVideoToAudio(bool audioPlaying, ChatRole? role) {
    // Тек avatar (Хорезми) дауысы ойналғанда видео анимациялансын.
    // User-дың өз дауысы — видео тоқтап тұрсын.
    final shouldPlay = audioPlaying && role == ChatRole.avatar;
    final v = _videoCtrl;
    if (v == null || !_videoReady) return;
    if (shouldPlay && !_wasAudioPlaying) {
      v.setVolume(0);
      v.play();
    } else if (!shouldPlay && _wasAudioPlaying) {
      v.pause();
      v.seekTo(Duration.zero);
    }
    _wasAudioPlaying = shouldPlay;
  }

  void _send() {
    final text = _textCtrl.text;
    if (text.trim().isEmpty) return;
    ref.read(avatarChatProvider.notifier).send(text);
    _textCtrl.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleRecord() async {
    if (_recording) {
      final path = await _recorder.stop();
      setState(() => _recording = false);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await ref.read(avatarChatProvider.notifier).sendVoice(file);
          _scrollToBottom();
        }
      }
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Микрофонға қол жеткізу қажет')),
        );
      }
      return;
    }

    final dir = await Directory.systemTemp.createTemp('ortax_voice_');
    final path = '${dir.path}/voice.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, sampleRate: 44100),
      path: path,
    );
    setState(() => _recording = true);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final state = ref.watch(avatarChatProvider);

    ref.listen<AvatarChatState>(avatarChatProvider, (prev, next) {
      _syncVideoToAudio(next.isAudioPlaying, next.playingRole);
    });

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        ref.read(avatarChatProvider.notifier).stopAudio();
        _videoCtrl?.pause();
      },
      child: Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.35),
        elevation: 0,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.avatarTitle,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            Text(
              t.avatarSubtitle,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _showChat = !_showChat),
            icon: Icon(
              _showChat ? Icons.visibility_off_outlined : Icons.chat_bubble_outline,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              _showChat ? 'Жасыру' : 'Чаттың текстін көрсету',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Толық экран видео фоны
          _FullscreenVideo(controller: _videoCtrl, ready: _videoReady),
          // 2. Жоғары жағы — қараңғы градиент (AppBar оқылатын болсын)
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),
          // 3. Чат overlay (қажет болғанда)
          if (_showChat)
            Positioned(
              left: 12,
              right: 12,
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
              bottom: 180,
              child: _ChatOverlay(messages: state.messages),
            ),
          // 4. Чат тарихы + композер
          SafeArea(child: _buildChatColumn(context, t, state)),
          // 4. Аудио ойнап жатқанда — өзгеше Stop батырмасы
          if (state.isAudioPlaying)
            Positioned(
              left: 0,
              right: 0,
              bottom: 110,
              child: Center(
                child: GestureDetector(
                  onTap: () => ref.read(avatarChatProvider.notifier).stopAudio(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stop_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Тоқтату',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildChatColumn(BuildContext context, AppLocalizations t, AvatarChatState state) {
    return Column(
      children: [
        const Expanded(child: SizedBox.shrink()),
            if (state.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  t.avatarError,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
            if (_recording)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Жазылып жатыр... Қайта басып аяқтаңыз',
                      style: TextStyle(color: AppColors.error.withValues(alpha: 0.9), fontSize: 12),
                    ),
                  ],
                ),
              ),
            _Composer(
              controller: _textCtrl,
              onSend: _send,
              onMicTap: _toggleRecord,
              hint: t.avatarHint,
              sendLabel: t.avatarSend,
              recording: _recording,
              disabled: state.loading && !_recording,
            ),
      ],
    );
  }
}



class _Composer extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onMicTap;
  final String hint;
  final String sendLabel;
  final bool recording;
  final bool disabled;
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.onMicTap,
    required this.hint,
    required this.sendLabel,
    required this.recording,
    required this.disabled,
  });

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  Widget build(BuildContext context) {
    final recording = widget.recording;
    final showSend = _hasText && !recording;

    final IconData icon;
    final Color bg;
    final Color fg;
    final String tooltip;
    final VoidCallback? onTap;
    if (recording) {
      icon = Icons.stop;
      bg = AppColors.error;
      fg = AppColors.textInverse;
      tooltip = 'Жазуды аяқтау';
      onTap = widget.onMicTap;
    } else if (showSend) {
      icon = Icons.send;
      bg = AppColors.primary;
      fg = AppColors.textInverse;
      tooltip = widget.sendLabel;
      onTap = widget.disabled ? null : widget.onSend;
    } else {
      icon = Icons.mic;
      bg = AppColors.accent;
      fg = context.colors.textPrimary;
      tooltip = 'Дауыспен жазу';
      onTap = widget.disabled ? null : widget.onMicTap;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.send,
              enabled: !recording,
              onSubmitted: (_) => widget.onSend(),
              decoration: InputDecoration(
                hintText: widget.hint,
                filled: true,
                fillColor: context.colors.surfaceMuted,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: IconButton.filled(
              key: ValueKey('${icon.codePoint}_${bg.toARGB32()}'),
              onPressed: onTap,
              icon: Icon(icon),
              style: IconButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                padding: const EdgeInsets.all(14),
              ),
              tooltip: tooltip,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullscreenVideo extends StatelessWidget {
  final VideoPlayerController? controller;
  final bool ready;
  const _FullscreenVideo({required this.controller, required this.ready});

  @override
  Widget build(BuildContext context) {
    if (!ready || controller == null || !controller!.value.isInitialized) {
      return Container(color: Colors.black);
    }
    final size = controller!.value.size;
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(controller!),
        ),
      ),
    );
  }
}



class _ChatOverlay extends ConsumerWidget {
  final List<ChatMessage> messages;
  const _ChatOverlay({required this.messages});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingAt = ref.watch(avatarChatProvider.select(
      (s) => s.isAudioPlaying ? s.playingAt : null,
    ));
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: messages.isEmpty
          ? Center(
              child: Text(
                'Әңгіме әлі басталмаған',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            )
          : ListView.builder(
              reverse: true,
              padding: EdgeInsets.zero,
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final m = messages[messages.length - 1 - i];
                final isUser = m.role == ChatRole.user;
                final hasAudio = m.audioBytes != null && m.audioBytes!.isNotEmpty;
                final isThisPlaying = playingAt != null && playingAt == m.at;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? AppColors.primary.withValues(alpha: 0.85)
                          : Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasAudio)
                          _OverlayAudioRow(
                            isUser: isUser,
                            isPlaying: isThisPlaying,
                            onTap: () => ref.read(avatarChatProvider.notifier).playMessageAudio(m),
                          ),
                        if (hasAudio) const SizedBox(height: 6),
                        Text(
                          m.text,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 13.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _OverlayAudioRow extends StatelessWidget {
  final bool isUser;
  final bool isPlaying;
  final VoidCallback onTap;
  const _OverlayAudioRow({
    required this.isUser,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isUser ? Colors.white : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: fg.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: fg.withValues(alpha: 0.4)),
            ),
            child: Icon(
              isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
              size: 18,
              color: fg,
            ),
          ),
          const SizedBox(width: 8),
          // Waveform visual
          ...List.generate(12, (i) {
            final h = 4.0 + ((i + (isPlaying ? DateTime.now().millisecond ~/ 100 : 0)) % 5) * 2.0;
            return Container(
              width: 2,
              height: h,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: fg.withValues(alpha: isPlaying ? 0.95 : 0.6),
                borderRadius: BorderRadius.circular(1),
              ),
            );
          }),
        ],
      ),
    );
  }
}
