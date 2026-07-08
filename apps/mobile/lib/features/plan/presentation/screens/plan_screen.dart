import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/plan_provider.dart';

/// Laravel's `decimal:2` model casts serialize to JSON as strings (e.g.
/// "18000.00"), not numbers — this project's budget fields hit that
/// specifically. Handles both shapes so a future backend fix (or any field
/// that's already a real number, like the pre-computed budget summary) still
/// works.
double _asDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});
  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String? _activeModal; // budget | guests | vendors | food | seating | travel | details

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 7, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(planProvider);
    final notifier = ref.read(planProvider.notifier);

    return Scaffold(
      floatingActionButton: _tabs.index == 2
          ? FloatingActionButton(
              backgroundColor: AppTheme.udoGreen,
              onPressed: () => showAddTaskSheet(context, notifier),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Stack(
        children: [
          Column(
            children: [
              _PlanHeader(tabs: _tabs),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _OverviewTab(state: state, onModuleTap: (id) => setState(() => _activeModal = id), onTabJump: _tabs.animateTo),
                    _YourVisionTab(state: state),
                    _TasksTab(state: state, notifier: notifier),
                    _BudgetTab(state: state),
                    _VendorsTab(state: state),
                    const _WeddingPartyTab(),
                    const _DetailsTab(),
                  ],
                ),
              ),
            ],
          ),
          if (_activeModal != null)
            _ModuleModal(modalId: _activeModal!, onClose: () => setState(() => _activeModal = null)),
        ],
      ),
    );
  }
}

// ── HEADER ─────────────────────────────────────────────────────────────────────

