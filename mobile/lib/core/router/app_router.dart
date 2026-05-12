import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ar/ar_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/avatar/avatar_hub_screen.dart';
import '../../features/avatar/avatar_screen.dart';
import '../../features/avatar/live_avatar_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/journal_detail/journal_detail_screen.dart';
import '../../features/journals/journals_screen.dart';
import '../../features/main_shell/main_shell.dart';
import '../../features/messages/messages_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
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
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/journals', builder: (_, _) => const JournalsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/avatar',
              builder: (_, _) => const AvatarHubScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/messages', builder: (_, _) => const MessagesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          ]),
        ],
      ),
      // Chat / Live — shell-ден тыс, толық экран (tabs көрінбейді)
      GoRoute(path: '/chat', builder: (_, _) => const AvatarScreen()),
      GoRoute(path: '/avatar-live', builder: (_, _) => const LiveAvatarScreen()),
      GoRoute(
        path: '/journal/:id',
        builder: (_, state) =>
            JournalDetailScreen(journalId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/ar/:markerId',
        builder: (_, state) => ArScreen(
          markerId: state.pathParameters['markerId']!,
          modelUrl: state.uri.queryParameters['modelUrl'],
          imageUrl: state.uri.queryParameters['imageUrl'],
          title: state.uri.queryParameters['title'],
          subtitle: state.uri.queryParameters['subtitle'],
        ),
      ),
    ],
  );
});
