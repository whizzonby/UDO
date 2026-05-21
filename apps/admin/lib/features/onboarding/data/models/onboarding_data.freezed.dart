// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingData {

// Step 2 — Couple names
 String? get partnerOneName; String? get partnerTwoName;// Step 3 — Wedding date
 DateTime? get weddingDate; bool get dateNotSet;// Step 4 — Guest count estimate
 String? get guestCountRange;// Step 5 — Role
 String? get userRole;// Step 6 — Venue status
 String? get venueStatus;// Step 7 — Venue name (if booked)
 String? get venueName; String? get venueCity;// Step 8 — Budget range
 String? get budgetRange;// Step 9 — Planning stage
 String? get planningStage;// Step 10 — Planning priorities
 List<String> get planningPriorities;// Step 11 — Guest experience preference
 String? get guestExperience;// Step 12 — Communication style
 String? get communicationStyle;// Step 13 — Invitations sent via
 List<String> get invitationChannels;// Step 14 — Aesthetic / vibe
 List<String> get weddingVibes;// Step 15 — How they found us
 String? get referralSource;
/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingDataCopyWith<OnboardingData> get copyWith => _$OnboardingDataCopyWithImpl<OnboardingData>(this as OnboardingData, _$identity);

  /// Serializes this OnboardingData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingData&&(identical(other.partnerOneName, partnerOneName) || other.partnerOneName == partnerOneName)&&(identical(other.partnerTwoName, partnerTwoName) || other.partnerTwoName == partnerTwoName)&&(identical(other.weddingDate, weddingDate) || other.weddingDate == weddingDate)&&(identical(other.dateNotSet, dateNotSet) || other.dateNotSet == dateNotSet)&&(identical(other.guestCountRange, guestCountRange) || other.guestCountRange == guestCountRange)&&(identical(other.userRole, userRole) || other.userRole == userRole)&&(identical(other.venueStatus, venueStatus) || other.venueStatus == venueStatus)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.venueCity, venueCity) || other.venueCity == venueCity)&&(identical(other.budgetRange, budgetRange) || other.budgetRange == budgetRange)&&(identical(other.planningStage, planningStage) || other.planningStage == planningStage)&&const DeepCollectionEquality().equals(other.planningPriorities, planningPriorities)&&(identical(other.guestExperience, guestExperience) || other.guestExperience == guestExperience)&&(identical(other.communicationStyle, communicationStyle) || other.communicationStyle == communicationStyle)&&const DeepCollectionEquality().equals(other.invitationChannels, invitationChannels)&&const DeepCollectionEquality().equals(other.weddingVibes, weddingVibes)&&(identical(other.referralSource, referralSource) || other.referralSource == referralSource));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partnerOneName,partnerTwoName,weddingDate,dateNotSet,guestCountRange,userRole,venueStatus,venueName,venueCity,budgetRange,planningStage,const DeepCollectionEquality().hash(planningPriorities),guestExperience,communicationStyle,const DeepCollectionEquality().hash(invitationChannels),const DeepCollectionEquality().hash(weddingVibes),referralSource);

@override
String toString() {
  return 'OnboardingData(partnerOneName: $partnerOneName, partnerTwoName: $partnerTwoName, weddingDate: $weddingDate, dateNotSet: $dateNotSet, guestCountRange: $guestCountRange, userRole: $userRole, venueStatus: $venueStatus, venueName: $venueName, venueCity: $venueCity, budgetRange: $budgetRange, planningStage: $planningStage, planningPriorities: $planningPriorities, guestExperience: $guestExperience, communicationStyle: $communicationStyle, invitationChannels: $invitationChannels, weddingVibes: $weddingVibes, referralSource: $referralSource)';
}


}

