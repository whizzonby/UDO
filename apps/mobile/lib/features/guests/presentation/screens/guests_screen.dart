import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/guests_provider.dart';
import '../providers/logistics_provider.dart';
import '../providers/messages_provider.dart';
import '../providers/experience_provider.dart';
import '../../../../core/network/api_client.dart';

class GuestsScreen extends ConsumerStatefulWidget {
  const GuestsScreen({super.key});
  @override
  ConsumerState<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends ConsumerState<GuestsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _search = '';
  String _statusFilter = 'all';
  bool _quickInviteMode = true;

  static const _tabLabels = ['Overview', 'Guest list', 'Invitations', 'Experience', 'Messages', 'Logistics'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guestsProvider);
    final notifier = ref.read(guestsProvider.notifier);

    return Scaffold(
      body: Column(
        children: [
          _Header(tabs: _tabs, tabLabels: _tabLabels, totalGuests: state.guests.length),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _OverviewTab(state: state, onGoToList: () => _tabs.animateTo(1)),
                _GuestListTab(
                  state: state,
                  search: _search,
                  statusFilter: _statusFilter,
                  onSearchChanged: (v) => setState(() => _search = v),
                  onFilterChanged: (v) => setState(() => _statusFilter = v),
                  onAddGuest: () => _showAddModal(context, notifier),
                  onGuestTap: (g) => _showDetailSheet(context, g),
                ),
                _InvitationsTab(),
                _ExperienceTab(),
                _MessagesTab(),
                _LogisticsTab(state: state),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddModal(context, notifier),
        backgroundColor: AppTheme.udoGreen,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }

  void _showAddModal(BuildContext context, GuestsNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddGuestModal(notifier: notifier, quickMode: _quickInviteMode, onToggleMode: (v) => setState(() => _quickInviteMode = v)),
    );
  }

  void _showDetailSheet(BuildContext context, Map<String, dynamic> guest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _GuestDetailSheet(guest: guest),
    );
  }
}

// ── HEADER ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final TabController tabs;
  final List<String> tabLabels;
  final int totalGuests;
  const _Header({required this.tabs, required this.tabLabels, required this.totalGuests});

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
                const Expanded(child: Text('Guests', style: TextStyle(color: Colors.white, fontFamily: 'Playfair', fontSize: 24, fontWeight: FontWeight.w400))),
                Text('$totalGuests', style: const TextStyle(color: Colors.white70, fontSize: 14)),
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

// ── OVERVIEW TAB ───────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final GuestsState state;
  final VoidCallback onGoToList;
  const _OverviewTab({required this.state, required this.onGoToList});

  @override
  Widget build(BuildContext context) {
    final total = state.guests.length;
    final attending = state.guests.where((g) => g['attending_status'] == 'attending').length;
    final pending = state.guests.where((g) => g['attending_status'] == 'pending' || g['attending_status'] == null).length;
    final declined = state.guests.where((g) => g['attending_status'] == 'not_attending').length;
    final confirmPct = total > 0 ? attending / total : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // RSVP ring card
        _Card(child: Column(children: [
          const Text('RSVP status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          SizedBox(
            width: 160, height: 160,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 160, height: 160,
                child: CircularProgressIndicator(
                  value: confirmPct,
                  strokeWidth: 12,
                  backgroundColor: AppTheme.udoBorder,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.udoGreen),
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('$attending', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: AppTheme.udoGreen)),
                const Text('confirmed', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
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
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Quick actions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _ActionChip(Icons.person_add_outlined, 'Add guest', AppTheme.udoGreen),
            _ActionChip(Icons.upload_file_outlined, 'Import CSV', Colors.indigo),
            _ActionChip(Icons.send_outlined, 'Send invites', AppTheme.udoCrimson),
            _ActionChip(Icons.restaurant_menu_outlined, 'Meal summary', Colors.orange),
            _ActionChip(Icons.flight_outlined, 'Travel overview', Colors.teal),
            _ActionChip(Icons.people_outlined, 'View all', AppTheme.udoTextSecondary, onTap: onGoToList),
          ]),
        ])),
        const SizedBox(height: 12),
        // Recent additions
        if (state.guests.isNotEmpty) _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Recently added', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ...state.guests.take(5).map((g) => _GuestRow(guest: g, onTap: () {})),
        ])),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String text;
  final Color color;
  const _StatChip(this.text, this.color);

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(text.split('\n')[0], style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color)),
    Text(text.split('\n')[1], style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
  ]));
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
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}

// ── GUEST LIST TAB ─────────────────────────────────────────────────────────────

class _GuestListTab extends StatelessWidget {
  final GuestsState state;
  final String search, statusFilter;
  final ValueChanged<String> onSearchChanged, onFilterChanged;
  final VoidCallback onAddGuest;
  final void Function(Map<String, dynamic>) onGuestTap;

  const _GuestListTab({
    required this.state,
    required this.search,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onAddGuest,
    required this.onGuestTap,
  });

