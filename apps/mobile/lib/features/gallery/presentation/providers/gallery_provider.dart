import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_client.dart';

class GalleryState {
  final bool isLoading;
  final List<Map<String, dynamic>> assets;
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> albums;
  final String? error;
  final String? uploadLinkUrl;
  final bool? pinterestConfigured;
  final bool pinterestConnected;
  final String? pinterestUsername;
  final bool isLoadingPinterest;
  final List<Map<String, dynamic>> pinterestBoards;

  const GalleryState({
    this.isLoading = false,
    this.assets = const [],
    this.summary = const {},
    this.albums = const [],
    this.error,
    this.uploadLinkUrl,
    this.pinterestConfigured,
    this.pinterestConnected = false,
    this.pinterestUsername,
    this.isLoadingPinterest = false,
    this.pinterestBoards = const [],
  });

  GalleryState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? assets,
    Map<String, dynamic>? summary,
    List<Map<String, dynamic>>? albums,
    String? error,
    String? uploadLinkUrl,
    bool? pinterestConfigured,
    bool? pinterestConnected,
    String? pinterestUsername,
    bool? isLoadingPinterest,
    List<Map<String, dynamic>>? pinterestBoards,
  }) =>
      GalleryState(
        isLoading: isLoading ?? this.isLoading,
        assets: assets ?? this.assets,
        summary: summary ?? this.summary,
        albums: albums ?? this.albums,
        error: error ?? this.error,
        uploadLinkUrl: uploadLinkUrl ?? this.uploadLinkUrl,
        pinterestConfigured: pinterestConfigured ?? this.pinterestConfigured,
        pinterestConnected: pinterestConnected ?? this.pinterestConnected,
        pinterestUsername: pinterestUsername ?? this.pinterestUsername,
        isLoadingPinterest: isLoadingPinterest ?? this.isLoadingPinterest,
        pinterestBoards: pinterestBoards ?? this.pinterestBoards,
      );
}

class GalleryNotifier extends StateNotifier<GalleryState> {
  final ApiClient _api;
  GalleryNotifier(this._api) : super(const GalleryState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final assetsRes = await _api.get('/gallery') as Map<String, dynamic>;
      final summaryRes =
          await _api.get('/gallery/summary') as Map<String, dynamic>;
      final assets =
          (assetsRes['data'] as List? ?? []).cast<Map<String, dynamic>>();
      final summary = summaryRes['data'] is Map
          ? Map<String, dynamic>.from(summaryRes['data'] as Map)
          : <String, dynamic>{};
      final albums = await _loadAlbums();
      state = state.copyWith(
          isLoading: false, assets: assets, summary: summary, albums: albums);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> approve(int id) async {
    try {
      await _api.patch('/gallery/$id', data: {'approved': true});
      state = state.copyWith(
          assets: state.assets
              .map((a) => a['id'] == id ? {...a, 'approved': true} : a)
              .toList());
      await refresh();
    } catch (_) {}
  }

  Future<void> reject(int id) async {
    try {
      await _api.post('/gallery/$id/reject', data: {});
      await refresh();
    } catch (_) {}
  }

  Future<void> archive(int id) async {
    try {
      await _api.post('/gallery/$id/archive', data: {});
      await refresh();
    } catch (_) {}
  }

  Future<void> toggleFeatured(int id) async {
    final current = state.assets.firstWhere((a) => a['id'] == id);
    final next = !(current['is_featured'] == true);
    try {
      await _api.post('/gallery/$id/feature', data: {'is_featured': next});
      state = state.copyWith(
          assets: state.assets
              .map((a) => a['id'] == id
                  ? {
                      ...a,
                      'is_featured': next,
                      'approved': next ? true : a['approved']
                    }
                  : a)
              .toList());
      await refresh();
    } catch (_) {}
  }

  Future<void> toggleSaved(int id) async {
    final current = state.assets.firstWhere((a) => a['id'] == id);
    final next = !(current['is_saved'] == true);
    try {
      await _api.patch('/gallery/$id', data: {'is_saved': next});
      state = state.copyWith(
          assets: state.assets
              .map((a) => a['id'] == id ? {...a, 'is_saved': next} : a)
              .toList());
      await refresh();
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> upload(XFile file, String album) async {
    try {
      final bytes = await file.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: file.name),
        'album': album,
      });
      final res =
          await _api.post('/gallery', data: formData) as Map<String, dynamic>;
      final asset = res['data'] as Map<String, dynamic>? ?? {};
      if (asset.isNotEmpty) {
        state = state.copyWith(assets: [...state.assets, asset]);
        await refresh();
      }
      return asset.isNotEmpty ? asset : null;
    } catch (_) {
      return null;
    }
  }

