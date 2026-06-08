import 'package:freezed_annotation/freezed_annotation.dart';

part 'experience_config_model.freezed.dart';
part 'experience_config_model.g.dart';

@freezed
abstract class ExperienceConfig with _$ExperienceConfig {
  const factory ExperienceConfig({
    required String id,
    @Default(false) bool isPublished,
    String? welcomeMessage,
    @Default({}) Map<String, dynamic> sectionsEnabled,
    @Default('#FF4D8C') String themeAccentColor,
    String? customDomain,
  }) = _ExperienceConfig;

  factory ExperienceConfig.fromJson(Map<String, dynamic> json) =>
      _$ExperienceConfigFromJson(json);
}
