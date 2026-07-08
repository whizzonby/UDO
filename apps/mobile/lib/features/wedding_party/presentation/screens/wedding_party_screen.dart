import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/wedding_party_provider.dart';

class WeddingPartyScreen extends ConsumerStatefulWidget {
  const WeddingPartyScreen({super.key});
  @override
  ConsumerState<WeddingPartyScreen> createState() => _WeddingPartyScreenState();
}

class _WeddingPartyScreenState extends ConsumerState<WeddingPartyScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 9, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _mapMembers(List<Map<String, dynamic>> raw) {
    return raw.map((g) => {
      'id': g['id']?.toString() ?? '',
      'name': '${g['first_name'] ?? ''} ${g['last_name'] ?? ''}'.trim(),
      'role': g['notes'] ?? 'Guest',
      'responsiveness': 'medium',
      'pendingTasks': 0,
      'travelStatus': g['travel_status'] ?? 'unknown',
      'attireStatus': 'pending',
      'rehearsalStatus': 'pending',
      'unreadUpdates': 0,
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final partyState = ref.watch(weddingPartyProvider);
    final members = _mapMembers(partyState.members);

    return Scaffold(
      backgroundColor: AppTheme.udoBackground,
      body: partyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _Header(tabs: _tabs, count: members.length),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _OverviewTab(members: members, onPersonTap: (id) => _showPersonDetail(context, members, id)),
                      _PeopleTab(members: members, onPersonTap: (id) => _showPersonDetail(context, members, id)),
                      _ResponsibilitiesTab(members: members),
                      _BuzzesTab(),
                      _WeddingTimelineTab(),
                      _TravelTab(members: members),
                      _RehearsalTab(members: members),
                      _EmergencyTab(members: members),
                      _FilesSpeechesTab(members: members),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPersonModal(context),
        backgroundColor: AppTheme.udoGreen,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }

  void _showPersonDetail(BuildContext context, List<Map<String, dynamic>> members, String id) {
    final person = members.firstWhere((m) => m['id'] == id, orElse: () => {});
    if (person.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PersonDetailSheet(person: person),
    );
  }

  void _showAddPersonModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddPersonModal(
        onAdd: ({required firstName, required lastName, required role, email, phone}) {
          ref.read(weddingPartyProvider.notifier).addMember(
            firstName: firstName,
            lastName: lastName,
            role: role,
            email: email,
            phone: phone,
          );
        },
      ),
    );
  }
}

// ── HEADER ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final TabController tabs;
  final int count;
  const _Header({required this.tabs, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.udoGreen,
      child: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(children: [
              const BackButton(color: Colors.white),
              const Expanded(child: Text('Wedding Party', style: TextStyle(color: Colors.white, fontFamily: 'Playfair', fontSize: 22, fontWeight: FontWeight.w400))),
              Text('$count people', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            tabs: const [
              Tab(text: 'Overview'), Tab(text: 'People'), Tab(text: 'Responsibilities'),
              Tab(text: 'Buzzes'), Tab(text: 'Timeline'), Tab(text: 'Travel'),
              Tab(text: 'Rehearsal'), Tab(text: 'Emergency'), Tab(text: 'Files & Speeches'),
            ],
            labelColor: AppTheme.udoGreen,
            unselectedLabelColor: Colors.white,
            indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.symmetric(vertical: 4),
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            dividerColor: Colors.transparent,
          ),
        ]),
      ),
    );
  }
}

// ── OVERVIEW TAB ───────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  final void Function(String) onPersonTap;
  const _OverviewTab({required this.members, required this.onPersonTap});

  @override
  Widget build(BuildContext context) {
    final needsAttention = members.where((m) => (m['pendingTasks'] as int) > 0 || m['responsiveness'] == 'low').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            _MiniStat('${members.length}', 'Total', AppTheme.udoGreen),
            _MiniStat('${members.where((m) => m['travelStatus'] == 'confirmed').length}', 'Travel\nconfirmed', const Color(0xFF22C55E)),
            _MiniStat('${members.where((m) => m['attireStatus'] == 'complete').length}', 'Attire\nready', Colors.blue),
            _MiniStat('${members.where((m) => m['rehearsalStatus'] == 'confirmed').length}', 'Rehearsal\nconfirmed', Colors.purple),
          ]),
        ),
        const SizedBox(height: 12),

        // Alerts
        if (needsAttention.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.udoCrimson.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoCrimson.withValues(alpha: 0.2))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.warning_amber_outlined, color: AppTheme.udoCrimson, size: 18),
                const SizedBox(width: 8),
                Text('${needsAttention.length} need your attention', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.udoCrimson)),
              ]),
              const SizedBox(height: 10),
              for (final m in needsAttention) Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  _Avatar(name: m['name'] as String),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    Text(m['role'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                  ])),
                  if ((m['pendingTasks'] as int) > 0)
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppTheme.udoCrimson.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text('${m['pendingTasks']} tasks', style: const TextStyle(fontSize: 11, color: AppTheme.udoCrimson))),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 12),
        ],

        // Quick send buzz
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Send a buzz', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              for (final label in ['Morning check-in', 'Rehearsal reminder', 'Day-of update', 'Thank you note'])
                ActionChip(label: Text(label, style: const TextStyle(fontSize: 12)), onPressed: () {}, side: const BorderSide(color: AppTheme.udoBorder)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),

        // All members
        const Text('All members', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        for (final m in members) _MemberRow(member: m, onTap: () => onPersonTap(m['id'] as String)),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _MiniStat(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: color)),
    Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.udoTextSecondary), textAlign: TextAlign.center),
  ]));
}

