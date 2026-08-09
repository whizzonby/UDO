import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class GuestsState {
  final bool isLoading;
  final List<Map<String, dynamic>> guests;
  final List<Map<String, dynamic>> activity;
  final String? error;
  final bool isOffline;
  final DateTime? cachedAt;

  const GuestsState({
    this.isLoading = false,
    this.guests = const [],
    this.activity = const [],
    this.error,
    this.isOffline = false,
    this.cachedAt,
  });

  GuestsState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? guests,
    List<Map<String, dynamic>>? activity,
    String? error,
    bool? isOffline,
    DateTime? cachedAt,
  }) =>
      GuestsState(
        isLoading: isLoading ?? this.isLoading,
        guests: guests ?? this.guests,
        activity: activity ?? this.activity,
        error: error,
        isOffline: isOffline ?? this.isOffline,
        cachedAt: cachedAt ?? this.cachedAt,
      );
}

class GuestsNotifier extends StateNotifier<GuestsState> {
  final ApiClient _api;
  GuestsNotifier(this._api) : super(const GuestsState(isLoading: true)) {
    _load();
    loadActivity();
  }

  Future<void> loadActivity() async {
    try {
      final res = await _api.get('/guests/activity') as Map<String, dynamic>;
      final activity = (res['data'] as List? ?? [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      state = state.copyWith(activity: activity);
    } catch (_) {
      // Non-critical — the rest of Overview still works without the feed.
    }
  }

  Future<void> _load({String? search, String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final query = <String, dynamic>{
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status != 'all') 'status': status,
      };
      final cached = await _api.getCached('/guests', query: query);
      final res = cached.data as Map<String, dynamic>;
      // Eagerly validated instead of a lazy .cast<Map<String, dynamic>>() —
      // a lazy cast only throws when a malformed entry is later iterated,
      // which would happen synchronously inside a widget's build() and
      // surface as an uncaught render-time exception rather than a caught,
      // reportable error here.
      final guests = (res['data'] as List? ?? [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      state = state.copyWith(
        isLoading: false,
        guests: guests,
        error: cached.fromCache
            ? 'Showing saved guest data. Connect to refresh.'
            : null,
        isOffline: cached.fromCache,
        cachedAt: cached.cachedAt,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadFiltered({String? search, String? status}) =>
      _load(search: search, status: status);

  Future<bool> addGuest({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    String? attendingStatus,
    bool sendInviteAfter = false,
    bool? plusOneAllowed,
    int? plusOneCount,
    String? mealPreference,
    String? dietaryNote,
  }) async {
    try {
      final res = await _api.post('/guests', data: {
        'first_name': firstName,
        'last_name': lastName,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (plusOneAllowed != null) 'plus_one_allowed': plusOneAllowed,
        if (plusOneCount != null) 'plus_one_count': plusOneCount,
        if (mealPreference != null && mealPreference.isNotEmpty)
          'meal_preference': mealPreference,
        if (dietaryNote != null && dietaryNote.isNotEmpty)
          'dietary_note': dietaryNote,
      }) as Map<String, dynamic>;
      var newGuest = res['data'] as Map<String, dynamic>;

      // attending_status isn't accepted by store(), only update() — set it
      // as a follow-up PATCH if the caller wants a non-default status.
      if (attendingStatus != null && attendingStatus != 'pending') {
        final updated = await _api.patch('/guests/${newGuest['id']}',
                data: {'attending_status': attendingStatus})
            as Map<String, dynamic>;
        newGuest = updated['data'] as Map<String, dynamic>;
      }
      state = state.copyWith(guests: [...state.guests, newGuest]);

      if (sendInviteAfter && email != null && email.isNotEmpty) {
        await sendInvite(newGuest['id'] as int);
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateGuest(int id, Map<String, dynamic> data) async {
    try {
      final res =
          await _api.patch('/guests/$id', data: data) as Map<String, dynamic>;
      final updated = res['data'] as Map<String, dynamic>;
      state = state.copyWith(
          guests:
              state.guests.map((g) => g['id'] == id ? updated : g).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteGuest(int id) async {
    try {
      await _api.delete('/guests/$id');
      state = state.copyWith(
          guests: state.guests.where((g) => g['id'] != id).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> generateToken(int id) async {
    try {
      final res = await _api.post('/guests/$id/token') as Map<String, dynamic>;
      final token = res['token'] as String?;
      state = state.copyWith(
          guests: state.guests.map((g) {
        if (g['id'] != id) return g;
        return {
          ...g,
          'token': {'token': token}
        };
      }).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> sendInvite(int id) async {
    try {
      final res = await _api.post('/guests/$id/invite') as Map<String, dynamic>;
      final updated = res['data'] as Map<String, dynamic>;
      state = state.copyWith(
          guests:
              state.guests.map((g) => g['id'] == id ? updated : g).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<int> bulkImport(List<Map<String, dynamic>> guests) async {
    try {
      final res =
          await _api.post('/guests/bulk-import', data: {'guests': guests})
              as Map<String, dynamic>;
      final created = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      state = state.copyWith(guests: [...state.guests, ...created]);
      return res['imported'] as int? ?? created.length;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return 0;
    }
  }

  Future<int> bulkUpdate(List<int> ids, Map<String, dynamic> updates) async {
    if (ids.isEmpty || updates.isEmpty) return 0;
    try {
      final res = await _api.post('/guests/bulk-update', data: {
        'ids': ids,
        'updates': updates,
        'confirm': true,
      }) as Map<String, dynamic>;
      final updated = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      final updatedById = {for (final guest in updated) guest['id']: guest};
      state = state.copyWith(
          guests: state.guests
              .map((guest) => updatedById[guest['id']] ?? guest)
              .toList());
      return res['updated'] as int? ?? updated.length;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return 0;
    }
  }

  Future<void> refresh() async {
    await _load();
    await loadActivity();
  }
}

final guestsProvider =
    StateNotifierProvider<GuestsNotifier, GuestsState>((ref) {
  return GuestsNotifier(ref.read(apiClientProvider));
});
