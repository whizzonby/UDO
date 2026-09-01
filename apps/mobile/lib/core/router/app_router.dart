import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/two_factor_verify_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/plan/presentation/screens/plan_screen.dart';
import '../../features/plan/presentation/screens/seating_screen.dart';
import '../../features/guests/presentation/screens/guests_screen.dart';
import '../../features/live/presentation/screens/live_screen.dart';
import '../../features/gallery/presentation/screens/gallery_screen.dart';
import '../../features/registry/presentation/screens/registry_screen.dart';
import '../../features/more/presentation/screens/more_screen.dart';
import '../../features/wedding_party/presentation/screens/wedding_party_screen.dart';
import '../../features/vision/presentation/screens/your_vision_screen.dart';
import '../../features/vision_style/presentation/screens/vision_style_screen.dart';
import '../../features/memories/presentation/screens/memories_screen.dart';
import '../../features/wedding_story/presentation/screens/wedding_story_screen.dart';
import '../../features/billing/presentation/screens/paywall_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

/// Notifies GoRouter to re-run its `redirect` in place, without GoRouter
/// itself being rebuilt. `routerProvider` must only `ref.listen` (not
/// `ref.watch`) `authProvider` — watching it would rebuild the whole
/// [GoRouter] instance on every auth-state change (e.g. saving a
/// preferences toggle), tearing down the navigator and resetting the app
/// back to '/home'.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    _subscription = ref.listen<AuthState>(authProvider, (_, __) {
      notifyListeners();
    });
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshListenable(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoading = authState.status == AuthStatus.loading;
      final isAuth = authState.status == AuthStatus.authenticated;
      final loc = state.matchedLocation;

      if (isLoading) return loc == '/splash' ? null : '/splash';

      if (!isAuth) {
        if (loc == '/login' ||
            loc == '/register' ||
            loc == '/forgot-password' ||
            loc == '/two-factor') {
          return null;
        }
        return '/login';
      }

      // Authenticated.
      if (!authState.user!.onboardingCompleted) {
        return loc == '/onboarding' ? null : '/onboarding';
      }

      // Every plan (including Free) is real, in-app access with its own
      // usage limits enforced server-side (402s surface an upgrade prompt
      // where the limit was actually hit) — /paywall is a screen users
      // reach voluntarily (e.g. an "Upgrade" button), never a forced gate.
      if (loc == '/splash' ||
          loc == '/login' ||
          loc == '/register' ||
          loc == '/two-factor') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
          path: '/two-factor',
          builder: (_, state) {
            final challenge = state.extra;
            if (challenge is! TwoFactorChallenge) return const LoginScreen();
            return TwoFactorVerifyScreen(challenge: challenge);
          }),
      GoRoute(
          path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/paywall', builder: (_, __) => const PaywallScreen()),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(
              path: '/plan',
              builder: (_, state) => PlanScreen(
                    initialSection: state.uri.queryParameters['section'],
                    initialAction: state.uri.queryParameters['action'],
                  )),
          GoRoute(
              path: '/plan/seating', builder: (_, __) => const SeatingScreen()),
          GoRoute(
              path: '/guests',
              builder: (_, state) => GuestsScreen(
                    initialTab: state.uri.queryParameters['tab'],
                    initialStatusFilter: state.uri.queryParameters['status'],
                    initialInfoFilter: state.uri.queryParameters['info'],
                  )),
          GoRoute(
              path: '/guests/:id',
              builder: (_, state) => GuestProfileScreen(
                  guestId: int.parse(state.pathParameters['id']!))),
          GoRoute(
              path: '/live',
              builder: (_, state) => LiveScreen(
                    resetToken: state.uri.queryParameters['reset'],
                  )),
          GoRoute(path: '/gallery', builder: (_, __) => const GalleryScreen()),
          GoRoute(
              path: '/registry', builder: (_, __) => const RegistryScreen()),
          GoRoute(path: '/more', builder: (_, __) => const MoreScreen()),
          GoRoute(
              path: '/wedding-party',
              builder: (_, state) => WeddingPartyScreen(
                    initialTab: state.uri.queryParameters['tab'],
                  )),
          GoRoute(
              path: '/your-vision',
              builder: (_, __) => const YourVisionScreen()),
          GoRoute(
              path: '/vision-style',
              builder: (_, __) => const VisionStyleScreen()),
          GoRoute(
              path: '/memories', builder: (_, __) => const MemoriesScreen()),
          GoRoute(
              path: '/wedding-story',
              builder: (_, __) => const WeddingStoryScreen()),
        ],
      ),
    ],
  );
});
