import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
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
  final dateStr = item['event_date'] as String?;
  final startTime = item['start_time'] as String?;
  if (dateStr == null || startTime == null) return '';
  final date = DateTime.tryParse(dateStr);
  if (date == null) return '';
  final parts = startTime.split(':');
  final target = DateTime(date.year, date.month, date.day, int.tryParse(parts[0]) ?? 0, int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
  final diff = target.difference(DateTime.now());
  if (diff.isNegative) return 'now';
  if (diff.inDays >= 1) return 'in ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
  if (diff.inMinutes < 60) return 'in ${diff.inMinutes} min';
  final hours = diff.inHours;
  final mins = diff.inMinutes % 60;
  return mins > 0 ? 'in $hours hr $mins min' : 'in $hours hr';
}

Future<void> _launchTel(BuildContext context, String? phone) async {
  if (phone == null || phone.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No phone number on file.')));
    return;
  }
  await launchUrl(Uri.parse('tel:$phone'));
}

Future<void> _launchSms(BuildContext context, String? phone) async {
  if (phone == null || phone.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No phone number on file.')));
    return;
  }
  await launchUrl(Uri.parse('sms:$phone'));
}

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});
  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  Timer? _autoRefresh;

  static const _tabLabels = ['Today', 'Timeline', 'Map', 'Weather', 'Updates'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
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
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _Header(tabs: _tabs, tabLabels: _tabLabels),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      RefreshIndicator(onRefresh: notifier.refresh, child: _TodayTab(state: state, onUpdatesTap: () => _tabs.animateTo(4))),
                      RefreshIndicator(onRefresh: notifier.refresh, child: _TimelineTab(state: state)),
                      RefreshIndicator(onRefresh: notifier.refresh, child: _MapTab(state: state)),
                      RefreshIndicator(onRefresh: notifier.refresh, child: _WeatherTab(state: state)),
                      RefreshIndicator(onRefresh: notifier.refresh, child: _UpdatesTab(state: state)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _Header extends StatelessWidget {
  final TabController tabs;
  final List<String> tabLabels;
  const _Header({required this.tabs, required this.tabLabels});

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.radio, color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    const Text('Live', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  ]),
                  const SizedBox(height: 4),
                  const Text('Your day, gently guided', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 12),
                  const Text(
                    'Everything is flowing beautifully today.',
                    style: TextStyle(color: Colors.white, fontFamily: 'Playfair', fontSize: 22, fontWeight: FontWeight.w400, height: 1.35),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            TabBar(
              controller: tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              tabs: tabLabels.map((l) => Tab(text: l)).toList(),
              labelColor: AppTheme.udoGreen,
              unselectedLabelColor: Colors.white,
              indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.symmetric(vertical: 4),
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              dividerColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

// ── TODAY TAB ──────────────────────────────────────────────────────────────────

class _TodayTab extends StatelessWidget {
  final LiveState state;
  final VoidCallback onUpdatesTap;

  const _TodayTab({required this.state, required this.onUpdatesTap});

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final timeStr = now.format(context);
    final today = state.today;
    final guests = today?['guests'] as Map<String, dynamic>?;
    final vendors = today?['vendors'] as Map<String, dynamic>?;
    final gallery = today?['gallery'] as Map<String, dynamic>?;
    final timelineData = today?['timeline'] as Map<String, dynamic>?;
    final current = timelineData?['current'] as Map<String, dynamic>?;
    final next = timelineData?['next'] as Map<String, dynamic>?;
    final recentUpdates = (today?['recent_updates'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final contacts = (today?['emergency_contacts'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    if (state.todayError != null) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        const SizedBox(height: 60),
        _errorBox("Couldn't load today's overview.", state.todayError!),
      ]);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GestureDetector(
          onTap: onUpdatesTap,
          child: _Card(child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFF22C55E).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline, color: Color(0xFF22C55E), size: 20),
            ),
            const SizedBox(width: 14),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('No action needed right now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              SizedBox(height: 2),
              Text('Tap to see the latest updates.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.4)),
            ])),
          ])),
        ),
        const SizedBox(height: 12),

        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Right now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          _InfoRow('Current time', timeStr),
          const Divider(height: 20),
          _InfoRow('Current moment', current != null ? current['title'] as String? ?? '' : (next != null ? 'Next: ${next['title']}' : 'No events scheduled')),
          const Divider(height: 20),
          _InfoRow('Guests confirmed', '${guests?['confirmed'] ?? 0} of ${guests?['invited'] ?? 0}', valueColor: AppTheme.udoGreen),
        ])),
        const SizedBox(height: 12),

        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Happening now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            const Text('Live', style: TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
          ]),
          const SizedBox(height: 12),
          if (recentUpdates.isEmpty)
            const Text('No updates shared yet.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
          else
            ...recentUpdates.map((u) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppTheme.udoBorder)),
                    child: const Icon(Icons.campaign_outlined, color: AppTheme.udoGreen, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(u['title'] as String? ?? '', style: const TextStyle(fontSize: 13, height: 1.4)),
                    Text(_timeAgo(u['created_at'] as String?), style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
                  ])),
                ]),
              ),
            )),
        ])),
        const SizedBox(height: 12),

        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Coming up next', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          if (next == null)
            const Text('Nothing else scheduled today.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
          else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(next['title'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  Text(_formatTime(next['start_time'] as String?), style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
                ])),
                Text(_countdownTo(next), style: const TextStyle(color: AppTheme.udoGreen, fontWeight: FontWeight.w500, fontSize: 13)),
              ]),
            ),
        ])),
        const SizedBox(height: 12),

        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Vendor readiness', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text('${vendors?['confirmed'] ?? 0} of ${vendors?['total'] ?? 0} vendors confirmed', style: const TextStyle(fontSize: 13))),
            ]),
          ),
        ])),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.udoPastelCrimson.withValues(alpha: 0.2), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.udoPastelCrimson.withValues(alpha: 0.5)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.auto_awesome, color: AppTheme.udoCrimson, size: 18),
              const SizedBox(width: 8),
              const Text('Your day so far', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ]),
            const SizedBox(height: 12),
            _DayStat(Icons.camera_alt_outlined, 'Photos captured', '${gallery?['photos'] ?? 0}', AppTheme.udoGreen),
            const SizedBox(height: 8),
            _DayStat(Icons.campaign_outlined, 'Updates shared', '${state.updates.length}', AppTheme.udoCrimson),
            const SizedBox(height: 8),
            _DayStat(Icons.people_outline, 'Guests confirmed', '${guests?['confirmed'] ?? 0}', const Color(0xFF22C55E)),
          ]),
        ),
        const SizedBox(height: 12),

        _Card(child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(state.weather != null ? '${state.weather!['temp']}°' : '—', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w500, height: 1)),
            const SizedBox(height: 4),
            Text(state.weather?['condition'] as String? ?? (state.weatherMessage ?? 'Weather unavailable'), style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
          ])),
          Icon(_weatherIcon(state.weather?['condition'] as String?), size: 56, color: Colors.orange),
        ])),
        const SizedBox(height: 12),

        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Your support team', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          if (contacts.isEmpty)
            const Text('No emergency contacts added yet. Add them from Wedding Party → Emergency.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
          else
            ...contacts.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c['name'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  Text(c['relationship'] as String? ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                  Text(c['phone'] as String? ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                ])),
                Row(children: [
                  GestureDetector(onTap: () => _launchTel(context, c['phone'] as String?), child: const Icon(Icons.phone_outlined, color: AppTheme.udoGreen, size: 18)),
                  const SizedBox(width: 10),
                  GestureDetector(onTap: () => _launchSms(context, c['phone'] as String?), child: const Icon(Icons.message_outlined, color: AppTheme.udoGreen, size: 18)),
                ]),
              ]),
            )),
        ])),
        const SizedBox(height: 24),
        const Center(child: Text(
          'Today is yours.',
          style: TextStyle(fontFamily: 'Playfair', fontSize: 16, fontStyle: FontStyle.italic, height: 1.5),
          textAlign: TextAlign.center,
        )),
        const SizedBox(height: 6),
        const Center(child: Text('Just enjoy this moment.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary))),
        const SizedBox(height: 24),
      ],
    );
  }

  IconData _weatherIcon(String? condition) {
    switch ((condition ?? '').toLowerCase()) {
      case 'rain': case 'drizzle': case 'thunderstorm': return Icons.umbrella_outlined;
      case 'clouds': return Icons.cloud_outlined;
      case 'snow': return Icons.ac_unit_outlined;
      default: return Icons.wb_sunny_outlined;
    }
  }
}

