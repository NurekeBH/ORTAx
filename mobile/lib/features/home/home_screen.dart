import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/ortax_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/data/mock_journals.dart';
import '../../shared/widgets/journal_grid_card.dart';

class _SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'all';
  void set(String id) => state = id;
}

final _selectedCategoryProvider =
    NotifierProvider<_SelectedCategoryNotifier, String>(_SelectedCategoryNotifier.new);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final selected = ref.watch(_selectedCategoryProvider);

    final categories = [
      _Category('all', t.categoryAll, AppColors.primary),
      _Category('Ғылым', t.categoryScience, const Color(0xFF7C3AED)),
      _Category('Табиғат', t.categoryNature, const Color(0xFF16A34A)),
      _Category('Ғарыш', t.categorySpace, const Color(0xFF0EA5E9)),
      _Category('Тарих', t.categoryHistory, const Color(0xFFB45309)),
      _Category('Әдебиет', t.categoryLiterature, const Color(0xFFDB2777)),
    ];

    final filtered = selected == 'all'
        ? mockJournals
        : mockJournals.where((j) => j.subject == selected).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(t.tabHome, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _KhwarizmiHero(
              title: t.homeHeroTitle,
              subtitle: t.homeHeroSubtitle,
              cta: t.homeHeroCta,
              onTap: () => context.go('/avatar'),
            ),
            const SizedBox(height: 28),
            Text(
              t.homeCategoriesTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final c = categories[i];
                  final isSelected = c.id == selected;
                  return _CategoryChip(
                    label: c.label,
                    color: c.color,
                    selected: isSelected,
                    onTap: () => ref.read(_selectedCategoryProvider.notifier).set(c.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    t.homePopularTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/journals'),
                  child: Text(
                    t.homeSeeAll,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    '—',
                    style: TextStyle(color: context.colors.textSecondary.withValues(alpha: 0.6), fontSize: 24),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.6,
                ),
                itemCount: filtered.length,
                itemBuilder: (_, i) => JournalGridCard(journal: filtered[i]),
              ),
          ],
        ),
      ),
    );
  }
}

class _Category {
  final String id;
  final String label;
  final Color color;
  const _Category(this.id, this.label, this.color);
}

class _KhwarizmiHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;
  const _KhwarizmiHero({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.18),
                      AppColors.accent.withValues(alpha: 0.22),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.functions, size: 38, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: Text(cta),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : context.colors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.35),
              width: selected ? 1.6 : 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check, size: 16, color: color),
                const SizedBox(width: 6),
              ] else ...[
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected ? color : context.colors.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

