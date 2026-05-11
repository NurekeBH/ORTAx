import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/ortax_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/data/mock_journals.dart';
import '../../shared/models/journal.dart';
import '../../shared/widgets/journal_grid_card.dart';

class _JournalsFilterNotifier extends Notifier<String> {
  @override
  String build() => 'all';
  void set(String id) => state = id;
}

final _journalsFilterProvider =
    NotifierProvider<_JournalsFilterNotifier, String>(
      _JournalsFilterNotifier.new,
    );

class _JournalsQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String q) => state = q;
}

final _journalsQueryProvider = NotifierProvider<_JournalsQueryNotifier, String>(
  _JournalsQueryNotifier.new,
);

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
    final filter = ref.watch(_journalsFilterProvider);
    final query = ref.watch(_journalsQueryProvider).trim().toLowerCase();
    final viewMode = ref.watch(_journalsViewModeProvider);

    final categories = [
      _Category('all', t.categoryAll),
      _Category('Ғылым', t.categoryScience),
      _Category('Табиғат', t.categoryNature),
      _Category('Ғарыш', t.categorySpace),
      _Category('Әдебиет', t.categoryLiterature),
    ];

    final filtered = mockJournals.where((j) {
      final byCategory = filter == 'all' || j.subject == filter;
      final byQuery =
          query.isEmpty ||
          j.title.toLowerCase().contains(query) ||
          j.description.toLowerCase().contains(query) ||
          j.subject.toLowerCase().contains(query);
      return byCategory && byQuery;
    }).toList();

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
                    ref.read(_journalsQueryProvider.notifier).set(v),
                decoration: InputDecoration(
                  hintText: t.homeSearch,
                  prefixIcon: const Icon(Icons.search, size: 22),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref.read(_journalsQueryProvider.notifier).set('');
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
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final c = categories[i];
                  final isSelected = c.id == filter;
                  return _CategoryChip(
                    label: c.label,
                    selected: isSelected,
                    onTap: () =>
                        ref.read(_journalsFilterProvider.notifier).set(c.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState(query: query, t: t)
                  : viewMode == JournalsViewMode.list
                  ? ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _JournalCard(journal: filtered[i]),
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
                      itemCount: filtered.length,
                      itemBuilder: (_, i) =>
                          JournalGridCard(journal: filtered[i]),
                    ),
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
  const _Category(this.id, this.label);
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({
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
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  final Journal journal;
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
                child: Container(
                  color: context.colors.surfaceMuted,
                  child: journal.coverAssetPath != null
                      ? Image.asset(
                          journal.coverAssetPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: context.colors.textSecondary,
                          ),
                        )
                      : const Icon(
                          Icons.menu_book,
                          size: 64,
                          color: AppColors.primary,
                        ),
                ),
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
                      _Tag(label: journal.subject),
                      _Tag(label: journal.gradeLevel),
                      if (journal.hasAr) _Tag(label: 'AR', accent: true),
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
                ],
              ),
            ),
          ],
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (accent) ...[
            const Icon(Icons.view_in_ar, size: 12, color: AppColors.accent),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
