// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seating_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TableAssignment {

 String get id;@JsonKey(name: 'guest_id') String get guestId;@JsonKey(name: 'guest_first_name') String get guestFirstName;@JsonKey(name: 'guest_last_name') String get guestLastName;@JsonKey(name: 'guest_rsvp_status') String get guestRsvpStatus;@JsonKey(name: 'seat_number') int? get seatNumber;
/// Create a copy of TableAssignment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TableAssignmentCopyWith<TableAssignment> get copyWith => _$TableAssignmentCopyWithImpl<TableAssignment>(this as TableAssignment, _$identity);

  /// Serializes this TableAssignment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TableAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.guestId, guestId) || other.guestId == guestId)&&(identical(other.guestFirstName, guestFirstName) || other.guestFirstName == guestFirstName)&&(identical(other.guestLastName, guestLastName) || other.guestLastName == guestLastName)&&(identical(other.guestRsvpStatus, guestRsvpStatus) || other.guestRsvpStatus == guestRsvpStatus)&&(identical(other.seatNumber, seatNumber) || other.seatNumber == seatNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guestId,guestFirstName,guestLastName,guestRsvpStatus,seatNumber);

@override
String toString() {
  return 'TableAssignment(id: $id, guestId: $guestId, guestFirstName: $guestFirstName, guestLastName: $guestLastName, guestRsvpStatus: $guestRsvpStatus, seatNumber: $seatNumber)';
}


}

