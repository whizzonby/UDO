import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/experience_config_model.dart';
import '../../data/repositories/experience_repository.dart';

part 'experience_provider.g.dart';

enum ExperienceStatus { loading, loaded, saving, error }

class ExperienceState {
  const ExperienceState({
    this.status = ExperienceStatus.loading,
    this.config,
    this.error,
  });

  final ExperienceStatus status;
  final ExperienceConfig? config;
  final String? error;

  ExperienceState copyWith({
    ExperienceStatus? status,
    ExperienceConfig? config,
    String? error,
  }) =>
      ExperienceState(
        status: status ?? this.status,
        config: config ?? this.config,
        error: error ?? this.error,
      );
}

@riverpod
class ExperienceNotifier extends _$ExperienceNotifier {
  @override
  ExperienceState build() {
    _load();
    return const ExperienceState();
  }

  Future<void> _load() async {
    try {
      final config = await ref.read(experienceRepositoryProvider).getConfig();
      state = ExperienceState(status: ExperienceStatus.loaded, config: config);
    } catch (e) {
      state = ExperienceState(status: ExperienceStatus.error, error: e.toString());
    }
  }

  Future<void> refresh() => _load();

  Future<void> togglePublished() async {
    if (state.config == null) return;
    await _save({'is_published': !state.config!.isPublished});
  }

  Future<void> updateWelcomeMessage(String msg) async {
    await _save({'welcome_message': msg.isEmpty ? null : msg});
  }

  Future<void> toggleSection(String key, bool enabled) async {
    await _save({
      'sections_enabled': {key: enabled},
    });
  }

  Future<void> updateAccentColor(String hex) async {
    await _save({'theme_accent_color': hex});
  }

  Future<void> _save(Map<String, dynamic> data) async {
    state = state.copyWith(status: ExperienceStatus.saving);
    try {
      final updated =
          await ref.read(experienceRepositoryProvider).updateConfig(data);
      state = ExperienceState(status: ExperienceStatus.loaded, config: updated);
    } catch (e) {
      state = state.copyWith(
          status: ExperienceStatus.loaded, error: e.toString());
    }
  }
}
