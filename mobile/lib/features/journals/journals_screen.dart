import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/ortax_colors.dart';
import '../../l10n/app_localizations.dart';
import 'journal_api_models.dart';
import 'journals_repository.dart';

enum JournalsViewMode { list, grid }

class _JournalsViewModeNotifier extends Notifier<JournalsViewMode> {
  @override
  JournalsViewMode build() => JournalsViewMode.grid;
  void toggle() => state = state == JournalsViewMode.list
      ? JournalsViewMode.grid
      : JournalsViewMode.list;
}

final _journalsViewModeProvider =
    NotifierProvider<_JournalsViewModeNotifier, JournalsViewMode>(
  _JournalsViewModeNotifier.new,
);

class JournalsScreen extends ConsumerStatefulWidget {
  const JournalsScreen({super.key});

  @override
  ConsumerState<JournalsScreen> createState() => _JournalsScreenState();
}

class _JournalsScreenState extends ConsumerState<JournalsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final query = ref.watch(journalsQueryProvider);
    final viewMode = ref.watch(_journalsViewModeProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final journalsAsync = ref.watch(journalsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t.tabJournals,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(_journalsViewModeProvider.notifier).toggle(),
            icon: Icon(
              viewMode == JournalsViewMode.list
                  ? Icons.grid_view_rounded
                  : Icons.view_list_rounded,
            ),
            tooltip: viewMode == JournalsViewMode.list ? 'Грид' : 'Список',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) =>
                    ref.read(journalsQueryProvider.notifier).setSearch(v),
                decoration: InputDecoration(
                  hintText: t.homeSearch,
                  prefixIcon: const Icon(Icons.search, size: 22),
                  suffixIcon: (query.search ?? '').isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref
                                .read(journalsQueryProvider.notifier)
                                .setSearch(null);
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: context.colors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            _CategoryChipsBar(
              categoriesAsync: categoriesAsync,
              selectedSlug: query.categorySlug,
              onSelect: (slug) =>
                  ref.read(journalsQueryProvider.notifier).setCategory(slug),
              allLabel: t.categoryAll,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: journalsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorState(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(journalsProvider),
                ),
                data: (journals) {
                  if (journals.isEmpty) {
                    return _EmptyState(query: query.search ?? '', t: t);
                  }
                  return viewMode == JournalsViewMode.list
                      ? ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          itemCount: journals.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) =>
                              _JournalCard(journal: journals[i]),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.6,
                          ),
                          itemCount: journals.length,
                          itemBuilder: (_, i) =>
                              _JournalGridTile(journal: journals[i]),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChipsBar extends StatelessWidget {
  final AsyncValue<List<JournalCategory>> categoriesAsync;
  final String? selectedSlug;
  final ValueChanged<String?> onSelect;
  final String allLabel;
  const _CategoryChipsBar({
    required this.categoriesAsync,
    required this.selectedSlug,
    required this.onSelect,
    required this.allLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: categoriesAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
        data: (categories) {
          final items = <Widget>[
            _CategoryChip(
              label: allLabel,
              icon: null,
              selected: selectedSlug == null,
              onTap: () => onSelect(null),
            ),
            ...categories.map(
              (c) => _CategoryChip(
                label: c.name,
                icon: c.icon,
                selected: c.slug == selectedSlug,
                onTap: () => onSelect(c.slug),
              ),
            ),
          ];
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => items[i],
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String? icon;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.label,
    required this.icon,
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
            color: selected
                ? AppColors.primary.withValues(alpha: 0.1)
                : context.colors.surface,
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
              ] else if (icon != null && icon!.isNotEmpty) ...[
                Text(icon!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? AppColors.primary
                      : context.colors.textPrimary,
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: context.colors.textSecondary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Қайталау'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  final AppLocalizations t;
  const _EmptyState({required this.query, required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: context.colors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 40,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              query.isEmpty ? '—' : '"$query"',
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  final ApiJournal journal;
  const _JournalCard({required this.journal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/journal/${journal.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: _CoverImage(url: journal.coverImageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (journal.category != null)
                        _Tag(label: journal.category!.name)
                      else if ((journal.subject ?? '').isNotEmpty)
                        _Tag(label: journal.subject!),
                      if ((journal.gradeLevel ?? '').isNotEmpty)
                        _Tag(label: journal.gradeLevel!),
                      if (journal.featured)
                        const _Tag(label: '★', accent: true),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    journal.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    journal.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.colors.textSecondary,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.visibility_outlined,
                          size: 14, color: context.colors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${journal.viewsCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
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

class _JournalGridTile extends StatelessWidget {
  final ApiJournal journal;
  const _JournalGridTile({required this.journal});

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
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _CoverImage(url: journal.coverImageUrl),
                  if (journal.featured)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '★',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (journal.category != null)
                      Text(
                        journal.category!.name,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
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
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.visibility_outlined,
                            size: 12, color: context.colors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          '${journal.viewsCount}',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? url;
  const _CoverImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        color: context.colors.surfaceMuted,
        child: const Icon(Icons.menu_book, size: 48, color: AppColors.primary),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: context.colors.surfaceMuted),
      errorWidget: (_, _, _) => Container(
        color: context.colors.surfaceMuted,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: context.colors.textSecondary,
          size: 36,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final bool accent;
  const _Tag({required this.label, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final color = accent ? AppColors.accent : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: accent ? Border.all(color: color.withValues(alpha: 0.4)) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
