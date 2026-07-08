import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class WeddingPartyState {
  final List<Map<String, dynamic>> members;
  final bool isLoading;
  final String? error;

  const WeddingPartyState({
    this.members = const [],
    this.isLoading = false,
    this.error,
  });

  WeddingPartyState copyWith({
    List<Map<String, dynamic>>? members,
    bool? isLoading,
    String? error,
  }) =>
      WeddingPartyState(
        members: members ?? this.members,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}

class WeddingPartyNotifier extends StateNotifier<WeddingPartyState> {
  final ApiClient _api;

  WeddingPartyNotifier(this._api) : super(const WeddingPartyState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get('/guests', query: {'group': 'wedding_party'});
      final list = (res.data as List? ?? []).cast<Map<String, dynamic>>();
      state = state.copyWith(members: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addMember({
    required String firstName,
    required String lastName,
    required String role,
    String? email,
    String? phone,
  }) async {
    try {
      final res = await _api.post('/guests', data: {
        'first_name': firstName,
        'last_name': lastName,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'guest_group': 'wedding_party',
        'notes': role,
      });
      final newMember = res.data as Map<String, dynamic>;
      state = state.copyWith(members: [...state.members, newMember]);
    } catch (_) {}
  }

  Future<void> removeMember(int id) async {
    try {
      await _api.delete('/guests/$id');
      state = state.copyWith(
        members: state.members.where((m) => m['id'] != id).toList(),
      );
    } catch (_) {}
  }
}

final weddingPartyProvider =
    StateNotifierProvider<WeddingPartyNotifier, WeddingPartyState>((ref) {
  return WeddingPartyNotifier(ref.read(apiClientProvider));
});
