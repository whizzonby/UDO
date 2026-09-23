class AppConstants {
  static const String appName = 'Udo';

  /// The Wedding Pass (one-time) product id registered in App Store Connect
  /// and Google Play Console — must match IOS_LIFETIME_PRODUCT_ID /
  /// ANDROID_LIFETIME_PRODUCT_ID in the API's .env.
  static const String lifetimeProductId = 'udo_lifetime_access';

  /// The Udo Premium monthly subscription product id — must match
  /// IOS_PREMIUM_PRODUCT_ID / ANDROID_PREMIUM_PRODUCT_ID in the API's .env.
  static const String premiumProductId = 'udo_premium_monthly';

  /// List prices in USD. Only fallbacks for analytics when the store's
  /// localized `ProductDetails` price isn't available — the actual charge
  /// always comes from the store.
  static const double lifetimePriceUsd = 49.99;
  static const double premiumPriceUsd = 4.99;

  /// Linked from the paywall — Apple requires Terms (EULA) and Privacy links
  /// next to any auto-renewing subscription.
  static const String termsUrl = 'https://udowedding.com/terms';
  static const String privacyUrl = 'https://udowedding.com/privacy';

  static String get apiBaseUrl {
    const env = String.fromEnvironment('API_BASE_URL');
    if (env.isNotEmpty) return env;
    return 'https://admin.udowedding.com/api';
  }

  static String get apiHostHeader {
    const env = String.fromEnvironment('API_HOST_HEADER');
    if (env.isNotEmpty) return env;
    return '';
  }

  /// Crash/error reporting DSN. Empty = Sentry is never initialized and the
  /// app behaves exactly as before — pass `--dart-define=SENTRY_DSN=...` at
  /// build time once a Sentry project exists for this app.
  static String get sentryDsn => const String.fromEnvironment('SENTRY_DSN');

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
