import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/date_formatters.dart' as udo_dates;
import '../../../../shared/widgets/place_search_field.dart';
import '../../../../shared/widgets/udo_design_system.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../live/presentation/providers/live_provider.dart';
import '../../../more/presentation/providers/more_operations_provider.dart';
import '../providers/guests_provider.dart';
import '../providers/logistics_provider.dart';
import '../providers/messages_provider.dart';
import '../providers/experience_provider.dart';
import '../providers/invitation_provider.dart';
import 'invitation_shared.dart';
import 'invitation_wizard_screen.dart';

String _statusLabel(String? s) => switch (s) {
      'yes' => 'Attending',
      'no' => 'Declined',
      _ => 'Pending',
    };

Color _statusColorFor(String? s) => switch (s) {
      'yes' => const Color(0xFF22C55E),
      'no' => AppTheme.udoCrimson,
      _ => Colors.orange,
    };

class GuestsScreen extends ConsumerStatefulWidget {
  final String? initialTab;
  final String? initialStatusFilter;
  final String? initialInfoFilter;
  const GuestsScreen({
    super.key,
    this.initialTab,
    this.initialStatusFilter,
    this.initialInfoFilter,
  });
  @override
  ConsumerState<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends ConsumerState<GuestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _search = '';
  String _statusFilter = 'all';
  // Independent of _statusFilter (which round-trips to the server) — these
  // are purely client-side predicates over the already-loaded guest list, so
  // Overview/Logistics can deep-link into a filtered Guest List with no new
  // fetch and no backend "status" value the server wouldn't recognize.
  // Values: null | 'missing_contact' | 'missing_meal' | 'missing_arrival' |
  // 'missing_accommodation' | 'missing_transport'.
  String? _infoFilter;
  bool _quickInviteMode = true;
  bool _drawerOpen = false;
  Timer? _dailyRefreshTimer;
  DateTime? _lastDailyRefresh;

  void _jumpToGuestList({String? infoFilter, String? statusFilter}) {
    setState(() {
      _infoFilter = infoFilter;
      if (statusFilter != null) _statusFilter = statusFilter;
    });
    if (statusFilter != null) {
      ref
          .read(guestsProvider.notifier)
          .loadFiltered(search: _search, status: statusFilter);
    }
    _tabs.animateTo(1);
  }

  static const _tabLabels = [
    'Overview',
    'Guest list',
    'Invitations',
    'Experience',
    'Messages',
    'Check In',
    'Logistics'
  ];

  @override
  void initState() {
    super.initState();
    final initialIndex =
        widget.initialTab == null ? 0 : _tabLabels.indexOf(widget.initialTab!);
    _statusFilter = widget.initialStatusFilter ?? 'all';
    _infoFilter = widget.initialInfoFilter;
    _tabs = TabController(
        length: 7,
        vsync: this,
        initialIndex: initialIndex < 0 ? 0 : initialIndex);
    _tabs.addListener(() => setState(() {}));
    if (_statusFilter != 'all') {
      Future.microtask(() => ref
          .read(guestsProvider.notifier)
          .loadFiltered(search: _search, status: _statusFilter));
    }
    _lastDailyRefresh = DateTime.now();
    _dailyRefreshTimer = Timer.periodic(const Duration(hours: 1), (_) {
      final now = DateTime.now();
      final last = _lastDailyRefresh;
      if (last == null ||
          now.year != last.year ||
          now.month != last.month ||
          now.day != last.day) {
        _lastDailyRefresh = now;
        ref.read(guestsProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _dailyRefreshTimer?.cancel();
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guestsProvider);
    final notifier = ref.read(guestsProvider.notifier);

    return Scaffold(
      backgroundColor: UdoDesign.bg,
      body: Stack(
        children: [
          Column(
            children: [
              _GuestWorkspaceHeader(
                title: _guestPages[_tabs.index].title,
                totalGuests: state.guests.length,
                onMenuTap: () => setState(() => _drawerOpen = true),
                onSearchTap: () => _tabs.animateTo(1),
                onAddGuest: () => _showAddModal(context, notifier),
              ),
              if (state.isOffline)
                _GuestStaleBanner(
                    cachedAt: state.cachedAt, onRefresh: notifier.refresh),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _OverviewTab(
                      state: state,
                      onGoToList: () => _tabs.animateTo(1),
                      onAddGuest: () => _showAddModal(context, notifier),
                      onGoToLogistics: () => _tabs.animateTo(6),
                      onGuestTap: (g) => context.push('/guests/${g['id']}'),
                      onJumpToGuestList: _jumpToGuestList,
                    ),
                    _GuestListTab(
                      state: state,
                      search: _search,
                      statusFilter: _statusFilter,
                      infoFilter: _infoFilter,
                      onSearchChanged: (v) => setState(() => _search = v),
                      onFilterChanged: (v) => setState(() => _statusFilter = v),
                      onInfoFilterChanged: (v) =>
                          setState(() => _infoFilter = v),
                      onAddGuest: () => _showAddModal(context, notifier),
                      onGuestTap: (g) => context.push('/guests/${g['id']}'),
                    ),
                    const _InvitationsTab(),
                    _ExperienceTab(onGoToList: () => _tabs.animateTo(1)),
                    const _MessagesTab(),
                    const _CheckInTab(),
                    _LogisticsTab(onJumpToGuestList: _jumpToGuestList),
                  ],
                ),
              ),
            ],
          ),
          _GuestWorkspaceDrawer(
            open: _drawerOpen,
            activeIndex: _tabs.index,
            state: state,
            onClose: () => setState(() => _drawerOpen = false),
            onNavigate: _navigateGuestPage,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddModal(context, notifier),
        backgroundColor: AppTheme.udoGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Guest Assistant'),
      ),
    );
  }

  void _showAddModal(BuildContext context, GuestsNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddGuestModal(
          notifier: notifier,
          quickMode: _quickInviteMode,
          onToggleMode: (v) => setState(() => _quickInviteMode = v)),
    );
  }

  void _navigateGuestPage(int index) {
    if (index < 0 || index >= _tabs.length) return;
    _tabs.animateTo(index);
    if (_drawerOpen) setState(() => _drawerOpen = false);
  }
}

// ── HEADER ─────────────────────────────────────────────────────────────────────

const _guestAccent = Color(0xFFCB2957);

class _GuestPageMeta {
  final String title;
  final IconData icon;
  const _GuestPageMeta(this.title, this.icon);
}

const _guestPages = [
  _GuestPageMeta('Overview', Icons.dashboard_outlined),
  _GuestPageMeta('Guest Directory', Icons.groups_outlined),
  _GuestPageMeta('Invitations', Icons.mark_email_unread_outlined),
  _GuestPageMeta('Guest Portal', Icons.room_service_outlined),
  _GuestPageMeta('Communication Centre', Icons.chat_bubble_outline),
  _GuestPageMeta('Check In', Icons.qr_code_scanner_outlined),
  _GuestPageMeta('Logistics', Icons.luggage_outlined),
];

class _GuestWorkspaceHeader extends StatelessWidget {
  final String title;
  final int totalGuests;
  final VoidCallback onMenuTap;
  final VoidCallback onSearchTap;
  final VoidCallback onAddGuest;

  const _GuestWorkspaceHeader({
    required this.title,
    required this.totalGuests,
    required this.onMenuTap,
    required this.onSearchTap,
    required this.onAddGuest,
  });

  @override
  Widget build(BuildContext context) {
    final isOverview = title == 'Overview';
    return Container(
      color: UdoDesign.bg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _GuestRoundButton(icon: Icons.menu, onTap: onMenuTap),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(isOverview ? 'Guests' : title,
                          maxLines: 1,
                          style: UdoDesign.serif(
                              size: isOverview ? 36 : 24,
                              color: UdoDesign.text)),
                    ),
                    if (!isOverview) ...[
                      const SizedBox(height: 6),
                      Text('$totalGuests guests in this workspace',
                          style: UdoDesign.sans(
                              size: 12.5, color: UdoDesign.muted)),
                    ],
                  ]),
            ),
            _GuestRoundButton(icon: Icons.search, onTap: onSearchTap),
            const SizedBox(width: 10),
            _GuestRoundButton(
                icon: Icons.person_add_alt_1_outlined, onTap: onAddGuest),
          ]),
        ),
      ),
    );
  }
}

class _GuestRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GuestRoundButton({required this.icon, required this.onTap});

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
            width: 50,
            height: 50,
            child: Icon(icon, color: _guestAccent, size: 22),
          ),
        ),
      );
}

class _GuestWorkspaceDrawer extends StatelessWidget {
  final bool open;
  final int activeIndex;
  final GuestsState state;
  final VoidCallback onClose;
  final ValueChanged<int> onNavigate;

  const _GuestWorkspaceDrawer({
    required this.open,
    required this.activeIndex,
    required this.state,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final pending = state.guests
        .where((g) =>
            g['attending_status'] == null || g['attending_status'] == 'pending')
        .length;
    final missingMeal = state.guests.where(_guestMissingMeal).length;
    final missingLogistics = state.guests
        .where((g) => _guestMatchesInfoFilter(g, 'missing_logistics'))
        .length;
    final checkedIn =
        state.guests.where((g) => g['checked_in_at'] != null).length;
    final badges = [
      '${state.guests.length} Guests',
      '${state.guests.length} Guests',
      pending > 0 ? '$pending Pending' : 'Current',
      missingMeal > 0 ? '$missingMeal Missing' : 'Ready',
      state.activity.isEmpty
          ? 'No updates'
          : '${state.activity.length} Updates',
      '$checkedIn Arrived',
      missingLogistics > 0 ? '$missingLogistics Missing' : 'Arranged',
    ];

    return IgnorePointer(
      ignoring: !open,
      child: AnimatedOpacity(
        opacity: open ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Stack(children: [
          GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.black.withValues(alpha: 0.16)),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            right: open ? 0 : -MediaQuery.sizeOf(context).width,
            width: MediaQuery.sizeOf(context).width * 0.86,
            child: SafeArea(
              child: UdoCard(
                radius: 0,
                border: BorderSide.none,
                padding: const EdgeInsets.fromLTRB(20, 20, 18, 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text('Guests',
                              style: UdoDesign.serif(
                                  size: 34, color: UdoDesign.text)),
                        ),
                        IconButton(
                            onPressed: onClose, icon: const Icon(Icons.close)),
                      ]),
                      Container(
                        margin: const EdgeInsets.only(top: 6, bottom: 18),
                        height: 2,
                        width: 68,
                        color: UdoDesign.gold,
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            for (var i = 0; i < _guestPages.length; i++)
                              _GuestDrawerRow(
                                meta: _guestPages[i],
                                badge: badges[i],
                                active: i == activeIndex,
                                onTap: () => onNavigate(i),
                              ),
                            const SizedBox(height: 12),
                            _GuestDrawerRow(
                              meta: const _GuestPageMeta(
                                  'Seating', Icons.event_seat_outlined),
                              badge: 'Plan module',
                              active: false,
                              onTap: () {
                                onClose();
                                context.push('/plan/seating');
                              },
                            ),
                          ],
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _GuestDrawerRow extends StatelessWidget {
  final _GuestPageMeta meta;
  final String badge;
  final bool active;
  final VoidCallback onTap;

  const _GuestDrawerRow({
    required this.meta,
    required this.badge,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      color: active ? UdoDesign.bg : UdoDesign.card,
      border: BorderSide(
          color:
              active ? _guestAccent.withValues(alpha: 0.22) : UdoDesign.border),
      child: Row(children: [
        Icon(meta.icon,
            color: active ? _guestAccent : UdoDesign.muted, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(meta.title,
              style: UdoDesign.sans(
                  size: 14,
                  weight: FontWeight.w800,
                  color: active ? _guestAccent : UdoDesign.text)),
        ),
        UdoBadge(label: badge, color: active ? _guestAccent : UdoDesign.muted),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right, size: 17, color: UdoDesign.muted),
      ]),
    );
  }
}

class _GuestStaleBanner extends StatelessWidget {
  final DateTime? cachedAt;
  final Future<void> Function() onRefresh;

  const _GuestStaleBanner({required this.cachedAt, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final saved = cachedAt == null
        ? 'saved guest data'
        : 'guest data saved ${TimeOfDay.fromDateTime(cachedAt!).format(context)}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: const Color(0xFFFFF8E8),
      child: Row(children: [
        const Icon(Icons.wifi_off_outlined, color: Color(0xFF9A6B00), size: 18),
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

class GuestLegacyHeader extends StatelessWidget {
  final TabController tabs;
  final List<String> tabLabels;
  final int totalGuests;
  const GuestLegacyHeader(
      {required this.tabs, required this.tabLabels, required this.totalGuests});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.udoGreen,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(children: [
                const Expanded(
                    child: Text('Guests',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Playfair',
                            fontSize: 24,
                            fontWeight: FontWeight.w400))),
                Text('$totalGuests',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
              ]),
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              tabs: tabLabels.map((l) => Tab(text: l)).toList(),
              labelColor: AppTheme.udoGreen,
              unselectedLabelColor: Colors.white,
              indicator: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(vertical: 4),
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              dividerColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

// ── OVERVIEW TAB ───────────────────────────────────────────────────────────────

class _OverviewTab extends ConsumerWidget {
  final GuestsState state;
  final VoidCallback onGoToList;
  final VoidCallback onAddGuest;
  final VoidCallback onGoToLogistics;
  final void Function(Map<String, dynamic>) onGuestTap;
  final void Function({String? infoFilter, String? statusFilter})
      onJumpToGuestList;
  const _OverviewTab(
      {required this.state,
      required this.onGoToList,
      required this.onAddGuest,
      required this.onGoToLogistics,
      required this.onGuestTap,
      required this.onJumpToGuestList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = state.guests.length;
    final attending =
        state.guests.where((g) => g['attending_status'] == 'yes').length;
    final pending = state.guests
        .where((g) =>
            g['attending_status'] == null || g['attending_status'] == 'pending')
        .length;
    final declined =
        state.guests.where((g) => g['attending_status'] == 'no').length;
    final confirmPct = total > 0 ? attending / total : 0.0;
    final missingContact = state.guests.where(_guestMissingContact).length;
    final missingMeal = state.guests.where(_guestMissingMeal).length;
    final missingArrival = state.guests
        .where((g) => _guestMatchesInfoFilter(g, 'missing_arrival'))
        .length;
    final missingAccommodation = state.guests
        .where((g) => _guestMatchesInfoFilter(g, 'missing_accommodation'))
        .length;
    final accessibilitySeating =
        state.guests.where(_guestNeedsAccessibilitySeating).length;
    final invitationsSent =
        state.guests.where((g) => g['invite_status'] == 'sent').length;
    final outstanding = state.guests.where(_guestNeedsRsvpFollowUp).length;
    final plusOnes = state.guests.fold<int>(
        0, (sum, g) => sum + ((g['plus_one_count'] as num?)?.toInt() ?? 0));
    final wedding = ref.watch(moreOperationsProvider).activeWedding;
    final rsvpDeadline = wedding?['rsvp_deadline'] as String?;
    final firstName = ref.watch(authProvider).user?.firstName.trim();

    if (state.error != null && state.guests.isEmpty) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        const SizedBox(height: 60),
        _errorBox("Couldn't load your guests.", state.error!),
      ]);
    }

    final rebuiltOverview = _GuestCommandCentrePage(
      total: total,
      attending: attending,
      pending: pending,
      declined: declined,
      invitationsSent: invitationsSent,
      plusOnes: plusOnes,
      confirmPct: confirmPct,
      missingContact: missingContact,
      missingMeal: missingMeal,
      missingArrival: missingArrival,
      missingAccommodation: missingAccommodation,
      accessibilitySeating: accessibilitySeating,
      outstanding: outstanding,
      activity: state.activity,
      guests: state.guests,
      onAddGuest: onAddGuest,
      onImportCsv: () => _showImportCsv(context, ref),
      onSendInvites: () => _sendBulkInvites(context, ref),
      onSendReminder: () =>
          _showOutstandingGuestMessageSheet(context, ref, state.guests),
      onMealSummary: () => _showMealSummary(context, state.guests),
      onTravelOverview: onGoToLogistics,
      onGoToList: onGoToList,
      onGuestTap: onGuestTap,
      onJumpToGuestList: onJumpToGuestList,
      rsvpDeadline: rsvpDeadline,
      firstName: firstName?.isEmpty == true ? null : firstName,
    );
    if (MediaQuery.sizeOf(context).width >= 0) {
      return rebuiltOverview;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (total > 0) ...[
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.3,
            children: [
              _KpiTile('$total', 'Total Guests', AppTheme.udoGreen),
              _KpiTile('$invitationsSent', 'Invitations Sent', Colors.indigo),
              _KpiTile('$pending', 'Pending RSVP', Colors.orange),
              _KpiTile('$attending', 'Confirmed', const Color(0xFF22C55E)),
              _KpiTile('$declined', 'Declined', AppTheme.udoCrimson),
              _KpiTile('$plusOnes', 'Plus Ones', Colors.purple),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (total > 0)
          _RsvpDeadlineCard(
              deadline: rsvpDeadline,
              confirmPct: confirmPct,
              pending: pending,
              onSendReminder: () => _showOutstandingGuestMessageSheet(
                  context, ref, state.guests)),
        if (total > 0) const SizedBox(height: 12),
        if (total > 0 &&
            (pending > 0 ||
                missingMeal > 0 ||
                missingContact > 0 ||
                missingArrival > 0 ||
                missingAccommodation > 0)) ...[
          _AttentionRequiredCard(
            pending: pending,
            missingMeal: missingMeal,
            missingContact: missingContact,
            missingArrival: missingArrival,
            missingAccommodation: missingAccommodation,
            onTapPending: () => onJumpToGuestList(statusFilter: 'pending'),
            onTapMissingMeal: () =>
                onJumpToGuestList(infoFilter: 'missing_meal'),
            onTapMissingContact: () =>
                onJumpToGuestList(infoFilter: 'missing_contact'),
            onTapMissingArrival: () =>
                onJumpToGuestList(infoFilter: 'missing_arrival'),
            onTapMissingAccommodation: () =>
                onJumpToGuestList(infoFilter: 'missing_accommodation'),
          ),
          const SizedBox(height: 12),
        ],
        // RSVP ring card
        _Card(
            child: Column(children: [
          const Text('RSVP status',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: confirmPct,
                  strokeWidth: 12,
                  backgroundColor: AppTheme.udoBorder,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.udoGreen),
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('$attending',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.udoGreen)),
                const Text('confirmed',
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.udoTextSecondary)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            _StatChip('$total\nTotal', AppTheme.udoGreen),
            _StatChip('$attending\nConfirmed', const Color(0xFF22C55E)),
            _StatChip('$pending\nPending', Colors.orange),
            _StatChip('$declined\nDeclined', AppTheme.udoCrimson),
          ]),
        ])),
        const SizedBox(height: 12),
        // Quick actions
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Quick actions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _ActionChip(
                Icons.person_add_outlined, 'Add guest', AppTheme.udoGreen,
                onTap: onAddGuest),
            _ActionChip(Icons.upload_file_outlined, 'Import CSV', Colors.indigo,
                onTap: () => _showImportCsv(context, ref)),
            _ActionChip(
                Icons.send_outlined, 'Send invites', AppTheme.udoCrimson,
                onTap: () => _sendBulkInvites(context, ref)),
            _ActionChip(
                Icons.restaurant_menu_outlined, 'Meal summary', Colors.orange,
                onTap: () => _showMealSummary(context, state.guests)),
            _ActionChip(Icons.flight_outlined, 'Travel overview', Colors.teal,
                onTap: () => _showTravelOverview(context, state.guests)),
            _ActionChip(
                Icons.people_outlined, 'View all', AppTheme.udoTextSecondary,
                onTap: onGoToList),
          ]),
        ])),
        const SizedBox(height: 12),
        // Recent guest activity — real events (RSVP, invites, hotel/transport
        // assignment), sourced from GET /guests/activity, not a fabricated feed.
        if (state.activity.isNotEmpty)
          _Card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Recent guest activity',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                ...state.activity
                    .take(6)
                    .map((event) => _ActivityRow(event: event)),
              ]))
        else if (state.guests.isNotEmpty)
          _Card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Recently added',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                ...state.guests.take(5).map(
                    (g) => _GuestRow(guest: g, onTap: () => onGuestTap(g))),
              ])),
      ],
    );
  }

  Future<void> sendRsvpReminder(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(messagesProvider.notifier).sendMessage(
          subject: 'RSVP reminder',
          body:
              "Just a friendly reminder to RSVP for our wedding — we'd love to know if you can make it!",
          audience: 'pending',
          channel: 'email',
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok
              ? 'RSVP reminder sent to pending guests.'
              : "Couldn't send the reminder. Try again.")));
    }
  }

  Future<void> _showOutstandingGuestMessageSheet(
      BuildContext context, WidgetRef ref, List<Map<String, dynamic>> guests) {
    final outstanding = guests.where(_guestNeedsRsvpFollowUp).toList();
    if (outstanding.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No outstanding guests with contact details.')));
      return Future.value();
    }
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _OutstandingGuestMessageSheet(guests: outstanding),
    );
  }

  Future<void> _showImportCsv(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt']);
    final file = result?.files.single;
    if (file == null || file.bytes == null) return;

    final text = String.fromCharCodes(file.bytes!);
    final lines =
        text.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return;

    // Skip a header row if the first line doesn't look like a name (contains "name"/"email").
    final startIdx = lines.first.toLowerCase().contains('name') ||
            lines.first.toLowerCase().contains('email')
        ? 1
        : 0;

    final parsed = <Map<String, dynamic>>[];
    for (final line in lines.skip(startIdx)) {
      final parts = line.split(',').map((p) => p.trim()).toList();
      if (parts.isEmpty || parts.first.isEmpty) continue;
      parsed.add({
        'first_name': parts[0],
        if (parts.length > 1 && parts[1].isNotEmpty) 'last_name': parts[1],
        if (parts.length > 2 && parts[2].isNotEmpty) 'email': parts[2],
      });
    }

    if (parsed.isEmpty) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'No rows found in that file. Expected: first_name,last_name,email')));
      return;
    }

    final imported = await ref.read(guestsProvider.notifier).bulkImport(parsed);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(imported > 0
              ? 'Imported $imported guest${imported == 1 ? '' : 's'}.'
              : "Couldn't import that file. Try again.")));
    }
  }

  Future<void> _sendBulkInvites(BuildContext context, WidgetRef ref) async {
    final targets = state.guests
        .where((g) =>
            g['invite_status'] != 'sent' &&
            (g['email'] as String?)?.isNotEmpty == true)
        .toList();
    if (targets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Everyone with an email on file has already been invited.')));
      return;
    }
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Text('Send invites',
                          style: UdoDesign.sans(
                              size: 18, weight: FontWeight.w800))),
                  IconButton(
                      onPressed: () => Navigator.pop(sheetContext, false),
                      icon: const Icon(Icons.close)),
                ]),
                const SizedBox(height: 8),
                Text(
                  'Send invitation emails to ${targets.length} guest${targets.length == 1 ? '' : 's'} who have an email and have not been invited yet.',
                  style: UdoDesign.sans(
                      size: 13, color: UdoDesign.muted, height: 1.4),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: targets.length,
                    itemBuilder: (_, i) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 15,
                        backgroundColor: _guestAccent.withValues(alpha: 0.12),
                        child: Text(_initials(targets[i]),
                            style: UdoDesign.sans(
                                size: 10,
                                color: _guestAccent,
                                weight: FontWeight.w800)),
                      ),
                      title: Text(_guestDisplayName(targets[i]),
                          style: UdoDesign.sans(
                              size: 13, weight: FontWeight.w700)),
                      subtitle: Text(targets[i]['email']?.toString() ?? '',
                          style:
                              UdoDesign.sans(size: 11, color: UdoDesign.muted)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext, false),
                          child: const Text('Cancel'))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(sheetContext, true),
                    icon: const Icon(Icons.send_outlined, size: 16),
                    label: const Text('Send invites'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _guestAccent,
                        foregroundColor: Colors.white),
                  )),
                ]),
              ]),
        ),
      ),
    );
    if (confirmed != true) return;

    var sent = 0;
    for (final g in targets) {
      final ok =
          await ref.read(guestsProvider.notifier).sendInvite(g['id'] as int);
      if (ok) sent++;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sent $sent of ${targets.length} invites.')));
    }
  }

  void _showMealSummary(
      BuildContext context, List<Map<String, dynamic>> guests) {
    final tally = <String, int>{};
    for (final g in guests) {
      final pref = (g['meal_preference'] as String?)?.trim();
      final key = (pref == null || pref.isEmpty) ? 'Not specified' : pref;
      tally[key] = (tally[key] ?? 0) + 1;
    }
    _showBreakdownSheet(context, 'Meal summary', tally);
  }

  void _showTravelOverview(
      BuildContext context, List<Map<String, dynamic>> guests) {
    final needsTravel =
        guests.where((g) => g['travel_required'] == true).length;
    final arranged = guests
        .where((g) =>
            g['travel_required'] == true &&
            (g['hotel_assignment_id'] != null ||
                g['transport_assignment_id'] != null))
        .length;
    final notNeeded = guests.length - needsTravel;
    _showBreakdownSheet(context, 'Travel overview', {
      'Needs travel arrangements': needsTravel,
      'Already arranged': arranged,
      'No travel needed': notNeeded,
    });
  }
}

class _GuestCommandCentrePage extends StatelessWidget {
  final int total;
  final int attending;
  final int pending;
  final int declined;
  final int invitationsSent;
  final int plusOnes;
  final double confirmPct;
  final int missingContact;
  final int missingMeal;
  final int missingArrival;
  final int missingAccommodation;
  final int accessibilitySeating;
  final int outstanding;
  final List<Map<String, dynamic>> activity;
  final List<Map<String, dynamic>> guests;
  final VoidCallback onAddGuest;
  final VoidCallback onImportCsv;
  final VoidCallback onSendInvites;
  final VoidCallback onSendReminder;
  final VoidCallback onMealSummary;
  final VoidCallback onTravelOverview;
  final VoidCallback onGoToList;
  final void Function(Map<String, dynamic>) onGuestTap;
  final void Function({String? infoFilter, String? statusFilter})
      onJumpToGuestList;
  final String? rsvpDeadline;
  final String? firstName;

