import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class NotificationsState {
  final bool isLoading;
  final List<Map<String, dynamic>> alerts;
  final int totalActive;
  final bool showResolved;
  final String? error;

  const NotificationsState({
    this.isLoading = false,
    this.alerts = const [],
    this.totalActive = 0,
    this.showResolved = false,
    this.error,
  });

  NotificationsState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? alerts,
    int? totalActive,
    bool? showResolved,
    String? error,
  }) =>
      NotificationsState(
        isLoading: isLoading ?? this.isLoading,
        alerts: alerts ?? this.alerts,
        totalActive: totalActive ?? this.totalActive,
        showResolved: showResolved ?? this.showResolved,
        error: error,
      );
}

/// Backed by the existing Smart Alerts system (real RSVP-deadline,
/// guest-readiness, budget etc. alerts already computed server-side) —
/// there's no separate push-notification infrastructure yet, so this is
/// the in-app notification list the bell icon opens.
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final ApiClient _api;
  NotificationsNotifier(this._api) : super(const NotificationsState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get('/smart-alerts', query: {
        if (state.showResolved) 'include_resolved': 'true',
      }) as Map<String, dynamic>;
      final alerts = (res['data'] as List? ?? [])
          .whereType<Map>()
          .map((a) => Map<String, dynamic>.from(a))
          .toList();
      final summary = res['summary'] as Map<String, dynamic>? ?? {};
      state = state.copyWith(
        isLoading: false,
        alerts: alerts,
        totalActive: (summary['total_active'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _load();

  Future<void> toggleShowResolved(bool value) async {
    state = state.copyWith(showResolved: value);
    await _load();
  }

  Future<void> resolve(int id) async {
    final previous = state.alerts;
    // Optimistic: either drop it (active-only view) or mark it resolved in
    // place (resolved-included view) so the tap feels instant.
    state = state.copyWith(
      alerts: state.showResolved
          ? state.alerts.map((a) => a['id'] == id ? {...a, 'status': 'resolved'} : a).toList()
          : state.alerts.where((a) => a['id'] != id).toList(),
      totalActive: state.totalActive > 0 ? state.totalActive - 1 : 0,
    );
    try {
      await _api.post('/smart-alerts/$id/resolve');
    } catch (_) {
      state = state.copyWith(alerts: previous);
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref.read(apiClientProvider));
});
