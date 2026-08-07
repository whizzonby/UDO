import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/udo_design_system.dart';
import '../../../more/presentation/providers/more_operations_provider.dart';
import '../../../wedding_party/presentation/providers/wedding_party_provider.dart';
import '../../../wedding_party/presentation/screens/wedding_party_screen.dart'
    show BuzzComposerSheet;
import '../providers/live_provider.dart';

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

String _timeAgo(String? iso) {
  if (iso == null) return '';
  final d = DateTime.tryParse(iso);
  if (d == null) return '';
  final diff = DateTime.now().difference(d);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  return '${diff.inDays} d ago';
}

String _countdownTo(Map<String, dynamic> item) {
  final target = _eventStartAt(item);
  if (target == null) return '';
  final diff = target.difference(DateTime.now());
  if (diff.inSeconds.abs() < 60) return 'now';
  if (diff.isNegative) return 'now';
  return 'in ${_durationShort(diff)}';
}

/// Live-ticking version of [_countdownTo] — once under 24h to the event,
/// shows a second-precision HH:MM:SS clock instead of a rounded string.
String _liveCountdownTo(Map<String, dynamic> item) {
  final target = _eventStartAt(item);
  if (target == null) return '';
  final diff = target.difference(DateTime.now());
  if (diff.inSeconds.abs() < 60) return 'now';
  if (diff.isNegative) return 'started ${_durationShort(diff.abs())} ago';
  return 'in ${_durationShort(diff)}';
}

DateTime? _eventStartAt(Map<String, dynamic> item) {
  final dateStr = item['event_date'] as String?;
  final startTime = item['start_time'] as String?;
  if (dateStr == null || startTime == null) return null;
  final date = DateTime.tryParse(dateStr);
  if (date == null) return null;
  return _combineDateAndTime(date, startTime);
}

DateTime? _eventEndAt(Map<String, dynamic> item) {
  final dateStr = item['event_date'] as String?;
  final date = dateStr == null ? null : DateTime.tryParse(dateStr);
  if (date == null) return null;
  final endTime = item['end_time'] as String?;
  if (endTime != null && endTime.isNotEmpty) {
    return _combineDateAndTime(date, endTime);
  }
  final start = _eventStartAt(item);
  if (start == null) return null;
  final minutes = (item['duration_minutes'] as num?)?.toInt() ?? 30;
  return start.add(Duration(minutes: minutes));
}

DateTime _combineDateAndTime(DateTime date, String time) {
  final parts = time.split(':');
  return DateTime(date.year, date.month, date.day, int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
}

String _durationShort(Duration duration) {
  final totalSeconds = duration.inSeconds.abs();
  if (totalSeconds < 60) return '${totalSeconds}s';
  final days = duration.inDays.abs();
  if (days > 0) return '$days day${days == 1 ? '' : 's'}';
  final hours = duration.inHours.abs();
  final minutes = duration.inMinutes.abs() % 60;
  if (hours > 0) {
    return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
  }
  return '${minutes}m';
}

String _currentEventTiming(Map<String, dynamic> item) {
  final now = DateTime.now();
  final start = _eventStartAt(item);
  final end = _eventEndAt(item);
  if (start == null) return '';
  if (now.isBefore(start))
    return 'Starts in ${_durationShort(start.difference(now))}';
  if (end != null && now.isBefore(end)) {
    return 'Started ${_durationShort(now.difference(start))} ago';
  }
  return 'Ended ${_durationShort(now.difference(end ?? start))} ago';
}

Future<void> _launchTel(BuildContext context, String? phone) async {
  if (phone == null || phone.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on file.')));
    return;
  }
  await launchUrl(Uri.parse('tel:$phone'));
}

Future<void> _launchSms(BuildContext context, String? phone) async {
  if (phone == null || phone.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on file.')));
    return;
  }
  await launchUrl(Uri.parse('sms:$phone'));
}

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});
  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  Timer? _autoRefresh;
  bool _drawerOpen = false;

  static const _pages = [
    _LivePageMeta('Mission Control', Icons.radar_outlined),
    _LivePageMeta('Timeline', Icons.timeline_outlined),
    _LivePageMeta('Locations', Icons.map_outlined),
    _LivePageMeta('Weather', Icons.wb_sunny_outlined),
    _LivePageMeta('Broadcast', Icons.campaign_outlined),
    _LivePageMeta('Team', Icons.groups_2_outlined),
    _LivePageMeta('Emergency', Icons.emergency_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _pages.length, vsync: this);
    _tabs.addListener(() {
      if (mounted) setState(() {});
    });
    _autoRefresh = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) ref.read(liveProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _autoRefresh?.cancel();
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveProvider);
    final notifier = ref.read(liveProvider.notifier);

    return Scaffold(
      backgroundColor: UdoDesign.bg,
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: UdoDesign.live))
          : Stack(
              children: [
                Column(
                  children: [
                    _LiveHeader(
                      title: _pages[_tabs.index].title,
                      onMenuTap: () => setState(() => _drawerOpen = true),
                      onRefresh: notifier.refresh,
                      onBroadcast: () {
                        if (_tabs.index == 1 || _tabs.index == 2) {
                          context.push('/plan?section=timeline');
                        } else if (_tabs.index == 3) {
                          context.push('/plan?section=details');
                        } else {
                          _tabs.animateTo(4);
                        }
                      },
                    ),
                    if (state.isOffline)
                      _StaleLiveBanner(
                          cachedAt: state.cachedAt,
                          onRefresh: notifier.refresh),
                    Expanded(
                      child: TabBarView(
                        controller: _tabs,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          RefreshIndicator(
                              onRefresh: notifier.refresh,
                              child: _TodayTab(
                                  state: state,
                                  onUpdatesTap: () => _tabs.animateTo(4))),
                          RefreshIndicator(
                              onRefresh: notifier.refresh,
                              child: _TimelineTab(state: state)),
                          RefreshIndicator(
                              onRefresh: notifier.refresh,
                              child: _MapTab(state: state)),
                          RefreshIndicator(
                              onRefresh: notifier.refresh,
                              child: _WeatherTab(state: state)),
                          RefreshIndicator(
                              onRefresh: notifier.refresh,
                              child: _UpdatesTab(state: state)),
                          RefreshIndicator(
                              onRefresh: notifier.refresh,
                              child: _TeamTab(state: state)),
                          RefreshIndicator(
                              onRefresh: notifier.refresh,
                              child: _EmergencyTab(state: state)),
                        ],
                      ),
                    ),
                  ],
                ),
                _LiveWorkspaceDrawer(
                  open: _drawerOpen,
                  activeIndex: _tabs.index,
                  state: state,
                  onClose: () => setState(() => _drawerOpen = false),
                  onNavigate: (index) {
                    _tabs.animateTo(index);
                    setState(() => _drawerOpen = false);
                  },
                ),
              ],
            ),
    );
  }
}

class _LivePageMeta {
  final String title;
  final IconData icon;
  const _LivePageMeta(this.title, this.icon);
}

class _LiveHeader extends StatelessWidget {
  final String title;
  final VoidCallback onMenuTap;
  final Future<void> Function() onRefresh;
  final VoidCallback onBroadcast;

  const _LiveHeader({
    required this.title,
    required this.onMenuTap,
    required this.onRefresh,
    required this.onBroadcast,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: UdoDesign.bg,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Row(children: [
          _LiveRoundButton(icon: Icons.menu, onTap: onMenuTap),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: UdoDesign.live, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                Text('LIVE',
                    style: UdoDesign.sans(
                        size: 12,
                        weight: FontWeight.w800,
                        color: UdoDesign.live)),
              ]),
              const SizedBox(height: 2),
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.serif(size: 28, color: UdoDesign.text)),
              Text('Everything happening today, in one beautiful place.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
            ]),
          ),
          _LiveRoundButton(
              icon: Icons.refresh,
              onTap: () {
                onRefresh();
              }),
          const SizedBox(width: 10),
          _LiveRoundButton(icon: Icons.edit_outlined, onTap: onBroadcast),
        ]),
      ),
    );
  }
}

class _LiveRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _LiveRoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: UdoDesign.live, size: 21),
          ),
        ),
      );
}

class _LiveWorkspaceDrawer extends StatelessWidget {
  final bool open;
  final int activeIndex;
  final LiveState state;
  final VoidCallback onClose;
  final ValueChanged<int> onNavigate;

