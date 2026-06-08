import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/live_status_model.dart';
import '../providers/live_provider.dart';
import '../../../guests/data/models/guest_model.dart';
import '../../../guests/presentation/providers/guests_provider.dart';
import '../../../guests/domain/guests_state.dart';
import '../../../guests/presentation/providers/messages_provider.dart';

class LiveScreen extends ConsumerWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveNotifierProvider);

    if (state.loadStatus == LiveLoadStatus.loading) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.pinkGradientStart)),
      );
    }

    if (state.loadStatus == LiveLoadStatus.error || state.status == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.grey300, size: 44),
            const SizedBox(height: 12),
            Text('Could not load Live',
                style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700)),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () =>
                  ref.read(liveNotifierProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ]),
        ),
      );
    }

    final s = state.status!;
    final days = s.daysUntil;

    // Pre-wedding: more than 3 days away
    if (!s.isLive && (days == null || days > 3)) {
      return _PreWeddingView(status: s);
    }

    // Final countdown: 0–3 days or live
    return _LiveView(status: s, isLive: s.isLive);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRE-WEDDING VIEW — countdown + upcoming events + go-live CTA
// ─────────────────────────────────────────────────────────────────────────────

class _PreWeddingView extends ConsumerWidget {
  const _PreWeddingView({required this.status});
  final LiveStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = status.daysUntil;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Text('Live',
            style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.grey700)),
      ),
      body: RefreshIndicator(
        color: AppColors.pinkGradientStart,
        onRefresh: () => ref.read(liveNotifierProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
          children: [
            // Countdown hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.pinkGradientStart, AppColors.pinkGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(children: [
                Text(
                  days != null ? '$days' : '—',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 72,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1),
                ),
                Text(
                  days == 1 ? 'day to go' : 'days to go',
                  style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.85)),
                ),
                if (status.venueName != null) ...[
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(status.venueName!,
                        style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8))),
                  ]),
                ],
              ]),
            ),
            const SizedBox(height: 20),

            // Stats row
            Row(children: [
              _MiniStat(
                  label: 'Attending', value: '${status.attendingCount}',
                  color: AppColors.teal),
              const SizedBox(width: 10),
              _MiniStat(
                  label: 'Total guests', value: '${status.totalGuests}',
                  color: AppColors.grey600),
              const SizedBox(width: 10),
              _MiniStat(
                  label: 'Days away',
                  value: days != null ? '$days' : '—',
                  color: AppColors.pinkGradientStart),
            ]),
            const SizedBox(height: 20),

            // Upcoming events
            if (status.upcomingEvents.isNotEmpty) ...[
              _SectionLabel('UPCOMING THIS WEEK'),
              const SizedBox(height: 8),
              ...status.upcomingEvents.map((e) => _UpcomingEventRow(event: e)),
              const SizedBox(height: 16),
            ],

            // Go live CTA (when 3 days or fewer)
            if (status.daysUntil != null && status.daysUntil! <= 3)
              _GoLiveBanner(
                onTap: () => ref.read(liveNotifierProvider.notifier).activate(),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIVE VIEW — day-of UX with 3 tabs
// ─────────────────────────────────────────────────────────────────────────────

class _LiveView extends ConsumerWidget {
  const _LiveView({required this.status, required this.isLive});
  final LiveStatus status;
  final bool isLive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          surfaceTintColor: AppColors.white,
          titleSpacing: 20,
          title: Row(children: [
            Text('Live',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey700)),
            const SizedBox(width: 8),
            if (isLive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text('LIVE',
                      style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5)),
                ]),
              ),
            const Spacer(),
            if (isLive)
              TextButton(
                onPressed: () => _confirmEndLive(context, ref),
                child: Text('End live',
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.grey500)),
              ),
          ]),
          bottom: TabBar(
            labelColor: AppColors.pinkGradientStart,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: AppColors.pinkGradientStart,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2,
            dividerColor: AppColors.grey200,
            labelStyle:
                GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle:
                GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'Schedule'),
              Tab(text: 'Check-in'),
              Tab(text: 'Updates'),
            ],
          ),
        ),
        body: TabBarView(children: [
          _ScheduleTab(status: status),
          _CheckInTab(status: status),
          _UpdatesTab(),
        ]),
        floatingActionButton: !isLive
            ? FloatingActionButton.extended(
                onPressed: () =>
                    ref.read(liveNotifierProvider.notifier).activate(),
                backgroundColor: AppColors.pinkGradientStart,
                icon: const Icon(Icons.radio_button_checked_rounded,
                    color: Colors.white),
                label: Text('Go Live',
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              )
            : null,
      ),
    );
  }

  void _confirmEndLive(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('End live mode?',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w700, fontSize: 17)),
        content: Text(
            'This will return your wedding to planning mode.',
            style: GoogleFonts.dmSans(fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(liveNotifierProvider.notifier).deactivate();
            },
            child: const Text('End live',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCHEDULE TAB
// ─────────────────────────────────────────────────────────────────────────────

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({required this.status});
  final LiveStatus status;

  @override
  Widget build(BuildContext context) {
    if (status.dayEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.schedule_rounded,
                size: 48, color: AppColors.grey300),
            const SizedBox(height: 14),
            Text('No schedule yet',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey700)),
            const SizedBox(height: 6),
            Text('Add timeline events in the Plan tab for your wedding day.',
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: AppColors.grey500, height: 1.5),
                textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    final now = TimeOfDay.now();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemCount: status.dayEvents.length,
      itemBuilder: (_, i) {
        final event = status.dayEvents[i];
        final isPast = _isEventPast(event.time, now);
        final isCurrent = i < status.dayEvents.length - 1 &&
            !isPast &&
            _isEventPast(status.dayEvents[i + 1].time, now);

        return _ScheduleRow(
          event: event,
          isPast: isPast,
          isCurrent: isCurrent,
          isLast: i == status.dayEvents.length - 1,
        );
      },
    );
  }

  bool _isEventPast(String? timeStr, TimeOfDay now) {
    if (timeStr == null) return false;
    try {
      final parts = timeStr.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1].split(' ')[0]);
      final isPm = timeStr.toLowerCase().contains('pm') && h != 12;
      final hour = isPm ? h + 12 : (timeStr.toLowerCase().contains('am') && h == 12 ? 0 : h);
      return hour < now.hour || (hour == now.hour && m < now.minute);
    } catch (_) {
      return false;
    }
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.event,
    required this.isPast,
    required this.isCurrent,
    required this.isLast,
  });

  final LiveEvent event;
  final bool isPast;
  final bool isCurrent;
  final bool isLast;

  static const _categoryColors = {
    'Ceremony': AppColors.pinkGradientStart,
    'Venue': AppColors.forestGreen,
    'Vendor': AppColors.teal,
    'Attire': AppColors.dustyRose,
  };

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[event.category] ?? const Color(0xFF8B5CF6);

    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Time column
        SizedBox(
          width: 56,
          child: Column(children: [
            Container(
              width: 40,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.pinkGradientStart.withValues(alpha: 0.1)
                    : isPast
                        ? AppColors.grey100
                        : AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
                border: isCurrent
                    ? Border.all(color: AppColors.pinkGradientStart, width: 1.5)
                    : null,
              ),
              child: Text(
                event.time ?? '—',
                style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isCurrent
                        ? AppColors.pinkGradientStart
                        : isPast
                            ? AppColors.grey400
                            : AppColors.grey600,
                    height: 1.2),
                textAlign: TextAlign.center,
              ),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  width: 1.5,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: isPast ? AppColors.grey200 : AppColors.grey200,
                ),
              ),
          ]),
        ),
        const SizedBox(width: 10),

        // Event card
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.blushLight : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent
                    ? AppColors.pinkGradientStart.withValues(alpha: 0.3)
                    : AppColors.grey100,
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(event.title,
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPast
                              ? AppColors.grey400
                              : AppColors.grey700,
                          decoration:
                              isPast ? TextDecoration.lineThrough : null)),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.pinkGradientStart,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Now',
                        style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
              ]),
              if (event.location != null) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                      size: 11, color: AppColors.grey400),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(event.location!,
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppColors.grey500),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ],
              if (event.category != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(event.category!,
                      style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ),
              ],
            ]),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHECK-IN TAB
