import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../data/auth_models.dart';
import '../../../../core/network/auth_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

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
    try {
      final token =
          await _authService.getToken().timeout(const Duration(seconds: 3));
      if (token == null) {
        state = AuthState.unauthenticated;
        return;
      }
      final user = await _authService.me().timeout(const Duration(seconds: 8));
      await _authService.saveSession(token, user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      state = AuthState.unauthenticated;
    }
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
      return result;
    } catch (e) {
      final message = e.toString().contains('Null check operator')
          ? 'Google sign-in is not fully configured yet. Please sign in with email and password.'
          : e.toString();
      state = AuthState(status: AuthStatus.unauthenticated, error: message);
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
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Thin passthrough — the code-entry screen shows its own SnackBar from
  /// the returned message or a thrown error.
  Future<String> resendTwoFactor({
    required String email,
    required String twoFactorToken,
  }) {
    return _authService.resendTwoFactor(email: email, twoFactorToken: twoFactorToken);
  }

  Future<String?> setTwoFactorEnabled(bool enabled, {required String currentPassword}) async {
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
      return e.toString();
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
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
    } catch (e) {
      state =
          AuthState(status: AuthStatus.unauthenticated, error: e.toString());
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
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled
        state = AuthState.unauthenticated;
        return;
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) throw Exception('Google sign-in: no ID token');

      final res = await _authService.socialLogin(
        provider: 'google',
        token: idToken,
      );
      await _authService.saveSession(res.token, res.user);
      state = AuthState(status: AuthStatus.authenticated, user: res.user);
    } catch (e) {
      state =
          AuthState(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> loginWithApple() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
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
      );
      await _authService.saveSession(res.token, res.user);
      state = AuthState(status: AuthStatus.authenticated, user: res.user);
    } catch (e) {
      state =
          AuthState(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
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
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> switchWedding(int weddingId) async {
    try {
      await _authService.switchWedding(weddingId);
      await refreshUser();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
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
      state = state.copyWith(error: e.toString());
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
      state = state.copyWith(error: e.toString());
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
      return e.toString();
    }
  }

  /// Returns null on success, or an error message to show inline. On success
  /// the local session is cleared and the account is anonymized server-side.
  Future<String?> deleteAccount({String? currentPassword}) async {
    try {
      await _authService.deleteAccount(currentPassword: currentPassword);
      await _authService.clearSession();
      state = AuthState.unauthenticated;
      return null;
    } catch (e) {
      return e.toString();
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
