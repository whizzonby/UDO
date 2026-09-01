import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const _seenKey = 'notifications_seen_alert_ids';

  NotificationsNotifier(this._api)
      : super(const NotificationsState(isLoading: true)) {
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
      final seenIds = await _seenAlertIds();
      state = state.copyWith(
        isLoading: false,
        alerts: alerts,
        totalActive: alerts
            .where((alert) =>
                alert['status'] == 'active' &&
                !seenIds.contains(_alertId(alert)))
            .length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _load();

  Future<void> markVisibleAsSeen() async {
    final activeIds = state.alerts
        .where((alert) => alert['status'] == 'active')
        .map(_alertId)
        .where((id) => id.isNotEmpty)
        .toSet();
    if (activeIds.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_seenKey)?.toSet() ?? <String>{};
    await prefs.setStringList(_seenKey, {...existing, ...activeIds}.toList());
    state = state.copyWith(totalActive: 0);
  }

  Future<void> toggleShowResolved(bool value) async {
    state = state.copyWith(showResolved: value);
    await _load();
  }

  Future<void> resolve(int id) async {
    final previous = state.alerts;
    final previousTotalActive = state.totalActive;
    final wasUnread = state.alerts.any((alert) =>
        _alertId(alert) == id.toString() && alert['status'] == 'active');
    // Optimistic: either drop it (active-only view) or mark it resolved in
    // place (resolved-included view) so the tap feels instant.
    state = state.copyWith(
      alerts: state.showResolved
          ? state.alerts
              .map((a) => a['id'] == id ? {...a, 'status': 'resolved'} : a)
              .toList()
          : state.alerts.where((a) => a['id'] != id).toList(),
      totalActive: wasUnread && state.totalActive > 0
          ? state.totalActive - 1
          : state.totalActive,
    );
    try {
      await _api.post('/smart-alerts/$id/resolve');
    } catch (_) {
      state =
          state.copyWith(alerts: previous, totalActive: previousTotalActive);
    }
  }

  Future<Set<String>> _seenAlertIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_seenKey) ?? const <String>[]).toSet();
  }

  String _alertId(Map<String, dynamic> alert) => (alert['id'] ?? '').toString();
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref.read(apiClientProvider));
});
