// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  avatar: json['avatar'] as String?,
  emailVerified: json['emailVerified'] as bool? ?? false,
  onboardingComplete: json['onboardingComplete'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'avatar': instance.avatar,
      'emailVerified': instance.emailVerified,
      'onboardingComplete': instance.onboardingComplete,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
