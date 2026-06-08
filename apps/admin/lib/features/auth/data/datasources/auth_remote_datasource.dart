import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../../../onboarding/data/models/onboarding_data.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource.g.dart';

@riverpod
AuthRemoteDatasource authRemoteDatasource(Ref ref) {
  return AuthRemoteDatasource(
    dio: ref.watch(apiClientProvider),
    storage: ref.watch(secureStorageProvider),
  );
}

class AuthRemoteDatasource {
  const AuthRemoteDatasource({
    required Dio dio,
    required FlutterSecureStorage storage,
  })  : _dio = dio,
        _storage = storage;

  final Dio _dio;
  final FlutterSecureStorage _storage;

  Future<AuthResponseModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return _parseAuthResponse(response.data as Map<String, dynamic>);
  }

  Future<AuthResponseModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
    return _parseAuthResponse(response.data as Map<String, dynamic>);
  }

  Future<AuthResponseModel> signInWithGoogle(String idToken) async {
    final response = await _dio.post('/auth/social/google', data: {
      'id_token': idToken,
    });
    return _parseAuthResponse(response.data as Map<String, dynamic>);
  }

  Future<AuthResponseModel> signInWithApple({
    required String authorizationCode,
    required String identityToken,
    String? fullName,
    String? email,
  }) async {
    final response = await _dio.post('/auth/social/apple', data: {
      'authorization_code': authorizationCode,
      'identity_token': identityToken,
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
    });
    return _parseAuthResponse(response.data as Map<String, dynamic>);
  }

  Future<AuthResponseModel> signInWithFacebook(String accessToken) async {
    final response = await _dio.post('/auth/social/facebook', data: {
      'access_token': accessToken,
    });
    return _parseAuthResponse(response.data as Map<String, dynamic>);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    final data = response.data as Map<String, dynamic>;
    return _buildUserModel(
      userJson: data['user'] as Map<String, dynamic>,
      hasWedding: data['wedding'] != null,
    );
  }

  Future<void> submitOnboarding(OnboardingData data) async {
    final body = <String, dynamic>{
      'partner_one_name': data.partnerOneName,
      if (data.partnerTwoName != null) 'partner_two_name': data.partnerTwoName,
      if (data.weddingDate != null)
        'wedding_date': data.weddingDate!.toIso8601String().substring(0, 10),
      'date_not_set': data.dateNotSet,
      if (data.guestCountRange != null) 'guest_count_range': data.guestCountRange,
      if (data.userRole != null) 'user_role': data.userRole,
      if (data.venueStatus != null) 'venue_status': data.venueStatus,
      if (data.venueName != null) 'venue_name': data.venueName,
      if (data.venueCity != null) 'venue_city': data.venueCity,
      if (data.budgetRange != null) 'budget_range': data.budgetRange,
      if (data.planningStage != null) 'planning_stage': data.planningStage,
      if (data.planningPriorities.isNotEmpty)
        'planning_priorities': data.planningPriorities,
      if (data.guestExperience != null) 'guest_experience': data.guestExperience,
      if (data.communicationStyle != null)
        'communication_style': data.communicationStyle,
      if (data.invitationChannels.isNotEmpty)
        'invitation_channels': data.invitationChannels,
      if (data.weddingVibes.isNotEmpty) 'wedding_vibes': data.weddingVibes,
      if (data.referralSource != null) 'referral_source': data.referralSource,
    };
    await _dio.post('/onboarding', data: body);
  }

  Future<void> signOut() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      await _storage.delete(key: ApiTokenStorage.tokenKey);
    }
  }

  Future<String?> getStoredToken() {
    return _storage.read(key: ApiTokenStorage.tokenKey);
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<AuthResponseModel> _parseAuthResponse(
      Map<String, dynamic> data) async {
    final token = data['token'] as String;
    await _storage.write(key: ApiTokenStorage.tokenKey, value: token);
    final user = _buildUserModel(
      userJson: data['user'] as Map<String, dynamic>,
      hasWedding: data['wedding'] != null,
    );
    return AuthResponseModel(token: token, user: user);
  }

  UserModel _buildUserModel({
    required Map<String, dynamic> userJson,
    required bool hasWedding,
  }) {
    final json = Map<String, dynamic>.from(userJson)
      ..['onboardingComplete'] = hasWedding;
    return UserModel.fromJson(json);
  }
}