class _MemberRow extends StatelessWidget {
  final Map<String, dynamic> member;
  final VoidCallback onTap;
  const _MemberRow({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
      child: Row(children: [
        _Avatar(name: member['name'] as String),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(member['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(member['role'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        ])),
        if ((member['unreadUpdates'] as int) > 0)
          Container(
            margin: const EdgeInsets.only(right: 8),
            width: 20, height: 20,
            decoration: const BoxDecoration(color: AppTheme.udoCrimson, shape: BoxShape.circle),
            child: Center(child: Text('${member['unreadUpdates']}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))),
          ),
        _StatusDot(member['travelStatus'] as String),
        const SizedBox(width: 4),
        _StatusDot(member['attireStatus'] as String),
      ]),
    ),
  );
}

class _StatusDot extends StatelessWidget {
  final String status;
  const _StatusDot(this.status);

  Color get _color {
    if (status == 'confirmed' || status == 'complete') return const Color(0xFF22C55E);
    if (status == 'needs-response' || status == 'needs-fitting' || status == 'measurements-needed') return AppTheme.udoCrimson;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) => Container(width: 8, height: 8, decoration: BoxDecoration(color: _color, shape: BoxShape.circle));
}

// ── PEOPLE TAB ─────────────────────────────────────────────────────────────────

class _PeopleTab extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  final void Function(String) onPersonTap;
  const _PeopleTab({required this.members, required this.onPersonTap});

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: members.length,
    itemBuilder: (_, i) {
      final m = members[i];
      return GestureDetector(
        onTap: () => onPersonTap(m['id'] as String),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            _Avatar(name: m['name'] as String, radius: 24),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              Text(m['role'] as String, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
              const SizedBox(height: 6),
              Row(children: [
                _MiniChip(_travelLabel(m['travelStatus'] as String), _travelColor(m['travelStatus'] as String)),
                const SizedBox(width: 6),
                _MiniChip(_attireLabel(m['attireStatus'] as String), _attireColor(m['attireStatus'] as String)),
              ]),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Icon(Icons.chevron_right, color: AppTheme.udoTextSecondary),
              if ((m['pendingTasks'] as int) > 0)
                Text('${m['pendingTasks']} tasks', style: const TextStyle(fontSize: 11, color: AppTheme.udoCrimson)),
            ]),
          ]),
        ),
      );
    },
  );

  String _travelLabel(String s) {
    switch (s) {
      case 'confirmed': return 'Travel ✓';
      case 'needs-response': return 'Travel ?';
      case 'travelling': return 'Travelling';
      case 'delayed': return 'Delayed';
      default: return s;
    }
  }

  Color _travelColor(String s) {
    if (s == 'confirmed') return const Color(0xFF22C55E);
    if (s == 'needs-response' || s == 'delayed') return AppTheme.udoCrimson;
    return Colors.orange;
  }

  String _attireLabel(String s) {
    switch (s) {
      case 'complete': return 'Attire ✓';
      case 'needs-fitting': return 'Fitting needed';
      case 'pending-approval': return 'Awaiting approval';
      case 'measurements-needed': return 'Measurements needed';
      default: return s;
    }
  }

  Color _attireColor(String s) {
    if (s == 'complete') return const Color(0xFF22C55E);
    if (s == 'needs-fitting' || s == 'measurements-needed') return AppTheme.udoCrimson;
    return Colors.orange;
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
  );
}

// ── RESPONSIBILITIES TAB ───────────────────────────────────────────────────────

class _ResponsibilitiesTab extends StatefulWidget {
  final List<Map<String, dynamic>> members;
  const _ResponsibilitiesTab({required this.members});
  @override
  State<_ResponsibilitiesTab> createState() => _ResponsibilitiesTabState();
}