  const _LiveWorkspaceDrawer({
    required this.open,
    required this.activeIndex,
    required this.state,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final today = state.today;
    final timeline = today?['timeline'] as Map<String, dynamic>?;
    final vendors = today?['vendors'] as Map<String, dynamic>?;
    final status = today?['status'] as Map<String, dynamic>?;
    final contacts =
        (today?['emergency_contacts'] as List?)?.cast<Map<String, dynamic>>() ??
            [];
    final badges = [
      status?['state'] == 'attention' ? 'Attention' : 'Live now',
      timeline?['current'] != null ? 'Live now' : '${state.timeline.length}',
      state.venue == null ? 'Set venue' : 'Ready',
      state.weather == null ? 'Offline' : '${state.weather!['temp']}',
      '${state.updates.length} sent',
      '${vendors?['checked_in_count'] ?? 0} active',
      contacts.isEmpty ? 'Setup' : 'Ready',
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
                          child: Text('Live',
                              style: UdoDesign.serif(
                                  size: 36, color: UdoDesign.text)),
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
                            for (var i = 0;
                                i < _LiveScreenState._pages.length;
                                i++)
                              _LiveDrawerRow(
                                meta: _LiveScreenState._pages[i],
                                badge: badges[i],
                                active: i == activeIndex,
                                onTap: () => onNavigate(i),
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

class _LiveDrawerRow extends StatelessWidget {
  final _LivePageMeta meta;
  final String badge;
  final bool active;
  final VoidCallback onTap;

  const _LiveDrawerRow({
    required this.meta,
    required this.badge,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        onTap: onTap,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        color: active ? UdoDesign.bg : UdoDesign.card,
        border: BorderSide(
            color: active
                ? UdoDesign.live.withValues(alpha: 0.22)
                : UdoDesign.border),
        child: Row(children: [
          Icon(meta.icon, color: active ? UdoDesign.live : UdoDesign.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(meta.title,
                style: UdoDesign.sans(
                    size: 14,
                    weight: FontWeight.w800,
                    color: active ? UdoDesign.live : UdoDesign.text)),
          ),
          UdoBadge(
              label: badge, color: active ? UdoDesign.live : UdoDesign.muted),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 17, color: UdoDesign.muted),
        ]),
      );
}

// ── TODAY TAB ──────────────────────────────────────────────────────────────────

class _StaleLiveBanner extends StatelessWidget {
  final DateTime? cachedAt;
  final Future<void> Function() onRefresh;

  const _StaleLiveBanner({required this.cachedAt, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final saved = cachedAt == null
        ? 'saved live data'
        : 'live data saved ${TimeOfDay.fromDateTime(cachedAt!).format(context)}';
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

class _TodayTab extends ConsumerStatefulWidget {
  final LiveState state;
  final VoidCallback onUpdatesTap;

  const _TodayTab({required this.state, required this.onUpdatesTap});

  @override
  ConsumerState<_TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends ConsumerState<_TodayTab> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _openEmergencyComposer(BuildContext context) {
    final memberCount = ref.read(weddingPartyProvider).members.length;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BuzzComposerSheet(
        initialUrgent: true,
        recipientCount: memberCount,
        onSend: (body, channel, urgent) => ref
            .read(weddingPartyProvider.notifier)
            .sendBuzz(body: body, channel: channel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final onUpdatesTap = widget.onUpdatesTap;
    final now = TimeOfDay.now();
    final timeStr = now.format(context);
    final today = state.today;
    final guests = today?['guests'] as Map<String, dynamic>?;
    final vendors = today?['vendors'] as Map<String, dynamic>?;
    final gallery = today?['gallery'] as Map<String, dynamic>?;
    final timelineData = today?['timeline'] as Map<String, dynamic>?;
    final current = timelineData?['current'] as Map<String, dynamic>?;
    final next = timelineData?['next'] as Map<String, dynamic>?;
    final recentUpdates =
        (today?['recent_updates'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final status = today?['status'] as Map<String, dynamic>?;
    final incidents =
        (today?['incidents'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final arrivals = today?['arrivals'] as Map<String, dynamic>?;
    final vipAttention =
        (today?['vip_attention'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final contacts =
        (today?['emergency_contacts'] as List?)?.cast<Map<String, dynamic>>() ??
            [];
    final arrivingTodayGuests = (arrivals?['arriving_today_guests'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final vendorRoster =
        (vendors?['roster'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final readiness = _computeReadiness(today);

    if (state.todayError != null) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        const SizedBox(height: 60),
        _errorBox("Couldn't load today's overview.", state.todayError!),
      ]);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _LiveMissionHero(
          timeLabel: timeStr,
          statusLabel: status?['label'] as String? ?? 'On schedule',
          statusMessage: status?['message'] as String? ??
              'What is happening now, what is next, and what needs attention.',
          current: current,
          next: next,
          progress: readiness.ratio,
          weather: state.weather,
          onBroadcast: onUpdatesTap,
          onEmergency: () => _openEmergencyComposer(context),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onUpdatesTap,
          child: _Card(
              child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: (status?['state'] == 'attention'
                          ? AppTheme.udoCrimson
                          : const Color(0xFF22C55E))
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: Icon(
                  status?['state'] == 'attention'
                      ? Icons.priority_high
                      : Icons.check_circle_outline,
                  color: status?['state'] == 'attention'
                      ? AppTheme.udoCrimson
                      : const Color(0xFF22C55E),
                  size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      status?['label'] as String? ??
                          'No action needed right now',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                      status?['message'] as String? ??
                          'Tap to see the latest updates.',
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.udoTextSecondary,
                          height: 1.4)),
                ])),
          ])),
        ),
        const SizedBox(height: 12),
        _MissionControlStatRow(today: today, weather: state.weather),
        const SizedBox(height: 12),
        if (readiness.ratio != null) ...[
          _ReadinessRing(ratio: readiness.ratio!),
          const SizedBox(height: 12),
        ],
        _LiveReadinessCard(today: today),
        const SizedBox(height: 12),
        if (incidents.isNotEmpty || vipAttention.isNotEmpty)
          _Card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Needs attention',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                ...incidents.take(3).map((incident) => _AlertRow(
                      icon: Icons.report_problem_outlined,
                      title: incident['title'] as String? ?? 'Live issue',
                      detail: incident['body'] as String? ??
                          incident['severity'] as String? ??
                          '',
                      color: AppTheme.udoCrimson,
                    )),
                ...vipAttention.take(3).map((guest) => _AlertRow(
                      icon: Icons.star_border,
                      title: guest['name'] as String? ?? 'VIP guest',
                      detail:
                          'Needs ${(guest['issues'] as List? ?? []).join(', ')}',
                      color: AppTheme.udoGreen,
                    )),
              ])),
        if (incidents.isNotEmpty || vipAttention.isNotEmpty)
          const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Right now',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          _InfoRow('Current time', timeStr),
          const Divider(height: 20),
          _InfoRow(
              'Current moment',
              current != null
                  ? current['title'] as String? ?? ''
                  : (next != null
                      ? 'Next: ${next['title']}'
                      : 'No events scheduled')),
          const Divider(height: 20),
          _InfoRow('Guests confirmed',
              '${guests?['confirmed'] ?? 0} of ${guests?['invited'] ?? 0}',
              valueColor: AppTheme.udoGreen),
          const Divider(height: 20),
          _InfoRow('Guests arrived',
              '${arrivals?['checked_in_count'] ?? 0} of ${guests?['confirmed'] ?? 0}',
              valueColor: AppTheme.udoGreen),
          const Divider(height: 20),
          _InfoRow('Missing arrival info',
              '${arrivals?['missing_arrival_info'] ?? 0}',
              valueColor: AppTheme.udoCrimson),
        ])),
        const SizedBox(height: 12),
        if (arrivingTodayGuests.isNotEmpty) ...[
          _Card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text("Today's arrivals",
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                ...arrivingTodayGuests.map((g) => _CheckInRow(
                      name: g['name'] as String? ?? '',
                      subtitle: _formatTime(g['arrival_time'] as String?),
                      checkedIn: g['checked_in_at'] != null,
                      onCheckIn: () => ref
                          .read(liveProvider.notifier)
                          .checkInGuest(g['id'] as int),
                    )),
              ])),
          const SizedBox(height: 12),
        ],
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(
                child: Text('Happening now',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
            Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Color(0xFF22C55E), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            const Text('Live',
                style:
                    TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
          ]),
          const SizedBox(height: 12),
          if (recentUpdates.isEmpty)
            const Text('No updates shared yet.',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
          else
            ...recentUpdates.map((u) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppTheme.udoCardFill,
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.udoBorder)),
                        child: const Icon(Icons.campaign_outlined,
                            color: AppTheme.udoGreen, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(u['title'] as String? ?? '',
                                style:
                                    const TextStyle(fontSize: 13, height: 1.4)),
                            Text(_timeAgo(u['created_at'] as String?),
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.udoTextSecondary)),
                          ])),
                    ]),
                  ),
                )),
        ])),
        const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Coming up next',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          if (next == null)
            const Text('Nothing else scheduled today.',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppTheme.udoCardFill,
                  borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(next['title'] as String? ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14)),
                      Text(_formatTime(next['start_time'] as String?),
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.udoTextSecondary)),
                    ])),
                Text(_liveCountdownTo(next),
                    style: const TextStyle(
                        color: AppTheme.udoGreen,
                        fontWeight: FontWeight.w500,
                        fontSize: 13)),
              ]),
            ),
        ])),
        const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Vendor readiness',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
                color: AppTheme.udoCardFill,
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.check_circle,
                  color: Color(0xFF22C55E), size: 18),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                      '${vendors?['confirmed'] ?? 0} of ${vendors?['total'] ?? 0} vendors confirmed · ${vendors?['checked_in_count'] ?? 0} checked in',
                      style: const TextStyle(fontSize: 13))),
            ]),
          ),
          if (vendorRoster.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...vendorRoster.map((v) => _CheckInRow(
                  name: v['name'] as String? ?? '',
                  subtitle: v['category'] as String? ?? '',
                  checkedIn: v['checked_in_at'] != null,
                  onCheckIn: () => ref
                      .read(liveProvider.notifier)
                      .checkInVendor(v['id'] as int),
                )),
          ],
        ])),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppTheme.udoPastelCrimson.withValues(alpha: 0.2),
              Colors.white
            ], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppTheme.udoPastelCrimson.withValues(alpha: 0.5)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.auto_awesome,
                  color: AppTheme.udoCrimson, size: 18),
              const SizedBox(width: 8),
              const Text('Your day so far',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 12),
            _DayStat(Icons.camera_alt_outlined, 'Photos captured',
                '${gallery?['photos'] ?? 0}', AppTheme.udoGreen),
            const SizedBox(height: 8),
            _DayStat(Icons.campaign_outlined, 'Updates shared',
                '${state.updates.length}', AppTheme.udoCrimson),
            const SizedBox(height: 8),
            _DayStat(Icons.people_outline, 'Guests confirmed',
                '${guests?['confirmed'] ?? 0}', const Color(0xFF22C55E)),
          ]),
        ),
        const SizedBox(height: 12),
        _Card(
            child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(state.weather != null ? '${state.weather!['temp']}°' : '—',
                    style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.w500, height: 1)),
                const SizedBox(height: 4),
                Text(
                    state.weather?['condition'] as String? ??
                        (state.weatherMessage ?? 'Weather unavailable'),
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.udoTextSecondary)),
              ])),
          Icon(_weatherIcon(state.weather?['condition'] as String?),
              size: 56, color: Colors.orange),
        ])),
        const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Your support team',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          if (contacts.isEmpty)
            const Text(
                'No emergency contacts added yet. Add them from Wedding Party → Emergency.',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
          else
            ...contacts.map((c) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppTheme.udoCardFill,
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(c['name'] as String? ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 14)),
                          Text(c['relationship'] as String? ?? '',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.udoTextSecondary)),
                          Text(c['phone'] as String? ?? '',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.udoTextSecondary)),
                        ])),
                    Row(children: [
                      GestureDetector(
                          onTap: () =>
                              _launchTel(context, c['phone'] as String?),
                          child: const Icon(Icons.phone_outlined,
                              color: AppTheme.udoGreen, size: 18)),
                      const SizedBox(width: 10),
                      GestureDetector(
                          onTap: () =>
                              _launchSms(context, c['phone'] as String?),
                          child: const Icon(Icons.message_outlined,
                              color: AppTheme.udoGreen, size: 18)),
                    ]),
                  ]),
                )),
        ])),
        const SizedBox(height: 24),
        const Center(
            child: Text(
          'Today is yours.',
          style: TextStyle(
              fontFamily: 'Playfair',
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.5),
          textAlign: TextAlign.center,
        )),
        const SizedBox(height: 6),
        const Center(
            child: Text('Just enjoy this moment.',
                style:
                    TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary))),
        const SizedBox(height: 24),
      ],
    );
  }

  IconData _weatherIcon(String? condition) {
    switch ((condition ?? '').toLowerCase()) {
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return Icons.umbrella_outlined;
      case 'clouds':
        return Icons.cloud_outlined;
      case 'snow':
        return Icons.ac_unit_outlined;
      default:
        return Icons.wb_sunny_outlined;
    }
  }
}