// ─────────────────────────────────────────────────────────────────────────────

class _CheckInTab extends ConsumerWidget {
  const _CheckInTab({required this.status});
  final LiveStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guestState = ref.watch(guestsListNotifierProvider);
    final liveState = ref.watch(liveNotifierProvider);
    final checkedIn = liveState.status?.checkedInCount ?? 0;
    final attending = liveState.status?.attendingCount ?? 0;

    return Column(children: [
      // Header with count
      Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.grey200)),
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$checkedIn checked in',
                  style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey700)),
              Text('of $attending attending',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.grey500)),
            ]),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: CircularProgressIndicator(
                  value: attending > 0 ? checkedIn / attending : 0,
                  strokeWidth: 5,
                  backgroundColor: AppColors.grey200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.teal),
                ),
              ),
              Text(
                attending > 0
                    ? '${(checkedIn / attending * 100).round()}%'
                    : '—',
                style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.teal),
              ),
            ],
          ),
        ]),
      ),

      // Guest list
      Expanded(
        child: guestState.when(
          loading: () => const Center(
              child: CircularProgressIndicator(
                  color: AppColors.pinkGradientStart)),
          error: (e) => Center(
              child: Text(e,
                  style:
                      GoogleFonts.dmSans(color: AppColors.grey500))),
          loaded: (guests, __, ___, ____) {
            final attending_ =
                guests.where((g) => g.rsvpStatus == 'attending').toList()
                  ..sort((a, b) =>
                      (a.checkedInAt == null ? 1 : 0)
                          .compareTo(b.checkedInAt == null ? 1 : 0));

            if (attending_.isEmpty) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.how_to_reg_rounded,
                      size: 44, color: AppColors.grey300),
                  const SizedBox(height: 12),
                  Text('No confirmed guests yet',
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey700)),
                ]),
              );
            }

            return RefreshIndicator(
              color: AppColors.pinkGradientStart,
              onRefresh: () =>
                  ref.read(liveNotifierProvider.notifier).refresh(),
              child: ListView.builder(
                padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: attending_.length,
                itemBuilder: (_, i) {
                  final g = attending_[i];
                  final isBusy =
                      liveState.busyGuestIds.contains(g.id);
                  return _CheckInRow(
                    guest: g,
                    isBusy: isBusy,
                    onCheckIn: () => ref
                        .read(liveNotifierProvider.notifier)
                        .checkIn(g.id),
                  );
                },
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class _CheckInRow extends StatelessWidget {
  const _CheckInRow({
    required this.guest,
    required this.isBusy,
    required this.onCheckIn,
  });

  final GuestModel guest;
  final bool isBusy;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final checked = guest.checkedInAt != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: checked
            ? const Color(0xFFE8F7F5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: checked
              ? AppColors.teal.withValues(alpha: 0.3)
              : AppColors.grey100,
        ),
      ),
      child: Row(children: [
        // Avatar
        CircleAvatar(
          radius: 18,
          backgroundColor: checked
              ? AppColors.teal.withValues(alpha: 0.15)
              : AppColors.blushLight,
          child: Text(
            _initials(guest.fullName),
            style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: checked
                    ? AppColors.teal
                    : AppColors.pinkGradientStart),
          ),
        ),
        const SizedBox(width: 12),

        // Name
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(guest.fullName,
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700)),
            if (guest.group != null)
              Text(guest.group!,
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: AppColors.grey500)),
          ]),
        ),

        // Check-in button or check
        if (checked)
          Row(children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.teal, size: 20),
            const SizedBox(width: 4),
            Text('In',
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal)),
          ])
        else
          GestureDetector(
            onTap: isBusy ? null : onCheckIn,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.pinkGradientStart,
                borderRadius: BorderRadius.circular(20),
              ),
              child: isBusy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Check in',
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
            ),
          ),
      ]),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UPDATES TAB — live announcements
