import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/guests_repository.dart';
import '../../domain/guests_state.dart';
import '../../data/models/guest_model.dart';

part 'guests_provider.g.dart';

// ─── Guest List ───────────────────────────────────────────────────────────────

@riverpod
class GuestsListNotifier extends _$GuestsListNotifier {
  @override
  GuestsListState build() {
    _load();
    return const GuestsListState.loading();
  }

  Future<void> _load({String query = '', String statusFilter = 'all'}) async {
    try {
      final result = await ref.read(guestsRepositoryProvider).getGuests(
            search: query,
            rsvpStatus: statusFilter == 'all' ? null : statusFilter,
          );
      state = GuestsListState.loaded(
        guests: result.guests,
        total: result.total,
        query: query,
        statusFilter: statusFilter,
      );
    } catch (e) {
      state = GuestsListState.error(e.toString());
    }
  }

  Future<void> search(String query) async {
    final currentFilter = state.mapOrNull(loaded: (s) => s.statusFilter) ?? 'all';
    state = const GuestsListState.loading();
    await _load(query: query, statusFilter: currentFilter);
  }

  Future<void> filterByStatus(String status) async {
    final currentQuery = state.mapOrNull(loaded: (s) => s.query) ?? '';
    state = const GuestsListState.loading();
    await _load(query: currentQuery, statusFilter: status);
  }

  Future<void> refresh() async {
    final q = state.mapOrNull(loaded: (s) => s.query) ?? '';
    final f = state.mapOrNull(loaded: (s) => s.statusFilter) ?? 'all';
    await _load(query: q, statusFilter: f);
  }

  Future<GuestModel> addGuest(Map<String, dynamic> data) async {
    final guest =
        await ref.read(guestsRepositoryProvider).createGuest(data);
    await refresh();
    return guest;
  }

  Future<GuestModel> updateGuest(String id, Map<String, dynamic> data) async {
    final guest =
        await ref.read(guestsRepositoryProvider).updateGuest(id, data);
    await refresh();
    return guest;
  }

  Future<void> deleteGuest(String id) async {
    await ref.read(guestsRepositoryProvider).deleteGuest(id);
    await refresh();
  }
}

// ─── Guests Overview ──────────────────────────────────────────────────────────

@riverpod
class GuestsOverviewNotifier extends _$GuestsOverviewNotifier {
  @override
  GuestsOverviewState build() {
    _load();
    return const GuestsOverviewState.loading();
  }

  Future<void> _load() async {
    try {
      final overview =
          await ref.read(guestsRepositoryProvider).getOverview();
      state = GuestsOverviewState.loaded(overview);
    } catch (e) {
      state = GuestsOverviewState.error(e.toString());
    }
  }

  Future<void> refresh() async => _load();
}

// ─── Invitations ──────────────────────────────────────────────────────────────

enum InvitationsStatus { loading, loaded, error, busy }

class InvitationsState {
  const InvitationsState({
    this.status = InvitationsStatus.loading,
    this.guests = const [],
    this.error,
  });

  final InvitationsStatus status;
  final List<GuestModel> guests;
  final String? error;

  List<GuestModel> get notInvited =>
      guests.where((g) => g.invitationSentAt == null).toList();
  List<GuestModel> get awaiting => guests
      .where((g) => g.invitationSentAt != null && g.rsvpRespondedAt == null)
      .toList();
  List<GuestModel> get responded =>
      guests.where((g) => g.rsvpRespondedAt != null).toList();

  InvitationsState copyWith({
    InvitationsStatus? status,
    List<GuestModel>? guests,
    String? error,
  }) =>
      InvitationsState(
        status: status ?? this.status,
        guests: guests ?? this.guests,
        error: error ?? this.error,
      );
}

@riverpod
class InvitationsNotifier extends _$InvitationsNotifier {
  @override
  InvitationsState build() {
    _load();
    return const InvitationsState();
  }

  Future<void> _load() async {
    try {
      final result =
          await ref.read(guestsRepositoryProvider).getGuests();
      state = InvitationsState(
        status: InvitationsStatus.loaded,
        guests: result.guests,
      );
    } catch (e) {
      state = InvitationsState(
        status: InvitationsStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() => _load();

  Future<void> markInvited(String id) async {
    state = state.copyWith(status: InvitationsStatus.busy);
    try {
      final updated =
          await ref.read(guestsRepositoryProvider).markInvited(id);
      state = state.copyWith(
        status: InvitationsStatus.loaded,
        guests: state.guests
            .map((g) => g.id == id ? updated : g)
            .toList(),
      );
    } catch (_) {
      state = state.copyWith(status: InvitationsStatus.loaded);
    }
  }

  Future<void> bulkInviteAll() async {
    state = state.copyWith(status: InvitationsStatus.busy);
    try {
      await ref
          .read(guestsRepositoryProvider)
          .bulkInvite(inviteAllUninvited: true);
      await _load();
    } catch (_) {
      state = state.copyWith(status: InvitationsStatus.loaded);
    }
  }

  Future<String> regenerateToken(String id) async {
    return ref.read(guestsRepositoryProvider).regenerateToken(id);
  }
}

// ─── Guest Detail ─────────────────────────────────────────────────────────────

@riverpod
class GuestDetailNotifier extends _$GuestDetailNotifier {
  @override
  GuestDetailState build() => const GuestDetailState.idle();

  Future<void> load(String id) async {
    state = const GuestDetailState.loading();
    try {
      final guest = await ref.read(guestsRepositoryProvider).getGuest(id);
      state = GuestDetailState.loaded(guest);
    } catch (e) {
      state = GuestDetailState.error(e.toString());
    }
  }

  Future<GuestModel> update(String id, Map<String, dynamic> data) async {
    final guest =
        await ref.read(guestsRepositoryProvider).updateGuest(id, data);
    state = GuestDetailState.loaded(guest);
    return guest;
  }

  void clear() => state = const GuestDetailState.idle();
}