class _LiveMissionHero extends StatelessWidget {
  final String timeLabel;
  final String statusLabel;
  final String statusMessage;
  final Map<String, dynamic>? current;
  final Map<String, dynamic>? next;
  final double? progress;
  final Map<String, dynamic>? weather;
  final VoidCallback onBroadcast;
  final VoidCallback onEmergency;

  const _LiveMissionHero({
    required this.timeLabel,
    required this.statusLabel,
    required this.statusMessage,
    required this.current,
    required this.next,
    required this.progress,
    required this.weather,
    required this.onBroadcast,
    required this.onEmergency,
  });

  @override
  Widget build(BuildContext context) {
    final progressValue = progress?.clamp(0.0, 1.0) ?? 0.0;
    return UdoCard(
      color: UdoDesign.live,
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const UdoBadge(
                    label: 'Wedding day',
                    color: UdoDesign.gold,
                    background: Color(0x22FFFFFF)),
                const SizedBox(height: 12),
                Text(timeLabel,
                    style: UdoDesign.serif(size: 38, color: Colors.white)),
                const SizedBox(height: 4),
                Text(statusLabel,
                    style: UdoDesign.sans(
                        size: 13.5,
                        weight: FontWeight.w800,
                        color: Colors.white)),
                Text(statusMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: UdoDesign.sans(
                        size: 12.5, color: Colors.white70, height: 1.4)),
              ])),
          UdoRingProgress(
            value: progressValue,
            color: Colors.white,
            size: 76,
            center: Text(
                progress == null ? 'LIVE' : '${(progressValue * 100).round()}%',
                style: UdoDesign.sans(
                    size: 13, weight: FontWeight.w800, color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 18),
        _LiveHeroMoment(
          label: 'Now',
          title: current?['title'] as String? ?? 'No active event',
          meta: current == null
              ? 'Waiting for the schedule to begin'
              : '${_formatTime(current!['start_time'] as String?)} ${current!['location'] ?? ''}',
          statusText: current == null ? null : _currentEventTiming(current!),
        ),
        const SizedBox(height: 8),
        _LiveHeroMoment(
          label: 'Next',
          title: next?['title'] as String? ?? 'Nothing else scheduled',
          meta: next == null
              ? 'Timeline is clear'
              : '${_formatTime(next!['start_time'] as String?)} ${next!['location'] ?? ''}',
          statusText: next == null ? null : _liveCountdownTo(next!),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
              child: _LiveHeroAction(
                  label: 'Broadcast',
                  icon: Icons.campaign_outlined,
                  onTap: onBroadcast)),
          const SizedBox(width: 8),
          Expanded(
              child: _LiveHeroAction(
                  label: 'Emergency',
                  icon: Icons.emergency_outlined,
                  onTap: onEmergency,
                  danger: true)),
        ]),
        if (weather != null) ...[
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.wb_sunny_outlined,
                color: Colors.white70, size: 17),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                    '${weather!['temp']} - ${weather!['condition'] ?? 'Weather'}',
                    style: UdoDesign.sans(size: 12, color: Colors.white70))),
          ]),
        ],
      ]),
    );
  }
}

class _LiveHeroMoment extends StatelessWidget {
  final String label;
  final String title;
  final String meta;
  final String? statusText;
  const _LiveHeroMoment(
      {required this.label,
      required this.title,
      required this.meta,
      this.statusText});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24)),
        child: Row(children: [
          SizedBox(
            width: 44,
            child: Text(label,
                style: UdoDesign.sans(
                    size: 11, weight: FontWeight.w800, color: UdoDesign.gold)),
          ),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UdoDesign.sans(
                        size: 13.5,
                        weight: FontWeight.w800,
                        color: Colors.white)),
                Text(meta.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UdoDesign.sans(size: 11.5, color: Colors.white70)),
              ])),
          if (statusText != null && statusText!.isNotEmpty) ...[
            const SizedBox(width: 10),
            Text(statusText!,
                style: UdoDesign.sans(
                    size: 11, weight: FontWeight.w800, color: UdoDesign.gold)),
          ],
        ]),
      );
}

class _LiveHeroAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;
  const _LiveHeroAction(
      {required this.label,
      required this.icon,
      required this.onTap,
      this.danger = false});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 17),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: danger ? AppTheme.udoPastelCrimson : Colors.white,
          side: BorderSide(
              color: danger ? AppTheme.udoPastelCrimson : Colors.white54),
          minimumSize: const Size(0, 42),
          padding: EdgeInsets.zero,
        ),
      );
}

class _CheckInRow extends StatelessWidget {
  final String name, subtitle;
  final bool checkedIn;
  final VoidCallback onCheckIn;
  const _CheckInRow(
      {required this.name,
      required this.subtitle,
      required this.checkedIn,
      required this.onCheckIn});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppTheme.udoCardFill,
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.udoTextSecondary)),
              ])),
          GestureDetector(
            onTap: checkedIn ? null : onCheckIn,
            child: Icon(
                checkedIn ? Icons.check_circle : Icons.radio_button_unchecked,
                color: checkedIn
                    ? const Color(0xFF22C55E)
                    : AppTheme.udoTextSecondary,
                size: 22),
          ),
        ]),
      );
}

typedef _Readiness = ({double? ratio, String? headline, List<String> facts});

/// Computes one real Live-specific readiness ratio from today's guest
/// check-in rate, vendor check-in rate, and today's-timeline completion rate
/// (never a fabricated number). Shared by [_LiveReadinessCard]'s text
/// rendering and [_ReadinessRing]'s visual gauge so both read the exact same
/// underlying facts. Returns a null ratio (honest not-started state) until
/// at least one of those has real activity.
_Readiness _computeReadiness(Map<String, dynamic>? today) {
  final arrivals = today?['arrivals'] as Map<String, dynamic>?;
  final guests = today?['guests'] as Map<String, dynamic>?;
  final vendors = today?['vendors'] as Map<String, dynamic>?;
  final timelineData = today?['timeline'] as Map<String, dynamic>?;
  final status = today?['status'] as Map<String, dynamic>?;
  final todayItems =
      (timelineData?['today_items'] as List?)?.cast<Map<String, dynamic>>() ??
          [];

  final confirmedGuests = (guests?['confirmed'] as num?)?.toInt() ?? 0;
  final checkedInGuests = (arrivals?['checked_in_count'] as num?)?.toInt() ?? 0;
  final confirmedVendors = (vendors?['confirmed'] as num?)?.toInt() ?? 0;
  final checkedInVendors = (vendors?['checked_in_count'] as num?)?.toInt() ?? 0;
  final unresolvedIncidents =
      (status?['unresolved_incidents'] as num?)?.toInt() ?? 0;

  final coreRatios = <double>[];
  final facts = <String>[];
  if (confirmedGuests > 0) {
    coreRatios.add(checkedInGuests / confirmedGuests);
    facts.add('$checkedInGuests of $confirmedGuests guests arrived');
  }
  if (confirmedVendors > 0) {
    coreRatios.add(checkedInVendors / confirmedVendors);
    facts.add('$checkedInVendors of $confirmedVendors vendors checked in');
  }
  if (todayItems.isNotEmpty) {
    final now = DateTime.now();
    final completed = todayItems.where((item) {
      final dateStr = item['event_date'] as String?;
      final endTime =
          (item['end_time'] as String?) ?? (item['start_time'] as String?);
      if (dateStr == null || endTime == null) return false;
      final date = DateTime.tryParse(dateStr);
      if (date == null) return false;
      final parts = endTime.split(':');
      final end = DateTime(
          date.year,
          date.month,
          date.day,
          int.tryParse(parts[0]) ?? 0,
          int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
      return end.isBefore(now);
    }).length;
    coreRatios.add(completed / todayItems.length);
    facts
        .add('$completed of ${todayItems.length} today\'s schedule items done');
  }

  if (coreRatios.isEmpty) return (ratio: null, headline: null, facts: facts);

  if (unresolvedIncidents > 0)
    facts.add(
        '$unresolvedIncidents unresolved live issue${unresolvedIncidents == 1 ? '' : 's'}');
  final incidentRatio = unresolvedIncidents == 0
      ? 1.0
      : (1 - unresolvedIncidents * 0.25).clamp(0.0, 1.0);
  final avg = ([...coreRatios, incidentRatio]).reduce((a, b) => a + b) /
      (coreRatios.length + 1);

  final String headline;
  if (unresolvedIncidents == 0 && avg >= 0.7) {
    headline = 'Everything is Flowing Beautifully';
  } else if (unresolvedIncidents == 0) {
    headline = 'Excellent';
  } else {
    headline = 'Attention Required';
  }

  return (ratio: avg, headline: headline, facts: facts);
}

class _LiveReadinessCard extends StatelessWidget {
  final Map<String, dynamic>? today;
  const _LiveReadinessCard({required this.today});

  @override
  Widget build(BuildContext context) {
    final readiness = _computeReadiness(today);

    if (readiness.ratio == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppTheme.udoCardFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.udoBorder)),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppTheme.udoGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.timer_outlined,
                color: AppTheme.udoGreen, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
              child: Text(
                  "Readiness will appear once guest arrivals, vendor check-ins, or schedule get underway.",
                  style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.udoTextSecondary,
                      height: 1.35))),
        ]),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.udoCardFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.udoBorder)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: AppTheme.udoGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.timer_outlined,
              color: AppTheme.udoGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Today — ${readiness.headline}',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(readiness.facts.join(' · '),
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.udoTextSecondary,
                  height: 1.35)),
        ])),
      ]),
    );
  }
}

/// A visual gauge over the exact same ratio [_computeReadiness] already
/// computes for [_LiveReadinessCard] — no separate/duplicated metric.
class _ReadinessRing extends StatelessWidget {
  final double ratio;
  const _ReadinessRing({required this.ratio});

  @override
  Widget build(BuildContext context) {
    final pct = (ratio.clamp(0.0, 1.0) * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.udoBorder)),
      child: Column(children: [
        SizedBox(
          width: 92,
          height: 92,
          child: CustomPaint(
            painter: _ReadinessRingPainter(ratio: ratio),
            child: Center(
                child: Text('$pct%',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700))),
          ),
        ),
        const SizedBox(height: 10),
        const Text('WEDDING DAY PROGRESS',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.udoTextSecondary,
                letterSpacing: 0.5)),
      ]),
    );
  }
}