// ── TIMELINE TAB ───────────────────────────────────────────────────────────────

class _TimelineTab extends StatelessWidget {
  final LiveState state;
  const _TimelineTab({required this.state});

  String _statusFor(Map<String, dynamic> item) {
    final dateStr = item['event_date'] as String?;
    final startTime = item['start_time'] as String?;
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    if (date == null) return 'upcoming';

    final today = DateTime.now();
    final itemDate = DateTime(date.year, date.month, date.day);
    final now = DateTime(today.year, today.month, today.day);
    if (itemDate.isBefore(now)) return 'completed';
    if (itemDate.isAfter(now)) return 'upcoming';

    if (startTime == null) return 'upcoming';
    final parts = startTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final nowTod = TimeOfDay.now();
    if (hour < nowTod.hour || (hour == nowTod.hour && minute <= nowTod.minute)) return 'completed';
    if (hour == nowTod.hour) return 'in-progress';
    return 'upcoming';
  }

  @override
  Widget build(BuildContext context) {
    final timeline = state.timeline;

    if (state.timelineError != null) {
      return ListView(padding: const EdgeInsets.all(16), children: [const SizedBox(height: 60), _errorBox("Couldn't load your timeline.", state.timelineError!)]);
    }

    if (timeline.isEmpty) {
      return ListView(children: const [
        SizedBox(height: 120),
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.calendar_today_outlined, size: 48, color: AppTheme.udoTextSecondary),
            SizedBox(height: 12),
            Text('No schedule yet', style: TextStyle(color: AppTheme.udoTextSecondary, fontSize: 15)),
            SizedBox(height: 4),
            Text('Add events in the Plan section', style: TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13)),
          ]),
        ),
      ]);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Full schedule', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          ...timeline.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isLast = i == timeline.length - 1;
            final status = _statusFor(item);
            final timeLabel = _formatTime(item['start_time'] as String?);
            final title = item['title'] as String? ?? '';
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(children: [
                _TimelineDot(status: status),
                if (!isLast) Container(width: 2, height: 48, color: AppTheme.udoBorder),
              ]),
              const SizedBox(width: 14),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(children: [
                  Expanded(child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: status == 'in-progress' ? FontWeight.w600 : FontWeight.w400,
                      color: status == 'completed' ? AppTheme.udoTextSecondary : AppTheme.udoTextPrimary,
                    ),
                  )),
                  const SizedBox(width: 8),
                  Text(timeLabel, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
                ]),
              )),
            ]);
          }),
        ])),
      ],
    );
  }
}

