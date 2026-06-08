// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'guests_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GuestsListState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuestsListState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GuestsListState()';
}


}

/// @nodoc
class $GuestsListStateCopyWith<$Res>  {
$GuestsListStateCopyWith(GuestsListState _, $Res Function(GuestsListState) __);
}


/// Adds pattern-matching-related methods to [GuestsListState].
extension GuestsListStatePatterns on GuestsListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GuestsListLoading value)?  loading,TResult Function( _GuestsListLoaded value)?  loaded,TResult Function( _GuestsListError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuestsListLoading() when loading != null:
return loading(_that);case _GuestsListLoaded() when loaded != null:
return loaded(_that);case _GuestsListError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GuestsListLoading value)  loading,required TResult Function( _GuestsListLoaded value)  loaded,required TResult Function( _GuestsListError value)  error,}){
final _that = this;
switch (_that) {
case _GuestsListLoading():
return loading(_that);case _GuestsListLoaded():
return loaded(_that);case _GuestsListError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GuestsListLoading value)?  loading,TResult? Function( _GuestsListLoaded value)?  loaded,TResult? Function( _GuestsListError value)?  error,}){
final _that = this;
switch (_that) {
case _GuestsListLoading() when loading != null:
return loading(_that);case _GuestsListLoaded() when loaded != null:
return loaded(_that);case _GuestsListError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( List<GuestModel> guests,  int total,  String query,  String statusFilter)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuestsListLoading() when loading != null:
return loading();case _GuestsListLoaded() when loaded != null:
return loaded(_that.guests,_that.total,_that.query,_that.statusFilter);case _GuestsListError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( List<GuestModel> guests,  int total,  String query,  String statusFilter)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _GuestsListLoading():
return loading();case _GuestsListLoaded():
return loaded(_that.guests,_that.total,_that.query,_that.statusFilter);case _GuestsListError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( List<GuestModel> guests,  int total,  String query,  String statusFilter)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _GuestsListLoading() when loading != null:
return loading();case _GuestsListLoaded() when loaded != null:
return loaded(_that.guests,_that.total,_that.query,_that.statusFilter);case _GuestsListError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _GuestsListLoading implements GuestsListState {
  const _GuestsListLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestsListLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GuestsListState.loading()';
}


}




/// @nodoc


class _GuestsListLoaded implements GuestsListState {
  const _GuestsListLoaded({required final  List<GuestModel> guests, required this.total, this.query = '', this.statusFilter = 'all'}): _guests = guests;
  

 final  List<GuestModel> _guests;
 List<GuestModel> get guests {
  if (_guests is EqualUnmodifiableListView) return _guests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_guests);
}

 final  int total;
@JsonKey() final  String query;
@JsonKey() final  String statusFilter;

/// Create a copy of GuestsListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestsListLoadedCopyWith<_GuestsListLoaded> get copyWith => __$GuestsListLoadedCopyWithImpl<_GuestsListLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestsListLoaded&&const DeepCollectionEquality().equals(other._guests, _guests)&&(identical(other.total, total) || other.total == total)&&(identical(other.query, query) || other.query == query)&&(identical(other.statusFilter, statusFilter) || other.statusFilter == statusFilter));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_guests),total,query,statusFilter);

@override
String toString() {
  return 'GuestsListState.loaded(guests: $guests, total: $total, query: $query, statusFilter: $statusFilter)';
}


}

