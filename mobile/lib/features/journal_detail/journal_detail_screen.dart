import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../shared/data/mock_journals.dart';
import '../../shared/models/journal.dart';

class JournalDetailScreen extends StatefulWidget {
  final String journalId;
  const JournalDetailScreen({super.key, required this.journalId});

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final journal = mockJournals.firstWhere(
      (j) => j.id == widget.journalId,
      orElse: () => mockJournals.first,
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceMuted,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceMuted,
        title: Text(journal.title, style: const TextStyle(fontSize: 18)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: journal.pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _PageView(page: journal.pages[i]),
              ),
            ),
            _PageIndicator(total: journal.pages.length, current: _index),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  final JournalPage page;
  const _PageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: AppColors.surface,
                width: double.infinity,
                child: page.imageAssetPath != null
                    ? Image.asset(
                        page.imageAssetPath!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          page.text ?? 'Бет ${page.number}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
              ),
            ),
          ),
          if (page.arMarkerId != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/ar/${page.arMarkerId}'),
              icon: const Icon(Icons.view_in_ar),
              label: const Text('AR-да жандандыру'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int total;
  final int current;
  const _PageIndicator({required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
