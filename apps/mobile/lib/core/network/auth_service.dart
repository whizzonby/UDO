import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import 'api_client.dart';
import '../../features/auth/data/auth_models.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiClientProvider));
});

class AuthService {
  final ApiClient _api;
  final _storage = const FlutterSecureStorage();

  AuthService(this._api);

  Future<AuthResponse> login(String email, String password) async {
    final data = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final data = await _api.post('/auth/register', data: {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> socialLogin({
    required String provider,   // 'google' | 'apple'
    required String token,
    String? firstName,
    String? lastName,
  }) async {
    final data = await _api.post('/auth/mobile/$provider', data: {
      if (provider == 'google') 'id_token': token,
      if (provider == 'apple') 'identity_token': token,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
    });
    return AuthResponse.fromJson(data);
  }

  Future<AuthUser> me() async {
    final data = await _api.get('/auth/me');
    return AuthUser.fromJson(data);
  }

  Future<void> logout() async {
    await _api.post('/auth/logout');
    await clearSession();
  }

  Future<String> forgotPassword(String email) async {
    final data = await _api.post('/auth/forgot-password', data: {'email': email});
    return (data is Map ? data['message']?.toString() : null) ?? 'If that email is registered, a reset link is on its way.';
  }

  Future<void> saveSession(String token, AuthUser user) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
    await _storage.write(key: AppConstants.userKey, value: jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
  }

  Future<String?> getToken() => _storage.read(key: AppConstants.tokenKey);

  Future<AuthUser?> getCachedUser() async {
    final raw = await _storage.read(key: AppConstants.userKey);
    if (raw == null) return null;
    return AuthUser.fromJson(jsonDecode(raw));
  }
}
