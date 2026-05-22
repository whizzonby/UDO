import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/plan_models.dart';

part 'plan_repository.g.dart';

@Riverpod(keepAlive: true)
PlanRepository planRepository(Ref ref) => MockPlanRepository();

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

// ─── Mock — static lists persist for the app session ─────────────────────────

class MockPlanRepository implements PlanRepository {
  static final List<PlanTask> _tasks = _seedTasks();
  static final List<Vendor> _vendors = _seedVendors();
  static final List<BudgetItem> _budgetItems = _seedBudgetItems();
  static final List<TimelineEvent> _timeline = _seedTimeline();

  @override
  Future<PlanData> getPlanData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return PlanData(
      tasks: List.from(_tasks),
      vendors: List.from(_vendors),
      budgetItems: List.from(_budgetItems),
      timeline: List.from(_timeline),
      totalBudget: 45000,
      currency: 'USD',
    );
  }

  @override
  Future<PlanTask> addTask(PlanTask task) async {
    _tasks.add(task);
    return task;
  }

  @override
  Future<PlanTask> updateTask(PlanTask task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = task;
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }

  @override
  Future<Vendor> addVendor(Vendor vendor) async {
    _vendors.add(vendor);
    return vendor;
  }

  @override
  Future<Vendor> updateVendor(Vendor vendor) async {
    final idx = _vendors.indexWhere((v) => v.id == vendor.id);
    if (idx != -1) _vendors[idx] = vendor;
    return vendor;
  }

  @override
  Future<void> deleteVendor(String id) async {
    _vendors.removeWhere((v) => v.id == id);
  }

  @override
  Future<BudgetItem> addBudgetItem(BudgetItem item) async {
    _budgetItems.add(item);
    return item;
  }

  @override
  Future<BudgetItem> updateBudgetItem(BudgetItem item) async {
    final idx = _budgetItems.indexWhere((b) => b.id == item.id);
    if (idx != -1) _budgetItems[idx] = item;
    return item;
  }

  @override
  Future<void> deleteBudgetItem(String id) async {
    _budgetItems.removeWhere((b) => b.id == id);
  }

  @override
  Future<TimelineEvent> addTimelineEvent(TimelineEvent event) async {
    _timeline.add(event);
    _timeline.sort((a, b) => a.date.compareTo(b.date));
    return event;
  }

  @override
  Future<void> deleteTimelineEvent(String id) async {
    _timeline.removeWhere((e) => e.id == id);
  }
}

// ─── Seed data ────────────────────────────────────────────────────────────────

List<PlanTask> _seedTasks() {
  final now = DateTime.now();
  return [
    // Venue & Catering — 6 tasks (5 complete)
    PlanTask(id: 't1', title: 'Book venue', category: 'Venue & Catering', isComplete: true),
    PlanTask(id: 't2', title: 'Pay venue deposit', category: 'Venue & Catering', isComplete: true),
    PlanTask(id: 't3', title: 'Select catering package', category: 'Venue & Catering', isComplete: true),
    PlanTask(id: 't4', title: 'Confirm catering menu', category: 'Venue & Catering', isComplete: true),
    PlanTask(id: 't5', title: 'Confirm catering headcount', category: 'Venue & Catering', isComplete: true),
    PlanTask(
      id: 't6',
      title: 'Final payment to venue',
      category: 'Venue & Catering',
      isComplete: false,
      priority: TaskPriority.high,
      dueDate: now.add(const Duration(days: 30)),
    ),

    // Invitations — 4 tasks (2 complete)
    PlanTask(id: 't7', title: 'Design invitations', category: 'Invitations', isComplete: true),
    PlanTask(id: 't8', title: 'Print invitations', category: 'Invitations', isComplete: true),
    PlanTask(
      id: 't9',
      title: 'Finalise invitation wording',
      category: 'Invitations',
      isComplete: false,
      priority: TaskPriority.high,
      dueDate: now.add(const Duration(days: 7)),
    ),
    PlanTask(
      id: 't10',
      title: 'Mail invitations',
      category: 'Invitations',
      isComplete: false,
      dueDate: now.add(const Duration(days: 21)),
    ),

    // Florals & Decor — 5 tasks (1 complete)
    PlanTask(id: 't11', title: 'Book florist', category: 'Florals & Decor', isComplete: true),
    PlanTask(
      id: 't12',
      title: 'Confirm florist deposit',
      category: 'Florals & Decor',
      isComplete: false,
      priority: TaskPriority.high,
      dueDate: now.add(const Duration(days: 3)),
    ),
    PlanTask(
      id: 't13',
      title: 'Choose floral arrangements',
      category: 'Florals & Decor',
      isComplete: false,
      dueDate: now.add(const Duration(days: 14)),
    ),
    PlanTask(
      id: 't14',
      title: 'Confirm decor setup plan',
      category: 'Florals & Decor',
      isComplete: false,
      dueDate: now.add(const Duration(days: 45)),
    ),
    PlanTask(
      id: 't15',
      title: 'Arrange transport for floral delivery',
      category: 'Florals & Decor',
      isComplete: false,
      priority: TaskPriority.medium,
      dueDate: now.subtract(const Duration(days: 1)),
    ),

    // Entertainment — 4 tasks (2 complete)
    PlanTask(id: 't16', title: 'Book wedding photographer', category: 'Entertainment', isComplete: true),
    PlanTask(id: 't17', title: 'Book videographer', category: 'Entertainment', isComplete: true),
    PlanTask(
      id: 't18',
      title: 'Confirm DJ/band playlist',
      category: 'Entertainment',
      isComplete: false,
      dueDate: now.add(const Duration(days: 14)),
    ),
    PlanTask(
      id: 't19',
      title: 'Schedule rehearsal dinner entertainment',
      category: 'Entertainment',
      isComplete: false,
      dueDate: now.add(const Duration(days: 30)),
    ),

    // Logistics — 5 tasks (0 complete, 1 overdue)
    PlanTask(
      id: 't20',
      title: 'Arrange guest transport',
      category: 'Logistics',
      isComplete: false,
      priority: TaskPriority.high,
      dueDate: now.subtract(const Duration(days: 1)),
    ),
    PlanTask(
      id: 't21',
      title: 'Book block of hotel rooms',
      category: 'Logistics',
      isComplete: false,
      dueDate: now.add(const Duration(days: 21)),
    ),
    PlanTask(
      id: 't22',
      title: 'Arrange hair & makeup team',
      category: 'Logistics',
      isComplete: false,
      dueDate: now.add(const Duration(days: 14)),
    ),
    PlanTask(
      id: 't23',
      title: 'Confirm master of ceremonies',
      category: 'Logistics',
      isComplete: false,
      dueDate: now.add(const Duration(days: 30)),
    ),
    PlanTask(
      id: 't24',
      title: 'Create wedding day run sheet',
      category: 'Logistics',
      isComplete: false,
      priority: TaskPriority.high,
      dueDate: now.add(const Duration(days: 45)),
    ),
  ];
}

