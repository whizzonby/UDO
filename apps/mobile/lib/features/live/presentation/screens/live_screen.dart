import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/live_provider.dart';

class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});
  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  int _guestsArrived = 89;
  bool _contactsExpanded = false;

  static const _tabLabels = ['Today', 'Timeline', 'Map', 'Weather', 'Updates'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _Header(
            tabs: _tabs,
            tabLabels: _tabLabels,
            guestsArrived: _guestsArrived,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _TodayTab(
                  guestsArrived: _guestsArrived,
                  contactsExpanded: _contactsExpanded,
                  onContactsToggle: () => setState(() => _contactsExpanded = !_contactsExpanded),
                  onStatusTap: () {},
                  onUpdatesTap: () => _tabs.animateTo(4),
                ),
                const _TimelineTab(),
                const _MapTab(),
                const _WeatherTab(),
                _UpdatesTab(provider: ref),
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
  final int guestsArrived;
  const _Header({required this.tabs, required this.tabLabels, required this.guestsArrived});

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
                  Text(
                    guestsArrived >= 110
                        ? 'Your loved ones are here, and everything is perfect.'
                        : 'Everything is flowing beautifully today.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Playfair',
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                    ),
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
  final int guestsArrived;
  final bool contactsExpanded;
  final VoidCallback onContactsToggle;
  final VoidCallback onStatusTap;
  final VoidCallback onUpdatesTap;

  const _TodayTab({
    required this.guestsArrived,
    required this.contactsExpanded,
    required this.onContactsToggle,
    required this.onStatusTap,
    required this.onUpdatesTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final timeStr = now.format(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status card
        GestureDetector(
          onTap: onStatusTap,
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
              Text('Your planner and vendors are handling everything.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.4)),
            ])),
          ])),
        ),
        const SizedBox(height: 12),

        // Right now
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Right now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          _InfoRow('Current time', timeStr),
          const Divider(height: 20),
          _InfoRow('Current moment', 'Guests arriving'),
          const Divider(height: 20),
          _InfoRow('Guests present', '$guestsArrived of 120', valueColor: AppTheme.udoGreen),
        ])),
        const SizedBox(height: 12),

        // Happening now
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Happening now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            const Text('Live', style: TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
          ]),
          const SizedBox(height: 12),
          ...[
            (Icons.people_outline, 'Sarah and Michael just arrived', 'Just now', const Color(0xFF22C55E)),
            (Icons.camera_alt_outlined, 'Photographer capturing ceremony details', '2 min ago', AppTheme.udoGreen),
            (Icons.favorite_outline, 'Your parents are greeting guests at entrance', '5 min ago', AppTheme.udoCrimson),
            (Icons.auto_awesome_outlined, 'Final touches on floral arrangements complete', '8 min ago', Colors.orange),
          ].map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppTheme.udoBorder)),
                  child: Icon(item.$1, color: item.$4, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.$2, style: const TextStyle(fontSize: 13, height: 1.4)),
                  Text(item.$3, style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
                ])),
              ]),
            ),
          )),
        ])),
        const SizedBox(height: 12),

        // Coming up next
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Coming up next', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ...[('Ceremony begins', '4:30 PM', 'in 18 minutes'), ('Cocktail hour', '5:15 PM', 'in 1 hr 3 min')].map((i) =>
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(i.$1, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  Text(i.$2, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
                ])),
                Text(i.$3, style: const TextStyle(color: AppTheme.udoGreen, fontWeight: FontWeight.w500, fontSize: 13)),
              ]),
            ),
          ),
        ])),
        const SizedBox(height: 12),

        // Everything in place
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Everything in place', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ...[
            'Florist setup complete', 'Musicians soundcheck done',
            'Catering team ready', 'Photographer capturing pre-ceremony',
          ].map((label) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
              const Text('Ready', style: TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
            ]),
          )),
        ])),
        const SizedBox(height: 12),

        // Your day so far
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
            _DayStat(Icons.camera_alt_outlined, 'Photos captured', '127', AppTheme.udoGreen),
            const SizedBox(height: 8),
            _DayStat(Icons.favorite_outline, 'Well-wishes received', '34', AppTheme.udoCrimson),
            const SizedBox(height: 8),
            _DayStat(Icons.people_outline, 'Loved ones present', '$guestsArrived', const Color(0xFF22C55E)),
          ]),
        ),
        const SizedBox(height: 12),

        // Weather mini
        _Card(child: Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('78°', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500, height: 1)),
            SizedBox(height: 4),
            Text('Partly cloudy', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            SizedBox(height: 8),
            Text('Perfect conditions for your ceremony', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary, height: 1.4)),
          ])),
          const Icon(Icons.wb_sunny_outlined, size: 56, color: Colors.orange),
        ])),
        const SizedBox(height: 12),

        // Support team
        _Card(child: Column(children: [
          GestureDetector(
            onTap: onContactsToggle,
            child: Row(children: [
              const Expanded(child: Text('Your support team', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
              Icon(contactsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppTheme.udoTextSecondary),
            ]),
          ),
          if (contactsExpanded) ...[
            const SizedBox(height: 12),
            ...[
              ('Maria Chen', 'Wedding Planner', '+1 (555) 123-4567'),
              ('John Anderson', 'Venue Manager', '+1 (555) 987-6543'),
              ('Sarah Williams', 'Day-of Coordinator', '+1 (555) 456-7890'),
            ].map((c) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.$1, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  Text(c.$2, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                  Text(c.$3, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                ])),
                Row(children: [
                  Icon(Icons.phone_outlined, color: AppTheme.udoGreen, size: 18),
                  const SizedBox(width: 10),
                  Icon(Icons.message_outlined, color: AppTheme.udoGreen, size: 18),
                ]),
              ]),
            )),
          ],
        ])),
        const SizedBox(height: 24),
        Center(child: Text(
          guestsArrived >= 115 ? 'Everyone who matters is here.' : 'Today is yours.',
          style: const TextStyle(fontFamily: 'Playfair', fontSize: 16, fontStyle: FontStyle.italic, height: 1.5),
          textAlign: TextAlign.center,
        )),
        const SizedBox(height: 6),
        const Center(child: Text('Just enjoy this moment.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary))),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── TIMELINE TAB ───────────────────────────────────────────────────────────────

class _TimelineTab extends ConsumerWidget {
  const _TimelineTab();

  String _statusFor(String? startTime) {
    if (startTime == null) return 'upcoming';
    final parts = startTime.split(':');
    if (parts.length < 2) return 'upcoming';
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final now = TimeOfDay.now();
    if (hour < now.hour || (hour == now.hour && minute <= now.minute)) return 'completed';
    if (hour == now.hour) return 'in-progress';
    return 'upcoming';
  }

  String _formatTime(String? t) {
    if (t == null) return '';
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
    final timeline = ref.watch(liveProvider).timeline;

    if (timeline.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.calendar_today_outlined, size: 48, color: AppTheme.udoTextSecondary),
          SizedBox(height: 12),
          Text('No schedule yet', style: TextStyle(color: AppTheme.udoTextSecondary, fontSize: 15)),
          SizedBox(height: 4),
          Text('Add events in the Plan section', style: TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13)),
        ]),
      );
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
            final status = _statusFor(item['start_time'] as String?);
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
  const _MapTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Venue layout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.map_outlined, size: 56, color: AppTheme.udoGreen),
              SizedBox(height: 8),
              Text('Interactive venue map', style: TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13)),
            ])),
          ),
          const SizedBox(height: 12),
          ...['Ceremony garden', 'Reception hall', 'Cocktail terrace', 'Restrooms', 'Photo area'].map((area) =>
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Expanded(child: Text(area, style: const TextStyle(fontSize: 14))),
                const Icon(Icons.place_outlined, color: AppTheme.udoGreen, size: 18),
              ]),
            ),
          ),
        ])),
      ],
    );
  }
}

