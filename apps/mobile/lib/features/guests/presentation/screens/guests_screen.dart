import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/guests_provider.dart';
import '../providers/logistics_provider.dart';
import '../providers/messages_provider.dart';
import '../providers/experience_provider.dart';
import '../providers/invitation_provider.dart';

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
                _OverviewTab(
                  state: state,
                  onGoToList: () => _tabs.animateTo(1),
                  onAddGuest: () => _showAddModal(context, notifier),
                  onGuestTap: (g) => _showDetailSheet(context, g, () => _tabs.animateTo(5)),
                ),
                _GuestListTab(
                  state: state,
                  search: _search,
                  statusFilter: _statusFilter,
                  onSearchChanged: (v) => setState(() => _search = v),
                  onFilterChanged: (v) => setState(() => _statusFilter = v),
                  onAddGuest: () => _showAddModal(context, notifier),
                  onGuestTap: (g) => _showDetailSheet(context, g, () => _tabs.animateTo(5)),
                ),
                const _InvitationsTab(),
                _ExperienceTab(onGoToList: () => _tabs.animateTo(1)),
                const _MessagesTab(),
                const _LogisticsTab(),
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

  void _showDetailSheet(BuildContext context, Map<String, dynamic> guest, VoidCallback onGoToLogistics) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _GuestDetailSheet(guest: guest, onGoToLogistics: onGoToLogistics),
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

class _OverviewTab extends ConsumerWidget {
  final GuestsState state;
  final VoidCallback onGoToList;
  final VoidCallback onAddGuest;
  final void Function(Map<String, dynamic>) onGuestTap;
  const _OverviewTab({required this.state, required this.onGoToList, required this.onAddGuest, required this.onGuestTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = state.guests.length;
    final attending = state.guests.where((g) => g['attending_status'] == 'yes').length;
    final pending = state.guests.where((g) => g['attending_status'] == null || g['attending_status'] == 'pending').length;
    final declined = state.guests.where((g) => g['attending_status'] == 'no').length;
    final confirmPct = total > 0 ? attending / total : 0.0;

    if (state.error != null && state.guests.isEmpty) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        const SizedBox(height: 60),
        _errorBox("Couldn't load your guests.", state.error!),
      ]);
    }

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
            _ActionChip(Icons.person_add_outlined, 'Add guest', AppTheme.udoGreen, onTap: onAddGuest),
            _ActionChip(Icons.upload_file_outlined, 'Import CSV', Colors.indigo, onTap: () => _showImportCsv(context, ref)),
            _ActionChip(Icons.send_outlined, 'Send invites', AppTheme.udoCrimson, onTap: () => _sendBulkInvites(context, ref)),
            _ActionChip(Icons.restaurant_menu_outlined, 'Meal summary', Colors.orange, onTap: () => _showMealSummary(context, state.guests)),
            _ActionChip(Icons.flight_outlined, 'Travel overview', Colors.teal, onTap: () => _showTravelOverview(context, state.guests)),
            _ActionChip(Icons.people_outlined, 'View all', AppTheme.udoTextSecondary, onTap: onGoToList),
          ]),
        ])),
        const SizedBox(height: 12),
        // Recent additions
        if (state.guests.isNotEmpty) _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Recently added', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ...state.guests.take(5).map((g) => _GuestRow(guest: g, onTap: () => onGuestTap(g))),
        ])),
      ],
    );
  }

  Future<void> _showImportCsv(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(withData: true, type: FileType.custom, allowedExtensions: ['csv', 'txt']);
    final file = result?.files.single;
    if (file == null || file.bytes == null) return;

    final text = String.fromCharCodes(file.bytes!);
    final lines = text.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return;

    // Skip a header row if the first line doesn't look like a name (contains "name"/"email").
    final startIdx = lines.first.toLowerCase().contains('name') || lines.first.toLowerCase().contains('email') ? 1 : 0;

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
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No rows found in that file. Expected: first_name,last_name,email')));
      return;
    }

    final imported = await ref.read(guestsProvider.notifier).bulkImport(parsed);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(imported > 0 ? 'Imported $imported guest${imported == 1 ? '' : 's'}.' : "Couldn't import that file. Try again.")));
    }
  }

  Future<void> _sendBulkInvites(BuildContext context, WidgetRef ref) async {
    final targets = state.guests.where((g) => g['invite_status'] != 'sent' && (g['email'] as String?)?.isNotEmpty == true).toList();
    if (targets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Everyone with an email on file has already been invited.')));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Send invites'),
        content: Text('Send an invitation email to ${targets.length} guest${targets.length == 1 ? '' : 's'} who haven\'t been invited yet?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send')),
        ],
      ),
    );
    if (confirmed != true) return;

    var sent = 0;
    for (final g in targets) {
      final ok = await ref.read(guestsProvider.notifier).sendInvite(g['id'] as int);
      if (ok) sent++;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sent $sent of ${targets.length} invites.')));
    }
  }

  void _showMealSummary(BuildContext context, List<Map<String, dynamic>> guests) {
    final tally = <String, int>{};
    for (final g in guests) {
      final pref = (g['meal_preference'] as String?)?.trim();
      final key = (pref == null || pref.isEmpty) ? 'Not specified' : pref;
      tally[key] = (tally[key] ?? 0) + 1;
    }
    _showBreakdownSheet(context, 'Meal summary', tally);
  }

  void _showTravelOverview(BuildContext context, List<Map<String, dynamic>> guests) {
    final needsTravel = guests.where((g) => g['travel_required'] == true).length;
    final arranged = guests.where((g) => g['travel_required'] == true && (g['hotel_assignment_id'] != null || g['transport_assignment_id'] != null)).length;
    final notNeeded = guests.length - needsTravel;
    _showBreakdownSheet(context, 'Travel overview', {
      'Needs travel arrangements': needsTravel,
      'Already arranged': arranged,
      'No travel needed': notNeeded,
    });
  }
}