class _TimelineDot extends StatelessWidget {
  final String status;
  const _TimelineDot({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == 'completed') return const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20);
    if (status == 'in-progress') return Container(width: 20, height: 20, decoration: BoxDecoration(color: AppTheme.udoGreen, shape: BoxShape.circle));
    return Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.udoBorder, width: 2)));
  }
}

// ── MAP TAB ────────────────────────────────────────────────────────────────────

class _MapTab extends StatelessWidget {
  final LiveState state;
  const _MapTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final venue = state.venue;
    final lat = venue?['lat'] as num?;
    final lng = venue?['lng'] as num?;
    final resolved = lat != null && lng != null;

    final areas = state.timeline
        .map((t) => t['location'] as String?)
        .where((l) => l != null && l.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Venue location', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 220,
              child: resolved
                  ? FlutterMap(
                      options: MapOptions(initialCenter: LatLng(lat.toDouble(), lng.toDouble()), initialZoom: 15),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.udowedding.app',
                        ),
                        MarkerLayer(markers: [
                          Marker(
                            point: LatLng(lat.toDouble(), lng.toDouble()),
                            width: 40, height: 40,
                            child: const Icon(Icons.location_on, color: AppTheme.udoCrimson, size: 40),
                          ),
                        ]),
                      ],
                    )
                  : Container(
                      color: const Color(0xFFF3EFEA),
                      child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.map_outlined, size: 48, color: AppTheme.udoGreen),
                        SizedBox(height: 8),
                        Text('Add a venue address in Wedding settings\nto see it on the map.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13)),
                      ])),
                    ),
            ),
          ),
          if (resolved && (venue?['venue_name'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(venue!['venue_name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
          if (resolved && (venue?['venue_address'] as String?)?.isNotEmpty == true)
            Text(venue!['venue_address'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          const SizedBox(height: 12),
          if (areas.isEmpty)
            const Text('Add locations to your timeline events to see them listed here.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
          else
            ...areas.map((area) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Expanded(child: Text(area, style: const TextStyle(fontSize: 14))),
                const Icon(Icons.place_outlined, color: AppTheme.udoGreen, size: 18),
              ]),
            )),
        ])),
      ],
    );
  }
}

// ── WEATHER TAB ────────────────────────────────────────────────────────────────

class _WeatherTab extends StatelessWidget {
  final LiveState state;
  const _WeatherTab({required this.state});

