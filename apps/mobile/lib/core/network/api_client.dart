import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  /// Fired on any 401 from any request, anywhere in the app. Wired once, in
  /// UdoApp, to force a clean logout + redirect to /login — without this, a
  /// stale/expired token just makes whatever action was in flight (add task,
  /// save budget item, ...) fail with a generic "couldn't save" error, with
  /// no indication that the real problem is "you're signed out".
  void Function()? onUnauthorized;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          onUnauthorized?.call();
          handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: const UnauthorizedException(),
            type: DioExceptionType.badResponse,
          ));
          return;
        }
        handler.next(error);
      },
    ));
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    return _request(() => _dio.get(path, queryParameters: query));
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    return _request(() => _dio.post(path, data: data));
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    return _request(() => _dio.patch(path, data: data));
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    return _request(() => _dio.put(path, data: data));
  }

  Future<dynamic> delete(String path) async {
    return _request(() => _dio.delete(path));
  }

  Future<dynamic> _request(Future<Response> Function() call) async {
    try {
      final res = await call();
      return res.data;
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      final statusCode = e.response?.statusCode;
      final message = _extractMessage(e.response?.data) ?? e.message ?? 'Something went wrong.';
      throw ServerException(message, statusCode: statusCode);
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map) {
      if (data['message'] != null) return data['message'].toString();
      if (data['errors'] != null) {
        final errors = data['errors'] as Map;
        return errors.values.first is List
            ? (errors.values.first as List).first.toString()
            : null;
      }
    }
    return null;
  }
}
