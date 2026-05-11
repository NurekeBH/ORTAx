import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/ortax_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/data/mock_journals.dart';
import '../../shared/models/journal.dart';

class JournalDetailScreen extends StatelessWidget {
  final String journalId;
  const JournalDetailScreen({super.key, required this.journalId});

  @override
  Widget build(BuildContext context) {
    final journal = mockJournals.firstWhere(
      (j) => j.id == journalId,
      orElse: () => mockJournals.first,
    );
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        slivers: [
          _HeroAppBar(journal: journal),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                  const SizedBox(height: 14),
                  Text(
                    journal.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(label: t.journalAbout),
                  const SizedBox(height: 8),
                  Text(
                    journal.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.colors.textSecondary,
                          height: 1.55,
                          fontSize: 15,
                        ),
                  ),
                  if (journal.excerpt != null) ...[
                    const SizedBox(height: 28),
                    _SectionHeader(label: t.journalExcerpt),
                    const SizedBox(height: 12),
                    _ExcerptCard(text: journal.excerpt!),
                  ],
                  if (journal.pages.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _SectionHeader(label: t.journalGallery),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
          if (journal.pages.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 240,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  itemCount: journal.pages.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final p = journal.pages[i];
                    return _PageThumb(
                      page: p,
                      label: t.journalPageNumber(p.number),
                      onTap: () => _openFullscreen(context, journal, i),
                    );
                  },
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: Border(top: BorderSide(color: context.colors.border)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: journal.hasAr ? 3 : 1,
                child: ElevatedButton.icon(
                  onPressed: () => _showBuyToast(context, t.journalBuyToast),
                  icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                  label: Text(
                    journal.priceTenge != null
                        ? '${t.journalBuy} · ${t.journalPrice(journal.priceTenge!.toString())}'
                        : t.journalBuy,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textInverse,
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
              if (journal.hasAr) ...[
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/ar/${journal.firstArMarker}'),
                    icon: const Icon(Icons.view_in_ar, size: 20),
                    label: Text(t.journalAr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.4),
                      minimumSize: const Size.fromHeight(52),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showBuyToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openFullscreen(BuildContext context, Journal journal, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PagesFullscreenViewer(journal: journal, initialIndex: initialIndex),
      ),
    );
  }
}

class _HeroAppBar extends StatelessWidget {
  final Journal journal;
  const _HeroAppBar({required this.journal});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      backgroundColor: context.colors.background,
      foregroundColor: context.colors.textPrimary,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Material(
          color: context.colors.surface.withValues(alpha: 0.92),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).maybePop(),
            child: const Icon(Icons.arrow_back, size: 22),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: context.colors.surfaceMuted),
            if (journal.coverAssetPath != null)
              Image.asset(
                journal.coverAssetPath!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.image_not_supported_outlined,
                  size: 64,
                  color: context.colors.textSecondary,
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      context.colors.background.withValues(alpha: 0.0),
                      context.colors.background,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _ExcerptCard extends StatelessWidget {
  final String text;
  const _ExcerptCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: AppColors.accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote, color: AppColors.accent, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        height: 1.6,
                        color: context.colors.textPrimary,
                      ),
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

class _PageThumb extends StatelessWidget {
  final JournalPage page;
  final String label;
  final VoidCallback onTap;
  const _PageThumb({required this.page, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            height: 200,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: page.imageAssetPath != null
                      ? Image.asset(
                          page.imageAssetPath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Center(
                            child: Icon(Icons.image_outlined, color: context.colors.textSecondary, size: 32),
                          ),
                        )
                      : Center(
                          child: Icon(Icons.description_outlined, color: context.colors.textSecondary, size: 32),
                        ),
                ),
                if (page.arMarkerId != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.view_in_ar, size: 10, color: context.colors.textPrimary),
                          SizedBox(width: 3),
                          Text(
                            'AR',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: context.colors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _PagesFullscreenViewer extends StatefulWidget {
  final Journal journal;
  final int initialIndex;
  const _PagesFullscreenViewer({required this.journal, required this.initialIndex});

  @override
  State<_PagesFullscreenViewer> createState() => _PagesFullscreenViewerState();
}

class _PagesFullscreenViewerState extends State<_PagesFullscreenViewer> {
  late final PageController _ctrl = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${_index + 1} / ${widget.journal.pages.length}'),
      ),
      body: PageView.builder(
        controller: _ctrl,
        itemCount: widget.journal.pages.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, i) {
          final p = widget.journal.pages[i];
          return InteractiveViewer(
            child: Center(
              child: p.imageAssetPath != null
                  ? Image.asset(
                      p.imageAssetPath!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.white54,
                      ),
                    )
                  : const Icon(Icons.description_outlined, size: 64, color: Colors.white54),
            ),
          );
        },
      ),
    );
  }
}
