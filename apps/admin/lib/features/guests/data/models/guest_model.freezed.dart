// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guest_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GuestModel {

 String get id; String get firstName; String get lastName; String get fullName; String? get email; String? get phone; String get rsvpStatus; String? get group; String? get relationship; String get ageGroup; bool get isVip; String? get dietaryRequirements; bool get plusOneAllowed; String? get plusOneName; String? get invitationSentAt; String? get rsvpRespondedAt; String? get checkedInAt; bool get needsTransport; bool get needsAccommodation; String? get token; String? get notes; String? get address; String? get language;
/// Create a copy of GuestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuestModelCopyWith<GuestModel> get copyWith => _$GuestModelCopyWithImpl<GuestModel>(this as GuestModel, _$identity);

  /// Serializes this GuestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.rsvpStatus, rsvpStatus) || other.rsvpStatus == rsvpStatus)&&(identical(other.group, group) || other.group == group)&&(identical(other.relationship, relationship) || other.relationship == relationship)&&(identical(other.ageGroup, ageGroup) || other.ageGroup == ageGroup)&&(identical(other.isVip, isVip) || other.isVip == isVip)&&(identical(other.dietaryRequirements, dietaryRequirements) || other.dietaryRequirements == dietaryRequirements)&&(identical(other.plusOneAllowed, plusOneAllowed) || other.plusOneAllowed == plusOneAllowed)&&(identical(other.plusOneName, plusOneName) || other.plusOneName == plusOneName)&&(identical(other.invitationSentAt, invitationSentAt) || other.invitationSentAt == invitationSentAt)&&(identical(other.rsvpRespondedAt, rsvpRespondedAt) || other.rsvpRespondedAt == rsvpRespondedAt)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt)&&(identical(other.needsTransport, needsTransport) || other.needsTransport == needsTransport)&&(identical(other.needsAccommodation, needsAccommodation) || other.needsAccommodation == needsAccommodation)&&(identical(other.token, token) || other.token == token)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.address, address) || other.address == address)&&(identical(other.language, language) || other.language == language));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,firstName,lastName,fullName,email,phone,rsvpStatus,group,relationship,ageGroup,isVip,dietaryRequirements,plusOneAllowed,plusOneName,invitationSentAt,rsvpRespondedAt,checkedInAt,needsTransport,needsAccommodation,token,notes,address,language]);

@override
String toString() {
  return 'GuestModel(id: $id, firstName: $firstName, lastName: $lastName, fullName: $fullName, email: $email, phone: $phone, rsvpStatus: $rsvpStatus, group: $group, relationship: $relationship, ageGroup: $ageGroup, isVip: $isVip, dietaryRequirements: $dietaryRequirements, plusOneAllowed: $plusOneAllowed, plusOneName: $plusOneName, invitationSentAt: $invitationSentAt, rsvpRespondedAt: $rsvpRespondedAt, checkedInAt: $checkedInAt, needsTransport: $needsTransport, needsAccommodation: $needsAccommodation, token: $token, notes: $notes, address: $address, language: $language)';
}


}

