import 'package:freezed_annotation/freezed_annotation.dart';

part 'gallery_models.freezed.dart';
part 'gallery_models.g.dart';

@freezed
abstract class GalleryItem with _$GalleryItem {
  const factory GalleryItem({
    required String id,
    @Default('inspiration') String type,
    String? title,
    String? caption,
    required String imageUrl,
    String? category,
    @Default(false) bool isFeatured,
    String? sourceUrl,
    String? uploadedBy,
    @Default(0) int sortOrder,
    String? createdAt,
  }) = _GalleryItem;

  factory GalleryItem.fromJson(Map<String, dynamic> json) =>
      _$GalleryItemFromJson(json);
}

@freezed
abstract class GallerySummary with _$GallerySummary {
  const factory GallerySummary({
    @Default(0) int total,
    @Default(0) int inspiration,
    @Default(0) int memories,
    @Default(0) int featured,
    @Default([]) List<String> categories,
  }) = _GallerySummary;

  factory GallerySummary.fromJson(Map<String, dynamic> json) =>
      _$GallerySummaryFromJson(json);
}
