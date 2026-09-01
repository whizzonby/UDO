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

  Future<LoginResult> login(String email, String password) async {
    final data = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    if (data is Map && data['two_factor_required'] == true) {
      return LoginResult.twoFactorRequired(
        data['two_factor_token'] as String,
        data['message']?.toString() ?? 'Enter the 6-digit code we emailed you.',
      );
    }
    return LoginResult.success(AuthResponse.fromJson(data));
  }

  Future<AuthResponse> verifyTwoFactor({
    required String email,
    required String twoFactorToken,
    required String code,
  }) async {
    final data = await _api.post('/auth/two-factor/verify', data: {
      'email': email,
      'two_factor_token': twoFactorToken,
      'code': code,
    });
    return AuthResponse.fromJson(data);
  }

  Future<String> resendTwoFactor({
    required String email,
    required String twoFactorToken,
  }) async {
    final data = await _api.post('/auth/two-factor/resend', data: {
      'email': email,
      'two_factor_token': twoFactorToken,
    });
    return (data is Map ? data['message']?.toString() : null) ??
        'A new code is on its way.';
  }

  Future<AuthUser> enableTwoFactor(String currentPassword) async {
    final data = await _api.post('/auth/two-factor/enable',
        data: {'current_password': currentPassword});
    final rawUser =
        data is Map && data['user'] is Map ? data['user'] as Map : data as Map;
    return AuthUser.fromJson(Map<String, dynamic>.from(rawUser));
  }

  Future<AuthUser> disableTwoFactor(String currentPassword) async {
    final data = await _api.post('/auth/two-factor/disable',
        data: {'current_password': currentPassword});
    final rawUser =
        data is Map && data['user'] is Map ? data['user'] as Map : data as Map;
    return AuthUser.fromJson(Map<String, dynamic>.from(rawUser));
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
    required String provider, // 'google' | 'apple'
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
    final rawUser =
        data is Map && data['user'] is Map ? data['user'] as Map : data as Map;
    return AuthUser.fromJson(Map<String, dynamic>.from(rawUser));
  }

  Future<void> switchWedding(int weddingId) async {
    await _api.post('/weddings/switch', data: {'wedding_id': weddingId});
  }

  Future<AuthUser> updateProfile({
    required String firstName,
    required String email,
    String? lastName,
    String? avatarUrl,
  }) async {
    final data = await _api.patch('/auth/me', data: {
      'first_name': firstName,
      'last_name': lastName ?? '',
      'email': email,
      if (avatarUrl != null && avatarUrl.trim().isNotEmpty)
        'avatar_url': avatarUrl.trim(),
    });
    final rawUser =
        data is Map && data['user'] is Map ? data['user'] as Map : data as Map;
    return AuthUser.fromJson(Map<String, dynamic>.from(rawUser));
  }

  Future<AuthUser> updatePreferences({
    Map<String, dynamic>? notificationPreferences,
    Map<String, dynamic>? supportPreferences,
  }) async {
    final data = await _api.patch('/auth/preferences', data: {
      if (notificationPreferences != null)
        'notification_preferences': notificationPreferences,
      if (supportPreferences != null) 'support_preferences': supportPreferences,
    });
    final rawUser =
        data is Map && data['user'] is Map ? data['user'] as Map : data as Map;
    return AuthUser.fromJson(Map<String, dynamic>.from(rawUser));
  }

  Future<void> logout() async {
    await _api.post('/auth/logout');
    await clearSession();
  }

  Future<String> forgotPassword(String email) async {
    final data =
        await _api.post('/auth/forgot-password', data: {'email': email});
    return (data is Map ? data['message']?.toString() : null) ??
        'If that email is registered, a reset link is on its way.';
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.post('/auth/change-password', data: {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': newPassword,
    });
  }

  Future<void> deleteAccount({String? currentPassword}) async {
    await _api.delete('/auth/me', data: {
      'confirmation': 'DELETE',
      if (currentPassword != null && currentPassword.isNotEmpty)
        'current_password': currentPassword,
    });
  }

  Future<void> saveSession(String token, AuthUser user) async {
    await _storage
        .write(key: AppConstants.tokenKey, value: token)
        .timeout(const Duration(seconds: 3));
    await _storage
        .write(key: AppConstants.userKey, value: jsonEncode(user.toJson()))
        .timeout(const Duration(seconds: 3));
  }

  Future<void> clearSession() async {
    await _storage
        .delete(key: AppConstants.tokenKey)
        .timeout(const Duration(seconds: 3));
    await _storage
        .delete(key: AppConstants.userKey)
        .timeout(const Duration(seconds: 3));
  }

  Future<String?> getToken() => _storage
      .read(key: AppConstants.tokenKey)
      .timeout(const Duration(seconds: 3));

  Future<AuthUser?> getCachedUser() async {
    final raw = await _storage
        .read(key: AppConstants.userKey)
        .timeout(const Duration(seconds: 3));
    if (raw == null) return null;
    return AuthUser.fromJson(jsonDecode(raw));
  }
}
