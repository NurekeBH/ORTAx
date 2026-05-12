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

  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;
  bool _wasAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final c = VideoPlayerController.asset('assets/avatar/video.mp4');
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
    // Чат бетінен шыққанда дауысты + видеоны тоқтату
    ref.read(avatarChatProvider.notifier).stopAudio();
    _videoCtrl?.pause();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _recorder.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  void _syncVideoToAudio(bool audioPlaying) {
    final v = _videoCtrl;
    if (v == null || !_videoReady) return;
    if (audioPlaying && !_wasAudioPlaying) {
      v.setVolume(0);
      v.play();
    } else if (!audioPlaying && _wasAudioPlaying) {
      v.pause();
      v.seekTo(Duration.zero);
    }
    _wasAudioPlaying = audioPlaying;
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
      _syncVideoToAudio(next.isAudioPlaying);
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
          // 3. Чат тарихы + композер
          SafeArea(child: _buildChatColumn(context, t, state)),
        ],
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