void _showBreakdownSheet(BuildContext context, String title, Map<String, int> tally) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (tally.isEmpty || tally.values.every((v) => v == 0))
            const Text('No data yet.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
          else
            for (final entry in tally.entries) Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Expanded(child: Text(entry.key, style: const TextStyle(fontSize: 14))),
                Text('${entry.value}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.udoGreen)),
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
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.udoCrimson)),
          const SizedBox(height: 6),
          Text(message, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary), textAlign: TextAlign.center),
        ]),
      ),
    );

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
    if (state.error != null && state.guests.isEmpty) {
      return _errorBox("Couldn't load your guests.", state.error!);
    }

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
              for (final (key, label) in [('all', 'All'), ('yes', 'Attending'), ('no', 'Declined'), ('pending', 'Pending')])
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

  String get _initials {
    final f = (guest['first_name'] as String? ?? '').isNotEmpty ? guest['first_name'][0] : '';
    final l = (guest['last_name'] as String? ?? '').isNotEmpty ? guest['last_name'][0] : '';
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
            decoration: BoxDecoration(color: _statusColorFor(status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(_statusLabel(status), style: TextStyle(fontSize: 11, color: _statusColorFor(status), fontWeight: FontWeight.w500)),
          ),
        ]),
      ),
    );
  }
}

// ── GUEST DETAIL SHEET ─────────────────────────────────────────────────────────

class _GuestDetailSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> guest;
  final VoidCallback onGoToLogistics;
  const _GuestDetailSheet({required this.guest, required this.onGoToLogistics});

  @override
  ConsumerState<_GuestDetailSheet> createState() => _GuestDetailSheetState();
}

class _GuestDetailSheetState extends ConsumerState<_GuestDetailSheet> {
  int _section = 0; // 0=info, 1=rsvp, 2=meals, 3=travel, 4=access, 5=notes
  late Map<String, dynamic> _guest;
  bool _sendingInvite = false;
  bool _generatingToken = false;

  @override
  void initState() {
    super.initState();
    _guest = widget.guest;
  }

