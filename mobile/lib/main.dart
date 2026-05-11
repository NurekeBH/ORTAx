import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/locale/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/ortax_colors.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/typography/font_provider.dart';
import 'core/typography/text_scale_provider.dart';
import 'l10n/app_localizations.dart';
import 'shared/widgets/science_doodle_background.dart';

void main() {
  runApp(const ProviderScope(child: OrtaxApp()));
}

class OrtaxApp extends ConsumerWidget {
  const OrtaxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    final font = ref.watch(fontProvider);
    final textScale = ref.watch(textScaleProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'AljabrA Labs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(fontFamily: font.family),
      darkTheme: AppTheme.dark(fontFamily: font.family),
      themeMode: themeMode,
      routerConfig: router,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final colors = OrtaxColors.of(context);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale.scale),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: colors.background)),
              const Positioned.fill(
                child: IgnorePointer(child: ScienceDoodleBackground()),
              ),
              child ?? const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }
}
