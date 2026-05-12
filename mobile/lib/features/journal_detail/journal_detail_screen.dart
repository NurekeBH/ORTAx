import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart' show fullAssetUrl;
import '../../core/theme/colors.dart';
import '../../core/theme/ortax_colors.dart';
import '../../l10n/app_localizations.dart';
import '../journals/journal_api_models.dart';
import '../journals/journals_repository.dart';

class JournalDetailScreen extends ConsumerWidget {
  final String journalId;
  const JournalDetailScreen({super.key, required this.journalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(journalDetailProvider(journalId));
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _DetailError(
          message: e.toString(),
          onRetry: () => ref.invalidate(journalDetailProvider(journalId)),
        ),
        data: (journal) => _DetailContent(journal: journal, t: t),
      ),
      bottomNavigationBar: detailAsync.maybeWhen(
        data: (j) => _DetailActions(journal: j, t: t),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final ApiJournalDetail journal;
  final AppLocalizations t;
  const _DetailContent({required this.journal, required this.t});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
                    if (journal.category != null)
                      _Tag(label: journal.category!.name),
                    if ((journal.subject ?? '').isNotEmpty)
                      _Tag(label: journal.subject!),
                    if ((journal.gradeLevel ?? '').isNotEmpty)
                      _Tag(label: journal.gradeLevel!),
                    if (journal.hasAr) const _Tag(label: 'AR', accent: true),
                    if (journal.featured)
                      const _Tag(label: '★ Featured', accent: true),
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
                if ((journal.author ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    journal.author!,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.visibility_outlined,
                        size: 14, color: context.colors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${journal.viewsCount}',
                      style: TextStyle(
                          color: context.colors.textSecondary, fontSize: 12),
                    ),
                  ],
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
                if (journal.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: journal.tags
                        .map((t) => _Tag(label: '#$t'))
                        .toList(),
                  ),
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
                    label: t.journalPageNumber(p.pageNumber),
                    onTap: () => _openFullscreen(context, journal, i),
                  );
                },
              ),
            ),
          ),
        if (journal.pages.any((p) => p.arAssets.isNotEmpty))
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(label: 'AR контент'),
                  const SizedBox(height: 12),
                  ...[
                    for (final p in journal.pages)
                      for (final ar in p.arAssets)
                        _ArAssetTile(page: p, asset: ar),
                  ],
                ],
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  void _openFullscreen(
      BuildContext context, ApiJournalDetail journal, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PagesFullscreenViewer(
          pages: journal.pages,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _DetailActions extends StatelessWidget {
  final ApiJournalDetail journal;
  final AppLocalizations t;
  const _DetailActions({required this.journal, required this.t});

  @override
  Widget build(BuildContext context) {
    final hasPdf = (journal.pdfFullUrl ?? '').isNotEmpty;
    final hasAr = journal.hasAr;
    return SafeArea(
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
              flex: hasAr ? 3 : 1,
              child: ElevatedButton.icon(
                onPressed: hasPdf
                    ? () => _openPdf(context, journal.pdfFullUrl!)
                    : null,
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                label: Text(hasPdf ? 'PDF ашу' : 'PDF қолжетімсіз'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textInverse,
                  minimumSize: const Size.fromHeight(52),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
            if (hasAr) ...[
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final first = _firstArAsset(journal);
                    if (first == null) return;
                    context.push(_arRouteFor(
                      marker: first.asset.triggerMarker,
                      modelUrl: first.asset.modelUrl,
                      imageUrl: first.page.imageUrl,
                      title: journal.title,
                      subtitle: first.page.title,
                    ));
                  },
                  icon: const Icon(Icons.view_in_ar, size: 20),
                  label: Text(t.journalAr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                        color: AppColors.primary, width: 1.4),
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the `/ar/<marker>?modelUrl=...&imageUrl=...&title=...` route so
  /// the AR screen knows which GLB to load instead of relying on the static
  /// asset map.
  String _arRouteFor({
    required String marker,
    String? modelUrl,
    String? imageUrl,
    String? title,
    String? subtitle,
  }) {
    final qp = <String, String>{};
    final m = fullAssetUrl(modelUrl);
    final i = fullAssetUrl(imageUrl);
    if (m != null && m.isNotEmpty) qp['modelUrl'] = m;
    if (i != null && i.isNotEmpty) qp['imageUrl'] = i;
    if (title != null && title.isNotEmpty) qp['title'] = title;
    if (subtitle != null && subtitle.isNotEmpty) qp['subtitle'] = subtitle;
    final uri = Uri(
      path: '/ar/${Uri.encodeComponent(marker)}',
      queryParameters: qp.isEmpty ? null : qp,
    );
    return uri.toString();
  }

  ({ArAsset asset, ApiJournalPage page})? _firstArAsset(
      ApiJournalDetail journal) {
    for (final p in journal.pages) {
      if (p.arAssets.isNotEmpty) {
        return (asset: p.arAssets.first, page: p);
      }
    }
    return null;
  }

  Future<void> _openPdf(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      await Clipboard.setData(ClipboardData(text: url));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF ашылмады, сілтеме көшірілді: $url'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

class _DetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _DetailError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off,
                  size: 56, color: context.colors.textSecondary),
              const SizedBox(height: 16),
              Text(
                'Журналды жүктеу кезінде қате шықты',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, color: context.colors.textSecondary),
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
      ),
    );
  }
}

class _HeroAppBar extends StatelessWidget {
  final ApiJournalDetail journal;
  const _HeroAppBar({required this.journal});

  @override
  Widget build(BuildContext context) {
    final cover = journal.coverImageUrl;
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
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: context.colors.surfaceMuted),
            if (cover != null && cover.isNotEmpty)
              CachedNetworkImage(
                imageUrl: cover,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Icon(
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
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w800),
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
        border:
            accent ? Border.all(color: color.withValues(alpha: 0.4)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (accent && label.toUpperCase() == 'AR') ...[
            const Icon(Icons.view_in_ar, size: 12, color: AppColors.accent),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _PageThumb extends StatelessWidget {
  final ApiJournalPage page;
  final String label;
  final VoidCallback onTap;
  const _PageThumb(
      {required this.page, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasAr = page.arAssets.isNotEmpty;
    final url = page.imageFullUrl;
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
                  child: url != null && url.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: context.colors.textSecondary,
                              size: 32,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.description_outlined,
                            color: context.colors.textSecondary,
                            size: 32,
                          ),
                        ),
                ),
                if (hasAr)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.view_in_ar,
                              size: 10, color: context.colors.textPrimary),
                          const SizedBox(width: 3),
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
            style: TextStyle(
                fontSize: 12,
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ArAssetTile extends StatelessWidget {
  final ApiJournalPage page;
  final ArAsset asset;
  const _ArAssetTile({required this.page, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.view_in_ar,
                color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.triggerMarker,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Page ${page.pageNumber}'
                  '${asset.animationSet != null ? ' · ${asset.animationSet}' : ''}',
                  style: TextStyle(
                      fontSize: 12, color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'AR ашу',
            onPressed: () {
              final qp = <String, String>{};
              final m = fullAssetUrl(asset.modelUrl);
              final i = fullAssetUrl(page.imageUrl);
              if (m != null && m.isNotEmpty) qp['modelUrl'] = m;
              if (i != null && i.isNotEmpty) qp['imageUrl'] = i;
              if (page.title != null && page.title!.isNotEmpty) {
                qp['subtitle'] = page.title!;
              }
              final uri = Uri(
                path: '/ar/${Uri.encodeComponent(asset.triggerMarker)}',
                queryParameters: qp.isEmpty ? null : qp,
              );
              context.push(uri.toString());
            },
            icon: const Icon(Icons.arrow_forward, size: 20),
          ),
        ],
      ),
    );
  }
}

class _PagesFullscreenViewer extends StatefulWidget {
  final List<ApiJournalPage> pages;
  final int initialIndex;
  const _PagesFullscreenViewer({
    required this.pages,
    required this.initialIndex,
  });

  @override
  State<_PagesFullscreenViewer> createState() => _PagesFullscreenViewerState();
}

class _PagesFullscreenViewerState extends State<_PagesFullscreenViewer> {
  late final PageController _ctrl =
      PageController(initialPage: widget.initialIndex);
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
        title: Text('${_index + 1} / ${widget.pages.length}'),
      ),
      body: PageView.builder(
        controller: _ctrl,
        itemCount: widget.pages.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (_, i) {
          final p = widget.pages[i];
          final url = p.imageFullUrl;
          return InteractiveViewer(
            child: Center(
              child: url != null && url.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      errorWidget: (_, _, _) => const Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.white54,
                      ),
                    )
                  : const Icon(Icons.description_outlined,
                      size: 64, color: Colors.white54),
            ),
          );
        },
      ),
    );
  }
}