  List<Map<String, dynamic>> get _filtered {
    return state.guests.where((g) {
      final name = '${g['first_name']} ${g['last_name']}'.toLowerCase();
      final matchSearch = search.isEmpty || name.contains(search.toLowerCase());
      final status = g['attending_status'] as String? ?? 'pending';
      final matchFilter = statusFilter == 'all' || status == statusFilter;
      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.udoGreen));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search guests...',
              hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: AppTheme.udoTextSecondary, size: 20),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.udoBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.udoBorder)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              for (final (key, label) in [('all', 'All'), ('attending', 'Attending'), ('not_attending', 'Declined'), ('pending', 'Pending'), ('awaiting', 'Awaiting')])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label, style: const TextStyle(fontSize: 13)),
                    selected: statusFilter == key,
                    onSelected: (_) => onFilterChanged(key),
                    selectedColor: AppTheme.udoGreen,
                    labelStyle: TextStyle(color: statusFilter == key ? Colors.white : AppTheme.udoTextPrimary),
                    side: BorderSide(color: statusFilter == key ? AppTheme.udoGreen : AppTheme.udoBorder),
                    checkmarkColor: Colors.white,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('No guests found.', style: TextStyle(color: AppTheme.udoTextSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => _GuestRow(guest: _filtered[i], onTap: () => onGuestTap(_filtered[i])),
                ),
        ),
      ],
    );
  }
}

class _GuestRow extends StatelessWidget {
  final Map<String, dynamic> guest;
  final VoidCallback onTap;
  const _GuestRow({required this.guest, required this.onTap});

  Color get _statusColor {
    switch (guest['attending_status'] as String? ?? 'pending') {
      case 'attending': return const Color(0xFF22C55E);
      case 'not_attending': return AppTheme.udoCrimson;
      default: return Colors.orange;
    }
  }

  String get _statusLabel {
    switch (guest['attending_status'] as String? ?? 'pending') {
      case 'attending': return 'Attending';
      case 'not_attending': return 'Declined';
      case 'awaiting': return 'Awaiting';
      default: return 'Pending';
    }
  }

  String get _initials {
    final f = (guest['first_name'] as String? ?? '').isNotEmpty ? guest['first_name'][0] : '';
    final l = (guest['last_name'] as String? ?? '').isNotEmpty ? guest['last_name'][0] : '';
    return '$f$l'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
      child: Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppTheme.udoGreen.withValues(alpha: 0.1),
          child: Text(_initials, style: const TextStyle(color: AppTheme.udoGreen, fontWeight: FontWeight.w600, fontSize: 14)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${guest['first_name'] ?? ''} ${guest['last_name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          if (guest['email'] != null) Text(guest['email'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(_statusLabel, style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w500)),
        ),
      ]),
    ),
  );
}

// ── GUEST DETAIL SHEET ─────────────────────────────────────────────────────────

class _GuestDetailSheet extends StatefulWidget {
  final Map<String, dynamic> guest;
  const _GuestDetailSheet({required this.guest});

  @override
  State<_GuestDetailSheet> createState() => _GuestDetailSheetState();
}

class _GuestDetailSheetState extends State<_GuestDetailSheet> {
  int _section = 0; // 0=info, 1=rsvp, 2=meals, 3=travel, 4=access, 5=notes

  @override
  Widget build(BuildContext context) {
    final g = widget.guest;
    final name = '${g['first_name'] ?? ''} ${g['last_name'] ?? ''}';

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, ctrl) => SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.udoBorder, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.udoGreen.withValues(alpha: 0.1),
                  child: Text(
                    '${name.isNotEmpty ? name[0] : ''}${name.split(' ').length > 1 ? name.split(' ').last[0] : ''}'.toUpperCase(),
                    style: const TextStyle(color: AppTheme.udoGreen, fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  if (g['email'] != null) Text(g['email'] as String, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
                ])),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ]),
            ),
            // Section chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final (i, label) in [
                    (0, 'Info'), (1, 'RSVP'), (2, 'Meals'), (3, 'Travel'), (4, 'Access'), (5, 'Notes'),
                  ]) Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label, style: const TextStyle(fontSize: 13)),
                      selected: _section == i,
                      onSelected: (_) => setState(() => _section = i),
                      selectedColor: AppTheme.udoGreen,
                      labelStyle: TextStyle(color: _section == i ? Colors.white : AppTheme.udoTextPrimary),
                      side: BorderSide(color: _section == i ? AppTheme.udoGreen : AppTheme.udoBorder),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: SingleChildScrollView(
              controller: ctrl,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _DetailSection(guest: g, section: _section),
            )),
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.send_outlined, size: 16),
                  label: const Text('Send invite'),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
                )),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
                )),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final Map<String, dynamic> guest;
  final int section;
  const _DetailSection({required this.guest, required this.section});

  @override
  Widget build(BuildContext context) {
    switch (section) {
      case 0: return _InfoSection(guest: guest);
      case 1: return _RsvpSection(guest: guest);
      case 2: return _MealsSection(guest: guest);
      case 3: return _TravelSection(guest: guest);
      case 4: return _AccessSection(guest: guest);
      case 5: return _NotesSection(guest: guest);
      default: return const SizedBox.shrink();
    }
  }
}