class _ResponsibilitiesTabState extends State<_ResponsibilitiesTab> {
  late List<Map<String, dynamic>> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = [
      {'title': 'Coordinate bridesmaids arrivals', 'description': 'Ensure all bridesmaids are ready and in position before the ceremony starts.', 'owner': 'Sarah Johnson', 'backupOwner': '', 'time': '9:00 AM', 'location': 'Bridal suite', 'status': 'in-progress', 'urgency': 'high', 'linkedEvent': 'Ceremony - 4:00 PM', 'dependencies': '', 'notes': '', 'transport': ''},
      {'title': 'Manage vendor check-ins', 'description': 'Greet and direct all vendors to their designated areas.', 'owner': 'Michael Chen', 'backupOwner': '', 'time': '2:00 PM', 'location': 'Venue entrance', 'status': 'assigned', 'urgency': 'high', 'linkedEvent': 'None', 'dependencies': '', 'notes': '', 'transport': ''},
      {'title': 'Distribute bouquets and buttonholes', 'description': 'Collect florals from florist and distribute to all wedding party members.', 'owner': 'Emily Davis', 'backupOwner': 'Amanda White', 'time': '3:30 PM', 'location': 'Florist prep room', 'status': 'assigned', 'urgency': 'medium', 'linkedEvent': 'None', 'dependencies': 'Florist delivery confirmed', 'notes': '', 'transport': ''},
      {'title': 'Escort parents to seats', 'description': 'Escort both sets of parents down the aisle to their reserved seats before the ceremony.', 'owner': 'James Wilson', 'backupOwner': '', 'time': '4:00 PM', 'location': 'Ceremony aisle', 'status': 'assigned', 'urgency': 'medium', 'linkedEvent': 'Ceremony - 4:00 PM', 'dependencies': '', 'notes': '', 'transport': ''},
      {'title': 'Coordinate cake cutting', 'description': 'Signal the DJ and photographer, cue the couple, and have venue staff ready with plates.', 'owner': 'Amanda White', 'backupOwner': '', 'time': '8:00 PM', 'location': 'Reception hall', 'status': 'assigned', 'urgency': 'low', 'linkedEvent': 'Reception - 6:00 PM', 'dependencies': '', 'notes': '', 'transport': ''},
      {'title': 'Gather gifts at end of night', 'description': 'Collect all gifts and cards and secure them in the designated vehicle.', 'owner': 'Ryan Taylor', 'backupOwner': '', 'time': '11:00 PM', 'location': 'Reception exit', 'status': 'assigned', 'urgency': 'low', 'linkedEvent': 'None', 'dependencies': '', 'notes': '', 'transport': ''},
    ];
  }

  void _openDetail(Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ResponsibilityDetailSheet(
        task: Map<String, dynamic>.from(task),
        members: widget.members,
        onSave: (updated) => setState(() {
          final i = _tasks.indexWhere((t) => t['title'] == task['title']);
          if (i >= 0) _tasks[i] = updated;
        }),
        onDelete: () => setState(() => _tasks.removeWhere((t) => t['title'] == task['title'])),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          const Expanded(child: Text('Day-of responsibilities', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('Add', style: TextStyle(fontSize: 13))),
        ]),
        const SizedBox(height: 8),
        for (final task in _tasks) GestureDetector(
          onTap: () => _openDetail(task),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: task['status'] == 'in-progress' ? AppTheme.udoGreen.withValues(alpha: 0.4) : AppTheme.udoBorder),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(task['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                _UrgencyBadge(task['urgency'] as String),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.person_outline, size: 14, color: AppTheme.udoTextSecondary),
                const SizedBox(width: 4),
                Text(task['owner'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                const Spacer(),
                const Icon(Icons.schedule, size: 14, color: AppTheme.udoTextSecondary),
                const SizedBox(width: 4),
                Text(task['time'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                _StatusBadge(task['status'] as String),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 16, color: AppTheme.udoTextSecondary),
              ]),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── RESPONSIBILITY DETAIL SHEET ────────────────────────────────────────────────

class _ResponsibilityDetailSheet extends StatefulWidget {
  final Map<String, dynamic> task;
  final List<Map<String, dynamic>> members;
  final void Function(Map<String, dynamic>) onSave;
  final VoidCallback onDelete;
  const _ResponsibilityDetailSheet({required this.task, required this.members, required this.onSave, required this.onDelete});
  @override
  State<_ResponsibilityDetailSheet> createState() => _ResponsibilityDetailSheetState();
}

class _ResponsibilityDetailSheetState extends State<_ResponsibilityDetailSheet> {
  late final TextEditingController _title, _description, _location, _dependencies, _notes;
  late String _owner, _backupOwner, _status, _urgency, _linkedEvent;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t['title'] as String);
    _description = TextEditingController(text: t['description'] as String);
    _location = TextEditingController(text: t['location'] as String);
    _dependencies = TextEditingController(text: t['dependencies'] as String);
    _notes = TextEditingController(text: t['notes'] as String);
    _owner = t['owner'] as String;
    _backupOwner = t['backupOwner'] as String;
    _status = t['status'] as String;
    _urgency = t['urgency'] as String;
    _linkedEvent = t['linkedEvent'] as String;
  }

  @override
  void dispose() {
    _title.dispose(); _description.dispose(); _location.dispose();
    _dependencies.dispose(); _notes.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave({
      ...widget.task,
      'title': _title.text, 'description': _description.text,
      'location': _location.text, 'dependencies': _dependencies.text,
      'notes': _notes.text, 'owner': _owner, 'backupOwner': _backupOwner,
      'status': _status, 'urgency': _urgency, 'linkedEvent': _linkedEvent,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final peopleNames = widget.members.map((m) => m['name'] as String).toList();
    return DraggableScrollableSheet(
      expand: false, initialChildSize: 0.92, maxChildSize: 0.98,
      builder: (_, ctrl) => Column(children: [
        // Sticky header
        Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(children: [
            const Expanded(child: Text('Responsibility Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
          ]),
        ),
        const Divider(height: 1),
        // Scrollable fields
        Expanded(child: SingleChildScrollView(controller: ctrl, padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SheetField('Title', _title),
          const SizedBox(height: 14),
          _SheetField('Description', _description, maxLines: 4),
          const SizedBox(height: 14),
          _SheetDropdown('Assigned person', _owner, peopleNames, (v) => setState(() => _owner = v)),
          const SizedBox(height: 14),
          _SheetDropdownNullable('Backup person (optional)', _backupOwner, ['', ...peopleNames], (v) => setState(() => _backupOwner = v ?? '')),
          const SizedBox(height: 14),
          _SheetField('Location', _location),
          const SizedBox(height: 14),
          _SheetDropdown('Linked timeline event', _linkedEvent, ['None', 'Hair & Makeup - 10:00 AM', 'Photography - 2:00 PM', 'Ceremony - 4:00 PM', 'Reception - 6:00 PM'], (v) => setState(() => _linkedEvent = v)),
          const SizedBox(height: 14),
          _SheetField('Dependencies', _dependencies, hint: 'e.g. Florist delivery confirmed'),
          const SizedBox(height: 14),
          _SheetDropdown('Priority', _urgency, ['high', 'medium', 'low'], (v) => setState(() => _urgency = v), display: {'high': 'High', 'medium': 'Medium', 'low': 'Low'}),
          const SizedBox(height: 14),
          _SheetDropdown('Status', _status, ['assigned', 'viewed', 'acknowledged', 'in-progress', 'delayed', 'needs-help', 'escalated', 'completed'], (v) => setState(() => _status = v), display: {'assigned': 'Assigned', 'viewed': 'Viewed', 'acknowledged': 'Acknowledged', 'in-progress': 'In Progress', 'delayed': 'Delayed', 'needs-help': 'Needs Help', 'escalated': 'Escalated', 'completed': 'Completed'}),
          const SizedBox(height: 14),
          _SheetField('Notes', _notes, maxLines: 3, hint: 'Additional notes or instructions...'),
          const SizedBox(height: 14),
          const Text('Communication history', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('2h ago: Sent reminder via WhatsApp', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            SizedBox(height: 4),
            Text('1d ago: Task assigned', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
          ])),
          const SizedBox(height: 24),
        ]))),
        // Sticky footer
        const Divider(height: 1),
        Container(
          color: AppTheme.udoBackground,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: SafeArea(top: false, child: Wrap(spacing: 8, runSpacing: 8, children: [
            _FooterBtn('Save', AppTheme.udoGreen, Icons.save_outlined, _save),
            _FooterBtn('Mark complete', const Color(0xFF22C55E), Icons.check_circle_outline, () {
              setState(() => _status = 'completed');
              _save();
            }),
            _FooterBtn('Send buzz', Colors.blue, Icons.send_outlined, () => Navigator.pop(context)),
            _FooterBtn('Reassign', Colors.purple, Icons.person_outlined, () {}),
            _FooterBtn('Delete', Colors.red, Icons.delete_outline, () {
              Navigator.pop(context);
              widget.onDelete();
            }),
          ])),
        ),
      ]),
    );
  }
}

Widget _FooterBtn(String label, Color color, IconData icon, VoidCallback onTap) => ElevatedButton.icon(
  onPressed: onTap,
  icon: Icon(icon, size: 16),
  label: Text(label, style: const TextStyle(fontSize: 13)),
  style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
);

Widget _SheetField(String label, TextEditingController ctrl, {int maxLines = 1, String? hint}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
  const SizedBox(height: 6),
  TextField(controller: ctrl, maxLines: maxLines, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13), filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.udoGreen, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))),
]);

