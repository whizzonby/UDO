// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GalleryItem _$GalleryItemFromJson(Map<String, dynamic> json) => _GalleryItem(
  id: json['id'] as String,
  type: json['type'] as String? ?? 'inspiration',
  title: json['title'] as String?,
  caption: json['caption'] as String?,
  imageUrl: json['imageUrl'] as String,
  category: json['category'] as String?,
  isFeatured: json['isFeatured'] as bool? ?? false,
  sourceUrl: json['sourceUrl'] as String?,
  uploadedBy: json['uploadedBy'] as String?,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$GalleryItemToJson(_GalleryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'caption': instance.caption,
      'imageUrl': instance.imageUrl,
      'category': instance.category,
      'isFeatured': instance.isFeatured,
      'sourceUrl': instance.sourceUrl,
      'uploadedBy': instance.uploadedBy,
      'sortOrder': instance.sortOrder,
      'createdAt': instance.createdAt,
    };

_GallerySummary _$GallerySummaryFromJson(Map<String, dynamic> json) =>
    _GallerySummary(
      total: (json['total'] as num?)?.toInt() ?? 0,
      inspiration: (json['inspiration'] as num?)?.toInt() ?? 0,
      memories: (json['memories'] as num?)?.toInt() ?? 0,
      featured: (json['featured'] as num?)?.toInt() ?? 0,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$GallerySummaryToJson(_GallerySummary instance) =>
    <String, dynamic>{
      'total': instance.total,
      'inspiration': instance.inspiration,
      'memories': instance.memories,
      'featured': instance.featured,
      'categories': instance.categories,
    };