/// @nodoc
abstract mixin class $GuestModelCopyWith<$Res>  {
  factory $GuestModelCopyWith(GuestModel value, $Res Function(GuestModel) _then) = _$GuestModelCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, String lastName, String fullName, String? email, String? phone, String rsvpStatus, String? group, String? relationship, String ageGroup, bool isVip, String? dietaryRequirements, bool plusOneAllowed, String? plusOneName, String? invitationSentAt, String? rsvpRespondedAt, String? checkedInAt, bool needsTransport, bool needsAccommodation, String? token, String? notes, String? address, String? language
});




}
/// @nodoc
class _$GuestModelCopyWithImpl<$Res>
    implements $GuestModelCopyWith<$Res> {
  _$GuestModelCopyWithImpl(this._self, this._then);

  final GuestModel _self;
  final $Res Function(GuestModel) _then;

/// Create a copy of GuestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? fullName = null,Object? email = freezed,Object? phone = freezed,Object? rsvpStatus = null,Object? group = freezed,Object? relationship = freezed,Object? ageGroup = null,Object? isVip = null,Object? dietaryRequirements = freezed,Object? plusOneAllowed = null,Object? plusOneName = freezed,Object? invitationSentAt = freezed,Object? rsvpRespondedAt = freezed,Object? checkedInAt = freezed,Object? needsTransport = null,Object? needsAccommodation = null,Object? token = freezed,Object? notes = freezed,Object? address = freezed,Object? language = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,rsvpStatus: null == rsvpStatus ? _self.rsvpStatus : rsvpStatus // ignore: cast_nullable_to_non_nullable
as String,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,relationship: freezed == relationship ? _self.relationship : relationship // ignore: cast_nullable_to_non_nullable
as String?,ageGroup: null == ageGroup ? _self.ageGroup : ageGroup // ignore: cast_nullable_to_non_nullable
as String,isVip: null == isVip ? _self.isVip : isVip // ignore: cast_nullable_to_non_nullable
as bool,dietaryRequirements: freezed == dietaryRequirements ? _self.dietaryRequirements : dietaryRequirements // ignore: cast_nullable_to_non_nullable
as String?,plusOneAllowed: null == plusOneAllowed ? _self.plusOneAllowed : plusOneAllowed // ignore: cast_nullable_to_non_nullable
as bool,plusOneName: freezed == plusOneName ? _self.plusOneName : plusOneName // ignore: cast_nullable_to_non_nullable
as String?,invitationSentAt: freezed == invitationSentAt ? _self.invitationSentAt : invitationSentAt // ignore: cast_nullable_to_non_nullable
as String?,rsvpRespondedAt: freezed == rsvpRespondedAt ? _self.rsvpRespondedAt : rsvpRespondedAt // ignore: cast_nullable_to_non_nullable
as String?,checkedInAt: freezed == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as String?,needsTransport: null == needsTransport ? _self.needsTransport : needsTransport // ignore: cast_nullable_to_non_nullable
as bool,needsAccommodation: null == needsAccommodation ? _self.needsAccommodation : needsAccommodation // ignore: cast_nullable_to_non_nullable
as bool,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GuestModel].
extension GuestModelPatterns on GuestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuestModel value)  $default,){
final _that = this;
switch (_that) {
case _GuestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuestModel value)?  $default,){
final _that = this;
switch (_that) {
case _GuestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String fullName,  String? email,  String? phone,  String rsvpStatus,  String? group,  String? relationship,  String ageGroup,  bool isVip,  String? dietaryRequirements,  bool plusOneAllowed,  String? plusOneName,  String? invitationSentAt,  String? rsvpRespondedAt,  String? checkedInAt,  bool needsTransport,  bool needsAccommodation,  String? token,  String? notes,  String? address,  String? language)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuestModel() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.fullName,_that.email,_that.phone,_that.rsvpStatus,_that.group,_that.relationship,_that.ageGroup,_that.isVip,_that.dietaryRequirements,_that.plusOneAllowed,_that.plusOneName,_that.invitationSentAt,_that.rsvpRespondedAt,_that.checkedInAt,_that.needsTransport,_that.needsAccommodation,_that.token,_that.notes,_that.address,_that.language);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String firstName,  String lastName,  String fullName,  String? email,  String? phone,  String rsvpStatus,  String? group,  String? relationship,  String ageGroup,  bool isVip,  String? dietaryRequirements,  bool plusOneAllowed,  String? plusOneName,  String? invitationSentAt,  String? rsvpRespondedAt,  String? checkedInAt,  bool needsTransport,  bool needsAccommodation,  String? token,  String? notes,  String? address,  String? language)  $default,) {final _that = this;
switch (_that) {
case _GuestModel():
return $default(_that.id,_that.firstName,_that.lastName,_that.fullName,_that.email,_that.phone,_that.rsvpStatus,_that.group,_that.relationship,_that.ageGroup,_that.isVip,_that.dietaryRequirements,_that.plusOneAllowed,_that.plusOneName,_that.invitationSentAt,_that.rsvpRespondedAt,_that.checkedInAt,_that.needsTransport,_that.needsAccommodation,_that.token,_that.notes,_that.address,_that.language);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String firstName,  String lastName,  String fullName,  String? email,  String? phone,  String rsvpStatus,  String? group,  String? relationship,  String ageGroup,  bool isVip,  String? dietaryRequirements,  bool plusOneAllowed,  String? plusOneName,  String? invitationSentAt,  String? rsvpRespondedAt,  String? checkedInAt,  bool needsTransport,  bool needsAccommodation,  String? token,  String? notes,  String? address,  String? language)?  $default,) {final _that = this;
switch (_that) {
case _GuestModel() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.fullName,_that.email,_that.phone,_that.rsvpStatus,_that.group,_that.relationship,_that.ageGroup,_that.isVip,_that.dietaryRequirements,_that.plusOneAllowed,_that.plusOneName,_that.invitationSentAt,_that.rsvpRespondedAt,_that.checkedInAt,_that.needsTransport,_that.needsAccommodation,_that.token,_that.notes,_that.address,_that.language);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuestModel implements GuestModel {
  const _GuestModel({required this.id, required this.firstName, required this.lastName, required this.fullName, this.email, this.phone, this.rsvpStatus = 'pending', this.group, this.relationship, this.ageGroup = 'adult', this.isVip = false, this.dietaryRequirements, this.plusOneAllowed = false, this.plusOneName, this.invitationSentAt, this.rsvpRespondedAt, this.checkedInAt, this.needsTransport = false, this.needsAccommodation = false, this.token, this.notes, this.address, this.language});
  factory _GuestModel.fromJson(Map<String, dynamic> json) => _$GuestModelFromJson(json);

@override final  String id;
@override final  String firstName;
@override final  String lastName;
@override final  String fullName;
@override final  String? email;
@override final  String? phone;
@override@JsonKey() final  String rsvpStatus;
@override final  String? group;
@override final  String? relationship;
@override@JsonKey() final  String ageGroup;
@override@JsonKey() final  bool isVip;
@override final  String? dietaryRequirements;
@override@JsonKey() final  bool plusOneAllowed;
@override final  String? plusOneName;
@override final  String? invitationSentAt;
@override final  String? rsvpRespondedAt;
@override final  String? checkedInAt;
@override@JsonKey() final  bool needsTransport;
@override@JsonKey() final  bool needsAccommodation;
@override final  String? token;
@override final  String? notes;
@override final  String? address;
@override final  String? language;

/// Create a copy of GuestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestModelCopyWith<_GuestModel> get copyWith => __$GuestModelCopyWithImpl<_GuestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.rsvpStatus, rsvpStatus) || other.rsvpStatus == rsvpStatus)&&(identical(other.group, group) || other.group == group)&&(identical(other.relationship, relationship) || other.relationship == relationship)&&(identical(other.ageGroup, ageGroup) || other.ageGroup == ageGroup)&&(identical(other.isVip, isVip) || other.isVip == isVip)&&(identical(other.dietaryRequirements, dietaryRequirements) || other.dietaryRequirements == dietaryRequirements)&&(identical(other.plusOneAllowed, plusOneAllowed) || other.plusOneAllowed == plusOneAllowed)&&(identical(other.plusOneName, plusOneName) || other.plusOneName == plusOneName)&&(identical(other.invitationSentAt, invitationSentAt) || other.invitationSentAt == invitationSentAt)&&(identical(other.rsvpRespondedAt, rsvpRespondedAt) || other.rsvpRespondedAt == rsvpRespondedAt)&&(identical(other.checkedInAt, checkedInAt) || other.checkedInAt == checkedInAt)&&(identical(other.needsTransport, needsTransport) || other.needsTransport == needsTransport)&&(identical(other.needsAccommodation, needsAccommodation) || other.needsAccommodation == needsAccommodation)&&(identical(other.token, token) || other.token == token)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.address, address) || other.address == address)&&(identical(other.language, language) || other.language == language));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,firstName,lastName,fullName,email,phone,rsvpStatus,group,relationship,ageGroup,isVip,dietaryRequirements,plusOneAllowed,plusOneName,invitationSentAt,rsvpRespondedAt,checkedInAt,needsTransport,needsAccommodation,token,notes,address,language]);

@override
String toString() {
  return 'GuestModel(id: $id, firstName: $firstName, lastName: $lastName, fullName: $fullName, email: $email, phone: $phone, rsvpStatus: $rsvpStatus, group: $group, relationship: $relationship, ageGroup: $ageGroup, isVip: $isVip, dietaryRequirements: $dietaryRequirements, plusOneAllowed: $plusOneAllowed, plusOneName: $plusOneName, invitationSentAt: $invitationSentAt, rsvpRespondedAt: $rsvpRespondedAt, checkedInAt: $checkedInAt, needsTransport: $needsTransport, needsAccommodation: $needsAccommodation, token: $token, notes: $notes, address: $address, language: $language)';
}


}

/// @nodoc
abstract mixin class _$GuestModelCopyWith<$Res> implements $GuestModelCopyWith<$Res> {
  factory _$GuestModelCopyWith(_GuestModel value, $Res Function(_GuestModel) _then) = __$GuestModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, String lastName, String fullName, String? email, String? phone, String rsvpStatus, String? group, String? relationship, String ageGroup, bool isVip, String? dietaryRequirements, bool plusOneAllowed, String? plusOneName, String? invitationSentAt, String? rsvpRespondedAt, String? checkedInAt, bool needsTransport, bool needsAccommodation, String? token, String? notes, String? address, String? language
});




}
/// @nodoc
class __$GuestModelCopyWithImpl<$Res>
    implements _$GuestModelCopyWith<$Res> {
  __$GuestModelCopyWithImpl(this._self, this._then);

  final _GuestModel _self;
  final $Res Function(_GuestModel) _then;

/// Create a copy of GuestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? fullName = null,Object? email = freezed,Object? phone = freezed,Object? rsvpStatus = null,Object? group = freezed,Object? relationship = freezed,Object? ageGroup = null,Object? isVip = null,Object? dietaryRequirements = freezed,Object? plusOneAllowed = null,Object? plusOneName = freezed,Object? invitationSentAt = freezed,Object? rsvpRespondedAt = freezed,Object? checkedInAt = freezed,Object? needsTransport = null,Object? needsAccommodation = null,Object? token = freezed,Object? notes = freezed,Object? address = freezed,Object? language = freezed,}) {
  return _then(_GuestModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,rsvpStatus: null == rsvpStatus ? _self.rsvpStatus : rsvpStatus // ignore: cast_nullable_to_non_nullable
as String,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,relationship: freezed == relationship ? _self.relationship : relationship // ignore: cast_nullable_to_non_nullable
as String?,ageGroup: null == ageGroup ? _self.ageGroup : ageGroup // ignore: cast_nullable_to_non_nullable
as String,isVip: null == isVip ? _self.isVip : isVip // ignore: cast_nullable_to_non_nullable
as bool,dietaryRequirements: freezed == dietaryRequirements ? _self.dietaryRequirements : dietaryRequirements // ignore: cast_nullable_to_non_nullable
as String?,plusOneAllowed: null == plusOneAllowed ? _self.plusOneAllowed : plusOneAllowed // ignore: cast_nullable_to_non_nullable
as bool,plusOneName: freezed == plusOneName ? _self.plusOneName : plusOneName // ignore: cast_nullable_to_non_nullable
as String?,invitationSentAt: freezed == invitationSentAt ? _self.invitationSentAt : invitationSentAt // ignore: cast_nullable_to_non_nullable
as String?,rsvpRespondedAt: freezed == rsvpRespondedAt ? _self.rsvpRespondedAt : rsvpRespondedAt // ignore: cast_nullable_to_non_nullable
as String?,checkedInAt: freezed == checkedInAt ? _self.checkedInAt : checkedInAt // ignore: cast_nullable_to_non_nullable
as String?,needsTransport: null == needsTransport ? _self.needsTransport : needsTransport // ignore: cast_nullable_to_non_nullable
as bool,needsAccommodation: null == needsAccommodation ? _self.needsAccommodation : needsAccommodation // ignore: cast_nullable_to_non_nullable
as bool,token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$GuestsOverview {

 int get totalGuests; int get attending; int get declined; int get pending; int get responseRate; GuestQuickStats get quickStats; Map<String, dynamic> get groups; int get vipCount; int get invitedCount; int get notInvitedYet;
/// Create a copy of GuestsOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuestsOverviewCopyWith<GuestsOverview> get copyWith => _$GuestsOverviewCopyWithImpl<GuestsOverview>(this as GuestsOverview, _$identity);

  /// Serializes this GuestsOverview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuestsOverview&&(identical(other.totalGuests, totalGuests) || other.totalGuests == totalGuests)&&(identical(other.attending, attending) || other.attending == attending)&&(identical(other.declined, declined) || other.declined == declined)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.responseRate, responseRate) || other.responseRate == responseRate)&&(identical(other.quickStats, quickStats) || other.quickStats == quickStats)&&const DeepCollectionEquality().equals(other.groups, groups)&&(identical(other.vipCount, vipCount) || other.vipCount == vipCount)&&(identical(other.invitedCount, invitedCount) || other.invitedCount == invitedCount)&&(identical(other.notInvitedYet, notInvitedYet) || other.notInvitedYet == notInvitedYet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalGuests,attending,declined,pending,responseRate,quickStats,const DeepCollectionEquality().hash(groups),vipCount,invitedCount,notInvitedYet);

@override
String toString() {
  return 'GuestsOverview(totalGuests: $totalGuests, attending: $attending, declined: $declined, pending: $pending, responseRate: $responseRate, quickStats: $quickStats, groups: $groups, vipCount: $vipCount, invitedCount: $invitedCount, notInvitedYet: $notInvitedYet)';
}


}

/// @nodoc
abstract mixin class $GuestsOverviewCopyWith<$Res>  {
  factory $GuestsOverviewCopyWith(GuestsOverview value, $Res Function(GuestsOverview) _then) = _$GuestsOverviewCopyWithImpl;
@useResult
$Res call({
 int totalGuests, int attending, int declined, int pending, int responseRate, GuestQuickStats quickStats, Map<String, dynamic> groups, int vipCount, int invitedCount, int notInvitedYet
});


$GuestQuickStatsCopyWith<$Res> get quickStats;

}
/// @nodoc
class _$GuestsOverviewCopyWithImpl<$Res>
    implements $GuestsOverviewCopyWith<$Res> {
  _$GuestsOverviewCopyWithImpl(this._self, this._then);

  final GuestsOverview _self;
  final $Res Function(GuestsOverview) _then;

/// Create a copy of GuestsOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalGuests = null,Object? attending = null,Object? declined = null,Object? pending = null,Object? responseRate = null,Object? quickStats = null,Object? groups = null,Object? vipCount = null,Object? invitedCount = null,Object? notInvitedYet = null,}) {
  return _then(_self.copyWith(
totalGuests: null == totalGuests ? _self.totalGuests : totalGuests // ignore: cast_nullable_to_non_nullable
as int,attending: null == attending ? _self.attending : attending // ignore: cast_nullable_to_non_nullable
as int,declined: null == declined ? _self.declined : declined // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,responseRate: null == responseRate ? _self.responseRate : responseRate // ignore: cast_nullable_to_non_nullable
as int,quickStats: null == quickStats ? _self.quickStats : quickStats // ignore: cast_nullable_to_non_nullable
as GuestQuickStats,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,vipCount: null == vipCount ? _self.vipCount : vipCount // ignore: cast_nullable_to_non_nullable
as int,invitedCount: null == invitedCount ? _self.invitedCount : invitedCount // ignore: cast_nullable_to_non_nullable
as int,notInvitedYet: null == notInvitedYet ? _self.notInvitedYet : notInvitedYet // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of GuestsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuestQuickStatsCopyWith<$Res> get quickStats {
  
  return $GuestQuickStatsCopyWith<$Res>(_self.quickStats, (value) {
    return _then(_self.copyWith(quickStats: value));
  });
}
}


/// Adds pattern-matching-related methods to [GuestsOverview].
extension GuestsOverviewPatterns on GuestsOverview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuestsOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuestsOverview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuestsOverview value)  $default,){
final _that = this;
switch (_that) {
case _GuestsOverview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuestsOverview value)?  $default,){
final _that = this;
switch (_that) {
case _GuestsOverview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalGuests,  int attending,  int declined,  int pending,  int responseRate,  GuestQuickStats quickStats,  Map<String, dynamic> groups,  int vipCount,  int invitedCount,  int notInvitedYet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuestsOverview() when $default != null:
return $default(_that.totalGuests,_that.attending,_that.declined,_that.pending,_that.responseRate,_that.quickStats,_that.groups,_that.vipCount,_that.invitedCount,_that.notInvitedYet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalGuests,  int attending,  int declined,  int pending,  int responseRate,  GuestQuickStats quickStats,  Map<String, dynamic> groups,  int vipCount,  int invitedCount,  int notInvitedYet)  $default,) {final _that = this;
switch (_that) {
case _GuestsOverview():
return $default(_that.totalGuests,_that.attending,_that.declined,_that.pending,_that.responseRate,_that.quickStats,_that.groups,_that.vipCount,_that.invitedCount,_that.notInvitedYet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalGuests,  int attending,  int declined,  int pending,  int responseRate,  GuestQuickStats quickStats,  Map<String, dynamic> groups,  int vipCount,  int invitedCount,  int notInvitedYet)?  $default,) {final _that = this;
switch (_that) {
case _GuestsOverview() when $default != null:
return $default(_that.totalGuests,_that.attending,_that.declined,_that.pending,_that.responseRate,_that.quickStats,_that.groups,_that.vipCount,_that.invitedCount,_that.notInvitedYet);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuestsOverview implements GuestsOverview {
  const _GuestsOverview({this.totalGuests = 0, this.attending = 0, this.declined = 0, this.pending = 0, this.responseRate = 0, this.quickStats = const GuestQuickStats(), final  Map<String, dynamic> groups = const {}, this.vipCount = 0, this.invitedCount = 0, this.notInvitedYet = 0}): _groups = groups;
  factory _GuestsOverview.fromJson(Map<String, dynamic> json) => _$GuestsOverviewFromJson(json);

@override@JsonKey() final  int totalGuests;
@override@JsonKey() final  int attending;
@override@JsonKey() final  int declined;
@override@JsonKey() final  int pending;
@override@JsonKey() final  int responseRate;
@override@JsonKey() final  GuestQuickStats quickStats;
 final  Map<String, dynamic> _groups;
@override@JsonKey() Map<String, dynamic> get groups {
  if (_groups is EqualUnmodifiableMapView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_groups);
}

@override@JsonKey() final  int vipCount;
@override@JsonKey() final  int invitedCount;
@override@JsonKey() final  int notInvitedYet;

/// Create a copy of GuestsOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestsOverviewCopyWith<_GuestsOverview> get copyWith => __$GuestsOverviewCopyWithImpl<_GuestsOverview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuestsOverviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestsOverview&&(identical(other.totalGuests, totalGuests) || other.totalGuests == totalGuests)&&(identical(other.attending, attending) || other.attending == attending)&&(identical(other.declined, declined) || other.declined == declined)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.responseRate, responseRate) || other.responseRate == responseRate)&&(identical(other.quickStats, quickStats) || other.quickStats == quickStats)&&const DeepCollectionEquality().equals(other._groups, _groups)&&(identical(other.vipCount, vipCount) || other.vipCount == vipCount)&&(identical(other.invitedCount, invitedCount) || other.invitedCount == invitedCount)&&(identical(other.notInvitedYet, notInvitedYet) || other.notInvitedYet == notInvitedYet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalGuests,attending,declined,pending,responseRate,quickStats,const DeepCollectionEquality().hash(_groups),vipCount,invitedCount,notInvitedYet);

@override
String toString() {
  return 'GuestsOverview(totalGuests: $totalGuests, attending: $attending, declined: $declined, pending: $pending, responseRate: $responseRate, quickStats: $quickStats, groups: $groups, vipCount: $vipCount, invitedCount: $invitedCount, notInvitedYet: $notInvitedYet)';
}


}

/// @nodoc
abstract mixin class _$GuestsOverviewCopyWith<$Res> implements $GuestsOverviewCopyWith<$Res> {
  factory _$GuestsOverviewCopyWith(_GuestsOverview value, $Res Function(_GuestsOverview) _then) = __$GuestsOverviewCopyWithImpl;
@override @useResult
$Res call({
 int totalGuests, int attending, int declined, int pending, int responseRate, GuestQuickStats quickStats, Map<String, dynamic> groups, int vipCount, int invitedCount, int notInvitedYet
});


@override $GuestQuickStatsCopyWith<$Res> get quickStats;

}
/// @nodoc
class __$GuestsOverviewCopyWithImpl<$Res>
    implements _$GuestsOverviewCopyWith<$Res> {
  __$GuestsOverviewCopyWithImpl(this._self, this._then);

  final _GuestsOverview _self;
  final $Res Function(_GuestsOverview) _then;

/// Create a copy of GuestsOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalGuests = null,Object? attending = null,Object? declined = null,Object? pending = null,Object? responseRate = null,Object? quickStats = null,Object? groups = null,Object? vipCount = null,Object? invitedCount = null,Object? notInvitedYet = null,}) {
  return _then(_GuestsOverview(
totalGuests: null == totalGuests ? _self.totalGuests : totalGuests // ignore: cast_nullable_to_non_nullable
as int,attending: null == attending ? _self.attending : attending // ignore: cast_nullable_to_non_nullable
as int,declined: null == declined ? _self.declined : declined // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,responseRate: null == responseRate ? _self.responseRate : responseRate // ignore: cast_nullable_to_non_nullable
as int,quickStats: null == quickStats ? _self.quickStats : quickStats // ignore: cast_nullable_to_non_nullable
as GuestQuickStats,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,vipCount: null == vipCount ? _self.vipCount : vipCount // ignore: cast_nullable_to_non_nullable
as int,invitedCount: null == invitedCount ? _self.invitedCount : invitedCount // ignore: cast_nullable_to_non_nullable
as int,notInvitedYet: null == notInvitedYet ? _self.notInvitedYet : notInvitedYet // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of GuestsOverview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuestQuickStatsCopyWith<$Res> get quickStats {
  
  return $GuestQuickStatsCopyWith<$Res>(_self.quickStats, (value) {
    return _then(_self.copyWith(quickStats: value));
  });
}
}


/// @nodoc
mixin _$GuestQuickStats {

 int get vegetarian; int get allergies; int get kids; int get plusOnes;
/// Create a copy of GuestQuickStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuestQuickStatsCopyWith<GuestQuickStats> get copyWith => _$GuestQuickStatsCopyWithImpl<GuestQuickStats>(this as GuestQuickStats, _$identity);

  /// Serializes this GuestQuickStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuestQuickStats&&(identical(other.vegetarian, vegetarian) || other.vegetarian == vegetarian)&&(identical(other.allergies, allergies) || other.allergies == allergies)&&(identical(other.kids, kids) || other.kids == kids)&&(identical(other.plusOnes, plusOnes) || other.plusOnes == plusOnes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vegetarian,allergies,kids,plusOnes);

@override
String toString() {
  return 'GuestQuickStats(vegetarian: $vegetarian, allergies: $allergies, kids: $kids, plusOnes: $plusOnes)';
}


}

/// @nodoc
abstract mixin class $GuestQuickStatsCopyWith<$Res>  {
  factory $GuestQuickStatsCopyWith(GuestQuickStats value, $Res Function(GuestQuickStats) _then) = _$GuestQuickStatsCopyWithImpl;
@useResult
$Res call({
 int vegetarian, int allergies, int kids, int plusOnes
});




}
/// @nodoc
class _$GuestQuickStatsCopyWithImpl<$Res>
    implements $GuestQuickStatsCopyWith<$Res> {
  _$GuestQuickStatsCopyWithImpl(this._self, this._then);

  final GuestQuickStats _self;
  final $Res Function(GuestQuickStats) _then;

/// Create a copy of GuestQuickStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vegetarian = null,Object? allergies = null,Object? kids = null,Object? plusOnes = null,}) {
  return _then(_self.copyWith(
vegetarian: null == vegetarian ? _self.vegetarian : vegetarian // ignore: cast_nullable_to_non_nullable
as int,allergies: null == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as int,kids: null == kids ? _self.kids : kids // ignore: cast_nullable_to_non_nullable
as int,plusOnes: null == plusOnes ? _self.plusOnes : plusOnes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GuestQuickStats].
extension GuestQuickStatsPatterns on GuestQuickStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuestQuickStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuestQuickStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuestQuickStats value)  $default,){
final _that = this;
switch (_that) {
case _GuestQuickStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuestQuickStats value)?  $default,){
final _that = this;
switch (_that) {
case _GuestQuickStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int vegetarian,  int allergies,  int kids,  int plusOnes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuestQuickStats() when $default != null:
return $default(_that.vegetarian,_that.allergies,_that.kids,_that.plusOnes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int vegetarian,  int allergies,  int kids,  int plusOnes)  $default,) {final _that = this;
switch (_that) {
case _GuestQuickStats():
return $default(_that.vegetarian,_that.allergies,_that.kids,_that.plusOnes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int vegetarian,  int allergies,  int kids,  int plusOnes)?  $default,) {final _that = this;
switch (_that) {
case _GuestQuickStats() when $default != null:
return $default(_that.vegetarian,_that.allergies,_that.kids,_that.plusOnes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuestQuickStats implements GuestQuickStats {
  const _GuestQuickStats({this.vegetarian = 0, this.allergies = 0, this.kids = 0, this.plusOnes = 0});
  factory _GuestQuickStats.fromJson(Map<String, dynamic> json) => _$GuestQuickStatsFromJson(json);

@override@JsonKey() final  int vegetarian;
@override@JsonKey() final  int allergies;
@override@JsonKey() final  int kids;
@override@JsonKey() final  int plusOnes;

/// Create a copy of GuestQuickStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestQuickStatsCopyWith<_GuestQuickStats> get copyWith => __$GuestQuickStatsCopyWithImpl<_GuestQuickStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuestQuickStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestQuickStats&&(identical(other.vegetarian, vegetarian) || other.vegetarian == vegetarian)&&(identical(other.allergies, allergies) || other.allergies == allergies)&&(identical(other.kids, kids) || other.kids == kids)&&(identical(other.plusOnes, plusOnes) || other.plusOnes == plusOnes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vegetarian,allergies,kids,plusOnes);

@override
String toString() {
  return 'GuestQuickStats(vegetarian: $vegetarian, allergies: $allergies, kids: $kids, plusOnes: $plusOnes)';
}


}

/// @nodoc
abstract mixin class _$GuestQuickStatsCopyWith<$Res> implements $GuestQuickStatsCopyWith<$Res> {
  factory _$GuestQuickStatsCopyWith(_GuestQuickStats value, $Res Function(_GuestQuickStats) _then) = __$GuestQuickStatsCopyWithImpl;
@override @useResult
$Res call({
 int vegetarian, int allergies, int kids, int plusOnes
});




}
/// @nodoc
class __$GuestQuickStatsCopyWithImpl<$Res>
    implements _$GuestQuickStatsCopyWith<$Res> {
  __$GuestQuickStatsCopyWithImpl(this._self, this._then);

  final _GuestQuickStats _self;
  final $Res Function(_GuestQuickStats) _then;

/// Create a copy of GuestQuickStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vegetarian = null,Object? allergies = null,Object? kids = null,Object? plusOnes = null,}) {
  return _then(_GuestQuickStats(
vegetarian: null == vegetarian ? _self.vegetarian : vegetarian // ignore: cast_nullable_to_non_nullable
as int,allergies: null == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as int,kids: null == kids ? _self.kids : kids // ignore: cast_nullable_to_non_nullable
as int,plusOnes: null == plusOnes ? _self.plusOnes : plusOnes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