class _InfoSection extends StatelessWidget {
  final Map<String, dynamic> guest;
  const _InfoSection({required this.guest});

  @override
  Widget build(BuildContext context) => Column(children: [
    _InfoRow('First name', guest['first_name'] as String? ?? '—'),
    _InfoRow('Last name', guest['last_name'] as String? ?? '—'),
    _InfoRow('Email', guest['email'] as String? ?? '—'),
    _InfoRow('Phone', guest['phone'] as String? ?? '—'),
    _InfoRow('Tags', (guest['tags'] as List?)?.join(', ') ?? '—'),
    _InfoRow('Added', guest['created_at'] as String? ?? '—'),
  ]);
}

class _RsvpSection extends StatelessWidget {
  final Map<String, dynamic> guest;
  const _RsvpSection({required this.guest});

  @override
  Widget build(BuildContext context) => Column(children: [
    _InfoRow('RSVP status', _formatStatus(guest['attending_status'] as String? ?? 'pending')),
    _InfoRow('Plus one', guest['plus_one_count']?.toString() ?? '0'),
    _InfoRow('RSVP date', guest['rsvp_date'] as String? ?? 'Not responded'),
    _InfoRow('Invite sent', guest['invite_sent_at'] as String? ?? 'Not sent'),
    _InfoRow('Last reminder', guest['last_reminder_at'] as String? ?? 'None'),
    const SizedBox(height: 8),
    OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.notifications_outlined, size: 16),
      label: const Text('Send RSVP reminder'),
      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: AppTheme.udoCrimson), foregroundColor: AppTheme.udoCrimson),
    ),
  ]);

  String _formatStatus(String s) {
    switch (s) {
      case 'attending': return 'Attending';
      case 'not_attending': return 'Declined';
      case 'awaiting': return 'Awaiting response';
      default: return 'Pending';
    }
  }
}

class _MealsSection extends StatelessWidget {
  final Map<String, dynamic> guest;
  const _MealsSection({required this.guest});

  @override
  Widget build(BuildContext context) => Column(children: [
    _InfoRow('Meal preference', guest['meal_preference'] as String? ?? 'Not specified'),
    _InfoRow('Dietary restrictions', guest['dietary_restrictions'] as String? ?? 'None'),
    _InfoRow('Allergies', guest['allergies'] as String? ?? 'None'),
    const SizedBox(height: 8),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
      child: const Row(children: [
        Icon(Icons.info_outline, size: 16, color: AppTheme.udoTextSecondary),
        SizedBox(width: 8),
        Expanded(child: Text('Meal selection can be enabled via the Guest Experience builder.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary, height: 1.5))),
      ]),
    ),
  ]);
}

class _TravelSection extends StatelessWidget {
  final Map<String, dynamic> guest;
  const _TravelSection({required this.guest});

  @override
  Widget build(BuildContext context) => Column(children: [
    _InfoRow('Travelling from', guest['city'] as String? ?? '—'),
    _InfoRow('Accommodation', guest['accommodation'] as String? ?? 'Not assigned'),
    _InfoRow('Transport group', guest['transport_group'] as String? ?? 'Not assigned'),
    _InfoRow('Arrival date', guest['arrival_date'] as String? ?? '—'),
    _InfoRow('Departure date', guest['departure_date'] as String? ?? '—'),
    const SizedBox(height: 8),
    OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.flight_outlined, size: 16),
      label: const Text('Manage travel & stay'),
      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
    ),
  ]);
}

class _AccessSection extends StatelessWidget {
  final Map<String, dynamic> guest;
  const _AccessSection({required this.guest});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Event access', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        for (final event in ['Ceremony', 'Cocktail hour', 'Reception', 'After party']) ...[
          Row(children: [
            Expanded(child: Text(event, style: const TextStyle(fontSize: 13))),
            Switch(value: true, onChanged: (_) {}, activeColor: AppTheme.udoGreen, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
          ]),
          const Divider(height: 8),
        ],
      ]),
    ),
    const SizedBox(height: 12),
    _InfoRow('Guest token', guest['guest_token'] as String? ?? 'Not generated'),
  ]);
}

class _NotesSection extends StatelessWidget {
  final Map<String, dynamic> guest;
  const _NotesSection({required this.guest});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
      child: Text(
        guest['notes'] as String? ?? 'No notes yet. Tap to add.',
        style: const TextStyle(fontSize: 13, color: AppTheme.udoTextPrimary, height: 1.5),
      ),
    ),
    const SizedBox(height: 12),
    const Text('Invite history', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
      child: const Text('No invite history available.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
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
      SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );
}

// ── ADD GUEST MODAL ────────────────────────────────────────────────────────────