/// @nodoc
abstract mixin class $OnboardingDataCopyWith<$Res>  {
  factory $OnboardingDataCopyWith(OnboardingData value, $Res Function(OnboardingData) _then) = _$OnboardingDataCopyWithImpl;
@useResult
$Res call({
 String? partnerOneName, String? partnerTwoName, DateTime? weddingDate, bool dateNotSet, String? guestCountRange, String? userRole, String? venueStatus, String? venueName, String? venueCity, String? budgetRange, String? planningStage, List<String> planningPriorities, String? guestExperience, String? communicationStyle, List<String> invitationChannels, List<String> weddingVibes, String? referralSource
});




}
/// @nodoc
class _$OnboardingDataCopyWithImpl<$Res>
    implements $OnboardingDataCopyWith<$Res> {
  _$OnboardingDataCopyWithImpl(this._self, this._then);

  final OnboardingData _self;
  final $Res Function(OnboardingData) _then;

/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? partnerOneName = freezed,Object? partnerTwoName = freezed,Object? weddingDate = freezed,Object? dateNotSet = null,Object? guestCountRange = freezed,Object? userRole = freezed,Object? venueStatus = freezed,Object? venueName = freezed,Object? venueCity = freezed,Object? budgetRange = freezed,Object? planningStage = freezed,Object? planningPriorities = null,Object? guestExperience = freezed,Object? communicationStyle = freezed,Object? invitationChannels = null,Object? weddingVibes = null,Object? referralSource = freezed,}) {
  return _then(_self.copyWith(
partnerOneName: freezed == partnerOneName ? _self.partnerOneName : partnerOneName // ignore: cast_nullable_to_non_nullable
as String?,partnerTwoName: freezed == partnerTwoName ? _self.partnerTwoName : partnerTwoName // ignore: cast_nullable_to_non_nullable
as String?,weddingDate: freezed == weddingDate ? _self.weddingDate : weddingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dateNotSet: null == dateNotSet ? _self.dateNotSet : dateNotSet // ignore: cast_nullable_to_non_nullable
as bool,guestCountRange: freezed == guestCountRange ? _self.guestCountRange : guestCountRange // ignore: cast_nullable_to_non_nullable
as String?,userRole: freezed == userRole ? _self.userRole : userRole // ignore: cast_nullable_to_non_nullable
as String?,venueStatus: freezed == venueStatus ? _self.venueStatus : venueStatus // ignore: cast_nullable_to_non_nullable
as String?,venueName: freezed == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String?,venueCity: freezed == venueCity ? _self.venueCity : venueCity // ignore: cast_nullable_to_non_nullable
as String?,budgetRange: freezed == budgetRange ? _self.budgetRange : budgetRange // ignore: cast_nullable_to_non_nullable
as String?,planningStage: freezed == planningStage ? _self.planningStage : planningStage // ignore: cast_nullable_to_non_nullable
as String?,planningPriorities: null == planningPriorities ? _self.planningPriorities : planningPriorities // ignore: cast_nullable_to_non_nullable
as List<String>,guestExperience: freezed == guestExperience ? _self.guestExperience : guestExperience // ignore: cast_nullable_to_non_nullable
as String?,communicationStyle: freezed == communicationStyle ? _self.communicationStyle : communicationStyle // ignore: cast_nullable_to_non_nullable
as String?,invitationChannels: null == invitationChannels ? _self.invitationChannels : invitationChannels // ignore: cast_nullable_to_non_nullable
as List<String>,weddingVibes: null == weddingVibes ? _self.weddingVibes : weddingVibes // ignore: cast_nullable_to_non_nullable
as List<String>,referralSource: freezed == referralSource ? _self.referralSource : referralSource // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingData].
extension OnboardingDataPatterns on OnboardingData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingData value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingData value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? partnerOneName,  String? partnerTwoName,  DateTime? weddingDate,  bool dateNotSet,  String? guestCountRange,  String? userRole,  String? venueStatus,  String? venueName,  String? venueCity,  String? budgetRange,  String? planningStage,  List<String> planningPriorities,  String? guestExperience,  String? communicationStyle,  List<String> invitationChannels,  List<String> weddingVibes,  String? referralSource)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingData() when $default != null:
return $default(_that.partnerOneName,_that.partnerTwoName,_that.weddingDate,_that.dateNotSet,_that.guestCountRange,_that.userRole,_that.venueStatus,_that.venueName,_that.venueCity,_that.budgetRange,_that.planningStage,_that.planningPriorities,_that.guestExperience,_that.communicationStyle,_that.invitationChannels,_that.weddingVibes,_that.referralSource);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? partnerOneName,  String? partnerTwoName,  DateTime? weddingDate,  bool dateNotSet,  String? guestCountRange,  String? userRole,  String? venueStatus,  String? venueName,  String? venueCity,  String? budgetRange,  String? planningStage,  List<String> planningPriorities,  String? guestExperience,  String? communicationStyle,  List<String> invitationChannels,  List<String> weddingVibes,  String? referralSource)  $default,) {final _that = this;
switch (_that) {
case _OnboardingData():
return $default(_that.partnerOneName,_that.partnerTwoName,_that.weddingDate,_that.dateNotSet,_that.guestCountRange,_that.userRole,_that.venueStatus,_that.venueName,_that.venueCity,_that.budgetRange,_that.planningStage,_that.planningPriorities,_that.guestExperience,_that.communicationStyle,_that.invitationChannels,_that.weddingVibes,_that.referralSource);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? partnerOneName,  String? partnerTwoName,  DateTime? weddingDate,  bool dateNotSet,  String? guestCountRange,  String? userRole,  String? venueStatus,  String? venueName,  String? venueCity,  String? budgetRange,  String? planningStage,  List<String> planningPriorities,  String? guestExperience,  String? communicationStyle,  List<String> invitationChannels,  List<String> weddingVibes,  String? referralSource)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingData() when $default != null:
return $default(_that.partnerOneName,_that.partnerTwoName,_that.weddingDate,_that.dateNotSet,_that.guestCountRange,_that.userRole,_that.venueStatus,_that.venueName,_that.venueCity,_that.budgetRange,_that.planningStage,_that.planningPriorities,_that.guestExperience,_that.communicationStyle,_that.invitationChannels,_that.weddingVibes,_that.referralSource);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OnboardingData implements OnboardingData {
  const _OnboardingData({this.partnerOneName, this.partnerTwoName, this.weddingDate, this.dateNotSet = false, this.guestCountRange, this.userRole, this.venueStatus, this.venueName, this.venueCity, this.budgetRange, this.planningStage, final  List<String> planningPriorities = const [], this.guestExperience, this.communicationStyle, final  List<String> invitationChannels = const [], final  List<String> weddingVibes = const [], this.referralSource}): _planningPriorities = planningPriorities,_invitationChannels = invitationChannels,_weddingVibes = weddingVibes;
  factory _OnboardingData.fromJson(Map<String, dynamic> json) => _$OnboardingDataFromJson(json);

// Step 2 — Couple names
@override final  String? partnerOneName;
@override final  String? partnerTwoName;
// Step 3 — Wedding date
@override final  DateTime? weddingDate;
@override@JsonKey() final  bool dateNotSet;
// Step 4 — Guest count estimate
@override final  String? guestCountRange;
// Step 5 — Role
@override final  String? userRole;
// Step 6 — Venue status
@override final  String? venueStatus;
// Step 7 — Venue name (if booked)
@override final  String? venueName;
@override final  String? venueCity;
// Step 8 — Budget range
@override final  String? budgetRange;
// Step 9 — Planning stage
@override final  String? planningStage;
// Step 10 — Planning priorities
 final  List<String> _planningPriorities;
// Step 10 — Planning priorities
@override@JsonKey() List<String> get planningPriorities {
  if (_planningPriorities is EqualUnmodifiableListView) return _planningPriorities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_planningPriorities);
}

// Step 11 — Guest experience preference
@override final  String? guestExperience;
// Step 12 — Communication style
@override final  String? communicationStyle;
// Step 13 — Invitations sent via
 final  List<String> _invitationChannels;
// Step 13 — Invitations sent via
@override@JsonKey() List<String> get invitationChannels {
  if (_invitationChannels is EqualUnmodifiableListView) return _invitationChannels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invitationChannels);
}

