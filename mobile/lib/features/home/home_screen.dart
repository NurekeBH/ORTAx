import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/ortax_colors.dart';
import '../../l10n/app_localizations.dart';
import '../journals/journal_api_models.dart';
import '../journals/journals_repository.dart';

class _SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null; // null = all
  void set(String? slug) => state = slug;
}

final _selectedCategoryProvider =
    NotifierProvider<_SelectedCategoryNotifier, String?>(_SelectedCategoryNotifier.new);

final _homeJournalsProvider = FutureProvider<List<ApiJournal>>((ref) async {
  final selected = ref.watch(_selectedCategoryProvider);
  final repo = ref.watch(journalsRepositoryProvider);
  return repo.fetchJournals(categorySlug: selected);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final selected = ref.watch(_selectedCategoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final journalsAsync = ref.watch(_homeJournalsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(t.tabHome, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(categoriesProvider);
            ref.invalidate(_homeJournalsProvider);
            await Future.delayed(const Duration(milliseconds: 400));
          },
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
                child: categoriesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (cats) {
                    final items = <_CategoryItem>[
                      _CategoryItem(slug: null, label: t.categoryAll),
                      for (final c in cats) _CategoryItem(slug: c.slug, label: c.name),
                    ];
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final c = items[i];
                        final isSelected = c.slug == selected;
                        return _CategoryChip(
                          label: c.label,
                          selected: isSelected,
                          onTap: () => ref.read(_selectedCategoryProvider.notifier).set(c.slug),
                        );
                      },
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
              journalsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Желі қатесі',
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                  ),
                ),
                data: (journals) {
                  if (journals.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          '—',
                          style: TextStyle(
                            color: context.colors.textSecondary.withValues(alpha: 0.6),
                            fontSize: 24,
                          ),
                        ),
                      ),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.6,
                    ),
                    itemCount: journals.length,
                    itemBuilder: (_, i) => _ApiJournalCard(journal: journals[i]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String? slug;
  final String label;
  const _CategoryItem({required this.slug, required this.label});
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

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
            color: selected ? AppColors.primary.withValues(alpha: 0.1) : context.colors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? AppColors.primary : context.colors.border,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.primary : context.colors.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiJournalCard extends StatelessWidget {
  final ApiJournal journal;
  const _ApiJournalCard({required this.journal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/journal/${journal.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: context.colors.surfaceMuted,
                child: journal.coverImageUrl != null && journal.coverImageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: journal.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Icon(
                          Icons.image_not_supported_outlined,
                          size: 36,
                          color: context.colors.textSecondary,
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.menu_book, size: 48, color: AppColors.primary),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (journal.category != null)
                    Text(
                      journal.category!.name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    journal.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
