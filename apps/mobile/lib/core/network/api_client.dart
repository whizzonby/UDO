import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../analytics/meta_events.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class CachedApiResponse {
  final dynamic data;
  final bool fromCache;
  final DateTime? cachedAt;

  const CachedApiResponse({
    required this.data,
    required this.fromCache,
    this.cachedAt,
  });
}

class ApiClient {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  /// Fired on any 401 from any request, anywhere in the app. Wired once, in
  /// UdoApp, to force a clean logout + redirect to /login — without this, a
  /// stale/expired token just makes whatever action was in flight (add task,
  /// save budget item, ...) fail with a generic "couldn't save" error, with
  /// no indication that the real problem is "you're signed out".
  void Function()? onUnauthorized;

  /// Fired on any 402 from any request — a plan limit was hit. Wired once,
  /// in UdoApp, to surface the server's exact limit message and route to
  /// the paywall, instead of the action just failing with a generic error.
  void Function(String message)? onLimitReached;

  static const _signInPaths = {
    '/auth/login',
    '/auth/register',
    '/auth/two-factor/verify',
    '/auth/two-factor/resend',
    '/auth/mobile/google',
    '/auth/mobile/apple',
  };

  ApiClient() {
    final hostHeader = AppConstants.apiHostHeader;
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (hostHeader.isNotEmpty) 'Host': hostHeader,
      },
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
        // A 401 from a sign-in endpoint means "wrong credentials / invalid
        // token", not an expired session — let its server message through.
        if (error.response?.statusCode == 401 &&
            !_signInPaths.contains(error.requestOptions.path)) {
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

  Future<CachedApiResponse> getCached(String path,
      {Map<String, dynamic>? query, String? cacheKey}) async {
    final key = cacheKey ?? _cacheKey(path, query);
    try {
      final data = await get(path, query: query);
      await _writeCache(key, data);
      return CachedApiResponse(
          data: data, fromCache: false, cachedAt: DateTime.now());
    } catch (_) {
      final cached = await _readCache(key);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<dynamic> post(String path,
      {dynamic data, Duration? receiveTimeout, Map<String, dynamic>? headers}) async {
    final res = await _request(() => _dio.post(
          path,
          data: data,
          options: (receiveTimeout != null || headers != null)
              ? Options(receiveTimeout: receiveTimeout, headers: headers)
              : null,
        ));
    final action = _firstActionTypes[path];
    if (action != null) MetaEvents.instance.firstMeaningfulAction(type: action);
    return res;
  }

  /// Successful creates that count as the "first meaningful action" in the
  /// signup funnel (the user actually started planning, beyond onboarding).
  static const _firstActionTypes = {
    '/guests': 'guest',
    '/guests/bulk-import': 'guest',
    '/plan/tasks': 'task',
    '/plan/vendors': 'vendor',
    '/plan/budget': 'budget_item',
    '/plan/timeline': 'timeline_item',
  };

  Future<dynamic> patch(String path, {dynamic data}) async {
    return _request(() => _dio.patch(path, data: data));
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    return _request(() => _dio.put(path, data: data));
  }

  Future<dynamic> delete(String path, {dynamic data}) async {
    return _request(() => _dio.delete(path, data: data));
  }

  Future<dynamic> _request(Future<Response> Function() call) async {
    try {
      final res = await call();
      return res.data;
    } on DioException catch (e) {
      final inner = e.error;
      if (inner is AppException) throw inner;
      final statusCode = e.response?.statusCode;
      final message = statusCode == 429
          ? 'Too many attempts. Please wait a minute and try again.'
          : _extractMessage(e.response?.data) ?? _networkMessage(e);
      if (statusCode == 402) {
        onLimitReached?.call(message);
      }
      throw ServerException(message, statusCode: statusCode);
    }
  }

  /// Dio's own `error.message` is developer-facing (raw SocketException
  /// text, or — for connection failures — the literal request URL), so it's
  /// never shown to the user. This always returns a clean, generic message
  /// instead, distinguishing only the cases where the wording actually
  /// helps the user (no connection vs. a slow/unresponsive server).
  String _networkMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
        return "You're not connected to the internet. Check your connection and try again.";
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The connection timed out. Check your internet connection and try again.';
      case DioExceptionType.badCertificate:
        return "Couldn't establish a secure connection. Please try again.";
      default:
        return 'Something went wrong. Please try again.';
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

  String _cacheKey(String path, Map<String, dynamic>? query) {
    final entries = (query ?? {}).entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final queryString =
        entries.map((entry) => '${entry.key}=${entry.value}').join('&');
    return 'api-cache:$path?$queryString';
  }

  Future<void> _writeCache(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        key,
        jsonEncode({
          'cached_at': DateTime.now().toIso8601String(),
          'data': data,
        }));
  }

  Future<CachedApiResponse?> _readCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return CachedApiResponse(
        data: decoded['data'],
        fromCache: true,
        cachedAt: DateTime.tryParse(decoded['cached_at'] as String? ?? ''),
      );
    } catch (_) {
      await prefs.remove(key);
      return null;
    }
  }
}