  const _GuestCommandCentrePage({
    required this.total,
    required this.attending,
    required this.pending,
    required this.declined,
    required this.invitationsSent,
    required this.plusOnes,
    required this.confirmPct,
    required this.missingContact,
    required this.missingMeal,
    required this.missingArrival,
    required this.missingAccommodation,
    required this.accessibilitySeating,
    required this.outstanding,
    required this.activity,
    required this.guests,
    required this.onAddGuest,
    required this.onImportCsv,
    required this.onSendInvites,
    required this.onSendReminder,
    required this.onMealSummary,
    required this.onTravelOverview,
    required this.onGoToList,
    required this.onGuestTap,
    required this.onJumpToGuestList,
    required this.rsvpDeadline,
    required this.firstName,
  });

  @override
  Widget build(BuildContext context) {
    final needsAttention = [
      if (pending > 0)
        (
          'RSVPs',
          '$pending guests still need to RSVP',
          Icons.mark_email_unread_outlined,
          () => onJumpToGuestList(statusFilter: 'pending')
        ),
      if (missingMeal > 0)
        (
          'Meals',
          '$missingMeal meal selections missing',
          Icons.restaurant_menu_outlined,
          () => onJumpToGuestList(infoFilter: 'missing_meal')
        ),
      if (missingArrival > 0)
        (
          'Travel',
          '$missingArrival guests have incomplete arrival details',
          Icons.flight_land_outlined,
          () => onJumpToGuestList(infoFilter: 'missing_arrival')
        ),
      if (missingAccommodation > 0)
        (
          'Rooms',
          '$missingAccommodation accommodation assignments missing',
          Icons.hotel_outlined,
          () => onJumpToGuestList(infoFilter: 'missing_accommodation')
        ),
      if (missingContact > 0)
        (
          'Contacts',
          '$missingContact guests need contact information',
          Icons.contact_mail_outlined,
          () => onJumpToGuestList(infoFilter: 'missing_contact')
        ),
      if (accessibilitySeating > 0)
        (
          'Accessibility',
          '$accessibilitySeating guests require wheelchair seating',
          Icons.accessible_forward_outlined,
          () => onJumpToGuestList(infoFilter: 'accessibility_seating')
        ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        _GuestTopActionCard(
          firstName: firstName?.isEmpty == true ? null : firstName,
          outstanding: outstanding,
          missingAccommodation: missingAccommodation,
          onTap: outstanding > 0 ? onSendReminder : onAddGuest,
        ),
        const SizedBox(height: 16),
        _GuestHeroCard(
          total: total,
          attending: attending,
          pending: pending,
          confirmPct: confirmPct,
          onSendReminder: onSendReminder,
          onAddGuest: onAddGuest,
        ),
        const SizedBox(height: 16),
        if (needsAttention.isNotEmpty) ...[
          UdoSectionHeader(title: 'Needs Attention'),
          for (final item in needsAttention)
            _GuestAttentionRow(
              title: item.$1,
              body: item.$2,
              icon: item.$3,
              onTap: item.$4,
            ),
          const SizedBox(height: 12),
        ],
        _GuestHealthGrid(
          attending: attending,
          pending: pending,
          declined: declined,
          invitationsSent: invitationsSent,
          plusOnes: plusOnes,
          missingMeal: missingMeal,
          missingAccommodation: missingAccommodation,
          missingArrival: missingArrival,
          mealsSpecified: guests
              .where((g) =>
                  (g['meal_preference'] as String?)?.trim().isNotEmpty ?? false)
              .length,
          totalGuests: guests.length,
          onRsvps: () => onJumpToGuestList(statusFilter: 'yes'),
          onMeals: () => onJumpToGuestList(infoFilter: 'missing_meal'),
          onAccommodation: () =>
              onJumpToGuestList(infoFilter: 'missing_accommodation'),
          onTravel: () => onJumpToGuestList(infoFilter: 'missing_transport'),
          onInvitations: () => onJumpToGuestList(infoFilter: 'not_invited'),
          onPlusOnes: () => onJumpToGuestList(infoFilter: 'plus_ones'),
        ),
        const SizedBox(height: 18),
        _GuestActionPanel(
          onAddGuest: onAddGuest,
          onImportCsv: onImportCsv,
          onSendInvites: onSendInvites,
          onMealSummary: onMealSummary,
          onTravelOverview: onTravelOverview,
          onGoToList: onGoToList,
        ),
        const SizedBox(height: 18),
        _GuestSmartRecommendation(
          pending: pending,
          missingMeal: missingMeal,
          missingArrival: missingArrival,
          onSendReminder: onSendReminder,
          onMealSummary: onMealSummary,
          onTravelOverview: onTravelOverview,
        ),
        const SizedBox(height: 18),
        UdoSectionHeader(
          title:
              activity.isNotEmpty ? 'Recent Guest Activity' : 'Recently Added',
          action: 'View All',
          onAction: activity.isNotEmpty
              ? () => _showAllGuestActivitySheet(context, activity)
              : onGoToList,
        ),
        if (activity.isNotEmpty)
          UdoCard(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              for (final event in activity.take(6))
                _GuestActivityLine(event: event),
            ]),
          )
        else if (guests.isNotEmpty)
          UdoCard(
            padding: const EdgeInsets.all(6),
            child: Column(children: [
              for (final guest in guests.take(5))
                _GuestPreviewLine(guest: guest, onTap: () => onGuestTap(guest)),
            ]),
          )
        else
          _GuestEmptyStart(onAddGuest: onAddGuest, onImportCsv: onImportCsv),
        if (rsvpDeadline != null && rsvpDeadline!.isNotEmpty) ...[
          const SizedBox(height: 18),
          UdoCard(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              const Icon(Icons.event_available_outlined, color: _guestAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Text('RSVP deadline: ${_formatDeadline(rsvpDeadline!)}',
                    style: UdoDesign.sans(size: 13, weight: FontWeight.w700)),
              ),
            ]),
          ),
        ],
      ],
    );
  }
}

class _GuestHeroCard extends StatelessWidget {
  final int total;
  final int attending;
  final int pending;
  final double confirmPct;
  final VoidCallback onSendReminder;
  final VoidCallback onAddGuest;

  const _GuestHeroCard({
    required this.total,
    required this.attending,
    required this.pending,
    required this.confirmPct,
    required this.onSendReminder,
    required this.onAddGuest,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      color: _guestAccent,
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const UdoBadge(
                  label: 'Guest command centre',
                  color: UdoDesign.gold,
                  background: Color(0x22FFFFFF)),
              const SizedBox(height: 12),
              Text('How are my guests doing?',
                  style: UdoDesign.serif(size: 32, color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                total == 0
                    ? 'Start your guest workspace by adding or importing guests.'
                    : pending > 0
                        ? '$pending guests still need to RSVP.'
                        : 'Guest responses are in a good state.',
                style: UdoDesign.sans(
                    size: 13.5, color: Colors.white70, height: 1.45),
              ),
            ]),
          ),
          UdoRingProgress(
            value: confirmPct,
            color: Colors.white,
            size: 76,
            center: Text('${(confirmPct * 100).round()}%',
                style: UdoDesign.sans(
                    size: 14, weight: FontWeight.w800, color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _GuestHeroStat(label: 'Guests', value: '$total')),
          Expanded(
              child: _GuestHeroStat(label: 'Confirmed', value: '$attending')),
          Expanded(child: _GuestHeroStat(label: 'Pending', value: '$pending')),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: pending > 0 ? onSendReminder : onAddGuest,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _guestAccent,
                  minimumSize: const Size(0, 46)),
              child: Text(pending > 0 ? 'Take Action' : 'Add Guest'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: onAddGuest,
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  minimumSize: const Size(0, 46)),
              child: const Text('Quick Add'),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _GuestTopActionCard extends StatelessWidget {
  final String? firstName;
  final int outstanding;
  final int missingAccommodation;
  final VoidCallback onTap;

  const _GuestTopActionCard({
    required this.firstName,
    required this.outstanding,
    required this.missingAccommodation,
    required this.onTap,
  });

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _title {
    final name = firstName?.trim();
    if (name == null || name.isEmpty) return _greeting;
    return '$_greeting, $name';
  }

  String get _summary {
    if (outstanding > 0 && missingAccommodation > 0) {
      return '$outstanding guests still need to RSVP. Hotel rooms are filling quickly.';
    }
    if (outstanding > 0) {
      return '$outstanding guests still need to RSVP. Send a follow-up message.';
    }
    return 'Guest responses are in a good state. Keep your list up to date.';
  }

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      radius: 20,
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: UdoDesign.blue.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.groups_2_outlined,
              color: UdoDesign.blue, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UdoDesign.sans(size: 16, weight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(_summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: UdoDesign.sans(
                    size: 12.5, color: UdoDesign.muted, height: 1.25)),
          ]),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: UdoDesign.muted, size: 22),
      ]),
    );
  }
}

class _GuestHeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _GuestHeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: UdoDesign.sans(
                  size: 16, weight: FontWeight.w800, color: Colors.white)),
          Text(label, style: UdoDesign.sans(size: 10, color: Colors.white70)),
        ]),
      );
}

class _GuestAttentionRow extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final VoidCallback onTap;
  const _GuestAttentionRow(
      {required this.title,
      required this.body,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) => UdoCard(
        onTap: onTap,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Icon(icon, color: UdoDesign.rose, size: 21),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: UdoDesign.sans(size: 14.5, weight: FontWeight.w800)),
                Text(body,
                    style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
              ])),
          const Icon(Icons.chevron_right, color: UdoDesign.muted),
        ]),
      );
}

class _GuestHealthGrid extends StatelessWidget {
  final int attending,
      pending,
      declined,
      invitationsSent,
      plusOnes,
      missingMeal,
      missingAccommodation,
      missingArrival,
      mealsSpecified,
      totalGuests;
  final VoidCallback onRsvps,
      onMeals,
      onAccommodation,
      onTravel,
      onInvitations,
      onPlusOnes;
  const _GuestHealthGrid({
    required this.attending,
    required this.pending,
    required this.declined,
    required this.invitationsSent,
    required this.plusOnes,
    required this.missingMeal,
    required this.missingAccommodation,
    required this.missingArrival,
    required this.mealsSpecified,
    required this.totalGuests,
    required this.onRsvps,
    required this.onMeals,
    required this.onAccommodation,
    required this.onTravel,
    required this.onInvitations,
    required this.onPlusOnes,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        'RSVPs',
        '$attending confirmed',
        Icons.how_to_reg_outlined,
        UdoDesign.sage,
        onRsvps
      ),
      (
        'Meals',
        '$mealsSpecified/$totalGuests set',
        Icons.restaurant_menu_outlined,
        UdoDesign.amber,
        onMeals
      ),
      (
        'Accommodation',
        missingAccommodation > 0 ? '$missingAccommodation missing' : 'Assigned',
        Icons.hotel_outlined,
        UdoDesign.blue,
        onAccommodation
      ),
      (
        'Transportation',
        missingArrival > 0 ? '$missingArrival pending' : 'Tracked',
        Icons.directions_bus_outlined,
        UdoDesign.plan,
        onTravel
      ),
      (
        'Invitations',
        '$invitationsSent sent',
        Icons.outgoing_mail,
        _guestAccent,
        onInvitations
      ),
      (
        'Plus Ones',
        '$plusOnes listed',
        Icons.group_add_outlined,
        UdoDesign.rose,
        onPlusOnes
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.95,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (context, index) {
        final card = cards[index];
        return UdoCard(
          onTap: card.$5,
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
                      style: UdoDesign.sans(size: 14, weight: FontWeight.w800)),
                  Text(card.$1,
                      style:
                          UdoDesign.sans(size: 10.5, color: UdoDesign.muted)),
                ])),
          ]),
        );
      },
    );
  }
}

class _GuestActionPanel extends StatelessWidget {
  final VoidCallback onAddGuest,
      onImportCsv,
      onSendInvites,
      onMealSummary,
      onTravelOverview,
      onGoToList;
  const _GuestActionPanel(
      {required this.onAddGuest,
      required this.onImportCsv,
      required this.onSendInvites,
      required this.onMealSummary,
      required this.onTravelOverview,
      required this.onGoToList});

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Add guest', Icons.person_add_outlined, onAddGuest),
      ('Import CSV', Icons.upload_file_outlined, onImportCsv),
      ('Send invites', Icons.send_outlined, onSendInvites),
      ('Meal summary', Icons.restaurant_menu_outlined, onMealSummary),
      ('Travel overview', Icons.flight_outlined, onTravelOverview),
      ('Directory', Icons.groups_outlined, onGoToList),
    ];
    return UdoCard(
      padding: const EdgeInsets.all(14),
      child: Wrap(spacing: 8, runSpacing: 8, children: [
        for (final action in actions)
          ActionChip(
            onPressed: action.$3,
            avatar: Icon(action.$2, size: 16, color: _guestAccent),
            label: Text(action.$1),
            backgroundColor: UdoDesign.card,
            side: const BorderSide(color: UdoDesign.stone),
            labelStyle: UdoDesign.sans(
                size: 12.5, weight: FontWeight.w700, color: UdoDesign.text),
          ),
      ]),
    );
  }
}

class _GuestSmartRecommendation extends StatelessWidget {
  final int pending, missingMeal, missingArrival;
  final VoidCallback onSendReminder, onMealSummary, onTravelOverview;
  const _GuestSmartRecommendation(
      {required this.pending,
      required this.missingMeal,
      required this.missingArrival,
      required this.onSendReminder,
      required this.onMealSummary,
      required this.onTravelOverview});

  @override
  Widget build(BuildContext context) {
    final text = pending > 0
        ? 'Send an RSVP reminder to $pending pending guest${pending == 1 ? '' : 's'}.'
        : missingMeal > 0
            ? 'Review meal selections before sharing counts with catering.'
            : missingArrival > 0
                ? 'Complete arrival details before transport assignments.'
                : 'Guest operations are stable. Review the directory for final checks.';
    final action = pending > 0
        ? onSendReminder
        : (missingMeal > 0 ? onMealSummary : onTravelOverview);
    return UdoCard(
      onTap: action,
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.auto_awesome_outlined, color: _guestAccent),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Smart recommendation',
              style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(text,
              style: UdoDesign.sans(
                  size: 12.5, color: UdoDesign.muted, height: 1.42)),
        ])),
        const Icon(Icons.chevron_right, color: UdoDesign.muted),
      ]),
    );
  }
}

class _GuestActivityLine extends StatelessWidget {
  final Map<String, dynamic> event;
  const _GuestActivityLine({required this.event});

  @override
  Widget build(BuildContext context) {
    final guestName = event['guest_name']?.toString() ?? 'A guest';
    final label = event['label']?.toString() ??
        event['action']?.toString() ??
        'had an update';
    final title = '$guestName $label';
    final createdAt = DateTime.tryParse(event['created_at']?.toString() ?? '');
    final subtitle = createdAt != null ? _relativeActivityTime(createdAt) : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        const Icon(Icons.bolt_outlined, color: _guestAccent, size: 18),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: UdoDesign.sans(size: 13, weight: FontWeight.w800)),
          if (subtitle.isNotEmpty)
            Text(subtitle,
                style: UdoDesign.sans(size: 11, color: UdoDesign.muted)),
        ])),
      ]),
    );
  }
}

void _showAllGuestActivitySheet(
    BuildContext context, List<Map<String, dynamic>> activity) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.92,
      builder: (sheetContext, controller) => SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
            child: Row(children: [
              Expanded(
                  child: Text('Recent guest activity',
                      style:
                          UdoDesign.sans(size: 18, weight: FontWeight.w800))),
              IconButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close)),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: activity.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: UdoDesign.stone),
              itemBuilder: (_, index) =>
                  _GuestActivityLine(event: activity[index]),
            ),
          ),
        ]),
      ),
    ),
  );
}

String _formatDeadline(String raw) {
  return udo_dates.formatApiDate(raw);
}

String _relativeActivityTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

class _GuestPreviewLine extends StatelessWidget {
  final Map<String, dynamic> guest;
  final VoidCallback onTap;
  const _GuestPreviewLine({required this.guest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name =
        '${guest['first_name'] ?? ''} ${guest['last_name'] ?? ''}'.trim();
    final status = guest['attending_status'] as String?;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          CircleAvatar(
              radius: 18,
              backgroundColor: _statusColorFor(status).withValues(alpha: 0.12),
              child: Text(_initials(guest),
                  style: UdoDesign.sans(
                      size: 11,
                      weight: FontWeight.w800,
                      color: _statusColorFor(status)))),
          const SizedBox(width: 12),
          Expanded(
              child: Text(name.isEmpty ? 'Guest' : name,
                  style: UdoDesign.sans(size: 13.5, weight: FontWeight.w800))),
          UdoBadge(label: _statusLabel(status), color: _statusColorFor(status)),
        ]),
      ),
    );
  }
}

class _GuestEmptyStart extends StatelessWidget {
  final VoidCallback onAddGuest;
  final VoidCallback onImportCsv;
  const _GuestEmptyStart({required this.onAddGuest, required this.onImportCsv});

  @override
  Widget build(BuildContext context) => UdoCard(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Icon(Icons.groups_outlined, size: 42, color: _guestAccent),
          const SizedBox(height: 12),
          Text('Build your guest hub',
              style: UdoDesign.sans(size: 16, weight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
              'Add guests one by one or import a CSV to start invitations, meals and logistics.',
              textAlign: TextAlign.center,
              style: UdoDesign.sans(
                  size: 12.5, color: UdoDesign.muted, height: 1.42)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: onAddGuest,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _guestAccent,
                        foregroundColor: Colors.white),
                    child: const Text('Add Guest'))),
            const SizedBox(width: 10),
            Expanded(
                child: OutlinedButton(
                    onPressed: onImportCsv,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: _guestAccent,
                        side: const BorderSide(color: _guestAccent)),
                    child: const Text('Import'))),
          ]),
        ]),
      );
}

String _initials(Map<String, dynamic> guest) {
  final first = guest['first_name']?.toString() ?? '';
  final last = guest['last_name']?.toString() ?? '';
  final value =
      '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}';
  return value.isEmpty ? '?' : value.toUpperCase();
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

Widget _errorBox(String title, String message) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 40, color: AppTheme.udoCrimson),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.udoCrimson)),
          const SizedBox(height: 6),
          Text(message,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary),
              textAlign: TextAlign.center),
        ]),
      ),
    );

class _StatChip extends StatelessWidget {
  final String text;
  final Color color;
  const _StatChip(this.text, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
          child: Column(children: [
        Text(text.split('\n')[0],
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600, color: color)),
        Text(text.split('\n')[1],
            style: const TextStyle(
                fontSize: 11, color: AppTheme.udoTextSecondary)),
      ]));
}

class _KpiTile extends StatelessWidget {
  final String value, label;
  final Color color;
  const _KpiTile(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.udoBorder)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.udoTextSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ]),
      );
}

class _ActivityRow extends StatelessWidget {
  final Map<String, dynamic> event;
  const _ActivityRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(event['created_at'] as String? ?? '');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5, right: 10),
          decoration: const BoxDecoration(
              color: AppTheme.udoGreen, shape: BoxShape.circle),
        ),
        Expanded(
            child: RichText(
          text: TextSpan(
              style:
                  const TextStyle(fontSize: 13, color: AppTheme.udoTextPrimary),
              children: [
                TextSpan(
                    text: '${event['guest_name'] ?? 'A guest'} ',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: event['label'] as String? ?? ''),
              ]),
        )),
        if (createdAt != null)
          Text(_relativeTime(createdAt),
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.udoTextSecondary)),
      ]),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _RsvpDeadlineCard extends StatelessWidget {
  final String? deadline;
  final double confirmPct;
  final int pending;
  final VoidCallback onSendReminder;
  const _RsvpDeadlineCard(
      {required this.deadline,
      required this.confirmPct,
      required this.pending,
      required this.onSendReminder});

  @override
  Widget build(BuildContext context) {
    final date = deadline == null ? null : DateTime.tryParse(deadline!);
    final daysRemaining = date
        ?.difference(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.udoBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: AppTheme.udoCrimson.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.event_available_outlined,
                color: AppTheme.udoCrimson, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('RSVP deadline',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.udoTextSecondary)),
                const SizedBox(height: 2),
                if (date == null || daysRemaining == null)
                  const Text('No deadline set — add one in Wedding settings.',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500))
                else
                  Builder(builder: (context) {
                    final days = daysRemaining;
                    return Text(
                      days < 0
                          ? 'Passed ${date.day}/${date.month}/${date.year}'
                          : (days == 0
                              ? 'Today'
                              : '$days day${days == 1 ? '' : 's'} remaining'),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: days < 0
                              ? AppTheme.udoCrimson
                              : AppTheme.udoTextPrimary),
                    );
                  }),
              ])),
        ]),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
              value: confirmPct,
              backgroundColor: AppTheme.udoBorder,
              valueColor: const AlwaysStoppedAnimation(AppTheme.udoGreen),
              minHeight: 6),
        ),
        const SizedBox(height: 6),
        Text('${(confirmPct * 100).round()}% responded',
            style: const TextStyle(
                fontSize: 11, color: AppTheme.udoTextSecondary)),
        if (pending > 0) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSendReminder,
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.udoCrimson,
                  side: const BorderSide(color: AppTheme.udoCrimson)),
              child: Text('Send RSVP Reminder ($pending pending)'),
            ),
          ),
        ],
      ]),
    );
  }
}

class _AttentionRequiredCard extends StatelessWidget {
  final int pending,
      missingMeal,
      missingContact,
      missingArrival,
      missingAccommodation;
  final VoidCallback onTapPending,
      onTapMissingMeal,
      onTapMissingContact,
      onTapMissingArrival,
      onTapMissingAccommodation;
  const _AttentionRequiredCard({
    required this.pending,
    required this.missingMeal,
    required this.missingContact,
    required this.missingArrival,
    required this.missingAccommodation,
    required this.onTapPending,
    required this.onTapMissingMeal,
    required this.onTapMissingContact,
    required this.onTapMissingArrival,
    required this.onTapMissingAccommodation,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppTheme.udoCrimson.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppTheme.udoCrimson.withValues(alpha: 0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.warning_amber_outlined,
                color: AppTheme.udoCrimson, size: 18),
            const SizedBox(width: 8),
            const Text('Attention required',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.udoCrimson)),
          ]),
          const SizedBox(height: 10),
          if (pending > 0)
            _AttentionRow(
                '$pending guest${pending == 1 ? '' : 's'} still pending RSVP',
                onTapPending),
          if (missingMeal > 0)
            _AttentionRow(
                '$missingMeal guest${missingMeal == 1 ? '' : 's'} missing meal selection',
                onTapMissingMeal),
          if (missingArrival > 0)
            _AttentionRow(
                '$missingArrival guest${missingArrival == 1 ? '' : 's'} missing arrival details',
                onTapMissingArrival),
          if (missingAccommodation > 0)
            _AttentionRow(
                '$missingAccommodation guest${missingAccommodation == 1 ? '' : 's'} need a hotel room assigned',
                onTapMissingAccommodation),
          if (missingContact > 0)
            _AttentionRow(
                '$missingContact guest${missingContact == 1 ? '' : 's'} missing contact information',
                onTapMissingContact),
        ]),
      );
}

class _AttentionRow extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _AttentionRow(this.text, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            Expanded(
                child: Text(text,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.udoCrimson))),
            const Icon(Icons.chevron_right,
                size: 16, color: AppTheme.udoCrimson),
          ]),
        ),
      );
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _ActionChip(this.icon, this.label, this.color, {this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 13, fontWeight: FontWeight.w500)),
          ]),
        ),
      );
}

// ── GUEST LIST TAB ─────────────────────────────────────────────────────────────

bool _guestMissingContact(Map<String, dynamic> g) =>
    (g['email'] as String? ?? '').isEmpty &&
    (g['phone'] as String? ?? '').isEmpty;

bool _guestMissingMeal(Map<String, dynamic> g) {
  final status = g['attending_status']?.toString().trim().toLowerCase();
  return status == 'yes' &&
      (g['meal_preference']?.toString().trim().isEmpty ?? true);
}

bool _guestNeedsAccessibilitySeating(Map<String, dynamic> g) {
  final status = g['attending_status']?.toString().trim().toLowerCase();
  return status == 'yes' &&
      g['accessibility_needs'] == true &&
      g['seating_assignment_id'] == null;
}

bool _guestHasContact(Map<String, dynamic> g) =>
    (g['email']?.toString().trim().isNotEmpty ?? false) ||
    (g['phone']?.toString().trim().isNotEmpty ?? false);

int? _guestId(Map<String, dynamic> g) {
  final id = g['id'];
  if (id is int) return id;
  if (id is num) return id.toInt();
  return int.tryParse(id?.toString() ?? '');
}

String _guestDisplayName(Map<String, dynamic> g) {
  final name = '${g['first_name'] ?? ''} ${g['last_name'] ?? ''}'.trim();
  return name.isEmpty ? 'Guest' : name;
}

bool _guestNeedsRsvpFollowUp(Map<String, dynamic> g) {
  final status = g['attending_status']?.toString().trim().toLowerCase();
  return _guestId(g) != null &&
      _guestHasContact(g) &&
      (status == null || status.isEmpty || status == 'pending');
}

/// Mirrors LogisticsController's exact predicates (app/Http/Controllers/LogisticsController.php)
/// so a drill-down list always matches the aggregate count it was opened from.
bool _guestMatchesInfoFilter(Map<String, dynamic> g, String filter) {
  switch (filter) {
    case 'missing_contact':
      return _guestMissingContact(g);
    case 'missing_meal':
      return _guestMissingMeal(g);
    case 'missing_arrival':
      return g['travel_required'] == true &&
          (g['arrival_date'] == null || g['arrival_time'] == null);
    case 'missing_accommodation':
      return g['travel_required'] == true && g['hotel_assignment_id'] == null;
    case 'missing_transport':
      return g['travel_required'] == true &&
          g['transport_assignment_id'] == null;
    case 'accessibility_seating':
      return _guestNeedsAccessibilitySeating(g);
    case 'not_invited':
      return g['invite_status'] != 'sent' &&
          (g['email']?.toString().trim().isNotEmpty ?? false);
    case 'plus_ones':
      return ((g['plus_one_count'] as num?)?.toInt() ?? 0) > 0;
    case 'missing_logistics':
      return g['travel_required'] == true &&
          (g['hotel_assignment_id'] == null ||
              g['transport_assignment_id'] == null);
    default:
      return true;
  }
}

