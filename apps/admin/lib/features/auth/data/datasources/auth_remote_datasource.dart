import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
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
    final model = AuthResponseModel.fromJson(response.data['data']);
    await _storage.write(key: ApiTokenStorage.tokenKey, value: model.token);
    return model;
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
    });
    final model = AuthResponseModel.fromJson(response.data['data']);
    await _storage.write(key: ApiTokenStorage.tokenKey, value: model.token);
    return model;
  }

  Future<AuthResponseModel> signInWithGoogle(String idToken) async {
    final response = await _dio.post('/auth/social/google', data: {
      'id_token': idToken,
    });
    final model = AuthResponseModel.fromJson(response.data['data']);
    await _storage.write(key: ApiTokenStorage.tokenKey, value: model.token);
    return model;
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
    final model = AuthResponseModel.fromJson(response.data['data']);
    await _storage.write(key: ApiTokenStorage.tokenKey, value: model.token);
    return model;
  }

  Future<AuthResponseModel> signInWithFacebook(String accessToken) async {
    final response = await _dio.post('/auth/social/facebook', data: {
      'access_token': accessToken,
    });
    final model = AuthResponseModel.fromJson(response.data['data']);
    await _storage.write(key: ApiTokenStorage.tokenKey, value: model.token);
    return model;
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data['data']);
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
}
