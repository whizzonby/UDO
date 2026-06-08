// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experience_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExperienceConfig _$ExperienceConfigFromJson(Map<String, dynamic> json) =>
    _ExperienceConfig(
      id: json['id'] as String,
      isPublished: json['isPublished'] as bool? ?? false,
      welcomeMessage: json['welcomeMessage'] as String?,
      sectionsEnabled:
          json['sectionsEnabled'] as Map<String, dynamic>? ?? const {},
      themeAccentColor: json['themeAccentColor'] as String? ?? '#FF4D8C',
      customDomain: json['customDomain'] as String?,
    );

Map<String, dynamic> _$ExperienceConfigToJson(_ExperienceConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isPublished': instance.isPublished,
      'welcomeMessage': instance.welcomeMessage,
      'sectionsEnabled': instance.sectionsEnabled,
      'themeAccentColor': instance.themeAccentColor,
      'customDomain': instance.customDomain,
    };