  Future<void> _sendInvite() async {
    setState(() => _sendingInvite = true);
    final ok = await ref.read(guestsProvider.notifier).sendInvite(_guest['id'] as int);
    if (!mounted) return;
    setState(() => _sendingInvite = false);
    if (ok) {
      final updated = ref.read(guestsProvider).guests.firstWhere((g) => g['id'] == _guest['id'], orElse: () => _guest);
      setState(() => _guest = updated);
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Invite sent.' : "Couldn't send invite. Try again.")));
  }

  Future<void> _generateToken() async {
    setState(() => _generatingToken = true);
    final ok = await ref.read(guestsProvider.notifier).generateToken(_guest['id'] as int);
    if (!mounted) return;
    if (ok) {
      final updated = ref.read(guestsProvider).guests.firstWhere((g) => g['id'] == _guest['id'], orElse: () => _guest);
      setState(() => _guest = updated);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't generate access. Try again.")));
    }
    setState(() => _generatingToken = false);
  }

  @override
  Widget build(BuildContext context) {
    final g = _guest;
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
              child: _DetailSection(
                guest: g,
                section: _section,
                onSendReminder: _sendInvite,
                onGoToLogistics: widget.onGoToLogistics,
                onGenerateToken: _generateToken,
                generatingToken: _generatingToken,
              ),
            )),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: _sendingInvite ? null : _sendInvite,
                  icon: _sendingInvite
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.udoGreen))
                      : const Icon(Icons.send_outlined, size: 16),
                  label: Text(g['invite_status'] == 'sent' ? 'Resend invite' : 'Send invite'),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
                )),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (_) => _EditGuestModal(guest: g, onSaved: (updated) => setState(() => _guest = updated)),
                  ),
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
  final VoidCallback onSendReminder;
  final VoidCallback onGoToLogistics;
  final VoidCallback onGenerateToken;
  final bool generatingToken;
  const _DetailSection({
    required this.guest,
    required this.section,
    required this.onSendReminder,
    required this.onGoToLogistics,
    required this.onGenerateToken,
    required this.generatingToken,
  });

  @override
  Widget build(BuildContext context) {
    switch (section) {
      case 0: return _InfoSection(guest: guest);
      case 1: return _RsvpSection(guest: guest, onSendReminder: onSendReminder);
      case 2: return _MealsSection(guest: guest);
      case 3: return _TravelSection(guest: guest, onGoToLogistics: onGoToLogistics);
      case 4: return _AccessSection(guest: guest, onGenerateToken: onGenerateToken, generating: generatingToken);
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
    _InfoRow('RSVP status', _statusLabel(guest['attending_status'] as String?)),
    _InfoRow('Plus one', guest['plus_one_count']?.toString() ?? '0'),
    _InfoRow('Invite status', guest['invite_status'] as String? ?? 'Not sent'),
    const SizedBox(height: 8),
    OutlinedButton.icon(
      onPressed: onSendReminder,
      icon: const Icon(Icons.notifications_outlined, size: 16),
      label: const Text('Send RSVP reminder'),
      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: AppTheme.udoCrimson), foregroundColor: AppTheme.udoCrimson),
    ),
  ]);
}

class _MealsSection extends StatelessWidget {
  final Map<String, dynamic> guest;
  const _MealsSection({required this.guest});

  @override
  Widget build(BuildContext context) => Column(children: [
    _InfoRow('Meal preference', guest['meal_preference'] as String? ?? 'Not specified'),
    _InfoRow('Dietary note', guest['dietary_note'] as String? ?? 'None'),
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
  final VoidCallback onGoToLogistics;
  const _TravelSection({required this.guest, required this.onGoToLogistics});

  @override
  Widget build(BuildContext context) => Column(children: [
    _InfoRow('Travel required', guest['travel_required'] == true ? 'Yes' : 'No'),
    _InfoRow('Arrival', [guest['arrival_date'], guest['arrival_time']].where((v) => v != null).join(' · ').isEmpty ? '—' : [guest['arrival_date'], guest['arrival_time']].where((v) => v != null).join(' · ')),
    _InfoRow('Departure', [guest['departure_date'], guest['departure_time']].where((v) => v != null).join(' · ').isEmpty ? '—' : [guest['departure_date'], guest['departure_time']].where((v) => v != null).join(' · ')),
    _InfoRow('Airport', guest['arrival_airport'] as String? ?? '—'),
    _InfoRow('Hotel assigned', guest['hotel_assignment_id'] != null ? 'Yes' : 'Not assigned'),
    _InfoRow('Transport assigned', guest['transport_assignment_id'] != null ? 'Yes' : 'Not assigned'),
    const SizedBox(height: 8),
    OutlinedButton.icon(
      onPressed: onGoToLogistics,
      icon: const Icon(Icons.flight_outlined, size: 16),
      label: const Text('Manage travel & stay'),
      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
    ),
  ]);
}

class _AccessSection extends StatelessWidget {
  final Map<String, dynamic> guest;
  final VoidCallback onGenerateToken;
  final bool generating;
  const _AccessSection({required this.guest, required this.onGenerateToken, required this.generating});

  @override
  Widget build(BuildContext context) {
    final token = (guest['token'] as Map<String, dynamic>?)?['token'] as String?;
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Guest portal access', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          _InfoRow('Token', token ?? 'Not generated'),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: generating ? null : onGenerateToken,
            icon: generating
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.vpn_key_outlined, size: 16),
            label: Text(token != null ? 'Regenerate access' : 'Generate access'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44), side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
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
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Notes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
      child: Text(
        (guest['notes'] as String?)?.isNotEmpty == true ? guest['notes'] as String : 'No notes yet. Tap Edit to add.',
        style: const TextStyle(fontSize: 13, color: AppTheme.udoTextPrimary, height: 1.5),
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
      SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
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
  late final TextEditingController _firstName, _lastName, _email, _phone, _notes;
  late String _status;
  bool _loading = false;

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
    if (_firstName.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final ok = await ref.read(guestsProvider.notifier).updateGuest(widget.guest['id'] as int, {
      'first_name': _firstName.text.trim(),
      'last_name': _lastName.text.trim(),
      if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
      if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
      'attending_status': _status,
      'notes': _notes.text.trim(),
    });
    if (!mounted) return;
    if (ok) {
      final updated = ref.read(guestsProvider).guests.firstWhere((g) => g['id'] == widget.guest['id'], orElse: () => widget.guest);
      widget.onSaved(updated);
      Navigator.pop(context);
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't save. Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Edit guest', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _FieldWrap('First name', controller: _firstName)),
            const SizedBox(width: 12),
            Expanded(child: _FieldWrap('Last name', controller: _lastName)),
          ]),
          const SizedBox(height: 12),
          _FieldWrap('Email', controller: _email, type: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _FieldWrap('Phone', controller: _phone, type: TextInputType.phone),
          const SizedBox(height: 12),
          const Text('RSVP status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: _dropDeco(),
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'yes', child: Text('Attending')),
              DropdownMenuItem(value: 'no', child: Text('Not attending')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'pending'),
          ),
          const SizedBox(height: 12),
          _FieldWrap('Notes', controller: _notes),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
            child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save changes'),
          ),
        ]),
      ),
    ),
  );

  InputDecoration _dropDeco() => InputDecoration(
    filled: true, fillColor: const Color(0xFFF3EFEA),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  @override
  void dispose() { _firstName.dispose(); _lastName.dispose(); _email.dispose(); _phone.dispose(); _notes.dispose(); super.dispose(); }
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
  bool _loading = false;
  String? _error;

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
            Row(children: [
              Expanded(child: _FieldWrap('First name', controller: _firstName)),
              const SizedBox(width: 12),
              Expanded(child: _FieldWrap('Last name', controller: _lastName)),
            ]),
            const SizedBox(height: 12),
            _FieldWrap('Email', controller: _email, type: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _FieldWrap('Phone (optional)', controller: _phone, type: TextInputType.phone),
            if (!widget.quickMode) ...[
              const SizedBox(height: 12),
              const Text('RSVP status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _rsvpStatus,
                decoration: _dropDeco(),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'yes', child: Text('Attending')),
                  DropdownMenuItem(value: 'no', child: Text('Not attending')),
                ],
                onChanged: (v) => setState(() => _rsvpStatus = v ?? 'pending'),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(fontSize: 12, color: AppTheme.udoCrimson)),
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
    if (_firstName.text.trim().isEmpty) return;
    setState(() { _loading = true; _error = null; });
    final ok = await widget.notifier.addGuest(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim().isNotEmpty ? _email.text.trim() : null,
      phone: _phone.text.trim().isNotEmpty ? _phone.text.trim() : null,
      attendingStatus: widget.quickMode ? null : _rsvpStatus,
      sendInviteAfter: widget.quickMode,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() { _loading = false; _error = "Couldn't add this guest. Try again."; });
      return;
    }
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

