import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

// ── STATE ──────────────────────────────────────────────────────────────────────

class LogisticsState {
  final bool isLoading;
  final List<Map<String, dynamic>> accommodations;
  final List<Map<String, dynamic>> transports;
  final String? error;

  const LogisticsState({
    this.isLoading = false,
    this.accommodations = const [],
    this.transports = const [],
    this.error,
  });

  LogisticsState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? accommodations,
    List<Map<String, dynamic>>? transports,
    String? error,
  }) =>
      LogisticsState(
        isLoading: isLoading ?? this.isLoading,
        accommodations: accommodations ?? this.accommodations,
        transports: transports ?? this.transports,
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
      ]);

      final acc = ((results[0] as Map<String, dynamic>)['data'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      final trn = ((results[1] as Map<String, dynamic>)['data'] as List? ?? [])
          .cast<Map<String, dynamic>>();

      state = state.copyWith(isLoading: false, accommodations: acc, transports: trn);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addAccommodation(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/logistics/accommodation', data: data) as Map<String, dynamic>;
      final created = res['data'] as Map<String, dynamic>;
      state = state.copyWith(accommodations: [...state.accommodations, created], error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> addTransport(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/logistics/transport', data: data) as Map<String, dynamic>;
      final created = res['data'] as Map<String, dynamic>;
      state = state.copyWith(transports: [...state.transports, created], error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> refresh() => _load();
}

// ── PROVIDER ───────────────────────────────────────────────────────────────────

final logisticsProvider = StateNotifierProvider<LogisticsNotifier, LogisticsState>((ref) {
  return LogisticsNotifier(ref.read(apiClientProvider));
});
