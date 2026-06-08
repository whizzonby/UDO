// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LiveStatus _$LiveStatusFromJson(Map<String, dynamic> json) => _LiveStatus(
  isLive: json['isLive'] as bool? ?? false,
  weddingDate: json['weddingDate'] as String?,
  daysUntil: (json['daysUntil'] as num?)?.toInt(),
  partnerOneName: json['partnerOneName'] as String?,
  partnerTwoName: json['partnerTwoName'] as String?,
  venueName: json['venueName'] as String?,
  totalGuests: (json['totalGuests'] as num?)?.toInt() ?? 0,
  checkedInCount: (json['checkedInCount'] as num?)?.toInt() ?? 0,
  attendingCount: (json['attendingCount'] as num?)?.toInt() ?? 0,
  dayEvents:
      (json['dayEvents'] as List<dynamic>?)
          ?.map((e) => LiveEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  upcomingEvents:
      (json['upcomingEvents'] as List<dynamic>?)
          ?.map((e) => LiveEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$LiveStatusToJson(_LiveStatus instance) =>
    <String, dynamic>{
      'isLive': instance.isLive,
      'weddingDate': instance.weddingDate,
      'daysUntil': instance.daysUntil,
      'partnerOneName': instance.partnerOneName,
      'partnerTwoName': instance.partnerTwoName,
      'venueName': instance.venueName,
      'totalGuests': instance.totalGuests,
      'checkedInCount': instance.checkedInCount,
      'attendingCount': instance.attendingCount,
      'dayEvents': instance.dayEvents,
      'upcomingEvents': instance.upcomingEvents,
    };

_LiveEvent _$LiveEventFromJson(Map<String, dynamic> json) => _LiveEvent(
  id: json['id'] as String,
  title: json['title'] as String,
  time: json['time'] as String?,
  category: json['category'] as String?,
  location: json['location'] as String?,
  description: json['description'] as String?,
  eventDate: json['eventDate'] as String?,
);

Map<String, dynamic> _$LiveEventToJson(_LiveEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'time': instance.time,
      'category': instance.category,
      'location': instance.location,
      'description': instance.description,
      'eventDate': instance.eventDate,
    };
