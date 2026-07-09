import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

// ── STATE ──────────────────────────────────────────────────────────────────────

class ExperienceState {
  final bool isLoading;
  final bool isSaving;
  /// Raw GuestExperienceConfig row as returned by the API — flat boolean/
  /// string columns (show_schedule, welcome_message, etc.), not a fake
  /// "modules" map. The UI maps these directly to the real field names.
  final Map<String, dynamic> config;
  final String? error;

  const ExperienceState({
    this.isLoading = false,
    this.isSaving = false,
    this.config = const {},
    this.error,
  });

  ExperienceState copyWith({
    bool? isLoading,
    bool? isSaving,
    Map<String, dynamic>? config,
    String? error,
  }) =>
      ExperienceState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        config: config ?? this.config,
        error: error,
      );
}

// ── NOTIFIER ───────────────────────────────────────────────────────────────────

class ExperienceNotifier extends StateNotifier<ExperienceState> {
  final ApiClient _api;

  ExperienceNotifier(this._api) : super(const ExperienceState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get('/experience') as Map<String, dynamic>;
      final config = res['data'] as Map<String, dynamic>? ?? {};
      state = state.copyWith(isLoading: false, config: config);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Toggles a single real boolean field (e.g. 'show_schedule') and
  /// immediately PATCHes it. Reverts optimistically on failure.
  Future<void> toggleField(String field, bool value) async {
    final previous = state.config[field];
    final updated = Map<String, dynamic>.from(state.config)..[field] = value;
    state = state.copyWith(config: updated, isSaving: true);
    try {
      await _api.patch('/experience', data: {field: value});
      state = state.copyWith(isSaving: false);
    } catch (e) {
      final reverted = Map<String, dynamic>.from(state.config)..[field] = previous;
      state = state.copyWith(isSaving: false, config: reverted, error: e.toString());
    }
  }

  Future<bool> saveText({String? welcomeMessage, String? dressCode, String? dressCodeDetails}) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final res = await _api.patch('/experience', data: {
        if (welcomeMessage != null) 'welcome_message': welcomeMessage,
        if (dressCode != null) 'dress_code': dressCode,
        if (dressCodeDetails != null) 'dress_code_details': dressCodeDetails,
      }) as Map<String, dynamic>;
      state = state.copyWith(isSaving: false, config: res['data'] as Map<String, dynamic>? ?? state.config);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<void> refresh() => _load();
}

// ── PROVIDER ───────────────────────────────────────────────────────────────────

final experienceProvider = StateNotifierProvider<ExperienceNotifier, ExperienceState>((ref) {
  return ExperienceNotifier(ref.read(apiClientProvider));
});