const _infoFilterLabels = {
  'missing_contact': 'Missing contact',
  'missing_meal': 'Missing meal',
  'missing_arrival': 'Missing arrival info',
  'missing_accommodation': 'Missing accommodation',
  'missing_transport': 'Missing transport',
  'missing_logistics': 'Needs accommodation or transport',
  'accessibility_seating': 'Needs wheelchair seating',
  'not_invited': 'Not invited',
  'plus_ones': 'Plus-ones listed',
};

class _OutstandingGuestMessageSheet extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> guests;
  const _OutstandingGuestMessageSheet({required this.guests});

  @override
  ConsumerState<_OutstandingGuestMessageSheet> createState() =>
      _OutstandingGuestMessageSheetState();
}

class _OutstandingGuestMessageSheetState
    extends ConsumerState<_OutstandingGuestMessageSheet> {
  late final TextEditingController _subjectCtrl;
  late final TextEditingController _bodyCtrl;
  String _channel = 'email';

  static const _channels = {
    'email': 'Email',
    'sms': 'SMS',
    'whatsapp': 'WhatsApp',
    'in_app': 'Guest Portal Link',
  };

  @override
  void initState() {
    super.initState();
    _subjectCtrl = TextEditingController(text: 'Reminder: please RSVP');
    _bodyCtrl = TextEditingController(
        text:
            "We'd love to know if you're joining us. Please RSVP soon so we can finalize the wedding details.");
  }

  Future<void> _send() async {
    final guestIds = widget.guests.map(_guestId).whereType<int>().toList();
    final body = _bodyCtrl.text.trim();
    if (body.isEmpty || guestIds.isEmpty) return;
    final subject = _subjectCtrl.text.trim().isNotEmpty
        ? _subjectCtrl.text.trim()
        : 'Reminder: please RSVP';
    final ok = await ref.read(messagesProvider.notifier).sendMessage(
          subject: subject,
          body: body,
          audience: 'outstanding',
          channel: _channel,
          guestIds: guestIds,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok
          ? 'Message sent to ${guestIds.length} outstanding guest${guestIds.length == 1 ? '' : 's'}.'
          : "Couldn't send the message. Try again."),
      backgroundColor: ok ? AppTheme.udoGreen : UdoDesign.rose,
    ));
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesProvider);
    final recipientCount = widget.guests.length;
    final previewGuests = widget.guests.take(5).toList();
    final guestPortalUrl = ref.watch(homeProvider).guestPortalUrl;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text('Message Outstanding Guests',
                      style: UdoDesign.sans(size: 18, weight: FontWeight.w800)),
                ),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ]),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: UdoDesign.rose.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: UdoDesign.rose.withValues(alpha: 0.18)),
                ),
                child: Row(children: [
                  const Icon(Icons.groups_2_outlined, color: _guestAccent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$recipientCount outstanding guest${recipientCount == 1 ? '' : 's'} will receive this message.',
                      style: UdoDesign.sans(
                          size: 13,
                          color: UdoDesign.text,
                          weight: FontWeight.w700),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final channel in _channels.entries)
                  ChoiceChip(
                    selected: _channel == channel.key,
                    label: Text(channel.value),
                    onSelected: (_) => setState(() => _channel = channel.key),
                    selectedColor: _guestAccent,
                    backgroundColor: UdoDesign.card,
                    side: BorderSide(
                        color: _channel == channel.key
                            ? _guestAccent
                            : UdoDesign.stone),
                    labelStyle: UdoDesign.sans(
                        size: 12,
                        weight: FontWeight.w700,
                        color: _channel == channel.key
                            ? Colors.white
                            : UdoDesign.text),
                  ),
              ]),
              if (_channel == 'in_app') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: _guestAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 15, color: _guestAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            guestPortalUrl != null && guestPortalUrl.isNotEmpty
                                ? 'Guests will receive this as a wedding portal message:\n$guestPortalUrl'
                                : "Guests will receive this as a wedding portal message once your portal link is ready.",
                            style: UdoDesign.sans(
                                size: 12,
                                color: _guestAccent,
                                weight: FontWeight.w500),
                          ),
                        ),
                      ]),
                ),
              ],
              const SizedBox(height: 12),
              _CampaignTextField(controller: _subjectCtrl, hint: 'Subject'),
              const SizedBox(height: 10),
              _CampaignTextField(
                  controller: _bodyCtrl,
                  hint: 'Write your message...',
                  maxLines: 5),
              const SizedBox(height: 14),
              Text('Recipients',
                  style: UdoDesign.sans(size: 13, weight: FontWeight.w800)),
              const SizedBox(height: 8),
              for (final guest in previewGuests)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: _guestAccent.withValues(alpha: 0.12),
                      child: Text(_initials(guest),
                          style: UdoDesign.sans(
                              size: 10,
                              weight: FontWeight.w800,
                              color: _guestAccent)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_guestDisplayName(guest),
                          style: UdoDesign.sans(
                              size: 12.5, weight: FontWeight.w700)),
                    ),
                  ]),
                ),
              if (recipientCount > previewGuests.length)
                Text('+${recipientCount - previewGuests.length} more',
                    style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
              if (state.sendError != null) ...[
                const SizedBox(height: 10),
                Text(state.sendError!,
                    style: UdoDesign.sans(size: 12, color: UdoDesign.rose)),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: state.isSending ? null : _send,
                icon: state.isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_outlined, size: 18),
                label: const Text('Send Message'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: _guestAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }
}

class _GuestListTab extends StatelessWidget {
  final GuestsState state;
  final String search, statusFilter;
  final String? infoFilter;
  final ValueChanged<String> onSearchChanged, onFilterChanged;
  final ValueChanged<String?> onInfoFilterChanged;
  final VoidCallback onAddGuest;
  final void Function(Map<String, dynamic>) onGuestTap;

  const _GuestListTab({
    required this.state,
    required this.search,
    required this.statusFilter,
    required this.infoFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onInfoFilterChanged,
    required this.onAddGuest,
    required this.onGuestTap,
  });

  List<Map<String, dynamic>> get _filtered {
    return state.guests.where((g) {
      final name = '${g['first_name']} ${g['last_name']}'.toLowerCase();
      final matchSearch = search.isEmpty || name.contains(search.toLowerCase());
      final status = g['attending_status'] as String? ?? 'pending';
      final matchFilter = statusFilter == 'all' || status == statusFilter;
      final matchInfo =
          infoFilter == null || _guestMatchesInfoFilter(g, infoFilter!);
      return matchSearch && matchFilter && matchInfo;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (state.isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));
    if (state.error != null && state.guests.isEmpty) {
      return _errorBox("Couldn't load your guests.", state.error!);
    }
    final filtered = _filtered;
    final directory = _GuestDirectoryPage(
      guests: state.guests,
      filtered: filtered,
      search: search,
      statusFilter: statusFilter,
      infoFilter: infoFilter,
      onSearchChanged: onSearchChanged,
      onFilterChanged: onFilterChanged,
      onInfoFilterChanged: onInfoFilterChanged,
      onAddGuest: onAddGuest,
      onGuestTap: onGuestTap,
    );
    if (MediaQuery.sizeOf(context).width >= 0) {
      return directory;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search guests...',
              hintStyle: const TextStyle(
                  color: AppTheme.udoTextSecondary, fontSize: 14),
              prefixIcon: const Icon(Icons.search,
                  color: AppTheme.udoTextSecondary, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.udoBorder)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.udoBorder)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final (key, label) in [
                ('all', 'All'),
                ('yes', 'Attending'),
                ('no', 'Declined'),
                ('pending', 'Pending')
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label, style: const TextStyle(fontSize: 13)),
                    selected: statusFilter == key,
                    onSelected: (_) => onFilterChanged(key),
                    selectedColor: AppTheme.udoGreen,
                    labelStyle: TextStyle(
                        color: statusFilter == key
                            ? Colors.white
                            : AppTheme.udoTextPrimary),
                    side: BorderSide(
                        color: statusFilter == key
                            ? AppTheme.udoGreen
                            : AppTheme.udoBorder),
                    checkmarkColor: Colors.white,
                  ),
                ),
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 1,
                  color: AppTheme.udoBorder),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('Missing contact',
                      style: TextStyle(fontSize: 13)),
                  selected: infoFilter == 'missing_contact',
                  onSelected: (selected) =>
                      onInfoFilterChanged(selected ? 'missing_contact' : null),
                  selectedColor: AppTheme.udoCrimson,
                  labelStyle: TextStyle(
                      color: infoFilter == 'missing_contact'
                          ? Colors.white
                          : AppTheme.udoTextPrimary),
                  side: BorderSide(
                      color: infoFilter == 'missing_contact'
                          ? AppTheme.udoCrimson
                          : AppTheme.udoBorder),
                  checkmarkColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        if (infoFilter != null && infoFilter != 'missing_contact')
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: AppTheme.udoCrimson.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Expanded(
                    child: Text(
                        'Filtered: ${_infoFilterLabels[infoFilter] ?? infoFilter}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.udoCrimson,
                            fontWeight: FontWeight.w500))),
                GestureDetector(
                    onTap: () => onInfoFilterChanged(null),
                    child: const Icon(Icons.close,
                        size: 16, color: AppTheme.udoCrimson)),
              ]),
            ),
          ),
        const SizedBox(height: 4),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(
                  child: Text('No guests found.',
                      style: TextStyle(color: AppTheme.udoTextSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _GuestRow(
                      guest: _filtered[i],
                      onTap: () => onGuestTap(_filtered[i])),
                ),
        ),
      ],
    );
  }
}

class _GuestDirectoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> guests;
  final List<Map<String, dynamic>> filtered;
  final String search;
  final String statusFilter;
  final String? infoFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String?> onInfoFilterChanged;
  final VoidCallback onAddGuest;
  final void Function(Map<String, dynamic>) onGuestTap;

  const _GuestDirectoryPage({
    required this.guests,
    required this.filtered,
    required this.search,
    required this.statusFilter,
    required this.infoFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onInfoFilterChanged,
    required this.onAddGuest,
    required this.onGuestTap,
  });

  @override
  Widget build(BuildContext context) {
    final attending =
        guests.where((g) => g['attending_status'] == 'yes').length;
    final pending = guests
        .where((g) =>
            g['attending_status'] == null || g['attending_status'] == 'pending')
        .length;
    final missingContact = guests.where(_guestMissingContact).length;
    final ready = guests
        .where((g) => !_guestMissingContact(g) && !_guestMissingMeal(g))
        .length;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: UdoCard(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search guests...',
                hintStyle: UdoDesign.sans(size: 14, color: UdoDesign.muted),
                prefixIcon:
                    const Icon(Icons.search, color: UdoDesign.muted, size: 20),
                filled: true,
                fillColor: UdoDesign.bg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              _DirectoryMiniStat(
                  label: 'Visible',
                  value: '${filtered.length}',
                  color: _guestAccent),
              _DirectoryMiniStat(
                  label: 'Attending',
                  value: '$attending',
                  color: UdoDesign.sage),
              _DirectoryMiniStat(
                  label: 'Pending', value: '$pending', color: UdoDesign.amber),
              _DirectoryMiniStat(
                  label: 'Ready', value: '$ready', color: UdoDesign.blue),
            ]),
          ]),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 38,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            for (final filter in const [
              ('all', 'All'),
              ('yes', 'Attending'),
              ('no', 'Declined'),
              ('pending', 'Pending')
            ])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter.$2),
                  selected: statusFilter == filter.$1,
                  onSelected: (_) => onFilterChanged(filter.$1),
                  selectedColor: _guestAccent,
                  backgroundColor: UdoDesign.card,
                  side: BorderSide(
                      color: statusFilter == filter.$1
                          ? _guestAccent
                          : UdoDesign.stone),
                  labelStyle: UdoDesign.sans(
                      size: 12,
                      weight: FontWeight.w700,
                      color: statusFilter == filter.$1
                          ? Colors.white
                          : UdoDesign.sub),
                ),
              ),
            ChoiceChip(
              label: Text(
                  'Missing contact ${missingContact > 0 ? missingContact : ''}'
                      .trim()),
              selected: infoFilter == 'missing_contact',
              onSelected: (selected) =>
                  onInfoFilterChanged(selected ? 'missing_contact' : null),
              selectedColor: UdoDesign.rose,
              backgroundColor: UdoDesign.card,
              side: BorderSide(
                  color: infoFilter == 'missing_contact'
                      ? UdoDesign.rose
                      : UdoDesign.stone),
              labelStyle: UdoDesign.sans(
                  size: 12,
                  weight: FontWeight.w700,
                  color: infoFilter == 'missing_contact'
                      ? Colors.white
                      : UdoDesign.sub),
            ),
          ],
        ),
      ),
      if (infoFilter != null && infoFilter != 'missing_contact')
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: UdoCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: UdoDesign.rose.withValues(alpha: 0.08),
            border: BorderSide(color: UdoDesign.rose.withValues(alpha: 0.18)),
            child: Row(children: [
              Expanded(
                  child: Text(
                      'Filtered: ${_infoFilterLabels[infoFilter] ?? infoFilter}',
                      style: UdoDesign.sans(
                          size: 12,
                          weight: FontWeight.w700,
                          color: UdoDesign.rose))),
              GestureDetector(
                  onTap: () => onInfoFilterChanged(null),
                  child:
                      const Icon(Icons.close, size: 16, color: UdoDesign.rose)),
            ]),
          ),
        ),
      Expanded(
        child: filtered.isEmpty
            ? _GuestDirectoryEmpty(onAddGuest: onAddGuest)
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                itemCount: filtered.length,
                itemBuilder: (_, i) => _GuestDirectoryCard(
                  guest: filtered[i],
                  onTap: () => onGuestTap(filtered[i]),
                ),
              ),
      ),
    ]);
  }
}

class _DirectoryMiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _DirectoryMiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: UdoDesign.sans(
                  size: 15, weight: FontWeight.w800, color: color)),
          Text(label, style: UdoDesign.sans(size: 9.5, color: UdoDesign.muted)),
        ]),
      );
}

class _GuestDirectoryCard extends StatelessWidget {
  final Map<String, dynamic> guest;
  final VoidCallback onTap;
  const _GuestDirectoryCard({required this.guest, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = guest['attending_status'] as String?;
    final readinessParts = [
      !_guestMissingContact(guest),
      guest['attending_status'] != null &&
          guest['attending_status'] != 'pending',
      !_guestMissingMeal(guest),
      !_guestMatchesInfoFilter(guest, 'missing_logistics'),
    ];
    final readiness =
        readinessParts.where((done) => done).length / readinessParts.length;
    final name =
        '${guest['first_name'] ?? ''} ${guest['last_name'] ?? ''}'.trim();
    final email = guest['email'] as String?;
    final group = guest['guest_group'] as String?;

    return UdoCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        CircleAvatar(
          radius: 23,
          backgroundColor: _statusColorFor(status).withValues(alpha: 0.12),
          child: Text(_initials(guest),
              style: UdoDesign.sans(
                  size: 12,
                  weight: FontWeight.w800,
                  color: _statusColorFor(status))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(name.isEmpty ? 'Guest' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          UdoDesign.sans(size: 14.5, weight: FontWeight.w800))),
              UdoBadge(
                  label: _statusLabel(status), color: _statusColorFor(status)),
            ]),
            const SizedBox(height: 3),
            Text(
                email?.isNotEmpty == true
                    ? email!
                    : (group?.isNotEmpty == true
                        ? group!
                        : 'No contact on file'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UdoDesign.sans(size: 11.5, color: UdoDesign.muted)),
            const SizedBox(height: 9),
            Row(children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: readiness,
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor: UdoDesign.stone,
                  valueColor: const AlwaysStoppedAnimation(_guestAccent),
                ),
              ),
              const SizedBox(width: 8),
              Text('${(readiness * 100).round()}%',
                  style: UdoDesign.sans(
                      size: 11, weight: FontWeight.w800, color: _guestAccent)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _GuestDirectoryEmpty extends StatelessWidget {
  final VoidCallback onAddGuest;
  const _GuestDirectoryEmpty({required this.onAddGuest});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: UdoCard(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.search_off_outlined,
                  color: UdoDesign.muted, size: 38),
              const SizedBox(height: 12),
              Text('No guests found',
                  style: UdoDesign.sans(size: 16, weight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Adjust the search or add a guest to continue.',
                  textAlign: TextAlign.center,
                  style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted)),
              const SizedBox(height: 14),
              ElevatedButton(
                  onPressed: onAddGuest,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _guestAccent,
                      foregroundColor: Colors.white),
                  child: const Text('Add Guest')),
            ]),
          ),
        ),
      );
}

class _GuestRow extends StatelessWidget {
  final Map<String, dynamic> guest;
  final VoidCallback onTap;
  const _GuestRow({required this.guest, required this.onTap});

  String get _initials {
    final f = (guest['first_name'] as String? ?? '').isNotEmpty
        ? guest['first_name'][0]
        : '';
    final l = (guest['last_name'] as String? ?? '').isNotEmpty
        ? guest['last_name'][0]
        : '';
    return '$f$l'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final status = guest['attending_status'] as String?;
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
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.udoGreen.withValues(alpha: 0.1),
            child: Text(_initials,
                style: const TextStyle(
                    color: AppTheme.udoGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('${guest['first_name'] ?? ''} ${guest['last_name'] ?? ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                if (guest['email'] != null)
                  Text(guest['email'] as String,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.udoTextSecondary)),
              ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: _statusColorFor(status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(_statusLabel(status),
                style: TextStyle(
                    fontSize: 11,
                    color: _statusColorFor(status),
                    fontWeight: FontWeight.w500)),
          ),
        ]),
      ),
    );
  }
}

// ── GUEST DETAIL SHEET ─────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  final Map<String, dynamic> guest;
  const _InfoSection({required this.guest});

  @override
  Widget build(BuildContext context) => Column(children: [
        _InfoRow('First name', guest['first_name'] as String? ?? '—'),
        _InfoRow('Last name', guest['last_name'] as String? ?? '—'),
        _InfoRow('Email', guest['email'] as String? ?? '—'),
        _InfoRow('Phone', guest['phone'] as String? ?? '—'),
        _InfoRow('Group', guest['guest_group'] as String? ?? '—'),
        _InfoRow('VIP', guest['vip_flag'] == true ? 'Yes' : 'No'),
      ]);
}

class _RsvpSection extends StatelessWidget {
  final Map<String, dynamic> guest;
  final VoidCallback onSendReminder;
  const _RsvpSection({required this.guest, required this.onSendReminder});

  @override
  Widget build(BuildContext context) => Column(children: [
        _InfoRow(
            'RSVP status', _statusLabel(guest['attending_status'] as String?)),
        _InfoRow('Plus one', guest['plus_one_count']?.toString() ?? '0'),
        _InfoRow(
            'Invite status', guest['invite_status'] as String? ?? 'Not sent'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onSendReminder,
          icon: const Icon(Icons.notifications_outlined, size: 16),
          label: const Text('Send RSVP reminder'),
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppTheme.udoCrimson),
              foregroundColor: AppTheme.udoCrimson),
        ),
      ]);
}

class _MealsSection extends StatelessWidget {
  final Map<String, dynamic> guest;
  const _MealsSection({required this.guest});

  @override
  Widget build(BuildContext context) => Column(children: [
        _InfoRow('Meal preference',
            guest['meal_preference'] as String? ?? 'Not specified'),
        _InfoRow('Dietary note', guest['dietary_note'] as String? ?? 'None'),
        _InfoRow('Allergies', guest['allergies'] as String? ?? 'None'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.udoCardFill,
              borderRadius: BorderRadius.circular(14)),
          child: const Row(children: [
            Icon(Icons.info_outline,
                size: 16, color: AppTheme.udoTextSecondary),
            SizedBox(width: 8),
            Expanded(
                child: Text(
                    'Meal selection can be enabled via the Guest Portal builder.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.udoTextSecondary,
                        height: 1.5))),
          ]),
        ),
      ]);
}

class _TravelSection extends StatelessWidget {
  final Map<String, dynamic> guest;
  final VoidCallback onGoToLogistics;
  const _TravelSection({required this.guest, required this.onGoToLogistics});

  @override
  Widget build(BuildContext context) => Column(children: [
        _InfoRow(
            'Travel required', guest['travel_required'] == true ? 'Yes' : 'No'),
        _InfoRow(
            'Arrival',
            [guest['arrival_date'], guest['arrival_time']]
                    .where((v) => v != null)
                    .join(' · ')
                    .isEmpty
                ? '—'
                : [guest['arrival_date'], guest['arrival_time']]
                    .where((v) => v != null)
                    .join(' · ')),
        _InfoRow(
            'Departure',
            [guest['departure_date'], guest['departure_time']]
                    .where((v) => v != null)
                    .join(' · ')
                    .isEmpty
                ? '—'
                : [guest['departure_date'], guest['departure_time']]
                    .where((v) => v != null)
                    .join(' · ')),
        _InfoRow('Airport', guest['arrival_airport'] as String? ?? '—'),
        _InfoRow('Hotel assigned',
            guest['hotel_assignment_id'] != null ? 'Yes' : 'Not assigned'),
        _InfoRow('Transport assigned',
            guest['transport_assignment_id'] != null ? 'Yes' : 'Not assigned'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onGoToLogistics,
          icon: const Icon(Icons.flight_outlined, size: 16),
          label: const Text('Manage travel & stay'),
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppTheme.udoGreen),
              foregroundColor: AppTheme.udoGreen),
        ),
      ]);
}

class _AccessSection extends StatelessWidget {
  final Map<String, dynamic> guest;
  final VoidCallback onGenerateToken;
  final bool generating;
  const _AccessSection(
      {required this.guest,
      required this.onGenerateToken,
      required this.generating});

  @override
  Widget build(BuildContext context) {
    final token =
        (guest['token'] as Map<String, dynamic>?)?['token'] as String?;
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.udoCardFill,
            borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Guest portal access',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          _InfoRow('Token', token ?? 'Not generated'),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: generating ? null : onGenerateToken,
            icon: generating
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.vpn_key_outlined, size: 16),
            label:
                Text(token != null ? 'Regenerate access' : 'Generate access'),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                side: const BorderSide(color: AppTheme.udoGreen),
                foregroundColor: AppTheme.udoGreen),
          ),
        ]),
      ),
    ]);
  }
}

class _NotesSection extends StatelessWidget {
  final Map<String, dynamic> guest;
  const _NotesSection({required this.guest});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Notes',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.udoCardFill,
              borderRadius: BorderRadius.circular(14)),
          child: Text(
            (guest['notes'] as String?)?.isNotEmpty == true
                ? guest['notes'] as String
                : 'No notes yet. Tap Edit to add.',
            style: const TextStyle(
                fontSize: 13, color: AppTheme.udoTextPrimary, height: 1.5),
          ),
        ),
      ]);
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 130,
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

// ── GUEST PROFILE (full page) ──────────────────────────────────────────────────

class GuestProfileScreen extends ConsumerWidget {
  final int guestId;
  const GuestProfileScreen({super.key, required this.guestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guests = ref.watch(guestsProvider).guests;
    Map<String, dynamic>? guest;
    for (final g in guests) {
      if (g['id'] == guestId) {
        guest = g;
        break;
      }
    }

    if (guest == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Guest Profile')),
        body: const Center(
            child: Text('Guest not found.',
                style: TextStyle(color: AppTheme.udoTextSecondary))),
      );
    }

    return _GuestProfileBody(guest: guest);
  }
}

class _GuestProfileBody extends ConsumerStatefulWidget {
  final Map<String, dynamic> guest;
  const _GuestProfileBody({required this.guest});

  @override
  ConsumerState<_GuestProfileBody> createState() => _GuestProfileBodyState();
}

