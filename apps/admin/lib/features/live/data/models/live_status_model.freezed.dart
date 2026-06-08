// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_status_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LiveActivity {

 String get type;// 'check_in' | 'rsvp' | 'announcement'
 String get actorName; String get description; String get occurredAt;
/// Create a copy of LiveActivity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveActivityCopyWith<LiveActivity> get copyWith => _$LiveActivityCopyWithImpl<LiveActivity>(this as LiveActivity, _$identity);

  /// Serializes this LiveActivity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveActivity&&(identical(other.type, type) || other.type == type)&&(identical(other.actorName, actorName) || other.actorName == actorName)&&(identical(other.description, description) || other.description == description)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,actorName,description,occurredAt);

@override
String toString() {
  return 'LiveActivity(type: $type, actorName: $actorName, description: $description, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class $LiveActivityCopyWith<$Res>  {
  factory $LiveActivityCopyWith(LiveActivity value, $Res Function(LiveActivity) _then) = _$LiveActivityCopyWithImpl;
@useResult
$Res call({
 String type, String actorName, String description, String occurredAt
});




}
/// @nodoc
class _$LiveActivityCopyWithImpl<$Res>
    implements $LiveActivityCopyWith<$Res> {
  _$LiveActivityCopyWithImpl(this._self, this._then);

  final LiveActivity _self;
  final $Res Function(LiveActivity) _then;

/// Create a copy of LiveActivity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? actorName = null,Object? description = null,Object? occurredAt = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,actorName: null == actorName ? _self.actorName : actorName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveActivity].
extension LiveActivityPatterns on LiveActivity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveActivity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveActivity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveActivity value)  $default,){
final _that = this;
switch (_that) {
case _LiveActivity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveActivity value)?  $default,){
final _that = this;
switch (_that) {
case _LiveActivity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String actorName,  String description,  String occurredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveActivity() when $default != null:
return $default(_that.type,_that.actorName,_that.description,_that.occurredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String actorName,  String description,  String occurredAt)  $default,) {final _that = this;
switch (_that) {
case _LiveActivity():
return $default(_that.type,_that.actorName,_that.description,_that.occurredAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String actorName,  String description,  String occurredAt)?  $default,) {final _that = this;
switch (_that) {
case _LiveActivity() when $default != null:
return $default(_that.type,_that.actorName,_that.description,_that.occurredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveActivity implements LiveActivity {
  const _LiveActivity({required this.type, required this.actorName, required this.description, required this.occurredAt});
  factory _LiveActivity.fromJson(Map<String, dynamic> json) => _$LiveActivityFromJson(json);

@override final  String type;
// 'check_in' | 'rsvp' | 'announcement'
@override final  String actorName;
@override final  String description;
@override final  String occurredAt;

/// Create a copy of LiveActivity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveActivityCopyWith<_LiveActivity> get copyWith => __$LiveActivityCopyWithImpl<_LiveActivity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveActivity&&(identical(other.type, type) || other.type == type)&&(identical(other.actorName, actorName) || other.actorName == actorName)&&(identical(other.description, description) || other.description == description)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,actorName,description,occurredAt);

@override
String toString() {
  return 'LiveActivity(type: $type, actorName: $actorName, description: $description, occurredAt: $occurredAt)';
}


}

/// @nodoc
abstract mixin class _$LiveActivityCopyWith<$Res> implements $LiveActivityCopyWith<$Res> {
  factory _$LiveActivityCopyWith(_LiveActivity value, $Res Function(_LiveActivity) _then) = __$LiveActivityCopyWithImpl;
@override @useResult
$Res call({
 String type, String actorName, String description, String occurredAt
});




}
/// @nodoc
class __$LiveActivityCopyWithImpl<$Res>
    implements _$LiveActivityCopyWith<$Res> {
  __$LiveActivityCopyWithImpl(this._self, this._then);

  final _LiveActivity _self;
  final $Res Function(_LiveActivity) _then;

/// Create a copy of LiveActivity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? actorName = null,Object? description = null,Object? occurredAt = null,}) {
  return _then(_LiveActivity(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,actorName: null == actorName ? _self.actorName : actorName // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LiveStatus {

 String? get weddingId; bool get isLive; String? get weddingDate; int? get daysUntil; String? get partnerOneName; String? get partnerTwoName; String? get venueName; int get totalGuests; int get checkedInCount; int get attendingCount; List<LiveEvent> get dayEvents; List<LiveEvent> get upcomingEvents;
/// Create a copy of LiveStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveStatusCopyWith<LiveStatus> get copyWith => _$LiveStatusCopyWithImpl<LiveStatus>(this as LiveStatus, _$identity);

  /// Serializes this LiveStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveStatus&&(identical(other.weddingId, weddingId) || other.weddingId == weddingId)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.weddingDate, weddingDate) || other.weddingDate == weddingDate)&&(identical(other.daysUntil, daysUntil) || other.daysUntil == daysUntil)&&(identical(other.partnerOneName, partnerOneName) || other.partnerOneName == partnerOneName)&&(identical(other.partnerTwoName, partnerTwoName) || other.partnerTwoName == partnerTwoName)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.totalGuests, totalGuests) || other.totalGuests == totalGuests)&&(identical(other.checkedInCount, checkedInCount) || other.checkedInCount == checkedInCount)&&(identical(other.attendingCount, attendingCount) || other.attendingCount == attendingCount)&&const DeepCollectionEquality().equals(other.dayEvents, dayEvents)&&const DeepCollectionEquality().equals(other.upcomingEvents, upcomingEvents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weddingId,isLive,weddingDate,daysUntil,partnerOneName,partnerTwoName,venueName,totalGuests,checkedInCount,attendingCount,const DeepCollectionEquality().hash(dayEvents),const DeepCollectionEquality().hash(upcomingEvents));

@override
String toString() {
  return 'LiveStatus(weddingId: $weddingId, isLive: $isLive, weddingDate: $weddingDate, daysUntil: $daysUntil, partnerOneName: $partnerOneName, partnerTwoName: $partnerTwoName, venueName: $venueName, totalGuests: $totalGuests, checkedInCount: $checkedInCount, attendingCount: $attendingCount, dayEvents: $dayEvents, upcomingEvents: $upcomingEvents)';
}


}

/// @nodoc
abstract mixin class $LiveStatusCopyWith<$Res>  {
  factory $LiveStatusCopyWith(LiveStatus value, $Res Function(LiveStatus) _then) = _$LiveStatusCopyWithImpl;
@useResult
$Res call({
 String? weddingId, bool isLive, String? weddingDate, int? daysUntil, String? partnerOneName, String? partnerTwoName, String? venueName, int totalGuests, int checkedInCount, int attendingCount, List<LiveEvent> dayEvents, List<LiveEvent> upcomingEvents
});




}
/// @nodoc
class _$LiveStatusCopyWithImpl<$Res>
    implements $LiveStatusCopyWith<$Res> {
  _$LiveStatusCopyWithImpl(this._self, this._then);

  final LiveStatus _self;
  final $Res Function(LiveStatus) _then;

/// Create a copy of LiveStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weddingId = freezed,Object? isLive = null,Object? weddingDate = freezed,Object? daysUntil = freezed,Object? partnerOneName = freezed,Object? partnerTwoName = freezed,Object? venueName = freezed,Object? totalGuests = null,Object? checkedInCount = null,Object? attendingCount = null,Object? dayEvents = null,Object? upcomingEvents = null,}) {
  return _then(_self.copyWith(
weddingId: freezed == weddingId ? _self.weddingId : weddingId // ignore: cast_nullable_to_non_nullable
as String?,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,weddingDate: freezed == weddingDate ? _self.weddingDate : weddingDate // ignore: cast_nullable_to_non_nullable
as String?,daysUntil: freezed == daysUntil ? _self.daysUntil : daysUntil // ignore: cast_nullable_to_non_nullable
as int?,partnerOneName: freezed == partnerOneName ? _self.partnerOneName : partnerOneName // ignore: cast_nullable_to_non_nullable
as String?,partnerTwoName: freezed == partnerTwoName ? _self.partnerTwoName : partnerTwoName // ignore: cast_nullable_to_non_nullable
as String?,venueName: freezed == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String?,totalGuests: null == totalGuests ? _self.totalGuests : totalGuests // ignore: cast_nullable_to_non_nullable
as int,checkedInCount: null == checkedInCount ? _self.checkedInCount : checkedInCount // ignore: cast_nullable_to_non_nullable
as int,attendingCount: null == attendingCount ? _self.attendingCount : attendingCount // ignore: cast_nullable_to_non_nullable
as int,dayEvents: null == dayEvents ? _self.dayEvents : dayEvents // ignore: cast_nullable_to_non_nullable
as List<LiveEvent>,upcomingEvents: null == upcomingEvents ? _self.upcomingEvents : upcomingEvents // ignore: cast_nullable_to_non_nullable
as List<LiveEvent>,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveStatus].
extension LiveStatusPatterns on LiveStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveStatus value)  $default,){
final _that = this;
switch (_that) {
case _LiveStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveStatus value)?  $default,){
final _that = this;
switch (_that) {
case _LiveStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? weddingId,  bool isLive,  String? weddingDate,  int? daysUntil,  String? partnerOneName,  String? partnerTwoName,  String? venueName,  int totalGuests,  int checkedInCount,  int attendingCount,  List<LiveEvent> dayEvents,  List<LiveEvent> upcomingEvents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveStatus() when $default != null:
return $default(_that.weddingId,_that.isLive,_that.weddingDate,_that.daysUntil,_that.partnerOneName,_that.partnerTwoName,_that.venueName,_that.totalGuests,_that.checkedInCount,_that.attendingCount,_that.dayEvents,_that.upcomingEvents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? weddingId,  bool isLive,  String? weddingDate,  int? daysUntil,  String? partnerOneName,  String? partnerTwoName,  String? venueName,  int totalGuests,  int checkedInCount,  int attendingCount,  List<LiveEvent> dayEvents,  List<LiveEvent> upcomingEvents)  $default,) {final _that = this;
switch (_that) {
case _LiveStatus():
return $default(_that.weddingId,_that.isLive,_that.weddingDate,_that.daysUntil,_that.partnerOneName,_that.partnerTwoName,_that.venueName,_that.totalGuests,_that.checkedInCount,_that.attendingCount,_that.dayEvents,_that.upcomingEvents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? weddingId,  bool isLive,  String? weddingDate,  int? daysUntil,  String? partnerOneName,  String? partnerTwoName,  String? venueName,  int totalGuests,  int checkedInCount,  int attendingCount,  List<LiveEvent> dayEvents,  List<LiveEvent> upcomingEvents)?  $default,) {final _that = this;
switch (_that) {
case _LiveStatus() when $default != null:
return $default(_that.weddingId,_that.isLive,_that.weddingDate,_that.daysUntil,_that.partnerOneName,_that.partnerTwoName,_that.venueName,_that.totalGuests,_that.checkedInCount,_that.attendingCount,_that.dayEvents,_that.upcomingEvents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveStatus implements LiveStatus {
  const _LiveStatus({this.weddingId, this.isLive = false, this.weddingDate, this.daysUntil, this.partnerOneName, this.partnerTwoName, this.venueName, this.totalGuests = 0, this.checkedInCount = 0, this.attendingCount = 0, final  List<LiveEvent> dayEvents = const [], final  List<LiveEvent> upcomingEvents = const []}): _dayEvents = dayEvents,_upcomingEvents = upcomingEvents;
  factory _LiveStatus.fromJson(Map<String, dynamic> json) => _$LiveStatusFromJson(json);

@override final  String? weddingId;
@override@JsonKey() final  bool isLive;
@override final  String? weddingDate;
@override final  int? daysUntil;
@override final  String? partnerOneName;
@override final  String? partnerTwoName;
@override final  String? venueName;
@override@JsonKey() final  int totalGuests;
@override@JsonKey() final  int checkedInCount;
@override@JsonKey() final  int attendingCount;
 final  List<LiveEvent> _dayEvents;
@override@JsonKey() List<LiveEvent> get dayEvents {
  if (_dayEvents is EqualUnmodifiableListView) return _dayEvents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dayEvents);
}

 final  List<LiveEvent> _upcomingEvents;
@override@JsonKey() List<LiveEvent> get upcomingEvents {
  if (_upcomingEvents is EqualUnmodifiableListView) return _upcomingEvents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_upcomingEvents);
}


/// Create a copy of LiveStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveStatusCopyWith<_LiveStatus> get copyWith => __$LiveStatusCopyWithImpl<_LiveStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveStatus&&(identical(other.weddingId, weddingId) || other.weddingId == weddingId)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.weddingDate, weddingDate) || other.weddingDate == weddingDate)&&(identical(other.daysUntil, daysUntil) || other.daysUntil == daysUntil)&&(identical(other.partnerOneName, partnerOneName) || other.partnerOneName == partnerOneName)&&(identical(other.partnerTwoName, partnerTwoName) || other.partnerTwoName == partnerTwoName)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.totalGuests, totalGuests) || other.totalGuests == totalGuests)&&(identical(other.checkedInCount, checkedInCount) || other.checkedInCount == checkedInCount)&&(identical(other.attendingCount, attendingCount) || other.attendingCount == attendingCount)&&const DeepCollectionEquality().equals(other._dayEvents, _dayEvents)&&const DeepCollectionEquality().equals(other._upcomingEvents, _upcomingEvents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weddingId,isLive,weddingDate,daysUntil,partnerOneName,partnerTwoName,venueName,totalGuests,checkedInCount,attendingCount,const DeepCollectionEquality().hash(_dayEvents),const DeepCollectionEquality().hash(_upcomingEvents));

@override
String toString() {
  return 'LiveStatus(weddingId: $weddingId, isLive: $isLive, weddingDate: $weddingDate, daysUntil: $daysUntil, partnerOneName: $partnerOneName, partnerTwoName: $partnerTwoName, venueName: $venueName, totalGuests: $totalGuests, checkedInCount: $checkedInCount, attendingCount: $attendingCount, dayEvents: $dayEvents, upcomingEvents: $upcomingEvents)';
}


}

/// @nodoc
abstract mixin class _$LiveStatusCopyWith<$Res> implements $LiveStatusCopyWith<$Res> {
  factory _$LiveStatusCopyWith(_LiveStatus value, $Res Function(_LiveStatus) _then) = __$LiveStatusCopyWithImpl;
@override @useResult
$Res call({
 String? weddingId, bool isLive, String? weddingDate, int? daysUntil, String? partnerOneName, String? partnerTwoName, String? venueName, int totalGuests, int checkedInCount, int attendingCount, List<LiveEvent> dayEvents, List<LiveEvent> upcomingEvents
});




}
/// @nodoc
class __$LiveStatusCopyWithImpl<$Res>
    implements _$LiveStatusCopyWith<$Res> {
  __$LiveStatusCopyWithImpl(this._self, this._then);

  final _LiveStatus _self;
  final $Res Function(_LiveStatus) _then;

/// Create a copy of LiveStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weddingId = freezed,Object? isLive = null,Object? weddingDate = freezed,Object? daysUntil = freezed,Object? partnerOneName = freezed,Object? partnerTwoName = freezed,Object? venueName = freezed,Object? totalGuests = null,Object? checkedInCount = null,Object? attendingCount = null,Object? dayEvents = null,Object? upcomingEvents = null,}) {
  return _then(_LiveStatus(
weddingId: freezed == weddingId ? _self.weddingId : weddingId // ignore: cast_nullable_to_non_nullable
as String?,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,weddingDate: freezed == weddingDate ? _self.weddingDate : weddingDate // ignore: cast_nullable_to_non_nullable
as String?,daysUntil: freezed == daysUntil ? _self.daysUntil : daysUntil // ignore: cast_nullable_to_non_nullable
as int?,partnerOneName: freezed == partnerOneName ? _self.partnerOneName : partnerOneName // ignore: cast_nullable_to_non_nullable
as String?,partnerTwoName: freezed == partnerTwoName ? _self.partnerTwoName : partnerTwoName // ignore: cast_nullable_to_non_nullable
as String?,venueName: freezed == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String?,totalGuests: null == totalGuests ? _self.totalGuests : totalGuests // ignore: cast_nullable_to_non_nullable
as int,checkedInCount: null == checkedInCount ? _self.checkedInCount : checkedInCount // ignore: cast_nullable_to_non_nullable
as int,attendingCount: null == attendingCount ? _self.attendingCount : attendingCount // ignore: cast_nullable_to_non_nullable
as int,dayEvents: null == dayEvents ? _self._dayEvents : dayEvents // ignore: cast_nullable_to_non_nullable
as List<LiveEvent>,upcomingEvents: null == upcomingEvents ? _self._upcomingEvents : upcomingEvents // ignore: cast_nullable_to_non_nullable
as List<LiveEvent>,
  ));
}


}


/// @nodoc
mixin _$LiveEvent {

 String get id; String get title; String? get time; String? get category; String? get location; String? get description; String? get eventDate;
/// Create a copy of LiveEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveEventCopyWith<LiveEvent> get copyWith => _$LiveEventCopyWithImpl<LiveEvent>(this as LiveEvent, _$identity);

  /// Serializes this LiveEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.time, time) || other.time == time)&&(identical(other.category, category) || other.category == category)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,time,category,location,description,eventDate);

@override
String toString() {
  return 'LiveEvent(id: $id, title: $title, time: $time, category: $category, location: $location, description: $description, eventDate: $eventDate)';
}


}

/// @nodoc
abstract mixin class $LiveEventCopyWith<$Res>  {
  factory $LiveEventCopyWith(LiveEvent value, $Res Function(LiveEvent) _then) = _$LiveEventCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? time, String? category, String? location, String? description, String? eventDate
});




}
/// @nodoc
class _$LiveEventCopyWithImpl<$Res>
    implements $LiveEventCopyWith<$Res> {
  _$LiveEventCopyWithImpl(this._self, this._then);

  final LiveEvent _self;
  final $Res Function(LiveEvent) _then;

/// Create a copy of LiveEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? time = freezed,Object? category = freezed,Object? location = freezed,Object? description = freezed,Object? eventDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,eventDate: freezed == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveEvent].
extension LiveEventPatterns on LiveEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveEvent value)  $default,){
final _that = this;
switch (_that) {
case _LiveEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveEvent value)?  $default,){
final _that = this;
switch (_that) {
case _LiveEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? time,  String? category,  String? location,  String? description,  String? eventDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveEvent() when $default != null:
return $default(_that.id,_that.title,_that.time,_that.category,_that.location,_that.description,_that.eventDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? time,  String? category,  String? location,  String? description,  String? eventDate)  $default,) {final _that = this;
switch (_that) {
case _LiveEvent():
return $default(_that.id,_that.title,_that.time,_that.category,_that.location,_that.description,_that.eventDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? time,  String? category,  String? location,  String? description,  String? eventDate)?  $default,) {final _that = this;
switch (_that) {
case _LiveEvent() when $default != null:
return $default(_that.id,_that.title,_that.time,_that.category,_that.location,_that.description,_that.eventDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveEvent implements LiveEvent {
  const _LiveEvent({required this.id, required this.title, this.time, this.category, this.location, this.description, this.eventDate});
  factory _LiveEvent.fromJson(Map<String, dynamic> json) => _$LiveEventFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? time;
@override final  String? category;
@override final  String? location;
@override final  String? description;
@override final  String? eventDate;

/// Create a copy of LiveEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveEventCopyWith<_LiveEvent> get copyWith => __$LiveEventCopyWithImpl<_LiveEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.time, time) || other.time == time)&&(identical(other.category, category) || other.category == category)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,time,category,location,description,eventDate);

@override
String toString() {
  return 'LiveEvent(id: $id, title: $title, time: $time, category: $category, location: $location, description: $description, eventDate: $eventDate)';
}


}

/// @nodoc
abstract mixin class _$LiveEventCopyWith<$Res> implements $LiveEventCopyWith<$Res> {
  factory _$LiveEventCopyWith(_LiveEvent value, $Res Function(_LiveEvent) _then) = __$LiveEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? time, String? category, String? location, String? description, String? eventDate
});




}
/// @nodoc
class __$LiveEventCopyWithImpl<$Res>
    implements _$LiveEventCopyWith<$Res> {
  __$LiveEventCopyWithImpl(this._self, this._then);

  final _LiveEvent _self;
  final $Res Function(_LiveEvent) _then;

/// Create a copy of LiveEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? time = freezed,Object? category = freezed,Object? location = freezed,Object? description = freezed,Object? eventDate = freezed,}) {
  return _then(_LiveEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,eventDate: freezed == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
