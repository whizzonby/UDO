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
    @JsonKey(name: 'is_complete') @Default(false) bool isComplete,
    @JsonKey(name: 'due_date') DateTime? dueDate,
    @JsonKey(name: 'description') String? notes,
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
    @Default(VendorStatus.shortlisted) VendorStatus status,
    @JsonKey(name: 'contact_name') String? contactName,
    @JsonKey(name: 'contact_phone') String? contactPhone,
    @JsonKey(name: 'contact_email') String? contactEmail,
    @JsonKey(name: 'contract_amount') @Default(0.0) double contractAmount,
    @JsonKey(name: 'deposit_amount') @Default(0.0) double paidAmount,
    String? notes,
  }) = _Vendor;

  factory Vendor.fromJson(Map<String, dynamic> json) =>
      _$VendorFromJson(json);
}

@JsonEnum(valueField: 'value')
enum VendorStatus {
  shortlisted('shortlisted'),
  booked('booked'),
  confirmed('confirmed'),
  paid('paid'),
  cancelled('cancelled');

  const VendorStatus(this.value);
  final String value;

  String get label => switch (this) {
        VendorStatus.shortlisted => 'Shortlisted',
        VendorStatus.booked => 'Booked',
        VendorStatus.confirmed => 'Confirmed',
        VendorStatus.paid => 'Paid',
        VendorStatus.cancelled => 'Cancelled',
      };
}

// ─── Timeline event ───────────────────────────────────────────────────────────

@freezed
abstract class TimelineEvent with _$TimelineEvent {
  const factory TimelineEvent({
    required String id,
    required String title,
    @JsonKey(name: 'event_date') required DateTime date,
    @JsonKey(name: 'start_time') String? time,
    @JsonKey(name: 'end_time') String? endTime,
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
    @JsonKey(name: 'name') required String title,
    required String category,
    @JsonKey(name: 'budgeted_amount') @Default(0.0) double budgetedAmount,
    @JsonKey(name: 'actual_amount') @Default(0.0) double paidAmount,
    @JsonKey(name: 'vendor_id') String? vendorId,
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
    @Default(0.0) double totalBudget,
    @Default('USD') String currency,
  }) = _PlanData;

  factory PlanData.fromJson(Map<String, dynamic> json) =>
      _$PlanDataFromJson(json);
}
