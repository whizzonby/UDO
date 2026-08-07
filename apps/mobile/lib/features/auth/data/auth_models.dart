class AuthUser {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final int? weddingId;
  final String? weddingRole;
  final List<String> weddingPermissions;
  final bool isWeddingOwner;
  final Map<String, dynamic>? subscription;
  final Map<String, dynamic> notificationPreferences;
  final Map<String, dynamic> supportPreferences;
  final bool onboardingCompleted;
  final bool twoFactorEnabled;

  const AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.weddingId,
    this.weddingRole,
    this.weddingPermissions = const [],
    this.isWeddingOwner = false,
    this.subscription,
    this.notificationPreferences = const {},
    this.supportPreferences = const {},
    required this.onboardingCompleted,
    this.twoFactorEnabled = false,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as int,
    email: json['email'] as String,
    firstName: json['first_name'] as String? ?? '',
    lastName: json['last_name'] as String? ?? '',
    avatarUrl: json['avatar_url'] as String?,
    weddingId: json['wedding_id'] as int?,
    weddingRole: json['wedding_role'] as String?,
    weddingPermissions: (json['wedding_permissions'] as List? ?? []).map((item) => item.toString()).toList(),
    isWeddingOwner: json['is_wedding_owner'] as bool? ?? false,
    subscription: json['subscription'] is Map ? Map<String, dynamic>.from(json['subscription'] as Map) : null,
    notificationPreferences: json['notification_preferences'] is Map ? Map<String, dynamic>.from(json['notification_preferences'] as Map) : const {},
    supportPreferences: json['support_preferences'] is Map ? Map<String, dynamic>.from(json['support_preferences'] as Map) : const {},
    onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
    twoFactorEnabled: json['two_factor_enabled'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'avatar_url': avatarUrl,
    'wedding_id': weddingId,
    'wedding_role': weddingRole,
    'wedding_permissions': weddingPermissions,
    'is_wedding_owner': isWeddingOwner,
    'subscription': subscription,
    'notification_preferences': notificationPreferences,
    'support_preferences': supportPreferences,
    'onboarding_completed': onboardingCompleted,
    'two_factor_enabled': twoFactorEnabled,
  };
}

class AuthResponse {
  final String token;
  final AuthUser user;

  const AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token: json['token'] as String,
    user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
  );
}

/// Result of a login attempt: either a normal successful [AuthResponse], or
/// a pending [twoFactorToken] challenge when the account has 2FA enabled —
/// in that case no token/session exists yet until the emailed code is
/// verified via `AuthService.verifyTwoFactor`.
class LoginResult {
  final AuthResponse? auth;
  final String? twoFactorToken;
  final String? message;

  const LoginResult.success(AuthResponse this.auth)
      : twoFactorToken = null,
        message = null;

  const LoginResult.twoFactorRequired(String this.twoFactorToken, String this.message)
      : auth = null;

  bool get requiresTwoFactor => twoFactorToken != null;
}
