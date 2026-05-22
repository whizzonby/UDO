import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/home_stats_model.dart';

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(Ref ref) => MockHomeRepository();

abstract class HomeRepository {
  Future<HomeStats> getHomeStats();
  Future<void> refresh();
}

// ─── Mock implementation — replace with real API calls in Phase 2 backend ────

class MockHomeRepository implements HomeRepository {
  @override
  Future<HomeStats> getHomeStats() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final weddingDate = DateTime.now().add(const Duration(days: 127));

    return HomeStats(
      wedding: WeddingInfo(
        id: 'wedding_001',
        partnerOneName: 'Amara',
        partnerTwoName: 'Kofi',
        weddingDate: weddingDate,
        venueName: 'The Grand Palm Estate',
        venueCity: 'Accra, Ghana',
        status: WeddingStatus.planning,
      ),
      guests: const GuestOverview(
        total: 150,
        confirmed: 78,
        pending: 42,
        declined: 12,
        notInvited: 18,
      ),
      plan: PlanProgress(
        totalTasks: 24,
        completedTasks: 9,
        overdueTasks: 2,
        categories: const [
          PlanCategory(name: 'Venue & Catering', total: 6, completed: 5),
          PlanCategory(name: 'Invitations', total: 4, completed: 2),
          PlanCategory(name: 'Florals & Decor', total: 5, completed: 1),
          PlanCategory(name: 'Entertainment', total: 4, completed: 1),
          PlanCategory(name: 'Logistics', total: 5, completed: 0),
        ],
        recentTasks: [
          RecentTask(
            id: 't1',
            title: 'Confirm catering menu',
            isComplete: true,
            category: 'Venue & Catering',
          ),
          RecentTask(
            id: 't2',
            title: 'Book wedding photographer',
            isComplete: true,
            category: 'Entertainment',
          ),
          RecentTask(
            id: 't3',
            title: 'Finalise invitation design',
            isComplete: false,
            category: 'Invitations',
            dueDate: DateTime.now().add(const Duration(days: 7)),
          ),
          RecentTask(
            id: 't4',
            title: 'Confirm florist deposit',
            isComplete: false,
            category: 'Florals & Decor',
            dueDate: DateTime.now().add(const Duration(days: 3)),
          ),
          RecentTask(
            id: 't5',
            title: 'Arrange guest transport',
            isComplete: false,
            category: 'Logistics',
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      budget: BudgetOverview(
        total: 45000,
        allocated: 38500,
        spent: 28500,
        currency: 'USD',
        categories: const [
          BudgetCategory(name: 'Venue', allocated: 12000, spent: 12000),
          BudgetCategory(name: 'Catering', allocated: 10000, spent: 8500),
          BudgetCategory(name: 'Photography', allocated: 4500, spent: 4500),
          BudgetCategory(name: 'Florals', allocated: 3500, spent: 1200),
          BudgetCategory(name: 'Entertainment', allocated: 4000, spent: 2300),
          BudgetCategory(name: 'Attire', allocated: 4500, spent: 0),
        ],
      ),
      alerts: [
        SmartAlert(
          id: 'a1',
          type: SmartAlertType.rsvp,
          title: '42 guests haven\'t responded',
          body: 'Your RSVP deadline is in 14 days. Send a reminder now.',
          actionLabel: 'Send reminder',
          actionRoute: '/guests/invitations',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        SmartAlert(
          id: 'a2',
          type: SmartAlertType.reminder,
          title: 'Task overdue: Guest transport',
          body: 'Arranging guest transport was due yesterday.',
          actionLabel: 'View task',
          actionRoute: '/plan',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        SmartAlert(
          id: 'a3',
          type: SmartAlertType.budget,
          title: 'Budget at 63%',
          body: '\$16,500 remaining. Your florist deposit is due next week.',
          actionLabel: 'View budget',
          actionRoute: '/plan/budget',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ],
      upcoming: [
        UpcomingEvent(
          id: 'e1',
          title: 'Florist consultation',
          date: DateTime.now().add(const Duration(days: 3)),
          category: 'Vendor',
          location: 'Bloom & Co., East Legon',
        ),
        UpcomingEvent(
          id: 'e2',
          title: 'Cake tasting',
          date: DateTime.now().add(const Duration(days: 7)),
          category: 'Vendor',
          location: 'Sweet Occasions Bakery',
        ),
        UpcomingEvent(
          id: 'e3',
          title: 'Venue walkthrough',
          date: DateTime.now().add(const Duration(days: 14)),
          category: 'Venue',
          location: 'The Grand Palm Estate',
        ),
      ],
    );
  }

  @override
  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