class _PlanHeader extends StatelessWidget {
  final TabController tabs;
  const _PlanHeader({required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.udoPastelCrimson.withValues(alpha: 0.15), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Column(
                children: [
                  Text('Plan', style: TextStyle(fontFamily: 'Playfair', fontSize: 28, fontWeight: FontWeight.w400, color: AppTheme.udoCrimson)),
                  const SizedBox(height: 4),
                  const Text('Everything important in one peaceful place.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TabBar(
              controller: tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.udoTextSecondary,
              indicator: BoxDecoration(color: AppTheme.udoGreen, borderRadius: BorderRadius.circular(20)),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(vertical: 4),
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(icon: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.auto_awesome, size: 14), SizedBox(width: 4), Text('Your Vision', style: TextStyle(fontSize: 13))])),
                Tab(text: 'Tasks'),
                Tab(text: 'Budget'),
                Tab(text: 'Vendors'),
                Tab(text: 'Wedding Party'),
                Tab(text: 'Details'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── OVERVIEW TAB ───────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final PlanState state;
  final void Function(String) onModuleTap;
  final void Function(int) onTabJump;
  const _OverviewTab({required this.state, required this.onModuleTap, required this.onTabJump});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.udoGreen));

    // Real "up next": incomplete tasks, high priority first, soonest due date first.
    final upNext = [...state.tasks.where((t) => t['completed'] != true)]
      ..sort((a, b) {
        const order = {'high': 0, 'medium': 1, 'low': 2};
        final pa = order[a['priority'] as String? ?? 'low'] ?? 2;
        final pb = order[b['priority'] as String? ?? 'low'] ?? 2;
        if (pa != pb) return pa.compareTo(pb);
        final da = a['due_date'] as String?;
        final db = b['due_date'] as String?;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });
    final topTasks = upNext.take(3).toList();

    final bookedVendors = state.vendors.where((v) => v['booking_status'] == 'booked' || v['booking_status'] == 'confirmed').length;
    final neededVendors = state.vendors.length - bookedVendors;
    final totalBudget = _asDouble(state.budgetSummary['total_budget']);
    final actualBudget = _asDouble(state.budgetSummary['total_actual']);
    final budgetProgress = totalBudget > 0 ? ((actualBudget / totalBudget) * 100).clamp(0, 100).round() : 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Intro card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('This is your planning space.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.4)),
              SizedBox(height: 4),
              Text('Everything is grouped here so you can move through it clearly. Start with what matters most, then refine as you go.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5)),
            ])),
            const SizedBox(width: 12),
            Icon(Icons.favorite_outline, color: AppTheme.udoPastelCrimson.withValues(alpha: 0.8), size: 24),
          ]),
        ),
        const SizedBox(height: 16),

        // Priority tasks — real, sourced from state.tasks
        _SectionHeader('Up next'),
        const SizedBox(height: 8),
        if (topTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
            child: const Text("You're all caught up — no open tasks.", style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
          )
        else
          ...topTasks.map((t) {
            final priority = t['priority'] as String? ?? 'low';
            final status = priority == 'high' ? 'Urgent' : priority == 'medium' ? 'Soon' : 'Later';
            return _PriorityTaskCard(
              title: t['title'] as String? ?? '',
              subtitle: t['due_date'] != null ? 'Due ${t['due_date']}' : (t['category'] as String? ?? 'No due date set'),
              status: status,
              onTap: () => onTabJump(2),
            );
          }),

        const SizedBox(height: 16),
        _SectionHeader('Core planning'),
        const SizedBox(height: 8),
        _ModuleCard(
          id: 'budget', icon: Icons.attach_money_outlined, title: 'Budget',
          status: totalBudget == 0 ? 'Not set' : (budgetProgress >= 100 ? 'Complete' : 'In progress'),
          summary: totalBudget > 0 ? '\$${totalBudget.toStringAsFixed(0)} total' : 'No budget set yet',
          progress: budgetProgress, nextStep: totalBudget > 0 ? '\$${actualBudget.toStringAsFixed(0)} spent so far' : 'Set your total budget to track spend',
          onTap: () => onTabJump(3),
        ),
        _ModuleCard(
          id: 'vendors', icon: Icons.work_outline, title: 'Vendors',
          status: state.vendors.isEmpty ? 'Not started' : (neededVendors == 0 ? 'Complete' : 'In progress'),
          summary: state.vendors.isEmpty ? 'No vendors added yet' : '$bookedVendors booked • $neededVendors still needed',
          progress: state.vendors.isEmpty ? 0 : ((bookedVendors / state.vendors.length) * 100).round(),
          nextStep: state.vendors.isEmpty ? 'Add your first vendor' : (neededVendors > 0 ? '$neededVendors vendor${neededVendors == 1 ? '' : 's'} still need confirmation' : 'All vendors booked'),
          onTap: () => onTabJump(4),
        ),
        _ModuleCard(
          id: 'event-structure', icon: Icons.calendar_today_outlined, title: 'Wedding Flow',
          status: state.timelineItems.isEmpty ? 'Not started' : 'In progress',
          summary: '${state.timelineItems.length} moment${state.timelineItems.length == 1 ? '' : 's'} planned',
          progress: state.timelineItems.isEmpty ? 0 : 100,
          nextStep: state.timelineItems.isEmpty ? 'Add your first timeline moment' : 'Your day, moment by moment',
          onTap: () => context.push('/your-vision'),
        ),
        // Guests and Food & Dining aren't owned by the Plan tab's data (no
        // guests/food API wired in here yet) — left as illustrative previews.
        ...[
          ('guests', Icons.people_outline, 'Guests', 'In progress', '120 invited • 95 confirmed', 85, '8 guests still pending RSVP'),
          ('food', Icons.restaurant_outlined, 'Food & Dining', 'In progress', 'Plated dinner • 5 dietary needs tracked', 60, 'Menu enhancements still need review'),
        ].map((m) => _ModuleCard(
          id: m.$1, icon: m.$2, title: m.$3, status: m.$4,
          summary: m.$5, progress: m.$6, nextStep: m.$7,
          onTap: () => onModuleTap(m.$1),
        )),

        const SizedBox(height: 16),
        _SectionHeader('Guest experience'),
        const SizedBox(height: 8),
        ...[
          ('lookbook', Icons.image_outlined, 'Vision & Style', 'In progress', '47 images saved', 55, 'Color palette needs final selection'),
          ('seating', Icons.chair_outlined, 'Seating', 'Not started', '120 guests • 15 tables planned', 0, 'Guest placement has not been arranged yet'),
          ('travel-stay', Icons.flight_outlined, 'Travel & Stay', 'In progress', '32 travelling guests • 12 transport requests', 45, 'Send logistics link'),
          ('additional-events', Icons.calendar_month_outlined, 'Wedding Weekend', 'In progress', 'Rehearsal dinner • Post-wedding brunch', 50, 'Welcome party venue needs booking'),
        ].map((m) => _ModuleCard(
          id: m.$1, icon: m.$2, title: m.$3, status: m.$4,
          summary: m.$5, progress: m.$6, nextStep: m.$7,
          onTap: () => onModuleTap(m.$1),
        )),

        const SizedBox(height: 16),
        _SectionHeader('Enhancements'),
        const SizedBox(height: 8),
        ...[
          ('honeymoon', Icons.beach_access_outlined, 'Honeymoon', 'Planned', 'Bali • 10 days', 90, 'Almost ready'),
          ('personal-moments', Icons.favorite_border_outlined, 'Memories', 'In progress', '4 speeches • Cultural traditions', 40, 'Photo booth and guestbook setup'),
          ('insurance', Icons.shield_outlined, 'Insurance', 'Complete', 'Policy active', 100, 'You are covered'),
          ('reminders', Icons.notifications_outlined, 'Reminders', 'Active', 'Weekly updates enabled', 100, 'You will stay gently informed'),
        ].map((m) => _ModuleCard(
          id: m.$1, icon: m.$2, title: m.$3, status: m.$4,
          summary: m.$5, progress: m.$6, nextStep: m.$7,
          onTap: () => onModuleTap(m.$1),
        )),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: AppTheme.udoTextSecondary));
}

