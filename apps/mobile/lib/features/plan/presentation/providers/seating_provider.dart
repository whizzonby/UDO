import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class SeatingPlannerState {
  final bool isLoading;
  final bool isSaving;
  final List<Map<String, dynamic>> tables;
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> pairings;
  final String? error;

  const SeatingPlannerState({
    this.isLoading = false,
    this.isSaving = false,
    this.tables = const [],
    this.summary = const {},
    this.pairings = const [],
    this.error,
  });

  SeatingPlannerState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<Map<String, dynamic>>? tables,
    Map<String, dynamic>? summary,
    List<Map<String, dynamic>>? pairings,
    String? error,
  }) =>
      SeatingPlannerState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        tables: tables ?? this.tables,
        summary: summary ?? this.summary,
        pairings: pairings ?? this.pairings,
        error: error,
      );
}

class SeatingPlannerNotifier extends StateNotifier<SeatingPlannerState> {
  final ApiClient _api;

  SeatingPlannerNotifier(this._api)
      : super(const SeatingPlannerState(isLoading: true)) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tablesRes = await _api.get('/seating');
      final summaryRes = await _api.get('/seating/summary');
      final pairingsRes = await _api.get('/seating/pairings');
      final tables = tablesRes is Map && tablesRes['data'] is List
          ? (tablesRes['data'] as List).cast<Map<String, dynamic>>()
          : <Map<String, dynamic>>[];
      final summary = summaryRes is Map && summaryRes['data'] is Map
          ? Map<String, dynamic>.from(summaryRes['data'] as Map)
          : <String, dynamic>{};
      final pairings = pairingsRes is Map && pairingsRes['data'] is List
          ? (pairingsRes['data'] as List).cast<Map<String, dynamic>>()
          : <Map<String, dynamic>>[];

      state = state.copyWith(
        isLoading: false,
        tables: tables,
        summary: summary,
        pairings: pairings,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Map<String, dynamic>?> addTable({Map<String, dynamic>? data}) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final res = await _api.post('/seating/tables',
          data: data ??
              {
                'name': 'Table ${state.tables.length + 1}',
                'shape': 'round',
                'capacity': 8,
              }) as Map<String, dynamic>;
      final created = Map<String, dynamic>.from(res['data'] as Map);
      state = state.copyWith(
        tables: [...state.tables, created],
        isSaving: false,
        error: null,
      );
      await refresh();
      return created;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return null;
    }
  }

  Future<bool> updateTable({
    required int tableId,
    String? name,
    int? capacity,
  }) async {
    try {
      await _api.patch('/seating/tables/$tableId', data: {
        if (name != null) 'name': name,
        if (capacity != null) 'capacity': capacity,
      });
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> assignSeat(
      {required int tableId, required int seatNumber, int? guestId}) async {
    try {
      await _api.post('/seating/tables/$tableId/assign', data: {
        'seat_number': seatNumber,
        'guest_id': guestId,
      });
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> clearTable(Map<String, dynamic> table) async {
    final tableId = table['id'] as int;
    final seats = (table['seats'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    try {
      for (final seat in seats) {
        if (seat['guest'] != null || seat['guest_id'] != null) {
          await _api.delete('/seating/tables/$tableId/seats/${seat['id']}');
        }
      }
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> clearSeat({required int tableId, required int seatId}) async {
    try {
      await _api.delete('/seating/tables/$tableId/seats/$seatId');
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> addPairing(
      {required int guestId,
      required int relatedGuestId,
      required String type}) async {
    try {
      await _api.post('/seating/pairings', data: {
        'guest_id': guestId,
        'related_guest_id': relatedGuestId,
        'type': type,
      });
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> removePairing(int id) async {
    try {
      await _api.delete('/seating/pairings/$id');
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<({int seated, int totalUnassigned})?> autoAssign(
      Map<String, bool> rules) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final res = await _api.post('/seating/auto-assign', data: rules)
          as Map<String, dynamic>;
      final data = res['data'] as Map<String, dynamic>? ?? {};
      await refresh();
      state = state.copyWith(isSaving: false);
      return (
        seated: (data['seated_count'] as num?)?.toInt() ?? 0,
        totalUnassigned: (data['total_unassigned'] as num?)?.toInt() ?? 0
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return null;
    }
  }

  Future<bool> setGuestFlags(int guestId,
      {bool? isElderly, bool? accessibilityNeeds}) async {
    try {
      await _api.patch('/guests/$guestId', data: {
        if (isElderly != null) 'is_elderly': isElderly,
        if (accessibilityNeeds != null)
          'accessibility_needs': accessibilityNeeds,
      });
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final seatingPlannerProvider =
    StateNotifierProvider<SeatingPlannerNotifier, SeatingPlannerState>((ref) {
  return SeatingPlannerNotifier(ref.read(apiClientProvider));
});
