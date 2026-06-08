import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../models/gallery_models.dart';

part 'gallery_repository.g.dart';

@riverpod
GalleryRepository galleryRepository(Ref ref) =>
    ApiGalleryRepository(ref.watch(apiClientProvider));

typedef GalleryData = ({List<GalleryItem> items, GallerySummary summary});

abstract class GalleryRepository {
  Future<GalleryData> getAll({String? type, String? category});
  Future<GalleryItem> addItem(Map<String, dynamic> data);
  Future<GalleryItem> updateItem(String id, Map<String, dynamic> data);
  Future<void> deleteItem(String id);
  Future<GalleryItem> featureItem(String id);
  Future<void> reorder(List<String> ids);
}

class ApiGalleryRepository implements GalleryRepository {
  const ApiGalleryRepository(this._dio);
  final Dio _dio;

  @override
  Future<GalleryData> getAll({String? type, String? category}) async {
    final resp = await _dio.get('/gallery/', queryParameters: {
      if (type != null) 'type': type,
      if (category != null) 'category': category,
    });
    final body = resp.data as Map<String, dynamic>;
    return (
      items: (body['items'] as List)
          .map((j) => GalleryItem.fromJson(j as Map<String, dynamic>))
          .toList(),
      summary: GallerySummary.fromJson(
          body['summary'] as Map<String, dynamic>),
    );
  }

  @override
  Future<GalleryItem> addItem(Map<String, dynamic> data) async {
    final resp = await _dio.post('/gallery/', data: data);
    return GalleryItem.fromJson(resp.data as Map<String, dynamic>);
  }

  @override
  Future<GalleryItem> updateItem(String id, Map<String, dynamic> data) async {
    final resp = await _dio.put('/gallery/$id', data: data);
    return GalleryItem.fromJson(resp.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _dio.delete('/gallery/$id');
  }

  @override
  Future<GalleryItem> featureItem(String id) async {
    final resp = await _dio.patch('/gallery/$id/feature');
    return GalleryItem.fromJson(resp.data as Map<String, dynamic>);
  }

  @override
  Future<void> reorder(List<String> ids) async {
    await _dio.post('/gallery/reorder', data: {'ids': ids});
  }
}
