// ignore: depend_on_referenced_packages
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  static const String appName = 'Udo';

  static String get apiBaseUrl {
    const env = String.fromEnvironment('API_BASE_URL');
    if (env.isNotEmpty) return env;
    return kIsWeb ? 'http://api.test/api' : 'http://10.0.2.2/api';
  }

  /// Server origin without the `/api` suffix — for resolving relative
  /// `/storage/...` URLs returned by upload endpoints into absolute links.
  static String get apiOrigin {
    final base = apiBaseUrl;
    return base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
  }

  // Colors
  static const int udoGreenHex = 0xFF285301;
  static const int udoCrimsonHex = 0xFFD45D78;
  static const int udoPastelCrimsonHex = 0xFFF194B2;
  static const int udoLightBlushHex = 0xFFF8EDEB;

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  // Pagination
  static const int defaultPageSize = 20;
}
