import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class VisionStyleState {
  final bool isLoading;
  final Map<String, dynamic>? visionStyle;
  final String? error;

  const VisionStyleState({this.isLoading = false, this.visionStyle, this.error});

  VisionStyleState copyWith({bool? isLoading, Map<String, dynamic>? visionStyle, String? error}) => VisionStyleState(
        isLoading: isLoading ?? this.isLoading,
        visionStyle: visionStyle ?? this.visionStyle,
        error: error,
      );
}

class VisionStyleNotifier extends StateNotifier<VisionStyleState> {
  final ApiClient _api;
  VisionStyleNotifier(this._api) : super(const VisionStyleState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.get('/wedding') as Map<String, dynamic>;
      state = state.copyWith(isLoading: false, visionStyle: _decode(res['vision_style']));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> save(Map<String, dynamic> visionStyle) async {
    try {
      final res = await _api.patch('/wedding', data: {'vision_style': visionStyle}) as Map<String, dynamic>;
      state = state.copyWith(visionStyle: _decode(res['vision_style']) ?? visionStyle, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> refresh() => _load();

  Map<String, dynamic>? _decode(dynamic value) => value is Map ? Map<String, dynamic>.from(value) : null;
}

final visionStyleProvider = StateNotifierProvider<VisionStyleNotifier, VisionStyleState>((ref) {
  return VisionStyleNotifier(ref.read(apiClientProvider));
});
