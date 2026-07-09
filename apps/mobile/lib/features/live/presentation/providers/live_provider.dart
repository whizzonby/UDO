import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class LiveState {
  final bool isLoading;
  final List<Map<String, dynamic>> updates;
  final List<Map<String, dynamic>> timeline;
  final Map<String, dynamic>? today;
  final Map<String, dynamic>? weather;
  final String? weatherMessage;
  final Map<String, dynamic>? venue;
  final String? updatesError;
  final String? timelineError;
  final String? todayError;

  const LiveState({
    this.isLoading = false,
    this.updates = const [],
    this.timeline = const [],
    this.today,
    this.weather,
    this.weatherMessage,
    this.venue,
    this.updatesError,
    this.timelineError,
    this.todayError,
  });

  LiveState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? updates,
    List<Map<String, dynamic>>? timeline,
    Map<String, dynamic>? today,
    Map<String, dynamic>? weather,
    String? weatherMessage,
    Map<String, dynamic>? venue,
    String? updatesError,
    String? timelineError,
    String? todayError,
  }) =>
      LiveState(
        isLoading: isLoading ?? this.isLoading,
        updates: updates ?? this.updates,
        timeline: timeline ?? this.timeline,
        today: today ?? this.today,
        weather: weather ?? this.weather,
        weatherMessage: weatherMessage,
        venue: venue ?? this.venue,
        updatesError: updatesError,
        timelineError: timelineError,
        todayError: todayError,
      );
}

class LiveNotifier extends StateNotifier<LiveState> {
  final ApiClient _api;
  LiveNotifier(this._api) : super(const LiveState(isLoading: true)) {
    load();
  }

  Future<({Map<String, dynamic>? data, String? error})> _fetchMap(String path) async {
    try {
      final res = await _api.get(path) as Map<String, dynamic>;
      return (data: res['data'] as Map<String, dynamic>?, error: null);
    } catch (e) {
      return (data: null, error: e.toString());
    }
  }

  Future<({List<Map<String, dynamic>> data, String? error})> _fetchList(String path) async {
    try {
      final res = await _api.get(path) as Map<String, dynamic>;
      final list = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      return (data: list, error: null);
    } catch (e) {
      return (data: <Map<String, dynamic>>[], error: e.toString());
    }
  }

  Future<void> load() async {
    final wasLoading = state.updates.isEmpty && state.today == null;
    if (wasLoading) state = state.copyWith(isLoading: true);

    final updatesFuture = _fetchList('/live');
    final timelineFuture = _fetchList('/plan/timeline');
    final todayFuture = _fetchMap('/live/today');
    final weatherFuture = _fetchWeather();
    final venueFuture = _fetchMap('/venue/location');

    final updates = await updatesFuture;
    final timeline = await timelineFuture;
    final today = await todayFuture;
    final weather = await weatherFuture;
    final venue = await venueFuture;

    timeline.data.sort((a, b) => (a['start_time'] ?? '').toString().compareTo((b['start_time'] ?? '').toString()));

    state = state.copyWith(
      isLoading: false,
      updates: updates.data,
      updatesError: updates.error,
      timeline: timeline.data,
      timelineError: timeline.error,
      today: today.data,
      todayError: today.error,
      weather: weather.data,
      weatherMessage: weather.message,
      venue: venue.data,
    );
  }

  Future<({Map<String, dynamic>? data, String? message})> _fetchWeather() async {
    try {
      final res = await _api.get('/weather') as Map<String, dynamic>;
      return (data: res['data'] as Map<String, dynamic>?, message: res['message'] as String?);
    } catch (e) {
      return (data: null, message: "Couldn't load weather.");
    }
  }

  Future<bool> post({required String title, String? body, bool pinned = false}) async {
    try {
      final res = await _api.post('/live', data: {
        'title': title,
        if (body != null && body.isNotEmpty) 'body': body,
        'pinned': pinned,
      }) as Map<String, dynamic>;
      final newUpdate = res['data'] as Map<String, dynamic>;
      state = state.copyWith(updates: [newUpdate, ...state.updates]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() => load();
}

final liveProvider = StateNotifierProvider<LiveNotifier, LiveState>((ref) {
  return LiveNotifier(ref.read(apiClientProvider));
});
