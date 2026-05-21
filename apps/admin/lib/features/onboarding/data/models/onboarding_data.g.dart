// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnboardingData _$OnboardingDataFromJson(Map<String, dynamic> json) =>
    _OnboardingData(
      partnerOneName: json['partnerOneName'] as String?,
      partnerTwoName: json['partnerTwoName'] as String?,
      weddingDate: json['weddingDate'] == null
          ? null
          : DateTime.parse(json['weddingDate'] as String),
      dateNotSet: json['dateNotSet'] as bool? ?? false,
      guestCountRange: json['guestCountRange'] as String?,
      userRole: json['userRole'] as String?,
      venueStatus: json['venueStatus'] as String?,
      venueName: json['venueName'] as String?,
      venueCity: json['venueCity'] as String?,
      budgetRange: json['budgetRange'] as String?,
      planningStage: json['planningStage'] as String?,
      planningPriorities:
          (json['planningPriorities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      guestExperience: json['guestExperience'] as String?,
      communicationStyle: json['communicationStyle'] as String?,
      invitationChannels:
          (json['invitationChannels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      weddingVibes:
          (json['weddingVibes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      referralSource: json['referralSource'] as String?,
    );

Map<String, dynamic> _$OnboardingDataToJson(_OnboardingData instance) =>
    <String, dynamic>{
      'partnerOneName': instance.partnerOneName,
      'partnerTwoName': instance.partnerTwoName,
      'weddingDate': instance.weddingDate?.toIso8601String(),
      'dateNotSet': instance.dateNotSet,
      'guestCountRange': instance.guestCountRange,
      'userRole': instance.userRole,
      'venueStatus': instance.venueStatus,
      'venueName': instance.venueName,
      'venueCity': instance.venueCity,
      'budgetRange': instance.budgetRange,
      'planningStage': instance.planningStage,
      'planningPriorities': instance.planningPriorities,
      'guestExperience': instance.guestExperience,
      'communicationStyle': instance.communicationStyle,
      'invitationChannels': instance.invitationChannels,
      'weddingVibes': instance.weddingVibes,
      'referralSource': instance.referralSource,
    };
