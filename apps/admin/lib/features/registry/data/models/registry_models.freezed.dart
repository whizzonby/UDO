// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registry_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RegistryItem {

 String get id; String get title; String? get description; double? get price; String? get url; String? get imageUrl; String? get category; bool get isClaimed; String? get claimedByName; bool get thankYouSent; int get sortOrder;
/// Create a copy of RegistryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistryItemCopyWith<RegistryItem> get copyWith => _$RegistryItemCopyWithImpl<RegistryItem>(this as RegistryItem, _$identity);

  /// Serializes this RegistryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.url, url) || other.url == url)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.isClaimed, isClaimed) || other.isClaimed == isClaimed)&&(identical(other.claimedByName, claimedByName) || other.claimedByName == claimedByName)&&(identical(other.thankYouSent, thankYouSent) || other.thankYouSent == thankYouSent)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,price,url,imageUrl,category,isClaimed,claimedByName,thankYouSent,sortOrder);

@override
String toString() {
  return 'RegistryItem(id: $id, title: $title, description: $description, price: $price, url: $url, imageUrl: $imageUrl, category: $category, isClaimed: $isClaimed, claimedByName: $claimedByName, thankYouSent: $thankYouSent, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $RegistryItemCopyWith<$Res>  {
  factory $RegistryItemCopyWith(RegistryItem value, $Res Function(RegistryItem) _then) = _$RegistryItemCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, double? price, String? url, String? imageUrl, String? category, bool isClaimed, String? claimedByName, bool thankYouSent, int sortOrder
});




}
/// @nodoc
class _$RegistryItemCopyWithImpl<$Res>
    implements $RegistryItemCopyWith<$Res> {
  _$RegistryItemCopyWithImpl(this._self, this._then);

  final RegistryItem _self;
  final $Res Function(RegistryItem) _then;

/// Create a copy of RegistryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? price = freezed,Object? url = freezed,Object? imageUrl = freezed,Object? category = freezed,Object? isClaimed = null,Object? claimedByName = freezed,Object? thankYouSent = null,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,isClaimed: null == isClaimed ? _self.isClaimed : isClaimed // ignore: cast_nullable_to_non_nullable
as bool,claimedByName: freezed == claimedByName ? _self.claimedByName : claimedByName // ignore: cast_nullable_to_non_nullable
as String?,thankYouSent: null == thankYouSent ? _self.thankYouSent : thankYouSent // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RegistryItem].
extension RegistryItemPatterns on RegistryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegistryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegistryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegistryItem value)  $default,){
final _that = this;
switch (_that) {
case _RegistryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegistryItem value)?  $default,){
final _that = this;
switch (_that) {
case _RegistryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  double? price,  String? url,  String? imageUrl,  String? category,  bool isClaimed,  String? claimedByName,  bool thankYouSent,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegistryItem() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.price,_that.url,_that.imageUrl,_that.category,_that.isClaimed,_that.claimedByName,_that.thankYouSent,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  double? price,  String? url,  String? imageUrl,  String? category,  bool isClaimed,  String? claimedByName,  bool thankYouSent,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _RegistryItem():
return $default(_that.id,_that.title,_that.description,_that.price,_that.url,_that.imageUrl,_that.category,_that.isClaimed,_that.claimedByName,_that.thankYouSent,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  double? price,  String? url,  String? imageUrl,  String? category,  bool isClaimed,  String? claimedByName,  bool thankYouSent,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _RegistryItem() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.price,_that.url,_that.imageUrl,_that.category,_that.isClaimed,_that.claimedByName,_that.thankYouSent,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegistryItem implements RegistryItem {
  const _RegistryItem({required this.id, required this.title, this.description, this.price, this.url, this.imageUrl, this.category, this.isClaimed = false, this.claimedByName, this.thankYouSent = false, this.sortOrder = 0});
  factory _RegistryItem.fromJson(Map<String, dynamic> json) => _$RegistryItemFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  double? price;
@override final  String? url;
@override final  String? imageUrl;
@override final  String? category;
@override@JsonKey() final  bool isClaimed;
@override final  String? claimedByName;
@override@JsonKey() final  bool thankYouSent;
@override@JsonKey() final  int sortOrder;

/// Create a copy of RegistryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegistryItemCopyWith<_RegistryItem> get copyWith => __$RegistryItemCopyWithImpl<_RegistryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegistryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegistryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.url, url) || other.url == url)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.isClaimed, isClaimed) || other.isClaimed == isClaimed)&&(identical(other.claimedByName, claimedByName) || other.claimedByName == claimedByName)&&(identical(other.thankYouSent, thankYouSent) || other.thankYouSent == thankYouSent)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,price,url,imageUrl,category,isClaimed,claimedByName,thankYouSent,sortOrder);

@override
String toString() {
  return 'RegistryItem(id: $id, title: $title, description: $description, price: $price, url: $url, imageUrl: $imageUrl, category: $category, isClaimed: $isClaimed, claimedByName: $claimedByName, thankYouSent: $thankYouSent, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$RegistryItemCopyWith<$Res> implements $RegistryItemCopyWith<$Res> {
  factory _$RegistryItemCopyWith(_RegistryItem value, $Res Function(_RegistryItem) _then) = __$RegistryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, double? price, String? url, String? imageUrl, String? category, bool isClaimed, String? claimedByName, bool thankYouSent, int sortOrder
});




}
/// @nodoc
class __$RegistryItemCopyWithImpl<$Res>
    implements _$RegistryItemCopyWith<$Res> {
  __$RegistryItemCopyWithImpl(this._self, this._then);

  final _RegistryItem _self;
  final $Res Function(_RegistryItem) _then;

/// Create a copy of RegistryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? price = freezed,Object? url = freezed,Object? imageUrl = freezed,Object? category = freezed,Object? isClaimed = null,Object? claimedByName = freezed,Object? thankYouSent = null,Object? sortOrder = null,}) {
  return _then(_RegistryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,isClaimed: null == isClaimed ? _self.isClaimed : isClaimed // ignore: cast_nullable_to_non_nullable
as bool,claimedByName: freezed == claimedByName ? _self.claimedByName : claimedByName // ignore: cast_nullable_to_non_nullable
as String?,thankYouSent: null == thankYouSent ? _self.thankYouSent : thankYouSent // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RegistryCashFund {

 String get id; String get title; String? get description; double? get targetAmount; bool get isActive; String? get shareToken;
/// Create a copy of RegistryCashFund
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistryCashFundCopyWith<RegistryCashFund> get copyWith => _$RegistryCashFundCopyWithImpl<RegistryCashFund>(this as RegistryCashFund, _$identity);

  /// Serializes this RegistryCashFund to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistryCashFund&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.shareToken, shareToken) || other.shareToken == shareToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,targetAmount,isActive,shareToken);

@override
String toString() {
  return 'RegistryCashFund(id: $id, title: $title, description: $description, targetAmount: $targetAmount, isActive: $isActive, shareToken: $shareToken)';
}


}

/// @nodoc
abstract mixin class $RegistryCashFundCopyWith<$Res>  {
  factory $RegistryCashFundCopyWith(RegistryCashFund value, $Res Function(RegistryCashFund) _then) = _$RegistryCashFundCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, double? targetAmount, bool isActive, String? shareToken
});




}
/// @nodoc
class _$RegistryCashFundCopyWithImpl<$Res>
    implements $RegistryCashFundCopyWith<$Res> {
  _$RegistryCashFundCopyWithImpl(this._self, this._then);

  final RegistryCashFund _self;
  final $Res Function(RegistryCashFund) _then;

/// Create a copy of RegistryCashFund
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? targetAmount = freezed,Object? isActive = null,Object? shareToken = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,targetAmount: freezed == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,shareToken: freezed == shareToken ? _self.shareToken : shareToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RegistryCashFund].
extension RegistryCashFundPatterns on RegistryCashFund {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegistryCashFund value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegistryCashFund() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegistryCashFund value)  $default,){
final _that = this;
switch (_that) {
case _RegistryCashFund():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegistryCashFund value)?  $default,){
final _that = this;
switch (_that) {
case _RegistryCashFund() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  double? targetAmount,  bool isActive,  String? shareToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegistryCashFund() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.targetAmount,_that.isActive,_that.shareToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  double? targetAmount,  bool isActive,  String? shareToken)  $default,) {final _that = this;
switch (_that) {
case _RegistryCashFund():
return $default(_that.id,_that.title,_that.description,_that.targetAmount,_that.isActive,_that.shareToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  double? targetAmount,  bool isActive,  String? shareToken)?  $default,) {final _that = this;
switch (_that) {
case _RegistryCashFund() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.targetAmount,_that.isActive,_that.shareToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegistryCashFund implements RegistryCashFund {
  const _RegistryCashFund({required this.id, this.title = 'Our Honeymoon Fund', this.description, this.targetAmount, this.isActive = false, this.shareToken});
  factory _RegistryCashFund.fromJson(Map<String, dynamic> json) => _$RegistryCashFundFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override final  String? description;
@override final  double? targetAmount;
@override@JsonKey() final  bool isActive;
@override final  String? shareToken;

/// Create a copy of RegistryCashFund
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegistryCashFundCopyWith<_RegistryCashFund> get copyWith => __$RegistryCashFundCopyWithImpl<_RegistryCashFund>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegistryCashFundToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegistryCashFund&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.shareToken, shareToken) || other.shareToken == shareToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,targetAmount,isActive,shareToken);

@override
String toString() {
  return 'RegistryCashFund(id: $id, title: $title, description: $description, targetAmount: $targetAmount, isActive: $isActive, shareToken: $shareToken)';
}


}

/// @nodoc
abstract mixin class _$RegistryCashFundCopyWith<$Res> implements $RegistryCashFundCopyWith<$Res> {
  factory _$RegistryCashFundCopyWith(_RegistryCashFund value, $Res Function(_RegistryCashFund) _then) = __$RegistryCashFundCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, double? targetAmount, bool isActive, String? shareToken
});




}
/// @nodoc
class __$RegistryCashFundCopyWithImpl<$Res>
    implements _$RegistryCashFundCopyWith<$Res> {
  __$RegistryCashFundCopyWithImpl(this._self, this._then);

  final _RegistryCashFund _self;
  final $Res Function(_RegistryCashFund) _then;

/// Create a copy of RegistryCashFund
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? targetAmount = freezed,Object? isActive = null,Object? shareToken = freezed,}) {
  return _then(_RegistryCashFund(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,targetAmount: freezed == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,shareToken: freezed == shareToken ? _self.shareToken : shareToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RegistrySummary {

 int get totalItems; int get claimed; int get unclaimed; int get thankYousPending; double get totalValue; double get claimedValue;
/// Create a copy of RegistrySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistrySummaryCopyWith<RegistrySummary> get copyWith => _$RegistrySummaryCopyWithImpl<RegistrySummary>(this as RegistrySummary, _$identity);

  /// Serializes this RegistrySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrySummary&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.claimed, claimed) || other.claimed == claimed)&&(identical(other.unclaimed, unclaimed) || other.unclaimed == unclaimed)&&(identical(other.thankYousPending, thankYousPending) || other.thankYousPending == thankYousPending)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue)&&(identical(other.claimedValue, claimedValue) || other.claimedValue == claimedValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalItems,claimed,unclaimed,thankYousPending,totalValue,claimedValue);

@override
String toString() {
  return 'RegistrySummary(totalItems: $totalItems, claimed: $claimed, unclaimed: $unclaimed, thankYousPending: $thankYousPending, totalValue: $totalValue, claimedValue: $claimedValue)';
}


}

/// @nodoc
abstract mixin class $RegistrySummaryCopyWith<$Res>  {
  factory $RegistrySummaryCopyWith(RegistrySummary value, $Res Function(RegistrySummary) _then) = _$RegistrySummaryCopyWithImpl;
@useResult
$Res call({
 int totalItems, int claimed, int unclaimed, int thankYousPending, double totalValue, double claimedValue
});




}
/// @nodoc
class _$RegistrySummaryCopyWithImpl<$Res>
    implements $RegistrySummaryCopyWith<$Res> {
  _$RegistrySummaryCopyWithImpl(this._self, this._then);

  final RegistrySummary _self;
  final $Res Function(RegistrySummary) _then;

/// Create a copy of RegistrySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalItems = null,Object? claimed = null,Object? unclaimed = null,Object? thankYousPending = null,Object? totalValue = null,Object? claimedValue = null,}) {
  return _then(_self.copyWith(
totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,claimed: null == claimed ? _self.claimed : claimed // ignore: cast_nullable_to_non_nullable
as int,unclaimed: null == unclaimed ? _self.unclaimed : unclaimed // ignore: cast_nullable_to_non_nullable
as int,thankYousPending: null == thankYousPending ? _self.thankYousPending : thankYousPending // ignore: cast_nullable_to_non_nullable
as int,totalValue: null == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as double,claimedValue: null == claimedValue ? _self.claimedValue : claimedValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RegistrySummary].
extension RegistrySummaryPatterns on RegistrySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegistrySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegistrySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegistrySummary value)  $default,){
final _that = this;
switch (_that) {
case _RegistrySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegistrySummary value)?  $default,){
final _that = this;
switch (_that) {
case _RegistrySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalItems,  int claimed,  int unclaimed,  int thankYousPending,  double totalValue,  double claimedValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegistrySummary() when $default != null:
return $default(_that.totalItems,_that.claimed,_that.unclaimed,_that.thankYousPending,_that.totalValue,_that.claimedValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalItems,  int claimed,  int unclaimed,  int thankYousPending,  double totalValue,  double claimedValue)  $default,) {final _that = this;
switch (_that) {
case _RegistrySummary():
return $default(_that.totalItems,_that.claimed,_that.unclaimed,_that.thankYousPending,_that.totalValue,_that.claimedValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalItems,  int claimed,  int unclaimed,  int thankYousPending,  double totalValue,  double claimedValue)?  $default,) {final _that = this;
switch (_that) {
case _RegistrySummary() when $default != null:
return $default(_that.totalItems,_that.claimed,_that.unclaimed,_that.thankYousPending,_that.totalValue,_that.claimedValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegistrySummary implements RegistrySummary {
  const _RegistrySummary({this.totalItems = 0, this.claimed = 0, this.unclaimed = 0, this.thankYousPending = 0, this.totalValue = 0.0, this.claimedValue = 0.0});
  factory _RegistrySummary.fromJson(Map<String, dynamic> json) => _$RegistrySummaryFromJson(json);

@override@JsonKey() final  int totalItems;
@override@JsonKey() final  int claimed;
@override@JsonKey() final  int unclaimed;
@override@JsonKey() final  int thankYousPending;
@override@JsonKey() final  double totalValue;
@override@JsonKey() final  double claimedValue;

/// Create a copy of RegistrySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegistrySummaryCopyWith<_RegistrySummary> get copyWith => __$RegistrySummaryCopyWithImpl<_RegistrySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegistrySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegistrySummary&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.claimed, claimed) || other.claimed == claimed)&&(identical(other.unclaimed, unclaimed) || other.unclaimed == unclaimed)&&(identical(other.thankYousPending, thankYousPending) || other.thankYousPending == thankYousPending)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue)&&(identical(other.claimedValue, claimedValue) || other.claimedValue == claimedValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalItems,claimed,unclaimed,thankYousPending,totalValue,claimedValue);

@override
String toString() {
  return 'RegistrySummary(totalItems: $totalItems, claimed: $claimed, unclaimed: $unclaimed, thankYousPending: $thankYousPending, totalValue: $totalValue, claimedValue: $claimedValue)';
}


}

/// @nodoc
abstract mixin class _$RegistrySummaryCopyWith<$Res> implements $RegistrySummaryCopyWith<$Res> {
  factory _$RegistrySummaryCopyWith(_RegistrySummary value, $Res Function(_RegistrySummary) _then) = __$RegistrySummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalItems, int claimed, int unclaimed, int thankYousPending, double totalValue, double claimedValue
});




}
/// @nodoc
class __$RegistrySummaryCopyWithImpl<$Res>
    implements _$RegistrySummaryCopyWith<$Res> {
  __$RegistrySummaryCopyWithImpl(this._self, this._then);

  final _RegistrySummary _self;
  final $Res Function(_RegistrySummary) _then;

/// Create a copy of RegistrySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalItems = null,Object? claimed = null,Object? unclaimed = null,Object? thankYousPending = null,Object? totalValue = null,Object? claimedValue = null,}) {
  return _then(_RegistrySummary(
totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,claimed: null == claimed ? _self.claimed : claimed // ignore: cast_nullable_to_non_nullable
as int,unclaimed: null == unclaimed ? _self.unclaimed : unclaimed // ignore: cast_nullable_to_non_nullable
as int,thankYousPending: null == thankYousPending ? _self.thankYousPending : thankYousPending // ignore: cast_nullable_to_non_nullable
as int,totalValue: null == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as double,claimedValue: null == claimedValue ? _self.claimedValue : claimedValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
