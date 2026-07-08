import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class PlanState {
  final bool isLoading;
  final List<Map<String, dynamic>> tasks;
  final List<Map<String, dynamic>> timelineItems;
  final List<Map<String, dynamic>> budgetItems;
  final Map<String, dynamic> budgetSummary;
  final List<Map<String, dynamic>> vendors;
  final String? tasksError;
  final String? timelineError;
  final String? budgetError;
  final String? vendorsError;

  const PlanState({
    this.isLoading = false,
    this.tasks = const [],
    this.timelineItems = const [],
    this.budgetItems = const [],
    this.budgetSummary = const {},
    this.vendors = const [],
    this.tasksError,
    this.timelineError,
    this.budgetError,
    this.vendorsError,
  });

  PlanState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? tasks,
    List<Map<String, dynamic>>? timelineItems,
    List<Map<String, dynamic>>? budgetItems,
    Map<String, dynamic>? budgetSummary,
    List<Map<String, dynamic>>? vendors,
    String? tasksError,
    String? timelineError,
    String? budgetError,
    String? vendorsError,
  }) => PlanState(
    isLoading: isLoading ?? this.isLoading,
    tasks: tasks ?? this.tasks,
    timelineItems: timelineItems ?? this.timelineItems,
    budgetItems: budgetItems ?? this.budgetItems,
    budgetSummary: budgetSummary ?? this.budgetSummary,
    vendors: vendors ?? this.vendors,
    tasksError: tasksError,
    timelineError: timelineError,
    budgetError: budgetError,
    vendorsError: vendorsError,
  );
}

class PlanNotifier extends StateNotifier<PlanState> {
  final ApiClient _api;
  PlanNotifier(this._api) : super(const PlanState(isLoading: true)) {
    _loadAll();
  }

  List<Map<String, dynamic>> _extract(dynamic res) {
    if (res is Map && res['data'] != null) return (res['data'] as List).cast<Map<String, dynamic>>();
    if (res is List) return res.cast<Map<String, dynamic>>();
    return [];
  }

  Future<({List<Map<String, dynamic>> data, String? error})> _fetchSection(String path) async {
    try {
      return (data: _extract(await _api.get(path)), error: null);
    } catch (e) {
      return (data: <Map<String, dynamic>>[], error: e.toString());
    }
  }

  Future<({List<Map<String, dynamic>> data, Map<String, dynamic> summary, String? error})> _fetchBudget() async {
    try {
      final res = await _api.get('/plan/budget');
      final summary = (res is Map && res['summary'] is Map) ? Map<String, dynamic>.from(res['summary'] as Map) : <String, dynamic>{};
      return (data: _extract(res), summary: summary, error: null);
    } catch (e) {
      return (data: <Map<String, dynamic>>[], summary: <String, dynamic>{}, error: e.toString());
    }
  }

  /// Each section loads independently — one endpoint failing (auth hiccup,
  /// 500, unexpected response shape) no longer blanks the other three tabs
  /// with no explanation. Every section gets its own data and its own error.
  Future<void> _loadAll() async {
    state = state.copyWith(isLoading: true);

    // Fire all four in parallel (not Future.wait — the budget fetch returns
    // a differently-shaped record, so the futures aren't homogeneous), then
    // await each independently so one failing section can't blank the rest.
    final tasksFuture = _fetchSection('/plan/tasks');
    final timelineFuture = _fetchSection('/plan/timeline');
    final budgetFuture = _fetchBudget();
    final vendorsFuture = _fetchSection('/plan/vendors');

    final tasks = await tasksFuture;
    final timeline = await timelineFuture;
    final budget = await budgetFuture;
    final vendors = await vendorsFuture;

    state = state.copyWith(
      isLoading: false,
      tasks: tasks.data,
      tasksError: tasks.error,
      timelineItems: timeline.data,
      timelineError: timeline.error,
      budgetItems: budget.data,
      budgetSummary: budget.summary,
      budgetError: budget.error,
      vendors: vendors.data,
      vendorsError: vendors.error,
    );
  }

  Future<void> toggleTask(int taskId) async {
    final idx = state.tasks.indexWhere((t) => t['id'] == taskId);
    if (idx == -1) return;
    final original = state.tasks[idx];
    final updated = Map<String, dynamic>.from(original);
    updated['completed'] = !(updated['completed'] == true);
    final optimistic = [...state.tasks];
    optimistic[idx] = updated;
    state = state.copyWith(tasks: optimistic);
    try {
      await _api.patch('/plan/tasks/$taskId', data: {'completed': updated['completed']});
    } catch (_) {
      final reverted = [...state.tasks];
      reverted[idx] = original;
      state = state.copyWith(tasks: reverted);
    }
  }

  Future<bool> createTask({
    required String title,
    String? description,
    String? category,
    DateTime? dueDate,
    String priority = 'medium',
  }) async {
    try {
      final res = await _api.post('/plan/tasks', data: {
        'title': title,
        if (description != null && description.isNotEmpty) 'description': description,
        if (category != null && category.isNotEmpty) 'category': category,
        if (dueDate != null) 'due_date': dueDate.toIso8601String().split('T').first,
        'priority': priority,
      });
      final created = (res is Map && res['data'] != null) ? res['data'] as Map<String, dynamic> : res as Map<String, dynamic>;
      state = state.copyWith(tasks: [...state.tasks, created]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() => _loadAll();
}

final planProvider = StateNotifierProvider<PlanNotifier, PlanState>((ref) {
  return PlanNotifier(ref.read(apiClientProvider));
});
