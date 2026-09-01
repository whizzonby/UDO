import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';

class PlanState {
  final bool isLoading;
  final List<Map<String, dynamic>> tasks;
  final List<Map<String, dynamic>> timelineItems;
  final List<Map<String, dynamic>> budgetItems;
  final Map<String, dynamic> budgetSummary;
  final List<Map<String, dynamic>> vendors;
  final Map<String, dynamic> vendorSummary;
  final String? tasksError;
  final String? timelineError;
  final String? budgetError;
  final String? vendorsError;
  final bool isOffline;
  final DateTime? cachedAt;

  const PlanState({
    this.isLoading = false,
    this.tasks = const [],
    this.timelineItems = const [],
    this.budgetItems = const [],
    this.budgetSummary = const {},
    this.vendors = const [],
    this.vendorSummary = const {},
    this.tasksError,
    this.timelineError,
    this.budgetError,
    this.vendorsError,
    this.isOffline = false,
    this.cachedAt,
  });

  PlanState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? tasks,
    List<Map<String, dynamic>>? timelineItems,
    List<Map<String, dynamic>>? budgetItems,
    Map<String, dynamic>? budgetSummary,
    List<Map<String, dynamic>>? vendors,
    Map<String, dynamic>? vendorSummary,
    String? tasksError,
    String? timelineError,
    String? budgetError,
    String? vendorsError,
    bool? isOffline,
    DateTime? cachedAt,
  }) =>
      PlanState(
        isLoading: isLoading ?? this.isLoading,
        tasks: tasks ?? this.tasks,
        timelineItems: timelineItems ?? this.timelineItems,
        budgetItems: budgetItems ?? this.budgetItems,
        budgetSummary: budgetSummary ?? this.budgetSummary,
        vendors: vendors ?? this.vendors,
        vendorSummary: vendorSummary ?? this.vendorSummary,
        tasksError: tasksError,
        timelineError: timelineError,
        budgetError: budgetError,
        vendorsError: vendorsError,
        isOffline: isOffline ?? this.isOffline,
        cachedAt: cachedAt ?? this.cachedAt,
      );
}

class PlanNotifier extends StateNotifier<PlanState> {
  final ApiClient _api;
  PlanNotifier(this._api) : super(const PlanState(isLoading: true)) {
    _loadAll();
  }

  List<Map<String, dynamic>> _extract(dynamic res) {
    if (res is Map && res['data'] != null)
      return (res['data'] as List).cast<Map<String, dynamic>>();
    if (res is List) return res.cast<Map<String, dynamic>>();
    return [];
  }