class _AddGuestModal extends StatefulWidget {
  final GuestsNotifier notifier;
  final bool quickMode;
  final ValueChanged<bool> onToggleMode;
  const _AddGuestModal({required this.notifier, required this.quickMode, required this.onToggleMode});

  @override
  State<_AddGuestModal> createState() => _AddGuestModalState();
}

class _AddGuestModalState extends State<_AddGuestModal> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String _rsvpStatus = 'pending';
  String _sendMethod = 'email';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Add guest', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
              // Quick / Manual toggle
              Container(
                decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  _ModeBtn('Quick', widget.quickMode, () => widget.onToggleMode(true)),
                  _ModeBtn('Manual', !widget.quickMode, () => widget.onToggleMode(false)),
                ]),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
            ]),
            const SizedBox(height: 16),
            // Quick invite mode
            if (widget.quickMode) ...[
              Row(children: [
                Expanded(child: _FieldWrap('First name', controller: _firstName)),
                const SizedBox(width: 12),
                Expanded(child: _FieldWrap('Last name', controller: _lastName)),
              ]),
              const SizedBox(height: 12),
              _FieldWrap('Email', controller: _email, type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _FieldWrap('Phone (optional)', controller: _phone, type: TextInputType.phone),
              const SizedBox(height: 12),
              Row(children: [
                for (final (key, icon, label) in [('email', Icons.email_outlined, 'Email'), ('sms', Icons.sms_outlined, 'SMS'), ('whatsapp', Icons.chat_outlined, 'WhatsApp')])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(icon, size: 14),
                      label: Text(label, style: const TextStyle(fontSize: 12)),
                      selected: _sendMethod == key,
                      onSelected: (_) => setState(() => _sendMethod = key),
                      selectedColor: AppTheme.udoGreen,
                      labelStyle: TextStyle(color: _sendMethod == key ? Colors.white : AppTheme.udoTextPrimary),
                      side: BorderSide(color: _sendMethod == key ? AppTheme.udoGreen : AppTheme.udoBorder),
                    ),
                  ),
              ]),
            ] else ...[
              // Manual add mode — full form
              Row(children: [
                Expanded(child: _FieldWrap('First name', controller: _firstName)),
                const SizedBox(width: 12),
                Expanded(child: _FieldWrap('Last name', controller: _lastName)),
              ]),
              const SizedBox(height: 12),
              _FieldWrap('Email', controller: _email, type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _FieldWrap('Phone (optional)', controller: _phone, type: TextInputType.phone),
              const SizedBox(height: 12),
              const Text('RSVP status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _rsvpStatus,
                decoration: _dropDeco(),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'attending', child: Text('Attending')),
                  DropdownMenuItem(value: 'not_attending', child: Text('Not attending')),
                  DropdownMenuItem(value: 'awaiting', child: Text('Awaiting')),
                ],
                onChanged: (v) => setState(() => _rsvpStatus = v ?? 'pending'),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
              child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(widget.quickMode ? 'Add & send invite' : 'Add guest'),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_firstName.text.isEmpty) return;
    setState(() => _loading = true);
    await widget.notifier.addGuest(
      firstName: _firstName.text,
      lastName: _lastName.text,
      email: _email.text.isNotEmpty ? _email.text : null,
      phone: _phone.text.isNotEmpty ? _phone.text : null,
    );
    if (mounted) Navigator.pop(context);
  }

  InputDecoration _dropDeco() => InputDecoration(
    filled: true, fillColor: const Color(0xFFF3EFEA),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  @override
  void dispose() { _firstName.dispose(); _lastName.dispose(); _email.dispose(); _phone.dispose(); super.dispose(); }
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
      decoration: BoxDecoration(color: selected ? AppTheme.udoGreen : Colors.transparent, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppTheme.udoTextPrimary, fontWeight: FontWeight.w500)),
    ),
  );
}

class _FieldWrap extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? type;
  const _FieldWrap(this.label, {required this.controller, this.type});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    const SizedBox(height: 6),
    TextField(controller: controller, keyboardType: type, decoration: InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14),
      filled: true, fillColor: const Color(0xFFF3EFEA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.udoGreen, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    )),
  ]);
}

// ── INVITATIONS TAB (Invitation Studio) ───────────────────────────────────────

class _InvitationsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_InvitationsTab> createState() => _InvitationsTabState();
}

class _InvitationsTabState extends ConsumerState<_InvitationsTab> {
  int _selectedTemplate = 0;
  String _deliveryMethod = 'email';
  bool _publishing = false;