class _InvitationTemplate {
  final String id, name, description;
  final Color accent, background;
  const _InvitationTemplate(this.id, this.name, this.description, this.accent, this.background);
}

const _invitationTemplates = [
  _InvitationTemplate('classic-ivory', 'Classic Ivory', 'Elegant serif design with gold accents', Color(0xFF285301), Color(0xFFFAF6F0)),
  _InvitationTemplate('garden-romance', 'Garden Romance', 'Floral watercolour style, soft pinks', Color(0xFFD45D78), Color(0xFFFCEEF2)),
  _InvitationTemplate('modern-minimal', 'Modern Minimal', 'Clean lines, contemporary typography', Color(0xFF1F2937), Color(0xFFF7F7F7)),
  _InvitationTemplate('rustic-warmth', 'Rustic Warmth', 'Earthy tones with botanical elements', Color(0xFF92400E), Color(0xFFFAF3E8)),
  _InvitationTemplate('royal-blue', 'Royal Blue', 'Deep navy with silver foiling effect', Color(0xFF1E3A8A), Color(0xFFEEF2FA)),
  _InvitationTemplate('blush-berry', 'Blush & Berry', 'Romantic blush with berry accents', Color(0xFF9D174D), Color(0xFFFBEEF3)),
];

class _InvitationsTab extends ConsumerStatefulWidget {
  const _InvitationsTab();
  @override
  ConsumerState<_InvitationsTab> createState() => _InvitationsTabState();
}

class _InvitationsTabState extends ConsumerState<_InvitationsTab> {
  bool _publishing = false;

  String _formatDate(dynamic iso) {
    if (iso == null) return 'Date to be confirmed';
    final d = DateTime.tryParse(iso.toString());
    if (d == null) return iso.toString();
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    const weekdays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final invState = ref.watch(invitationProvider);
    final invNotifier = ref.read(invitationProvider.notifier);
    final guests = ref.watch(guestsProvider).guests;

    if (invState.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.udoGreen));
    if (invState.error != null && invState.wedding == null) {
      return _errorBox("Couldn't load your invitation.", invState.error!);
    }

