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
      AuthState(status: status ?? this.status, user: user ?? this.user, error: error);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState.initial) {
    _init();
  }

  Future<void> _init() async {
    try {
      final token = await _authService.getToken()
          .timeout(const Duration(seconds: 3));
      if (token == null) {
        state = AuthState.unauthenticated;
        return;
      }
      final user = await _authService.me()
          .timeout(const Duration(seconds: 8));
      await _authService.saveSession(token, user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      state = AuthState.unauthenticated;
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final res = await _authService.login(email, password);
      await _authService.saveSession(res.token, res.user);
      state = AuthState(status: AuthStatus.authenticated, user: res.user);
    } catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> register({
    required String firstName, required String lastName,
    required String email, required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final res = await _authService.register(
        firstName: firstName, lastName: lastName,
        email: email, password: password,
        passwordConfirmation: password,
      );
      await _authService.saveSession(res.token, res.user);
      state = AuthState(status: AuthStatus.authenticated, user: res.user);
    } catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
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
      state = AuthState(status: AuthStatus.unauthenticated, error: e.toString());
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
      state = AuthState(status: AuthStatus.unauthenticated, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.unauthenticated;
  }

  /// Called when any API call comes back 401 — the token is already dead
  /// server-side, so there's nothing to notify the backend of; just clear
  /// local session state and surface a clear reason on the login screen
  /// instead of leaving whatever screen was open showing a generic error.
  Future<void> forceLogout() async {
    if (state.status == AuthStatus.unauthenticated) return;
    await _authService.clearSession();
    state = AuthState.unauthenticated.copyWith(error: 'Your session expired. Please sign in again.');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});
