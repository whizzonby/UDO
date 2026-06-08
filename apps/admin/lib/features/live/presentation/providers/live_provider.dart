import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/live_status_model.dart';
import '../../data/repositories/live_repository.dart';

part 'live_provider.g.dart';

enum LiveLoadStatus { loading, loaded, error }

class LiveState {
  const LiveState({
    this.loadStatus = LiveLoadStatus.loading,
    this.status,
    this.error,
    this.busyGuestIds = const {},
  });

  final LiveLoadStatus loadStatus;
  final LiveStatus? status;
  final String? error;
  final Set<String> busyGuestIds;

  LiveState copyWith({
    LiveLoadStatus? loadStatus,
    LiveStatus? status,
    String? error,
    Set<String>? busyGuestIds,
  }) =>
      LiveState(
        loadStatus: loadStatus ?? this.loadStatus,
        status: status ?? this.status,
        error: error ?? this.error,
        busyGuestIds: busyGuestIds ?? this.busyGuestIds,
      );
}

@riverpod
class LiveNotifier extends _$LiveNotifier {
  @override
  LiveState build() {
    _load();
    return const LiveState();
  }

  Future<void> _load() async {
    try {
      final s = await ref.read(liveRepositoryProvider).getStatus();
      state = LiveState(loadStatus: LiveLoadStatus.loaded, status: s);
    } catch (e) {
      state = LiveState(loadStatus: LiveLoadStatus.error, error: e.toString());
    }
  }

  Future<void> refresh() => _load();

  Future<void> activate() async {
    await ref.read(liveRepositoryProvider).activate();
    await _load();
  }

  Future<void> deactivate() async {
    await ref.read(liveRepositoryProvider).deactivate();
    await _load();
  }

  Future<void> checkIn(String guestId) async {
    state = state.copyWith(busyGuestIds: {...state.busyGuestIds, guestId});
    try {
      await ref.read(liveRepositoryProvider).checkInGuest(guestId);
      await _load();
    } finally {
      state = state.copyWith(
        busyGuestIds: state.busyGuestIds.difference({guestId}),
      );
    }
  }
}