/// @nodoc
abstract mixin class _$GuestsListLoadedCopyWith<$Res> implements $GuestsListStateCopyWith<$Res> {
  factory _$GuestsListLoadedCopyWith(_GuestsListLoaded value, $Res Function(_GuestsListLoaded) _then) = __$GuestsListLoadedCopyWithImpl;
@useResult
$Res call({
 List<GuestModel> guests, int total, String query, String statusFilter
});




}
/// @nodoc
class __$GuestsListLoadedCopyWithImpl<$Res>
    implements _$GuestsListLoadedCopyWith<$Res> {
  __$GuestsListLoadedCopyWithImpl(this._self, this._then);

  final _GuestsListLoaded _self;
  final $Res Function(_GuestsListLoaded) _then;

/// Create a copy of GuestsListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? guests = null,Object? total = null,Object? query = null,Object? statusFilter = null,}) {
  return _then(_GuestsListLoaded(
guests: null == guests ? _self._guests : guests // ignore: cast_nullable_to_non_nullable
as List<GuestModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,statusFilter: null == statusFilter ? _self.statusFilter : statusFilter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _GuestsListError implements GuestsListState {
  const _GuestsListError(this.message);
  

 final  String message;

/// Create a copy of GuestsListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestsListErrorCopyWith<_GuestsListError> get copyWith => __$GuestsListErrorCopyWithImpl<_GuestsListError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestsListError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'GuestsListState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$GuestsListErrorCopyWith<$Res> implements $GuestsListStateCopyWith<$Res> {
  factory _$GuestsListErrorCopyWith(_GuestsListError value, $Res Function(_GuestsListError) _then) = __$GuestsListErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$GuestsListErrorCopyWithImpl<$Res>
    implements _$GuestsListErrorCopyWith<$Res> {
  __$GuestsListErrorCopyWithImpl(this._self, this._then);

  final _GuestsListError _self;
  final $Res Function(_GuestsListError) _then;

/// Create a copy of GuestsListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_GuestsListError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$GuestsOverviewState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuestsOverviewState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GuestsOverviewState()';
}


}

/// @nodoc
class $GuestsOverviewStateCopyWith<$Res>  {
$GuestsOverviewStateCopyWith(GuestsOverviewState _, $Res Function(GuestsOverviewState) __);
}


/// Adds pattern-matching-related methods to [GuestsOverviewState].
extension GuestsOverviewStatePatterns on GuestsOverviewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GuestsOverviewLoading value)?  loading,TResult Function( _GuestsOverviewLoaded value)?  loaded,TResult Function( _GuestsOverviewError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuestsOverviewLoading() when loading != null:
return loading(_that);case _GuestsOverviewLoaded() when loaded != null:
return loaded(_that);case _GuestsOverviewError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GuestsOverviewLoading value)  loading,required TResult Function( _GuestsOverviewLoaded value)  loaded,required TResult Function( _GuestsOverviewError value)  error,}){
final _that = this;
switch (_that) {
case _GuestsOverviewLoading():
return loading(_that);case _GuestsOverviewLoaded():
return loaded(_that);case _GuestsOverviewError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GuestsOverviewLoading value)?  loading,TResult? Function( _GuestsOverviewLoaded value)?  loaded,TResult? Function( _GuestsOverviewError value)?  error,}){
final _that = this;
switch (_that) {
case _GuestsOverviewLoading() when loading != null:
return loading(_that);case _GuestsOverviewLoaded() when loaded != null:
return loaded(_that);case _GuestsOverviewError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( GuestsOverview overview)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuestsOverviewLoading() when loading != null:
return loading();case _GuestsOverviewLoaded() when loaded != null:
return loaded(_that.overview);case _GuestsOverviewError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( GuestsOverview overview)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _GuestsOverviewLoading():
return loading();case _GuestsOverviewLoaded():
return loaded(_that.overview);case _GuestsOverviewError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( GuestsOverview overview)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _GuestsOverviewLoading() when loading != null:
return loading();case _GuestsOverviewLoaded() when loaded != null:
return loaded(_that.overview);case _GuestsOverviewError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _GuestsOverviewLoading implements GuestsOverviewState {
  const _GuestsOverviewLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestsOverviewLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GuestsOverviewState.loading()';
}


}




/// @nodoc


class _GuestsOverviewLoaded implements GuestsOverviewState {
  const _GuestsOverviewLoaded(this.overview);
  

 final  GuestsOverview overview;

/// Create a copy of GuestsOverviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestsOverviewLoadedCopyWith<_GuestsOverviewLoaded> get copyWith => __$GuestsOverviewLoadedCopyWithImpl<_GuestsOverviewLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestsOverviewLoaded&&(identical(other.overview, overview) || other.overview == overview));
}


@override
int get hashCode => Object.hash(runtimeType,overview);

@override
String toString() {
  return 'GuestsOverviewState.loaded(overview: $overview)';
}


}

