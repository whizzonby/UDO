import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class HomeState {
  final bool isLoading;
  final String coupleName;
  final int? daysUntil;
  final int totalGuests;
  final int confirmedGuests;
  final int pendingTasks;
  final List<Map<String, dynamic>> upcomingTasks;
  final double? budgetSpent;
  final double? budgetTotal;
  final String? error;

  const HomeState({
    this.isLoading = false,
    this.coupleName = '',
    this.daysUntil,
    this.totalGuests = 0,
    this.confirmedGuests = 0,
    this.pendingTasks = 0,
    this.upcomingTasks = const [],
    this.budgetSpent,
    this.budgetTotal,
    this.error,
  });

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  HomeState copyWith({
    bool? isLoading, String? coupleName, int? daysUntil,
    int? totalGuests, int? confirmedGuests, int? pendingTasks,
    List<Map<String, dynamic>>? upcomingTasks,
    double? budgetSpent, double? budgetTotal, String? error,
  }) => HomeState(
    isLoading: isLoading ?? this.isLoading,
    coupleName: coupleName ?? this.coupleName,
    daysUntil: daysUntil ?? this.daysUntil,
    totalGuests: totalGuests ?? this.totalGuests,
    confirmedGuests: confirmedGuests ?? this.confirmedGuests,
    pendingTasks: pendingTasks ?? this.pendingTasks,
    upcomingTasks: upcomingTasks ?? this.upcomingTasks,
    budgetSpent: budgetSpent ?? this.budgetSpent,
    budgetTotal: budgetTotal ?? this.budgetTotal,
    error: error ?? this.error,
  );
}

class HomeNotifier extends StateNotifier<HomeState> {
  final ApiClient _api;
  HomeNotifier(this._api) : super(const HomeState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.get('/dashboard') as Map<String, dynamic>;
      final wedding = data['wedding'] as Map<String, dynamic>?;
      final stats = data['stats'] as Map<String, dynamic>? ?? {};
      final tasks = (data['upcoming_tasks'] as List? ?? []).cast<Map<String, dynamic>>();

      DateTime? eventDate;
      if (wedding?['event_date'] != null) {
        eventDate = DateTime.tryParse(wedding!['event_date'] as String);
      }

      state = state.copyWith(
        isLoading: false,
        coupleName: wedding?['couple_names'] as String? ?? '',
        daysUntil: eventDate != null ? eventDate.difference(DateTime.now()).inDays : null,
        totalGuests: (stats['total_guests'] as num?)?.toInt() ?? 0,
        confirmedGuests: (stats['confirmed_guests'] as num?)?.toInt() ?? 0,
        pendingTasks: (stats['pending_tasks'] as num?)?.toInt() ?? 0,
        upcomingTasks: tasks,
        budgetSpent: (stats['budget_spent'] as num?)?.toDouble(),
        budgetTotal: (stats['budget_total'] as num?)?.toDouble(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _load();
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref.read(apiClientProvider));
});