class _GuestProfileBodyState extends ConsumerState<_GuestProfileBody> {
  bool _loadingActivity = true;
  List<Map<String, dynamic>> _activity = [];
  List<Map<String, dynamic>> _communications = [];
  bool _togglingVip = false;
  bool _generatingToken = false;

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final res = await ref
              .read(apiClientProvider)
              .get('/guests/${widget.guest['id']}/activity')
          as Map<String, dynamic>;
      final data = Map<String, dynamic>.from(res['data'] as Map);
      setState(() {
        _activity = (data['activity'] as List? ?? [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _communications = (data['communications'] as List? ?? [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _loadingActivity = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingActivity = false);
    }
  }

  Future<void> _toggleVip() async {
    setState(() => _togglingVip = true);
    await ref.read(guestsProvider.notifier).updateGuest(
        widget.guest['id'] as int,
        {'vip_flag': !(widget.guest['vip_flag'] == true)});
    if (mounted) setState(() => _togglingVip = false);
  }

  Future<void> _generateToken() async {
    setState(() => _generatingToken = true);
    await ref
        .read(guestsProvider.notifier)
        .generateToken(widget.guest['id'] as int);
    if (mounted) setState(() => _generatingToken = false);
  }

  void _launch(String uri) =>
      launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final guest = ref.watch(guestsProvider).guests.firstWhere(
        (g) => g['id'] == widget.guest['id'],
        orElse: () => widget.guest);
    final name =
        '${guest['first_name'] ?? ''} ${guest['last_name'] ?? ''}'.trim();
    final phone = guest['phone'] as String?;
    final email = guest['email'] as String?;
    final isVip = guest['vip_flag'] == true;

    return Scaffold(
      backgroundColor: AppTheme.udoBackground,
      appBar: AppBar(
        title: const Text('Guest Profile'),
        actions: [
          TextButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24))),
              builder: (_) => _EditGuestModal(guest: guest, onSaved: (_) {}),
            ),
            child: const Text('Edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.udoGreen.withValues(alpha: 0.1),
              child: Text(
                '${(guest['first_name'] as String? ?? '').isNotEmpty ? (guest['first_name'] as String)[0] : ''}${(guest['last_name'] as String? ?? '').isNotEmpty ? (guest['last_name'] as String)[0] : ''}'
                    .toUpperCase(),
                style: const TextStyle(
                    color: AppTheme.udoGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(name.isEmpty ? 'Guest' : name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                        color: _statusColorFor(
                                guest['attending_status'] as String?)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                        _statusLabel(guest['attending_status'] as String?),
                        style: TextStyle(
                            fontSize: 12,
                            color: _statusColorFor(
                                guest['attending_status'] as String?),
                            fontWeight: FontWeight.w600)),
                  ),
                ])),
            IconButton(
              onPressed: _togglingVip ? null : _toggleVip,
              icon: Icon(isVip ? Icons.star : Icons.star_border,
                  color: isVip ? Colors.amber : AppTheme.udoTextSecondary),
              tooltip: isVip ? 'Remove VIP' : 'Mark as VIP',
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: _ContactButton(
                    icon: Icons.call_outlined,
                    label: 'Call',
                    enabled: phone != null && phone.isNotEmpty,
                    onTap: () => _launch('tel:$phone'))),
            const SizedBox(width: 8),
            Expanded(
                child: _ContactButton(
                    icon: Icons.sms_outlined,
                    label: 'SMS',
                    enabled: phone != null && phone.isNotEmpty,
                    onTap: () => _launch('sms:$phone'))),
            const SizedBox(width: 8),
            Expanded(
                child: _ContactButton(
                    icon: Icons.chat_outlined,
                    label: 'WhatsApp',
                    enabled: phone != null && phone.isNotEmpty,
                    onTap: () => _launch(
                        'https://wa.me/${phone?.replaceAll(RegExp(r'[^0-9+]'), '')}'))),
            const SizedBox(width: 8),
            Expanded(
                child: _ContactButton(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    enabled: email != null && email.isNotEmpty,
                    onTap: () => _launch('mailto:$email'))),
          ]),
          const SizedBox(height: 20),
          _Card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Guest details',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                _InfoSection(guest: guest),
                const Divider(height: 24),
                _RsvpSection(
                    guest: guest,
                    onSendReminder: () => ref
                        .read(guestsProvider.notifier)
                        .sendInvite(guest['id'] as int)),
                const Divider(height: 24),
                _MealsSection(guest: guest),
                const Divider(height: 24),
                _TravelSection(
                    guest: guest,
                    onGoToLogistics: () =>
                        context.push('/guests?tab=Logistics')),
                const Divider(height: 24),
                _AccessSection(
                    guest: guest,
                    onGenerateToken: _generateToken,
                    generating: _generatingToken),
                const Divider(height: 24),
                _NotesSection(guest: guest),
              ])),
          const SizedBox(height: 12),
          _Card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Activity timeline',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                if (_loadingActivity)
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(
                              color: AppTheme.udoGreen)))
                else if (_activity.isEmpty)
                  const Text('No activity recorded yet.',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.udoTextSecondary))
                else
                  ..._activity.map((event) => _ActivityRow(event: event)),
              ])),
          const SizedBox(height: 12),
          _Card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Communication history',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                if (_loadingActivity)
                  const SizedBox.shrink()
                else if (_communications.isEmpty)
                  const Text('No messages sent to this guest yet.',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.udoTextSecondary))
                else
                  for (final comm in _communications)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(comm['subject'] as String? ?? 'Message',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                              Text(
                                  '${comm['channel'] ?? ''} · ${comm['sent_at'] ?? ''}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.udoTextSecondary)),
                            ])),
                        Text((comm['status'] ?? '').toString(),
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.udoGreen,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
              ])),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  const _ContactButton(
      {required this.icon,
      required this.label,
      required this.enabled,
      required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : AppTheme.udoCardFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.udoBorder),
          ),
          child: Column(children: [
            Icon(icon,
                size: 18,
                color: enabled ? AppTheme.udoGreen : AppTheme.udoTextSecondary),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: enabled
                        ? AppTheme.udoTextPrimary
                        : AppTheme.udoTextSecondary)),
          ]),
        ),
      );
}

// ── EDIT GUEST MODAL ───────────────────────────────────────────────────────────

class _EditGuestModal extends ConsumerStatefulWidget {
  final Map<String, dynamic> guest;
  final void Function(Map<String, dynamic>) onSaved;
  const _EditGuestModal({required this.guest, required this.onSaved});

  @override
  ConsumerState<_EditGuestModal> createState() => _EditGuestModalState();
}

class _EditGuestModalState extends ConsumerState<_EditGuestModal> {
  late final TextEditingController _firstName,
      _lastName,
      _email,
      _phone,
      _notes;
  late String _status;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final g = widget.guest;
    _firstName = TextEditingController(text: g['first_name'] as String? ?? '');
    _lastName = TextEditingController(text: g['last_name'] as String? ?? '');
    _email = TextEditingController(text: g['email'] as String? ?? '');
    _phone = TextEditingController(text: g['phone'] as String? ?? '');
    _notes = TextEditingController(text: g['notes'] as String? ?? '');
    _status = g['attending_status'] as String? ?? 'pending';
  }

  Future<void> _submit() async {
    if (_firstName.text.trim().isEmpty) {
      setState(() => _error = 'First name is required.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await ref
        .read(guestsProvider.notifier)
        .updateGuest(widget.guest['id'] as int, {
      'first_name': _firstName.text.trim(),
      'last_name': _lastName.text.trim().isEmpty ? null : _lastName.text.trim(),
      'email': _email.text.trim().isEmpty ? null : _email.text.trim(),
      'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      'attending_status': _status,
      'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    }).timeout(const Duration(seconds: 35), onTimeout: () => false);
    if (!mounted) return;
    if (ok) {
      final updated = ref.read(guestsProvider).guests.firstWhere(
          (g) => g['id'] == widget.guest['id'],
          orElse: () => widget.guest);
      widget.onSaved(updated);
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Guest saved.')));
    } else {
      final message = ref.read(guestsProvider).error ??
          "Couldn't save this guest. Check your connection and try again.";
      setState(() {
        _loading = false;
        _error = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: FractionallySizedBox(
            heightFactor: 0.86,
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 112),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Expanded(
                          child: Text('Edit guest',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600))),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          padding: EdgeInsets.zero),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child:
                              _FieldWrap('First name', controller: _firstName)),
                      const SizedBox(width: 12),
                      Expanded(
                          child:
                              _FieldWrap('Last name', controller: _lastName)),
                    ]),
                    const SizedBox(height: 12),
                    _FieldWrap('Email',
                        controller: _email, type: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    _FieldWrap('Phone',
                        controller: _phone, type: TextInputType.phone),
                    const SizedBox(height: 12),
                    const Text('RSVP status',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: _dropDeco(),
                      items: const [
                        DropdownMenuItem(
                            value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(
                            value: 'yes', child: Text('Attending')),
                        DropdownMenuItem(
                            value: 'no', child: Text('Not attending')),
                      ],
                      onChanged: (v) =>
                          setState(() => _status = v ?? 'pending'),
                    ),
                    const SizedBox(height: 12),
                    _FieldWrap('Notes', controller: _notes),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.udoCrimson)),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          backgroundColor: AppTheme.udoGreen,
                          foregroundColor: Colors.white),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Save changes'),
                    ),
                  ]),
            ),
          ),
        ),
      );

  InputDecoration _dropDeco() => InputDecoration(
        filled: true,
        fillColor: AppTheme.udoCardFill,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }
}

// ── ADD GUEST MODAL ────────────────────────────────────────────────────────────

class _AddGuestModal extends StatefulWidget {
  final GuestsNotifier notifier;
  final bool quickMode;
  final ValueChanged<bool> onToggleMode;
  const _AddGuestModal(
      {required this.notifier,
      required this.quickMode,
      required this.onToggleMode});

  @override
  State<_AddGuestModal> createState() => _AddGuestModalState();
}

const _kMealPreferenceOptions = {
  '': 'No preference',
  'standard': 'Standard',
  'vegetarian': 'Vegetarian',
  'vegan': 'Vegan',
  'halal': 'Halal',
  'kosher': 'Kosher',
  'gluten-free': 'Gluten-Free',
};

class _AddGuestModalState extends State<_AddGuestModal> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _dietaryNote = TextEditingController();
  String _rsvpStatus = 'pending';
  bool _plusOneAllowed = false;
  int _plusOneCount = 0;
  String _mealPreference = '';
  // Local, not widget.quickMode directly — an already-open showModalBottomSheet
  // doesn't rebuild when the parent screen's state changes, so the mode
  // toggle must be driven from this widget's own state to actually work.
  late bool _quickMode = widget.quickMode;
  bool _loading = false;
  String? _error;

  void _setMode(bool quick) {
    setState(() => _quickMode = quick);
    widget.onToggleMode(quick);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: FractionallySizedBox(
          heightFactor: 0.92,
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 112),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Expanded(
                        child: Text('Add guest',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600))),
                    Container(
                      decoration: BoxDecoration(
                          color: AppTheme.udoCardFill,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        _ModeBtn('Quick', _quickMode, () => _setMode(true)),
                        _ModeBtn('Manual', !_quickMode, () => _setMode(false)),
                      ]),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                        child:
                            _FieldWrap('First name', controller: _firstName)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _FieldWrap('Last name', controller: _lastName)),
                  ]),
                  const SizedBox(height: 12),
                  _FieldWrap('Email',
                      controller: _email, type: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _FieldWrap('Phone (optional)',
                      controller: _phone, type: TextInputType.phone),
                  if (!_quickMode) ...[
                    const SizedBox(height: 12),
                    const Text('RSVP status',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _rsvpStatus,
                      decoration: _dropDeco(),
                      items: const [
                        DropdownMenuItem(
                            value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(
                            value: 'yes', child: Text('Attending')),
                        DropdownMenuItem(
                            value: 'no', child: Text('Not attending')),
                      ],
                      onChanged: (v) =>
                          setState(() => _rsvpStatus = v ?? 'pending'),
                    ),
                    const SizedBox(height: 12),
                    const Text('Meal preference',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _mealPreference,
                      decoration: _dropDeco(),
                      items: [
                        for (final entry in _kMealPreferenceOptions.entries)
                          DropdownMenuItem(
                              value: entry.key, child: Text(entry.value)),
                      ],
                      onChanged: (v) =>
                          setState(() => _mealPreference = v ?? ''),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      const Expanded(
                          child: Text('Plus-one allowed',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500))),
                      Switch(
                          value: _plusOneAllowed,
                          onChanged: (v) => setState(() {
                                _plusOneAllowed = v;
                                if (!v) _plusOneCount = 0;
                              }),
                          activeThumbColor: AppTheme.udoGreen),
                    ]),
                    if (_plusOneAllowed) ...[
                      const SizedBox(height: 6),
                      const Text('Plus-one count',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        initialValue: _plusOneCount,
                        decoration: _dropDeco(),
                        items: [
                          for (var i = 0; i <= 5; i++)
                            DropdownMenuItem(value: i, child: Text('$i')),
                        ],
                        onChanged: (v) =>
                            setState(() => _plusOneCount = v ?? 0),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _FieldWrap('Dietary note (optional)',
                        controller: _dietaryNote),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.udoCrimson)),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: AppTheme.udoGreen,
                        foregroundColor: Colors.white),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(_quickMode ? 'Add & send invite' : 'Add guest'),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_firstName.text.trim().isEmpty) {
      setState(() => _error = 'Add at least a first name.');
      return;
    }
    if (_quickMode && _email.text.trim().isEmpty) {
      setState(() => _error =
          'Add an email address to send an invite, or switch to Manual to add without inviting.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await widget.notifier.addGuest(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim().isNotEmpty ? _email.text.trim() : null,
      phone: _phone.text.trim().isNotEmpty ? _phone.text.trim() : null,
      attendingStatus: _quickMode ? null : _rsvpStatus,
      sendInviteAfter: _quickMode,
      plusOneAllowed: _quickMode ? null : _plusOneAllowed,
      plusOneCount: _quickMode ? null : _plusOneCount,
      mealPreference: _quickMode ? null : _mealPreference,
      dietaryNote: _quickMode ? null : _dietaryNote.text.trim(),
    );
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _loading = false;
        _error = "Couldn't add this guest. Try again.";
      });
      return;
    }
    if (mounted) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(
          content: Text(
              _quickMode ? 'Guest added and invite queued.' : 'Guest added.')));
    }
  }

  InputDecoration _dropDeco() => InputDecoration(
        filled: true,
        fillColor: AppTheme.udoCardFill,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _dietaryNote.dispose();
    super.dispose();
  }
}

class _ModeBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeBtn(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
              color: selected ? AppTheme.udoGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(20)),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white : AppTheme.udoTextPrimary,
                  fontWeight: FontWeight.w500)),
        ),
      );
}

class _FieldWrap extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? type;
  const _FieldWrap(this.label, {required this.controller, this.type});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
            controller: controller,
            keyboardType: type,
            decoration: InputDecoration(
              hintText: label,
              hintStyle: const TextStyle(
                  color: AppTheme.udoTextSecondary, fontSize: 14),
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
            )),
      ]);
}

// ── INVITATIONS TAB (Invitation Studio) ───────────────────────────────────────

class _CheckInTab extends ConsumerStatefulWidget {
  const _CheckInTab();

  @override
  ConsumerState<_CheckInTab> createState() => _CheckInTabState();
}

class _CheckInTabState extends ConsumerState<_CheckInTab> {
  String _search = '';
  final Set<int> _saving = {};
  final _scrollController = ScrollController();
  final _searchFocusNode = FocusNode();

  Future<void> _setCheckedIn(Map<String, dynamic> guest, bool checked) async {
    final id = _guestId(guest);
    if (id == null || _saving.contains(id)) return;
    setState(() => _saving.add(id));
    final ok = checked
        ? await ref.read(liveProvider.notifier).checkInGuest(id)
        : await ref
            .read(guestsProvider.notifier)
            .updateGuest(id, {'checked_in_at': null});
    if (ok) {
      await ref.read(guestsProvider.notifier).refresh();
      await ref.read(liveProvider.notifier).refresh();
    }
    if (!mounted) return;
    setState(() => _saving.remove(id));
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't update check-in.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guestsProvider);
    final attending = state.guests
        .where((guest) => guest['attending_status'] == 'yes')
        .where((guest) {
      if (_search.trim().isEmpty) return true;
      return _guestDisplayName(guest)
          .toLowerCase()
          .contains(_search.trim().toLowerCase());
    }).toList()
      ..sort((a, b) {
        final aChecked = a['checked_in_at'] != null;
        final bChecked = b['checked_in_at'] != null;
        if (aChecked != bChecked) return aChecked ? 1 : -1;
        return _guestDisplayName(a).compareTo(_guestDisplayName(b));
      });
    final arrived =
        state.guests.where((guest) => guest['checked_in_at'] != null).length;
    final confirmed = state.guests
        .where((guest) => guest['attending_status'] == 'yes')
        .length;
    final percent = confirmed == 0 ? 0.0 : arrived / confirmed;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(guestsProvider.notifier).refresh();
        await ref.read(liveProvider.notifier).refresh();
      },
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          UdoCard(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: UdoDesign.gold.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.how_to_reg_outlined,
                      color: _guestAccent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Live attendance',
                            style: UdoDesign.serif(
                                size: 22, color: UdoDesign.text)),
                        const SizedBox(height: 2),
                        Text('$arrived of $confirmed arrived',
                            style: const TextStyle(
                                fontSize: 12,
                                color: UdoDesign.muted,
                                fontWeight: FontWeight.w600)),
                      ]),
                ),
                Text('${(percent * 100).round()}%',
                    style: const TextStyle(
                        fontSize: 18,
                        color: _guestAccent,
                        fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: percent.clamp(0, 1),
                  backgroundColor: UdoDesign.border,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(UdoDesign.gold),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/guests/check-in/qr'),
                    icon: const Icon(Icons.qr_code_scanner_outlined, size: 18),
                    label: const Text('QR scanner'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: _guestAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _scrollController.animateTo(
                        250,
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                      );
                      _searchFocusNode.requestFocus();
                    },
                    icon: const Icon(Icons.checklist_outlined, size: 18),
                    label: const Text('Manual list'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      foregroundColor: _guestAccent,
                      side: const BorderSide(color: UdoDesign.border),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          TextField(
            focusNode: _searchFocusNode,
            onChanged: (value) => setState(() => _search = value),
            decoration: InputDecoration(
              hintText: 'Search arriving guests',
              prefixIcon:
                  const Icon(Icons.search_outlined, color: UdoDesign.muted),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: UdoDesign.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: UdoDesign.border)),
            ),
          ),
          const SizedBox(height: 12),
          if (attending.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text('No attending guests found.',
                    style: TextStyle(fontSize: 13, color: UdoDesign.muted)),
              ),
            )
          else
            for (final guest in attending)
              _CheckInGuestRow(
                guest: guest,
                saving: _saving.contains(_guestId(guest)),
                onChanged: (checked) => _setCheckedIn(guest, checked),
              ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}

class _CheckInGuestRow extends StatelessWidget {
  final Map<String, dynamic> guest;
  final bool saving;
  final ValueChanged<bool> onChanged;

  const _CheckInGuestRow({
    required this.guest,
    required this.saving,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final checked = guest['checked_in_at'] != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: checked ? UdoDesign.gold : UdoDesign.border, width: 1),
      ),
      child: Row(children: [
        saving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: _guestAccent),
              )
            : Checkbox(
                value: checked,
                onChanged: (value) => onChanged(value ?? false),
                activeColor: _guestAccent,
              ),
        const SizedBox(width: 8),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              _guestDisplayName(guest),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                decoration: checked ? TextDecoration.lineThrough : null,
                color: checked ? UdoDesign.muted : UdoDesign.text,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              checked ? 'Arrived' : 'Not arrived yet',
              style: TextStyle(
                fontSize: 11,
                color: checked ? _guestAccent : UdoDesign.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
        ),
        if (guest['vip_flag'] == true)
          const Icon(Icons.star_rounded, color: UdoDesign.gold, size: 18),
      ]),
    );
  }
}

class GuestQrScannerScreen extends StatefulWidget {
  const GuestQrScannerScreen({super.key});

  @override
  State<GuestQrScannerScreen> createState() => _GuestQrScannerScreenState();
}

class _GuestQrScannerScreenState extends State<GuestQrScannerScreen> {
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_openCamera);
  }

  Future<void> _openCamera() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await ImagePicker().pickImage(source: ImageSource.camera);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Camera opened. Use manual list to finish check-in.')));
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('QR Scanner'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Icon(Icons.qr_code_scanner_outlined,
                          color: Colors.white.withValues(alpha: 0.86),
                          size: 96),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text('Point the camera at a guest QR code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Manual checklist remains available for walk-ins.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.68),
                          fontSize: 13)),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _opening ? null : _openCamera,
                    icon: _opening
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.camera_alt_outlined),
                    label: Text(_opening ? 'Opening camera...' : 'Open camera'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: UdoDesign.gold,
                      foregroundColor: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      foregroundColor: Colors.white,
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: const Text('Back to checklist'),
                  ),
                ]),
          ),
        ),
      );
}

class _InvitationsTab extends ConsumerStatefulWidget {
  const _InvitationsTab();
  @override
  ConsumerState<_InvitationsTab> createState() => _InvitationsTabState();
}

class _InvitationsTabState extends ConsumerState<_InvitationsTab> {
  String _formatDate(dynamic iso) {
    if (iso == null) return 'Date to be confirmed';
    final d = DateTime.tryParse(iso.toString());
    if (d == null) return iso.toString();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _selectTemplate(
      InvitationNotifier notifier, InvitationTemplate template) async {
    final ok = await notifier.save(templateId: template.id);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Couldn't save the ${template.name} template. Check your connection and try again."),
        backgroundColor: UdoDesign.rose,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final invState = ref.watch(invitationProvider);
    final invNotifier = ref.read(invitationProvider.notifier);
    final guests = ref.watch(guestsProvider).guests;

    if (invState.isLoading)
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));
    if (invState.error != null && invState.wedding == null) {
      return _errorBox("Couldn't load your invitation.", invState.error!);
    }

    final invitation = invState.invitation;
    final wedding = invState.wedding ?? {};
    final selectedId = invitation?['template_id'] as String?;
    final selectedTemplate = templateById(selectedId);

    final sent = guests.where((g) => g['invite_status'] == 'sent').length;
    final rsvpd = guests
        .where((g) =>
            g['attending_status'] == 'yes' || g['attending_status'] == 'no')
        .length;
    final pending = guests.length - sent;
    final delivered = sent;
    final opened = guests.where((g) => g['invite_opened_at'] != null).length;
    final declined = guests.where((g) => g['attending_status'] == 'no').length;
    final missingMeal = guests.where(_guestMissingMeal).length;
    final missingTravel = guests
        .where((g) => _guestMatchesInfoFilter(g, 'missing_logistics'))
        .length;

    final coupleNames = (invitation?['title_line'] as String?)?.isNotEmpty ==
            true
        ? invitation!['title_line'] as String
        : ([wedding['couple_name_primary'], wedding['couple_name_secondary']]
            .where((v) => v != null && (v as String).isNotEmpty)
            .join(' & '));
    final dateText = (invitation?['date_text'] as String?)?.isNotEmpty == true
        ? invitation!['date_text'] as String
        : _formatDate(wedding['event_date']);
    final venueText = (invitation?['venue_text'] as String?)?.isNotEmpty == true
        ? invitation!['venue_text'] as String
        : ([wedding['primary_venue_name'], wedding['city']]
            .where((v) => v != null && (v as String).isNotEmpty)
            .join(' · '));
    final introText = invitation?['optional_quote'] as String? ?? '';
    final mainWording = invitation?['invitation_text'] as String? ?? '';
    final rsvpDeadlineText = invitation?['rsvp_deadline_text'] as String?;
    final commandCentre = _InvitationCommandCentrePage(
      guests: guests,
      sent: sent,
      delivered: delivered,
      opened: opened,
      rsvpd: rsvpd,
      pending: pending,
      declined: declined,
      missingMeal: missingMeal,
      missingTravel: missingTravel,
      selectedTemplate: selectedTemplate,
      invitationTemplates: invitationTemplates,
      onTemplateTap: (template) => _selectTemplate(invNotifier, template),
      onSendReminder: () => _openWizard(context, initialStep: 0),
      onPreview: () => _showInvitationPreviewSheet(
        context,
        selectedTemplate,
        coupleNames,
        introText,
        mainWording,
        dateText,
        venueText,
        rsvpDeadlineText,
      ),
      onSettings: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const InvitationEditorScreen())),
      onSendInvitations: () => _openWizard(context, initialStep: 0),
      onDeliveryHistory: () => _showBreakdownSheet(context, 'Invite status', {
        'Sent': sent,
        'Not sent yet': guests.length - sent,
        'RSVP\'d': rsvpd,
      }),
    );
    if (MediaQuery.sizeOf(context).width >= 0) {
      return commandCentre;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            _InvStat('$sent', 'Sent'),
            _InvStat('$rsvpd', 'RSVP\'d'),
            _InvStat('$pending', 'Pending'),
          ]),
        ),
        const SizedBox(height: 16),
        const Text('Choose a template',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: invitationTemplates.length,
            itemBuilder: (_, i) {
              final t = invitationTemplates[i];
              final selected = t.id == selectedTemplate.id;
              return GestureDetector(
                onTap: () => invNotifier.save(templateId: t.id),
                child: Container(
                  width: 110,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? t.accent.withValues(alpha: 0.08)
                        : AppTheme.udoCardFill,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: selected ? t.accent : AppTheme.udoBorder,
                        width: selected ? 2 : 1),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 56,
                            height: 72,
                            decoration: BoxDecoration(
                                color: t.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.udoBorder)),
                            child: Center(
                                child: Icon(Icons.mail_outline,
                                    color: t.accent, size: 28))),
                        const SizedBox(height: 6),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(t.name,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: selected
                                        ? t.accent
                                        : AppTheme.udoTextPrimary),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis)),
                      ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(selectedTemplate.description,
            style: const TextStyle(
                fontSize: 12,
                color: AppTheme.udoTextSecondary,
                fontStyle: FontStyle.italic)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.udoBorder)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const Text('Preview',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            const SizedBox(height: 12),
            InvitationPreviewCard(
              template: selectedTemplate,
              coupleNames: coupleNames,
              introText: introText,
              mainWording: mainWording,
              dateText: dateText,
              venueText: venueText,
              rsvpDeadlineText: rsvpDeadlineText,
            ),
          ]),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _openWizard(context, initialStep: 2),
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Edit wording'),
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: const BorderSide(color: AppTheme.udoGreen),
              foregroundColor: AppTheme.udoGreen),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _openWizard(context, initialStep: 0),
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: AppTheme.udoGreen,
              foregroundColor: Colors.white),
          child: const Text('Send invitations'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _showBreakdownSheet(context, 'Invite status', {
            'Sent': sent,
            'Not sent yet': guests.length - sent,
            'RSVP\'d': rsvpd,
          }),
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppTheme.udoBorder),
              foregroundColor: AppTheme.udoTextSecondary),
          child: const Text('View delivery history'),
        ),
      ],
    );
  }

  void _openWizard(BuildContext context, {required int initialStep}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => InvitationWizardScreen(initialStep: initialStep),
    ));
  }

  void _showInvitationPreviewSheet(
    BuildContext context,
    InvitationTemplate template,
    String coupleNames,
    String introText,
    String mainWording,
    String dateText,
    String venueText,
    String? rsvpDeadlineText,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(
                  child: Text('Invitation Preview',
                      style:
                          UdoDesign.sans(size: 18, weight: FontWeight.w800))),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 12),
            InvitationPreviewCard(
              template: template,
              coupleNames: coupleNames,
              introText: introText,
              mainWording: mainWording,
              dateText: dateText,
              venueText: venueText,
              rsvpDeadlineText: rsvpDeadlineText,
            ),
          ]),
        ),
      ),
    );
  }
}

