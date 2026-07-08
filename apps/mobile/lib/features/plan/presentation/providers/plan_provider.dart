import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class PlanState {
  final bool isLoading;
  final List<Map<String, dynamic>> tasks;
  final List<Map<String, dynamic>> timelineItems;
  final List<Map<String, dynamic>> budgetItems;
  final List<Map<String, dynamic>> vendors;
  final String? error;

  const PlanState({
    this.isLoading = false,
    this.tasks = const [],
    this.timelineItems = const [],
    this.budgetItems = const [],
    this.vendors = const [],
    this.error,
  });

  PlanState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? tasks,
    List<Map<String, dynamic>>? timelineItems,
    List<Map<String, dynamic>>? budgetItems,
    List<Map<String, dynamic>>? vendors,
    String? error,
  }) => PlanState(
    isLoading: isLoading ?? this.isLoading,
    tasks: tasks ?? this.tasks,
    timelineItems: timelineItems ?? this.timelineItems,
    budgetItems: budgetItems ?? this.budgetItems,
    vendors: vendors ?? this.vendors,
    error: error ?? this.error,
  );
}

class PlanNotifier extends StateNotifier<PlanState> {
  final ApiClient _api;
  PlanNotifier(this._api) : super(const PlanState(isLoading: true)) {
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      final results = await Future.wait([
        _api.get('/plan/tasks'),
        _api.get('/plan/timeline'),
        _api.get('/plan/budget'),
        _api.get('/plan/vendors'),
      ]);

      List<Map<String, dynamic>> extract(dynamic res) {
        if (res is Map && res['data'] != null) return (res['data'] as List).cast<Map<String, dynamic>>();
        if (res is List) return res.cast<Map<String, dynamic>>();
        return [];
      }

      state = state.copyWith(
        isLoading: false,
        tasks: extract(results[0]),
        timelineItems: extract(results[1]),
        budgetItems: extract(results[2]),
        vendors: extract(results[3]),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleTask(int taskId) async {
    final idx = state.tasks.indexWhere((t) => t['id'] == taskId);
    if (idx == -1) return;
    final updated = Map<String, dynamic>.from(state.tasks[idx]);
    updated['completed'] = !(updated['completed'] == true);
    final newTasks = [...state.tasks];
    newTasks[idx] = updated;
    state = state.copyWith(tasks: newTasks);
    try {
      await _api.patch('/plan/tasks/$taskId', data: {'completed': updated['completed']});
    } catch (_) {
      // revert
      newTasks[idx] = state.tasks[idx];
      state = state.copyWith(tasks: [...state.tasks]);
    }
  }

  Future<void> refresh() => _loadAll();
}

final planProvider = StateNotifierProvider<PlanNotifier, PlanState>((ref) {
  return PlanNotifier(ref.read(apiClientProvider));
});
