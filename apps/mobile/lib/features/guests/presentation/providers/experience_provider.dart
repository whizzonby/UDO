import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

// ── STATE ──────────────────────────────────────────────────────────────────────

class ExperienceState {
  final bool isLoading;
  final bool isSaving;
  /// Module name → enabled flag, e.g. {'Our Story': true, 'Photo Upload': false}
  final Map<String, bool> modules;
  /// Raw portal data returned by the API (slug, url, etc.)
  final Map<String, dynamic> portal;
  final String? error;

  const ExperienceState({
    this.isLoading = false,
    this.isSaving = false,
    this.modules = const {},
    this.portal = const {},
    this.error,
  });

  ExperienceState copyWith({
    bool? isLoading,
    bool? isSaving,
    Map<String, bool>? modules,
    Map<String, dynamic>? portal,
    String? error,
  }) =>
      ExperienceState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        modules: modules ?? this.modules,
        portal: portal ?? this.portal,
        error: error ?? this.error,
      );
}

// ── NOTIFIER ───────────────────────────────────────────────────────────────────

class ExperienceNotifier extends StateNotifier<ExperienceState> {
  final ApiClient _api;

  ExperienceNotifier(this._api) : super(const ExperienceState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.get('/experience') as Map<String, dynamic>;
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final rawModules = data['modules'] as Map<String, dynamic>? ?? {};
      final portal = data['portal'] as Map<String, dynamic>? ?? {};

      // Convert dynamic values to bool
      final modules = rawModules.map(
        (k, v) => MapEntry(k, v == true || v == 1 || v == 'true'),
      );

      state = state.copyWith(isLoading: false, modules: modules, portal: portal);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Toggles a single module and immediately PATCHes the API.
  Future<void> toggleModule(String key, bool value) async {
    final updated = Map<String, bool>.from(state.modules)..[key] = value;
    state = state.copyWith(modules: updated, isSaving: true);
    try {
      await _api.patch('/experience', data: {'modules': updated});
      state = state.copyWith(isSaving: false);
    } catch (e) {
      // Revert on failure
      final reverted = Map<String, bool>.from(state.modules)..[key] = !value;
      state = state.copyWith(isSaving: false, modules: reverted, error: e.toString());
    }
  }

  Future<void> refresh() => _load();
}

// ── PROVIDER ───────────────────────────────────────────────────────────────────

final experienceProvider = StateNotifierProvider<ExperienceNotifier, ExperienceState>((ref) {
  return ExperienceNotifier(ref.read(apiClientProvider));
});