  static const _templates = [
    ('Classic Ivory', 'Elegant serif design with gold accents'),
    ('Garden Romance', 'Floral watercolour style, soft pinks'),
    ('Modern Minimal', 'Clean lines, contemporary typography'),
    ('Rustic Warmth', 'Earthy tones with botanical elements'),
    ('Royal Blue', 'Deep navy with silver foiling effect'),
    ('Blush & Berry', 'Romantic blush with berry accents'),
  ];

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      // Stats bar
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
        child: Row(children: [
          _InvStat('95', 'Sent'),
          _InvStat('82', 'Opened'),
          _InvStat('64', 'RSVP\'d'),
          _InvStat('31', 'Pending'),
        ]),
      ),
      const SizedBox(height: 16),

      // Template picker
      const Text('Choose a template', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      const SizedBox(height: 10),
      SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _templates.length,
          itemBuilder: (_, i) {
            final selected = _selectedTemplate == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedTemplate = i),
              child: Container(
                width: 110,
                margin: EdgeInsets.only(right: 10, left: i == 0 ? 0 : 0),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.udoGreen.withValues(alpha: 0.08) : const Color(0xFFF3EFEA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: selected ? AppTheme.udoGreen : AppTheme.udoBorder, width: selected ? 2 : 1),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 56, height: 72, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.udoBorder)), child: Center(child: Icon(Icons.mail_outline, color: selected ? AppTheme.udoGreen : AppTheme.udoTextSecondary, size: 28))),
                  const SizedBox(height: 6),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(_templates[i].$1, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: selected ? AppTheme.udoGreen : AppTheme.udoTextPrimary), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis)),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 6),
      Text(_templates[_selectedTemplate].$2, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary, fontStyle: FontStyle.italic)),
      const SizedBox(height: 16),

      // Live preview
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Text('Preview', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(color: const Color(0xFFFAF6F0), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8DDD0))),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text('Sophie & James', style: TextStyle(fontFamily: 'Playfair', fontSize: 24, fontWeight: FontWeight.w400, color: AppTheme.udoGreen)),
              SizedBox(height: 4),
              Text('together with their families', style: TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary, fontStyle: FontStyle.italic)),
              SizedBox(height: 12),
              Text('invite you to celebrate', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
              SizedBox(height: 2),
              Text('their wedding', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
              SizedBox(height: 12),
              Text('Saturday, September 14, 2026', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text('4:00 PM · Rosewood Gardens', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 16),

      // Delivery method
      const Text('Delivery method', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Row(children: [
        for (final (val, label, icon) in [('email', 'Email', Icons.email_outlined), ('sms', 'SMS', Icons.sms_outlined), ('whatsapp', 'WhatsApp', Icons.message_outlined)])
          Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(
            onTap: () => setState(() => _deliveryMethod = val),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: _deliveryMethod == val ? AppTheme.udoGreen.withValues(alpha: 0.08) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _deliveryMethod == val ? AppTheme.udoGreen : AppTheme.udoBorder, width: _deliveryMethod == val ? 2 : 1)),
              child: Column(children: [
                Icon(icon, size: 20, color: _deliveryMethod == val ? AppTheme.udoGreen : AppTheme.udoTextSecondary),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(fontSize: 11, color: _deliveryMethod == val ? AppTheme.udoGreen : AppTheme.udoTextSecondary, fontWeight: FontWeight.w500)),
              ]),
            ),
          ))),
      ]),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: _publishing ? null : () => _showSendFlow(context),
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
        child: _publishing
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Send invitations'),
      ),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: AppTheme.udoBorder), foregroundColor: AppTheme.udoTextSecondary),
        child: const Text('View delivery history'),
      ),
    ],
  );

  void _showSendFlow(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _SendInvitationModal(
        template: _templates[_selectedTemplate].$1,
        method: _deliveryMethod,
        onConfirm: () => _publishInvitation(context),
      ),
    );
  }

  Future<void> _publishInvitation(BuildContext context) async {
    setState(() => _publishing = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.post('/invitation/publish', data: {});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invitations sent successfully!'), backgroundColor: AppTheme.udoGreen),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e'), backgroundColor: AppTheme.udoCrimson),
        );
      }
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }
}

class _InvStat extends StatelessWidget {
  final String value, label;
  const _InvStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.udoGreen)),
    Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
  ]));
}

class _SendInvitationModal extends StatelessWidget {
  final String template, method;
  final Future<void> Function() onConfirm;
  const _SendInvitationModal({required this.template, required this.method, required this.onConfirm});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Send invitations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
        ]),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)), child: Column(children: [
          _SummaryRow('Template', template),
          const SizedBox(height: 6),
          _SummaryRow('Method', method[0].toUpperCase() + method.substring(1)),
          const SizedBox(height: 6),
          _SummaryRow('Recipients', 'Guests without invite sent'),
        ])),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await onConfirm();
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
          child: const Text('Send now'),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 44), foregroundColor: AppTheme.udoTextSecondary), child: const Text('Cancel')),
      ]),
    ),
  );
}

Widget _SummaryRow(String label, String value) => Row(children: [
  SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))),
  Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
]);

// ── EXPERIENCE TAB ─────────────────────────────────────────────────────────────

