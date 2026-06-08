// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seating_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SeatingState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeatingState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SeatingState()';
}


}

/// @nodoc
class $SeatingStateCopyWith<$Res>  {
$SeatingStateCopyWith(SeatingState _, $Res Function(SeatingState) __);
}


/// Adds pattern-matching-related methods to [SeatingState].
extension SeatingStatePatterns on SeatingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SeatingLoading value)?  loading,TResult Function( SeatingLoaded value)?  loaded,TResult Function( SeatingError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SeatingLoading() when loading != null:
return loading(_that);case SeatingLoaded() when loaded != null:
return loaded(_that);case SeatingError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SeatingLoading value)  loading,required TResult Function( SeatingLoaded value)  loaded,required TResult Function( SeatingError value)  error,}){
final _that = this;
switch (_that) {
case SeatingLoading():
return loading(_that);case SeatingLoaded():
return loaded(_that);case SeatingError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SeatingLoading value)?  loading,TResult? Function( SeatingLoaded value)?  loaded,TResult? Function( SeatingError value)?  error,}){
final _that = this;
switch (_that) {
case SeatingLoading() when loading != null:
return loading(_that);case SeatingLoaded() when loaded != null:
return loaded(_that);case SeatingError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( SeatingData data)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SeatingLoading() when loading != null:
return loading();case SeatingLoaded() when loaded != null:
return loaded(_that.data);case SeatingError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( SeatingData data)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case SeatingLoading():
return loading();case SeatingLoaded():
return loaded(_that.data);case SeatingError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( SeatingData data)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case SeatingLoading() when loading != null:
return loading();case SeatingLoaded() when loaded != null:
return loaded(_that.data);case SeatingError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class SeatingLoading implements SeatingState {
  const SeatingLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeatingLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SeatingState.loading()';
}


}




/// @nodoc


class SeatingLoaded implements SeatingState {
  const SeatingLoaded(this.data);
  

 final  SeatingData data;

/// Create a copy of SeatingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeatingLoadedCopyWith<SeatingLoaded> get copyWith => _$SeatingLoadedCopyWithImpl<SeatingLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeatingLoaded&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'SeatingState.loaded(data: $data)';
}


}

/// @nodoc
abstract mixin class $SeatingLoadedCopyWith<$Res> implements $SeatingStateCopyWith<$Res> {
  factory $SeatingLoadedCopyWith(SeatingLoaded value, $Res Function(SeatingLoaded) _then) = _$SeatingLoadedCopyWithImpl;
@useResult
$Res call({
 SeatingData data
});


$SeatingDataCopyWith<$Res> get data;

}
/// @nodoc
class _$SeatingLoadedCopyWithImpl<$Res>
    implements $SeatingLoadedCopyWith<$Res> {
  _$SeatingLoadedCopyWithImpl(this._self, this._then);

  final SeatingLoaded _self;
  final $Res Function(SeatingLoaded) _then;

/// Create a copy of SeatingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(SeatingLoaded(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as SeatingData,
  ));
}

/// Create a copy of SeatingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeatingDataCopyWith<$Res> get data {
  
  return $SeatingDataCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc


class SeatingError implements SeatingState {
  const SeatingError(this.message);
  

 final  String message;

/// Create a copy of SeatingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeatingErrorCopyWith<SeatingError> get copyWith => _$SeatingErrorCopyWithImpl<SeatingError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeatingError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SeatingState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $SeatingErrorCopyWith<$Res> implements $SeatingStateCopyWith<$Res> {
  factory $SeatingErrorCopyWith(SeatingError value, $Res Function(SeatingError) _then) = _$SeatingErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SeatingErrorCopyWithImpl<$Res>
    implements $SeatingErrorCopyWith<$Res> {
  _$SeatingErrorCopyWithImpl(this._self, this._then);

  final SeatingError _self;
  final $Res Function(SeatingError) _then;

/// Create a copy of SeatingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SeatingError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
