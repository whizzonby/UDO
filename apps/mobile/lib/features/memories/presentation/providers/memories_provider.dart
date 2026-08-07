import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_client.dart';

class MemoriesState {
  final bool isLoading;
  final List<Map<String, dynamic>> speeches;
  final List<Map<String, dynamic>> vows;
  final List<Map<String, dynamic>> traditions;
  final Map<String, dynamic>? guestbook;
  final Map<String, dynamic>? photoBooth;
  final Map<String, dynamic>? music;
  final String? error;

  const MemoriesState({
    this.isLoading = false,
    this.speeches = const [],
    this.vows = const [],
    this.traditions = const [],
    this.guestbook,
    this.photoBooth,
    this.music,
    this.error,
  });

  List<Map<String, dynamic>> get guestbookEntries {
    final raw = guestbook?['entries'];
    return raw is List ? raw.cast<Map<String, dynamic>>() : const [];
  }

  MemoriesState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? speeches,
    List<Map<String, dynamic>>? vows,
    List<Map<String, dynamic>>? traditions,
    Map<String, dynamic>? guestbook,
    Map<String, dynamic>? photoBooth,
    Map<String, dynamic>? music,
    String? error,
  }) =>
      MemoriesState(
        isLoading: isLoading ?? this.isLoading,
        speeches: speeches ?? this.speeches,
        vows: vows ?? this.vows,
        traditions: traditions ?? this.traditions,
        guestbook: guestbook ?? this.guestbook,
        photoBooth: photoBooth ?? this.photoBooth,
        music: music ?? this.music,
        error: error,
      );
}

List<Map<String, dynamic>> _extractList(dynamic res) {
  if (res is Map && res['data'] is List) return (res['data'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  return [];
}

Map<String, dynamic>? _extractItem(dynamic res) {
  if (res is Map && res['data'] is Map) return Map<String, dynamic>.from(res['data'] as Map);
  return null;
}

class MemoriesNotifier extends StateNotifier<MemoriesState> {
  final ApiClient _api;
  MemoriesNotifier(this._api) : super(const MemoriesState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _api.get('/plan/memories/speeches'),
        _api.get('/plan/memories/vows'),
        _api.get('/plan/memories/traditions'),
        _api.get('/plan/memories/guestbook'),
        _api.get('/plan/memories/photo-booth'),
        _api.get('/plan/memories/music'),
      ]);
      state = state.copyWith(
        isLoading: false,
        speeches: _extractList(results[0]),
        vows: _extractList(results[1]),
        traditions: _extractList(results[2]),
        guestbook: _extractItem(results[3]),
        photoBooth: _extractItem(results[4]),
        music: _extractItem(results[5]),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _load();

  // ── SPEECHES ─────────────────────────────────────────────────────────────

  Future<bool> addSpeech(Map<String, dynamic> data, {XFile? file}) async {
    try {
      final res = file != null
          ? await _api.post('/plan/memories/speeches', data: await _withFile(data, file))
          : await _api.post('/plan/memories/speeches', data: data);
      final created = _extractItem(res);
      if (created != null) state = state.copyWith(speeches: [...state.speeches, created]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateSpeech(int id, Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/plan/memories/speeches/$id', data: data);
      final updated = _extractItem(res);
      if (updated != null) state = state.copyWith(speeches: state.speeches.map((s) => s['id'] == id ? updated : s).toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteSpeech(int id) async {
    try {
      await _api.delete('/plan/memories/speeches/$id');
      state = state.copyWith(speeches: state.speeches.where((s) => s['id'] != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── VOWS ─────────────────────────────────────────────────────────────────

  Future<bool> addVow(Map<String, dynamic> data, {XFile? file}) async {
    try {
      final res = file != null
          ? await _api.post('/plan/memories/vows', data: await _withFile(data, file))
          : await _api.post('/plan/memories/vows', data: data);
      final created = _extractItem(res);
      if (created != null) state = state.copyWith(vows: [...state.vows, created]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateVow(int id, Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/plan/memories/vows/$id', data: data);
      final updated = _extractItem(res);
      if (updated != null) state = state.copyWith(vows: state.vows.map((v) => v['id'] == id ? updated : v).toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteVow(int id) async {
    try {
      await _api.delete('/plan/memories/vows/$id');
      state = state.copyWith(vows: state.vows.where((v) => v['id'] != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Fire-and-forget — backs the "you've never revisited your vows" Smart
  /// Alert, which should clear once the couple actually opens one.
  Future<void> markVowViewed(int id) async {
    final matches = state.vows.where((v) => v['id'] == id);
    if (matches.isNotEmpty && matches.first['viewed_at'] != null) return;
    try {
      final res = await _api.post('/plan/memories/vows/$id/mark-viewed');
      final updated = _extractItem(res);
      if (updated != null) state = state.copyWith(vows: state.vows.map((v) => v['id'] == id ? updated : v).toList());
    } catch (_) {
      // Best-effort — not viewing-critical.
    }
  }

  // ── TRADITIONS ───────────────────────────────────────────────────────────

  Future<bool> addTradition(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/plan/memories/traditions', data: data);
      final created = _extractItem(res);
      if (created != null) state = state.copyWith(traditions: [...state.traditions, created]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateTradition(int id, Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/plan/memories/traditions/$id', data: data);
      final updated = _extractItem(res);
      if (updated != null) state = state.copyWith(traditions: state.traditions.map((t) => t['id'] == id ? updated : t).toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTradition(int id) async {
    try {
      await _api.delete('/plan/memories/traditions/$id');
      state = state.copyWith(traditions: state.traditions.where((t) => t['id'] != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── GUESTBOOK ────────────────────────────────────────────────────────────

  Future<bool> updateGuestbook(Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/plan/memories/guestbook', data: data);
      final updated = _extractItem(res);
      if (updated != null) state = state.copyWith(guestbook: updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> moderateGuestbookEntry(int id, bool approved) async {
    try {
      await _api.patch('/plan/memories/guestbook/entries/$id', data: {'approved': approved});
      final entries = state.guestbookEntries.map((e) => e['id'] == id ? {...e, 'approved': approved} : e).toList();
      state = state.copyWith(guestbook: {...state.guestbook ?? {}, 'entries': entries});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteGuestbookEntry(int id) async {
    try {
      await _api.delete('/plan/memories/guestbook/entries/$id');
      final entries = state.guestbookEntries.where((e) => e['id'] != id).toList();
      state = state.copyWith(guestbook: {...state.guestbook ?? {}, 'entries': entries});
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── PHOTO BOOTH ──────────────────────────────────────────────────────────

  Future<bool> updatePhotoBooth(Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/plan/memories/photo-booth', data: data);
      final updated = _extractItem(res);
      if (updated != null) state = state.copyWith(photoBooth: updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── MUSIC ────────────────────────────────────────────────────────────────

  Future<bool> updateMusic(Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/plan/memories/music', data: data);
      final updated = _extractItem(res);
      if (updated != null) state = state.copyWith(music: updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<FormData> _withFile(Map<String, dynamic> data, XFile file) async {
    final bytes = await file.readAsBytes();
    return FormData.fromMap({
      ...data,
      'file': MultipartFile.fromBytes(bytes, filename: file.name),
    });
  }
}

final memoriesProvider = StateNotifierProvider<MemoriesNotifier, MemoriesState>((ref) {
  return MemoriesNotifier(ref.read(apiClientProvider));
});