class _PriorityTaskCard extends StatelessWidget {
  final String title, subtitle, status;
  final VoidCallback? onTap;
  const _PriorityTaskCard({required this.title, required this.subtitle, required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUrgent = status == 'Urgent';
    final color = isUrgent ? AppTheme.udoCrimson : AppTheme.udoPastelCrimson;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
        child: Row(children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary, height: 1.4)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          ),
        ]),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String id, title, status, summary, nextStep;
  final IconData icon;
  final int progress;
  final VoidCallback onTap;
  const _ModuleCard({required this.id, required this.icon, required this.title, required this.status, required this.summary, required this.progress, required this.nextStep, required this.onTap});

  Color get _statusColor {
    switch (status) {
      case 'Complete': case 'Active': case 'Planned': return AppTheme.udoGreen;
      case 'Urgent': case 'Needs attention': return AppTheme.udoCrimson;
      case 'In progress': case 'Soon': return AppTheme.udoPastelCrimson;
      default: return AppTheme.udoTextSecondary;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.udoBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: AppTheme.udoGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppTheme.udoGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Text(summary, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w500)),
          ),
        ]),
        if (progress > 0) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: AppTheme.udoBorder,
            valueColor: AlwaysStoppedAnimation(_statusColor),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.udoTextSecondary),
          const SizedBox(width: 6),
          Expanded(child: Text(nextStep, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary))),
        ]),
      ]),
    ),
  );
}

// ── YOUR VISION TAB ────────────────────────────────────────────────────────────

class _YourVisionTab extends StatelessWidget {
  final PlanState state;
  const _YourVisionTab({required this.state});

  String _formatTime(String? t) {
    if (t == null || t.isEmpty) return '';
    final parts = t.split(':');
    if (parts.length < 2) return t;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final suffix = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:${m.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.udoGreen));

    final items = [...state.timelineItems]
      ..sort((a, b) => (a['start_time'] as String? ?? '').compareTo(b['start_time'] as String? ?? ''));

    if (state.timelineError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 40, color: AppTheme.udoCrimson),
            const SizedBox(height: 12),
            const Text("Couldn't load your timeline.", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.udoCrimson)),
            const SizedBox(height: 6),
            Text(state.timelineError!, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary), textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.udoLightBlush, Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.udoPastelCrimson.withValues(alpha: 0.4)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.auto_awesome, color: AppTheme.udoCrimson, size: 18),
              const SizedBox(width: 8),
              const Text('DAY SIMULATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppTheme.udoTextSecondary)),
            ]),
            const SizedBox(height: 8),
            const Text('What the day actually looks like', style: TextStyle(fontFamily: 'Playfair', fontSize: 22, fontWeight: FontWeight.w400, height: 1.3)),
            const SizedBox(height: 8),
            const Text('Not a checklist. A simulation — atmospheric, behavioral, operational, and emotional — of exactly how the day will unfold. Every observation is specific to this couple, this venue, this guest list.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5)),
          ]),
        ),
        const SizedBox(height: 16),

        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppTheme.udoBackground, borderRadius: BorderRadius.circular(16)),
            child: const Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.calendar_today_outlined, size: 40, color: AppTheme.udoTextSecondary),
              SizedBox(height: 12),
              Text('No events planned yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              SizedBox(height: 6),
              Text('Add events to your timeline and they will appear here.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            ]),
          )
        else ...[
          // Timeline bar — real events, times
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final item in items)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text((item['title'] as String? ?? '').toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppTheme.udoTextSecondary)),
                      const SizedBox(height: 4),
                      Text(_formatTime(item['start_time'] as String?), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ]),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text('TIMELINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: AppTheme.udoTextSecondary)),
          const SizedBox(height: 12),

          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final tag = (item['event_type'] as String? ?? 'Event');
            final tagColor = _tagColor(tag);
            final time = _formatTime(item['start_time'] as String?);
            final desc = (item['description'] as String?)?.isNotEmpty == true ? item['description'] as String : (item['location'] as String? ?? '');
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: tagColor.withValues(alpha: 0.3))),
                  child: Center(child: Text(time.split(' ').first, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: tagColor))),
                ),
                if (i < items.length - 1) Container(width: 1, height: 60, color: AppTheme.udoBorder),
              ]),
              const SizedBox(width: 14),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.udoCrimson)),
                  const SizedBox(height: 2),
                  Text(item['title'] as String? ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.3)),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5)),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(tag, style: TextStyle(fontSize: 10, color: tagColor, fontWeight: FontWeight.w600)),
                  ),
                ]),
              )),
            ]);
          }),
        ],
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => context.push('/your-vision'),
          icon: const Icon(Icons.open_in_new, size: 16),
          label: const Text('Open full day simulation'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoCrimson, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Ceremony': return AppTheme.udoGreen;
      case 'Emotional': return AppTheme.udoCrimson;
      case 'Photography': return Colors.indigo;
      case 'Logistics': return Colors.teal;
      default: return AppTheme.udoTextSecondary;
    }
  }
}