class _ReadinessRingPainter extends CustomPainter {
  final double ratio;
  const _ReadinessRingPainter({required this.ratio});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 10.0;
    final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
        size.width - strokeWidth, size.height - strokeWidth);
    final bg = Paint()
      ..color = AppTheme.udoBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, 2 * pi, false, bg);
    final fg = Paint()
      ..color = AppTheme.udoGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -pi / 2, 2 * pi * ratio.clamp(0.0, 1.0), false, fg);
  }

  @override
  bool shouldRepaint(covariant _ReadinessRingPainter oldDelegate) =>
      oldDelegate.ratio != ratio;
}

class _MissionControlStatRow extends StatelessWidget {
  final Map<String, dynamic>? today;
  final Map<String, dynamic>? weather;
  const _MissionControlStatRow({required this.today, required this.weather});

  @override
  Widget build(BuildContext context) {
    final arrivals = today?['arrivals'] as Map<String, dynamic>?;
    final guests = today?['guests'] as Map<String, dynamic>?;
    final vendors = today?['vendors'] as Map<String, dynamic>?;
    final transport = today?['transport'] as Map<String, dynamic>?;
    final status = today?['status'] as Map<String, dynamic>?;

    final confirmedGuests = (guests?['confirmed'] as num?)?.toInt() ?? 0;
    final checkedInGuests =
        (arrivals?['checked_in_count'] as num?)?.toInt() ?? 0;
    final confirmedVendors = (vendors?['confirmed'] as num?)?.toInt() ?? 0;
    final checkedInVendors =
        (vendors?['checked_in_count'] as num?)?.toInt() ?? 0;
    final totalRequiringTransport =
        (transport?['total_requiring'] as num?)?.toInt() ?? 0;
    final arrangedTransport = (transport?['arranged'] as num?)?.toInt() ?? 0;
    final transportPct = totalRequiringTransport > 0
        ? ((arrangedTransport / totalRequiringTransport) * 100).round()
        : null;
    final unresolvedIncidents =
        (status?['unresolved_incidents'] as num?)?.toInt() ?? 0;

    final tiles = [
      _MissionStatTile(Icons.people_outline, 'Guests Arrived',
          '$checkedInGuests/$confirmedGuests'),
      _MissionStatTile(Icons.directions_bus_outlined, 'Transport Arranged',
          transportPct != null ? '$transportPct%' : '—'),
      _MissionStatTile(Icons.store_outlined, 'Vendors On-Site',
          '$checkedInVendors/$confirmedVendors'),
      _MissionStatTile(
          Icons.wb_sunny_outlined, 'Weather', _weatherQualityLabel(weather)),
      _MissionStatTile(Icons.report_problem_outlined, 'Urgent Issues',
          '$unresolvedIncidents',
          color: unresolvedIncidents > 0 ? AppTheme.udoCrimson : null),
    ];

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => tiles[i],
      ),
    );
  }
}

class _MissionStatTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? color;
  const _MissionStatTile(this.icon, this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 108,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.udoBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: color ?? AppTheme.udoGreen),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color ?? AppTheme.udoTextPrimary)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.udoTextSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ]),
      );
}

/// Same rain/temp thresholds [_WeatherTab._advisory] already uses to write
/// its advisory sentence — reused here as a single-word quality label for
/// the Mission Control stat row, not a separate metric.
String _weatherQualityLabel(Map<String, dynamic>? w) {
  if (w == null) return '—';
  final rain = (w['rain_chance_pct'] as num?) ?? 0;
  final temp = (w['temp'] as num?) ?? 70;
  if (rain >= 50) return 'Poor';
  if (temp >= 90 || temp <= 50) return 'Fair';
  if (rain <= 15 && temp >= 65 && temp <= 85) return 'Excellent';
  return 'Good';
}

// ── TIMELINE TAB ───────────────────────────────────────────────────────────────

class _TimelineTab extends StatelessWidget {
  final LiveState state;
  const _TimelineTab({required this.state});

  String _statusFor(Map<String, dynamic> item) {
    final start = _eventStartAt(item);
    if (start == null) return 'upcoming';
    final end = _eventEndAt(item) ?? start.add(const Duration(minutes: 30));
    final now = DateTime.now();
    if (now.isBefore(start)) return 'upcoming';
    if (now.isAfter(end)) return 'completed';
    return 'in-progress';
  }

  @override
  Widget build(BuildContext context) {
    final timeline = state.timeline;

    if (state.timelineError != null) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        const SizedBox(height: 60),
        _errorBox("Couldn't load your timeline.", state.timelineError!)
      ]);
    }

    if (timeline.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 120),
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.calendar_today_outlined,
                size: 48, color: AppTheme.udoTextSecondary),
            const SizedBox(height: 12),
            const Text('No schedule yet',
                style:
                    TextStyle(color: AppTheme.udoTextSecondary, fontSize: 15)),
            const SizedBox(height: 4),
            const Text('Add events in the Plan section',
                style:
                    TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.push('/plan?section=timeline'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add timeline event'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: UdoDesign.live,
                  side: const BorderSide(color: UdoDesign.live)),
            ),
          ]),
        ),
      ]);
    }
    final completed =
        timeline.where((item) => _statusFor(item) == 'completed').length;
    final live =
        timeline.where((item) => _statusFor(item) == 'in-progress').length;
    final progress = timeline.isEmpty ? 0.0 : completed / timeline.length;
    final next = timeline.cast<Map<String, dynamic>?>().firstWhere(
        (item) => item != null && _statusFor(item) != 'completed',
        orElse: () => null);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TimelineOpsHero(
          completed: completed,
          total: timeline.length,
          live: live,
          progress: progress,
          next: next,
        ),
        const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Full schedule',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          ...timeline.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isLast = i == timeline.length - 1;
            final status = _statusFor(item);
            final timeLabel = _formatTime(item['start_time'] as String?);
            final title = item['title'] as String? ?? '';
            return GestureDetector(
              onTap: () => _showTimelineDetail(context, item, status),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Column(children: [
                  _TimelineDot(status: status),
                  if (!isLast)
                    Container(width: 2, height: 58, color: AppTheme.udoBorder),
                ]),
                const SizedBox(width: 14),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: status == 'in-progress'
                            ? UdoDesign.live.withValues(alpha: 0.08)
                            : AppTheme.udoCardFill,
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: status == 'in-progress'
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: status == 'completed'
                                    ? AppTheme.udoTextSecondary
                                    : AppTheme.udoTextPrimary,
                              ),
                            ),
                            if ((item['location'] as String?)?.isNotEmpty ==
                                true)
                              Text(item['location'] as String,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.udoTextSecondary)),
                          ])),
                      const SizedBox(width: 8),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(timeLabel,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.udoTextSecondary)),
                            Text(
                                status == 'in-progress'
                                    ? 'Live'
                                    : status == 'completed'
                                        ? 'Done'
                                        : _countdownTo(item),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: status == 'in-progress'
                                        ? UdoDesign.live
                                        : AppTheme.udoTextSecondary)),
                          ]),
                    ]),
                  ),
                )),
              ]),
            );
          }),
        ])),
      ],
    );
  }

  void _showTimelineDetail(
      BuildContext context, Map<String, dynamic> item, String status) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                UdoBadge(label: status, color: UdoDesign.live),
                const SizedBox(height: 12),
                Text(item['title'] as String? ?? 'Timeline event',
                    style: UdoDesign.serif(size: 28)),
                const SizedBox(height: 8),
                _InfoRow('Time', _formatTime(item['start_time'] as String?)),
                if ((item['location'] as String?)?.isNotEmpty == true) ...[
                  const Divider(height: 20),
                  _InfoRow('Location', item['location'] as String),
                ],
                if ((item['notes'] as String?)?.isNotEmpty == true) ...[
                  const Divider(height: 20),
                  Text(item['notes'] as String,
                      style: UdoDesign.sans(
                          size: 13, color: UdoDesign.muted, height: 1.45)),
                ],
              ]),
        ),
      ),
    );
  }
}

class _TimelineOpsHero extends StatelessWidget {
  final int completed;
  final int total;
  final int live;
  final double progress;
  final Map<String, dynamic>? next;

  const _TimelineOpsHero({
    required this.completed,
    required this.total,
    required this.live,
    required this.progress,
    required this.next,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        color: UdoDesign.live,
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          UdoRingProgress(
            value: progress,
            color: Colors.white,
            size: 70,
            center: Text('$completed/$total',
                style: UdoDesign.sans(
                    size: 12, weight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(live > 0 ? 'Timeline is live now' : 'Timeline standby',
                    style: UdoDesign.sans(
                        size: 15,
                        weight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                    next == null
                        ? 'All scheduled events are complete.'
                        : 'Next: ${next!['title'] ?? 'Timeline event'} ${_countdownTo(next!)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: UdoDesign.sans(
                        size: 12.5, color: Colors.white70, height: 1.4)),
              ])),
        ]),
      );
}

class _TimelineDot extends StatelessWidget {
  final String status;
  const _TimelineDot({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == 'completed')
      return const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20);
    if (status == 'in-progress')
      return Container(
          width: 20,
          height: 20,
          decoration:
              BoxDecoration(color: AppTheme.udoGreen, shape: BoxShape.circle));
    return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.udoBorder, width: 2)));
  }
}

// ── MAP TAB ────────────────────────────────────────────────────────────────────

class _MapTab extends ConsumerWidget {
  final LiveState state;
  const _MapTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venue = state.venue;
    final timelineData = state.today?['timeline'] as Map<String, dynamic>?;
    final current = timelineData?['current'] as Map<String, dynamic>?;
    final next = timelineData?['next'] as Map<String, dynamic>?;
    final liveEvent = current ??
        next ??
        (state.timeline.isNotEmpty ? state.timeline.first : null);
    final liveLocation = liveEvent?['location'] as String?;