Widget _SheetDropdown(String label, String value, List<String> options, ValueChanged<String> onChanged, {Map<String, String>? display}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
  const SizedBox(height: 6),
  DropdownButtonFormField<String>(
    value: options.contains(value) ? value : options.first,
    decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4)),
    items: options.map((o) => DropdownMenuItem(value: o, child: Text(display?[o] ?? o, style: const TextStyle(fontSize: 14)))).toList(),
    onChanged: (v) { if (v != null) onChanged(v); },
  ),
]);

Widget _SheetDropdownNullable(String label, String value, List<String> options, ValueChanged<String?> onChanged) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
  const SizedBox(height: 6),
  DropdownButtonFormField<String>(
    value: options.contains(value) ? value : '',
    decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4)),
    items: options.map((o) => DropdownMenuItem(value: o, child: Text(o.isEmpty ? 'None' : o, style: const TextStyle(fontSize: 14)))).toList(),
    onChanged: onChanged,
  ),
]);

class _UrgencyBadge extends StatelessWidget {
  final String urgency;
  const _UrgencyBadge(this.urgency);

  @override
  Widget build(BuildContext context) {
    final color = urgency == 'high' ? AppTheme.udoCrimson : urgency == 'medium' ? Colors.orange : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(urgency[0].toUpperCase() + urgency.substring(1), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final color = status == 'in-progress' ? AppTheme.udoGreen : status == 'completed' ? const Color(0xFF22C55E) : AppTheme.udoTextSecondary;
    final label = status == 'in-progress' ? 'In progress' : status == 'completed' ? 'Done' : 'Assigned';
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 12, color: color)),
    ]);
  }
}

// ── BUZZES TAB ─────────────────────────────────────────────────────────────────

class _BuzzesTab extends StatefulWidget {
  @override
  State<_BuzzesTab> createState() => _BuzzesTabState();
}

class _BuzzesTabState extends State<_BuzzesTab> {
  final _ctrl = TextEditingController();
  String _tone = 'gentle';
  String _channel = 'WhatsApp';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Send a buzz', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl, maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write your message to the wedding party...',
                hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14),
                filled: true, fillColor: const Color(0xFFF3EFEA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Tone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, children: [
              for (final t in ['gentle', 'warm', 'loving', 'excited', 'encouraging', 'formal'])
                ChoiceChip(
                  label: Text(t[0].toUpperCase() + t.substring(1), style: const TextStyle(fontSize: 12)),
                  selected: _tone == t,
                  onSelected: (_) => setState(() => _tone = t),
                  selectedColor: AppTheme.udoGreen,
                  labelStyle: TextStyle(color: _tone == t ? Colors.white : AppTheme.udoTextPrimary),
                  side: BorderSide(color: _tone == t ? AppTheme.udoGreen : AppTheme.udoBorder),
                ),
            ]),
            const SizedBox(height: 12),
            const Text('Channel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Row(children: [
              for (final ch in ['WhatsApp', 'SMS', 'Email', 'In-app'])
                Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
                  label: Text(ch, style: const TextStyle(fontSize: 12)),
                  selected: _channel == ch,
                  onSelected: (_) => setState(() => _channel = ch),
                  selectedColor: AppTheme.udoGreen,
                  labelStyle: TextStyle(color: _channel == ch ? Colors.white : AppTheme.udoTextPrimary),
                  side: BorderSide(color: _channel == ch ? AppTheme.udoGreen : AppTheme.udoBorder),
                )),
            ]),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => _ctrl.clear(),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
              child: const Text('Send to all'),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        const Text('Recent buzzes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        for (final (msg, to, sent, status) in [
          ('Reminder: rehearsal is at 3pm sharp tomorrow at the venue.', 'All', '2h ago', 'read'),
          ('Don\'t forget to pick up your dresses today! 💕', 'Bridesmaids', '1d ago', 'delivered'),
          ('Hey team — hotel check-in is from 2pm. See you all there!', 'All', '2d ago', 'read'),
        ]) Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(msg, style: const TextStyle(fontSize: 13, height: 1.4)),
            const SizedBox(height: 6),
            Row(children: [
              Text('To: $to', style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
              const Spacer(),
              Container(width: 6, height: 6, decoration: BoxDecoration(color: status == 'read' ? AppTheme.udoGreen : Colors.orange, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(sent, style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
            ]),
          ]),
        ),
      ],
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}

