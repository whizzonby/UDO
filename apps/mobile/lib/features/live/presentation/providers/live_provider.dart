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
  final bool isOffline;
  final DateTime? cachedAt;

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
    this.isOffline = false,
    this.cachedAt,
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
    bool? isOffline,
    DateTime? cachedAt,
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
        isOffline: isOffline ?? this.isOffline,
        cachedAt: cachedAt ?? this.cachedAt,
      );
}

class LiveNotifier extends StateNotifier<LiveState> {
  final ApiClient _api;
  LiveNotifier(this._api) : super(const LiveState(isLoading: true)) {
    load();
  }

  Future<
      ({
        Map<String, dynamic>? data,
        String? error,
        bool fromCache,
        DateTime? cachedAt
      })> _fetchMap(String path) async {
    try {
      final cached = await _api.getCached(path);
      final res = cached.data as Map<String, dynamic>;
      return (
        data: res['data'] as Map<String, dynamic>?,
        error:
            cached.fromCache ? 'Showing saved data. Connect to refresh.' : null,
        fromCache: cached.fromCache,
        cachedAt: cached.cachedAt,
      );
    } catch (e) {
      return (
        data: null,
        error: e.toString(),
        fromCache: false,
        cachedAt: null
      );
    }
  }

  Future<
      ({
        List<Map<String, dynamic>> data,
        String? error,
        bool fromCache,
        DateTime? cachedAt
      })> _fetchList(String path) async {
    try {
      final cached = await _api.getCached(path);
      final res = cached.data as Map<String, dynamic>;
      final list = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      return (
        data: list,
        error:
            cached.fromCache ? 'Showing saved data. Connect to refresh.' : null,
        fromCache: cached.fromCache,
        cachedAt: cached.cachedAt,
      );
    } catch (e) {
      return (
        data: <Map<String, dynamic>>[],
        error: e.toString(),
        fromCache: false,
        cachedAt: null
      );
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

    timeline.data.sort((a, b) => (a['start_time'] ?? '')
        .toString()
        .compareTo((b['start_time'] ?? '').toString()));

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
      isOffline: updates.fromCache ||
          timeline.fromCache ||
          today.fromCache ||
          weather.fromCache ||
          venue.fromCache,
      cachedAt: updates.cachedAt ??
          timeline.cachedAt ??
          today.cachedAt ??
          weather.cachedAt ??
          venue.cachedAt,
    );
  }

  Future<
      ({
        Map<String, dynamic>? data,
        String? message,
        bool fromCache,
        DateTime? cachedAt
      })> _fetchWeather() async {
    try {
      final res = await _api.get('/weather') as Map<String, dynamic>;
      return (
        data: res['data'] as Map<String, dynamic>?,
        message: res['message'] as String?,
        fromCache: false,
        cachedAt: null,
      );
    } catch (e) {
      return (
        data: null,
        message: "Couldn't load weather.",
        fromCache: false,
        cachedAt: null
      );
    }
  }

  Future<bool> post({
    required String title,
    String? body,
    bool pinned = false,
    String type = 'announcement',
    String severity = 'info',
    String audience = 'all',
    List<String> deliveryChannels = const ['sms', 'whatsapp', 'email'],
    bool requiresAction = false,
  }) async {
    try {
      final res = await _api.post('/live', data: {
        'title': title,
        if (body != null && body.isNotEmpty) 'body': body,
        'pinned': pinned,
        'type': type,
        'severity': severity,
        'audience': audience,
        'delivery_channels': deliveryChannels,
        'requires_action': requiresAction,
      }) as Map<String, dynamic>;
      final newUpdate = res['data'] as Map<String, dynamic>;
      state = state.copyWith(updates: [newUpdate, ...state.updates]);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Bulk-sets which live updates are shown on the guest link — mirrors
  /// LogisticsNotifier's updateTransportVisibility()/
  /// updateAccommodationVisibility() for the "Live Updates" guest-portal
  /// picker.
  Future<bool> updateVisibility(List<int> visibleIds) async {
    try {
      final res = await _api.patch('/live-visibility',
          data: {'visible_ids': visibleIds}) as Map<String, dynamic>;
      final updated =
          (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      state = state.copyWith(updates: updated, updatesError: null);
      return true;
    } catch (e) {
      state = state.copyWith(updatesError: e.toString());
      return false;
    }
  }

  Future<void> refresh() => load();

  Future<bool> checkInGuest(int id) => _checkIn('/guests/$id');

  Future<bool> checkInVendor(int id) => _checkIn('/plan/vendors/$id');

  Future<bool> updateTimelineLocationStatuses(
      List<int> itemIds, String status) async {
    if (itemIds.isEmpty) return false;
    try {
      for (final id in itemIds) {
        await _api
            .patch('/plan/timeline/$id', data: {'location_status': status});
      }
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _checkIn(String path) async {
    try {
      await _api.patch(path,
          data: {'checked_in_at': DateTime.now().toIso8601String()});
      final today = await _fetchMap('/live/today');
      state = state.copyWith(today: today.data, todayError: today.error);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final liveProvider = StateNotifierProvider<LiveNotifier, LiveState>((ref) {
  return LiveNotifier(ref.read(apiClientProvider));
});
