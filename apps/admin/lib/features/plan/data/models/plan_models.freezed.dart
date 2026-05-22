// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlanTask {

 String get id; String get title; String get category; TaskPriority get priority; bool get isComplete; DateTime? get dueDate; String? get notes;
/// Create a copy of PlanTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanTaskCopyWith<PlanTask> get copyWith => _$PlanTaskCopyWithImpl<PlanTask>(this as PlanTask, _$identity);

  /// Serializes this PlanTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanTask&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,category,priority,isComplete,dueDate,notes);

@override
String toString() {
  return 'PlanTask(id: $id, title: $title, category: $category, priority: $priority, isComplete: $isComplete, dueDate: $dueDate, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $PlanTaskCopyWith<$Res>  {
  factory $PlanTaskCopyWith(PlanTask value, $Res Function(PlanTask) _then) = _$PlanTaskCopyWithImpl;
@useResult
$Res call({
 String id, String title, String category, TaskPriority priority, bool isComplete, DateTime? dueDate, String? notes
});




}
/// @nodoc
class _$PlanTaskCopyWithImpl<$Res>
    implements $PlanTaskCopyWith<$Res> {
  _$PlanTaskCopyWithImpl(this._self, this._then);

  final PlanTask _self;
  final $Res Function(PlanTask) _then;

/// Create a copy of PlanTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? category = null,Object? priority = null,Object? isComplete = null,Object? dueDate = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,isComplete: null == isComplete ? _self.isComplete : isComplete // ignore: cast_nullable_to_non_nullable
as bool,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanTask].
extension PlanTaskPatterns on PlanTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanTask value)  $default,){
final _that = this;
switch (_that) {
case _PlanTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanTask value)?  $default,){
final _that = this;
switch (_that) {
case _PlanTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String category,  TaskPriority priority,  bool isComplete,  DateTime? dueDate,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanTask() when $default != null:
return $default(_that.id,_that.title,_that.category,_that.priority,_that.isComplete,_that.dueDate,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String category,  TaskPriority priority,  bool isComplete,  DateTime? dueDate,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _PlanTask():
return $default(_that.id,_that.title,_that.category,_that.priority,_that.isComplete,_that.dueDate,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String category,  TaskPriority priority,  bool isComplete,  DateTime? dueDate,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _PlanTask() when $default != null:
return $default(_that.id,_that.title,_that.category,_that.priority,_that.isComplete,_that.dueDate,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlanTask implements PlanTask {
  const _PlanTask({required this.id, required this.title, required this.category, this.priority = TaskPriority.medium, this.isComplete = false, this.dueDate, this.notes});
  factory _PlanTask.fromJson(Map<String, dynamic> json) => _$PlanTaskFromJson(json);

@override final  String id;
@override final  String title;
@override final  String category;
@override@JsonKey() final  TaskPriority priority;
@override@JsonKey() final  bool isComplete;
@override final  DateTime? dueDate;
@override final  String? notes;

/// Create a copy of PlanTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanTaskCopyWith<_PlanTask> get copyWith => __$PlanTaskCopyWithImpl<_PlanTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanTask&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,category,priority,isComplete,dueDate,notes);

@override
String toString() {
  return 'PlanTask(id: $id, title: $title, category: $category, priority: $priority, isComplete: $isComplete, dueDate: $dueDate, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$PlanTaskCopyWith<$Res> implements $PlanTaskCopyWith<$Res> {
  factory _$PlanTaskCopyWith(_PlanTask value, $Res Function(_PlanTask) _then) = __$PlanTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String category, TaskPriority priority, bool isComplete, DateTime? dueDate, String? notes
});




}
/// @nodoc
class __$PlanTaskCopyWithImpl<$Res>
    implements _$PlanTaskCopyWith<$Res> {
  __$PlanTaskCopyWithImpl(this._self, this._then);

  final _PlanTask _self;
  final $Res Function(_PlanTask) _then;

/// Create a copy of PlanTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? category = null,Object? priority = null,Object? isComplete = null,Object? dueDate = freezed,Object? notes = freezed,}) {
  return _then(_PlanTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,isComplete: null == isComplete ? _self.isComplete : isComplete // ignore: cast_nullable_to_non_nullable
as bool,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Vendor {

 String get id; String get name; String get category; VendorStatus get status; String? get contactName; String? get contactPhone; String? get contactEmail; double get contractAmount; double get paidAmount; String? get notes;
/// Create a copy of Vendor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorCopyWith<Vendor> get copyWith => _$VendorCopyWithImpl<Vendor>(this as Vendor, _$identity);

  /// Serializes this Vendor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Vendor&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.contactName, contactName) || other.contactName == contactName)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.contractAmount, contractAmount) || other.contractAmount == contractAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,status,contactName,contactPhone,contactEmail,contractAmount,paidAmount,notes);

@override
String toString() {
  return 'Vendor(id: $id, name: $name, category: $category, status: $status, contactName: $contactName, contactPhone: $contactPhone, contactEmail: $contactEmail, contractAmount: $contractAmount, paidAmount: $paidAmount, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $VendorCopyWith<$Res>  {
  factory $VendorCopyWith(Vendor value, $Res Function(Vendor) _then) = _$VendorCopyWithImpl;
@useResult
$Res call({
 String id, String name, String category, VendorStatus status, String? contactName, String? contactPhone, String? contactEmail, double contractAmount, double paidAmount, String? notes
});




}
/// @nodoc
class _$VendorCopyWithImpl<$Res>
    implements $VendorCopyWith<$Res> {
  _$VendorCopyWithImpl(this._self, this._then);

  final Vendor _self;
  final $Res Function(Vendor) _then;

/// Create a copy of Vendor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? category = null,Object? status = null,Object? contactName = freezed,Object? contactPhone = freezed,Object? contactEmail = freezed,Object? contractAmount = null,Object? paidAmount = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VendorStatus,contactName: freezed == contactName ? _self.contactName : contactName // ignore: cast_nullable_to_non_nullable
as String?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,contactEmail: freezed == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String?,contractAmount: null == contractAmount ? _self.contractAmount : contractAmount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Vendor].
extension VendorPatterns on Vendor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Vendor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Vendor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Vendor value)  $default,){
final _that = this;
switch (_that) {
case _Vendor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Vendor value)?  $default,){
final _that = this;
switch (_that) {
case _Vendor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String category,  VendorStatus status,  String? contactName,  String? contactPhone,  String? contactEmail,  double contractAmount,  double paidAmount,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Vendor() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.status,_that.contactName,_that.contactPhone,_that.contactEmail,_that.contractAmount,_that.paidAmount,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String category,  VendorStatus status,  String? contactName,  String? contactPhone,  String? contactEmail,  double contractAmount,  double paidAmount,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _Vendor():
return $default(_that.id,_that.name,_that.category,_that.status,_that.contactName,_that.contactPhone,_that.contactEmail,_that.contractAmount,_that.paidAmount,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String category,  VendorStatus status,  String? contactName,  String? contactPhone,  String? contactEmail,  double contractAmount,  double paidAmount,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _Vendor() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.status,_that.contactName,_that.contactPhone,_that.contactEmail,_that.contractAmount,_that.paidAmount,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Vendor implements Vendor {
  const _Vendor({required this.id, required this.name, required this.category, this.status = VendorStatus.potential, this.contactName, this.contactPhone, this.contactEmail, this.contractAmount = 0.0, this.paidAmount = 0.0, this.notes});
  factory _Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);

@override final  String id;
@override final  String name;
@override final  String category;
@override@JsonKey() final  VendorStatus status;
@override final  String? contactName;
@override final  String? contactPhone;
@override final  String? contactEmail;
@override@JsonKey() final  double contractAmount;
@override@JsonKey() final  double paidAmount;
@override final  String? notes;

/// Create a copy of Vendor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorCopyWith<_Vendor> get copyWith => __$VendorCopyWithImpl<_Vendor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Vendor&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.status, status) || other.status == status)&&(identical(other.contactName, contactName) || other.contactName == contactName)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.contractAmount, contractAmount) || other.contractAmount == contractAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,status,contactName,contactPhone,contactEmail,contractAmount,paidAmount,notes);

@override
String toString() {
  return 'Vendor(id: $id, name: $name, category: $category, status: $status, contactName: $contactName, contactPhone: $contactPhone, contactEmail: $contactEmail, contractAmount: $contractAmount, paidAmount: $paidAmount, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$VendorCopyWith<$Res> implements $VendorCopyWith<$Res> {
  factory _$VendorCopyWith(_Vendor value, $Res Function(_Vendor) _then) = __$VendorCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String category, VendorStatus status, String? contactName, String? contactPhone, String? contactEmail, double contractAmount, double paidAmount, String? notes
});




}
/// @nodoc
class __$VendorCopyWithImpl<$Res>
    implements _$VendorCopyWith<$Res> {
  __$VendorCopyWithImpl(this._self, this._then);

  final _Vendor _self;
  final $Res Function(_Vendor) _then;

/// Create a copy of Vendor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? category = null,Object? status = null,Object? contactName = freezed,Object? contactPhone = freezed,Object? contactEmail = freezed,Object? contractAmount = null,Object? paidAmount = null,Object? notes = freezed,}) {
  return _then(_Vendor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VendorStatus,contactName: freezed == contactName ? _self.contactName : contactName // ignore: cast_nullable_to_non_nullable
as String?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,contactEmail: freezed == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String?,contractAmount: null == contractAmount ? _self.contractAmount : contractAmount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TimelineEvent {

 String get id; String get title; DateTime get date; String? get time; String? get description; String? get category; String? get location; bool get isCompleted;
/// Create a copy of TimelineEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineEventCopyWith<TimelineEvent> get copyWith => _$TimelineEventCopyWithImpl<TimelineEvent>(this as TimelineEvent, _$identity);

  /// Serializes this TimelineEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.location, location) || other.location == location)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,date,time,description,category,location,isCompleted);

@override
String toString() {
  return 'TimelineEvent(id: $id, title: $title, date: $date, time: $time, description: $description, category: $category, location: $location, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class $TimelineEventCopyWith<$Res>  {
  factory $TimelineEventCopyWith(TimelineEvent value, $Res Function(TimelineEvent) _then) = _$TimelineEventCopyWithImpl;
@useResult
$Res call({
 String id, String title, DateTime date, String? time, String? description, String? category, String? location, bool isCompleted
});




}
/// @nodoc
class _$TimelineEventCopyWithImpl<$Res>
    implements $TimelineEventCopyWith<$Res> {
  _$TimelineEventCopyWithImpl(this._self, this._then);

  final TimelineEvent _self;
  final $Res Function(TimelineEvent) _then;

/// Create a copy of TimelineEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? date = null,Object? time = freezed,Object? description = freezed,Object? category = freezed,Object? location = freezed,Object? isCompleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TimelineEvent].
extension TimelineEventPatterns on TimelineEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimelineEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimelineEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimelineEvent value)  $default,){
final _that = this;
switch (_that) {
case _TimelineEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimelineEvent value)?  $default,){
final _that = this;
switch (_that) {
case _TimelineEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  DateTime date,  String? time,  String? description,  String? category,  String? location,  bool isCompleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimelineEvent() when $default != null:
return $default(_that.id,_that.title,_that.date,_that.time,_that.description,_that.category,_that.location,_that.isCompleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  DateTime date,  String? time,  String? description,  String? category,  String? location,  bool isCompleted)  $default,) {final _that = this;
switch (_that) {
case _TimelineEvent():
return $default(_that.id,_that.title,_that.date,_that.time,_that.description,_that.category,_that.location,_that.isCompleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  DateTime date,  String? time,  String? description,  String? category,  String? location,  bool isCompleted)?  $default,) {final _that = this;
switch (_that) {
case _TimelineEvent() when $default != null:
return $default(_that.id,_that.title,_that.date,_that.time,_that.description,_that.category,_that.location,_that.isCompleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimelineEvent implements TimelineEvent {
  const _TimelineEvent({required this.id, required this.title, required this.date, this.time, this.description, this.category, this.location, this.isCompleted = false});
  factory _TimelineEvent.fromJson(Map<String, dynamic> json) => _$TimelineEventFromJson(json);

@override final  String id;
@override final  String title;
@override final  DateTime date;
@override final  String? time;
@override final  String? description;
@override final  String? category;
@override final  String? location;
@override@JsonKey() final  bool isCompleted;

/// Create a copy of TimelineEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimelineEventCopyWith<_TimelineEvent> get copyWith => __$TimelineEventCopyWithImpl<_TimelineEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimelineEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimelineEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.location, location) || other.location == location)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,date,time,description,category,location,isCompleted);

@override
String toString() {
  return 'TimelineEvent(id: $id, title: $title, date: $date, time: $time, description: $description, category: $category, location: $location, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class _$TimelineEventCopyWith<$Res> implements $TimelineEventCopyWith<$Res> {
  factory _$TimelineEventCopyWith(_TimelineEvent value, $Res Function(_TimelineEvent) _then) = __$TimelineEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, DateTime date, String? time, String? description, String? category, String? location, bool isCompleted
});




}
/// @nodoc
class __$TimelineEventCopyWithImpl<$Res>
    implements _$TimelineEventCopyWith<$Res> {
  __$TimelineEventCopyWithImpl(this._self, this._then);

  final _TimelineEvent _self;
  final $Res Function(_TimelineEvent) _then;

/// Create a copy of TimelineEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? date = null,Object? time = freezed,Object? description = freezed,Object? category = freezed,Object? location = freezed,Object? isCompleted = null,}) {
  return _then(_TimelineEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$BudgetItem {

 String get id; String get title; String get category; double get budgetedAmount; double get paidAmount; String? get vendorId; String? get notes;
/// Create a copy of BudgetItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetItemCopyWith<BudgetItem> get copyWith => _$BudgetItemCopyWithImpl<BudgetItem>(this as BudgetItem, _$identity);

  /// Serializes this BudgetItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.budgetedAmount, budgetedAmount) || other.budgetedAmount == budgetedAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,category,budgetedAmount,paidAmount,vendorId,notes);

@override
String toString() {
  return 'BudgetItem(id: $id, title: $title, category: $category, budgetedAmount: $budgetedAmount, paidAmount: $paidAmount, vendorId: $vendorId, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $BudgetItemCopyWith<$Res>  {
  factory $BudgetItemCopyWith(BudgetItem value, $Res Function(BudgetItem) _then) = _$BudgetItemCopyWithImpl;
@useResult
$Res call({
 String id, String title, String category, double budgetedAmount, double paidAmount, String? vendorId, String? notes
});




}
/// @nodoc
class _$BudgetItemCopyWithImpl<$Res>
    implements $BudgetItemCopyWith<$Res> {
  _$BudgetItemCopyWithImpl(this._self, this._then);

  final BudgetItem _self;
  final $Res Function(BudgetItem) _then;

/// Create a copy of BudgetItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? category = null,Object? budgetedAmount = null,Object? paidAmount = null,Object? vendorId = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,budgetedAmount: null == budgetedAmount ? _self.budgetedAmount : budgetedAmount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,vendorId: freezed == vendorId ? _self.vendorId : vendorId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetItem].
extension BudgetItemPatterns on BudgetItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetItem value)  $default,){
final _that = this;
switch (_that) {
case _BudgetItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetItem value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String category,  double budgetedAmount,  double paidAmount,  String? vendorId,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetItem() when $default != null:
return $default(_that.id,_that.title,_that.category,_that.budgetedAmount,_that.paidAmount,_that.vendorId,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String category,  double budgetedAmount,  double paidAmount,  String? vendorId,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _BudgetItem():
return $default(_that.id,_that.title,_that.category,_that.budgetedAmount,_that.paidAmount,_that.vendorId,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String category,  double budgetedAmount,  double paidAmount,  String? vendorId,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _BudgetItem() when $default != null:
return $default(_that.id,_that.title,_that.category,_that.budgetedAmount,_that.paidAmount,_that.vendorId,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetItem implements BudgetItem {
  const _BudgetItem({required this.id, required this.title, required this.category, this.budgetedAmount = 0.0, this.paidAmount = 0.0, this.vendorId, this.notes});
  factory _BudgetItem.fromJson(Map<String, dynamic> json) => _$BudgetItemFromJson(json);

@override final  String id;
@override final  String title;
@override final  String category;
@override@JsonKey() final  double budgetedAmount;
@override@JsonKey() final  double paidAmount;
@override final  String? vendorId;
@override final  String? notes;

/// Create a copy of BudgetItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetItemCopyWith<_BudgetItem> get copyWith => __$BudgetItemCopyWithImpl<_BudgetItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.budgetedAmount, budgetedAmount) || other.budgetedAmount == budgetedAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.vendorId, vendorId) || other.vendorId == vendorId)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,category,budgetedAmount,paidAmount,vendorId,notes);

@override
String toString() {
  return 'BudgetItem(id: $id, title: $title, category: $category, budgetedAmount: $budgetedAmount, paidAmount: $paidAmount, vendorId: $vendorId, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$BudgetItemCopyWith<$Res> implements $BudgetItemCopyWith<$Res> {
  factory _$BudgetItemCopyWith(_BudgetItem value, $Res Function(_BudgetItem) _then) = __$BudgetItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String category, double budgetedAmount, double paidAmount, String? vendorId, String? notes
});




}
/// @nodoc
class __$BudgetItemCopyWithImpl<$Res>
    implements _$BudgetItemCopyWith<$Res> {
  __$BudgetItemCopyWithImpl(this._self, this._then);

  final _BudgetItem _self;
  final $Res Function(_BudgetItem) _then;

/// Create a copy of BudgetItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? category = null,Object? budgetedAmount = null,Object? paidAmount = null,Object? vendorId = freezed,Object? notes = freezed,}) {
  return _then(_BudgetItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,budgetedAmount: null == budgetedAmount ? _self.budgetedAmount : budgetedAmount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,vendorId: freezed == vendorId ? _self.vendorId : vendorId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PlanData {

 List<PlanTask> get tasks; List<Vendor> get vendors; List<BudgetItem> get budgetItems; List<TimelineEvent> get timeline; double get totalBudget; String get currency;
/// Create a copy of PlanData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanDataCopyWith<PlanData> get copyWith => _$PlanDataCopyWithImpl<PlanData>(this as PlanData, _$identity);

  /// Serializes this PlanData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanData&&const DeepCollectionEquality().equals(other.tasks, tasks)&&const DeepCollectionEquality().equals(other.vendors, vendors)&&const DeepCollectionEquality().equals(other.budgetItems, budgetItems)&&const DeepCollectionEquality().equals(other.timeline, timeline)&&(identical(other.totalBudget, totalBudget) || other.totalBudget == totalBudget)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tasks),const DeepCollectionEquality().hash(vendors),const DeepCollectionEquality().hash(budgetItems),const DeepCollectionEquality().hash(timeline),totalBudget,currency);

@override
String toString() {
  return 'PlanData(tasks: $tasks, vendors: $vendors, budgetItems: $budgetItems, timeline: $timeline, totalBudget: $totalBudget, currency: $currency)';
}


}

/// @nodoc
abstract mixin class $PlanDataCopyWith<$Res>  {
  factory $PlanDataCopyWith(PlanData value, $Res Function(PlanData) _then) = _$PlanDataCopyWithImpl;
@useResult
$Res call({
 List<PlanTask> tasks, List<Vendor> vendors, List<BudgetItem> budgetItems, List<TimelineEvent> timeline, double totalBudget, String currency
});




}
/// @nodoc
class _$PlanDataCopyWithImpl<$Res>
    implements $PlanDataCopyWith<$Res> {
  _$PlanDataCopyWithImpl(this._self, this._then);

  final PlanData _self;
  final $Res Function(PlanData) _then;

/// Create a copy of PlanData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tasks = null,Object? vendors = null,Object? budgetItems = null,Object? timeline = null,Object? totalBudget = null,Object? currency = null,}) {
  return _then(_self.copyWith(
tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<PlanTask>,vendors: null == vendors ? _self.vendors : vendors // ignore: cast_nullable_to_non_nullable
as List<Vendor>,budgetItems: null == budgetItems ? _self.budgetItems : budgetItems // ignore: cast_nullable_to_non_nullable
as List<BudgetItem>,timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<TimelineEvent>,totalBudget: null == totalBudget ? _self.totalBudget : totalBudget // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanData].
extension PlanDataPatterns on PlanData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanData value)  $default,){
final _that = this;
switch (_that) {
case _PlanData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanData value)?  $default,){
final _that = this;
switch (_that) {
case _PlanData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PlanTask> tasks,  List<Vendor> vendors,  List<BudgetItem> budgetItems,  List<TimelineEvent> timeline,  double totalBudget,  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanData() when $default != null:
return $default(_that.tasks,_that.vendors,_that.budgetItems,_that.timeline,_that.totalBudget,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PlanTask> tasks,  List<Vendor> vendors,  List<BudgetItem> budgetItems,  List<TimelineEvent> timeline,  double totalBudget,  String currency)  $default,) {final _that = this;
switch (_that) {
case _PlanData():
return $default(_that.tasks,_that.vendors,_that.budgetItems,_that.timeline,_that.totalBudget,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PlanTask> tasks,  List<Vendor> vendors,  List<BudgetItem> budgetItems,  List<TimelineEvent> timeline,  double totalBudget,  String currency)?  $default,) {final _that = this;
switch (_that) {
case _PlanData() when $default != null:
return $default(_that.tasks,_that.vendors,_that.budgetItems,_that.timeline,_that.totalBudget,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlanData implements PlanData {
  const _PlanData({required final  List<PlanTask> tasks, required final  List<Vendor> vendors, required final  List<BudgetItem> budgetItems, required final  List<TimelineEvent> timeline, this.totalBudget = 45000.0, this.currency = 'USD'}): _tasks = tasks,_vendors = vendors,_budgetItems = budgetItems,_timeline = timeline;
  factory _PlanData.fromJson(Map<String, dynamic> json) => _$PlanDataFromJson(json);

 final  List<PlanTask> _tasks;
@override List<PlanTask> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}

 final  List<Vendor> _vendors;
@override List<Vendor> get vendors {
  if (_vendors is EqualUnmodifiableListView) return _vendors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vendors);
}

 final  List<BudgetItem> _budgetItems;
@override List<BudgetItem> get budgetItems {
  if (_budgetItems is EqualUnmodifiableListView) return _budgetItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_budgetItems);
}

 final  List<TimelineEvent> _timeline;
@override List<TimelineEvent> get timeline {
  if (_timeline is EqualUnmodifiableListView) return _timeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeline);
}

@override@JsonKey() final  double totalBudget;
@override@JsonKey() final  String currency;

/// Create a copy of PlanData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanDataCopyWith<_PlanData> get copyWith => __$PlanDataCopyWithImpl<_PlanData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanData&&const DeepCollectionEquality().equals(other._tasks, _tasks)&&const DeepCollectionEquality().equals(other._vendors, _vendors)&&const DeepCollectionEquality().equals(other._budgetItems, _budgetItems)&&const DeepCollectionEquality().equals(other._timeline, _timeline)&&(identical(other.totalBudget, totalBudget) || other.totalBudget == totalBudget)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tasks),const DeepCollectionEquality().hash(_vendors),const DeepCollectionEquality().hash(_budgetItems),const DeepCollectionEquality().hash(_timeline),totalBudget,currency);

@override
String toString() {
  return 'PlanData(tasks: $tasks, vendors: $vendors, budgetItems: $budgetItems, timeline: $timeline, totalBudget: $totalBudget, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$PlanDataCopyWith<$Res> implements $PlanDataCopyWith<$Res> {
  factory _$PlanDataCopyWith(_PlanData value, $Res Function(_PlanData) _then) = __$PlanDataCopyWithImpl;
@override @useResult
$Res call({
 List<PlanTask> tasks, List<Vendor> vendors, List<BudgetItem> budgetItems, List<TimelineEvent> timeline, double totalBudget, String currency
});




}
/// @nodoc
class __$PlanDataCopyWithImpl<$Res>
    implements _$PlanDataCopyWith<$Res> {
  __$PlanDataCopyWithImpl(this._self, this._then);

  final _PlanData _self;
  final $Res Function(_PlanData) _then;

/// Create a copy of PlanData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tasks = null,Object? vendors = null,Object? budgetItems = null,Object? timeline = null,Object? totalBudget = null,Object? currency = null,}) {
  return _then(_PlanData(
tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<PlanTask>,vendors: null == vendors ? _self._vendors : vendors // ignore: cast_nullable_to_non_nullable
as List<Vendor>,budgetItems: null == budgetItems ? _self._budgetItems : budgetItems // ignore: cast_nullable_to_non_nullable
as List<BudgetItem>,timeline: null == timeline ? _self._timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<TimelineEvent>,totalBudget: null == totalBudget ? _self.totalBudget : totalBudget // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
