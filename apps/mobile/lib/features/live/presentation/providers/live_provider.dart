import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class LiveState {
  final bool isLoading;
  final List<Map<String, dynamic>> updates;
  final List<Map<String, dynamic>> timeline;
  final String? error;

  const LiveState({
    this.isLoading = false,
    this.updates = const [],
    this.timeline = const [],
    this.error,
  });

  LiveState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? updates,
    List<Map<String, dynamic>>? timeline,
    String? error,
  }) =>
      LiveState(
        isLoading: isLoading ?? this.isLoading,
        updates: updates ?? this.updates,
        timeline: timeline ?? this.timeline,
        error: error ?? this.error,
      );
}

class LiveNotifier extends StateNotifier<LiveState> {
  final ApiClient _api;
  LiveNotifier(this._api) : super(const LiveState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.get('/live') as Map<String, dynamic>;
      final updates = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      state = state.copyWith(isLoading: false, updates: updates);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    try {
      final res = await _api.get('/plan/timeline') as Map<String, dynamic>;
      final items = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      items.sort((a, b) => (a['start_time'] ?? '').compareTo(b['start_time'] ?? ''));
      state = state.copyWith(timeline: items);
    } catch (_) {}
  }

  Future<void> post({required String title, String? body, bool pinned = false}) async {
    try {
      final res = await _api.post('/live', data: {
        'title': title,
        if (body != null) 'body': body,
        'pinned': pinned,
      }) as Map<String, dynamic>;
      final newUpdate = res['data'] as Map<String, dynamic>;
      state = state.copyWith(updates: [newUpdate, ...state.updates]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() => _load();
}

final liveProvider = StateNotifierProvider<LiveNotifier, LiveState>((ref) {
  return LiveNotifier(ref.read(apiClientProvider));
});
