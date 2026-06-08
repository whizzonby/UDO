// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gallery_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GalleryItem {

 String get id; String get type; String? get title; String? get caption; String get imageUrl; String? get category; bool get isFeatured; String? get sourceUrl; String? get uploadedBy; int get sortOrder; String? get createdAt;
/// Create a copy of GalleryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GalleryItemCopyWith<GalleryItem> get copyWith => _$GalleryItemCopyWithImpl<GalleryItem>(this as GalleryItem, _$identity);

  /// Serializes this GalleryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GalleryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,caption,imageUrl,category,isFeatured,sourceUrl,uploadedBy,sortOrder,createdAt);

@override
String toString() {
  return 'GalleryItem(id: $id, type: $type, title: $title, caption: $caption, imageUrl: $imageUrl, category: $category, isFeatured: $isFeatured, sourceUrl: $sourceUrl, uploadedBy: $uploadedBy, sortOrder: $sortOrder, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GalleryItemCopyWith<$Res>  {
  factory $GalleryItemCopyWith(GalleryItem value, $Res Function(GalleryItem) _then) = _$GalleryItemCopyWithImpl;
@useResult
$Res call({
 String id, String type, String? title, String? caption, String imageUrl, String? category, bool isFeatured, String? sourceUrl, String? uploadedBy, int sortOrder, String? createdAt
});




}
/// @nodoc
class _$GalleryItemCopyWithImpl<$Res>
    implements $GalleryItemCopyWith<$Res> {
  _$GalleryItemCopyWithImpl(this._self, this._then);

  final GalleryItem _self;
  final $Res Function(GalleryItem) _then;

/// Create a copy of GalleryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? title = freezed,Object? caption = freezed,Object? imageUrl = null,Object? category = freezed,Object? isFeatured = null,Object? sourceUrl = freezed,Object? uploadedBy = freezed,Object? sortOrder = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,uploadedBy: freezed == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GalleryItem].
extension GalleryItemPatterns on GalleryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GalleryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GalleryItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GalleryItem value)  $default,){
final _that = this;
switch (_that) {
case _GalleryItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GalleryItem value)?  $default,){
final _that = this;
switch (_that) {
case _GalleryItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String? title,  String? caption,  String imageUrl,  String? category,  bool isFeatured,  String? sourceUrl,  String? uploadedBy,  int sortOrder,  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GalleryItem() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.caption,_that.imageUrl,_that.category,_that.isFeatured,_that.sourceUrl,_that.uploadedBy,_that.sortOrder,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String? title,  String? caption,  String imageUrl,  String? category,  bool isFeatured,  String? sourceUrl,  String? uploadedBy,  int sortOrder,  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _GalleryItem():
return $default(_that.id,_that.type,_that.title,_that.caption,_that.imageUrl,_that.category,_that.isFeatured,_that.sourceUrl,_that.uploadedBy,_that.sortOrder,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String? title,  String? caption,  String imageUrl,  String? category,  bool isFeatured,  String? sourceUrl,  String? uploadedBy,  int sortOrder,  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _GalleryItem() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.caption,_that.imageUrl,_that.category,_that.isFeatured,_that.sourceUrl,_that.uploadedBy,_that.sortOrder,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GalleryItem implements GalleryItem {
  const _GalleryItem({required this.id, this.type = 'inspiration', this.title, this.caption, required this.imageUrl, this.category, this.isFeatured = false, this.sourceUrl, this.uploadedBy, this.sortOrder = 0, this.createdAt});
  factory _GalleryItem.fromJson(Map<String, dynamic> json) => _$GalleryItemFromJson(json);

@override final  String id;
@override@JsonKey() final  String type;
@override final  String? title;
@override final  String? caption;
@override final  String imageUrl;
@override final  String? category;
@override@JsonKey() final  bool isFeatured;
@override final  String? sourceUrl;
@override final  String? uploadedBy;
@override@JsonKey() final  int sortOrder;
@override final  String? createdAt;

/// Create a copy of GalleryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GalleryItemCopyWith<_GalleryItem> get copyWith => __$GalleryItemCopyWithImpl<_GalleryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GalleryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GalleryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,title,caption,imageUrl,category,isFeatured,sourceUrl,uploadedBy,sortOrder,createdAt);

@override
String toString() {
  return 'GalleryItem(id: $id, type: $type, title: $title, caption: $caption, imageUrl: $imageUrl, category: $category, isFeatured: $isFeatured, sourceUrl: $sourceUrl, uploadedBy: $uploadedBy, sortOrder: $sortOrder, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GalleryItemCopyWith<$Res> implements $GalleryItemCopyWith<$Res> {
  factory _$GalleryItemCopyWith(_GalleryItem value, $Res Function(_GalleryItem) _then) = __$GalleryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String? title, String? caption, String imageUrl, String? category, bool isFeatured, String? sourceUrl, String? uploadedBy, int sortOrder, String? createdAt
});




}
/// @nodoc
class __$GalleryItemCopyWithImpl<$Res>
    implements _$GalleryItemCopyWith<$Res> {
  __$GalleryItemCopyWithImpl(this._self, this._then);

  final _GalleryItem _self;
  final $Res Function(_GalleryItem) _then;

/// Create a copy of GalleryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? title = freezed,Object? caption = freezed,Object? imageUrl = null,Object? category = freezed,Object? isFeatured = null,Object? sourceUrl = freezed,Object? uploadedBy = freezed,Object? sortOrder = null,Object? createdAt = freezed,}) {
  return _then(_GalleryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,uploadedBy: freezed == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$GallerySummary {

 int get total; int get inspiration; int get memories; int get featured; List<String> get categories;
/// Create a copy of GallerySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GallerySummaryCopyWith<GallerySummary> get copyWith => _$GallerySummaryCopyWithImpl<GallerySummary>(this as GallerySummary, _$identity);

  /// Serializes this GallerySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GallerySummary&&(identical(other.total, total) || other.total == total)&&(identical(other.inspiration, inspiration) || other.inspiration == inspiration)&&(identical(other.memories, memories) || other.memories == memories)&&(identical(other.featured, featured) || other.featured == featured)&&const DeepCollectionEquality().equals(other.categories, categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,inspiration,memories,featured,const DeepCollectionEquality().hash(categories));

@override
String toString() {
  return 'GallerySummary(total: $total, inspiration: $inspiration, memories: $memories, featured: $featured, categories: $categories)';
}


}

/// @nodoc
abstract mixin class $GallerySummaryCopyWith<$Res>  {
  factory $GallerySummaryCopyWith(GallerySummary value, $Res Function(GallerySummary) _then) = _$GallerySummaryCopyWithImpl;
@useResult
$Res call({
 int total, int inspiration, int memories, int featured, List<String> categories
});




}
/// @nodoc
class _$GallerySummaryCopyWithImpl<$Res>
    implements $GallerySummaryCopyWith<$Res> {
  _$GallerySummaryCopyWithImpl(this._self, this._then);

  final GallerySummary _self;
  final $Res Function(GallerySummary) _then;

/// Create a copy of GallerySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? inspiration = null,Object? memories = null,Object? featured = null,Object? categories = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,inspiration: null == inspiration ? _self.inspiration : inspiration // ignore: cast_nullable_to_non_nullable
as int,memories: null == memories ? _self.memories : memories // ignore: cast_nullable_to_non_nullable
as int,featured: null == featured ? _self.featured : featured // ignore: cast_nullable_to_non_nullable
as int,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [GallerySummary].
extension GallerySummaryPatterns on GallerySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GallerySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GallerySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GallerySummary value)  $default,){
final _that = this;
switch (_that) {
case _GallerySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GallerySummary value)?  $default,){
final _that = this;
switch (_that) {
case _GallerySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  int inspiration,  int memories,  int featured,  List<String> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GallerySummary() when $default != null:
return $default(_that.total,_that.inspiration,_that.memories,_that.featured,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  int inspiration,  int memories,  int featured,  List<String> categories)  $default,) {final _that = this;
switch (_that) {
case _GallerySummary():
return $default(_that.total,_that.inspiration,_that.memories,_that.featured,_that.categories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  int inspiration,  int memories,  int featured,  List<String> categories)?  $default,) {final _that = this;
switch (_that) {
case _GallerySummary() when $default != null:
return $default(_that.total,_that.inspiration,_that.memories,_that.featured,_that.categories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GallerySummary implements GallerySummary {
  const _GallerySummary({this.total = 0, this.inspiration = 0, this.memories = 0, this.featured = 0, final  List<String> categories = const []}): _categories = categories;
  factory _GallerySummary.fromJson(Map<String, dynamic> json) => _$GallerySummaryFromJson(json);

@override@JsonKey() final  int total;
@override@JsonKey() final  int inspiration;
@override@JsonKey() final  int memories;
@override@JsonKey() final  int featured;
 final  List<String> _categories;
@override@JsonKey() List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of GallerySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GallerySummaryCopyWith<_GallerySummary> get copyWith => __$GallerySummaryCopyWithImpl<_GallerySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GallerySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GallerySummary&&(identical(other.total, total) || other.total == total)&&(identical(other.inspiration, inspiration) || other.inspiration == inspiration)&&(identical(other.memories, memories) || other.memories == memories)&&(identical(other.featured, featured) || other.featured == featured)&&const DeepCollectionEquality().equals(other._categories, _categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,inspiration,memories,featured,const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'GallerySummary(total: $total, inspiration: $inspiration, memories: $memories, featured: $featured, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$GallerySummaryCopyWith<$Res> implements $GallerySummaryCopyWith<$Res> {
  factory _$GallerySummaryCopyWith(_GallerySummary value, $Res Function(_GallerySummary) _then) = __$GallerySummaryCopyWithImpl;
@override @useResult
$Res call({
 int total, int inspiration, int memories, int featured, List<String> categories
});




}
/// @nodoc
class __$GallerySummaryCopyWithImpl<$Res>
    implements _$GallerySummaryCopyWith<$Res> {
  __$GallerySummaryCopyWithImpl(this._self, this._then);

  final _GallerySummary _self;
  final $Res Function(_GallerySummary) _then;

/// Create a copy of GallerySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? inspiration = null,Object? memories = null,Object? featured = null,Object? categories = null,}) {
  return _then(_GallerySummary(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,inspiration: null == inspiration ? _self.inspiration : inspiration // ignore: cast_nullable_to_non_nullable
as int,memories: null == memories ? _self.memories : memories // ignore: cast_nullable_to_non_nullable
as int,featured: null == featured ? _self.featured : featured // ignore: cast_nullable_to_non_nullable
as int,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
