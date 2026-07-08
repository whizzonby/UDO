import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class GalleryState {
  final bool isLoading;
  final List<Map<String, dynamic>> assets;
  final String? error;

  const GalleryState({this.isLoading = false, this.assets = const [], this.error});

  GalleryState copyWith({bool? isLoading, List<Map<String, dynamic>>? assets, String? error}) =>
      GalleryState(isLoading: isLoading ?? this.isLoading, assets: assets ?? this.assets, error: error ?? this.error);
}

class GalleryNotifier extends StateNotifier<GalleryState> {
  final ApiClient _api;
  GalleryNotifier(this._api) : super(const GalleryState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.get('/gallery') as Map<String, dynamic>;
      final assets = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      state = state.copyWith(isLoading: false, assets: assets);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> approve(int id) async {
    try {
      await _api.patch('/gallery/$id', data: {'approved': true});
      state = state.copyWith(assets: state.assets.map((a) => a['id'] == id ? {...a, 'approved': true} : a).toList());
    } catch (_) {}
  }

  Future<bool> upload(File file, String album) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        'album': album,
      });
      final res = await _api.post('/gallery', data: formData) as Map<String, dynamic>;
      final asset = res['data'] as Map<String, dynamic>? ?? {};
      if (asset.isNotEmpty) {
        state = state.copyWith(assets: [...state.assets, asset]);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() => _load();
}

final galleryProvider = StateNotifierProvider<GalleryNotifier, GalleryState>((ref) {
  return GalleryNotifier(ref.read(apiClientProvider));
});