List<Vendor> _seedVendors() {
  return [
    const Vendor(
      id: 'v1',
      name: 'The Grand Palm Estate',
      category: 'Venue',
      status: VendorStatus.confirmed,
      contactName: 'Mr. Asante Boateng',
      contactPhone: '+233 20 123 4567',
      contactEmail: 'events@grandpalm.gh',
      contractAmount: 12000,
      paidAmount: 6000,
    ),
    const Vendor(
      id: 'v2',
      name: 'Golden Table Catering',
      category: 'Catering',
      status: VendorStatus.confirmed,
      contactName: 'Chef Kwesi Mensah',
      contactPhone: '+233 24 987 6543',
      contactEmail: 'info@goldentable.gh',
      contractAmount: 10000,
      paidAmount: 5000,
    ),
    const Vendor(
      id: 'v3',
      name: 'Lens & Light Photography',
      category: 'Photography',
      status: VendorStatus.booked,
      contactName: 'Abena Asante',
      contactPhone: '+233 26 555 1234',
      contactEmail: 'abena@lensandlight.gh',
      contractAmount: 4500,
      paidAmount: 4500,
    ),
    const Vendor(
      id: 'v4',
      name: 'Bloom & Co. Florals',
      category: 'Florals & Decor',
      status: VendorStatus.booked,
      contactName: 'Maame Adu',
      contactPhone: '+233 20 777 8899',
      contractAmount: 3500,
      paidAmount: 1200,
    ),
    const Vendor(
      id: 'v5',
      name: 'Style by Afia',
      category: 'Attire',
      status: VendorStatus.booked,
      contactName: 'Afia Mensah',
      contactPhone: '+233 27 333 4455',
      contractAmount: 4500,
      paidAmount: 0,
    ),
    const Vendor(
      id: 'v6',
      name: 'DJ Kwame Sound Systems',
      category: 'Entertainment',
      status: VendorStatus.potential,
      contactName: 'DJ Kwame',
      contactPhone: '+233 24 111 2233',
      contractAmount: 2000,
      paidAmount: 0,
    ),
    const Vendor(
      id: 'v7',
      name: 'Sweet Occasions Bakery',
      category: 'Cake',
      status: VendorStatus.potential,
      contactName: 'Ama Darko',
      contactPhone: '+233 20 888 9900',
      contractAmount: 800,
      paidAmount: 0,
    ),
    const Vendor(
      id: 'v8',
      name: 'Premier Transport GH',
      category: 'Transport',
      status: VendorStatus.potential,
      contactName: 'Mr. Osei',
      contactPhone: '+233 26 444 5566',
      contractAmount: 1500,
      paidAmount: 0,
    ),
    const Vendor(
      id: 'v9',
      name: 'CineVision Films',
      category: 'Videography',
      status: VendorStatus.potential,
      contactName: 'Kojo Amponsah',
      contactPhone: '+233 24 222 3344',
      contractAmount: 3200,
      paidAmount: 0,
    ),
    const Vendor(
      id: 'v10',
      name: 'Grand Buffet Bar Services',
      category: 'Bar Service',
      status: VendorStatus.booked,
      contactName: 'Fiifi Brew',
      contactPhone: '+233 27 666 7788',
      contractAmount: 2500,
      paidAmount: 2500,
    ),
  ];
}

