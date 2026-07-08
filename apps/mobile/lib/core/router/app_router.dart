import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/plan/presentation/screens/plan_screen.dart';
import '../../features/guests/presentation/screens/guests_screen.dart';
import '../../features/live/presentation/screens/live_screen.dart';
import '../../features/gallery/presentation/screens/gallery_screen.dart';
import '../../features/registry/presentation/screens/registry_screen.dart';
import '../../features/more/presentation/screens/more_screen.dart';
import '../../features/wedding_party/presentation/screens/wedding_party_screen.dart';
import '../../features/vision/presentation/screens/your_vision_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authState.status == AuthStatus.loading;
      final isAuth = authState.status == AuthStatus.authenticated;
      final loc = state.matchedLocation;

      if (isLoading) return loc == '/splash' ? null : '/splash';

      if (!isAuth) {
        if (loc == '/login' || loc == '/register' || loc == '/forgot-password') return null;
        return '/login';
      }

      // Authenticated
      if (!authState.user!.onboardingCompleted && loc != '/onboarding') {
        return '/onboarding';
      }
      if (loc == '/splash' || loc == '/login' || loc == '/register') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/wedding-party', builder: (_, __) => const WeddingPartyScreen()),
      GoRoute(path: '/your-vision', builder: (_, __) => const YourVisionScreen()),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/plan', builder: (_, __) => const PlanScreen()),
          GoRoute(path: '/guests', builder: (_, __) => const GuestsScreen()),
          GoRoute(path: '/live', builder: (_, __) => const LiveScreen()),
          GoRoute(path: '/gallery', builder: (_, __) => const GalleryScreen()),
          GoRoute(path: '/registry', builder: (_, __) => const RegistryScreen()),
          GoRoute(path: '/more', builder: (_, __) => const MoreScreen()),
        ],
      ),
    ],
  );
});
