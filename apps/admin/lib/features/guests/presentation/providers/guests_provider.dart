import 'package:flutter_riverpod/flutter_riverpod.dart';
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