List<BudgetItem> _seedBudgetItems() {
  return [
    // Venue
    const BudgetItem(id: 'b1', title: 'Venue hire fee', category: 'Venue', budgetedAmount: 10000, paidAmount: 6000, vendorId: 'v1'),
    const BudgetItem(id: 'b2', title: 'Venue decor & setup', category: 'Venue', budgetedAmount: 2000, paidAmount: 0),
    // Catering
    const BudgetItem(id: 'b3', title: 'Food & service', category: 'Catering', budgetedAmount: 8000, paidAmount: 5000, vendorId: 'v2'),
    const BudgetItem(id: 'b4', title: 'Wedding cake', category: 'Catering', budgetedAmount: 800, paidAmount: 0, vendorId: 'v7'),
    const BudgetItem(id: 'b5', title: 'Bar & beverages', category: 'Catering', budgetedAmount: 2500, paidAmount: 2500, vendorId: 'v10'),
    // Photography
    const BudgetItem(id: 'b6', title: 'Photography package', category: 'Photography', budgetedAmount: 4500, paidAmount: 4500, vendorId: 'v3'),
    // Florals & Decor
    const BudgetItem(id: 'b7', title: 'Florals & centrepieces', category: 'Florals & Decor', budgetedAmount: 3500, paidAmount: 1200, vendorId: 'v4'),
    // Entertainment
    const BudgetItem(id: 'b8', title: 'DJ & sound system', category: 'Entertainment', budgetedAmount: 2000, paidAmount: 0, vendorId: 'v6'),
    const BudgetItem(id: 'b9', title: 'Videography', category: 'Entertainment', budgetedAmount: 3200, paidAmount: 0, vendorId: 'v9'),
    // Attire
    const BudgetItem(id: 'b10', title: 'Bridal gown & groom attire', category: 'Attire', budgetedAmount: 4500, paidAmount: 0, vendorId: 'v5'),
  ];
}

List<TimelineEvent> _seedTimeline() {
  final now = DateTime.now();
  return [
    TimelineEvent(
      id: 'e1',
      title: 'Florist consultation',
      date: now.add(const Duration(days: 3)),
      time: '2:00 PM',
      category: 'Vendor',
      location: 'Bloom & Co., East Legon',
    ),
    TimelineEvent(
      id: 'e2',
      title: 'Cake tasting',
      date: now.add(const Duration(days: 7)),
      time: '11:00 AM',
      category: 'Vendor',
      location: 'Sweet Occasions Bakery, Osu',
    ),
    TimelineEvent(
      id: 'e3',
      title: 'Venue walkthrough',
      date: now.add(const Duration(days: 14)),
      time: '10:00 AM',
      category: 'Venue',
      location: 'The Grand Palm Estate, Accra',
    ),
    TimelineEvent(
      id: 'e4',
      title: 'Photography pre-shoot',
      date: now.add(const Duration(days: 21)),
      time: '4:00 PM',
      category: 'Vendor',
      location: 'Labadi Beach, Accra',
    ),
    TimelineEvent(
      id: 'e5',
      title: 'DJ consultation',
      date: now.add(const Duration(days: 28)),
      time: '1:00 PM',
      category: 'Vendor',
    ),
    TimelineEvent(
      id: 'e6',
      title: 'Dress fitting — first',
      date: now.add(const Duration(days: 35)),
      time: '10:00 AM',
      category: 'Attire',
      location: 'Style by Afia, Airport City',
    ),
    TimelineEvent(
      id: 'e7',
      title: 'Send final RSVP reminder',
      date: now.add(const Duration(days: 42)),
      category: 'Admin',
      description: 'Send reminder to all guests who have not yet responded.',
    ),
    TimelineEvent(
      id: 'e8',
      title: 'Dress fitting — final',
      date: now.add(const Duration(days: 70)),
      time: '10:00 AM',
      category: 'Attire',
      location: 'Style by Afia, Airport City',
    ),
    TimelineEvent(
      id: 'e9',
      title: 'Rehearsal dinner',
      date: now.add(const Duration(days: 120)),
      time: '6:00 PM',
      category: 'Ceremony',
      location: 'The Grand Palm Estate',
    ),
    TimelineEvent(
      id: 'e10',
      title: 'Wedding day',
      date: now.add(const Duration(days: 127)),
      time: '10:00 AM',
      category: 'Ceremony',
      location: 'The Grand Palm Estate, Accra',
      description: 'Ceremony begins at 10:00 AM. Reception to follow.',
    ),
  ];
}