  Future<
      ({
        List<Map<String, dynamic>> data,
        String? error,
        bool fromCache,
        DateTime? cachedAt
      })> _fetchSection(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _api.getCached(path, query: query);
      return (
        data: _extract(res.data),
        error: res.fromCache ? 'Showing saved data. Connect to refresh.' : null,
        fromCache: res.fromCache,
        cachedAt: res.cachedAt,
      );
    } catch (e) {
      return (
        data: <Map<String, dynamic>>[],
        error: e.toString(),
        fromCache: false,
        cachedAt: null
      );
    }
  }

  Future<
      ({
        List<Map<String, dynamic>> data,
        Map<String, dynamic> summary,
        String? error,
        bool fromCache,
        DateTime? cachedAt
      })> _fetchBudget() async {
    try {
      final cached = await _api.getCached('/plan/budget');
      final res = cached.data;
      final summary = (res is Map && res['summary'] is Map)
          ? Map<String, dynamic>.from(res['summary'] as Map)
          : <String, dynamic>{};
      return (
        data: _extract(res),
        summary: summary,
        error:
            cached.fromCache ? 'Showing saved data. Connect to refresh.' : null,
        fromCache: cached.fromCache,
        cachedAt: cached.cachedAt,
      );
    } catch (e) {
      return (
        data: <Map<String, dynamic>>[],
        summary: <String, dynamic>{},
        error: e.toString(),
        fromCache: false,
        cachedAt: null
      );
    }
  }

  Future<
      ({
        List<Map<String, dynamic>> data,
        Map<String, dynamic> summary,
        String? error,
        bool fromCache,
        DateTime? cachedAt
      })> _fetchVendors() async {
    try {
      final vendorsRes = await _api.getCached('/plan/vendors');
      final summaryRes = await _api.getCached('/plan/vendors/summary');
      final summaryData = summaryRes.data;
      final summary = (summaryData is Map && summaryData['data'] is Map)
          ? Map<String, dynamic>.from(summaryData['data'] as Map)
          : <String, dynamic>{};
      final fromCache = vendorsRes.fromCache || summaryRes.fromCache;
      return (
        data: _extract(vendorsRes.data),
        summary: summary,
        error: fromCache ? 'Showing saved data. Connect to refresh.' : null,
        fromCache: fromCache,
        cachedAt: vendorsRes.cachedAt ?? summaryRes.cachedAt,
      );
    } catch (e) {
      return (
        data: <Map<String, dynamic>>[],
        summary: <String, dynamic>{},
        error: e.toString(),
        fromCache: false,
        cachedAt: null
      );
    }
  }

  Future<void> loadTasksFiltered(
      {String? search, String? status, String? priority}) async {
    final result = await _fetchSection('/plan/tasks', query: {
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (status != null && status != 'All') 'status': status,
      if (priority != null && priority.isNotEmpty) 'priority': priority,
    });
    state = state.copyWith(
        tasks: result.data,
        tasksError: result.error,
        isOffline: result.fromCache,
        cachedAt: result.cachedAt);
  }

  Future<void> loadVendorsFiltered({String? search, String? status}) async {
    final query = {
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (status != null && status != 'all') 'status': status,
    };
    try {
      final vendorsRes = await _api.getCached('/plan/vendors', query: query);
      state = state.copyWith(
        vendors: _extract(vendorsRes.data),
        vendorsError: vendorsRes.fromCache
            ? 'Showing saved data. Connect to refresh.'
            : null,
        isOffline: vendorsRes.fromCache,
        cachedAt: vendorsRes.cachedAt,
      );
    } catch (e) {
      state = state.copyWith(vendorsError: e.toString());
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
    final vendorsFuture = _fetchVendors();

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
      vendorSummary: vendors.summary,
      vendorsError: vendors.error,
      isOffline: tasks.fromCache ||
          timeline.fromCache ||
          budget.fromCache ||
          vendors.fromCache,
      cachedAt: tasks.cachedAt ??
          timeline.cachedAt ??
          budget.cachedAt ??
          vendors.cachedAt,
    );
  }

  Future<void> refresh() => _loadAll();

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
      await _api.patch('/plan/tasks/$taskId',
          data: {'completed': updated['completed']});
    } catch (_) {
      final reverted = [...state.tasks];
      reverted[idx] = original;
      state = state.copyWith(tasks: reverted);
    }
  }

  Future<bool> updateTask(
    int taskId, {
    String? title,
    String? category,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? priority,
  }) async {
    final idx = state.tasks.indexWhere((t) => t['id'] == taskId);
    if (idx == -1) return false;
    try {
      final res = await _api.patch('/plan/tasks/$taskId', data: {
        if (title != null) 'title': title,
        if (category != null) 'category': category,
        if (clearDueDate)
          'due_date': null
        else if (dueDate != null)
          'due_date': dueDate.toIso8601String().split('T').first,
        if (priority != null) 'priority': priority,
      });
      final updated = (res is Map && res['data'] != null)
          ? res['data'] as Map<String, dynamic>
          : res as Map<String, dynamic>;
      final list = [...state.tasks];
      list[idx] = updated;
      state = state.copyWith(tasks: list);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTask(int taskId) async {
    final idx = state.tasks.indexWhere((t) => t['id'] == taskId);
    if (idx == -1) return false;
    final original = state.tasks[idx];
    final optimistic = [...state.tasks]..removeAt(idx);
    state = state.copyWith(tasks: optimistic);
    try {
      await _api.delete('/plan/tasks/$taskId');
      return true;
    } catch (_) {
      final reverted = [...state.tasks];
      reverted.insert(idx, original);
      state = state.copyWith(tasks: reverted);
      return false;
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
        if (description != null && description.isNotEmpty)
          'description': description,
        if (category != null && category.isNotEmpty) 'category': category,
        if (dueDate != null)
          'due_date': dueDate.toIso8601String().split('T').first,
        'priority': priority,
      });
      final created = (res is Map && res['data'] != null)
          ? res['data'] as Map<String, dynamic>
          : res as Map<String, dynamic>;
      state = state.copyWith(tasks: [...state.tasks, created]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createTimelineItem({
    required String title,
    String? eventType,
    String? eventDate,
    String? startTime,
    String? endTime,
    String? location,
    String? notes,
    bool visibleToGuests = true,
  }) async {
    try {
      final res = await _api.post('/plan/timeline', data: {
        'title': title,
        if (eventType != null && eventType.isNotEmpty) 'event_type': eventType,
        if (eventDate != null && eventDate.isNotEmpty) 'event_date': eventDate,
        if (startTime != null && startTime.isNotEmpty) 'start_time': startTime,
        if (endTime != null && endTime.isNotEmpty) 'end_time': endTime,
        if (location != null && location.isNotEmpty) 'location': location,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'visible_to_guests': visibleToGuests,
      });
      final created = (res is Map && res['data'] != null)
          ? res['data'] as Map<String, dynamic>
          : res as Map<String, dynamic>;
      state =
          state.copyWith(timelineItems: [...state.timelineItems, created]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateTimelineItem({
    required int id,
    required String title,
    String? eventType,
    String? eventDate,
    String? startTime,
    String? endTime,
    String location = '',
    String notes = '',
    bool visibleToGuests = true,
  }) async {
    try {
      final res = await _api.patch('/plan/timeline/$id', data: {
        'title': title,
        'event_type': eventType,
        if (eventDate != null && eventDate.isNotEmpty) 'event_date': eventDate,
        if (startTime != null && startTime.isNotEmpty) 'start_time': startTime,
        if (endTime != null && endTime.isNotEmpty) 'end_time': endTime,
        'location': location,
        'notes': notes,
        'visible_to_guests': visibleToGuests,
      });
      final updated = (res is Map && res['data'] != null)
          ? res['data'] as Map<String, dynamic>
          : res as Map<String, dynamic>;
      state = state.copyWith(
          timelineItems: state.timelineItems
              .map((item) => item['id'] == id ? updated : item)
              .toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTimelineItem(int id) async {
    try {
      await _api.delete('/plan/timeline/$id');
      state = state.copyWith(
          timelineItems:
              state.timelineItems.where((item) => item['id'] != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Returns the created budget item's id on success, or null on failure.
  Future<int?> createBudgetItem({
    required String name,
    String? category,
    int? vendorId,
    double? estimatedAmount,
    double? actualAmount,
    double? paidAmount,
    String? paymentStatus,
    String? dueDate,
    String? note,
  }) async {
    try {
      final res = await _api.post('/plan/budget', data: {
        'name': name,
        if (category != null && category.isNotEmpty) 'category': category,
        if (vendorId != null) 'vendor_id': vendorId,
        if (estimatedAmount != null) 'estimated_amount': estimatedAmount,
        if (actualAmount != null) 'actual_amount': actualAmount,
        if (paidAmount != null) 'paid_amount': paidAmount,
        if (paymentStatus != null && paymentStatus.isNotEmpty)
          'payment_status': paymentStatus,
        if (dueDate != null && dueDate.isNotEmpty) 'due_date': dueDate,
        if (note != null && note.isNotEmpty) 'notes': note,
      }) as Map<String, dynamic>;
      final budget = await _fetchBudget();
      state = state.copyWith(
          budgetItems: budget.data,
          budgetSummary: budget.summary,
          budgetError: budget.error);
      final created = res['data'];
      return created is Map ? created['id'] as int? : null;
    } catch (_) {
      return null;
    }
  }

  /// Returns the created vendor's id on success, or null on failure.
  Future<int?> createVendor({
    required String name,
    String? category,
    String? contactPerson,
    String? email,
    String? phone,
    String bookingStatus = 'researching',
    String priority = 'medium',
    String? notes,
  }) async {
    try {
      final res = await _api.post('/plan/vendors', data: {
        'name': name,
        if (category != null && category.isNotEmpty) 'category': category,
        if (contactPerson != null && contactPerson.isNotEmpty)
          'contact_person': contactPerson,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'booking_status': bookingStatus,
        'priority': priority,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }) as Map<String, dynamic>;
      final vendors = await _fetchVendors();
      state = state.copyWith(
          vendors: vendors.data,
          vendorSummary: vendors.summary,
          vendorsError: vendors.error);
      final created = res['data'];
      return created is Map ? created['id'] as int? : null;
    } catch (_) {
      return null;
    }
  }

  /// Adds a payment-schedule milestone (e.g. deposit/progress/final, or an
  /// unpaid invoice) to an existing vendor-linked budget item. `document`
  /// attaches a supporting file (invoice/receipt image) to the milestone.
  Future<bool> createPaymentSchedule({
    required int budgetItemId,
    required String label,
    required double amount,
    String? dueDate,
    String? notes,
    List<int>? documentBytes,
    String? documentFilename,
  }) async {
    try {
      dynamic data = {
        'label': label,
        'amount': amount,
        if (dueDate != null && dueDate.isNotEmpty) 'due_date': dueDate,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };
      if (documentBytes != null) {
        data = FormData.fromMap({
          ...data,
          'receipt': MultipartFile.fromBytes(documentBytes,
              filename: documentFilename ?? 'invoice'),
        });
      }
      await _api.post('/plan/budget/$budgetItemId/payment-schedules',
          data: data);
      final budget = await _fetchBudget();
      state = state.copyWith(
          budgetItems: budget.data,
          budgetSummary: budget.summary,
          budgetError: budget.error);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Marks an existing pending/scheduled milestone as paid. Returns null on
  /// success, or a human-readable error message (from the server when
  /// available) on failure.
  Future<String?> payVendorSchedule({
    required int scheduleId,
    double? amount,
    String? paymentMethod,
    String? reference,
    String? notes,
    List<int>? receiptBytes,
    String? receiptFilename,
  }) async {
    try {
      dynamic data = {
        if (amount != null) 'amount': amount,
        if (paymentMethod != null && paymentMethod.isNotEmpty)
          'payment_method': paymentMethod,
        if (reference != null && reference.isNotEmpty) 'reference': reference,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };
      if (receiptBytes != null) {
        data = FormData.fromMap({
          ...data,
          'receipt': MultipartFile.fromBytes(receiptBytes,
              filename: receiptFilename ?? 'receipt'),
        });
      }
      await _api.post('/plan/budget/payment-schedules/$scheduleId/mark-paid',
          data: data);
      final budget = await _fetchBudget();
      state = state.copyWith(
          budgetItems: budget.data,
          budgetSummary: budget.summary,
          budgetError: budget.error);
      return null;
    } catch (e) {
      return humanizeError(e);
    }
  }

  /// Records a one-off payment against a budget item that has no predefined
  /// milestone — creates the schedule row already marked paid. Works for
  /// vendor-linked items (paying an ad-hoc amount) and non-vendor category
  /// budgets alike (e.g. logging a Home Depot receipt under "Decor").
  /// Returns null on success, or a human-readable error message on failure.
  Future<String?> createAdHocPayment({
    required int budgetItemId,
    required String label,
    required double amount,
    String? paymentMethod,
    String? reference,
    String? notes,
    String? dueDate,
    List<int>? receiptBytes,
    String? receiptFilename,
  }) async {
    try {
      dynamic data = {
        'label': label,
        'amount': amount,
        'status': 'paid',
        if (paymentMethod != null && paymentMethod.isNotEmpty)
          'payment_method': paymentMethod,
        if (reference != null && reference.isNotEmpty) 'reference': reference,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (dueDate != null && dueDate.isNotEmpty) 'due_date': dueDate,
      };
      if (receiptBytes != null) {
        data = FormData.fromMap({
          ...data,
          'receipt': MultipartFile.fromBytes(receiptBytes,
              filename: receiptFilename ?? 'receipt'),
        });
      }
      await _api.post('/plan/budget/$budgetItemId/payment-schedules',
          data: data);
      final budget = await _fetchBudget();
      state = state.copyWith(
          budgetItems: budget.data,
          budgetSummary: budget.summary,
          budgetError: budget.error);
      return null;
    } catch (e) {
      return humanizeError(e);
    }
  }

  Future<int> bulkUpdateTasks(
      List<int> ids, Map<String, dynamic> updates) async {
    if (ids.isEmpty || updates.isEmpty) return 0;
    try {
      final res = await _api.post('/plan/tasks/bulk-update',
              data: {'ids': ids, 'updates': updates, 'confirm': true})
          as Map<String, dynamic>;
      final updated = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      final updatedById = {for (final task in updated) task['id']: task};
      state = state.copyWith(
          tasks: state.tasks
              .map((task) => updatedById[task['id']] ?? task)
              .toList());
      return res['updated'] as int? ?? updated.length;
    } catch (_) {
      return 0;
    }
  }

  Future<(int updated, int pendingApproval)> bulkUpdateVendors(
      List<int> ids, Map<String, dynamic> updates) async {
    if (ids.isEmpty || updates.isEmpty) return (0, 0);
    try {
      final res = await _api.post('/plan/vendors/bulk-update',
              data: {'ids': ids, 'updates': updates, 'confirm': true})
          as Map<String, dynamic>;
      final updated = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      final updatedById = {for (final vendor in updated) vendor['id']: vendor};
      state = state.copyWith(
          vendors: state.vendors
              .map((vendor) => updatedById[vendor['id']] ?? vendor)
              .toList());
      return (
        res['updated'] as int? ?? updated.length,
        res['pending_approval'] as int? ?? 0
      );
    } catch (_) {
      return (0, 0);
    }
  }

  /// Updates a single vendor. `gated: true` means the change (e.g.
  /// confirming a booking) needs Decision-maker approval and hasn't been
  /// applied yet — mirrors the response shape `bulkUpdateVendors` already
  /// handles.
  Future<({bool ok, bool gated})> updateVendor(
      int vendorId, Map<String, dynamic> updates) async {
    if (updates.isEmpty) return (ok: true, gated: false);
    try {
      final res = await _api.patch('/plan/vendors/$vendorId', data: updates)
          as Map<String, dynamic>;
      final updated = res['data'];
      if (updated is Map<String, dynamic>) {
        state = state.copyWith(
            vendors: state.vendors
                .map((vendor) => vendor['id'] == vendorId ? updated : vendor)
                .toList());
      }
      return (ok: true, gated: res['gated'] == true);
    } catch (_) {
      return (ok: false, gated: false);
    }
  }

  Future<bool> deleteVendor(int vendorId) async {
    try {
      await _api.delete('/plan/vendors/$vendorId');
      state = state.copyWith(
          vendors:
              state.vendors.where((vendor) => vendor['id'] != vendorId).toList());
      return true;
    } catch (_) {
      return false;
    }
  }
}

final planProvider = StateNotifierProvider<PlanNotifier, PlanState>((ref) {
  return PlanNotifier(ref.read(apiClientProvider));
});