class _ExperienceTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(experienceProvider);
    final notifier = ref.read(experienceProvider.notifier);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.udoGreen));
    }

    // Fall back to sensible defaults if API returns empty modules map
    final modules = state.modules.isNotEmpty
        ? state.modules
        : const {
            'Our Story': true, 'Venue Guide': true, 'RSVP Form': true,
            'Photo Upload': true, 'Schedule': false, 'Accommodation': false,
            'Gift Registry': true, 'Guest Wall': false,
          };

    final portalUrl = state.portal['url'] as String? ?? 'udo.app/guest/your-wedding';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Guest portal modules', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
              if (state.isSaving) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.udoGreen)),
            ]),
            const SizedBox(height: 4),
            const Text('Choose what guests can see and do on their wedding portal.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.4)),
            const SizedBox(height: 14),
            for (final entry in modules.entries) Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Container(width: 32, height: 32, decoration: BoxDecoration(color: (entry.value ? AppTheme.udoGreen : AppTheme.udoTextSecondary).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(_moduleIcon(entry.key), size: 16, color: entry.value ? AppTheme.udoGreen : AppTheme.udoTextSecondary)),
                const SizedBox(width: 12),
                Expanded(child: Text(entry.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                Switch(value: entry.value, onChanged: (v) => notifier.toggleModule(entry.key, v), activeColor: AppTheme.udoGreen, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Portal link', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Expanded(child: Text(portalUrl, style: const TextStyle(fontSize: 13, color: AppTheme.udoGreen))),
                const Icon(Icons.copy_outlined, color: AppTheme.udoGreen, size: 18),
              ]),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.share_outlined, size: 16), label: const Text('Share'), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.qr_code_outlined, size: 16), label: const Text('QR code'), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen))),
            ]),
          ]),
        ),
      ],
    );
  }

  IconData _moduleIcon(String key) {
    switch (key) {
      case 'Our Story': return Icons.favorite_border_outlined;
      case 'Venue Guide': return Icons.location_on_outlined;
      case 'RSVP Form': return Icons.how_to_reg_outlined;
      case 'Photo Upload': return Icons.photo_camera_outlined;
      case 'Schedule': return Icons.schedule_outlined;
      case 'Accommodation': return Icons.hotel_outlined;
      case 'Gift Registry': return Icons.card_giftcard_outlined;
      case 'Guest Wall': return Icons.message_outlined;
      default: return Icons.toggle_on_outlined;
    }
  }
}

// ── MESSAGES TAB (Wedding Wall) ────────────────────────────────────────────────

class _MessagesTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends ConsumerState<_MessagesTab> {
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _audience = 'all';
  int? _expandedTemplate;

  static const _audiences = [
    ('all', 'All guests'),
    ('confirmed', 'Confirmed'),
    ('pending', 'Pending'),
    ('vip', 'VIP'),
    ('bridesmaids', 'Bridesmaids'),
  ];

  static const _templates = [
    ('Thank you for RSVPing!', 'We\'re so excited to celebrate with you on September 14th. More details coming soon!'),
    ('Reminder: RSVP by August 1', 'We\'d love to know if you\'re joining us. Please respond before August 1st so we can finalize the seating plan.'),
    ('Day-of details', 'A reminder that our ceremony begins at 4:00 PM. The venue opens for guests from 3:30 PM.'),
    ('Travel & accommodation', 'We\'ve reserved a room block at The Grand Marriott. Use code SOJAIEWEDDING for a special rate.'),
  ];

  Future<void> _send() async {
    final body = _bodyCtrl.text.trim();
    if (body.isEmpty) return;
    final subject = _subjectCtrl.text.trim().isNotEmpty ? _subjectCtrl.text.trim() : 'Message from the couple';
    final notifier = ref.read(messagesProvider.notifier);
    final ok = await notifier.sendMessage(subject: subject, body: body, audience: _audience);
    if (ok && mounted) {
      _subjectCtrl.clear();
      _bodyCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent!'), backgroundColor: AppTheme.udoGreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Compose
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Send a message', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            // Audience
            const Text('To', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
              for (final (val, label) in _audiences) Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
                label: Text(label, style: const TextStyle(fontSize: 11)),
                selected: _audience == val,
                onSelected: (_) => setState(() => _audience = val),
                selectedColor: AppTheme.udoGreen,
                labelStyle: TextStyle(color: _audience == val ? Colors.white : AppTheme.udoTextPrimary),
                side: BorderSide(color: _audience == val ? AppTheme.udoGreen : AppTheme.udoBorder),
              )),
            ])),
            const SizedBox(height: 12),
            TextField(controller: _subjectCtrl, decoration: InputDecoration(hintText: 'Subject (optional)', hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14), filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))),
            const SizedBox(height: 8),
            TextField(controller: _bodyCtrl, maxLines: 4, decoration: InputDecoration(hintText: 'Write your message...', hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14), filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(14))),
            const SizedBox(height: 12),
            if (state.sendError != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(state.sendError!, style: const TextStyle(fontSize: 12, color: AppTheme.udoCrimson))),
            ElevatedButton(
              onPressed: state.isSending ? null : _send,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
              child: state.isSending
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Send'),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Template library
        const Text('Message templates', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        for (int i = 0; i < _templates.length; i++) GestureDetector(
          onTap: () => setState(() => _expandedTemplate = _expandedTemplate == i ? null : i),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(_templates[i].$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                Icon(_expandedTemplate == i ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 18, color: AppTheme.udoTextSecondary),
              ]),
              if (_expandedTemplate == i) ...[
                const SizedBox(height: 8),
                Text(_templates[i].$2, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary, height: 1.5)),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: () { _bodyCtrl.text = _templates[i].$2; _subjectCtrl.text = _templates[i].$1; setState(() => _expandedTemplate = null); }, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), minimumSize: Size.zero, side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen), child: const Text('Use template', style: TextStyle(fontSize: 12))),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 16),

        // History — real data from API, fallback to empty state
        const Text('Message history', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        if (state.isLoading) const Center(child: CircularProgressIndicator(color: AppTheme.udoGreen))
        else if (state.history.isEmpty)
          const Text('No messages sent yet.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
        else for (final msg in state.history) Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            const Icon(Icons.mark_email_read_outlined, color: AppTheme.udoGreen, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(msg['subject'] as String? ?? '—', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text('To: ${msg['audience'] ?? '—'} · ${msg['sent_at'] ?? msg['created_at'] ?? ''}', style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
            ])),
            if (msg['opened_count'] != null)
              Text('${msg['opened_count']} opened', style: const TextStyle(fontSize: 11, color: AppTheme.udoGreen)),
          ]),
        ),
      ],
    );
  }

  @override
  void dispose() { _subjectCtrl.dispose(); _bodyCtrl.dispose(); super.dispose(); }
}