// Step 14 — Aesthetic / vibe
 final  List<String> _weddingVibes;
// Step 14 — Aesthetic / vibe
@override@JsonKey() List<String> get weddingVibes {
  if (_weddingVibes is EqualUnmodifiableListView) return _weddingVibes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weddingVibes);
}

// Step 15 — How they found us
@override final  String? referralSource;

/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingDataCopyWith<_OnboardingData> get copyWith => __$OnboardingDataCopyWithImpl<_OnboardingData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OnboardingDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingData&&(identical(other.partnerOneName, partnerOneName) || other.partnerOneName == partnerOneName)&&(identical(other.partnerTwoName, partnerTwoName) || other.partnerTwoName == partnerTwoName)&&(identical(other.weddingDate, weddingDate) || other.weddingDate == weddingDate)&&(identical(other.dateNotSet, dateNotSet) || other.dateNotSet == dateNotSet)&&(identical(other.guestCountRange, guestCountRange) || other.guestCountRange == guestCountRange)&&(identical(other.userRole, userRole) || other.userRole == userRole)&&(identical(other.venueStatus, venueStatus) || other.venueStatus == venueStatus)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.venueCity, venueCity) || other.venueCity == venueCity)&&(identical(other.budgetRange, budgetRange) || other.budgetRange == budgetRange)&&(identical(other.planningStage, planningStage) || other.planningStage == planningStage)&&const DeepCollectionEquality().equals(other._planningPriorities, _planningPriorities)&&(identical(other.guestExperience, guestExperience) || other.guestExperience == guestExperience)&&(identical(other.communicationStyle, communicationStyle) || other.communicationStyle == communicationStyle)&&const DeepCollectionEquality().equals(other._invitationChannels, _invitationChannels)&&const DeepCollectionEquality().equals(other._weddingVibes, _weddingVibes)&&(identical(other.referralSource, referralSource) || other.referralSource == referralSource));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,partnerOneName,partnerTwoName,weddingDate,dateNotSet,guestCountRange,userRole,venueStatus,venueName,venueCity,budgetRange,planningStage,const DeepCollectionEquality().hash(_planningPriorities),guestExperience,communicationStyle,const DeepCollectionEquality().hash(_invitationChannels),const DeepCollectionEquality().hash(_weddingVibes),referralSource);

