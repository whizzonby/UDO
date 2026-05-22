import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/plan_models.dart';
import '../../data/repositories/plan_repository.dart';
import '../../domain/plan_state.dart';

part 'plan_provider.g.dart';

@Riverpod(keepAlive: true)
class PlanNotifier extends _$PlanNotifier {
  @override
  PlanState build() {
    _load();
    return const PlanState.loading();
  }

  Future<void> _load() async {
    try {
      final data = await ref.read(planRepositoryProvider).getPlanData();
      state = PlanState.loaded(data);
    } catch (e) {
      state = PlanState.error(e.toString());
    }
  }

  Future<void> refresh() async {
    state = const PlanState.loading();
    await _load();
  }

  // ─── Task mutations ─────────────────────────────────────────────────────────

  Future<void> toggleTask(String id) async {
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded == null) return;
    final tasks = loaded.data.tasks.map((t) {
      return t.id == id ? t.copyWith(isComplete: !t.isComplete) : t;
    }).toList();
    state = PlanState.loaded(loaded.data.copyWith(tasks: tasks));
    await ref
        .read(planRepositoryProvider)
        .updateTask(tasks.firstWhere((t) => t.id == id));
  }

  Future<void> addTask(PlanTask task) async {
    await ref.read(planRepositoryProvider).addTask(task);
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded != null) {
      state = PlanState.loaded(
        loaded.data.copyWith(tasks: [...loaded.data.tasks, task]),
      );
    }
  }

  Future<void> updateTask(PlanTask task) async {
    await ref.read(planRepositoryProvider).updateTask(task);
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded != null) {
      final tasks =
          loaded.data.tasks.map((t) => t.id == task.id ? task : t).toList();
      state = PlanState.loaded(loaded.data.copyWith(tasks: tasks));
    }
  }

  Future<void> deleteTask(String id) async {
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded == null) return;
    state = PlanState.loaded(
      loaded.data
          .copyWith(tasks: loaded.data.tasks.where((t) => t.id != id).toList()),
    );
    await ref.read(planRepositoryProvider).deleteTask(id);
  }

  // ─── Vendor mutations ───────────────────────────────────────────────────────

  Future<void> addVendor(Vendor vendor) async {
    await ref.read(planRepositoryProvider).addVendor(vendor);
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded != null) {
      state = PlanState.loaded(
        loaded.data.copyWith(vendors: [...loaded.data.vendors, vendor]),
      );
    }
  }

  Future<void> updateVendor(Vendor vendor) async {
    await ref.read(planRepositoryProvider).updateVendor(vendor);
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded != null) {
      final vendors = loaded.data.vendors
          .map((v) => v.id == vendor.id ? vendor : v)
          .toList();
      state = PlanState.loaded(loaded.data.copyWith(vendors: vendors));
    }
  }

  Future<void> deleteVendor(String id) async {
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded == null) return;
    state = PlanState.loaded(
      loaded.data.copyWith(
          vendors: loaded.data.vendors.where((v) => v.id != id).toList()),
    );
    await ref.read(planRepositoryProvider).deleteVendor(id);
  }

  // ─── Budget mutations ───────────────────────────────────────────────────────

  Future<void> addBudgetItem(BudgetItem item) async {
    await ref.read(planRepositoryProvider).addBudgetItem(item);
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded != null) {
      state = PlanState.loaded(
        loaded.data
            .copyWith(budgetItems: [...loaded.data.budgetItems, item]),
      );
    }
  }

  Future<void> updateBudgetItem(BudgetItem item) async {
    await ref.read(planRepositoryProvider).updateBudgetItem(item);
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded != null) {
      final items = loaded.data.budgetItems
          .map((b) => b.id == item.id ? item : b)
          .toList();
      state = PlanState.loaded(loaded.data.copyWith(budgetItems: items));
    }
  }

  Future<void> deleteBudgetItem(String id) async {
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded == null) return;
    state = PlanState.loaded(
      loaded.data.copyWith(
          budgetItems:
              loaded.data.budgetItems.where((b) => b.id != id).toList()),
    );
    await ref.read(planRepositoryProvider).deleteBudgetItem(id);
  }

  // ─── Timeline mutations ─────────────────────────────────────────────────────

  Future<void> addTimelineEvent(TimelineEvent event) async {
    await ref.read(planRepositoryProvider).addTimelineEvent(event);
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded != null) {
      final events = [...loaded.data.timeline, event]
        ..sort((a, b) => a.date.compareTo(b.date));
      state = PlanState.loaded(loaded.data.copyWith(timeline: events));
    }
  }

  Future<void> deleteTimelineEvent(String id) async {
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded == null) return;
    state = PlanState.loaded(
      loaded.data.copyWith(
          timeline:
              loaded.data.timeline.where((e) => e.id != id).toList()),
    );
    await ref.read(planRepositoryProvider).deleteTimelineEvent(id);
  }
}