/// @nodoc
abstract mixin class $TableAssignmentCopyWith<$Res>  {
  factory $TableAssignmentCopyWith(TableAssignment value, $Res Function(TableAssignment) _then) = _$TableAssignmentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'guest_id') String guestId,@JsonKey(name: 'guest_first_name') String guestFirstName,@JsonKey(name: 'guest_last_name') String guestLastName,@JsonKey(name: 'guest_rsvp_status') String guestRsvpStatus,@JsonKey(name: 'seat_number') int? seatNumber
});




}
/// @nodoc
class _$TableAssignmentCopyWithImpl<$Res>
    implements $TableAssignmentCopyWith<$Res> {
  _$TableAssignmentCopyWithImpl(this._self, this._then);

  final TableAssignment _self;
  final $Res Function(TableAssignment) _then;

/// Create a copy of TableAssignment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? guestId = null,Object? guestFirstName = null,Object? guestLastName = null,Object? guestRsvpStatus = null,Object? seatNumber = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guestId: null == guestId ? _self.guestId : guestId // ignore: cast_nullable_to_non_nullable
as String,guestFirstName: null == guestFirstName ? _self.guestFirstName : guestFirstName // ignore: cast_nullable_to_non_nullable
as String,guestLastName: null == guestLastName ? _self.guestLastName : guestLastName // ignore: cast_nullable_to_non_nullable
as String,guestRsvpStatus: null == guestRsvpStatus ? _self.guestRsvpStatus : guestRsvpStatus // ignore: cast_nullable_to_non_nullable
as String,seatNumber: freezed == seatNumber ? _self.seatNumber : seatNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TableAssignment].
extension TableAssignmentPatterns on TableAssignment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TableAssignment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TableAssignment() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TableAssignment value)  $default,){
final _that = this;
switch (_that) {
case _TableAssignment():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TableAssignment value)?  $default,){
final _that = this;
switch (_that) {
case _TableAssignment() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'guest_id')  String guestId, @JsonKey(name: 'guest_first_name')  String guestFirstName, @JsonKey(name: 'guest_last_name')  String guestLastName, @JsonKey(name: 'guest_rsvp_status')  String guestRsvpStatus, @JsonKey(name: 'seat_number')  int? seatNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TableAssignment() when $default != null:
return $default(_that.id,_that.guestId,_that.guestFirstName,_that.guestLastName,_that.guestRsvpStatus,_that.seatNumber);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'guest_id')  String guestId, @JsonKey(name: 'guest_first_name')  String guestFirstName, @JsonKey(name: 'guest_last_name')  String guestLastName, @JsonKey(name: 'guest_rsvp_status')  String guestRsvpStatus, @JsonKey(name: 'seat_number')  int? seatNumber)  $default,) {final _that = this;
switch (_that) {
case _TableAssignment():
return $default(_that.id,_that.guestId,_that.guestFirstName,_that.guestLastName,_that.guestRsvpStatus,_that.seatNumber);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'guest_id')  String guestId, @JsonKey(name: 'guest_first_name')  String guestFirstName, @JsonKey(name: 'guest_last_name')  String guestLastName, @JsonKey(name: 'guest_rsvp_status')  String guestRsvpStatus, @JsonKey(name: 'seat_number')  int? seatNumber)?  $default,) {final _that = this;
switch (_that) {
case _TableAssignment() when $default != null:
return $default(_that.id,_that.guestId,_that.guestFirstName,_that.guestLastName,_that.guestRsvpStatus,_that.seatNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TableAssignment implements TableAssignment {
  const _TableAssignment({required this.id, @JsonKey(name: 'guest_id') required this.guestId, @JsonKey(name: 'guest_first_name') required this.guestFirstName, @JsonKey(name: 'guest_last_name') required this.guestLastName, @JsonKey(name: 'guest_rsvp_status') this.guestRsvpStatus = 'attending', @JsonKey(name: 'seat_number') this.seatNumber});
  factory _TableAssignment.fromJson(Map<String, dynamic> json) => _$TableAssignmentFromJson(json);

@override final  String id;
@override@JsonKey(name: 'guest_id') final  String guestId;
@override@JsonKey(name: 'guest_first_name') final  String guestFirstName;
@override@JsonKey(name: 'guest_last_name') final  String guestLastName;
@override@JsonKey(name: 'guest_rsvp_status') final  String guestRsvpStatus;
@override@JsonKey(name: 'seat_number') final  int? seatNumber;

/// Create a copy of TableAssignment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TableAssignmentCopyWith<_TableAssignment> get copyWith => __$TableAssignmentCopyWithImpl<_TableAssignment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TableAssignmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TableAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.guestId, guestId) || other.guestId == guestId)&&(identical(other.guestFirstName, guestFirstName) || other.guestFirstName == guestFirstName)&&(identical(other.guestLastName, guestLastName) || other.guestLastName == guestLastName)&&(identical(other.guestRsvpStatus, guestRsvpStatus) || other.guestRsvpStatus == guestRsvpStatus)&&(identical(other.seatNumber, seatNumber) || other.seatNumber == seatNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,guestId,guestFirstName,guestLastName,guestRsvpStatus,seatNumber);

@override
String toString() {
  return 'TableAssignment(id: $id, guestId: $guestId, guestFirstName: $guestFirstName, guestLastName: $guestLastName, guestRsvpStatus: $guestRsvpStatus, seatNumber: $seatNumber)';
}


}

/// @nodoc
abstract mixin class _$TableAssignmentCopyWith<$Res> implements $TableAssignmentCopyWith<$Res> {
  factory _$TableAssignmentCopyWith(_TableAssignment value, $Res Function(_TableAssignment) _then) = __$TableAssignmentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'guest_id') String guestId,@JsonKey(name: 'guest_first_name') String guestFirstName,@JsonKey(name: 'guest_last_name') String guestLastName,@JsonKey(name: 'guest_rsvp_status') String guestRsvpStatus,@JsonKey(name: 'seat_number') int? seatNumber
});




}
/// @nodoc
class __$TableAssignmentCopyWithImpl<$Res>
    implements _$TableAssignmentCopyWith<$Res> {
  __$TableAssignmentCopyWithImpl(this._self, this._then);

  final _TableAssignment _self;
  final $Res Function(_TableAssignment) _then;

/// Create a copy of TableAssignment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? guestId = null,Object? guestFirstName = null,Object? guestLastName = null,Object? guestRsvpStatus = null,Object? seatNumber = freezed,}) {
  return _then(_TableAssignment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,guestId: null == guestId ? _self.guestId : guestId // ignore: cast_nullable_to_non_nullable
as String,guestFirstName: null == guestFirstName ? _self.guestFirstName : guestFirstName // ignore: cast_nullable_to_non_nullable
as String,guestLastName: null == guestLastName ? _self.guestLastName : guestLastName // ignore: cast_nullable_to_non_nullable
as String,guestRsvpStatus: null == guestRsvpStatus ? _self.guestRsvpStatus : guestRsvpStatus // ignore: cast_nullable_to_non_nullable
as String,seatNumber: freezed == seatNumber ? _self.seatNumber : seatNumber // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$SeatingTable {

 String get id; String get name; int get capacity; String get shape; String? get section; String get color;@JsonKey(name: 'sort_order') int get sortOrder; List<TableAssignment> get assignments;
/// Create a copy of SeatingTable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeatingTableCopyWith<SeatingTable> get copyWith => _$SeatingTableCopyWithImpl<SeatingTable>(this as SeatingTable, _$identity);

  /// Serializes this SeatingTable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeatingTable&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.shape, shape) || other.shape == shape)&&(identical(other.section, section) || other.section == section)&&(identical(other.color, color) || other.color == color)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other.assignments, assignments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,capacity,shape,section,color,sortOrder,const DeepCollectionEquality().hash(assignments));

@override
String toString() {
  return 'SeatingTable(id: $id, name: $name, capacity: $capacity, shape: $shape, section: $section, color: $color, sortOrder: $sortOrder, assignments: $assignments)';
}


}

/// @nodoc
abstract mixin class $SeatingTableCopyWith<$Res>  {
  factory $SeatingTableCopyWith(SeatingTable value, $Res Function(SeatingTable) _then) = _$SeatingTableCopyWithImpl;
@useResult
$Res call({
 String id, String name, int capacity, String shape, String? section, String color,@JsonKey(name: 'sort_order') int sortOrder, List<TableAssignment> assignments
});




}
/// @nodoc
class _$SeatingTableCopyWithImpl<$Res>
    implements $SeatingTableCopyWith<$Res> {
  _$SeatingTableCopyWithImpl(this._self, this._then);

  final SeatingTable _self;
  final $Res Function(SeatingTable) _then;

/// Create a copy of SeatingTable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? capacity = null,Object? shape = null,Object? section = freezed,Object? color = null,Object? sortOrder = null,Object? assignments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,shape: null == shape ? _self.shape : shape // ignore: cast_nullable_to_non_nullable
as String,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,assignments: null == assignments ? _self.assignments : assignments // ignore: cast_nullable_to_non_nullable
as List<TableAssignment>,
  ));
}

}


