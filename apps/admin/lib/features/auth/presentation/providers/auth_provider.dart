import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../onboarding/data/models/onboarding_data.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/auth_state.dart';

part 'auth_provider.g.dart';

final googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
);

@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  AuthState build() {
    _checkStoredAuth();
    return const AuthState.loading();
  }

  Future<void> _checkStoredAuth() async {
    final datasource = ref.read(authRemoteDatasourceProvider);
    final token = await datasource.getStoredToken();

    if (token == null) {
      state = const AuthState.unauthenticated();
      return;
    }

    try {
      final user = await datasource.getCurrentUser();
      if (user.onboardingComplete) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.onboarding();
      }
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final datasource = ref.read(authRemoteDatasourceProvider);
      final response = await datasource.signInWithEmail(
        email: email,
        password: password,
      );
      if (response.user.onboardingComplete) {
        state = AuthState.authenticated(response.user);
      } else {
        state = const AuthState.onboarding();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
      rethrow;
    }
  }

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final datasource = ref.read(authRemoteDatasourceProvider);
      final response = await datasource.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      if (response.user.onboardingComplete) {
        state = AuthState.authenticated(response.user);
      } else {
        state = const AuthState.onboarding();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        state = const AuthState.unauthenticated();
        return;
      }
      final auth = await googleUser.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        state = const AuthState.unauthenticated();
        return;
      }
      final datasource = ref.read(authRemoteDatasourceProvider);
      final response = await datasource.signInWithGoogle(idToken);
      if (response.user.onboardingComplete) {
        state = AuthState.authenticated(response.user);
      } else {
        state = const AuthState.onboarding();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
      rethrow;
    }
  }

  Future<void> signInWithApple() async {
    state = const AuthState.loading();
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final datasource = ref.read(authRemoteDatasourceProvider);
      final fullName = [
        credential.givenName,
        credential.familyName,
      ].where((s) => s != null).join(' ');
      final response = await datasource.signInWithApple(
        authorizationCode: credential.authorizationCode,
        identityToken: credential.identityToken ?? '',
        fullName: fullName.isEmpty ? null : fullName,
        email: credential.email,
      );
      if (response.user.onboardingComplete) {
        state = AuthState.authenticated(response.user);
      } else {
        state = const AuthState.onboarding();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final datasource = ref.read(authRemoteDatasourceProvider);
      await datasource.signOut();
      await googleSignIn.signOut();
    } finally {
      state = const AuthState.unauthenticated();
    }
  }

  void completeOnboarding(dynamic user) {
    state = AuthState.authenticated(user);
  }

  Future<void> submitOnboarding(OnboardingData data) async {
    state = const AuthState.loading();
    try {
      final datasource = ref.read(authRemoteDatasourceProvider);
      await datasource.submitOnboarding(data);
      await _checkStoredAuth();
    } catch (e) {
      state = const AuthState.onboarding();
      rethrow;
    }
  }
}

@riverpod
AuthState authState(Ref ref) {
  return ref.watch(authStateNotifierProvider);
}
