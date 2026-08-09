import 'dart:async';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/date_formatters.dart' as udo_dates;
import '../../../../shared/widgets/udo_design_system.dart';
import '../../../gallery/presentation/providers/gallery_provider.dart';
import '../../../guests/presentation/providers/guests_provider.dart';
import '../../../guests/presentation/providers/logistics_provider.dart';
import '../../../guests/presentation/providers/messages_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../memories/presentation/providers/memories_provider.dart';
import '../../../more/presentation/providers/more_operations_provider.dart';
import '../../../more/presentation/screens/more_screen.dart';
import '../../../more/presentation/screens/notifications_screen.dart';
import '../../../registry/presentation/providers/registry_provider.dart';
import '../../../wedding_party/presentation/providers/wedding_party_provider.dart';
import '../../../wedding_story/presentation/providers/wedding_story_provider.dart';
import '../providers/food_provider.dart';
import '../providers/plan_extras_provider.dart';
import '../providers/plan_provider.dart';
import '../providers/seating_provider.dart';

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

int? _asIntId(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _humanizeStatus(String? value) {
  if (value == null || value.isEmpty) return null;
  return '${value[0].toUpperCase()}${value.substring(1).replaceAll('_', ' ')}';
}

String? _nullIfBlank(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _dateOnly(dynamic value) {
  if (value == null) return '';
  final parsed = udo_dates.parseApiDate(value);
  if (parsed == null) return value.toString();
  return _formatDate(parsed);
}

String? _formatTaskDueDate(dynamic value) {
  if (value == null) return null;
  final formatted = udo_dates.formatApiDate(value);
  return formatted.isEmpty ? null : formatted;
}

class PlanScreen extends ConsumerStatefulWidget {
  final String? initialSection;
  final String? initialAction;

  const PlanScreen({super.key, this.initialSection, this.initialAction});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  var _drawerOpen = false;
  final _tabHistory = <int>[];
  double? _dragStartX;
  double _dragDeltaX = 0;
  bool _handledInitialAction = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: _planPages.length,
      vsync: this,
      initialIndex: _planSectionIndex(widget.initialSection),
    );
    _tabs.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleInitialAction());
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
    final guests = ref.watch(guestsProvider).guests;
    final logisticsSummary = ref.watch(logisticsProvider).summary;
    final activeWedding = ref.watch(moreOperationsProvider).activeWedding;

    return Scaffold(
      backgroundColor: UdoDesign.bg,
      floatingActionButton: _tabs.index == 2
          ? FloatingActionButton(
              backgroundColor: UdoDesign.plan,
              onPressed: () => showAddTaskSheet(context, notifier),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (details) {
              _dragStartX = details.localPosition.dx;
              _dragDeltaX = 0;
            },
            onHorizontalDragUpdate: (details) {
              _dragDeltaX += details.delta.dx;
            },
            onHorizontalDragEnd: (details) {
              final fromLeftEdge = (_dragStartX ?? double.infinity) <= 36;
              final fastRightSwipe = details.primaryVelocity != null &&
                  details.primaryVelocity! > 450;
              if (!_drawerOpen &&
                  fromLeftEdge &&
                  (_dragDeltaX > 72 || fastRightSwipe)) {
                _goBackPlanPage();
              }
              _dragStartX = null;
              _dragDeltaX = 0;
            },
            child: Column(
              children: [
                _PlanHeader(
                  title: _planPages[_tabs.index].title,
                  isOverview: _tabs.index == 0,
                  onMenuTap: () => setState(() => _drawerOpen = true),
                  // Only shown where it actually edits something on the
                  // current page — every other tab already has its own
                  // in-body "+ Add"/edit affordance, so a header-level pencil
                  // there was either a dead end or a confusing jump to the
                  // Wedding Details tab.
                  onEditTap: _tabs.index == 14 && activeWedding != null
                      ? () => _openWeddingDetailsSheet(
                            context,
                            ref,
                            ref.read(moreOperationsProvider.notifier),
                            activeWedding,
                          )
                      : _tabs.index == 5
                          ? () => showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(24))),
                                builder: (_) =>
                                    _AddTimelineEventSheet(notifier: notifier),
                              )
                          : null,
                ),
                if (state.isOffline)
                  _StaleDataBanner(
                      cachedAt: state.cachedAt, onRefresh: notifier.refresh),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _PlanLandingTab(
                        state: state,
                        guests: guests,
                        logisticsSummary: logisticsSummary,
                        onTabJump: _navigatePlanPage,
                      ),
                      _YourVisionTab(state: state),
                      _TasksTab(state: state, notifier: notifier),
                      _BudgetTab(
                        state: state,
                        notifier: notifier,
                        onOpenSchedule: () => _navigatePlanPage(7),
                      ),
                      _VendorsTab(state: state, notifier: notifier),
                      _TimelineTab(state: state, notifier: notifier),
                      const _PlanRegistryTab(),
                      _PaymentsTab(state: state),
                      const _FoodTab(),
                      const _WeddingWeekendTab(),
                      const _WeddingPartyTab(),
                      _HoneymoonTab(onViewBudget: () => _navigatePlanPage(3)),
                      const _InsuranceTab(),
                      _DocumentsTab(state: state, onTabJump: _navigatePlanPage),
                      const _DetailsTab(),
                      _InsightsTab(onTabJump: _navigatePlanPage),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _PlanningDrawer(
            open: _drawerOpen,
            activeIndex: _tabs.index,
            onClose: () => setState(() => _drawerOpen = false),
            onNavigate: _navigatePlanPage,
          ),
        ],
      ),
    );
  }

  void _navigatePlanPage(int index) {
    if (index < 0 || index >= _tabs.length) return;
    if (index == 10) {
      if (_drawerOpen) {
        setState(() => _drawerOpen = false);
      }
      context.push('/wedding-party?tab=overview');
      return;
    }
    if (index != _tabs.index) {
      _tabHistory.remove(_tabs.index);
      _tabHistory.add(_tabs.index);
      if (_tabHistory.length > 12) _tabHistory.removeAt(0);
    }
    _tabs.animateTo(index);
    if (_drawerOpen) {
      setState(() => _drawerOpen = false);
    }
  }

  void _goBackPlanPage() {
    final previous = _tabHistory.isNotEmpty
        ? _tabHistory.removeLast()
        : (_tabs.index > 0 ? _tabs.index - 1 : 0);
    if (previous == _tabs.index) return;
    _tabs.animateTo(previous);
  }

  void _handleInitialAction() {
    if (_handledInitialAction || !mounted) return;
    final action = widget.initialAction?.trim().toLowerCase();
    if (action != 'add-event') return;
    _handledInitialAction = true;
    if (_tabs.index != _planSectionIndex('timeline')) {
      _tabs.animateTo(_planSectionIndex('timeline'));
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddTimelineEventSheet(
        notifier: ref.read(planProvider.notifier),
      ),
    );
  }
}

// ── HEADER ─────────────────────────────────────────────────────────────────────

class _PlanPageMeta {
  final String title;
  final IconData icon;
  final String badge;
  final Color badgeColor;

  const _PlanPageMeta({
    required this.title,
    required this.icon,
    this.badge = '',
    this.badgeColor = UdoDesign.muted,
  });
}

const _planPages = [
  _PlanPageMeta(title: 'Overview', icon: Icons.dashboard_outlined),
  _PlanPageMeta(
      title: 'Vision Board',
      icon: Icons.auto_awesome_mosaic_outlined,
      badge: 'Boards',
      badgeColor: UdoDesign.blue),
  _PlanPageMeta(
      title: 'Tasks',
      icon: Icons.check_circle_outline,
      badge: 'Open',
      badgeColor: UdoDesign.amber),
  _PlanPageMeta(
      title: 'Budget',
      icon: Icons.account_balance_wallet_outlined,
      badge: 'On Track',
      badgeColor: UdoDesign.sage),
  _PlanPageMeta(
      title: 'Vendors',
      icon: Icons.storefront_outlined,
      badge: 'Quotes',
      badgeColor: UdoDesign.rose),
  _PlanPageMeta(
      title: 'Timeline',
      icon: Icons.timeline_outlined,
      badge: 'Build',
      badgeColor: UdoDesign.sage),
  _PlanPageMeta(
      title: 'Registry',
      icon: Icons.card_giftcard_outlined,
      badge: 'Gifts',
      badgeColor: UdoDesign.gold),
  _PlanPageMeta(
      title: 'Payments',
      icon: Icons.payments_outlined,
      badge: 'Due',
      badgeColor: UdoDesign.amber),
  _PlanPageMeta(
      title: 'Food & Dining',
      icon: Icons.restaurant_menu_outlined,
      badge: 'Meals',
      badgeColor: UdoDesign.amber),
  _PlanPageMeta(
      title: 'Wedding Weekend',
      icon: Icons.event_outlined,
      badge: 'Events',
      badgeColor: UdoDesign.blue),
  _PlanPageMeta(
      title: 'Wedding Party',
      icon: Icons.groups_2_outlined,
      badge: 'Roles',
      badgeColor: UdoDesign.amber),
  _PlanPageMeta(
      title: 'Honeymoon',
      icon: Icons.flight_takeoff_outlined,
      badge: 'Trip',
      badgeColor: UdoDesign.sage),
  _PlanPageMeta(
      title: 'Insurance',
      icon: Icons.verified_user_outlined,
      badge: 'Protect',
      badgeColor: UdoDesign.rose),
  _PlanPageMeta(
      title: 'Documents',
      icon: Icons.folder_copy_outlined,
      badge: 'Vault',
      badgeColor: UdoDesign.blue),
  _PlanPageMeta(
      title: 'Wedding Details',
      icon: Icons.edit_note_outlined,
      badge: 'Profile',
      badgeColor: UdoDesign.rose),
  _PlanPageMeta(
      title: 'Insights',
      icon: Icons.insights_outlined,
      badge: 'Reports',
      badgeColor: UdoDesign.sage),
];

const _planSectionIndexes = {
  'overview': 0,
  'vision': 1,
  'vision-board': 1,
  'tasks': 2,
  'planning': 2,
  'budget': 3,
  'vendors': 4,
  'timeline': 5,
  'registry': 6,
  'payments': 7,
  'food': 8,
  'meals': 8,
  'wedding-weekend': 9,
  'party': 10,
  'wedding-party': 10,
  'honeymoon': 11,
  'insurance': 12,
  'documents': 13,
  'details': 14,
  'wedding-details': 14,
  'insights': 15,
};

int _planSectionIndex(String? section) {
  final key = section?.trim().toLowerCase();
  if (key == null || key.isEmpty) return 0;
  return _planSectionIndexes[key] ?? 0;
}

class _StaleDataBanner extends StatelessWidget {
  final DateTime? cachedAt;
  final Future<void> Function() onRefresh;

  const _StaleDataBanner({required this.cachedAt, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final saved = cachedAt == null
        ? 'saved data'
        : 'data saved ${TimeOfDay.fromDateTime(cachedAt!).format(context)}';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8C36A)),
      ),
      child: Row(children: [
        const Icon(Icons.wifi_off_outlined, size: 18, color: Color(0xFF9A6B00)),
        const SizedBox(width: 10),
        Expanded(
            child: Text('Offline mode: showing $saved.',
                style:
                    const TextStyle(fontSize: 12, color: Color(0xFF6B4B00)))),
        TextButton(onPressed: onRefresh, child: const Text('Retry')),
      ]),
    );
  }
}

class _PlanHeader extends StatefulWidget {
  final String title;
  final bool isOverview;
  final VoidCallback onMenuTap;
  final VoidCallback? onEditTap;

  const _PlanHeader({
    required this.title,
    required this.isOverview,
    required this.onMenuTap,
    this.onEditTap,
  });

  @override
  State<_PlanHeader> createState() => _PlanHeaderState();
}

class _PlanHeaderState extends State<_PlanHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: UdoDesign.bg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _RoundIconButton(icon: Icons.menu, onTap: widget.onMenuTap),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: UdoDesign.serif(
                      size: widget.isOverview ? 36 : 24,
                      color: UdoDesign.text,
                    ),
                    child: Text(widget.isOverview ? 'Plan' : widget.title),
                  ),
                ])),
            if (widget.onEditTap != null)
              _RoundIconButton(
                icon: Icons.edit_outlined,
                onTap: widget.onEditTap!,
              ),
          ]),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: UdoDesign.card,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
              width: 52,
              height: 52,
              child: Icon(icon, color: UdoDesign.text, size: 24)),
        ),
      );
}
// ── OVERVIEW TAB ───────────────────────────────────────────────────────────────

class _PlanningDrawer extends StatelessWidget {
  final bool open;
  final int activeIndex;
  final VoidCallback onClose;
  final void Function(int) onNavigate;

  const _PlanningDrawer({
    required this.open,
    required this.activeIndex,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !open,
      child: Stack(children: [
        AnimatedOpacity(
          opacity: open ? 1 : 0,
          duration: const Duration(milliseconds: 240),
          child: GestureDetector(
            onTap: onClose,
            child: Container(color: UdoDesign.text.withValues(alpha: 0.30)),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          top: 0,
          bottom: 0,
          right: open ? 0 : -380,
          width: MediaQuery.sizeOf(context).width * 0.86,
          child: Material(
            color: UdoDesign.bg,
            elevation: 18,
            shadowColor: Colors.black.withValues(alpha: 0.18),
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(32)),
            child: SafeArea(
              bottom: false,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(32)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 18, 12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: Text('Planning',
                                        style: UdoDesign.serif(size: 38))),
                                IconButton(
                                  tooltip: 'Close',
                                  onPressed: onClose,
                                  icon: const Icon(Icons.close,
                                      color: UdoDesign.sub),
                                ),
                              ]),
                              const SizedBox(height: 16),
                              Row(children: [
                                Expanded(
                                    child: Container(
                                        height: 1,
                                        color: UdoDesign.gold
                                            .withValues(alpha: 0.45))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text('*',
                                      style: UdoDesign.sans(
                                          size: 16, color: UdoDesign.gold)),
                                ),
                                Expanded(
                                    child: Container(
                                        height: 1,
                                        color: UdoDesign.gold
                                            .withValues(alpha: 0.45))),
                              ]),
                            ]),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                          children: [
                            for (var i = 0; i < _planPages.length; i++)
                              _PlanDrawerRow(
                                meta: _planPages[i],
                                active: activeIndex == i,
                                onTap: () => onNavigate(i),
                              ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              child: Divider(color: UdoDesign.stone),
                            ),
                            _PlanUtilityRow(
                                icon: Icons.settings_outlined,
                                label: 'Settings',
                                onTap: () {
                                  onClose();
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(24))),
                                    builder: (_) =>
                                        const WeddingSettingsSheet(),
                                  );
                                }),
                            _PlanUtilityRow(
                                icon: Icons.help_outline,
                                label: 'Help & Support',
                                onTap: () {
                                  onClose();
                                  showHelpSheet(context);
                                }),
                          ],
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _PlanDrawerRow extends StatelessWidget {
  final _PlanPageMeta meta;
  final bool active;
  final VoidCallback onTap;

  const _PlanDrawerRow({
    required this.meta,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? UdoDesign.plan : UdoDesign.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: active
            ? UdoDesign.plan.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 64,
            child: Row(children: [
              const SizedBox(width: 14),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: active
                      ? UdoDesign.plan.withValues(alpha: 0.14)
                      : UdoDesign.stone.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(meta.icon,
                    color: active ? UdoDesign.plan : UdoDesign.muted, size: 19),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  meta.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(
                      size: 15,
                      weight: active ? FontWeight.w700 : FontWeight.w500,
                      color: color),
                ),
              ),
              if (meta.badge.isNotEmpty) ...[
                UdoBadge(
                    label: meta.badge,
                    color: active ? UdoDesign.plan : meta.badgeColor),
                const SizedBox(width: 8),
              ],
              Icon(Icons.chevron_right,
                  color: active ? UdoDesign.plan : UdoDesign.stone, size: 18),
              const SizedBox(width: 12),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PlanUtilityRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PlanUtilityRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 56,
          child: Row(children: [
            const SizedBox(width: 14),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: UdoDesign.stone.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: UdoDesign.muted, size: 19),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(label,
                    style: UdoDesign.sans(size: 15, color: UdoDesign.sub))),
            const Icon(Icons.chevron_right, color: UdoDesign.stone, size: 18),
            const SizedBox(width: 12),
          ]),
        ),
      ),
    );
  }
}

String _insightsIssueLabel(String key, int count) {
  final noun = count == 1 ? '' : 's';
  switch (key) {
    case 'pending_rsvps':
      return '$count guest$noun have not responded yet';
    case 'missing_meals':
      return '$count confirmed guest$noun missing a meal choice';
    case 'missing_arrival_info':
      return '$count traveling guest$noun missing arrival details';
    case 'missing_accommodation':
      return '$count traveling guest$noun without a hotel assignment';
    case 'missing_transport':
      return '$count traveling guest$noun without transport arranged';
    case 'unassigned_seating':
      return '$count confirmed guest$noun without a seat';
    case 'vip_needs_attention':
      return '$count VIP guest$noun need logistics attention';
    default:
      return '$count $key';
  }
}

Color _insightsPriorityColor(String? priority) {
  switch (priority) {
    case 'critical':
      return UdoDesign.rose;
    case 'high':
      return UdoDesign.amber;
    case 'medium':
      return UdoDesign.gold;
    default:
      return UdoDesign.sage;
  }
}

Color _insightsScoreColor(int score) {
  if (score >= 85) return UdoDesign.sage;
  if (score >= 65) return UdoDesign.plan;
  if (score >= 40) return UdoDesign.amber;
  return UdoDesign.rose;
}

class _InsightsTab extends ConsumerWidget {
  final void Function(int) onTabJump;
  const _InsightsTab({required this.onTabJump});

  void _openAction(BuildContext context, Map<String, dynamic> action) {
    final id = (action['id'] ?? '').toString();
    final target = (action['target'] ?? '').toString();
    if (id == 'live-incidents') {
      context.go('/live');
      return;
    }
    if (id == 'overdue-tasks' || id.startsWith('task-')) {
      onTabJump(2);
      return;
    }
    if (id == 'pending-rsvps' || id == 'vip-attention') {
      context.go('/guests?tab=Guest%20list');
      return;
    }
    if (id == 'budget-risk') {
      onTabJump(3);
      return;
    }
    if (id == 'timeline-empty') {
      onTabJump(5);
      return;
    }
    if (target == 'live') {
      context.go('/live');
    } else if (target == 'guests') {
      context.go('/guests');
    } else {
      onTabJump(0);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider);
    final cc = home.commandCenter;

    if (home.isLoading && cc.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));
    }

    final planning = cc['planning_health'] as Map<String, dynamic>? ?? {};
    final rsvp = cc['rsvp_health'] as Map<String, dynamic>? ?? {};
    final budget = cc['budget_status'] as Map<String, dynamic>? ?? {};
    final guestIssues = cc['guest_issues'] as Map<String, dynamic>? ?? {};
    final live = cc['live_readiness'] as Map<String, dynamic>? ?? {};
    final vendorReadiness =
        live['vendor_readiness'] as Map<String, dynamic>? ?? {};
    final actions = ((cc['upcoming_actions'] as List?) ?? const [])
        .cast<Map<String, dynamic>>();
    final alerts = cc['smart_alerts'] as Map<String, dynamic>? ?? {};

    final planningScore = (planning['score'] as num?)?.toInt() ?? 0;
    final liveScore = (live['score'] as num?)?.toInt() ?? 0;
    final rsvpCompletion = (rsvp['completion'] as num?)?.toInt() ?? 0;
    final budgetUsage = (budget['usage'] as num?)?.toInt() ?? 0;
    final vendorConfirmed =
        (vendorReadiness['confirmed'] as num?)?.toInt() ?? 0;
    final vendorTotal = (vendorReadiness['total'] as num?)?.toInt() ?? 0;

    final issueRows = <MapEntry<String, int>>[];
    for (final key in [
      'vip_needs_attention',
      'pending_rsvps',
      'unassigned_seating',
      'missing_meals',
      'missing_arrival_info',
      'missing_accommodation',
      'missing_transport',
    ]) {
      final count = (guestIssues[key] as num?)?.toInt() ?? 0;
      if (count > 0) issueRows.add(MapEntry(key, count));
    }

    final totalAlerts = (alerts['total_active'] as num?)?.toInt() ?? 0;
    final criticalAlerts = (alerts['critical'] as num?)?.toInt() ?? 0;
    final highAlerts = (alerts['high'] as num?)?.toInt() ?? 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
      children: [
        UdoCard(
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: UdoDesign.plan.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.insights_outlined,
                  color: UdoDesign.plan, size: 26),
            ),
            const SizedBox(height: 18),
            Text('Insights', style: UdoDesign.serif(size: 34)),
            const SizedBox(height: 8),
            Text('What needs executive attention?',
                style: UdoDesign.sans(
                    size: 16, weight: FontWeight.w700, color: UdoDesign.sub)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: _InsightsScoreRing(
                  label: 'Planning health',
                  score: planningScore,
                  caption: (planning['label'] as String?) ?? '',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InsightsScoreRing(
                  label: 'Live readiness',
                  score: liveScore,
                  caption: (live['label'] as String?) ?? '',
                ),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            _InsightsKpiTile(
              label: 'RSVP completion',
              value: '$rsvpCompletion%',
              detail:
                  '${rsvp['confirmed'] ?? 0} confirmed · ${rsvp['pending'] ?? 0} pending',
              progress: rsvpCompletion / 100,
              color: UdoDesign.guests,
              onTap: () => context.go('/guests?tab=Guest%20list'),
            ),
            _InsightsKpiTile(
              label: 'Budget usage',
              value: '$budgetUsage%',
              detail:
                  '${_money(_asDouble(budget['spent']))} of ${_money(_asDouble(budget['total']))}',
              progress: budgetUsage / 100,
              color: UdoDesign.budget,
              onTap: () => onTabJump(3),
            ),
            _InsightsKpiTile(
              label: 'Vendor readiness',
              value: '$vendorConfirmed/$vendorTotal',
              detail:
                  '${vendorReadiness['missing_contracts'] ?? 0} missing contract(s)',
              progress: vendorTotal > 0 ? vendorConfirmed / vendorTotal : 0,
              color: UdoDesign.plan,
              onTap: () => onTabJump(4),
            ),
            _InsightsKpiTile(
              label: 'Smart alerts',
              value: '$totalAlerts',
              detail: totalAlerts == 0
                  ? 'Nothing needs review'
                  : '$criticalAlerts critical · $highAlerts high',
              progress: totalAlerts == 0 ? 0 : 1,
              color: criticalAlerts > 0 ? UdoDesign.rose : UdoDesign.amber,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const NotificationsScreen())),
            ),
          ],
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 20),
          const UdoSectionHeader(title: 'Needs attention'),
          UdoCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (var i = 0; i < actions.length; i++)
                _InsightsActionRow(
                  action: actions[i],
                  showDivider: i < actions.length - 1,
                  onTap: () => _openAction(context, actions[i]),
                ),
            ]),
          ),
        ],
        if (issueRows.isNotEmpty) ...[
          const SizedBox(height: 20),
          const UdoSectionHeader(title: 'Guest checklist'),
          UdoCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (var i = 0; i < issueRows.length; i++)
                _InsightsIssueRow(
                  label:
                      _insightsIssueLabel(issueRows[i].key, issueRows[i].value),
                  showDivider: i < issueRows.length - 1,
                  onTap: () => context.go('/guests?tab=Guest%20list'),
                ),
            ]),
          ),
        ],
      ],
    );
  }
}

class _InsightsScoreRing extends StatelessWidget {
  final String label;
  final int score;
  final String caption;

  const _InsightsScoreRing({
    required this.label,
    required this.score,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final color = _insightsScoreColor(score);
    return Column(children: [
      UdoRingProgress(
        value: score / 100,
        size: 84,
        color: color,
        center: Text('$score',
            style: UdoDesign.sans(
                size: 20, weight: FontWeight.w800, color: color)),
      ),
      const SizedBox(height: 10),
      Text(label,
          textAlign: TextAlign.center,
          style: UdoDesign.sans(size: 12.5, weight: FontWeight.w600)),
      const SizedBox(height: 2),
      Text(caption,
          textAlign: TextAlign.center,
          style: UdoDesign.sans(size: 11.5, color: UdoDesign.muted)),
    ]);
  }
}

class _InsightsKpiTile extends StatelessWidget {
  final String label;
  final String value;
  final String detail;
  final double progress;
  final Color color;
  final VoidCallback onTap;

  const _InsightsKpiTile({
    required this.label,
    required this.value,
    required this.detail,
    required this.progress,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(14),
      radius: 18,
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: UdoDesign.sans(
                size: 11.5, weight: FontWeight.w600, color: UdoDesign.muted)),
        const SizedBox(height: 4),
        Text(value,
            style: UdoDesign.sans(
                size: 22, weight: FontWeight.w800, color: color)),
        const Spacer(),
        Text(detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UdoDesign.sans(size: 10.5, color: UdoDesign.muted)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: UdoDesign.stone,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
          ),
        ),
      ]),
    );
  }
}

class _InsightsActionRow extends StatelessWidget {
  final Map<String, dynamic> action;
  final bool showDivider;
  final VoidCallback onTap;

  const _InsightsActionRow({
    required this.action,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _insightsPriorityColor(action['priority'] as String?);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: UdoDesign.border))
              : null,
        ),
        child: Row(children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text((action['title'] ?? '').toString(),
                  style: UdoDesign.sans(size: 13.5, weight: FontWeight.w600)),
              if ((action['reason'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text((action['reason']).toString(),
                    style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
              ],
            ]),
          ),
          const Icon(Icons.chevron_right, size: 18, color: UdoDesign.muted),
        ]),
      ),
    );
  }
}

class _InsightsIssueRow extends StatelessWidget {
  final String label;
  final bool showDivider;
  final VoidCallback onTap;

  const _InsightsIssueRow({
    required this.label,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(bottom: BorderSide(color: UdoDesign.border))
              : null,
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, size: 16, color: UdoDesign.amber),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: UdoDesign.sans(size: 13, weight: FontWeight.w500))),
          const Icon(Icons.chevron_right, size: 18, color: UdoDesign.muted),
        ]),
      ),
    );
  }
}

class _PlanLandingTab extends ConsumerWidget {
  final PlanState state;
  final List<Map<String, dynamic>> guests;
  final Map<String, dynamic> logisticsSummary;
  final void Function(int) onTabJump;
  const _PlanLandingTab(
      {required this.state,
      required this.guests,
      required this.logisticsSummary,
      required this.onTabJump});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));
    }

    final wedding = ref.watch(moreOperationsProvider).activeWedding;
    final rawEventDate = wedding?['event_date'];
    final eventDate = rawEventDate is DateTime
        ? rawEventDate
        : rawEventDate is String
            ? DateTime.tryParse(rawEventDate)
            : null;
    final location = [wedding?['city'], wedding?['country']]
        .where((v) => v is String && v.trim().isNotEmpty)
        .join(', ');
    final daysToGo = eventDate == null
        ? null
        : max(0, eventDate.difference(DateTime.now()).inDays);
    final greeting = _dayGreeting(DateTime.now());
    final firstName = ((wedding?['owner'] as Map?)?['first_name'] as String?) ??
        (wedding?['owner_first_name'] as String?) ??
        'there';
    final completedTasks =
        state.tasks.where((t) => t['completed'] == true).length;
    final totalTasks = state.tasks.length;
    final planningProgress = totalTasks == 0
        ? 0
        : ((completedTasks / totalTasks) * 100).round().clamp(0, 100);
    final respondedGuests = guests
        .where((g) =>
            g['attending_status'] == 'yes' || g['attending_status'] == 'no')
        .length;
    final awaitingGuests = max(0, guests.length - respondedGuests);
    final travellingGuests =
        (logisticsSummary['travelling_guests'] as num?)?.toInt() ?? 0;
    final missingAccommodation =
        (logisticsSummary['missing_accommodation'] as num?)?.toInt() ?? 0;
    final missingTransport =
        (logisticsSummary['missing_transport'] as num?)?.toInt() ?? 0;
    final travelGaps = missingAccommodation + missingTransport;
    final travelReady = max(0, travellingGuests - travelGaps);
    final timelineProgress = state.timelineItems.isEmpty ? 0 : 80;
    final totalBudget = _asDouble(state.budgetSummary['total_budget']);
    final remainingBudget = _asDouble(state.budgetSummary['remaining_budget']);
    final balanceDue = _asDouble(state.budgetSummary['balance_due']);
    final budgetRemaining = remainingBudget > 0
        ? remainingBudget
        : max<double>(0, totalBudget - balanceDue);
    final upcomingTasks = [...state.tasks.where((t) => t['completed'] != true)]
      ..sort((a, b) {
        const priority = {'high': 0, 'medium': 1, 'low': 2};
        final pa = priority[a['priority'] as String? ?? 'low'] ?? 2;
        final pb = priority[b['priority'] as String? ?? 'low'] ?? 2;
        if (pa != pb) return pa.compareTo(pb);
        return (a['due_date'] as String? ?? '9999')
            .compareTo(b['due_date'] as String? ?? '9999');
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
      children: [
        _GreetingCard(
            greeting: greeting,
            firstName: firstName,
            onTap: () => onTabJump(15)),
        const SizedBox(height: 20),
        _WeddingDayCard(
          date: eventDate == null
              ? 'Wedding date not set'
              : DateFormat('MMMM d, yyyy').format(eventDate),
          days: daysToGo == null
              ? 'Add your wedding date'
              : '$daysToGo days to go',
          location: location.isEmpty ? 'Location not set' : location,
        ),
        const SizedBox(height: 24),
        const _TitleRow(title: 'At a glance'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.88,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            _ProgressGlanceCard(
                progress: planningProgress,
                completed: completedTasks,
                total: totalTasks,
                onTap: () => onTabJump(2)),
            _GlanceCard(
                icon: Icons.attach_money,
                tint: const Color(0xFFEAF5F1),
                title: 'Budget',
                value: _money(budgetRemaining),
                detail: totalBudget > 0
                    ? 'remaining of ${_money(totalBudget)}'
                    : 'set budget',
                status: 'On Track',
                statusColor: const Color(0xFF11745A),
                onTap: () => onTabJump(3)),
            _GlanceCard(
                icon: Icons.people_outline,
                tint: const Color(0xFFEAF4FB),
                title: 'Guests',
                value: '$respondedGuests',
                detail: 'of ${guests.length} responded',
                status: '$awaitingGuests awaiting',
                statusColor: const Color(0xFF276A94),
                onTap: () => context.go('/guests?tab=Guest%20list')),
            _GlanceCard(
                icon: Icons.flight_takeoff_outlined,
                tint: const Color(0xFFFFF0E7),
                title: 'Travel',
                value: '$travelReady',
                detail: 'of $travellingGuests ready',
                status: travelGaps == 0 ? 'Ready' : '$travelGaps missing',
                statusColor: travelGaps == 0
                    ? const Color(0xFF11745A)
                    : const Color(0xFFB06A00),
                onTap: () => context.go('/guests?tab=Logistics')),
            _GlanceCard(
                icon: Icons.calendar_today_outlined,
                tint: const Color(0xFFF0EBFA),
                title: 'Timeline',
                value: '$timelineProgress%',
                detail: 'complete',
                status:
                    timelineProgress >= 80 ? 'Needs attention' : 'In progress',
                statusColor: const Color(0xFFB06A00),
                onTap: () => onTabJump(5)),
          ],
        ),
        const SizedBox(height: 26),
        _TitleRow(
            title: 'Upcoming Tasks',
            action: 'View all tasks',
            onTap: () => onTabJump(2)),
        const SizedBox(height: 4),
        const Text('Your next planning tasks, sorted by due date and priority.',
            style: TextStyle(fontSize: 13, color: Color(0xFF7B7771))),
        const SizedBox(height: 12),
        _UpcomingTasksPanel(
            tasks: upcomingTasks.take(3).toList(), onTap: () => onTabJump(2)),
        const SizedBox(height: 24),
        const Text('Quick Actions',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827))),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _QuickAction(
                  icon: Icons.storefront_outlined,
                  label: 'Add vendor',
                  onTap: () => onTabJump(4))),
          const SizedBox(width: 10),
          Expanded(
              child: _QuickAction(
                  icon: Icons.groups_2_outlined,
                  label: 'Edit wedding party',
                  onTap: () => onTabJump(10))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _QuickAction(
                  icon: Icons.card_giftcard_outlined,
                  label: 'Create registry',
                  onTap: () => onTabJump(6))),
          const SizedBox(width: 10),
          Expanded(
              child: _QuickAction(
                  icon: Icons.share_outlined,
                  label: 'Share plan',
                  onTap: () => Share.share(
                      'Wedding plan is $planningProgress% complete.'))),
        ]),
      ],
    );
  }

  String _money(double value) =>
      NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(value);

  String _dayGreeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _GreetingCard extends StatelessWidget {
  final String greeting;
  final String firstName;
  final VoidCallback? onTap;
  const _GreetingCard(
      {required this.greeting, required this.firstName, this.onTap});

  @override
  Widget build(BuildContext context) => _SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.all(22),
        child: Row(children: [
          Container(
              width: 62,
              height: 62,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFF7F4F2)),
              child: const Icon(Icons.calendar_month_outlined,
                  size: 30, color: Color(0xFF111827))),
          const SizedBox(width: 18),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('$greeting, $firstName',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827))),
                const SizedBox(height: 8),
                const Text(
                    "Here's what's happening with\nyour wedding planning.",
                    style: TextStyle(
                        fontSize: 13, height: 1.55, color: Color(0xFF6D6A66))),
              ])),
          const Icon(Icons.chevron_right, color: Color(0xFF7B7771)),
        ]),
      );
}

class _WeddingDayCard extends StatelessWidget {
  final String date, days, location;
  const _WeddingDayCard(
      {required this.date, required this.days, required this.location});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 170,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/images/plan_landing_hero.png',
                fit: BoxFit.cover, alignment: Alignment.centerRight),
            Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
              Colors.white,
              Color(0xEFFFFFFF),
              Color(0x00FFFFFF)
            ], stops: [
              0,
              0.48,
              1
            ]))),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 20, 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('YOUR WEDDING DAY',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6D6A66))),
                    const SizedBox(height: 16),
                    Text(date,
                        style: const TextStyle(
                            fontSize: 33,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF111827),
                            height: 1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 12),
                    Text(days,
                        style: const TextStyle(
                            fontSize: 18, color: Color(0xFF6D6A66))),
                    const Spacer(),
                    Row(children: [
                      const Icon(Icons.location_on_outlined,
                          size: 18, color: Color(0xFF6D6A66)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(location,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF4F4B47)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                    ]),
                  ]),
            ),
          ]),
        ),
      );
}

class _TitleRow extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;
  const _TitleRow({required this.title, this.action, this.onTap});

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827)))),
        if (action != null && onTap != null)
          TextButton(
              onPressed: onTap,
              child: Row(children: [
                Text(action!,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF82765E))),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    size: 18, color: Color(0xFF82765E)),
              ])),
      ]);
}

class _ProgressGlanceCard extends StatelessWidget {
  final int progress, completed, total;
  final VoidCallback onTap;
  const _ProgressGlanceCard(
      {required this.progress,
      required this.completed,
      required this.total,
      required this.onTap});

  @override
  Widget build(BuildContext context) => _SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.all(13),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Planning Progress',
              style: TextStyle(fontSize: 11, color: Color(0xFF4F4B47))),
          const SizedBox(height: 10),
          SizedBox(
              width: 54,
              height: 54,
              child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(
                    value: progress / 100,
                    strokeWidth: 5,
                    backgroundColor: const Color(0xFFEDEBE7),
                    valueColor:
                        const AlwaysStoppedAnimation(Color(0xFF11745A))),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('$progress%',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ])),
          const SizedBox(height: 8),
          Text('$completed of $total tasks\ncompleted',
              style: const TextStyle(
                  fontSize: 11, height: 1.2, color: Color(0xFF6D6A66))),
          const Spacer(),
          const _StatusPill(text: 'On Track', color: Color(0xFF11745A)),
        ]),
      );
}

class _GlanceCard extends StatelessWidget {
  final IconData icon;
  final Color tint, statusColor;
  final String title, value, detail, status;
  final VoidCallback onTap;
  const _GlanceCard(
      {required this.icon,
      required this.tint,
      required this.title,
      required this.value,
      required this.detail,
      required this.status,
      required this.statusColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) => _SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.all(13),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: const Color(0xFF1D594D))),
          const SizedBox(height: 9),
          Text(title,
              style: const TextStyle(fontSize: 11, color: Color(0xFFB9B2AA))),
          const SizedBox(height: 4),
          FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827)))),
          const SizedBox(height: 4),
          Text(detail,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11, height: 1.2, color: Color(0xFF6D6A66))),
          const Spacer(),
          _StatusPill(text: status, color: statusColor),
        ]),
      );
}

class _UpcomingTasksPanel extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final VoidCallback onTap;
  const _UpcomingTasksPanel({required this.tasks, required this.onTap});

  @override
  Widget build(BuildContext context) => _SoftCard(
        padding: EdgeInsets.zero,
        child: tasks.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(18),
                child: Text('No upcoming tasks.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6D6A66))))
            : Column(children: [
                for (var i = 0; i < tasks.length; i++)
                  _LandingTaskRow(
                      task: tasks[i],
                      isLast: i == tasks.length - 1,
                      onTap: onTap)
              ]),
      );
}

class _LandingTaskRow extends StatelessWidget {
  final Map<String, dynamic> task;
  final bool isLast;
  final VoidCallback onTap;
  const _LandingTaskRow(
      {required this.task, required this.isLast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final priority = task['priority'] as String? ?? 'low';
    final urgent = priority == 'high';
    final color = urgent ? const Color(0xFFE388A7) : const Color(0xFFE8BD84);
    final icon = urgent
        ? Icons.chat_bubble_outline
        : priority == 'medium'
            ? Icons.calendar_today_outlined
            : Icons.phone_in_talk_outlined;
    final due = _formatTaskDueDate(task['due_date']);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(bottom: BorderSide(color: Color(0xFFF0EDE9)))),
        child: Row(children: [
          Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 16),
          Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                  color: Color(0xFFF8F5F3), shape: BoxShape.circle),
              child: Icon(icon, color: const Color(0xFF5B5A56), size: 22)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(task['title'] as String? ?? 'Untitled task',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(due == null ? 'No due date set' : 'Due $due',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6D6A66))),
              ])),
          _StatusPill(
              text: urgent ? 'Urgent' : 'Soon',
              color:
                  urgent ? const Color(0xFFC24770) : const Color(0xFFB06A00)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFF9D968E)),
        ]),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => _SoftCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 22, color: const Color(0xFF111827)),
          const SizedBox(width: 10),
          Flexible(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
        ]),
      );
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: double.infinity),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 10.5, color: color, fontWeight: FontWeight.w700)),
        ),
      );
}

class _SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const _SoftCard(
      {required this.child,
      this.padding = const EdgeInsets.all(16),
      this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(padding: padding, child: child),
        ),
      );
}

// ignore: unused_element
class _OverviewTab extends ConsumerWidget {
  final PlanState state;
  final List<Map<String, dynamic>> guests;
  final Map<String, dynamic> logisticsSummary;
  final void Function(int) onTabJump;
  const _OverviewTab({
    required this.state,
    required this.guests,
    required this.logisticsSummary,
    required this.onTabJump,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));

    final totalGuests = guests.length;
    final confirmedGuests =
        guests.where((g) => g['attending_status'] == 'yes').length;
    final pendingGuests = guests
        .where((g) =>
            g['attending_status'] == null || g['attending_status'] == 'pending')
        .length;
    final mealsSelected = guests
        .where(
            (g) => (g['meal_preference'] as String?)?.trim().isNotEmpty == true)
        .length;
    final dietaryNeeds = guests
        .where((g) => (g['dietary_note'] as String?)?.trim().isNotEmpty == true)
        .length;

    final seating = ref.watch(seatingPlannerProvider);
    final seatingSummary = seating.summary;

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

    final bookedVendors = state.vendors
        .where((v) =>
            v['booking_status'] == 'booked' ||
            v['booking_status'] == 'confirmed')
        .length;
    final neededVendors = state.vendors.length - bookedVendors;
    final totalBudget = _asDouble(state.budgetSummary['total_budget']);
    final actualBudget = _asDouble(state.budgetSummary['total_actual']);
    final budgetProgress = totalBudget > 0
        ? ((actualBudget / totalBudget) * 100).clamp(0, 100).round()
        : 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Intro card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('This is your planning space.',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.4)),
                  SizedBox(height: 4),
                  Text(
                      'Everything is grouped here so you can move through it clearly. Start with what matters most, then refine as you go.',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.udoTextSecondary,
                          height: 1.5)),
                ])),
            const SizedBox(width: 12),
            Icon(Icons.favorite_outline,
                color: AppTheme.udoPastelCrimson.withValues(alpha: 0.8),
                size: 24),
          ]),
        ),
        const SizedBox(height: 16),

        // Priority tasks — real, sourced from state.tasks
        _SectionHeader('Up next'),
        const SizedBox(height: 8),
        if (topTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.udoBorder)),
            child: const Text("You're all caught up — no open tasks.",
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
          )
        else
          ...topTasks.map((t) {
            final priority = t['priority'] as String? ?? 'low';
            final status = priority == 'high'
                ? 'Urgent'
                : priority == 'medium'
                    ? 'Soon'
                    : 'Later';
            return _PriorityTaskCard(
              title: t['title'] as String? ?? '',
              subtitle: t['due_date'] != null
                  ? 'Due ${_formatTaskDueDate(t['due_date'])}'
                  : (t['category'] as String? ?? 'No due date set'),
              status: status,
              onTap: () => onTabJump(2),
            );
          }),

        const SizedBox(height: 16),
        _SectionHeader('Core planning'),
        const SizedBox(height: 8),
        _ModuleCard(
          id: 'budget',
          icon: Icons.attach_money_outlined,
          title: 'Budget',
          status: totalBudget == 0
              ? 'Not set'
              : (budgetProgress >= 100 ? 'Complete' : 'In progress'),
          summary: totalBudget > 0
              ? '${_money(totalBudget)} total'
              : 'No budget set yet',
          progress: budgetProgress,
          nextStep: totalBudget > 0
              ? '${_money(actualBudget)} spent so far'
              : 'Set your total budget to track spend',
          onTap: () => onTabJump(3),
        ),
        _ModuleCard(
          id: 'vendors',
          icon: Icons.work_outline,
          title: 'Vendors',
          status: state.vendors.isEmpty
              ? 'Not started'
              : (neededVendors == 0 ? 'Complete' : 'In progress'),
          summary: state.vendors.isEmpty
              ? 'No vendors added yet'
              : '$bookedVendors booked • $neededVendors still needed',
          progress: state.vendors.isEmpty
              ? 0
              : ((bookedVendors / state.vendors.length) * 100).round(),
          nextStep: state.vendors.isEmpty
              ? 'Add your first vendor'
              : (neededVendors > 0
                  ? '$neededVendors vendor${neededVendors == 1 ? '' : 's'} still need confirmation'
                  : 'All vendors booked'),
          onTap: () => onTabJump(4),
        ),
        _ModuleCard(
          id: 'event-structure',
          icon: Icons.calendar_today_outlined,
          title: 'Wedding Flow',
          status: state.timelineItems.isEmpty ? 'Not started' : 'In progress',
          summary:
              '${state.timelineItems.length} moment${state.timelineItems.length == 1 ? '' : 's'} planned',
          progress: state.timelineItems.isEmpty ? 0 : 100,
          nextStep: state.timelineItems.isEmpty
              ? 'Add your first timeline moment'
              : 'Your day, moment by moment',
          onTap: () => context.push('/your-vision'),
        ),
        _ModuleCard(
          id: 'guests',
          icon: Icons.people_outline,
          title: 'Guests',
          status: totalGuests == 0
              ? 'Not started'
              : (pendingGuests == 0 ? 'Complete' : 'In progress'),
          summary: totalGuests == 0
              ? 'No guests added yet'
              : '$totalGuests invited • $confirmedGuests confirmed',
          progress: totalGuests == 0
              ? 0
              : ((confirmedGuests / totalGuests) * 100).round(),
          nextStep: totalGuests == 0
              ? 'Add guests to begin managing invitations'
              : (pendingGuests > 0
                  ? '$pendingGuests guest${pendingGuests == 1 ? '' : 's'} still pending RSVP'
                  : 'All guests have responded'),
          onTap: () => context.go('/guests'),
        ),
        _ModuleCard(
          id: 'food',
          icon: Icons.restaurant_outlined,
          title: 'Food & Dining',
          status: totalGuests == 0
              ? 'Not started'
              : (mealsSelected == totalGuests ? 'Complete' : 'In progress'),
          summary: mealsSelected == 0
              ? 'Meal selections: 0'
              : '$mealsSelected of $totalGuests meals selected',
          progress: totalGuests == 0
              ? 0
              : ((mealsSelected / totalGuests) * 100).round(),
          nextStep: totalGuests == 0
              ? 'Add guests, then plan food and dining'
              : (mealsSelected < totalGuests
                  ? '${totalGuests - mealsSelected} guest${(totalGuests - mealsSelected) == 1 ? '' : 's'} missing meal selections'
                  : dietaryNeeds > 0
                      ? '$dietaryNeeds dietary requirement${dietaryNeeds == 1 ? '' : 's'} tracked'
                      : 'All meal selections complete'),
          onTap: () => onTabJump(5),
        ),

        const SizedBox(height: 16),
        _SectionHeader('Guest portal'),
        const SizedBox(height: 8),
        Builder(builder: (context) {
          final imageCount = ref
              .watch(galleryProvider)
              .assets
              .where((a) => a['album'] == 'inspiration')
              .length;
          final visionStyle = ref
              .watch(moreOperationsProvider)
              .activeWedding?['vision_style'] as Map?;
          final theme = visionStyle?['theme'] as String?;
          final paletteName =
              (visionStyle?['color_palette'] as Map?)?['name'] as String?;
          final started = imageCount > 0 ||
              (theme?.isNotEmpty ?? false) ||
              (paletteName?.isNotEmpty ?? false);
          return _ModuleCard(
            id: 'lookbook',
            icon: Icons.image_outlined,
            title: 'Vision & Style',
            status: started ? 'In progress' : 'Not started',
            summary: imageCount == 0
                ? '0 images saved'
                : '$imageCount image${imageCount == 1 ? '' : 's'} saved',
            progress: 0,
            nextStep: theme?.isNotEmpty == true
                ? 'Theme: $theme'
                : 'Start building your wedding vision',
            onTap: () => context.push('/vision-style'),
          );
        }),
        Builder(builder: (context) {
          final events = ref.watch(weddingWeekendProvider).events;
          final needsAttention = events
              .where((e) =>
                  (e['location'] == null ||
                      (e['location'] as String).isEmpty) ||
                  e['start_time'] == null)
              .length;
          return _ModuleCard(
            id: 'additional-events',
            icon: Icons.calendar_month_outlined,
            title: 'Wedding Weekend',
            status: events.isEmpty
                ? 'Not started'
                : (needsAttention == 0 ? 'Complete' : 'In progress'),
            summary: events.isEmpty
                ? '0 events planned'
                : '${events.length} event${events.length == 1 ? '' : 's'} planned',
            progress: events.isEmpty
                ? 0
                : (((events.length - needsAttention) / events.length) * 100)
                    .round(),
            nextStep: events.isEmpty
                ? 'Plan your wedding weekend'
                : (needsAttention > 0
                    ? '$needsAttention event${needsAttention == 1 ? '' : 's'} missing details'
                    : 'All events ready'),
            onTap: () => onTabJump(6),
          );
        }),
        Builder(builder: (context) {
          final tableCount = (seatingSummary['table_count'] as num?)?.toInt() ??
              seating.tables.length;
          final assignedCount =
              (seatingSummary['assigned_count'] as num?)?.toInt() ?? 0;
          final stillToPlace =
              (seatingSummary['unassigned_attending_count'] as num?)?.toInt() ??
                  0;
          return _ModuleCard(
            id: 'seating',
            icon: Icons.chair_outlined,
            title: 'Seating',
            status: tableCount == 0
                ? 'Not started'
                : (stillToPlace == 0 ? 'Complete' : 'In progress'),
            summary: tableCount == 0
                ? 'No tables added yet'
                : '$tableCount table${tableCount == 1 ? '' : 's'} • $assignedCount seated',
            progress: tableCount == 0
                ? 0
                : (assignedCount + stillToPlace) > 0
                    ? ((assignedCount / (assignedCount + stillToPlace)) * 100)
                        .round()
                    : 0,
            nextStep: tableCount == 0
                ? 'Add your first table'
                : (stillToPlace > 0
                    ? '$stillToPlace guest${stillToPlace == 1 ? '' : 's'} still need seating'
                    : 'All guests seated'),
            onTap: () => context.go('/plan/seating'),
          );
        }),
        Builder(builder: (context) {
          final travelling =
              (logisticsSummary['travelling_guests'] as num?)?.toInt() ?? 0;
          final missingAccommodation =
              (logisticsSummary['missing_accommodation'] as num?)?.toInt() ?? 0;
          final missingTransport =
              (logisticsSummary['missing_transport'] as num?)?.toInt() ?? 0;
          final needsAttention = missingAccommodation + missingTransport;
          return _ModuleCard(
            id: 'travel-stay',
            icon: Icons.flight_outlined,
            title: 'Travel & Stay',
            status: travelling == 0
                ? 'Not started'
                : (needsAttention == 0 ? 'Complete' : 'In progress'),
            summary: travelling == 0
                ? '0 travelling guests'
                : '$travelling travelling guest${travelling == 1 ? '' : 's'}',
            progress: travelling == 0
                ? 0
                : needsAttention == 0
                    ? 100
                    : (((travelling - needsAttention) / travelling) * 100)
                        .round(),
            nextStep: travelling == 0
                ? 'Set up travel and stay'
                : (needsAttention > 0
                    ? '$needsAttention guest${needsAttention == 1 ? '' : 's'} missing travel details'
                    : 'All travel arrangements complete'),
            onTap: () => context.go('/guests'),
          );
        }),

        const SizedBox(height: 16),
        _SectionHeader('Enhancements'),
        const SizedBox(height: 8),
        Builder(builder: (context) {
          final memories = ref.watch(memoriesProvider);
          final confirmedSpeeches =
              memories.speeches.where((s) => s['confirmed'] == true).length;
          final started = memories.speeches.isNotEmpty ||
              memories.vows.isNotEmpty ||
              memories.traditions.isNotEmpty ||
              memories.guestbookEntries.isNotEmpty;
          return _ModuleCard(
            id: 'memories',
            icon: Icons.favorite_border_outlined,
            title: 'Memories',
            status: started ? 'In progress' : 'Not started',
            summary: memories.speeches.isEmpty
                ? '0 speeches planned'
                : '$confirmedSpeeches of ${memories.speeches.length} speeches confirmed',
            progress: 0,
            nextStep: started
                ? 'Speeches, vows, traditions, and more'
                : 'Plan the moments and keepsakes you want to preserve',
            onTap: () => context.push('/memories'),
          );
        }),
        Builder(builder: (context) {
          final trip = ref.watch(honeymoonProvider).trip;
          final checklistTasks = ref.watch(honeymoonProvider).checklistTasks;
          final destination = trip?['destination'] as String?;
          final hasDestination = destination?.isNotEmpty == true;
          final checklistDone =
              checklistTasks.where((t) => t['completed'] == true).length;
          final dates =
              (trip?['departure_date'] != null && trip?['return_date'] != null)
                  ? '${trip!['departure_date']} → ${trip['return_date']}'
                  : null;
          return _ModuleCard(
            id: 'honeymoon',
            icon: Icons.beach_access_outlined,
            title: 'Honeymoon',
            status: hasDestination
                ? (_humanizeStatus(trip?['status'] as String?) ?? 'Planned')
                : 'Not started',
            summary: hasDestination
                ? (dates ?? destination!)
                : 'No destination selected',
            progress: checklistTasks.isEmpty
                ? 0
                : ((checklistDone / checklistTasks.length) * 100).round(),
            nextStep: hasDestination
                ? (checklistTasks.isEmpty
                    ? destination!
                    : '$checklistDone of ${checklistTasks.length} checklist items done')
                : 'Plan your honeymoon',
            onTap: () => onTabJump(7),
          );
        }),
        Builder(builder: (context) {
          final policies = ref.watch(insuranceProvider).policies;
          final active = policies.where((p) => p['status'] == 'active').length;
          return _ModuleCard(
            id: 'insurance',
            icon: Icons.shield_outlined,
            title: 'Insurance',
            status: policies.isEmpty
                ? 'Not started'
                : (active > 0 ? 'Complete' : 'Needs attention'),
            summary: policies.isEmpty
                ? 'No policy added yet'
                : '${policies.length} polic${policies.length == 1 ? 'y' : 'ies'} · $active active',
            progress: policies.isEmpty ? 0 : 100,
            nextStep: policies.isEmpty
                ? 'Add your wedding insurance policy'
                : (active > 0 ? 'You are covered' : 'Policy needs renewal'),
            onTap: () => onTabJump(9),
          );
        }),
        Builder(builder: (context) {
          final reminders = ref.watch(remindersProvider).reminders;
          final pending =
              reminders.where((r) => r['status'] != 'completed').length;
          final completed = reminders.length - pending;
          return _ModuleCard(
            id: 'reminders',
            icon: Icons.notifications_outlined,
            title: 'Reminders',
            status: reminders.isEmpty
                ? 'Not started'
                : (pending == 0 ? 'Complete' : 'Active'),
            summary: reminders.isEmpty
                ? 'No reminders yet'
                : '$pending active reminder${pending == 1 ? '' : 's'}',
            progress: reminders.isEmpty
                ? 0
                : ((completed / reminders.length) * 100).round(),
            nextStep: reminders.isEmpty
                ? 'Reminders are created automatically from budget and insurance deadlines'
                : (pending > 0
                    ? '$pending reminder${pending == 1 ? '' : 's'} need attention'
                    : 'All reminders handled'),
            onTap: () => onTabJump(8),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppTheme.udoTextSecondary));
}

class _PriorityTaskCard extends StatelessWidget {
  final String title, subtitle, status;
  final VoidCallback? onTap;
  const _PriorityTaskCard(
      {required this.title,
      required this.subtitle,
      required this.status,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUrgent = status == 'Urgent';
    final color = isUrgent ? AppTheme.udoCrimson : AppTheme.udoPastelCrimson;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.udoBorder)),
        child: Row(children: [
          Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.udoTextSecondary,
                        height: 1.4)),
              ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(status,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w500)),
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
  const _ModuleCard(
      {required this.id,
      required this.icon,
      required this.title,
      required this.status,
      required this.summary,
      required this.progress,
      required this.nextStep,
      required this.onTap});

  Color get _statusColor {
    switch (status) {
      case 'Complete':
      case 'Active':
      case 'Planned':
        return AppTheme.udoGreen;
      case 'Urgent':
      case 'Needs attention':
        return AppTheme.udoCrimson;
      case 'In progress':
      case 'Soon':
        return AppTheme.udoPastelCrimson;
      default:
        return AppTheme.udoTextSecondary;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.udoBorder)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: AppTheme.udoGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: AppTheme.udoGreen, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    Text(summary,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.udoTextSecondary)),
                  ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(status,
                    style: TextStyle(
                        fontSize: 11,
                        color: _statusColor,
                        fontWeight: FontWeight.w500)),
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
              const Icon(Icons.arrow_forward_ios,
                  size: 10, color: AppTheme.udoTextSecondary),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(nextStep,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.udoTextSecondary))),
            ]),
          ]),
        ),
      );
}

// ── YOUR VISION TAB ────────────────────────────────────────────────────────────

class _YourVisionTab extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));

    final items = [...state.timelineItems]..sort((a, b) =>
        (a['start_time'] as String? ?? '')
            .compareTo(b['start_time'] as String? ?? ''));
    final inspiration = ref
        .watch(galleryProvider)
        .assets
        .where((asset) => asset['album'] == 'inspiration')
        .toList();
    final visionStyle = ref
        .watch(moreOperationsProvider)
        .activeWedding?['vision_style'] as Map?;

    Future<void> addInspiration() async {
      final picker = ImagePicker();
      final file =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file == null) return;
      final asset =
          await ref.read(galleryProvider.notifier).upload(file, 'inspiration');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(asset == null
              ? 'Upload failed. Try again.'
              : 'Inspiration added to your vision board.'),
        ),
      );
    }

    final rebuiltVision = _VisionBoardRedesignPage(
      inspiration: inspiration,
      visionStyle: visionStyle,
      timelineItems: items,
      onOpenVision: () => context.push('/vision-style'),
      onAddInspiration: addInspiration,
      onOpenSimulation: () => context.push('/your-vision'),
    );
    if (MediaQuery.sizeOf(context).width >= 0) {
      return rebuiltVision;
    }

    if (state.timelineError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline,
                size: 40, color: AppTheme.udoCrimson),
            const SizedBox(height: 12),
            const Text("Couldn't load your timeline.",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.udoCrimson)),
            const SizedBox(height: 6),
            Text(state.timelineError!,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.udoTextSecondary),
                textAlign: TextAlign.center),
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
            gradient: LinearGradient(
                colors: [AppTheme.udoLightBlush, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppTheme.udoPastelCrimson.withValues(alpha: 0.4)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.auto_awesome,
                  color: AppTheme.udoCrimson, size: 18),
              const SizedBox(width: 8),
              const Text('DAY SIMULATION',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppTheme.udoTextSecondary)),
            ]),
            const SizedBox(height: 8),
            const Text('What the day actually looks like',
                style: TextStyle(
                    fontFamily: 'Playfair',
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    height: 1.3)),
            const SizedBox(height: 8),
            const Text(
                'Not a checklist. A simulation — atmospheric, behavioral, operational, and emotional — of exactly how the day will unfold. Every observation is specific to this couple, this venue, this guest list.',
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.udoTextSecondary,
                    height: 1.5)),
          ]),
        ),
        const SizedBox(height: 16),

        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: AppTheme.udoBackground,
                borderRadius: BorderRadius.circular(16)),
            child: const Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.calendar_today_outlined,
                  size: 40, color: AppTheme.udoTextSecondary),
              SizedBox(height: 12),
              Text('No events planned yet',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              SizedBox(height: 6),
              Text('Add events to your timeline and they will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.udoTextSecondary)),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.udoBorder)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text((item['title'] as String? ?? '').toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: AppTheme.udoTextSecondary)),
                          const SizedBox(height: 4),
                          Text(_formatTime(item['start_time'] as String?),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                        ]),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text('TIMELINE',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AppTheme.udoTextSecondary)),
          const SizedBox(height: 12),

          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final tag = (item['event_type'] as String? ?? 'Event');
            final tagColor = _tagColor(tag);
            final time = _formatTime(item['start_time'] as String?);
            final desc = (item['description'] as String?)?.isNotEmpty == true
                ? item['description'] as String
                : (item['location'] as String? ?? '');
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: tagColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: tagColor.withValues(alpha: 0.3))),
                  child: Center(
                      child: Text(time.split(' ').first,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: tagColor))),
                ),
                if (i < items.length - 1)
                  Container(width: 1, height: 60, color: AppTheme.udoBorder),
              ]),
              const SizedBox(width: 14),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(time,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.udoCrimson)),
                      const SizedBox(height: 2),
                      Text(item['title'] as String? ?? '',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.3)),
                      if (desc.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(desc,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.udoTextSecondary,
                                height: 1.5)),
                      ],
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: tagColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(tag,
                            style: TextStyle(
                                fontSize: 10,
                                color: tagColor,
                                fontWeight: FontWeight.w600)),
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
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: AppTheme.udoCrimson,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Ceremony':
        return AppTheme.udoGreen;
      case 'Emotional':
        return AppTheme.udoCrimson;
      case 'Photography':
        return Colors.indigo;
      case 'Logistics':
        return Colors.teal;
      default:
        return AppTheme.udoTextSecondary;
    }
  }
}

// ── ADD TASK SHEET ─────────────────────────────────────────────────────────────

class _VisionBoardRedesignPage extends StatefulWidget {
  final List<Map<String, dynamic>> inspiration;
  final Map? visionStyle;
  final List<Map<String, dynamic>> timelineItems;
  final VoidCallback onOpenVision;
  final Future<void> Function() onAddInspiration;
  final VoidCallback onOpenSimulation;

  const _VisionBoardRedesignPage({
    required this.inspiration,
    required this.visionStyle,
    required this.timelineItems,
    required this.onOpenVision,
    required this.onAddInspiration,
    required this.onOpenSimulation,
  });

  @override
  State<_VisionBoardRedesignPage> createState() =>
      _VisionBoardRedesignPageState();
}

class _VisionBoardRedesignPageState extends State<_VisionBoardRedesignPage> {
  var _activeBoard = 'All Inspiration';

  @override
  Widget build(BuildContext context) {
    final theme = widget.visionStyle?['theme']?.toString();
    final palette = widget.visionStyle?['color_palette'] as Map?;
    final paletteName = palette?['name']?.toString();
    final moodWords = ((widget.visionStyle?['mood_words'] as List?) ?? [])
        .map((e) => e.toString())
        .toList();
    final mustHaves =
        ((widget.visionStyle?['must_have_elements'] as List?) ?? [])
            .map((e) => e.toString())
            .toList();
    final paletteColors = ((palette?['colors'] as List?) ?? [])
        .whereType<Map>()
        .map((c) => (
              hex: c['hex']?.toString() ?? '#D8C7B5',
              label: c['label']?.toString() ?? ''
            ))
        .toList();
    final boards = [
      ('All Inspiration', widget.inspiration.length),
      ('Florals', _countByCategory(widget.inspiration, 'florals')),
      ('Colour Palette', paletteColors.length),
      ('Venue Vibes', _countByCategory(widget.inspiration, 'venue')),
      (
        'Ceremony',
        widget.timelineItems.where((i) => i['event_type'] == 'Ceremony').length
      ),
      (
        'Reception',
        widget.timelineItems.where((i) => i['event_type'] == 'Reception').length
      ),
    ];
    final visibleInspiration =
        _filterInspiration(widget.inspiration, _activeBoard);
    final visibleTimeline = _filterTimeline(widget.timelineItems, _activeBoard);
    final completionParts = [
      widget.inspiration.isNotEmpty,
      theme?.isNotEmpty == true,
      paletteColors.isNotEmpty,
      moodWords.isNotEmpty,
      mustHaves.isNotEmpty,
    ];
    final progress = completionParts.where((complete) => complete).length /
        completionParts.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        _VisionHeroCard(
          progress: progress,
          theme: theme?.isNotEmpty == true ? theme! : 'Wedding vision',
          imageCount: widget.inspiration.length,
          paletteName:
              paletteName?.isNotEmpty == true ? paletteName! : 'Palette unset',
          moodCount: moodWords.length,
          onOpenVision: widget.onOpenVision,
        ),
        const SizedBox(height: 16),
        _VisionBoardChips(
          boards: boards,
          active: _activeBoard,
          onSelected: (board) => setState(() => _activeBoard = board),
        ),
        const SizedBox(height: 18),
        _VisionInsightCard(
          imageCount: widget.inspiration.length,
          theme: theme,
          paletteColors: paletteColors.length,
          onOpenVision: widget.onOpenVision,
        ),
        const SizedBox(height: 22),
        UdoSectionHeader(
          title: _activeBoard == 'Colour Palette'
              ? 'Colour Palette'
              : _activeBoard,
          action: 'Add',
          onAction: widget.onAddInspiration,
        ),
        if (_activeBoard == 'Colour Palette')
          _VisionPaletteCard(
            name: paletteName,
            colors: paletteColors,
            moodWords: moodWords,
            mustHaves: mustHaves,
            onOpenVision: widget.onOpenVision,
          )
        else ...[
          _VisionMasonryGrid(
              inspiration: visibleInspiration, board: _activeBoard),
          if (visibleTimeline.isNotEmpty) ...[
            const SizedBox(height: 14),
            _VisionTimelineBoard(
                title: 'Timeline links', items: visibleTimeline),
          ],
          const SizedBox(height: 18),
          _VisionPaletteCard(
            name: paletteName,
            colors: paletteColors,
            moodWords: moodWords,
            mustHaves: mustHaves,
            onOpenVision: widget.onOpenVision,
          ),
        ],
        const SizedBox(height: 18),
        UdoCard(
          onTap: widget.onOpenSimulation,
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.timeline_outlined, color: UdoDesign.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Day simulation',
                        style:
                            UdoDesign.sans(size: 15, weight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(
                        '${widget.timelineItems.length} timeline moments available for the full simulation.',
                        style:
                            UdoDesign.sans(size: 12.5, color: UdoDesign.muted)),
                  ]),
            ),
            const Icon(Icons.chevron_right, color: UdoDesign.muted),
          ]),
        ),
      ],
    );
  }

  int _countByCategory(List<Map<String, dynamic>> assets, String needle) {
    return assets.where((asset) {
      final category = asset['category']?.toString().toLowerCase() ?? '';
      final title = asset['title']?.toString().toLowerCase() ?? '';
      return category.contains(needle) || title.contains(needle);
    }).length;
  }

  List<Map<String, dynamic>> _filterInspiration(
      List<Map<String, dynamic>> assets, String board) {
    if (board == 'All Inspiration') return assets;
    final needles = switch (board) {
      'Florals' => const ['floral', 'florals', 'flower', 'bouquet'],
      'Venue Vibes' => const ['venue', 'vibes', 'table', 'setting'],
      'Ceremony' => const ['ceremony', 'aisle', 'arch'],
      'Reception' => const ['reception', 'table', 'dining'],
      _ => const <String>[],
    };
    if (needles.isEmpty) return assets;
    return assets.where((asset) {
      final haystack = [
        asset['category'],
        asset['title'],
        asset['board_name'],
        asset['caption'],
      ].where((value) => value != null).join(' ').toLowerCase();
      return needles.any(haystack.contains);
    }).toList();
  }

  List<Map<String, dynamic>> _filterTimeline(
      List<Map<String, dynamic>> items, String board) {
    if (board != 'Ceremony' && board != 'Reception') return const [];
    return items
        .where((item) => item['event_type']?.toString() == board)
        .toList();
  }
}

class _VisionHeroCard extends StatelessWidget {
  final double progress;
  final String theme;
  final int imageCount;
  final String paletteName;
  final int moodCount;
  final VoidCallback onOpenVision;

  const _VisionHeroCard({
    required this.progress,
    required this.theme,
    required this.imageCount,
    required this.paletteName,
    required this.moodCount,
    required this.onOpenVision,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      color: UdoDesign.blue,
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const UdoBadge(
                  label: 'Mood board',
                  color: UdoDesign.gold,
                  background: Color(0x22FFFFFF)),
              const SizedBox(height: 12),
              Text('Vision Board',
                  style: UdoDesign.serif(size: 34, color: Colors.white)),
              const SizedBox(height: 8),
              Text('What should our wedding feel like?',
                  style: UdoDesign.sans(size: 14, color: Colors.white70)),
            ]),
          ),
          UdoRingProgress(
            value: progress,
            color: Colors.white,
            size: 74,
            center: Text('${(progress * 100).round()}%',
                style: UdoDesign.sans(
                    size: 14, weight: FontWeight.w800, color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _VisionHeroStat(label: 'Theme', value: theme)),
          Expanded(
              child: _VisionHeroStat(label: 'Saves', value: '$imageCount')),
          Expanded(
              child: _VisionHeroStat(label: 'Palette', value: paletteName)),
          Expanded(child: _VisionHeroStat(label: 'Mood', value: '$moodCount')),
        ]),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: onOpenVision,
          icon: const Icon(Icons.auto_awesome_mosaic_outlined, size: 18),
          label: const Text('Open Vision Studio'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: UdoDesign.blue,
            minimumSize: const Size(double.infinity, 46),
          ),
        ),
      ]),
    );
  }
}

class _VisionHeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _VisionHeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(
                  size: 11.5,
                  weight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.15)),
          Text(label, style: UdoDesign.sans(size: 9.5, color: Colors.white70)),
        ]),
      );
}

class _VisionBoardChips extends StatefulWidget {
  final List<(String, int)> boards;
  final String active;
  final ValueChanged<String> onSelected;
  const _VisionBoardChips(
      {required this.boards, required this.active, required this.onSelected});

  @override
  State<_VisionBoardChips> createState() => _VisionBoardChipsState();
}

class _VisionBoardChipsState extends State<_VisionBoardChips> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.boards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final board = widget.boards[index];
          final active = board.$1 == widget.active;
          return ChoiceChip(
            selected: active,
            label: Text('${board.$1} ${board.$2 > 0 ? board.$2 : ''}'.trim()),
            onSelected: (_) => widget.onSelected(board.$1),
            selectedColor: UdoDesign.blue,
            backgroundColor: UdoDesign.card,
            side: BorderSide(color: active ? UdoDesign.blue : UdoDesign.stone),
            labelStyle: UdoDesign.sans(
                size: 12,
                weight: FontWeight.w700,
                color: active ? Colors.white : UdoDesign.sub),
          );
        },
      ),
    );
  }
}

class _VisionInsightCard extends StatelessWidget {
  final int imageCount;
  final String? theme;
  final int paletteColors;
  final VoidCallback onOpenVision;

  const _VisionInsightCard({
    required this.imageCount,
    required this.theme,
    required this.paletteColors,
    required this.onOpenVision,
  });

  @override
  Widget build(BuildContext context) {
    final insight = imageCount == 0
        ? 'Upload inspiration photos so Udo can build a visual direction.'
        : paletteColors == 0
            ? 'Your inspiration is saved. Add a colour palette next.'
            : theme?.isNotEmpty == true
                ? 'Your $theme direction is ready to guide vendors and details.'
                : 'Name the visual theme so every module can use the same language.';
    return UdoCard(
      onTap: onOpenVision,
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.auto_awesome_outlined, color: UdoDesign.blue),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI inspiration prompt',
                style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(insight,
                style: UdoDesign.sans(
                    size: 12.5, color: UdoDesign.muted, height: 1.42)),
          ]),
        ),
        const Icon(Icons.chevron_right, color: UdoDesign.muted),
      ]),
    );
  }
}

class _VisionMasonryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> inspiration;
  final String board;
  const _VisionMasonryGrid({required this.inspiration, required this.board});

  static const _fallbacks = [
    ('assets/images/figma_make/image.png', 'Floral Arch'),
    ('assets/images/figma_make/image-1.png', 'Aisle Decor'),
    ('assets/images/figma_make/image-2.png', 'Table Setting'),
    ('assets/images/figma_make/image-3.png', 'Bouquet'),
    ('assets/images/figma_make/image-4.png', 'Venue Vibes'),
    ('assets/images/figma_make/image-5.png', 'Rings'),
  ];

  @override
  Widget build(BuildContext context) {
    final tiles = inspiration.isEmpty
        ? _fallbacksFor(board)
            .map((item) =>
                _VisionTileData(path: item.$1, label: item.$2, network: false))
            .toList()
        : inspiration.take(8).map((asset) {
            final url =
                (asset['thumbnail_url'] ?? asset['url'])?.toString() ?? '';
            return _VisionTileData(
              path: url,
              label: asset['title']?.toString().isNotEmpty == true
                  ? asset['title'].toString()
                  : 'Inspiration',
              network: url.startsWith('http'),
            );
          }).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.86,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) => _VisionImageTile(tile: tiles[index]),
    );
  }

  List<(String, String)> _fallbacksFor(String board) {
    return switch (board) {
      'Florals' => const [
          ('assets/images/figma_make/image.png', 'Floral Arch'),
          ('assets/images/figma_make/image-3.png', 'Bouquet'),
          ('assets/images/figma_make/image-5.png', 'Rings'),
        ],
      'Venue Vibes' => const [
          ('assets/images/figma_make/image-4.png', 'Venue Vibes'),
          ('assets/images/figma_make/image-2.png', 'Table Setting'),
        ],
      'Ceremony' => const [
          ('assets/images/figma_make/image-1.png', 'Aisle Decor'),
          ('assets/images/figma_make/image.png', 'Floral Arch'),
        ],
      'Reception' => const [
          ('assets/images/figma_make/image-2.png', 'Table Setting'),
          ('assets/images/figma_make/image-4.png', 'Venue Vibes'),
        ],
      _ => _fallbacks,
    };
  }
}

class _VisionTimelineBoard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  const _VisionTimelineBoard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
        const SizedBox(height: 10),
        for (final item in items.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              const Icon(Icons.event_note_outlined,
                  size: 16, color: UdoDesign.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item['title']?.toString() ?? 'Timeline moment',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(size: 12.5, color: UdoDesign.sub),
                ),
              ),
            ]),
          ),
      ]),
    );
  }
}

class _VisionTileData {
  final String path;
  final String label;
  final bool network;

  const _VisionTileData({
    required this.path,
    required this.label,
    required this.network,
  });
}

class _VisionImageTile extends StatelessWidget {
  final _VisionTileData tile;
  const _VisionImageTile({required this.tile});

  @override
  Widget build(BuildContext context) {
    final image = tile.network
        ? Image.network(tile.path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _VisionImageFallback(label: tile.label))
        : Image.asset(tile.path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _VisionImageFallback(label: tile.label));
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(fit: StackFit.expand, children: [
        image,
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.46),
                Colors.transparent
              ],
            ),
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 10,
          child: Text(tile.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(
                  size: 12, weight: FontWeight.w800, color: Colors.white)),
        ),
      ]),
    );
  }
}

class _VisionImageFallback extends StatelessWidget {
  final String label;
  const _VisionImageFallback({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        color: UdoDesign.stone,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        child: Text(label,
            textAlign: TextAlign.center,
            style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
      );
}

class _VisionPaletteCard extends StatelessWidget {
  final String? name;
  final List<({String hex, String label})> colors;
  final List<String> moodWords;
  final List<String> mustHaves;
  final VoidCallback onOpenVision;

  const _VisionPaletteCard({
    required this.name,
    required this.colors,
    required this.moodWords,
    required this.mustHaves,
    required this.onOpenVision,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      onTap: onOpenVision,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(name?.isNotEmpty == true ? name! : 'Colour Palette',
                  style: UdoDesign.sans(size: 15, weight: FontWeight.w800))),
          const Icon(Icons.chevron_right, color: UdoDesign.muted),
        ]),
        const SizedBox(height: 12),
        if (colors.isEmpty)
          Text('No colours selected yet.',
              style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted))
        else
          Row(children: [
            for (final color in colors.take(6))
              Expanded(
                child: Container(
                  height: 42,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: _colorFromVisionHex(color.hex),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: UdoDesign.stone),
                  ),
                ),
              ),
          ]),
        if (moodWords.isNotEmpty || mustHaves.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 7, runSpacing: 7, children: [
            for (final word in [...moodWords, ...mustHaves].take(8))
              UdoBadge(label: word, color: UdoDesign.blue),
          ]),
        ],
      ]),
    );
  }

  Color _colorFromVisionHex(String hex) {
    final normalized = hex.replaceAll('#', '');
    final value = int.tryParse(
        normalized.length == 6 ? 'FF$normalized' : normalized,
        radix: 16);
    return value == null ? UdoDesign.stone : Color(value);
  }
}

class _TimelineTab extends StatefulWidget {
  final PlanState state;
  final PlanNotifier notifier;
  const _TimelineTab({required this.state, required this.notifier});

  @override
  State<_TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends State<_TimelineTab> {
  String _filter = 'All';
  String _query = '';

  String _title(Map<String, dynamic> item) =>
      (item['title'] ?? item['name'] ?? item['event_name'] ?? 'Timeline event')
          .toString();

  String _phase(Map<String, dynamic> item) =>
      (item['event_type'] ?? item['phase'] ?? item['category'] ?? 'Event')
          .toString();

  String _location(Map<String, dynamic> item) =>
      (item['location'] ?? item['venue_area'] ?? '').toString();

  String _vendor(Map<String, dynamic> item) {
    final vendorName = item['vendor_name'];
    if (vendorName is String && vendorName.trim().isNotEmpty) return vendorName;
    final vendor = item['vendor'];
    if (vendor is Map) {
      final name = (vendor['name'] ?? vendor['business_name'])?.toString();
      if (name != null && name.trim().isNotEmpty) return name;
      return '';
    }
    return (vendor ?? '').toString();
  }

  bool _hasConflict(Map<String, dynamic> item) {
    final raw = item['conflict'] ?? item['has_conflict'] ?? item['conflicts'];
    if (raw is bool) return raw;
    if (raw is List) return raw.isNotEmpty;
    if (raw is String) return raw.trim().isNotEmpty;
    return false;
  }

  bool _isLocked(Map<String, dynamic> item) {
    final raw = item['locked'] ?? item['is_locked'];
    return raw == true;
  }

  int _duration(Map<String, dynamic> item) {
    final raw = item['duration_minutes'] ?? item['duration'] ?? item['minutes'];
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    final start = _timeMinutes(item['start_time']);
    final end = _timeMinutes(item['end_time']);
    if (start != null && end != null && end > start) return end - start;
    return 0;
  }

  int? _timeMinutes(dynamic raw) {
    if (raw == null) return null;
    final parts = raw.toString().split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  String _formatTime(dynamic raw) {
    final minutes = _timeMinutes(raw);
    if (minutes == null) return raw?.toString() ?? 'TBC';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final suffix = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:${m.toString().padLeft(2, '0')} $suffix';
  }

  Color _phaseColor(String phase) {
    final normalized = phase.toLowerCase();
    if (normalized.contains('morning') ||
        normalized.contains('preparation') ||
        normalized.contains('prep')) {
      return UdoDesign.gold;
    }
    if (normalized.contains('photo')) return UdoDesign.blue;
    if (normalized.contains('ceremony')) return UdoDesign.sage;
    if (normalized.contains('reception')) return UdoDesign.plan;
    if (normalized.contains('evening') ||
        normalized.contains('entertainment')) {
      return UdoDesign.rose;
    }
    return UdoDesign.muted;
  }

  List<Map<String, dynamic>> _sortedItems() {
    final items = [...widget.state.timelineItems];
    items.sort((a, b) => (a['start_time'] ?? '')
        .toString()
        .compareTo((b['start_time'] ?? '').toString()));
    return items;
  }

  List<Map<String, dynamic>> _visibleItems(List<Map<String, dynamic>> items) {
    final q = _query.trim().toLowerCase();
    return items.where((item) {
      final phase = _phase(item);
      final matchesFilter = _filter == 'All'
          ? true
          : _filter == 'Conflicts'
              ? _hasConflict(item)
              : phase.toLowerCase().contains(_filter.toLowerCase());
      final matchesSearch = q.isEmpty ||
          _title(item).toLowerCase().contains(q) ||
          _location(item).toLowerCase().contains(q) ||
          _vendor(item).toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _showAddEvent([Map<String, dynamic>? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) =>
          _AddTimelineEventSheet(notifier: widget.notifier, existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));
    }

    if (state.timelineError != null && state.timelineItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline,
                size: 40, color: AppTheme.udoCrimson),
            const SizedBox(height: 12),
            const Text("Couldn't load your timeline.",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.udoCrimson)),
            const SizedBox(height: 6),
            Text(state.timelineError!,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.udoTextSecondary),
                textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    final items = _sortedItems();
    final visible = _visibleItems(items);
    final conflicts = items.where(_hasConflict).length;
    final locked = items.where(_isLocked).length;
    final completion = items.isEmpty
        ? 0
        : ((items.where((item) {
                      final status =
                          (item['status'] ?? '').toString().toLowerCase();
                      return status == 'confirmed' ||
                          status == 'completed' ||
                          status == 'done';
                    }).length /
                    items.length) *
                100)
            .round();
    final start =
        items.isEmpty ? 'TBC' : _formatTime(items.first['start_time']);
    final finish = items.isEmpty
        ? 'TBC'
        : _formatTime(items.last['end_time'] ?? items.last['start_time']);

    return Stack(children: [
      ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 128),
        children: [
          _TimelineHeroCard(
            completion: completion,
            events: items.length,
            conflicts: conflicts,
            locked: locked,
            start: start,
            finish: finish,
          ),
          if (conflicts > 0) ...[
            const SizedBox(height: 12),
            _TimelineConflictBanner(
              count: conflicts,
              onReview: () => setState(() => _filter = 'Conflicts'),
            ),
          ],
          const SizedBox(height: 14),
          _TimelineInsightStrip(
            events: items.length,
            buffers: items.where((item) => _duration(item) >= 30).length,
            vendors: items.where((item) => _vendor(item).isNotEmpty).length,
          ),
          const SizedBox(height: 14),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search events, locations, vendors...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              filled: true,
              fillColor: UdoDesign.card,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: UdoDesign.stone),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: UdoDesign.stone),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: UdoDesign.sage, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final filter in const [
                'All',
                'Morning',
                'Ceremony',
                'Reception',
                'Evening',
                'Conflicts',
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: _filter == filter,
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 18),
          if (items.isEmpty)
            UdoCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  const Icon(Icons.timeline_outlined,
                      size: 36, color: UdoDesign.muted),
                  const SizedBox(height: 10),
                  const Text('No timeline events yet',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text(
                      'Add wedding-day moments to build the operating schedule.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: UdoDesign.muted)),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _showAddEvent,
                    icon: const Icon(Icons.add),
                    label: const Text('Add event'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.udoGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ]),
              ),
            )
          else ...[
            UdoSectionHeader(
              title: 'Day map',
              subtitle: 'A compact read of the full wedding-day sequence',
            ),
            _TimelineDayMap(
              items: items,
              titleFor: _title,
              phaseFor: _phase,
              colorFor: _phaseColor,
              timeFor: _formatTime,
            ),
            const SizedBox(height: 18),
            UdoSectionHeader(
              title: 'Editable timeline',
              subtitle: '${visible.length} events visible',
            ),
            _TimelineEventList(
              items: visible,
              titleFor: _title,
              phaseFor: _phase,
              locationFor: _location,
              vendorFor: _vendor,
              timeFor: _formatTime,
              durationFor: _duration,
              colorFor: _phaseColor,
              hasConflict: _hasConflict,
              isLocked: _isLocked,
              onTap: (item) => _showAddEvent(item),
            ),
          ],
        ],
      ),
      Positioned(
        right: 18,
        bottom: 18,
        child: SafeArea(
          child: FloatingActionButton.extended(
            heroTag: 'timeline-add',
            backgroundColor: UdoDesign.plan,
            foregroundColor: Colors.white,
            elevation: 8,
            onPressed: _showAddEvent,
            icon: const Icon(Icons.add),
            label: const Text('Add event'),
          ),
        ),
      ),
    ]);
  }
}

const _timelineEventTypeOptions = [
  'Preparation',
  'Morning',
  'Ceremony',
  'Reception',
  'Evening',
  'Photos',
  'Custom',
];

class _AddTimelineEventSheet extends StatefulWidget {
  final PlanNotifier notifier;
  final Map<String, dynamic>? existing;
  const _AddTimelineEventSheet({required this.notifier, this.existing});

  @override
  State<_AddTimelineEventSheet> createState() => _AddTimelineEventSheetState();
}

class _AddTimelineEventSheetState extends State<_AddTimelineEventSheet> {
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _notes = TextEditingController();
  String? _eventType;
  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _saving = false;
  bool _deleting = false;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _title.text = (existing['title'] ?? '').toString();
      _location.text = (existing['location'] ?? '').toString();
      _notes.text = (existing['notes'] ?? '').toString();
      final type = existing['event_type']?.toString();
      _eventType = type != null && _timelineEventTypeOptions.contains(type)
          ? type
          : null;
      final date = existing['event_date']?.toString();
      _eventDate =
          date == null || date.isEmpty ? null : DateTime.tryParse(date);
      _startTime = _parseTime(existing['start_time']?.toString());
      _endTime = _parseTime(existing['end_time']?.toString());
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Give the event a title.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = _isEditing
        ? await widget.notifier.updateTimelineItem(
            id: widget.existing!['id'] as int,
            title: _title.text.trim(),
            eventType: _eventType,
            eventDate: _eventDate == null ? null : _formatDate(_eventDate!),
            startTime: _startTime == null ? null : _fmtTime(_startTime!),
            endTime: _endTime == null ? null : _fmtTime(_endTime!),
            location: _location.text.trim(),
            notes: _notes.text.trim(),
          )
        : await widget.notifier.createTimelineItem(
            title: _title.text.trim(),
            eventType: _eventType,
            eventDate: _eventDate == null ? null : _formatDate(_eventDate!),
            startTime: _startTime == null ? null : _fmtTime(_startTime!),
            endTime: _endTime == null ? null : _fmtTime(_endTime!),
            location: _location.text.trim(),
            notes: _notes.text.trim(),
          );
    if (!mounted) return;
    if (ok) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Weekend update queued for sending.')),
      );
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save this event. Try again.";
      });
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text(
            'Remove "${_title.text.trim()}" from the timeline? This can\'t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.udoCrimson)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _deleting = true);
    final ok =
        await widget.notifier.deleteTimelineItem(widget.existing!['id'] as int);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _deleting = false;
        _error = "Couldn't delete this event. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppTheme.udoBorder,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: Text(_isEditing ? 'Edit event' : 'Add event',
                        style: const TextStyle(
                            fontFamily: 'Playfair',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.udoGreen)),
                  ),
                  if (_isEditing)
                    IconButton(
                      onPressed: _deleting ? null : _delete,
                      icon: _deleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppTheme.udoCrimson))
                          : const Icon(Icons.delete_outline,
                              color: AppTheme.udoCrimson),
                    ),
                ]),
                const SizedBox(height: 16),
                TextField(
                    controller: _title,
                    autofocus: true,
                    decoration: const InputDecoration(
                        labelText: 'Event title',
                        hintText: 'e.g. Bridal party hair & makeup')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _eventType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      labelText: 'Type (optional)',
                      hintText: 'Select a phase of the day'),
                  items: _timelineEventTypeOptions
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => _eventType = value),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _eventDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) setState(() => _eventDate = picked);
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(_eventDate == null
                      ? 'Set date'
                      : _formatDate(_eventDate!)),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _startTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() => _startTime = picked);
                        }
                      },
                      icon: const Icon(Icons.schedule_outlined),
                      label: Text(_startTime == null
                          ? 'Start time'
                          : _startTime!.format(context)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _endTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) setState(() => _endTime = picked);
                      },
                      icon: const Icon(Icons.schedule_outlined),
                      label: Text(_endTime == null
                          ? 'End time'
                          : _endTime!.format(context)),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                TextField(
                    controller: _location,
                    decoration: const InputDecoration(
                        labelText: 'Location (optional)',
                        hintText: 'e.g. Grand Ballroom')),
                const SizedBox(height: 12),
                TextField(
                    controller: _notes,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'Anything the day-of team should know')),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(
                          color: AppTheme.udoCrimson, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_saving || _deleting) ? null : _save,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.udoGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50)),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(_isEditing ? 'Save changes' : 'Add event'),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

class _TimelineHeroCard extends StatelessWidget {
  final int completion;
  final int events;
  final int conflicts;
  final int locked;
  final String start;
  final String finish;

  const _TimelineHeroCard({
    required this.completion,
    required this.events,
    required this.conflicts,
    required this.locked,
    required this.start,
    required this.finish,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(18),
      child: Row(children: [
        UdoRingProgress(
          value: completion / 100,
          size: 62,
          color: UdoDesign.sage,
          center: Text('$completion%',
              style: UdoDesign.sans(
                  size: 13, weight: FontWeight.w800, color: UdoDesign.sage)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Timeline Progress',
                style: UdoDesign.sans(size: 16, weight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('$events events · $conflicts conflicts · $locked locked',
                style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted)),
            const SizedBox(height: 8),
            Row(children: [
              _TimelineMiniStat(label: 'Start', value: start),
              const SizedBox(width: 10),
              _TimelineMiniStat(label: 'Finish', value: finish),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _TimelineMiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _TimelineMiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: UdoDesign.sage.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: UdoDesign.sans(size: 10, color: UdoDesign.muted)),
          const SizedBox(height: 2),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(size: 12, weight: FontWeight.w800)),
        ]),
      ),
    );
  }
}

class _TimelineConflictBanner extends StatelessWidget {
  final int count;
  final VoidCallback onReview;
  const _TimelineConflictBanner({required this.count, required this.onReview});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UdoDesign.rose.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: UdoDesign.rose.withValues(alpha: 0.24)),
      ),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: UdoDesign.rose),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$count scheduling conflict${count == 1 ? '' : 's'} detected',
            style: UdoDesign.sans(
                size: 13, weight: FontWeight.w700, color: UdoDesign.rose),
          ),
        ),
        TextButton(onPressed: onReview, child: const Text('Review')),
      ]),
    );
  }
}

class _TimelineInsightStrip extends StatelessWidget {
  final int events;
  final int buffers;
  final int vendors;
  const _TimelineInsightStrip({
    required this.events,
    required this.buffers,
    required this.vendors,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        _TimelineInsight(
            icon: Icons.event_available_outlined,
            label: 'Events',
            value: '$events'),
        _TimelineInsight(
            icon: Icons.av_timer_outlined, label: 'Buffers', value: '$buffers'),
        _TimelineInsight(
            icon: Icons.storefront_outlined,
            label: 'Vendors',
            value: '$vendors'),
      ]),
    );
  }
}

class _TimelineInsight extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _TimelineInsight({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Icon(icon, size: 19, color: UdoDesign.sage),
        const SizedBox(height: 5),
        Text(value,
            style: UdoDesign.sans(
                size: 16, weight: FontWeight.w800, color: UdoDesign.sage)),
        const SizedBox(height: 2),
        Text(label, style: UdoDesign.sans(size: 10, color: UdoDesign.muted)),
      ]),
    );
  }
}

class _TimelineDayMap extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String Function(Map<String, dynamic> item) titleFor;
  final String Function(Map<String, dynamic> item) phaseFor;
  final Color Function(String phase) colorFor;
  final String Function(dynamic raw) timeFor;

  const _TimelineDayMap({
    required this.items,
    required this.titleFor,
    required this.phaseFor,
    required this.colorFor,
    required this.timeFor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = items[index];
          final color = colorFor(phaseFor(item));
          return Container(
            width: 132,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: UdoDesign.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(timeFor(item['start_time']),
                  style: UdoDesign.sans(
                      size: 11, weight: FontWeight.w800, color: color)),
              const SizedBox(height: 5),
              Text(titleFor(item),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(size: 12.5, weight: FontWeight.w700)),
              const Spacer(),
              Container(
                width: 28,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ]),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: items.length,
      ),
    );
  }
}

class _TimelineEventList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String Function(Map<String, dynamic> item) titleFor;
  final String Function(Map<String, dynamic> item) phaseFor;
  final String Function(Map<String, dynamic> item) locationFor;
  final String Function(Map<String, dynamic> item) vendorFor;
  final String Function(dynamic raw) timeFor;
  final int Function(Map<String, dynamic> item) durationFor;
  final Color Function(String phase) colorFor;
  final bool Function(Map<String, dynamic> item) hasConflict;
  final bool Function(Map<String, dynamic> item) isLocked;
  final void Function(Map<String, dynamic> item)? onTap;

  const _TimelineEventList({
    required this.items,
    required this.titleFor,
    required this.phaseFor,
    required this.locationFor,
    required this.vendorFor,
    required this.timeFor,
    required this.durationFor,
    required this.colorFor,
    required this.hasConflict,
    required this.isLocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (var index = 0; index < items.length; index++)
        _TimelineEventCard(
          item: items[index],
          isLast: index == items.length - 1,
          title: titleFor(items[index]),
          phase: phaseFor(items[index]),
          location: locationFor(items[index]),
          vendor: vendorFor(items[index]),
          time: timeFor(items[index]['start_time']),
          duration: durationFor(items[index]),
          color: colorFor(phaseFor(items[index])),
          hasConflict: hasConflict(items[index]),
          isLocked: isLocked(items[index]),
          onTap: onTap == null ? null : () => onTap!(items[index]),
        ),
    ]);
  }
}

class _TimelineEventCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isLast;
  final String title;
  final String phase;
  final String location;
  final String vendor;
  final String time;
  final int duration;
  final Color color;
  final bool hasConflict;
  final bool isLocked;
  final VoidCallback? onTap;

  const _TimelineEventCard({
    required this.item,
    required this.isLast,
    required this.title,
    required this.phase,
    required this.location,
    required this.vendor,
    required this.time,
    required this.duration,
    required this.color,
    required this.hasConflict,
    required this.isLocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final description = item['description'];
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 52,
        child: Column(children: [
          Text(time,
              textAlign: TextAlign.right,
              style: UdoDesign.sans(size: 10.5, color: UdoDesign.muted)),
          const SizedBox(height: 8),
          Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.22), spreadRadius: 4)
              ],
            ),
          ),
          if (!isLast)
            Container(
              width: 1.4,
              height: 82,
              margin: const EdgeInsets.only(top: 4),
              color: UdoDesign.stone,
            ),
        ]),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: UdoCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          onTap: onTap,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Text(title,
                    style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              UdoBadge(label: phase, color: color),
            ]),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 6, children: [
              if (duration > 0)
                _TimelinePill(
                    icon: Icons.schedule_outlined,
                    label: '${duration}m',
                    color: UdoDesign.muted),
              if (location.isNotEmpty)
                _TimelinePill(
                    icon: Icons.place_outlined,
                    label: location,
                    color: UdoDesign.blue),
              if (vendor.isNotEmpty)
                _TimelinePill(
                    icon: Icons.storefront_outlined,
                    label: vendor,
                    color: UdoDesign.plan),
              if (isLocked)
                const _TimelinePill(
                    icon: Icons.lock_outline,
                    label: 'Locked',
                    color: UdoDesign.muted),
              if (hasConflict)
                const _TimelinePill(
                    icon: Icons.warning_amber_rounded,
                    label: 'Conflict',
                    color: UdoDesign.rose),
            ]),
            if (description is String && description.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(description,
                  style: UdoDesign.sans(
                      size: 12.5, color: UdoDesign.sub, height: 1.4)),
            ],
          ]),
        ),
      ),
    ]);
  }
}

class _TimelinePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TimelinePill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(
                  size: 10.5, weight: FontWeight.w700, color: color)),
        ),
      ]),
    );
  }
}

void _showRecordCashGiftSheet(
  BuildContext context,
  WidgetRef ref, {
  required int itemId,
  required String fundName,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) =>
        _RecordCashGiftSheet(ref: ref, itemId: itemId, fundName: fundName),
  );
}

class _PlanRegistryTab extends ConsumerStatefulWidget {
  const _PlanRegistryTab();

  @override
  ConsumerState<_PlanRegistryTab> createState() => _PlanRegistryTabState();
}

class _PlanRegistryTabState extends ConsumerState<_PlanRegistryTab> {
  String _query = '';

  double _amount(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final raw = item[key];
      if (raw is num) return raw.toDouble();
      if (raw is String) {
        final parsed = double.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), ''));
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  bool _isPurchased(Map<String, dynamic> item) {
    final status = (item['status'] ?? item['purchase_status'] ?? '')
        .toString()
        .toLowerCase();
    return item['purchased'] == true ||
        status == 'purchased' ||
        status == 'fulfilled' ||
        status == 'received';
  }

  String _category(Map<String, dynamic> item) =>
      (item['category'] ?? item['type'] ?? 'Registry').toString();

  List<Map<String, dynamic>> _visible(List<Map<String, dynamic>> items) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((item) {
      return (item['name'] ?? '').toString().toLowerCase().contains(q) ||
          _category(item).toLowerCase().contains(q) ||
          (item['store'] ?? item['store_name'] ?? '')
              .toString()
              .toLowerCase()
              .contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registryProvider);
    final items = state.items;
    final visible = _visible(items);
    final purchased = items.where(_isPurchased).length;
    final remaining = items.length - purchased;
    final cashFunds = items.where((item) {
      final type = (item['type'] ?? '').toString().toLowerCase();
      return type == 'cash_fund' || type.contains('fund');
    }).toList();
    final fundGoal = cashFunds.fold<double>(0,
        (total, item) => total + _amount(item, const ['fund_goal', 'price']));
    final fundRaised = cashFunds.fold<double>(
        0,
        (total, item) =>
            total +
            _amount(item,
                const ['fund_raised', 'contributed', 'raised', 'amount']));
    final completion =
        items.isEmpty ? 0 : ((purchased / items.length) * 100).round();
    final categories = <String, List<Map<String, dynamic>>>{};
    for (final item in items) {
      categories.putIfAbsent(_category(item), () => []).add(item);
    }
    final thankYouRemaining =
        (state.summary['thank_you_remaining'] as num?)?.toInt() ??
            (state.summary['unthanked_count'] as num?)?.toInt() ??
            0;

    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));
    }

    if (state.error != null && items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline,
                size: 40, color: AppTheme.udoCrimson),
            const SizedBox(height: 12),
            const Text("Couldn't load your registry.",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.udoCrimson)),
            const SizedBox(height: 6),
            Text(state.error!,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.udoTextSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => ref.read(registryProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ]),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 128),
      children: [
        _RegistryHeroCard(
          completion: completion,
          purchased: purchased,
          remaining: remaining,
          fundRaised: fundRaised,
          thankYouRemaining: thankYouRemaining,
          onOpen: () => context.go('/registry'),
        ),
        const SizedBox(height: 14),
        _RegistryMetricGrid(
          items: items.length,
          purchased: purchased,
          funds: fundRaised,
          thanksRemaining: thankYouRemaining,
        ),
        const SizedBox(height: 14),
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Search gifts, categories, stores...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            filled: true,
            fillColor: UdoDesign.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: UdoDesign.stone),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: UdoDesign.stone),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: UdoDesign.gold, width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (items.isEmpty)
          _RegistrySetupPanel(onOpen: () => context.go('/registry'))
        else ...[
          UdoSectionHeader(
            title: 'Gift categories',
            subtitle: '${categories.length} active groups',
            action: 'Manage',
            onAction: () => context.go('/registry'),
          ),
          for (final entry in categories.entries.take(5))
            _RegistryCategoryRow(
              name: entry.key,
              total: entry.value.length,
              purchased: entry.value.where(_isPurchased).length,
            ),
          if (cashFunds.isNotEmpty) ...[
            const SizedBox(height: 18),
            UdoSectionHeader(
              title: 'Cash funds',
              subtitle: '${_money(fundRaised)} raised of ${_money(fundGoal)}',
            ),
            for (final fund in cashFunds.take(2))
              _RegistryFundCard(
                name: (fund['name'] ?? 'Cash fund').toString(),
                raised: _amount(fund,
                    const ['fund_raised', 'contributed', 'raised', 'amount']),
                goal: _amount(fund, const ['fund_goal', 'price']),
                onAddGift: () => _showRecordCashGiftSheet(
                  context,
                  ref,
                  itemId: (fund['id'] as num).toInt(),
                  fundName: (fund['name'] ?? 'Cash fund').toString(),
                ),
              ),
          ],
          const SizedBox(height: 18),
          UdoSectionHeader(
            title: 'Gift cards',
            subtitle: '${visible.length} visible',
            action: 'Open full registry',
            onAction: () => context.go('/registry'),
          ),
          for (final item in visible.take(6))
            _RegistryGiftCard(
              name: (item['name'] ?? 'Registry gift').toString(),
              category: _category(item),
              price: _amount(item, const ['price', 'fund_goal']),
              purchased: _isPurchased(item),
              store: (item['store'] ?? item['store_name'] ?? '').toString(),
            ),
        ],
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: () => context.go('/registry'),
          icon: const Icon(Icons.card_giftcard_outlined, size: 18),
          label: const Text('Open registry operations'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            backgroundColor: UdoDesign.gold,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
}

class _RegistryHeroCard extends StatelessWidget {
  final int completion;
  final int purchased;
  final int remaining;
  final double fundRaised;
  final int thankYouRemaining;
  final VoidCallback onOpen;

  const _RegistryHeroCard({
    required this.completion,
    required this.purchased,
    required this.remaining,
    required this.fundRaised,
    required this.thankYouRemaining,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      onTap: onOpen,
      color: UdoDesign.gold,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your Registry',
            style: UdoDesign.sans(
                size: 11, weight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 8),
        Text('Building your future together',
            style: UdoDesign.serif(
                size: 24, weight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 6),
        Text('$purchased gifts received · $remaining still available',
            style: UdoDesign.sans(
                size: 13, color: Colors.white.withValues(alpha: 0.76))),
        const SizedBox(height: 18),
        Row(children: [
          UdoRingProgress(
            value: completion / 100,
            size: 60,
            color: Colors.white,
            center: Text('$completion%',
                style: UdoDesign.sans(
                    size: 12, weight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Row(children: [
              _RegistryHeroStat(label: 'Funds', value: _money(fundRaised)),
              _RegistryHeroStat(
                  label: 'Thanks', value: '$thankYouRemaining left'),
            ]),
          ),
        ]),
      ]),
    );
  }
}

class _RegistryHeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _RegistryHeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UdoDesign.sans(
                size: 14, weight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: UdoDesign.sans(
                size: 10, color: Colors.white.withValues(alpha: 0.66))),
      ]),
    );
  }
}

class _RegistryMetricGrid extends StatelessWidget {
  final int items;
  final int purchased;
  final double funds;
  final int thanksRemaining;

  const _RegistryMetricGrid({
    required this.items,
    required this.purchased,
    required this.funds,
    required this.thanksRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Gifts', '$items', Icons.card_giftcard_outlined),
      ('Purchased', '$purchased', Icons.check_circle_outline),
      ('Funds', _money(funds), Icons.savings_outlined),
      ('Thanks', '$thanksRemaining', Icons.mail_outline),
    ];
    return Row(children: [
      for (final metric in metrics)
        Expanded(
          child: UdoCard(
            margin: const EdgeInsets.only(right: 7),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(children: [
              Icon(metric.$3, size: 18, color: UdoDesign.gold),
              const SizedBox(height: 5),
              Text(metric.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(
                      size: 14,
                      weight: FontWeight.w800,
                      color: UdoDesign.gold)),
              const SizedBox(height: 2),
              Text(metric.$1,
                  style: UdoDesign.sans(size: 10, color: UdoDesign.muted)),
            ]),
          ),
        ),
    ]);
  }
}

class _RegistrySetupPanel extends StatelessWidget {
  final VoidCallback onOpen;
  const _RegistrySetupPanel({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const Icon(Icons.card_giftcard_outlined,
            size: 38, color: UdoDesign.gold),
        const SizedBox(height: 10),
        Text('No registry gifts yet',
            style: UdoDesign.sans(size: 16, weight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text('Create gifts, cash funds, store links, and thank-you tracking.',
            textAlign: TextAlign.center,
            style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted)),
        const SizedBox(height: 14),
        OutlinedButton(onPressed: onOpen, child: const Text('Start registry')),
      ]),
    );
  }
}

class _RegistryCategoryRow extends StatelessWidget {
  final String name;
  final int total;
  final int purchased;

  const _RegistryCategoryRow({
    required this.name,
    required this.total,
    required this.purchased,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : purchased / total;
    return UdoCard(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: UdoDesign.gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.inventory_2_outlined, color: UdoDesign.gold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UdoDesign.sans(size: 14.5, weight: FontWeight.w800)),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                color: UdoDesign.gold,
                backgroundColor: UdoDesign.stone,
              ),
            ),
          ]),
        ),
        const SizedBox(width: 10),
        Text('$purchased/$total',
            style: UdoDesign.sans(
                size: 12, weight: FontWeight.w800, color: UdoDesign.gold)),
      ]),
    );
  }
}

class _RegistryFundCard extends StatelessWidget {
  final String name;
  final double raised;
  final double goal;
  final VoidCallback onAddGift;

  const _RegistryFundCard({
    required this.name,
    required this.raised,
    required this.goal,
    required this.onAddGift,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal <= 0 ? 0.0 : (raised / goal).clamp(0.0, 1.0);
    return UdoCard(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.volunteer_activism_outlined,
              color: UdoDesign.sage, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UdoDesign.sans(size: 14, weight: FontWeight.w800)),
          ),
          Text(_money(raised),
              style: UdoDesign.sans(
                  size: 13, weight: FontWeight.w800, color: UdoDesign.sage)),
          const SizedBox(width: 8),
          InkWell(
            onTap: onAddGift,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: UdoDesign.sage.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 15, color: UdoDesign.sage),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            color: UdoDesign.sage,
            backgroundColor: UdoDesign.stone,
          ),
        ),
      ]),
    );
  }
}

class _RecordCashGiftSheet extends StatefulWidget {
  final WidgetRef ref;
  final int itemId;
  final String fundName;

  const _RecordCashGiftSheet({
    required this.ref,
    required this.itemId,
    required this.fundName,
  });

  @override
  State<_RecordCashGiftSheet> createState() => _RecordCashGiftSheetState();
}

class _RecordCashGiftSheetState extends State<_RecordCashGiftSheet> {
  final _amountCtrl = TextEditingController();
  final _fromCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _fromCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final from = _fromCtrl.text.trim();
    final ok = await widget.ref
        .read(registryProvider.notifier)
        .recordContribution(
          itemId: widget.itemId,
          contributorName: from.isEmpty ? 'Cash gift' : from,
          amount: amount,
          message: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_money(amount)} added to ${widget.fundName}.')));
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save this gift. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Record a cash gift',
                style: UdoDesign.sans(size: 17, weight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
                'Adds straight to ${widget.fundName} — for gifts given in person, like cash in an envelope.',
                style: UdoDesign.sans(
                    size: 12.5, color: UdoDesign.muted, height: 1.4)),
            const SizedBox(height: 18),
            TextField(
              controller: _amountCtrl,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Amount', prefixText: '\$ '),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fromCtrl,
              decoration: const InputDecoration(
                  labelText: 'From (optional)', hintText: 'e.g. Aunt Linda'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style: UdoDesign.sans(size: 12, color: UdoDesign.rose)),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                    backgroundColor: UdoDesign.sage,
                    minimumSize: const Size(double.infinity, 50)),
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save gift'),
              ),
            ),
          ]),
    );
  }
}

class _RegistryGiftCard extends StatelessWidget {
  final String name;
  final String category;
  final double price;
  final bool purchased;
  final String store;

  const _RegistryGiftCard({
    required this.name,
    required this.category,
    required this.price,
    required this.purchased,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: (purchased ? UdoDesign.sage : UdoDesign.gold)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
              purchased
                  ? Icons.check_circle_outline
                  : Icons.card_giftcard_outlined,
              color: purchased ? UdoDesign.sage : UdoDesign.gold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UdoDesign.sans(size: 14.5, weight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(
              [
                category,
                if (store.isNotEmpty) store,
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(size: 12, color: UdoDesign.muted),
            ),
          ]),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (price > 0)
            Text(_money(price),
                style: UdoDesign.sans(size: 12, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          UdoBadge(
              label: purchased ? 'Received' : 'Available',
              color: purchased ? UdoDesign.sage : UdoDesign.gold),
        ]),
      ]),
    );
  }
}

class _PaymentsTab extends ConsumerStatefulWidget {
  final PlanState state;
  const _PaymentsTab({required this.state});

  @override
  ConsumerState<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends ConsumerState<_PaymentsTab> {
  String _filter = 'All';
  final String _query = '';

  double _paymentAmount(Map<String, dynamic> payment) =>
      _asDouble(payment['amount'] ??
          payment['actual_amount'] ??
          payment['estimated_amount'] ??
          payment['balance_due']);

  String _paymentLabel(Map<String, dynamic> payment) => (payment['label'] ??
          payment['title'] ??
          payment['name'] ??
          payment['item_name'] ??
          'Payment')
      .toString();

  String _paymentVendor(Map<String, dynamic> payment) {
    final vendorName = payment['vendor_name'];
    if (vendorName is String && vendorName.trim().isNotEmpty) return vendorName;
    final vendor = payment['vendor'];
    if (vendor is Map) {
      final name = (vendor['name'] ?? vendor['business_name'])?.toString();
      if (name != null && name.trim().isNotEmpty) return name;
    } else if (vendor is String && vendor.trim().isNotEmpty) {
      return vendor;
    }
    return (payment['category'] ?? '').toString();
  }

  String _paymentStatus(Map<String, dynamic> payment) =>
      (payment['status'] ?? payment['payment_status'] ?? 'pending')
          .toString()
          .toLowerCase();

  String _paymentDate(Map<String, dynamic> payment) {
    final raw = payment['due_date'] ?? payment['date'];
    if (raw == null) return 'Date not set';
    final value = raw.toString().trim();
    if (value.isEmpty) return 'Date not set';
    final parsed = DateTime.tryParse(value);
    return parsed == null ? value : DateFormat('MMM d, yyyy').format(parsed);
  }

  String _paymentMethod(Map<String, dynamic> payment) =>
      (payment['payment_method'] ??
              payment['method'] ??
              payment['document_type'] ??
              'Bank Transfer')
          .toString();

  String _paymentInvoice(Map<String, dynamic> payment) =>
      (payment['invoice_number'] ??
              payment['invoice'] ??
              payment['document_ref'] ??
              payment['id'])
          .toString();

  List<Map<String, dynamic>> _payments() {
    final summary = widget.state.budgetSummary;
    final nextPayments = ((summary['next_payments'] as List?) ?? const [])
        .cast<Map<String, dynamic>>();
    final overduePayments = ((summary['overdue_payments'] as List?) ?? const [])
        .cast<Map<String, dynamic>>();
    final schedule = <Map<String, dynamic>>[
      ...overduePayments.map((payment) => {
            ...payment,
            'status': payment['status'] ?? 'overdue',
          }),
      ...nextPayments.map((payment) => {
            ...payment,
            'status': payment['status'] ?? 'upcoming',
          }),
    ];
    if (schedule.isNotEmpty) return schedule;

    return widget.state.budgetItems
        .where((item) =>
            item['due_date'] != null ||
            item['payment_status'] != null ||
            item['paid_amount'] != null)
        .map((item) {
      final amount =
          _asDouble(item['actual_amount'] ?? item['estimated_amount']);
      final paid = _asDouble(item['paid_amount']);
      return {
        ...item,
        'label': item['name'] ?? item['category'] ?? 'Budget payment',
        'amount': (amount - paid).clamp(0, double.infinity),
        'status':
            item['payment_status'] ?? (paid >= amount ? 'paid' : 'pending'),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _visible(List<Map<String, dynamic>> payments) {
    final q = _query.trim().toLowerCase();
    return payments.where((payment) {
      final status = _paymentStatus(payment);
      final matchesFilter = _filter == 'All'
          ? true
          : _filter == 'Due'
              ? status == 'due' || status == 'upcoming' || status == 'pending'
              : _filter == 'Overdue'
                  ? status == 'overdue'
                  : _filter == 'Paid'
                      ? status == 'paid'
                      : true;
      final matchesSearch = q.isEmpty ||
          _paymentLabel(payment).toLowerCase().contains(q) ||
          _paymentVendor(payment).toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Color _statusColor(String status) {
    if (status == 'paid') return UdoDesign.sage;
    if (status == 'overdue') return UdoDesign.rose;
    if (status == 'due' || status == 'upcoming') return UdoDesign.amber;
    return UdoDesign.blue;
  }

  void _showAddToPayments() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddToPaymentsSheet(
        parentContext: context,
        notifier: ref.read(planProvider.notifier),
        vendors: widget.state.vendors,
        budgetItems: widget.state.budgetItems,
      ),
    );
  }

  void _openPaymentSheet(Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => sheet,
    );
  }

  void _showAddPayment() => _openPaymentSheet(_PaymentEntrySheet(
        notifier: ref.read(planProvider.notifier),
        vendors: widget.state.vendors,
        budgetItems: widget.state.budgetItems,
      ));

  void _showScanInvoice() => _openPaymentSheet(_PaymentInvoiceSheet(
        notifier: ref.read(planProvider.notifier),
        vendors: widget.state.vendors,
        budgetItems: widget.state.budgetItems,
      ));

  void _showUploadReceipt() => _openPaymentSheet(_PaymentEntrySheet(
        notifier: ref.read(planProvider.notifier),
        vendors: widget.state.vendors,
        budgetItems: widget.state.budgetItems,
        title: 'Upload receipt',
        buttonLabel: 'Save receipt',
      ));

  void _showRecordManual() => _openPaymentSheet(_PaymentEntrySheet(
        notifier: ref.read(planProvider.notifier),
        vendors: widget.state.vendors,
        budgetItems: widget.state.budgetItems,
        title: 'Record manual payment',
        buttonLabel: 'Record payment',
      ));

  void _showPayForSchedule(Map<String, dynamic> payment) {
    final scheduleId = _asIntId(payment['id']);
    // Only real payment-schedule rows (from the budget summary) carry
    // `budget_item_id` — the fallback list built straight from budget items
    // (when no schedule exists yet) reuses the item's own `id` here instead,
    // which isn't a schedule id. Fall back to the generic picker for those.
    if (scheduleId == null || !payment.containsKey('budget_item_id')) {
      _showAddToPayments();
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PaymentEntrySheet(
        notifier: ref.read(planProvider.notifier),
        vendors: widget.state.vendors,
        budgetItems: widget.state.budgetItems,
        initialScheduleId: scheduleId,
        initialVendorId: _asIntId(payment['vendor_id']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));
    }
    if (state.budgetError != null && state.budgetItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text("Couldn't load payment data.",
              style: UdoDesign.sans(size: 13, color: UdoDesign.muted)),
        ),
      );
    }

    final payments = _payments();
    final visible = _visible(payments);
    final paid = payments.where((p) => _paymentStatus(p) == 'paid').toList();
    final overdue =
        payments.where((p) => _paymentStatus(p) == 'overdue').toList();
    final due = payments
        .where(
            (p) => ['due', 'upcoming', 'pending'].contains(_paymentStatus(p)))
        .toList();
    final totalPaid = _asDouble(
        state.budgetSummary['total_paid'] ?? state.budgetSummary['paid']);
    final outstanding =
        payments.fold<double>(0, (sum, p) => sum + _paymentAmount(p));
    final budgetTotal = _asDouble(state.budgetSummary['total_budget'] ??
        state.budgetSummary['budget'] ??
        state.budgetSummary['estimated_total']);
    final paidPct =
        budgetTotal <= 0 ? 0 : ((totalPaid / budgetTotal) * 100).round();
    final paidCount = paid.length;
    final dueThisMonth = due.where((payment) {
      final parsed = DateTime.tryParse((payment['due_date'] ?? '').toString());
      final now = DateTime.now();
      return parsed != null &&
          parsed.year == now.year &&
          parsed.month == now.month;
    }).length;
    final dueThisMonthAmount = due.fold<double>(0, (sum, payment) {
      final parsed = DateTime.tryParse((payment['due_date'] ?? '').toString());
      final now = DateTime.now();
      if (parsed == null ||
          parsed.year != now.year ||
          parsed.month != now.month) {
        return sum;
      }
      return sum + _paymentAmount(payment);
    });
    final showAllDue = _filter == 'Due';
    final nextPayment = !showAllDue && due.isNotEmpty ? due.first : null;
    final upcoming = showAllDue
        ? due
        : due.skip(nextPayment == null ? 0 : 1).take(5).toList();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 128),
          children: [
            _PaymentsOverviewCard(
              paidPct: paidPct.clamp(0, 100),
              totalPaid: totalPaid,
              outstanding: outstanding,
              budgetTotal: budgetTotal,
              upcomingTotal: due.fold<double>(
                  0, (sum, payment) => sum + _paymentAmount(payment)),
              dueThisMonth: dueThisMonth,
              dueThisMonthAmount: dueThisMonthAmount,
              upcoming: due.length,
              overdue: overdue.length,
              paidCount: paidCount,
            ),
            const SizedBox(height: 12),
            if (nextPayment != null)
              _NextPaymentCard(
                title: _paymentLabel(nextPayment),
                vendor: _paymentVendor(nextPayment),
                amount: _paymentAmount(nextPayment),
                dueDate: _paymentDate(nextPayment),
                method: _paymentMethod(nextPayment),
                invoice: _paymentInvoice(nextPayment),
                status: _paymentStatus(nextPayment),
                onPayNow: () => _showPayForSchedule(nextPayment),
              )
            else
              UdoCard(
                padding: const EdgeInsets.all(18),
                child: Text('No upcoming payment is due right now.',
                    style: UdoDesign.sans(size: 13, color: UdoDesign.muted)),
              ),
            const SizedBox(height: 18),
            UdoSectionHeader(
              title: showAllDue ? 'All upcoming payments' : 'Upcoming payments',
              action: showAllDue ? 'Show less' : 'See all (${due.length})',
              onAction: () =>
                  setState(() => _filter = showAllDue ? 'All' : 'Due'),
            ),
            if (upcoming.isEmpty)
              UdoCard(
                padding: const EdgeInsets.all(18),
                child: Text('No additional upcoming payments.',
                    style: UdoDesign.sans(size: 13, color: UdoDesign.muted)),
              )
            else
              for (final payment in upcoming)
                _PaymentScheduleCard(
                  title: _paymentLabel(payment),
                  vendor: _paymentVendor(payment),
                  amount: _paymentAmount(payment),
                  dueDate: _paymentDate(payment),
                  method: _paymentMethod(payment),
                  invoice: _paymentInvoice(payment),
                  status: _paymentStatus(payment),
                  color: _statusColor(_paymentStatus(payment)),
                  onTap: () => _showPayForSchedule(payment),
                ),
            const SizedBox(height: 12),
            _PaymentSmartInsightCard(
              paidPct: paidPct.clamp(0, 100),
              totalPayments: payments.length,
              outstanding: outstanding,
              onViewDetails: () => Share.share(
                'Wedding payment schedule: ${payments.length} records, ${_money(outstanding)} outstanding.',
              ),
            ),
            const SizedBox(height: 12),
            _PaymentActionGrid(
              onAddPayment: _showAddPayment,
              onScanInvoice: _showScanInvoice,
              onUploadReceipt: _showUploadReceipt,
              onRecordManual: _showRecordManual,
              onMore: _showAddToPayments,
            ),
            if (visible.isEmpty) const SizedBox.shrink(),
          ],
        ),
        Positioned(
          right: 18,
          bottom: 18,
          child: SafeArea(
            child: FloatingActionButton.extended(
              heroTag: 'payments-add',
              backgroundColor: UdoDesign.blue,
              foregroundColor: Colors.white,
              elevation: 8,
              onPressed: _showAddToPayments,
              icon: const Icon(Icons.add),
              label: const Text('Add payment'),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentsOverviewCard extends StatelessWidget {
  final int paidPct;
  final double totalPaid;
  final double outstanding;
  final double budgetTotal;
  final double upcomingTotal;
  final int dueThisMonth;
  final double dueThisMonthAmount;
  final int upcoming;
  final int overdue;
  final int paidCount;

  const _PaymentsOverviewCard({
    required this.paidPct,
    required this.totalPaid,
    required this.outstanding,
    required this.budgetTotal,
    required this.upcomingTotal,
    required this.dueThisMonth,
    required this.dueThisMonthAmount,
    required this.upcoming,
    required this.overdue,
    required this.paidCount,
  });

  @override
  Widget build(BuildContext context) {
    final percentLeft = (100 - paidPct).clamp(0, 100);
    return UdoCard(
      color: const Color(0xFF214638),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('BUDGET OVERVIEW',
                style: UdoDesign.sans(
                    size: 9.5,
                    weight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.76))),
          ),
          Text('View details',
              style: UdoDesign.sans(
                  size: 10, color: Colors.white.withValues(alpha: 0.82))),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right,
              size: 16, color: Colors.white.withValues(alpha: 0.82)),
        ]),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          UdoRingProgress(
            value: paidPct / 100,
            size: 82,
            color: const Color(0xFFD7AA62),
            center: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$paidPct%',
                  style: UdoDesign.sans(
                      size: 20, weight: FontWeight.w900, color: Colors.white)),
              Text('Paid',
                  style: UdoDesign.sans(
                      size: 10, color: Colors.white.withValues(alpha: 0.75))),
            ]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(children: [
              Expanded(
                child: _PaymentOverviewMetric(
                    label: 'Paid to date',
                    value: _money(totalPaid),
                    detail: budgetTotal > 0 ? 'of ${_money(budgetTotal)}' : ''),
              ),
              Expanded(
                child: _PaymentOverviewMetric(
                    label: 'Remaining',
                    value: _money(outstanding),
                    detail: '$percentLeft% left'),
              ),
              Expanded(
                child: _PaymentOverviewMetric(
                    label: 'Upcoming',
                    value: _money(upcomingTotal),
                    detail: '$upcoming payments'),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        Divider(color: Colors.white.withValues(alpha: 0.16), height: 1),
        const SizedBox(height: 12),
        Row(children: [
          _PaymentMiniMetric(
              icon: Icons.calendar_month_outlined,
              value: '$dueThisMonth',
              label: 'Due this month',
              detail: _money(dueThisMonthAmount),
              color: const Color(0xFFD7AA62)),
          _PaymentMiniMetric(
              icon: Icons.schedule_outlined,
              value: '$upcoming',
              label: 'Upcoming',
              detail: _money(upcomingTotal),
              color: UdoDesign.blue),
          _PaymentMiniMetric(
              icon: Icons.check_circle_outline,
              value: '$paidCount',
              label: 'Paid',
              detail: _money(totalPaid),
              color: UdoDesign.sage),
          _PaymentMiniMetric(
              icon: Icons.warning_amber_outlined,
              value: '$overdue',
              label: 'Overdue',
              detail: _money(outstanding),
              color: UdoDesign.rose),
        ]),
      ]),
    );
  }
}

class _PaymentOverviewMetric extends StatelessWidget {
  final String label;
  final String value;
  final String detail;

  const _PaymentOverviewMetric({
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(
                  size: 9.5, color: Colors.white.withValues(alpha: 0.70))),
          const SizedBox(height: 4),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(
                  size: 15, weight: FontWeight.w900, color: Colors.white)),
          if (detail.isNotEmpty)
            Text(detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UdoDesign.sans(
                    size: 9.5, color: Colors.white.withValues(alpha: 0.58))),
        ]),
      );
}

class _PaymentMiniMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String detail;
  final Color color;

  const _PaymentMiniMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(height: 6),
          Text(value,
              style: UdoDesign.sans(
                  size: 15, weight: FontWeight.w900, color: Colors.white)),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(
                  size: 9.5, color: Colors.white.withValues(alpha: 0.68))),
          Text(detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(size: 9.5, color: color)),
        ]),
      );
}

class _NextPaymentCard extends StatelessWidget {
  final String title;
  final String vendor;
  final double amount;
  final String dueDate;
  final String method;
  final String invoice;
  final String status;
  final VoidCallback onPayNow;

  const _NextPaymentCard({
    required this.title,
    required this.vendor,
    required this.amount,
    required this.dueDate,
    required this.method,
    required this.invoice,
    required this.status,
    required this.onPayNow,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: UdoDesign.rose.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headphones_outlined, color: UdoDesign.rose),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(size: 14, weight: FontWeight.w900)),
              const SizedBox(height: 3),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(vendor.isEmpty ? 'Vendor not set' : vendor,
                      style: UdoDesign.sans(size: 11, color: UdoDesign.muted)),
                  UdoBadge(
                      label: status == 'overdue' ? 'Overdue' : 'Due tomorrow',
                      color: status == 'overdue'
                          ? UdoDesign.rose
                          : UdoDesign.gold),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(spacing: 10, runSpacing: 4, children: [
                _PaymentTinyInfo(icon: Icons.event_outlined, text: dueDate),
                _PaymentTinyInfo(
                    icon: Icons.account_balance_outlined, text: method),
                _PaymentTinyInfo(
                    icon: Icons.receipt_long_outlined, text: invoice),
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_money(amount),
                style: UdoDesign.sans(size: 14, weight: FontWeight.w900)),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: onPayNow,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF214638),
                foregroundColor: Colors.white,
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Pay now'),
            ),
          ]),
        ]),
      );
}

class _PaymentTinyInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PaymentTinyInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: UdoDesign.muted),
        const SizedBox(width: 4),
        Text(text,
            style: UdoDesign.sans(size: 10.5, color: UdoDesign.sub),
            overflow: TextOverflow.ellipsis),
      ]);
}

class _PaymentScheduleCard extends StatelessWidget {
  final String title;
  final String vendor;
  final double amount;
  final String dueDate;
  final String method;
  final String invoice;
  final String status;
  final Color color;
  final VoidCallback? onTap;

  const _PaymentScheduleCard({
    required this.title,
    required this.vendor,
    required this.amount,
    required this.dueDate,
    required this.method,
    required this.invoice,
    required this.status,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = _humanizeStatus(status) ?? 'Pending';
    return UdoCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      onTap: status == 'paid' ? null : onTap,
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.payments_outlined, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UdoDesign.sans(size: 14.5, weight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(
              [
                if (vendor.isNotEmpty) vendor,
                if (dueDate.isNotEmpty) 'Due $dueDate',
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(size: 12, color: UdoDesign.muted),
            ),
          ]),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(_money(amount),
              style: UdoDesign.sans(size: 13, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          UdoBadge(label: label, color: color),
        ]),
      ]),
    );
  }
}

class _PaymentSmartInsightCard extends StatelessWidget {
  final int paidPct;
  final int totalPayments;
  final double outstanding;
  final VoidCallback onViewDetails;

  const _PaymentSmartInsightCard({
    required this.paidPct,
    required this.totalPayments,
    required this.outstanding,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        color: const Color(0xFFFFFBF1),
        border: const BorderSide(color: Color(0xFFE7D4A8)),
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFD7AA62),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text('Smart insight',
                      style: UdoDesign.sans(size: 12, weight: FontWeight.w900)),
                ),
                InkWell(
                  onTap: onViewDetails,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE7D4A8)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.ios_share, size: 12),
                      const SizedBox(width: 4),
                      Text('Share',
                          style: UdoDesign.sans(
                              size: 11, weight: FontWeight.w800)),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: 4),
              Text(
                totalPayments == 0
                    ? 'Add payment records to activate payment insights.'
                    : 'Paying the next due payment keeps your schedule ${paidPct >= 75 ? 'on track' : 'moving'} with ${_money(outstanding)} still open.',
                style: UdoDesign.sans(
                    size: 12, color: UdoDesign.sub, height: 1.35),
              ),
            ]),
          ),
        ]),
      );
}

class _PaymentActionGrid extends StatelessWidget {
  final VoidCallback onAddPayment;
  final VoidCallback onScanInvoice;
  final VoidCallback onUploadReceipt;
  final VoidCallback onRecordManual;
  final VoidCallback onMore;
  const _PaymentActionGrid({
    required this.onAddPayment,
    required this.onScanInvoice,
    required this.onUploadReceipt,
    required this.onRecordManual,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.add, 'Add\npayment', onAddPayment),
      (Icons.document_scanner_outlined, 'Scan\ninvoice', onScanInvoice),
      (Icons.upload_file_outlined, 'Upload\nreceipt', onUploadReceipt),
      (Icons.account_balance_outlined, 'Record\nmanual', onRecordManual),
      (Icons.more_horiz, 'More', onMore),
    ];
    return UdoCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(children: [
        for (final action in actions)
          Expanded(
            child: InkWell(
              onTap: action.$3,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF214638).withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(action.$1,
                        size: 18, color: const Color(0xFF214638)),
                  ),
                  const SizedBox(height: 5),
                  Text(action.$2,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: UdoDesign.sans(
                          size: 9.5,
                          color: UdoDesign.sub,
                          weight: FontWeight.w700,
                          height: 1.05)),
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}

// ignore: unused_element
class _PaymentReminderPanel extends StatelessWidget {
  final List<Map<String, dynamic>> overdue;
  final List<Map<String, dynamic>> due;
  final String Function(Map<String, dynamic> payment) labelFor;
  final double Function(Map<String, dynamic> payment) amountFor;

  const _PaymentReminderPanel({
    required this.overdue,
    required this.due,
    required this.labelFor,
    required this.amountFor,
  });

  @override
  Widget build(BuildContext context) {
    final reminders = [...overdue, ...due].take(3).toList();
    return UdoCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('Payment reminders',
                style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
          ),
          const UdoBadge(label: 'Smart', color: UdoDesign.blue),
        ]),
        const SizedBox(height: 10),
        if (reminders.isEmpty)
          Text('No payment reminders right now.',
              style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted))
        else
          for (final payment in reminders)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                const Icon(Icons.notifications_active_outlined,
                    size: 16, color: UdoDesign.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${labelFor(payment)} · ${_money(amountFor(payment))}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UdoDesign.sans(size: 12.5, color: UdoDesign.sub),
                  ),
                ),
              ]),
            ),
      ]),
    );
  }
}

class _AddToPaymentsSheet extends StatelessWidget {
  final BuildContext parentContext;
  final PlanNotifier notifier;
  final List<Map<String, dynamic>> vendors;
  final List<Map<String, dynamic>> budgetItems;
  const _AddToPaymentsSheet({
    required this.parentContext,
    required this.notifier,
    this.vendors = const [],
    this.budgetItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        Icons.add,
        'Add Payment',
        'Pay a vendor against their budget',
        () => _open(
              context,
              _PaymentEntrySheet(
                notifier: notifier,
                vendors: vendors,
                budgetItems: budgetItems,
              ),
            )
      ),
      (
        Icons.edit_outlined,
        'Record Manual Payment',
        'Log a cash or offline payment',
        () => _open(
              context,
              _PaymentEntrySheet(
                notifier: notifier,
                vendors: vendors,
                budgetItems: budgetItems,
                title: 'Record manual payment',
                buttonLabel: 'Record payment',
              ),
            )
      ),
      (
        Icons.insert_drive_file_outlined,
        'Upload Invoice',
        'Attach a bill you owe a vendor',
        () => _open(
              context,
              _PaymentInvoiceSheet(
                notifier: notifier,
                vendors: vendors,
                budgetItems: budgetItems,
              ),
            )
      ),
      (
        Icons.receipt_long_outlined,
        'Upload Receipt',
        'Keep proof of a payment you made',
        () => _open(
              context,
              _PaymentEntrySheet(
                notifier: notifier,
                vendors: vendors,
                budgetItems: budgetItems,
                title: 'Upload receipt',
                buttonLabel: 'Save receipt',
              ),
            )
      ),
      (
        Icons.calendar_month_outlined,
        'Add Payment Plan',
        'Split into installments',
        () => _open(
              context,
              _PaymentPlanSheet(notifier: notifier, vendors: vendors),
            )
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            14, 14, 14, MediaQuery.of(context).viewInsets.bottom + 18),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(
                child: Text('Add to Payments',
                    style: UdoDesign.sans(size: 18, weight: FontWeight.w800)),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ]),
            const SizedBox(height: 4),
            for (final action in actions)
              _PaymentActionRow(
                icon: action.$1,
                title: action.$2,
                subtitle: action.$3,
                onTap: action.$4,
              ),
          ]),
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget sheet) {
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!parentContext.mounted) return;
      showModalBottomSheet(
        context: parentContext,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => sheet,
      );
    });
  }
}

class _PaymentActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _PaymentActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: UdoDesign.stone),
            ),
            child: Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: UdoDesign.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: UdoDesign.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: UdoDesign.sans(
                              size: 13.5, weight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style:
                              UdoDesign.sans(size: 11.5, color: UdoDesign.sub)),
                    ]),
              ),
              const Icon(Icons.chevron_right, color: UdoDesign.muted),
            ]),
          ),
        ),
      ),
    );
  }
}

const _paymentMethodOptions = [
  'Bank Transfer',
  'Card',
  'Cash',
  'Mobile Money',
  'Cheque',
  'Other',
];

class _PayableOption {
  final int? scheduleId;
  final int budgetItemId;
  final String label;
  final double amount;
  final String? status;
  const _PayableOption({
    this.scheduleId,
    required this.budgetItemId,
    required this.label,
    required this.amount,
    this.status,
  });
}

/// Lets the user attach a receipt/invoice via camera, photo gallery, or a
/// file picker (so PDFs work, not just images) — used by every payment
/// sheet that accepts a supporting document.
Future<({List<int> bytes, String filename})?> _pickReceiptFile(
    BuildContext context) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Attach a file',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
        ),
        ListTile(
          leading:
              const Icon(Icons.camera_alt_outlined, color: AppTheme.udoGreen),
          title: const Text('Take a photo'),
          onTap: () => Navigator.pop(context, 'camera'),
        ),
        ListTile(
          leading: const Icon(Icons.photo_library_outlined,
              color: AppTheme.udoGreen),
          title: const Text('Choose from photos'),
          onTap: () => Navigator.pop(context, 'gallery'),
        ),
        ListTile(
          leading: const Icon(Icons.insert_drive_file_outlined,
              color: AppTheme.udoGreen),
          title: const Text('Choose a file'),
          subtitle: const Text('PDF or image', style: TextStyle(fontSize: 11)),
          onTap: () => Navigator.pop(context, 'file'),
        ),
        const SizedBox(height: 8),
      ]),
    ),
  );
  if (choice == null || !context.mounted) return null;

  if (choice == 'camera' || choice == 'gallery') {
    final xfile = await ImagePicker().pickImage(
      source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile == null) return null;
    final bytes = await xfile.readAsBytes();
    return (bytes: bytes, filename: xfile.name);
  }

  final result = await FilePicker.pickFiles(
    withData: true,
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
  );
  final picked = result?.files.single;
  if (picked == null || picked.bytes == null) return null;
  return (bytes: picked.bytes!, filename: picked.name);
}

class _PaymentEntrySheet extends StatefulWidget {
  final PlanNotifier notifier;
  final String title;
  final String buttonLabel;
  final List<Map<String, dynamic>> vendors;
  final List<Map<String, dynamic>> budgetItems;
  final int? initialVendorId;
  final int? initialScheduleId;
  const _PaymentEntrySheet({
    required this.notifier,
    this.title = 'Make a payment',
    this.buttonLabel = 'Make payment',
    this.vendors = const [],
    this.budgetItems = const [],
    this.initialVendorId,
    this.initialScheduleId,
  });

  @override
  State<_PaymentEntrySheet> createState() => _PaymentEntrySheetState();
}

class _PaymentEntrySheetState extends State<_PaymentEntrySheet> {
  final _label = TextEditingController();
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _note = TextEditingController();
  final _store = TextEditingController();
  final _itemDescription = TextEditingController();
  final _newCategoryBudget = TextEditingController();
  int? _vendorId;
  _PayableOption? _selectedOption;
  String _paymentMethod = _paymentMethodOptions.first;
  List<int>? _receiptBytes;
  String? _receiptFilename;
  bool _saving = false;
  String? _error;

  bool _isVendorMode = true;
  int? _categoryChoice;
  String? _newCategoryName;
  DateTime? _purchaseDate;

  bool get _isLockedFlow =>
      widget.initialScheduleId != null || widget.initialVendorId != null;

  @override
  void initState() {
    super.initState();
    _vendorId = widget.initialVendorId;
    _purchaseDate = DateTime.now();
    if (widget.initialScheduleId != null) {
      final options = _optionsForVendor(_vendorId);
      final match = options
          .where((o) => o.scheduleId == widget.initialScheduleId)
          .toList();
      if (match.isNotEmpty) _applyOption(match.first);
    } else if (widget.initialVendorId != null) {
      final options = _optionsForVendor(_vendorId);
      if (options.isNotEmpty) _applyOption(options.first);
    }
  }

  @override
  void dispose() {
    _label.dispose();
    _amount.dispose();
    _reference.dispose();
    _note.dispose();
    _store.dispose();
    _itemDescription.dispose();
    _newCategoryBudget.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _nonVendorBudgetItems => widget.budgetItems
      .where((item) => _asIntId(item['vendor_id']) == null)
      .toList();

  List<_PayableOption> _optionsForVendor(int? vendorId) {
    if (vendorId == null) return const [];
    final options = <_PayableOption>[];
    for (final item in widget.budgetItems) {
      if (_asIntId(item['vendor_id']) != vendorId) continue;
      final itemId = _asIntId(item['id']);
      if (itemId == null) continue;
      final schedules = ((item['payment_schedules'] as List?) ?? const [])
          .cast<Map>()
          .where((s) => (s['status'] ?? 'pending') != 'paid')
          .toList();
      for (final schedule in schedules) {
        options.add(_PayableOption(
          scheduleId: _asIntId(schedule['id']),
          budgetItemId: itemId,
          label:
              '${item['name'] ?? 'Budget item'} — ${schedule['label'] ?? 'Payment'}',
          amount: _asDouble(schedule['amount']),
          status: schedule['status']?.toString(),
        ));
      }
      if (schedules.isEmpty) {
        final actual =
            _asDouble(item['actual_amount'] ?? item['estimated_amount']);
        final paid = _asDouble(item['paid_amount']);
        final remaining = actual - paid;
        if (remaining > 0.01) {
          options.add(_PayableOption(
            budgetItemId: itemId,
            label: '${item['name'] ?? 'Budget item'} — remaining balance',
            amount: remaining,
          ));
        }
      }
    }
    return options;
  }

  void _applyOption(_PayableOption option) {
    _selectedOption = option;
    _label.text = option.label;
    _amount.text = option.amount.toStringAsFixed(2);
  }

  Future<void> _pickReceipt() async {
    final picked = await _pickReceiptFile(context);
    if (picked != null) {
      setState(() {
        _receiptBytes = picked.bytes;
        _receiptFilename = picked.filename;
      });
    }
  }

  Future<void> _submitVendor() async {
    final amount = double.tryParse(_amount.text.trim());
    if (_vendorId == null) {
      setState(() => _error = 'Choose a vendor.');
      return;
    }
    if (_selectedOption == null || amount == null || amount <= 0) {
      setState(() => _error = 'Choose what you\'re paying and an amount.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final option = _selectedOption!;
    final error = option.scheduleId != null
        ? await widget.notifier.payVendorSchedule(
            scheduleId: option.scheduleId!,
            amount: amount,
            paymentMethod: _paymentMethod,
            reference: _reference.text.trim(),
            notes: _note.text.trim(),
            receiptBytes: _receiptBytes,
            receiptFilename: _receiptFilename,
          )
        : await widget.notifier.createAdHocPayment(
            budgetItemId: option.budgetItemId,
            label: _label.text.trim().isEmpty ? 'Payment' : _label.text.trim(),
            amount: amount,
            paymentMethod: _paymentMethod,
            reference: _reference.text.trim(),
            notes: _note.text.trim(),
            receiptBytes: _receiptBytes,
            receiptFilename: _receiptFilename,
          );
    _finish(error);
  }

  Future<void> _submitNonVendor() async {
    final amount = double.tryParse(_amount.text.trim());
    if (_categoryChoice == null) {
      setState(() => _error = 'Choose a budget category.');
      return;
    }
    if (_categoryChoice == _createNewBudgetItemChoice &&
        (_newCategoryName == null || _newCategoryName!.isEmpty)) {
      setState(() => _error = 'Choose a category name.');
      return;
    }
    if (_store.text.trim().isEmpty && _itemDescription.text.trim().isEmpty) {
      setState(() => _error = 'Add the store/place or an item description.');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter an amount.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    var budgetItemId =
        _categoryChoice == _createNewBudgetItemChoice ? null : _categoryChoice;
    if (budgetItemId == null) {
      budgetItemId = await widget.notifier.createBudgetItem(
        name: _newCategoryName!,
        category: _newCategoryName,
        estimatedAmount: double.tryParse(_newCategoryBudget.text.trim()),
      );
      if (budgetItemId == null) {
        if (!mounted) return;
        setState(() {
          _saving = false;
          _error = "Couldn't create that budget category.";
        });
        return;
      }
    }
    final label = [
      if (_store.text.trim().isNotEmpty) _store.text.trim(),
      if (_itemDescription.text.trim().isNotEmpty) _itemDescription.text.trim(),
    ].join(' — ');
    final error = await widget.notifier.createAdHocPayment(
      budgetItemId: budgetItemId,
      label: label.isEmpty ? 'Purchase' : label,
      amount: amount,
      paymentMethod: _paymentMethod,
      reference: _reference.text.trim(),
      notes: _note.text.trim(),
      dueDate: _purchaseDate == null ? null : _formatDate(_purchaseDate!),
      receiptBytes: _receiptBytes,
      receiptFilename: _receiptFilename,
    );
    _finish(error);
  }

  void _finish(String? error) {
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  List<Widget> _buildVendorFields() {
    final options = _optionsForVendor(_vendorId);
    final lockedToSchedule = widget.initialScheduleId != null;
    return [
      DropdownButtonFormField<int>(
        initialValue: _vendorId,
        isExpanded: true,
        menuMaxHeight: 360,
        decoration: const InputDecoration(labelText: 'Vendor'),
        items: widget.vendors
            .map((vendor) => _asIntId(vendor['id']) == null
                ? null
                : DropdownMenuItem(
                    value: _asIntId(vendor['id'])!,
                    child: Text(vendor['name']?.toString() ?? 'Vendor',
                        overflow: TextOverflow.ellipsis),
                  ))
            .whereType<DropdownMenuItem<int>>()
            .toList(),
        onChanged: lockedToSchedule
            ? null
            : (value) => setState(() {
                  _vendorId = value;
                  _selectedOption = null;
                  _label.clear();
                  _amount.clear();
                }),
      ),
      const SizedBox(height: 12),
      if (_vendorId != null && !lockedToSchedule)
        options.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'This vendor has no budget yet. Add one from the Budget tab first.',
                  style: UdoDesign.sans(size: 12.5, color: UdoDesign.sub),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<int>(
                  initialValue: null,
                  isExpanded: true,
                  menuMaxHeight: 360,
                  decoration:
                      const InputDecoration(labelText: 'What are you paying?'),
                  hint: const Text('Choose a milestone or balance'),
                  items: List.generate(options.length, (i) => i)
                      .map((i) => DropdownMenuItem(
                            value: i,
                            child: Text(
                                '${options[i].label} · ${_moneyCents(options[i].amount)}',
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (i) => setState(() => _applyOption(options[i!])),
                ),
              ),
      if (lockedToSchedule) ...[
        Text(_label.text,
            style: UdoDesign.sans(size: 14, weight: FontWeight.w800)),
        const SizedBox(height: 12),
      ],
    ];
  }

  List<Widget> _buildNonVendorFields() {
    final items = _nonVendorBudgetItems;
    return [
      DropdownButtonFormField<int>(
        initialValue: _categoryChoice,
        isExpanded: true,
        menuMaxHeight: 360,
        decoration: const InputDecoration(labelText: 'Budget category'),
        hint: const Text('Choose or create a category'),
        items: [
          ...items.map((item) {
            final itemId = _asIntId(item['id']);
            if (itemId == null) return null;
            return DropdownMenuItem<int>(
              value: itemId,
              child: Text(item['name']?.toString() ?? 'Budget item',
                  overflow: TextOverflow.ellipsis),
            );
          }).whereType<DropdownMenuItem<int>>(),
          const DropdownMenuItem(
            value: _createNewBudgetItemChoice,
            child: Text('+ Create new category'),
          ),
        ],
        onChanged: (value) => setState(() => _categoryChoice = value),
      ),
      if (_categoryChoice == _createNewBudgetItemChoice) ...[
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _newCategoryName,
          isExpanded: true,
          menuMaxHeight: 360,
          decoration: const InputDecoration(labelText: 'Category name'),
          items: _budgetCategoryOptions
              .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _newCategoryName = value),
        ),
        const SizedBox(height: 12),
        _PaymentTextField(
            _newCategoryBudget, 'Budgeted amount (optional)', '2500',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefix: '\$'),
      ],
      const SizedBox(height: 12),
      _PaymentTextField(_store, 'Store / Place', 'e.g. Amazon'),
      const SizedBox(height: 12),
      _PaymentTextField(_itemDescription, 'Item / Description',
          'e.g. Candle Holders (Set of 10)'),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _purchaseDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2035),
          );
          if (picked != null) setState(() => _purchaseDate = picked);
        },
        icon: const Icon(Icons.calendar_month_outlined),
        label: Text(_purchaseDate == null
            ? 'Set purchase date'
            : 'Purchased ${_formatDate(_purchaseDate!)}'),
      ),
      const SizedBox(height: 12),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _PaymentFormShell(
      title: widget.title,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (!_isLockedFlow) ...[
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _isVendorMode = true;
                  _error = null;
                }),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _isVendorMode
                      ? UdoDesign.blue.withValues(alpha: 0.1)
                      : null,
                  side: BorderSide(
                      color: _isVendorMode ? UdoDesign.blue : UdoDesign.stone),
                ),
                child: const Text('Vendor'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _isVendorMode = false;
                  _error = null;
                }),
                style: OutlinedButton.styleFrom(
                  backgroundColor: !_isVendorMode
                      ? UdoDesign.blue.withValues(alpha: 0.1)
                      : null,
                  side: BorderSide(
                      color: !_isVendorMode ? UdoDesign.blue : UdoDesign.stone),
                ),
                child: const Text('Non-Vendor'),
              ),
            ),
          ]),
          const SizedBox(height: 12),
        ],
        ..._isVendorMode ? _buildVendorFields() : _buildNonVendorFields(),
        _PaymentTextField(_amount, 'Amount', '900',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefix: '\$'),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _paymentMethod,
          decoration: const InputDecoration(labelText: 'Payment method'),
          items: _paymentMethodOptions
              .map((method) =>
                  DropdownMenuItem(value: method, child: Text(method)))
              .toList(),
          onChanged: (value) =>
              setState(() => _paymentMethod = value ?? _paymentMethod),
        ),
        const SizedBox(height: 12),
        _PaymentTextField(
            _reference, 'Reference', 'e.g. transaction ID or cheque no.'),
        const SizedBox(height: 12),
        _PaymentTextField(_note, 'Note', 'Optional internal note', maxLines: 2),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickReceipt,
          icon: const Icon(Icons.attach_file_outlined),
          label: Text(
              _receiptFilename == null ? 'Attach receipt' : _receiptFilename!),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: UdoDesign.sans(size: 12, color: UdoDesign.rose)),
        ],
        const SizedBox(height: 18),
        _PaymentSubmitButton(
          saving: _saving,
          label: widget.buttonLabel,
          onPressed: _isVendorMode ? _submitVendor : _submitNonVendor,
        ),
      ]),
    );
  }
}

/// Sentinel used in the budget-item picker below to mean "create a new
/// budget item for this invoice" rather than attaching to an existing one.
const _createNewBudgetItemChoice = -1;

class _PaymentInvoiceSheet extends StatefulWidget {
  final PlanNotifier notifier;
  final List<Map<String, dynamic>> vendors;
  final List<Map<String, dynamic>> budgetItems;
  const _PaymentInvoiceSheet({
    required this.notifier,
    this.vendors = const [],
    this.budgetItems = const [],
  });

  @override
  State<_PaymentInvoiceSheet> createState() => _PaymentInvoiceSheetState();
}

class _PaymentInvoiceSheetState extends State<_PaymentInvoiceSheet> {
  final _label = TextEditingController();
  final _newItemName = TextEditingController();
  final _amount = TextEditingController();
  int? _vendorId;
  int? _budgetItemChoice;
  DateTime? _dueDate;
  List<int>? _fileBytes;
  String? _fileName;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _label.dispose();
    _newItemName.dispose();
    _amount.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _vendorBudgetItems => widget.budgetItems
      .where((item) => _asIntId(item['vendor_id']) == _vendorId)
      .toList();

  Future<void> _pick() async {
    final picked = await _pickReceiptFile(context);
    if (picked != null) {
      setState(() {
        _fileBytes = picked.bytes;
        _fileName = picked.filename;
      });
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amount.text.trim());
    if (_vendorId == null || _budgetItemChoice == null) {
      setState(() => _error = 'Choose a vendor and a budget item.');
      return;
    }
    if (_label.text.trim().isEmpty || amount == null || amount <= 0) {
      setState(() => _error = 'Add an invoice title and amount.');
      return;
    }
    if (_fileBytes == null) {
      setState(() => _error = 'Attach the invoice file.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    var budgetItemId = _budgetItemChoice == _createNewBudgetItemChoice
        ? null
        : _budgetItemChoice;
    if (budgetItemId == null) {
      budgetItemId = await widget.notifier.createBudgetItem(
        name: _newItemName.text.trim().isEmpty
            ? _label.text.trim()
            : _newItemName.text.trim(),
        vendorId: _vendorId,
        estimatedAmount: amount,
      );
      if (budgetItemId == null) {
        if (!mounted) return;
        setState(() {
          _saving = false;
          _error = "Couldn't create a budget item for this invoice.";
        });
        return;
      }
    }
    final ok = await widget.notifier.createPaymentSchedule(
      budgetItemId: budgetItemId,
      label: _label.text.trim(),
      amount: amount,
      dueDate: _dueDate == null ? null : _formatDate(_dueDate!),
      documentBytes: _fileBytes,
      documentFilename: _fileName,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save this invoice.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _vendorBudgetItems;
    return _PaymentFormShell(
      title: 'Upload invoice',
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<int>(
          initialValue: _vendorId,
          isExpanded: true,
          menuMaxHeight: 360,
          decoration: const InputDecoration(labelText: 'Vendor'),
          items: widget.vendors
              .map((vendor) {
                final vendorId = _asIntId(vendor['id']);
                if (vendorId == null) return null;
                return DropdownMenuItem<int>(
                  value: vendorId,
                  child: Text(vendor['name']?.toString() ?? 'Vendor',
                      overflow: TextOverflow.ellipsis),
                );
              })
              .whereType<DropdownMenuItem<int>>()
              .toList(),
          onChanged: (value) => setState(() {
            _vendorId = value;
            _budgetItemChoice = null;
          }),
        ),
        if (_vendorId != null) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _budgetItemChoice,
            isExpanded: true,
            menuMaxHeight: 360,
            decoration: const InputDecoration(labelText: 'Budget item'),
            hint: const Text('Choose or create a budget item'),
            items: [
              ...items.map((item) {
                final itemId = _asIntId(item['id']);
                if (itemId == null) return null;
                return DropdownMenuItem<int>(
                  value: itemId,
                  child: Text(item['name']?.toString() ?? 'Budget item',
                      overflow: TextOverflow.ellipsis),
                );
              }).whereType<DropdownMenuItem<int>>(),
              const DropdownMenuItem(
                value: _createNewBudgetItemChoice,
                child: Text('+ Create new budget item'),
              ),
            ],
            onChanged: (value) => setState(() => _budgetItemChoice = value),
          ),
          if (_budgetItemChoice == _createNewBudgetItemChoice) ...[
            const SizedBox(height: 12),
            _PaymentTextField(
                _newItemName, 'New budget item name', 'e.g. Florist balance'),
          ],
        ],
        const SizedBox(height: 12),
        _PaymentTextField(
            _label, 'Invoice title', 'e.g. Florist final invoice'),
        const SizedBox(height: 12),
        _PaymentTextField(_amount, 'Amount', '900',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefix: '\$'),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dueDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
            );
            if (picked != null) setState(() => _dueDate = picked);
          },
          icon: const Icon(Icons.calendar_month_outlined),
          label: Text(_dueDate == null
              ? 'Set due date'
              : 'Due ${_formatDate(_dueDate!)}'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pick,
          icon: const Icon(Icons.attach_file_outlined),
          label: Text(
              _fileName == null ? 'Attach invoice (PDF or image)' : _fileName!),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: UdoDesign.sans(size: 12, color: UdoDesign.rose)),
        ],
        const SizedBox(height: 18),
        _PaymentSubmitButton(
          saving: _saving,
          label: 'Save invoice',
          onPressed: _submit,
        ),
      ]),
    );
  }
}

class _PaymentPlanSheet extends StatefulWidget {
  final PlanNotifier notifier;
  final List<Map<String, dynamic>> vendors;
  const _PaymentPlanSheet({required this.notifier, this.vendors = const []});

  @override
  State<_PaymentPlanSheet> createState() => _PaymentPlanSheetState();
}

class _PaymentPlanSheetState extends State<_PaymentPlanSheet> {
  final _total = TextEditingController();
  int? _vendorId;
  int _installments = 2;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _total.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final total = double.tryParse(_total.text.trim());
    if (_vendorId == null || total == null || total <= 0) {
      setState(() => _error = 'Choose a vendor and enter a total amount.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final vendorName = widget.vendors
        .firstWhere((v) => _asIntId(v['id']) == _vendorId,
            orElse: () => const {'name': 'Vendor'})['name']
        ?.toString();
    final itemId = await widget.notifier.createBudgetItem(
      name: '$vendorName payment plan',
      vendorId: _vendorId,
      estimatedAmount: total,
    );
    if (itemId == null) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = "Couldn't create the budget for this payment plan.";
      });
      return;
    }
    final each = total / _installments;
    var saved = true;
    for (var i = 1; i <= _installments; i++) {
      final ok = await widget.notifier.createPaymentSchedule(
        budgetItemId: itemId,
        label: 'Installment $i of $_installments',
        amount: each,
      );
      saved = saved && ok;
    }
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save the full payment plan.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PaymentFormShell(
      title: 'Add payment plan',
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<int>(
          initialValue: _vendorId,
          isExpanded: true,
          menuMaxHeight: 360,
          decoration: const InputDecoration(labelText: 'Vendor'),
          items: widget.vendors
              .map((vendor) {
                final vendorId = _asIntId(vendor['id']);
                if (vendorId == null) return null;
                return DropdownMenuItem<int>(
                  value: vendorId,
                  child: Text(vendor['name']?.toString() ?? 'Vendor',
                      overflow: TextOverflow.ellipsis),
                );
              })
              .whereType<DropdownMenuItem<int>>()
              .toList(),
          onChanged: (value) => setState(() => _vendorId = value),
        ),
        const SizedBox(height: 12),
        _PaymentTextField(_total, 'Total amount', '3500',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefix: '\$'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: Text('Installments',
                  style: UdoDesign.sans(size: 13, weight: FontWeight.w800))),
          IconButton(
            onPressed: _installments <= 2
                ? null
                : () => setState(() => _installments--),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('$_installments',
              style: UdoDesign.sans(size: 16, weight: FontWeight.w800)),
          IconButton(
            onPressed: _installments >= 12
                ? null
                : () => setState(() => _installments++),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ]),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: UdoDesign.sans(size: 12, color: UdoDesign.rose)),
        ],
        const SizedBox(height: 18),
        _PaymentSubmitButton(
          saving: _saving,
          label: 'Create plan',
          onPressed: _submit,
        ),
      ]),
    );
  }
}

class _PaymentFormShell extends StatelessWidget {
  final String title;
  final Widget child;
  const _PaymentFormShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 22),
      child: SafeArea(
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(title,
                    style: UdoDesign.sans(size: 18, weight: FontWeight.w800)),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ]),
            const SizedBox(height: 12),
            child,
          ]),
        ),
      ),
    );
  }
}

class _PaymentTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final String? prefix;
  final int maxLines;
  const _PaymentTextField(
    this.controller,
    this.label,
    this.hint, {
    this.keyboardType,
    this.prefix,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _PaymentSubmitButton extends StatelessWidget {
  final bool saving;
  final String label;
  final VoidCallback onPressed;
  const _PaymentSubmitButton({
    required this.saving,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: saving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          backgroundColor: UdoDesign.blue,
          foregroundColor: Colors.white,
        ),
        child: saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class _ScheduleMilestoneRow {
  final TextEditingController label;
  final TextEditingController amount;
  DateTime? dueDate;
  _ScheduleMilestoneRow({String label = '', double? amount})
      : label = TextEditingController(text: label),
        amount = TextEditingController(
            text: amount == null ? '' : amount.toStringAsFixed(2));

  void dispose() {
    label.dispose();
    amount.dispose();
  }
}

class _PaymentScheduleSheet extends StatefulWidget {
  final PlanNotifier notifier;
  final int budgetItemId;
  final double totalAmount;
  const _PaymentScheduleSheet({
    required this.notifier,
    required this.budgetItemId,
    required this.totalAmount,
  });

  @override
  State<_PaymentScheduleSheet> createState() => _PaymentScheduleSheetState();
}

class _PaymentScheduleSheetState extends State<_PaymentScheduleSheet> {
  late final List<_ScheduleMilestoneRow> _rows;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final deposit = (widget.totalAmount * 0.3).roundToDouble();
    _rows = [
      _ScheduleMilestoneRow(label: 'Deposit', amount: deposit),
      _ScheduleMilestoneRow(
          label: 'Balance', amount: widget.totalAmount - deposit),
    ];
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  double get _runningTotal => _rows.fold<double>(
      0, (sum, row) => sum + (double.tryParse(row.amount.text.trim()) ?? 0));

  void _addRow() {
    setState(() => _rows.add(_ScheduleMilestoneRow()));
  }

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  Future<void> _pickDate(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _rows[index].dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _rows[index].dueDate = picked);
  }

  Future<void> _save() async {
    final validRows = _rows
        .where((row) =>
            row.label.text.trim().isNotEmpty &&
            (double.tryParse(row.amount.text.trim()) ?? 0) > 0)
        .toList();
    if (validRows.isEmpty) {
      setState(() => _error = 'Add at least one milestone with an amount.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    var allOk = true;
    for (final row in validRows) {
      final ok = await widget.notifier.createPaymentSchedule(
        budgetItemId: widget.budgetItemId,
        label: row.label.text.trim(),
        amount: double.parse(row.amount.text.trim()),
        dueDate: row.dueDate == null ? null : _formatDate(row.dueDate!),
      );
      allOk = allOk && ok;
    }
    if (!mounted) return;
    if (allOk) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save the full payment schedule.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.totalAmount - _runningTotal;
    return _PaymentFormShell(
      title: 'Set payment schedule',
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          'Budgeted amount: ${_moneyCents(widget.totalAmount)}',
          style: UdoDesign.sans(size: 12.5, color: UdoDesign.sub),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < _rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  flex: 3,
                  child: _PaymentTextField(
                      _rows[i].label, 'Milestone', 'e.g. Deposit (30%)'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _PaymentTextField(
                    _rows[i].amount,
                    'Amount',
                    '0.00',
                    prefix: '\$',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                IconButton(
                  onPressed: _rows.length > 1 ? () => _removeRow(i) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
              ]),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: () => _pickDate(i),
                icon: const Icon(Icons.calendar_month_outlined, size: 16),
                label: Text(_rows[i].dueDate == null
                    ? 'Set due date'
                    : 'Due ${_formatDate(_rows[i].dueDate!)}'),
              ),
            ]),
          ),
        TextButton.icon(
          onPressed: _addRow,
          icon: const Icon(Icons.add),
          label: const Text('Add milestone'),
        ),
        const SizedBox(height: 8),
        Text(
          remaining.abs() < 0.01
              ? 'Milestones match the budgeted amount.'
              : remaining > 0
                  ? '${_moneyCents(remaining)} left to schedule.'
                  : '${_moneyCents(-remaining)} over the budgeted amount.',
          style: UdoDesign.sans(
              size: 12,
              color: remaining.abs() < 0.01 ? UdoDesign.sage : UdoDesign.amber),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: UdoDesign.sans(size: 12, color: UdoDesign.rose)),
        ],
        const SizedBox(height: 18),
        _PaymentSubmitButton(
          saving: _saving,
          label: 'Save schedule',
          onPressed: _save,
        ),
      ]),
    );
  }
}

Future<void> showAddTaskSheet(BuildContext context, PlanNotifier notifier) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
      category:
          _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
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
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.udoBorder,
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('New task',
              style: TextStyle(
                  fontFamily: 'Playfair',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.udoGreen)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            autofocus: true,
            decoration: const InputDecoration(
                labelText: 'Title', hintText: 'e.g. Confirm florist order'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _categoryCtrl,
            decoration: const InputDecoration(
                labelText: 'Category (optional)', hintText: 'e.g. Vendors'),
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
                label: Text(_dueDate == null
                    ? 'Due date'
                    : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['low', 'medium', 'high']
                .map((p) => ChoiceChip(
                      label: Text(p[0].toUpperCase() + p.substring(1)),
                      selected: _priority == p,
                      onSelected: (_) => setState(() => _priority = p),
                      selectedColor: AppTheme.udoGreen,
                      labelStyle: TextStyle(
                          color: _priority == p
                              ? Colors.white
                              : AppTheme.udoTextPrimary,
                          fontSize: 13),
                    ))
                .toList(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style:
                    const TextStyle(color: AppTheme.udoCrimson, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.udoGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50)),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
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
  String _query = '';

  @override
  Widget build(BuildContext context) {
    if (widget.state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));
    }

    if (widget.state.tasksError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline,
                size: 40, color: AppTheme.udoCrimson),
            const SizedBox(height: 12),
            const Text("Couldn't load your tasks.",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.udoCrimson)),
            const SizedBox(height: 6),
            Text(widget.state.tasksError!,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.udoTextSecondary),
                textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    final tasks = widget.state.tasks;
    final today = DateTime.now();
    final filtered = tasks.where((t) {
      final done = t['completed'] == true;
      final priority = t['priority'] as String? ?? 'low';
      final due = _parseDate(t['due_date']);
      final title = (t['title'] as String? ?? '').toLowerCase();
      final category = (t['category'] as String? ?? '').toLowerCase();
      final matchesQuery = _query.trim().isEmpty ||
          title.contains(_query.toLowerCase()) ||
          category.contains(_query.toLowerCase());
      if (!matchesQuery) return false;
      if (_filter == 'Urgent') return !done && priority == 'high';
      if (_filter == 'This Week') {
        return !done &&
            due != null &&
            !due.isBefore(_dateOnly(today)) &&
            due.difference(_dateOnly(today)).inDays <= 7;
      }
      if (_filter == 'Overdue') {
        return !done && due != null && due.isBefore(_dateOnly(today));
      }
      if (_filter == 'Completed') return done;
      return true;
    }).toList()
      ..sort(_sortTasks);

    final remaining = tasks.where((t) => t['completed'] != true).length;
    final completed = tasks.length - remaining;
    final overdue = tasks.where((t) {
      final due = _parseDate(t['due_date']);
      return t['completed'] != true &&
          due != null &&
          due.isBefore(_dateOnly(today));
    }).length;
    final thisWeek = tasks.where((t) {
      final due = _parseDate(t['due_date']);
      return t['completed'] != true &&
          due != null &&
          !due.isBefore(_dateOnly(today)) &&
          due.difference(_dateOnly(today)).inDays <= 7;
    }).length;
    final grouped = _groupTasks(filtered);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 110),
      children: [
        GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.9,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            _TaskMetricCard(
                label: 'Remaining', value: '$remaining', color: UdoDesign.text),
            _TaskMetricCard(
                label: 'Done', value: '$completed', color: UdoDesign.sage),
            _TaskMetricCard(
                label: 'Overdue', value: '$overdue', color: UdoDesign.rose),
            _TaskMetricCard(
                label: 'This week', value: '$thisWeek', color: UdoDesign.amber),
          ],
        ),
        const SizedBox(height: 16),
        UdoCard(
          radius: 22,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search tasks, categories, owners...',
              hintStyle: UdoDesign.sans(size: 14, color: UdoDesign.muted),
              border: InputBorder.none,
              icon: const Icon(Icons.search, color: UdoDesign.muted, size: 20),
            ),
            style: UdoDesign.sans(size: 14),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final f in [
                'All',
                'Urgent',
                'This Week',
                'Overdue',
                'Completed'
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: UdoDesign.plan,
                    backgroundColor: UdoDesign.card,
                    side: BorderSide(
                        color: _filter == f ? UdoDesign.plan : UdoDesign.stone),
                    labelStyle: UdoDesign.sans(
                      size: 13,
                      weight: FontWeight.w600,
                      color: _filter == f ? Colors.white : UdoDesign.sub,
                    ),
                    showCheckmark: false,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (filtered.any((t) => t['completed'] != true)) ...[
          OutlinedButton.icon(
            onPressed: () async => _completeVisible(context, filtered),
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Complete visible pending tasks'),
            style: OutlinedButton.styleFrom(
              foregroundColor: UdoDesign.plan,
              side: BorderSide(color: UdoDesign.plan.withValues(alpha: 0.32)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 18),
        ],
        if (filtered.isEmpty)
          UdoCard(
            padding: const EdgeInsets.all(26),
            child: Column(children: [
              const Icon(Icons.task_alt_outlined,
                  color: UdoDesign.muted, size: 36),
              const SizedBox(height: 12),
              Text('No tasks here',
                  style: UdoDesign.sans(size: 16, weight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Change the filter or add a new planning task.',
                  textAlign: TextAlign.center,
                  style: UdoDesign.sans(size: 13, color: UdoDesign.muted)),
            ]),
          )
        else
          for (final group in grouped)
            _TaskGroupSection(
              title: group.title,
              color: group.color,
              tasks: group.tasks,
              onToggle: (task) => widget.notifier.toggleTask(task['id'] as int),
            ),
        const SizedBox(height: 18),
        Text('Need to add another task?',
            textAlign: TextAlign.center,
            style: UdoDesign.sans(size: 13, color: UdoDesign.muted)),
        const SizedBox(height: 10),
        UdoCard(
          onTap: () => showAddTaskSheet(context, widget.notifier),
          radius: 30,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          border: BorderSide(
              color: UdoDesign.plan.withValues(alpha: 0.16), width: 1.5),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: UdoDesign.plan.withValues(alpha: 0.10),
                  shape: BoxShape.circle),
              child: const Icon(Icons.add, color: UdoDesign.plan, size: 20),
            ),
            const SizedBox(width: 14),
            Text('Add Task',
                style: UdoDesign.sans(
                    size: 20, weight: FontWeight.w800, color: UdoDesign.plan)),
          ]),
        ),
      ],
    );
  }

  Future<void> _completeVisible(
      BuildContext context, List<Map<String, dynamic>> tasks) async {
    final ids = tasks
        .where((t) => t['completed'] != true)
        .map((t) => t['id'] as int)
        .toList();
    final count =
        await widget.notifier.bulkUpdateTasks(ids, {'completed': true});
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Marked $count task${count == 1 ? '' : 's'} complete.')),
      );
    }
  }

  int _sortTasks(Map<String, dynamic> a, Map<String, dynamic> b) {
    if ((a['completed'] == true) != (b['completed'] == true)) {
      return a['completed'] == true ? 1 : -1;
    }
    const priority = {'high': 0, 'medium': 1, 'low': 2};
    final pa = priority[a['priority'] as String? ?? 'low'] ?? 2;
    final pb = priority[b['priority'] as String? ?? 'low'] ?? 2;
    if (pa != pb) return pa.compareTo(pb);
    final da = _parseDate(a['due_date']);
    final db = _parseDate(b['due_date']);
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  }

  List<_TaskGroup> _groupTasks(List<Map<String, dynamic>> tasks) {
    final today = _dateOnly(DateTime.now());
    final overdue = <Map<String, dynamic>>[];
    final week = <Map<String, dynamic>>[];
    final upcoming = <Map<String, dynamic>>[];
    final completed = <Map<String, dynamic>>[];

    for (final task in tasks) {
      if (task['completed'] == true) {
        completed.add(task);
        continue;
      }
      final due = _parseDate(task['due_date']);
      if (due != null && due.isBefore(today)) {
        overdue.add(task);
      } else if (due != null && due.difference(today).inDays <= 7) {
        week.add(task);
      } else {
        upcoming.add(task);
      }
    }

    return [
      if (overdue.isNotEmpty) _TaskGroup('Overdue', UdoDesign.rose, overdue),
      if (week.isNotEmpty) _TaskGroup('This Week', UdoDesign.amber, week),
      if (upcoming.isNotEmpty) _TaskGroup('Upcoming', UdoDesign.sage, upcoming),
      if (completed.isNotEmpty)
        _TaskGroup('Completed', UdoDesign.muted, completed),
    ];
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return _dateOnly(value);
    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      return parsed == null ? null : _dateOnly(parsed);
    }
    return null;
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

// ── BUDGET TAB ─────────────────────────────────────────────────────────────────

class _TaskGroup {
  final String title;
  final Color color;
  final List<Map<String, dynamic>> tasks;

  const _TaskGroup(this.title, this.color, this.tasks);
}

class _TaskMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TaskMetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      radius: 18,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value,
              style: UdoDesign.sans(
                  size: 22, weight: FontWeight.w800, color: color)),
        ),
        const SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center,
            style: UdoDesign.sans(size: 10.5, color: UdoDesign.muted),
            maxLines: 2),
      ]),
    );
  }
}

class _TaskGroupSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<Map<String, dynamic>> tasks;
  final void Function(Map<String, dynamic>) onToggle;

  const _TaskGroupSection({
    required this.title,
    required this.color,
    required this.tasks,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(title.toUpperCase(),
              style: UdoDesign.sans(
                  size: 13, weight: FontWeight.w800, color: UdoDesign.sub)),
          const SizedBox(width: 6),
          Text('(${tasks.length})',
              style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
        ]),
        const SizedBox(height: 10),
        UdoCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            for (var i = 0; i < tasks.length; i++)
              _TaskCommandRow(
                task: tasks[i],
                accent: color,
                last: i == tasks.length - 1,
                onToggle: () => onToggle(tasks[i]),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _TaskCommandRow extends StatelessWidget {
  final Map<String, dynamic> task;
  final Color accent;
  final bool last;
  final VoidCallback onToggle;

  const _TaskCommandRow({
    required this.task,
    required this.accent,
    required this.last,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final done = task['completed'] == true;
    final priority = task['priority'] as String? ?? 'low';
    final category = task['category'] as String? ?? 'Planning';
    final due = _formatTaskDueDate(task['due_date']);
    return AnimatedOpacity(
      opacity: done ? 0.62 : 1,
      duration: const Duration(milliseconds: 180),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
            border: last
                ? null
                : const Border(bottom: BorderSide(color: UdoDesign.stone))),
        child: Row(children: [
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: done ? UdoDesign.plan : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                    color: done ? UdoDesign.plan : UdoDesign.stone, width: 1.6),
              ),
              child: done
                  ? const Icon(Icons.check, color: Colors.white, size: 15)
                  : null,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                task['title'] as String? ?? 'Untitled task',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: UdoDesign.sans(
                  size: 14.5,
                  weight: FontWeight.w700,
                  color: done ? UdoDesign.muted : UdoDesign.text,
                  height: 1.25,
                ).copyWith(
                    decoration: done ? TextDecoration.lineThrough : null),
              ),
              const SizedBox(height: 7),
              Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    UdoBadge(
                        label: category,
                        color: UdoDesign.muted,
                        background: UdoDesign.stone.withValues(alpha: 0.55)),
                    UdoBadge(label: priority, color: _priorityColor(priority)),
                    Text(due == null ? 'No due date' : 'Due $due',
                        style:
                            UdoDesign.sans(size: 12, color: UdoDesign.muted)),
                  ]),
            ]),
          ),
          const SizedBox(width: 10),
          Icon(Icons.chevron_right,
              color: accent.withValues(alpha: 0.72), size: 18),
        ]),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return UdoDesign.rose;
      case 'medium':
        return UdoDesign.amber;
      default:
        return UdoDesign.sage;
    }
  }
}

class _BudgetTab extends StatefulWidget {
  final PlanState state;
  final PlanNotifier notifier;
  final VoidCallback onOpenSchedule;
  const _BudgetTab(
      {required this.state,
      required this.notifier,
      required this.onOpenSchedule});

  @override
  State<_BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<_BudgetTab> {
  final _scrollController = ScrollController();
  final _categoriesKey = GlobalKey();
  final _scheduleKey = GlobalKey();
  String? _statusFilter;
  String _sortBy = 'amount';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null)
      Scrollable.ensureVisible(ctx,
          alignment: 0.1, duration: const Duration(milliseconds: 300));
  }

  void _exportReport(
      Map<String, ({double estimated, double actual, double paid})>
          byCategory) {
    final buffer = StringBuffer('Item,Category,Estimated,Actual,Paid,Status\n');
    for (final item in widget.state.budgetItems) {
      buffer.writeln([
        item['name'] ?? '',
        item['category'] ?? 'Uncategorized',
        _asDouble(item['estimated_amount']).toStringAsFixed(2),
        _asDouble(item['actual_amount']).toStringAsFixed(2),
        _asDouble(item['paid_amount']).toStringAsFixed(2),
        item['payment_status'] ?? 'pending',
      ].join(','));
    }
    Share.share(buffer.toString(), subject: 'Budget report');
  }

  Future<void> _showAddBudgetItem() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddBudgetItemSheet(
        notifier: widget.notifier,
        vendors: widget.state.vendors,
      ),
    );
    if (!mounted) return;
    await _maybeOfferPaymentSchedule(context, widget.notifier, result);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state.isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));

    final summary = state.budgetSummary;
    final totalBudget = _asDouble(summary['total_budget']);
    final totalActual = _asDouble(summary['total_actual']);
    final totalPaid = _asDouble(summary['total_paid']);
    // If no total budget was ever set during onboarding, compare spend against
    // the sum of estimates instead of dividing by zero / showing "of $0".
    final totalEstimated = _asDouble(summary['total_estimated']);
    final remaining = _asDouble(summary['remaining_budget']);
    final comparisonTotal = totalBudget > 0 ? totalBudget : totalEstimated;
    final progress = comparisonTotal > 0
        ? (totalActual / comparisonTotal).clamp(0.0, 1.0)
        : 0.0;
    final nextPayments = ((summary['next_payments'] as List?) ?? const [])
        .cast<Map<String, dynamic>>();
    final overduePayments = ((summary['overdue_payments'] as List?) ?? const [])
        .cast<Map<String, dynamic>>();
    final largestExpense = summary['largest_expense'] as Map<String, dynamic>?;

    // Group real budget items by category.
    final byCategory =
        <String, ({double estimated, double actual, double paid})>{};
    for (final item in state.budgetItems) {
      final category = (item['category'] as String?)?.trim();
      final key =
          (category == null || category.isEmpty) ? 'Uncategorized' : category;
      final existing = byCategory[key] ?? (estimated: 0, actual: 0, paid: 0);
      byCategory[key] = (
        estimated: existing.estimated + _asDouble(item['estimated_amount']),
        actual: existing.actual + _asDouble(item['actual_amount']),
        paid: existing.paid + _asDouble(item['paid_amount']),
      );
    }

    var categoryEntries = byCategory.entries.toList();
    if (_statusFilter != null) {
      categoryEntries = categoryEntries.where((e) {
        final status = e.value.actual == 0
            ? 'pending'
            : (e.value.paid >= e.value.actual ? 'complete' : 'on-track');
        return status == _statusFilter;
      }).toList();
    }
    switch (_sortBy) {
      case 'category':
        categoryEntries.sort((a, b) => a.key.compareTo(b.key));
      case 'amount':
        categoryEntries
            .sort((a, b) => b.value.actual.compareTo(a.value.actual));
    }

    final rebuiltBudget = _BudgetRedesignPage(
      scrollController: _scrollController,
      budgetError: state.budgetError,
      remaining: remaining,
      comparisonTotal: comparisonTotal,
      totalActual: totalActual,
      totalEstimated: totalEstimated,
      totalPaid: totalPaid,
      progress: progress,
      categoriesKey: _categoriesKey,
      scheduleKey: _scheduleKey,
      categoryEntries: categoryEntries,
      payments: [...overduePayments, ...nextPayments],
      largestExpense: largestExpense,
      onAdd: _showAddBudgetItem,
      onCategories: () => _scrollTo(_categoriesKey),
      onSchedule: widget.onOpenSchedule,
      onExport: () => _exportReport(byCategory),
      onStatusFilter: (v) =>
          setState(() => _statusFilter = v == 'all' ? null : v),
      onSort: (v) => setState(() => _sortBy = v),
    );
    if (MediaQuery.sizeOf(context).width >= 0) {
      return rebuiltBudget;
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        if (state.budgetError != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppTheme.udoCrimson.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14)),
            child: const Text(
                "Couldn't load your budget. Pull to refresh or try again later.",
                style: TextStyle(fontSize: 13, color: AppTheme.udoCrimson)),
          ),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppTheme.udoGreen,
                AppTheme.udoGreen.withValues(alpha: 0.8)
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Budget overview',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _BudgetStat(
                      label: 'Total budget',
                      value: comparisonTotal,
                      percentage: null)),
              const SizedBox(width: 8),
              Expanded(
                  child: _BudgetStat(
                      label: 'Committed',
                      value: totalEstimated,
                      percentage: comparisonTotal > 0
                          ? ((totalEstimated / comparisonTotal) * 100).round()
                          : 0)),
              const SizedBox(width: 8),
              Expanded(
                  child: _BudgetStat(
                      label: 'Paid',
                      value: totalPaid,
                      percentage: comparisonTotal > 0
                          ? ((totalPaid / comparisonTotal) * 100).round()
                          : 0)),
              const SizedBox(width: 8),
              Expanded(
                  child: _BudgetStat(
                      label: 'Remaining',
                      value: remaining,
                      percentage: comparisonTotal > 0
                          ? ((remaining / comparisonTotal) * 100).round()
                          : 0)),
            ]),
            const SizedBox(height: 14),
            LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3)),
            const SizedBox(height: 6),
            Text(
                '${(progress * 100).toStringAsFixed(0)}% used • ${_money(totalPaid)} paid so far',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.udoBorder)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: _BudgetInfoColumn(
              icon: Icons.event_outlined,
              label: 'Next payment',
              value: nextPayments.isEmpty
                  ? '—'
                  : (nextPayments.first['label'] as String? ?? 'Payment'),
              detail: nextPayments.isEmpty
                  ? null
                  : nextPayments.first['due_date'] as String?,
            )),
            Expanded(
                child: _BudgetInfoColumn(
              icon: Icons.warning_amber_outlined,
              label: 'Overdue payments',
              value: '${overduePayments.length}',
              detail: overduePayments.isEmpty
                  ? null
                  : '${_money(overduePayments.fold<double>(0, (sum, p) => sum + _asDouble(p['amount'])))} overdue',
            )),
            Expanded(
                child: _BudgetInfoColumn(
              icon: Icons.bar_chart_outlined,
              label: 'Largest expense',
              value: largestExpense == null
                  ? '—'
                  : (largestExpense['category'] as String? ?? 'Uncategorized'),
              detail: largestExpense == null
                  ? null
                  : '${_money(_asDouble(largestExpense['amount']))} (${largestExpense['percentage']}%)',
            )),
          ]),
        ),
        const SizedBox(height: 16),
        const Text('Quick actions',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _QuickActionChip(
              icon: Icons.add,
              label: 'Add budget item',
              onTap: _showAddBudgetItem),
          _QuickActionChip(
              icon: Icons.category_outlined,
              label: 'Categories',
              onTap: () => _scrollTo(_categoriesKey)),
          _QuickActionChip(
              icon: Icons.event_note_outlined,
              label: 'Payment schedule',
              onTap: () => _scrollTo(_scheduleKey)),
          _QuickActionChip(
              icon: Icons.ios_share_outlined,
              label: 'Export report',
              onTap: () => _exportReport(byCategory)),
        ]),
        const SizedBox(height: 20),
        if (byCategory.isNotEmpty) ...[
          KeyedSubtree(
              key: _categoriesKey,
              child: _CategoryDonut(byCategory: byCategory)),
          const SizedBox(height: 20),
        ],
        if (nextPayments.isNotEmpty || overduePayments.isNotEmpty) ...[
          KeyedSubtree(
            key: _scheduleKey,
            child: const Text('Payment schedule',
                style: TextStyle(
                    fontFamily: 'Playfair',
                    fontSize: 20,
                    fontWeight: FontWeight.w400)),
          ),
          const SizedBox(height: 10),
          for (final payment in [...overduePayments, ...nextPayments].take(5))
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.udoBorder)),
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(payment['label'] as String? ?? 'Payment',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(
                          '${payment['vendor_name'] ?? payment['item_name'] ?? 'Budget item'}${payment['due_date'] != null ? ' due ${payment['due_date']}' : ''}',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.udoTextSecondary)),
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(_money(_asDouble(payment['amount'])),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  Text((payment['status'] ?? 'pending').toString(),
                      style: TextStyle(
                          fontSize: 11,
                          color: payment['status'] == 'overdue'
                              ? AppTheme.udoCrimson
                              : AppTheme.udoGreen)),
                ]),
              ]),
            ),
          const SizedBox(height: 8),
        ],
        Row(children: [
          const Expanded(
              child: Text('Budget items',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list,
                size: 20, color: AppTheme.udoTextSecondary),
            onSelected: (v) =>
                setState(() => _statusFilter = v == 'all' ? null : v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'all', child: Text('All statuses')),
              PopupMenuItem(value: 'pending', child: Text('Pending')),
              PopupMenuItem(value: 'on-track', child: Text('On track')),
              PopupMenuItem(value: 'complete', child: Text('Complete')),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort,
                size: 20, color: AppTheme.udoTextSecondary),
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'amount', child: Text('Sort by amount')),
              PopupMenuItem(value: 'category', child: Text('Sort by category')),
            ],
          ),
        ]),
        const SizedBox(height: 4),
        if (categoryEntries.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.udoBorder)),
            child: const Column(children: [
              Text('No budget items yet',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              SizedBox(height: 6),
              Text('Add budget items to see spending broken down by category.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.udoTextSecondary)),
            ]),
          )
        else
          for (final entry in categoryEntries)
            _BudgetRow(
              name: entry.key,
              allocated: entry.value.estimated,
              spent: entry.value.actual,
              status: entry.value.actual == 0
                  ? 'pending'
                  : (entry.value.paid >= entry.value.actual
                      ? 'complete'
                      : 'on-track'),
            ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _BudgetRedesignPage extends StatelessWidget {
  final ScrollController scrollController;
  final String? budgetError;
  final double remaining;
  final double comparisonTotal;
  final double totalActual;
  final double totalEstimated;
  final double totalPaid;
  final double progress;
  final GlobalKey categoriesKey;
  final GlobalKey scheduleKey;
  final List<MapEntry<String, ({double estimated, double actual, double paid})>>
      categoryEntries;
  final List<Map<String, dynamic>> payments;
  final Map<String, dynamic>? largestExpense;
  final VoidCallback onAdd;
  final VoidCallback onCategories;
  final VoidCallback onSchedule;
  final VoidCallback onExport;
  final ValueChanged<String> onStatusFilter;
  final ValueChanged<String> onSort;

  const _BudgetRedesignPage({
    required this.scrollController,
    required this.budgetError,
    required this.remaining,
    required this.comparisonTotal,
    required this.totalActual,
    required this.totalEstimated,
    required this.totalPaid,
    required this.progress,
    required this.categoriesKey,
    required this.scheduleKey,
    required this.categoryEntries,
    required this.payments,
    required this.largestExpense,
    required this.onAdd,
    required this.onCategories,
    required this.onSchedule,
    required this.onExport,
    required this.onStatusFilter,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 124),
          children: [
            if (budgetError != null)
              UdoCard(
                margin: const EdgeInsets.only(bottom: 12),
                color: UdoDesign.rose.withValues(alpha: 0.08),
                border:
                    BorderSide(color: UdoDesign.rose.withValues(alpha: 0.24)),
                child: Text(
                  "Couldn't load your budget. Pull to refresh or try again later.",
                  style: UdoDesign.sans(size: 13, color: UdoDesign.rose),
                ),
              ),
            _BudgetHeroCard(
              remaining: remaining,
              comparisonTotal: comparisonTotal,
              totalActual: totalActual,
              totalEstimated: totalEstimated,
              totalPaid: totalPaid,
              progress: progress,
            ),
            const SizedBox(height: 22),
            UdoSectionHeader(
                title: 'Category Breakdown', onAction: onCategories),
            KeyedSubtree(
              key: categoriesKey,
              child: _BudgetCategoryBreakdown(entries: categoryEntries),
            ),
            const SizedBox(height: 24),
            UdoSectionHeader(
                title: 'Upcoming Payments',
                action: 'Payment schedule',
                onAction: onSchedule),
            KeyedSubtree(
              key: scheduleKey,
              child: _BudgetPaymentList(payments: payments),
            ),
            const SizedBox(height: 24),
            _BudgetInsightCard(largestExpense: largestExpense),
            const SizedBox(height: 24),
            const UdoSectionHeader(title: 'Quick actions'),
            _BudgetQuickActions(
              onAdd: onAdd,
              onCategories: onCategories,
              onSchedule: onSchedule,
              onExport: onExport,
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                  child: Text('Budget items',
                      style:
                          UdoDesign.sans(size: 18, weight: FontWeight.w700))),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list,
                    size: 20, color: UdoDesign.muted),
                onSelected: onStatusFilter,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'all', child: Text('All statuses')),
                  PopupMenuItem(value: 'pending', child: Text('Pending')),
                  PopupMenuItem(value: 'on-track', child: Text('On track')),
                  PopupMenuItem(value: 'complete', child: Text('Complete')),
                ],
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort, size: 20, color: UdoDesign.muted),
                onSelected: onSort,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'amount', child: Text('Sort by amount')),
                  PopupMenuItem(
                      value: 'category', child: Text('Sort by category')),
                ],
              ),
            ]),
            const SizedBox(height: 10),
            if (categoryEntries.isEmpty)
              UdoCard(
                padding: const EdgeInsets.all(22),
                child: Column(children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 34, color: UdoDesign.muted),
                  const SizedBox(height: 12),
                  Text('No budget items yet',
                      style: UdoDesign.sans(size: 15, weight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                    'Add budget items to see spending broken down by category.',
                    textAlign: TextAlign.center,
                    style: UdoDesign.sans(size: 13, color: UdoDesign.muted),
                  ),
                ]),
              )
            else
              for (final entry in categoryEntries)
                _BudgetCategoryItem(
                  name: entry.key,
                  allocated: entry.value.estimated,
                  spent: entry.value.actual,
                  paid: entry.value.paid,
                ),
          ],
        ),
        Positioned(
          right: 18,
          bottom: 18,
          child: SafeArea(
            child: FloatingActionButton.extended(
              heroTag: 'budget-add-item',
              backgroundColor: UdoDesign.budget,
              foregroundColor: Colors.white,
              elevation: 8,
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add budget'),
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetHeroCard extends StatelessWidget {
  final double remaining;
  final double comparisonTotal;
  final double totalActual;
  final double totalEstimated;
  final double totalPaid;
  final double progress;

  const _BudgetHeroCard({
    required this.remaining,
    required this.comparisonTotal,
    required this.totalActual,
    required this.totalEstimated,
    required this.totalPaid,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      color: UdoDesign.budget,
      border: BorderSide.none,
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('BUDGET REMAINING',
            style: UdoDesign.sans(
                size: 12, weight: FontWeight.w700, color: UdoDesign.gold)),
        const SizedBox(height: 8),
        Text(_money(remaining),
            style: UdoDesign.serif(size: 44, color: Colors.white)),
        const SizedBox(height: 4),
        Text('of ${_money(comparisonTotal)} total budget',
            style: UdoDesign.sans(
                size: 14, color: Colors.white.withValues(alpha: 0.68))),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.16),
            valueColor: const AlwaysStoppedAnimation(UdoDesign.gold),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: Text('${_money(totalActual)} spent',
                  style: UdoDesign.sans(
                      size: 12, color: Colors.white.withValues(alpha: 0.68)))),
          const UdoBadge(
              label: 'On Track',
              color: UdoDesign.gold,
              background: Color(0x33C9A46A)),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
              child: _BudgetHeroMetric(
                  label: 'Spent', value: _money(totalActual))),
          Expanded(
              child: _BudgetHeroMetric(
                  label: 'Committed', value: _money(totalEstimated))),
          Expanded(
              child:
                  _BudgetHeroMetric(label: 'Paid', value: _money(totalPaid))),
        ]),
      ]),
    );
  }
}

class _BudgetHeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const _BudgetHeroMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(value,
            style: UdoDesign.sans(
                size: 16, weight: FontWeight.w800, color: Colors.white)),
      ),
      const SizedBox(height: 2),
      Text(label,
          style: UdoDesign.sans(
              size: 11, color: Colors.white.withValues(alpha: 0.62))),
    ]);
  }
}

class _BudgetCategoryBreakdown extends StatelessWidget {
  final List<MapEntry<String, ({double estimated, double actual, double paid})>>
      entries;

  const _BudgetCategoryBreakdown({required this.entries});

  static const _colors = [
    UdoDesign.budget,
    UdoDesign.gold,
    UdoDesign.sage,
    UdoDesign.blue,
    UdoDesign.rose,
    UdoDesign.amber,
    UdoDesign.muted
  ];

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return UdoCard(
          child: Text('No category spending yet.',
              style: UdoDesign.sans(size: 13, color: UdoDesign.muted)));
    }
    return UdoCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
      child: Column(children: [
        for (var i = 0; i < entries.length; i++)
          _BudgetCategoryBar(
              entry: entries[i], color: _colors[i % _colors.length]),
      ]),
    );
  }
}

class _BudgetCategoryBar extends StatelessWidget {
  final MapEntry<String, ({double estimated, double actual, double paid})>
      entry;
  final Color color;

  const _BudgetCategoryBar({required this.entry, required this.color});

  @override
  Widget build(BuildContext context) {
    final total =
        entry.value.estimated > 0 ? entry.value.estimated : entry.value.actual;
    final pct = total > 0 ? (entry.value.actual / total).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(children: [
        Row(children: [
          Expanded(
              child: Text(entry.key,
                  style: UdoDesign.sans(size: 13.5, weight: FontWeight.w700))),
          Text('${_money(entry.value.actual)} / ${_money(total)}',
              style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
        ]),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 7,
            backgroundColor: UdoDesign.stone.withValues(alpha: 0.72),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ]),
    );
  }
}

class _BudgetPaymentList extends StatelessWidget {
  final List<Map<String, dynamic>> payments;

  const _BudgetPaymentList({required this.payments});

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return UdoCard(
          child: Text('No upcoming payments.',
              style: UdoDesign.sans(size: 13, color: UdoDesign.muted)));
    }
    final visible = payments.take(5).toList();
    return UdoCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        for (var i = 0; i < visible.length; i++)
          _BudgetPaymentRow(payment: visible[i], last: i == visible.length - 1),
      ]),
    );
  }
}

class _BudgetPaymentRow extends StatelessWidget {
  final Map<String, dynamic> payment;
  final bool last;

  const _BudgetPaymentRow({required this.payment, required this.last});

  @override
  Widget build(BuildContext context) {
    final overdue = payment['status'] == 'overdue';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: UdoDesign.stone))),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: UdoDesign.rose.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.credit_card,
              color: overdue ? UdoDesign.rose : UdoDesign.gold, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(payment['label'] as String? ?? 'Payment',
              style: UdoDesign.sans(size: 14, weight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(
              '${payment['vendor_name'] ?? payment['item_name'] ?? 'Budget item'}${payment['due_date'] != null ? ' - ${payment['due_date']}' : ''}',
              style: UdoDesign.sans(size: 12, color: UdoDesign.muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ])),
        const SizedBox(width: 10),
        Text(_money(_asDouble(payment['amount'])),
            style: UdoDesign.sans(
                size: 15,
                weight: FontWeight.w800,
                color: overdue ? UdoDesign.rose : UdoDesign.text)),
      ]),
    );
  }
}

class _BudgetInsightCard extends StatelessWidget {
  final Map<String, dynamic>? largestExpense;

  const _BudgetInsightCard({required this.largestExpense});

  @override
  Widget build(BuildContext context) {
    final label = largestExpense == null
        ? 'No largest expense yet'
        : largestExpense!['category'] as String? ?? 'Largest expense';
    final amount = largestExpense == null
        ? null
        : _money(_asDouble(largestExpense!['amount']));
    return UdoCard(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
              color: UdoDesign.budget.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.bar_chart_outlined, color: UdoDesign.budget),
        ),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Largest expense',
              style: UdoDesign.sans(
                  size: 12, weight: FontWeight.w700, color: UdoDesign.muted)),
          const SizedBox(height: 3),
          Text(label, style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
          if (amount != null)
            Text(amount,
                style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
        ])),
      ]),
    );
  }
}

class _BudgetQuickActions extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onCategories;
  final VoidCallback onSchedule;
  final VoidCallback onExport;

  const _BudgetQuickActions({
    required this.onAdd,
    required this.onCategories,
    required this.onSchedule,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      _BudgetActionChip(icon: Icons.add, label: 'Add expense', onTap: onAdd),
      _BudgetActionChip(
          icon: Icons.category_outlined,
          label: 'Categories',
          onTap: onCategories),
      _BudgetActionChip(
          icon: Icons.event_note_outlined,
          label: 'Schedule',
          onTap: onSchedule),
      _BudgetActionChip(
          icon: Icons.ios_share_outlined, label: 'Export', onTap: onExport),
    ]);
  }
}

class _BudgetActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BudgetActionChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: UdoDesign.plan),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: UdoDesign.card,
      side: const BorderSide(color: UdoDesign.stone),
      labelStyle: UdoDesign.sans(
          size: 12.5, weight: FontWeight.w700, color: UdoDesign.text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _BudgetCategoryItem extends StatelessWidget {
  final String name;
  final double allocated;
  final double spent;
  final double paid;

  const _BudgetCategoryItem({
    required this.name,
    required this.allocated,
    required this.spent,
    required this.paid,
  });

  @override
  Widget build(BuildContext context) {
    final total = allocated > 0 ? allocated : spent;
    final pct = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    return UdoCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(name,
                  style: UdoDesign.sans(size: 15, weight: FontWeight.w800))),
          UdoBadge(
              label: paid >= spent && spent > 0
                  ? 'complete'
                  : spent == 0
                      ? 'pending'
                      : 'on track',
              color: paid >= spent && spent > 0
                  ? UdoDesign.sage
                  : UdoDesign.amber),
        ]),
        const SizedBox(height: 8),
        Text('${_money(spent)} spent of ${_money(total)}',
            style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: UdoDesign.stone,
            valueColor: const AlwaysStoppedAnimation(UdoDesign.budget),
          ),
        ),
      ]),
    );
  }
}

String _money(double value) =>
    NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(value);

String _moneyCents(double value) =>
    NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);

class _BudgetStat extends StatelessWidget {
  final String label;
  final double value;
  final int? percentage;
  const _BudgetStat(
      {required this.label, required this.value, required this.percentage});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 4),
          Text(_money(value),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          if (percentage != null)
            Text('$percentage%',
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ]),
      );
}

class _BudgetInfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? detail;
  const _BudgetInfoColumn(
      {required this.icon,
      required this.label,
      required this.value,
      required this.detail});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: AppTheme.udoGreen),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.udoTextSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        if (detail != null)
          Text(detail!,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.udoTextSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
      ]);
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.udoBorder)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 15, color: AppTheme.udoGreen),
            const SizedBox(width: 6),
            Text(label,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ]),
        ),
      );
}

class _CategoryDonut extends StatelessWidget {
  final Map<String, ({double estimated, double actual, double paid})>
      byCategory;
  const _CategoryDonut({required this.byCategory});

  static const _palette = [
    AppTheme.udoGreen,
    AppTheme.udoCrimson,
    Colors.purple,
    Colors.orange,
    Colors.blueGrey,
    Colors.teal
  ];

  @override
  Widget build(BuildContext context) {
    final entries = byCategory.entries.where((e) => e.value.actual > 0).toList()
      ..sort((a, b) => b.value.actual.compareTo(a.value.actual));
    final total = entries.fold<double>(0, (sum, e) => sum + e.value.actual);
    if (total <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.udoBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Spending by category',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(
                  painter: _DonutPainter(
                      entries: entries, total: total, palette: _palette))),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                for (var i = 0; i < entries.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                              color: _palette[i % _palette.length],
                              shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(entries[i].key,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                      Text(
                          '${((entries[i].value.actual / total) * 100).round()}%',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  ),
              ])),
        ]),
      ]),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<MapEntry<String, ({double estimated, double actual, double paid})>>
      entries;
  final double total;
  final List<Color> palette;
  const _DonutPainter(
      {required this.entries, required this.total, required this.palette});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
        size.width - strokeWidth, size.height - strokeWidth);
    var startAngle = -pi / 2;
    for (var i = 0; i < entries.length; i++) {
      final sweep = (entries[i].value.actual / total) * 2 * pi;
      final paint = Paint()
        ..color = palette[i % palette.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.entries != entries || oldDelegate.total != total;
}

/// Shown after `_AddBudgetItemSheet` returns a vendor-linked, amount-bearing
/// result — offers to break the new budget item into payment milestones
/// (deposit/progress/final) without forcing every budget item through it.
Future<void> _maybeOfferPaymentSchedule(
  BuildContext context,
  PlanNotifier notifier,
  Map<String, dynamic>? result,
) async {
  if (result == null) return;
  final vendorId = result['vendorId'] as int?;
  final amount = result['amount'] as double?;
  final itemId = result['itemId'] as int?;
  if (vendorId == null || itemId == null || amount == null || amount <= 0) {
    return;
  }
  final wantsSchedule = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Set a payment schedule?'),
      content: const Text(
          'Break this budget into milestones (e.g. deposit, progress, final payment)?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Skip'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Set schedule'),
        ),
      ],
    ),
  );
  if (wantsSchedule != true || !context.mounted) return;
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _PaymentScheduleSheet(
      notifier: notifier,
      budgetItemId: itemId,
      totalAmount: amount,
    ),
  );
}

class _AddBudgetItemSheet extends StatefulWidget {
  final PlanNotifier notifier;
  final List<Map<String, dynamic>> vendors;
  final int? initialVendorId;
  final String? initialVendorName;
  final String? initialCategory;
  const _AddBudgetItemSheet({
    required this.notifier,
    this.vendors = const [],
    this.initialVendorId,
    this.initialVendorName,
    this.initialCategory,
  });
  @override
  State<_AddBudgetItemSheet> createState() => _AddBudgetItemSheetState();
}

const _budgetCategoryOptions = [
  'Accessibility Services',
  'Accessories',
  'Airport Transfers',
  'Albums & Prints',
  'Alcohol',
  'Alterations',
  'Backdrops',
  'Balloon Decor',
  'Bar Service',
  'Barber',
  'Bridal Party Gifts',
  'Bridal Transportation',
  'Bridesmaid Dresses',
  'Cake',
  'Candles',
  'Catering',
  'Centrepieces',
  'Ceremony Decor',
  'Ceremony Music',
  'Ceremony Programs',
  'Ceremony Setup',
  'Ceremony Venue',
  'Chairs',
  'Chauffeur',
  'Childcare',
  'Cleaning Fees',
  'Cocktail Hour',
  'Coffee Station',
  'Consultation Fees',
  'Contingency',
  'Corkage Fees',
  'Dance Floor',
  'Day-of Coordinator',
  'Dessert Table',
  'DJ',
  'Draping',
  'Drone Coverage',
  'Emergency Purchases',
  'Engagement Shoot',
  'Event Coordinator',
  'Event Permits',
  'Fireworks',
  'Flights',
  'Florals',
  'Flower Girl',
  'Furniture Rental',
  'Generator',
  'Groom Transportation',
  'Groomsmen Attire',
  'Guest Accommodation',
  'Guest Favours',
  'Guest Shuttle',
  'Guest Wi-Fi',
  'Hair',
  'Heating / Cooling',
  'Honeymoon',
  'Hotel',
  'Invitations',
  'Jewellery',
  'Late Night Snacks',
  'Legal Fees',
  'Licences',
  'Lighting',
  'Linen Rental',
  'Live Band',
  'Live Streaming',
  'Lounge Furniture',
  'Makeup',
  'Marriage Licence',
  'MC',
  'Menus',
  'Nails',
  'Non-Alcoholic Drinks',
  'Officiant',
  'Parent Gifts',
  'Parking',
  'Performers',
  'Pet Attendant',
  'Photo Booth',
  'Photographer',
  'Place Cards',
  'Portable Toilets',
  'QR Codes',
  'Reception Decor',
  'Reception Venue',
  'Ring Bearer',
  'Ring Box',
  'RSVP Cards',
  'Save the Dates',
  'Seating Chart',
  'Security',
  'Security Deposit',
  'Service Charges',
  'Shoes',
  'Signage',
  'Site Fees',
  'Skincare',
  'Special Effects',
  'Suit / Tuxedo',
  'Tables',
  'Tableware Rental',
  'Taxes',
  'Tent',
  'Thank You Cards',
  'Tips',
  'Unity Ceremony Items',
  'Valet',
  'Veil',
  'Vendor Tips',
  'Venue Hire',
  'Videographer',
  'Wedding App',
  'Wedding Content Creator',
  'Wedding Dress',
  'Wedding Insurance',
  'Wedding Planner',
  'Wedding Website',
  'Welcome Bags',
  'Welcome Sign',
  'Other',
];

class _AddBudgetItemSheetState extends State<_AddBudgetItemSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? _category;
  int? _vendorId;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _vendorId = widget.initialVendorId;
    if (widget.initialVendorName != null) {
      _nameCtrl.text = '${widget.initialVendorName} budget';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _vendorOptions {
    final options = [...widget.vendors];
    if (widget.initialVendorId != null &&
        !options.any((v) => _asIntId(v['id']) == widget.initialVendorId)) {
      options.insert(0, {
        'id': widget.initialVendorId,
        'name': widget.initialVendorName ?? 'Vendor',
      });
    }
    return options;
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Give the item a name.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final itemId = await widget.notifier.createBudgetItem(
      name: _nameCtrl.text.trim(),
      category: _category,
      vendorId: _vendorId,
      estimatedAmount: double.tryParse(_amountCtrl.text.trim()),
    );
    if (!mounted) return;
    if (itemId == null) {
      setState(() {
        _saving = false;
        _error = "Couldn't save this budget item. Try again.";
      });
      return;
    }
    final amount = double.tryParse(_amountCtrl.text.trim());
    Navigator.of(context).pop({
      'itemId': itemId,
      'vendorId': _vendorId,
      'amount': amount,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.udoBorder,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('New budget item',
                style: TextStyle(
                    fontFamily: 'Playfair',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.udoGreen)),
            const SizedBox(height: 16),
            TextField(
                controller: _nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: 'Name', hintText: 'e.g. Florist final balance')),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _vendorId,
              isExpanded: true,
              menuMaxHeight: 360,
              decoration: const InputDecoration(
                  labelText: 'Vendor (optional)',
                  hintText: 'Link this budget to a vendor'),
              items: _vendorOptions
                  .map((vendor) {
                    final vendorId = _asIntId(vendor['id']);
                    if (vendorId == null) return null;
                    return DropdownMenuItem<int>(
                      value: vendorId,
                      child: Text(vendor['name']?.toString() ?? 'Vendor',
                          overflow: TextOverflow.ellipsis),
                    );
                  })
                  .whereType<DropdownMenuItem<int>>()
                  .toList(),
              onChanged: (value) => setState(() => _vendorId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              menuMaxHeight: 360,
              decoration: const InputDecoration(
                  labelText: 'Category (optional)',
                  hintText: 'Select budget category'),
              items: _budgetCategoryOptions
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _category = value),
            ),
            const SizedBox(height: 12),
            TextField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Estimated amount (optional)',
                    prefixText: '\$')),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(
                      color: AppTheme.udoCrimson, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.udoGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50)),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Add budget item'),
              ),
            ),
          ]),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String name, status;
  final double allocated, spent;
  const _BudgetRow(
      {required this.name,
      required this.allocated,
      required this.spent,
      required this.status});

  Color get _color {
    switch (status) {
      case 'complete':
        return AppTheme.udoGreen;
      case 'on-track':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.udoBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                  status == 'complete'
                      ? 'Complete'
                      : status == 'on-track'
                          ? 'On Track'
                          : 'Pending',
                  style: TextStyle(
                      fontSize: 11,
                      color: _color,
                      fontWeight: FontWeight.w500)),
            ),
          ]),
          const SizedBox(height: 4),
          Text('${_money(spent)} of ${_money(allocated)}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary)),
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

class _VendorsTab extends StatefulWidget {
  final PlanState state;
  final PlanNotifier notifier;
  const _VendorsTab({required this.state, required this.notifier});

  @override
  State<_VendorsTab> createState() => _VendorsTabState();
}

class _VendorsTabState extends State<_VendorsTab> {
  String _statusFilter = 'all';
  String _query = '';

  Future<void> _showAddVendorSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => _AddVendorSheet(notifier: widget.notifier),
    );
    if (result == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vendor added.')),
    );
    final vendorName = (result['name'] as String?) ?? 'this vendor';
    final wantsBudget = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Set a budget?'),
        content: Text('Set a budgeted amount for $vendorName now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Add budget'),
          ),
        ],
      ),
    );
    if (wantsBudget != true || !mounted) return;
    final budgetResult = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddBudgetItemSheet(
        notifier: widget.notifier,
        vendors: widget.state.vendors,
        initialVendorId: _asIntId(result['id']),
        initialVendorName: vendorName,
        initialCategory: result['category'] as String?,
      ),
    );
    if (!mounted) return;
    await _maybeOfferPaymentSchedule(context, widget.notifier, budgetResult);
  }

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

  String _vendorName(Map<String, dynamic> vendor) => (vendor['name'] ??
          vendor['business_name'] ??
          vendor['vendor_name'] ??
          'Vendor')
      .toString();

  String _vendorCategory(Map<String, dynamic> vendor) => (vendor['category'] ??
          vendor['role'] ??
          vendor['service_type'] ??
          'Vendor')
      .toString();

  String _vendorContact(Map<String, dynamic> vendor) =>
      (vendor['contact_person'] ??
              vendor['contact_name'] ??
              vendor['email'] ??
              vendor['phone'] ??
              'Contact details needed')
          .toString();

  bool _isConfirmed(Map<String, dynamic> vendor) {
    final status = (vendor['booking_status'] ?? vendor['status'] ?? '')
        .toString()
        .toLowerCase();
    return status == 'booked' ||
        status == 'confirmed' ||
        status == 'deposit_paid';
  }

  bool _needsQuote(Map<String, dynamic> vendor) {
    final status = (vendor['booking_status'] ?? vendor['quote_status'] ?? '')
        .toString()
        .toLowerCase();
    return status.contains('quote') ||
        status == 'researching' ||
        status == 'negotiating';
  }

  bool _hasContract(Map<String, dynamic> vendor) {
    final contract = vendor['contract_signed'] ?? vendor['has_contract'];
    if (contract is bool) return contract;
    final status = (vendor['contract_status'] ?? '').toString().toLowerCase();
    return status == 'signed' || status == 'complete' || status == 'completed';
  }

  double _amount(Map<String, dynamic> vendor, List<String> keys) {
    for (final key in keys) {
      final raw = vendor[key];
      if (raw is num) return raw.toDouble();
      if (raw is String) {
        final parsed = double.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), ''));
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  List<Map<String, dynamic>> _visibleVendors(
      List<Map<String, dynamic>> vendors) {
    final q = _query.trim().toLowerCase();
    return vendors.where((vendor) {
      final bookingStatus =
          (vendor['booking_status'] ?? vendor['status'] ?? 'researching')
              .toString()
              .toLowerCase();
      final matchesStatus =
          _statusFilter == 'all' || bookingStatus == _statusFilter;
      final matchesSearch = q.isEmpty ||
          _vendorName(vendor).toLowerCase().contains(q) ||
          _vendorCategory(vendor).toLowerCase().contains(q) ||
          _vendorContact(vendor).toLowerCase().contains(q);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state.isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));

    if (state.vendorsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline,
                size: 40, color: AppTheme.udoCrimson),
            const SizedBox(height: 12),
            const Text("Couldn't load your vendors.",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.udoCrimson)),
            const SizedBox(height: 6),
            Text(state.vendorsError!,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.udoTextSecondary),
                textAlign: TextAlign.center),
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
            const Icon(Icons.work_outline,
                size: 40, color: AppTheme.udoTextSecondary),
            const SizedBox(height: 12),
            const Text('No vendors yet',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('Vendors you add will show up here.',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddVendorSheet,
              icon: const Icon(Icons.add),
              label: const Text('Add vendor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: UdoDesign.plan,
                foregroundColor: Colors.white,
              ),
            ),
          ]),
        ),
      );
    }

    final summary = state.vendorSummary;
    final dayOfSheet = ((summary['day_of_contact_sheet'] as List?) ?? const [])
        .cast<Map<String, dynamic>>();
    final visibleVendors = _visibleVendors(vendors);
    final confirmedCount = (summary['confirmed_count'] as num?)?.toInt() ??
        vendors.where(_isConfirmed).length;
    final outstandingQuotes = vendors
        .where((vendor) => !_isConfirmed(vendor) || _needsQuote(vendor))
        .length;
    final missingContracts = (summary['missing_contracts'] as num?)?.toInt() ??
        vendors.where((vendor) => !_hasContract(vendor)).length;
    final unpaidBalance = (summary['unpaid_balance'] as num?)?.toDouble() ??
        vendors.fold<double>(
          0,
          (total, vendor) =>
              total +
              (_amount(vendor,
                      const ['quoted_amount', 'total_amount', 'budget']) -
                  _amount(vendor, const ['paid_amount', 'amount_paid'])),
        );
    final progress =
        vendors.isEmpty ? 0 : ((confirmedCount / vendors.length) * 100).round();
    final attentionVendors = vendors
        .where((vendor) => !_isConfirmed(vendor) || !_hasContract(vendor))
        .take(3)
        .toList();
    final rebuiltVendors = _VendorsRedesignPage(
      vendors: vendors,
      visibleVendors: visibleVendors,
      dayOfSheet: dayOfSheet,
      progress: progress,
      confirmedCount: confirmedCount,
      outstandingQuotes: outstandingQuotes,
      missingContracts: missingContracts,
      unpaidBalance: unpaidBalance.clamp(0, double.infinity).toDouble(),
      attentionVendors: attentionVendors,
      statusFilter: _statusFilter,
      onSearch: (value) {
        setState(() => _query = value);
        widget.notifier.loadVendorsFiltered(
          search: value.trim().isEmpty ? null : value.trim(),
          status: _statusFilter == 'all' ? null : _statusFilter,
        );
      },
      onFilter: (value) {
        setState(() => _statusFilter = value);
        widget.notifier.loadVendorsFiltered(
          search: _query.trim().isEmpty ? null : _query.trim(),
          status: value == 'all' ? null : value,
        );
      },
      statusColorFor: _statusColor,
      vendorName: _vendorName,
      vendorCategory: _vendorCategory,
      vendorContact: _vendorContact,
      contractSigned: _hasContract,
      amountFor: _amount,
      onAddVendor: _showAddVendorSheet,
      onConfirmVisible: () async {
        final ids = visibleVendors
            .where((v) =>
                v['booking_status'] == 'researching' ||
                v['booking_status'] == 'negotiating')
            .map((v) => _asIntId(v['id']))
            .whereType<int>()
            .toList();
        if (ids.isEmpty) return;
        final (count, pendingApproval) = await widget.notifier
            .bulkUpdateVendors(ids, {'booking_status': 'confirmed'});
        if (context.mounted) {
          final message = pendingApproval > 0
              ? 'Confirmed $count vendor${count == 1 ? '' : 's'} · $pendingApproval awaiting Decision-maker approval'
              : 'Confirmed $count vendor${count == 1 ? '' : 's'}';
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
      },
      onConfirmVendor: (id) async {
        final (count, pendingApproval) = await widget.notifier
            .bulkUpdateVendors([id], {'booking_status': 'confirmed'});
        if (context.mounted) {
          final message = pendingApproval > 0
              ? 'Awaiting Decision-maker approval'
              : count > 0
                  ? 'Vendor confirmed'
                  : "Couldn't confirm vendor";
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
      },
    );
    if (MediaQuery.sizeOf(context).width >= 0) {
      return rebuiltVendors;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          Expanded(
              child: _VendorMetricCard(
                  label: 'Confirmed',
                  value:
                      '${summary['confirmed_count'] ?? vendors.where((v) => v['booking_status'] == 'booked' || v['booking_status'] == 'confirmed').length}',
                  color: AppTheme.udoGreen)),
          const SizedBox(width: 10),
          Expanded(
              child: _VendorMetricCard(
                  label: 'Contracts',
                  value: '${summary['missing_contracts'] ?? 0} missing',
                  color: AppTheme.udoCrimson)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _VendorMetricCard(
                  label: 'Balance',
                  value: _money(
                      (((summary['unpaid_balance'] as num?) ?? 0)).toDouble()),
                  color: AppTheme.udoGold)),
          const SizedBox(width: 10),
          Expanded(
              child: _VendorMetricCard(
                  label: 'Day-of',
                  value: '${dayOfSheet.length} contacts',
                  color: AppTheme.udoTeal)),
        ]),
        if (dayOfSheet.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Text('Day-of contact sheet',
              style: TextStyle(
                  fontFamily: 'Playfair',
                  fontSize: 20,
                  fontWeight: FontWeight.w400)),
          const SizedBox(height: 10),
          for (final row in dayOfSheet.take(4))
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.udoBorder)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row['category'] as String? ?? '',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.udoTextSecondary)),
                    const SizedBox(height: 2),
                    Text(row['name'] as String? ?? 'Vendor',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                        (row['contact_person'] ??
                                row['email'] ??
                                row['phone'] ??
                                'Contact details needed')
                            .toString(),
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.udoTextSecondary)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(
                          row['contract_signed'] == true
                              ? Icons.verified_outlined
                              : Icons.description_outlined,
                          size: 14,
                          color: row['contract_signed'] == true
                              ? AppTheme.udoGreen
                              : AppTheme.udoCrimson),
                      const SizedBox(width: 5),
                      Text(
                          row['contract_signed'] == true
                              ? 'Contract signed'
                              : 'Contract needed',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.udoTextSecondary)),
                      const Spacer(),
                      Text('${row['open_task_count'] ?? 0} open tasks',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.udoTextSecondary)),
                    ]),
                  ]),
            ),
        ],
        const SizedBox(height: 18),
        const Text('Vendor records',
            style: TextStyle(
                fontFamily: 'Playfair',
                fontSize: 20,
                fontWeight: FontWeight.w400)),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final entry in const {
              'all': 'All',
              'researching': 'Researching',
              'negotiating': 'Negotiating',
              'confirmed': 'Confirmed'
            }.entries)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label:
                      Text(entry.value, style: const TextStyle(fontSize: 12)),
                  selected: _statusFilter == entry.key,
                  onSelected: (_) {
                    setState(() => _statusFilter = entry.key);
                    widget.notifier.loadVendorsFiltered(status: entry.key);
                  },
                  selectedColor: AppTheme.udoGreen,
                  labelStyle: TextStyle(
                      color: _statusFilter == entry.key
                          ? Colors.white
                          : AppTheme.udoTextPrimary),
                  side: BorderSide(
                      color: _statusFilter == entry.key
                          ? AppTheme.udoGreen
                          : AppTheme.udoBorder),
                  checkmarkColor: Colors.white,
                ),
              ),
          ]),
        ),
        const SizedBox(height: 10),
        if (vendors.any((v) =>
            v['booking_status'] == 'researching' ||
            v['booking_status'] == 'negotiating'))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton.icon(
              onPressed: () async {
                final ids = vendors
                    .where((v) =>
                        v['booking_status'] == 'researching' ||
                        v['booking_status'] == 'negotiating')
                    .map((v) => _asIntId(v['id']))
                    .whereType<int>()
                    .toList();
                if (ids.isEmpty) return;
                final (count, pendingApproval) = await widget.notifier
                    .bulkUpdateVendors(ids, {'booking_status': 'confirmed'});
                if (context.mounted) {
                  final message = pendingApproval > 0
                      ? 'Confirmed $count vendor${count == 1 ? '' : 's'} · $pendingApproval awaiting Decision-maker approval'
                      : 'Confirmed $count vendor${count == 1 ? '' : 's'}';
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
                }
              },
              icon: const Icon(Icons.verified_outlined, size: 18),
              label: const Text('Confirm visible researching vendors'),
            ),
          ),
        for (final v in vendors)
          Builder(builder: (_) {
            final status = v['booking_status'] as String? ?? 'researching';
            final statusColor = _statusColor(status);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.udoBorder)),
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(v['category'] as String? ?? '',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      if (v['name'] != null)
                        Text(v['name'] as String,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.udoTextSecondary)),
                      const SizedBox(height: 4),
                      Text(
                          '${v['contact_logs_count'] ?? 0} notes • ${v['tasks_count'] ?? 0} tasks',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.udoTextSecondary)),
                    ])),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(status[0].toUpperCase() + status.substring(1),
                      style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w500)),
                ),
              ]),
            );
          }),
      ],
    );
  }
}

class _VendorsRedesignPage extends StatelessWidget {
  final List<Map<String, dynamic>> vendors;
  final List<Map<String, dynamic>> visibleVendors;
  final List<Map<String, dynamic>> dayOfSheet;
  final int progress;
  final int confirmedCount;
  final int outstandingQuotes;
  final int missingContracts;
  final double unpaidBalance;
  final List<Map<String, dynamic>> attentionVendors;
  final String statusFilter;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onFilter;
  final Color Function(String status) statusColorFor;
  final String Function(Map<String, dynamic> vendor) vendorName;
  final String Function(Map<String, dynamic> vendor) vendorCategory;
  final String Function(Map<String, dynamic> vendor) vendorContact;
  final bool Function(Map<String, dynamic> vendor) contractSigned;
  final double Function(Map<String, dynamic> vendor, List<String> keys)
      amountFor;
  final Future<void> Function() onAddVendor;
  final Future<void> Function() onConfirmVisible;
  final Future<void> Function(int vendorId) onConfirmVendor;

  const _VendorsRedesignPage({
    required this.vendors,
    required this.visibleVendors,
    required this.dayOfSheet,
    required this.progress,
    required this.confirmedCount,
    required this.outstandingQuotes,
    required this.missingContracts,
    required this.unpaidBalance,
    required this.attentionVendors,
    required this.statusFilter,
    required this.onSearch,
    required this.onFilter,
    required this.statusColorFor,
    required this.vendorName,
    required this.vendorCategory,
    required this.vendorContact,
    required this.contractSigned,
    required this.amountFor,
    required this.onAddVendor,
    required this.onConfirmVisible,
    required this.onConfirmVendor,
  });

  @override
  Widget build(BuildContext context) {
    final canConfirm = visibleVendors.any((vendor) =>
        vendor['booking_status'] == 'researching' ||
        vendor['booking_status'] == 'negotiating');
    final paymentsDue = vendors
        .where((vendor) =>
            amountFor(vendor, const ['balance_due', 'unpaid_amount']) > 0 ||
            vendor['payment_status'] == 'due')
        .length;
    final priorityVendor =
        attentionVendors.isNotEmpty ? attentionVendors.first : vendors.first;
    final activeVendors = visibleVendors.take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 128),
      children: [
        _VendorOverviewDashboard(
          progress: progress,
          confirmed: confirmedCount,
          total: vendors.length,
          outstandingQuotes: outstandingQuotes,
          missingContracts: missingContracts,
          unpaidBalance: unpaidBalance,
          paymentsDue: paymentsDue,
          dayOfContacts: dayOfSheet.length,
          onViewDetails: () => onFilter('all'),
        ),
        const SizedBox(height: 12),
        _PriorityVendorCard(
          vendor: priorityVendor,
          name: vendorName(priorityVendor),
          category: vendorCategory(priorityVendor),
          contact: vendorContact(priorityVendor),
          statusColor: statusColorFor(
            (priorityVendor['booking_status'] ??
                    priorityVendor['status'] ??
                    'researching')
                .toString(),
          ),
          contractSigned: contractSigned(priorityVendor),
          balanceDue:
              amountFor(priorityVendor, const ['balance_due', 'unpaid_amount']),
          onPrimaryAction: (priorityVendor['booking_status'] == 'researching' ||
                  priorityVendor['booking_status'] == 'negotiating')
              ? () async {
                  final vendorId = _asIntId(priorityVendor['id']);
                  if (vendorId == null) return;
                  await onConfirmVendor(vendorId);
                }
              : onAddVendor,
        ),
        const SizedBox(height: 14),
        UdoSectionHeader(
          title: 'Active vendors',
          action: 'See all (${visibleVendors.length})',
          onAction: () => onFilter('all'),
        ),
        if (activeVendors.isEmpty)
          UdoCard(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: const [
                Icon(Icons.work_outline_rounded,
                    size: 34, color: UdoDesign.muted),
                SizedBox(height: 10),
                Text('No vendors match this view',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Adjust the search or filter to see vendor records.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: UdoDesign.muted)),
              ]),
            ),
          )
        else
          for (final vendor in activeVendors)
            _VendorScheduleCard(
              name: vendorName(vendor),
              category: vendorCategory(vendor),
              contact: vendorContact(vendor),
              status: (vendor['booking_status'] ??
                      vendor['status'] ??
                      'researching')
                  .toString(),
              statusColor: statusColorFor(
                (vendor['booking_status'] ?? vendor['status'] ?? 'researching')
                    .toString(),
              ),
              contractSigned: contractSigned(vendor),
              balanceDue:
                  amountFor(vendor, const ['balance_due', 'unpaid_amount']),
              openTasks: (vendor['tasks_count'] as num?)?.toInt() ?? 0,
            ),
        const SizedBox(height: 12),
        _VendorSmartInsightCard(
          progress: progress,
          missingContracts: missingContracts,
          outstandingQuotes: outstandingQuotes,
          onViewDetails: () => onFilter('researching'),
        ),
        const SizedBox(height: 12),
        _VendorActionGrid(
          onAddVendor: onAddVendor,
          onConfirmVisible: onConfirmVisible,
          canConfirm: canConfirm,
        ),
        if (dayOfSheet.isNotEmpty) ...[
          const SizedBox(height: 18),
          UdoSectionHeader(
            title: 'Day-of contact sheet',
            subtitle:
                '${dayOfSheet.length} vendor contacts ready for execution',
          ),
          _VendorContactSheet(rows: dayOfSheet),
        ],
        const SizedBox(height: 18),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text('Search and filters',
              style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
          children: [
            TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Search vendors...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: UdoDesign.card,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: UdoDesign.stone),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: UdoDesign.stone),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: UdoDesign.plan, width: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                for (final entry in const {
                  'all': 'All',
                  'researching': 'Researching',
                  'negotiating': 'Negotiating',
                  'confirmed': 'Confirmed',
                  'booked': 'Booked',
                }.entries)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.value),
                      selected: statusFilter == entry.key,
                      onSelected: (_) => onFilter(entry.key),
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 8),
          ],
        ),
        for (final vendor in visibleVendors.skip(5))
          _VendorRecordCard(
            vendor: vendor,
            statusColor: statusColorFor(
              (vendor['booking_status'] ?? vendor['status'] ?? 'researching')
                  .toString(),
            ),
            name: vendorName(vendor),
            category: vendorCategory(vendor),
            contact: vendorContact(vendor),
            contractSigned: contractSigned(vendor),
            paidAmount: amountFor(vendor, const ['paid_amount', 'amount_paid']),
            totalAmount: amountFor(
                vendor, const ['quoted_amount', 'total_amount', 'budget']),
          ),
      ],
    );
  }
}

class _VendorOverviewDashboard extends StatelessWidget {
  final int progress;
  final int confirmed;
  final int total;
  final int outstandingQuotes;
  final int missingContracts;
  final int paymentsDue;
  final int dayOfContacts;
  final double unpaidBalance;
  final VoidCallback onViewDetails;

  const _VendorOverviewDashboard({
    required this.progress,
    required this.confirmed,
    required this.total,
    required this.outstandingQuotes,
    required this.missingContracts,
    required this.paymentsDue,
    required this.dayOfContacts,
    required this.unpaidBalance,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = max(0, total - confirmed);
    return UdoCard(
      color: const Color(0xFF214638),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('VENDOR OVERVIEW',
                style: UdoDesign.sans(
                    size: 9.5,
                    weight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.76))),
          ),
          InkWell(
            onTap: onViewDetails,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('View details',
                    style: UdoDesign.sans(
                        size: 10, color: Colors.white.withValues(alpha: 0.82))),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    size: 16, color: Colors.white.withValues(alpha: 0.82)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          UdoRingProgress(
            value: progress / 100,
            size: 82,
            color: const Color(0xFFD7AA62),
            center: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$progress%',
                  style: UdoDesign.sans(
                      size: 20, weight: FontWeight.w900, color: Colors.white)),
              Text('Ready',
                  style: UdoDesign.sans(
                      size: 10, color: Colors.white.withValues(alpha: 0.75))),
            ]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(children: [
              Expanded(
                  child: _VendorOverviewMetric(
                      label: 'Confirmed',
                      value: '$confirmed',
                      detail: 'of $total vendors')),
              Expanded(
                  child: _VendorOverviewMetric(
                      label: 'Remaining',
                      value: '$remaining',
                      detail: 'need action')),
              Expanded(
                  child: _VendorOverviewMetric(
                      label: 'Balance',
                      value: _money(unpaidBalance),
                      detail: '$paymentsDue due')),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        Divider(color: Colors.white.withValues(alpha: 0.16), height: 1),
        const SizedBox(height: 12),
        Row(children: [
          _VendorMiniMetric(
              icon: Icons.request_quote_outlined,
              value: '$outstandingQuotes',
              label: 'Quotes',
              detail: 'to review',
              color: const Color(0xFFD7AA62)),
          _VendorMiniMetric(
              icon: Icons.description_outlined,
              value: '$missingContracts',
              label: 'Contracts',
              detail: 'missing',
              color: UdoDesign.rose),
          _VendorMiniMetric(
              icon: Icons.contacts_outlined,
              value: '$dayOfContacts',
              label: 'Day-of',
              detail: 'contacts',
              color: UdoDesign.blue),
          _VendorMiniMetric(
              icon: Icons.payments_outlined,
              value: '$paymentsDue',
              label: 'Payments',
              detail: _money(unpaidBalance),
              color: UdoDesign.sage),
        ]),
      ]),
    );
  }
}

class _VendorOverviewMetric extends StatelessWidget {
  final String label;
  final String value;
  final String detail;

  const _VendorOverviewMetric({
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(
                  size: 9.5, color: Colors.white.withValues(alpha: 0.70))),
          const SizedBox(height: 4),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(
                  size: 15, weight: FontWeight.w900, color: Colors.white)),
          Text(detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(
                  size: 9.5, color: Colors.white.withValues(alpha: 0.58))),
        ]),
      );
}

class _VendorMiniMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String detail;
  final Color color;

  const _VendorMiniMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(height: 6),
          Text(value,
              style: UdoDesign.sans(
                  size: 15, weight: FontWeight.w900, color: Colors.white)),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(
                  size: 9.5, color: Colors.white.withValues(alpha: 0.68))),
          Text(detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(size: 9.5, color: color)),
        ]),
      );
}

class _PriorityVendorCard extends StatelessWidget {
  final Map<String, dynamic> vendor;
  final String name;
  final String category;
  final String contact;
  final Color statusColor;
  final bool contractSigned;
  final double balanceDue;
  final Future<void> Function() onPrimaryAction;

  const _PriorityVendorCard({
    required this.vendor,
    required this.name,
    required this.category,
    required this.contact,
    required this.statusColor,
    required this.contractSigned,
    required this.balanceDue,
    required this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        (vendor['booking_status'] ?? vendor['status'] ?? 'researching')
            .toString();
    return UdoCard(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.13),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.storefront_outlined, color: statusColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UdoDesign.sans(size: 14, weight: FontWeight.w900)),
              ),
              UdoBadge(
                  label: _humanizeStatus(status) ?? 'Researching',
                  color: statusColor),
            ]),
            const SizedBox(height: 3),
            Text(category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UdoDesign.sans(size: 11, color: UdoDesign.muted)),
            const SizedBox(height: 6),
            Wrap(spacing: 10, runSpacing: 4, children: [
              _VendorTinyInfo(icon: Icons.person_outline, text: contact),
              _VendorTinyInfo(
                  icon: Icons.description_outlined,
                  text: contractSigned ? 'Contract signed' : 'Contract needed'),
              _VendorTinyInfo(
                  icon: Icons.payments_outlined,
                  text: balanceDue > 0 ? _money(balanceDue) : 'No balance'),
            ]),
          ]),
        ),
        const SizedBox(width: 10),
        FilledButton(
          onPressed: onPrimaryAction,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF214638),
            foregroundColor: Colors.white,
            visualDensity: VisualDensity.compact,
          ),
          child: const Text('Action'),
        ),
      ]),
    );
  }
}

class _VendorScheduleCard extends StatelessWidget {
  final String name;
  final String category;
  final String contact;
  final String status;
  final Color statusColor;
  final bool contractSigned;
  final double balanceDue;
  final int openTasks;

  const _VendorScheduleCard({
    required this.name,
    required this.category,
    required this.contact,
    required this.status,
    required this.statusColor,
    required this.contractSigned,
    required this.balanceDue,
    required this.openTasks,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.storefront_outlined, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(size: 14.5, weight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
              const SizedBox(height: 6),
              Wrap(spacing: 10, runSpacing: 4, children: [
                _VendorTinyInfo(icon: Icons.person_outline, text: contact),
                _VendorTinyInfo(
                    icon: Icons.description_outlined,
                    text:
                        contractSigned ? 'Contract signed' : 'Contract needed'),
                _VendorTinyInfo(
                    icon: Icons.task_alt_outlined, text: '$openTasks tasks'),
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(balanceDue > 0 ? _money(balanceDue) : 'Ready',
                style: UdoDesign.sans(size: 13, weight: FontWeight.w800)),
            const SizedBox(height: 4),
            UdoBadge(
                label: _humanizeStatus(status) ?? 'Researching',
                color: statusColor),
          ]),
        ]),
      );
}

class _VendorTinyInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _VendorTinyInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: UdoDesign.muted),
        const SizedBox(width: 4),
        Text(text,
            style: UdoDesign.sans(size: 10.5, color: UdoDesign.sub),
            overflow: TextOverflow.ellipsis),
      ]);
}

class _VendorSmartInsightCard extends StatelessWidget {
  final int progress;
  final int missingContracts;
  final int outstandingQuotes;
  final VoidCallback onViewDetails;

  const _VendorSmartInsightCard({
    required this.progress,
    required this.missingContracts,
    required this.outstandingQuotes,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        color: const Color(0xFFFFFBF1),
        border: const BorderSide(color: Color(0xFFE7D4A8)),
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFD7AA62),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text('Smart insight',
                      style: UdoDesign.sans(size: 12, weight: FontWeight.w900)),
                ),
                InkWell(
                  onTap: onViewDetails,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE7D4A8)),
                    ),
                    child: Text('View details',
                        style:
                            UdoDesign.sans(size: 11, weight: FontWeight.w800)),
                  ),
                ),
              ]),
              const SizedBox(height: 4),
              Text(
                progress >= 80
                    ? 'Vendor operations are close to day-of ready.'
                    : '$missingContracts contracts and $outstandingQuotes quotes still need attention before execution.',
                style: UdoDesign.sans(
                    size: 12, color: UdoDesign.sub, height: 1.35),
              ),
            ]),
          ),
        ]),
      );
}

class _VendorActionGrid extends StatelessWidget {
  final Future<void> Function() onAddVendor;
  final Future<void> Function() onConfirmVisible;
  final bool canConfirm;

  const _VendorActionGrid({
    required this.onAddVendor,
    required this.onConfirmVisible,
    required this.canConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.add_business_outlined, 'Add\nvendor', onAddVendor),
      (
        Icons.verified_outlined,
        'Confirm\nvisible',
        canConfirm ? onConfirmVisible : onAddVendor
      ),
      (Icons.description_outlined, 'Track\ncontract', onAddVendor),
      (Icons.payments_outlined, 'Record\npayment', onAddVendor),
      (Icons.more_horiz, 'More', onAddVendor),
    ];
    return UdoCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(children: [
        for (final action in actions)
          Expanded(
            child: InkWell(
              onTap: action.$3,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF214638).withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(action.$1,
                        size: 18, color: const Color(0xFF214638)),
                  ),
                  const SizedBox(height: 5),
                  Text(action.$2,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: UdoDesign.sans(
                          size: 9.5,
                          color: UdoDesign.sub,
                          weight: FontWeight.w700,
                          height: 1.05)),
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}

const _vendorCategoryOptions = [
  'Photographer',
  'Videographer',
  'Drone Photography',
  'Photo Booth',
  'Content Creator (Wedding BTS)',
  'Livestream Services',
  'Ceremony Venue',
  'Reception Venue',
  'All-in-One Venue',
  'Private Estate',
  'Marquee / Tent Rental',
  'Caterer',
  'Bartending Service',
  'Cake Designer',
  'Dessert Bar',
  'Coffee Cart',
  'Ice Cream / Gelato Cart',
  'Mobile Bar',
  'Late-Night Food',
  'Florist',
  'Wedding Decorator',
  'Event Stylist',
  'Balloon Stylist',
  'Lighting',
  'Furniture Rental',
  'Linen Rental',
  'Tableware Rental',
  'Dance Floor Rental',
  'Backdrops & Arches',
  'Signage',
  'Draping',
  'DJ',
  'Live Band',
  'Solo Musician',
  'String Quartet',
  'Singer',
  'Master of Ceremonies (MC)',
  'Dancers / Performers',
  'Fireworks / Special Effects',
  'Bridal Hair Stylist',
  'Makeup Artist',
  "Groom's Barber",
  'Bridal Boutique',
  'Suit / Tuxedo Supplier',
  'Dress Alterations',
  'Accessories',
  'Jewellery',
  'Officiant',
  'Marriage Licence Services',
  'Wedding Planner',
  'Wedding Coordinator',
  'Day-of Coordinator',
  'Celebrant',
  'Ceremony Musicians',
  'Bridal Transportation',
  'Guest Transportation',
  'Luxury Car Hire',
  'Shuttle Service',
  'Chauffeur',
  'Horse & Carriage',
  'Boat / Yacht Charter',
  'Hotel',
  'Resort',
  'Travel Agent',
  'Honeymoon Planner',
  'Vacation Rental',
  'Invitations',
  'Calligrapher',
  'Wedding Website Designer',
  'Favors & Gifts',
  'Guest Book Supplier',
  'Registry Partner',
  'Tent Rental',
  'Generator Rental',
  'Portable Restrooms',
  'Climate Control',
  'Bridal Party Attire',
  'Groomsmen Attire',
  'Flower Girl Attire',
  'Ring Bearer Attire',
  'Dance Lessons',
  'Pet Attendant',
  'Childcare',
  'Security',
  'Valet Parking',
  'Cleaning Crew',
  'Insurance Provider',
  'Wedding App Integration',
  'Guest Wi-Fi',
  'QR Code Printing',
  'RSVP Management',
  'Live Streaming',
  'Other',
];

class _AddVendorSheet extends StatefulWidget {
  final PlanNotifier notifier;
  const _AddVendorSheet({required this.notifier});

  @override
  State<_AddVendorSheet> createState() => _AddVendorSheetState();
}

class _AddVendorSheetState extends State<_AddVendorSheet> {
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  String? _category;
  String _status = 'researching';
  String _priority = 'medium';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _email.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Add the vendor name.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final vendorId = await widget.notifier.createVendor(
      name: _name.text.trim(),
      category: _category,
      contactPerson: _contact.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      bookingStatus: _status,
      priority: _priority,
      notes: _notes.text.trim(),
    );
    if (!mounted) return;
    if (vendorId != null) {
      Navigator.of(context).pop({
        'id': vendorId,
        'name': _name.text.trim(),
        'category': _category,
      });
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save this vendor. Check the details and try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: UdoDesign.stone,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Add vendor',
                style: UdoDesign.serif(size: 24, color: UdoDesign.text)),
            const SizedBox(height: 16),
            _VendorTextField(_name, 'Vendor name', 'e.g. Marigold Florals'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              menuMaxHeight: 360,
              decoration: _vendorInputDecoration('Category'),
              hint: const Text('Select vendor category'),
              items: _vendorCategoryOptions
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _category = value),
            ),
            const SizedBox(height: 12),
            _VendorTextField(_contact, 'Contact person', 'e.g. Nadia Mensah'),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _VendorTextField(_email, 'Email', 'name@example.com',
                      keyboardType: TextInputType.emailAddress)),
              const SizedBox(width: 10),
              Expanded(
                  child: _VendorTextField(_phone, 'Phone', '+233...',
                      keyboardType: TextInputType.phone)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: _vendorInputDecoration('Status'),
                  items: const [
                    DropdownMenuItem(
                        value: 'researching', child: Text('Researching')),
                    DropdownMenuItem(
                        value: 'negotiating', child: Text('Negotiating')),
                    DropdownMenuItem(value: 'booked', child: Text('Booked')),
                    DropdownMenuItem(
                        value: 'confirmed', child: Text('Confirmed')),
                  ],
                  onChanged: (value) =>
                      setState(() => _status = value ?? _status),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: _vendorInputDecoration('Priority'),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (value) =>
                      setState(() => _priority = value ?? _priority),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            _VendorTextField(_notes, 'Notes', 'Contract notes, preferences...',
                maxLines: 3),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: UdoDesign.sans(size: 12, color: UdoDesign.rose)),
            ],
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add_business_outlined),
              label: Text(_saving ? 'Saving vendor' : 'Save vendor'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: UdoDesign.plan,
                foregroundColor: Colors.white,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _VendorTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

  const _VendorTextField(this.controller, this.label, this.hint,
      {this.keyboardType, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _vendorInputDecoration(label).copyWith(hintText: hint),
      );
}

InputDecoration _vendorInputDecoration(String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: UdoDesign.bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: UdoDesign.stone),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: UdoDesign.stone),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: UdoDesign.plan, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    );

// ignore: unused_element
class _VendorHeroCard extends StatelessWidget {
  final int progress;
  final int confirmed;
  final int total;
  final int outstandingQuotes;
  final int missingContracts;
  final double unpaidBalance;

  const _VendorHeroCard({
    required this.progress,
    required this.confirmed,
    required this.total,
    required this.outstandingQuotes,
    required this.missingContracts,
    required this.unpaidBalance,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      color: UdoDesign.plan,
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          UdoRingProgress(
            value: progress / 100,
            size: 62,
            color: Colors.white,
            center: Text('$progress%',
                style: UdoDesign.sans(
                    size: 13, weight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Vendor Progress',
                  style: UdoDesign.sans(
                      size: 17, weight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 4),
              Text('$confirmed of $total confirmed',
                  style: UdoDesign.sans(
                      size: 13, color: Colors.white.withValues(alpha: 0.74))),
              const SizedBox(height: 8),
              Text('Who is delivering this wedding?',
                  style: UdoDesign.serif(
                      size: 21, color: Colors.white, weight: FontWeight.w600)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _VendorHeroMetric(label: 'Quotes', value: '$outstandingQuotes'),
          _VendorHeroMetric(label: 'Contracts', value: '$missingContracts'),
          _VendorHeroMetric(label: 'Balance', value: _money(unpaidBalance)),
        ]),
      ]),
    );
  }
}

class _VendorHeroMetric extends StatelessWidget {
  final String label;
  final String value;
  const _VendorHeroMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(
                  size: 15, weight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label,
              style: UdoDesign.sans(
                  size: 10, color: Colors.white.withValues(alpha: 0.68))),
        ]),
      ),
    );
  }
}

// ignore: unused_element
class _VendorHealthCard extends StatelessWidget {
  final int confirmed;
  final int outstandingQuotes;
  final int missingContracts;
  final int paymentsDue;

  const _VendorHealthCard({
    required this.confirmed,
    required this.outstandingQuotes,
    required this.missingContracts,
    required this.paymentsDue,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      (
        'Confirmed',
        confirmed.toString(),
        Icons.verified_outlined,
        UdoDesign.sage
      ),
      (
        'Quotes',
        outstandingQuotes.toString(),
        Icons.request_quote_outlined,
        UdoDesign.amber
      ),
      (
        'Contracts',
        missingContracts.toString(),
        Icons.description_outlined,
        UdoDesign.rose
      ),
      (
        'Payments',
        paymentsDue.toString(),
        Icons.payments_outlined,
        UdoDesign.plan
      ),
    ];

    return UdoCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('Vendor Health',
                style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
          ),
          const UdoBadge(label: 'Smart', color: UdoDesign.plan),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          for (final metric in metrics)
            Expanded(
              child: Column(children: [
                Icon(metric.$3, size: 18, color: metric.$4),
                const SizedBox(height: 5),
                Text(metric.$2,
                    style: UdoDesign.sans(
                        size: 16, weight: FontWeight.w800, color: metric.$4)),
                const SizedBox(height: 2),
                Text(metric.$1,
                    textAlign: TextAlign.center,
                    style: UdoDesign.sans(size: 10, color: UdoDesign.muted)),
              ]),
            ),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1, color: UdoDesign.stone),
        const SizedBox(height: 10),
        Text('One vendor issue can affect timeline, documents, and payments.',
            style:
                UdoDesign.sans(size: 12.5, color: UdoDesign.sub, height: 1.4)),
      ]),
    );
  }
}

// ignore: unused_element
class _VendorAttentionPanel extends StatelessWidget {
  final List<Map<String, dynamic>> vendors;
  final String Function(Map<String, dynamic> vendor) vendorName;
  final String Function(Map<String, dynamic> vendor) vendorCategory;
  final bool Function(Map<String, dynamic> vendor) contractSigned;

  const _VendorAttentionPanel({
    required this.vendors,
    required this.vendorName,
    required this.vendorCategory,
    required this.contractSigned,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text('Smart recommendations',
                  style: UdoDesign.sans(size: 15, weight: FontWeight.w800))),
          const UdoBadge(label: 'AI', color: UdoDesign.plan),
        ]),
        const SizedBox(height: 8),
        for (final vendor in vendors)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: UdoDesign.plan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    size: 18, color: UdoDesign.plan),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendorName(vendor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: UdoDesign.sans(
                              size: 13.5, weight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                          contractSigned(vendor)
                              ? '${vendorCategory(vendor)} needs booking follow-up'
                              : '${vendorCategory(vendor)} contract needs attention',
                          style:
                              UdoDesign.sans(size: 12, color: UdoDesign.muted)),
                    ]),
              ),
              Text('Review',
                  style: UdoDesign.sans(
                      size: 12,
                      weight: FontWeight.w700,
                      color: UdoDesign.plan)),
            ]),
          ),
      ]),
    );
  }
}

class _VendorContactSheet extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  const _VendorContactSheet({required this.rows});

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        for (var index = 0; index < rows.length; index++) ...[
          _VendorContactRow(row: rows[index]),
          if (index < rows.length - 1)
            const Divider(height: 1, color: UdoDesign.stone),
        ],
      ]),
    );
  }
}

class _VendorContactRow extends StatelessWidget {
  final Map<String, dynamic> row;
  const _VendorContactRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final contractSigned = row['contract_signed'] == true;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: (contractSigned ? UdoDesign.sage : UdoDesign.rose)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            contractSigned
                ? Icons.verified_outlined
                : Icons.description_outlined,
            color: contractSigned ? UdoDesign.sage : UdoDesign.rose,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text((row['name'] ?? 'Vendor').toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UdoDesign.sans(size: 14, weight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(
              (row['contact_person'] ??
                      row['email'] ??
                      row['phone'] ??
                      'Contact details needed')
                  .toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(size: 12, color: UdoDesign.muted),
            ),
          ]),
        ),
        Text('${row['open_task_count'] ?? 0} tasks',
            style: UdoDesign.sans(size: 11, color: UdoDesign.muted)),
      ]),
    );
  }
}

class _VendorRecordCard extends StatelessWidget {
  final Map<String, dynamic> vendor;
  final Color statusColor;
  final String name;
  final String category;
  final String contact;
  final bool contractSigned;
  final double paidAmount;
  final double totalAmount;

  const _VendorRecordCard({
    required this.vendor,
    required this.statusColor,
    required this.name,
    required this.category,
    required this.contact,
    required this.contractSigned,
    required this.paidAmount,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        (vendor['booking_status'] ?? vendor['status'] ?? 'researching')
            .toString();
    final paymentProgress =
        totalAmount <= 0 ? 0.0 : (paidAmount / totalAmount).clamp(0.0, 1.0);

    return UdoCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child:
                Icon(Icons.storefront_outlined, size: 22, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
                ),
                UdoBadge(
                  label: status.isEmpty
                      ? 'Researching'
                      : status[0].toUpperCase() + status.substring(1),
                  color: statusColor,
                ),
              ]),
              const SizedBox(height: 3),
              Text('$category · $contact',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _VendorSignal(
            icon: contractSigned
                ? Icons.description_outlined
                : Icons.description_outlined,
            label: contractSigned ? 'Contract signed' : 'Contract needed',
            color: contractSigned ? UdoDesign.sage : UdoDesign.rose,
          ),
          const SizedBox(width: 8),
          _VendorSignal(
            icon: Icons.timeline_outlined,
            label: '${vendor['tasks_count'] ?? 0} tasks',
            color: UdoDesign.blue,
          ),
          const SizedBox(width: 8),
          _VendorSignal(
            icon: Icons.chat_bubble_outline_rounded,
            label: '${vendor['contact_logs_count'] ?? 0} notes',
            color: UdoDesign.amber,
          ),
        ]),
        if (totalAmount > 0) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: paymentProgress,
                  minHeight: 7,
                  backgroundColor: UdoDesign.stone,
                  color: UdoDesign.plan,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('${(paymentProgress * 100).round()}% paid',
                style: UdoDesign.sans(size: 11, color: UdoDesign.muted)),
          ]),
        ],
      ]),
    );
  }
}

class _VendorSignal extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _VendorSignal({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UdoDesign.sans(
                    size: 10.5, weight: FontWeight.w700, color: color)),
          ),
        ]),
      ),
    );
  }
}

class _VendorMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _VendorMetricCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.udoBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary)),
        ]),
      );
}

// ── REMINDERS TAB ──────────────────────────────────────────────────────────────

class _RemindersTab extends ConsumerStatefulWidget {
  const _RemindersTab();
  @override
  ConsumerState<_RemindersTab> createState() => _RemindersTabState();
}

class _RemindersTabState extends ConsumerState<_RemindersTab> {
  @override
  void initState() {
    super.initState();
    // Best-effort: pull in any newly-due auto reminders (unpaid budget
    // schedules, expiring policies) whenever this tab is opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(remindersProvider.notifier).refreshAutoReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(remindersProvider);
    final notifier = ref.read(remindersProvider.notifier);

    if (state.isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));
    if (state.error != null && state.reminders.isEmpty) {
      return Center(
          child: Text("We couldn't load your reminders. Please try again.",
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.udoTextSecondary)));
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pending =
        state.reminders.where((r) => r['status'] != 'completed').toList();
    final completed =
        state.reminders.where((r) => r['status'] == 'completed').toList();

    DateTime? dueOf(Map<String, dynamic> r) {
      final raw = r['due_date'] as String?;
      return raw == null ? null : DateTime.tryParse(raw);
    }

    final groups = <String, List<Map<String, dynamic>>>{
      'Overdue': [],
      'Today': [],
      'Tomorrow': [],
      'This week': [],
      'Later': [],
      'No due date': [],
    };
    for (final r in pending) {
      final due = dueOf(r);
      if (due == null) {
        groups['No due date']!.add(r);
      } else {
        final dueDay = DateTime(due.year, due.month, due.day);
        final diff = dueDay.difference(today).inDays;
        if (diff < 0) {
          groups['Overdue']!.add(r);
        } else if (diff == 0) {
          groups['Today']!.add(r);
        } else if (diff == 1) {
          groups['Tomorrow']!.add(r);
        } else if (diff <= 7) {
          groups['This week']!.add(r);
        } else {
          groups['Later']!.add(r);
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          onPressed: () => _showAddReminderSheet(context, notifier),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add reminder'),
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: AppTheme.udoGreen,
              foregroundColor: Colors.white),
        ),
        const SizedBox(height: 16),
        if (pending.isEmpty && completed.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.udoBorder)),
            child: const Text(
                'No reminders yet. Add one, or reminders will be created automatically from upcoming payment due dates.',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
          ),
        for (final section in [
          'Overdue',
          'Today',
          'Tomorrow',
          'This week',
          'Later',
          'No due date'
        ])
          if (groups[section]!.isNotEmpty) ...[
            _SectionHeader(section),
            const SizedBox(height: 8),
            for (final r in groups[section]!)
              _ReminderCard(
                  reminder: r,
                  onToggle: () =>
                      notifier.setStatus(r['id'] as int, 'completed'),
                  onDelete: () => notifier.delete(r['id'] as int)),
            const SizedBox(height: 16),
          ],
        if (completed.isNotEmpty) ...[
          _SectionHeader('Completed'),
          const SizedBox(height: 8),
          for (final r in completed)
            _ReminderCard(
                reminder: r,
                completed: true,
                onToggle: () => notifier.setStatus(r['id'] as int, 'pending'),
                onDelete: () => notifier.delete(r['id'] as int)),
        ],
      ],
    );
  }

  void _showAddReminderSheet(BuildContext context, RemindersNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddReminderSheet(notifier: notifier),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Map<String, dynamic> reminder;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  const _ReminderCard(
      {required this.reminder,
      this.completed = false,
      required this.onToggle,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final priority = reminder['priority'] as String? ?? 'medium';
    final color = priority == 'high'
        ? AppTheme.udoCrimson
        : priority == 'low'
            ? AppTheme.udoTextSecondary
            : Colors.orange;
    final isAuto = reminder['source'] == 'auto';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.udoBorder)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: onToggle,
          child: Icon(
              completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: completed ? AppTheme.udoGreen : color,
              size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(reminder['title'] as String? ?? '',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: completed ? TextDecoration.lineThrough : null)),
          if ((reminder['description'] as String?)?.isNotEmpty == true)
            Text(reminder['description'] as String,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.udoTextSecondary)),
          if (isAuto &&
              (reminder['source_description'] as String?)?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(reminder['source_description'] as String,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.udoTextSecondary,
                      fontStyle: FontStyle.italic)),
            ),
        ])),
        GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close,
                size: 18, color: AppTheme.udoTextSecondary)),
      ]),
    );
  }
}

class _AddReminderSheet extends StatefulWidget {
  final RemindersNotifier notifier;
  const _AddReminderSheet({required this.notifier});
  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'medium';
  bool _saving = false;
  String? _error;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 22),
        child: SafeArea(
            child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Row(children: [
                const Expanded(
                    child: Text('Add reminder',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero),
              ]),
              const SizedBox(height: 14),
              _GField('Reminder title', _title),
              const SizedBox(height: 10),
              _GField('Description (optional)', _description, maxLines: 3),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 3650)));
                  if (picked != null) setState(() => _dueDate = picked);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                      color: AppTheme.udoCardFill,
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: AppTheme.udoTextSecondary),
                    const SizedBox(width: 10),
                    Text(
                        _dueDate == null
                            ? 'Due date (optional)'
                            : '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.udoTextSecondary)),
                  ]),
                ),
              ),
              const SizedBox(height: 10),
              Row(children: [
                for (final (key, label) in [
                  ('high', 'High'),
                  ('medium', 'Medium'),
                  ('low', 'Low')
                ])
                  Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label:
                            Text(label, style: const TextStyle(fontSize: 12)),
                        selected: _priority == key,
                        onSelected: (_) => setState(() => _priority = key),
                        selectedColor: key == 'high'
                            ? AppTheme.udoCrimson
                            : key == 'medium'
                                ? Colors.orange
                                : AppTheme.udoGreen,
                        labelStyle: TextStyle(
                            color: _priority == key
                                ? Colors.white
                                : AppTheme.udoTextPrimary),
                        side: BorderSide(
                            color: _priority == key
                                ? AppTheme.udoGreen
                                : AppTheme.udoBorder),
                      )),
              ]),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.udoCrimson))
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    backgroundColor: AppTheme.udoGreen,
                    foregroundColor: Colors.white),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Add reminder'),
              ),
            ]))),
      );

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Give the reminder a title.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await widget.notifier.create(
        title: _title.text.trim(),
        description:
            _description.text.trim().isEmpty ? null : _description.text.trim(),
        dueDate: _dueDate,
        priority: _priority);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save this reminder. Try again.";
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }
}

// ── INSURANCE TAB ──────────────────────────────────────────────────────────────

class _InsuranceTab extends ConsumerWidget {
  const _InsuranceTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(insuranceProvider);
    final notifier = ref.read(insuranceProvider.notifier);

    if (state.isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));

    final activePolicies = state.policies
        .where((policy) =>
            (policy['status'] as String? ?? 'active').toLowerCase() == 'active')
        .length;
    final expiringPolicies = state.policies.where((policy) {
      final rawDate = policy['end_date'] as String?;
      if (rawDate == null || rawDate.isEmpty) return false;
      final endDate = DateTime.tryParse(rawDate);
      if (endDate == null) return false;
      final days = endDate.difference(DateTime.now()).inDays;
      return days >= 0 && days <= 45;
    }).length;
    final coverageTotal = state.policies.fold<double>(
        0, (sum, policy) => sum + _asDouble(policy['coverage_amount']));
    final readiness = state.policies.isEmpty
        ? 0.0
        : ((activePolicies +
                    state.policies.where((p) => p['end_date'] != null).length) /
                (state.policies.length * 2))
            .clamp(0.0, 1.0);

    return _InsuranceRedesignPage(
      error: state.error,
      policies: state.policies,
      documents: state.documents,
      activePolicies: activePolicies,
      expiringPolicies: expiringPolicies,
      coverageTotal: coverageTotal,
      readiness: readiness,
      onAddPolicy: () => _showAddPolicySheet(context, notifier),
      onEditPolicy: (policy) =>
          _showAddPolicySheet(context, notifier, existing: policy),
      onDeletePolicy: (policy) => notifier.delete(policy['id'] as int),
      onUploadDocument: () => _uploadDocument(context, notifier),
      onDeleteDocument: (id) => notifier.deleteDocument(id),
    );
  }

  void _showAddPolicySheet(BuildContext context, InsuranceNotifier notifier,
      {Map<String, dynamic>? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) =>
          _AddInsuranceSheet(notifier: notifier, existing: existing),
    );
  }

  Future<void> _uploadDocument(
      BuildContext context, InsuranceNotifier notifier) async {
    final result = await FilePicker.pickFiles(withData: true);
    final picked = result?.files.single;
    if (picked == null || picked.bytes == null || !context.mounted) return;
    final ok = await notifier.uploadDocument(picked.bytes!, picked.name);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Couldn't upload that file. Try again.")));
    }
  }
}

class _InsuranceRedesignPage extends StatelessWidget {
  final String? error;
  final List<Map<String, dynamic>> policies;
  final List<Map<String, dynamic>> documents;
  final int activePolicies;
  final int expiringPolicies;
  final double coverageTotal;
  final double readiness;
  final VoidCallback onAddPolicy;
  final ValueChanged<Map<String, dynamic>> onEditPolicy;
  final ValueChanged<Map<String, dynamic>> onDeletePolicy;
  final VoidCallback onUploadDocument;
  final ValueChanged<int> onDeleteDocument;

  const _InsuranceRedesignPage({
    required this.error,
    required this.policies,
    required this.documents,
    required this.activePolicies,
    required this.expiringPolicies,
    required this.coverageTotal,
    required this.readiness,
    required this.onAddPolicy,
    required this.onEditPolicy,
    required this.onDeletePolicy,
    required this.onUploadDocument,
    required this.onDeleteDocument,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        _InsuranceHeroCard(
          readiness: readiness,
          activePolicies: activePolicies,
          coverageTotal: coverageTotal,
          expiringPolicies: expiringPolicies,
        ),
        if (error != null && error!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InsuranceAlert(message: error!),
        ],
        const SizedBox(height: 16),
        _InsuranceMetricGrid(
          policies: policies.length,
          activePolicies: activePolicies,
          expiringPolicies: expiringPolicies,
          coverageTotal: coverageTotal,
        ),
        const SizedBox(height: 18),
        if (policies.isEmpty)
          _InsuranceSetupPanel(onAddPolicy: onAddPolicy)
        else ...[
          UdoSectionHeader(
            title: 'Policy Vault',
            action: 'Add',
            onAction: onAddPolicy,
          ),
          const SizedBox(height: 10),
          for (final policy in policies)
            _InsurancePolicyCard(
              policy: policy,
              onEdit: () => onEditPolicy(policy),
              onDelete: () => onDeletePolicy(policy),
            ),
        ],
        const SizedBox(height: 18),
        _InsuranceDocumentsSection(
          documents: documents,
          onUpload: onUploadDocument,
          onDelete: onDeleteDocument,
        ),
        const SizedBox(height: 18),
        const _InsuranceEmergencyPanel(),
      ],
    );
  }
}

class _InsuranceHeroCard extends StatelessWidget {
  final double readiness;
  final int activePolicies;
  final double coverageTotal;
  final int expiringPolicies;

  const _InsuranceHeroCard({
    required this.readiness,
    required this.activePolicies,
    required this.coverageTotal,
    required this.expiringPolicies,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      color: UdoDesign.blue,
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              UdoBadge(
                label: expiringPolicies > 0 ? 'Review due' : 'Protected',
                color: expiringPolicies > 0 ? UdoDesign.amber : UdoDesign.sage,
                background: Colors.white.withValues(alpha: 0.18),
              ),
              const SizedBox(height: 12),
              Text('Wedding Protection',
                  style: UdoDesign.serif(size: 34, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Is our wedding protected?',
                  style: UdoDesign.sans(
                      size: 14,
                      weight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.78))),
            ]),
          ),
          UdoRingProgress(
            value: readiness,
            color: Colors.white,
            size: 72,
            center: Text('${(readiness * 100).round()}%',
                style: UdoDesign.sans(
                    size: 13, weight: FontWeight.w800, color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
              child: _InsuranceHeroStat(
                  label: 'Active', value: '$activePolicies')),
          Expanded(
              child: _InsuranceHeroStat(
                  label: 'Coverage', value: _money(coverageTotal))),
          Expanded(
              child: _InsuranceHeroStat(
                  label: 'Renewals', value: '$expiringPolicies')),
        ]),
      ]),
    );
  }
}

class _InsuranceHeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _InsuranceHeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UdoDesign.sans(
                size: 14, weight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 3),
        Text(label,
            style: UdoDesign.sans(
                size: 10, color: Colors.white.withValues(alpha: 0.70))),
      ]),
    );
  }
}

class _InsuranceMetricGrid extends StatelessWidget {
  final int policies;
  final int activePolicies;
  final int expiringPolicies;
  final double coverageTotal;

  const _InsuranceMetricGrid({
    required this.policies,
    required this.activePolicies,
    required this.expiringPolicies,
    required this.coverageTotal,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Policies', '$policies', Icons.policy_outlined, UdoDesign.blue),
      (
        'Active',
        '$activePolicies',
        Icons.verified_user_outlined,
        UdoDesign.sage
      ),
      (
        'Coverage',
        _money(coverageTotal),
        Icons.savings_outlined,
        UdoDesign.gold
      ),
      (
        'Renewals',
        '$expiringPolicies',
        Icons.event_repeat_outlined,
        UdoDesign.amber
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return UdoCard(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: metric.$4.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(metric.$3, color: metric.$4, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(metric.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            UdoDesign.sans(size: 14, weight: FontWeight.w800)),
                    Text(metric.$1,
                        style:
                            UdoDesign.sans(size: 10, color: UdoDesign.muted)),
                  ]),
            ),
          ]),
        );
      },
    );
  }
}

class _InsuranceSetupPanel extends StatelessWidget {
  final VoidCallback onAddPolicy;
  const _InsuranceSetupPanel({required this.onAddPolicy});

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: UdoDesign.blue.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.shield_outlined,
              size: 30, color: UdoDesign.blue),
        ),
        const SizedBox(height: 14),
        Text('Build your protection file',
            style: UdoDesign.sans(size: 16, weight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(
          'Add wedding insurance, policy numbers, coverage values, renewal dates, claim details, and emergency contacts in one place.',
          textAlign: TextAlign.center,
          style:
              UdoDesign.sans(size: 12.5, color: UdoDesign.muted, height: 1.45),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onAddPolicy,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add insurance policy'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: UdoDesign.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ]),
    );
  }
}

class _InsuranceAlert extends StatelessWidget {
  final String message;
  const _InsuranceAlert({required this.message});

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      color: UdoDesign.rose.withValues(alpha: 0.08),
      border: BorderSide(color: UdoDesign.rose.withValues(alpha: 0.18)),
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded,
            color: UdoDesign.rose, size: 18),
        const SizedBox(width: 8),
        Expanded(
            child: Text(message,
                style: UdoDesign.sans(size: 12.5, color: UdoDesign.rose))),
      ]),
    );
  }
}

class _InsuranceEmergencyPanel extends StatelessWidget {
  const _InsuranceEmergencyPanel();

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: UdoDesign.amber.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.support_agent_outlined,
              color: UdoDesign.amber, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Emergency file',
                style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              'Keep provider hotline, venue contacts, document scans, and claim notes attached before final week.',
              style: UdoDesign.sans(
                  size: 12.5, color: UdoDesign.muted, height: 1.4),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _InsuranceDocumentsSection extends StatelessWidget {
  final List<Map<String, dynamic>> documents;
  final VoidCallback onUpload;
  final ValueChanged<int> onDelete;
  const _InsuranceDocumentsSection(
      {required this.documents,
      required this.onUpload,
      required this.onDelete});

  String _fileSize(dynamic bytes) {
    final size = (bytes as num?)?.toInt() ?? 0;
    if (size <= 0) return '';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(0)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text('Documents',
                  style: UdoDesign.sans(size: 15, weight: FontWeight.w800))),
          TextButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add', style: TextStyle(fontSize: 12)),
          ),
        ]),
        if (documents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
                'No documents added yet — policy scans, claim forms, receipts.',
                style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
          )
        else
          for (final doc in documents)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                      color: UdoDesign.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.description_outlined,
                      size: 16, color: UdoDesign.blue),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc['name'] as String? ?? 'Document',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: UdoDesign.sans(
                                size: 13, weight: FontWeight.w600)),
                        if (_fileSize(doc['file_size_bytes']).isNotEmpty)
                          Text(_fileSize(doc['file_size_bytes']),
                              style: UdoDesign.sans(
                                  size: 11, color: UdoDesign.muted)),
                      ]),
                ),
                GestureDetector(
                  onTap: () => onDelete(doc['id'] as int),
                  child: const Icon(Icons.delete_outline,
                      size: 18, color: AppTheme.udoTextSecondary),
                ),
              ]),
            ),
      ]),
    );
  }
}

class _InsurancePolicyCard extends StatelessWidget {
  final Map<String, dynamic> policy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _InsurancePolicyCard({
    required this.policy,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final status = policy['status'] as String? ?? 'active';
    final statusColor = status == 'active'
        ? AppTheme.udoGreen
        : status == 'expired'
            ? Colors.orange
            : AppTheme.udoTextSecondary;
    final coverage = policy['coverage_amount'];
    final policyType = (policy['policy_type'] ??
            policy['coverage_type'] ??
            policy['category'] ??
            'Wedding insurance')
        .toString();
    final contact = (policy['claim_phone'] ??
            policy['emergency_phone'] ??
            policy['contact_phone'] ??
            '')
        .toString();

    return UdoCard(
      onTap: onEdit,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.shield_outlined, size: 20, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(policy['provider'] as String? ?? 'Insurance provider',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(policyType,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
              ])),
          UdoBadge(
              label: status[0].toUpperCase() + status.substring(1),
              color: statusColor),
          IconButton(
            tooltip: 'Delete policy',
            onPressed: onDelete,
            icon: const Icon(Icons.close,
                size: 18, color: AppTheme.udoTextSecondary),
          ),
        ]),
        const SizedBox(height: 10),
        if (coverage != null)
          _ModalInfoRow('Coverage', _money(_asDouble(coverage))),
        if (policy['premium_amount'] != null)
          _ModalInfoRow('Premium', _money(_asDouble(policy['premium_amount']))),
        if (policy['deductible_amount'] != null)
          _ModalInfoRow(
              'Deductible', _money(_asDouble(policy['deductible_amount']))),
        if (policy['policy_number'] != null)
          _ModalInfoRow('Policy number', policy['policy_number'] as String),
        if (policy['end_date'] != null)
          _ModalInfoRow('Expires', udo_dates.formatApiDate(policy['end_date'])),
        if (contact.isNotEmpty) _ModalInfoRow('Claims contact', contact),
        const SizedBox(height: 6),
        Text('Tap to edit policy details',
            style: UdoDesign.sans(size: 11, color: UdoDesign.muted)),
      ]),
    );
  }
}

class _InsuranceDateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime> onPick;
  const _InsuranceDateButton({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (picked != null) onPick(picked);
      },
      icon: const Icon(Icons.event_outlined, size: 16),
      label: Text(date == null ? label : _formatDate(date!)),
    );
  }
}

class _AddInsuranceSheet extends StatefulWidget {
  final InsuranceNotifier notifier;
  final Map<String, dynamic>? existing;
  const _AddInsuranceSheet({required this.notifier, this.existing});
  @override
  State<_AddInsuranceSheet> createState() => _AddInsuranceSheetState();
}

class _AddInsuranceSheetState extends State<_AddInsuranceSheet> {
  final _provider = TextEditingController();
  final _policyNumber = TextEditingController();
  final _policyType = TextEditingController();
  final _coverage = TextEditingController();
  final _premium = TextEditingController();
  final _deductible = TextEditingController();
  final _contactName = TextEditingController();
  final _contactPhone = TextEditingController();
  final _claimPhone = TextEditingController();
  final _notes = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _status = 'active';
  bool _saving = false;
  String? _error;

  bool get _editing => widget.existing?['id'] != null;

  @override
  void initState() {
    super.initState();
    final policy = widget.existing;
    if (policy == null) return;
    _provider.text = policy['provider']?.toString() ?? '';
    _policyNumber.text = policy['policy_number']?.toString() ?? '';
    _policyType.text = (policy['policy_type'] ??
            policy['coverage_type'] ??
            policy['category'] ??
            '')
        .toString();
    _coverage.text = policy['coverage_amount']?.toString() ?? '';
    _premium.text = policy['premium_amount']?.toString() ?? '';
    _deductible.text = policy['deductible_amount']?.toString() ?? '';
    _contactName.text = policy['contact_name']?.toString() ?? '';
    _contactPhone.text = policy['contact_phone']?.toString() ?? '';
    _claimPhone.text =
        (policy['claim_phone'] ?? policy['emergency_phone'] ?? '').toString();
    _notes.text = policy['notes']?.toString() ?? '';
    _status = policy['status']?.toString() ?? 'active';
    _startDate = DateTime.tryParse(policy['start_date']?.toString() ?? '');
    _endDate = DateTime.tryParse(policy['end_date']?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          builder: (_, ctrl) => Column(children: [
            Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24))),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(children: [
                Expanded(
                    child: Text(
                        _editing
                            ? 'Edit insurance policy'
                            : 'Add insurance policy',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GField('Provider', _provider),
                      const SizedBox(height: 10),
                      _GField('Coverage type', _policyType),
                      const SizedBox(height: 10),
                      _GField('Policy number (optional)', _policyNumber),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                            child: _GField('Coverage amount', _coverage,
                                type: const TextInputType.numberWithOptions(
                                    decimal: true))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _GField('Premium', _premium,
                                type: const TextInputType.numberWithOptions(
                                    decimal: true))),
                      ]),
                      const SizedBox(height: 10),
                      _GField('Deductible (optional)', _deductible,
                          type: const TextInputType.numberWithOptions(
                              decimal: true)),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'active', child: Text('Active')),
                          DropdownMenuItem(
                              value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(
                              value: 'expired', child: Text('Expired')),
                          DropdownMenuItem(
                              value: 'cancelled', child: Text('Cancelled')),
                        ],
                        onChanged: (value) =>
                            setState(() => _status = value ?? 'active'),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                            child: _InsuranceDateButton(
                          label: 'Start date',
                          date: _startDate,
                          onPick: (date) => setState(() => _startDate = date),
                        )),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _InsuranceDateButton(
                          label: 'End date',
                          date: _endDate,
                          onPick: (date) => setState(() => _endDate = date),
                        )),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: _GField('Contact name', _contactName)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _GField('Contact phone', _contactPhone,
                                type: TextInputType.phone)),
                      ]),
                      const SizedBox(height: 10),
                      _GField('Claims / emergency phone', _claimPhone,
                          type: TextInputType.phone),
                      const SizedBox(height: 10),
                      _GField('Claim notes / exclusions', _notes, maxLines: 3),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(_error!,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.udoCrimson))
                      ],
                      const SizedBox(height: 20),
                    ]),
              ),
            ),
            const Divider(height: 1),
            Container(
              color: AppTheme.udoBackground,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: AppTheme.udoGreen,
                      foregroundColor: Colors.white),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(_editing ? 'Save policy' : 'Add policy'),
                ),
              ),
            ),
          ]),
        ),
      );

  Future<void> _submit() async {
    if (_provider.text.trim().isEmpty) {
      setState(() => _error = 'Provider name is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final payload = {
      'provider': _provider.text.trim(),
      'status': _status,
      if (_policyType.text.trim().isNotEmpty)
        'policy_type': _policyType.text.trim(),
      if (_policyNumber.text.trim().isNotEmpty)
        'policy_number': _policyNumber.text.trim(),
      if (_coverage.text.trim().isNotEmpty)
        'coverage_amount': double.tryParse(_coverage.text.trim()),
      if (_premium.text.trim().isNotEmpty)
        'premium_amount': double.tryParse(_premium.text.trim()),
      if (_deductible.text.trim().isNotEmpty)
        'deductible_amount': double.tryParse(_deductible.text.trim()),
      if (_contactName.text.trim().isNotEmpty)
        'contact_name': _contactName.text.trim(),
      if (_contactPhone.text.trim().isNotEmpty)
        'contact_phone': _contactPhone.text.trim(),
      if (_claimPhone.text.trim().isNotEmpty)
        'claim_phone': _claimPhone.text.trim(),
      if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
      if (_startDate != null) 'start_date': _formatDate(_startDate!),
      if (_endDate != null) 'end_date': _formatDate(_endDate!),
    };
    final ok = _editing
        ? await widget.notifier.update(widget.existing!['id'] as int, payload)
        : await widget.notifier.create(payload);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save this policy. Try again.";
      });
    }
  }

  @override
  void dispose() {
    _provider.dispose();
    _policyNumber.dispose();
    _policyType.dispose();
    _coverage.dispose();
    _premium.dispose();
    _deductible.dispose();
    _contactName.dispose();
    _contactPhone.dispose();
    _claimPhone.dispose();
    _notes.dispose();
    super.dispose();
  }
}

// ── FOOD & DINING TAB ──────────────────────────────────────────────────────────

// ── DOCUMENTS TAB ─────────────────────────────────────────────────────────────

class _DocumentsTab extends ConsumerWidget {
  final PlanState state;
  final ValueChanged<int> onTabJump;
  const _DocumentsTab({required this.state, required this.onTabJump});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insurance = ref.watch(insuranceProvider);
    final honeymoon = ref.watch(honeymoonProvider);
    final party = ref.watch(weddingPartyProvider);
    final registry = ref.watch(registryProvider);
    final vault = ref.watch(documentsVaultProvider);
    final documents = _buildVaultDocuments(
      state: state,
      insurancePolicies: insurance.policies,
      honeymoonItems: honeymoon.items,
      partyFiles: party.files,
      registryItems: registry.items,
      uploadedDocuments: vault.documents,
    );
    final verified = documents.where((doc) => doc.verified).length;
    final signatures = documents
        .where((doc) => doc.status == _VaultDocStatus.signature)
        .length;
    final missing =
        documents.where((doc) => doc.status == _VaultDocStatus.missing).length;
    final recent = documents.take(5).toList();
    final secureScore =
        documents.isEmpty ? 0.0 : (verified / documents.length).clamp(0.0, 1.0);
    final folders = _buildVaultFolders(documents);

    Future<void> openDocument(_VaultDocument doc) async {
      if (doc.url != null) {
        final uri = Uri.parse(_resolveDocumentUrl(doc.url));
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Couldn't open this document.")));
        }
      } else if (doc.jumpToTab != null) {
        onTabJump(doc.jumpToTab!);
      }
    }

    Future<void> uploadDocument({String folder = 'Uploads'}) async {
      final result = await FilePicker.pickFiles(withData: true);
      final picked = result?.files.single;
      if (picked == null || picked.bytes == null || !context.mounted) return;
      final ok = await ref
          .read(documentsVaultProvider.notifier)
          .upload(picked.bytes!, picked.name, folder: folder);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok
              ? 'Document uploaded.'
              : "Couldn't upload that file. Try again.")));
    }

    void openVaultBrowser({String? folder, bool autoFocusSearch = false}) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => _VaultBrowserSheet(
          documents: documents,
          folders: folders,
          initialFolder: folder,
          autoFocusSearch: autoFocusSearch,
          onOpenDocument: openDocument,
          onUpload: (targetFolder) => uploadDocument(folder: targetFolder),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        _DocumentsHeroCard(
          total: documents.length,
          verified: verified,
          signatures: signatures,
          missing: missing,
          recent: recent.length,
          secureScore: secureScore,
          onOpenVault: () => openVaultBrowser(),
          onUpload: uploadDocument,
        ),
        const SizedBox(height: 16),
        _DocumentsOverviewGrid(
          total: documents.length,
          signatures: signatures,
          secureScore: secureScore,
          missing: missing,
        ),
        const SizedBox(height: 18),
        _DocumentsInsightCard(
          documents: documents,
          missing: missing,
          signatures: signatures,
          onShare: () => Share.share(
              'Wedding vault: ${documents.length} documents, $verified verified, $missing missing.'),
        ),
        const SizedBox(height: 22),
        UdoSectionHeader(
          title: 'Document Folders',
          action: 'Search',
          onAction: () => openVaultBrowser(autoFocusSearch: true),
        ),
        for (final folder in folders)
          _VaultFolderCard(
            folder: folder,
            onTap: () => openVaultBrowser(folder: folder.title),
          ),
        const SizedBox(height: 18),
        UdoSectionHeader(title: 'Recent Uploads'),
        if (recent.isEmpty)
          UdoCard(
            padding: const EdgeInsets.all(18),
            child: Text(
              'Documents added in other modules will appear here automatically.',
              style: UdoDesign.sans(size: 13, color: UdoDesign.muted),
            ),
          )
        else
          for (final doc in recent)
            _VaultDocumentRow(document: doc, onTap: () => openDocument(doc)),
      ],
    );
  }
}

String _resolveDocumentUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  return url.startsWith('http') ? url : '${AppConstants.apiOrigin}$url';
}

enum _VaultDocStatus { verified, signature, missing, generated }

class _VaultDocument {
  final String title;
  final String folder;
  final String source;
  final IconData icon;
  final _VaultDocStatus status;
  final double amount;
  // Real uploads (from the Documents backend) carry an id + url and open
  // directly. Everything else here is a *derived* entry describing a real
  // record that lives in another module (a vendor contract, a budget
  // invoice, ...) — there's no file behind it, so tapping it jumps to the
  // Plan tab where that record actually lives instead of pretending to open
  // a document that doesn't exist.
  final int? uploadId;
  final String? url;
  final int? jumpToTab;

  const _VaultDocument({
    required this.title,
    required this.folder,
    required this.source,
    required this.icon,
    required this.status,
    this.amount = 0,
    this.uploadId,
    this.url,
    this.jumpToTab,
  });

  bool get verified =>
      status == _VaultDocStatus.verified || status == _VaultDocStatus.generated;
}

class _VaultFolder {
  final String title;
  final IconData icon;
  final Color color;
  final List<_VaultDocument> documents;

  const _VaultFolder({
    required this.title,
    required this.icon,
    required this.color,
    required this.documents,
  });
}

List<_VaultDocument> _buildVaultDocuments({
  required PlanState state,
  required List<Map<String, dynamic>> insurancePolicies,
  required List<Map<String, dynamic>> honeymoonItems,
  required List<Map<String, dynamic>> partyFiles,
  required List<Map<String, dynamic>> registryItems,
  List<Map<String, dynamic>> uploadedDocuments = const [],
}) {
  final docs = <_VaultDocument>[];

  for (final upload in uploadedDocuments) {
    docs.add(_VaultDocument(
      title: upload['name'] as String? ?? 'Document',
      folder: upload['folder'] as String? ?? 'Uploads',
      source: 'Uploads',
      icon: Icons.upload_file_outlined,
      status: _VaultDocStatus.verified,
      uploadId: upload['id'] as int?,
      url: upload['url'] as String?,
    ));
  }

  for (final vendor in state.vendors) {
    final name = vendor['business_name'] as String? ??
        vendor['name'] as String? ??
        'Vendor';
    final signed = vendor['contract_signed'] == true ||
        vendor['contract_status'] == 'signed' ||
        vendor['booking_status'] == 'booked';
    docs.add(_VaultDocument(
      title: '$name contract',
      folder: 'Contracts',
      source: 'Vendors',
      icon: Icons.description_outlined,
      status: signed ? _VaultDocStatus.verified : _VaultDocStatus.signature,
      amount: _asDouble(vendor['estimated_cost']),
      jumpToTab: 4,
    ));
  }

  for (final item in state.budgetItems) {
    final title = item['name'] as String? ??
        item['title'] as String? ??
        item['category'] as String? ??
        'Budget item';
    final paid = _asDouble(item['paid_amount']) >= _asDouble(item['amount']) &&
        _asDouble(item['amount']) > 0;
    docs.add(_VaultDocument(
      title: '$title invoice',
      folder: 'Payments',
      source: 'Budget',
      icon: Icons.receipt_long_outlined,
      status: paid ? _VaultDocStatus.verified : _VaultDocStatus.missing,
      amount: _asDouble(item['amount']),
      jumpToTab: 7,
    ));
  }

  for (final policy in insurancePolicies) {
    docs.add(_VaultDocument(
      title: '${policy['provider'] as String? ?? 'Insurance'} policy',
      folder: 'Insurance',
      source: 'Insurance',
      icon: Icons.verified_user_outlined,
      status: policy['policy_number'] == null
          ? _VaultDocStatus.missing
          : _VaultDocStatus.verified,
      amount: _asDouble(policy['coverage_amount']),
      jumpToTab: 12,
    ));
  }

  for (final item in honeymoonItems) {
    final type = item['type'] as String? ?? 'travel';
    final title = item['title'] as String? ?? item['name'] as String? ?? type;
    docs.add(_VaultDocument(
      title: '$title confirmation',
      folder: 'Travel',
      source: 'Honeymoon',
      icon: Icons.flight_takeoff_outlined,
      status: _VaultDocStatus.verified,
      amount: _asDouble(item['cost']),
      jumpToTab: 11,
    ));
  }

  for (final file in partyFiles) {
    docs.add(_VaultDocument(
      title: file['name'] as String? ?? 'Wedding party file',
      folder: 'Wedding Party',
      source: 'Wedding Party',
      icon: Icons.attach_file_outlined,
      status: _VaultDocStatus.verified,
      jumpToTab: 10,
    ));
  }

  for (final item in registryItems.take(6)) {
    docs.add(_VaultDocument(
      title: '${item['name'] as String? ?? 'Registry item'} record',
      folder: 'Registry',
      source: 'Registry',
      icon: Icons.card_giftcard_outlined,
      status: _VaultDocStatus.generated,
      amount: _asDouble(item['price']),
      jumpToTab: 6,
    ));
  }

  if (state.timelineItems.isNotEmpty) {
    docs.add(const _VaultDocument(
      title: 'Wedding day timeline PDF',
      folder: 'Generated',
      source: 'Timeline',
      icon: Icons.timeline_outlined,
      status: _VaultDocStatus.generated,
      jumpToTab: 5,
    ));
  }

  return docs;
}

List<_VaultFolder> _buildVaultFolders(List<_VaultDocument> documents) {
  final configs = [
    ('Contracts', Icons.assignment_outlined, UdoDesign.text),
    ('Payments', Icons.receipt_long_outlined, UdoDesign.gold),
    ('Insurance', Icons.verified_user_outlined, UdoDesign.blue),
    ('Travel', Icons.flight_takeoff_outlined, UdoDesign.sage),
    ('Wedding Party', Icons.groups_2_outlined, UdoDesign.rose),
    ('Registry', Icons.card_giftcard_outlined, UdoDesign.amber),
    ('Generated', Icons.auto_awesome_outlined, UdoDesign.plan),
    ('Uploads', Icons.upload_file_outlined, UdoDesign.text),
  ];

  return [
    for (final config in configs)
      _VaultFolder(
        title: config.$1,
        icon: config.$2,
        color: config.$3,
        documents: documents
            .where((document) => document.folder == config.$1)
            .toList(),
      ),
  ].where((folder) => folder.documents.isNotEmpty).toList();
}

class _DocumentsHeroCard extends StatelessWidget {
  final int total, verified, signatures, missing, recent;
  final double secureScore;
  final VoidCallback onOpenVault;
  final VoidCallback onUpload;

  const _DocumentsHeroCard({
    required this.total,
    required this.verified,
    required this.signatures,
    required this.missing,
    required this.recent,
    required this.secureScore,
    required this.onOpenVault,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      color: UdoDesign.text,
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const UdoBadge(
                  label: 'Secure vault',
                  color: UdoDesign.gold,
                  background: Color(0x22FFFFFF)),
              const SizedBox(height: 12),
              Text('Wedding Vault',
                  style: UdoDesign.serif(size: 34, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Every contract, invoice, receipt and important file.',
                  style: UdoDesign.sans(
                      size: 13.5, color: Colors.white70, height: 1.45)),
            ]),
          ),
          UdoRingProgress(
            value: secureScore,
            color: UdoDesign.gold,
            size: 76,
            center: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$total',
                  style: UdoDesign.sans(
                      size: 18, weight: FontWeight.w800, color: Colors.white)),
              Text('Docs',
                  style: UdoDesign.sans(size: 10, color: Colors.white70)),
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
              child: _VaultHeroStat(label: 'Verified', value: '$verified')),
          Expanded(
              child: _VaultHeroStat(label: 'Signatures', value: '$signatures')),
          Expanded(child: _VaultHeroStat(label: 'Missing', value: '$missing')),
          Expanded(child: _VaultHeroStat(label: 'Recent', value: '$recent')),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onOpenVault,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: UdoDesign.text,
                  minimumSize: const Size(0, 46)),
              child: const Text('Open Vault'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: onUpload,
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  minimumSize: const Size(0, 46)),
              child: const Text('Upload'),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _VaultHeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _VaultHeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: UdoDesign.sans(
                  size: 13, weight: FontWeight.w800, color: Colors.white)),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(size: 9.5, color: Colors.white70)),
        ]),
      );
}

class _DocumentsOverviewGrid extends StatelessWidget {
  final int total, signatures, missing;
  final double secureScore;

  const _DocumentsOverviewGrid({
    required this.total,
    required this.signatures,
    required this.secureScore,
    required this.missing,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      ('Documents', '$total', Icons.folder_copy_outlined, UdoDesign.text),
      ('Pending', '$signatures', Icons.draw_outlined, UdoDesign.amber),
      (
        'Secure',
        '${(secureScore * 100).round()}%',
        Icons.lock_outline,
        UdoDesign.sage
      ),
      ('Missing', '$missing', Icons.warning_amber_rounded, UdoDesign.rose),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.95,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return UdoCard(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Icon(card.$3, color: card.$4, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(card.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            UdoDesign.sans(size: 16, weight: FontWeight.w800)),
                    Text(card.$1,
                        style:
                            UdoDesign.sans(size: 10.5, color: UdoDesign.muted)),
                  ]),
            ),
          ]),
        );
      },
    );
  }
}

class _DocumentsInsightCard extends StatelessWidget {
  final List<_VaultDocument> documents;
  final int missing, signatures;
  final VoidCallback onShare;

  const _DocumentsInsightCard({
    required this.documents,
    required this.missing,
    required this.signatures,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final insight = missing > 0
        ? '$missing important file${missing == 1 ? '' : 's'} still need attention.'
        : signatures > 0
            ? '$signatures document${signatures == 1 ? '' : 's'} awaiting signature.'
            : documents.isEmpty
                ? 'Start by adding vendor contracts and payment receipts.'
                : 'Your vault is organized across ${_buildVaultFolders(documents).length} folders.';

    return UdoCard(
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: UdoDesign.text.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.auto_awesome_outlined,
              color: UdoDesign.text, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Vault assistant',
                style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(insight,
                style: UdoDesign.sans(
                    size: 12.5, color: UdoDesign.muted, height: 1.42)),
          ]),
        ),
        IconButton(
          onPressed: onShare,
          icon: const Icon(Icons.ios_share_outlined, color: UdoDesign.text),
        ),
      ]),
    );
  }
}

class _VaultFolderCard extends StatelessWidget {
  final _VaultFolder folder;
  final VoidCallback onTap;
  const _VaultFolderCard({required this.folder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final verified = folder.documents.where((doc) => doc.verified).length;
    final progress = folder.documents.isEmpty
        ? 0.0
        : (verified / folder.documents.length).clamp(0.0, 1.0);

    return UdoCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: folder.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(folder.icon, color: folder.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(folder.title,
                    style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
                Text('${folder.documents.length} files · $verified verified',
                    style: UdoDesign.sans(size: 11, color: UdoDesign.muted)),
              ])),
          UdoBadge(
              label: '${(progress * 100).round()}%',
              color: folder.color,
              background: folder.color.withValues(alpha: 0.10)),
        ]),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          minHeight: 5,
          borderRadius: BorderRadius.circular(999),
          backgroundColor: UdoDesign.stone,
          valueColor: AlwaysStoppedAnimation(folder.color),
        ),
      ]),
    );
  }
}

class _VaultDocumentRow extends StatelessWidget {
  final _VaultDocument document;
  final VoidCallback? onTap;
  const _VaultDocumentRow({required this.document, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = switch (document.status) {
      _VaultDocStatus.verified => UdoDesign.sage,
      _VaultDocStatus.signature => UdoDesign.amber,
      _VaultDocStatus.missing => UdoDesign.rose,
      _VaultDocStatus.generated => UdoDesign.blue,
    };
    final label = switch (document.status) {
      _VaultDocStatus.verified => 'Verified',
      _VaultDocStatus.signature => 'Signature',
      _VaultDocStatus.missing => 'Missing',
      _VaultDocStatus.generated => 'Generated',
    };

    return UdoCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Icon(document.icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(document.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(size: 14.5, weight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(
              document.url != null
                  ? '${document.source} · ${document.folder}'
                  : '${document.source} · ${document.folder} · tap to view in ${document.source}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(size: 11, color: UdoDesign.muted)),
        ])),
        const SizedBox(width: 8),
        UdoBadge(label: label, color: color),
        if (onTap != null) ...[
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 18, color: UdoDesign.muted),
        ],
      ]),
    );
  }
}

/// Backs "Open Vault", "Document search", and every folder tap — one real
/// browser (search + folder filter + upload-into-this-folder) instead of
/// three separate half-built surfaces.
class _VaultBrowserSheet extends StatefulWidget {
  final List<_VaultDocument> documents;
  final List<_VaultFolder> folders;
  final String? initialFolder;
  final bool autoFocusSearch;
  final Future<void> Function(_VaultDocument document) onOpenDocument;
  final Future<void> Function(String folder) onUpload;

  const _VaultBrowserSheet({
    required this.documents,
    required this.folders,
    this.initialFolder,
    this.autoFocusSearch = false,
    required this.onOpenDocument,
    required this.onUpload,
  });

  @override
  State<_VaultBrowserSheet> createState() => _VaultBrowserSheetState();
}

class _VaultBrowserSheetState extends State<_VaultBrowserSheet> {
  late String? _folderFilter = widget.initialFolder;
  final _query = TextEditingController();
  bool _uploading = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<_VaultDocument> get _filtered {
    final q = _query.text.trim().toLowerCase();
    return widget.documents.where((doc) {
      final matchesFolder =
          _folderFilter == null || doc.folder == _folderFilter;
      final matchesQuery = q.isEmpty ||
          doc.title.toLowerCase().contains(q) ||
          doc.source.toLowerCase().contains(q);
      return matchesFolder && matchesQuery;
    }).toList();
  }

  Future<void> _upload() async {
    setState(() => _uploading = true);
    await widget.onUpload(_folderFilter ?? 'Uploads');
    if (mounted) setState(() => _uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(_folderFilter ?? 'Wedding Vault',
                      style:
                          UdoDesign.sans(size: 18, weight: FontWeight.w800))),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 8),
            TextField(
              controller: _query,
              autofocus: widget.autoFocusSearch,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: UdoDesign.card,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                _folderChip('All', _folderFilter == null,
                    () => setState(() => _folderFilter = null)),
                for (final folder in widget.folders)
                  _folderChip(folder.title, _folderFilter == folder.title,
                      () => setState(() => _folderFilter = folder.title)),
              ]),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _uploading ? null : _upload,
              icon: _uploading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.upload_file_outlined, size: 16),
              label: Text(_uploading
                  ? 'Uploading...'
                  : (_folderFilter != null
                      ? 'Add document to $_folderFilter'
                      : 'Add document')),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text('No documents found.',
                          style:
                              UdoDesign.sans(size: 13, color: UdoDesign.muted)))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: results.length,
                      itemBuilder: (context, index) => _VaultDocumentRow(
                        document: results[index],
                        onTap: () {
                          Navigator.pop(context);
                          widget.onOpenDocument(results[index]);
                        },
                      ),
                    ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _folderChip(String label, bool selected, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
          selected: selected,
          onSelected: (_) => onTap(),
          selectedColor: UdoDesign.text.withValues(alpha: 0.12),
        ),
      );
}

const _kCourseTypeLabels = {
  'drinks': 'Welcome Drinks',
  'starter': 'Starters',
  'main': 'Main Courses',
  'dessert': 'Desserts',
  'late_night': 'Late Night Bites',
  'other': 'Other',
};

const _dietaryAllergyOptions = [
  'Peanuts',
  'Tree Nuts',
  'Dairy (Milk)',
  'Eggs',
  'Fish',
  'Shellfish',
  'Wheat',
  'Soy',
  'Sesame',
  'Mustard',
  'Celery',
  'Lupin',
  'Sulphites',
  'Corn',
  'Coconut',
  'Garlic',
  'Onion',
  'Mushroom',
  'Chocolate',
  'Citrus',
  'Other (Specify)',
];

const _dietaryRequirementOptions = [
  'Vegetarian',
  'Vegan',
  'Pescatarian',
  'Gluten-Free',
  'Dairy-Free',
  'Egg-Free',
  'Nut-Free',
  'Halal',
  'Kosher',
  'Jain',
  'Hindu Vegetarian',
  'No Pork',
  'No Beef',
  'Low Sodium',
  'Low Sugar / Diabetic',
  'Keto',
  'Paleo',
  'Low Carb',
  'Whole30',
  'Pregnancy Dietary Needs',
  'Child Meal Required',
  'Other (Specify)',
];

const _drinkCategoryOptions = [
  'Welcome Drinks',
  'Ceremony Refreshments',
  'Cocktail Hour',
  'Reception Bar',
  'Dinner Service',
  'Toasts & Champagne',
  'After Party',
  'Farewell Brunch',
  'Late Night Refreshments',
  'Guest Welcome Bags',
  'Bridal Suite',
  'Groomsmen Suite',
  'Vendor Refreshments',
  'Kids Drinks',
  'Non-Alcoholic Station',
  'Coffee & Tea Station',
  'Dessert Bar',
  'Signature Drinks',
  'Open Bar',
  'Cash Bar',
];

const _beverageTypeOptions = [
  'Water (Still)',
  'Water (Sparkling)',
  'Soft Drinks',
  'Juice',
  'Lemonade',
  'Iced Tea',
  'Fruit Punch',
  'Mocktails',
  'Coffee',
  'Espresso',
  'Cappuccino',
  'Latte',
  'Hot Chocolate',
  'Tea',
  'Champagne',
  'Prosecco',
  'Sparkling Wine',
  'White Wine',
  'Rosé Wine',
  'Red Wine',
  'Beer',
  'Cider',
  'Rum',
  'Vodka',
  'Gin',
  'Whiskey',
  'Bourbon',
  'Tequila',
  'Brandy',
  'Cognac',
  'Liqueurs',
  'Signature Cocktail',
  'Frozen Cocktail',
  'Mixed Drinks',
  'Energy Drinks',
  'Coconut Water',
  'Smoothies',
  'Milkshakes',
  'Other',
];

const _drinkServiceTypeOptions = [
  'Passed by Servers',
  'Self-Serve Station',
  'Open Bar',
  'Cash Bar',
  'Limited Bar',
  'Premium Bar',
  'Beer & Wine Only',
  'Signature Drinks Only',
  'Welcome Drink on Arrival',
  'Table Service',
  'Buffet Beverage Station',
  'Coffee Station',
  'Tea Station',
  'Champagne Toast',
  'Wine Service with Dinner',
  'Bottle Service',
  'Bartender Service',
  'Cocktail Cart',
  'Mobile Bar',
  'Poolside Service',
  'Beach Service',
  'After Party Bar',
  'Non-Alcoholic Bar',
  'Kids Beverage Station',
];

const _drinkUnitOptions = [
  'Bottles',
  'Cases',
  'Cans',
  'Kegs',
  'Glasses',
  'Servings',
  'Litres',
  'Gallons',
  'Carafes',
  'Pitchers',
  'Boxes',
  'Crates',
  'Cups',
  'Guests',
  'Per Person',
  'Other',
];

const _drinkTagOptions = [
  'Alcoholic',
  'Non-Alcoholic',
  'Vegan Friendly',
  'Sugar Free',
  'Gluten Free',
  'Dairy Free',
  'Kids Friendly',
  'Premium',
  'Imported',
  'Local',
  'Signature',
  'Seasonal',
  'Unlimited',
  'Limited Quantity',
  'Requires ID Verification',
];

const _createServiceCategorySentinel = '__create_category__';

const _eventCategoryOptions = [
  'Welcome Drinks',
  'Guest Arrival',
  'Ceremony',
  'Cocktail Hour',
  'Dinner',
  'Reception',
  'Speeches & Toasts',
  'Cake Cutting',
  'First Dance',
  'Parent Dances',
  'Bouquet Toss',
  'Garter Toss',
  'Party & Dancing',
  'Late Night Snacks',
  'After Party',
  'Farewell Brunch',
  'Bridal Prep',
  'Groom Prep',
  'Rehearsal',
  'Rehearsal Dinner',
  'Photoshoot',
  'Vendor Setup',
  'Venue Setup',
  'Cleanup',
  'Other',
];

const _serviceCategoryOptions = [
  'Beverage Service',
  'Food Service',
  'Staffing',
  'Equipment',
  'Bar',
  'Coffee & Tea',
  'Dessert',
  'Guest Portal',
  'Rentals',
  'Logistics',
  'Entertainment',
  'Other',
];

const _serviceTypeOptionsByCategory = {
  'Beverage Service': [
    'Welcome Drink',
    'Open Bar',
    'Cash Bar',
    'Premium Bar',
    'Beer & Wine Bar',
    'Signature Cocktail Station',
    'Champagne Toast',
    'Wine Service',
    'Table Water Service',
    'Soft Drink Station',
    'Juice Station',
    'Mocktail Bar',
    'Coffee Station',
    'Tea Station',
    'Cocktail Cart',
    'Mobile Bar',
  ],
  'Food Service': [
    'Buffet',
    'Plated Service',
    'Family Style',
    'Food Stations',
    'Passed Canapés',
    'Grazing Table',
    'Dessert Station',
    'Late Night Snacks',
    'Kids Meal Service',
    'Breakfast Service',
    'Brunch Service',
  ],
  'Staffing': [
    'Bartenders',
    'Wait Staff',
    'Kitchen Staff',
    'Food Runners',
    'Bussers',
    'Barbacks',
    'Event Manager',
    'Floor Supervisor',
  ],
  'Equipment': [
    'Glassware Setup',
    'Tableware Setup',
    'Bar Setup',
    'Coffee Machine Setup',
    'Beverage Cooler Setup',
    'Ice Station',
    'Water Station',
  ],
  'Bar': [
    'Stock Bar',
    'Restock Bar',
    'Ice Delivery',
    'Garnish Station',
    'Spirit Display',
    'Wine Service',
  ],
  'Coffee & Tea': [
    'Espresso Bar',
    'Coffee Cart',
    'Tea Selection',
    'Hot Chocolate Station',
  ],
  'Dessert': [
    'Cake Service',
    'Dessert Buffet',
    'Donut Wall',
    'Ice Cream Station',
    'Candy Bar',
  ],
  'Guest Portal': [
    'Champagne Greeting',
    'Table Drink Service',
    'VIP Service',
    'Kids Drinks',
    'Hydration Station',
  ],
  'Rentals': [
    'Bar Rental',
    'Glassware Rental',
    'Beverage Dispensers',
    'Coffee Equipment',
    'Refrigeration',
  ],
  'Logistics': [
    'Delivery',
    'Setup',
    'Breakdown',
    'Collection',
    'Storage',
  ],
  'Entertainment': [
    'Mixologist',
    'Flair Bartender',
    'Whiskey Tasting',
    'Wine Tasting',
    'Cocktail Class',
  ],
  'Other': ['Other'],
};

const _serviceAssignedToOptions = [
  'Caterer',
  'Head Chef',
  'Bar Manager',
  'Bartender',
  'Beverage Team',
  'Wait Staff',
  'Event Planner',
  'Wedding Coordinator',
  'Venue Manager',
  'Banquet Manager',
  'Kitchen Team',
  'Volunteer',
  'Other',
];

class _FoodTab extends ConsumerWidget {
  const _FoodTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(foodProvider);
    final notifier = ref.read(foodProvider.notifier);
    final guests = ref.watch(guestsProvider).guests;
    final timelineEventTitles = ref
        .watch(planProvider)
        .timelineItems
        .map((item) => (item['title'] ?? '').toString().trim())
        .where((title) => title.isNotEmpty)
        .toSet()
        .toList();

    if (state.isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));

    final summary = state.summary;
    final totalGuests = (summary['total_guests'] as num?)?.toInt() ?? 0;
    final mealSelections = (summary['meal_selections'] as num?)?.toInt() ?? 0;
    final dietaryNeeds = (summary['dietary_needs'] as num?)?.toInt() ?? 0;
    final allergyCount = (summary['allergy_count'] as num?)?.toInt() ?? 0;
    final itemsToReview = (summary['items_to_review'] as num?)?.toInt() ?? 0;
    final progress =
        totalGuests > 0 ? (mealSelections / totalGuests).clamp(0.0, 1.0) : 0.0;
    final rebuiltFood = _FoodRedesignPage(
      error: state.error,
      courses: state.courses,
      guests: guests,
      totalGuests: totalGuests,
      mealSelections: mealSelections,
      dietaryNeeds: dietaryNeeds,
      allergyCount: allergyCount,
      itemsToReview: itemsToReview,
      progress: progress,
      onAddCourse: () => _showAddCourseSheet(context, notifier),
      onAddDrinks: () => _showAddDrinkSheet(context, notifier, state.courses),
      onDietary: () => _showDietaryOverview(context, guests),
      onAddService: () =>
          _showAddServiceSheet(context, notifier, timelineEventTitles),
      onExport: () => _exportMenu(state.courses),
      onReview: () => _showReviewSheet(context, state.courses, notifier),
      courseBuilder: (course) =>
          _CourseCard(course: course, guests: guests, notifier: notifier),
    );
    if (MediaQuery.sizeOf(context).width >= 0) {
      return rebuiltFood;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (state.error != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppTheme.udoCrimson.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14)),
            child: const Text(
                "Couldn't load your menu. Pull to refresh or try again later.",
                style: TextStyle(fontSize: 13, color: AppTheme.udoCrimson)),
          ),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppTheme.udoGreen,
                AppTheme.udoGreen.withValues(alpha: 0.8)
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Dining overview',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text('$totalGuests guests',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('$mealSelections meal selections',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                ])),
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        valueColor:
                            const AlwaysStoppedAnimation(Colors.white))),
                Text('${(progress * 100).round()}%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.4,
          children: [
            _FoodStatTile('$totalGuests', 'Total guests'),
            _FoodStatTile('$mealSelections', 'Meal selections',
                detail: totalGuests > 0
                    ? '${((mealSelections / totalGuests) * 100).round()}% completed'
                    : null),
            _FoodStatTile('$dietaryNeeds', 'Dietary needs',
                detail: allergyCount > 0
                    ? '$allergyCount allerg${allergyCount == 1 ? 'y' : 'ies'}'
                    : null),
            _FoodStatTile('$itemsToReview', 'Items to review'),
          ],
        ),
        if (itemsToReview > 0) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showReviewSheet(context, state.courses, notifier),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.orange.withValues(alpha: 0.3))),
              child: Row(children: [
                const Icon(Icons.rate_review_outlined,
                    color: Colors.orange, size: 20),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                        'Menu enhancements still need review — $itemsToReview item${itemsToReview == 1 ? '' : 's'} waiting for your approval',
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500))),
                const Icon(Icons.chevron_right, color: Colors.orange, size: 18),
              ]),
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Text('Quick actions',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _QuickActionChip(
              icon: Icons.restaurant_menu_outlined,
              label: 'Menu',
              onTap: () => _showAddCourseSheet(context, notifier)),
          _QuickActionChip(
              icon: Icons.no_food_outlined,
              label: 'Dietary needs',
              onTap: () => _showDietaryBreakdown(context, guests)),
          _QuickActionChip(
              icon: Icons.local_bar_outlined,
              label: 'Drinks & bar',
              onTap: () => _showAddCourseSheet(context, notifier,
                  defaultType: 'drinks')),
          _QuickActionChip(
              icon: Icons.list_alt_outlined,
              label: 'Service order',
              onTap: () => _showServiceOrder(context, state.courses)),
          _QuickActionChip(
              icon: Icons.ios_share_outlined,
              label: 'Send to caterer',
              onTap: () => _exportMenu(state.courses)),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          const Expanded(
              child: Text('Menu summary',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          TextButton.icon(
              onPressed: () => _showAddCourseSheet(context, notifier),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add course')),
        ]),
        if (state.courses.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.udoBorder)),
            child: const Column(children: [
              Text('No menu set up yet',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              SizedBox(height: 6),
              Text(
                  'Add courses like Starters, Main Courses, and Desserts to start tracking meal selections.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.udoTextSecondary)),
            ]),
          )
        else
          for (final course in state.courses)
            _CourseCard(course: course, guests: guests, notifier: notifier),
        const SizedBox(height: 80),
      ],
    );
  }

  void _showAddCourseSheet(BuildContext context, FoodNotifier notifier,
      {String defaultType = 'other'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) =>
          _AddCourseSheet(notifier: notifier, defaultType: defaultType),
    );
  }

  void _showAddDrinkSheet(BuildContext context, FoodNotifier notifier,
      List<Map<String, dynamic>> courses) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddDrinkSheet(notifier: notifier, courses: courses),
    );
  }

  void _showAddServiceSheet(BuildContext context, FoodNotifier notifier,
      List<String> timelineEventTitles) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddServiceSheet(
          notifier: notifier, timelineEventTitles: timelineEventTitles),
    );
  }

  void _showDietaryBreakdown(
      BuildContext context, List<Map<String, dynamic>> guests) {
    _showBreakdownSheet(context, 'Dietary needs', _dietaryTally(guests));
  }

  void _showDietaryOverview(
      BuildContext context, List<Map<String, dynamic>> guests) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) =>
          _DietaryOverviewSheet(guests: guests, launcherContext: context),
    );
  }

  void _showServiceOrder(
      BuildContext context, List<Map<String, dynamic>> courses) {
    final ordered = [...courses]..sort((a, b) =>
        ((a['sort_order'] as num?) ?? 0)
            .compareTo((b['sort_order'] as num?) ?? 0));
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Service order',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                if (ordered.isEmpty)
                  const Text('No courses added yet.',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.udoTextSecondary))
                else
                  for (var i = 0; i < ordered.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        Text('${i + 1}.',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.udoTextSecondary)),
                        const SizedBox(width: 8),
                        Text(ordered[i]['name'] as String? ?? '',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ]),
                    ),
              ]),
        ),
      ),
    );
  }

  void _exportMenu(List<Map<String, dynamic>> courses) {
    final buffer = StringBuffer('Course,Option,Confirmed,Selections\n');
    for (final course in courses) {
      for (final option in (course['options'] as List? ?? [])) {
        if (option is! Map) continue;
        buffer.writeln([
          course['name'] ?? '',
          option['name'] ?? '',
          option['confirmed'] == true ? 'Yes' : 'No',
          option['selections_count'] ?? 0,
        ].join(','));
      }
    }
    Share.share(buffer.toString(), subject: 'Wedding menu for caterer');
  }

  void _showReviewSheet(BuildContext context,
      List<Map<String, dynamic>> courses, FoodNotifier notifier) {
    final unconfirmed = <Map<String, dynamic>>[];
    for (final course in courses) {
      for (final option in (course['options'] as List? ?? [])) {
        if (option is Map && option['confirmed'] != true) {
          unconfirmed.add({
            ...Map<String, dynamic>.from(option),
            'course_name': course['name']
          });
        }
      }
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) =>
          StatefulBuilder(builder: (sheetContext, setSheetState) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Menu items to review',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  if (unconfirmed.isEmpty)
                    const Text('Nothing left to review.',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.udoTextSecondary))
                  else
                    for (final option in unconfirmed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(option['name'] as String? ?? '',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                                Text(option['course_name'] as String? ?? '',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.udoTextSecondary)),
                              ])),
                          TextButton(
                            onPressed: () async {
                              await notifier.confirmOption(option['id'] as int);
                              setSheetState(() => unconfirmed.remove(option));
                            },
                            child: const Text('Confirm'),
                          ),
                        ]),
                      ),
                ]),
          ),
        );
      }),
    );
  }
}

Map<String, int> _dietaryTally(List<Map<String, dynamic>> guests) {
  final tally = <String, int>{};
  for (final g in guests) {
    final note = (g['dietary_note'] as String?)?.trim();
    final allergy = (g['allergies'] as String?)?.trim();
    if (note != null && note.isNotEmpty) tally[note] = (tally[note] ?? 0) + 1;
    if (allergy != null && allergy.isNotEmpty) {
      tally['Allergy: $allergy'] = (tally['Allergy: $allergy'] ?? 0) + 1;
    }
    final tags = (g['dietary_tags'] as List?) ?? const [];
    for (final tag in tags) {
      final label = tag.toString();
      if (label.isEmpty) continue;
      tally[label] = (tally[label] ?? 0) + 1;
    }
  }
  return tally;
}

void _showBreakdownSheet(
    BuildContext context, String title, Map<String, int> tally) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              if (tally.isEmpty || tally.values.every((v) => v == 0))
                const Text('No data yet.',
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.udoTextSecondary))
              else
                for (final entry in tally.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Expanded(
                          child: Text(entry.key,
                              style: const TextStyle(fontSize: 14))),
                      Text('${entry.value}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.udoGreen)),
                    ]),
                  ),
            ]),
      ),
    ),
  );
}

class _FoodRedesignPage extends StatelessWidget {
  final String? error;
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> guests;
  final int totalGuests;
  final int mealSelections;
  final int dietaryNeeds;
  final int allergyCount;
  final int itemsToReview;
  final double progress;
  final VoidCallback onAddCourse;
  final VoidCallback onAddDrinks;
  final VoidCallback onDietary;
  final VoidCallback onAddService;
  final VoidCallback onExport;
  final VoidCallback onReview;
  final Widget Function(Map<String, dynamic> course) courseBuilder;

  const _FoodRedesignPage({
    required this.error,
    required this.courses,
    required this.guests,
    required this.totalGuests,
    required this.mealSelections,
    required this.dietaryNeeds,
    required this.allergyCount,
    required this.itemsToReview,
    required this.progress,
    required this.onAddCourse,
    required this.onAddDrinks,
    required this.onDietary,
    required this.onAddService,
    required this.onExport,
    required this.onReview,
    required this.courseBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final missingMeals = (totalGuests - mealSelections).clamp(0, totalGuests);
    final confirmedCourses = courses.where((course) {
      final status = (course['status'] ?? '').toString().toLowerCase();
      return status == 'approved' || status == 'confirmed' || status == 'done';
    }).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 128),
      children: [
        if (error != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: UdoDesign.rose.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: UdoDesign.rose.withValues(alpha: 0.18)),
            ),
            child: Text(
                "Couldn't load your menu. Pull to refresh or try again later.",
                style: UdoDesign.sans(size: 13, color: UdoDesign.rose)),
          ),
        _FoodHeroCard(
          progress: progress,
          totalGuests: totalGuests,
          mealSelections: mealSelections,
          missingMeals: missingMeals,
        ),
        const SizedBox(height: 14),
        _FoodMetricGrid(
          totalGuests: totalGuests,
          mealSelections: mealSelections,
          dietaryNeeds: dietaryNeeds,
          allergyCount: allergyCount,
          reviewCount: itemsToReview,
        ),
        if (itemsToReview > 0) ...[
          const SizedBox(height: 14),
          _FoodReviewBanner(count: itemsToReview, onTap: onReview),
        ],
        const SizedBox(height: 18),
        UdoSectionHeader(
          title: 'Kitchen operations',
          subtitle: 'Menu, dietary requirements, drinks, service order, export',
        ),
        _FoodActionGrid(
          onAddCourse: onAddCourse,
          onDietary: onDietary,
          onAddDrinks: onAddDrinks,
          onAddService: onAddService,
          onExport: onExport,
        ),
        const SizedBox(height: 18),
        UdoSectionHeader(
          title: 'Menu builder',
          subtitle:
              '$confirmedCourses confirmed of ${courses.length} course${courses.length == 1 ? '' : 's'}',
          action: 'Add course',
          onAction: onAddCourse,
        ),
        if (courses.isEmpty)
          UdoCard(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Icon(Icons.restaurant_menu_outlined,
                  size: 36, color: UdoDesign.amber),
              const SizedBox(height: 10),
              Text('No menu set up yet',
                  style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(
                'Add courses like starters, mains, desserts, drinks, and late-night bites.',
                textAlign: TextAlign.center,
                style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted),
              ),
            ]),
          )
        else
          for (final course in courses) courseBuilder(course),
        const SizedBox(height: 18),
        _FoodCatererPanel(
          courses: courses.length,
          guests: guests.length,
          dietaryNeeds: dietaryNeeds,
          onExport: onExport,
        ),
      ],
    );
  }
}

class _FoodHeroCard extends StatelessWidget {
  final double progress;
  final int totalGuests;
  final int mealSelections;
  final int missingMeals;

  const _FoodHeroCard({
    required this.progress,
    required this.totalGuests,
    required this.mealSelections,
    required this.missingMeals,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      color: UdoDesign.amber,
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        UdoRingProgress(
          value: progress,
          size: 64,
          color: Colors.white,
          center: Text('${(progress * 100).round()}%',
              style: UdoDesign.sans(
                  size: 12, weight: FontWeight.w800, color: Colors.white)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Food & Dining',
                style: UdoDesign.sans(
                    size: 17, weight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text('What is everyone eating?',
                style: UdoDesign.serif(
                    size: 22, weight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              '$mealSelections of $totalGuests meal selections · $missingMeals missing',
              style: UdoDesign.sans(
                  size: 12.5, color: Colors.white.withValues(alpha: 0.76)),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _FoodMetricGrid extends StatelessWidget {
  final int totalGuests;
  final int mealSelections;
  final int dietaryNeeds;
  final int allergyCount;
  final int reviewCount;

  const _FoodMetricGrid({
    required this.totalGuests,
    required this.mealSelections,
    required this.dietaryNeeds,
    required this.allergyCount,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Guests', '$totalGuests', Icons.groups_outlined, UdoDesign.blue),
      ('Meals', '$mealSelections', Icons.restaurant_outlined, UdoDesign.amber),
      ('Dietary', '$dietaryNeeds', Icons.spa_outlined, UdoDesign.sage),
      ('Review', '$reviewCount', Icons.rate_review_outlined, UdoDesign.rose),
    ];
    return Row(children: [
      for (final metric in metrics)
        Expanded(
          child: UdoCard(
            margin: const EdgeInsets.only(right: 7),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(children: [
              Icon(metric.$3, size: 18, color: metric.$4),
              const SizedBox(height: 5),
              Text(metric.$2,
                  style: UdoDesign.sans(
                      size: 15, weight: FontWeight.w800, color: metric.$4)),
              Text(metric.$1,
                  style: UdoDesign.sans(size: 10, color: UdoDesign.muted)),
              if (metric.$1 == 'Dietary' && allergyCount > 0)
                Text('$allergyCount allergies',
                    style: UdoDesign.sans(size: 9.5, color: UdoDesign.rose)),
            ]),
          ),
        ),
    ]);
  }
}

class _FoodReviewBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _FoodReviewBanner({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      onTap: onTap,
      color: UdoDesign.amber.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        const Icon(Icons.rate_review_outlined, color: UdoDesign.amber),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$count menu item${count == 1 ? '' : 's'} waiting for approval',
            style: UdoDesign.sans(
                size: 13, weight: FontWeight.w700, color: UdoDesign.amber),
          ),
        ),
        const Icon(Icons.chevron_right, color: UdoDesign.amber),
      ]),
    );
  }
}

class _FoodActionGrid extends StatelessWidget {
  final VoidCallback onAddCourse;
  final VoidCallback onDietary;
  final VoidCallback onAddDrinks;
  final VoidCallback onAddService;
  final VoidCallback onExport;

  const _FoodActionGrid({
    required this.onAddCourse,
    required this.onDietary,
    required this.onAddDrinks,
    required this.onAddService,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Menu', Icons.restaurant_menu_outlined, onAddCourse),
      ('Dietary', Icons.no_food_outlined, onDietary),
      ('Drinks', Icons.local_bar_outlined, onAddDrinks),
      ('Service', Icons.list_alt_outlined, onAddService),
      ('Caterer', Icons.ios_share_outlined, onExport),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final action in actions)
          ActionChip(
            avatar: Icon(action.$2, size: 16, color: UdoDesign.amber),
            label: Text(action.$1),
            onPressed: action.$3,
          ),
      ],
    );
  }
}

class _FoodCatererPanel extends StatelessWidget {
  final int courses;
  final int guests;
  final int dietaryNeeds;
  final VoidCallback onExport;

  const _FoodCatererPanel({
    required this.courses,
    required this.guests,
    required this.dietaryNeeds,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text('Send to caterer',
                  style: UdoDesign.sans(size: 15, weight: FontWeight.w800))),
          const UdoBadge(label: 'Export', color: UdoDesign.amber),
        ]),
        const SizedBox(height: 8),
        Text(
          '$courses courses · $guests guests · $dietaryNeeds dietary requirements',
          style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onExport,
          icon: const Icon(Icons.ios_share_outlined, size: 16),
          label: const Text('Export meal list'),
        ),
      ]),
    );
  }
}

class _FoodStatTile extends StatelessWidget {
  final String value, label;
  final String? detail;
  const _FoodStatTile(this.value, this.label, {this.detail});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.udoBorder)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.udoGreen)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.udoTextSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              if (detail != null)
                Text(detail!,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.udoTextSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
            ]),
      );
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final List<Map<String, dynamic>> guests;
  final FoodNotifier notifier;
  const _CourseCard(
      {required this.course, required this.guests, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final options = (course['options'] as List? ?? [])
        .whereType<Map>()
        .map((o) => Map<String, dynamic>.from(o))
        .toList();
    final totalGuests = guests.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.udoBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(course['name'] as String? ?? '',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600))),
          IconButton(
            tooltip: 'Edit course',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24))),
              builder: (_) =>
                  _EditCourseSheet(course: course, notifier: notifier),
            ),
            icon: const Icon(Icons.edit_outlined,
                size: 18, color: AppTheme.udoTextSecondary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Text('${options.length} selection${options.length == 1 ? '' : 's'}',
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.udoTextSecondary)),
          IconButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24))),
              builder: (_) => _AddOptionSheet(
                  courseId: course['id'] as int, notifier: notifier),
            ),
            icon: const Icon(Icons.add_circle_outline,
                size: 18, color: AppTheme.udoGreen),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ]),
        if (options.isEmpty)
          const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('No options added yet.',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.udoTextSecondary)))
        else
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showMenuOptionDetailSheet(
                    context: context,
                    course: course,
                    option: option,
                    totalGuests: totalGuests),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    if (option['confirmed'] != true)
                      const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(Icons.hourglass_empty,
                              size: 14, color: Colors.orange)),
                    Expanded(
                        child: Text(option['name'] as String? ?? '',
                            style: const TextStyle(fontSize: 13))),
                    Text('${option['selections_count'] ?? 0} of $totalGuests',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.udoTextSecondary)),
                    PopupMenuButton<String>(
                      tooltip: 'Menu option actions',
                      icon: const Icon(Icons.more_horiz,
                          size: 18, color: AppTheme.udoTextSecondary),
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        if (value == 'edit') {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24))),
                            builder: (_) => _EditOptionSheet(
                                option: option, notifier: notifier),
                          );
                        } else if (value == 'assign') {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24))),
                            builder: (_) => _GuestPickerSheet(
                              guests: guests,
                              onPicked: (guestId) => notifier.selectForGuest(
                                  optionId: option['id'] as int,
                                  guestId: guestId),
                            ),
                          );
                        } else if (value == 'confirm') {
                          notifier.confirmOption(option['id'] as int);
                        } else if (value == 'delete') {
                          notifier.deleteOption(option['id'] as int);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'edit', child: Text('Edit option')),
                        const PopupMenuItem(
                            value: 'assign', child: Text('Assign to guest')),
                        if (option['confirmed'] != true)
                          const PopupMenuItem(
                              value: 'confirm', child: Text('Mark confirmed')),
                        const PopupMenuItem(
                            value: 'delete', child: Text('Delete option')),
                      ],
                    ),
                  ]),
                ),
              ),
            ),
      ]),
    );
  }
}

void _showMenuOptionDetailSheet({
  required BuildContext context,
  required Map<String, dynamic> course,
  required Map<String, dynamic> option,
  required int totalGuests,
}) {
  final selections = (option['selections_count'] as num?)?.toInt() ?? 0;
  final complete = totalGuests > 0 && selections >= totalGuests;
  final courseName = course['name']?.toString() ?? 'Course';
  final optionName = option['name']?.toString() ?? 'Menu option';
  final courseType = course['type']?.toString() ?? 'other';
  final title = '$optionName — ${courseType == 'main' ? 'Main' : courseName}';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(title,
                      style: UdoDesign.serif(size: 22, color: UdoDesign.text)),
                ),
                IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close)),
              ]),
              const Divider(height: 24),
              UdoBadge(
                  label: complete ? 'Complete' : 'In progress',
                  color: complete ? UdoDesign.sage : UdoDesign.amber),
              const SizedBox(height: 14),
              Text('$selections selection${selections == 1 ? '' : 's'}',
                  style: UdoDesign.sans(size: 13, color: UdoDesign.muted)),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  context.go('/guests?tab=Guest%20list&info=missing_meal');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: UdoDesign.guests,
                  foregroundColor: Colors.white,
                ),
                child: const Text('View Guest List'),
              ),
            ]),
      ),
    ),
  );
}

class _EditCourseSheet extends StatefulWidget {
  final Map<String, dynamic> course;
  final FoodNotifier notifier;
  const _EditCourseSheet({required this.course, required this.notifier});
  @override
  State<_EditCourseSheet> createState() => _EditCourseSheetState();
}

class _EditCourseSheetState extends State<_EditCourseSheet> {
  late final _name =
      TextEditingController(text: widget.course['name']?.toString() ?? '');
  late String _type = widget.course['type']?.toString() ?? 'other';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Give the course a name.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await widget.notifier.updateCourse(
      courseId: widget.course['id'] as int,
      name: _name.text.trim(),
      type: _type,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't update this course. Try again.";
      });
    }
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    final ok = await widget.notifier.deleteCourse(widget.course['id'] as int);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't delete this course. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppTheme.udoBorder,
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Edit course',
                  style: TextStyle(
                      fontFamily: 'Playfair',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.udoGreen)),
              const SizedBox(height: 16),
              TextField(
                  controller: _name,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Course name')),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final entry in _kCourseTypeLabels.entries)
                  ChoiceChip(
                    label:
                        Text(entry.value, style: const TextStyle(fontSize: 12)),
                    selected: _type == entry.key,
                    onSelected: (_) => setState(() => _type = entry.key),
                    selectedColor: AppTheme.udoGreen,
                    labelStyle: TextStyle(
                        color: _type == entry.key
                            ? Colors.white
                            : AppTheme.udoTextPrimary,
                        fontSize: 12),
                  ),
              ]),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.udoCrimson))
              ],
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : _delete,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.udoCrimson,
                        side: const BorderSide(color: AppTheme.udoCrimson),
                        minimumSize: const Size(0, 50)),
                    child: const Text('Delete'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.udoGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 50)),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save changes'),
                  ),
                ),
              ]),
            ]),
      );
}

/// Maps a Spoonacular recipe's dietary booleans/diets onto this app's own
/// dietary label strings (`_dietaryRequirementOptions`) so a recipe-derived
/// tag renders identically to one a couple assigns manually to a guest.
List<String> _dietaryTagsFromRecipe(Map<String, dynamic> recipe) {
  final tags = <String>{};
  if (recipe['vegetarian'] == true) tags.add('Vegetarian');
  if (recipe['vegan'] == true) tags.add('Vegan');
  if (recipe['gluten_free'] == true) tags.add('Gluten-Free');
  if (recipe['dairy_free'] == true) tags.add('Dairy-Free');
  for (final diet in (recipe['diets'] as List? ?? const [])) {
    final match = _dietaryRequirementOptions.firstWhere(
      (option) => option.toLowerCase() == diet.toString().toLowerCase(),
      orElse: () => '',
    );
    if (match.isNotEmpty) tags.add(match);
  }
  return tags.toList();
}

Map<String, dynamic> _metadataFromRecipe(Map<String, dynamic> recipe) {
  final cuisines = (recipe['cuisines'] as List?) ?? const [];
  final dishTypes = (recipe['dish_types'] as List?) ?? const [];
  return {
    if (recipe['id'] != null) 'spoonacular_id': recipe['id'],
    if (recipe['image'] != null) 'image_url': recipe['image'],
    if (cuisines.isNotEmpty) 'cuisines': cuisines,
    if (dishTypes.isNotEmpty) 'dish_types': dishTypes,
  };
}

/// A meal-name field backed by Spoonacular recipe search. Degrades to a
/// plain text field with no visible suggestions if the backend has no
/// Spoonacular API key configured (`searchRecipes` just returns `[]` then) —
/// the couple can still type any name freely either way.
class _RecipeSearchField extends StatefulWidget {
  final TextEditingController controller;
  final FoodNotifier notifier;
  final void Function(Map<String, dynamic> recipe) onRecipeSelected;
  final String label;
  const _RecipeSearchField({
    required this.controller,
    required this.notifier,
    required this.onRecipeSelected,
    this.label = 'Meal name',
  });

  @override
  State<_RecipeSearchField> createState() => _RecipeSearchFieldState();
}

class _RecipeSearchFieldState extends State<_RecipeSearchField> {
  Timer? _debounce;
  bool _loadingDetails = false;

  Future<List<Map<String, dynamic>>> _search(String query) {
    if (query.trim().length < 2) return Future.value(const []);
    final completer = Completer<List<Map<String, dynamic>>>();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final results = await widget.notifier.searchRecipes(query.trim());
      if (!completer.isCompleted) completer.complete(results);
    });
    return completer.future;
  }

  Future<void> _onSelected(Map<String, dynamic> recipe) async {
    widget.controller.text = recipe['title']?.toString() ?? '';
    final id = recipe['id'] as int?;
    if (id == null) return;
    setState(() => _loadingDetails = true);
    final details = await widget.notifier.fetchRecipeDetails(id);
    if (!mounted) return;
    setState(() => _loadingDetails = false);
    if (details != null) widget.onRecipeSelected(details);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Map<String, dynamic>>(
      textEditingController: widget.controller,
      optionsBuilder: (value) => _search(value.text),
      displayStringForOption: (option) => option['title']?.toString() ?? '',
      onSelected: (option) => _onSelected(option),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: 'e.g. Grilled Chicken',
            suffixIcon: _loadingDetails
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)))
                : null,
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options.elementAt(index);
                return ListTile(
                  dense: true,
                  title: Text(option['title']?.toString() ?? ''),
                  onTap: () => onSelected(option),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MealOptionRow {
  final TextEditingController name;
  final TextEditingController description;
  List<String>? dietaryTags;
  Map<String, dynamic>? metadata;
  String? imageUrl;
  _MealOptionRow()
      : name = TextEditingController(),
        description = TextEditingController();

  void dispose() {
    name.dispose();
    description.dispose();
  }
}

class _AddCourseSheet extends StatefulWidget {
  final FoodNotifier notifier;
  final String defaultType;
  const _AddCourseSheet({required this.notifier, required this.defaultType});
  @override
  State<_AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends State<_AddCourseSheet> {
  final _name = TextEditingController();
  late String _type = widget.defaultType;
  int _step = 0;
  late final List<_MealOptionRow> _rows = [_MealOptionRow()];
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _goToOptions() {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Give the course a name.');
      return;
    }
    setState(() {
      _error = null;
      _step = 1;
    });
  }

  void _addRow() => setState(() => _rows.add(_MealOptionRow()));

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final courseId = await widget.notifier
        .createCourse(name: _name.text.trim(), type: _type);
    if (courseId == null) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = "Couldn't add this course. Try again.";
      });
      return;
    }
    var allOk = true;
    for (final row in _rows) {
      if (row.name.text.trim().isEmpty) continue;
      final ok = await widget.notifier.createOption(
        courseId: courseId,
        name: row.name.text.trim(),
        description: row.description.text.trim(),
        metadata: row.metadata,
        dietaryTags: row.dietaryTags,
      );
      allOk = allOk && ok;
    }
    if (!mounted) return;
    if (allOk) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error =
            'Course added, but some meal options failed to save. Add them from the course card.';
      });
    }
  }

  Widget _buildStepOne() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New course',
                style: TextStyle(
                    fontFamily: 'Playfair',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.udoGreen)),
            const SizedBox(height: 16),
            TextField(
                controller: _name,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: 'Course name', hintText: 'e.g. Main Courses')),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final entry in _kCourseTypeLabels.entries)
                ChoiceChip(
                  label:
                      Text(entry.value, style: const TextStyle(fontSize: 12)),
                  selected: _type == entry.key,
                  onSelected: (_) => setState(() => _type = entry.key),
                  selectedColor: AppTheme.udoGreen,
                  labelStyle: TextStyle(
                      color: _type == entry.key
                          ? Colors.white
                          : AppTheme.udoTextPrimary,
                      fontSize: 12),
                ),
            ]),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style:
                      const TextStyle(fontSize: 12, color: AppTheme.udoCrimson))
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToOptions,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.udoGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50)),
                child: const Text('Next: add meals'),
              ),
            ),
          ]);

  Widget _buildStepTwo() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              IconButton(
                onPressed: _saving
                    ? null
                    : () => setState(() {
                          _error = null;
                          _step = 0;
                        }),
                icon: const Icon(Icons.arrow_back),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Add meals to ${_name.text.trim()}',
                    style: const TextStyle(
                        fontFamily: 'Playfair',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.udoGreen)),
              ),
            ]),
            const SizedBox(height: 4),
            const Text('Leave a row blank to skip it — you can add more later.',
                style:
                    TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
            const SizedBox(height: 14),
            for (var i = 0; i < _rows.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(children: [
                          _RecipeSearchField(
                            controller: _rows[i].name,
                            notifier: widget.notifier,
                            onRecipeSelected: (recipe) => setState(() {
                              _rows[i].dietaryTags =
                                  _dietaryTagsFromRecipe(recipe);
                              _rows[i].metadata = _metadataFromRecipe(recipe);
                              _rows[i].imageUrl = recipe['image'] as String?;
                            }),
                          ),
                          if (_rows[i].imageUrl != null) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(_rows[i].imageUrl!,
                                    width: 56, height: 56, fit: BoxFit.cover),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          TextField(
                              controller: _rows[i].description,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                  labelText: 'Description (optional)')),
                        ]),
                      ),
                      IconButton(
                        onPressed:
                            _rows.length > 1 ? () => _removeRow(i) : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                    ]),
              ),
            TextButton.icon(
              onPressed: _addRow,
              icon: const Icon(Icons.add),
              label: const Text('Add another meal'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!,
                  style:
                      const TextStyle(fontSize: 12, color: AppTheme.udoCrimson))
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.udoGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50)),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Add course'),
              ),
            ),
          ]);

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppTheme.udoBorder,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                _step == 0 ? _buildStepOne() : _buildStepTwo(),
              ]),
        ),
      );
}

class _AddOptionSheet extends StatefulWidget {
  final int courseId;
  final FoodNotifier notifier;
  const _AddOptionSheet({required this.courseId, required this.notifier});
  @override
  State<_AddOptionSheet> createState() => _AddOptionSheetState();
}

class _AddOptionSheetState extends State<_AddOptionSheet> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  List<String>? _dietaryTags;
  Map<String, dynamic>? _metadata;
  String? _imageUrl;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Give the option a name.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await widget.notifier.createOption(
        courseId: widget.courseId,
        name: _name.text.trim(),
        description: _description.text.trim(),
        metadata: _metadata,
        dietaryTags: _dietaryTags);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't add this option. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppTheme.udoBorder,
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('New menu option',
                  style: TextStyle(
                      fontFamily: 'Playfair',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.udoGreen)),
              const SizedBox(height: 4),
              const Text('New options start unconfirmed until you review them.',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.udoTextSecondary)),
              const SizedBox(height: 16),
              _RecipeSearchField(
                controller: _name,
                notifier: widget.notifier,
                label: 'Option name',
                onRecipeSelected: (recipe) => setState(() {
                  _dietaryTags = _dietaryTagsFromRecipe(recipe);
                  _metadata = _metadataFromRecipe(recipe);
                  _imageUrl = recipe['image'] as String?;
                }),
              ),
              if (_imageUrl != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(_imageUrl!,
                      width: 56, height: 56, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                  controller: _description,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Description (optional)')),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.udoCrimson))
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.udoGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50)),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Add option'),
                ),
              ),
            ]),
      );
}

class _AddDrinkSheet extends StatefulWidget {
  final FoodNotifier notifier;
  final List<Map<String, dynamic>> courses;
  const _AddDrinkSheet({required this.notifier, required this.courses});

  @override
  State<_AddDrinkSheet> createState() => _AddDrinkSheetState();
}

class _AddDrinkSheetState extends State<_AddDrinkSheet> {
  final _qty = TextEditingController();
  final _notes = TextEditingController();
  String? _category;
  String? _beverageType;
  String? _serviceType;
  String? _unit;
  final Set<String> _tags = {};
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _qty.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_category == null || _beverageType == null) {
      setState(() => _error = 'Choose a drink category and beverage type.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    final existing = widget.courses.firstWhere(
      (c) => c['type'] == 'drinks' && c['name'] == _category,
      orElse: () => const {},
    );
    var courseId = existing['id'] as int?;
    courseId ??=
        await widget.notifier.createCourse(name: _category!, type: 'drinks');
    if (courseId == null) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = "Couldn't save this drink category. Try again.";
      });
      return;
    }

    final metadata = <String, dynamic>{
      if (_serviceType != null) 'service_type': _serviceType,
      if (_qty.text.trim().isNotEmpty)
        'quantity': double.tryParse(_qty.text.trim()),
      if (_unit != null) 'unit': _unit,
      if (_tags.isNotEmpty) 'tags': _tags.toList(),
    };

    final ok = await widget.notifier.createOption(
      courseId: courseId,
      name: _beverageType!,
      description: _notes.text.trim(),
      metadata: metadata,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't add this drink. Try again.";
      });
    }
  }

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text('Add Drinks',
                          style: TextStyle(
                              fontFamily: 'Playfair',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: UdoDesign.amber)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                    ),
                  ]),
                  const SizedBox(height: 16),
                  const Text('Drink category',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    isExpanded: true,
                    menuMaxHeight: 360,
                    decoration: _decoration('Select category'),
                    hint: const Text('Select category'),
                    items: _drinkCategoryOptions
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v),
                  ),
                  const SizedBox(height: 14),
                  const Text('Beverage type',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _beverageType,
                    isExpanded: true,
                    menuMaxHeight: 360,
                    decoration: _decoration('Select beverage type'),
                    hint: const Text('Select beverage type'),
                    items: _beverageTypeOptions
                        .map((b) => DropdownMenuItem(
                            value: b,
                            child: Text(b, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) => setState(() => _beverageType = v),
                  ),
                  const SizedBox(height: 14),
                  const Text('Service type',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _serviceType,
                    isExpanded: true,
                    menuMaxHeight: 360,
                    decoration: _decoration('Select service type'),
                    hint: const Text('Select service type'),
                    items: _drinkServiceTypeOptions
                        .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) => setState(() => _serviceType = v),
                  ),
                  const SizedBox(height: 14),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estimated qty',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            TextField(
                                controller: _qty,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: _decoration('e.g. 100')),
                          ]),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Unit',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _unit,
                              isExpanded: true,
                              menuMaxHeight: 360,
                              decoration: _decoration('Select unit'),
                              hint: const Text('Select unit'),
                              items: _drinkUnitOptions
                                  .map((u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(u,
                                          overflow: TextOverflow.ellipsis)))
                                  .toList(),
                              onChanged: (v) => setState(() => _unit = v),
                            ),
                          ]),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  const Text('Notes (optional)',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                      controller: _notes,
                      maxLines: 2,
                      decoration: _decoration('Add any notes...')),
                  const SizedBox(height: 14),
                  const Text('Tags (optional)',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in _drinkTagOptions)
                        FilterChip(
                          label:
                              Text(tag, style: const TextStyle(fontSize: 12)),
                          selected: _tags.contains(tag),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              _tags.add(tag);
                            } else {
                              _tags.remove(tag);
                            }
                          }),
                          selectedColor: UdoDesign.amber,
                          labelStyle: TextStyle(
                              color: _tags.contains(tag)
                                  ? Colors.white
                                  : AppTheme.udoTextPrimary,
                              fontSize: 12),
                        ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.udoCrimson)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: UdoDesign.amber,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50)),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Add Drink'),
                    ),
                  ),
                ]),
          ),
        ),
      );
}

class _AddServiceSheet extends StatefulWidget {
  final FoodNotifier notifier;
  final List<String> timelineEventTitles;
  const _AddServiceSheet(
      {required this.notifier, required this.timelineEventTitles});

  @override
  State<_AddServiceSheet> createState() => _AddServiceSheetState();
}

class _AddServiceSheetState extends State<_AddServiceSheet> {
  final _customCategory = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  final _notes = TextEditingController();
  String? _eventCategory;
  String? _serviceCategory;
  String? _serviceType;
  String? _assignedTo;
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _customCategory.dispose();
    _location.dispose();
    _description.dispose();
    _notes.dispose();
    super.dispose();
  }

  List<String> get _eventCategoryChoices => {
        ...widget.timelineEventTitles,
        ..._eventCategoryOptions,
      }.toList();

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    final category = _eventCategory == _createServiceCategorySentinel
        ? _customCategory.text.trim()
        : _eventCategory;
    if (category == null || category.isEmpty) {
      setState(() => _error = 'Choose or enter an event category.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await widget.notifier.createServiceItem(
      eventCategory: category,
      serviceCategory: _serviceCategory,
      serviceType: _serviceType,
      eventDate: _date == null ? null : _formatDate(_date!),
      startTime: _startTime == null ? null : _fmtTime(_startTime!),
      endTime: _endTime == null ? null : _fmtTime(_endTime!),
      location: _location.text.trim(),
      description: _description.text.trim(),
      assignedTo: _assignedTo,
      notes: _notes.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't add this service. Try again.";
      });
    }
  }

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    final serviceTypeChoices =
        _serviceTypeOptionsByCategory[_serviceCategory] ?? const <String>[];
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text('Add Service',
                        style: TextStyle(
                            fontFamily: 'Playfair',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: UdoDesign.amber)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                  ),
                ]),
                const SizedBox(height: 16),
                const Text('Event category',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _eventCategory,
                  isExpanded: true,
                  menuMaxHeight: 360,
                  decoration: _decoration('Select event category'),
                  hint: const Text('Select event category'),
                  items: [
                    for (final c in _eventCategoryChoices)
                      DropdownMenuItem(
                          value: c,
                          child: Text(c, overflow: TextOverflow.ellipsis)),
                    const DropdownMenuItem(
                      value: _createServiceCategorySentinel,
                      child: Text('+ Create custom category'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _eventCategory = v),
                ),
                if (_eventCategory == _createServiceCategorySentinel) ...[
                  const SizedBox(height: 10),
                  TextField(
                      controller: _customCategory,
                      decoration: _decoration('e.g. Guest Welcome Bags')),
                ],
                const SizedBox(height: 14),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Service category',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _serviceCategory,
                            isExpanded: true,
                            menuMaxHeight: 360,
                            decoration: _decoration('Select service category'),
                            hint: const Text('Select service category'),
                            items: _serviceCategoryOptions
                                .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c,
                                        overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (v) => setState(() {
                              _serviceCategory = v;
                              _serviceType = null;
                            }),
                          ),
                        ]),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Service type',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _serviceType,
                            isExpanded: true,
                            menuMaxHeight: 360,
                            decoration: _decoration(_serviceCategory == null
                                ? 'Pick a category first'
                                : 'Select service type'),
                            hint: Text(_serviceCategory == null
                                ? 'Pick a category first'
                                : 'Select service type'),
                            items: serviceTypeChoices
                                .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t,
                                        overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: _serviceCategory == null
                                ? null
                                : (v) => setState(() => _serviceType = v),
                          ),
                        ]),
                  ),
                ]),
                const SizedBox(height: 14),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _date ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (picked != null)
                                setState(() => _date = picked);
                            },
                            icon: const Icon(Icons.calendar_month_outlined,
                                size: 16),
                            label: Text(
                                _date == null
                                    ? 'Select date'
                                    : _formatDate(_date!),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ]),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start time (optional)',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _startTime ?? TimeOfDay.now(),
                              );
                              if (picked != null) {
                                setState(() => _startTime = picked);
                              }
                            },
                            icon: const Icon(Icons.schedule_outlined, size: 16),
                            label: Text(
                                _startTime == null
                                    ? 'Select time'
                                    : _startTime!.format(context),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ]),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('End time (optional)',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _endTime ?? TimeOfDay.now(),
                              );
                              if (picked != null)
                                setState(() => _endTime = picked);
                            },
                            icon: const Icon(Icons.schedule_outlined, size: 16),
                            label: Text(
                                _endTime == null
                                    ? 'Select time'
                                    : _endTime!.format(context),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ]),
                  ),
                ]),
                const SizedBox(height: 14),
                const Text('Location',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                    controller: _location,
                    decoration: _decoration('Enter location')),
                const SizedBox(height: 14),
                const Text('Description (optional)',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                    controller: _description,
                    maxLines: 2,
                    decoration: _decoration('Add service details...')),
                const SizedBox(height: 14),
                const Text('Assigned to (optional)',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _assignedTo,
                  isExpanded: true,
                  menuMaxHeight: 360,
                  decoration: _decoration('Select person or team'),
                  hint: const Text('Select person or team'),
                  items: _serviceAssignedToOptions
                      .map((a) => DropdownMenuItem(
                          value: a,
                          child: Text(a, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (v) => setState(() => _assignedTo = v),
                ),
                const SizedBox(height: 14),
                const Text('Notes (optional)',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                    controller: _notes,
                    maxLines: 2,
                    decoration: _decoration('Add any notes...')),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.udoCrimson)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: UdoDesign.amber,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50)),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Add Service'),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

class _EditOptionSheet extends StatefulWidget {
  final Map<String, dynamic> option;
  final FoodNotifier notifier;
  const _EditOptionSheet({required this.option, required this.notifier});
  @override
  State<_EditOptionSheet> createState() => _EditOptionSheetState();
}

class _EditOptionSheetState extends State<_EditOptionSheet> {
  late final _name =
      TextEditingController(text: widget.option['name']?.toString() ?? '');
  late final _description = TextEditingController(
      text: widget.option['description']?.toString() ?? '');
  late bool _confirmed = widget.option['confirmed'] == true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Give the option a name.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await widget.notifier.updateOption(
      optionId: widget.option['id'] as int,
      name: _name.text.trim(),
      description: _description.text.trim(),
      confirmed: _confirmed,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't update this option. Try again.";
      });
    }
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    final ok = await widget.notifier.deleteOption(widget.option['id'] as int);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't delete this option. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppTheme.udoBorder,
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Edit menu option',
                  style: TextStyle(
                      fontFamily: 'Playfair',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.udoGreen)),
              const SizedBox(height: 16),
              TextField(
                  controller: _name,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Option name')),
              const SizedBox(height: 12),
              TextField(
                  controller: _description,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Description (optional)')),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _confirmed,
                onChanged: (value) => setState(() => _confirmed = value),
                activeThumbColor: AppTheme.udoGreen,
                contentPadding: EdgeInsets.zero,
                title: const Text('Confirmed'),
                subtitle: const Text(
                    'Confirmed options are ready for guest selections.'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.udoCrimson))
              ],
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : _delete,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.udoCrimson,
                        side: const BorderSide(color: AppTheme.udoCrimson),
                        minimumSize: const Size(0, 50)),
                    child: const Text('Delete'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.udoGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 50)),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save changes'),
                  ),
                ),
              ]),
            ]),
      );
}

class _DietaryOverviewSheet extends StatelessWidget {
  final List<Map<String, dynamic>> guests;
  final BuildContext launcherContext;
  const _DietaryOverviewSheet({
    required this.guests,
    required this.launcherContext,
  });

  Future<void> _assignDietary(BuildContext context) async {
    final guestId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _GuestPickerSheet(guests: guests),
    );
    if (guestId == null || !context.mounted) return;
    final guest = guests.firstWhere((g) => _asIntId(g['id']) == guestId,
        orElse: () => {'id': guestId});
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _DietaryTagPickerSheet(guest: guest),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tally = _dietaryTally(guests);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dietary needs',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _assignDietary(launcherContext));
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Assign dietary needs'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.udoGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Current breakdown',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                if (tally.isEmpty)
                  const Text('No dietary needs recorded yet.',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.udoTextSecondary))
                else
                  for (final entry in tally.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(children: [
                        Expanded(
                            child: Text(entry.key,
                                style: const TextStyle(fontSize: 14))),
                        Text('${entry.value}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.udoGreen)),
                      ]),
                    ),
              ]),
        ),
      ),
    );
  }
}

class _DietaryTagPickerSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> guest;
  const _DietaryTagPickerSheet({required this.guest});

  @override
  ConsumerState<_DietaryTagPickerSheet> createState() =>
      _DietaryTagPickerSheetState();
}

class _DietaryTagPickerSheetState
    extends ConsumerState<_DietaryTagPickerSheet> {
  late final Set<String> _selected = {
    ...((widget.guest['dietary_tags'] as List?) ?? const [])
        .map((t) => t.toString()),
  };
  final _allergyOtherCtrl = TextEditingController();
  final _dietaryOtherCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final tag in _selected) {
      if (tag.startsWith('Other (Allergy): ')) {
        _allergyOtherCtrl.text = tag.substring('Other (Allergy): '.length);
      } else if (tag.startsWith('Other (Dietary): ')) {
        _dietaryOtherCtrl.text = tag.substring('Other (Dietary): '.length);
      }
    }
  }

  @override
  void dispose() {
    _allergyOtherCtrl.dispose();
    _dietaryOtherCtrl.dispose();
    super.dispose();
  }

  bool _isOtherAllergySelected() =>
      _selected.any((t) => t.startsWith('Other (Allergy): '));
  bool _isOtherDietarySelected() =>
      _selected.any((t) => t.startsWith('Other (Dietary): '));

  void _toggle(String option, {required String otherPrefix}) {
    setState(() {
      if (option == 'Other (Specify)') {
        final hasOther = _selected.any((t) => t.startsWith(otherPrefix));
        if (hasOther) {
          _selected.removeWhere((t) => t.startsWith(otherPrefix));
        } else {
          _selected.add('$otherPrefix ');
        }
        return;
      }
      if (_selected.contains(option)) {
        _selected.remove(option);
      } else {
        _selected.add(option);
      }
    });
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final tags = <String>{};
    for (final tag in _selected) {
      if (tag.startsWith('Other (Allergy):')) {
        final text = _allergyOtherCtrl.text.trim();
        if (text.isNotEmpty) tags.add('Other (Allergy): $text');
      } else if (tag.startsWith('Other (Dietary):')) {
        final text = _dietaryOtherCtrl.text.trim();
        if (text.isNotEmpty) tags.add('Other (Dietary): $text');
      } else {
        tags.add(tag);
      }
    }
    final guestId = _asIntId(widget.guest['id']);
    if (guestId == null) {
      setState(() {
        _saving = false;
        _error = "Couldn't identify this guest. Try opening the guest again.";
      });
      return;
    }
    final ok = await ref
        .read(guestsProvider.notifier)
        .updateGuest(guestId, {'dietary_tags': tags.toList()});
    if (ok) {
      await ref.read(foodProvider.notifier).refresh();
    }
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save dietary needs. Try again.";
      });
    }
  }

  Widget _buildSection(String title, List<String> options,
      {required String otherPrefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              FilterChip(
                label: Text(option, style: const TextStyle(fontSize: 12)),
                selected: option == 'Other (Specify)'
                    ? _selected.any((t) => t.startsWith(otherPrefix))
                    : _selected.contains(option),
                onSelected: (_) => _toggle(option, otherPrefix: otherPrefix),
                selectedColor: AppTheme.udoGreen,
                labelStyle: TextStyle(
                    color: (option == 'Other (Specify)'
                            ? _selected.any((t) => t.startsWith(otherPrefix))
                            : _selected.contains(option))
                        ? Colors.white
                        : AppTheme.udoTextPrimary,
                    fontSize: 12),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final name =
        '${widget.guest['first_name'] ?? ''} ${widget.guest['last_name'] ?? ''}'
            .trim();
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppTheme.udoBorder,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text('Dietary needs for ${name.isEmpty ? 'this guest' : name}',
                    style: const TextStyle(
                        fontFamily: 'Playfair',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.udoGreen)),
                const SizedBox(height: 16),
                _buildSection('Allergies', _dietaryAllergyOptions,
                    otherPrefix: 'Other (Allergy):'),
                if (_isOtherAllergySelected()) ...[
                  const SizedBox(height: 10),
                  TextField(
                      controller: _allergyOtherCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Specify allergy', hintText: 'e.g. Kiwi')),
                ],
                const SizedBox(height: 16),
                _buildSection(
                    'Dietary Requirements', _dietaryRequirementOptions,
                    otherPrefix: 'Other (Dietary):'),
                if (_isOtherDietarySelected()) ...[
                  const SizedBox(height: 10),
                  TextField(
                      controller: _dietaryOtherCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Specify requirement',
                          hintText: 'e.g. FODMAP-friendly')),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.udoCrimson)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.udoGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50)),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save dietary needs'),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}

class _GuestPickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> guests;
  final void Function(int guestId)? onPicked;
  const _GuestPickerSheet({required this.guests, this.onPicked});
  @override
  State<_GuestPickerSheet> createState() => _GuestPickerSheetState();
}

class _GuestPickerSheetState extends State<_GuestPickerSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.guests.where((g) {
      if (_search.trim().isEmpty) return true;
      final name =
          '${g['first_name'] ?? ''} ${g['last_name'] ?? ''}'.toLowerCase();
      return name.contains(_search.trim().toLowerCase());
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select a guest',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: const InputDecoration(
                    hintText: 'Search guests',
                    prefixIcon: Icon(Icons.search, size: 18),
                    isDense: true),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5),
                child: filtered.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('No guests found.',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.udoTextSecondary)))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final g = filtered[i];
                          final name =
                              '${g['first_name'] ?? ''} ${g['last_name'] ?? ''}'
                                  .trim();
                          return ListTile(
                            title: Text(name.isEmpty ? 'Guest' : name),
                            onTap: () {
                              final guestId = _asIntId(g['id']);
                              if (guestId == null) return;
                              widget.onPicked?.call(guestId);
                              Navigator.pop(context, guestId);
                            },
                          );
                        },
                      ),
              ),
            ]),
      ),
    );
  }
}

// ── WEDDING WEEKEND TAB ────────────────────────────────────────────────────────

class _WeddingWeekendTab extends ConsumerStatefulWidget {
  const _WeddingWeekendTab();
  @override
  ConsumerState<_WeddingWeekendTab> createState() => _WeddingWeekendTabState();
}

class _WeddingWeekendTabState extends ConsumerState<_WeddingWeekendTab> {
  DateTime? _selectedDay;

  int _guestCountForAudience(
      List<Map<String, dynamic>> guests, String? audience) {
    switch (audience) {
      case 'all':
        return guests.where((g) => g['attending_status'] == 'yes').length;
      case 'wedding_party':
        return guests
            .where((g) =>
                g['attending_status'] == 'yes' &&
                g['guest_group'] == 'wedding_party')
            .length;
      case 'vip':
        return guests
            .where(
                (g) => g['attending_status'] == 'yes' && g['vip_flag'] == true)
            .length;
      case 'travelling':
        return guests
            .where((g) =>
                g['attending_status'] == 'yes' && g['travel_required'] == true)
            .length;
      default:
        // family/selected/private have no reliable guest-field mapping —
        // skip rather than guess, so the total stays honest.
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weddingWeekendProvider);
    final notifier = ref.read(weddingWeekendProvider.notifier);
    final guests = ref.watch(guestsProvider).guests;

    if (state.isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));

    final events = [...state.events]..sort((a, b) {
        final ad = a['event_date'] as String? ?? '';
        final bd = b['event_date'] as String? ?? '';
        final cmp = ad.compareTo(bd);
        if (cmp != 0) return cmp;
        return (a['start_time'] as String? ?? '')
            .compareTo(b['start_time'] as String? ?? '');
      });

    final days = events
        .map((e) => e['event_date'] as String?)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    final needsAttention = events
        .where((e) =>
            (e['location'] == null || (e['location'] as String).isEmpty) ||
            e['start_time'] == null)
        .length;
    final guestAttendances = events.fold<int>(
        0,
        (sum, e) =>
            sum + _guestCountForAudience(guests, e['audience'] as String?));
    final venuesBooked = events
        .map((e) => e['location'] as String?)
        .where((l) => l != null && l.isNotEmpty)
        .toSet()
        .length;

    final visibleEvents = _selectedDay == null
        ? events
        : events
            .where((e) => e['event_date'] == _fmtDate(_selectedDay!))
            .toList();
    final rebuiltWeekend = _WeekendRedesignPage(
      events: events,
      visibleEvents: visibleEvents,
      days: days,
      selectedDay: _selectedDay,
      guestAttendances: guestAttendances,
      needsAttention: needsAttention,
      venuesBooked: venuesBooked,
      onSelectAll: () => setState(() => _selectedDay = null),
      onSelectDay: (day) => setState(() => _selectedDay = day),
      onAddEvent: () => _showAddEventSheet(context, notifier),
      onSendUpdate: () => _showSendUpdateSheet(context),
      onExport: () => _exportItinerary(events),
      onEditEvent: (event) =>
          _showAddEventSheet(context, notifier, existing: event),
      onDeleteEvent: (event) => notifier.delete(event['id'] as int),
      dayLabelFor: _fmtDayLabel,
      parseDay: (raw) => DateTime.parse(raw),
    );
    if (MediaQuery.sizeOf(context).width >= 0) {
      return rebuiltWeekend;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: AppTheme.udoGreen,
              borderRadius: BorderRadius.circular(20)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Weekend overview',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _WeekendStat('${events.length}', 'Events')),
              Expanded(child: _WeekendStat('$guestAttendances', 'Guests')),
              Expanded(
                  child: _WeekendStat('$needsAttention', 'Needs attention')),
              Expanded(child: _WeekendStat('$venuesBooked', 'Venues')),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        if (needsAttention > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppTheme.udoCrimson.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14)),
            child: Text(
                '$needsAttention event${needsAttention == 1 ? '' : 's'} need attention',
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.udoCrimson,
                    fontWeight: FontWeight.w500)),
          ),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _QuickActionChip(
              icon: Icons.add,
              label: 'Add event',
              onTap: () => _showAddEventSheet(context, notifier)),
          _QuickActionChip(
              icon: Icons.campaign_outlined,
              label: 'Send update',
              onTap: () => _showSendUpdateSheet(context)),
          _QuickActionChip(
              icon: Icons.ios_share_outlined,
              label: 'Export itinerary',
              onTap: () => _exportItinerary(events)),
        ]),
        const SizedBox(height: 16),
        if (events.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.udoBorder)),
            child: Column(children: [
              const Text('0 events planned. Plan your wedding weekend.',
                  style: TextStyle(fontSize: 14), textAlign: TextAlign.center),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => _showAddEventSheet(context, notifier),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add event'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: AppTheme.udoGreen,
                    foregroundColor: Colors.white),
              ),
            ]),
          )
        else ...[
          if (days.length > 1)
            SizedBox(
              height: 64,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _DayChip(
                      label: 'All',
                      selected: _selectedDay == null,
                      onTap: () => setState(() => _selectedDay = null)),
                  for (final d in days)
                    _DayChip(
                      label: _fmtDayLabel(DateTime.parse(d)),
                      selected:
                          _selectedDay != null && _fmtDate(_selectedDay!) == d,
                      onTap: () =>
                          setState(() => _selectedDay = DateTime.parse(d)),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(children: [
            const Expanded(
                child: Text('Events',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
            TextButton.icon(
                onPressed: () => _showAddEventSheet(context, notifier),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add event')),
          ]),
          for (final e in visibleEvents)
            _WeekendEventCard(
              event: e,
              onTap: () => _showAddEventSheet(context, notifier, existing: e),
              onDelete: () => notifier.delete(e['id'] as int),
            ),
        ],
      ],
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _fmtDayLabel(DateTime d) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${weekdays[d.weekday - 1]}\n${d.day} ${months[d.month - 1]}';
  }

  void _showAddEventSheet(BuildContext context, WeddingWeekendNotifier notifier,
      {Map<String, dynamic>? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) =>
          _AddWeekendEventSheet(notifier: notifier, existing: existing),
    );
  }

  void _showSendUpdateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _WeekendSendUpdateSheet(),
    );
  }

  void _exportItinerary(List<Map<String, dynamic>> events) {
    final buffer = StringBuffer('Title,Date,Start,End,Location,Audience\n');
    for (final e in events) {
      buffer.writeln([
        e['title'] ?? '',
        e['event_date'] ?? '',
        e['start_time'] ?? '',
        e['end_time'] ?? '',
        e['location'] ?? '',
        e['audience'] ?? '',
      ].join(','));
    }
    Share.share(buffer.toString(), subject: 'Wedding weekend itinerary');
  }
}

class _WeekendRedesignPage extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> visibleEvents;
  final List<String> days;
  final DateTime? selectedDay;
  final int guestAttendances;
  final int needsAttention;
  final int venuesBooked;
  final VoidCallback onSelectAll;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onAddEvent;
  final VoidCallback onSendUpdate;
  final VoidCallback onExport;
  final ValueChanged<Map<String, dynamic>> onEditEvent;
  final ValueChanged<Map<String, dynamic>> onDeleteEvent;
  final String Function(DateTime day) dayLabelFor;
  final DateTime Function(String raw) parseDay;

  const _WeekendRedesignPage({
    required this.events,
    required this.visibleEvents,
    required this.days,
    required this.selectedDay,
    required this.guestAttendances,
    required this.needsAttention,
    required this.venuesBooked,
    required this.onSelectAll,
    required this.onSelectDay,
    required this.onAddEvent,
    required this.onSendUpdate,
    required this.onExport,
    required this.onEditEvent,
    required this.onDeleteEvent,
    required this.dayLabelFor,
    required this.parseDay,
  });

  @override
  Widget build(BuildContext context) {
    final transportEvents = events.where((event) {
      final type = (event['event_type'] ?? event['title'] ?? '')
          .toString()
          .toLowerCase();
      return type.contains('transport') ||
          type.contains('shuttle') ||
          type.contains('arrival');
    }).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 128),
      children: [
        _WeekendHeroCard(
          events: events.length,
          guests: guestAttendances,
          days: days.isEmpty ? 0 : days.length,
          needsAttention: needsAttention,
        ),
        if (needsAttention > 0) ...[
          const SizedBox(height: 12),
          _WeekendAttentionBanner(count: needsAttention),
        ],
        const SizedBox(height: 14),
        _WeekendMetricGrid(
          events: events.length,
          guests: guestAttendances,
          venues: venuesBooked,
          transport: transportEvents,
        ),
        const SizedBox(height: 18),
        UdoSectionHeader(
          title: 'Weekend operations',
          subtitle: 'Events, guest updates, itinerary export',
        ),
        _WeekendActionGrid(
          onAddEvent: onAddEvent,
          onSendUpdate: onSendUpdate,
          onExport: onExport,
        ),
        const SizedBox(height: 18),
        if (days.length > 1)
          SizedBox(
            height: 58,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              _WeekendDayFilter(
                  label: 'All',
                  selected: selectedDay == null,
                  onTap: onSelectAll),
              for (final rawDay in days)
                _WeekendDayFilter(
                  label: dayLabelFor(parseDay(rawDay)),
                  selected: selectedDay != null &&
                      '${selectedDay!.year}-${selectedDay!.month.toString().padLeft(2, '0')}-${selectedDay!.day.toString().padLeft(2, '0')}' ==
                          rawDay,
                  onTap: () => onSelectDay(parseDay(rawDay)),
                ),
            ]),
          ),
        if (days.length > 1) const SizedBox(height: 14),
        UdoSectionHeader(
          title: 'Itinerary',
          subtitle:
              '${visibleEvents.length} event${visibleEvents.length == 1 ? '' : 's'} visible',
          action: 'Add event',
          onAction: onAddEvent,
        ),
        if (events.isEmpty)
          UdoCard(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Icon(Icons.event_available_outlined,
                  size: 36, color: UdoDesign.blue),
              const SizedBox(height: 10),
              Text('No weekend events planned yet',
                  style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(
                'Plan welcome drinks, rehearsal dinner, transport, brunch, and guest communications.',
                textAlign: TextAlign.center,
                style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onAddEvent,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add event'),
              ),
            ]),
          )
        else
          for (final event in visibleEvents)
            _WeekendRedesignEventCard(
              event: event,
              onTap: () => onEditEvent(event),
              onDelete: () => onDeleteEvent(event),
            ),
        const SizedBox(height: 18),
        _WeekendCommunicationPanel(
          guestAttendances: guestAttendances,
          onSendUpdate: onSendUpdate,
          onExport: onExport,
        ),
      ],
    );
  }
}

class _WeekendHeroCard extends StatelessWidget {
  final int events;
  final int guests;
  final int days;
  final int needsAttention;

  const _WeekendHeroCard({
    required this.events,
    required this.guests,
    required this.days,
    required this.needsAttention,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      color: UdoDesign.blue,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your Wedding Weekend',
            style: UdoDesign.sans(
                size: 11, weight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 8),
        Text('Every celebration, coordinated',
            style: UdoDesign.serif(
                size: 24, weight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 12),
        Row(children: [
          _WeekendHeroStat(label: 'Events', value: '$events'),
          _WeekendHeroStat(label: 'Guests', value: '$guests'),
          _WeekendHeroStat(label: 'Days', value: '$days'),
          _WeekendHeroStat(label: 'Alerts', value: '$needsAttention'),
        ]),
      ]),
    );
  }
}

class _WeekendHeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _WeekendHeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: UdoDesign.sans(
                size: 20, weight: FontWeight.w800, color: Colors.white)),
        Text(label,
            style: UdoDesign.sans(
                size: 10, color: Colors.white.withValues(alpha: 0.66))),
      ]),
    );
  }
}

class _WeekendAttentionBanner extends StatelessWidget {
  final int count;
  const _WeekendAttentionBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      color: UdoDesign.rose.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: UdoDesign.rose),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$count event${count == 1 ? '' : 's'} need time or location details',
            style: UdoDesign.sans(
                size: 13, weight: FontWeight.w700, color: UdoDesign.rose),
          ),
        ),
      ]),
    );
  }
}

class _WeekendMetricGrid extends StatelessWidget {
  final int events;
  final int guests;
  final int venues;
  final int transport;

  const _WeekendMetricGrid({
    required this.events,
    required this.guests,
    required this.venues,
    required this.transport,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Events', '$events', Icons.event_outlined, UdoDesign.blue),
      ('Guests', '$guests', Icons.groups_outlined, UdoDesign.sage),
      ('Venues', '$venues', Icons.location_city_outlined, UdoDesign.gold),
      (
        'Transport',
        '$transport',
        Icons.directions_bus_outlined,
        UdoDesign.amber
      ),
    ];
    return Row(children: [
      for (final metric in metrics)
        Expanded(
          child: UdoCard(
            margin: const EdgeInsets.only(right: 7),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(children: [
              Icon(metric.$3, size: 18, color: metric.$4),
              const SizedBox(height: 5),
              Text(metric.$2,
                  style: UdoDesign.sans(
                      size: 15, weight: FontWeight.w800, color: metric.$4)),
              Text(metric.$1,
                  style: UdoDesign.sans(size: 10, color: UdoDesign.muted)),
            ]),
          ),
        ),
    ]);
  }
}

class _WeekendActionGrid extends StatelessWidget {
  final VoidCallback onAddEvent;
  final VoidCallback onSendUpdate;
  final VoidCallback onExport;

  const _WeekendActionGrid({
    required this.onAddEvent,
    required this.onSendUpdate,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Add event', Icons.add, onAddEvent),
      ('Send update', Icons.campaign_outlined, onSendUpdate),
      ('Export', Icons.ios_share_outlined, onExport),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final action in actions)
          ActionChip(
            avatar: Icon(action.$2, size: 16, color: UdoDesign.blue),
            label: Text(action.$1),
            onPressed: action.$3,
          ),
      ],
    );
  }
}

class _WeekendDayFilter extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _WeekendDayFilter({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _WeekendRedesignEventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _WeekendRedesignEventCard({
    required this.event,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = (event['title'] ?? 'Weekend event').toString();
    final date = _weekendDisplayDate(event['event_date']);
    final time =
        _weekendDisplayTimeRange(event['start_time'], event['end_time']);
    final location = (event['location'] ?? '').toString();
    final audience = _humanizeStatus(event['audience'] as String?) ?? 'Guests';
    final status = _humanizeStatus(event['status'] as String?) ?? 'Planned';
    final needsAttention = location.isEmpty || time.isEmpty;

    return UdoCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (needsAttention ? UdoDesign.rose : UdoDesign.blue)
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(Icons.celebration_outlined,
              color: needsAttention ? UdoDesign.rose : UdoDesign.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
              ),
              UdoBadge(
                  label: status,
                  color: needsAttention ? UdoDesign.rose : UdoDesign.blue),
            ]),
            const SizedBox(height: 4),
            Text(
              [
                if (date.isNotEmpty) date,
                if (time.isNotEmpty) time,
                if (location.isNotEmpty) location,
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(size: 12, color: UdoDesign.muted),
            ),
            const SizedBox(height: 6),
            Text(audience,
                style: UdoDesign.sans(size: 11, color: UdoDesign.sub)),
          ]),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 18),
          color: UdoDesign.muted,
        ),
      ]),
    );
  }
}

String _weekendDisplayDate(dynamic raw) {
  return udo_dates.formatApiDate(raw);
}

String _weekendDisplayTime(dynamic raw) {
  return udo_dates.formatApiTime(raw);
}

String _weekendDisplayTimeRange(dynamic start, dynamic end) {
  final startText = _weekendDisplayTime(start);
  final endText = _weekendDisplayTime(end);
  if (startText.isEmpty) return endText;
  if (endText.isEmpty) return startText;
  return '$startText - $endText';
}

class _WeekendCommunicationPanel extends StatelessWidget {
  final int guestAttendances;
  final VoidCallback onSendUpdate;
  final VoidCallback onExport;

  const _WeekendCommunicationPanel({
    required this.guestAttendances,
    required this.onSendUpdate,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text('Guest communications',
                  style: UdoDesign.sans(size: 15, weight: FontWeight.w800))),
          UdoBadge(label: '$guestAttendances guests', color: UdoDesign.blue),
        ]),
        const SizedBox(height: 8),
        Text(
            'Send weekend updates or export a full itinerary for guests and vendors.',
            style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onSendUpdate,
              icon: const Icon(Icons.campaign_outlined, size: 16),
              label: const Text('Send update'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.ios_share_outlined, size: 16),
              label: const Text('Export'),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _WeekendStat extends StatelessWidget {
  final String value, label;
  const _WeekendStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ]);
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DayChip(
      {required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppTheme.udoGreen : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: selected ? AppTheme.udoGreen : AppTheme.udoBorder),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppTheme.udoTextPrimary)),
          ),
        ),
      );
}

class _WeekendEventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _WeekendEventCard(
      {required this.event, required this.onTap, required this.onDelete});

  static const _audienceLabels = {
    'all': 'All Guests',
    'wedding_party': 'Wedding Party',
    'family': 'Family',
    'travelling': 'Travelling',
    'vip': 'VIP',
    'selected': 'Selected',
    'private': 'Private',
  };

  @override
  Widget build(BuildContext context) {
    final missingVenue =
        (event['location'] == null || (event['location'] as String).isEmpty);
    final missingTime = event['start_time'] == null;
    final endTime = event['end_time'] as String?;
    final audience = event['audience'] as String?;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.udoBorder)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(event['title'] as String? ?? '',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  missingTime
                      ? 'Start time missing'
                      : '${event['start_time']}${endTime != null ? ' – $endTime' : ''}',
                  style: TextStyle(
                      fontSize: 12,
                      color: missingTime
                          ? AppTheme.udoCrimson
                          : AppTheme.udoTextSecondary),
                ),
                Text(
                    missingVenue
                        ? 'Venue missing'
                        : (event['location'] as String),
                    style: TextStyle(
                        fontSize: 12,
                        color: missingVenue
                            ? AppTheme.udoCrimson
                            : AppTheme.udoTextSecondary)),
                if (audience != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppTheme.udoGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(_audienceLabels[audience] ?? audience,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.udoGreen,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ])),
          GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.close,
                  size: 18, color: AppTheme.udoTextSecondary)),
        ]),
      ),
    );
  }
}

class _AddWeekendEventSheet extends StatefulWidget {
  final WeddingWeekendNotifier notifier;
  final Map<String, dynamic>? existing;
  const _AddWeekendEventSheet({required this.notifier, this.existing});
  @override
  State<_AddWeekendEventSheet> createState() => _AddWeekendEventSheetState();
}

class _AddWeekendEventSheetState extends State<_AddWeekendEventSheet> {
  late final _title =
      TextEditingController(text: widget.existing?['title'] as String? ?? '');
  late final _location = TextEditingController(
      text: widget.existing?['location'] as String? ?? '');
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _audience;
  bool _saving = false;
  String? _error;

  static const _audienceOptions = {
    'all': 'All Guests',
    'wedding_party': 'Wedding Party',
    'family': 'Family',
    'travelling': 'Travelling',
    'vip': 'VIP',
  };

  @override
  void initState() {
    super.initState();
    final existingDate = widget.existing?['event_date'] as String?;
    _date = existingDate != null ? DateTime.tryParse(existingDate) : null;
    _startTime = _parseTime(widget.existing?['start_time'] as String?);
    _endTime = _parseTime(widget.existing?['end_time'] as String?);
    _audience = widget.existing?['audience'] as String?;
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(children: [
                        Expanded(
                            child: Text(
                                widget.existing == null
                                    ? 'Add event'
                                    : 'Edit event',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600))),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            padding: EdgeInsets.zero),
                      ]),
                      const SizedBox(height: 14),
                      _GField('Event title', _title),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                              context: context,
                              initialDate: _date ?? DateTime.now(),
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 3650)));
                          if (picked != null) setState(() => _date = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                              color: AppTheme.udoCardFill,
                              borderRadius: BorderRadius.circular(14)),
                          child: Row(children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 16, color: AppTheme.udoTextSecondary),
                            const SizedBox(width: 10),
                            Text(
                                _date == null
                                    ? 'Event date'
                                    : '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.udoTextSecondary)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _GField('Location', _location),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                            child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                                context: context,
                                initialTime: _startTime ?? TimeOfDay.now());
                            if (picked != null)
                              setState(() => _startTime = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                                color: AppTheme.udoCardFill,
                                borderRadius: BorderRadius.circular(14)),
                            child: Text(
                                _startTime == null
                                    ? 'Start time'
                                    : _fmtTime(_startTime!),
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.udoTextSecondary)),
                          ),
                        )),
                        const SizedBox(width: 10),
                        Expanded(
                            child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                                context: context,
                                initialTime: _endTime ?? TimeOfDay.now());
                            if (picked != null)
                              setState(() => _endTime = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                                color: AppTheme.udoCardFill,
                                borderRadius: BorderRadius.circular(14)),
                            child: Text(
                                _endTime == null
                                    ? 'End time'
                                    : _fmtTime(_endTime!),
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.udoTextSecondary)),
                          ),
                        )),
                      ]),
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final entry in _audienceOptions.entries)
                          ChoiceChip(
                            label: Text(entry.value,
                                style: const TextStyle(fontSize: 12)),
                            selected: _audience == entry.key,
                            onSelected: (_) => setState(() => _audience =
                                _audience == entry.key ? null : entry.key),
                            selectedColor: AppTheme.udoGreen,
                            labelStyle: TextStyle(
                                color: _audience == entry.key
                                    ? Colors.white
                                    : AppTheme.udoTextPrimary,
                                fontSize: 12),
                          ),
                      ]),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(_error!,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.udoCrimson))
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            backgroundColor: AppTheme.udoGreen,
                            foregroundColor: Colors.white),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text(widget.existing == null
                                ? 'Add event'
                                : 'Save changes'),
                      ),
                    ])))),
      );

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty || _date == null) {
      setState(() => _error = 'Title and date are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final data = {
      'title': _title.text.trim(),
      'event_date':
          '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}',
      if (_location.text.trim().isNotEmpty) 'location': _location.text.trim(),
      if (_startTime != null) 'start_time': _fmtTime(_startTime!),
      if (_endTime != null) 'end_time': _fmtTime(_endTime!),
      if (_audience != null) 'audience': _audience,
    };
    final ok = widget.existing == null
        ? await widget.notifier.create(data)
        : await widget.notifier.update(widget.existing!['id'] as int, data);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save this event. Try again.";
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    super.dispose();
  }
}

class _WeekendSendUpdateSheet extends ConsumerStatefulWidget {
  const _WeekendSendUpdateSheet();
  @override
  ConsumerState<_WeekendSendUpdateSheet> createState() =>
      _WeekendSendUpdateSheetState();
}

class _WeekendSendUpdateSheetState
    extends ConsumerState<_WeekendSendUpdateSheet> {
  final _subject = TextEditingController(text: 'Wedding weekend update');
  final _body = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_body.text.trim().isEmpty) {
      setState(() => _error = 'Write a message first.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await ref.read(messagesProvider.notifier).sendMessage(
          subject: _subject.text.trim(),
          body: _body.text.trim(),
          audience: 'all',
          channel: 'email',
        );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't send this update. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.udoBorder,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Send weekend update',
                style: TextStyle(
                    fontFamily: 'Playfair',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.udoGreen)),
            const SizedBox(height: 16),
            _GField('Subject', _subject),
            const SizedBox(height: 12),
            _GField('Message', _body, maxLines: 4),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(
                      color: AppTheme.udoCrimson, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _send,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.udoGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50)),
                child: _saving
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white)),
                          SizedBox(width: 10),
                          Text('Queueing update...'),
                        ],
                      )
                    : const Text('Send to all guests'),
              ),
            ),
          ]),
    );
  }
}

// ── HONEYMOON TAB ──────────────────────────────────────────────────────────────

const _kHoneymoonTypeMeta = {
  'flight': ('Flight', Icons.flight_outlined, 'Booked'),
  'accommodation': ('Hotel', Icons.hotel_outlined, 'Booked'),
  'activity': ('Activity', Icons.local_activity_outlined, 'Planned'),
  'other': ('Other Item', Icons.list_alt_outlined, 'Planned'),
};

const _kHoneymoonBudgetCategories = [
  'Transportation',
  'Accommodation',
  'Food & Dining',
  'Activities',
  'Shopping',
  'Other',
];

const _kHoneymoonCurrencies = ['USD', 'EUR', 'GBP'];

InputDecoration _pickerDropdownDecoration() => InputDecoration(
      filled: true,
      fillColor: AppTheme.udoCardFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    );

String _honeymoonImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  return url.startsWith('http') ? url : '${AppConstants.apiOrigin}$url';
}

double _honeymoonProgress(HoneymoonState state) {
  final items = state.items;
  final tasks = state.checklistTasks;
  final ratios = <double>[
    if (items.isNotEmpty)
      items.where((i) => i['status'] == 'confirmed').length / items.length,
    if (tasks.isNotEmpty)
      tasks.where((t) => t['completed'] == true).length / tasks.length,
  ];
  if (ratios.isEmpty) return 0;
  return ratios.reduce((a, b) => a + b) / ratios.length;
}

class _HoneymoonTab extends ConsumerWidget {
  final VoidCallback onViewBudget;
  const _HoneymoonTab({required this.onViewBudget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(honeymoonProvider);

    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 128),
      children: [
        if (state.error != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: UdoDesign.rose.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: UdoDesign.rose.withValues(alpha: 0.18))),
            child: Text("Couldn't load honeymoon planning data.",
                style: UdoDesign.sans(size: 13, color: UdoDesign.rose)),
          ),
        _HoneymoonHeroCard(state: state),
        const SizedBox(height: 14),
        _HoneymoonStatRow(state: state),
        const SizedBox(height: 14),
        _HoneymoonUpcomingPlansCard(state: state),
        const SizedBox(height: 14),
        _HoneymoonBudgetCard(state: state, onViewBudget: onViewBudget),
        const SizedBox(height: 14),
        _HoneymoonTravelersCard(state: state),
        const SizedBox(height: 14),
        _HoneymoonChecklistCard(state: state),
      ],
    );
  }
}

class _HoneymoonHeroCard extends ConsumerWidget {
  final HoneymoonState state;
  const _HoneymoonHeroCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = state.trip;
    final hasDestination =
        (trip?['destination'] as String?)?.isNotEmpty == true;
    final destination =
        hasDestination ? trip!['destination'] as String : 'Destination not set';
    final dateLine = (trip?['departure_date'] != null &&
            trip?['return_date'] != null)
        ? '${DateFormat('MMM d').format(DateTime.parse(trip!['departure_date'] as String))} - ${DateFormat('MMM d, yyyy').format(DateTime.parse(trip['return_date'] as String))}'
        : 'Dates not selected';
    final progress = _honeymoonProgress(state);
    final coverUrl = _honeymoonImageUrl(trip?['cover_photo_path'] as String?);
    final travelersCount = state.travelers.length;

    return UdoCard(
      padding: EdgeInsets.zero,
      color: UdoDesign.sage,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (coverUrl.isNotEmpty)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.network(coverUrl,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 12, 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            UdoRingProgress(
              value: progress,
              size: 60,
              color: Colors.white,
              center: Text('${(progress * 100).round()}%',
                  style: UdoDesign.sans(
                      size: 12, weight: FontWeight.w800, color: Colors.white)),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UdoDesign.serif(
                          size: 19,
                          weight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(dateLine,
                      style: UdoDesign.sans(
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.85))),
                  if (travelersCount > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                        '$travelersCount Traveler${travelersCount == 1 ? '' : 's'}',
                        style: UdoDesign.sans(
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ])),
            IconButton(
              onPressed: () => _showTripSheet(context, ref),
              icon: const Icon(Icons.edit_outlined,
                  color: Colors.white, size: 18),
              tooltip: 'Edit trip',
            ),
            IconButton(
              onPressed: () => _pickCoverPhoto(context, ref),
              icon: const Icon(Icons.add_a_photo_outlined,
                  color: Colors.white, size: 18),
              tooltip: 'Cover photo',
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showItinerary(context, state),
              icon: const Icon(Icons.arrow_forward,
                  size: 16, color: Colors.white),
              label: const Text('View Itinerary',
                  style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54)),
            ),
          ),
        ),
      ]),
    );
  }

  void _showTripSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EditTripSheet(
          notifier: ref.read(honeymoonProvider.notifier), trip: state.trip),
    );
  }

  Future<void> _pickCoverPhoto(BuildContext context, WidgetRef ref) async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!context.mounted) return;
    final ok = await ref
        .read(honeymoonProvider.notifier)
        .uploadCoverPhoto(bytes, picked.name);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't upload photo. Try again.")));
    }
  }

  void _showItinerary(BuildContext context, HoneymoonState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _HoneymoonItinerarySheet(state: state),
    );
  }
}

class _HoneymoonStatRow extends StatelessWidget {
  final HoneymoonState state;
  const _HoneymoonStatRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final items = state.items;
    final budgetTotal = state.budgetItems
        .fold<double>(0, (sum, b) => sum + _asDouble(b['estimated_amount']));

    Widget tile(String type) {
      final meta = _kHoneymoonTypeMeta[type]!;
      final typeItems = items.where((i) => i['type'] == type).toList();
      final confirmed =
          typeItems.where((i) => i['status'] == 'confirmed').length;
      return Expanded(
        child: UdoCard(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(children: [
            Icon(meta.$2, size: 18, color: UdoDesign.sage),
            const SizedBox(height: 6),
            Text('$confirmed / ${typeItems.length}',
                style: UdoDesign.sans(size: 13, weight: FontWeight.w800)),
            Text(meta.$1,
                style: UdoDesign.sans(size: 10, color: UdoDesign.muted)),
            Text(meta.$3,
                style: UdoDesign.sans(
                    size: 9, color: UdoDesign.sage, weight: FontWeight.w600)),
          ]),
        ),
      );
    }

    return Row(children: [
      tile('flight'),
      tile('accommodation'),
      tile('activity'),
      Expanded(
        child: UdoCard(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(children: [
            const Icon(Icons.account_balance_wallet_outlined,
                size: 18, color: UdoDesign.gold),
            const SizedBox(height: 6),
            Text(_money(budgetTotal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UdoDesign.sans(size: 13, weight: FontWeight.w800)),
            Text('Budget',
                style: UdoDesign.sans(size: 10, color: UdoDesign.muted)),
          ]),
        ),
      ),
    ]);
  }
}

class _HoneymoonStatusBadge extends StatelessWidget {
  final String? status;
  const _HoneymoonStatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final confirmed = status == 'confirmed';
    final color = confirmed ? const Color(0xFF22C55E) : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(confirmed ? 'Confirmed' : 'Pending',
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _HoneymoonUpcomingPlansCard extends ConsumerWidget {
  final HoneymoonState state;
  const _HoneymoonUpcomingPlansCard({required this.state});

  List<Map<String, dynamic>> _upcoming() {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final sorted = [...state.items]..sort((a, b) {
        final da = DateTime.tryParse(a['date'] as String? ?? '');
        final db = DateTime.tryParse(b['date'] as String? ?? '');
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });
    final upcoming = sorted.where((i) {
      final d = DateTime.tryParse(i['date'] as String? ?? '');
      return d == null || !d.isBefore(todayOnly);
    }).toList();
    return (upcoming.isNotEmpty ? upcoming : sorted).take(4).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = _upcoming();
    return UdoCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text('Upcoming Plans',
                  style: UdoDesign.sans(size: 15, weight: FontWeight.w700))),
          TextButton(
              onPressed: () => _showItinerary(context),
              child: const Text('View All', style: TextStyle(fontSize: 12))),
        ]),
        if (upcoming.isEmpty)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('No plans added yet.',
                  style: UdoDesign.sans(size: 12, color: UdoDesign.muted)))
        else
          for (final item in upcoming)
            InkWell(
              onTap: () => _showAddPlanSheet(context, ref, item: item),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  Icon(
                      _kHoneymoonTypeMeta[item['type']]?.$2 ??
                          Icons.event_outlined,
                      size: 18,
                      color: UdoDesign.sage),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title'] as String? ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: UdoDesign.sans(
                                  size: 13, weight: FontWeight.w600)),
                          if (item['date'] != null)
                            Text(
                                DateFormat('MMM d, yyyy').format(
                                    DateTime.parse(item['date'] as String)),
                                style: UdoDesign.sans(
                                    size: 11, color: UdoDesign.muted)),
                        ]),
                  ),
                  _HoneymoonStatusBadge(item['status'] as String?),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right,
                      size: 16, color: AppTheme.udoTextSecondary),
                ]),
              ),
            ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showAddPlanSheet(context, ref),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Plan'),
          ),
        ),
      ]),
    );
  }

  void _showAddPlanSheet(BuildContext context, WidgetRef ref,
      {Map<String, dynamic>? item}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => _AddHoneymoonPlanScreen(state: state, item: item)));
  }

  void _showItinerary(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _HoneymoonItinerarySheet(state: state),
    );
  }
}

class _AddHoneymoonPlanScreen extends ConsumerStatefulWidget {
  final HoneymoonState state;
  final Map<String, dynamic>? item;
  const _AddHoneymoonPlanScreen({required this.state, this.item});

  @override
  ConsumerState<_AddHoneymoonPlanScreen> createState() =>
      _AddHoneymoonPlanScreenState();
}

class _AddHoneymoonPlanScreenState
    extends ConsumerState<_AddHoneymoonPlanScreen> {
  late final _title =
      TextEditingController(text: widget.item?['title'] as String? ?? '');
  late final _location = TextEditingController(
      text: (widget.item?['details'] as Map?)?['location']?.toString() ?? '');
  late final _notes = TextEditingController(
      text: (widget.item?['details'] as Map?)?['notes']?.toString() ?? '');
  late final _cost = TextEditingController(
      text: widget.item?['cost'] != null
          ? _asDouble(widget.item!['cost']).toStringAsFixed(2)
          : '');
  late String _type = widget.item?['type'] as String? ?? 'flight';
  String? _category;
  late String _currency;
  DateTime? _date;
  TimeOfDay? _time;
  late final Set<String> _travelerIds;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final details = widget.item?['details'] as Map?;
    _category = details?['category']?.toString();
    _currency = details?['currency']?.toString() ?? 'USD';
    final rawDate = widget.item?['date'] as String?;
    _date = rawDate != null ? DateTime.tryParse(rawDate) : null;
    _time = _parseTimeOfDay(widget.item?['time'] as String?);
    _travelerIds = (widget.item?['traveler_ids'] as List?)
            ?.map((id) => id.toString())
            .toSet() ??
        {};
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _notes.dispose();
    _cost.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTimeOfDay(String? raw) {
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _fmtTimeOfDay(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Give this plan a title.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final notifier = ref.read(honeymoonProvider.notifier);
    final data = {
      'type': _type,
      if (!_isEdit) 'status': 'pending',
      'title': _title.text.trim(),
      'date': _date != null ? _formatDate(_date!) : null,
      'time': _time != null ? _fmtTimeOfDay(_time!) : null,
      'cost': _cost.text.trim().isNotEmpty
          ? double.tryParse(_cost.text.trim())
          : null,
      'traveler_ids': _travelerIds.map(int.parse).toList(),
      'details': {
        if (_location.text.trim().isNotEmpty) 'location': _location.text.trim(),
        if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
        if (_category != null) 'category': _category,
        'currency': _currency,
      },
    };
    final ok = _isEdit
        ? await notifier.updateItem(widget.item!['id'] as int, data)
        : await notifier.addItem(data);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save this plan. Try again.";
      });
    }
  }

  Future<void> _delete() async {
    Navigator.pop(context);
    await ref
        .read(honeymoonProvider.notifier)
        .deleteItem(widget.item!['id'] as int);
  }

  void _addTraveler() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddHoneymoonTravelerSheet(
          notifier: ref.read(honeymoonProvider.notifier)),
    );
  }

  Widget _typeCard(String type) {
    final meta = _kHoneymoonTypeMeta[type]!;
    final selected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.udoGreen.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: selected ? AppTheme.udoGreen : AppTheme.udoBorder,
                width: selected ? 1.5 : 1),
          ),
          child: Column(children: [
            Icon(meta.$2,
                size: 20,
                color:
                    selected ? AppTheme.udoGreen : AppTheme.udoTextSecondary),
            const SizedBox(height: 6),
            Text(meta.$1,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppTheme.udoGreen
                        : AppTheme.udoTextPrimary)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.state.trip;
    final destination = (trip?['destination'] as String?)?.isNotEmpty == true
        ? trip!['destination'] as String
        : 'Not set';
    final dateLine = (trip?['departure_date'] != null &&
            trip?['return_date'] != null)
        ? '${DateFormat('MMM d').format(DateTime.parse(trip!['departure_date'] as String))} - ${DateFormat('MMM d').format(DateTime.parse(trip['return_date'] as String))}'
        : 'Not set';
    final travelers = widget.state.travelers;

    return Scaffold(
      backgroundColor: AppTheme.udoBackground,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
            child: Row(children: [
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back)),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(_isEdit ? 'Edit Plan' : 'Add Plan',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const Text(
                        'This will update your plan, budget, and traveler details.',
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.udoTextSecondary)),
                  ])),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: _TripContextChip(
                              icon: Icons.calendar_today_outlined,
                              label: 'Trip Dates',
                              value: dateLine)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _TripContextChip(
                              icon: Icons.place_outlined,
                              label: 'Destination',
                              value: destination)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _TripContextChip(
                              icon: Icons.groups_outlined,
                              label: 'Travelers',
                              value:
                                  '${travelers.length} Traveler${travelers.length == 1 ? '' : 's'}')),
                    ]),
                    const SizedBox(height: 20),
                    const Text('What would you like to add?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(children: [
                      for (final type in _kHoneymoonTypeMeta.keys)
                        _typeCard(type)
                    ]),
                    const SizedBox(height: 20),
                    Text('Plan Details',
                        style:
                            UdoDesign.sans(size: 15, weight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    const Text('Type of Plan',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.udoTextSecondary)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: _pickerDropdownDecoration(),
                      items: [
                        for (final entry in _kHoneymoonTypeMeta.entries)
                          DropdownMenuItem(
                              value: entry.key, child: Text(entry.value.$1))
                      ],
                      onChanged: (v) => setState(() => _type = v ?? _type),
                    ),
                    const SizedBox(height: 12),
                    const Text('Title',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.udoTextSecondary)),
                    const SizedBox(height: 4),
                    _GField(
                        _type == 'flight'
                            ? 'e.g. Flight to Bali'
                            : _type == 'accommodation'
                                ? 'e.g. Resort name'
                                : 'e.g. Snorkeling trip',
                        _title),
                    const SizedBox(height: 12),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Date',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.udoTextSecondary)),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                          context: context,
                                          initialDate: _date ?? DateTime.now(),
                                          firstDate: DateTime.now().subtract(
                                              const Duration(days: 365)),
                                          lastDate: DateTime.now()
                                              .add(const Duration(days: 3650)));
                                      if (picked != null)
                                        setState(() => _date = picked);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 14),
                                      decoration: BoxDecoration(
                                          color: AppTheme.udoCardFill,
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      child: Row(children: [
                                        const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 14,
                                            color: AppTheme.udoTextSecondary),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child: Text(
                                                _date == null
                                                    ? 'Select date'
                                                    : DateFormat('MMM d, yyyy')
                                                        .format(_date!),
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                      ]),
                                    ),
                                  ),
                                ]),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Time (optional)',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.udoTextSecondary)),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () async {
                                      final picked = await showTimePicker(
                                          context: context,
                                          initialTime:
                                              _time ?? TimeOfDay.now());
                                      if (picked != null)
                                        setState(() => _time = picked);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 14),
                                      decoration: BoxDecoration(
                                          color: AppTheme.udoCardFill,
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      child: Row(children: [
                                        const Icon(Icons.schedule_outlined,
                                            size: 14,
                                            color: AppTheme.udoTextSecondary),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child: Text(
                                                _time == null
                                                    ? 'Select time'
                                                    : _time!.format(context),
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                      ]),
                                    ),
                                  ),
                                ]),
                          ),
                        ]),
                    const SizedBox(height: 12),
                    const Text('Location / Details',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.udoTextSecondary)),
                    const SizedBox(height: 4),
                    _GField('e.g. Ngurah Rai International Airport (DPS)',
                        _location),
                    const SizedBox(height: 12),
                    const Text('Notes (optional)',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.udoTextSecondary)),
                    const SizedBox(height: 4),
                    _GField('Add any additional notes...', _notes, maxLines: 3),
                    const SizedBox(height: 20),
                    Text('Budget',
                        style:
                            UdoDesign.sans(size: 15, weight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Estimated Cost (optional)',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.udoTextSecondary)),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    SizedBox(
                                      width: 78,
                                      child: DropdownButtonFormField<String>(
                                        initialValue: _currency,
                                        decoration: _pickerDropdownDecoration(),
                                        items: [
                                          for (final c in _kHoneymoonCurrencies)
                                            DropdownMenuItem(
                                                value: c,
                                                child: Text(c,
                                                    style: const TextStyle(
                                                        fontSize: 12)))
                                        ],
                                        onChanged: (v) => setState(
                                            () => _currency = v ?? _currency),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: _GField('0.00', _cost,
                                            type: const TextInputType
                                                .numberWithOptions(
                                                decimal: true))),
                                  ]),
                                ]),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Category',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.udoTextSecondary)),
                                  const SizedBox(height: 4),
                                  DropdownButtonFormField<String>(
                                    initialValue: _category,
                                    decoration: _pickerDropdownDecoration(),
                                    items: [
                                      for (final c
                                          in _kHoneymoonBudgetCategories)
                                        DropdownMenuItem(
                                            value: c,
                                            child: Text(c,
                                                style: const TextStyle(
                                                    fontSize: 12)))
                                    ],
                                    onChanged: (v) =>
                                        setState(() => _category = v),
                                  ),
                                ]),
                          ),
                        ]),
                    const SizedBox(height: 6),
                    const Text('This will be added to your honeymoon budget.',
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.udoTextSecondary)),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                          child: Text('Travelers',
                              style: UdoDesign.sans(
                                  size: 15, weight: FontWeight.w700))),
                      TextButton(
                        onPressed: () => setState(() {
                          if (_travelerIds.length == travelers.length) {
                            _travelerIds.clear();
                          } else {
                            _travelerIds
                              ..clear()
                              ..addAll(
                                  travelers.map((t) => t['id'].toString()));
                          }
                        }),
                        child: const Text('Select All',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ]),
                    const Text('Who is this plan for?',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.udoTextSecondary)),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final t in travelers)
                        FilterChip(
                          avatar: CircleAvatar(
                              radius: 10,
                              backgroundColor: UdoDesign.sage,
                              child: Text(
                                  (t['name'] as String? ?? '?')[0]
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10))),
                          label: Text(
                              '${t['name']}${(t['role'] as String?)?.isNotEmpty == true ? '\n${t['role']}' : ''}',
                              style: const TextStyle(fontSize: 11)),
                          selected: _travelerIds.contains(t['id'].toString()),
                          onSelected: (sel) => setState(() {
                            final id = t['id'].toString();
                            if (sel) {
                              _travelerIds.add(id);
                            } else {
                              _travelerIds.remove(id);
                            }
                          }),
                          selectedColor:
                              AppTheme.udoGreen.withValues(alpha: 0.15),
                        ),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 14),
                        label: const Text('Add other traveler',
                            style: TextStyle(fontSize: 11)),
                        onPressed: _addTraveler,
                      ),
                    ]),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.udoCrimson)),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            backgroundColor: AppTheme.udoGreen,
                            foregroundColor: Colors.white),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text(_isEdit ? 'Save Changes' : 'Add Plan'),
                      ),
                    ),
                    if (_isEdit) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _delete,
                          icon: const Icon(Icons.delete_outline,
                              size: 16, color: Colors.red),
                          label: const Text('Delete Plan',
                              style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                            'This will be added to your Plan, update your Budget, and sync with Travelers.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.udoTextSecondary)),
                      ),
                    ),
                  ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _TripContextChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _TripContextChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.udoBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: AppTheme.udoTextSecondary),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.udoTextSecondary)),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _HoneymoonBudgetCard extends StatelessWidget {
  final HoneymoonState state;
  final VoidCallback onViewBudget;
  const _HoneymoonBudgetCard({required this.state, required this.onViewBudget});

  @override
  Widget build(BuildContext context) {
    final spent = state.budgetItems
        .fold<double>(0, (sum, b) => sum + _asDouble(b['paid_amount']));
    final estimated = state.budgetItems
        .fold<double>(0, (sum, b) => sum + _asDouble(b['estimated_amount']));
    final tripTotal = _asDouble(state.trip?['total_budget']);
    final total = tripTotal > 0 ? tripTotal : estimated;
    final remaining = (total - spent).clamp(0, double.infinity).toDouble();

    return UdoCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Budget Overview',
            style: UdoDesign.sans(size: 15, weight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(children: [
          SizedBox(
              width: 84,
              height: 84,
              child: CustomPaint(
                  painter: _HoneymoonBudgetDonutPainter(
                      spent: spent, remaining: remaining))),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                _budgetLegendRow('Spent', spent, const Color(0xFFC9867A)),
                const SizedBox(height: 6),
                _budgetLegendRow('Remaining', remaining, AppTheme.udoBorder),
                const SizedBox(height: 6),
                _budgetLegendRow('Total', total, null),
              ])),
        ]),
        const SizedBox(height: 14),
        SizedBox(
            width: double.infinity,
            child: OutlinedButton(
                onPressed: onViewBudget, child: const Text('View Budget'))),
      ]),
    );
  }

  Widget _budgetLegendRow(String label, double amount, Color? dotColor) =>
      Row(children: [
        if (dotColor != null) ...[
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 6),
        ],
        Text(label, style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
        const Spacer(),
        Text(_money(amount),
            style: UdoDesign.sans(size: 12, weight: FontWeight.w700)),
      ]);
}

class _HoneymoonBudgetDonutPainter extends CustomPainter {
  final double spent;
  final double remaining;
  const _HoneymoonBudgetDonutPainter(
      {required this.spent, required this.remaining});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
        size.width - strokeWidth, size.height - strokeWidth);
    final total = spent + remaining;
    if (total <= 0) {
      final paint = Paint()
        ..color = AppTheme.udoBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, 0, 2 * pi, false, paint);
      return;
    }
    var startAngle = -pi / 2;
    for (final segment in [
      (spent, const Color(0xFFC9867A)),
      (remaining, AppTheme.udoBorder)
    ]) {
      if (segment.$1 <= 0) continue;
      final sweep = (segment.$1 / total) * 2 * pi;
      final paint = Paint()
        ..color = segment.$2
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _HoneymoonBudgetDonutPainter oldDelegate) =>
      oldDelegate.spent != spent || oldDelegate.remaining != remaining;
}

class _HoneymoonTravelersCard extends ConsumerWidget {
  final HoneymoonState state;
  const _HoneymoonTravelersCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final travelers = state.travelers;
    return UdoCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text('Travelers',
                  style: UdoDesign.sans(size: 15, weight: FontWeight.w700))),
        ]),
        if (travelers.isEmpty)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('No travelers added yet.',
                  style: UdoDesign.sans(size: 12, color: UdoDesign.muted)))
        else
          for (final t in travelers)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                CircleAvatar(
                    radius: 16,
                    backgroundColor: UdoDesign.sage,
                    child: Text(_travelerInitial(t['name'] as String?),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700))),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(t['name'] as String? ?? '',
                          style: UdoDesign.sans(
                              size: 13, weight: FontWeight.w600)),
                      if ((t['role'] as String?)?.isNotEmpty == true)
                        Text(t['role'] as String,
                            style: UdoDesign.sans(
                                size: 11, color: UdoDesign.muted)),
                    ])),
                GestureDetector(
                  onTap: () => ref
                      .read(honeymoonProvider.notifier)
                      .removeTraveler(t['id'] as int),
                  child: const Icon(Icons.close,
                      size: 16, color: AppTheme.udoTextSecondary),
                ),
              ]),
            ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: () => _showInviteSheet(context, ref),
          icon: const Icon(Icons.person_add_alt_outlined, size: 16),
          label: const Text('Invite Traveler'),
        ),
      ]),
    );
  }

  String _travelerInitial(String? name) =>
      (name == null || name.isEmpty) ? '?' : name[0].toUpperCase();

  void _showInviteSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddHoneymoonTravelerSheet(
          notifier: ref.read(honeymoonProvider.notifier)),
    );
  }
}

class _AddHoneymoonTravelerSheet extends StatefulWidget {
  final HoneymoonNotifier notifier;
  const _AddHoneymoonTravelerSheet({required this.notifier});

  @override
  State<_AddHoneymoonTravelerSheet> createState() =>
      _AddHoneymoonTravelerSheetState();
}

class _AddHoneymoonTravelerSheetState
    extends State<_AddHoneymoonTravelerSheet> {
  final _name = TextEditingController();
  final _role = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Give this traveler a name.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await widget.notifier
        .addTraveler(name: _name.text.trim(), role: _role.text.trim());
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't add this traveler. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Expanded(
                        child: Text('Invite Traveler',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600))),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero),
                  ]),
                  const SizedBox(height: 4),
                  const Text(
                      'Adds them to your trip — no invite email is sent.',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.udoTextSecondary)),
                  const SizedBox(height: 14),
                  _GField('Name', _name),
                  const SizedBox(height: 10),
                  _GField('Role (e.g. Lead Traveler)', _role),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.udoCrimson)),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: AppTheme.udoGreen,
                        foregroundColor: Colors.white),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Add'),
                  ),
                ]),
          ),
        ),
      );
}

class _HoneymoonChecklistCard extends ConsumerWidget {
  final HoneymoonState state;
  const _HoneymoonChecklistCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = state.checklistTasks;
    final done = tasks.where((t) => t['completed'] == true).length;
    final pct = tasks.isEmpty ? 0.0 : done / tasks.length;

    return UdoCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text('Checklist',
                  style: UdoDesign.sans(size: 15, weight: FontWeight.w700))),
          TextButton(
              onPressed: () => _showChecklist(context),
              child:
                  const Text('View Checklist', style: TextStyle(fontSize: 12))),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppTheme.udoBorder,
              color: AppTheme.udoGreen),
        ),
        const SizedBox(height: 6),
        Text('$done of ${tasks.length} tasks completed',
            style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
      ]),
    );
  }

  void _showChecklist(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _HoneymoonChecklistSheet(),
    );
  }
}

class _HoneymoonChecklistSheet extends ConsumerStatefulWidget {
  const _HoneymoonChecklistSheet();

  @override
  ConsumerState<_HoneymoonChecklistSheet> createState() =>
      _HoneymoonChecklistSheetState();
}

class _HoneymoonChecklistSheetState
    extends ConsumerState<_HoneymoonChecklistSheet> {
  final _newTask = TextEditingController();
  final _newTaskFocus = FocusNode();
  bool _adding = false;

  @override
  void dispose() {
    _newTask.dispose();
    _newTaskFocus.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    if (_newTask.text.trim().isEmpty) {
      _newTaskFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Type a checklist item first.')));
      return;
    }
    setState(() => _adding = true);
    final ok = await ref
        .read(honeymoonProvider.notifier)
        .addChecklistTask(_newTask.text.trim());
    if (!mounted) return;
    if (ok) {
      _newTask.clear();
      _newTaskFocus.requestFocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Couldn't add this checklist item. Try again.")));
    }
    setState(() => _adding = false);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(honeymoonProvider).checklistTasks;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Column(children: [
        Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(children: [
            const Expanded(
                child: Text('Checklist',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              children: [
                if (tasks.isEmpty)
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No checklist items yet.',
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.udoTextSecondary)))
                else
                  for (final task in tasks)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: task['completed'] == true,
                      onChanged: (v) => ref
                          .read(honeymoonProvider.notifier)
                          .toggleChecklistTask(task['id'] as int, v ?? false),
                      title: Text(task['title'] as String? ?? '',
                          style: const TextStyle(fontSize: 13)),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppTheme.udoGreen,
                      secondary: IconButton(
                        onPressed: () => ref
                            .read(honeymoonProvider.notifier)
                            .deleteChecklistTask(task['id'] as int),
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: AppTheme.udoTextSecondary),
                      ),
                    ),
              ]),
        ),
        const Divider(height: 1),
        Padding(
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, 12 + MediaQuery.of(context).viewInsets.bottom),
          child: Row(children: [
            Expanded(
                child: _GField('Add a checklist item', _newTask,
                    focusNode: _newTaskFocus, onSubmitted: (_) => _addTask())),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _adding ? null : _addTask,
              icon: _adding
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.add),
              style: IconButton.styleFrom(backgroundColor: AppTheme.udoGreen),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _HoneymoonItinerarySheet extends StatelessWidget {
  final HoneymoonState state;
  const _HoneymoonItinerarySheet({required this.state});

  @override
  Widget build(BuildContext context) {
    final sorted = [...state.items]..sort((a, b) {
        final da = DateTime.tryParse(a['date'] as String? ?? '');
        final db = DateTime.tryParse(b['date'] as String? ?? '');
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Column(children: [
        Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(children: [
            const Expanded(
                child: Text('Itinerary',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
          child: sorted.isEmpty
              ? const Center(
                  child: Text('No plans added yet.',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.udoTextSecondary)))
              : ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  children: [
                      for (final item in sorted)
                        Builder(builder: (context) {
                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => _AddHoneymoonPlanScreen(
                                      state: state, item: item)));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(children: [
                                Icon(
                                    _kHoneymoonTypeMeta[item['type']]?.$2 ??
                                        Icons.event_outlined,
                                    size: 18,
                                    color: AppTheme.udoGreen),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(item['title'] as String? ?? '',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                          item['date'] != null
                                              ? DateFormat('EEE, MMM d, yyyy')
                                                  .format(DateTime.parse(
                                                      item['date'] as String))
                                              : 'No date',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color:
                                                  AppTheme.udoTextSecondary)),
                                    ])),
                                _HoneymoonStatusBadge(
                                    item['status'] as String?),
                              ]),
                            ),
                          );
                        }),
                    ]),
        ),
      ]),
    );
  }
}

class _EditTripSheet extends StatefulWidget {
  final HoneymoonNotifier notifier;
  final Map<String, dynamic>? trip;
  const _EditTripSheet({required this.notifier, this.trip});
  @override
  State<_EditTripSheet> createState() => _EditTripSheetState();
}

class _EditTripSheetState extends State<_EditTripSheet> {
  late final _destination =
      TextEditingController(text: widget.trip?['destination'] as String? ?? '');
  late final _status =
      TextEditingController(text: widget.trip?['status'] as String? ?? '');
  late final _totalBudget = TextEditingController(
      text: widget.trip?['total_budget'] != null
          ? _asDouble(widget.trip!['total_budget']).toStringAsFixed(2)
          : '');
  DateTime? _departure;
  DateTime? _return;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final dep = widget.trip?['departure_date'] as String?;
    final ret = widget.trip?['return_date'] as String?;
    _departure = dep != null ? DateTime.tryParse(dep) : null;
    _return = ret != null ? DateTime.tryParse(ret) : null;
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Expanded(
                        child: Text('Plan honeymoon',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600))),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero),
                  ]),
                  const SizedBox(height: 14),
                  _GField('Destination', _destination),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                            context: context,
                            initialDate: _departure ?? DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 3650)));
                        if (picked != null) setState(() => _departure = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                            color: AppTheme.udoCardFill,
                            borderRadius: BorderRadius.circular(14)),
                        child: Text(
                            _departure == null
                                ? 'Departure'
                                : DateFormat('MMM d, yyyy').format(_departure!),
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.udoTextSecondary)),
                      ),
                    )),
                    const SizedBox(width: 8),
                    Expanded(
                        child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                            context: context,
                            initialDate: _return ?? DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 3650)));
                        if (picked != null) setState(() => _return = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                            color: AppTheme.udoCardFill,
                            borderRadius: BorderRadius.circular(14)),
                        child: Text(
                            _return == null
                                ? 'Return'
                                : DateFormat('MMM d, yyyy').format(_return!),
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.udoTextSecondary)),
                      ),
                    )),
                  ]),
                  const SizedBox(height: 10),
                  _GField('Total budget (optional)', _totalBudget,
                      type:
                          const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 10),
                  _GField('Status (optional)', _status),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.udoCrimson)),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: AppTheme.udoGreen,
                        foregroundColor: Colors.white),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Save'),
                  ),
                ]),
          ),
        ),
      );

  Future<void> _submit() async {
    if (_destination.text.trim().isEmpty) {
      setState(() => _error = 'Destination is required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await widget.notifier.updateTrip({
      'destination': _destination.text.trim(),
      if (_departure != null) 'departure_date': _formatDate(_departure!),
      if (_return != null) 'return_date': _formatDate(_return!),
      if (_totalBudget.text.trim().isNotEmpty)
        'total_budget': double.tryParse(_totalBudget.text.trim()),
      if (_status.text.trim().isNotEmpty) 'status': _status.text.trim(),
    });
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save. Try again.";
      });
    }
  }

  @override
  void dispose() {
    _destination.dispose();
    _status.dispose();
    _totalBudget.dispose();
    super.dispose();
  }
}

// ── WEDDING PARTY TAB (links to full screen) ───────────────────────────────────

class _WeddingPartyTab extends StatelessWidget {
  const _WeddingPartyTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
      children: [
        UdoCard(
          padding: const EdgeInsets.all(22),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: UdoDesign.rose.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.groups_2_outlined, color: UdoDesign.rose),
            ),
            const SizedBox(height: 16),
            Text('Wedding Party planning', style: UdoDesign.serif(size: 28)),
            const SizedBox(height: 8),
            Text(
              'This section now lives in the full Wedding Party module so Overview, People, Responsibilities, Rehearsal, Travel, and Files stay in one place.',
              style: UdoDesign.sans(
                  size: 13, color: UdoDesign.muted, height: 1.45),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push('/wedding-party?tab=overview'),
                icon: const Icon(Icons.event_note_outlined, size: 16),
                label: const Text('Open Detailed Planning'),
                style: FilledButton.styleFrom(
                  backgroundColor: UdoDesign.rose,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

// ── DETAILS TAB ────────────────────────────────────────────────────────────────

class _DetailsTab extends ConsumerWidget {
  const _DetailsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wedding = ref.watch(moreOperationsProvider).activeWedding;
    final notifier = ref.read(moreOperationsProvider.notifier);
    if (wedding == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No active wedding found.',
              style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
        ),
      );
    }

    String dash(dynamic v) =>
        (v == null || (v is String && v.isEmpty)) ? 'Not set' : v.toString();
    String displayDate(dynamic v) {
      if (v == null || (v is String && v.trim().isEmpty)) return 'Not set';
      final formatted = udo_dates.formatApiDate(v);
      return formatted.isEmpty ? 'Not set' : formatted;
    }

    String displayTime(dynamic v) {
      if (v == null || (v is String && v.trim().isEmpty)) return 'Not set';
      final formatted = udo_dates.formatApiTime(v);
      return formatted.isEmpty ? 'Not set' : formatted;
    }

    dynamic setting(String key) {
      final settings = wedding['settings'] is Map
          ? Map<String, dynamic>.from(wedding['settings'] as Map)
          : <String, dynamic>{};
      return wedding[key] ?? settings[key];
    }

    final destination = [wedding['city'], wedding['country']]
        .where((v) => v != null && (v as String).isNotEmpty)
        .join(', ');
    final fields = [
      _ProfileField(Icons.calendar_today_outlined, 'Wedding date',
          displayDate(wedding['event_date']), wedding['event_date']),
      _ProfileField(Icons.favorite_border_outlined, 'Wedding type',
          dash(setting('wedding_type')), setting('wedding_type')),
      _ProfileField(Icons.location_on_outlined, 'Ceremony venue',
          dash(wedding['primary_venue_name']), wedding['primary_venue_name']),
      _ProfileField(Icons.schedule_outlined, 'Ceremony time',
          displayTime(setting('ceremony_time')), setting('ceremony_time')),
      _ProfileField(
          Icons.apartment_outlined,
          'Reception venue',
          dash(setting('reception_venue_name')),
          setting('reception_venue_name')),
      _ProfileField(Icons.schedule_outlined, 'Reception time',
          displayTime(setting('reception_time')), setting('reception_time')),
      _ProfileField(Icons.location_city_outlined, 'Destination',
          destination.isEmpty ? 'Not set' : destination, destination),
      _ProfileField(Icons.event_available_outlined, 'RSVP deadline',
          displayDate(wedding['rsvp_deadline']), wedding['rsvp_deadline']),
      _ProfileField(Icons.groups_outlined, 'Guest count',
          dash(setting('guest_count')), setting('guest_count')),
      _ProfileField(Icons.language_outlined, 'Wedding website',
          dash(setting('website_url')), setting('website_url')),
      _ProfileField(Icons.tag_outlined, 'Wedding hashtag',
          dash(wedding['hashtag']), wedding['hashtag']),
      _ProfileField(Icons.checkroom_outlined, 'Dress code',
          dash(setting('dress_code')), setting('dress_code')),
      _ProfileField(Icons.person_outline, 'Celebrant',
          dash(setting('celebrant_name')), setting('celebrant_name')),
      _ProfileField(Icons.local_parking_outlined, 'Parking information',
          dash(setting('parking_information')), setting('parking_information')),
      _ProfileField(Icons.map_outlined, 'Google Maps link',
          dash(setting('google_maps_link')), setting('google_maps_link')),
      _ProfileField(
          Icons.directions_bus_outlined,
          'Transportation',
          dash(setting('transportation_notes')),
          setting('transportation_notes')),
      _ProfileField(Icons.flag_outlined, 'Venue status',
          dash(setting('venue_status')), setting('venue_status')),
      _ProfileField(Icons.account_tree_outlined, 'Planning approach',
          dash(setting('planning_approach')), setting('planning_approach')),
    ];
    final weddingDate =
        DateTime.tryParse(wedding['event_date'] as String? ?? '');

    final rebuiltProfile = _WeddingProfilePage(
      fields: fields,
      weddingDate: weddingDate,
      destination: destination,
      guestCount: dash(setting('guest_count')),
      budgetStatus: () {
        final raw = setting('total_budget');
        final amount = raw is num
            ? raw.toDouble()
            : double.tryParse(raw?.toString() ?? '');
        return (amount != null && amount > 0) ? _money(amount) : 'Not set';
      }(),
      onComplete: () =>
          _openWeddingDetailsSheet(context, ref, notifier, wedding),
      onPreview: () {
        ref.invalidate(weddingStoryProvider);
        context.push('/wedding-story');
      },
    );
    if (MediaQuery.sizeOf(context).width >= 0) {
      return rebuiltProfile;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final (icon, title, value) in [
          (
            Icons.calendar_today_outlined,
            'Wedding date',
            displayDate(wedding['event_date'])
          ),
          (
            Icons.location_on_outlined,
            'Venue',
            dash(wedding['primary_venue_name'])
          ),
          (
            Icons.location_city_outlined,
            'Destination',
            destination.isEmpty ? 'Not set' : destination
          ),
          (
            Icons.event_available_outlined,
            'RSVP deadline',
            displayDate(wedding['rsvp_deadline'])
          ),
          (Icons.tag_outlined, 'Wedding hashtag', dash(wedding['hashtag'])),
        ])
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.udoBorder)),
            child: Row(children: [
              Icon(icon, color: AppTheme.udoGreen, size: 20),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.udoTextSecondary)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  ])),
            ]),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('Edit these details from More → Wedding settings.',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary)),
        ),
      ],
    );
  }
}

void _openWeddingDetailsSheet(BuildContext context, WidgetRef ref,
    MoreOperationsNotifier notifier, Map<String, dynamic> wedding) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _EditWeddingDetailsSheet(
      wedding: wedding,
      notifier: notifier,
      onSaved: () {
        ref.invalidate(homeProvider);
        ref.invalidate(moreOperationsProvider);
        ref.invalidate(weddingStoryProvider);
      },
    ),
  );
}

class _ProfileField {
  final IconData icon;
  final String label;
  final String value;
  final dynamic rawValue;

  const _ProfileField(this.icon, this.label, this.value, this.rawValue);

  bool get isComplete =>
      rawValue != null && (!(rawValue is String) || rawValue.trim().isNotEmpty);
}

const _weddingTypeOptions = [
  'Traditional Wedding',
  'Modern Wedding',
  'Classic Elegant',
  'Luxury Wedding',
  'Destination Wedding',
  'Beach Wedding',
  'Garden Wedding',
  'Church Wedding',
  'Civil Ceremony',
  'Courthouse Wedding',
  'Intimate Wedding',
  'Micro Wedding',
  'Elopement',
  'Black Tie',
  'Formal Wedding',
  'Semi-Formal Wedding',
  'Casual Wedding',
  'Boho Wedding',
  'Rustic Wedding',
  'Barn Wedding',
  'Vintage Wedding',
  'Glamorous Wedding',
  'Minimalist Wedding',
  'Industrial Wedding',
  'Tropical Wedding',
  'Cultural Wedding',
  'Fusion Wedding',
  'Multicultural Wedding',
  'LGBTQ+ Wedding',
  'Vow Renewal',
  'Adventure Wedding',
  'Weekend Wedding',
  'Festival Wedding',
  'Winery/Vineyard Wedding',
  'Estate Wedding',
  'Hotel Ballroom Wedding',
  'All-Inclusive Resort Wedding',
  'Cruise Wedding',
  'Custom',
];

const _planningApproachOptions = [
  'Planning Ourselves',
  'Mostly DIY',
  'DIY with Family Support',
  'DIY with Friends',
  'Day-of Coordinator',
  'Month-of Coordinator',
  'Partial Wedding Planner',
  'Full-Service Wedding Planner',
  'Venue Coordinator',
  'Destination Wedding Specialist',
  'Bride Leads Planning',
  'Groom Leads Planning',
  'Planning Together Equally',
  'Parent-Led Planning',
  'Planner + Couple Collaboration',
  'Luxury Concierge Planning',
  'Religious Organization Assisted',
  'Custom',
];

const _dressCodeOptionsList = [
  'White Tie',
  'Black Tie',
  'Black Tie Optional',
  'Formal / Evening Wear',
  'Cocktail Attire',
  'Semi-Formal',
  'Dressy Casual',
  'Smart Casual',
  'Casual',
  'Business Casual',
  'Beach Formal',
  'Beach Casual',
  'Tropical Formal',
  'Tropical Chic',
  'Garden Party',
  'Resort Elegant',
  'Island Elegant',
  'Boho Chic',
  'Rustic Chic',
  'Festive',
  'Cultural Attire Encouraged',
  'Traditional National Dress',
  'Colour Theme Required',
  'All Black',
  'All White',
  'Neutral Tones',
  'Pastel Colours',
  'Jewel Tones',
  'Floral Attire Welcome',
  'No Denim',
  'Comfortable Shoes Recommended',
  'Custom Dress Code',
];

class _EditWeddingDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> wedding;
  final MoreOperationsNotifier notifier;
  final VoidCallback onSaved;
  const _EditWeddingDetailsSheet({
    required this.wedding,
    required this.notifier,
    required this.onSaved,
  });

  @override
  State<_EditWeddingDetailsSheet> createState() =>
      _EditWeddingDetailsSheetState();
}

class _EditWeddingDetailsSheetState extends State<_EditWeddingDetailsSheet> {
  final _title = TextEditingController();
  final _primaryName = TextEditingController();
  final _secondaryName = TextEditingController();
  final _weddingType = TextEditingController();
  String? _weddingTypeSelection;
  String? _planningApproachSelection;
  String? _dressCodeSelection;
  final _eventDate = TextEditingController();
  final _rsvpDeadline = TextEditingController();
  final _guestCount = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController();
  final _venueStatus = TextEditingController();
  final _planningApproach = TextEditingController();
  final _ceremonyVenue = TextEditingController();
  final _ceremonyTime = TextEditingController();
  final _venueAddress = TextEditingController();
  final _receptionVenue = TextEditingController();
  final _receptionTime = TextEditingController();
  final _website = TextEditingController();
  final _hashtag = TextEditingController();
  final _dressCode = TextEditingController();
  final _celebrant = TextEditingController();
  final _parking = TextEditingController();
  final _mapsLink = TextEditingController();
  final _transport = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final wedding = widget.wedding;
    final settings = wedding['settings'] is Map
        ? Map<String, dynamic>.from(wedding['settings'] as Map)
        : <String, dynamic>{};
    String value(String key) =>
        (wedding[key] ?? settings[key] ?? '').toString();
    _title.text = value('title');
    _primaryName.text = value('couple_name_primary');
    _secondaryName.text = value('couple_name_secondary');
    _weddingType.text = value('wedding_type');
    _weddingTypeSelection = _weddingTypeOptions.contains(_weddingType.text)
        ? _weddingType.text
        : (_weddingType.text.isNotEmpty ? 'Custom' : null);
    _eventDate.text = _dateOnly(wedding['event_date']);
    _rsvpDeadline.text = _dateOnly(wedding['rsvp_deadline']);
    _guestCount.text = value('guest_count');
    _city.text = value('city');
    _country.text = value('country');
    _venueStatus.text = value('venue_status');
    _planningApproach.text = value('planning_approach');
    _planningApproachSelection =
        _planningApproachOptions.contains(_planningApproach.text)
            ? _planningApproach.text
            : (_planningApproach.text.isNotEmpty ? 'Custom' : null);
    _ceremonyVenue.text = value('primary_venue_name');
    _ceremonyTime.text = value('ceremony_time');
    _venueAddress.text = value('primary_venue_address');
    _receptionVenue.text = value('reception_venue_name');
    _receptionTime.text = value('reception_time');
    _website.text = value('website_url');
    _hashtag.text = value('hashtag');
    _dressCode.text = value('dress_code');
    _dressCodeSelection = _dressCodeOptionsList.contains(_dressCode.text)
        ? _dressCode.text
        : (_dressCode.text.isNotEmpty ? 'Custom Dress Code' : null);
    _celebrant.text = value('celebrant_name');
    _parking.text = value('parking_information');
    _mapsLink.text = value('google_maps_link');
    _transport.text = value('transportation_notes');
  }

  @override
  void dispose() {
    _title.dispose();
    _primaryName.dispose();
    _secondaryName.dispose();
    _weddingType.dispose();
    _eventDate.dispose();
    _rsvpDeadline.dispose();
    _guestCount.dispose();
    _city.dispose();
    _country.dispose();
    _venueStatus.dispose();
    _planningApproach.dispose();
    _ceremonyVenue.dispose();
    _ceremonyTime.dispose();
    _venueAddress.dispose();
    _receptionVenue.dispose();
    _receptionTime.dispose();
    _website.dispose();
    _hashtag.dispose();
    _dressCode.dispose();
    _celebrant.dispose();
    _parking.dispose();
    _mapsLink.dispose();
    _transport.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final initial = DateTime.tryParse(controller.text.trim()) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) controller.text = _formatDate(picked);
  }

  Widget _taxonomyField({
    required String label,
    required List<String> options,
    required String? selection,
    required TextEditingController controller,
    required String customSentinel,
    required ValueChanged<String?> onSelectionChanged,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DropdownButtonFormField<String>(
        initialValue: selection,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: label,
          hintStyle:
              const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13),
          labelStyle:
              const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 12),
          filled: true,
          fillColor: AppTheme.udoCardFill,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        ),
        items: [
          for (final o in options)
            DropdownMenuItem(
                value: o,
                child: Text(o,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis))
        ],
        onChanged: (v) => setState(() {
          onSelectionChanged(v);
          if (v != null && v != customSentinel) controller.text = v;
          if (v == customSentinel) controller.clear();
        }),
      ),
      if (selection == customSentinel) ...[
        const SizedBox(height: 8),
        _GField('Enter custom ${label.toLowerCase()}', controller),
      ],
    ]);
  }

  Future<void> _save() async {
    if (_primaryName.text.trim().isEmpty) {
      setState(() => _error = 'Add at least one name for the couple.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final existingSettings = widget.wedding['settings'] is Map
        ? Map<String, dynamic>.from(widget.wedding['settings'] as Map)
        : <String, dynamic>{};
    final settings = {
      ...existingSettings,
      'ceremony_time': _nullIfBlank(_ceremonyTime.text),
      'reception_venue_name': _nullIfBlank(_receptionVenue.text),
      'reception_time': _nullIfBlank(_receptionTime.text),
      'parking_information': _nullIfBlank(_parking.text),
      'google_maps_link': _nullIfBlank(_mapsLink.text),
      'transportation_notes': _nullIfBlank(_transport.text),
      'wedding_type': _nullIfBlank(_weddingType.text),
      'guest_count': int.tryParse(_guestCount.text.trim()) ??
          _nullIfBlank(_guestCount.text),
      'venue_status': _nullIfBlank(_venueStatus.text),
      'planning_approach': _nullIfBlank(_planningApproach.text),
      'website_url': _nullIfBlank(_website.text),
      'dress_code': _nullIfBlank(_dressCode.text),
      'celebrant_name': _nullIfBlank(_celebrant.text),
    }..removeWhere((_, value) => value == null);

    final ok = await widget.notifier.updateWedding({
      'title': _nullIfBlank(_title.text),
      'couple_name_primary': _nullIfBlank(_primaryName.text),
      'couple_name_secondary': _nullIfBlank(_secondaryName.text),
      'wedding_type': _nullIfBlank(_weddingType.text),
      'event_date': _nullIfBlank(_eventDate.text),
      'rsvp_deadline': _nullIfBlank(_rsvpDeadline.text),
      'guest_count': int.tryParse(_guestCount.text.trim()),
      'city': _nullIfBlank(_city.text),
      'country': _nullIfBlank(_country.text),
      'primary_venue_name': _nullIfBlank(_ceremonyVenue.text),
      'primary_venue_address': _nullIfBlank(_venueAddress.text),
      'hashtag': _nullIfBlank(_hashtag.text),
      'settings': settings,
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      widget.onSaved();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Wedding profile saved')));
      Navigator.pop(context);
    } else {
      setState(() => _error = "Couldn't save wedding profile.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text('Wedding details',
                  style: UdoDesign.sans(size: 18, weight: FontWeight.w800)),
            ),
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)),
          ]),
          const SizedBox(height: 6),
          Text(
              'This profile powers Plan, Guests, Live, Home, and wedding story.',
              style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted)),
          const SizedBox(height: 16),
          _GField('Workspace title', _title),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _GField('Primary name', _primaryName)),
            const SizedBox(width: 10),
            Expanded(child: _GField('Partner name', _secondaryName)),
          ]),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: _taxonomyField(
                    label: 'Wedding type',
                    options: _weddingTypeOptions,
                    selection: _weddingTypeSelection,
                    controller: _weddingType,
                    customSentinel: 'Custom',
                    onSelectionChanged: (v) => _weddingTypeSelection = v)),
            const SizedBox(width: 10),
            Expanded(
                child: _GField('Guest count', _guestCount,
                    type: TextInputType.number)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: _WeddingDateInput(
                    label: 'Wedding date',
                    controller: _eventDate,
                    onPick: () => _pickDate(_eventDate))),
            const SizedBox(width: 10),
            Expanded(
                child: _WeddingDateInput(
                    label: 'RSVP deadline',
                    controller: _rsvpDeadline,
                    onPick: () => _pickDate(_rsvpDeadline))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _GField('City', _city)),
            const SizedBox(width: 10),
            Expanded(child: _GField('Country', _country)),
          ]),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _GField('Venue status', _venueStatus)),
            const SizedBox(width: 10),
            Expanded(
                child: _taxonomyField(
                    label: 'Planning approach',
                    options: _planningApproachOptions,
                    selection: _planningApproachSelection,
                    controller: _planningApproach,
                    customSentinel: 'Custom',
                    onSelectionChanged: (v) => _planningApproachSelection = v)),
          ]),
          const SizedBox(height: 10),
          _GField('Ceremony venue', _ceremonyVenue),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: _GField('Ceremony time', _ceremonyTime,
                    type: TextInputType.datetime)),
            const SizedBox(width: 10),
            Expanded(
                child: _GField('Reception time', _receptionTime,
                    type: TextInputType.datetime)),
          ]),
          const SizedBox(height: 10),
          _GField('Reception venue', _receptionVenue),
          const SizedBox(height: 10),
          _GField('Venue address', _venueAddress, maxLines: 2),
          const SizedBox(height: 10),
          _GField('Wedding website', _website, type: TextInputType.url),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _GField('Wedding hashtag', _hashtag)),
            const SizedBox(width: 10),
            Expanded(
                child: _taxonomyField(
                    label: 'Dress code',
                    options: _dressCodeOptionsList,
                    selection: _dressCodeSelection,
                    controller: _dressCode,
                    customSentinel: 'Custom Dress Code',
                    onSelectionChanged: (v) => _dressCodeSelection = v)),
          ]),
          const SizedBox(height: 10),
          _GField('Celebrant / officiant', _celebrant),
          const SizedBox(height: 10),
          _GField('Parking information', _parking, maxLines: 2),
          const SizedBox(height: 10),
          _GField('Google Maps link', _mapsLink, type: TextInputType.url),
          const SizedBox(height: 10),
          _GField('Transportation notes', _transport, maxLines: 2),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: UdoDesign.sans(size: 12, color: UdoDesign.rose)),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save_outlined, size: 16),
            label: Text(_saving ? 'Saving...' : 'Save wedding profile'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: UdoDesign.rose,
              foregroundColor: Colors.white,
            ),
          ),
        ]),
      ),
    );
  }
}

class _WeddingDateInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onPick;
  const _WeddingDateInput({
    required this.label,
    required this.controller,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'YYYY-MM-DD',
        suffixIcon: IconButton(
          onPressed: onPick,
          icon: const Icon(Icons.event_outlined),
        ),
      ),
    );
  }
}

class _WeddingProfilePage extends StatelessWidget {
  final List<_ProfileField> fields;
  final DateTime? weddingDate;
  final String destination;
  final String guestCount;
  final String budgetStatus;
  final VoidCallback onComplete;
  final VoidCallback onPreview;

  const _WeddingProfilePage({
    required this.fields,
    required this.weddingDate,
    required this.destination,
    required this.guestCount,
    required this.budgetStatus,
    required this.onComplete,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final completed = fields.where((field) => field.isComplete).length;
    final progress = fields.isEmpty ? 0.0 : completed / fields.length;
    final missing = fields.where((field) => !field.isComplete).toList();
    final countdown = weddingDate == null
        ? 'Not set'
        : '${weddingDate!.difference(DateTime.now()).inDays.clamp(0, 9999)} days';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        _WeddingProfileHero(
          progress: progress,
          completed: completed,
          total: fields.length,
          missing: missing,
          onComplete: onComplete,
          onPreview: onPreview,
        ),
        const SizedBox(height: 16),
        _WeddingProfileAssistant(missing: missing, onComplete: onComplete),
        const SizedBox(height: 18),
        _WeddingProfileOverview(
          date: weddingDate == null
              ? 'Not set'
              : DateFormat('EEE, MMM d, yyyy').format(weddingDate!),
          countdown: countdown,
          location: destination.isEmpty ? 'Not set' : destination,
          guestCount: guestCount,
          budgetStatus: budgetStatus,
          progress: progress,
          onTap: onComplete,
        ),
        const SizedBox(height: 22),
        UdoSectionHeader(title: 'Profile Sections'),
        _WeddingProfileSection(
          title: 'Ceremony',
          icon: Icons.church_outlined,
          color: UdoDesign.rose,
          onEdit: onComplete,
          fields: fields
              .where((field) => [
                    'Wedding date',
                    'Wedding type',
                    'Ceremony venue',
                    'Ceremony time',
                    'Reception venue',
                    'Reception time',
                    'Destination',
                    'Celebrant',
                  ].contains(field.label))
              .toList(),
        ),
        _WeddingProfileSection(
          title: 'Guest Portal',
          icon: Icons.groups_outlined,
          color: UdoDesign.blue,
          onEdit: onComplete,
          fields: fields
              .where((field) => [
                    'RSVP deadline',
                    'Guest count',
                    'Wedding website',
                    'Wedding hashtag',
                    'Dress code',
                  ].contains(field.label))
              .toList(),
        ),
        _WeddingProfileSection(
          title: 'Operations',
          icon: Icons.tune_outlined,
          color: UdoDesign.sage,
          onEdit: onComplete,
          fields: fields
              .where((field) => [
                    'Parking information',
                    'Google Maps link',
                    'Transportation',
                    'Venue status',
                    'Planning approach',
                  ].contains(field.label))
              .toList(),
        ),
        UdoCard(
          onTap: onComplete,
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Icon(Icons.info_outline, color: UdoDesign.muted, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                  'Keep this profile current so invites, guest updates, live wedding details, and your wedding story stay accurate.',
                  style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted)),
            ),
          ]),
        ),
      ],
    );
  }
}

class _WeddingProfileHero extends StatelessWidget {
  final double progress;
  final int completed;
  final int total;
  final List<_ProfileField> missing;
  final VoidCallback onComplete;
  final VoidCallback onPreview;

  const _WeddingProfileHero({
    required this.progress,
    required this.completed,
    required this.total,
    required this.missing,
    required this.onComplete,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      color: UdoDesign.rose,
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const UdoBadge(
                  label: 'Source of truth',
                  color: Colors.white,
                  background: Color(0x22FFFFFF)),
              const SizedBox(height: 12),
              Text('Wedding Profile',
                  style: UdoDesign.serif(size: 34, color: Colors.white)),
              const SizedBox(height: 8),
              Text('One place to manage the details that power your wedding.',
                  style: UdoDesign.sans(
                      size: 13.5, color: Colors.white70, height: 1.45)),
            ]),
          ),
          UdoRingProgress(
            value: progress,
            color: Colors.white,
            size: 76,
            center: Text('${(progress * 100).round()}%',
                style: UdoDesign.sans(
                    size: 14, weight: FontWeight.w800, color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _ProfileSignal(label: '$completed of $total complete', done: true),
          for (final field in missing.take(2))
            _ProfileSignal(label: '${field.label} missing', done: false),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: UdoDesign.rose,
                  minimumSize: const Size(0, 46)),
              child: const Text('Complete Profile'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: onPreview,
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  minimumSize: const Size(0, 46)),
              child: const Text('View guest portal'),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _ProfileSignal extends StatelessWidget {
  final String label;
  final bool done;
  const _ProfileSignal({required this.label, required this.done});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(done ? Icons.check_circle : Icons.warning_amber_rounded,
              color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(label,
              style: UdoDesign.sans(
                  size: 11, weight: FontWeight.w700, color: Colors.white)),
        ]),
      );
}

class _WeddingProfileAssistant extends StatelessWidget {
  final List<_ProfileField> missing;
  final VoidCallback onComplete;

  const _WeddingProfileAssistant({
    required this.missing,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final text = missing.isEmpty
        ? 'Your wedding profile is complete enough to power guest-facing modules.'
        : '${missing.length} detail${missing.length == 1 ? '' : 's'} missing before the profile is fully complete.';
    return UdoCard(
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.auto_awesome_outlined, color: UdoDesign.rose),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Wedding assistant',
                style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(text,
                style: UdoDesign.sans(
                    size: 12.5, color: UdoDesign.muted, height: 1.42)),
          ]),
        ),
        TextButton(onPressed: onComplete, child: const Text('Fix')),
      ]),
    );
  }
}

class _WeddingProfileOverview extends StatelessWidget {
  final String date, countdown, location, guestCount, budgetStatus;
  final double progress;
  final VoidCallback onTap;

  const _WeddingProfileOverview({
    required this.date,
    required this.countdown,
    required this.location,
    required this.guestCount,
    required this.budgetStatus,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Wedding Date', date, Icons.calendar_today_outlined, UdoDesign.rose),
      (
        'Countdown',
        countdown,
        Icons.hourglass_bottom_outlined,
        UdoDesign.amber
      ),
      ('Location', location, Icons.location_city_outlined, UdoDesign.blue),
      ('Guest Count', guestCount, Icons.groups_outlined, UdoDesign.sage),
      (
        'Budget',
        budgetStatus,
        Icons.account_balance_wallet_outlined,
        UdoDesign.gold
      ),
      (
        'Progress',
        '${(progress * 100).round()}%',
        Icons.insights_outlined,
        UdoDesign.plan
      ),
    ];

    return UdoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.15,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return Row(children: [
            Icon(item.$3, color: item.$4, size: 20),
            const SizedBox(width: 9),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text(item.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UdoDesign.sans(size: 13, weight: FontWeight.w800)),
                  Text(item.$1,
                      style:
                          UdoDesign.sans(size: 10.5, color: UdoDesign.muted)),
                ])),
          ]);
        },
      ),
    );
  }
}

class _WeddingProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onEdit;
  final List<_ProfileField> fields;

  const _WeddingProfileSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.onEdit,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    final completed = fields.where((field) => field.isComplete).length;
    return UdoCard(
      onTap: onEdit,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 10),
          Expanded(
              child: Text(title,
                  style: UdoDesign.sans(size: 15, weight: FontWeight.w800))),
          UdoBadge(
              label: '$completed/${fields.length}',
              color: color,
              background: color.withValues(alpha: 0.10)),
          const SizedBox(width: 8),
          Icon(Icons.edit_outlined, color: color, size: 17),
        ]),
        const SizedBox(height: 12),
        for (final field in fields) _WeddingProfileFieldRow(field: field),
      ]),
    );
  }
}

class _WeddingProfileFieldRow extends StatelessWidget {
  final _ProfileField field;
  const _WeddingProfileFieldRow({required this.field});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Icon(field.icon,
              size: 17,
              color: field.isComplete ? UdoDesign.sage : UdoDesign.amber),
          const SizedBox(width: 10),
          Expanded(
              child: Text(field.label,
                  style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted))),
          Flexible(
            child: Text(field.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: UdoDesign.sans(size: 12.5, weight: FontWeight.w800)),
          ),
        ]),
      );
}

class _GField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final TextInputType? type;
  final int maxLines;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  const _GField(this.label, this.ctrl,
      {this.type, this.maxLines = 1, this.focusNode, this.onSubmitted});

  @override
  Widget build(BuildContext context) => TextField(
        controller: ctrl,
        focusNode: focusNode,
        keyboardType: type,
        maxLines: maxLines,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: label,
          hintStyle:
              const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14),
          labelStyle:
              const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 12),
          filled: true,
          fillColor: AppTheme.udoCardFill,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppTheme.udoGreen, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}

class _ModalInfoRow extends StatelessWidget {
  final String label, value;
  const _ModalInfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          SizedBox(
              width: 140,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.udoTextSecondary))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500))),
        ]),
      );
}
