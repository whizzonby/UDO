// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seating_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TableAssignment _$TableAssignmentFromJson(Map<String, dynamic> json) =>
    _TableAssignment(
      id: json['id'] as String,
      guestId: json['guest_id'] as String,
      guestFirstName: json['guest_first_name'] as String,
      guestLastName: json['guest_last_name'] as String,
      guestRsvpStatus: json['guest_rsvp_status'] as String? ?? 'attending',
      seatNumber: (json['seat_number'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TableAssignmentToJson(_TableAssignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'guest_id': instance.guestId,
      'guest_first_name': instance.guestFirstName,
      'guest_last_name': instance.guestLastName,
      'guest_rsvp_status': instance.guestRsvpStatus,
      'seat_number': instance.seatNumber,
    };

_SeatingTable _$SeatingTableFromJson(Map<String, dynamic> json) =>
    _SeatingTable(
      id: json['id'] as String,
      name: json['name'] as String,
      capacity: (json['capacity'] as num).toInt(),
      shape: json['shape'] as String? ?? 'round',
      section: json['section'] as String?,
      color: json['color'] as String? ?? '#FF4D8C',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      assignments:
          (json['assignments'] as List<dynamic>?)
              ?.map((e) => TableAssignment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SeatingTableToJson(_SeatingTable instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'capacity': instance.capacity,
      'shape': instance.shape,
      'section': instance.section,
      'color': instance.color,
      'sort_order': instance.sortOrder,
      'assignments': instance.assignments,
    };

_UnassignedGuest _$UnassignedGuestFromJson(Map<String, dynamic> json) =>
    _UnassignedGuest(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      rsvpStatus: json['rsvp_status'] as String? ?? 'attending',
    );

Map<String, dynamic> _$UnassignedGuestToJson(_UnassignedGuest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'rsvp_status': instance.rsvpStatus,
    };

_SeatingStats _$SeatingStatsFromJson(Map<String, dynamic> json) =>
    _SeatingStats(
      totalAttending: (json['total_attending'] as num?)?.toInt() ?? 0,
      assigned: (json['assigned'] as num?)?.toInt() ?? 0,
      unassigned: (json['unassigned'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SeatingStatsToJson(_SeatingStats instance) =>
    <String, dynamic>{
      'total_attending': instance.totalAttending,
      'assigned': instance.assigned,
      'unassigned': instance.unassigned,
    };

_SeatingData _$SeatingDataFromJson(Map<String, dynamic> json) => _SeatingData(
  tables: (json['tables'] as List<dynamic>)
      .map((e) => SeatingTable.fromJson(e as Map<String, dynamic>))
      .toList(),
  unassignedGuests: (json['unassigned_guests'] as List<dynamic>)
      .map((e) => UnassignedGuest.fromJson(e as Map<String, dynamic>))
      .toList(),
  stats: SeatingStats.fromJson(json['stats'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SeatingDataToJson(_SeatingData instance) =>
    <String, dynamic>{
      'tables': instance.tables,
      'unassigned_guests': instance.unassignedGuests,
      'stats': instance.stats,
    };