    final areaSet = state.timeline
        .map((t) => t['location'] as String?)
        .where((l) => l != null && l.isNotEmpty)
        .cast<String>()
        .toSet();
    if (liveLocation != null && liveLocation.isNotEmpty) {
      areaSet.add(liveLocation);
    }
    final areas = areaSet.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _LocationsOpsHero(
          hasLiveLocation: liveLocation != null && liveLocation.isNotEmpty,
          liveLocation: liveLocation,
          venueName: venue?['venue_name'] as String?,
          areaCount: areas.length,
        ),
        const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Live event location',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          _LiveLocationSummary(event: liveEvent, venue: venue),
          const SizedBox(height: 12),
          if (areas.isEmpty) ...[
            const Text(
                'Add locations to your timeline events to see them listed here.',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/plan?section=timeline'),
              icon: const Icon(Icons.add_location_alt_outlined, size: 18),
              label: const Text('Add timeline event'),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  foregroundColor: UdoDesign.live,
                  side: const BorderSide(color: UdoDesign.live)),
            ),
          ] else
            ...areas.map((area) {
              final items = state.timeline
                  .where((item) => item['location'] == area)
                  .toList();
              if (liveEvent != null && liveEvent['location'] == area) {
                final exists =
                    items.any((item) => item['id'] == liveEvent['id']);
                if (!exists) items.add(liveEvent);
              }
              return _LiveLocationRow(
                location: area,
                items: items,
                onTap: () =>
                    _showLocationStatusSheet(context, ref, area, items),
              );
            }),
        ])),
      ],
    );
  }

  void _showLocationStatusSheet(BuildContext context, WidgetRef ref,
      String location, List<Map<String, dynamic>> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _LocationStatusSheet(location: location, items: items),
    );
  }
}

// ── WEATHER TAB ────────────────────────────────────────────────────────────────

class _LocationsOpsHero extends StatelessWidget {
  final bool hasLiveLocation;
  final String? liveLocation;
  final String? venueName;
  final int areaCount;

  const _LocationsOpsHero({
    required this.hasLiveLocation,
    required this.liveLocation,
    required this.venueName,
    required this.areaCount,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        color: UdoDesign.live,
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(
                hasLiveLocation ? Icons.location_on : Icons.location_searching,
                color: Colors.white,
                size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                    hasLiveLocation
                        ? liveLocation!
                        : (venueName ?? 'Live location pending'),
                    style: UdoDesign.sans(
                        size: 15,
                        weight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                    hasLiveLocation
                        ? '$areaCount timeline location${areaCount == 1 ? '' : 's'} ready for live coordination.'
                        : 'Add locations to timeline events so the live team knows where to go.',
                    style: UdoDesign.sans(
                        size: 12.5, color: Colors.white70, height: 1.4)),
              ])),
        ]),
      );
}

class _LiveLocationSummary extends StatelessWidget {
  final Map<String, dynamic>? event;
  final Map<String, dynamic>? venue;

  const _LiveLocationSummary({required this.event, required this.venue});

  @override
  Widget build(BuildContext context) {
    final location = event?['location'] as String?;
    final venueName = venue?['venue_name'] as String?;
    final venueAddress = venue?['venue_address'] as String?;
    final title = event?['title'] as String?;
    final timing = event == null ? '' : _currentEventTiming(event!);

    if (event == null || location == null || location.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.udoCardFill,
            borderRadius: BorderRadius.circular(14)),
        child: const Row(children: [
          Icon(Icons.location_searching,
              color: AppTheme.udoTextSecondary, size: 22),
          SizedBox(width: 12),
          Expanded(
              child: Text(
                  'Add locations to timeline events to show live event location here.',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.udoTextSecondary,
                      height: 1.4))),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(14)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: AppTheme.udoGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle),
          child:
              const Icon(Icons.location_on, color: AppTheme.udoGreen, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(location,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            if (title != null && title.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.udoTextSecondary)),
            ],
            if (timing.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(timing,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.udoGreen,
                      fontWeight: FontWeight.w600)),
            ],
            if (venueName != null && venueName.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(venueName,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
            if (venueAddress != null && venueAddress.isNotEmpty)
              Text(venueAddress,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.udoTextSecondary)),
          ]),
        ),
      ]),
    );
  }
}

class _LiveLocationRow extends StatelessWidget {
  final String location;
  final List<Map<String, dynamic>> items;
  final VoidCallback onTap;

  const _LiveLocationRow({
    required this.location,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = _locationStatusFor(items);
    final eventCount = items.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.udoCardFill,
              borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: _locationStatusColor(status).withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child: Icon(Icons.place_outlined,
                  color: _locationStatusColor(status), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(location,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(
                      eventCount == 1
                          ? '1 timeline event'
                          : '$eventCount timeline events',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.udoTextSecondary)),
                ])),
            UdoBadge(
                label: _locationStatusLabel(status),
                color: _locationStatusColor(status)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: AppTheme.udoTextSecondary, size: 18),
          ]),
        ),
      ),
    );
  }
}

class _LocationStatusSheet extends ConsumerStatefulWidget {
  final String location;
  final List<Map<String, dynamic>> items;

  const _LocationStatusSheet({
    required this.location,
    required this.items,
  });

  @override
  ConsumerState<_LocationStatusSheet> createState() =>
      _LocationStatusSheetState();
}

class _LocationStatusSheetState extends ConsumerState<_LocationStatusSheet> {
  late String _status = _locationStatusFor(widget.items);
  bool _saving = false;

  Future<void> _save() async {
    final ids =
        widget.items.map((item) => item['id']).whereType<int>().toList();
    if (ids.isEmpty) return;
    setState(() => _saving = true);
    final ok = await ref
        .read(liveProvider.notifier)
        .updateTimelineLocationStatuses(ids, _status);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.location} status updated.')));
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Couldn't update this location status.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
                color: AppTheme.udoBorder,
                borderRadius: BorderRadius.circular(999)),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
              child: Text(widget.location,
                  style: UdoDesign.serif(size: 24, color: UdoDesign.text)),
            ),
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                    backgroundColor: AppTheme.udoCardFill)),
          ]),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
                widget.items.length == 1
                    ? '1 timeline event uses this location'
                    : '${widget.items.length} timeline events use this location',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.udoTextSecondary)),
          ),
          const SizedBox(height: 16),
          ..._locationStatusOptions.map((option) {
            final selected = option.value == _status;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _status = option.value),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: selected
                        ? option.color.withValues(alpha: 0.12)
                        : AppTheme.udoCardFill,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: selected ? option.color : AppTheme.udoBorder),
                  ),
                  child: Row(children: [
                    Icon(
                        selected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color:
                            selected ? option.color : AppTheme.udoTextSecondary,
                        size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(option.label,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600))),
                  ]),
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(_saving ? 'Updating...' : 'Update status'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.udoGreen,
                foregroundColor: Colors.white),
          ),
        ]),
      ),
    );
  }
}

class _LocationStatusOption {
  final String value;
  final String label;
  final Color color;

  const _LocationStatusOption(this.value, this.label, this.color);
}

const _locationStatusOptions = [
  _LocationStatusOption('upcoming', 'Upcoming', Color(0xFF7EA1D2)),
  _LocationStatusOption('current', 'Current', AppTheme.udoCrimson),
  _LocationStatusOption('active', 'Active', AppTheme.udoGreen),
  _LocationStatusOption('complete', 'Complete', Color(0xFF8C8C8C)),
  _LocationStatusOption('closed', 'Closed', Color(0xFF6B7280)),
];

String _locationStatusFor(List<Map<String, dynamic>> items) {
  final statuses = items
      .map((item) => item['location_status'] as String?)
      .where((status) => status != null && status.isNotEmpty)
      .cast<String>()
      .toSet();
  if (statuses.length == 1) return statuses.first;
  if (statuses.length > 1) return 'mixed';
  return 'upcoming';
}

String _locationStatusLabel(String status) {
  if (status == 'mixed') return 'Mixed';
  return _locationStatusOptions
      .firstWhere((option) => option.value == status,
          orElse: () => _locationStatusOptions.first)
      .label;
}

Color _locationStatusColor(String status) {
  if (status == 'mixed') return UdoDesign.gold;
  return _locationStatusOptions
      .firstWhere((option) => option.value == status,
          orElse: () => _locationStatusOptions.first)
      .color;
}

class _WeatherTab extends StatelessWidget {
  final LiveState state;
  const _WeatherTab({required this.state});

  String _advisory(Map<String, dynamic> w) {
    final rain = w['rain_chance_pct'] as num? ?? 0;
    final temp = w['temp'] as num? ?? 70;
    if (rain >= 50)
      return 'Rain is likely — consider a backup plan or tent for outdoor moments.';
    if (temp >= 90)
      return 'It\'ll be hot — keep guests hydrated and consider shade for outdoor seating.';
    if (temp <= 50)
      return 'It\'ll be cool — guests may appreciate blankets or heaters for outdoor areas.';
    if (rain <= 15 && temp >= 65 && temp <= 85)
      return 'Great conditions for your outdoor plans today.';
    return 'Conditions look manageable — check back closer to the day for updates.';
  }

  IconData _icon(String? condition) {
    switch ((condition ?? '').toLowerCase()) {
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return Icons.umbrella_outlined;
      case 'clouds':
        return Icons.cloud_outlined;
      case 'snow':
        return Icons.ac_unit_outlined;
      default:
        return Icons.wb_sunny_outlined;
    }
  }

  /// Rule-based recommendations from the same rain/wind/temp/sunset thresholds
  /// [_advisory] and [_goldenHourWindow] already use — reshaped into a list
  /// for the mockup's recommendations card. Deliberately labeled "Weather
  /// Recommendations", not "AI" — every item here is plain deterministic
  /// logic on real forecast fields, never a generative claim.
  List<({IconData icon, Color color, String title, String subtitle})>
      _weatherRecommendations(Map<String, dynamic> w) {
    final rain = (w['rain_chance_pct'] as num?) ?? 0;
    final temp = (w['temp'] as num?) ?? 70;
    final wind = (w['wind_mph'] as num?) ?? 0;
    final goldenHour = _goldenHourWindow(w['sunset'] as String?);

    final items =
        <({IconData icon, Color color, String title, String subtitle})>[];

    if (rain >= 50) {
      items.add((
        icon: Icons.umbrella_outlined,
        color: AppTheme.udoCrimson,
        title: 'Rain risk is high',
        subtitle: 'Consider a backup plan or tent for outdoor moments.'
      ));
    } else if (rain <= 15) {
      items.add((
        icon: Icons.umbrella_outlined,
        color: AppTheme.udoGreen,
        title: 'Low chance of rain all day',
        subtitle: 'No action needed for outdoor plans.'
      ));
    } else {
      items.add((
        icon: Icons.umbrella_outlined,
        color: Colors.orange,
        title: 'Some chance of rain',
        subtitle: 'Worth keeping an eye on closer to the day.'
      ));
    }

    if (goldenHour != null) {
      items.add((
        icon: Icons.wb_twilight_outlined,
        color: Colors.orange,
        title: 'Golden hour is around $goldenHour',
        subtitle: 'Favorable light for outdoor photos before sunset.'
      ));
    }

    if (wind >= 15) {
      items.add((
        icon: Icons.air_outlined,
        color: Colors.orange,
        title: 'Breezy conditions',
        subtitle: 'Secure light decor and loose paper items outdoors.'
      ));
    } else {
      items.add((
        icon: Icons.air_outlined,
        color: AppTheme.udoGreen,
        title: 'Light breeze all day',
        subtitle: 'Comfortable wind conditions for an outdoor ceremony.'
      ));
    }

    if (temp >= 90) {
      items.add((
        icon: Icons.thermostat_outlined,
        color: AppTheme.udoCrimson,
        title: "It'll be hot",
        subtitle: 'Keep guests hydrated and consider shade for outdoor seating.'
      ));
    } else if (temp <= 50) {
      items.add((
        icon: Icons.thermostat_outlined,
        color: Colors.blue,
        title: "It'll be cool",
        subtitle: 'Guests may appreciate blankets or heaters for outdoor areas.'
      ));
    }

    return items;
  }