// ── WEDDING TIMELINE TAB ───────────────────────────────────────────────────────

class _WeddingTimelineTab extends StatefulWidget {
  @override
  State<_WeddingTimelineTab> createState() => _WeddingTimelineTabState();
}

class _WeddingTimelineTabState extends State<_WeddingTimelineTab> {
  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _items = [
      {'time': '3:30 PM', 'title': 'Guests arrive', 'owner': 'Ushers', 'status': 'completed', 'startTime': '15:30', 'endTime': '16:00', 'location': 'Venue entrance', 'transport': '', 'notes': '', 'linkedResponsibilities': []},
      {'time': '4:00 PM', 'title': 'Ceremony begins', 'owner': 'Officiant', 'status': 'in-progress', 'startTime': '16:00', 'endTime': '16:30', 'location': 'Ceremony hall', 'transport': '', 'notes': '', 'linkedResponsibilities': []},
      {'time': '4:30 PM', 'title': 'Ceremony ends', 'owner': 'Wedding party', 'status': 'upcoming', 'startTime': '16:30', 'endTime': '16:45', 'location': 'Ceremony hall', 'transport': '', 'notes': '', 'linkedResponsibilities': []},
      {'time': '4:45 PM', 'title': 'Photos', 'owner': 'Photographer', 'status': 'upcoming', 'startTime': '16:45', 'endTime': '17:00', 'location': 'Garden', 'transport': '', 'notes': '', 'linkedResponsibilities': []},
      {'time': '5:00 PM', 'title': 'Cocktail hour', 'owner': 'Catering', 'status': 'upcoming', 'startTime': '17:00', 'endTime': '18:00', 'location': 'Terrace', 'transport': '', 'notes': '', 'linkedResponsibilities': []},
      {'time': '6:00 PM', 'title': 'Grand entrance', 'owner': 'DJ', 'status': 'upcoming', 'startTime': '18:00', 'endTime': '18:15', 'location': 'Reception hall', 'transport': '', 'notes': '', 'linkedResponsibilities': []},
      {'time': '6:15 PM', 'title': 'First dance', 'owner': 'Couple', 'status': 'upcoming', 'startTime': '18:15', 'endTime': '18:30', 'location': 'Dance floor', 'transport': '', 'notes': '', 'linkedResponsibilities': []},
      {'time': '6:30 PM', 'title': 'Dinner service', 'owner': 'Catering', 'status': 'upcoming', 'startTime': '18:30', 'endTime': '19:30', 'location': 'Reception hall', 'transport': '', 'notes': '', 'linkedResponsibilities': []},
      {'time': '7:30 PM', 'title': 'Speeches', 'owner': 'Best man & MOH', 'status': 'upcoming', 'startTime': '19:30', 'endTime': '20:00', 'location': 'Reception hall', 'transport': '', 'notes': '', 'linkedResponsibilities': []},
      {'time': '8:00 PM', 'title': 'Cake cutting', 'owner': 'Couple', 'status': 'upcoming', 'startTime': '20:00', 'endTime': '20:15', 'location': 'Reception hall', 'transport': '', 'notes': '', 'linkedResponsibilities': []},
      {'time': '8:15 PM', 'title': 'Dance floor opens', 'owner': 'DJ', 'status': 'upcoming', 'startTime': '20:15', 'endTime': '23:30', 'location': 'Reception hall', 'transport': '', 'notes': '', 'linkedResponsibilities': []},
    ];
  }

  void _openDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _TimelineItemDetailSheet(
        item: Map<String, dynamic>.from(item),
        onSave: (updated) => setState(() {
          final i = _items.indexWhere((t) => t['title'] == item['title'] && t['time'] == item['time']);
          if (i >= 0) _items[i] = updated;
        }),
        onDelete: () => setState(() => _items.removeWhere((t) => t['title'] == item['title'] && t['time'] == item['time'])),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Day timeline', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        ..._items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final isLast = i == _items.length - 1;
          return GestureDetector(
            onTap: () => _openDetail(item),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(children: [
                _TimelineDot(item['status'] as String),
                if (!isLast) Container(width: 2, height: 56, color: AppTheme.udoBorder),
              ]),
              const SizedBox(width: 14),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item['time'] as String, style: const TextStyle(fontSize: 11, color: AppTheme.udoGreen, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Row(children: [
                    Expanded(child: Text(item['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                    const Icon(Icons.chevron_right, size: 16, color: AppTheme.udoTextSecondary),
                  ]),
                  Text(item['owner'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                ]),
              )),
            ]),
          );
        }),
      ],
    );
  }
}

class _TimelineDot extends StatelessWidget {
  final String status;
  const _TimelineDot(this.status);
  @override
  Widget build(BuildContext context) {
    if (status == 'completed') return const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20);
    if (status == 'in-progress') return Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppTheme.udoGreen, shape: BoxShape.circle));
    return Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.udoBorder, width: 2)));
  }
}

// ── TIMELINE ITEM DETAIL SHEET ─────────────────────────────────────────────────

class _TimelineItemDetailSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  final void Function(Map<String, dynamic>) onSave;
  final VoidCallback onDelete;
  const _TimelineItemDetailSheet({required this.item, required this.onSave, required this.onDelete});
  @override
  State<_TimelineItemDetailSheet> createState() => _TimelineItemDetailSheetState();
}

class _TimelineItemDetailSheetState extends State<_TimelineItemDetailSheet> {
  late final TextEditingController _title, _location, _transport, _notes;
  late String _startTime, _endTime, _owner, _status;
  bool _timeChanged = false;

  static const _coordinators = [
    'Sarah Johnson - Maid of Honour', 'Michael Chen - Best Man',
    'Emily Davis - Bridesmaid', 'James Wilson - Groomsman',
    'Amanda White - Bridesmaid', 'Wedding Planner', 'Bride', 'Groom',
  ];

