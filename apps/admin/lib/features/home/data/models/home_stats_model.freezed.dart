// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeStats {

 WeddingInfo get wedding; GuestOverview get guests; PlanProgress get plan; BudgetOverview get budget; List<SmartAlert> get alerts; List<UpcomingEvent> get upcoming;
/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStatsCopyWith<HomeStats> get copyWith => _$HomeStatsCopyWithImpl<HomeStats>(this as HomeStats, _$identity);

  /// Serializes this HomeStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeStats&&(identical(other.wedding, wedding) || other.wedding == wedding)&&(identical(other.guests, guests) || other.guests == guests)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.budget, budget) || other.budget == budget)&&const DeepCollectionEquality().equals(other.alerts, alerts)&&const DeepCollectionEquality().equals(other.upcoming, upcoming));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wedding,guests,plan,budget,const DeepCollectionEquality().hash(alerts),const DeepCollectionEquality().hash(upcoming));

@override
String toString() {
  return 'HomeStats(wedding: $wedding, guests: $guests, plan: $plan, budget: $budget, alerts: $alerts, upcoming: $upcoming)';
}


}

/// @nodoc
abstract mixin class $HomeStatsCopyWith<$Res>  {
  factory $HomeStatsCopyWith(HomeStats value, $Res Function(HomeStats) _then) = _$HomeStatsCopyWithImpl;
@useResult
$Res call({
 WeddingInfo wedding, GuestOverview guests, PlanProgress plan, BudgetOverview budget, List<SmartAlert> alerts, List<UpcomingEvent> upcoming
});


$WeddingInfoCopyWith<$Res> get wedding;$GuestOverviewCopyWith<$Res> get guests;$PlanProgressCopyWith<$Res> get plan;$BudgetOverviewCopyWith<$Res> get budget;

}
/// @nodoc
class _$HomeStatsCopyWithImpl<$Res>
    implements $HomeStatsCopyWith<$Res> {
  _$HomeStatsCopyWithImpl(this._self, this._then);

  final HomeStats _self;
  final $Res Function(HomeStats) _then;

/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wedding = null,Object? guests = null,Object? plan = null,Object? budget = null,Object? alerts = null,Object? upcoming = null,}) {
  return _then(_self.copyWith(
wedding: null == wedding ? _self.wedding : wedding // ignore: cast_nullable_to_non_nullable
as WeddingInfo,guests: null == guests ? _self.guests : guests // ignore: cast_nullable_to_non_nullable
as GuestOverview,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as PlanProgress,budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as BudgetOverview,alerts: null == alerts ? _self.alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<SmartAlert>,upcoming: null == upcoming ? _self.upcoming : upcoming // ignore: cast_nullable_to_non_nullable
as List<UpcomingEvent>,
  ));
}
/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeddingInfoCopyWith<$Res> get wedding {
  
  return $WeddingInfoCopyWith<$Res>(_self.wedding, (value) {
    return _then(_self.copyWith(wedding: value));
  });
}/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuestOverviewCopyWith<$Res> get guests {
  
  return $GuestOverviewCopyWith<$Res>(_self.guests, (value) {
    return _then(_self.copyWith(guests: value));
  });
}/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanProgressCopyWith<$Res> get plan {
  
  return $PlanProgressCopyWith<$Res>(_self.plan, (value) {
    return _then(_self.copyWith(plan: value));
  });
}/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetOverviewCopyWith<$Res> get budget {
  
  return $BudgetOverviewCopyWith<$Res>(_self.budget, (value) {
    return _then(_self.copyWith(budget: value));
  });
}
}


/// Adds pattern-matching-related methods to [HomeStats].
extension HomeStatsPatterns on HomeStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeStats value)  $default,){
final _that = this;
switch (_that) {
case _HomeStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeStats value)?  $default,){
final _that = this;
switch (_that) {
case _HomeStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WeddingInfo wedding,  GuestOverview guests,  PlanProgress plan,  BudgetOverview budget,  List<SmartAlert> alerts,  List<UpcomingEvent> upcoming)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeStats() when $default != null:
return $default(_that.wedding,_that.guests,_that.plan,_that.budget,_that.alerts,_that.upcoming);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WeddingInfo wedding,  GuestOverview guests,  PlanProgress plan,  BudgetOverview budget,  List<SmartAlert> alerts,  List<UpcomingEvent> upcoming)  $default,) {final _that = this;
switch (_that) {
case _HomeStats():
return $default(_that.wedding,_that.guests,_that.plan,_that.budget,_that.alerts,_that.upcoming);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WeddingInfo wedding,  GuestOverview guests,  PlanProgress plan,  BudgetOverview budget,  List<SmartAlert> alerts,  List<UpcomingEvent> upcoming)?  $default,) {final _that = this;
switch (_that) {
case _HomeStats() when $default != null:
return $default(_that.wedding,_that.guests,_that.plan,_that.budget,_that.alerts,_that.upcoming);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeStats implements HomeStats {
  const _HomeStats({required this.wedding, required this.guests, required this.plan, required this.budget, final  List<SmartAlert> alerts = const [], final  List<UpcomingEvent> upcoming = const []}): _alerts = alerts,_upcoming = upcoming;
  factory _HomeStats.fromJson(Map<String, dynamic> json) => _$HomeStatsFromJson(json);

@override final  WeddingInfo wedding;
@override final  GuestOverview guests;
@override final  PlanProgress plan;
@override final  BudgetOverview budget;
 final  List<SmartAlert> _alerts;
@override@JsonKey() List<SmartAlert> get alerts {
  if (_alerts is EqualUnmodifiableListView) return _alerts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alerts);
}

 final  List<UpcomingEvent> _upcoming;
@override@JsonKey() List<UpcomingEvent> get upcoming {
  if (_upcoming is EqualUnmodifiableListView) return _upcoming;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_upcoming);
}


/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStatsCopyWith<_HomeStats> get copyWith => __$HomeStatsCopyWithImpl<_HomeStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeStats&&(identical(other.wedding, wedding) || other.wedding == wedding)&&(identical(other.guests, guests) || other.guests == guests)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.budget, budget) || other.budget == budget)&&const DeepCollectionEquality().equals(other._alerts, _alerts)&&const DeepCollectionEquality().equals(other._upcoming, _upcoming));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wedding,guests,plan,budget,const DeepCollectionEquality().hash(_alerts),const DeepCollectionEquality().hash(_upcoming));

@override
String toString() {
  return 'HomeStats(wedding: $wedding, guests: $guests, plan: $plan, budget: $budget, alerts: $alerts, upcoming: $upcoming)';
}


}

