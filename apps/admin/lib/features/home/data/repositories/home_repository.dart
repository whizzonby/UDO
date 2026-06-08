import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../models/home_stats_model.dart';

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(Ref ref) =>
    ApiHomeRepository(ref.watch(apiClientProvider));

abstract class HomeRepository {
  Future<HomeStats> getHomeStats();
  Future<void> refresh();
}

class ApiHomeRepository implements HomeRepository {
  const ApiHomeRepository(this._dio);

  final Dio _dio;

  @override
  Future<HomeStats> getHomeStats() async {
    final response = await _dio.get('/home');
    return _mapResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> refresh() => getHomeStats();

  HomeStats _mapResponse(Map<String, dynamic> data) {
    final w = data['wedding'] as Map<String, dynamic>;
    final p = data['plan'] as Map<String, dynamic>;
    final b = data['budget'] as Map<String, dynamic>;
    final g = data['guests'] as Map<String, dynamic>;
    final rawAlerts = data['alerts'] as List<dynamic>;
    final rawUpcoming = data['upcoming_events'] as List<dynamic>;

    final wedding = WeddingInfo(
      id: w['id'] as String,
      partnerOneName: w['partner_one_name'] as String,
      partnerTwoName: w['partner_two_name'] as String? ?? '',
      weddingDate: w['wedding_date'] != null
          ? DateTime.tryParse(w['wedding_date'] as String)
          : null,
      status: WeddingStatus.values.firstWhere(
        (s) => s.value == (w['status'] as String? ?? 'planning'),
        orElse: () => WeddingStatus.planning,
      ),
    );

    final guests = GuestOverview(
      total: (g['total_invited'] as int?) ?? 0,
      confirmed: (g['attending'] as int?) ?? 0,
      pending: (g['pending'] as int?) ?? 0,
      declined: (g['declined'] as int?) ?? 0,
    );

    final plan = PlanProgress(
      totalTasks: (p['total_tasks'] as int?) ?? 0,
      completedTasks: (p['done_tasks'] as int?) ?? 0,
      overdueTasks: (p['overdue_tasks'] as int?) ?? 0,
    );

    final budget = BudgetOverview(
      total: _toDouble(b['total_budget']) ?? 0.0,
      allocated: _toDouble(b['total_budgeted']) ?? 0.0,
      spent: _toDouble(b['total_spent']) ?? 0.0,
    );

    final alerts = rawAlerts.asMap().entries.map((e) {
      final a = e.value as Map<String, dynamic>;
      final type = _mapAlertType(a['type'] as String? ?? '');
      return SmartAlert(
        id: 'alert_${e.key}',
        type: type,
        title: a['message'] as String? ?? '',
        body: a['detail'] as String? ?? '',
      );
    }).toList();

    final upcoming = rawUpcoming.map((raw) {
      final e = raw as Map<String, dynamic>;
      return UpcomingEvent(
        id: e['id'].toString(),
        title: e['title'] as String,
        date: DateTime.parse(e['event_date'] as String),
        category: e['is_wedding_day'] == true ? 'Ceremony' : 'Event',
        location: e['location'] as String?,
      );
    }).toList();

    return HomeStats(
      wedding: wedding,
      guests: guests,
      plan: plan,
      budget: budget,
      alerts: alerts,
      upcoming: upcoming,
    );
  }

  SmartAlertType _mapAlertType(String type) => switch (type) {
        'rsvp_pending' => SmartAlertType.rsvp,
        'vendor_deposit_due' => SmartAlertType.vendor,
        _ => SmartAlertType.info,
      };

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}
