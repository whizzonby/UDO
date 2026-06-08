// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeStats _$HomeStatsFromJson(Map<String, dynamic> json) => _HomeStats(
  wedding: WeddingInfo.fromJson(json['wedding'] as Map<String, dynamic>),
  guests: GuestOverview.fromJson(json['guests'] as Map<String, dynamic>),
  plan: PlanProgress.fromJson(json['plan'] as Map<String, dynamic>),
  budget: BudgetOverview.fromJson(json['budget'] as Map<String, dynamic>),
  alerts:
      (json['alerts'] as List<dynamic>?)
          ?.map((e) => SmartAlert.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  upcoming:
      (json['upcoming'] as List<dynamic>?)
          ?.map((e) => UpcomingEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  todaysFocus:
      (json['todaysFocus'] as List<dynamic>?)
          ?.map((e) => TodaysFocusItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  guidancePrompts:
      (json['guidancePrompts'] as List<dynamic>?)
          ?.map((e) => GuidancePrompt.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  priorities:
      (json['priorities'] as List<dynamic>?)
          ?.map((e) => PriorityAlert.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$HomeStatsToJson(_HomeStats instance) =>
    <String, dynamic>{
      'wedding': instance.wedding,
      'guests': instance.guests,
      'plan': instance.plan,
      'budget': instance.budget,
      'alerts': instance.alerts,
      'upcoming': instance.upcoming,
      'todaysFocus': instance.todaysFocus,
      'guidancePrompts': instance.guidancePrompts,
      'priorities': instance.priorities,
    };

_WeddingInfo _$WeddingInfoFromJson(Map<String, dynamic> json) => _WeddingInfo(
  id: json['id'] as String,
  partnerOneName: json['partnerOneName'] as String,
  partnerTwoName: json['partnerTwoName'] as String,
  weddingDate: json['weddingDate'] == null
      ? null
      : DateTime.parse(json['weddingDate'] as String),
  venueName: json['venueName'] as String?,
  venueCity: json['venueCity'] as String?,
  status:
      $enumDecodeNullable(_$WeddingStatusEnumMap, json['status']) ??
      WeddingStatus.planning,
);

Map<String, dynamic> _$WeddingInfoToJson(_WeddingInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'partnerOneName': instance.partnerOneName,
      'partnerTwoName': instance.partnerTwoName,
      'weddingDate': instance.weddingDate?.toIso8601String(),
      'venueName': instance.venueName,
      'venueCity': instance.venueCity,
      'status': _$WeddingStatusEnumMap[instance.status]!,
    };

const _$WeddingStatusEnumMap = {
  WeddingStatus.planning: 'planning',
  WeddingStatus.live: 'live',
  WeddingStatus.past: 'past',
};

_GuestOverview _$GuestOverviewFromJson(Map<String, dynamic> json) =>
    _GuestOverview(
      total: (json['total'] as num?)?.toInt() ?? 0,
      confirmed: (json['confirmed'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      declined: (json['declined'] as num?)?.toInt() ?? 0,
      notInvited: (json['notInvited'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$GuestOverviewToJson(_GuestOverview instance) =>
    <String, dynamic>{
      'total': instance.total,
      'confirmed': instance.confirmed,
      'pending': instance.pending,
      'declined': instance.declined,
      'notInvited': instance.notInvited,
    };

_PlanProgress _$PlanProgressFromJson(Map<String, dynamic> json) =>
    _PlanProgress(
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,
      overdueTasks: (json['overdueTasks'] as num?)?.toInt() ?? 0,
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => PlanCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recentTasks:
          (json['recentTasks'] as List<dynamic>?)
              ?.map((e) => RecentTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PlanProgressToJson(_PlanProgress instance) =>
    <String, dynamic>{
      'totalTasks': instance.totalTasks,
      'completedTasks': instance.completedTasks,
      'overdueTasks': instance.overdueTasks,
      'categories': instance.categories,
      'recentTasks': instance.recentTasks,
    };

_PlanCategory _$PlanCategoryFromJson(Map<String, dynamic> json) =>
    _PlanCategory(
      name: json['name'] as String,
      total: (json['total'] as num).toInt(),
      completed: (json['completed'] as num).toInt(),
    );

Map<String, dynamic> _$PlanCategoryToJson(_PlanCategory instance) =>
    <String, dynamic>{
      'name': instance.name,
      'total': instance.total,
      'completed': instance.completed,
    };

_RecentTask _$RecentTaskFromJson(Map<String, dynamic> json) => _RecentTask(
  id: json['id'] as String,
  title: json['title'] as String,
  isComplete: json['isComplete'] as bool,
  category: json['category'] as String?,
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
);

Map<String, dynamic> _$RecentTaskToJson(_RecentTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'isComplete': instance.isComplete,
      'category': instance.category,
      'dueDate': instance.dueDate?.toIso8601String(),
    };

_BudgetOverview _$BudgetOverviewFromJson(Map<String, dynamic> json) =>
    _BudgetOverview(
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      allocated: (json['allocated'] as num?)?.toDouble() ?? 0.0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => BudgetCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$BudgetOverviewToJson(_BudgetOverview instance) =>
    <String, dynamic>{
      'total': instance.total,
      'allocated': instance.allocated,
      'spent': instance.spent,
      'currency': instance.currency,
      'categories': instance.categories,
    };

_BudgetCategory _$BudgetCategoryFromJson(Map<String, dynamic> json) =>
    _BudgetCategory(
      name: json['name'] as String,
      allocated: (json['allocated'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
    );

Map<String, dynamic> _$BudgetCategoryToJson(_BudgetCategory instance) =>
    <String, dynamic>{
      'name': instance.name,
      'allocated': instance.allocated,
      'spent': instance.spent,
    };

_SmartAlert _$SmartAlertFromJson(Map<String, dynamic> json) => _SmartAlert(
  id: json['id'] as String,
  type: $enumDecode(_$SmartAlertTypeEnumMap, json['type']),
  title: json['title'] as String,
  body: json['body'] as String,
  actionLabel: json['actionLabel'] as String?,
  actionRoute: json['actionRoute'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$SmartAlertToJson(_SmartAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SmartAlertTypeEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'actionLabel': instance.actionLabel,
      'actionRoute': instance.actionRoute,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$SmartAlertTypeEnumMap = {
  SmartAlertType.rsvp: 'rsvp',
  SmartAlertType.budget: 'budget',
  SmartAlertType.vendor: 'vendor',
  SmartAlertType.reminder: 'reminder',
  SmartAlertType.info: 'info',
};

_UpcomingEvent _$UpcomingEventFromJson(Map<String, dynamic> json) =>
    _UpcomingEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
    );

Map<String, dynamic> _$UpcomingEventToJson(_UpcomingEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'date': instance.date.toIso8601String(),
      'category': instance.category,
      'description': instance.description,
      'location': instance.location,
    };

_TodaysFocusItem _$TodaysFocusItemFromJson(Map<String, dynamic> json) =>
    _TodaysFocusItem(
      id: json['id'] as String,
      title: json['title'] as String,
      reason: json['reason'] as String,
      actionLabel: json['actionLabel'] as String,
      actionRoute: json['actionRoute'] as String?,
      isDone: json['isDone'] as bool? ?? false,
    );

Map<String, dynamic> _$TodaysFocusItemToJson(_TodaysFocusItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'reason': instance.reason,
      'actionLabel': instance.actionLabel,
      'actionRoute': instance.actionRoute,
      'isDone': instance.isDone,
    };

_GuidancePrompt _$GuidancePromptFromJson(Map<String, dynamic> json) =>
    _GuidancePrompt(
      id: json['id'] as String,
      question: json['question'] as String,
      context: json['context'] as String?,
      category: json['category'] as String?,
    );

Map<String, dynamic> _$GuidancePromptToJson(_GuidancePrompt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'context': instance.context,
      'category': instance.category,
    };

_PriorityAlert _$PriorityAlertFromJson(Map<String, dynamic> json) =>
    _PriorityAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      level: $enumDecode(_$PriorityAlertLevelEnumMap, json['level']),
      actionLabel: json['actionLabel'] as String?,
      actionRoute: json['actionRoute'] as String?,
      amount: json['amount'] as String?,
    );

Map<String, dynamic> _$PriorityAlertToJson(_PriorityAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'level': _$PriorityAlertLevelEnumMap[instance.level]!,
      'actionLabel': instance.actionLabel,
      'actionRoute': instance.actionRoute,
      'amount': instance.amount,
    };

const _$PriorityAlertLevelEnumMap = {
  PriorityAlertLevel.urgent: 'urgent',
  PriorityAlertLevel.warning: 'warning',
  PriorityAlertLevel.info: 'info',
};