/// @nodoc
abstract mixin class _$HomeStatsCopyWith<$Res> implements $HomeStatsCopyWith<$Res> {
  factory _$HomeStatsCopyWith(_HomeStats value, $Res Function(_HomeStats) _then) = __$HomeStatsCopyWithImpl;
@override @useResult
$Res call({
 WeddingInfo wedding, GuestOverview guests, PlanProgress plan, BudgetOverview budget, List<SmartAlert> alerts, List<UpcomingEvent> upcoming
});


@override $WeddingInfoCopyWith<$Res> get wedding;@override $GuestOverviewCopyWith<$Res> get guests;@override $PlanProgressCopyWith<$Res> get plan;@override $BudgetOverviewCopyWith<$Res> get budget;

}
/// @nodoc
class __$HomeStatsCopyWithImpl<$Res>
    implements _$HomeStatsCopyWith<$Res> {
  __$HomeStatsCopyWithImpl(this._self, this._then);

  final _HomeStats _self;
  final $Res Function(_HomeStats) _then;

/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wedding = null,Object? guests = null,Object? plan = null,Object? budget = null,Object? alerts = null,Object? upcoming = null,}) {
  return _then(_HomeStats(
wedding: null == wedding ? _self.wedding : wedding // ignore: cast_nullable_to_non_nullable
as WeddingInfo,guests: null == guests ? _self.guests : guests // ignore: cast_nullable_to_non_nullable
as GuestOverview,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as PlanProgress,budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as BudgetOverview,alerts: null == alerts ? _self._alerts : alerts // ignore: cast_nullable_to_non_nullable
as List<SmartAlert>,upcoming: null == upcoming ? _self._upcoming : upcoming // ignore: cast_nullable_to_non_nullable
as List<UpcomingEvent>,
  ));
}

/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeddingInfoCopyWith<$Res> get wedding {
  
  return $WeddingInfoCopyWith<$Res>(_self.wedding, (value) {
    return _then(_self.copyWith(wedding: value));
  });
}/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuestOverviewCopyWith<$Res> get guests {
  
  return $GuestOverviewCopyWith<$Res>(_self.guests, (value) {
    return _then(_self.copyWith(guests: value));
  });
}/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlanProgressCopyWith<$Res> get plan {
  
  return $PlanProgressCopyWith<$Res>(_self.plan, (value) {
    return _then(_self.copyWith(plan: value));
  });
}/// Create a copy of HomeStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetOverviewCopyWith<$Res> get budget {
  
  return $BudgetOverviewCopyWith<$Res>(_self.budget, (value) {
    return _then(_self.copyWith(budget: value));
  });
}
}


/// @nodoc
mixin _$WeddingInfo {

 String get id; String get partnerOneName; String get partnerTwoName; DateTime? get weddingDate; String? get venueName; String? get venueCity; WeddingStatus get status;
/// Create a copy of WeddingInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeddingInfoCopyWith<WeddingInfo> get copyWith => _$WeddingInfoCopyWithImpl<WeddingInfo>(this as WeddingInfo, _$identity);

  /// Serializes this WeddingInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeddingInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.partnerOneName, partnerOneName) || other.partnerOneName == partnerOneName)&&(identical(other.partnerTwoName, partnerTwoName) || other.partnerTwoName == partnerTwoName)&&(identical(other.weddingDate, weddingDate) || other.weddingDate == weddingDate)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.venueCity, venueCity) || other.venueCity == venueCity)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,partnerOneName,partnerTwoName,weddingDate,venueName,venueCity,status);

@override
String toString() {
  return 'WeddingInfo(id: $id, partnerOneName: $partnerOneName, partnerTwoName: $partnerTwoName, weddingDate: $weddingDate, venueName: $venueName, venueCity: $venueCity, status: $status)';
}


}