  /// Golden-hour window is real math on the real sunset time (~30-60 min
  /// before sunset) — not a fabricated "AI recommendation".
  String? _goldenHourWindow(String? sunset) {
    if (sunset == null || sunset.isEmpty) return null;
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
        .firstMatch(sunset.trim());
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    final sunsetMinutes = hour * 60 + minute;
    String fmt(int totalMinutes) {
      final m = totalMinutes % (24 * 60);
      final h = m ~/ 60;
      final min = m % 60;
      final suffix = h >= 12 ? 'PM' : 'AM';
      final displayHour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      return '$displayHour:${min.toString().padLeft(2, '0')} $suffix';
    }

    return '${fmt(sunsetMinutes - 60)} – ${fmt(sunsetMinutes - 30)}';
  }

  @override
  Widget build(BuildContext context) {
    final currentWeather = state.weather;
    final weddingDay = currentWeather?['wedding_day'] as Map<String, dynamic>?;
    final weddingDayAvailable = weddingDay?['forecast_available'] == true;
    final w = weddingDayAvailable ? weddingDay : null;
    final sunset = currentWeather?['sunset'] as String?;
    final timelineRisks = (currentWeather?['timeline_risks'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _WeatherOpsHero(
          weather: w,
          quality: _weatherQualityLabel(w),
          advisory: w == null ? state.weatherMessage : _advisory(w),
        ),
        const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Wedding-day weather',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          if (w == null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppTheme.udoCardFill,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                const Icon(Icons.cloud_off_outlined,
                    size: 40, color: AppTheme.udoTextSecondary),
                const SizedBox(height: 10),
                Text(
                    state.weatherMessage ?? 'Weather is currently unavailable.',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.udoTextSecondary),
                    textAlign: TextAlign.center),
                if ((state.weatherMessage ?? '')
                    .toLowerCase()
                    .contains('venue address')) ...[
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/plan?section=details'),
                    icon: const Icon(Icons.edit_location_alt_outlined,
                        size: 18),
                    label: const Text('Update venue address'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: UdoDesign.live,
                        side: const BorderSide(color: UdoDesign.live)),
                  ),
                ],
              ]),
            )
          else if (!weddingDayAvailable)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: AppTheme.udoCardFill,
                  borderRadius: BorderRadius.circular(16)),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.event_busy_outlined,
                    color: AppTheme.udoTextSecondary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Wedding-day forecast pending',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                          weddingDay?['reason'] as String? ??
                              'Forecast available closer to the wedding date.',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.udoTextSecondary,
                              height: 1.4)),
                    ])),
              ]),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppTheme.udoCardFill,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                Row(children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${w['temp']}°',
                            style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w500,
                                height: 1)),
                        const SizedBox(height: 4),
                        Text(
                            '${w['temp_min'] ?? w['temp']}° low · ${w['temp_max'] ?? w['temp']}° high',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.udoTextSecondary)),
                      ]),
                  const Spacer(),
                  Icon(_icon(w['condition'] as String?),
                      size: 72, color: Colors.orange),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  _WeatherStat(Icons.umbrella_outlined, 'Rain',
                      '${w['rain_chance_pct']}%'),
                  _WeatherStat(
                      Icons.air_outlined, 'Wind', '${w['wind_mph']} mph'),
                  _WeatherStat(
                      Icons.cloud_outlined, 'Clouds', '${w['clouds_pct']}%'),
                  if (sunset != null)
                    _WeatherStat(Icons.wb_twilight_outlined, 'Sunset', sunset),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            const Text('Hourly forecast',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ...((w['hourly'] as List?)?.cast<Map<String, dynamic>>() ?? [])
                .map((h) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppTheme.udoCardFill,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                          '${h['time']} — ${h['temp']}° ${h['condition']}',
                          style: const TextStyle(fontSize: 13)),
                    )),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppTheme.udoPastelCrimson.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppTheme.udoPastelCrimson.withValues(alpha: 0.4))),
              child: Text(_advisory(w),
                  style: const TextStyle(fontSize: 13, height: 1.5)),
            ),
            ...[
              const SizedBox(height: 12),
              const Text('Weather Recommendations',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              ..._weatherRecommendations(w).map((rec) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: rec.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(rec.icon, color: rec.color, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(rec.title,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                Text(rec.subtitle,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.udoTextSecondary,
                                        height: 1.35)),
                              ])),
                        ]),
                  )),
            ],
          ],
        ])),
        if (weddingDayAvailable) ...[
          const SizedBox(height: 12),
          _TimelineWeatherRiskCard(risks: timelineRisks),
        ],
        if (currentWeather != null) ...[
          const SizedBox(height: 12),
          _Card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Current venue weather',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppTheme.udoCardFill,
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    Icon(_icon(currentWeather['condition'] as String?),
                        color: AppTheme.udoGreen, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                              '${currentWeather['temp']}° · ${currentWeather['description'] ?? currentWeather['condition']}',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          Text(
                              '${currentWeather['rain_chance_pct']}% chance of rain',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.udoTextSecondary)),
                        ])),
                  ]),
                ),
              ])),
        ],
      ],
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _WeatherStat(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Expanded(
          child: Column(children: [
        Icon(icon, color: AppTheme.udoGreen, size: 28),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.udoTextSecondary)),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ]));
}

// ── UPDATES TAB ────────────────────────────────────────────────────────────────

class _TimelineWeatherRiskCard extends StatelessWidget {
  final List<Map<String, dynamic>> risks;
  const _TimelineWeatherRiskCard({required this.risks});

  @override
  Widget build(BuildContext context) => _Card(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.warning_amber_outlined,
              color: AppTheme.udoCrimson, size: 20),
          const SizedBox(width: 8),
          const Expanded(
              child: Text('Timeline weather alerts',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          UdoBadge(
              label: risks.isEmpty ? 'Clear' : '${risks.length}',
              color: risks.isEmpty ? AppTheme.udoGreen : AppTheme.udoCrimson),
        ]),
        const SizedBox(height: 10),
        if (risks.isEmpty)
          const Text(
              'No weather conflicts detected against the wedding-day timeline right now. Forecasts can change.',
              style: TextStyle(
                  fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.4))
        else
          ...risks.map((risk) {
            final severe = risk['severity'] == 'high';
            final color = severe ? AppTheme.udoCrimson : Colors.orange;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.18))),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(
                    risk['risk_type'] == 'wind'
                        ? Icons.air_outlined
                        : Icons.umbrella_outlined,
                    color: color,
                    size: 18),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(risk['event_title'] as String? ?? 'Timeline event',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(risk['message'] as String? ?? '',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.udoTextSecondary,
                              height: 1.35)),
                    ])),
              ]),
            );
          }),
      ]));
}

class _WeatherOpsHero extends StatelessWidget {
  final Map<String, dynamic>? weather;
  final String quality;
  final String? advisory;

  const _WeatherOpsHero({
    required this.weather,
    required this.quality,
    required this.advisory,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        color: UdoDesign.live,
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Icon(
              weather == null
                  ? Icons.cloud_off_outlined
                  : Icons.wb_sunny_outlined,
              color: Colors.white,
              size: 46),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                    weather == null
                        ? 'Weather unavailable'
                        : 'Wedding-day weather',
                    style: UdoDesign.sans(
                        size: 15,
                        weight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                    weather == null
                        ? (advisory ?? 'Connect to refresh weather.')
                        : '${weather!['temp']}° on the wedding day. ${advisory ?? 'No advisory.'}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: UdoDesign.sans(
                        size: 12.5, color: Colors.white70, height: 1.4)),
              ])),
        ]),
      );
}

class _UpdatesTab extends ConsumerStatefulWidget {
  final LiveState state;
  const _UpdatesTab({required this.state});

  @override
  ConsumerState<_UpdatesTab> createState() => _UpdatesTabState();
}

const _kUpdateFilters = <String, List<String>>{
  'All': [],
  'Arrivals': ['arrival', 'vip'],
  'Incidents & Alerts': ['incident', 'alert'],
  'Announcements': ['announcement', 'general', 'schedule'],
  'Logistics': ['logistics', 'venue'],
};

class _BroadcastAudienceOption {
  final String value;
  final String label;
  const _BroadcastAudienceOption(this.value, this.label);
}

class _BroadcastChannelOption {
  final String value;
  final String label;
  final IconData icon;
  const _BroadcastChannelOption(this.value, this.label, this.icon);
}

const _broadcastAudiences = [
  _BroadcastAudienceOption('guests', 'All Guests'),
  _BroadcastAudienceOption('vip', 'VIP'),
  _BroadcastAudienceOption('team', 'Wedding Party'),
  _BroadcastAudienceOption('vendors', 'Vendors'),
];

const _broadcastChannels = [
  _BroadcastChannelOption('all', 'All', Icons.all_inbox_outlined),
  _BroadcastChannelOption('sms', 'SMS', Icons.sms_outlined),
  _BroadcastChannelOption('whatsapp', 'WhatsApp', Icons.chat_outlined),
  _BroadcastChannelOption('email', 'Email', Icons.email_outlined),
];

const _broadcastTemplates = [
  (
    icon: Icons.celebration_outlined,
    message:
        'Reception doors opening in 15 minutes — please make your way to the Grand Ballroom.'
  ),
  (
    icon: Icons.directions_bus_outlined,
    message: 'Shuttle departing in 10 minutes from the main entrance.'
  ),
  (
    icon: Icons.restaurant_outlined,
    message: 'Dinner is now being served. Please take your seats.'
  ),
  (
    icon: Icons.photo_camera_outlined,
    message: 'Group photo in 5 minutes on the garden terrace.'
  ),
];