    final invitation = invState.invitation;
    final wedding = invState.wedding ?? {};
    final selectedId = invitation?['template_id'] as String? ?? _invitationTemplates.first.id;
    final selectedTemplate = _invitationTemplates.firstWhere((t) => t.id == selectedId, orElse: () => _invitationTemplates.first);

    final sent = guests.where((g) => g['invite_status'] == 'sent').length;
    final rsvpd = guests.where((g) => g['attending_status'] == 'yes' || g['attending_status'] == 'no').length;
    final pending = guests.length - sent;

    final coupleNames = (invitation?['title_line'] as String?)?.isNotEmpty == true
        ? invitation!['title_line'] as String
        : ([wedding['couple_name_primary'], wedding['couple_name_secondary']].where((v) => v != null && (v as String).isNotEmpty).join(' & '));
    final dateText = (invitation?['date_text'] as String?)?.isNotEmpty == true ? invitation!['date_text'] as String : _formatDate(wedding['event_date']);
    final venueText = (invitation?['venue_text'] as String?)?.isNotEmpty == true
        ? invitation!['venue_text'] as String
        : ([wedding['primary_venue_name'], wedding['city']].where((v) => v != null && (v as String).isNotEmpty).join(' · '));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            _InvStat('$sent', 'Sent'),
            _InvStat('$rsvpd', 'RSVP\'d'),
            _InvStat('$pending', 'Pending'),
          ]),
        ),
        const SizedBox(height: 16),

        const Text('Choose a template', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _invitationTemplates.length,
            itemBuilder: (_, i) {
              final t = _invitationTemplates[i];
              final selected = t.id == selectedId;
              return GestureDetector(
                onTap: () => invNotifier.save(templateId: t.id),
                child: Container(
                  width: 110,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: selected ? t.accent.withValues(alpha: 0.08) : const Color(0xFFF3EFEA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: selected ? t.accent : AppTheme.udoBorder, width: selected ? 2 : 1),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 56, height: 72, decoration: BoxDecoration(color: t.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.udoBorder)), child: Center(child: Icon(Icons.mail_outline, color: t.accent, size: 28))),
                    const SizedBox(height: 6),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(t.name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: selected ? t.accent : AppTheme.udoTextPrimary), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis)),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(selectedTemplate.description, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary, fontStyle: FontStyle.italic)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const Text('Preview', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(color: selectedTemplate.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: selectedTemplate.accent.withValues(alpha: 0.3))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text(coupleNames.isEmpty ? 'Your names here' : coupleNames, style: TextStyle(fontFamily: 'Playfair', fontSize: 24, fontWeight: FontWeight.w400, color: selectedTemplate.accent), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                const Text('together with their families', style: TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary, fontStyle: FontStyle.italic)),
                const SizedBox(height: 12),
                const Text('invite you to celebrate their wedding', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(dateText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                if (venueText.isNotEmpty) Text(venueText, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary), textAlign: TextAlign.center),
                if ((invitation?['invitation_text'] as String?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Text(invitation!['invitation_text'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary, height: 1.5), textAlign: TextAlign.center),
                ],
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showEditInvitationText(context, invNotifier, invitation),
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Edit wording'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44), side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
        ),
        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: _publishing ? null : () => _showSendFlow(context, invNotifier),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
          child: _publishing
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Send invitations'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _showBreakdownSheet(context, 'Invite status', {
            'Sent': sent,
            'Not sent yet': guests.length - sent,
            'RSVP\'d': rsvpd,
          }),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: AppTheme.udoBorder), foregroundColor: AppTheme.udoTextSecondary),
          child: const Text('View delivery history'),
        ),
      ],
    );
  }

  void _showEditInvitationText(BuildContext context, InvitationNotifier notifier, Map<String, dynamic>? invitation) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EditInvitationTextModal(notifier: notifier, invitation: invitation),
    );
  }

  void _showSendFlow(BuildContext context, InvitationNotifier notifier) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _SendInvitationModal(onConfirm: () => _publishInvitation(context, notifier)),
    );
  }

  Future<void> _publishInvitation(BuildContext context, InvitationNotifier notifier) async {
    setState(() => _publishing = true);
    final ok = await notifier.publish();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Invitation published!' : "Couldn't publish. Try again."),
        backgroundColor: ok ? AppTheme.udoGreen : AppTheme.udoCrimson,
      ));
    }
    if (mounted) setState(() => _publishing = false);
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

class _EditInvitationTextModal extends StatefulWidget {
  final InvitationNotifier notifier;
  final Map<String, dynamic>? invitation;
  const _EditInvitationTextModal({required this.notifier, required this.invitation});
  @override
  State<_EditInvitationTextModal> createState() => _EditInvitationTextModalState();
}

