import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/reverb_client.dart';
import '../../data/models/live_status_model.dart';
import '../../data/repositories/live_repository.dart';

part 'live_provider.g.dart';

// Exposes the weddingId from the loaded status so liveActivitiesProvider
// only restarts the WebSocket when the ID actually changes.
@riverpod
String? currentWeddingId(Ref ref) =>
    ref.watch(liveNotifierProvider).status?.weddingId;

// Loads historical activities via HTTP, then upgrades to a live WebSocket
// stream on the private-wedding.{weddingId} Reverb channel.
// Cancels automatically when no longer watched.
@riverpod
Stream<List<LiveActivity>> liveActivities(Ref ref) async* {
  final weddingId = ref.watch(currentWeddingIdProvider);

  // Fetch history first so the feed isn't empty while WS connects.
  List<LiveActivity> current = const [];
  try {
    current = await ref.read(liveRepositoryProvider).getActivity();
  } catch (_) {}
  yield current;

  if (weddingId == null) return;

  final client = ReverbClient(ref.read(apiClientProvider));
  try {
    await for (final activity in client.activityStream(weddingId)) {
      current = [activity, ...current.take(29)];
      yield current;
    }
  } catch (_) {
    // WS connection failed — stay on last HTTP snapshot.
  }
}

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