class _InvitationCommandCentrePage extends StatefulWidget {
  final List<Map<String, dynamic>> guests;
  final int sent;
  final int delivered;
  final int opened;
  final int rsvpd;
  final int pending;
  final int declined;
  final int missingMeal;
  final int missingTravel;
  final InvitationTemplate selectedTemplate;
  final List<InvitationTemplate> invitationTemplates;
  final ValueChanged<InvitationTemplate> onTemplateTap;
  final VoidCallback onSendReminder;
  final VoidCallback onPreview;
  final VoidCallback onSettings;
  final VoidCallback onSendInvitations;
  final VoidCallback onDeliveryHistory;

  const _InvitationCommandCentrePage({
    required this.guests,
    required this.sent,
    required this.delivered,
    required this.opened,
    required this.rsvpd,
    required this.pending,
    required this.declined,
    required this.missingMeal,
    required this.missingTravel,
    required this.selectedTemplate,
    required this.invitationTemplates,
    required this.onTemplateTap,
    required this.onSendReminder,
    required this.onPreview,
    required this.onSettings,
    required this.onSendInvitations,
    required this.onDeliveryHistory,
  });

  @override
  State<_InvitationCommandCentrePage> createState() =>
      _InvitationCommandCentrePageState();
}

class _InvitationCommandCentrePageState
    extends State<_InvitationCommandCentrePage> {
  String _filter = 'all';

  List<Map<String, dynamic>> get _filteredGuests {
    return widget.guests.where((guest) {
      final status = guest['attending_status'] as String? ?? 'pending';
      return switch (_filter) {
        'pending' => status == 'pending' || guest['attending_status'] == null,
        'confirmed' => status == 'yes',
        'declined' => status == 'no',
        'sent' => guest['invite_status'] == 'sent',
        'not_sent' => guest['invite_status'] != 'sent',
        'meal_missing' => _guestMissingMeal(guest),
        'travel_missing' => _guestMatchesInfoFilter(guest, 'missing_logistics'),
        _ => true,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.guests.length;
    final completion = total == 0 ? 0.0 : widget.rsvpd / total;
    final sentPct = total == 0 ? 0.0 : widget.sent / total;
    final deliveredPct = total == 0 ? 0.0 : widget.delivered / total;
    final openedPct = total == 0 ? 0.0 : widget.opened / total;
    final filteredGuests = _filteredGuests;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        _InvitationHeroCard(
          completion: completion,
          rsvpd: widget.rsvpd,
          pending: widget.pending,
          onSendReminder: widget.onSendReminder,
          onPreview: widget.onPreview,
          onSettings: widget.onSettings,
        ),
        const SizedBox(height: 16),
        _InvitationKpiGrid(
          sent: widget.sent,
          delivered: widget.delivered,
          opened: widget.opened,
          responded: widget.rsvpd,
          pending: widget.pending,
          sentPct: sentPct,
          deliveredPct: deliveredPct,
          openedPct: openedPct,
          respondedPct: completion,
          onTapSent: () => setState(() => _filter = 'sent'),
          onTapPending: () => setState(() => _filter = 'pending'),
        ),
        const SizedBox(height: 18),
        _InvitationInsights(
          pending: widget.pending,
          missingMeal: widget.missingMeal,
          missingTravel: widget.missingTravel,
          onResolve: widget.onSendReminder,
        ),
        const SizedBox(height: 18),
        _InvitationFilterChips(
          active: _filter,
          onChanged: (value) => setState(() => _filter = value),
        ),
        const SizedBox(height: 18),
        UdoSectionHeader(
          title: 'Template Studio',
          action: 'Settings',
          onAction: widget.onSettings,
        ),
        InvitationTemplateStrip(
          templates: widget.invitationTemplates,
          selected: widget.selectedTemplate,
          onTap: widget.onTemplateTap,
        ),
        const SizedBox(height: 18),
        UdoSectionHeader(
          title: 'Guest Sections',
          action: 'History',
          onAction: widget.onDeliveryHistory,
        ),
        if (filteredGuests.isEmpty)
          UdoCard(
            padding: const EdgeInsets.all(18),
            child: Text('No guests match this invitation filter.',
                style: UdoDesign.sans(size: 13, color: UdoDesign.muted)),
          )
        else
          for (final guest in filteredGuests.take(8))
            _InvitationGuestCard(guest: guest),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: widget.onSendInvitations,
          icon: const Icon(Icons.send_outlined, size: 18),
          label: const Text('Send Invitations'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: _guestAccent,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _InvitationHeroCard extends StatelessWidget {
  final double completion;
  final int rsvpd;
  final int pending;
  final VoidCallback onSendReminder;
  final VoidCallback onPreview;
  final VoidCallback onSettings;

  const _InvitationHeroCard({
    required this.completion,
    required this.rsvpd,
    required this.pending,
    required this.onSendReminder,
    required this.onPreview,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      color: _guestAccent,
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const UdoBadge(
                  label: 'Invitation health',
                  color: UdoDesign.gold,
                  background: Color(0x22FFFFFF)),
              const SizedBox(height: 12),
              Text('Everything is progressing beautifully.',
                  style: UdoDesign.serif(size: 30, color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                '$rsvpd guests have responded. $pending still require follow-up.',
                style: UdoDesign.sans(
                    size: 13.5, color: Colors.white70, height: 1.45),
              ),
            ]),
          ),
          UdoRingProgress(
            value: completion,
            color: Colors.white,
            size: 76,
            center: Text('${(completion * 100).round()}%',
                style: UdoDesign.sans(
                    size: 14, weight: FontWeight.w800, color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
              child: _InvitationHeroButton(
                  label: 'Reminder', onTap: onSendReminder)),
          const SizedBox(width: 8),
          Expanded(
              child: _InvitationHeroButton(label: 'Preview', onTap: onPreview)),
          const SizedBox(width: 8),
          Expanded(
              child:
                  _InvitationHeroButton(label: 'Settings', onTap: onSettings)),
        ]),
      ]),
    );
  }
}

class _InvitationHeroButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _InvitationHeroButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white54),
          minimumSize: const Size(0, 42),
          padding: const EdgeInsets.symmetric(horizontal: 6),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, maxLines: 1),
        ),
      );
}

class _InvitationKpiGrid extends StatelessWidget {
  final int sent, delivered, opened, responded, pending;
  final double sentPct, deliveredPct, openedPct, respondedPct;
  final VoidCallback onTapSent, onTapPending;

  const _InvitationKpiGrid({
    required this.sent,
    required this.delivered,
    required this.opened,
    required this.responded,
    required this.pending,
    required this.sentPct,
    required this.deliveredPct,
    required this.openedPct,
    required this.respondedPct,
    required this.onTapSent,
    required this.onTapPending,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      ('Sent', '$sent', sentPct, Icons.outgoing_mail, onTapSent),
      (
        'Delivered',
        '$delivered',
        deliveredPct,
        Icons.mark_email_read_outlined,
        onTapSent
      ),
      ('Opened', '$opened', openedPct, Icons.visibility_outlined, onTapSent),
      (
        'Responded',
        '$responded',
        respondedPct,
        Icons.check_circle_outline,
        onTapPending
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (_, index) {
        final card = cards[index];
        return UdoCard(
          onTap: card.$5,
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            UdoRingProgress(
              value: card.$3,
              color: _guestAccent,
              size: 44,
              center: Icon(card.$4, color: _guestAccent, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text(card.$2,
                      style: UdoDesign.sans(size: 17, weight: FontWeight.w800)),
                  Text(card.$1,
                      style:
                          UdoDesign.sans(size: 10.5, color: UdoDesign.muted)),
                  Text('${(card.$3 * 100).round()}%',
                      style: UdoDesign.sans(
                          size: 10,
                          weight: FontWeight.w800,
                          color: _guestAccent)),
                ])),
          ]),
        );
      },
    );
  }
}

class _InvitationInsights extends StatelessWidget {
  final int pending;
  final int missingMeal;
  final int missingTravel;
  final VoidCallback onResolve;

  const _InvitationInsights({
    required this.pending,
    required this.missingMeal,
    required this.missingTravel,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final insights = [
      if (pending > 0) 'Send RSVP reminder to $pending pending guests.',
      if (missingMeal > 0)
        '$missingMeal confirmed guests still need meal selections.',
      if (missingTravel > 0)
        '$missingTravel guests have incomplete travel details.',
      if (pending == 0 && missingMeal == 0 && missingTravel == 0)
        'Invitation operations are stable. Review delivery history next.',
    ];
    return UdoCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Smart Insights',
            style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
        const SizedBox(height: 10),
        for (final insight in insights)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.lightbulb_outline,
                  color: UdoDesign.gold, size: 18),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(insight,
                      style: UdoDesign.sans(
                          size: 12.5, color: UdoDesign.sub, height: 1.35))),
              TextButton(onPressed: onResolve, child: const Text('Resolve')),
            ]),
          ),
      ]),
    );
  }
}

class _InvitationFilterChips extends StatelessWidget {
  final String active;
  final ValueChanged<String> onChanged;
  const _InvitationFilterChips({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final chips = [
      ('all', 'All'),
      ('pending', 'Pending RSVP'),
      ('confirmed', 'Confirmed'),
      ('sent', 'Sent'),
      ('not_sent', 'Not Sent'),
      ('declined', 'Declined'),
      ('meal_missing', 'Meal Missing'),
      ('travel_missing', 'Travel Missing'),
    ];
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (final chip in chips)
        ChoiceChip(
          selected: active == chip.$1,
          label: Text(chip.$2),
          onSelected: (_) => onChanged(chip.$1),
          selectedColor: _guestAccent,
          backgroundColor: UdoDesign.card,
          side: BorderSide(
              color: active == chip.$1 ? _guestAccent : UdoDesign.stone),
          labelStyle: UdoDesign.sans(
              size: 12,
              weight: FontWeight.w700,
              color: active == chip.$1 ? Colors.white : UdoDesign.sub),
        ),
    ]);
  }
}

class _InvitationGuestCard extends StatelessWidget {
  final Map<String, dynamic> guest;
  const _InvitationGuestCard({required this.guest});

  @override
  Widget build(BuildContext context) {
    final status = guest['attending_status'] as String?;
    final sent = guest['invite_status'] == 'sent';
    final readiness = [
          sent,
          status != null && status != 'pending',
          !_guestMissingMeal(guest),
          !_guestMatchesInfoFilter(guest, 'missing_logistics'),
        ].where((done) => done).length /
        4;
    final name =
        '${guest['first_name'] ?? ''} ${guest['last_name'] ?? ''}'.trim();
    return UdoCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: _statusColorFor(status).withValues(alpha: 0.12),
          child: Text(_initials(guest),
              style: UdoDesign.sans(
                  size: 12,
                  weight: FontWeight.w800,
                  color: _statusColorFor(status))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(name.isEmpty ? 'Guest' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          UdoDesign.sans(size: 14.5, weight: FontWeight.w800))),
              UdoBadge(
                  label: sent ? 'Sent' : 'Not sent',
                  color: sent ? UdoDesign.sage : UdoDesign.amber),
            ]),
            const SizedBox(height: 4),
            Text(_statusLabel(status),
                style: UdoDesign.sans(size: 11.5, color: UdoDesign.muted)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: readiness,
              minHeight: 5,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: UdoDesign.stone,
              valueColor: const AlwaysStoppedAnimation(_guestAccent),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _InvStat extends StatelessWidget {
  final String value, label;
  const _InvStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(
          child: Column(children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.udoGreen)),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.udoTextSecondary)),
      ]));
}

// ── EXPERIENCE TAB ─────────────────────────────────────────────────────────────

const _experienceToggles = [
  ('show_schedule', 'Wedding Schedule', Icons.schedule_outlined),
  ('show_venue_map', 'Venue Map', Icons.location_on_outlined),
  ('show_accommodation', 'Accommodation Info', Icons.hotel_outlined),
  ('show_transport', 'Transport Info', Icons.directions_bus_outlined),
  ('show_seating', 'Seating Assignment', Icons.chair_outlined),
  ('show_dress_code', 'Dress Code', Icons.checkroom_outlined),
  ('show_registry', 'Gift Registry', Icons.card_giftcard_outlined),
  ('show_gallery', 'Photo Gallery', Icons.photo_library_outlined),
  ('show_live_feed', 'Live Updates', Icons.radio_outlined),
  (
    'allow_photo_uploads',
    'Guest Photos, Videos & Voice Notes',
    Icons.add_a_photo_outlined
  ),
  ('allow_messages', 'Guest Messages', Icons.forum_outlined),
  ('rsvp_enabled', 'RSVP Form', Icons.how_to_reg_outlined),
  ('meal_selection_enabled', 'Meal Selection', Icons.restaurant_menu_outlined),
  ('plus_one_enabled', 'Plus-One Option', Icons.people_outline),
];

class _ExperienceTab extends ConsumerWidget {
  final VoidCallback onGoToList;
  const _ExperienceTab({required this.onGoToList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(experienceProvider);
    final notifier = ref.read(experienceProvider.notifier);
    final guests = ref.watch(guestsProvider).guests;

    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));
    }
    if (state.error != null && state.config.isEmpty) {
      return _errorBox(
          "Couldn't load your guest portal settings.", state.error!);
    }

    final config = state.config;
    final guestPortalUrl = ref.watch(homeProvider).guestPortalUrl;
    final enabledModules =
        _experienceToggles.where((item) => config[item.$1] == true).length;
    final readiness = enabledModules / _experienceToggles.length;
    final portalCopyReady =
        (config['welcome_message'] as String?)?.trim().isNotEmpty == true;
    final rsvpReady = config['rsvp_enabled'] == true;
    final dressReady = config['show_dress_code'] == true &&
        (config['dress_code'] as String?)?.trim().isNotEmpty == true;
    final portalCommandCentre = ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        _PortalHeroCard(
          readiness: readiness,
          enabledModules: enabledModules,
          totalModules: _experienceToggles.length,
          guestCount: guests.length,
          isSaving: state.isSaving,
          onPreview: () => _showPortalPreview(context, config),
          onEditText: () => _showEditTextModal(context, notifier, config),
          onLinks: () => _showPortalLinksSheet(context, ref, guestPortalUrl),
        ),
        const SizedBox(height: 16),
        _PortalLinkCard(
          url: guestPortalUrl,
          onEdit: () => _showEditPortalLinkSheet(context, ref, guestPortalUrl),
        ),
        const SizedBox(height: 16),
        _PortalReadinessStrip(
          portalCopyReady: portalCopyReady,
          rsvpReady: rsvpReady,
          dressReady: dressReady,
          enabledModules: enabledModules,
        ),
        const SizedBox(height: 18),
        UdoSectionHeader(
          title: 'Shown on guest link',
          action: state.isSaving ? 'Saving' : 'View guest portal',
          onAction: () => _showPortalPreview(context, config),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _experienceToggles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.08,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemBuilder: (_, index) {
            final item = _experienceToggles[index];
            return _PortalModuleCard(
              field: item.$1,
              label: item.$2,
              icon: item.$3,
              category: _portalCategory(item.$1),
              enabled: config[item.$1] == true,
              onChanged: (value) => notifier.toggleField(item.$1, value),
            );
          },
        ),
        const SizedBox(height: 18),
        _PortalTextCard(
          config: config,
          onEdit: () => _showEditTextModal(context, notifier, config),
        ),
        const SizedBox(height: 18),
        _PortalAccessCard(onGoToList: onGoToList),
      ],
    );
    if (MediaQuery.sizeOf(context).width >= 0) {
      return portalCommandCentre;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.udoBorder)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(
                  child: Text('Guest portal modules',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500))),
              if (state.isSaving)
                const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.udoGreen)),
            ]),
            const SizedBox(height: 4),
            const Text(
                'Choose what guests can see and do on their public guest portal link.',
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.udoTextSecondary,
                    height: 1.4)),
            const SizedBox(height: 14),
            for (final (key, label, icon) in _experienceToggles)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                    color: AppTheme.udoCardFill,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: (config[key] == true
                                  ? AppTheme.udoGreen
                                  : AppTheme.udoTextSecondary)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(icon,
                          size: 16,
                          color: config[key] == true
                              ? AppTheme.udoGreen
                              : AppTheme.udoTextSecondary)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(label,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500))),
                  Switch(
                      value: config[key] == true,
                      onChanged: (v) => notifier.toggleField(key, v),
                      activeThumbColor: AppTheme.udoGreen,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ]),
              ),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.udoBorder)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Guest-facing text',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            const Text('Shown to guests on their portal.',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showEditTextModal(context, notifier, config),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text(
                  (config['welcome_message'] as String?)?.isNotEmpty == true
                      ? 'Edit welcome message & dress code'
                      : 'Add welcome message & dress code'),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  side: const BorderSide(color: AppTheme.udoGreen),
                  foregroundColor: AppTheme.udoGreen),
            ),
            if ((config['welcome_message'] as String?)?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              Text(config['welcome_message'] as String,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.udoTextSecondary,
                      height: 1.4)),
            ],
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.udoBorder)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Guest portal access',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            const Text(
                'Each wedding has a shared public portal link for general details. Personalized invitation links still handle RSVP, meal choices, plus-one rules, and private guest details.',
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.udoTextSecondary,
                    height: 1.5)),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onGoToList,
              icon: const Icon(Icons.people_outline, size: 16),
              label: const Text('Go to guest list'),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  side: const BorderSide(color: AppTheme.udoGreen),
                  foregroundColor: AppTheme.udoGreen),
            ),
          ]),
        ),
      ],
    );
  }

  void _showEditTextModal(BuildContext context, ExperienceNotifier notifier,
      Map<String, dynamic> config) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) =>
          _EditExperienceTextModal(notifier: notifier, config: config),
    );
  }

  void _showPortalPreview(BuildContext context, Map<String, dynamic> config) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PortalPreviewSheet(config: config),
    );
  }
}

String _portalCategory(String field) {
  if (field.contains('schedule') ||
      field.contains('venue') ||
      field.contains('transport') ||
      field.contains('accommodation')) {
    return 'Arrival';
  }
  if (field.contains('rsvp') ||
      field.contains('meal') ||
      field.contains('plus_one')) {
    return 'Response';
  }
  if (field.contains('photo') ||
      field.contains('gallery') ||
      field.contains('message') ||
      field.contains('live')) {
    return 'Memory';
  }
  return 'Details';
}

class _PortalHeroCard extends StatelessWidget {
  final double readiness;
  final int enabledModules;
  final int totalModules;
  final int guestCount;
  final bool isSaving;
  final VoidCallback onPreview;
  final VoidCallback onEditText;
  final VoidCallback onLinks;

  const _PortalHeroCard({
    required this.readiness,
    required this.enabledModules,
    required this.totalModules,
    required this.guestCount,
    required this.isSaving,
    required this.onPreview,
    required this.onEditText,
    required this.onLinks,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        color: _guestAccent,
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  UdoBadge(
                      label: isSaving ? 'Syncing portal' : 'Guest portal',
                      color: UdoDesign.gold,
                      background: const Color(0x22FFFFFF)),
                  const SizedBox(height: 12),
                  Text('Shape the wedding your guests open first.',
                      style: UdoDesign.serif(size: 29, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                      '$enabledModules of $totalModules modules live for $guestCount guest${guestCount == 1 ? '' : 's'}.',
                      style: UdoDesign.sans(
                          size: 13.5, color: Colors.white70, height: 1.45)),
                ])),
            UdoRingProgress(
              value: readiness,
              color: Colors.white,
              size: 76,
              center: Text('${(readiness * 100).round()}%',
                  style: UdoDesign.sans(
                      size: 14, weight: FontWeight.w800, color: Colors.white)),
            ),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _PortalHeroButton('View guest portal', onPreview)),
            const SizedBox(width: 8),
            Expanded(child: _PortalHeroButton('Wording', onEditText)),
            const SizedBox(width: 8),
            Expanded(child: _PortalHeroButton('Links', onLinks)),
          ]),
        ]),
      );
}

class _PortalLinkCard extends StatelessWidget {
  final String? url;
  final VoidCallback onEdit;
  const _PortalLinkCard({required this.url, required this.onEdit});

  @override
  Widget build(BuildContext context) => UdoCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.link_outlined, color: _guestAccent),
            const SizedBox(width: 10),
            Expanded(
                child: Text('Your guest portal link',
                    style: UdoDesign.sans(size: 15, weight: FontWeight.w800))),
          ]),
          const SizedBox(height: 6),
          Text(
              'This is the link every guest opens. The toggles and wording below control what they see once they get there.',
              style: UdoDesign.sans(
                  size: 12.5, color: UdoDesign.muted, height: 1.4)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
                color: UdoDesign.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: UdoDesign.border)),
            child: Text(
                (url == null || url!.isEmpty) ? 'Link not available yet' : url!,
                style: UdoDesign.sans(
                    size: 12.5, weight: FontWeight.w700, color: UdoDesign.text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
              onPressed: (url == null || url!.isEmpty)
                  ? null
                  : () {
                      Clipboard.setData(ClipboardData(text: url!));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Link copied')));
                    },
              icon: const Icon(Icons.copy_outlined, size: 16),
              label: const Text('Copy'),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _guestAccent),
                  foregroundColor: _guestAccent),
            )),
            const SizedBox(width: 10),
            Expanded(
                child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _guestAccent),
                  foregroundColor: _guestAccent),
            )),
          ]),
        ]),
      );
}

void _showPortalLinksSheet(
    BuildContext context, WidgetRef ref, String? guestPortalUrl) {
  final hasUrl = guestPortalUrl != null && guestPortalUrl.isNotEmpty;
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text('Guest portal links',
                        style:
                            UdoDesign.sans(size: 18, weight: FontWeight.w800))),
                IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close)),
              ]),
              const SizedBox(height: 6),
              Text(
                'Share this link with guests for wedding details, RSVP access, updates, and enabled portal modules.',
                style: UdoDesign.sans(
                    size: 12.5, color: UdoDesign.muted, height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                    color: UdoDesign.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: UdoDesign.border)),
                child: Text(
                  hasUrl ? guestPortalUrl : 'Link not available yet',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(
                      size: 12.5,
                      color: UdoDesign.text,
                      weight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                  onPressed: !hasUrl
                      ? null
                      : () {
                          Clipboard.setData(
                              ClipboardData(text: guestPortalUrl));
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Link copied')));
                        },
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  label: const Text('Copy link'),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _guestAccent),
                      foregroundColor: _guestAccent),
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showEditPortalLinkSheet(context, ref, guestPortalUrl);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit link'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _guestAccent,
                      foregroundColor: Colors.white),
                )),
              ]),
            ]),
      ),
    ),
  );
}

void _showEditPortalLinkSheet(
    BuildContext context, WidgetRef ref, String? currentUrl) {
  final currentSlug = (currentUrl != null && currentUrl.contains('/'))
      ? currentUrl.split('/').last
      : '';
  final controller = TextEditingController(text: currentSlug);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit portal link',
                    style: UdoDesign.sans(size: 18, weight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                    'Lowercase letters, numbers, and hyphens only — this changes the link every guest uses.',
                    style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted)),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'e.g. louis-and-jame',
                    filled: true,
                    fillColor: UdoDesign.bg,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final raw = controller.text.trim().toLowerCase();
                    if (raw.isEmpty) return;
                    if (raw == currentSlug.toLowerCase()) {
                      Navigator.pop(sheetContext);
                      return;
                    }
                    final ok = await ref
                        .read(moreOperationsProvider.notifier)
                        .updateWedding({'slug': raw});
                    if (ok) {
                      await ref.read(homeProvider.notifier).refresh();
                    }
                    if (!sheetContext.mounted) return;
                    if (ok) {
                      Navigator.pop(sheetContext);
                    } else {
                      final error = ref.read(moreOperationsProvider).error;
                      ScaffoldMessenger.of(sheetContext).showSnackBar(SnackBar(
                        content: Text(error ??
                            "Couldn't update the link. It might already be taken."),
                        backgroundColor: UdoDesign.rose,
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppTheme.udoGreen,
                      foregroundColor: Colors.white),
                  child: const Text('Save link'),
                ),
              ]),
        ),
      ),
    ),
  );
}

void _showAutomationsSheet(BuildContext context, WidgetRef ref) {
  final config = ref.read(experienceProvider).config;
  bool reminderEnabled = config['auto_rsvp_reminder_enabled'] == true;
  int reminderDays = (config['auto_rsvp_reminder_days'] as num?)?.toInt() ?? 5;
  bool thankYouEnabled = config['auto_thank_you_enabled'] == true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Consumer(builder: (context, sheetRef, _) {
              final isSaving = sheetRef.watch(experienceProvider).isSaving;
              return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Automations',
                        style:
                            UdoDesign.sans(size: 18, weight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Real, automatic messages — no manual sending needed.',
                        style:
                            UdoDesign.sans(size: 12.5, color: UdoDesign.muted)),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: reminderEnabled,
                      onChanged: (v) =>
                          setSheetState(() => reminderEnabled = v),
                      activeThumbColor: _guestAccent,
                      title: Text('Auto RSVP reminder',
                          style: UdoDesign.sans(
                              size: 14, weight: FontWeight.w700)),
                      subtitle: Text(
                          'Automatically message guests who still haven\'t responded.',
                          style:
                              UdoDesign.sans(size: 12, color: UdoDesign.muted)),
                    ),
                    if (reminderEnabled)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          Text('Remind after', style: UdoDesign.sans(size: 13)),
                          const SizedBox(width: 10),
                          DropdownButton<int>(
                            value: reminderDays,
                            items: [3, 5, 7, 10, 14, 21]
                                .map((d) => DropdownMenuItem(
                                    value: d, child: Text('$d days')))
                                .toList(),
                            onChanged: (v) => setSheetState(
                                () => reminderDays = v ?? reminderDays),
                          ),
                        ]),
                      ),
                    const Divider(height: 24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: thankYouEnabled,
                      onChanged: (v) =>
                          setSheetState(() => thankYouEnabled = v),
                      activeThumbColor: _guestAccent,
                      title: Text('Auto thank-you',
                          style: UdoDesign.sans(
                              size: 14, weight: FontWeight.w700)),
                      subtitle: Text(
                          'Send a thank-you message the moment a guest RSVPs.',
                          style:
                              UdoDesign.sans(size: 12, color: UdoDesign.muted)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final ok = await sheetRef
                                  .read(experienceProvider.notifier)
                                  .saveAutomations(
                                    rsvpReminderEnabled: reminderEnabled,
                                    rsvpReminderDays: reminderDays,
                                    thankYouEnabled: thankYouEnabled,
                                  );
                              if (!context.mounted) return;
                              if (ok) {
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Couldn't save automations. Try again."),
                                        backgroundColor: UdoDesign.rose));
                              }
                            },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: AppTheme.udoGreen,
                          foregroundColor: Colors.white),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Save'),
                    ),
                  ]);
            }),
          ),
        ),
      ),
    ),
  );
}

