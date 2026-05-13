import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart' show fullAssetUrl;
import '../../core/theme/colors.dart';
import '../../core/theme/ortax_colors.dart';
import '../../l10n/app_localizations.dart';
import 'avatar_chat_controller.dart';
import 'avatar_history_sheet.dart';
import 'avatar_repository.dart';

/// Tab3-тің кіру нүктесі. Хорезмидің портретін көрсетеді және астында
/// екі режимді ұсынады:
///   • Чат — мәтін/дауыс (бар [AvatarScreen])
///   • Видео — LiveAvatar streaming ([LiveAvatarScreen])
class AvatarHubScreen extends ConsumerWidget {
  const AvatarHubScreen({super.key});

  Future<void> _openHistory(BuildContext context, WidgetRef ref) async {
    final selected = await AvatarHistorySheet.show(context, character: 'khwarizmi');
    if (selected == null || !context.mounted) return;
    await ref.read(avatarChatProvider.notifier).loadConversation(selected);
    if (!context.mounted) return;
    context.push('/chat');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.avatarTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Чат тарихы',
            onPressed: () => _openHistory(context, ref),
            icon: const Icon(Icons.history),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: _PortraitCard(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.avatarTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                t.avatarSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/chat'),
                  icon: const Icon(Icons.chat_bubble_rounded),
                  label: Text(t.onboardingStart),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortraitCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncChar = ref.watch(khwarizmiCharacterProvider);
    final remoteUrl = asyncChar.maybeWhen(
      data: (c) => fullAssetUrl(c?.imageUrl),
      orElse: () => null,
    );

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.12),
              AppColors.accent.withValues(alpha: 0.18),
            ],
          ),
          border: Border.all(color: context.colors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: remoteUrl != null && remoteUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: remoteUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) => _localAsset(),
                errorWidget: (_, _, _) => _localAsset(),
              )
            : _localAsset(),
      ),
    );
  }

  Widget _localAsset() => Image.asset(
        'assets/avatar/khwarizmi.png',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _PortraitFallback(),
      );
}

class _PortraitFallback extends StatelessWidget {
  const _PortraitFallback();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.functions,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Әл-Хорезми',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }
}