class _EditInvitationTextModalState extends State<_EditInvitationTextModal> {
  late final TextEditingController _titleLine, _text, _dateText, _venueText;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final inv = widget.invitation;
    _titleLine = TextEditingController(text: inv?['title_line'] as String? ?? '');
    _text = TextEditingController(text: inv?['invitation_text'] as String? ?? '');
    _dateText = TextEditingController(text: inv?['date_text'] as String? ?? '');
    _venueText = TextEditingController(text: inv?['venue_text'] as String? ?? '');
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await widget.notifier.save(
      titleLine: _titleLine.text.trim(),
      invitationText: _text.text.trim(),
      dateText: _dateText.text.trim(),
      venueText: _venueText.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't save. Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Edit wording', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
        ]),
        const SizedBox(height: 12),
        _FieldWrap('Names (leave blank to use your wedding\'s names)', controller: _titleLine),
        const SizedBox(height: 12),
        _FieldWrap('Date text (leave blank to use your wedding date)', controller: _dateText),
        const SizedBox(height: 12),
        _FieldWrap('Venue text (leave blank to use your wedding venue)', controller: _venueText),
        const SizedBox(height: 12),
        const Text('Additional message', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(controller: _text, maxLines: 3, decoration: InputDecoration(hintText: 'Optional note shown below the details...', hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13), filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(14))),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save'),
        ),
      ]),
    )),
  );

  @override
  void dispose() { _titleLine.dispose(); _text.dispose(); _dateText.dispose(); _venueText.dispose(); super.dispose(); }
}

class _SendInvitationModal extends StatelessWidget {
  final Future<void> Function() onConfirm;
  const _SendInvitationModal({required this.onConfirm});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Publish invitation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
        ]),
        const SizedBox(height: 8),
        const Text('This marks your invitation as published. To email it to specific guests, use "Send invite" from their guest detail card, or "Send invites" from Overview to reach everyone at once.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await onConfirm();
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
          child: const Text('Publish now'),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 44), foregroundColor: AppTheme.udoTextSecondary), child: const Text('Cancel')),
      ]),
    ),
  );
}

// ── EXPERIENCE TAB ─────────────────────────────────────────────────────────────

const _experienceToggles = [
  ('show_schedule', 'Wedding Schedule', Icons.schedule_outlined),
  ('show_venue_map', 'Venue Map', Icons.location_on_outlined),
  ('show_accommodation', 'Accommodation Info', Icons.hotel_outlined),
  ('show_transport', 'Transport Info', Icons.directions_bus_outlined),
  ('show_dress_code', 'Dress Code', Icons.checkroom_outlined),
  ('show_registry', 'Gift Registry', Icons.card_giftcard_outlined),
  ('show_gallery', 'Photo Gallery', Icons.photo_library_outlined),
  ('show_live_feed', 'Live Updates', Icons.radio_outlined),
  ('allow_photo_uploads', 'Guest Photo Uploads', Icons.add_a_photo_outlined),
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

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.udoGreen));
    }
    if (state.error != null && state.config.isEmpty) {
      return _errorBox("Couldn't load your guest experience settings.", state.error!);
    }

    final config = state.config;

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
            for (final (key, label, icon) in _experienceToggles) Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Container(width: 32, height: 32, decoration: BoxDecoration(color: (config[key] == true ? AppTheme.udoGreen : AppTheme.udoTextSecondary).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: config[key] == true ? AppTheme.udoGreen : AppTheme.udoTextSecondary)),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                Switch(value: config[key] == true, onChanged: (v) => notifier.toggleField(key, v), activeColor: AppTheme.udoGreen, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Guest-facing text', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            const Text('Shown to guests on their portal.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _showEditTextModal(context, notifier, config),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text((config['welcome_message'] as String?)?.isNotEmpty == true ? 'Edit welcome message & dress code' : 'Add welcome message & dress code'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44), side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
            ),
            if ((config['welcome_message'] as String?)?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              Text(config['welcome_message'] as String, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.4)),
            ],
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Guest portal access', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            const Text('Each guest gets their own personalized portal link — there\'s no single shared URL. Generate and share links from a guest\'s detail card.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5)),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onGoToList,
              icon: const Icon(Icons.people_outline, size: 16),
              label: const Text('Go to guest list'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44), side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
            ),
          ]),
        ),
      ],
    );
  }

  void _showEditTextModal(BuildContext context, ExperienceNotifier notifier, Map<String, dynamic> config) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EditExperienceTextModal(notifier: notifier, config: config),
    );
  }
}

class _EditExperienceTextModal extends StatefulWidget {
  final ExperienceNotifier notifier;
  final Map<String, dynamic> config;
  const _EditExperienceTextModal({required this.notifier, required this.config});
  @override
  State<_EditExperienceTextModal> createState() => _EditExperienceTextModalState();
}