class _PortalHeroButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PortalHeroButton(this.label, this.onTap);

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white54),
            minimumSize: const Size(0, 42),
            padding: const EdgeInsets.symmetric(horizontal: 6)),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, maxLines: 1),
        ),
      );
}

class _PortalReadinessStrip extends StatelessWidget {
  final bool portalCopyReady;
  final bool rsvpReady;
  final bool dressReady;
  final int enabledModules;

  const _PortalReadinessStrip({
    required this.portalCopyReady,
    required this.rsvpReady,
    required this.dressReady,
    required this.enabledModules,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Welcome copy', portalCopyReady),
      ('RSVP flow', rsvpReady),
      ('Dress code', dressReady),
      ('Modules live', enabledModules >= 6),
    ];
    return UdoCard(
      padding: const EdgeInsets.all(14),
      child: Wrap(spacing: 8, runSpacing: 8, children: [
        for (final item in items)
          UdoBadge(
            label: item.$1,
            color: item.$2 ? UdoDesign.sage : UdoDesign.rose,
            background: (item.$2 ? UdoDesign.sage : UdoDesign.rose)
                .withValues(alpha: 0.1),
          ),
      ]),
    );
  }
}

class _PortalModuleCard extends StatelessWidget {
  final String field;
  final String label;
  final IconData icon;
  final String category;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _PortalModuleCard({
    required this.field,
    required this.label,
    required this.icon,
    required this.category,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        onTap: () => onChanged(!enabled),
        padding: const EdgeInsets.all(13),
        color: enabled ? const Color(0xFFFFFCF6) : UdoDesign.card,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: (enabled ? _guestAccent : UdoDesign.muted)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon,
                  color: enabled ? _guestAccent : UdoDesign.muted, size: 18),
            ),
            const Spacer(),
            Switch(
              value: enabled,
              onChanged: onChanged,
              activeThumbColor: _guestAccent,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ]),
          const Spacer(),
          Text(category,
              style: UdoDesign.sans(size: 10.5, color: UdoDesign.muted)),
          const SizedBox(height: 3),
          Text(label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(size: 13.5, weight: FontWeight.w800)),
        ]),
      );
}

class _PortalTextCard extends StatelessWidget {
  final Map<String, dynamic> config;
  final VoidCallback onEdit;
  const _PortalTextCard({required this.config, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final welcome = (config['welcome_message'] as String?)?.trim();
    final dress = (config['dress_code'] as String?)?.trim();
    final dressDetails = (config['dress_code_details'] as String?)?.trim();
    return UdoCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        UdoSectionHeader(
          title: 'Guest-facing Text',
          action: 'Edit',
          onAction: onEdit,
        ),
        const SizedBox(height: 10),
        Text(
          welcome?.isNotEmpty == true
              ? welcome!
              : 'Add the note guests see when they open their portal.',
          style: UdoDesign.sans(size: 13, color: UdoDesign.muted, height: 1.45),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          UdoBadge(
              label: dress?.isNotEmpty == true ? dress! : 'Dress code not set',
              color: UdoDesign.gold),
          if (dressDetails?.isNotEmpty == true)
            UdoBadge(label: dressDetails!, color: UdoDesign.blue),
        ]),
      ]),
    );
  }
}

class _PortalAccessCard extends StatelessWidget {
  final VoidCallback onGoToList;
  const _PortalAccessCard({required this.onGoToList});

  @override
  Widget build(BuildContext context) => UdoCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.link_outlined, color: _guestAccent),
            const SizedBox(width: 10),
            Expanded(
                child: Text('Personalized portal links',
                    style: UdoDesign.sans(size: 15, weight: FontWeight.w800))),
          ]),
          const SizedBox(height: 8),
          Text(
              'Each guest gets a secure invitation link tied to their profile, event access, RSVP permissions, plus-one rules, and portal modules.',
              style: UdoDesign.sans(
                  size: 12.5, color: UdoDesign.muted, height: 1.45)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onGoToList,
            icon: const Icon(Icons.people_outline, size: 16),
            label: const Text('Manage guest links'),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                side: const BorderSide(color: _guestAccent),
                foregroundColor: _guestAccent),
          ),
        ]),
      );
}

class _PortalPreviewSheet extends StatelessWidget {
  final Map<String, dynamic> config;
  const _PortalPreviewSheet({required this.config});

  @override
  Widget build(BuildContext context) {
    final modules =
        _experienceToggles.where((item) => config[item.$1] == true).toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text('Portal Preview',
                        style:
                            UdoDesign.sans(size: 18, weight: FontWeight.w800))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ]),
              const SizedBox(height: 12),
              UdoCard(
                color: _guestAccent,
                padding: const EdgeInsets.all(18),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome',
                          style:
                              UdoDesign.serif(size: 24, color: Colors.white)),
                      const SizedBox(height: 6),
                      Text(
                          (config['welcome_message'] as String?)
                                      ?.trim()
                                      .isNotEmpty ==
                                  true
                              ? config['welcome_message'] as String
                              : 'We are so excited to celebrate with you.',
                          style: UdoDesign.sans(
                              size: 13, color: Colors.white70, height: 1.45)),
                    ]),
              ),
              const SizedBox(height: 12),
              Text('Visible modules',
                  style: UdoDesign.sans(size: 14, weight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final module in modules.take(10))
                  UdoBadge(label: module.$2, color: _guestAccent),
                if (modules.length > 10)
                  UdoBadge(
                      label: '+${modules.length - 10} more',
                      color: UdoDesign.gold),
              ]),
            ]),
      ),
    );
  }
}

class _EditExperienceTextModal extends StatefulWidget {
  final ExperienceNotifier notifier;
  final Map<String, dynamic> config;
  const _EditExperienceTextModal(
      {required this.notifier, required this.config});
  @override
  State<_EditExperienceTextModal> createState() =>
      _EditExperienceTextModalState();
}

class _EditExperienceTextModalState extends State<_EditExperienceTextModal> {
  late final TextEditingController _welcome, _dressCode, _dressDetails;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _welcome = TextEditingController(
        text: widget.config['welcome_message'] as String? ?? '');
    _dressCode = TextEditingController(
        text: widget.config['dress_code'] as String? ?? '');
    _dressDetails = TextEditingController(
        text: widget.config['dress_code_details'] as String? ?? '');
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await widget.notifier.saveText(
      welcomeMessage: _welcome.text.trim(),
      dressCode: _dressCode.text.trim(),
      dressCodeDetails: _dressDetails.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't save. Try again.")));
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
                      child: Text('Guest-facing text',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600))),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero),
                ]),
                const SizedBox(height: 12),
                const Text('Welcome message',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                    controller: _welcome,
                    maxLines: 3,
                    decoration: InputDecoration(
                        hintText:
                            'A note guests see when they open their portal...',
                        hintStyle: const TextStyle(
                            color: AppTheme.udoTextSecondary, fontSize: 13),
                        filled: true,
                        fillColor: AppTheme.udoCardFill,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(14))),
                const SizedBox(height: 12),
                _FieldWrap('Dress code', controller: _dressCode, type: null),
                const SizedBox(height: 12),
                const Text('Dress code details',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                    controller: _dressDetails,
                    maxLines: 2,
                    decoration: InputDecoration(
                        hintText: 'e.g. Garden formal, no white or ivory',
                        hintStyle: const TextStyle(
                            color: AppTheme.udoTextSecondary, fontSize: 13),
                        filled: true,
                        fillColor: AppTheme.udoCardFill,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(14))),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
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
        )),
      );

  @override
  void dispose() {
    _welcome.dispose();
    _dressCode.dispose();
    _dressDetails.dispose();
    super.dispose();
  }
}

// ── MESSAGES TAB (Wedding Wall) ────────────────────────────────────────────────

class _MessagesTab extends ConsumerStatefulWidget {
  const _MessagesTab();
  @override
  ConsumerState<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends ConsumerState<_MessagesTab> {
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _audience = 'all';
  String _channel = 'email';

  static const _audiences = [
    ('all', 'All guests'),
    ('confirmed', 'Confirmed'),
    ('pending', 'Pending'),
    ('vip', 'VIP'),
    ('wedding_party', 'Wedding party'),
  ];

  static const _channels = {
    'email': 'Email',
    'sms': 'SMS',
    'whatsapp': 'WhatsApp',
    'in_app': 'Guest Portal Link'
  };

  static const _templates = [
    (
      'Thank you for RSVPing!',
      'We\'re so excited to celebrate with you. More details coming soon!'
    ),
    (
      'Reminder: please RSVP',
      'We\'d love to know if you\'re joining us. Please respond soon so we can finalize the seating plan.'
    ),
    ('Day-of details', 'A reminder of tomorrow\'s schedule — see you there!'),
    (
      'Travel & accommodation',
      'We\'ve reserved a room block nearby. Reach out if you\'d like the details.'
    ),
  ];

  Future<void> _send() async {
    final body = _bodyCtrl.text.trim();
    if (body.isEmpty) return;
    final subject = _subjectCtrl.text.trim().isNotEmpty
        ? _subjectCtrl.text.trim()
        : 'Message from the couple';
    final notifier = ref.read(messagesProvider.notifier);
    final ok = await notifier.sendMessage(
        subject: subject, body: body, audience: _audience, channel: _channel);
    if (ok && mounted) {
      _subjectCtrl.clear();
      _bodyCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Message sent!'), backgroundColor: AppTheme.udoGreen),
      );
    }
  }

  int _deliveryCount(Map<String, dynamic> msg, String key) {
    final summary = msg['delivery_summary'];
    if (summary is! Map) return 0;
    final counts = summary['counts'];
    final value = counts is Map ? counts[key] : null;
    return value is num ? value.toInt() : 0;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesProvider);
    final guests = ref.watch(guestsProvider).guests;
    final delivered = state.history
        .fold<int>(0, (sum, msg) => sum + _deliveryCount(msg, 'delivered'));
    final opened = state.history
        .fold<int>(0, (sum, msg) => sum + _deliveryCount(msg, 'opened'));
    final failed = state.history.fold<int>(
        0,
        (sum, msg) =>
            sum +
            _deliveryCount(msg, 'failed') +
            _deliveryCount(msg, 'bounced'));
    final recipients = state.history.fold<int>(0, (sum, msg) {
      final summary = msg['delivery_summary'];
      if (summary is Map && summary['total'] is num) {
        return sum + (summary['total'] as num).toInt();
      }
      return sum + ((msg['recipient_count'] as num?)?.toInt() ?? 0);
    });
    final commandCentre = _CommunicationCentrePage(
      state: state,
      guests: guests,
      delivered: delivered,
      opened: opened,
      failed: failed,
      recipients: recipients,
      audiences: _audiences,
      channels: _channels,
      guestPortalUrl: ref.watch(homeProvider).guestPortalUrl,
      templates: _templates,
      selectedAudience: _audience,
      selectedChannel: _channel,
      subjectCtrl: _subjectCtrl,
      bodyCtrl: _bodyCtrl,
      onAudienceChanged: (value) => setState(() => _audience = value),
      onChannelChanged: (value) => setState(() => _channel = value),
      onSend: _send,
      onUseTemplate: (template) {
        _subjectCtrl.text = template.$1;
        _bodyCtrl.text = template.$2;
      },
      onAutomations: () => _showAutomationsSheet(context, ref),
    );
    return commandCentre;
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }
}

class _CommunicationCentrePage extends StatefulWidget {
  final MessagesState state;
  final List<Map<String, dynamic>> guests;
  final int delivered;
  final int opened;
  final int failed;
  final int recipients;
  final List<(String, String)> audiences;
  final Map<String, String> channels;
  final String? guestPortalUrl;
  final List<(String, String)> templates;
  final String selectedAudience;
  final String selectedChannel;
  final TextEditingController subjectCtrl;
  final TextEditingController bodyCtrl;
  final ValueChanged<String> onAudienceChanged;
  final ValueChanged<String> onChannelChanged;
  final Future<void> Function() onSend;
  final ValueChanged<(String, String)> onUseTemplate;
  final VoidCallback onAutomations;

  const _CommunicationCentrePage({
    required this.state,
    required this.guests,
    required this.delivered,
    required this.opened,
    required this.failed,
    required this.recipients,
    required this.audiences,
    required this.channels,
    this.guestPortalUrl,
    required this.templates,
    required this.selectedAudience,
    required this.selectedChannel,
    required this.subjectCtrl,
    required this.bodyCtrl,
    required this.onAudienceChanged,
    required this.onChannelChanged,
    required this.onSend,
    required this.onUseTemplate,
    required this.onAutomations,
  });

  @override
  State<_CommunicationCentrePage> createState() =>
      _CommunicationCentrePageState();
}

class _CommunicationCentrePageState extends State<_CommunicationCentrePage> {
  String _filter = 'all';

  List<Map<String, dynamic>> get _filteredHistory {
    return widget.state.history.where((msg) {
      final status = msg['status']?.toString().toLowerCase() ?? '';
      return switch (_filter) {
        'failed' => widget.failed > 0 && status.contains('fail'),
        'completed' => status.contains('sent') || status.contains('complete'),
        'draft' => status.contains('draft'),
        'scheduled' => status.contains('scheduled'),
        _ => true,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final deliveryRate =
        widget.recipients == 0 ? 0.0 : widget.delivered / widget.recipients;
    final openRate =
        widget.delivered == 0 ? 0.0 : widget.opened / widget.delivered;
    final followUp = widget.guests
        .where((g) =>
            g['attending_status'] == null || g['attending_status'] == 'pending')
        .length;
    final history = _filteredHistory;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        _CommunicationHeroCard(
          totalGuests: widget.guests.length,
          campaigns: widget.state.history.length,
          deliveryRate: deliveryRate,
          failed: widget.failed,
          onNewCampaign: () => _showComposer(context),
          onTemplates: () => _showTemplates(context),
          onAutomations: widget.onAutomations,
        ),
        const SizedBox(height: 16),
        _CommunicationKpiGrid(
          deliveredRate: deliveryRate,
          openedRate: openRate,
          rsvpRate: widget.guests.isEmpty
              ? 0
              : widget.guests
                      .where((g) =>
                          g['attending_status'] == 'yes' ||
                          g['attending_status'] == 'no')
                      .length /
                  widget.guests.length,
          followUp: followUp,
          onFollowUp: () => _showComposer(context, audience: 'pending'),
        ),
        const SizedBox(height: 18),
        _CommunicationInsights(
          followUp: followUp,
          failed: widget.failed,
          onResolve: () => _showComposer(context, audience: 'pending'),
        ),
        const SizedBox(height: 18),
        _CampaignFilterChips(
          active: _filter,
          onChanged: (value) => setState(() => _filter = value),
        ),
        const SizedBox(height: 18),
        UdoSectionHeader(
          title: 'Campaign Cards',
          action: 'New',
          onAction: () => _showComposer(context),
        ),
        if (widget.state.isLoading)
          const Center(child: CircularProgressIndicator(color: _guestAccent))
        else if (widget.state.error != null && widget.state.history.isEmpty)
          _errorBox("Couldn't load message history.", widget.state.error!)
        else if (history.isEmpty)
          UdoCard(
            padding: const EdgeInsets.all(18),
            child: Text('No campaigns match this filter.',
                style: UdoDesign.sans(size: 13, color: UdoDesign.muted)),
          )
        else
          for (final msg in history) _CampaignCard(message: msg),
        const SizedBox(height: 18),
        const UdoSectionHeader(title: 'Audience Builder'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final audience in widget.audiences)
            ActionChip(
              onPressed: () => _showComposer(context, audience: audience.$1),
              avatar: const Icon(Icons.group_outlined,
                  size: 16, color: _guestAccent),
              label: Text(audience.$2),
              backgroundColor: UdoDesign.card,
              side: const BorderSide(color: UdoDesign.stone),
              labelStyle: UdoDesign.sans(
                  size: 12.5, weight: FontWeight.w700, color: UdoDesign.text),
            ),
        ]),
      ],
    );
  }

  void _showTemplates(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Message Templates',
                        style:
                            UdoDesign.sans(size: 18, weight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    for (final template in widget.templates)
                      UdoCard(
                        onTap: () {
                          widget.onUseTemplate(template);
                          Navigator.pop(context);
                          _showComposer(context);
                        },
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(template.$1,
                                  style: UdoDesign.sans(
                                      size: 14, weight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text(template.$2,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: UdoDesign.sans(
                                      size: 12,
                                      color: UdoDesign.muted,
                                      height: 1.35)),
                            ]),
                      ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  void _showComposer(BuildContext context, {String? audience}) {
    if (audience != null) widget.onAudienceChanged(audience);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85),
              child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Text('New Campaign',
                                style: UdoDesign.sans(
                                    size: 18, weight: FontWeight.w800))),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close)),
                      ]),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final audience in widget.audiences)
                          ChoiceChip(
                            selected: widget.selectedAudience == audience.$1,
                            label: Text(audience.$2),
                            onSelected: (_) => setState(
                                () => widget.onAudienceChanged(audience.$1)),
                            selectedColor: _guestAccent,
                            backgroundColor: UdoDesign.card,
                            side: BorderSide(
                                color: widget.selectedAudience == audience.$1
                                    ? _guestAccent
                                    : UdoDesign.stone),
                            labelStyle: UdoDesign.sans(
                                size: 12,
                                weight: FontWeight.w700,
                                color: widget.selectedAudience == audience.$1
                                    ? Colors.white
                                    : UdoDesign.text),
                          ),
                      ]),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, children: [
                        for (final channel in widget.channels.entries)
                          ChoiceChip(
                            selected: widget.selectedChannel == channel.key,
                            label: Text(channel.value),
                            onSelected: (_) => setState(
                                () => widget.onChannelChanged(channel.key)),
                            selectedColor: _guestAccent,
                            backgroundColor: UdoDesign.card,
                            side: BorderSide(
                                color: widget.selectedChannel == channel.key
                                    ? _guestAccent
                                    : UdoDesign.stone),
                            labelStyle: UdoDesign.sans(
                                size: 12,
                                weight: FontWeight.w700,
                                color: widget.selectedChannel == channel.key
                                    ? Colors.white
                                    : UdoDesign.text),
                          ),
                      ]),
                      if (widget.selectedChannel == 'in_app') ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: _guestAccent.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline,
                                    size: 15, color: _guestAccent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.guestPortalUrl != null &&
                                            widget.guestPortalUrl!.isNotEmpty
                                        ? 'Guests will receive this as a wedding portal message:\n${widget.guestPortalUrl}'
                                        : "Guests will receive this as a wedding portal message once your portal link is ready.",
                                    style: UdoDesign.sans(
                                        size: 12,
                                        color: _guestAccent,
                                        weight: FontWeight.w500),
                                  ),
                                ),
                              ]),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _CampaignTextField(
                          controller: widget.subjectCtrl, hint: 'Subject'),
                      const SizedBox(height: 10),
                      _CampaignTextField(
                          controller: widget.bodyCtrl,
                          hint: 'Write your message...',
                          maxLines: 4),
                      if (widget.state.sendError != null) ...[
                        const SizedBox(height: 10),
                        Text(widget.state.sendError!,
                            style: UdoDesign.sans(
                                size: 12, color: UdoDesign.rose)),
                      ],
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: widget.state.isSending
                            ? null
                            : () async {
                                await widget.onSend();
                                if (context.mounted &&
                                    !widget.state.isSending) {
                                  Navigator.pop(context);
                                }
                              },
                        icon: widget.state.isSending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send_outlined, size: 18),
                        label: const Text('Send Campaign'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: _guestAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunicationHeroCard extends StatelessWidget {
  final int totalGuests;
  final int campaigns;
  final double deliveryRate;
  final int failed;
  final VoidCallback onNewCampaign;
  final VoidCallback onTemplates;
  final VoidCallback onAutomations;

  const _CommunicationHeroCard({
    required this.totalGuests,
    required this.campaigns,
    required this.deliveryRate,
    required this.failed,
    required this.onNewCampaign,
    required this.onTemplates,
    required this.onAutomations,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        color: _guestAccent,
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const UdoBadge(
                        label: 'Communication overview',
                        color: UdoDesign.gold,
                        background: Color(0x22FFFFFF)),
                    const SizedBox(height: 12),
                    Text('Reach every guest, on every channel.',
                        style: UdoDesign.serif(size: 30, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(
                        '$totalGuests guests. $campaigns campaigns. $failed require attention.',
                        style: UdoDesign.sans(
                            size: 13.5, color: Colors.white70, height: 1.45)),
                  ]),
            ),
            UdoRingProgress(
              value: deliveryRate,
              color: Colors.white,
              size: 76,
              center: Text('${(deliveryRate * 100).round()}%',
                  style: UdoDesign.sans(
                      size: 14, weight: FontWeight.w800, color: Colors.white)),
            ),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
                child:
                    _HeroAction(label: 'New Campaign', onTap: onNewCampaign)),
            const SizedBox(width: 8),
            Expanded(
                child: _HeroAction(label: 'Templates', onTap: onTemplates)),
            const SizedBox(width: 8),
            Expanded(
                child: _HeroAction(label: 'Automations', onTap: onAutomations)),
          ]),
        ]),
      );
}

class _HeroAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _HeroAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white54),
            minimumSize: const Size(0, 42),
            padding: const EdgeInsets.symmetric(horizontal: 6)),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, maxLines: 1),
        ),
      );
}

class _CommunicationKpiGrid extends StatelessWidget {
  final double deliveredRate, openedRate, rsvpRate;
  final int followUp;
  final VoidCallback onFollowUp;
  const _CommunicationKpiGrid({
    required this.deliveredRate,
    required this.openedRate,
    required this.rsvpRate,
    required this.followUp,
    required this.onFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        'Delivered',
        '${(deliveredRate * 100).round()}%',
        deliveredRate,
        Icons.mark_email_read_outlined
      ),
      (
        'Opened',
        '${(openedRate * 100).round()}%',
        openedRate,
        Icons.visibility_outlined
      ),
      (
        'RSVP Generated',
        '${(rsvpRate * 100).round()}%',
        rsvpRate,
        Icons.how_to_reg_outlined
      ),
      (
        'Need Follow-up',
        '$followUp',
        followUp == 0 ? 1.0 : 0.25,
        Icons.notification_important_outlined
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (_, index) {
        final card = cards[index];
        return UdoCard(
          onTap: index == 3 ? onFollowUp : null,
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            UdoRingProgress(
              value: card.$3,
              color: _guestAccent,
              size: 44,
              center: Icon(card.$4, color: _guestAccent, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text(card.$2,
                      style: UdoDesign.sans(size: 16, weight: FontWeight.w800)),
                  Text(card.$1,
                      style:
                          UdoDesign.sans(size: 10.5, color: UdoDesign.muted)),
                ])),
          ]),
        );
      },
    );
  }
}

class _CommunicationInsights extends StatelessWidget {
  final int followUp;
  final int failed;
  final VoidCallback onResolve;
  const _CommunicationInsights(
      {required this.followUp, required this.failed, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    final insight = failed > 0
        ? '$failed message deliveries need review.'
        : followUp > 0
            ? '$followUp guests should receive an RSVP follow-up.'
            : 'Communication health is stable. Schedule final-week updates next.';
    return UdoCard(
      onTap: onResolve,
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.auto_awesome_outlined, color: _guestAccent),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Smart Recommendations',
              style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(insight,
              style: UdoDesign.sans(
                  size: 12.5, color: UdoDesign.muted, height: 1.42)),
        ])),
        const Icon(Icons.chevron_right, color: UdoDesign.muted),
      ]),
    );
  }
}

class _CampaignFilterChips extends StatelessWidget {
  final String active;
  final ValueChanged<String> onChanged;
  const _CampaignFilterChips({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final chips = [
      'all',
      'scheduled',
      'draft',
      'sending',
      'completed',
      'failed',
      'archived'
    ];
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (final chip in chips)
        ChoiceChip(
          selected: active == chip,
          label: Text(chip[0].toUpperCase() + chip.substring(1)),
          onSelected: (_) => onChanged(chip),
          selectedColor: _guestAccent,
          backgroundColor: UdoDesign.card,
          side: BorderSide(
              color: active == chip ? _guestAccent : UdoDesign.stone),
          labelStyle: UdoDesign.sans(
              size: 12,
              weight: FontWeight.w700,
              color: active == chip ? Colors.white : UdoDesign.sub),
        ),
    ]);
  }
}

class _CampaignCard extends StatelessWidget {
  final Map<String, dynamic> message;
  const _CampaignCard({required this.message});

  int _count(String key) {
    final summary = message['delivery_summary'];
    if (summary is! Map) return 0;
    final counts = summary['counts'];
    final value = counts is Map ? counts[key] : null;
    return value is num ? value.toInt() : 0;
  }

  @override
  Widget build(BuildContext context) {
    final summary = message['delivery_summary'];
    final total = summary is Map && summary['total'] is num
        ? (summary['total'] as num).toInt()
        : (message['recipient_count'] as num?)?.toInt() ?? 0;
    final delivered = _count('delivered') + _count('opened');
    final failed = _count('failed') + _count('bounced');
    final progress = total == 0 ? 0.0 : delivered / total;
    final subject = message['subject'] as String? ?? 'Campaign';
    return UdoCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(failed > 0 ? Icons.error_outline : Icons.campaign_outlined,
              color: failed > 0 ? UdoDesign.rose : _guestAccent),
          const SizedBox(width: 12),
          Expanded(
              child: Text(subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(size: 14.5, weight: FontWeight.w800))),
          UdoBadge(
              label: message['status']?.toString() ?? 'sent',
              color: failed > 0 ? UdoDesign.rose : UdoDesign.sage),
        ]),
        const SizedBox(height: 8),
        Text(
            '${message['channel'] ?? 'email'} - $total recipient${total == 1 ? '' : 's'}',
            style: UdoDesign.sans(size: 11.5, color: UdoDesign.muted)),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress,
          minHeight: 5,
          borderRadius: BorderRadius.circular(999),
          backgroundColor: UdoDesign.stone,
          valueColor: const AlwaysStoppedAnimation(_guestAccent),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          UdoBadge(label: '$delivered delivered', color: UdoDesign.sage),
          UdoBadge(label: '${_count('opened')} opened', color: UdoDesign.blue),
          if (failed > 0)
            UdoBadge(label: '$failed failed', color: UdoDesign.rose),
        ]),
      ]),
    );
  }
}

