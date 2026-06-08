// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GuestMessageModel _$GuestMessageModelFromJson(Map<String, dynamic> json) =>
    _GuestMessageModel(
      id: json['id'] as String,
      subject: json['subject'] as String?,
      body: json['body'] as String,
      channel: json['channel'] as String? ?? 'in_app',
      recipientFilter:
          json['recipientFilter'] as Map<String, dynamic>? ?? const {},
      recipientCount: (json['recipientCount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'sent',
      sentAt: json['sentAt'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$GuestMessageModelToJson(_GuestMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'body': instance.body,
      'channel': instance.channel,
      'recipientFilter': instance.recipientFilter,
      'recipientCount': instance.recipientCount,
      'status': instance.status,
      'sentAt': instance.sentAt,
      'createdAt': instance.createdAt,
    };
