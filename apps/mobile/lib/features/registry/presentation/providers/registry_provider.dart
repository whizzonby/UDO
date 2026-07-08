import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class RegistryState {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final String? error;

  const RegistryState({this.isLoading = false, this.items = const [], this.error});

  RegistryState copyWith({bool? isLoading, List<Map<String, dynamic>>? items, String? error}) =>
      RegistryState(isLoading: isLoading ?? this.isLoading, items: items ?? this.items, error: error ?? this.error);
}

class RegistryNotifier extends StateNotifier<RegistryState> {
  final ApiClient _api;
  RegistryNotifier(this._api) : super(const RegistryState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.get('/registry') as Map<String, dynamic>;
      final items = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addItem(Map<String, dynamic> data) async {
    try {
      final type = data['type'] as String? ?? 'item';
      final price = data['price'];
      final payload = {
        'name': data['name'] ?? '',
        'type': type,
        if (data['url'] != null) 'url': data['url'],
        if (data['description'] != null) 'description': data['description'],
        if (data['note'] != null) 'notes': data['note'],
        if (price != null) (type == 'cash_fund' ? 'fund_goal' : 'price'): price,
      };
      final res = await _api.post('/registry', data: payload) as Map<String, dynamic>;
      state = state.copyWith(items: [...state.items, res['data'] as Map<String, dynamic>]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refresh() => _load();
}

final registryProvider = StateNotifierProvider<RegistryNotifier, RegistryState>((ref) {
  return RegistryNotifier(ref.read(apiClientProvider));
});