class _EditExperienceTextModalState extends State<_EditExperienceTextModal> {
  late final TextEditingController _welcome, _dressCode, _dressDetails;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _welcome = TextEditingController(text: widget.config['welcome_message'] as String? ?? '');
    _dressCode = TextEditingController(text: widget.config['dress_code'] as String? ?? '');
    _dressDetails = TextEditingController(text: widget.config['dress_code_details'] as String? ?? '');
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't save. Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Guest-facing text', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
        ]),
        const SizedBox(height: 12),
        const Text('Welcome message', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(controller: _welcome, maxLines: 3, decoration: InputDecoration(hintText: 'A note guests see when they open their portal...', hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13), filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(14))),
        const SizedBox(height: 12),
        _FieldWrap('Dress code', controller: _dressCode, type: null),
        const SizedBox(height: 12),
        const Text('Dress code details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(controller: _dressDetails, maxLines: 2, decoration: InputDecoration(hintText: 'e.g. Garden formal, no white or ivory', hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13), filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(14))),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save'),
        ),
      ]),
    )),
  );

  @override
  void dispose() { _welcome.dispose(); _dressCode.dispose(); _dressDetails.dispose(); super.dispose(); }
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
  int? _expandedTemplate;

  static const _audiences = [
    ('all', 'All guests'),
    ('confirmed', 'Confirmed'),
    ('pending', 'Pending'),
    ('vip', 'VIP'),
    ('wedding_party', 'Wedding party'),
  ];

  static const _channels = {'email': 'Email', 'sms': 'SMS', 'whatsapp': 'WhatsApp', 'in_app': 'In-app'};

  static const _templates = [
    ('Thank you for RSVPing!', 'We\'re so excited to celebrate with you. More details coming soon!'),
    ('Reminder: please RSVP', 'We\'d love to know if you\'re joining us. Please respond soon so we can finalize the seating plan.'),
    ('Day-of details', 'A reminder of tomorrow\'s schedule — see you there!'),
    ('Travel & accommodation', 'We\'ve reserved a room block nearby. Reach out if you\'d like the details.'),
  ];

  Future<void> _send() async {
    final body = _bodyCtrl.text.trim();
    if (body.isEmpty) return;
    final subject = _subjectCtrl.text.trim().isNotEmpty ? _subjectCtrl.text.trim() : 'Message from the couple';
    final notifier = ref.read(messagesProvider.notifier);
    final ok = await notifier.sendMessage(subject: subject, body: body, audience: _audience, channel: _channel);
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Send a message', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
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
            const Text('Channel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, children: [
              for (final entry in _channels.entries) ChoiceChip(
                label: Text(entry.value, style: const TextStyle(fontSize: 11)),
                selected: _channel == entry.key,
                onSelected: (_) => setState(() => _channel = entry.key),
                selectedColor: AppTheme.udoGreen,
                labelStyle: TextStyle(color: _channel == entry.key ? Colors.white : AppTheme.udoTextPrimary),
                side: BorderSide(color: _channel == entry.key ? AppTheme.udoGreen : AppTheme.udoBorder),
              ),
            ]),
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

        const Text('Message history', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        if (state.isLoading) const Center(child: CircularProgressIndicator(color: AppTheme.udoGreen))
        else if (state.error != null && state.history.isEmpty)
          _errorBox("Couldn't load message history.", state.error!)
        else if (state.history.isEmpty)
          const Text('No messages sent yet.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
        else for (final msg in state.history) Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            Icon(msg['status'] == 'sent' ? Icons.mark_email_read_outlined : Icons.drafts_outlined, color: msg['status'] == 'sent' ? AppTheme.udoGreen : AppTheme.udoTextSecondary, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(msg['subject'] as String? ?? '—', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text('${msg['status'] ?? 'draft'} · ${msg['recipient_count'] ?? 0} recipient${(msg['recipient_count'] ?? 0) == 1 ? '' : 's'}', style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
            ])),
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
  const _LogisticsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logistics = ref.watch(logisticsProvider);
    final notifier = ref.read(logisticsProvider.notifier);
    final guests = ref.watch(guestsProvider).guests;

    if (logistics.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.udoGreen));
    }
    if (logistics.error != null && logistics.accommodations.isEmpty && logistics.transports.isEmpty) {
      return _errorBox("Couldn't load logistics.", logistics.error!);
    }

    final needsTravel = guests.where((g) => g['travel_required'] == true).length;
    final arranged = guests.where((g) => g['travel_required'] == true && (g['hotel_assignment_id'] != null || g['transport_assignment_id'] != null)).length;
    final notNeeded = guests.length - needsTravel;

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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Travel overview', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            const Text('Based on each guest\'s travel details.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            const SizedBox(height: 12),
            Row(children: [
              _ArrivalStat('$arranged', 'Arranged', AppTheme.udoGreen),
              _ArrivalStat('${needsTravel - arranged}', 'Needs arranging', Colors.orange),
              _ArrivalStat('$notNeeded', 'Not traveling', AppTheme.udoTextSecondary),
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
    final totalRooms = (h['total_rooms_blocked'] ?? 0) as num;
    final bookedRooms = (h['rooms_assigned'] ?? 0) as num;
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
          if (h['price_per_night'] != null) Text('\$${h['price_per_night']}/night', style: const TextStyle(fontSize: 12, color: AppTheme.udoGreen, fontWeight: FontWeight.w500)),
        ]),
        if ((h['address'] as String?)?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(h['address'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        ],
        const SizedBox(height: 8),
        Row(children: [
          if (h['check_in_date'] != null) _LogBadge('Check-in: ${h['check_in_date']}', Colors.blue),
          if (h['check_in_date'] != null) const SizedBox(width: 6),
          if (h['check_out_date'] != null) _LogBadge('Check-out: ${h['check_out_date']}', Colors.orange),
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
    final seats = (t['capacity'] ?? 0) as num;
    final assignments = (t['assignments'] as List?) ?? [];
    final booked = assignments.length;
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
          if ((t['type'] as String?)?.isNotEmpty == true) _LogBadge(t['type'] as String, Colors.indigo),
        ]),
        if ((t['pickup_location'] as String?)?.isNotEmpty == true || (t['dropoff_location'] as String?)?.isNotEmpty == true) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.arrow_forward, size: 12, color: AppTheme.udoTextSecondary),
            const SizedBox(width: 4),
            Expanded(child: Text('${t['pickup_location'] ?? ''} → ${t['dropoff_location'] ?? ''}', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary))),
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
    Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary), textAlign: TextAlign.center),
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
  String? _error;

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
      Row(children: [Expanded(child: _GField('Rooms', _rooms, type: TextInputType.number)), const SizedBox(width: 10), Expanded(child: _GField('Rate/night', _rate, type: const TextInputType.numberWithOptions(decimal: true)))]),
      if (_error != null) ...[const SizedBox(height: 10), Text(_error!, style: const TextStyle(fontSize: 12, color: AppTheme.udoCrimson))],
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
        child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Add hotel'),
      ),
    ]))),
  );

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) return;
    setState(() { _loading = true; _error = null; });
    final ok = await widget.notifier.addAccommodation({
      'name': _name.text.trim(),
      if (_address.text.trim().isNotEmpty) 'address': _address.text.trim(),
      if (_rooms.text.trim().isNotEmpty) 'total_rooms': int.tryParse(_rooms.text.trim()) ?? 0,
      if (_rate.text.trim().isNotEmpty) 'price_per_night': double.tryParse(_rate.text.trim()),
    });
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() { _loading = false; _error = "Couldn't add this hotel. Try again."; });
    }
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
  final _seats = TextEditingController();
  String _type = 'car';
  bool _loading = false;
  String? _error;

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
      Wrap(spacing: 6, children: [
        for (final t in ['car', 'van', 'minibus', 'coach']) ChoiceChip(
          label: Text(t, style: const TextStyle(fontSize: 12)),
          selected: _type == t,
          onSelected: (_) => setState(() => _type = t),
          selectedColor: AppTheme.udoGreen,
          labelStyle: TextStyle(color: _type == t ? Colors.white : AppTheme.udoTextPrimary),
          side: BorderSide(color: _type == t ? AppTheme.udoGreen : AppTheme.udoBorder),
        ),
      ]),
      const SizedBox(height: 10),
      _GField('Pickup location', _pickup),
      const SizedBox(height: 10),
      _GField('Drop-off location', _drop),
      const SizedBox(height: 10),
      _GField('Seats', _seats, type: TextInputType.number),
      if (_error != null) ...[const SizedBox(height: 10), Text(_error!, style: const TextStyle(fontSize: 12, color: AppTheme.udoCrimson))],
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: _loading ? null : _submit,
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
        child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Add transport'),
      ),
    ]))),
  );

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) return;
    setState(() { _loading = true; _error = null; });
    final ok = await widget.notifier.addTransport({
      'name': _name.text.trim(),
      'type': _type,
      if (_pickup.text.trim().isNotEmpty) 'pickup_location': _pickup.text.trim(),
      if (_drop.text.trim().isNotEmpty) 'dropoff_location': _drop.text.trim(),
      if (_seats.text.trim().isNotEmpty) 'capacity': int.tryParse(_seats.text.trim()) ?? 0,
    });
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() { _loading = false; _error = "Couldn't add this transport group. Try again."; });
    }
  }

  @override
  void dispose() { _name.dispose(); _pickup.dispose(); _drop.dispose(); _seats.dispose(); super.dispose(); }
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
