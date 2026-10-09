import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../data/auth_models.dart';
import '../../../../core/analytics/meta_events.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/auth_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

const _googleUnavailable =
    "Google sign-in isn't working right now. Please try again, or sign in with your email and password.";

/// The backend answers 401 when it can't verify a Google/Apple token.
bool _isRejectedToken(Object e) => e is ServerException && e.statusCode == 401;

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? error;

  const AuthState({required this.status, this.user, this.error});

  static const initial = AuthState(status: AuthStatus.loading);
  static const unauthenticated = AuthState(status: AuthStatus.unauthenticated);
  AuthState copyWith({AuthStatus? status, AuthUser? user, String? error}) =>
      AuthState(
          status: status ?? this.status, user: user ?? this.user, error: error);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState.initial) {
    _init();
  }

  Future<void> _init() async {
    // A saved session with no network hiccup resolves in well under 100ms,
    // which flashes the branded /splash screen for a single frame before
    // jumping to /login or /home. Holding it on screen for a minimum beat
    // makes the launch feel intentional instead of a flicker — real slow
    // paths (the 3s/8s timeouts below) are unaffected since they already
    // take longer than this floor.
    final minSplash = Future.delayed(const Duration(milliseconds: 900));
    try {
      final user =
          await _bootstrapSavedSession().timeout(const Duration(seconds: 14));
      await minSplash;
      state = user == null
          ? AuthState.unauthenticated
          : AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      // A slow/unreachable API (timeout, DNS hiccup, server cold start) is
      // not proof the session is invalid — only a real 401 is. Wiping the
      // token here on every transient network failure was forcing a fresh
      // sign-in on almost every cold start against a slow backend. Fall
      // back to the last-known user instead, and let a real 401 from a
      // later request take the user through the normal forceLogout path.
      if (e is UnauthorizedException ||
          (e is ServerException && e.statusCode == 401)) {
        try {
          await _authService
              .clearSession()
              .timeout(const Duration(seconds: 2));
        } catch (_) {}
        await minSplash;
        state = AuthState.unauthenticated;
        return;
      }
      AuthUser? cachedUser;
      try {
        cachedUser = await _authService.getCachedUser();
      } catch (_) {}
      await minSplash;
      state = cachedUser == null
          ? AuthState.unauthenticated
          : AuthState(status: AuthStatus.authenticated, user: cachedUser);
    }
  }

  Future<AuthUser?> _bootstrapSavedSession() async {
    final token =
        await _authService.getToken().timeout(const Duration(seconds: 3));
    if (token == null) return null;

    final user = await _authService.me().timeout(const Duration(seconds: 8));
    await _authService
        .saveSession(token, user)
        .timeout(const Duration(seconds: 2));
    return user;
  }

  /// Returns the [LoginResult] so the screen can navigate to the 2FA
  /// code-entry step when required; null only on a hard failure (the error
  /// is already reflected in [AuthState.error] in that case).
  Future<LoginResult?> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final result = await _authService.login(email, password);
      if (result.requiresTwoFactor) {
        // No session yet — stays logged out until the emailed code is
        // verified. Never leave this on `loading`: the router forces a
        // `/splash` redirect while status is loading, which would fight
        // the screen's own navigation to the code-entry step.
        state = AuthState.unauthenticated;
        return result;
      }
      final res = result.auth!;
      await _authService.saveSession(res.token, res.user);
      state = AuthState(status: AuthStatus.authenticated, user: res.user);
      MetaEvents.instance.identify(res.user.id);
      return result;
    } catch (e) {
      state = AuthState(
          status: AuthStatus.unauthenticated, error: humanizeError(e));
      return null;
    }
  }

  /// Returns null on success (session saved, state authenticated), or an
  /// error message to show inline on the code-entry screen. Deliberately
  /// avoids touching `AuthStatus.loading` for the same reason as [login].
  Future<String?> verifyTwoFactor({
    required String email,
    required String twoFactorToken,
    required String code,
  }) async {
    try {
      final res = await _authService.verifyTwoFactor(
        email: email,
        twoFactorToken: twoFactorToken,
        code: code,
      );
      await _authService.saveSession(res.token, res.user);
      state = AuthState(status: AuthStatus.authenticated, user: res.user);
      MetaEvents.instance.identify(res.user.id);
      return null;
    } catch (e) {
      return humanizeError(e);
    }
  }

  /// Thin passthrough — the code-entry screen shows its own SnackBar from
  /// the returned message or a thrown error.
  Future<String> resendTwoFactor({
    required String email,
    required String twoFactorToken,
  }) {
    return _authService.resendTwoFactor(
        email: email, twoFactorToken: twoFactorToken);
  }

  Future<String?> setTwoFactorEnabled(bool enabled,
      {required String currentPassword}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return 'You need to be signed in.';
      final user = enabled
          ? await _authService.enableTwoFactor(currentPassword)
          : await _authService.disableTwoFactor(currentPassword);
      await _authService.saveSession(token, user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return null;
    } catch (e) {
      return humanizeError(e);
    }
  }

  Future<void> register({
    required String firstName,
    String lastName = '',
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    MetaEvents.instance.registrationAttempted(method: 'email');
    try {
      final res = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        passwordConfirmation: password,
      );
      await _authService.saveSession(res.token, res.user);
      state = AuthState(status: AuthStatus.authenticated, user: res.user);
      MetaEvents.instance.identify(res.user.id);
      MetaEvents.instance
          .registrationCompleted(userId: res.user.id, method: 'email');
    } catch (e) {
      MetaEvents.instance
          .registrationFailed(method: 'email', reason: e.runtimeType.toString());
      state = AuthState(
          status: AuthStatus.unauthenticated, error: humanizeError(e));
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    if (kIsWeb) {
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        error:
            'Google sign-in is not configured for web testing yet. Please sign in with email and password.',
      );
      return;
    }
    MetaEvents.instance.registrationAttempted(method: 'google');
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled
        state = AuthState.unauthenticated;
        return;
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) throw const AppException(_googleUnavailable);

      final res = await _authService.socialLogin(
        provider: 'google',
        token: idToken,
      );
      await _authService.saveSession(res.token, res.user);
      state = AuthState(status: AuthStatus.authenticated, user: res.user);
      MetaEvents.instance.identify(res.user.id);
      MetaEvents.instance
          .registrationCompleted(userId: res.user.id, method: 'google');
    } on PlatformException catch (e) {
      if (e.code == GoogleSignIn.kSignInCanceledError) {
        state = AuthState.unauthenticated;
        return;
      }
      MetaEvents.instance.registrationFailed(
          method: 'google', reason: 'PlatformException:${e.code}:${e.message}');
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.code == GoogleSignIn.kNetworkError
            ? "You're not connected to the internet. Check your connection and try again."
            : _googleUnavailable,
      );
    } catch (e) {
      MetaEvents.instance.registrationFailed(
          method: 'google', reason: e.runtimeType.toString());
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _isRejectedToken(e)
            ? "We couldn't verify your Google account. Please try again."
            : humanizeError(e),
      );
    }
  }

  Future<void> loginWithApple() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    MetaEvents.instance.registrationAttempted(method: 'apple');
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final res = await _authService.socialLogin(
        provider: 'apple',
        token: credential.identityToken ?? '',
        firstName: credential.givenName,
        lastName: credential.familyName,
        authorizationCode: credential.authorizationCode,
      );
      await _authService.saveSession(res.token, res.user);
      state = AuthState(status: AuthStatus.authenticated, user: res.user);
      MetaEvents.instance.identify(res.user.id);
      MetaEvents.instance
          .registrationCompleted(userId: res.user.id, method: 'apple');
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        state = AuthState.unauthenticated;
        return;
      }
      MetaEvents.instance.registrationFailed(
          method: 'apple', reason: 'AppleAuth:${e.code.name}:${e.message}');
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        error:
            "Apple sign-in didn't complete. Please try again, or sign in with your email and password.",
      );
    } catch (e) {
      MetaEvents.instance.registrationFailed(
          method: 'apple', reason: e.runtimeType.toString());
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: _isRejectedToken(e)
            ? "We couldn't verify your Apple ID. Please try again."
            : humanizeError(e),
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    MetaEvents.instance.reset();
    state = AuthState.unauthenticated;
  }

  Future<void> refreshUser() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;
      final user = await _authService.me();
      await _authService.saveSession(token, user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(error: humanizeError(e));
    }
  }

  /// Re-reads the user after onboarding is saved so the router lets them into
  /// the app. Unlike invalidating the provider, this never passes through
  /// `AuthStatus.loading`, so it doesn't bounce the user through the splash.
  /// Returns null on success, or a message to show if it didn't take.
  Future<String?> finishOnboardingRefresh() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return 'You need to be signed in.';
      final user = await _authService.me();
      await _authService.saveSession(token, user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return user.onboardingCompleted
          ? null
          : "We couldn't finish setting up your wedding. Please try again.";
    } catch (e) {
      return humanizeError(e);
    }
  }

  Future<bool> switchWedding(int weddingId) async {
    try {
      await _authService.switchWedding(weddingId);
      await refreshUser();
      return true;
    } catch (e) {
      state = state.copyWith(error: humanizeError(e));
      return false;
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String email,
    String? lastName,
    String? avatarUrl,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;
      final user = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        avatarUrl: avatarUrl,
      );
      await _authService.saveSession(token, user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(error: humanizeError(e));
      return false;
    }
  }

  Future<bool> updatePreferences({
    Map<String, dynamic>? notificationPreferences,
    Map<String, dynamic>? supportPreferences,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;
      final user = await _authService.updatePreferences(
        notificationPreferences: notificationPreferences,
        supportPreferences: supportPreferences,
      );
      await _authService.saveSession(token, user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(error: humanizeError(e));
      return false;
    }
  }

  /// Returns null on success, or an error message to show inline.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null;
    } catch (e) {
      return humanizeError(e);
    }
  }

  /// Returns null on success, or an error message to show inline. On success
  /// the local session is cleared; server-side the account and every wedding
  /// it owns are deleted.
  Future<String?> deleteAccount({String? currentPassword}) async {
    try {
      await _authService.deleteAccount(currentPassword: currentPassword);
      await _authService.clearSession();
      MetaEvents.instance.reset();
      state = AuthState.unauthenticated;
      return null;
    } catch (e) {
      return humanizeError(e);
    }
  }

  /// Called when any API call comes back 401. The token is already dead
  /// server-side, so just clear local session state and surface a clear reason.
  Future<void> forceLogout() async {
    if (state.status == AuthStatus.unauthenticated) return;
    await _authService.clearSession();
    state = AuthState.unauthenticated
        .copyWith(error: 'Your session expired. Please sign in again.');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});