/// @nodoc
abstract mixin class _$GuestsOverviewLoadedCopyWith<$Res> implements $GuestsOverviewStateCopyWith<$Res> {
  factory _$GuestsOverviewLoadedCopyWith(_GuestsOverviewLoaded value, $Res Function(_GuestsOverviewLoaded) _then) = __$GuestsOverviewLoadedCopyWithImpl;
@useResult
$Res call({
 GuestsOverview overview
});


$GuestsOverviewCopyWith<$Res> get overview;

}
/// @nodoc
class __$GuestsOverviewLoadedCopyWithImpl<$Res>
    implements _$GuestsOverviewLoadedCopyWith<$Res> {
  __$GuestsOverviewLoadedCopyWithImpl(this._self, this._then);

  final _GuestsOverviewLoaded _self;
  final $Res Function(_GuestsOverviewLoaded) _then;

/// Create a copy of GuestsOverviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? overview = null,}) {
  return _then(_GuestsOverviewLoaded(
null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as GuestsOverview,
  ));
}

/// Create a copy of GuestsOverviewState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuestsOverviewCopyWith<$Res> get overview {
  
  return $GuestsOverviewCopyWith<$Res>(_self.overview, (value) {
    return _then(_self.copyWith(overview: value));
  });
}
}

/// @nodoc


class _GuestsOverviewError implements GuestsOverviewState {
  const _GuestsOverviewError(this.message);
  

 final  String message;

/// Create a copy of GuestsOverviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestsOverviewErrorCopyWith<_GuestsOverviewError> get copyWith => __$GuestsOverviewErrorCopyWithImpl<_GuestsOverviewError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestsOverviewError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'GuestsOverviewState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$GuestsOverviewErrorCopyWith<$Res> implements $GuestsOverviewStateCopyWith<$Res> {
  factory _$GuestsOverviewErrorCopyWith(_GuestsOverviewError value, $Res Function(_GuestsOverviewError) _then) = __$GuestsOverviewErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$GuestsOverviewErrorCopyWithImpl<$Res>
    implements _$GuestsOverviewErrorCopyWith<$Res> {
  __$GuestsOverviewErrorCopyWithImpl(this._self, this._then);

  final _GuestsOverviewError _self;
  final $Res Function(_GuestsOverviewError) _then;

/// Create a copy of GuestsOverviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_GuestsOverviewError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$GuestDetailState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GuestDetailState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GuestDetailState()';
}


}

/// @nodoc
class $GuestDetailStateCopyWith<$Res>  {
$GuestDetailStateCopyWith(GuestDetailState _, $Res Function(GuestDetailState) __);
}


/// Adds pattern-matching-related methods to [GuestDetailState].
extension GuestDetailStatePatterns on GuestDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _GuestDetailIdle value)?  idle,TResult Function( _GuestDetailLoading value)?  loading,TResult Function( _GuestDetailLoaded value)?  loaded,TResult Function( _GuestDetailError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GuestDetailIdle() when idle != null:
return idle(_that);case _GuestDetailLoading() when loading != null:
return loading(_that);case _GuestDetailLoaded() when loaded != null:
return loaded(_that);case _GuestDetailError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _GuestDetailIdle value)  idle,required TResult Function( _GuestDetailLoading value)  loading,required TResult Function( _GuestDetailLoaded value)  loaded,required TResult Function( _GuestDetailError value)  error,}){
final _that = this;
switch (_that) {
case _GuestDetailIdle():
return idle(_that);case _GuestDetailLoading():
return loading(_that);case _GuestDetailLoaded():
return loaded(_that);case _GuestDetailError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _GuestDetailIdle value)?  idle,TResult? Function( _GuestDetailLoading value)?  loading,TResult? Function( _GuestDetailLoaded value)?  loaded,TResult? Function( _GuestDetailError value)?  error,}){
final _that = this;
switch (_that) {
case _GuestDetailIdle() when idle != null:
return idle(_that);case _GuestDetailLoading() when loading != null:
return loading(_that);case _GuestDetailLoaded() when loaded != null:
return loaded(_that);case _GuestDetailError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function()?  loading,TResult Function( GuestModel guest)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GuestDetailIdle() when idle != null:
return idle();case _GuestDetailLoading() when loading != null:
return loading();case _GuestDetailLoaded() when loaded != null:
return loaded(_that.guest);case _GuestDetailError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function()  loading,required TResult Function( GuestModel guest)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _GuestDetailIdle():
return idle();case _GuestDetailLoading():
return loading();case _GuestDetailLoaded():
return loaded(_that.guest);case _GuestDetailError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function()?  loading,TResult? Function( GuestModel guest)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _GuestDetailIdle() when idle != null:
return idle();case _GuestDetailLoading() when loading != null:
return loading();case _GuestDetailLoaded() when loaded != null:
return loaded(_that.guest);case _GuestDetailError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _GuestDetailIdle implements GuestDetailState {
  const _GuestDetailIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestDetailIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GuestDetailState.idle()';
}


}




/// @nodoc


class _GuestDetailLoading implements GuestDetailState {
  const _GuestDetailLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestDetailLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GuestDetailState.loading()';
}


}