  static const _statusOptions = ['scheduled', 'confirmed', 'in-progress', 'at-risk', 'delayed', 'completed'];
  static const _statusDisplay = {'scheduled': 'Scheduled', 'confirmed': 'Confirmed', 'in-progress': 'In Progress', 'at-risk': 'At Risk', 'delayed': 'Delayed', 'completed': 'Completed'};

  @override
  void initState() {
    super.initState();
    final it = widget.item;
    _title = TextEditingController(text: it['title'] as String);
    _location = TextEditingController(text: it['location'] as String);
    _transport = TextEditingController(text: it['transport'] as String? ?? '');
    _notes = TextEditingController(text: it['notes'] as String? ?? '');
    _startTime = it['startTime'] as String;
    _endTime = it['endTime'] as String;
    _owner = _coordinators.first;
    _status = _statusOptions.contains(it['status']) ? (it['status'] as String) : 'scheduled';
  }

  @override
  void dispose() {
    _title.dispose(); _location.dispose(); _transport.dispose(); _notes.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave({
      ...widget.item,
      'title': _title.text, 'location': _location.text,
      'transport': _transport.text, 'notes': _notes.text,
      'startTime': _startTime, 'endTime': _endTime,
      'owner': _owner, 'status': _status,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    expand: false, initialChildSize: 0.92, maxChildSize: 0.98,
    builder: (_, ctrl) => Column(children: [
      Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Row(children: [
          const Expanded(child: Text('Timeline Event Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
        ]),
      ),
      const Divider(height: 1),
      Expanded(child: SingleChildScrollView(controller: ctrl, padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SheetField('Event title', _title),
        const SizedBox(height: 14),
        // Time range
        Row(children: [
          Expanded(child: _TimeField('Start time', _startTime, (v) => setState(() { _startTime = v; _timeChanged = v != widget.item['startTime']; }))),
          const SizedBox(width: 12),
          Expanded(child: _TimeField('End time', _endTime, (v) => setState(() => _endTime = v))),
        ]),
        // Downstream warning
        if (_timeChanged) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFCD34D))),
            child: const Row(children: [
              Icon(Icons.warning_amber_outlined, color: Color(0xFFD97706), size: 18),
              SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Time Change Detected', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                SizedBox(height: 2),
                Text('This will affect following events. Auto-adjustment is enabled.', style: TextStyle(fontSize: 12, color: Color(0xFFB45309))),
              ])),
            ]),
          ),
        ],
        const SizedBox(height: 14),
        _SheetField('Location', _location, hint: 'e.g. Bridal Suite, Ceremony Venue'),
        const SizedBox(height: 14),
        _SheetDropdown('Event coordinator', _owner, _coordinators, (v) => setState(() => _owner = v)),
        const SizedBox(height: 14),
        // Affected people
        const Text('Affected people', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (final p in ['Sarah Johnson', 'Michael Chen', 'Emily Davis'])
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.udoBorder)),
                child: Text(p, style: const TextStyle(fontSize: 12)),
              ),
            GestureDetector(
              onTap: () {},
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppTheme.udoGreen, borderRadius: BorderRadius.circular(20)), child: const Text('+ Add person', style: TextStyle(color: Colors.white, fontSize: 12))),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        // Linked responsibilities
        const Text('Linked responsibilities', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _LinkedRow('Setup floral arrangements', 'Completed', const Color(0xFF22C55E)),
            const SizedBox(height: 6),
            _LinkedRow('Coordinate photographer arrival', 'In Progress', Colors.blue),
            const SizedBox(height: 6),
            GestureDetector(onTap: () {}, child: const Text('+ Link responsibility', style: TextStyle(fontSize: 13, color: AppTheme.udoGreen))),
          ]),
        ),
        const SizedBox(height: 14),
        _SheetField('Transport details', _transport, hint: 'e.g. Shared car from hotel at 9:30 AM', maxLines: 2),
        const SizedBox(height: 14),
        _SheetField('Notes', _notes, hint: 'Additional notes or instructions...', maxLines: 3),
        const SizedBox(height: 14),
        _SheetDropdown('Status', _status, _statusOptions, (v) => setState(() => _status = v), display: _statusDisplay),
        const SizedBox(height: 14),
        // Dependencies
        const Text('Depends on', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.access_time, size: 14, color: AppTheme.udoTextSecondary),
              const SizedBox(width: 6),
              const Expanded(child: Text('Hair & Makeup (must complete 30 min before)', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))),
            ]),
            const SizedBox(height: 6),
            GestureDetector(onTap: () {}, child: const Text('+ Add dependency', style: TextStyle(fontSize: 13, color: AppTheme.udoGreen))),
          ]),
        ),
        const SizedBox(height: 24),
      ]))),
      const Divider(height: 1),
      Container(
        color: AppTheme.udoBackground,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: SafeArea(top: false, child: Wrap(spacing: 8, runSpacing: 8, children: [
          _FooterBtn('Save', AppTheme.udoGreen, Icons.save_outlined, _save),
          _FooterBtn('Notify people', Colors.blue, Icons.notifications_outlined, () => Navigator.pop(context)),
          _FooterBtn('Delete event', Colors.red, Icons.delete_outline, () {
            Navigator.pop(context);
            widget.onDelete();
          }),
        ])),
      ),
    ]),
  );
}

class _TimeField extends StatelessWidget {
  final String label, value;
  final ValueChanged<String> onChanged;
  const _TimeField(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final parts = value.split(':');
    final h = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () async {
          final picked = await showTimePicker(context: context, initialTime: TimeOfDay(hour: h, minute: m));
          if (picked != null) onChanged('${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
            const Icon(Icons.access_time, size: 16, color: AppTheme.udoTextSecondary),
          ]),
        ),
      ),
    ]);
  }
}