// ─────────────────────────────────────────────────────────────────────────────

class _UpdatesTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_UpdatesTab> createState() => _UpdatesTabState();
}

class _UpdatesTabState extends ConsumerState<_UpdatesTab> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Re-use messages provider for day-of updates (in_app channel)
    return Column(children: [
      // Quick announce bar
      Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.grey200)),
          color: AppColors.white,
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppColors.grey700),
              decoration: InputDecoration(
                hintText: 'Announce something to all guests…',
                hintStyle:
                    GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey400),
                filled: true,
                fillColor: AppColors.grey100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sending ? null : _send,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.pinkGradientStart,
                shape: BoxShape.circle,
              ),
              child: _sending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
            ),
          ),
        ]),
      ),

      // Live activity feed
      Expanded(child: _ActivityFeed()),
    ]);
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      final ok = await ref.read(messagesNotifierProvider.notifier).send(
            body: text,
            channel: 'in_app',
            recipientFilter: const {'type': 'all'},
          );
      if (mounted) {
        if (ok) {
          _ctrl.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Announcement sent to all guests',
                  style: GoogleFonts.dmSans(fontSize: 13)),
              backgroundColor: AppColors.teal,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to send'),
                backgroundColor: Colors.redAccent),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Text(value,
              style: GoogleFonts.dmSans(
                  fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppColors.grey500)),
        ]),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(label,
      style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.grey500,
          letterSpacing: 0.8));
}