/// @nodoc
abstract mixin class $WeddingInfoCopyWith<$Res>  {
  factory $WeddingInfoCopyWith(WeddingInfo value, $Res Function(WeddingInfo) _then) = _$WeddingInfoCopyWithImpl;
@useResult
$Res call({
 String id, String partnerOneName, String partnerTwoName, DateTime? weddingDate, String? venueName, String? venueCity, WeddingStatus status
});




}
/// @nodoc
class _$WeddingInfoCopyWithImpl<$Res>
    implements $WeddingInfoCopyWith<$Res> {
  _$WeddingInfoCopyWithImpl(this._self, this._then);

  final WeddingInfo _self;
  final $Res Function(WeddingInfo) _then;

/// Create a copy of WeddingInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? partnerOneName = null,Object? partnerTwoName = null,Object? weddingDate = freezed,Object? venueName = freezed,Object? venueCity = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,partnerOneName: null == partnerOneName ? _self.partnerOneName : partnerOneName // ignore: cast_nullable_to_non_nullable
as String,partnerTwoName: null == partnerTwoName ? _self.partnerTwoName : partnerTwoName // ignore: cast_nullable_to_non_nullable
as String,weddingDate: freezed == weddingDate ? _self.weddingDate : weddingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,venueName: freezed == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String?,venueCity: freezed == venueCity ? _self.venueCity : venueCity // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WeddingStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [WeddingInfo].
extension WeddingInfoPatterns on WeddingInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeddingInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeddingInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeddingInfo value)  $default,){
final _that = this;
switch (_that) {
case _WeddingInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeddingInfo value)?  $default,){
final _that = this;
switch (_that) {
case _WeddingInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String partnerOneName,  String partnerTwoName,  DateTime? weddingDate,  String? venueName,  String? venueCity,  WeddingStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeddingInfo() when $default != null:
return $default(_that.id,_that.partnerOneName,_that.partnerTwoName,_that.weddingDate,_that.venueName,_that.venueCity,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String partnerOneName,  String partnerTwoName,  DateTime? weddingDate,  String? venueName,  String? venueCity,  WeddingStatus status)  $default,) {final _that = this;
switch (_that) {
case _WeddingInfo():
return $default(_that.id,_that.partnerOneName,_that.partnerTwoName,_that.weddingDate,_that.venueName,_that.venueCity,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String partnerOneName,  String partnerTwoName,  DateTime? weddingDate,  String? venueName,  String? venueCity,  WeddingStatus status)?  $default,) {final _that = this;
switch (_that) {
case _WeddingInfo() when $default != null:
return $default(_that.id,_that.partnerOneName,_that.partnerTwoName,_that.weddingDate,_that.venueName,_that.venueCity,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeddingInfo implements WeddingInfo {
  const _WeddingInfo({required this.id, required this.partnerOneName, required this.partnerTwoName, this.weddingDate, this.venueName, this.venueCity, this.status = WeddingStatus.planning});
  factory _WeddingInfo.fromJson(Map<String, dynamic> json) => _$WeddingInfoFromJson(json);

@override final  String id;
@override final  String partnerOneName;
@override final  String partnerTwoName;
@override final  DateTime? weddingDate;
@override final  String? venueName;
@override final  String? venueCity;
@override@JsonKey() final  WeddingStatus status;

/// Create a copy of WeddingInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeddingInfoCopyWith<_WeddingInfo> get copyWith => __$WeddingInfoCopyWithImpl<_WeddingInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeddingInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeddingInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.partnerOneName, partnerOneName) || other.partnerOneName == partnerOneName)&&(identical(other.partnerTwoName, partnerTwoName) || other.partnerTwoName == partnerTwoName)&&(identical(other.weddingDate, weddingDate) || other.weddingDate == weddingDate)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.venueCity, venueCity) || other.venueCity == venueCity)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,partnerOneName,partnerTwoName,weddingDate,venueName,venueCity,status);

@override
String toString() {
  return 'WeddingInfo(id: $id, partnerOneName: $partnerOneName, partnerTwoName: $partnerTwoName, weddingDate: $weddingDate, venueName: $venueName, venueCity: $venueCity, status: $status)';
}


}

/// @nodoc
abstract mixin class _$WeddingInfoCopyWith<$Res> implements $WeddingInfoCopyWith<$Res> {
  factory _$WeddingInfoCopyWith(_WeddingInfo value, $Res Function(_WeddingInfo) _then) = __$WeddingInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String partnerOneName, String partnerTwoName, DateTime? weddingDate, String? venueName, String? venueCity, WeddingStatus status
});




}
/// @nodoc
class __$WeddingInfoCopyWithImpl<$Res>
    implements _$WeddingInfoCopyWith<$Res> {
  __$WeddingInfoCopyWithImpl(this._self, this._then);

  final _WeddingInfo _self;
  final $Res Function(_WeddingInfo) _then;

/// Create a copy of WeddingInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? partnerOneName = null,Object? partnerTwoName = null,Object? weddingDate = freezed,Object? venueName = freezed,Object? venueCity = freezed,Object? status = null,}) {
  return _then(_WeddingInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,partnerOneName: null == partnerOneName ? _self.partnerOneName : partnerOneName // ignore: cast_nullable_to_non_nullable
as String,partnerTwoName: null == partnerTwoName ? _self.partnerTwoName : partnerTwoName // ignore: cast_nullable_to_non_nullable
as String,weddingDate: freezed == weddingDate ? _self.weddingDate : weddingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,venueName: freezed == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String?,venueCity: freezed == venueCity ? _self.venueCity : venueCity // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WeddingStatus,
  ));
}


}


/// @nodoc
mixin _$GuestOverview {

 int get total; int get confirmed; int get pending; int get declined; int get notInvited;
/// Create a copy of GuestOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GuestOverviewCopyWith<GuestOverview> get copyWith => _$GuestOverviewCopyWithImpl<GuestOverview>(this as GuestOverview, _$identity);

  /// Serializes this GuestOverview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuestOverview&&(identical(other.total, total) || other.total == total)&&(identical(other.confirmed, confirmed) || other.confirmed == confirmed)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.declined, declined) || other.declined == declined)&&(identical(other.notInvited, notInvited) || other.notInvited == notInvited));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,confirmed,pending,declined,notInvited);

@override
String toString() {
  return 'GuestOverview(total: $total, confirmed: $confirmed, pending: $pending, declined: $declined, notInvited: $notInvited)';
}


}

/// @nodoc
abstract mixin class $GuestOverviewCopyWith<$Res>  {
  factory $GuestOverviewCopyWith(GuestOverview value, $Res Function(GuestOverview) _then) = _$GuestOverviewCopyWithImpl;
@useResult
$Res call({
 int total, int confirmed, int pending, int declined, int notInvited
});




}
/// @nodoc
class _$GuestOverviewCopyWithImpl<$Res>
    implements $GuestOverviewCopyWith<$Res> {
  _$GuestOverviewCopyWithImpl(this._self, this._then);

  final GuestOverview _self;
  final $Res Function(GuestOverview) _then;

/// Create a copy of GuestOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? confirmed = null,Object? pending = null,Object? declined = null,Object? notInvited = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,declined: null == declined ? _self.declined : declined // ignore: cast_nullable_to_non_nullable
as int,notInvited: null == notInvited ? _self.notInvited : notInvited // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GuestOverview].
extension GuestOverviewPatterns on GuestOverview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GuestOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuestOverview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GuestOverview value)  $default,){
final _that = this;
switch (_that) {
case _GuestOverview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GuestOverview value)?  $default,){
final _that = this;
switch (_that) {
case _GuestOverview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  int confirmed,  int pending,  int declined,  int notInvited)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuestOverview() when $default != null:
return $default(_that.total,_that.confirmed,_that.pending,_that.declined,_that.notInvited);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  int confirmed,  int pending,  int declined,  int notInvited)  $default,) {final _that = this;
switch (_that) {
case _GuestOverview():
return $default(_that.total,_that.confirmed,_that.pending,_that.declined,_that.notInvited);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  int confirmed,  int pending,  int declined,  int notInvited)?  $default,) {final _that = this;
switch (_that) {
case _GuestOverview() when $default != null:
return $default(_that.total,_that.confirmed,_that.pending,_that.declined,_that.notInvited);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GuestOverview implements GuestOverview {
  const _GuestOverview({this.total = 0, this.confirmed = 0, this.pending = 0, this.declined = 0, this.notInvited = 0});
  factory _GuestOverview.fromJson(Map<String, dynamic> json) => _$GuestOverviewFromJson(json);

@override@JsonKey() final  int total;
@override@JsonKey() final  int confirmed;
@override@JsonKey() final  int pending;
@override@JsonKey() final  int declined;
@override@JsonKey() final  int notInvited;

/// Create a copy of GuestOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestOverviewCopyWith<_GuestOverview> get copyWith => __$GuestOverviewCopyWithImpl<_GuestOverview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GuestOverviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestOverview&&(identical(other.total, total) || other.total == total)&&(identical(other.confirmed, confirmed) || other.confirmed == confirmed)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.declined, declined) || other.declined == declined)&&(identical(other.notInvited, notInvited) || other.notInvited == notInvited));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,confirmed,pending,declined,notInvited);

@override
String toString() {
  return 'GuestOverview(total: $total, confirmed: $confirmed, pending: $pending, declined: $declined, notInvited: $notInvited)';
}


}

/// @nodoc
abstract mixin class _$GuestOverviewCopyWith<$Res> implements $GuestOverviewCopyWith<$Res> {
  factory _$GuestOverviewCopyWith(_GuestOverview value, $Res Function(_GuestOverview) _then) = __$GuestOverviewCopyWithImpl;
@override @useResult
$Res call({
 int total, int confirmed, int pending, int declined, int notInvited
});




}
/// @nodoc
class __$GuestOverviewCopyWithImpl<$Res>
    implements _$GuestOverviewCopyWith<$Res> {
  __$GuestOverviewCopyWithImpl(this._self, this._then);

  final _GuestOverview _self;
  final $Res Function(_GuestOverview) _then;

/// Create a copy of GuestOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? confirmed = null,Object? pending = null,Object? declined = null,Object? notInvited = null,}) {
  return _then(_GuestOverview(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,declined: null == declined ? _self.declined : declined // ignore: cast_nullable_to_non_nullable
as int,notInvited: null == notInvited ? _self.notInvited : notInvited // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PlanProgress {

 int get totalTasks; int get completedTasks; int get overdueTasks; List<PlanCategory> get categories; List<RecentTask> get recentTasks;
/// Create a copy of PlanProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanProgressCopyWith<PlanProgress> get copyWith => _$PlanProgressCopyWithImpl<PlanProgress>(this as PlanProgress, _$identity);

  /// Serializes this PlanProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanProgress&&(identical(other.totalTasks, totalTasks) || other.totalTasks == totalTasks)&&(identical(other.completedTasks, completedTasks) || other.completedTasks == completedTasks)&&(identical(other.overdueTasks, overdueTasks) || other.overdueTasks == overdueTasks)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.recentTasks, recentTasks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalTasks,completedTasks,overdueTasks,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(recentTasks));

@override
String toString() {
  return 'PlanProgress(totalTasks: $totalTasks, completedTasks: $completedTasks, overdueTasks: $overdueTasks, categories: $categories, recentTasks: $recentTasks)';
}


}

/// @nodoc
abstract mixin class $PlanProgressCopyWith<$Res>  {
  factory $PlanProgressCopyWith(PlanProgress value, $Res Function(PlanProgress) _then) = _$PlanProgressCopyWithImpl;
@useResult
$Res call({
 int totalTasks, int completedTasks, int overdueTasks, List<PlanCategory> categories, List<RecentTask> recentTasks
});




}
/// @nodoc
class _$PlanProgressCopyWithImpl<$Res>
    implements $PlanProgressCopyWith<$Res> {
  _$PlanProgressCopyWithImpl(this._self, this._then);

  final PlanProgress _self;
  final $Res Function(PlanProgress) _then;

/// Create a copy of PlanProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalTasks = null,Object? completedTasks = null,Object? overdueTasks = null,Object? categories = null,Object? recentTasks = null,}) {
  return _then(_self.copyWith(
totalTasks: null == totalTasks ? _self.totalTasks : totalTasks // ignore: cast_nullable_to_non_nullable
as int,completedTasks: null == completedTasks ? _self.completedTasks : completedTasks // ignore: cast_nullable_to_non_nullable
as int,overdueTasks: null == overdueTasks ? _self.overdueTasks : overdueTasks // ignore: cast_nullable_to_non_nullable
as int,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<PlanCategory>,recentTasks: null == recentTasks ? _self.recentTasks : recentTasks // ignore: cast_nullable_to_non_nullable
as List<RecentTask>,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanProgress].
extension PlanProgressPatterns on PlanProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanProgress value)  $default,){
final _that = this;
switch (_that) {
case _PlanProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanProgress value)?  $default,){
final _that = this;
switch (_that) {
case _PlanProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalTasks,  int completedTasks,  int overdueTasks,  List<PlanCategory> categories,  List<RecentTask> recentTasks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanProgress() when $default != null:
return $default(_that.totalTasks,_that.completedTasks,_that.overdueTasks,_that.categories,_that.recentTasks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalTasks,  int completedTasks,  int overdueTasks,  List<PlanCategory> categories,  List<RecentTask> recentTasks)  $default,) {final _that = this;
switch (_that) {
case _PlanProgress():
return $default(_that.totalTasks,_that.completedTasks,_that.overdueTasks,_that.categories,_that.recentTasks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalTasks,  int completedTasks,  int overdueTasks,  List<PlanCategory> categories,  List<RecentTask> recentTasks)?  $default,) {final _that = this;
switch (_that) {
case _PlanProgress() when $default != null:
return $default(_that.totalTasks,_that.completedTasks,_that.overdueTasks,_that.categories,_that.recentTasks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlanProgress implements PlanProgress {
  const _PlanProgress({this.totalTasks = 0, this.completedTasks = 0, this.overdueTasks = 0, final  List<PlanCategory> categories = const [], final  List<RecentTask> recentTasks = const []}): _categories = categories,_recentTasks = recentTasks;
  factory _PlanProgress.fromJson(Map<String, dynamic> json) => _$PlanProgressFromJson(json);

@override@JsonKey() final  int totalTasks;
@override@JsonKey() final  int completedTasks;
@override@JsonKey() final  int overdueTasks;
 final  List<PlanCategory> _categories;
@override@JsonKey() List<PlanCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<RecentTask> _recentTasks;
@override@JsonKey() List<RecentTask> get recentTasks {
  if (_recentTasks is EqualUnmodifiableListView) return _recentTasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentTasks);
}


/// Create a copy of PlanProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanProgressCopyWith<_PlanProgress> get copyWith => __$PlanProgressCopyWithImpl<_PlanProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanProgress&&(identical(other.totalTasks, totalTasks) || other.totalTasks == totalTasks)&&(identical(other.completedTasks, completedTasks) || other.completedTasks == completedTasks)&&(identical(other.overdueTasks, overdueTasks) || other.overdueTasks == overdueTasks)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._recentTasks, _recentTasks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalTasks,completedTasks,overdueTasks,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_recentTasks));

@override
String toString() {
  return 'PlanProgress(totalTasks: $totalTasks, completedTasks: $completedTasks, overdueTasks: $overdueTasks, categories: $categories, recentTasks: $recentTasks)';
}


}

/// @nodoc
abstract mixin class _$PlanProgressCopyWith<$Res> implements $PlanProgressCopyWith<$Res> {
  factory _$PlanProgressCopyWith(_PlanProgress value, $Res Function(_PlanProgress) _then) = __$PlanProgressCopyWithImpl;
@override @useResult
$Res call({
 int totalTasks, int completedTasks, int overdueTasks, List<PlanCategory> categories, List<RecentTask> recentTasks
});




}
/// @nodoc
class __$PlanProgressCopyWithImpl<$Res>
    implements _$PlanProgressCopyWith<$Res> {
  __$PlanProgressCopyWithImpl(this._self, this._then);

  final _PlanProgress _self;
  final $Res Function(_PlanProgress) _then;

/// Create a copy of PlanProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalTasks = null,Object? completedTasks = null,Object? overdueTasks = null,Object? categories = null,Object? recentTasks = null,}) {
  return _then(_PlanProgress(
totalTasks: null == totalTasks ? _self.totalTasks : totalTasks // ignore: cast_nullable_to_non_nullable
as int,completedTasks: null == completedTasks ? _self.completedTasks : completedTasks // ignore: cast_nullable_to_non_nullable
as int,overdueTasks: null == overdueTasks ? _self.overdueTasks : overdueTasks // ignore: cast_nullable_to_non_nullable
as int,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<PlanCategory>,recentTasks: null == recentTasks ? _self._recentTasks : recentTasks // ignore: cast_nullable_to_non_nullable
as List<RecentTask>,
  ));
}


}


/// @nodoc
mixin _$PlanCategory {

 String get name; int get total; int get completed;
/// Create a copy of PlanCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanCategoryCopyWith<PlanCategory> get copyWith => _$PlanCategoryCopyWithImpl<PlanCategory>(this as PlanCategory, _$identity);

  /// Serializes this PlanCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanCategory&&(identical(other.name, name) || other.name == name)&&(identical(other.total, total) || other.total == total)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,total,completed);

@override
String toString() {
  return 'PlanCategory(name: $name, total: $total, completed: $completed)';
}


}

/// @nodoc
abstract mixin class $PlanCategoryCopyWith<$Res>  {
  factory $PlanCategoryCopyWith(PlanCategory value, $Res Function(PlanCategory) _then) = _$PlanCategoryCopyWithImpl;
@useResult
$Res call({
 String name, int total, int completed
});




}
/// @nodoc
class _$PlanCategoryCopyWithImpl<$Res>
    implements $PlanCategoryCopyWith<$Res> {
  _$PlanCategoryCopyWithImpl(this._self, this._then);

  final PlanCategory _self;
  final $Res Function(PlanCategory) _then;

/// Create a copy of PlanCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? total = null,Object? completed = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanCategory].
extension PlanCategoryPatterns on PlanCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanCategory value)  $default,){
final _that = this;
switch (_that) {
case _PlanCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanCategory value)?  $default,){
final _that = this;
switch (_that) {
case _PlanCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int total,  int completed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanCategory() when $default != null:
return $default(_that.name,_that.total,_that.completed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int total,  int completed)  $default,) {final _that = this;
switch (_that) {
case _PlanCategory():
return $default(_that.name,_that.total,_that.completed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int total,  int completed)?  $default,) {final _that = this;
switch (_that) {
case _PlanCategory() when $default != null:
return $default(_that.name,_that.total,_that.completed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlanCategory implements PlanCategory {
  const _PlanCategory({required this.name, required this.total, required this.completed});
  factory _PlanCategory.fromJson(Map<String, dynamic> json) => _$PlanCategoryFromJson(json);

@override final  String name;
@override final  int total;
@override final  int completed;

/// Create a copy of PlanCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanCategoryCopyWith<_PlanCategory> get copyWith => __$PlanCategoryCopyWithImpl<_PlanCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanCategory&&(identical(other.name, name) || other.name == name)&&(identical(other.total, total) || other.total == total)&&(identical(other.completed, completed) || other.completed == completed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,total,completed);

@override
String toString() {
  return 'PlanCategory(name: $name, total: $total, completed: $completed)';
}


}

/// @nodoc
abstract mixin class _$PlanCategoryCopyWith<$Res> implements $PlanCategoryCopyWith<$Res> {
  factory _$PlanCategoryCopyWith(_PlanCategory value, $Res Function(_PlanCategory) _then) = __$PlanCategoryCopyWithImpl;
@override @useResult
$Res call({
 String name, int total, int completed
});




}
/// @nodoc
class __$PlanCategoryCopyWithImpl<$Res>
    implements _$PlanCategoryCopyWith<$Res> {
  __$PlanCategoryCopyWithImpl(this._self, this._then);

  final _PlanCategory _self;
  final $Res Function(_PlanCategory) _then;

/// Create a copy of PlanCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? total = null,Object? completed = null,}) {
  return _then(_PlanCategory(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RecentTask {

 String get id; String get title; bool get isComplete; String? get category; DateTime? get dueDate;
/// Create a copy of RecentTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentTaskCopyWith<RecentTask> get copyWith => _$RecentTaskCopyWithImpl<RecentTask>(this as RecentTask, _$identity);

  /// Serializes this RecentTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentTask&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete)&&(identical(other.category, category) || other.category == category)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,isComplete,category,dueDate);

@override
String toString() {
  return 'RecentTask(id: $id, title: $title, isComplete: $isComplete, category: $category, dueDate: $dueDate)';
}


}

/// @nodoc
abstract mixin class $RecentTaskCopyWith<$Res>  {
  factory $RecentTaskCopyWith(RecentTask value, $Res Function(RecentTask) _then) = _$RecentTaskCopyWithImpl;
@useResult
$Res call({
 String id, String title, bool isComplete, String? category, DateTime? dueDate
});




}
/// @nodoc
class _$RecentTaskCopyWithImpl<$Res>
    implements $RecentTaskCopyWith<$Res> {
  _$RecentTaskCopyWithImpl(this._self, this._then);

  final RecentTask _self;
  final $Res Function(RecentTask) _then;

/// Create a copy of RecentTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? isComplete = null,Object? category = freezed,Object? dueDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isComplete: null == isComplete ? _self.isComplete : isComplete // ignore: cast_nullable_to_non_nullable
as bool,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentTask].
extension RecentTaskPatterns on RecentTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentTask value)  $default,){
final _that = this;
switch (_that) {
case _RecentTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentTask value)?  $default,){
final _that = this;
switch (_that) {
case _RecentTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  bool isComplete,  String? category,  DateTime? dueDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentTask() when $default != null:
return $default(_that.id,_that.title,_that.isComplete,_that.category,_that.dueDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  bool isComplete,  String? category,  DateTime? dueDate)  $default,) {final _that = this;
switch (_that) {
case _RecentTask():
return $default(_that.id,_that.title,_that.isComplete,_that.category,_that.dueDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  bool isComplete,  String? category,  DateTime? dueDate)?  $default,) {final _that = this;
switch (_that) {
case _RecentTask() when $default != null:
return $default(_that.id,_that.title,_that.isComplete,_that.category,_that.dueDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecentTask implements RecentTask {
  const _RecentTask({required this.id, required this.title, required this.isComplete, this.category, this.dueDate});
  factory _RecentTask.fromJson(Map<String, dynamic> json) => _$RecentTaskFromJson(json);

@override final  String id;
@override final  String title;
@override final  bool isComplete;
@override final  String? category;
@override final  DateTime? dueDate;

/// Create a copy of RecentTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentTaskCopyWith<_RecentTask> get copyWith => __$RecentTaskCopyWithImpl<_RecentTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecentTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentTask&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete)&&(identical(other.category, category) || other.category == category)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,isComplete,category,dueDate);

@override
String toString() {
  return 'RecentTask(id: $id, title: $title, isComplete: $isComplete, category: $category, dueDate: $dueDate)';
}


}

/// @nodoc
abstract mixin class _$RecentTaskCopyWith<$Res> implements $RecentTaskCopyWith<$Res> {
  factory _$RecentTaskCopyWith(_RecentTask value, $Res Function(_RecentTask) _then) = __$RecentTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, bool isComplete, String? category, DateTime? dueDate
});




}
/// @nodoc
class __$RecentTaskCopyWithImpl<$Res>
    implements _$RecentTaskCopyWith<$Res> {
  __$RecentTaskCopyWithImpl(this._self, this._then);

  final _RecentTask _self;
  final $Res Function(_RecentTask) _then;

/// Create a copy of RecentTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? isComplete = null,Object? category = freezed,Object? dueDate = freezed,}) {
  return _then(_RecentTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isComplete: null == isComplete ? _self.isComplete : isComplete // ignore: cast_nullable_to_non_nullable
as bool,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$BudgetOverview {

 double get total; double get allocated; double get spent; String get currency; List<BudgetCategory> get categories;
/// Create a copy of BudgetOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetOverviewCopyWith<BudgetOverview> get copyWith => _$BudgetOverviewCopyWithImpl<BudgetOverview>(this as BudgetOverview, _$identity);

  /// Serializes this BudgetOverview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetOverview&&(identical(other.total, total) || other.total == total)&&(identical(other.allocated, allocated) || other.allocated == allocated)&&(identical(other.spent, spent) || other.spent == spent)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other.categories, categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,allocated,spent,currency,const DeepCollectionEquality().hash(categories));

@override
String toString() {
  return 'BudgetOverview(total: $total, allocated: $allocated, spent: $spent, currency: $currency, categories: $categories)';
}


}

/// @nodoc
abstract mixin class $BudgetOverviewCopyWith<$Res>  {
  factory $BudgetOverviewCopyWith(BudgetOverview value, $Res Function(BudgetOverview) _then) = _$BudgetOverviewCopyWithImpl;
@useResult
$Res call({
 double total, double allocated, double spent, String currency, List<BudgetCategory> categories
});




}
/// @nodoc
class _$BudgetOverviewCopyWithImpl<$Res>
    implements $BudgetOverviewCopyWith<$Res> {
  _$BudgetOverviewCopyWithImpl(this._self, this._then);

  final BudgetOverview _self;
  final $Res Function(BudgetOverview) _then;

/// Create a copy of BudgetOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? allocated = null,Object? spent = null,Object? currency = null,Object? categories = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,allocated: null == allocated ? _self.allocated : allocated // ignore: cast_nullable_to_non_nullable
as double,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<BudgetCategory>,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetOverview].
extension BudgetOverviewPatterns on BudgetOverview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetOverview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetOverview value)  $default,){
final _that = this;
switch (_that) {
case _BudgetOverview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetOverview value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetOverview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double total,  double allocated,  double spent,  String currency,  List<BudgetCategory> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetOverview() when $default != null:
return $default(_that.total,_that.allocated,_that.spent,_that.currency,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double total,  double allocated,  double spent,  String currency,  List<BudgetCategory> categories)  $default,) {final _that = this;
switch (_that) {
case _BudgetOverview():
return $default(_that.total,_that.allocated,_that.spent,_that.currency,_that.categories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double total,  double allocated,  double spent,  String currency,  List<BudgetCategory> categories)?  $default,) {final _that = this;
switch (_that) {
case _BudgetOverview() when $default != null:
return $default(_that.total,_that.allocated,_that.spent,_that.currency,_that.categories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetOverview implements BudgetOverview {
  const _BudgetOverview({this.total = 0.0, this.allocated = 0.0, this.spent = 0.0, this.currency = 'USD', final  List<BudgetCategory> categories = const []}): _categories = categories;
  factory _BudgetOverview.fromJson(Map<String, dynamic> json) => _$BudgetOverviewFromJson(json);

@override@JsonKey() final  double total;
@override@JsonKey() final  double allocated;
@override@JsonKey() final  double spent;
@override@JsonKey() final  String currency;
 final  List<BudgetCategory> _categories;
@override@JsonKey() List<BudgetCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of BudgetOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetOverviewCopyWith<_BudgetOverview> get copyWith => __$BudgetOverviewCopyWithImpl<_BudgetOverview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetOverviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetOverview&&(identical(other.total, total) || other.total == total)&&(identical(other.allocated, allocated) || other.allocated == allocated)&&(identical(other.spent, spent) || other.spent == spent)&&(identical(other.currency, currency) || other.currency == currency)&&const DeepCollectionEquality().equals(other._categories, _categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,allocated,spent,currency,const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'BudgetOverview(total: $total, allocated: $allocated, spent: $spent, currency: $currency, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$BudgetOverviewCopyWith<$Res> implements $BudgetOverviewCopyWith<$Res> {
  factory _$BudgetOverviewCopyWith(_BudgetOverview value, $Res Function(_BudgetOverview) _then) = __$BudgetOverviewCopyWithImpl;
@override @useResult
$Res call({
 double total, double allocated, double spent, String currency, List<BudgetCategory> categories
});




}
/// @nodoc
class __$BudgetOverviewCopyWithImpl<$Res>
    implements _$BudgetOverviewCopyWith<$Res> {
  __$BudgetOverviewCopyWithImpl(this._self, this._then);

  final _BudgetOverview _self;
  final $Res Function(_BudgetOverview) _then;

/// Create a copy of BudgetOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? allocated = null,Object? spent = null,Object? currency = null,Object? categories = null,}) {
  return _then(_BudgetOverview(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,allocated: null == allocated ? _self.allocated : allocated // ignore: cast_nullable_to_non_nullable
as double,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<BudgetCategory>,
  ));
}


}


/// @nodoc
mixin _$BudgetCategory {

 String get name; double get allocated; double get spent;
/// Create a copy of BudgetCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetCategoryCopyWith<BudgetCategory> get copyWith => _$BudgetCategoryCopyWithImpl<BudgetCategory>(this as BudgetCategory, _$identity);

  /// Serializes this BudgetCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetCategory&&(identical(other.name, name) || other.name == name)&&(identical(other.allocated, allocated) || other.allocated == allocated)&&(identical(other.spent, spent) || other.spent == spent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,allocated,spent);

@override
String toString() {
  return 'BudgetCategory(name: $name, allocated: $allocated, spent: $spent)';
}


}

/// @nodoc
abstract mixin class $BudgetCategoryCopyWith<$Res>  {
  factory $BudgetCategoryCopyWith(BudgetCategory value, $Res Function(BudgetCategory) _then) = _$BudgetCategoryCopyWithImpl;
@useResult
$Res call({
 String name, double allocated, double spent
});




}
/// @nodoc
class _$BudgetCategoryCopyWithImpl<$Res>
    implements $BudgetCategoryCopyWith<$Res> {
  _$BudgetCategoryCopyWithImpl(this._self, this._then);

  final BudgetCategory _self;
  final $Res Function(BudgetCategory) _then;

/// Create a copy of BudgetCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? allocated = null,Object? spent = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,allocated: null == allocated ? _self.allocated : allocated // ignore: cast_nullable_to_non_nullable
as double,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetCategory].
extension BudgetCategoryPatterns on BudgetCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetCategory value)  $default,){
final _that = this;
switch (_that) {
case _BudgetCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetCategory value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double allocated,  double spent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetCategory() when $default != null:
return $default(_that.name,_that.allocated,_that.spent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double allocated,  double spent)  $default,) {final _that = this;
switch (_that) {
case _BudgetCategory():
return $default(_that.name,_that.allocated,_that.spent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double allocated,  double spent)?  $default,) {final _that = this;
switch (_that) {
case _BudgetCategory() when $default != null:
return $default(_that.name,_that.allocated,_that.spent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetCategory implements BudgetCategory {
  const _BudgetCategory({required this.name, required this.allocated, required this.spent});
  factory _BudgetCategory.fromJson(Map<String, dynamic> json) => _$BudgetCategoryFromJson(json);

@override final  String name;
@override final  double allocated;
@override final  double spent;

/// Create a copy of BudgetCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetCategoryCopyWith<_BudgetCategory> get copyWith => __$BudgetCategoryCopyWithImpl<_BudgetCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetCategory&&(identical(other.name, name) || other.name == name)&&(identical(other.allocated, allocated) || other.allocated == allocated)&&(identical(other.spent, spent) || other.spent == spent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,allocated,spent);

@override
String toString() {
  return 'BudgetCategory(name: $name, allocated: $allocated, spent: $spent)';
}


}

/// @nodoc
abstract mixin class _$BudgetCategoryCopyWith<$Res> implements $BudgetCategoryCopyWith<$Res> {
  factory _$BudgetCategoryCopyWith(_BudgetCategory value, $Res Function(_BudgetCategory) _then) = __$BudgetCategoryCopyWithImpl;
@override @useResult
$Res call({
 String name, double allocated, double spent
});




}
/// @nodoc
class __$BudgetCategoryCopyWithImpl<$Res>
    implements _$BudgetCategoryCopyWith<$Res> {
  __$BudgetCategoryCopyWithImpl(this._self, this._then);

  final _BudgetCategory _self;
  final $Res Function(_BudgetCategory) _then;

/// Create a copy of BudgetCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? allocated = null,Object? spent = null,}) {
  return _then(_BudgetCategory(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,allocated: null == allocated ? _self.allocated : allocated // ignore: cast_nullable_to_non_nullable
as double,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$SmartAlert {

 String get id; SmartAlertType get type; String get title; String get body; String? get actionLabel; String? get actionRoute; DateTime? get createdAt;
/// Create a copy of SmartAlert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SmartAlertCopyWith<SmartAlert> get copyWith => _$SmartAlertCopyWithImpl<SmartAlert>(this as SmartAlert, _$identity);

  /// Serializes this SmartAlert to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SmartAlert&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.actionLabel, actionLabel) || other.actionLabel == actionLabel)&&(identical(other.actionRoute, actionRoute) || other.actionRoute == actionRoute)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,body,actionLabel,actionRoute,createdAt);

@override
String toString() {
  return 'SmartAlert(id: $id, type: $type, title: $title, body: $body, actionLabel: $actionLabel, actionRoute: $actionRoute, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SmartAlertCopyWith<$Res>  {
  factory $SmartAlertCopyWith(SmartAlert value, $Res Function(SmartAlert) _then) = _$SmartAlertCopyWithImpl;
@useResult
$Res call({
 String id, SmartAlertType type, String title, String body, String? actionLabel, String? actionRoute, DateTime? createdAt
});




}
/// @nodoc
class _$SmartAlertCopyWithImpl<$Res>
    implements $SmartAlertCopyWith<$Res> {
  _$SmartAlertCopyWithImpl(this._self, this._then);

  final SmartAlert _self;
  final $Res Function(SmartAlert) _then;

/// Create a copy of SmartAlert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? title = null,Object? body = null,Object? actionLabel = freezed,Object? actionRoute = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SmartAlertType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,actionLabel: freezed == actionLabel ? _self.actionLabel : actionLabel // ignore: cast_nullable_to_non_nullable
as String?,actionRoute: freezed == actionRoute ? _self.actionRoute : actionRoute // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SmartAlert].
extension SmartAlertPatterns on SmartAlert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SmartAlert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SmartAlert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SmartAlert value)  $default,){
final _that = this;
switch (_that) {
case _SmartAlert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SmartAlert value)?  $default,){
final _that = this;
switch (_that) {
case _SmartAlert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  SmartAlertType type,  String title,  String body,  String? actionLabel,  String? actionRoute,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SmartAlert() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.body,_that.actionLabel,_that.actionRoute,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  SmartAlertType type,  String title,  String body,  String? actionLabel,  String? actionRoute,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _SmartAlert():
return $default(_that.id,_that.type,_that.title,_that.body,_that.actionLabel,_that.actionRoute,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  SmartAlertType type,  String title,  String body,  String? actionLabel,  String? actionRoute,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SmartAlert() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.body,_that.actionLabel,_that.actionRoute,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SmartAlert implements SmartAlert {
  const _SmartAlert({required this.id, required this.type, required this.title, required this.body, this.actionLabel, this.actionRoute, this.createdAt});
  factory _SmartAlert.fromJson(Map<String, dynamic> json) => _$SmartAlertFromJson(json);

@override final  String id;
@override final  SmartAlertType type;
@override final  String title;
@override final  String body;
@override final  String? actionLabel;
@override final  String? actionRoute;
@override final  DateTime? createdAt;

/// Create a copy of SmartAlert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SmartAlertCopyWith<_SmartAlert> get copyWith => __$SmartAlertCopyWithImpl<_SmartAlert>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SmartAlertToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SmartAlert&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.actionLabel, actionLabel) || other.actionLabel == actionLabel)&&(identical(other.actionRoute, actionRoute) || other.actionRoute == actionRoute)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,body,actionLabel,actionRoute,createdAt);

@override
String toString() {
  return 'SmartAlert(id: $id, type: $type, title: $title, body: $body, actionLabel: $actionLabel, actionRoute: $actionRoute, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SmartAlertCopyWith<$Res> implements $SmartAlertCopyWith<$Res> {
  factory _$SmartAlertCopyWith(_SmartAlert value, $Res Function(_SmartAlert) _then) = __$SmartAlertCopyWithImpl;
@override @useResult
$Res call({
 String id, SmartAlertType type, String title, String body, String? actionLabel, String? actionRoute, DateTime? createdAt
});




}
/// @nodoc
class __$SmartAlertCopyWithImpl<$Res>
    implements _$SmartAlertCopyWith<$Res> {
  __$SmartAlertCopyWithImpl(this._self, this._then);

  final _SmartAlert _self;
  final $Res Function(_SmartAlert) _then;

/// Create a copy of SmartAlert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? title = null,Object? body = null,Object? actionLabel = freezed,Object? actionRoute = freezed,Object? createdAt = freezed,}) {
  return _then(_SmartAlert(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SmartAlertType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,actionLabel: freezed == actionLabel ? _self.actionLabel : actionLabel // ignore: cast_nullable_to_non_nullable
as String?,actionRoute: freezed == actionRoute ? _self.actionRoute : actionRoute // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$UpcomingEvent {

 String get id; String get title; DateTime get date; String get category; String? get description; String? get location;
/// Create a copy of UpcomingEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpcomingEventCopyWith<UpcomingEvent> get copyWith => _$UpcomingEventCopyWithImpl<UpcomingEvent>(this as UpcomingEvent, _$identity);

  /// Serializes this UpcomingEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpcomingEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,date,category,description,location);

@override
String toString() {
  return 'UpcomingEvent(id: $id, title: $title, date: $date, category: $category, description: $description, location: $location)';
}


}

/// @nodoc
abstract mixin class $UpcomingEventCopyWith<$Res>  {
  factory $UpcomingEventCopyWith(UpcomingEvent value, $Res Function(UpcomingEvent) _then) = _$UpcomingEventCopyWithImpl;
@useResult
$Res call({
 String id, String title, DateTime date, String category, String? description, String? location
});




}
/// @nodoc
class _$UpcomingEventCopyWithImpl<$Res>
    implements $UpcomingEventCopyWith<$Res> {
  _$UpcomingEventCopyWithImpl(this._self, this._then);

  final UpcomingEvent _self;
  final $Res Function(UpcomingEvent) _then;

/// Create a copy of UpcomingEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? date = null,Object? category = null,Object? description = freezed,Object? location = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpcomingEvent].
extension UpcomingEventPatterns on UpcomingEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpcomingEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpcomingEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpcomingEvent value)  $default,){
final _that = this;
switch (_that) {
case _UpcomingEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpcomingEvent value)?  $default,){
final _that = this;
switch (_that) {
case _UpcomingEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  DateTime date,  String category,  String? description,  String? location)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpcomingEvent() when $default != null:
return $default(_that.id,_that.title,_that.date,_that.category,_that.description,_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  DateTime date,  String category,  String? description,  String? location)  $default,) {final _that = this;
switch (_that) {
case _UpcomingEvent():
return $default(_that.id,_that.title,_that.date,_that.category,_that.description,_that.location);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  DateTime date,  String category,  String? description,  String? location)?  $default,) {final _that = this;
switch (_that) {
case _UpcomingEvent() when $default != null:
return $default(_that.id,_that.title,_that.date,_that.category,_that.description,_that.location);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpcomingEvent implements UpcomingEvent {
  const _UpcomingEvent({required this.id, required this.title, required this.date, required this.category, this.description, this.location});
  factory _UpcomingEvent.fromJson(Map<String, dynamic> json) => _$UpcomingEventFromJson(json);

@override final  String id;
@override final  String title;
@override final  DateTime date;
@override final  String category;
@override final  String? description;
@override final  String? location;

/// Create a copy of UpcomingEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpcomingEventCopyWith<_UpcomingEvent> get copyWith => __$UpcomingEventCopyWithImpl<_UpcomingEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpcomingEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpcomingEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,date,category,description,location);

@override
String toString() {
  return 'UpcomingEvent(id: $id, title: $title, date: $date, category: $category, description: $description, location: $location)';
}


}

/// @nodoc
abstract mixin class _$UpcomingEventCopyWith<$Res> implements $UpcomingEventCopyWith<$Res> {
  factory _$UpcomingEventCopyWith(_UpcomingEvent value, $Res Function(_UpcomingEvent) _then) = __$UpcomingEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, DateTime date, String category, String? description, String? location
});




}
/// @nodoc
class __$UpcomingEventCopyWithImpl<$Res>
    implements _$UpcomingEventCopyWith<$Res> {
  __$UpcomingEventCopyWithImpl(this._self, this._then);

  final _UpcomingEvent _self;
  final $Res Function(_UpcomingEvent) _then;

/// Create a copy of UpcomingEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? date = null,Object? category = null,Object? description = freezed,Object? location = freezed,}) {
  return _then(_UpcomingEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
