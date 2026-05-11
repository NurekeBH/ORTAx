import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';

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

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _recorder.dispose();
    super.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.avatarTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(
              t.avatarSubtitle,
              style: TextStyle(fontSize: 12, color: context.colors.textSecondary, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: state.messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.functions, size: 48, color: AppColors.primary),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              t.avatarEmpty,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      itemCount: state.messages.length,
                      itemBuilder: (_, i) => _MessageBubble(message: state.messages[i]),
                    ),
            ),
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
        ),
      ),
    );
  }
}

class _MessageBubble extends ConsumerWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = message.role == ChatRole.user;
    final canReplay = !isUser && message.audioBytes != null && message.audioBytes!.isNotEmpty;
    final textColor = isUser ? AppColors.textInverse : context.colors.textPrimary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : context.colors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: context.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canReplay)
              _VoicePlayButton(
                onTap: () => ref.read(avatarChatProvider.notifier).playMessageAudio(message),
              ),
            if (canReplay) const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.isVoice && !canReplay) ...[
                  Icon(Icons.mic, size: 14, color: textColor),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    message.text,
                    style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VoicePlayButton extends StatelessWidget {
  final VoidCallback onTap;
  const _VoicePlayButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_arrow_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 4),
              Container(
                width: 70,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(10, (i) {
                    final h = 4.0 + (i % 4) * 2.5;
                    return Container(
                      width: 2,
                      height: h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Дауыс',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
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