class _UpcomingEventRow extends StatelessWidget {
  const _UpcomingEventRow({required this.event});
  final LiveEvent event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(children: [
          const Icon(Icons.event_rounded,
              size: 16, color: AppColors.grey400),
          const SizedBox(width: 10),
          Expanded(
            child: Text(event.title,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey700)),
          ),
          if (event.eventDate != null)
            Text(_formatDate(event.eventDate!),
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppColors.grey400)),
        ]),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month]} ${dt.day}';
    } catch (_) {
      return iso;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVITY FEED — polls every 15 s, shows check-ins, RSVPs, announcements
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityFeed extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(liveActivitiesProvider);

    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.pinkGradientStart),
      ),
      error: (_, __) => _emptyFeed(),
      data: (activities) {
        if (activities.isEmpty) return _emptyFeed();
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          itemCount: activities.length,
          itemBuilder: (_, i) => _ActivityRow(activity: activities[i]),
        );
      },
    );
  }

  Widget _emptyFeed() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.campaign_outlined, size: 44, color: AppColors.grey300),
        const SizedBox(height: 12),
        Text('No activity yet',
            style: GoogleFonts.playfairDisplay(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.grey700)),
        const SizedBox(height: 6),
        Text(
          'Check-ins, RSVPs, and announcements will appear here as they happen.',
          style: GoogleFonts.dmSans(
              fontSize: 13, color: AppColors.grey500, height: 1.5),
          textAlign: TextAlign.center,
        ),
      ]),
    ),
  );
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});
  final LiveActivity activity;

  IconData get _icon => switch (activity.type) {
    'check_in'     => Icons.how_to_reg_rounded,
    'rsvp'         => Icons.favorite_rounded,
    'announcement' => Icons.campaign_rounded,
    _              => Icons.circle_outlined,
  };

  Color get _color => switch (activity.type) {
    'check_in'     => AppColors.teal,
    'rsvp'         => AppColors.pinkGradientStart,
    'announcement' => const Color(0xFF8B5CF6),
    _              => AppColors.grey400,
  };

  @override
  Widget build(BuildContext context) {

    final color = _color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Icon circle
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey700),
                children: [
                  TextSpan(
                    text: activity.actorName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: '  ${activity.description}'),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _relativeTime(activity.occurredAt),
              style: AppTypography.caption,
            ),
          ]),
        ),
      ]),
    );
  }

  String _relativeTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }
}

class _GoLiveBanner extends StatelessWidget {
  const _GoLiveBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.pinkGradientStart, AppColors.pinkGradientEnd],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          const Icon(Icons.radio_button_checked_rounded,
              color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Ready to go live?',
                  style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              Text('Activate live mode for day-of coordination.',
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85))),
            ]),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white, size: 16),
        ]),
      ),
    );
  }
}
