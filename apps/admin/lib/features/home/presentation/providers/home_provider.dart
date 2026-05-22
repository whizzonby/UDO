import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/home_repository.dart';
import '../../domain/home_state.dart';

part 'home_provider.g.dart';

@riverpod
class HomeNotifier extends _$HomeNotifier {
  @override
  HomeState build() {
    _load();
    return const HomeState.loading();
  }

  Future<void> _load() async {
    try {
      final stats = await ref.read(homeRepositoryProvider).getHomeStats();
      state = HomeState.loaded(stats);
    } catch (e) {
      state = HomeState.error(e.toString());
    }
  }

  Future<void> refresh() async {
    state = const HomeState.loading();
    await _load();
  }
}

@riverpod
HomeState homeState(Ref ref) => ref.watch(homeNotifierProvider);

@riverpod
Stream<Duration> weddingCountdown(Ref ref, DateTime weddingDate) async* {
  while (true) {
    final remaining = weddingDate.difference(DateTime.now());
    yield remaining.isNegative ? Duration.zero : remaining;
    await Future.delayed(const Duration(minutes: 1));
  }
}