// ── ADD TASK SHEET ─────────────────────────────────────────────────────────────

Future<void> showAddTaskSheet(BuildContext context, PlanNotifier notifier) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => _AddTaskSheet(notifier: notifier),
  );
}

class _AddTaskSheet extends StatefulWidget {
  final PlanNotifier notifier;
  const _AddTaskSheet({required this.notifier});
  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  String _priority = 'medium';
  DateTime? _dueDate;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Give the task a title.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await widget.notifier.createTask(
      title: _titleCtrl.text.trim(),
      category: _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
      dueDate: _dueDate,
      priority: _priority,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save this task. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.udoBorder, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('New task', style: TextStyle(fontFamily: 'Playfair', fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.udoGreen)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Confirm florist order'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _categoryCtrl,
            decoration: const InputDecoration(labelText: 'Category (optional)', hintText: 'e.g. Vendors'),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 1460)),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text(_dueDate == null ? 'Due date' : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['low', 'medium', 'high'].map((p) => ChoiceChip(
              label: Text(p[0].toUpperCase() + p.substring(1)),
              selected: _priority == p,
              onSelected: (_) => setState(() => _priority = p),
              selectedColor: AppTheme.udoGreen,
              labelStyle: TextStyle(color: _priority == p ? Colors.white : AppTheme.udoTextPrimary, fontSize: 13),
            )).toList(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppTheme.udoCrimson, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Add task'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── TASKS TAB ──────────────────────────────────────────────────────────────────

class _TasksTab extends StatefulWidget {
  final PlanState state;
  final PlanNotifier notifier;
  const _TasksTab({required this.state, required this.notifier});
  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<_TasksTab> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    if (widget.state.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.udoGreen));

    if (widget.state.tasksError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 40, color: AppTheme.udoCrimson),
            const SizedBox(height: 12),
            const Text("Couldn't load your tasks.", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.udoCrimson)),
            const SizedBox(height: 6),
            Text(widget.state.tasksError!, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary), textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    final tasks = widget.state.tasks;
    final filtered = _filter == 'All' ? tasks : tasks.where((t) {
      if (_filter == 'Pending') return t['completed'] != true;
      if (_filter == 'Done') return t['completed'] == true;
      return (t['priority'] as String? ?? '') == _filter;
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: [
              for (final f in ['All', 'Pending', 'Done', 'high', 'medium', 'low']) Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f[0].toUpperCase() + f.substring(1), style: const TextStyle(fontSize: 12)),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: AppTheme.udoGreen,
                  labelStyle: TextStyle(color: _filter == f ? Colors.white : AppTheme.udoTextPrimary),
                  side: BorderSide(color: _filter == f ? AppTheme.udoGreen : AppTheme.udoBorder),
                  checkmarkColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No tasks.', style: TextStyle(color: AppTheme.udoTextSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final t = filtered[i];
                    final done = t['completed'] == true;
                    final priority = t['priority'] as String? ?? 'low';
                    final pColor = priority == 'high' ? AppTheme.udoCrimson : priority == 'medium' ? Colors.orange : Colors.grey;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        leading: GestureDetector(
                          onTap: () => widget.notifier.toggleTask(t['id'] as int),
                          child: Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done ? AppTheme.udoGreen : Colors.transparent,
                              border: Border.all(color: done ? AppTheme.udoGreen : AppTheme.udoBorder, width: 2),
                            ),
                            child: done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                          ),
                        ),
                        title: Text(t['title'] as String? ?? '', style: TextStyle(fontSize: 14, decoration: done ? TextDecoration.lineThrough : null, color: done ? AppTheme.udoTextSecondary : AppTheme.udoTextPrimary)),
                        subtitle: t['due_date'] != null ? Text(t['due_date'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)) : null,
                        trailing: Container(width: 8, height: 8, decoration: BoxDecoration(color: pColor, shape: BoxShape.circle)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── BUDGET TAB ─────────────────────────────────────────────────────────────────

class _BudgetTab extends StatelessWidget {
  final PlanState state;
  const _BudgetTab({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.udoGreen));

    final summary = state.budgetSummary;
    final totalBudget = _asDouble(summary['total_budget']);
    final totalActual = _asDouble(summary['total_actual']);
    final totalPaid = _asDouble(summary['total_paid']);
    // If no total budget was ever set during onboarding, compare spend against
    // the sum of estimates instead of dividing by zero / showing "of $0".
    final totalEstimated = _asDouble(summary['total_estimated']);
    final comparisonTotal = totalBudget > 0 ? totalBudget : totalEstimated;
    final progress = comparisonTotal > 0 ? (totalActual / comparisonTotal).clamp(0.0, 1.0) : 0.0;

    // Group real budget items by category.
    final byCategory = <String, ({double estimated, double actual, double paid})>{};
    for (final item in state.budgetItems) {
      final category = (item['category'] as String?)?.trim();
      final key = (category == null || category.isEmpty) ? 'Uncategorized' : category;
      final existing = byCategory[key] ?? (estimated: 0, actual: 0, paid: 0);
      byCategory[key] = (
        estimated: existing.estimated + _asDouble(item['estimated_amount']),
        actual: existing.actual + _asDouble(item['actual_amount']),
        paid: existing.paid + _asDouble(item['paid_amount']),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (state.budgetError != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.udoCrimson.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(14)),
            child: const Text("Couldn't load your budget. Pull to refresh or try again later.", style: TextStyle(fontSize: 13, color: AppTheme.udoCrimson)),
          ),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.udoGreen, AppTheme.udoGreen.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Budget overview', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            Text('\$${totalActual.toStringAsFixed(0)} spent', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              comparisonTotal > 0 ? 'of \$${comparisonTotal.toStringAsFixed(0)} ${totalBudget > 0 ? 'total' : 'estimated'}' : 'No budget set yet',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress, backgroundColor: Colors.white.withValues(alpha: 0.3), valueColor: const AlwaysStoppedAnimation(Colors.white), minHeight: 6, borderRadius: BorderRadius.circular(3)),
            const SizedBox(height: 6),
            Text('${(progress * 100).toStringAsFixed(0)}% used • \$${totalPaid.toStringAsFixed(0)} paid so far', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 16),
        if (byCategory.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
            child: const Column(children: [
              Text('No budget items yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              SizedBox(height: 6),
              Text('Add budget items to see spending broken down by category.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            ]),
          )
        else
          for (final entry in byCategory.entries)
            _BudgetRow(
              name: entry.key,
              allocated: entry.value.estimated,
              spent: entry.value.actual,
              status: entry.value.actual == 0
                  ? 'pending'
                  : (entry.value.paid >= entry.value.actual ? 'complete' : 'on-track'),
            ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String name, status;
  final double allocated, spent;
  const _BudgetRow({required this.name, required this.allocated, required this.spent, required this.status});

  Color get _color {
    switch (status) {
      case 'complete': return AppTheme.udoGreen;
      case 'on-track': return Colors.blue;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: _color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(status == 'complete' ? 'Complete' : status == 'on-track' ? 'On Track' : 'Pending', style: TextStyle(fontSize: 11, color: _color, fontWeight: FontWeight.w500)),
        ),
      ]),
      const SizedBox(height: 4),
      Text('\$${spent.toStringAsFixed(0)} of \$${allocated.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
      const SizedBox(height: 8),
      LinearProgressIndicator(
        value: allocated > 0 ? spent / allocated : 0,
        backgroundColor: AppTheme.udoBorder,
        valueColor: AlwaysStoppedAnimation(_color),
        minHeight: 4,
        borderRadius: BorderRadius.circular(2),
      ),
    ]),
  );
}

// ── VENDORS TAB ────────────────────────────────────────────────────────────────

class _VendorsTab extends StatelessWidget {
  final PlanState state;
  const _VendorsTab({required this.state});

  Color _statusColor(String status) {
    switch (status) {
      case 'booked':
      case 'confirmed':
        return AppTheme.udoGreen;
      case 'negotiating':
        return Colors.orange;
      case 'cancelled':
        return AppTheme.udoCrimson;
      default: // researching
        return AppTheme.udoTextSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.udoGreen));

    if (state.vendorsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 40, color: AppTheme.udoCrimson),
            const SizedBox(height: 12),
            const Text("Couldn't load your vendors.", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.udoCrimson)),
            const SizedBox(height: 6),
            Text(state.vendorsError!, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary), textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    final vendors = state.vendors;
    if (vendors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.work_outline, size: 40, color: AppTheme.udoTextSecondary),
            const SizedBox(height: 12),
            const Text('No vendors yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('Vendors you add will show up here.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
          ]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vendors.length,
      itemBuilder: (_, i) {
        final v = vendors[i];
        final status = v['booking_status'] as String? ?? 'researching';
        final statusColor = _statusColor(status);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v['category'] as String? ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              if (v['name'] != null) Text(v['name'] as String, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(status[0].toUpperCase() + status.substring(1), style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w500)),
            ),
          ]),
        );
      },
    );
  }
}