// ── LOGISTICS TAB ──────────────────────────────────────────────────────────────

class _LogisticsTab extends ConsumerWidget {
  // GuestsState kept for potential future use (e.g. arrival tracking per-guest)
  final GuestsState state;
  const _LogisticsTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logistics = ref.watch(logisticsProvider);
    final notifier = ref.read(logisticsProvider.notifier);

    if (logistics.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.udoGreen));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          const Expanded(child: Text('Accommodation', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          TextButton.icon(onPressed: () => _showAddHotelModal(context, notifier), icon: const Icon(Icons.add, size: 16), label: const Text('Add', style: TextStyle(fontSize: 13))),
        ]),
        const SizedBox(height: 8),
        if (logistics.accommodations.isEmpty)
          const Padding(padding: EdgeInsets.only(bottom: 12), child: Text('No accommodation added yet.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)))
        else for (final h in logistics.accommodations) _AccommodationCard(h: h),
        const SizedBox(height: 16),
        Row(children: [
          const Expanded(child: Text('Transport', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          TextButton.icon(onPressed: () => _showAddTransportModal(context, notifier), icon: const Icon(Icons.add, size: 16), label: const Text('Add', style: TextStyle(fontSize: 13))),
        ]),
        const SizedBox(height: 8),
        if (logistics.transports.isEmpty)
          const Padding(padding: EdgeInsets.only(bottom: 12), child: Text('No transport groups added yet.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)))
        else for (final t in logistics.transports) _TransportCard(t: t),
        const SizedBox(height: 16),
        // Arrival tracker (static for now — real data can come from a future endpoint)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Arrival tracker', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            const Text('Track guest arrivals on the day.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            const SizedBox(height: 12),
            Row(children: [
              _ArrivalStat('${state.guests.where((g) => g['arrived'] == true).length}', 'Arrived', AppTheme.udoGreen),
              _ArrivalStat('${state.guests.where((g) => g['attending_status'] == 'attending' && g['arrived'] != true).length}', 'Expected', Colors.orange),
              _ArrivalStat('${state.guests.where((g) => g['attending_status'] == null || g['attending_status'] == 'pending').length}', 'Unknown', AppTheme.udoTextSecondary),
            ]),
          ]),
        ),
      ],
    );
  }

  void _showAddHotelModal(BuildContext context, LogisticsNotifier notifier) {
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (_) => _AddHotelModal(notifier: notifier));
  }

  void _showAddTransportModal(BuildContext context, LogisticsNotifier notifier) {
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (_) => _AddTransportModal(notifier: notifier));
  }
}

class _AccommodationCard extends StatelessWidget {
  final Map<String, dynamic> h;
  const _AccommodationCard({required this.h});

