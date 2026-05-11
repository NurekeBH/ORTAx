import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/ortax_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.go('/onboarding');
    });
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