// ── WEDDING PARTY TAB (links to full screen) ───────────────────────────────────

class _WeddingPartyTab extends StatelessWidget {
  const _WeddingPartyTab();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.udoBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Wedding Party', style: TextStyle(fontFamily: 'Playfair', fontSize: 22, fontWeight: FontWeight.w400)),
          const SizedBox(height: 8),
          const Text('Manage your wedding party members, their responsibilities, travel, and day-of coordination.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5)),
          const SizedBox(height: 16),
          for (final (_, name, role) in [
            (Icons.person_outline, 'Sarah Johnson', 'Maid of honour'),
            (Icons.person_outline, 'Michael Chen', 'Best man'),
            (Icons.person_outline, 'Emily Davis', 'Bridesmaid'),
            (Icons.person_outline, 'James Wilson', 'Groomsman'),
          ]) Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              CircleAvatar(radius: 18, backgroundColor: AppTheme.udoGreen.withValues(alpha: 0.1), child: Text(name[0], style: const TextStyle(color: AppTheme.udoGreen, fontWeight: FontWeight.w600))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text(role, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
              ])),
            ]),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => context.push('/wedding-party'),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Open Wedding Party module'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
          ),
        ]),
      ),
    ],
  );
}

// ── DETAILS TAB ────────────────────────────────────────────────────────────────

