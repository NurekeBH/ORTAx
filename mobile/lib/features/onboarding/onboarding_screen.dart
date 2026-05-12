import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/locale/locale_provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/ortax_colors.dart';
import 'onboarding_models.dart';
import 'onboarding_repository.dart';

const _onboardingSeenKey = 'app.onboardingSeen';

Future<void> _markOnboardingSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_onboardingSeenKey, true);
}

const _fallbackSlides = <OnboardingSlideDto>[
  OnboardingSlideDto(
    id: 'fallback-ar',
    position: 0,
    titleKk: 'AR кейіпкерлер',
    titleRu: 'AR-герои',
    titleEn: 'AR characters',
    descriptionKk: 'Журнал бетінен тарихи тұлғалар тірілеп шығады',
    descriptionRu: 'Исторические личности оживают со страниц журнала',
    descriptionEn: 'Historical figures come alive from the journal pages',
  ),
  OnboardingSlideDto(
    id: 'fallback-journal',
    position: 1,
    titleKk: 'Ғылыми журнал',
    titleRu: 'Научный журнал',
    titleEn: 'Science journal',
    descriptionKk: 'Қызықты, түсінікті — оқушыларға арналған',
    descriptionRu: 'Интересно и понятно — для школьников',
    descriptionEn: 'Engaging, clear — made for students',
  ),
  OnboardingSlideDto(
    id: 'fallback-ai',
    position: 2,
    titleKk: 'AI-сөйлесу',
    titleRu: 'AI-диалог',
    titleEn: 'AI conversations',
    descriptionKk: 'Тарихи тұлғадан тікелей сұрақ қойып, жауап ал',
    descriptionRu: 'Задай вопрос исторической личности напрямую и получи ответ',
    descriptionEn: 'Ask questions directly to historical figures',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next(int total) {
    if (_index < total - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await _markOnboardingSeen();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final asyncSlides = ref.watch(onboardingSlidesProvider);
    final locale = ref.watch(localeProvider).languageCode;

    final slides = asyncSlides.maybeWhen(
      data: (data) => data.isEmpty ? _fallbackSlides : data,
      orElse: () => _fallbackSlides,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _SlideView(slide: slides[i], locale: locale),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.accent : context.colors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ElevatedButton(
                onPressed: () => _next(slides.length),
                child: Text(
                  _index == slides.length - 1 ? 'Бастау' : 'Келесі',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final OnboardingSlideDto slide;
  final String locale;
  const _SlideView({required this.slide, required this.locale});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 96,
                height: 96,
                child: _SlideIcon(svg: slide.iconSvg, color: accent),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            slide.title(locale),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.description(locale),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.colors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _SlideIcon extends StatelessWidget {
  final String? svg;
  final Color color;
  const _SlideIcon({required this.svg, required this.color});

  @override
  Widget build(BuildContext context) {
    final raw = svg?.trim();
    if (raw == null || raw.isEmpty) {
      return Icon(Icons.auto_awesome, size: 80, color: color);
    }
    return SvgPicture.string(
      raw,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (_) => Icon(Icons.image, size: 64, color: color),
    );
  }
}
