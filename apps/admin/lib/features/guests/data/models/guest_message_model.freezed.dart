// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guest_message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GuestMessageModel {

 String get id; String? get subject; String get body; String get channel; Map<String, dynamic> get recipientFilter; int get recipientCount; String get status; String? get sentAt; String? get createdAt;
/// Create a copy of GuestMessageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuestMessageModelCopyWith<GuestMessageModel> get copyWith => _$GuestMessageModelCopyWithImpl<GuestMessageModel>(this as GuestMessageModel, _$identity);

  /// Serializes this GuestMessageModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuestMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body)&&(identical(other.channel, channel) || other.channel == channel)&&const DeepCollectionEquality().equals(other.recipientFilter, recipientFilter)&&(identical(other.recipientCount, recipientCount) || other.recipientCount == recipientCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subject,body,channel,const DeepCollectionEquality().hash(recipientFilter),recipientCount,status,sentAt,createdAt);

@override
String toString() {
  return 'GuestMessageModel(id: $id, subject: $subject, body: $body, channel: $channel, recipientFilter: $recipientFilter, recipientCount: $recipientCount, status: $status, sentAt: $sentAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GuestMessageModelCopyWith<$Res>  {
  factory $GuestMessageModelCopyWith(GuestMessageModel value, $Res Function(GuestMessageModel) _then) = _$GuestMessageModelCopyWithImpl;
@useResult
$Res call({
 String id, String? subject, String body, String channel, Map<String, dynamic> recipientFilter, int recipientCount, String status, String? sentAt, String? createdAt
});




}
/// @nodoc
class _$GuestMessageModelCopyWithImpl<$Res>
    implements $GuestMessageModelCopyWith<$Res> {
  _$GuestMessageModelCopyWithImpl(this._self, this._then);

  final GuestMessageModel _self;
  final $Res Function(GuestMessageModel) _then;

/// Create a copy of GuestMessageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? subject = freezed,Object? body = null,Object? channel = null,Object? recipientFilter = null,Object? recipientCount = null,Object? status = null,Object? sentAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String?,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,recipientFilter: null == recipientFilter ? _self.recipientFilter : recipientFilter // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,recipientCount: null == recipientCount ? _self.recipientCount : recipientCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GuestMessageModel].
extension GuestMessageModelPatterns on GuestMessageModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuestMessageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuestMessageModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuestMessageModel value)  $default,){
final _that = this;
switch (_that) {
case _GuestMessageModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuestMessageModel value)?  $default,){
final _that = this;
switch (_that) {
case _GuestMessageModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? subject,  String body,  String channel,  Map<String, dynamic> recipientFilter,  int recipientCount,  String status,  String? sentAt,  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuestMessageModel() when $default != null:
return $default(_that.id,_that.subject,_that.body,_that.channel,_that.recipientFilter,_that.recipientCount,_that.status,_that.sentAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? subject,  String body,  String channel,  Map<String, dynamic> recipientFilter,  int recipientCount,  String status,  String? sentAt,  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _GuestMessageModel():
return $default(_that.id,_that.subject,_that.body,_that.channel,_that.recipientFilter,_that.recipientCount,_that.status,_that.sentAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? subject,  String body,  String channel,  Map<String, dynamic> recipientFilter,  int recipientCount,  String status,  String? sentAt,  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GuestMessageModel() when $default != null:
return $default(_that.id,_that.subject,_that.body,_that.channel,_that.recipientFilter,_that.recipientCount,_that.status,_that.sentAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuestMessageModel implements GuestMessageModel {
  const _GuestMessageModel({required this.id, this.subject, required this.body, this.channel = 'in_app', final  Map<String, dynamic> recipientFilter = const {}, this.recipientCount = 0, this.status = 'sent', this.sentAt, this.createdAt}): _recipientFilter = recipientFilter;
  factory _GuestMessageModel.fromJson(Map<String, dynamic> json) => _$GuestMessageModelFromJson(json);

@override final  String id;
@override final  String? subject;
@override final  String body;
@override@JsonKey() final  String channel;
 final  Map<String, dynamic> _recipientFilter;
@override@JsonKey() Map<String, dynamic> get recipientFilter {
  if (_recipientFilter is EqualUnmodifiableMapView) return _recipientFilter;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_recipientFilter);
}

@override@JsonKey() final  int recipientCount;
@override@JsonKey() final  String status;
@override final  String? sentAt;
@override final  String? createdAt;

/// Create a copy of GuestMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestMessageModelCopyWith<_GuestMessageModel> get copyWith => __$GuestMessageModelCopyWithImpl<_GuestMessageModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuestMessageModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestMessageModel&&(identical(other.id, id) || other.id == id)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body)&&(identical(other.channel, channel) || other.channel == channel)&&const DeepCollectionEquality().equals(other._recipientFilter, _recipientFilter)&&(identical(other.recipientCount, recipientCount) || other.recipientCount == recipientCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,subject,body,channel,const DeepCollectionEquality().hash(_recipientFilter),recipientCount,status,sentAt,createdAt);

@override
String toString() {
  return 'GuestMessageModel(id: $id, subject: $subject, body: $body, channel: $channel, recipientFilter: $recipientFilter, recipientCount: $recipientCount, status: $status, sentAt: $sentAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GuestMessageModelCopyWith<$Res> implements $GuestMessageModelCopyWith<$Res> {
  factory _$GuestMessageModelCopyWith(_GuestMessageModel value, $Res Function(_GuestMessageModel) _then) = __$GuestMessageModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? subject, String body, String channel, Map<String, dynamic> recipientFilter, int recipientCount, String status, String? sentAt, String? createdAt
});




}
/// @nodoc
class __$GuestMessageModelCopyWithImpl<$Res>
    implements _$GuestMessageModelCopyWith<$Res> {
  __$GuestMessageModelCopyWithImpl(this._self, this._then);

  final _GuestMessageModel _self;
  final $Res Function(_GuestMessageModel) _then;

/// Create a copy of GuestMessageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? subject = freezed,Object? body = null,Object? channel = null,Object? recipientFilter = null,Object? recipientCount = null,Object? status = null,Object? sentAt = freezed,Object? createdAt = freezed,}) {
  return _then(_GuestMessageModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subject: freezed == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String?,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,channel: null == channel ? _self.channel : channel // ignore: cast_nullable_to_non_nullable
as String,recipientFilter: null == recipientFilter ? _self._recipientFilter : recipientFilter // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,recipientCount: null == recipientCount ? _self.recipientCount : recipientCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,sentAt: freezed == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
