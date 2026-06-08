import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_status_model.freezed.dart';
part 'live_status_model.g.dart';

@freezed
abstract class LiveActivity with _$LiveActivity {
  const factory LiveActivity({
    required String type,        // 'check_in' | 'rsvp' | 'announcement'
    required String actorName,
    required String description,
    required String occurredAt,
  }) = _LiveActivity;

  factory LiveActivity.fromJson(Map<String, dynamic> json) =>
      _$LiveActivityFromJson(json);
}

@freezed
abstract class LiveStatus with _$LiveStatus {
  const factory LiveStatus({
    String? weddingId,
    @Default(false) bool isLive,
    String? weddingDate,
    int? daysUntil,
    String? partnerOneName,
    String? partnerTwoName,
    String? venueName,
    @Default(0) int totalGuests,
    @Default(0) int checkedInCount,
    @Default(0) int attendingCount,
    @Default([]) List<LiveEvent> dayEvents,
    @Default([]) List<LiveEvent> upcomingEvents,
  }) = _LiveStatus;

  factory LiveStatus.fromJson(Map<String, dynamic> json) =>
      _$LiveStatusFromJson(json);
}

@freezed
abstract class LiveEvent with _$LiveEvent {
  const factory LiveEvent({
    required String id,
    required String title,
    String? time,
    String? category,
    String? location,
    String? description,
    String? eventDate,
  }) = _LiveEvent;

  factory LiveEvent.fromJson(Map<String, dynamic> json) =>
      _$LiveEventFromJson(json);
}
