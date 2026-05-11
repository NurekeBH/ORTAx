import 'package:flutter/material.dart';

import '../../core/theme/ortax_colors.dart';
import '../../l10n/app_localizations.dart';

class _Notification {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  final bool unread;
  const _Notification({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
  });
}

const _mockNotifications = <_Notification>[
  _Notification(
    icon: Icons.auto_stories,
    color: Color(0xFF7C3AED),
    title: 'Жаңа журнал',
    body: '"Шоқан Уәлиханов" журналы қосылды. Жетісу мен Қашғар туралы оқыңыз.',
    time: '15 мин бұрын',
    unread: true,
  ),
  _Notification(
    icon: Icons.functions,
    color: Color(0xFFD4AF37),
    title: 'Әл-Хорезми сізді күтеді',
    body: 'Бүгін алгебра туралы сұрағыңызды қойып, дауыспен жауап алыңыз.',
    time: '2 сағ бұрын',
    unread: true,
  ),
  _Notification(
    icon: Icons.view_in_ar,
    color: Color(0xFF16A34A),
    title: 'AR жаңалығы',
    body: 'Әл-Фараби журналының 2-бетінде "Күн жүйесі" моделі қол жетімді.',
    time: 'Кеше',
  ),
];

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(t.messagesTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          itemCount: _mockNotifications.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _NotificationCard(notification: _mockNotifications[i]),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final _Notification notification;
  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.unread
              ? notification.color.withValues(alpha: 0.4)
              : context.colors.border,
          width: notification.unread ? 1.4 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: notification.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(notification.icon, color: notification.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                    if (notification.unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: notification.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notification.time,
                  style: TextStyle(
                    color: context.colors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
