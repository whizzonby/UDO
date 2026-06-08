import 'package:freezed_annotation/freezed_annotation.dart';

part 'seating_models.freezed.dart';
part 'seating_models.g.dart';

@freezed
abstract class TableAssignment with _$TableAssignment {
  const factory TableAssignment({
    required String id,
    @JsonKey(name: 'guest_id') required String guestId,
    @JsonKey(name: 'guest_first_name') required String guestFirstName,
    @JsonKey(name: 'guest_last_name') required String guestLastName,
    @JsonKey(name: 'guest_rsvp_status') @Default('attending') String guestRsvpStatus,
    @JsonKey(name: 'seat_number') int? seatNumber,
  }) = _TableAssignment;

  factory TableAssignment.fromJson(Map<String, dynamic> json) =>
      _$TableAssignmentFromJson(json);
}

@freezed
abstract class SeatingTable with _$SeatingTable {
  const factory SeatingTable({
    required String id,
    required String name,
    required int capacity,
    @Default('round') String shape,
    String? section,
    @Default('#FF4D8C') String color,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @Default([]) List<TableAssignment> assignments,
  }) = _SeatingTable;

  factory SeatingTable.fromJson(Map<String, dynamic> json) =>
      _$SeatingTableFromJson(json);
}

@freezed
abstract class UnassignedGuest with _$UnassignedGuest {
  const factory UnassignedGuest({
    required String id,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'rsvp_status') @Default('attending') String rsvpStatus,
  }) = _UnassignedGuest;

  factory UnassignedGuest.fromJson(Map<String, dynamic> json) =>
      _$UnassignedGuestFromJson(json);
}

@freezed
abstract class SeatingStats with _$SeatingStats {
  const factory SeatingStats({
    @JsonKey(name: 'total_attending') @Default(0) int totalAttending,
    @Default(0) int assigned,
    @Default(0) int unassigned,
  }) = _SeatingStats;

  factory SeatingStats.fromJson(Map<String, dynamic> json) =>
      _$SeatingStatsFromJson(json);
}

@freezed
abstract class SeatingData with _$SeatingData {
  const factory SeatingData({
    required List<SeatingTable> tables,
    @JsonKey(name: 'unassigned_guests') required List<UnassignedGuest> unassignedGuests,
    required SeatingStats stats,
  }) = _SeatingData;

  factory SeatingData.fromJson(Map<String, dynamic> json) =>
      _$SeatingDataFromJson(json);
}
