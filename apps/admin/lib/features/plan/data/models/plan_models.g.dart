// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlanTask _$PlanTaskFromJson(Map<String, dynamic> json) => _PlanTask(
  id: json['id'] as String,
  title: json['title'] as String,
  category: json['category'] as String,
  priority:
      $enumDecodeNullable(_$TaskPriorityEnumMap, json['priority']) ??
      TaskPriority.medium,
  isComplete: json['isComplete'] as bool? ?? false,
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$PlanTaskToJson(_PlanTask instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'category': instance.category,
  'priority': _$TaskPriorityEnumMap[instance.priority]!,
  'isComplete': instance.isComplete,
  'dueDate': instance.dueDate?.toIso8601String(),
  'notes': instance.notes,
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
};

_Vendor _$VendorFromJson(Map<String, dynamic> json) => _Vendor(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  status:
      $enumDecodeNullable(_$VendorStatusEnumMap, json['status']) ??
      VendorStatus.potential,
  contactName: json['contactName'] as String?,
  contactPhone: json['contactPhone'] as String?,
  contactEmail: json['contactEmail'] as String?,
  contractAmount: (json['contractAmount'] as num?)?.toDouble() ?? 0.0,
  paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$VendorToJson(_Vendor instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'status': _$VendorStatusEnumMap[instance.status]!,
  'contactName': instance.contactName,
  'contactPhone': instance.contactPhone,
  'contactEmail': instance.contactEmail,
  'contractAmount': instance.contractAmount,
  'paidAmount': instance.paidAmount,
  'notes': instance.notes,
};

const _$VendorStatusEnumMap = {
  VendorStatus.potential: 'potential',
  VendorStatus.booked: 'booked',
  VendorStatus.confirmed: 'confirmed',
  VendorStatus.cancelled: 'cancelled',
};

_TimelineEvent _$TimelineEventFromJson(Map<String, dynamic> json) =>
    _TimelineEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      location: json['location'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$TimelineEventToJson(_TimelineEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'date': instance.date.toIso8601String(),
      'time': instance.time,
      'description': instance.description,
      'category': instance.category,
      'location': instance.location,
      'isCompleted': instance.isCompleted,
    };

_BudgetItem _$BudgetItemFromJson(Map<String, dynamic> json) => _BudgetItem(
  id: json['id'] as String,
  title: json['title'] as String,
  category: json['category'] as String,
  budgetedAmount: (json['budgetedAmount'] as num?)?.toDouble() ?? 0.0,
  paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
  vendorId: json['vendorId'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$BudgetItemToJson(_BudgetItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'budgetedAmount': instance.budgetedAmount,
      'paidAmount': instance.paidAmount,
      'vendorId': instance.vendorId,
      'notes': instance.notes,
    };

_PlanData _$PlanDataFromJson(Map<String, dynamic> json) => _PlanData(
  tasks: (json['tasks'] as List<dynamic>)
      .map((e) => PlanTask.fromJson(e as Map<String, dynamic>))
      .toList(),
  vendors: (json['vendors'] as List<dynamic>)
      .map((e) => Vendor.fromJson(e as Map<String, dynamic>))
      .toList(),
  budgetItems: (json['budgetItems'] as List<dynamic>)
      .map((e) => BudgetItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  timeline: (json['timeline'] as List<dynamic>)
      .map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 45000.0,
  currency: json['currency'] as String? ?? 'USD',
);

Map<String, dynamic> _$PlanDataToJson(_PlanData instance) => <String, dynamic>{
  'tasks': instance.tasks,
  'vendors': instance.vendors,
  'budgetItems': instance.budgetItems,
  'timeline': instance.timeline,
  'totalBudget': instance.totalBudget,
  'currency': instance.currency,
};
