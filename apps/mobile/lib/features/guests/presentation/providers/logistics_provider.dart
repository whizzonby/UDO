import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

// ── STATE ──────────────────────────────────────────────────────────────────────

class LogisticsState {
  final bool isLoading;
  final List<Map<String, dynamic>> accommodations;
  final List<Map<String, dynamic>> transports;
  final Map<String, dynamic> summary;
  final String? error;

  const LogisticsState({
    this.isLoading = false,
    this.accommodations = const [],
    this.transports = const [],
    this.summary = const {},
    this.error,
  });

  LogisticsState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? accommodations,
    List<Map<String, dynamic>>? transports,
    Map<String, dynamic>? summary,
    String? error,
  }) =>
      LogisticsState(
        isLoading: isLoading ?? this.isLoading,
        accommodations: accommodations ?? this.accommodations,
        transports: transports ?? this.transports,
        summary: summary ?? this.summary,
        error: error,
      );
}

// ── NOTIFIER ───────────────────────────────────────────────────────────────────

class LogisticsNotifier extends StateNotifier<LogisticsState> {
  final ApiClient _api;

  LogisticsNotifier(this._api) : super(const LogisticsState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _api.get('/logistics/accommodation'),
        _api.get('/logistics/transport'),
        _api.get('/logistics/summary'),
      ]);

      final acc = ((results[0] as Map<String, dynamic>)['data'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      final trn = ((results[1] as Map<String, dynamic>)['data'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      final summary = Map<String, dynamic>.from(
          (results[2] as Map<String, dynamic>)['data'] as Map? ?? {});

      state = state.copyWith(
          isLoading: false,
          accommodations: acc,
          transports: trn,
          summary: summary);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Returns null on success, or the real reason for failure (e.g. a
  /// backend validation message) so the caller can show it instead of a
  /// generic "something went wrong".
  Future<String?> addAccommodation(Map<String, dynamic> data) async {
    try {
      await _api.post('/logistics/accommodation', data: data);
      await _load();
      return null;
    } catch (e) {
      final message = e.toString();
      state = state.copyWith(error: message);
      return message;
    }
  }

  /// Returns an empty list on any failure (missing API key, network error) —
  /// the hotel search field is a nice-to-have and should silently fall back
  /// to plain typing rather than surface an error.
  Future<List<Map<String, dynamic>>> searchPlaces(String query, String sessionToken, {String? type}) async {
    try {
      final res = await _api.get('/places/search', query: {
        'query': query,
        'session_token': sessionToken,
        if (type != null) 'type': type,
      }) as Map<String, dynamic>;
      return (res['data'] as List? ?? [])
          .whereType<Map>()
          .map((p) => Map<String, dynamic>.from(p))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<Map<String, dynamic>?> fetchPlaceDetails(String placeId, String sessionToken) async {
    try {
      final res = await _api.get('/places/$placeId', query: {
        'session_token': sessionToken,
      }) as Map<String, dynamic>;
      final data = res['data'];
      return data is Map ? Map<String, dynamic>.from(data) : null;
    } catch (_) {
      return null;
    }
  }

  /// Returns null on success, or the real reason for failure so the caller
  /// can show it instead of a generic "something went wrong".
  Future<String?> addTransport(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/logistics/transport', data: data)
          as Map<String, dynamic>;
      final created = res['data'] as Map<String, dynamic>;
      state = state
          .copyWith(transports: [...state.transports, created], error: null);
      return null;
    } catch (e) {
      final message = e.toString();
      state = state.copyWith(error: message);
      return message;
    }
  }

  /// Returns null on success, or the real reason for failure so the caller
  /// can show it instead of a generic "something went wrong".
  Future<String?> updateAccommodation(int id, Map<String, dynamic> data) async {
    try {
      final res = await _api.patch('/logistics/accommodation/$id', data: data)
          as Map<String, dynamic>;
      final updated = res['data'] as Map<String, dynamic>;
      state = state.copyWith(
        accommodations: state.accommodations
            .map((a) => a['id'] == id ? updated : a)
            .toList(),
        error: null,
      );
      return null;
    } catch (e) {
      final message = e.toString();
      state = state.copyWith(error: message);
      return message;
    }
  }

  Future<bool> assignAccommodation(int accommodationId, int guestId) async {
    try {
      await _api.post('/logistics/accommodation/$accommodationId/assign',
          data: {'guest_id': guestId});
      await _load();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> assignTransport(int transportId, int guestId) async {
    try {
      await _api.post('/logistics/transport/$transportId/assign',
          data: {'guest_id': guestId});
      await _load();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> refresh() => _load();
}

// ── PROVIDER ───────────────────────────────────────────────────────────────────

final logisticsProvider =
    StateNotifierProvider<LogisticsNotifier, LogisticsState>((ref) {
  return LogisticsNotifier(ref.read(apiClientProvider));
});
