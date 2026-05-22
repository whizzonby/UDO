import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_stats_model.freezed.dart';
part 'home_stats_model.g.dart';

// ─── Top-level aggregate ─────────────────────────────────────────────────────

@freezed
abstract class HomeStats with _$HomeStats {
  const factory HomeStats({
    required WeddingInfo wedding,
    required GuestOverview guests,
    required PlanProgress plan,
    required BudgetOverview budget,
    @Default([]) List<SmartAlert> alerts,
    @Default([]) List<UpcomingEvent> upcoming,
  }) = _HomeStats;

  factory HomeStats.fromJson(Map<String, dynamic> json) =>
      _$HomeStatsFromJson(json);
}

// ─── Wedding ─────────────────────────────────────────────────────────────────

@freezed
abstract class WeddingInfo with _$WeddingInfo {
  const factory WeddingInfo({
    required String id,
    required String partnerOneName,
    required String partnerTwoName,
    DateTime? weddingDate,
    String? venueName,
    String? venueCity,
    @Default(WeddingStatus.planning) WeddingStatus status,
  }) = _WeddingInfo;

  factory WeddingInfo.fromJson(Map<String, dynamic> json) =>
      _$WeddingInfoFromJson(json);
}

@JsonEnum(valueField: 'value')
enum WeddingStatus {
  planning('planning'),
  live('live'),
  past('past');

  const WeddingStatus(this.value);
  final String value;
}

// ─── Guests ──────────────────────────────────────────────────────────────────

@freezed
abstract class GuestOverview with _$GuestOverview {
  const factory GuestOverview({
    @Default(0) int total,
    @Default(0) int confirmed,
    @Default(0) int pending,
    @Default(0) int declined,
    @Default(0) int notInvited,
  }) = _GuestOverview;

  factory GuestOverview.fromJson(Map<String, dynamic> json) =>
      _$GuestOverviewFromJson(json);
}

// ─── Plan ─────────────────────────────────────────────────────────────────────

@freezed
abstract class PlanProgress with _$PlanProgress {
  const factory PlanProgress({
    @Default(0) int totalTasks,
    @Default(0) int completedTasks,
    @Default(0) int overdueTasks,
    @Default([]) List<PlanCategory> categories,
    @Default([]) List<RecentTask> recentTasks,
  }) = _PlanProgress;

  factory PlanProgress.fromJson(Map<String, dynamic> json) =>
      _$PlanProgressFromJson(json);
}

@freezed
abstract class PlanCategory with _$PlanCategory {
  const factory PlanCategory({
    required String name,
    required int total,
    required int completed,
  }) = _PlanCategory;

  factory PlanCategory.fromJson(Map<String, dynamic> json) =>
      _$PlanCategoryFromJson(json);
}

@freezed
abstract class RecentTask with _$RecentTask {
  const factory RecentTask({
    required String id,
    required String title,
    required bool isComplete,
    String? category,
    DateTime? dueDate,
  }) = _RecentTask;

  factory RecentTask.fromJson(Map<String, dynamic> json) =>
      _$RecentTaskFromJson(json);
}

// ─── Budget ──────────────────────────────────────────────────────────────────

@freezed
abstract class BudgetOverview with _$BudgetOverview {
  const factory BudgetOverview({
    @Default(0.0) double total,
    @Default(0.0) double allocated,
    @Default(0.0) double spent,
    @Default('USD') String currency,
    @Default([]) List<BudgetCategory> categories,
  }) = _BudgetOverview;

  factory BudgetOverview.fromJson(Map<String, dynamic> json) =>
      _$BudgetOverviewFromJson(json);
}

@freezed
abstract class BudgetCategory with _$BudgetCategory {
  const factory BudgetCategory({
    required String name,
    required double allocated,
    required double spent,
  }) = _BudgetCategory;

  factory BudgetCategory.fromJson(Map<String, dynamic> json) =>
      _$BudgetCategoryFromJson(json);
}

// ─── Smart alerts ─────────────────────────────────────────────────────────────

@freezed
abstract class SmartAlert with _$SmartAlert {
  const factory SmartAlert({
    required String id,
    required SmartAlertType type,
    required String title,
    required String body,
    String? actionLabel,
    String? actionRoute,
    DateTime? createdAt,
  }) = _SmartAlert;

  factory SmartAlert.fromJson(Map<String, dynamic> json) =>
      _$SmartAlertFromJson(json);
}

@JsonEnum(valueField: 'value')
enum SmartAlertType {
  rsvp('rsvp'),
  budget('budget'),
  vendor('vendor'),
  reminder('reminder'),
  info('info');

  const SmartAlertType(this.value);
  final String value;
}

// ─── Upcoming events ──────────────────────────────────────────────────────────

@freezed
abstract class UpcomingEvent with _$UpcomingEvent {
  const factory UpcomingEvent({
    required String id,
    required String title,
    required DateTime date,
    required String category,
    String? description,
    String? location,
  }) = _UpcomingEvent;

  factory UpcomingEvent.fromJson(Map<String, dynamic> json) =>
      _$UpcomingEventFromJson(json);
}
