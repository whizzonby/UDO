// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'experience_config_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExperienceConfig {

 String get id; bool get isPublished; String? get welcomeMessage; Map<String, dynamic> get sectionsEnabled; String get themeAccentColor; String? get customDomain;
/// Create a copy of ExperienceConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExperienceConfigCopyWith<ExperienceConfig> get copyWith => _$ExperienceConfigCopyWithImpl<ExperienceConfig>(this as ExperienceConfig, _$identity);

  /// Serializes this ExperienceConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExperienceConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.welcomeMessage, welcomeMessage) || other.welcomeMessage == welcomeMessage)&&const DeepCollectionEquality().equals(other.sectionsEnabled, sectionsEnabled)&&(identical(other.themeAccentColor, themeAccentColor) || other.themeAccentColor == themeAccentColor)&&(identical(other.customDomain, customDomain) || other.customDomain == customDomain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,isPublished,welcomeMessage,const DeepCollectionEquality().hash(sectionsEnabled),themeAccentColor,customDomain);

@override
String toString() {
  return 'ExperienceConfig(id: $id, isPublished: $isPublished, welcomeMessage: $welcomeMessage, sectionsEnabled: $sectionsEnabled, themeAccentColor: $themeAccentColor, customDomain: $customDomain)';
}


}

/// @nodoc
abstract mixin class $ExperienceConfigCopyWith<$Res>  {
  factory $ExperienceConfigCopyWith(ExperienceConfig value, $Res Function(ExperienceConfig) _then) = _$ExperienceConfigCopyWithImpl;
@useResult
$Res call({
 String id, bool isPublished, String? welcomeMessage, Map<String, dynamic> sectionsEnabled, String themeAccentColor, String? customDomain
});




}
/// @nodoc
class _$ExperienceConfigCopyWithImpl<$Res>
    implements $ExperienceConfigCopyWith<$Res> {
  _$ExperienceConfigCopyWithImpl(this._self, this._then);

  final ExperienceConfig _self;
  final $Res Function(ExperienceConfig) _then;

/// Create a copy of ExperienceConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? isPublished = null,Object? welcomeMessage = freezed,Object? sectionsEnabled = null,Object? themeAccentColor = null,Object? customDomain = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,welcomeMessage: freezed == welcomeMessage ? _self.welcomeMessage : welcomeMessage // ignore: cast_nullable_to_non_nullable
as String?,sectionsEnabled: null == sectionsEnabled ? _self.sectionsEnabled : sectionsEnabled // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,themeAccentColor: null == themeAccentColor ? _self.themeAccentColor : themeAccentColor // ignore: cast_nullable_to_non_nullable
as String,customDomain: freezed == customDomain ? _self.customDomain : customDomain // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExperienceConfig].
extension ExperienceConfigPatterns on ExperienceConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExperienceConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExperienceConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExperienceConfig value)  $default,){
final _that = this;
switch (_that) {
case _ExperienceConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExperienceConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ExperienceConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool isPublished,  String? welcomeMessage,  Map<String, dynamic> sectionsEnabled,  String themeAccentColor,  String? customDomain)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExperienceConfig() when $default != null:
return $default(_that.id,_that.isPublished,_that.welcomeMessage,_that.sectionsEnabled,_that.themeAccentColor,_that.customDomain);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool isPublished,  String? welcomeMessage,  Map<String, dynamic> sectionsEnabled,  String themeAccentColor,  String? customDomain)  $default,) {final _that = this;
switch (_that) {
case _ExperienceConfig():
return $default(_that.id,_that.isPublished,_that.welcomeMessage,_that.sectionsEnabled,_that.themeAccentColor,_that.customDomain);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool isPublished,  String? welcomeMessage,  Map<String, dynamic> sectionsEnabled,  String themeAccentColor,  String? customDomain)?  $default,) {final _that = this;
switch (_that) {
case _ExperienceConfig() when $default != null:
return $default(_that.id,_that.isPublished,_that.welcomeMessage,_that.sectionsEnabled,_that.themeAccentColor,_that.customDomain);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExperienceConfig implements ExperienceConfig {
  const _ExperienceConfig({required this.id, this.isPublished = false, this.welcomeMessage, final  Map<String, dynamic> sectionsEnabled = const {}, this.themeAccentColor = '#FF4D8C', this.customDomain}): _sectionsEnabled = sectionsEnabled;
  factory _ExperienceConfig.fromJson(Map<String, dynamic> json) => _$ExperienceConfigFromJson(json);

@override final  String id;
@override@JsonKey() final  bool isPublished;
@override final  String? welcomeMessage;
 final  Map<String, dynamic> _sectionsEnabled;
@override@JsonKey() Map<String, dynamic> get sectionsEnabled {
  if (_sectionsEnabled is EqualUnmodifiableMapView) return _sectionsEnabled;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sectionsEnabled);
}

@override@JsonKey() final  String themeAccentColor;
@override final  String? customDomain;

/// Create a copy of ExperienceConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExperienceConfigCopyWith<_ExperienceConfig> get copyWith => __$ExperienceConfigCopyWithImpl<_ExperienceConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExperienceConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExperienceConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished)&&(identical(other.welcomeMessage, welcomeMessage) || other.welcomeMessage == welcomeMessage)&&const DeepCollectionEquality().equals(other._sectionsEnabled, _sectionsEnabled)&&(identical(other.themeAccentColor, themeAccentColor) || other.themeAccentColor == themeAccentColor)&&(identical(other.customDomain, customDomain) || other.customDomain == customDomain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,isPublished,welcomeMessage,const DeepCollectionEquality().hash(_sectionsEnabled),themeAccentColor,customDomain);

@override
String toString() {
  return 'ExperienceConfig(id: $id, isPublished: $isPublished, welcomeMessage: $welcomeMessage, sectionsEnabled: $sectionsEnabled, themeAccentColor: $themeAccentColor, customDomain: $customDomain)';
}


}

/// @nodoc
abstract mixin class _$ExperienceConfigCopyWith<$Res> implements $ExperienceConfigCopyWith<$Res> {
  factory _$ExperienceConfigCopyWith(_ExperienceConfig value, $Res Function(_ExperienceConfig) _then) = __$ExperienceConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, bool isPublished, String? welcomeMessage, Map<String, dynamic> sectionsEnabled, String themeAccentColor, String? customDomain
});




}
/// @nodoc
class __$ExperienceConfigCopyWithImpl<$Res>
    implements _$ExperienceConfigCopyWith<$Res> {
  __$ExperienceConfigCopyWithImpl(this._self, this._then);

  final _ExperienceConfig _self;
  final $Res Function(_ExperienceConfig) _then;

/// Create a copy of ExperienceConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? isPublished = null,Object? welcomeMessage = freezed,Object? sectionsEnabled = null,Object? themeAccentColor = null,Object? customDomain = freezed,}) {
  return _then(_ExperienceConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,welcomeMessage: freezed == welcomeMessage ? _self.welcomeMessage : welcomeMessage // ignore: cast_nullable_to_non_nullable
as String?,sectionsEnabled: null == sectionsEnabled ? _self._sectionsEnabled : sectionsEnabled // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,themeAccentColor: null == themeAccentColor ? _self.themeAccentColor : themeAccentColor // ignore: cast_nullable_to_non_nullable
as String,customDomain: freezed == customDomain ? _self.customDomain : customDomain // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