/// Adds pattern-matching-related methods to [SeatingTable].
extension SeatingTablePatterns on SeatingTable {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeatingTable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeatingTable() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeatingTable value)  $default,){
final _that = this;
switch (_that) {
case _SeatingTable():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeatingTable value)?  $default,){
final _that = this;
switch (_that) {
case _SeatingTable() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int capacity,  String shape,  String? section,  String color, @JsonKey(name: 'sort_order')  int sortOrder,  List<TableAssignment> assignments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeatingTable() when $default != null:
return $default(_that.id,_that.name,_that.capacity,_that.shape,_that.section,_that.color,_that.sortOrder,_that.assignments);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int capacity,  String shape,  String? section,  String color, @JsonKey(name: 'sort_order')  int sortOrder,  List<TableAssignment> assignments)  $default,) {final _that = this;
switch (_that) {
case _SeatingTable():
return $default(_that.id,_that.name,_that.capacity,_that.shape,_that.section,_that.color,_that.sortOrder,_that.assignments);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int capacity,  String shape,  String? section,  String color, @JsonKey(name: 'sort_order')  int sortOrder,  List<TableAssignment> assignments)?  $default,) {final _that = this;
switch (_that) {
case _SeatingTable() when $default != null:
return $default(_that.id,_that.name,_that.capacity,_that.shape,_that.section,_that.color,_that.sortOrder,_that.assignments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeatingTable implements SeatingTable {
  const _SeatingTable({required this.id, required this.name, required this.capacity, this.shape = 'round', this.section, this.color = '#FF4D8C', @JsonKey(name: 'sort_order') this.sortOrder = 0, final  List<TableAssignment> assignments = const []}): _assignments = assignments;
  factory _SeatingTable.fromJson(Map<String, dynamic> json) => _$SeatingTableFromJson(json);

@override final  String id;
@override final  String name;
@override final  int capacity;
@override@JsonKey() final  String shape;
@override final  String? section;
@override@JsonKey() final  String color;
@override@JsonKey(name: 'sort_order') final  int sortOrder;
 final  List<TableAssignment> _assignments;
@override@JsonKey() List<TableAssignment> get assignments {
  if (_assignments is EqualUnmodifiableListView) return _assignments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignments);
}


/// Create a copy of SeatingTable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeatingTableCopyWith<_SeatingTable> get copyWith => __$SeatingTableCopyWithImpl<_SeatingTable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeatingTableToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeatingTable&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.shape, shape) || other.shape == shape)&&(identical(other.section, section) || other.section == section)&&(identical(other.color, color) || other.color == color)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&const DeepCollectionEquality().equals(other._assignments, _assignments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,capacity,shape,section,color,sortOrder,const DeepCollectionEquality().hash(_assignments));

@override
String toString() {
  return 'SeatingTable(id: $id, name: $name, capacity: $capacity, shape: $shape, section: $section, color: $color, sortOrder: $sortOrder, assignments: $assignments)';
}


}

/// @nodoc
abstract mixin class _$SeatingTableCopyWith<$Res> implements $SeatingTableCopyWith<$Res> {
  factory _$SeatingTableCopyWith(_SeatingTable value, $Res Function(_SeatingTable) _then) = __$SeatingTableCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int capacity, String shape, String? section, String color,@JsonKey(name: 'sort_order') int sortOrder, List<TableAssignment> assignments
});




}
/// @nodoc
class __$SeatingTableCopyWithImpl<$Res>
    implements _$SeatingTableCopyWith<$Res> {
  __$SeatingTableCopyWithImpl(this._self, this._then);

  final _SeatingTable _self;
  final $Res Function(_SeatingTable) _then;

/// Create a copy of SeatingTable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? capacity = null,Object? shape = null,Object? section = freezed,Object? color = null,Object? sortOrder = null,Object? assignments = null,}) {
  return _then(_SeatingTable(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,shape: null == shape ? _self.shape : shape // ignore: cast_nullable_to_non_nullable
as String,section: freezed == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,assignments: null == assignments ? _self._assignments : assignments // ignore: cast_nullable_to_non_nullable
as List<TableAssignment>,
  ));
}


}


