import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class WeddingStoryState {
  final bool isLoading;
  final bool hasEventDate;
  final List<Map<String, dynamic>> phases;
  final Map<String, dynamic> memories;
  final String? error;

  const WeddingStoryState({
    this.isLoading = false,
    this.hasEventDate = false,
    this.phases = const [],
    this.memories = const {},
    this.error,
  });

  WeddingStoryState copyWith({
    bool? isLoading,
    bool? hasEventDate,
    List<Map<String, dynamic>>? phases,
    Map<String, dynamic>? memories,
    String? error,
  }) =>
      WeddingStoryState(
        isLoading: isLoading ?? this.isLoading,
        hasEventDate: hasEventDate ?? this.hasEventDate,
        phases: phases ?? this.phases,
        memories: memories ?? this.memories,
        error: error,
      );
}

class WeddingStoryNotifier extends StateNotifier<WeddingStoryState> {
  final ApiClient _api;
  WeddingStoryNotifier(this._api) : super(const WeddingStoryState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get('/wedding-story') as Map<String, dynamic>;
      final data = res['data'] as Map<String, dynamic>;
      state = state.copyWith(
        isLoading: false,
        hasEventDate: data['has_event_date'] == true,
        phases: (data['phases'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList(),
        memories: data['memories'] is Map ? Map<String, dynamic>.from(data['memories'] as Map) : {},
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _load();
}

final weddingStoryProvider = StateNotifierProvider<WeddingStoryNotifier, WeddingStoryState>((ref) {
  return WeddingStoryNotifier(ref.read(apiClientProvider));
});