class _DetailsTab extends StatelessWidget {
  const _DetailsTab();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      for (final (icon, title, value) in [
        (Icons.calendar_today_outlined, 'Wedding date', 'September 14, 2026'),
        (Icons.location_on_outlined, 'Venue', 'Sunset Gardens'),
        (Icons.location_city_outlined, 'City', 'Jaipur, India'),
        (Icons.people_outline, 'Guest count', '120 invited'),
        (Icons.attach_money_outlined, 'Total budget', '\$45,000'),
        (Icons.favorite_outline, 'Wedding style', 'Garden ceremony • Seated dinner'),
        (Icons.palette_outlined, 'Colour palette', 'Dusty rose, sage green, ivory'),
        (Icons.church_outlined, 'Ceremony type', 'Non-denominational'),
      ]) Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
        child: Row(children: [
          Icon(icon, color: AppTheme.udoGreen, size: 20),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ])),
        ]),
      ),
    ],
  );
}

// ── MODULE MODAL (full-screen overlay) ────────────────────────────────────────

class _ModuleModal extends StatelessWidget {
  final String modalId;
  final VoidCallback onClose;
  const _ModuleModal({required this.modalId, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.udoBorder, borderRadius: BorderRadius.circular(2))),
                Expanded(child: SingleChildScrollView(child: _modalContent(modalId, onClose))),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modalContent(String id, VoidCallback onClose) {
    final configs = {
      'budget': ('Budget Overview', Icons.attach_money_outlined, _budgetContent()),
      'guests': ('Guests', Icons.people_outline, _guestsContent()),
      'event-structure': ('Wedding Flow', Icons.calendar_today_outlined, _eventContent()),
      'vendors': ('Vendors', Icons.work_outline, _vendorContent()),
      'food': ('Food & Dining', Icons.restaurant_outlined, _foodContent()),
      'lookbook': ('Vision & Style', Icons.image_outlined, _lookbookContent()),
      'seating': ('Seating Plan', Icons.chair_outlined, _seatingContent()),
      'travel-stay': ('Travel & Stay', Icons.flight_outlined, _travelContent()),
      'additional-events': ('Wedding Weekend', Icons.calendar_month_outlined, _weekendContent()),
      'honeymoon': ('Honeymoon', Icons.beach_access_outlined, _honeymoonContent()),
      'personal-moments': ('Memories', Icons.favorite_border_outlined, _memoriesContent()),
      'insurance': ('Insurance', Icons.shield_outlined, _insuranceContent()),
      'reminders': ('Reminders', Icons.notifications_outlined, _remindersContent()),
    };

    final config = configs[id] ?? ('Module', Icons.info_outline, const SizedBox());
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(config.$2, color: AppTheme.udoGreen, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(config.$1, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Playfair'))),
          IconButton(onPressed: onClose, icon: const Icon(Icons.close), padding: EdgeInsets.zero),
        ]),
        const Divider(height: 20),
        config.$3,
      ]),
    );
  }

  Widget _budgetContent() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      _BudgetStat('Total', '\$45,000', Colors.blue),
      _BudgetStat('Spent', '\$35,650', AppTheme.udoGreen),
      _BudgetStat('Left', '\$9,350', Colors.purple),
    ]),
    const SizedBox(height: 16),
    for (final (name, spent, allocated, status) in [
      ('Venue & Catering', 15200, 18000, 'on-track'),
      ('Photography', 8000, 8000, 'complete'),
      ('Florals & Décor', 3200, 6000, 'on-track'),
      ('Music', 0, 4000, 'pending'),
      ('Attire', 3800, 5000, 'on-track'),
    ]) _BudgetCatRow(name, spent, allocated, status),
  ]);

  Widget _guestsContent() => const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _ModalInfoRow('Total invited', '120'),
    _ModalInfoRow('Confirmed', '95'),
    _ModalInfoRow('Pending RSVP', '8'),
    _ModalInfoRow('Declined', '17'),
    SizedBox(height: 12),
    Text('8 guests still pending RSVP. Consider sending a reminder this week.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5)),
  ]);

  Widget _eventContent() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    for (final (time, name, loc) in [
      ('4:00 PM', 'Ceremony', 'Beach pavilion'),
      ('5:00 PM', 'Cocktail hour', 'Garden terrace'),
      ('6:30 PM', 'Reception', 'Main ballroom'),
      ('11:00 PM', 'After party', 'Poolside lounge'),
    ]) Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        SizedBox(width: 60, child: Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.udoGreen))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(loc, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        ])),
      ]),
    ),
  ]);

  Widget _vendorContent() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    for (final (cat, name, status) in [
      ('Venue', 'Sunset Gardens', 'Booked'),
      ('Photographer', 'Emma Stone Photography', 'Booked'),
      ('Catering', 'Gourmet Affairs', 'Booked'),
      ('Florist', null, 'Shortlisted (2)'),
      ('DJ / Band', null, 'Shortlisted (4)'),
      ('Cake', null, 'Needed'),
    ]) Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(cat, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          if (name != null) Text(name, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: status == 'Booked' ? AppTheme.udoGreen.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(status, style: TextStyle(fontSize: 11, color: status == 'Booked' ? AppTheme.udoGreen : Colors.orange, fontWeight: FontWeight.w500)),
        ),
      ]),
    ),
  ]);

  Widget _foodContent() => const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _ModalInfoRow('Meal service', 'Plated dinner'),
    _ModalInfoRow('Vegetarian', '12 guests'),
    _ModalInfoRow('Vegan', '4 guests'),
    _ModalInfoRow('Gluten-free', '6 guests'),
    _ModalInfoRow('Allergies', '5 guests'),
    SizedBox(height: 12),
    Text('Menu enhancements still need review. Check cocktail hour extras and late-night snacks.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5)),
  ]);

  Widget _lookbookContent() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const _ModalInfoRow('Images saved', '47'),
    const _ModalInfoRow('Boards', '3 Pinterest boards'),
    const _ModalInfoRow('Colour palette', 'In progress'),
    const SizedBox(height: 12),
    Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)), child: const Text('Color palette needs final selection. Narrow down to 3 primary colors.', style: TextStyle(fontSize: 13, height: 1.5))),
  ]);

  Widget _seatingContent() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const _ModalInfoRow('Status', 'Not started'),
    const _ModalInfoRow('Guests', '120 to place'),
    const _ModalInfoRow('Tables', '15 planned'),
    const SizedBox(height: 12),
    Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.udoCrimson.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoCrimson.withValues(alpha: 0.2))), child: const Text('Guest placement has not been arranged yet. Start once RSVPs are confirmed.', style: TextStyle(fontSize: 13, height: 1.5, color: AppTheme.udoCrimson))),
  ]);

  Widget _travelContent() => const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _ModalInfoRow('Travelling guests', '32'),
    _ModalInfoRow('Transport requests', '12'),
    _ModalInfoRow('Hotel blocks', '2 arranged'),
    _ModalInfoRow('Shuttle groups', '3 planned'),
    SizedBox(height: 12),
    Text('Send the logistics link to travelling guests so they can confirm their arrangements.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5)),
  ]);

  Widget _weekendContent() => const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _ModalInfoRow('Rehearsal dinner', 'Friday 7:00 PM'),
    _ModalInfoRow('Post-wedding brunch', 'Sunday 11:00 AM'),
    _ModalInfoRow('Welcome party', 'Venue needed'),
    SizedBox(height: 12),
    Text('Welcome party venue still needs booking. Consider a relaxed outdoor venue.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5)),
  ]);

  Widget _honeymoonContent() => const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _ModalInfoRow('Destination', 'Bali, Indonesia'),
    _ModalInfoRow('Duration', '10 days'),
    _ModalInfoRow('Flights', 'Booked'),
    _ModalInfoRow('Hotel', 'Confirmed'),
    _ModalInfoRow('Activities', '3 planned'),
    SizedBox(height: 12),
    Text('Almost ready. Double-check travel insurance and entry requirements.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5)),
  ]);

  Widget _memoriesContent() => const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _ModalInfoRow('Speeches', '4 confirmed'),
    _ModalInfoRow('Cultural traditions', '2 planned'),
    _ModalInfoRow('Photo booth', 'Not set up'),
    _ModalInfoRow('Guestbook', 'Needed'),
    SizedBox(height: 12),
    Text('Photo booth and guestbook setup still needed.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5)),
  ]);

  Widget _insuranceContent() => const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _ModalInfoRow('Status', 'Policy active'),
    _ModalInfoRow('Provider', 'WedSure Pro'),
    _ModalInfoRow('Coverage', '\$50,000'),
    _ModalInfoRow('Cancellation', 'Covered'),
    _ModalInfoRow('Liability', 'Covered'),
    SizedBox(height: 12),
    Text('You are fully covered. Policy expires 30 days after your wedding date.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5)),
  ]);

  Widget _remindersContent() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const _ModalInfoRow('Status', 'Active'),
    const _ModalInfoRow('Frequency', 'Weekly'),
    const _ModalInfoRow('Next reminder', 'Monday 9:00 AM'),
    const SizedBox(height: 12),
    for (final r in ['RSVP deadline — 3 weeks away', 'Final headcount due in 2 weeks', 'Vendor payments — 1 due this week'])
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.notifications_outlined, color: AppTheme.udoGreen, size: 16),
          const SizedBox(width: 10),
          Expanded(child: Text(r, style: const TextStyle(fontSize: 13))),
        ]),
      ),
  ]);
}

class _BudgetStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _BudgetStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
    const SizedBox(height: 4),
    Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
  ]));
}

class _BudgetCatRow extends StatelessWidget {
  final String name, status;
  final int spent, allocated;
  const _BudgetCatRow(this.name, this.spent, this.allocated, this.status);
  @override
  Widget build(BuildContext context) {
    final color = status == 'complete' ? AppTheme.udoGreen : status == 'on-track' ? Colors.blue : Colors.orange;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          Text('\$$spent / \$$allocated', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        ]),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: spent / allocated, backgroundColor: Colors.white, valueColor: AlwaysStoppedAnimation(color), minHeight: 4, borderRadius: BorderRadius.circular(2)),
      ]),
    );
  }
}

class _ModalInfoRow extends StatelessWidget {
  final String label, value;
  const _ModalInfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );
}