class _CampaignTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _CampaignTextField(
      {required this.controller, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: UdoDesign.sans(size: 14, color: UdoDesign.muted),
          filled: true,
          fillColor: UdoDesign.bg,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      );
}

// ── LOGISTICS TAB ──────────────────────────────────────────────────────────────

class _LogisticsTab extends ConsumerWidget {
  final void Function({String? infoFilter, String? statusFilter})
      onJumpToGuestList;
  const _LogisticsTab({required this.onJumpToGuestList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logistics = ref.watch(logisticsProvider);
    final notifier = ref.read(logisticsProvider.notifier);
    if (logistics.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.udoGreen));
    }
    if (logistics.error != null &&
        logistics.accommodations.isEmpty &&
        logistics.transports.isEmpty) {
      return _errorBox("Couldn't load logistics.", logistics.error!);
    }

    final summary = logistics.summary;
    final travelling = (summary['travelling_guests'] as num?)?.toInt() ?? 0;
    final accommodationAssigned =
        (summary['accommodation_assigned'] as num?)?.toInt() ?? 0;
    final transportAssigned =
        (summary['transport_assigned'] as num?)?.toInt() ?? 0;
    final missingArrival =
        (summary['missing_arrival_info'] as num?)?.toInt() ?? 0;
    // Deduplicated (a guest missing both accommodation and transport counts
    // once here, not twice) so this tile's number always matches exactly
    // what the drill-down list shows — summing the two separate backend
    // counts would double-count guests missing both.
    final needsLogistics = ref
        .watch(guestsProvider)
        .guests
        .where((g) => _guestMatchesInfoFilter(g, 'missing_logistics'))
        .length;
    final seatsRemaining =
        (summary['transport_seats_remaining'] as num?)?.toInt() ?? 0;
    final totalHotelRooms = logistics.accommodations.fold<int>(
        0,
        (sum, hotel) =>
            sum +
            ((hotel['total_rooms_blocked'] ?? hotel['total_rooms'] ?? 0) as num)
                .toInt());
    final bookedHotelRooms = logistics.accommodations.fold<int>(0,
        (sum, hotel) => sum + ((hotel['rooms_assigned'] ?? 0) as num).toInt());
    final totalSeats = logistics.transports.fold<int>(
        0, (sum, route) => sum + ((route['capacity'] ?? 0) as num).toInt());
    final bookedSeats = logistics.transports.fold<int>(0,
        (sum, route) => sum + ((route['assignments'] as List?)?.length ?? 0));
    final logisticsCommandCentre = ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        _LogisticsHeroCard(
          travelling: travelling,
          missingArrival: missingArrival,
          needsLogistics: needsLogistics,
          onAddHotel: () => _showAddHotelModal(context, notifier),
          onAddTransport: () => _showAddTransportModal(context, notifier),
          onReviewMissing: needsLogistics == 0
              ? () => onJumpToGuestList()
              : () => onJumpToGuestList(infoFilter: 'missing_logistics'),
        ),
        const SizedBox(height: 16),
        _LogisticsKpiGrid(
          hotelAssigned: accommodationAssigned,
          transportAssigned: transportAssigned,
          rooms:
              totalHotelRooms == 0 ? '0' : '$bookedHotelRooms/$totalHotelRooms',
          seats:
              totalSeats == 0 ? '$seatsRemaining' : '$bookedSeats/$totalSeats',
          onMissingArrival: missingArrival == 0
              ? null
              : () => onJumpToGuestList(infoFilter: 'missing_arrival'),
          onNeedsLogistics: needsLogistics == 0
              ? null
              : () => onJumpToGuestList(infoFilter: 'missing_logistics'),
        ),
        const SizedBox(height: 18),
        _LogisticsInsight(
          missingArrival: missingArrival,
          needsLogistics: needsLogistics,
          seatsRemaining: seatsRemaining,
          onTap: needsLogistics == 0
              ? null
              : () => onJumpToGuestList(infoFilter: 'missing_logistics'),
        ),
        const SizedBox(height: 18),
        const UdoSectionHeader(title: 'Accommodation'),
        const SizedBox(height: 10),
        if (logistics.accommodations.isEmpty)
          const _LogisticsEmptyCard(
              icon: Icons.hotel_outlined,
              title: 'No hotel blocks yet',
              body: 'Add room blocks, rates and assignment capacity.')
        else ...[
          for (final hotel in logistics.accommodations)
            _HotelCommandCard(
              hotel: hotel,
              guests: ref.watch(guestsProvider).guests,
              notifier: notifier,
              guestsNotifier: ref.read(guestsProvider.notifier),
            ),
          const SizedBox(height: 12),
          _AddRouteBottomButton(
            label: 'Add Hotel',
            onTap: () => _showAddHotelModal(context, notifier),
          ),
        ],
        const SizedBox(height: 18),
        const UdoSectionHeader(title: 'Transportation'),
        const SizedBox(height: 10),
        if (logistics.transports.isEmpty)
          _LogisticsEmptyCard(
              icon: Icons.directions_bus_outlined,
              title: 'No routes yet',
              body: 'Add shuttles, pickup windows, drivers and capacity.',
              actionLabel: 'Add Route',
              onAction: () => _showAddTransportModal(context, notifier))
        else ...[
          for (final route in logistics.transports)
            _RouteCommandCard(
              route: route,
              guests: ref.watch(guestsProvider).guests,
              notifier: notifier,
              guestsNotifier: ref.read(guestsProvider.notifier),
            ),
          const SizedBox(height: 12),
          _AddRouteBottomButton(
            onTap: () => _showAddTransportModal(context, notifier),
          ),
        ],
      ],
    );
    if (MediaQuery.sizeOf(context).width >= 0) {
      return logisticsCommandCentre;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          const Expanded(
              child: Text('Accommodation',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          TextButton.icon(
              onPressed: () => _showAddHotelModal(context, notifier),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add', style: TextStyle(fontSize: 13))),
        ]),
        const SizedBox(height: 8),
        if (logistics.accommodations.isEmpty)
          const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('No accommodation added yet.',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.udoTextSecondary)))
        else
          for (final h in logistics.accommodations) _AccommodationCard(h: h),
        const SizedBox(height: 16),
        Row(children: [
          const Expanded(
              child: Text('Transport',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          TextButton.icon(
              onPressed: () => _showAddTransportModal(context, notifier),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add', style: TextStyle(fontSize: 13))),
        ]),
        const SizedBox(height: 8),
        if (logistics.transports.isEmpty)
          const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('No transport groups added yet.',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.udoTextSecondary)))
        else
          for (final t in logistics.transports) _TransportCard(t: t),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.udoBorder)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Travel overview',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            const Text('Based on each guest\'s travel details.',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            const SizedBox(height: 12),
            Row(children: [
              _ArrivalStat('$travelling', 'Travelling', AppTheme.udoGreen),
              _ArrivalStat('$missingArrival', 'Missing arrival', Colors.orange,
                  onTap: missingArrival == 0
                      ? null
                      : () => onJumpToGuestList(infoFilter: 'missing_arrival')),
              _ArrivalStat(
                  '${(summary['transport_seats_remaining'] as num?)?.toInt() ?? 0}',
                  'Seats left',
                  AppTheme.udoTextSecondary),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _ArrivalStat('$accommodationAssigned', 'Hotels assigned',
                  AppTheme.udoGreen),
              _ArrivalStat('$transportAssigned', 'Transport assigned',
                  AppTheme.udoGreen),
              _ArrivalStat('$needsLogistics', 'Needs logistics', Colors.orange,
                  onTap: needsLogistics == 0
                      ? null
                      : () =>
                          onJumpToGuestList(infoFilter: 'missing_logistics')),
            ]),
          ]),
        ),
      ],
    );
  }

  void _showAddHotelModal(BuildContext context, LogisticsNotifier notifier) {
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => AddHotelModal(notifier: notifier));
  }

  void _showAddTransportModal(
      BuildContext context, LogisticsNotifier notifier) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => AddTransportModal(notifier: notifier));
  }
}

class _LogisticsHeroCard extends StatelessWidget {
  final int travelling;
  final int missingArrival;
  final int needsLogistics;
  final VoidCallback onAddHotel;
  final VoidCallback onAddTransport;
  final VoidCallback onReviewMissing;

  const _LogisticsHeroCard({
    required this.travelling,
    required this.missingArrival,
    required this.needsLogistics,
    required this.onAddHotel,
    required this.onAddTransport,
    required this.onReviewMissing,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        color: _guestAccent,
        padding: const EdgeInsets.all(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const UdoBadge(
              label: 'Arrival operations',
              color: UdoDesign.gold,
              background: Color(0x22FFFFFF)),
          const SizedBox(height: 12),
          Text('Coordinate every room, route and arrival.',
              style: UdoDesign.serif(size: 30, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
              '$travelling travelling guests. $missingArrival missing arrival details. $needsLogistics need logistics.',
              style: UdoDesign.sans(
                  size: 13.5, color: Colors.white70, height: 1.45)),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _PortalHeroButton('Add Hotel', onAddHotel)),
            const SizedBox(width: 8),
            Expanded(child: _PortalHeroButton('Add Route', onAddTransport)),
            const SizedBox(width: 8),
            Expanded(child: _PortalHeroButton('Review', onReviewMissing)),
          ]),
        ]),
      );
}

class _LogisticsKpiGrid extends StatelessWidget {
  final int hotelAssigned;
  final int transportAssigned;
  final String rooms;
  final String seats;
  final VoidCallback? onMissingArrival;
  final VoidCallback? onNeedsLogistics;

  const _LogisticsKpiGrid({
    required this.hotelAssigned,
    required this.transportAssigned,
    required this.rooms,
    required this.seats,
    required this.onMissingArrival,
    required this.onNeedsLogistics,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      ('Hotels assigned', '$hotelAssigned', Icons.hotel_outlined, null),
      (
        'Transport assigned',
        '$transportAssigned',
        Icons.directions_bus_outlined,
        null
      ),
      ('Room usage', rooms, Icons.king_bed_outlined, onNeedsLogistics),
      ('Seat usage', seats, Icons.event_seat_outlined, onMissingArrival),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.9,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (_, index) {
        final card = cards[index];
        return UdoCard(
          onTap: card.$4,
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: _guestAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(card.$3, color: _guestAccent, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(card.$2,
                      style: UdoDesign.sans(size: 16, weight: FontWeight.w800)),
                  Text(card.$1,
                      style:
                          UdoDesign.sans(size: 10.5, color: UdoDesign.muted)),
                ])),
          ]),
        );
      },
    );
  }
}

class _LogisticsInsight extends StatelessWidget {
  final int missingArrival;
  final int needsLogistics;
  final int seatsRemaining;
  final VoidCallback? onTap;

  const _LogisticsInsight({
    required this.missingArrival,
    required this.needsLogistics,
    required this.seatsRemaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = needsLogistics > 0
        ? '$needsLogistics guests need hotel or transport assignments.'
        : missingArrival > 0
            ? '$missingArrival guests still need arrival details.'
            : seatsRemaining < 0
                ? 'Transport is over capacity. Add another route.'
                : 'Logistics are currently stable.';
    return UdoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.route_outlined, color: _guestAccent),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Operations Note',
              style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(text,
              style: UdoDesign.sans(
                  size: 12.5, color: UdoDesign.muted, height: 1.42)),
        ])),
        if (onTap != null)
          const Icon(Icons.chevron_right, color: UdoDesign.muted),
      ]),
    );
  }
}

class _HotelCommandCard extends StatelessWidget {
  final Map<String, dynamic> hotel;
  final List<Map<String, dynamic>> guests;
  final LogisticsNotifier notifier;
  final GuestsNotifier guestsNotifier;
  const _HotelCommandCard({
    required this.hotel,
    required this.guests,
    required this.notifier,
    required this.guestsNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final totalRooms =
        ((hotel['total_rooms_blocked'] ?? hotel['total_rooms'] ?? 0) as num)
            .toInt();
    final assigned = ((hotel['rooms_assigned'] ?? 0) as num).toInt();
    final progress = totalRooms == 0 ? 0.0 : assigned / totalRooms;
    final rate = hotel['price_per_night'];
    final assignedGuests = guests
        .where((guest) => guest['hotel_assignment_id'] == hotel['id'])
        .toList();
    return UdoCard(
      onTap: () => _showAccommodationDetailSheet(
        context: context,
        hotel: hotel,
        guests: guests,
        notifier: notifier,
        guestsNotifier: guestsNotifier,
      ),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.hotel_outlined, color: _guestAccent),
          const SizedBox(width: 10),
          Expanded(
              child: Text(hotel['name'] as String? ?? 'Hotel block',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(size: 14.5, weight: FontWeight.w800))),
          if (rate != null)
            UdoBadge(label: '\$$rate/night', color: UdoDesign.gold),
        ]),
        if ((hotel['address'] as String?)?.isNotEmpty == true) ...[
          const SizedBox(height: 6),
          Text(hotel['address'] as String,
              style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
        ],
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress.clamp(0, 1).toDouble(),
          minHeight: 5,
          borderRadius: BorderRadius.circular(999),
          backgroundColor: UdoDesign.stone,
          valueColor: const AlwaysStoppedAnimation(_guestAccent),
        ),
        const SizedBox(height: 9),
        Wrap(spacing: 8, runSpacing: 8, children: [
          UdoBadge(label: '$assigned assigned', color: UdoDesign.sage),
          UdoBadge(label: '$totalRooms rooms', color: UdoDesign.blue),
          if (assignedGuests.isNotEmpty)
            UdoBadge(
                label:
                    '${assignedGuests.length} guest${assignedGuests.length == 1 ? '' : 's'}',
                color: UdoDesign.gold),
          if (hotel['check_in_date'] != null)
            UdoBadge(
                label: 'In ${udo_dates.formatApiDate(hotel['check_in_date'])}',
                color: UdoDesign.gold),
        ]),
      ]),
    );
  }
}

class _RouteCommandCard extends StatelessWidget {
  final Map<String, dynamic> route;
  final List<Map<String, dynamic>> guests;
  final LogisticsNotifier notifier;
  final GuestsNotifier guestsNotifier;
  const _RouteCommandCard({
    required this.route,
    required this.guests,
    required this.notifier,
    required this.guestsNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final capacity = ((route['capacity'] ?? 0) as num).toInt();
    final assigned = ((route['assignments'] as List?) ?? []).length;
    final progress = capacity == 0 ? 0.0 : assigned / capacity;
    final pickup = route['pickup_location'] as String? ?? '';
    final dropoff = route['dropoff_location'] as String? ?? '';
    return UdoCard(
      onTap: () => _showTransportDetailSheet(
        context: context,
        route: route,
        guests: guests,
        notifier: notifier,
        guestsNotifier: guestsNotifier,
      ),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.directions_bus_outlined, color: _guestAccent),
          const SizedBox(width: 10),
          Expanded(
              child: Text(route['name'] as String? ?? 'Transport route',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(size: 14.5, weight: FontWeight.w800))),
          if ((route['type'] as String?)?.isNotEmpty == true)
            UdoBadge(label: route['type'] as String, color: UdoDesign.blue),
        ]),
        if (pickup.isNotEmpty || dropoff.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('$pickup -> $dropoff',
              style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
        ],
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress.clamp(0, 1).toDouble(),
          minHeight: 5,
          borderRadius: BorderRadius.circular(999),
          backgroundColor: UdoDesign.stone,
          valueColor: const AlwaysStoppedAnimation(_guestAccent),
        ),
        const SizedBox(height: 9),
        Wrap(spacing: 8, runSpacing: 8, children: [
          UdoBadge(label: '$assigned assigned', color: UdoDesign.sage),
          UdoBadge(label: '$capacity seats', color: UdoDesign.gold),
          if (capacity > 0)
            UdoBadge(
                label: '${capacity - assigned} left', color: UdoDesign.blue),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.person_add_alt_1_outlined,
              size: 16, color: _guestAccent),
          const SizedBox(width: 6),
          Text('Add guests to route',
              style: UdoDesign.sans(
                  size: 12, weight: FontWeight.w800, color: _guestAccent)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: UdoDesign.muted, size: 18),
        ]),
      ]),
    );
  }
}

void _showTransportDetailSheet({
  required BuildContext context,
  required Map<String, dynamic> route,
  required List<Map<String, dynamic>> guests,
  required LogisticsNotifier notifier,
  required GuestsNotifier guestsNotifier,
}) {
  final routeId = _guestId(route) ?? 0;
  final capacity = ((route['capacity'] ?? 0) as num).toInt();
  final assignedGuests = _transportAssignedGuests(route, guests);
  final assignedCount =
      ((route['assignments'] as List?)?.length ?? assignedGuests.length);
  final remaining =
      capacity > 0 ? (capacity - assignedCount).clamp(0, capacity) : 0;
  final pickup = route['pickup_location']?.toString() ?? '';
  final dropoff = route['dropoff_location']?.toString() ?? '';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(route['name']?.toString() ?? 'Transport route',
                    style: UdoDesign.serif(size: 22, color: UdoDesign.text)),
              ),
              IconButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close)),
            ]),
            if (pickup.isNotEmpty || dropoff.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('$pickup -> $dropoff',
                  style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
            ],
            const Divider(height: 24),
            _AccommodationInfoRow('Capacity', '$capacity seats'),
            _AccommodationInfoRow('Assigned',
                '$assignedCount guest${assignedCount == 1 ? '' : 's'}'),
            _AccommodationInfoRow(
                'Available', '$remaining seat${remaining == 1 ? '' : 's'}'),
            const SizedBox(height: 16),
            Text('Assigned Guests',
                style: UdoDesign.sans(
                    size: 11, weight: FontWeight.w800, color: UdoDesign.muted)),
            const SizedBox(height: 10),
            if (assignedGuests.isEmpty)
              Text('No guests assigned yet.',
                  style: UdoDesign.sans(size: 13, color: UdoDesign.muted))
            else
              for (final guest in assignedGuests)
                _TransportAssignedGuestRow(guest: guest),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                _showAssignTransportGuestSheet(
                  context: context,
                  route: route,
                  guests: guests,
                  notifier: notifier,
                  guestsNotifier: guestsNotifier,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: _guestAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Guests to Route'),
            ),
            if (routeId == 0) ...[
              const SizedBox(height: 8),
              Text('Route ID is missing, so assignments cannot be saved.',
                  style: UdoDesign.sans(size: 12, color: AppTheme.udoCrimson)),
            ],
          ]),
        ),
      ),
    ),
  );
}

void _showAssignTransportGuestSheet({
  required BuildContext context,
  required Map<String, dynamic> route,
  required List<Map<String, dynamic>> guests,
  required LogisticsNotifier notifier,
  required GuestsNotifier guestsNotifier,
}) {
  final routeId = _guestId(route);
  if (routeId == null) return;
  final routeAssignedIds = _transportAssignedGuestIds(route);
  final capacity = ((route['capacity'] ?? 0) as num).toInt();
  final assignedCount = ((route['assignments'] as List?) ?? []).length;
  final full = capacity > 0 && assignedCount >= capacity;
  final candidates = guests.toList()
    ..sort((a, b) {
      final aAssigned = routeAssignedIds.contains(_guestId(a));
      final bAssigned = routeAssignedIds.contains(_guestId(b));
      if (aAssigned != bAssigned) return aAssigned ? -1 : 1;
      return _guestDisplayName(a).compareTo(_guestDisplayName(b));
    });

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(
              child: Text('Add guests to route',
                  style: UdoDesign.sans(size: 18, weight: FontWeight.w800)),
            ),
            IconButton(
                onPressed: () => Navigator.pop(sheetContext),
                icon: const Icon(Icons.close)),
          ]),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(route['name']?.toString() ?? 'Transport route',
                style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
          ),
          const SizedBox(height: 12),
          if (candidates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('No guests found. Add guests first.',
                  style: UdoDesign.sans(size: 13, color: UdoDesign.muted)),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: candidates.length,
                itemBuilder: (_, index) {
                  final guest = candidates[index];
                  final guestId = _guestId(guest);
                  final selected = routeAssignedIds.contains(guestId);
                  final assignedTransportId =
                      _guestId({'id': guest['transport_assignment_id']});
                  final assignedElsewhere = assignedTransportId != null &&
                      assignedTransportId != routeId &&
                      !selected;
                  final canAssign = !selected &&
                      !assignedElsewhere &&
                      (!full || capacity == 0);
                  return UdoCard(
                    onTap: canAssign
                        ? () async {
                            if (guestId == null) return;
                            final ok = await notifier.assignTransport(
                                routeId, guestId);
                            if (ok) await guestsNotifier.refresh();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(ok
                                    ? 'Guest added to ${route['name'] ?? 'route'}.'
                                    : "Couldn't add this guest.")));
                            if (ok && sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          }
                        : null,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: _guestAccent.withValues(alpha: 0.12),
                        child: Text(_initials(guest),
                            style: UdoDesign.sans(
                                size: 10,
                                weight: FontWeight.w800,
                                color: _guestAccent)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_guestDisplayName(guest),
                                  style: UdoDesign.sans(
                                      size: 13, weight: FontWeight.w800)),
                              if (selected)
                                Text('Already on this route',
                                    style: UdoDesign.sans(
                                        size: 11, color: UdoDesign.muted))
                              else if (assignedElsewhere)
                                Text('Assigned to another route',
                                    style: UdoDesign.sans(
                                        size: 11, color: UdoDesign.muted))
                              else if (full && capacity > 0)
                                Text('Route is full',
                                    style: UdoDesign.sans(
                                        size: 11, color: AppTheme.udoCrimson)),
                            ]),
                      ),
                      if (selected)
                        const Icon(Icons.check_circle,
                            color: UdoDesign.sage, size: 22)
                      else if (canAssign)
                        const Icon(Icons.add_circle_outline,
                            color: _guestAccent, size: 22),
                    ]),
                  );
                },
              ),
            ),
        ]),
      ),
    ),
  );
}

Set<int> _transportAssignedGuestIds(Map<String, dynamic> route) {
  final assignments = (route['assignments'] as List?) ?? [];
  return assignments
      .whereType<Map>()
      .map((assignment) =>
          _guestId({'id': assignment['guest_id']}) ??
          (assignment['guest'] is Map
              ? _guestId(Map<String, dynamic>.from(assignment['guest'] as Map))
              : null))
      .whereType<int>()
      .toSet();
}

List<Map<String, dynamic>> _transportAssignedGuests(
  Map<String, dynamic> route,
  List<Map<String, dynamic>> guests,
) {
  final assignedIds = _transportAssignedGuestIds(route);
  final byId = {
    for (final guest in guests)
      if (_guestId(guest) != null) _guestId(guest)!: guest,
  };
  final assigned = <Map<String, dynamic>>[];
  for (final id in assignedIds) {
    final fromList = byId[id];
    if (fromList != null) {
      assigned.add(fromList);
      continue;
    }
    final assignment = ((route['assignments'] as List?) ?? [])
        .whereType<Map>()
        .firstWhere(
          (item) =>
              _guestId({'id': item['guest_id']}) == id ||
              (item['guest'] is Map &&
                  _guestId(Map<String, dynamic>.from(item['guest'] as Map)) ==
                      id),
          orElse: () => {},
        );
    if (assignment['guest'] is Map) {
      assigned.add(Map<String, dynamic>.from(assignment['guest'] as Map));
    }
  }
  return assigned;
}

class _TransportAssignedGuestRow extends StatelessWidget {
  final Map<String, dynamic> guest;
  const _TransportAssignedGuestRow({required this.guest});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: UdoDesign.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: UdoDesign.border),
        ),
        child: Row(children: [
          const Icon(Icons.check_circle, color: UdoDesign.sage, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_guestDisplayName(guest),
                style: UdoDesign.sans(size: 13, weight: FontWeight.w800)),
          ),
        ]),
      );
}

/// Real room label if the couple has set one, otherwise the placeholder
/// sequence ("Room 201", "Room 202"...) used before any real numbers exist.
String _roomLabel(Map<String, dynamic> hotel, int index) {
  final labels = hotel['room_labels'];
  if (labels is List && index < labels.length) {
    final label = labels[index]?.toString().trim();
    if (label != null && label.isNotEmpty) return label;
  }
  return 'Room ${201 + index}';
}

List<String> _roomLabels(Map<String, dynamic> hotel) {
  final labels = hotel['room_labels'];
  if (labels is List) {
    final parsed = labels
        .map((label) => label?.toString().trim() ?? '')
        .where((label) => label.isNotEmpty)
        .toList();
    if (parsed.isNotEmpty) return parsed;
  }

  final totalRooms =
      ((hotel['total_rooms_blocked'] ?? hotel['total_rooms'] ?? 0) as num)
          .toInt();
  return List.generate(totalRooms, (index) => _roomLabel(hotel, index));
}

InputDecoration _logisticsSheetInput(String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppTheme.udoCardFill,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );

