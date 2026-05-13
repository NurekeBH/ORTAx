import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/ortax_colors.dart';
import 'avatar_chat_controller.dart';
import 'avatar_repository.dart';

/// Аватар чатының тарихы — қолданушының бар сессияларын көрсетеді.
/// Pop нәтижесі — таңдалған `conversationId` (немесе `null`).
class AvatarHistorySheet extends ConsumerStatefulWidget {
  final String character;
  const AvatarHistorySheet({super.key, required this.character});

  static Future<String?> show(BuildContext context, {required String character}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AvatarHistorySheet(character: character),
    );
  }

  @override
  ConsumerState<AvatarHistorySheet> createState() => _AvatarHistorySheetState();
}

class _AvatarHistorySheetState extends ConsumerState<AvatarHistorySheet> {
  late Future<List<AvatarHistorySession>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<AvatarHistorySession>> _load() {
    return ref.read(avatarRepositoryProvider).fetchHistory(widget.character);
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(local.year, local.month, local.day);
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    if (d == today) return 'Бүгін, $hh:$mm';
    if (d == today.subtract(const Duration(days: 1))) return 'Кеше, $hh:$mm';
    final dd = local.day.toString().padLeft(2, '0');
    final mo = local.month.toString().padLeft(2, '0');
    return '$dd.$mo.${local.year}, $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    Icon(Icons.history, color: context.colors.textPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'Чат тарихы',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Жаңарту',
                      onPressed: () => setState(() => _future = _load()),
                      icon: const Icon(Icons.refresh),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        ref
                            .read(avatarChatProvider.notifier)
                            .startNewConversation();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Жаңа'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: FutureBuilder<List<AvatarHistorySession>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      final err = snap.error;
                      final isAuth = err is DioException &&
                          err.response?.statusCode == 401;
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            isAuth
                                ? 'Тарихты көру үшін кіріңіз'
                                : 'Тарих жүктелмеді',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: context.colors.textSecondary),
                          ),
                        ),
                      );
                    }
                    final sessions = snap.data ?? const <AvatarHistorySession>[];
                    if (sessions.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Әңгімелер тарихы әлі бос',
                            style: TextStyle(color: context.colors.textSecondary),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: sessions.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: context.colors.border),
                      itemBuilder: (_, i) {
                        final s = sessions[i];
                        final preview = s.lastMessage.replaceAll('\n', ' ').trim();
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.12),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            preview.isEmpty ? 'Бос әңгіме' : preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${_formatDate(s.updatedAt)} • ${s.messageCount} хабар',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.textSecondary,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () =>
                              Navigator.of(context).pop(s.conversationId),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
