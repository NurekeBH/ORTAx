import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ar/ar_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/journal_detail/journal_detail_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/splash/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/reset-password',
        builder: (_, _) => const ResetPasswordScreen(),
      ),
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: '/journal/:id',
        builder: (_, state) =>
            JournalDetailScreen(journalId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/ar/:markerId',
        builder: (_, state) =>
            ArScreen(markerId: state.pathParameters['markerId']!),
      ),
    ],
  );
});