// ── WEATHER TAB ────────────────────────────────────────────────────────────────

class _WeatherTab extends StatelessWidget {
  const _WeatherTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Weather forecast', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Row(children: [
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('78°', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w500, height: 1)),
                  SizedBox(height: 4),
                  Text('Feels like 76°', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
                ]),
                const Spacer(),
                const Icon(Icons.wb_sunny_outlined, size: 72, color: Colors.orange),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _WeatherStat(Icons.umbrella_outlined, 'Rain', '10%'),
                _WeatherStat(Icons.air_outlined, 'Wind', '8 mph'),
                _WeatherStat(Icons.cloud_outlined, 'Clouds', '30%'),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          const Text('Hourly forecast', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          ...['4:00 PM — 78° Sunny', '5:00 PM — 76° Partly cloudy', '6:00 PM — 74° Partly cloudy', '7:00 PM — 72° Clear', '8:00 PM — 70° Clear']
            .map((h) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
              child: Text(h, style: const TextStyle(fontSize: 13)),
            )),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.udoPastelCrimson.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoPastelCrimson.withValues(alpha: 0.4))),
            child: const Text('Perfect conditions for your outdoor ceremony. Light breeze will keep guests comfortable.', style: TextStyle(fontSize: 13, height: 1.5)),
          ),
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

class _UpdatesTab extends StatefulWidget {
  final WidgetRef provider;
  const _UpdatesTab({required this.provider});

  @override
  State<_UpdatesTab> createState() => _UpdatesTabState();
}

class _UpdatesTabState extends State<_UpdatesTab> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = widget.provider.watch(liveProvider);
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
            onPressed: () {
              if (_ctrl.text.isNotEmpty) {
                widget.provider.read(liveProvider.notifier).post(title: _ctrl.text);
                _ctrl.clear();
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
            child: const Text('Send to all guests'),
          ),
        ])),
        const SizedBox(height: 12),
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Recent updates', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          if (state.updates.isEmpty)
            const Text('No updates yet.', style: TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13))
          else
            ...state.updates.take(10).map((u) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(u['title'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                if (u['body'] != null) ...[const SizedBox(height: 4), Text(u['body'] as String, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))],
              ]),
            )),
        ])),
      ],
    );
  }
}

// ── SHARED WIDGETS ─────────────────────────────────────────────────────────────

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