  @override
  Widget build(BuildContext context) {
    final totalRooms = (h['total_rooms'] ?? h['rooms'] ?? 0) as num;
    final bookedRooms = (h['booked_rooms'] ?? h['booked'] ?? 0) as num;
    final progress = totalRooms > 0 ? (bookedRooms / totalRooms).clamp(0.0, 1.0) : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.hotel_outlined, color: AppTheme.udoGreen, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(h['name'] as String? ?? '—', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          if (h['rate'] != null) Text(h['rate'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoGreen, fontWeight: FontWeight.w500)),
        ]),
        if (h['address'] != null) ...[
          const SizedBox(height: 4),
          Text(h['address'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        ],
        const SizedBox(height: 8),
        Row(children: [
          if (h['check_in'] != null) _LogBadge('Check-in: ${h['check_in']}', Colors.blue),
          if (h['check_in'] != null) const SizedBox(width: 6),
          if (h['check_out'] != null) _LogBadge('Check-out: ${h['check_out']}', Colors.orange),
        ]),
        if (totalRooms > 0) ...[
          const SizedBox(height: 8),
          Text('$bookedRooms of $totalRooms rooms booked', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: progress.toDouble(), backgroundColor: AppTheme.udoBorder, color: AppTheme.udoGreen, borderRadius: BorderRadius.circular(4), minHeight: 6),
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
    final seats = (t['capacity'] ?? t['seats'] ?? 0) as num;
    final booked = (t['booked_seats'] ?? t['booked'] ?? 0) as num;
    final progress = seats > 0 ? (booked / seats).clamp(0.0, 1.0) : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.directions_bus_outlined, color: AppTheme.udoGreen, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(t['name'] as String? ?? '—', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          if (t['departure_time'] != null) Text(t['departure_time'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        ]),
        if (t['pickup_location'] != null || t['drop_location'] != null) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.arrow_forward, size: 12, color: AppTheme.udoTextSecondary),
            const SizedBox(width: 4),
            Expanded(child: Text('${t['pickup_location'] ?? ''} → ${t['drop_location'] ?? ''}', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary))),
          ]),
        ],
        if (seats > 0) ...[
          const SizedBox(height: 8),
          Text('$booked of $seats seats taken', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: progress.toDouble(), backgroundColor: AppTheme.udoBorder, color: AppTheme.udoGreen, borderRadius: BorderRadius.circular(4), minHeight: 6),
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
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)));
}

class _ArrivalStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _ArrivalStat(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
    Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
  ]));
}

class _AddHotelModal extends StatefulWidget {
  final LogisticsNotifier notifier;
  const _AddHotelModal({required this.notifier});
  @override
  State<_AddHotelModal> createState() => _AddHotelModalState();
}

class _AddHotelModalState extends State<_AddHotelModal> {
  final _name = TextEditingController();
  final _rate = TextEditingController();
  final _rooms = TextEditingController();
  final _address = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: Text('Add hotel block', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
      ]),
      const SizedBox(height: 14),
      _GField('Hotel name', _name),
      const SizedBox(height: 10),
      _GField('Address (optional)', _address),
      const SizedBox(height: 10),
      Row(children: [Expanded(child: _GField('Rooms', _rooms, type: TextInputType.number)), const SizedBox(width: 10), Expanded(child: _GField('Rate/night', _rate))]),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
        child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Add hotel'),
      ),
    ]))),
  );

  Future<void> _submit() async {
    if (_name.text.isEmpty) return;
    setState(() => _loading = true);
    await widget.notifier.addAccommodation({
      'name': _name.text,
      if (_address.text.isNotEmpty) 'address': _address.text,
      if (_rooms.text.isNotEmpty) 'total_rooms': int.tryParse(_rooms.text) ?? 0,
      if (_rate.text.isNotEmpty) 'rate': _rate.text,
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() { _name.dispose(); _rate.dispose(); _rooms.dispose(); _address.dispose(); super.dispose(); }
}

class _AddTransportModal extends StatefulWidget {
  final LogisticsNotifier notifier;
  const _AddTransportModal({required this.notifier});
  @override
  State<_AddTransportModal> createState() => _AddTransportModalState();
}

class _AddTransportModalState extends State<_AddTransportModal> {
  final _name = TextEditingController();
  final _pickup = TextEditingController();
  final _drop = TextEditingController();
  final _time = TextEditingController();
  final _seats = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: Text('Add transport group', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
      ]),
      const SizedBox(height: 14),
      _GField('Group name', _name),
      const SizedBox(height: 10),
      _GField('Pickup location', _pickup),
      const SizedBox(height: 10),
      _GField('Drop location', _drop),
      const SizedBox(height: 10),
      Row(children: [Expanded(child: _GField('Departure time', _time)), const SizedBox(width: 10), Expanded(child: _GField('Seats', _seats, type: TextInputType.number))]),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
        child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Add transport'),
      ),
    ]))),
  );

  Future<void> _submit() async {
    if (_name.text.isEmpty) return;
    setState(() => _loading = true);
    await widget.notifier.addTransport({
      'name': _name.text,
      if (_pickup.text.isNotEmpty) 'pickup_location': _pickup.text,
      if (_drop.text.isNotEmpty) 'drop_location': _drop.text,
      if (_time.text.isNotEmpty) 'departure_time': _time.text,
      if (_seats.text.isNotEmpty) 'capacity': int.tryParse(_seats.text) ?? 0,
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() { _name.dispose(); _pickup.dispose(); _drop.dispose(); _time.dispose(); _seats.dispose(); super.dispose(); }
}

Widget _GField(String hint, TextEditingController ctrl, {TextInputType? type}) => TextField(controller: ctrl, keyboardType: type, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13), filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)));


// ── SHARED ─────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
    child: child,
  );
}
