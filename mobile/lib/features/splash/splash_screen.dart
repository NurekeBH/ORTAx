import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/ortax_colors.dart';
import '../auth/auth_controller.dart';

const _onboardingSeenKey = 'app.onboardingSeen';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Auth provider-ді ерте оқып, _load() іске қосылсын
    ref.read(authProvider);
    _route();
  }

  Future<void> _route() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final token = prefs.getString('auth.token');
    if (token != null && token.isNotEmpty) {
      context.go('/home');
      return;
    }

    final onboardingSeen = prefs.getBool(_onboardingSeenKey) ?? false;
    context.go(onboardingSeen ? '/login' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_stories, size: 96, color: AppColors.accent),
            const SizedBox(height: 24),
            Text(
              'AljabrA Labs',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Білім — өткеннен болашаққа көпір',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colors.accentSoft,
                  ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
