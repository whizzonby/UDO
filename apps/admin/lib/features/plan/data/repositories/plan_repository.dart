import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../models/plan_models.dart';

part 'plan_repository.g.dart';

@Riverpod(keepAlive: true)
PlanRepository planRepository(Ref ref) =>
    ApiPlanRepository(ref.watch(apiClientProvider));

abstract class PlanRepository {
  Future<PlanData> getPlanData();
  Future<PlanTask> addTask(PlanTask task);
  Future<PlanTask> updateTask(PlanTask task);
  Future<void> deleteTask(String id);
  Future<Vendor> addVendor(Vendor vendor);
  Future<Vendor> updateVendor(Vendor vendor);
  Future<void> deleteVendor(String id);
  Future<BudgetItem> addBudgetItem(BudgetItem item);
  Future<BudgetItem> updateBudgetItem(BudgetItem item);
  Future<void> deleteBudgetItem(String id);
  Future<TimelineEvent> addTimelineEvent(TimelineEvent event);
  Future<void> deleteTimelineEvent(String id);
}

class ApiPlanRepository implements PlanRepository {
  const ApiPlanRepository(this._dio);

  final Dio _dio;

  // ─── Fetch all plan data in parallel ────────────────────────────────────────

  @override
  Future<PlanData> getPlanData() async {
    final results = await Future.wait([
      _dio.get('/plan/tasks'),
      _dio.get('/plan/vendors'),
      _dio.get('/plan/budget'),
      _dio.get('/plan/timeline'),
    ]);

    final tasks = (results[0].data as List)
        .map((j) => PlanTask.fromJson(j as Map<String, dynamic>))
        .toList();
    final vendors = (results[1].data as List)
        .map((j) => Vendor.fromJson(j as Map<String, dynamic>))
        .toList();
    final budgetItems = (results[2].data as List)
        .map((j) => BudgetItem.fromJson(j as Map<String, dynamic>))
        .toList();
    final timeline = (results[3].data as List)
        .map((j) => TimelineEvent.fromJson(j as Map<String, dynamic>))
        .toList();

    return PlanData(
      tasks: tasks,
      vendors: vendors,
      budgetItems: budgetItems,
      timeline: timeline,
    );
  }

  // ─── Tasks ──────────────────────────────────────────────────────────────────

  @override
  Future<PlanTask> addTask(PlanTask task) async {
    final response = await _dio.post('/plan/tasks', data: _taskBody(task));
    return PlanTask.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PlanTask> updateTask(PlanTask task) async {
    final response = await _dio.put('/plan/tasks/${task.id}',
        data: _taskBody(task));
    return PlanTask.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTask(String id) => _dio.delete('/plan/tasks/$id');

  Map<String, dynamic> _taskBody(PlanTask t) => {
        'title': t.title,
        'category': t.category,
        'priority': t.priority.value,
        'status': t.isComplete ? 'complete' : 'pending',
        if (t.dueDate != null)
          'due_date': t.dueDate!.toIso8601String().substring(0, 10),
        if (t.notes != null) 'description': t.notes,
      };

  // ─── Vendors ────────────────────────────────────────────────────────────────

  @override
  Future<Vendor> addVendor(Vendor vendor) async {
    final response =
        await _dio.post('/plan/vendors', data: _vendorBody(vendor));
    return Vendor.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Vendor> updateVendor(Vendor vendor) async {
    final response = await _dio.put('/plan/vendors/${vendor.id}',
        data: _vendorBody(vendor));
    return Vendor.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteVendor(String id) => _dio.delete('/plan/vendors/$id');

  Map<String, dynamic> _vendorBody(Vendor v) => {
        'name': v.name,
        'category': v.category,
        'status': v.status.value,
        if (v.contactName != null) 'contact_name': v.contactName,
        if (v.contactPhone != null) 'contact_phone': v.contactPhone,
        if (v.contactEmail != null) 'contact_email': v.contactEmail,
        if (v.contractAmount > 0) 'contract_amount': v.contractAmount,
        if (v.paidAmount > 0) 'deposit_amount': v.paidAmount,
        if (v.notes != null) 'notes': v.notes,
      };

  // ─── Budget ──────────────────────────────────────────────────────────────────

  @override
  Future<BudgetItem> addBudgetItem(BudgetItem item) async {
    final response =
        await _dio.post('/plan/budget', data: _budgetBody(item));
    return BudgetItem.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<BudgetItem> updateBudgetItem(BudgetItem item) async {
    final response = await _dio.put('/plan/budget/${item.id}',
        data: _budgetBody(item));
    return BudgetItem.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteBudgetItem(String id) =>
      _dio.delete('/plan/budget/$id');

  Map<String, dynamic> _budgetBody(BudgetItem b) => {
        'name': b.title,
        'category': b.category,
        'budgeted_amount': b.budgetedAmount,
        if (b.paidAmount > 0) 'actual_amount': b.paidAmount,
        if (b.vendorId != null) 'vendor_id': b.vendorId,
        if (b.notes != null) 'notes': b.notes,
      };

  // ─── Timeline ────────────────────────────────────────────────────────────────

  @override
  Future<TimelineEvent> addTimelineEvent(TimelineEvent event) async {
    final response =
        await _dio.post('/plan/timeline', data: _timelineBody(event));
    return TimelineEvent.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTimelineEvent(String id) =>
      _dio.delete('/plan/timeline/$id');

  Map<String, dynamic> _timelineBody(TimelineEvent e) => {
        'title': e.title,
        'event_date': e.date.toIso8601String().substring(0, 10),
        if (e.time != null) 'start_time': e.time,
        if (e.endTime != null) 'end_time': e.endTime,
        if (e.description != null) 'description': e.description,
        if (e.location != null) 'location': e.location,
      };
}
