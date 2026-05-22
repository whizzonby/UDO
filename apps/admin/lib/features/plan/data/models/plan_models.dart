import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_models.freezed.dart';
part 'plan_models.g.dart';

// ─── Category constants ───────────────────────────────────────────────────────

const kTaskCategories = [
  'Venue & Catering',
  'Invitations',
  'Florals & Decor',
  'Entertainment',
  'Logistics',
  'Other',
];

const kVendorCategories = [
  'Venue',
  'Catering',
  'Photography',
  'Florals & Decor',
  'Entertainment',
  'Attire',
  'Cake',
  'Transport',
  'Videography',
  'Bar Service',
  'Other',
];

const kBudgetCategories = [
  'Venue',
  'Catering',
  'Photography',
  'Florals & Decor',
  'Entertainment',
  'Attire',
  'Other',
];

// ─── Task ─────────────────────────────────────────────────────────────────────

@freezed
abstract class PlanTask with _$PlanTask {
  const factory PlanTask({
    required String id,
    required String title,
    required String category,
    @Default(TaskPriority.medium) TaskPriority priority,
    @Default(false) bool isComplete,
    DateTime? dueDate,
    String? notes,
  }) = _PlanTask;

  factory PlanTask.fromJson(Map<String, dynamic> json) =>
      _$PlanTaskFromJson(json);
}

@JsonEnum(valueField: 'value')
enum TaskPriority {
  low('low'),
  medium('medium'),
  high('high');

  const TaskPriority(this.value);
  final String value;
}

// ─── Vendor ───────────────────────────────────────────────────────────────────

@freezed
abstract class Vendor with _$Vendor {
  const factory Vendor({
    required String id,
    required String name,
    required String category,
    @Default(VendorStatus.potential) VendorStatus status,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    @Default(0.0) double contractAmount,
    @Default(0.0) double paidAmount,
    String? notes,
  }) = _Vendor;

  factory Vendor.fromJson(Map<String, dynamic> json) =>
      _$VendorFromJson(json);
}

@JsonEnum(valueField: 'value')
enum VendorStatus {
  potential('potential'),
  booked('booked'),
  confirmed('confirmed'),
  cancelled('cancelled');

  const VendorStatus(this.value);
  final String value;

  String get label => switch (this) {
        VendorStatus.potential => 'Potential',
        VendorStatus.booked => 'Booked',
        VendorStatus.confirmed => 'Confirmed',
        VendorStatus.cancelled => 'Cancelled',
      };
}

// ─── Timeline event ───────────────────────────────────────────────────────────

@freezed
abstract class TimelineEvent with _$TimelineEvent {
  const factory TimelineEvent({
    required String id,
    required String title,
    required DateTime date,
    String? time,
    String? description,
    String? category,
    String? location,
    @Default(false) bool isCompleted,
  }) = _TimelineEvent;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) =>
      _$TimelineEventFromJson(json);
}

// ─── Budget item ──────────────────────────────────────────────────────────────

@freezed
abstract class BudgetItem with _$BudgetItem {
  const factory BudgetItem({
    required String id,
    required String title,
    required String category,
    @Default(0.0) double budgetedAmount,
    @Default(0.0) double paidAmount,
    String? vendorId,
    String? notes,
  }) = _BudgetItem;

  factory BudgetItem.fromJson(Map<String, dynamic> json) =>
      _$BudgetItemFromJson(json);
}

// ─── Top-level plan data ──────────────────────────────────────────────────────

@freezed
abstract class PlanData with _$PlanData {
  const factory PlanData({
    required List<PlanTask> tasks,
    required List<Vendor> vendors,
    required List<BudgetItem> budgetItems,
    required List<TimelineEvent> timeline,
    @Default(45000.0) double totalBudget,
    @Default('USD') String currency,
  }) = _PlanData;

  factory PlanData.fromJson(Map<String, dynamic> json) =>
      _$PlanDataFromJson(json);
}
