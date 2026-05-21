import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      final isOnboarding = authState.maybeWhen(
        onboarding: () => true,
        orElse: () => false,
      );
      final isLoading = authState.maybeWhen(
        loading: () => true,
        orElse: () => false,
      );

      if (isLoading) return AppRoutes.splash;
      if (isOnboarding) return AppRoutes.onboarding;
      if (isAuthenticated) {
        final onAuthRoutes = [
          AppRoutes.splash,
          AppRoutes.signIn,
          AppRoutes.signUp,
        ];
        if (onAuthRoutes.contains(state.matchedLocation)) {
          return AppRoutes.home;
        }
      } else {
        final protectedRoutes = [AppRoutes.home, AppRoutes.onboarding];
        if (protectedRoutes.contains(state.matchedLocation)) {
          return AppRoutes.signIn;
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, _) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, _) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, _) => const HomeScreen(),
      ),
    ],
  );
}

abstract final class AppRoutes {
  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
}