Widget _LinkedRow(String title, String statusLabel, Color color) => Row(children: [
  Expanded(child: Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextPrimary))),
  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text(statusLabel, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500))),
]);

// ── TRAVEL TAB ─────────────────────────────────────────────────────────────────

class _TravelTab extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  const _TravelTab({required this.members});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      sectionCard('Hotels', [
        ('Grand Marriott', '4 rooms blocked', '8 party members'),
        ('Boutique Inn', '2 rooms', '4 party members'),
      ]),
      const SizedBox(height: 12),
      sectionCard('Transport', [
        ('Shuttle — Airport to Hotel', 'Friday 4pm pickup', '6 people'),
        ('Shuttle — Hotel to Venue', 'Saturday 3pm', 'All party'),
      ]),
      const SizedBox(height: 12),
      const Text('Travel status by member', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      for (final m in members) Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
        child: Row(children: [
          _Avatar(name: m['name'] as String),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text(m['role'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          ])),
          _TravelBadge(m['travelStatus'] as String),
        ]),
      ),
    ],
  );
}

class _TravelBadge extends StatelessWidget {
  final String status;
  const _TravelBadge(this.status);
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'confirmed' => ('Confirmed', const Color(0xFF22C55E)),
      'needs-response' => ('Needs response', AppTheme.udoCrimson),
      'travelling' => ('Travelling', Colors.blue),
      'checked-in' => ('Checked in', AppTheme.udoGreen),
      _ => (status, Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

Widget sectionCard(String title, List<(String, String, String)> items) => Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
    const SizedBox(height: 10),
    for (final (name, detail1, detail2) in items) Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Text('$detail1 · $detail2', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
      ]),
    ),
  ]),
);

// ── REHEARSAL TAB ──────────────────────────────────────────────────────────────

class _RehearsalTab extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  const _RehearsalTab({required this.members});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.udoGreen, AppTheme.udoGreen.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Rehearsal dinner', style: TextStyle(color: Colors.white70, fontSize: 13)),
          SizedBox(height: 4),
          Text('Friday, September 13', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 2),
          Text('7:00 PM · Rosewood Restaurant', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      ),
      const SizedBox(height: 12),
      const Text('Attendance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      for (final m in members) Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
        child: Row(children: [
          _Avatar(name: m['name'] as String),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text(m['role'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          ])),
          _RehearsalBadge(m['rehearsalStatus'] as String),
        ]),
      ),
    ],
  );
}

class _RehearsalBadge extends StatelessWidget {
  final String status;
  const _RehearsalBadge(this.status);
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'confirmed' => ('Confirmed', const Color(0xFF22C55E)),
      'pending' => ('Pending', Colors.orange),
      'declined' => ('Declined', AppTheme.udoCrimson),
      _ => (status, Colors.grey),
    };
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)));
  }
}

// ── EMERGENCY TAB ──────────────────────────────────────────────────────────────

class _EmergencyTab extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  const _EmergencyTab({required this.members});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.udoCrimson.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoCrimson.withValues(alpha: 0.3))),
        child: Row(children: [
          const Icon(Icons.warning_amber_outlined, color: AppTheme.udoCrimson, size: 20),
          const SizedBox(width: 10),
          const Expanded(child: Text('Emergency broadcast sends an urgent message to all wedding party members simultaneously.', style: TextStyle(fontSize: 13, color: AppTheme.udoCrimson, height: 1.5))),
        ]),
      ),
      const SizedBox(height: 12),
      ElevatedButton.icon(
        onPressed: () => _showEmergencyBroadcast(context),
        icon: const Icon(Icons.broadcast_on_personal_outlined),
        label: const Text('Send emergency broadcast'),
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoCrimson, foregroundColor: Colors.white),
      ),
      const SizedBox(height: 16),
      const Text('Emergency contacts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      for (final m in members) Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
        child: Row(children: [
          _Avatar(name: m['name'] as String),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text(m['role'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          ])),
          Row(children: [
            Icon(Icons.phone_outlined, color: AppTheme.udoGreen, size: 20),
            const SizedBox(width: 10),
            Icon(Icons.message_outlined, color: AppTheme.udoGreen, size: 20),
          ]),
        ]),
      ),
    ],
  );

  void _showEmergencyBroadcast(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _EmergencyBroadcastModal(),
    );
  }
}

class _EmergencyBroadcastModal extends StatelessWidget {
  const _EmergencyBroadcastModal();

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.warning_amber_outlined, color: AppTheme.udoCrimson),
              const SizedBox(width: 8),
              const Expanded(child: Text('Emergency broadcast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
            ]),
            const SizedBox(height: 8),
            const Text('This will immediately alert all wedding party members.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            const SizedBox(height: 16),
            TextField(controller: ctrl, maxLines: 4, decoration: InputDecoration(hintText: 'Type your urgent message...', filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(14))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoCrimson, foregroundColor: Colors.white),
              child: const Text('Send to all party members now'),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── FILES & SPEECHES TAB ───────────────────────────────────────────────────────

class _FilesSpeechesTab extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  const _FilesSpeechesTab({required this.members});

  @override
  Widget build(BuildContext context) {
    final speechGivers = members.where((m) => m['role'] == 'Maid of honour' || m['role'] == 'Best man').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Speeches', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        for (final m in speechGivers) Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            _Avatar(name: m['name'] as String),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text(m['role'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
            ])),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), minimumSize: Size.zero, side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
              child: const Text('Upload', style: TextStyle(fontSize: 12)),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        const Text('Shared files', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        for (final (icon, name, type) in [
          (Icons.picture_as_pdf_outlined, 'Ceremony runsheet.pdf', 'PDF'),
          (Icons.image_outlined, 'Group photo reference.jpg', 'Image'),
          (Icons.description_outlined, 'Seating arrangement.docx', 'Document'),
        ]) Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.udoGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppTheme.udoGreen, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text(type, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
            ])),
            const Icon(Icons.download_outlined, color: AppTheme.udoGreen, size: 20),
          ]),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_outlined, size: 18),
          label: const Text('Upload file'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
        ),
      ],
    );
  }
}

