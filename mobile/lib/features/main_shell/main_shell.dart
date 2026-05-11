import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/ortax_colors.dart';
import '../../l10n/app_localizations.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const MainShell({super.key, required this.shell});

  void _onTap(int index) {
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 10.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.accent : context.colors.textSecondary,
              height: 1.1,
              overflow: TextOverflow.ellipsis,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _onTap,
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          backgroundColor: context.colors.surface,
          indicatorColor: AppColors.accent.withValues(alpha: 0.12),
          destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded, color: AppColors.accent),
            label: t.tabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book, color: AppColors.accent),
            label: t.tabJournals,
          ),
          NavigationDestination(
            icon: const Icon(Icons.functions_outlined),
            selectedIcon: const Icon(Icons.functions, color: AppColors.accent),
            label: t.tabAvatar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_none),
            selectedIcon: const Icon(Icons.notifications, color: AppColors.accent),
            label: t.tabMessages,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: AppColors.accent),
            label: t.tabProfile,
          ),
        ],
        ),
      ),
    );
  }
}
