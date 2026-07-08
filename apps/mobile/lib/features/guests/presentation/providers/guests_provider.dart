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
    try {
      final res = await _api.get('/guests') as Map<String, dynamic>;
      final guests = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      state = state.copyWith(isLoading: false, guests: guests);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addGuest({required String firstName, required String lastName, String? email, String? phone}) async {
    try {
      final res = await _api.post('/guests', data: {
        'first_name': firstName, 'last_name': lastName,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      }) as Map<String, dynamic>;
      final newGuest = res['data'] as Map<String, dynamic>;
      state = state.copyWith(guests: [...state.guests, newGuest]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() => _load();
}

final guestsProvider = StateNotifierProvider<GuestsNotifier, GuestsState>((ref) {
  return GuestsNotifier(ref.read(apiClientProvider));
});