void _showAccommodationDetailSheet({
  required BuildContext context,
  required Map<String, dynamic> hotel,
  required List<Map<String, dynamic>> guests,
  required LogisticsNotifier notifier,
  required GuestsNotifier guestsNotifier,
}) {
  final totalRooms =
      ((hotel['total_rooms_blocked'] ?? hotel['total_rooms'] ?? 0) as num)
          .toInt();
  final assignedGuests = guests
      .where((guest) => guest['hotel_assignment_id'] == hotel['id'])
      .toList();
  final assignedRooms =
      ((hotel['rooms_assigned'] ?? assignedGuests.length) as num).toInt();
  final available =
      totalRooms > 0 ? (totalRooms - assignedRooms).clamp(0, totalRooms) : 0;
  final rate = hotel['price_per_night'];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(hotel['name']?.toString() ?? 'Hotel block',
                    style: UdoDesign.serif(size: 22, color: UdoDesign.text)),
              ),
              IconButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close)),
            ]),
            const Divider(height: 24),
            _AccommodationInfoRow('Total rooms', '$totalRooms rooms'),
            _AccommodationInfoRow('Assigned',
                '$assignedRooms guest${assignedRooms == 1 ? '' : 's'}'),
            _AccommodationInfoRow(
                'Available', '$available room${available == 1 ? '' : 's'}'),
            if (hotel['check_in_date'] != null)
              _AccommodationInfoRow(
                  'Check-in', udo_dates.formatApiDate(hotel['check_in_date'])),
            if (hotel['check_out_date'] != null)
              _AccommodationInfoRow('Check-out',
                  udo_dates.formatApiDate(hotel['check_out_date'])),
            if (rate != null) _AccommodationInfoRow('Rate', '\$$rate / night'),
            const SizedBox(height: 16),
            Text('Assigned Guests',
                style: UdoDesign.sans(
                    size: 11, weight: FontWeight.w800, color: UdoDesign.muted)),
            const SizedBox(height: 10),
            if (assignedGuests.isEmpty)
              Text('No guests assigned yet.',
                  style: UdoDesign.sans(size: 13, color: UdoDesign.muted))
            else
              for (var i = 0; i < assignedGuests.length; i++)
                _AccommodationGuestRow(
                  guest: assignedGuests[i],
                  roomLabel: assignedGuests[i]['hotel_room_label']
                              ?.toString()
                              .trim()
                              .isNotEmpty ==
                          true
                      ? assignedGuests[i]['hotel_room_label'].toString()
                      : _roomLabel(hotel, i),
                ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                _showAssignAccommodationGuestSheet(
                  context: context,
                  hotel: hotel,
                  guests: guests,
                  notifier: notifier,
                  guestsNotifier: guestsNotifier,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: _guestAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Assign Guest to Room'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                _showAllRoomsSheet(
                    context: context,
                    hotel: hotel,
                    guests: guests,
                    notifier: notifier);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: _guestAccent,
                side: const BorderSide(color: _guestAccent),
              ),
              child: const Text('View All Rooms'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                _showEditRoomLabelsSheet(
                    context: context, hotel: hotel, notifier: notifier);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: _guestAccent,
                side: const BorderSide(color: _guestAccent),
              ),
              child: const Text('Edit Room Labels'),
            ),
          ]),
        ),
      ),
    ),
  );
}

void _showAssignAccommodationGuestSheet({
  required BuildContext context,
  required Map<String, dynamic> hotel,
  required List<Map<String, dynamic>> guests,
  required LogisticsNotifier notifier,
  required GuestsNotifier guestsNotifier,
}) {
  final hotelId = hotel['id'] as int;
  final candidates = guests.where((guest) {
    if (_guestId(guest) == null) return false;
    final assignedHotel = guest['hotel_assignment_id'];
    return assignedHotel == null || assignedHotel == hotelId;
  }).toList();
  final roomLabels = _roomLabels(hotel);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _AssignAccommodationSheet(
      hotel: hotel,
      candidates: candidates,
      roomLabels: roomLabels,
      notifier: notifier,
      guestsNotifier: guestsNotifier,
    ),
  );
}

class _AssignAccommodationSheet extends StatefulWidget {
  final Map<String, dynamic> hotel;
  final List<Map<String, dynamic>> candidates;
  final List<String> roomLabels;
  final LogisticsNotifier notifier;
  final GuestsNotifier guestsNotifier;

  const _AssignAccommodationSheet({
    required this.hotel,
    required this.candidates,
    required this.roomLabels,
    required this.notifier,
    required this.guestsNotifier,
  });

  @override
  State<_AssignAccommodationSheet> createState() =>
      _AssignAccommodationSheetState();
}

class _AssignAccommodationSheetState extends State<_AssignAccommodationSheet> {
  int? _selectedGuestId;
  String? _selectedRoom;
  bool _saving = false;

  Set<String> get _takenRooms => widget.candidates
      .where((guest) =>
          guest['hotel_assignment_id'] == widget.hotel['id'] &&
          guest['hotel_room_label'] != null &&
          _guestId(guest) != _selectedGuestId)
      .map((guest) => guest['hotel_room_label'].toString())
      .toSet();

  @override
  Widget build(BuildContext context) {
    final availableRooms = widget.roomLabels
        .where((room) => !_takenRooms.contains(room) || room == _selectedRoom)
        .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(
              child: Text('Assign guest to room',
                  style: UdoDesign.sans(size: 18, weight: FontWeight.w800)),
            ),
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)),
          ]),
          const SizedBox(height: 12),
          if (widget.candidates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('No guests available to assign to this hotel.',
                  style: UdoDesign.sans(size: 13, color: UdoDesign.muted)),
            )
          else ...[
            DropdownButtonFormField<int>(
              initialValue: _selectedGuestId,
              decoration: _logisticsSheetInput('Guest'),
              isExpanded: true,
              items: [
                for (final guest in widget.candidates)
                  DropdownMenuItem(
                    value: _guestId(guest),
                    child: Text(
                      [
                        _guestDisplayName(guest),
                        if (guest['hotel_room_label'] != null)
                          'Room ${guest['hotel_room_label']}',
                      ].join(' - '),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (id) {
                final guest = widget.candidates
                    .firstWhere((candidate) => _guestId(candidate) == id);
                setState(() {
                  _selectedGuestId = id;
                  _selectedRoom = guest['hotel_room_label']?.toString();
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedRoom,
              decoration: _logisticsSheetInput('Room'),
              isExpanded: true,
              items: [
                for (final room in availableRooms)
                  DropdownMenuItem(value: room, child: Text(room)),
              ],
              onChanged: (room) => setState(() => _selectedRoom = room),
            ),
            if (widget.roomLabels.isEmpty) ...[
              const SizedBox(height: 8),
              Text('Add room numbers to this hotel block first.',
                  style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  _saving || _selectedGuestId == null || _selectedRoom == null
                      ? null
                      : () async {
                          setState(() => _saving = true);
                          final ok = await widget.notifier.assignAccommodation(
                            widget.hotel['id'] as int,
                            _selectedGuestId!,
                            roomLabel: _selectedRoom,
                          );
                          if (ok) await widget.guestsNotifier.refresh();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(ok
                                  ? 'Guest assigned to ${widget.hotel['name'] ?? 'hotel'}, room $_selectedRoom.'
                                  : "Couldn't assign this guest.")));
                          if (ok) {
                            Navigator.pop(context);
                          } else {
                            setState(() => _saving = false);
                          }
                        },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: _guestAccent,
                foregroundColor: Colors.white,
              ),
              child: Text(_saving ? 'Assigning...' : 'Assign room'),
            ),
          ],
        ]),
      ),
    );
  }
}

void _showAllRoomsSheet({
  required BuildContext context,
  required Map<String, dynamic> hotel,
  required List<Map<String, dynamic>> guests,
  required LogisticsNotifier notifier,
}) {
  final assignedGuests = guests
      .where((guest) => guest['hotel_assignment_id'] == hotel['id'])
      .toList();
  final roomLabels = _roomLabels(hotel);
  final roomCount =
      roomLabels.isNotEmpty ? roomLabels.length : assignedGuests.length;
  final guestByRoom = {
    for (final guest in assignedGuests)
      if (guest['hotel_room_label'] != null)
        guest['hotel_room_label'].toString(): guest,
  };

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(
              child: Text('All rooms',
                  style: UdoDesign.sans(size: 18, weight: FontWeight.w800)),
            ),
            if (roomCount > 0)
              IconButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showEditRoomLabelsSheet(
                        context: context, hotel: hotel, notifier: notifier);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit room labels'),
            IconButton(
                onPressed: () => Navigator.pop(sheetContext),
                icon: const Icon(Icons.close)),
          ]),
          const SizedBox(height: 12),
          if (roomCount == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('No rooms have been added to this hotel block.',
                  style: UdoDesign.sans(size: 13, color: UdoDesign.muted)),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: roomCount,
                itemBuilder: (_, index) {
                  final label = roomLabels.isNotEmpty
                      ? roomLabels[index]
                      : _roomLabel(hotel, index);
                  final guest = guestByRoom[label] ??
                      (index < assignedGuests.length
                          ? assignedGuests[index]
                          : null);
                  return _RoomSlotRow(
                    roomLabel: label,
                    guest: guest,
                  );
                },
              ),
            ),
        ]),
      ),
    ),
  );
}

void _showEditRoomLabelsSheet({
  required BuildContext context,
  required Map<String, dynamic> hotel,
  required LogisticsNotifier notifier,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _EditRoomLabelsSheet(hotel: hotel, notifier: notifier),
  );
}

class _EditRoomLabelsSheet extends StatefulWidget {
  final Map<String, dynamic> hotel;
  final LogisticsNotifier notifier;
  const _EditRoomLabelsSheet({required this.hotel, required this.notifier});

  @override
  State<_EditRoomLabelsSheet> createState() => _EditRoomLabelsSheetState();
}

class _EditRoomLabelsSheetState extends State<_EditRoomLabelsSheet> {
  late final List<TextEditingController> _controllers;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final totalRooms = ((widget.hotel['total_rooms_blocked'] ??
            widget.hotel['total_rooms'] ??
            0) as num)
        .toInt();
    final existing = widget.hotel['room_labels'];
    _controllers = List.generate(totalRooms, (i) {
      final label = (existing is List && i < existing.length)
          ? existing[i]?.toString() ?? ''
          : '';
      return TextEditingController(text: label);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final labels = _controllers.map((c) => c.text.trim()).toList();
    final errorMessage = await widget.notifier.updateAccommodation(
        widget.hotel['id'] as int, {'room_labels': labels});
    if (!mounted) return;
    if (errorMessage == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Room labels updated.')));
    } else {
      setState(() {
        _loading = false;
        _error = errorMessage;
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text('Edit Room Labels',
                            style: UdoDesign.sans(
                                size: 18, weight: FontWeight.w800)),
                      ),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close)),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                        'Add the real room numbers once the hotel assigns them — guests currently show placeholder room numbers until you do.',
                        style: UdoDesign.sans(
                            size: 12.5, color: UdoDesign.muted, height: 1.35)),
                    const SizedBox(height: 14),
                    if (_controllers.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                            'Set a total room count on this hotel block first.',
                            style: UdoDesign.sans(
                                size: 13, color: UdoDesign.muted)),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _controllers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, index) => _GField(
                              'Room ${201 + index}', _controllers[index]),
                        ),
                      ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.udoCrimson))
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          backgroundColor: _guestAccent,
                          foregroundColor: Colors.white),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Save Labels'),
                    ),
                  ]),
            ),
          ),
        ),
      );
}

class _AccommodationInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _AccommodationInfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          Expanded(
            child: Text(label.toUpperCase(),
                style: UdoDesign.sans(
                    size: 10, color: UdoDesign.muted, weight: FontWeight.w800)),
          ),
          Text(value,
              style: UdoDesign.sans(size: 12.5, weight: FontWeight.w800)),
        ]),
      );
}

class _AccommodationGuestRow extends StatelessWidget {
  final Map<String, dynamic> guest;
  final String roomLabel;
  const _AccommodationGuestRow({required this.guest, required this.roomLabel});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: UdoDesign.blue.withValues(alpha: 0.12),
            child: Text(_initials(guest),
                style: UdoDesign.sans(
                    size: 10, weight: FontWeight.w800, color: UdoDesign.blue)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_guestDisplayName(guest),
                style: UdoDesign.sans(size: 13, weight: FontWeight.w700)),
          ),
          Text(roomLabel,
              style: UdoDesign.sans(size: 11.5, color: UdoDesign.muted)),
        ]),
      );
}

class _RoomSlotRow extends StatelessWidget {
  final String roomLabel;
  final Map<String, dynamic>? guest;
  const _RoomSlotRow({required this.roomLabel, required this.guest});

  @override
  Widget build(BuildContext context) => UdoCard(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          const Icon(Icons.king_bed_outlined, color: _guestAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(roomLabel,
                  style: UdoDesign.sans(size: 13, weight: FontWeight.w800)),
              Text(guest == null ? 'Available' : _guestDisplayName(guest!),
                  style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
            ]),
          ),
          UdoBadge(
              label: guest == null ? 'Open' : 'Assigned',
              color: guest == null ? UdoDesign.blue : UdoDesign.sage),
        ]),
      );
}

class _LogisticsEmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _LogisticsEmptyCard({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        onTap: onAction,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: _guestAccent),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: UdoDesign.sans(size: 14, weight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(body,
                      style:
                          UdoDesign.sans(size: 12.5, color: UdoDesign.muted)),
                ])),
          ]),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            _AddRouteBottomButton(label: actionLabel!, onTap: onAction!),
          ],
        ]),
      );
}

class _AddRouteBottomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddRouteBottomButton({this.label = 'Add Route', required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: UdoDesign.border),
            ),
            child: Row(children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: UdoDesign.bg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Icon(Icons.add, size: 17, color: _guestAccent),
              ),
              const SizedBox(width: 10),
              Text(label,
                  style: UdoDesign.sans(
                      size: 15, weight: FontWeight.w800, color: _guestAccent)),
            ]),
          ),
        ),
      );
}

class _AccommodationCard extends StatelessWidget {
  final Map<String, dynamic> h;
  const _AccommodationCard({required this.h});

  @override
  Widget build(BuildContext context) {
    final totalRooms = (h['total_rooms_blocked'] ?? 0) as num;
    final bookedRooms = (h['rooms_assigned'] ?? 0) as num;
    final progress =
        totalRooms > 0 ? (bookedRooms / totalRooms).clamp(0.0, 1.0) : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.udoBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.hotel_outlined, color: AppTheme.udoGreen, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(h['name'] as String? ?? '—',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500))),
          if (h['price_per_night'] != null)
            Text('\$${h['price_per_night']}/night',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.udoGreen,
                    fontWeight: FontWeight.w500)),
        ]),
        if ((h['address'] as String?)?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(h['address'] as String,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary)),
        ],
        const SizedBox(height: 8),
        Row(children: [
          if (h['check_in_date'] != null)
            _LogBadge(
                'Check-in: ${udo_dates.formatApiDate(h['check_in_date'])}',
                Colors.blue),
          if (h['check_in_date'] != null) const SizedBox(width: 6),
          if (h['check_out_date'] != null)
            _LogBadge(
                'Check-out: ${udo_dates.formatApiDate(h['check_out_date'])}',
                Colors.orange),
        ]),
        if (totalRooms > 0) ...[
          const SizedBox(height: 8),
          Text('$bookedRooms of $totalRooms rooms booked',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
              value: progress.toDouble(),
              backgroundColor: AppTheme.udoBorder,
              color: AppTheme.udoGreen,
              borderRadius: BorderRadius.circular(4),
              minHeight: 6),
        ],
      ]),
    );
  }
}

class _TransportCard extends StatelessWidget {
  final Map<String, dynamic> t;
  const _TransportCard({required this.t});

  @override
  Widget build(BuildContext context) {
    final seats = (t['capacity'] ?? 0) as num;
    final assignments = (t['assignments'] as List?) ?? [];
    final booked = assignments.length;
    final progress = seats > 0 ? (booked / seats).clamp(0.0, 1.0) : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.udoBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.directions_bus_outlined,
              color: AppTheme.udoGreen, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(t['name'] as String? ?? '—',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500))),
          if ((t['type'] as String?)?.isNotEmpty == true)
            _LogBadge(t['type'] as String, Colors.indigo),
        ]),
        if ((t['pickup_location'] as String?)?.isNotEmpty == true ||
            (t['dropoff_location'] as String?)?.isNotEmpty == true) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.arrow_forward,
                size: 12, color: AppTheme.udoTextSecondary),
            const SizedBox(width: 4),
            Expanded(
                child: Text(
                    '${t['pickup_location'] ?? ''} → ${t['dropoff_location'] ?? ''}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.udoTextSecondary))),
          ]),
        ],
        if (seats > 0) ...[
          const SizedBox(height: 8),
          Text('$booked of $seats seats taken',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
              value: progress.toDouble(),
              backgroundColor: AppTheme.udoBorder,
              color: AppTheme.udoGreen,
              borderRadius: BorderRadius.circular(4),
              minHeight: 6),
        ],
      ]),
    );
  }
}

class _LogBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _LogBadge(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w500)));
}

class _ArrivalStat extends StatelessWidget {
  final String value, label;
  final Color color;
  final VoidCallback? onTap;
  const _ArrivalStat(this.value, this.label, this.color, {this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
          child: GestureDetector(
        onTap: onTap,
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.udoTextSecondary),
                textAlign: TextAlign.center),
            if (onTap != null)
              const Icon(Icons.chevron_right,
                  size: 12, color: AppTheme.udoTextSecondary),
          ]),
        ]),
      ));
}

class AddHotelModal extends StatefulWidget {
  final LogisticsNotifier notifier;
  const AddHotelModal({super.key, required this.notifier});
  @override
  State<AddHotelModal> createState() => _AddHotelModalState();
}

class _AddHotelModalState extends State<AddHotelModal> {
  final _name = TextEditingController();
  final _rate = TextEditingController();
  final _rooms = TextEditingController();
  final _address = TextEditingController();
  final _bookingCode = TextEditingController();
  final _bookingUrl = TextEditingController();
  final _contactName = TextEditingController();
  final _contactPhone = TextEditingController();
  final _notes = TextEditingController();
  DateTime? _checkIn;
  DateTime? _checkOut;
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text('Add hotel block',
                      style: UdoDesign.serif(size: 22, color: UdoDesign.text)),
                ),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero),
              ]),
              const SizedBox(height: 6),
              Text(
                  'Create a real accommodation option guests can be assigned to.',
                  style: UdoDesign.sans(
                      size: 12.5, color: UdoDesign.muted, height: 1.35)),
              const SizedBox(height: 16),
              PlaceSearchField(
                controller: _name,
                search: widget.notifier.searchPlaces,
                fetchDetails: widget.notifier.fetchPlaceDetails,
                hint: 'Hotel name',
                placeType: 'lodging',
                icon: Icons.hotel_outlined,
                onPlaceSelected: (place) {
                  final address = place['address']?.toString();
                  final phone = place['phone']?.toString();
                  if (address != null && address.isNotEmpty)
                    _address.text = address;
                  if (phone != null &&
                      phone.isNotEmpty &&
                      _contactPhone.text.trim().isEmpty) {
                    _contactPhone.text = phone;
                  }
                },
              ),
              const SizedBox(height: 10),
              _GField('Address', _address),
              const SizedBox(height: 10),
              _GField('Room numbers / labels', _rooms,
                  hint: '101, 102, 103, King Suite, Accessible Room'),
              const SizedBox(height: 10),
              _GField('Rate/night', _rate,
                  type: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: _DatePickField(
                  label: 'Check-in',
                  value: _checkIn,
                  onPick: (date) => setState(() => _checkIn = date),
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: _DatePickField(
                  label: 'Check-out',
                  value: _checkOut,
                  onPick: (date) => setState(() => _checkOut = date),
                )),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _GField('Booking code', _bookingCode)),
                const SizedBox(width: 10),
                Expanded(child: _GField('Booking link', _bookingUrl)),
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
              _GField('Notes', _notes),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.udoCrimson))
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    backgroundColor: _guestAccent,
                    foregroundColor: Colors.white),
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.hotel_outlined, size: 18),
                label: Text(_loading ? 'Adding hotel...' : 'Add hotel'),
              ),
            ]),
          ),
        ),
      );

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) return;
    final roomLabels = _rooms.text
        .split(',')
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList();
    setState(() {
      _loading = true;
      _error = null;
    });
    final errorMessage = await widget.notifier.addAccommodation({
      'name': _name.text.trim(),
      if (_address.text.trim().isNotEmpty) 'address': _address.text.trim(),
      if (roomLabels.isNotEmpty) 'total_rooms': roomLabels.length,
      if (roomLabels.isNotEmpty) 'room_labels': roomLabels,
      if (_rate.text.trim().isNotEmpty)
        'price_per_night': double.tryParse(_rate.text.trim()),
      if (_checkIn != null) 'check_in_date': _dateOnly(_checkIn!),
      if (_checkOut != null) 'check_out_date': _dateOnly(_checkOut!),
      if (_bookingCode.text.trim().isNotEmpty)
        'booking_code': _bookingCode.text.trim(),
      if (_bookingUrl.text.trim().isNotEmpty)
        'booking_url': _bookingUrl.text.trim(),
      if (_contactName.text.trim().isNotEmpty)
        'contact_name': _contactName.text.trim(),
      if (_contactPhone.text.trim().isNotEmpty)
        'contact_phone': _contactPhone.text.trim(),
      if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
    });
    if (!mounted) return;
    if (errorMessage == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Hotel block added.')));
      Navigator.pop(context);
    } else {
      setState(() {
        _loading = false;
        _error = errorMessage;
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _rate.dispose();
    _rooms.dispose();
    _address.dispose();
    _bookingCode.dispose();
    _bookingUrl.dispose();
    _contactName.dispose();
    _contactPhone.dispose();
    _notes.dispose();
    super.dispose();
  }
}

String _dateOnly(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class _DatePickField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPick;

  const _DatePickField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 3650)),
          );
          if (picked != null) onPick(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            hintText: label,
            hintStyle: UdoDesign.sans(size: 14, color: UdoDesign.muted),
            filled: true,
            fillColor: AppTheme.udoCardFill,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          child: Text(value == null ? label : _dateOnly(value!),
              style: UdoDesign.sans(
                  size: 13.5,
                  color: value == null ? UdoDesign.muted : UdoDesign.text)),
        ),
      );
}

class AddTransportModal extends StatefulWidget {
  final LogisticsNotifier notifier;
  const AddTransportModal({super.key, required this.notifier});
  @override
  State<AddTransportModal> createState() => _AddTransportModalState();
}

class _AddTransportModalState extends State<AddTransportModal> {
  final _name = TextEditingController();
  final _pickup = TextEditingController();
  final _drop = TextEditingController();
  final _seats = TextEditingController();
  final _company = TextEditingController();
  final _driverName = TextEditingController();
  final _driverPhone = TextEditingController();
  String _type = 'car';
  bool _loading = false;
  String? _error;

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
                            child: Text('Add route',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600))),
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            padding: EdgeInsets.zero),
                      ]),
                      const SizedBox(height: 14),
                      _GField('Route name', _name),
                      const SizedBox(height: 10),
                      Wrap(spacing: 6, children: [
                        for (final t in ['car', 'van', 'minibus', 'coach'])
                          ChoiceChip(
                            label:
                                Text(t, style: const TextStyle(fontSize: 12)),
                            selected: _type == t,
                            onSelected: (_) => setState(() => _type = t),
                            selectedColor: AppTheme.udoGreen,
                            labelStyle: TextStyle(
                                color: _type == t
                                    ? Colors.white
                                    : AppTheme.udoTextPrimary),
                            side: BorderSide(
                                color: _type == t
                                    ? AppTheme.udoGreen
                                    : AppTheme.udoBorder),
                          ),
                      ]),
                      const SizedBox(height: 10),
                      PlaceSearchField(
                        controller: _pickup,
                        search: widget.notifier.searchPlaces,
                        fetchDetails: widget.notifier.fetchPlaceDetails,
                        hint: 'Pickup location',
                        icon: Icons.location_on_outlined,
                        useFullDescriptionOnSelect: true,
                        onPlaceSelected: (place) {
                          final address = place['address']?.toString();
                          final name = place['name']?.toString();
                          _pickup.text = address?.isNotEmpty == true
                              ? address!
                              : name ?? _pickup.text;
                        },
                      ),
                      const SizedBox(height: 10),
                      PlaceSearchField(
                        controller: _drop,
                        search: widget.notifier.searchPlaces,
                        fetchDetails: widget.notifier.fetchPlaceDetails,
                        hint: 'Drop-off location',
                        icon: Icons.flag_outlined,
                        useFullDescriptionOnSelect: true,
                        onPlaceSelected: (place) {
                          final address = place['address']?.toString();
                          final name = place['name']?.toString();
                          _drop.text = address?.isNotEmpty == true
                              ? address!
                              : name ?? _drop.text;
                        },
                      ),
                      const SizedBox(height: 10),
                      _GField('Seats', _seats, type: TextInputType.number),
                      const SizedBox(height: 10),
                      _GField('Company name', _company),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: _GField('Driver name', _driverName)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _GField('Driver phone', _driverPhone,
                                type: TextInputType.phone)),
                      ]),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(_error!,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.udoCrimson))
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            backgroundColor: AppTheme.udoGreen,
                            foregroundColor: Colors.white),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Add Route'),
                      ),
                    ]))),
      );

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final errorMessage = await widget.notifier.addTransport({
      'name': _name.text.trim(),
      'type': _type,
      if (_pickup.text.trim().isNotEmpty)
        'pickup_location': _pickup.text.trim(),
      if (_drop.text.trim().isNotEmpty) 'dropoff_location': _drop.text.trim(),
      if (_seats.text.trim().isNotEmpty)
        'capacity': int.tryParse(_seats.text.trim()) ?? 0,
      if (_company.text.trim().isNotEmpty) 'company_name': _company.text.trim(),
      if (_driverName.text.trim().isNotEmpty)
        'driver_name': _driverName.text.trim(),
      if (_driverPhone.text.trim().isNotEmpty)
        'driver_phone': _driverPhone.text.trim(),
    });
    if (!mounted) return;
    if (errorMessage == null) {
      Navigator.pop(context);
    } else {
      setState(() {
        _loading = false;
        _error = errorMessage;
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _pickup.dispose();
    _drop.dispose();
    _seats.dispose();
    _company.dispose();
    _driverName.dispose();
    _driverPhone.dispose();
    super.dispose();
  }
}

Widget _GField(String label, TextEditingController ctrl,
        {TextInputType? type, String? hint}) =>
    TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle:
                const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13),
            filled: true,
            fillColor: AppTheme.udoCardFill,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12)));

// ── SHARED ─────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.udoBorder)),
        child: child,
      );
}