@override
String toString() {
  return 'OnboardingData(partnerOneName: $partnerOneName, partnerTwoName: $partnerTwoName, weddingDate: $weddingDate, dateNotSet: $dateNotSet, guestCountRange: $guestCountRange, userRole: $userRole, venueStatus: $venueStatus, venueName: $venueName, venueCity: $venueCity, budgetRange: $budgetRange, planningStage: $planningStage, planningPriorities: $planningPriorities, guestExperience: $guestExperience, communicationStyle: $communicationStyle, invitationChannels: $invitationChannels, weddingVibes: $weddingVibes, referralSource: $referralSource)';
}


}

/// @nodoc
abstract mixin class _$OnboardingDataCopyWith<$Res> implements $OnboardingDataCopyWith<$Res> {
  factory _$OnboardingDataCopyWith(_OnboardingData value, $Res Function(_OnboardingData) _then) = __$OnboardingDataCopyWithImpl;
@override @useResult
$Res call({
 String? partnerOneName, String? partnerTwoName, DateTime? weddingDate, bool dateNotSet, String? guestCountRange, String? userRole, String? venueStatus, String? venueName, String? venueCity, String? budgetRange, String? planningStage, List<String> planningPriorities, String? guestExperience, String? communicationStyle, List<String> invitationChannels, List<String> weddingVibes, String? referralSource
});




}
/// @nodoc
class __$OnboardingDataCopyWithImpl<$Res>
    implements _$OnboardingDataCopyWith<$Res> {
  __$OnboardingDataCopyWithImpl(this._self, this._then);

  final _OnboardingData _self;
  final $Res Function(_OnboardingData) _then;

/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? partnerOneName = freezed,Object? partnerTwoName = freezed,Object? weddingDate = freezed,Object? dateNotSet = null,Object? guestCountRange = freezed,Object? userRole = freezed,Object? venueStatus = freezed,Object? venueName = freezed,Object? venueCity = freezed,Object? budgetRange = freezed,Object? planningStage = freezed,Object? planningPriorities = null,Object? guestExperience = freezed,Object? communicationStyle = freezed,Object? invitationChannels = null,Object? weddingVibes = null,Object? referralSource = freezed,}) {
  return _then(_OnboardingData(
partnerOneName: freezed == partnerOneName ? _self.partnerOneName : partnerOneName // ignore: cast_nullable_to_non_nullable
as String?,partnerTwoName: freezed == partnerTwoName ? _self.partnerTwoName : partnerTwoName // ignore: cast_nullable_to_non_nullable
as String?,weddingDate: freezed == weddingDate ? _self.weddingDate : weddingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dateNotSet: null == dateNotSet ? _self.dateNotSet : dateNotSet // ignore: cast_nullable_to_non_nullable
as bool,guestCountRange: freezed == guestCountRange ? _self.guestCountRange : guestCountRange // ignore: cast_nullable_to_non_nullable
as String?,userRole: freezed == userRole ? _self.userRole : userRole // ignore: cast_nullable_to_non_nullable
as String?,venueStatus: freezed == venueStatus ? _self.venueStatus : venueStatus // ignore: cast_nullable_to_non_nullable
as String?,venueName: freezed == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String?,venueCity: freezed == venueCity ? _self.venueCity : venueCity // ignore: cast_nullable_to_non_nullable
as String?,budgetRange: freezed == budgetRange ? _self.budgetRange : budgetRange // ignore: cast_nullable_to_non_nullable
as String?,planningStage: freezed == planningStage ? _self.planningStage : planningStage // ignore: cast_nullable_to_non_nullable
as String?,planningPriorities: null == planningPriorities ? _self._planningPriorities : planningPriorities // ignore: cast_nullable_to_non_nullable
as List<String>,guestExperience: freezed == guestExperience ? _self.guestExperience : guestExperience // ignore: cast_nullable_to_non_nullable
as String?,communicationStyle: freezed == communicationStyle ? _self.communicationStyle : communicationStyle // ignore: cast_nullable_to_non_nullable
as String?,invitationChannels: null == invitationChannels ? _self._invitationChannels : invitationChannels // ignore: cast_nullable_to_non_nullable
as List<String>,weddingVibes: null == weddingVibes ? _self._weddingVibes : weddingVibes // ignore: cast_nullable_to_non_nullable
as List<String>,referralSource: freezed == referralSource ? _self.referralSource : referralSource // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