bool _channelSelected(Set<String> selected, String value) =>
    value == 'all' ? selected.length == 3 : selected.contains(value);

String _deliveryLabel(Set<String> selected) {
  if (selected.length == 3) return 'all channels';
  return selected.map((value) {
    if (value == 'sms') return 'SMS';
    if (value == 'whatsapp') return 'WhatsApp';
    return 'email';
  }).join(', ');
}

String _audienceLabel(String value) => _broadcastAudiences
    .firstWhere((option) => option.value == value,
        orElse: () => _broadcastAudiences.first)
    .label;

String _defaultBroadcastSubject(Map<String, dynamic>? wedding) {
  if (wedding == null) return 'Wedding Broadcast';
  final primary = (wedding['couple_name_primary'] ??
          wedding['partner_one_name'] ??
          wedding['bride_name'])
      ?.toString()
      .trim();
  final secondary = (wedding['couple_name_secondary'] ??
          wedding['partner_two_name'] ??
          wedding['groom_name'])
      ?.toString()
      .trim();
  if (primary != null &&
      primary.isNotEmpty &&
      secondary != null &&
      secondary.isNotEmpty) {
    return "$primary and $secondary's Wedding Broadcast";
  }
  final coupleName = wedding['couple_name']?.toString().trim();
  if (coupleName != null && coupleName.isNotEmpty) {
    return "$coupleName Wedding Broadcast";
  }
  final title = wedding['title']?.toString().trim();
  if (title != null && title.isNotEmpty) {
    return '$title Broadcast';
  }
  return 'Wedding Broadcast';
}

class _UpdatesTabState extends ConsumerState<_UpdatesTab> {
  final _ctrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageFieldKey = GlobalKey();
  bool _sending = false;
  String _filter = 'All';
  String _audience = 'guests';
  final Set<String> _deliveryChannels = {'sms', 'whatsapp', 'email'};
  bool _subjectSeeded = false;

  Future<void> _send() async {
    if (_ctrl.text.trim().isEmpty || _subjectCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    final ok = await ref.read(liveProvider.notifier).post(
          title: _subjectCtrl.text.trim(),
          body: _ctrl.text.trim(),
          audience: _audience,
          type: 'announcement',
          deliveryChannels: _deliveryChannels.toList()..sort(),
        );
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) _ctrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? 'Broadcast sent via ${_deliveryLabel(_deliveryChannels)}.'
            : "Couldn't send that update. Try again.")));
  }

  void _toggleDelivery(String value) {
    setState(() {
      if (value == 'all') {
        _deliveryChannels
          ..clear()
          ..addAll(['sms', 'whatsapp', 'email']);
        return;
      }
      if (_deliveryChannels.contains(value)) {
        if (_deliveryChannels.length > 1) _deliveryChannels.remove(value);
      } else {
        _deliveryChannels.add(value);
      }
    });
  }

  void _useTemplate(String message) {
    setState(() {
      _ctrl.text = message;
      _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Template added to your message below.'),
        duration: Duration(seconds: 2)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fieldContext = _messageFieldKey.currentContext;
      if (fieldContext != null) {
        Scrollable.ensureVisible(fieldContext,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: 0.1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final wedding = ref.watch(moreOperationsProvider).activeWedding;
    if (!_subjectSeeded) {
      _subjectCtrl.text = _defaultBroadcastSubject(wedding);
      _subjectSeeded = true;
    }
    final types = _kUpdateFilters[_filter]!;
    final filteredUpdates = types.isEmpty
        ? state.updates
        : state.updates
            .where((u) => types.contains(u['type'] as String?))
            .toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _BroadcastOpsHero(
          totalUpdates: state.updates.length,
          filter: _filter,
          sending: _sending,
        ),
        const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Quick templates',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ..._broadcastTemplates.map((template) => _BroadcastTemplateRow(
                icon: template.icon,
                message: template.message,
                onTap: () => _useTemplate(template.message),
              )),
        ])),
        const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Send update',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          const Text('Subject',
              style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.udoTextSecondary,
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _subjectCtrl,
            decoration: InputDecoration(
              hintText: 'Wedding broadcast subject',
              hintStyle: const TextStyle(
                  color: AppTheme.udoTextSecondary, fontSize: 14),
              filled: true,
              fillColor: AppTheme.udoCardFill,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Audience',
              style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.udoTextSecondary,
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final option in _broadcastAudiences)
              ChoiceChip(
                label: Text(option.label, style: const TextStyle(fontSize: 12)),
                selected: _audience == option.value,
                onSelected: (_) => setState(() => _audience = option.value),
                selectedColor: AppTheme.udoGreen,
                labelStyle: TextStyle(
                    color: _audience == option.value
                        ? Colors.white
                        : AppTheme.udoTextPrimary),
                side: BorderSide(
                    color: _audience == option.value
                        ? AppTheme.udoGreen
                        : AppTheme.udoBorder),
              ),
          ]),
          const SizedBox(height: 14),
          const Text('Send by',
              style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.udoTextSecondary,
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final option in _broadcastChannels)
              FilterChip(
                avatar: Icon(option.icon,
                    size: 16,
                    color: _channelSelected(_deliveryChannels, option.value)
                        ? Colors.white
                        : AppTheme.udoGreen),
                label: Text(option.label, style: const TextStyle(fontSize: 12)),
                selected: _channelSelected(_deliveryChannels, option.value),
                onSelected: (_) => _toggleDelivery(option.value),
                selectedColor: AppTheme.udoGreen,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                    color: _channelSelected(_deliveryChannels, option.value)
                        ? Colors.white
                        : AppTheme.udoTextPrimary),
                side: BorderSide(
                    color: _channelSelected(_deliveryChannels, option.value)
                        ? AppTheme.udoGreen
                        : AppTheme.udoBorder),
              ),
          ]),
          const SizedBox(height: 14),
          TextField(
            key: _messageFieldKey,
            controller: _ctrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write a message to your guests...',
              hintStyle: const TextStyle(
                  color: AppTheme.udoTextSecondary, fontSize: 14),
              filled: true,
              fillColor: AppTheme.udoCardFill,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _sending ? null : _send,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: AppTheme.udoGreen,
                foregroundColor: Colors.white),
            child: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text('Send to ${_audienceLabel(_audience)}'),
          ),
        ])),
        const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Recent updates',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final label in _kUpdateFilters.keys)
              ChoiceChip(
                label: Text(label, style: const TextStyle(fontSize: 12)),
                selected: _filter == label,
                onSelected: (_) => setState(() => _filter = label),
                selectedColor: AppTheme.udoGreen,
                labelStyle: TextStyle(
                    color: _filter == label
                        ? Colors.white
                        : AppTheme.udoTextPrimary),
                side: BorderSide(
                    color: _filter == label
                        ? AppTheme.udoGreen
                        : AppTheme.udoBorder),
              ),
          ]),
          const SizedBox(height: 12),
          if (state.updatesError != null)
            Text(state.updatesError!,
                style:
                    const TextStyle(color: AppTheme.udoCrimson, fontSize: 12))
          else if (filteredUpdates.isEmpty)
            Text(
                state.updates.isEmpty
                    ? 'No updates yet.'
                    : 'No updates in this category yet.',
                style: const TextStyle(
                    color: AppTheme.udoTextSecondary, fontSize: 13))
          else
            ...filteredUpdates.take(10).map((u) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppTheme.udoCardFill,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u['title'] as String? ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 14)),
                        if (u['body'] != null) ...[
                          const SizedBox(height: 4),
                          Text(u['body'] as String,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.udoTextSecondary))
                        ],
                        const SizedBox(height: 4),
                        Text(_timeAgo(u['created_at'] as String?),
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.udoTextSecondary)),
                      ]),
                )),
        ])),
      ],
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _subjectCtrl.dispose();
    super.dispose();
  }
}

class _BroadcastOpsHero extends StatelessWidget {
  final int totalUpdates;
  final String filter;
  final bool sending;

  const _BroadcastOpsHero({
    required this.totalUpdates,
    required this.filter,
    required this.sending,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        color: UdoDesign.live,
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(sending ? Icons.sync : Icons.campaign_outlined,
                color: Colors.white, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(sending ? 'Broadcast sending' : 'Broadcast centre',
                    style: UdoDesign.sans(
                        size: 15,
                        weight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text('$totalUpdates live updates shared. Viewing $filter.',
                    style: UdoDesign.sans(
                        size: 12.5, color: Colors.white70, height: 1.4)),
              ])),
        ]),
      );
}

class _BroadcastTemplateRow extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onTap;

  const _BroadcastTemplateRow({
    required this.icon,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppTheme.udoCardFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.udoBorder)),
            child: Row(children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.udoBorder)),
                child: Icon(icon, color: AppTheme.udoGreen, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(message,
                      style: const TextStyle(fontSize: 12.5, height: 1.3))),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right,
                  color: AppTheme.udoTextSecondary, size: 18),
            ]),
          ),
        ),
      );
}

class _TeamTab extends ConsumerWidget {
  final LiveState state;
  const _TeamTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = state.today;
    final vendors = today?['vendors'] as Map<String, dynamic>?;
    final vendorRoster =
        (vendors?['roster'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final party = ref.watch(weddingPartyProvider);
    final responsibilities = party.responsibilities;
    final openResponsibilities =
        responsibilities.where((r) => r['status'] != 'done').toList();
    final completedResponsibilities =
        responsibilities.where((r) => r['status'] == 'done').length;
    final delayedResponsibilities = responsibilities
        .where((r) =>
            r['status'] != 'done' &&
            (r['priority'] == 'high' || _isPastDue(r['due_date'] as String?)))
        .length;
    final timelineAssignments =
        (state.timeline.isNotEmpty ? state.timeline : party.timelineItems)
            .where(_hasTeamAssignment)
            .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Team command',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(children: [
            _TeamStat('${openResponsibilities.length}', 'Active'),
            _TeamStat('$delayedResponsibilities', 'Delayed'),
            _TeamStat('$completedResponsibilities', 'Complete'),
          ]),
        ])),
        const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Timeline assignments',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (timelineAssignments.isEmpty)
            const Text('No timeline assignments added yet.',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
          else
            ...timelineAssignments
                .take(10)
                .map((item) => _LiveTeamAssignmentRow(item: item)),
        ])),
        const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Assigned responsibilities',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (responsibilities.isEmpty)
            const Text('No responsibilities assigned yet.',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
          else
            ...openResponsibilities
                .take(12)
                .map((task) => _LiveResponsibilityRow(task: task)),
          if (responsibilities.isNotEmpty && openResponsibilities.isEmpty)
            const Text('All assigned responsibilities are complete.',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
        ])),
        const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Wedding party roster',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (party.members.isEmpty)
            const Text('No wedding party members loaded yet.',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
          else
            ...party.members.take(12).map((member) => _SupportRow(
                  name: _guestDisplayName(member, fallback: 'Team member'),
                  detail: member['role'] as String? ?? '',
                  phone: member['phone'] as String?,
                )),
        ])),
        const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Vendor check-ins',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (vendorRoster.isEmpty)
            const Text('No vendor check-in roster available yet.',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
          else
            ...vendorRoster.take(12).map((vendor) => _CheckInRow(
                  name: vendor['name'] as String? ?? 'Vendor',
                  subtitle: vendor['category'] as String? ?? '',
                  checkedIn: vendor['checked_in_at'] != null,
                  onCheckIn: () => ref
                      .read(liveProvider.notifier)
                      .checkInVendor(vendor['id'] as int),
                )),
        ])),
      ],
    );
  }
}

