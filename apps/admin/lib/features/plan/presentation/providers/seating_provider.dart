import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/seating_models.dart';
import '../../data/repositories/seating_repository.dart';
import '../../domain/seating_state.dart';

part 'seating_provider.g.dart';

@Riverpod(keepAlive: true)
class SeatingNotifier extends _$SeatingNotifier {
  @override
  SeatingState build() {
    _load();
    return const SeatingState.loading();
  }

  Future<void> _load() async {
    try {
      final data = await ref.read(seatingRepositoryProvider).getSeatingData();
      state = SeatingState.loaded(data);
    } catch (e) {
      state = SeatingState.error(e.toString());
    }
  }

  Future<void> refresh() async {
    state = const SeatingState.loading();
    await _load();
  }

  Future<void> createTable({
    required String name,
    required int capacity,
    String shape = 'round',
    String? section,
  }) async {
    final table = await ref.read(seatingRepositoryProvider).createTable(
          name: name,
          capacity: capacity,
          shape: shape,
          section: section,
        );
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded != null) {
      state = SeatingState.loaded(
        loaded.data.copyWith(tables: [...loaded.data.tables, table]),
      );
    }
  }

  Future<void> deleteTable(String tableId) async {
    await ref.read(seatingRepositoryProvider).deleteTable(tableId);
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded != null) {
      final tables = loaded.data.tables.where((t) => t.id != tableId).toList();
      final removed = loaded.data.tables.firstWhere((t) => t.id == tableId);
      final releasedGuests = removed.assignments
          .map((a) => UnassignedGuest(
                id: a.guestId,
                firstName: a.guestFirstName,
                lastName: a.guestLastName,
                rsvpStatus: a.guestRsvpStatus,
              ))
          .toList();
      final newUnassigned = [
        ...loaded.data.unassignedGuests,
        ...releasedGuests,
      ]..sort((a, b) => a.firstName.compareTo(b.firstName));
      final oldStats = loaded.data.stats;
      state = SeatingState.loaded(loaded.data.copyWith(
        tables: tables,
        unassignedGuests: newUnassigned,
        stats: oldStats.copyWith(
          assigned: oldStats.assigned - removed.assignments.length,
          unassigned: oldStats.unassigned + removed.assignments.length,
        ),
      ));
    }
  }

  Future<void> assignGuest({
    required String tableId,
    required String guestId,
  }) async {
    final updatedTable = await ref.read(seatingRepositoryProvider).assignGuest(
          tableId: tableId,
          guestId: guestId,
        );
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded == null) return;

    final tables = loaded.data.tables.map((t) {
      if (t.id == tableId) return updatedTable;
      // Remove guest from any other table (moved)
      return t.copyWith(
        assignments: t.assignments.where((a) => a.guestId != guestId).toList(),
      );
    }).toList();

    final unassigned =
        loaded.data.unassignedGuests.where((g) => g.id != guestId).toList();

    final wasAlreadyAssigned = loaded.data.tables
        .any((t) => t.id != tableId && t.assignments.any((a) => a.guestId == guestId));
    final oldStats = loaded.data.stats;

    state = SeatingState.loaded(loaded.data.copyWith(
      tables: tables,
      unassignedGuests: unassigned,
      stats: wasAlreadyAssigned
          ? oldStats
          : oldStats.copyWith(
              assigned: oldStats.assigned + 1,
              unassigned: oldStats.unassigned - 1,
            ),
    ));
  }

  Future<void> unassignGuest({
    required String tableId,
    required String guestId,
  }) async {
    await ref
        .read(seatingRepositoryProvider)
        .unassignGuest(tableId: tableId, guestId: guestId);

    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded == null) return;

    SeatingTable? sourceTable;
    TableAssignment? removedAssignment;
    final tables = loaded.data.tables.map((t) {
      if (t.id != tableId) return t;
      final assignment = t.assignments.firstWhere((a) => a.guestId == guestId,
          orElse: () => const TableAssignment(
              id: '', guestId: '', guestFirstName: '', guestLastName: ''));
      if (assignment.id.isNotEmpty) {
        sourceTable = t;
        removedAssignment = assignment;
      }
      return t.copyWith(
        assignments: t.assignments.where((a) => a.guestId != guestId).toList(),
      );
    }).toList();

    if (removedAssignment == null) return;

    final released = UnassignedGuest(
      id: removedAssignment!.guestId,
      firstName: removedAssignment!.guestFirstName,
      lastName: removedAssignment!.guestLastName,
      rsvpStatus: removedAssignment!.guestRsvpStatus,
    );
    final newUnassigned = [...loaded.data.unassignedGuests, released]
      ..sort((a, b) => a.firstName.compareTo(b.firstName));

    final oldStats = loaded.data.stats;
    state = SeatingState.loaded(loaded.data.copyWith(
      tables: tables,
      unassignedGuests: newUnassigned,
      stats: oldStats.copyWith(
        assigned: oldStats.assigned - 1,
        unassigned: oldStats.unassigned + 1,
      ),
    ));
  }
}
