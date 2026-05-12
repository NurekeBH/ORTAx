import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/ortax_colors.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../../core/typography/font_provider.dart';
import '../../core/typography/text_scale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final font = ref.watch(fontProvider);
    final textScale = ref.watch(textScaleProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.profileTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _ProfileHeader(),
            const SizedBox(height: 24),
            _SectionLabel(label: t.profileLanguage),
            const SizedBox(height: 8),
            _LanguageTile(
              code: 'kk',
              label: t.profileLanguageKk,
              selected: locale.languageCode == 'kk',
              onTap: () => ref.read(localeProvider.notifier).set(const Locale('kk')),
            ),
            _LanguageTile(
              code: 'ru',
              label: t.profileLanguageRu,
              selected: locale.languageCode == 'ru',
              onTap: () => ref.read(localeProvider.notifier).set(const Locale('ru')),
            ),
            _LanguageTile(
              code: 'en',
              label: t.profileLanguageEn,
              selected: locale.languageCode == 'en',
              onTap: () => ref.read(localeProvider.notifier).set(const Locale('en')),
            ),
            const SizedBox(height: 24),
            _SectionLabel(label: t.profileFont),
            const SizedBox(height: 8),
            ...availableFonts.map((f) => _FontTile(
                  font: f,
                  preview: t.profileFontPreview,
                  selected: f.id == font.id,
                  onTap: () => ref.read(fontProvider.notifier).set(f),
                )),
            const SizedBox(height: 24),
            _SectionLabel(label: t.profileTextSize),
            const SizedBox(height: 8),
            _TextSizeRow(
              current: textScale,
              preview: t.profileTextSizePreview,
              onSelect: (opt) => ref.read(textScaleProvider.notifier).set(opt),
            ),
            const SizedBox(height: 24),
            _SectionLabel(label: t.profileTheme),
            const SizedBox(height: 8),
            _ThemeRow(
              current: themeMode,
              labels: [t.profileThemeSystem, t.profileThemeLight, t.profileThemeDark],
              onSelect: (mode) => ref.read(themeModeProvider.notifier).set(mode),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (!context.mounted) return;
                context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: Text(t.profileLogout),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '${t.profileVersion} 1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 28, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Қонақ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '+7 (___) ___-__-__',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: context.colors.textSecondary,
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LanguageTile({
    required this.code,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.08) : context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : context.colors.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  code.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
              if (selected) const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextSizeRow extends StatelessWidget {
  final TextScaleOption current;
  final String preview;
  final ValueChanged<TextScaleOption> onSelect;
  const _TextSizeRow({
    required this.current,
    required this.preview,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: textScaleOptions.map((opt) {
          final selected = opt.id == current.id;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(opt),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        preview,
                        style: TextStyle(
                          fontSize: 11 + opt.scale * 7,
                          fontWeight: FontWeight.w700,
                          color: selected ? AppColors.textInverse : context.colors.textPrimary,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        opt.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.textInverse.withValues(alpha: 0.85)
                              : context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FontTile extends StatelessWidget {
  final AppFont font;
  final String preview;
  final bool selected;
  final VoidCallback onTap;
  const _FontTile({
    required this.font,
    required this.preview,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.08) : context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : context.colors.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      font.label,
                      style: TextStyle(
                        fontFamily: font.family,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preview,
                      style: TextStyle(
                        fontFamily: font.family,
                        fontSize: 13,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  final ThemeMode current;
  final List<String> labels;
  final ValueChanged<ThemeMode> onSelect;
  const _ThemeRow({
    required this.current,
    required this.labels,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final modes = [
      (ThemeMode.system, Icons.brightness_auto, labels[0]),
      (ThemeMode.light, Icons.light_mode, labels[1]),
      (ThemeMode.dark, Icons.dark_mode, labels[2]),
    ];
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: modes.map((m) {
          final selected = m.$1 == current;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(m.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 72,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(m.$2, size: 22,
                      color: selected ? AppColors.textInverse : context.colors.textPrimary),
                    const SizedBox(height: 6),
                    Text(m.$3,
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: selected ? AppColors.textInverse : context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