/// @nodoc


class _GuestDetailLoaded implements GuestDetailState {
  const _GuestDetailLoaded(this.guest);
  

 final  GuestModel guest;

/// Create a copy of GuestDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestDetailLoadedCopyWith<_GuestDetailLoaded> get copyWith => __$GuestDetailLoadedCopyWithImpl<_GuestDetailLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestDetailLoaded&&(identical(other.guest, guest) || other.guest == guest));
}


@override
int get hashCode => Object.hash(runtimeType,guest);

@override
String toString() {
  return 'GuestDetailState.loaded(guest: $guest)';
}


}

/// @nodoc
abstract mixin class _$GuestDetailLoadedCopyWith<$Res> implements $GuestDetailStateCopyWith<$Res> {
  factory _$GuestDetailLoadedCopyWith(_GuestDetailLoaded value, $Res Function(_GuestDetailLoaded) _then) = __$GuestDetailLoadedCopyWithImpl;
@useResult
$Res call({
 GuestModel guest
});


$GuestModelCopyWith<$Res> get guest;

}
/// @nodoc
class __$GuestDetailLoadedCopyWithImpl<$Res>
    implements _$GuestDetailLoadedCopyWith<$Res> {
  __$GuestDetailLoadedCopyWithImpl(this._self, this._then);

  final _GuestDetailLoaded _self;
  final $Res Function(_GuestDetailLoaded) _then;

/// Create a copy of GuestDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? guest = null,}) {
  return _then(_GuestDetailLoaded(
null == guest ? _self.guest : guest // ignore: cast_nullable_to_non_nullable
as GuestModel,
  ));
}

/// Create a copy of GuestDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GuestModelCopyWith<$Res> get guest {
  
  return $GuestModelCopyWith<$Res>(_self.guest, (value) {
    return _then(_self.copyWith(guest: value));
  });
}
}

/// @nodoc


class _GuestDetailError implements GuestDetailState {
  const _GuestDetailError(this.message);
  

 final  String message;

/// Create a copy of GuestDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GuestDetailErrorCopyWith<_GuestDetailError> get copyWith => __$GuestDetailErrorCopyWithImpl<_GuestDetailError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GuestDetailError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'GuestDetailState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$GuestDetailErrorCopyWith<$Res> implements $GuestDetailStateCopyWith<$Res> {
  factory _$GuestDetailErrorCopyWith(_GuestDetailError value, $Res Function(_GuestDetailError) _then) = __$GuestDetailErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$GuestDetailErrorCopyWithImpl<$Res>
    implements _$GuestDetailErrorCopyWith<$Res> {
  __$GuestDetailErrorCopyWithImpl(this._self, this._then);

  final _GuestDetailError _self;
  final $Res Function(_GuestDetailError) _then;

/// Create a copy of GuestDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_GuestDetailError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