/// @nodoc
mixin _$UnassignedGuest {

 String get id;@JsonKey(name: 'first_name') String get firstName;@JsonKey(name: 'last_name') String get lastName;@JsonKey(name: 'rsvp_status') String get rsvpStatus;
/// Create a copy of UnassignedGuest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnassignedGuestCopyWith<UnassignedGuest> get copyWith => _$UnassignedGuestCopyWithImpl<UnassignedGuest>(this as UnassignedGuest, _$identity);

  /// Serializes this UnassignedGuest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnassignedGuest&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.rsvpStatus, rsvpStatus) || other.rsvpStatus == rsvpStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,rsvpStatus);

@override
String toString() {
  return 'UnassignedGuest(id: $id, firstName: $firstName, lastName: $lastName, rsvpStatus: $rsvpStatus)';
}


}

/// @nodoc
abstract mixin class $UnassignedGuestCopyWith<$Res>  {
  factory $UnassignedGuestCopyWith(UnassignedGuest value, $Res Function(UnassignedGuest) _then) = _$UnassignedGuestCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'first_name') String firstName,@JsonKey(name: 'last_name') String lastName,@JsonKey(name: 'rsvp_status') String rsvpStatus
});




}
/// @nodoc
class _$UnassignedGuestCopyWithImpl<$Res>
    implements $UnassignedGuestCopyWith<$Res> {
  _$UnassignedGuestCopyWithImpl(this._self, this._then);

  final UnassignedGuest _self;
  final $Res Function(UnassignedGuest) _then;

/// Create a copy of UnassignedGuest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? rsvpStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,rsvpStatus: null == rsvpStatus ? _self.rsvpStatus : rsvpStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UnassignedGuest].
extension UnassignedGuestPatterns on UnassignedGuest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnassignedGuest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnassignedGuest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnassignedGuest value)  $default,){
final _that = this;
switch (_that) {
case _UnassignedGuest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnassignedGuest value)?  $default,){
final _that = this;
switch (_that) {
case _UnassignedGuest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName, @JsonKey(name: 'rsvp_status')  String rsvpStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnassignedGuest() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.rsvpStatus);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName, @JsonKey(name: 'rsvp_status')  String rsvpStatus)  $default,) {final _that = this;
switch (_that) {
case _UnassignedGuest():
return $default(_that.id,_that.firstName,_that.lastName,_that.rsvpStatus);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'first_name')  String firstName, @JsonKey(name: 'last_name')  String lastName, @JsonKey(name: 'rsvp_status')  String rsvpStatus)?  $default,) {final _that = this;
switch (_that) {
case _UnassignedGuest() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.rsvpStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnassignedGuest implements UnassignedGuest {
  const _UnassignedGuest({required this.id, @JsonKey(name: 'first_name') required this.firstName, @JsonKey(name: 'last_name') required this.lastName, @JsonKey(name: 'rsvp_status') this.rsvpStatus = 'attending'});
  factory _UnassignedGuest.fromJson(Map<String, dynamic> json) => _$UnassignedGuestFromJson(json);

@override final  String id;
@override@JsonKey(name: 'first_name') final  String firstName;
@override@JsonKey(name: 'last_name') final  String lastName;
@override@JsonKey(name: 'rsvp_status') final  String rsvpStatus;

/// Create a copy of UnassignedGuest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnassignedGuestCopyWith<_UnassignedGuest> get copyWith => __$UnassignedGuestCopyWithImpl<_UnassignedGuest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnassignedGuestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnassignedGuest&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.rsvpStatus, rsvpStatus) || other.rsvpStatus == rsvpStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,rsvpStatus);

@override
String toString() {
  return 'UnassignedGuest(id: $id, firstName: $firstName, lastName: $lastName, rsvpStatus: $rsvpStatus)';
}


}

/// @nodoc
abstract mixin class _$UnassignedGuestCopyWith<$Res> implements $UnassignedGuestCopyWith<$Res> {
  factory _$UnassignedGuestCopyWith(_UnassignedGuest value, $Res Function(_UnassignedGuest) _then) = __$UnassignedGuestCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'first_name') String firstName,@JsonKey(name: 'last_name') String lastName,@JsonKey(name: 'rsvp_status') String rsvpStatus
});




}
/// @nodoc
class __$UnassignedGuestCopyWithImpl<$Res>
    implements _$UnassignedGuestCopyWith<$Res> {
  __$UnassignedGuestCopyWithImpl(this._self, this._then);

  final _UnassignedGuest _self;
  final $Res Function(_UnassignedGuest) _then;

/// Create a copy of UnassignedGuest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? rsvpStatus = null,}) {
  return _then(_UnassignedGuest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,rsvpStatus: null == rsvpStatus ? _self.rsvpStatus : rsvpStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SeatingStats {

@JsonKey(name: 'total_attending') int get totalAttending; int get assigned; int get unassigned;
/// Create a copy of SeatingStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeatingStatsCopyWith<SeatingStats> get copyWith => _$SeatingStatsCopyWithImpl<SeatingStats>(this as SeatingStats, _$identity);

  /// Serializes this SeatingStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeatingStats&&(identical(other.totalAttending, totalAttending) || other.totalAttending == totalAttending)&&(identical(other.assigned, assigned) || other.assigned == assigned)&&(identical(other.unassigned, unassigned) || other.unassigned == unassigned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalAttending,assigned,unassigned);

@override
String toString() {
  return 'SeatingStats(totalAttending: $totalAttending, assigned: $assigned, unassigned: $unassigned)';
}


}

/// @nodoc
abstract mixin class $SeatingStatsCopyWith<$Res>  {
  factory $SeatingStatsCopyWith(SeatingStats value, $Res Function(SeatingStats) _then) = _$SeatingStatsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_attending') int totalAttending, int assigned, int unassigned
});




}
/// @nodoc
class _$SeatingStatsCopyWithImpl<$Res>
    implements $SeatingStatsCopyWith<$Res> {
  _$SeatingStatsCopyWithImpl(this._self, this._then);

  final SeatingStats _self;
  final $Res Function(SeatingStats) _then;

/// Create a copy of SeatingStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalAttending = null,Object? assigned = null,Object? unassigned = null,}) {
  return _then(_self.copyWith(
totalAttending: null == totalAttending ? _self.totalAttending : totalAttending // ignore: cast_nullable_to_non_nullable
as int,assigned: null == assigned ? _self.assigned : assigned // ignore: cast_nullable_to_non_nullable
as int,unassigned: null == unassigned ? _self.unassigned : unassigned // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SeatingStats].
extension SeatingStatsPatterns on SeatingStats {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeatingStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeatingStats() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeatingStats value)  $default,){
final _that = this;
switch (_that) {
case _SeatingStats():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeatingStats value)?  $default,){
final _that = this;
switch (_that) {
case _SeatingStats() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_attending')  int totalAttending,  int assigned,  int unassigned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeatingStats() when $default != null:
return $default(_that.totalAttending,_that.assigned,_that.unassigned);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_attending')  int totalAttending,  int assigned,  int unassigned)  $default,) {final _that = this;
switch (_that) {
case _SeatingStats():
return $default(_that.totalAttending,_that.assigned,_that.unassigned);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_attending')  int totalAttending,  int assigned,  int unassigned)?  $default,) {final _that = this;
switch (_that) {
case _SeatingStats() when $default != null:
return $default(_that.totalAttending,_that.assigned,_that.unassigned);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeatingStats implements SeatingStats {
  const _SeatingStats({@JsonKey(name: 'total_attending') this.totalAttending = 0, this.assigned = 0, this.unassigned = 0});
  factory _SeatingStats.fromJson(Map<String, dynamic> json) => _$SeatingStatsFromJson(json);

@override@JsonKey(name: 'total_attending') final  int totalAttending;
@override@JsonKey() final  int assigned;
@override@JsonKey() final  int unassigned;

/// Create a copy of SeatingStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeatingStatsCopyWith<_SeatingStats> get copyWith => __$SeatingStatsCopyWithImpl<_SeatingStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeatingStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeatingStats&&(identical(other.totalAttending, totalAttending) || other.totalAttending == totalAttending)&&(identical(other.assigned, assigned) || other.assigned == assigned)&&(identical(other.unassigned, unassigned) || other.unassigned == unassigned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalAttending,assigned,unassigned);

@override
String toString() {
  return 'SeatingStats(totalAttending: $totalAttending, assigned: $assigned, unassigned: $unassigned)';
}


}

/// @nodoc
abstract mixin class _$SeatingStatsCopyWith<$Res> implements $SeatingStatsCopyWith<$Res> {
  factory _$SeatingStatsCopyWith(_SeatingStats value, $Res Function(_SeatingStats) _then) = __$SeatingStatsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_attending') int totalAttending, int assigned, int unassigned
});




}
/// @nodoc
class __$SeatingStatsCopyWithImpl<$Res>
    implements _$SeatingStatsCopyWith<$Res> {
  __$SeatingStatsCopyWithImpl(this._self, this._then);

  final _SeatingStats _self;
  final $Res Function(_SeatingStats) _then;

/// Create a copy of SeatingStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalAttending = null,Object? assigned = null,Object? unassigned = null,}) {
  return _then(_SeatingStats(
totalAttending: null == totalAttending ? _self.totalAttending : totalAttending // ignore: cast_nullable_to_non_nullable
as int,assigned: null == assigned ? _self.assigned : assigned // ignore: cast_nullable_to_non_nullable
as int,unassigned: null == unassigned ? _self.unassigned : unassigned // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SeatingData {

 List<SeatingTable> get tables;@JsonKey(name: 'unassigned_guests') List<UnassignedGuest> get unassignedGuests; SeatingStats get stats;
/// Create a copy of SeatingData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeatingDataCopyWith<SeatingData> get copyWith => _$SeatingDataCopyWithImpl<SeatingData>(this as SeatingData, _$identity);

  /// Serializes this SeatingData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeatingData&&const DeepCollectionEquality().equals(other.tables, tables)&&const DeepCollectionEquality().equals(other.unassignedGuests, unassignedGuests)&&(identical(other.stats, stats) || other.stats == stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tables),const DeepCollectionEquality().hash(unassignedGuests),stats);

@override
String toString() {
  return 'SeatingData(tables: $tables, unassignedGuests: $unassignedGuests, stats: $stats)';
}


}

/// @nodoc
abstract mixin class $SeatingDataCopyWith<$Res>  {
  factory $SeatingDataCopyWith(SeatingData value, $Res Function(SeatingData) _then) = _$SeatingDataCopyWithImpl;
@useResult
$Res call({
 List<SeatingTable> tables,@JsonKey(name: 'unassigned_guests') List<UnassignedGuest> unassignedGuests, SeatingStats stats
});


$SeatingStatsCopyWith<$Res> get stats;

}
/// @nodoc
class _$SeatingDataCopyWithImpl<$Res>
    implements $SeatingDataCopyWith<$Res> {
  _$SeatingDataCopyWithImpl(this._self, this._then);

  final SeatingData _self;
  final $Res Function(SeatingData) _then;

/// Create a copy of SeatingData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tables = null,Object? unassignedGuests = null,Object? stats = null,}) {
  return _then(_self.copyWith(
tables: null == tables ? _self.tables : tables // ignore: cast_nullable_to_non_nullable
as List<SeatingTable>,unassignedGuests: null == unassignedGuests ? _self.unassignedGuests : unassignedGuests // ignore: cast_nullable_to_non_nullable
as List<UnassignedGuest>,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as SeatingStats,
  ));
}
/// Create a copy of SeatingData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeatingStatsCopyWith<$Res> get stats {
  
  return $SeatingStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [SeatingData].
extension SeatingDataPatterns on SeatingData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeatingData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeatingData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeatingData value)  $default,){
final _that = this;
switch (_that) {
case _SeatingData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeatingData value)?  $default,){
final _that = this;
switch (_that) {
case _SeatingData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SeatingTable> tables, @JsonKey(name: 'unassigned_guests')  List<UnassignedGuest> unassignedGuests,  SeatingStats stats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeatingData() when $default != null:
return $default(_that.tables,_that.unassignedGuests,_that.stats);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SeatingTable> tables, @JsonKey(name: 'unassigned_guests')  List<UnassignedGuest> unassignedGuests,  SeatingStats stats)  $default,) {final _that = this;
switch (_that) {
case _SeatingData():
return $default(_that.tables,_that.unassignedGuests,_that.stats);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SeatingTable> tables, @JsonKey(name: 'unassigned_guests')  List<UnassignedGuest> unassignedGuests,  SeatingStats stats)?  $default,) {final _that = this;
switch (_that) {
case _SeatingData() when $default != null:
return $default(_that.tables,_that.unassignedGuests,_that.stats);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeatingData implements SeatingData {
  const _SeatingData({required final  List<SeatingTable> tables, @JsonKey(name: 'unassigned_guests') required final  List<UnassignedGuest> unassignedGuests, required this.stats}): _tables = tables,_unassignedGuests = unassignedGuests;
  factory _SeatingData.fromJson(Map<String, dynamic> json) => _$SeatingDataFromJson(json);

 final  List<SeatingTable> _tables;
@override List<SeatingTable> get tables {
  if (_tables is EqualUnmodifiableListView) return _tables;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tables);
}

 final  List<UnassignedGuest> _unassignedGuests;
@override@JsonKey(name: 'unassigned_guests') List<UnassignedGuest> get unassignedGuests {
  if (_unassignedGuests is EqualUnmodifiableListView) return _unassignedGuests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unassignedGuests);
}

@override final  SeatingStats stats;

/// Create a copy of SeatingData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeatingDataCopyWith<_SeatingData> get copyWith => __$SeatingDataCopyWithImpl<_SeatingData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeatingDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeatingData&&const DeepCollectionEquality().equals(other._tables, _tables)&&const DeepCollectionEquality().equals(other._unassignedGuests, _unassignedGuests)&&(identical(other.stats, stats) || other.stats == stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tables),const DeepCollectionEquality().hash(_unassignedGuests),stats);

@override
String toString() {
  return 'SeatingData(tables: $tables, unassignedGuests: $unassignedGuests, stats: $stats)';
}


}

/// @nodoc
abstract mixin class _$SeatingDataCopyWith<$Res> implements $SeatingDataCopyWith<$Res> {
  factory _$SeatingDataCopyWith(_SeatingData value, $Res Function(_SeatingData) _then) = __$SeatingDataCopyWithImpl;
@override @useResult
$Res call({
 List<SeatingTable> tables,@JsonKey(name: 'unassigned_guests') List<UnassignedGuest> unassignedGuests, SeatingStats stats
});


@override $SeatingStatsCopyWith<$Res> get stats;

}
/// @nodoc
class __$SeatingDataCopyWithImpl<$Res>
    implements _$SeatingDataCopyWith<$Res> {
  __$SeatingDataCopyWithImpl(this._self, this._then);

  final _SeatingData _self;
  final $Res Function(_SeatingData) _then;

/// Create a copy of SeatingData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tables = null,Object? unassignedGuests = null,Object? stats = null,}) {
  return _then(_SeatingData(
tables: null == tables ? _self._tables : tables // ignore: cast_nullable_to_non_nullable
as List<SeatingTable>,unassignedGuests: null == unassignedGuests ? _self._unassignedGuests : unassignedGuests // ignore: cast_nullable_to_non_nullable
as List<UnassignedGuest>,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as SeatingStats,
  ));
}

/// Create a copy of SeatingData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeatingStatsCopyWith<$Res> get stats {
  
  return $SeatingStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

// dart format on