bool _hasTeamAssignment(Map<String, dynamic> item) {
  final vendors = item['assigned_vendors'];
  final groups = item['guest_groups'];
  return vendors is List && vendors.isNotEmpty ||
      groups is List && groups.isNotEmpty;
}

bool _isPastDue(String? date) {
  if (date == null || date.isEmpty) return false;
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return false;
  return parsed.isBefore(DateTime.now());
}

String _guestDisplayName(Map<String, dynamic> guest,
    {String fallback = 'Assigned guest'}) {
  final name = guest['name']?.toString().trim();
  if (name != null && name.isNotEmpty) return name;
  final first = guest['first_name']?.toString().trim() ?? '';
  final last = guest['last_name']?.toString().trim() ?? '';
  final combined = '$first $last'.trim();
  return combined.isEmpty ? fallback : combined;
}

class _LiveTeamAssignmentRow extends StatelessWidget {
  final Map<String, dynamic> item;
  const _LiveTeamAssignmentRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final vendors = (item['assigned_vendors'] as List? ?? [])
        .map((v) => v.toString())
        .where((v) => v.isNotEmpty)
        .toList();
    final groups = (item['guest_groups'] as List? ?? [])
        .map((g) => g.toString())
        .where((g) => g.isNotEmpty)
        .toList();
    final detail = [
      if (vendors.isNotEmpty) 'Vendors: ${vendors.join(', ')}',
      if (groups.isNotEmpty) 'Groups: ${groups.join(', ')}',
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.timeline_outlined, color: AppTheme.udoGreen, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['title'] as String? ?? 'Timeline item',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
              '${_formatTime(item['start_time'] as String?)}${(item['location'] as String?)?.isNotEmpty == true ? ' · ${item['location']}' : ''}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary)),
          if (detail.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(detail,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.udoTextSecondary,
                    height: 1.35)),
          ],
        ])),
      ]),
    );
  }
}

class _LiveResponsibilityRow extends StatelessWidget {
  final Map<String, dynamic> task;
  const _LiveResponsibilityRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final guest = task['guest'] is Map
        ? Map<String, dynamic>.from(task['guest'] as Map)
        : null;
    final status = task['status'] as String? ?? 'pending';
    final color = status == 'done'
        ? AppTheme.udoGreen
        : status == 'in_progress'
            ? Colors.orange
            : AppTheme.udoTextSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.assignment_turned_in_outlined, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(task['title'] as String? ?? 'Responsibility',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
              guest == null
                  ? 'Unassigned'
                  : _guestDisplayName(guest, fallback: 'Assigned guest'),
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary)),
          if ((task['description'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(task['description'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.udoTextSecondary,
                    height: 1.35)),
          ],
        ])),
        UdoBadge(
            label: status == 'in_progress'
                ? 'In progress'
                : status == 'done'
                    ? 'Done'
                    : 'Pending',
            color: color),
      ]),
    );
  }
}

class _EmergencyTab extends ConsumerWidget {
  final LiveState state;
  const _EmergencyTab({required this.state});

  void _openEmergencyComposer(BuildContext context, WidgetRef ref) {
    final memberCount = ref.read(weddingPartyProvider).members.length;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BuzzComposerSheet(
        initialUrgent: true,
        recipientCount: memberCount,
        onSend: (body, channel, urgent) => ref
            .read(weddingPartyProvider.notifier)
            .sendBuzz(body: body, channel: channel),
      ),
    );
  }

  void _openAddEmergencyContact(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _LiveAddEmergencyContactSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = state.today;
    final contacts =
        (today?['emergency_contacts'] as List?)?.cast<Map<String, dynamic>>() ??
            [];
    final incidents =
        (today?['incidents'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final status = today?['status'] as Map<String, dynamic>?;
    final unresolved =
        (status?['unresolved_incidents'] as num?)?.toInt() ?? incidents.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.udoPastelCrimson.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppTheme.udoCrimson.withValues(alpha: 0.22)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.emergency_outlined, color: AppTheme.udoCrimson),
              const SizedBox(width: 10),
              Expanded(
                  child: Text('Emergency operations',
                      style: UdoDesign.sans(
                          size: 16,
                          weight: FontWeight.w800,
                          color: AppTheme.udoCrimson))),
              UdoBadge(
                  label: unresolved == 0 ? 'Ready' : '$unresolved open',
                  color: AppTheme.udoCrimson),
            ]),
            const SizedBox(height: 10),
            Text(
                'Send an urgent team broadcast, call key contacts, and review active live issues from one place.',
                style: UdoDesign.sans(
                    size: 12.5, color: UdoDesign.sub, height: 1.45)),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => _openEmergencyComposer(context, ref),
              icon: const Icon(Icons.campaign_outlined, size: 18),
              label: const Text('Send emergency broadcast'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: AppTheme.udoCrimson,
                  foregroundColor: Colors.white),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _openAddEmergencyContact(context),
              icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
              label: const Text('Add emergency contact'),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  foregroundColor: AppTheme.udoCrimson,
                  side: const BorderSide(color: AppTheme.udoCrimson)),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Active issues',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (incidents.isEmpty)
            const Text('No active incidents right now.',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
          else
            ...incidents.map((incident) => _AlertRow(
                  icon: Icons.report_problem_outlined,
                  title: incident['title'] as String? ?? 'Live issue',
                  detail: incident['body'] as String? ??
                      incident['severity'] as String? ??
                      '',
                  color: AppTheme.udoCrimson,
                )),
        ])),
        const SizedBox(height: 12),
        _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(
              child: Text('Emergency contacts',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            TextButton.icon(
              onPressed: () => _openAddEmergencyContact(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
            ),
          ]),
          const SizedBox(height: 12),
          if (contacts.isEmpty)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('No emergency contacts added yet.',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.udoTextSecondary)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _openAddEmergencyContact(context),
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                label: const Text('Add emergency contact'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 46),
                    backgroundColor: AppTheme.udoCrimson,
                    foregroundColor: Colors.white),
              ),
            ])
          else
            ...contacts.map((contact) => _SupportRow(
                  name: contact['name'] as String? ?? 'Emergency contact',
                  detail: contact['relationship'] as String? ?? '',
                  phone: contact['phone'] as String?,
                )),
        ])),
      ],
    );
  }
}

class _LiveAddEmergencyContactSheet extends ConsumerStatefulWidget {
  const _LiveAddEmergencyContactSheet();

  @override
  ConsumerState<_LiveAddEmergencyContactSheet> createState() =>
      _LiveAddEmergencyContactSheetState();
}

class _LiveAddEmergencyContactSheetState
    extends ConsumerState<_LiveAddEmergencyContactSheet> {
  final _name = TextEditingController();
  final _relationship = TextEditingController();
  final _phone = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final ok =
        await ref.read(weddingPartyProvider.notifier).addEmergencyContact(
              name: _name.text.trim(),
              relationship: _relationship.text.trim(),
              phone: _phone.text.trim(),
            );
    if (ok) await ref.read(liveProvider.notifier).refresh();
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emergency contact added.')));
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Couldn't save this contact. Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(
                  child: Text('Add emergency contact',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600))),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero),
            ]),
            const SizedBox(height: 16),
            _LiveContactField('Name', _name),
            const SizedBox(height: 12),
            _LiveContactField('Relationship', _relationship,
                hint: 'Venue coordinator, doctor, security'),
            const SizedBox(height: 12),
            _LiveContactField('Phone', _phone, type: TextInputType.phone),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: AppTheme.udoCrimson,
                  foregroundColor: Colors.white),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.person_add_alt_1_outlined, size: 18),
              label: Text(_saving ? 'Adding contact...' : 'Add contact'),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _relationship.dispose();
    _phone.dispose();
    super.dispose();
  }
}

class _LiveContactField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? type;

  const _LiveContactField(this.label, this.controller, {this.hint, this.type});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
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
                  const BorderSide(color: AppTheme.udoCrimson, width: 1.4)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      );
}

class _TeamStat extends StatelessWidget {
  final String value;
  final String label;
  const _TeamStat(this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(
          child: Column(children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.udoGreen)),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.udoTextSecondary)),
      ]));
}

class _SupportRow extends StatelessWidget {
  final String name;
  final String detail;
  final String? phone;
  const _SupportRow({required this.name, required this.detail, this.phone});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.udoCardFill,
            borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                if (detail.isNotEmpty)
                  Text(detail,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.udoTextSecondary)),
                if ((phone ?? '').isNotEmpty)
                  Text(phone!,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.udoTextSecondary)),
              ])),
          GestureDetector(
              onTap: () => _launchTel(context, phone),
              child: const Icon(Icons.phone_outlined,
                  color: AppTheme.udoGreen, size: 18)),
          const SizedBox(width: 12),
          GestureDetector(
              onTap: () => _launchSms(context, phone),
              child: const Icon(Icons.message_outlined,
                  color: AppTheme.udoGreen, size: 18)),
        ]),
      );
}

// ── SHARED WIDGETS ─────────────────────────────────────────────────────────────

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

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.udoBorder),
        ),
        child: child,
      );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.udoTextSecondary))),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppTheme.udoTextPrimary)),
      ]);
}

class _AlertRow extends StatelessWidget {
  final IconData icon;
  final String title, detail;
  final Color color;
  const _AlertRow(
      {required this.icon,
      required this.title,
      required this.detail,
      required this.color});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                if (detail.isNotEmpty)
                  Text(detail,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.udoTextSecondary,
                          height: 1.4)),
              ])),
        ]),
      );
}

class _DayStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _DayStat(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: color)),
      ]);
}
