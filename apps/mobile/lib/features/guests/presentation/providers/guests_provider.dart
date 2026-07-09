import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class GuestsState {
  final bool isLoading;
  final List<Map<String, dynamic>> guests;
  final String? error;

  const GuestsState({this.isLoading = false, this.guests = const [], this.error});

  GuestsState copyWith({bool? isLoading, List<Map<String, dynamic>>? guests, String? error}) =>
      GuestsState(isLoading: isLoading ?? this.isLoading, guests: guests ?? this.guests, error: error ?? this.error);
}

class GuestsNotifier extends StateNotifier<GuestsState> {
  final ApiClient _api;
  GuestsNotifier(this._api) : super(const GuestsState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get('/guests') as Map<String, dynamic>;
      final guests = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      state = state.copyWith(isLoading: false, guests: guests);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addGuest({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    String? attendingStatus,
    bool sendInviteAfter = false,
  }) async {
    try {
      final res = await _api.post('/guests', data: {
        'first_name': firstName,
        'last_name': lastName,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      }) as Map<String, dynamic>;
      var newGuest = res['data'] as Map<String, dynamic>;

      // attending_status isn't accepted by store(), only update() — set it
      // as a follow-up PATCH if the caller wants a non-default status.
      if (attendingStatus != null && attendingStatus != 'pending') {
        final updated = await _api.patch('/guests/${newGuest['id']}', data: {'attending_status': attendingStatus}) as Map<String, dynamic>;
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
      final res = await _api.patch('/guests/$id', data: data) as Map<String, dynamic>;
      final updated = res['data'] as Map<String, dynamic>;
      state = state.copyWith(guests: state.guests.map((g) => g['id'] == id ? updated : g).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteGuest(int id) async {
    try {
      await _api.delete('/guests/$id');
      state = state.copyWith(guests: state.guests.where((g) => g['id'] != id).toList());
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
      state = state.copyWith(guests: state.guests.map((g) {
        if (g['id'] != id) return g;
        return {...g, 'token': {'token': token}};
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
      state = state.copyWith(guests: state.guests.map((g) => g['id'] == id ? updated : g).toList());
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<int> bulkImport(List<Map<String, dynamic>> guests) async {
    try {
      final res = await _api.post('/guests/bulk-import', data: {'guests': guests}) as Map<String, dynamic>;
      final created = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      state = state.copyWith(guests: [...state.guests, ...created]);
      return res['imported'] as int? ?? created.length;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return 0;
    }
  }

  Future<void> refresh() => _load();
}

final guestsProvider = StateNotifierProvider<GuestsNotifier, GuestsState>((ref) {
  return GuestsNotifier(ref.read(apiClientProvider));
});