  String _advisory(Map<String, dynamic> w) {
    final rain = w['rain_chance_pct'] as num? ?? 0;
    final temp = w['temp'] as num? ?? 70;
    if (rain >= 50) return 'Rain is likely — consider a backup plan or tent for outdoor moments.';
    if (temp >= 90) return 'It\'ll be hot — keep guests hydrated and consider shade for outdoor seating.';
    if (temp <= 50) return 'It\'ll be cool — guests may appreciate blankets or heaters for outdoor areas.';
    if (rain <= 15 && temp >= 65 && temp <= 85) return 'Great conditions for your outdoor plans today.';
    return 'Conditions look manageable — check back closer to the day for updates.';
  }

  IconData _icon(String? condition) {
    switch ((condition ?? '').toLowerCase()) {
      case 'rain': case 'drizzle': case 'thunderstorm': return Icons.umbrella_outlined;
      case 'clouds': return Icons.cloud_outlined;
      case 'snow': return Icons.ac_unit_outlined;
      default: return Icons.wb_sunny_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = state.weather;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Weather forecast', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          if (w == null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                const Icon(Icons.cloud_off_outlined, size: 40, color: AppTheme.udoTextSecondary),
                const SizedBox(height: 10),
                Text(state.weatherMessage ?? 'Weather is currently unavailable.', style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary), textAlign: TextAlign.center),
              ]),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${w['temp']}°', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w500, height: 1)),
                    const SizedBox(height: 4),
                    Text('Feels like ${w['feels_like']}°', style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
                  ]),
                  const Spacer(),
                  Icon(_icon(w['condition'] as String?), size: 72, color: Colors.orange),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  _WeatherStat(Icons.umbrella_outlined, 'Rain', '${w['rain_chance_pct']}%'),
                  _WeatherStat(Icons.air_outlined, 'Wind', '${w['wind_mph']} mph'),
                  _WeatherStat(Icons.cloud_outlined, 'Clouds', '${w['clouds_pct']}%'),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            const Text('Hourly forecast', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ...((w['hourly'] as List?)?.cast<Map<String, dynamic>>() ?? []).map((h) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
              child: Text('${h['time']} — ${h['temp']}° ${h['condition']}', style: const TextStyle(fontSize: 13)),
            )),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppTheme.udoPastelCrimson.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoPastelCrimson.withValues(alpha: 0.4))),
              child: Text(_advisory(w), style: const TextStyle(fontSize: 13, height: 1.5)),
            ),
          ],
        ])),
      ],
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _WeatherStat(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Icon(icon, color: AppTheme.udoGreen, size: 28),
    const SizedBox(height: 6),
    Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
    Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
  ]));
}

// ── UPDATES TAB ────────────────────────────────────────────────────────────────

class _UpdatesTab extends ConsumerStatefulWidget {
  final LiveState state;
  const _UpdatesTab({required this.state});

  @override
  ConsumerState<_UpdatesTab> createState() => _UpdatesTabState();
}

class _UpdatesTabState extends ConsumerState<_UpdatesTab> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    final ok = await ref.read(liveProvider.notifier).post(title: _ctrl.text.trim());
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) _ctrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Sent to all guests.' : "Couldn't send that update. Try again.")));
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Send update', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write a message to your guests...',
              hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14),
              filled: true, fillColor: const Color(0xFFF3EFEA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _sending ? null : _send,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
            child: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Send to all guests'),
          ),
        ])),
        const SizedBox(height: 12),
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Recent updates', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          if (state.updatesError != null)
            Text(state.updatesError!, style: const TextStyle(color: AppTheme.udoCrimson, fontSize: 12))
          else if (state.updates.isEmpty)
            const Text('No updates yet.', style: TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13))
          else
            ...state.updates.take(10).map((u) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(u['title'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                if (u['body'] != null) ...[const SizedBox(height: 4), Text(u['body'] as String, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))],
                const SizedBox(height: 4),
                Text(_timeAgo(u['created_at'] as String?), style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
              ]),
            )),
        ])),
      ],
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}

// ── SHARED WIDGETS ─────────────────────────────────────────────────────────────

Widget _errorBox(String title, String message) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 40, color: AppTheme.udoCrimson),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.udoCrimson)),
          const SizedBox(height: 6),
          Text(message, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary), textAlign: TextAlign.center),
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
    Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.udoTextSecondary))),
    Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: valueColor ?? AppTheme.udoTextPrimary)),
  ]);
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
    Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color)),
  ]);
}