  /// Bulk-sets which approved photos/videos are shown on the guest link —
  /// mirrors LogisticsNotifier's updateTransportVisibility()/
  /// updateAccommodationVisibility(). Kept separate from approve()/reject()
  /// so curating the guest link never changes a photo's moderation status.
  Future<bool> updateVisibility(List<int> visibleIds) async {
    try {
      final res = await _api.patch('/gallery-visibility',
          data: {'visible_ids': visibleIds}) as Map<String, dynamic>;
      final updated =
          (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      state = state.copyWith(assets: updated, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> refresh() => _load();

  Future<List<Map<String, dynamic>>> _loadAlbums() async {
    try {
      final albumsRes =
          await _api.get('/gallery/albums') as Map<String, dynamic>;
      return (albumsRes['data'] as List? ?? []).cast<Map<String, dynamic>>();
    } catch (_) {
      return state.albums;
    }
  }

  Future<bool> createAlbum({
    required String name,
    String? description,
  }) async {
    try {
      final res = await _api.post('/gallery/albums', data: {
        'name': name,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      }) as Map<String, dynamic>;
      final album = res['data'] as Map<String, dynamic>? ?? {};
      if (album.isNotEmpty) {
        final next = [
          ...state.albums.where((a) => a['id'] != album['id']),
          album,
        ];
        state = state.copyWith(albums: next);
      }
      await refresh();
      return album.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchUploadLink() async {
    if (state.uploadLinkUrl != null) return;
    try {
      final res =
          await _api.get('/gallery/upload-link') as Map<String, dynamic>;
      final data = res['data'] as Map<String, dynamic>?;
      final url = data?['url'] as String?;
      if (url != null) state = state.copyWith(uploadLinkUrl: url);
    } catch (_) {}
  }

  Future<bool> setBoardName(int id, String? boardName) async {
    try {
      await _api.patch('/gallery/$id', data: {'board_name': boardName});
      state = state.copyWith(
          assets: state.assets
              .map((a) => a['id'] == id ? {...a, 'board_name': boardName} : a)
              .toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setCategory(int id, String? category) async {
    try {
      await _api.patch('/gallery/$id', data: {'category': category});
      state = state.copyWith(
          assets: state.assets
              .map((a) => a['id'] == id ? {...a, 'category': category} : a)
              .toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setJourneyStage(int id, String? stage) async {
    try {
      await _api.patch('/gallery/$id', data: {'journey_stage': stage});
      state = state.copyWith(
          assets: state.assets
              .map((a) => a['id'] == id ? {...a, 'journey_stage': stage} : a)
              .toList());
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── PINTEREST ────────────────────────────────────────────────────────────

  Future<void> fetchPinterestStatus() async {
    try {
      final res = await _api.get('/pinterest/status') as Map<String, dynamic>;
      final data = Map<String, dynamic>.from(res['data'] as Map);
      state = state.copyWith(
        pinterestConfigured: data['configured'] as bool? ?? false,
        pinterestConnected: data['connected'] as bool? ?? false,
        pinterestUsername: data['username'] as String?,
      );
    } catch (_) {
      // Best-effort — the card shows its default "unknown" state until this succeeds.
    }
  }

  /// Returns the real Pinterest authorize URL to open externally, or null if
  /// Pinterest isn't configured for this deployment (the honest fallback).
  Future<String?> connectPinterest() async {
    try {
      final res = await _api.get('/pinterest/connect') as Map<String, dynamic>;
      final data = Map<String, dynamic>.from(res['data'] as Map);
      return data['authorize_url'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchPinterestBoards() async {
    state = state.copyWith(isLoadingPinterest: true);
    try {
      final res = await _api.get('/pinterest/boards') as Map<String, dynamic>;
      final boards = (res['data'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      state =
          state.copyWith(isLoadingPinterest: false, pinterestBoards: boards);
    } catch (e) {
      state = state.copyWith(isLoadingPinterest: false, error: e.toString());
    }
  }

  Future<int> importPinterestBoard(String boardId) async {
    try {
      final res = await _api.post('/pinterest/boards/$boardId/import')
          as Map<String, dynamic>;
      final imported = (res['data'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      state = state.copyWith(assets: [...state.assets, ...imported]);
      return res['imported'] as int? ?? imported.length;
    } catch (_) {
      return 0;
    }
  }

  Future<void> disconnectPinterest() async {
    try {
      await _api.post('/pinterest/disconnect');
    } catch (_) {}
    state = GalleryState(
      isLoading: state.isLoading,
      assets: state.assets,
      summary: state.summary,
      albums: state.albums,
      uploadLinkUrl: state.uploadLinkUrl,
      pinterestConfigured: state.pinterestConfigured,
      pinterestConnected: false,
      pinterestUsername: null,
      pinterestBoards: const [],
    );
  }
}

final galleryProvider =
    StateNotifierProvider<GalleryNotifier, GalleryState>((ref) {
  return GalleryNotifier(ref.read(apiClientProvider));
});
