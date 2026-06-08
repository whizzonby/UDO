// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GuestModel _$GuestModelFromJson(Map<String, dynamic> json) => _GuestModel(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  rsvpStatus: json['rsvpStatus'] as String? ?? 'pending',
  group: json['group'] as String?,
  relationship: json['relationship'] as String?,
  ageGroup: json['ageGroup'] as String? ?? 'adult',
  isVip: json['isVip'] as bool? ?? false,
  dietaryRequirements: json['dietaryRequirements'] as String?,
  plusOneAllowed: json['plusOneAllowed'] as bool? ?? false,
  plusOneName: json['plusOneName'] as String?,
  invitationSentAt: json['invitationSentAt'] as String?,
  rsvpRespondedAt: json['rsvpRespondedAt'] as String?,
  checkedInAt: json['checkedInAt'] as String?,
  needsTransport: json['needsTransport'] as bool? ?? false,
  needsAccommodation: json['needsAccommodation'] as bool? ?? false,
  token: json['token'] as String?,
  notes: json['notes'] as String?,
  address: json['address'] as String?,
  language: json['language'] as String?,
);

Map<String, dynamic> _$GuestModelToJson(_GuestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'fullName': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'rsvpStatus': instance.rsvpStatus,
      'group': instance.group,
      'relationship': instance.relationship,
      'ageGroup': instance.ageGroup,
      'isVip': instance.isVip,
      'dietaryRequirements': instance.dietaryRequirements,
      'plusOneAllowed': instance.plusOneAllowed,
      'plusOneName': instance.plusOneName,
      'invitationSentAt': instance.invitationSentAt,
      'rsvpRespondedAt': instance.rsvpRespondedAt,
      'checkedInAt': instance.checkedInAt,
      'needsTransport': instance.needsTransport,
      'needsAccommodation': instance.needsAccommodation,
      'token': instance.token,
      'notes': instance.notes,
      'address': instance.address,
      'language': instance.language,
    };

_GuestsOverview _$GuestsOverviewFromJson(Map<String, dynamic> json) =>
    _GuestsOverview(
      totalGuests: (json['totalGuests'] as num?)?.toInt() ?? 0,
      attending: (json['attending'] as num?)?.toInt() ?? 0,
      declined: (json['declined'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      responseRate: (json['responseRate'] as num?)?.toInt() ?? 0,
      quickStats: json['quickStats'] == null
          ? const GuestQuickStats()
          : GuestQuickStats.fromJson(
              json['quickStats'] as Map<String, dynamic>,
            ),
      groups: json['groups'] as Map<String, dynamic>? ?? const {},
      vipCount: (json['vipCount'] as num?)?.toInt() ?? 0,
      invitedCount: (json['invitedCount'] as num?)?.toInt() ?? 0,
      notInvitedYet: (json['notInvitedYet'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$GuestsOverviewToJson(_GuestsOverview instance) =>
    <String, dynamic>{
      'totalGuests': instance.totalGuests,
      'attending': instance.attending,
      'declined': instance.declined,
      'pending': instance.pending,
      'responseRate': instance.responseRate,
      'quickStats': instance.quickStats,
      'groups': instance.groups,
      'vipCount': instance.vipCount,
      'invitedCount': instance.invitedCount,
      'notInvitedYet': instance.notInvitedYet,
    };

_GuestQuickStats _$GuestQuickStatsFromJson(Map<String, dynamic> json) =>
    _GuestQuickStats(
      vegetarian: (json['vegetarian'] as num?)?.toInt() ?? 0,
      allergies: (json['allergies'] as num?)?.toInt() ?? 0,
      kids: (json['kids'] as num?)?.toInt() ?? 0,
      plusOnes: (json['plusOnes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$GuestQuickStatsToJson(_GuestQuickStats instance) =>
    <String, dynamic>{
      'vegetarian': instance.vegetarian,
      'allergies': instance.allergies,
      'kids': instance.kids,
      'plusOnes': instance.plusOnes,
    };