// ── PERSON DETAIL SHEET ────────────────────────────────────────────────────────

class _PersonDetailSheet extends StatelessWidget {
  final Map<String, dynamic> person;
  const _PersonDetailSheet({required this.person});

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.85,
    builder: (_, ctrl) => SafeArea(
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 12, bottom: 8), width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.udoBorder, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Row(children: [
            _Avatar(name: person['name'] as String, radius: 26),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(person['name'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Text(person['role'] as String, style: const TextStyle(fontSize: 14, color: AppTheme.udoTextSecondary)),
            ])),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
        ),
        Expanded(child: SingleChildScrollView(controller: ctrl, padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SectionTitle('Status'),
          _MiniChipRow([
            (_travelLabel(person['travelStatus'] as String), _travelColor(person['travelStatus'] as String)),
            (_attireLabel(person['attireStatus'] as String), _attireColor(person['attireStatus'] as String)),
            (_rehearsalLabel(person['rehearsalStatus'] as String), _rehearsalColor(person['rehearsalStatus'] as String)),
          ]),
          const SizedBox(height: 16),
          _SectionTitle('Responsibilities'),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)), child: const Text('No responsibilities assigned yet.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))),
          const SizedBox(height: 16),
          _SectionTitle('Contact'),
          const _InfoRow('Phone', '+1 (555) 123-4567'),
          const _InfoRow('Email', 'member@email.com'),
          const _InfoRow('Preferred', 'WhatsApp'),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.send_outlined, size: 16), label: const Text('Send buzz'), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Edit'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white))),
          ]),
        ]))),
      ]),
    ),
  );

  String _travelLabel(String s) => switch (s) { 'confirmed' => 'Travel ✓', 'needs-response' => 'Travel ?', _ => s };
  Color _travelColor(String s) => s == 'confirmed' ? const Color(0xFF22C55E) : s == 'needs-response' ? AppTheme.udoCrimson : Colors.orange;
  String _attireLabel(String s) => switch (s) { 'complete' => 'Attire ✓', 'needs-fitting' => 'Fitting needed', _ => s };
  Color _attireColor(String s) => s == 'complete' ? const Color(0xFF22C55E) : s == 'needs-fitting' ? AppTheme.udoCrimson : Colors.orange;
  String _rehearsalLabel(String s) => switch (s) { 'confirmed' => 'Rehearsal ✓', 'pending' => 'Rehearsal ?', _ => s };
  Color _rehearsalColor(String s) => s == 'confirmed' ? const Color(0xFF22C55E) : Colors.orange;
}

class _MiniChipRow extends StatelessWidget {
  final List<(String, Color)> items;
  const _MiniChipRow(this.items);
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6, runSpacing: 6,
    children: items.map((i) => _MiniChip(i.$1, i.$2)).toList(),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );
}

// ── ADD PERSON MODAL ───────────────────────────────────────────────────────────

class _AddPersonModal extends StatefulWidget {
  final void Function({required String firstName, required String lastName, required String role, String? email, String? phone}) onAdd;
  const _AddPersonModal({required this.onAdd});
  @override
  State<_AddPersonModal> createState() => _AddPersonModalState();
}

class _AddPersonModalState extends State<_AddPersonModal> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String _role = 'Bridesmaid';

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Add party member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
          ]),
          const SizedBox(height: 16),
          _FieldBox('Full name', _name),
          const SizedBox(height: 12),
          const Text('Role', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _role,
            decoration: _dec(),
            items: const [
              DropdownMenuItem(value: 'Maid of honour', child: Text('Maid of honour')),
              DropdownMenuItem(value: 'Best man', child: Text('Best man')),
              DropdownMenuItem(value: 'Bridesmaid', child: Text('Bridesmaid')),
              DropdownMenuItem(value: 'Groomsman', child: Text('Groomsman')),
              DropdownMenuItem(value: 'Flower girl', child: Text('Flower girl')),
              DropdownMenuItem(value: 'Ring bearer', child: Text('Ring bearer')),
            ],
            onChanged: (v) => setState(() => _role = v ?? 'Bridesmaid'),
          ),
          const SizedBox(height: 12),
          _FieldBox('Email', _email, type: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _FieldBox('Phone', _phone, type: TextInputType.phone),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final fullName = _name.text.trim();
              final parts = fullName.split(' ');
              final firstName = parts.isNotEmpty ? parts.first : fullName;
              final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
              widget.onAdd(
                firstName: firstName,
                lastName: lastName,
                role: _role,
                email: _email.text.trim(),
                phone: _phone.text.trim(),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
            child: const Text('Add to wedding party'),
          ),
        ]),
      ),
    ),
  );

  InputDecoration _dec() => InputDecoration(filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14));

  @override
  void dispose() { _name.dispose(); _email.dispose(); _phone.dispose(); super.dispose(); }
}

class _FieldBox extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final TextInputType? type;
  const _FieldBox(this.label, this.ctrl, {this.type});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    const SizedBox(height: 6),
    TextField(controller: ctrl, keyboardType: type, decoration: InputDecoration(hintText: label, hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14), filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.udoGreen, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
  ]);
}

// ── AVATAR ─────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final double radius;
  const _Avatar({required this.name, this.radius = 20});
  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: AppTheme.udoGreen.withValues(alpha: 0.12),
    child: Text(name.isNotEmpty ? name[0] : '?', style: TextStyle(color: AppTheme.udoGreen, fontWeight: FontWeight.w700, fontSize: radius * 0.7)),
  );
}
