import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/wedding_party_provider.dart';

String _fullName(Map<String, dynamic> g) => '${g['first_name'] ?? ''} ${g['last_name'] ?? ''}'.trim();

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

String _formatDate(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return DateFormat('EEE, MMM d').format(d);
}

String _formatFileSize(int? bytes) {
  if (bytes == null) return '';
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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

Widget _emptyBox(String message, {IconData icon = Icons.inbox_outlined}) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 36, color: AppTheme.udoTextSecondary),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary), textAlign: TextAlign.center),
        ]),
      ),
    );

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weddingPartyProvider);
    final notifier = ref.read(weddingPartyProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.udoBackground,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _Header(tabs: _tabs, count: state.members.length, onRefresh: notifier.refresh),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _OverviewTab(state: state, onPersonTap: (id) => _showPersonDetail(context, state, id)),
                      _PeopleTab(state: state, onPersonTap: (id) => _showPersonDetail(context, state, id)),
                      _ResponsibilitiesTab(state: state),
                      _BuzzesTab(state: state),
                      _WeddingTimelineTab(state: state),
                      _TravelTab(state: state),
                      _RehearsalTab(state: state),
                      _EmergencyTab(state: state),
                      _FilesSpeechesTab(state: state),
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

  void _showPersonDetail(BuildContext context, WeddingPartyState state, String id) {
    final person = state.members.firstWhere((m) => m['id'].toString() == id, orElse: () => {});
    if (person.isEmpty) return;
    final responsibilities = state.responsibilities.where((r) => r['guest_id']?.toString() == id).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PersonDetailSheet(person: person, responsibilities: responsibilities),
    );
  }

  void _showAddPersonModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddPersonModal(
        onAdd: ({required firstName, required lastName, required role, email, phone}) async {
          final ok = await ref.read(weddingPartyProvider.notifier).addMember(
                firstName: firstName,
                lastName: lastName,
                role: role,
                email: email,
                phone: phone,
              );
          if (!context.mounted) return;
          if (!ok) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't add this person. Try again.")));
          }
        },
      ),
    );
  }
}

// ── HEADER ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final TabController tabs;
  final int count;
  final VoidCallback onRefresh;
  const _Header({required this.tabs, required this.count, required this.onRefresh});

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
              IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh, color: Colors.white, size: 20), tooltip: 'Refresh'),
            ]),
          ),
          const SizedBox(height: 4),
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

class _OverviewTab extends ConsumerWidget {
  final WeddingPartyState state;
  final void Function(String) onPersonTap;
  const _OverviewTab({required this.state, required this.onPersonTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = state.members;
    final openByGuest = <String, int>{};
    for (final r in state.responsibilities) {
      if (r['status'] == 'done' || r['guest_id'] == null) continue;
      final gid = r['guest_id'].toString();
      openByGuest[gid] = (openByGuest[gid] ?? 0) + 1;
    }
    final needsAttention = members.where((m) => (openByGuest[m['id'].toString()] ?? 0) > 0).toList();
    final travelConfirmed = members.where((m) => m['hotel_assignment_id'] != null || m['transport_assignment_id'] != null).length;
    final attireReady = members.where((m) => m['attire_status'] == 'ready').length;
    final rehearsalConfirmed = members.where((m) => m['rehearsal_status'] == 'confirmed').length;

    if (state.membersError != null) {
      return _errorBox("Couldn't load your wedding party.", state.membersError!);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            _MiniStat('${members.length}', 'Total', AppTheme.udoGreen),
            _MiniStat('$travelConfirmed', 'Travel\narranged', const Color(0xFF22C55E)),
            _MiniStat('$attireReady', 'Attire\nready', Colors.blue),
            _MiniStat('$rehearsalConfirmed', 'Rehearsal\nconfirmed', Colors.purple),
          ]),
        ),
        const SizedBox(height: 12),

        if (needsAttention.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.udoCrimson.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoCrimson.withValues(alpha: 0.2))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.warning_amber_outlined, color: AppTheme.udoCrimson, size: 18),
                const SizedBox(width: 8),
                Text('${needsAttention.length} need${needsAttention.length == 1 ? 's' : ''} your attention', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.udoCrimson)),
              ]),
              const SizedBox(height: 10),
              for (final m in needsAttention) GestureDetector(
                onTap: () => onPersonTap(m['id'].toString()),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    _Avatar(name: _fullName(m)),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_fullName(m), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      Text((m['wedding_party_role'] as String?) ?? 'Wedding party', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                    ])),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppTheme.udoCrimson.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text('${openByGuest[m['id'].toString()]} open', style: const TextStyle(fontSize: 11, color: AppTheme.udoCrimson))),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
        ],

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Send a buzz', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final label in ['Morning check-in', 'Rehearsal reminder', 'Day-of update', 'Thank you note'])
                ActionChip(
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  onPressed: members.isEmpty ? null : () async {
                    final ok = await ref.read(weddingPartyProvider.notifier).sendBuzz(body: label, channel: 'email');
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Buzz sent to your wedding party.' : "Couldn't send that buzz.")));
                  },
                  side: const BorderSide(color: AppTheme.udoBorder),
                ),
            ]),
          ]),
        ),
        const SizedBox(height: 12),

        const Text('All members', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        if (members.isEmpty) _emptyBox('No one added to your wedding party yet. Tap + to add someone.', icon: Icons.people_outline)
        else for (final m in members) _MemberRow(member: m, onTap: () => onPersonTap(m['id'].toString())),
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
        _Avatar(name: _fullName(member)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_fullName(member), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text((member['wedding_party_role'] as String?) ?? 'Wedding party', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        ])),
        _AttireDot(member['attire_status'] as String?),
        const SizedBox(width: 4),
        _RehearsalDot(member['rehearsal_status'] as String?),
      ]),
    ),
  );
}

class _AttireDot extends StatelessWidget {
  final String? status;
  const _AttireDot(this.status);
  @override
  Widget build(BuildContext context) {
    final color = status == 'ready' ? const Color(0xFF22C55E) : status == 'fitted' || status == 'ordered' ? Colors.orange : AppTheme.udoBorder;
    return Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class _RehearsalDot extends StatelessWidget {
  final String? status;
  const _RehearsalDot(this.status);
  @override
  Widget build(BuildContext context) {
    final color = status == 'confirmed' ? const Color(0xFF22C55E) : status == 'declined' ? AppTheme.udoCrimson : AppTheme.udoBorder;
    return Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

// ── PEOPLE TAB ─────────────────────────────────────────────────────────────────

class _PeopleTab extends StatelessWidget {
  final WeddingPartyState state;
  final void Function(String) onPersonTap;
  const _PeopleTab({required this.state, required this.onPersonTap});

  String _attireLabel(String? s) => switch (s) {
        'ready' => 'Attire ready',
        'fitted' => 'Fitted',
        'ordered' => 'Ordered',
        'not_started' => 'Not started',
        _ => 'Attire pending',
      };

  Color _attireColor(String? s) => s == 'ready' ? const Color(0xFF22C55E) : (s == 'fitted' || s == 'ordered') ? Colors.orange : AppTheme.udoTextSecondary;

  String _rehearsalLabel(String? s) => switch (s) {
        'confirmed' => 'Rehearsal ✓',
        'declined' => "Won't attend",
        _ => 'Rehearsal ?',
      };

  Color _rehearsalColor(String? s) => s == 'confirmed' ? const Color(0xFF22C55E) : s == 'declined' ? AppTheme.udoCrimson : Colors.orange;

  @override
  Widget build(BuildContext context) {
    if (state.membersError != null) return _errorBox("Couldn't load your wedding party.", state.membersError!);
    if (state.members.isEmpty) return _emptyBox('No one added to your wedding party yet. Tap + to add someone.', icon: Icons.people_outline);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.members.length,
      itemBuilder: (_, i) {
        final m = state.members[i];
        return GestureDetector(
          onTap: () => onPersonTap(m['id'].toString()),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
            child: Row(children: [
              _Avatar(name: _fullName(m), radius: 24),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_fullName(m), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                Text((m['wedding_party_role'] as String?) ?? 'Wedding party', style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
                const SizedBox(height: 6),
                Row(children: [
                  _MiniChip(_attireLabel(m['attire_status'] as String?), _attireColor(m['attire_status'] as String?)),
                  const SizedBox(width: 6),
                  _MiniChip(_rehearsalLabel(m['rehearsal_status'] as String?), _rehearsalColor(m['rehearsal_status'] as String?)),
                ]),
              ])),
              const Icon(Icons.chevron_right, color: AppTheme.udoTextSecondary),
            ]),
          ),
        );
      },
    );
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

class _ResponsibilitiesTab extends ConsumerWidget {
  final WeddingPartyState state;
  const _ResponsibilitiesTab({required this.state});

  String _guestName(WeddingPartyState state, dynamic guestId) {
    if (guestId == null) return 'Unassigned';
    final g = state.members.firstWhere((m) => m['id'].toString() == guestId.toString(), orElse: () => {});
    return g.isEmpty ? 'Unassigned' : _fullName(g);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.responsibilitiesError != null) {
      return _errorBox("Couldn't load responsibilities.", state.responsibilitiesError!);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          const Expanded(child: Text('Day-of responsibilities', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          TextButton.icon(
            onPressed: () => _openEditor(context, ref, null),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add', style: TextStyle(fontSize: 13)),
          ),
        ]),
        const SizedBox(height: 8),
        if (state.responsibilities.isEmpty)
          _emptyBox('No responsibilities yet. Tap Add to assign one.', icon: Icons.checklist_outlined)
        else
          for (final task in state.responsibilities) GestureDetector(
            onTap: () => _openEditor(context, ref, task),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: task['status'] == 'in_progress' ? AppTheme.udoGreen.withValues(alpha: 0.4) : AppTheme.udoBorder),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(task['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                  _StatusBadge(task['status'] as String? ?? 'pending'),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.person_outline, size: 14, color: AppTheme.udoTextSecondary),
                  const SizedBox(width: 4),
                  Text(_guestName(state, task['guest_id']), style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                  if (task['due_date'] != null) ...[
                    const Spacer(),
                    const Icon(Icons.schedule, size: 14, color: AppTheme.udoTextSecondary),
                    const SizedBox(width: 4),
                    Text(_formatDate(task['due_date'] as String?), style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                  ],
                ]),
                if ((task['description'] as String?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 6),
                  Text(task['description'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ]),
            ),
          ),
      ],
    );
  }

  void _openEditor(BuildContext context, WidgetRef ref, Map<String, dynamic>? task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ResponsibilityEditorSheet(task: task, members: state.members),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final color = status == 'in_progress' ? AppTheme.udoGreen : status == 'done' ? const Color(0xFF22C55E) : AppTheme.udoTextSecondary;
    final label = status == 'in_progress' ? 'In progress' : status == 'done' ? 'Done' : 'Pending';
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 12, color: color)),
    ]);
  }
}

// ── RESPONSIBILITY EDITOR SHEET ────────────────────────────────────────────────

class _ResponsibilityEditorSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? task;
  final List<Map<String, dynamic>> members;
  const _ResponsibilityEditorSheet({required this.task, required this.members});
  @override
  ConsumerState<_ResponsibilityEditorSheet> createState() => _ResponsibilityEditorSheetState();
}

class _ResponsibilityEditorSheetState extends ConsumerState<_ResponsibilityEditorSheet> {
  late final TextEditingController _title, _description;
  String? _guestId;
  String _status = 'pending';
  DateTime? _dueDate;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t?['title'] as String? ?? '');
    _description = TextEditingController(text: t?['description'] as String? ?? '');
    _guestId = t?['guest_id']?.toString();
    _status = t?['status'] as String? ?? 'pending';
    final due = t?['due_date'] as String?;
    _dueDate = due != null ? DateTime.tryParse(due) : null;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Give this responsibility a title.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    final notifier = ref.read(weddingPartyProvider.notifier);
    final ok = _isEdit
        ? await notifier.updateResponsibility(widget.task!['id'] as int, {
            'title': _title.text.trim(),
            'description': _description.text.trim(),
            'guest_id': _guestId != null ? int.parse(_guestId!) : null,
            'status': _status,
            if (_dueDate != null) 'due_date': _dueDate!.toIso8601String().split('T').first,
          })
        : await notifier.createResponsibility(
            title: _title.text.trim(),
            description: _description.text.trim(),
            guestId: _guestId != null ? int.parse(_guestId!) : null,
            status: _status,
            dueDate: _dueDate,
          );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() { _saving = false; _error = "Couldn't save. Try again."; });
    }
  }

  Future<void> _delete() async {
    if (!_isEdit) return;
    Navigator.pop(context);
    await ref.read(weddingPartyProvider.notifier).deleteResponsibility(widget.task!['id'] as int);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false, initialChildSize: 0.85, maxChildSize: 0.95,
      builder: (_, ctrl) => Column(children: [
        Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(children: [
            Expanded(child: Text(_isEdit ? 'Edit responsibility' : 'New responsibility', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
          ]),
        ),
        const Divider(height: 1),
        Expanded(child: SingleChildScrollView(controller: ctrl, padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SheetField('Title', _title),
          const SizedBox(height: 14),
          _SheetField('Description', _description, maxLines: 3, hint: 'Optional'),
          const SizedBox(height: 14),
          const Text('Assigned to', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String?>(
            value: _guestId,
            decoration: _sheetDecoration(),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('Unassigned')),
              ...widget.members.map((m) => DropdownMenuItem<String?>(value: m['id'].toString(), child: Text(_fullName(m)))),
            ],
            onChanged: (v) => setState(() => _guestId = v),
          ),
          const SizedBox(height: 14),
          const Text('Due date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: _dueDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
              if (picked != null) setState(() => _dueDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Expanded(child: Text(_dueDate != null ? DateFormat('EEE, MMM d, yyyy').format(_dueDate!) : 'No due date', style: const TextStyle(fontSize: 14))),
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.udoTextSecondary),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: _sheetDecoration(),
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'in_progress', child: Text('In progress')),
              DropdownMenuItem(value: 'done', child: Text('Done')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'pending'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(fontSize: 12, color: AppTheme.udoCrimson)),
          ],
          const SizedBox(height: 24),
        ]))),
        const Divider(height: 1),
        Container(
          color: AppTheme.udoBackground,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: SafeArea(top: false, child: Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_outlined, size: 16),
              label: Text(_saving ? 'Saving…' : 'Save', style: const TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
            )),
            if (_isEdit) ...[
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                label: const Text('Delete', style: TextStyle(fontSize: 13, color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14)),
              ),
            ],
          ])),
        ),
      ]),
    );
  }
}

InputDecoration _sheetDecoration() => InputDecoration(filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4));

Widget _SheetField(String label, TextEditingController ctrl, {int maxLines = 1, String? hint}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
  const SizedBox(height: 6),
  TextField(controller: ctrl, maxLines: maxLines, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13), filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.udoGreen, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))),
]);

// ── BUZZES TAB ─────────────────────────────────────────────────────────────────

class _BuzzesTab extends ConsumerStatefulWidget {
  final WeddingPartyState state;
  const _BuzzesTab({required this.state});
  @override
  ConsumerState<_BuzzesTab> createState() => _BuzzesTabState();
}

class _BuzzesTabState extends ConsumerState<_BuzzesTab> {
  final _ctrl = TextEditingController();
  String _channel = 'email';
  bool _sending = false;

  static const _channels = {'email': 'Email', 'sms': 'SMS', 'whatsapp': 'WhatsApp', 'in_app': 'In-app'};

  Future<void> _send() async {
    final body = _ctrl.text.trim();
    if (body.isEmpty || widget.state.members.isEmpty) return;
    setState(() => _sending = true);
    final ok = await ref.read(weddingPartyProvider.notifier).sendBuzz(body: body, channel: _channel);
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) _ctrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Buzz sent to your wedding party.' : "Couldn't send that buzz. Try again.")));
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
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
            const Text('Channel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, children: [
              for (final entry in _channels.entries)
                ChoiceChip(
                  label: Text(entry.value, style: const TextStyle(fontSize: 12)),
                  selected: _channel == entry.key,
                  onSelected: (_) => setState(() => _channel = entry.key),
                  selectedColor: AppTheme.udoGreen,
                  labelStyle: TextStyle(color: _channel == entry.key ? Colors.white : AppTheme.udoTextPrimary),
                  side: BorderSide(color: _channel == entry.key ? AppTheme.udoGreen : AppTheme.udoBorder),
                ),
            ]),
            const SizedBox(height: 14),
            if (state.members.isEmpty)
              const Text('Add someone to your wedding party first.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
            ElevatedButton(
              onPressed: (_sending || state.members.isEmpty) ? null : _send,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
              child: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Send to all'),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        const Text('Recent buzzes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        if (state.buzzesError != null)
          _errorBox("Couldn't load recent buzzes.", state.buzzesError!)
        else if (state.buzzes.isEmpty)
          _emptyBox('No buzzes sent yet.', icon: Icons.campaign_outlined)
        else
          for (final msg in state.buzzes) Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(msg['body'] as String? ?? '', style: const TextStyle(fontSize: 13, height: 1.4)),
              const SizedBox(height: 6),
              Row(children: [
                Text('Via ${_channels[msg['channel']] ?? msg['channel']} · ${msg['recipient_count'] ?? 0} recipient${(msg['recipient_count'] ?? 0) == 1 ? '' : 's'}', style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
                const Spacer(),
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(_formatDate(msg['sent_at'] as String?), style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
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

class _WeddingTimelineTab extends StatelessWidget {
  final WeddingPartyState state;
  const _WeddingTimelineTab({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.timelineError != null) return _errorBox("Couldn't load the timeline.", state.timelineError!);
    if (state.timelineItems.isEmpty) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        _emptyBox('No timeline events yet.', icon: Icons.schedule_outlined),
        const SizedBox(height: 8),
        Center(child: TextButton(onPressed: () => context.push('/your-vision'), child: const Text('Build your day timeline'))),
      ]);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          const Expanded(child: Text('Day timeline', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          TextButton(onPressed: () => context.push('/your-vision'), child: const Text('Edit in Plan', style: TextStyle(fontSize: 13))),
        ]),
        const SizedBox(height: 12),
        ...state.timelineItems.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final isLast = i == state.timelineItems.length - 1;
          return GestureDetector(
            onTap: () => _openDetail(context, item),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(children: [
                Container(width: 20, height: 20, decoration: BoxDecoration(color: AppTheme.udoGreen, shape: BoxShape.circle)),
                if (!isLast) Container(width: 2, height: 56, color: AppTheme.udoBorder),
              ]),
              const SizedBox(width: 14),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_formatTime(item['start_time'] as String?), style: const TextStyle(fontSize: 11, color: AppTheme.udoGreen, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Row(children: [
                    Expanded(child: Text(item['title'] as String? ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                    const Icon(Icons.chevron_right, size: 16, color: AppTheme.udoTextSecondary),
                  ]),
                  if ((item['location'] as String?)?.isNotEmpty == true)
                    Text(item['location'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                ]),
              )),
            ]),
          );
        }),
      ],
    );
  }

  void _openDetail(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.5, maxChildSize: 0.8,
        builder: (_, ctrl) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: SingleChildScrollView(controller: ctrl, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item['title'] as String? ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _InfoRow('Time', '${_formatTime(item['start_time'] as String?)} – ${_formatTime(item['end_time'] as String?)}'),
            if ((item['location'] as String?)?.isNotEmpty == true) _InfoRow('Location', item['location'] as String),
            if ((item['description'] as String?)?.isNotEmpty == true) _InfoRow('Details', item['description'] as String),
            const SizedBox(height: 16),
            Text('Edit event details from Plan → Your Vision.', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          ])),
        ),
      ),
    );
  }
}

// ── TRAVEL TAB ─────────────────────────────────────────────────────────────────

class _TravelTab extends StatelessWidget {
  final WeddingPartyState state;
  const _TravelTab({required this.state});

  String _travelStatus(Map<String, dynamic> m) {
    if (m['travel_required'] != true) return 'not-required';
    if (m['hotel_assignment_id'] != null && m['transport_assignment_id'] != null) return 'arranged';
    if (m['arrival_date'] != null) return 'arriving';
    return 'needs-info';
  }

  @override
  Widget build(BuildContext context) {
    if (state.travelError != null) return _errorBox("Couldn't load travel details.", state.travelError!);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Hotels', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            if (state.accommodations.isEmpty)
              const Text('No accommodation options added yet.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary))
            else for (final a in state.accommodations) Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a['name'] as String? ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text('${a['total_rooms_blocked'] ?? 0} rooms blocked · ${a['rooms_assigned'] ?? 0} assigned', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Transport', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            if (state.transportGroups.isEmpty)
              const Text('No transport groups added yet.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary))
            else for (final t in state.transportGroups) Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t['name'] as String? ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text('${t['pickup_location'] ?? '—'} → ${t['dropoff_location'] ?? '—'} · ${(t['assignments'] as List?)?.length ?? 0} assigned', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        const Text('Travel status by member', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        if (state.members.isEmpty)
          _emptyBox('No wedding party members yet.', icon: Icons.people_outline)
        else for (final m in state.members) Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            _Avatar(name: _fullName(m)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_fullName(m), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text((m['wedding_party_role'] as String?) ?? 'Wedding party', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
            ])),
            _TravelBadge(_travelStatus(m)),
          ]),
        ),
      ],
    );
  }
}

class _TravelBadge extends StatelessWidget {
  final String status;
  const _TravelBadge(this.status);
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'arranged' => ('Arranged', const Color(0xFF22C55E)),
      'arriving' => ('Arriving', Colors.blue),
      'not-required' => ('Not traveling', Colors.grey),
      _ => ('Needs info', AppTheme.udoCrimson),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

// ── REHEARSAL TAB ──────────────────────────────────────────────────────────────

class _RehearsalTab extends ConsumerWidget {
  final WeddingPartyState state;
  const _RehearsalTab({required this.state});

  Map<String, dynamic>? _findRehearsal(WeddingPartyState state) {
    for (final item in state.timelineItems) {
      final title = (item['title'] as String? ?? '').toLowerCase();
      final type = (item['event_type'] as String? ?? '').toLowerCase();
      if (title.contains('rehearsal') || type.contains('rehearsal')) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rehearsal = _findRehearsal(state);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (rehearsal != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.udoGreen, AppTheme.udoGreen.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Rehearsal', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(_formatDate(rehearsal['event_date'] as String?), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('${_formatTime(rehearsal['start_time'] as String?)}${(rehearsal['location'] as String?)?.isNotEmpty == true ? ' · ${rehearsal['location']}' : ''}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('No rehearsal scheduled yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              const Text('Add a timeline event titled "Rehearsal" from Plan → Your Vision to see it here.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
              const SizedBox(height: 10),
              TextButton(onPressed: () => context.push('/your-vision'), child: const Text('Go to Your Vision')),
            ]),
          ),
        const SizedBox(height: 12),
        const Text('Attendance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        if (state.members.isEmpty)
          _emptyBox('No wedding party members yet.', icon: Icons.people_outline)
        else for (final m in state.members) GestureDetector(
          onTap: () => _cycleStatus(ref, m),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
            child: Row(children: [
              _Avatar(name: _fullName(m)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_fullName(m), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text((m['wedding_party_role'] as String?) ?? 'Wedding party', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
              ])),
              _RehearsalBadge(m['rehearsal_status'] as String?),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _cycleStatus(WidgetRef ref, Map<String, dynamic> m) async {
    const order = ['pending', 'confirmed', 'declined'];
    final current = m['rehearsal_status'] as String? ?? 'pending';
    final next = order[(order.indexOf(current) + 1) % order.length];
    await ref.read(weddingPartyProvider.notifier).updateMember(m['id'] as int, {'rehearsal_status': next});
  }
}

class _RehearsalBadge extends StatelessWidget {
  final String? status;
  const _RehearsalBadge(this.status);
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'confirmed' => ('Confirmed', const Color(0xFF22C55E)),
      'declined' => ('Declined', AppTheme.udoCrimson),
      _ => ('Pending', Colors.orange),
    };
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)));
  }
}

// ── EMERGENCY TAB ──────────────────────────────────────────────────────────────

class _EmergencyTab extends ConsumerWidget {
  final WeddingPartyState state;
  const _EmergencyTab({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.udoCrimson.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoCrimson.withValues(alpha: 0.3))),
          child: Row(children: [
            const Icon(Icons.warning_amber_outlined, color: AppTheme.udoCrimson, size: 20),
            const SizedBox(width: 10),
            const Expanded(child: Text('Emergency broadcast emails everyone in your wedding party immediately.', style: TextStyle(fontSize: 13, color: AppTheme.udoCrimson, height: 1.5))),
          ]),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _showEmergencyBroadcast(context, ref),
          icon: const Icon(Icons.broadcast_on_personal_outlined),
          label: const Text('Send emergency broadcast'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoCrimson, foregroundColor: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text('Wedding party contacts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        if (state.members.isEmpty)
          _emptyBox('No wedding party members yet.', icon: Icons.people_outline)
        else for (final m in state.members) Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            _Avatar(name: _fullName(m)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_fullName(m), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text((m['wedding_party_role'] as String?) ?? 'Wedding party', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
            ])),
            Row(children: [
              GestureDetector(onTap: () => _launchTel(context, m['phone'] as String?), child: Icon(Icons.phone_outlined, color: (m['phone'] as String?)?.isNotEmpty == true ? AppTheme.udoGreen : AppTheme.udoBorder, size: 20)),
              const SizedBox(width: 14),
              GestureDetector(onTap: () => _launchSms(context, m['phone'] as String?), child: Icon(Icons.message_outlined, color: (m['phone'] as String?)?.isNotEmpty == true ? AppTheme.udoGreen : AppTheme.udoBorder, size: 20)),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          const Expanded(child: Text('Additional emergency contacts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          TextButton.icon(onPressed: () => _showAddContact(context, ref), icon: const Icon(Icons.add, size: 16), label: const Text('Add', style: TextStyle(fontSize: 13))),
        ]),
        const SizedBox(height: 8),
        if (state.emergencyError != null)
          _errorBox("Couldn't load emergency contacts.", state.emergencyError!)
        else if (state.emergencyContacts.isEmpty)
          _emptyBox('No additional contacts yet — add parents, coordinator, or venue.', icon: Icons.contact_phone_outlined)
        else for (final c in state.emergencyContacts) Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            _Avatar(name: c['name'] as String? ?? '?'),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c['name'] as String? ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text('${c['relationship'] ?? 'Contact'} · ${c['phone'] ?? ''}', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
            ])),
            GestureDetector(onTap: () => _launchTel(context, c['phone'] as String?), child: const Icon(Icons.phone_outlined, color: AppTheme.udoGreen, size: 20)),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => ref.read(weddingPartyProvider.notifier).removeEmergencyContact(c['id'] as int),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            ),
          ]),
        ),
      ],
    );
  }

  void _showEmergencyBroadcast(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EmergencyBroadcastModal(memberCount: state.members.length),
    );
  }

  void _showAddContact(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _AddEmergencyContactModal(),
    );
  }
}

class _EmergencyBroadcastModal extends ConsumerStatefulWidget {
  final int memberCount;
  const _EmergencyBroadcastModal({required this.memberCount});
  @override
  ConsumerState<_EmergencyBroadcastModal> createState() => _EmergencyBroadcastModalState();
}

class _EmergencyBroadcastModalState extends ConsumerState<_EmergencyBroadcastModal> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    final message = _ctrl.text.trim();
    if (message.isEmpty) return;
    setState(() => _sending = true);
    final result = await ref.read(weddingPartyProvider.notifier).broadcastEmergency(message);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.ok ? 'Broadcast sent to ${result.recipients} wedding party member${result.recipients == 1 ? '' : 's'}.' : "Couldn't send the broadcast. Try again."),
    ));
  }

  @override
  Widget build(BuildContext context) {
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
            Text('This will immediately email all ${widget.memberCount} wedding party member${widget.memberCount == 1 ? '' : 's'}.', style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            const SizedBox(height: 16),
            TextField(controller: _ctrl, maxLines: 4, decoration: InputDecoration(hintText: 'Type your urgent message...', filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(14))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sending ? null : _send,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoCrimson, foregroundColor: Colors.white),
              child: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Send to all party members now'),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}

class _AddEmergencyContactModal extends ConsumerStatefulWidget {
  const _AddEmergencyContactModal();
  @override
  ConsumerState<_AddEmergencyContactModal> createState() => _AddEmergencyContactModalState();
}

class _AddEmergencyContactModalState extends ConsumerState<_AddEmergencyContactModal> {
  final _name = TextEditingController();
  final _relationship = TextEditingController();
  final _phone = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final ok = await ref.read(weddingPartyProvider.notifier).addEmergencyContact(
      name: _name.text.trim(),
      relationship: _relationship.text.trim(),
      phone: _phone.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't save this contact. Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Add emergency contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
            ]),
            const SizedBox(height: 16),
            _FieldBox('Name', _name),
            const SizedBox(height: 12),
            _FieldBox('Relationship', _relationship, hint: 'e.g. Venue coordinator'),
            const SizedBox(height: 12),
            _FieldBox('Phone', _phone, type: TextInputType.phone),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
              child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Add contact'),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() { _name.dispose(); _relationship.dispose(); _phone.dispose(); super.dispose(); }
}

// ── FILES & SPEECHES TAB ───────────────────────────────────────────────────────

class _FilesSpeechesTab extends ConsumerStatefulWidget {
  final WeddingPartyState state;
  const _FilesSpeechesTab({required this.state});
  @override
  ConsumerState<_FilesSpeechesTab> createState() => _FilesSpeechesTabState();
}

class _FilesSpeechesTabState extends ConsumerState<_FilesSpeechesTab> {
  bool _uploadingSpeech = false;
  bool _uploadingFile = false;

  Future<void> _upload(String category) async {
    final result = await FilePicker.pickFiles(withData: true);
    final picked = result?.files.single;
    if (picked == null || picked.bytes == null) return;
    setState(() { if (category == 'speech') _uploadingSpeech = true; else _uploadingFile = true; });
    final ok = await ref.read(weddingPartyProvider.notifier).uploadFile(picked.bytes!, picked.name, category: category);
    if (!mounted) return;
    setState(() { if (category == 'speech') _uploadingSpeech = false; else _uploadingFile = false; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Uploaded.' : "Couldn't upload that file. Try again.")));
  }

  Future<void> _download(Map<String, dynamic> file) async {
    final url = file['url'] as String? ?? '';
    if (url.isEmpty) return;
    final absolute = url.startsWith('http') ? url : '${AppConstants.apiOrigin}$url';
    final ok = await launchUrl(Uri.parse(absolute), mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't open that file.")));
    }
  }

  IconData _iconFor(String? name) {
    final n = (name ?? '').toLowerCase();
    if (n.endsWith('.pdf')) return Icons.picture_as_pdf_outlined;
    if (n.endsWith('.jpg') || n.endsWith('.jpeg') || n.endsWith('.png')) return Icons.image_outlined;
    return Icons.description_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state.filesError != null) return _errorBox("Couldn't load files.", state.filesError!);

    final speeches = state.files.where((f) => f['category'] == 'speech').toList();
    final files = state.files.where((f) => f['category'] != 'speech').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Speeches', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        if (speeches.isEmpty)
          _emptyBox('No speeches uploaded yet.', icon: Icons.mic_outlined)
        else for (final f in speeches) _FileRow(file: f, icon: _iconFor(f['name'] as String?), onDownload: () => _download(f), onDelete: () => ref.read(weddingPartyProvider.notifier).deleteFile(f['id'] as int)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _uploadingSpeech ? null : () => _upload('speech'),
          icon: _uploadingSpeech ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload_outlined, size: 18),
          label: Text(_uploadingSpeech ? 'Uploading…' : 'Upload speech'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44), side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
        ),
        const SizedBox(height: 20),
        const Text('Shared files', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        if (files.isEmpty)
          _emptyBox('No shared files yet.', icon: Icons.folder_open_outlined)
        else for (final f in files) _FileRow(file: f, icon: _iconFor(f['name'] as String?), onDownload: () => _download(f), onDelete: () => ref.read(weddingPartyProvider.notifier).deleteFile(f['id'] as int)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _uploadingFile ? null : () => _upload('file'),
          icon: _uploadingFile ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload_outlined, size: 18),
          label: Text(_uploadingFile ? 'Uploading…' : 'Upload file'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
        ),
      ],
    );
  }
}

class _FileRow extends StatelessWidget {
  final Map<String, dynamic> file;
  final IconData icon;
  final VoidCallback onDownload;
  final VoidCallback onDelete;
  const _FileRow({required this.file, required this.icon, required this.onDownload, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.udoGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppTheme.udoGreen, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(file['name'] as String? ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(_formatFileSize(file['file_size_bytes'] as int?), style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
      ])),
      GestureDetector(onTap: onDownload, child: const Icon(Icons.download_outlined, color: AppTheme.udoGreen, size: 20)),
      const SizedBox(width: 12),
      GestureDetector(onTap: onDelete, child: const Icon(Icons.delete_outline, color: Colors.red, size: 20)),
    ]),
  );
}

// ── PERSON DETAIL SHEET ────────────────────────────────────────────────────────

class _PersonDetailSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> person;
  final List<Map<String, dynamic>> responsibilities;
  const _PersonDetailSheet({required this.person, required this.responsibilities});
  @override
  ConsumerState<_PersonDetailSheet> createState() => _PersonDetailSheetState();
}

class _PersonDetailSheetState extends ConsumerState<_PersonDetailSheet> {
  late final TextEditingController _roleCtrl;
  late String _attireStatus;
  late String _rehearsalStatus;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _roleCtrl = TextEditingController(text: widget.person['wedding_party_role'] as String? ?? '');
    _attireStatus = widget.person['attire_status'] as String? ?? 'not_started';
    _rehearsalStatus = widget.person['rehearsal_status'] as String? ?? 'pending';
  }

  @override
  void dispose() {
    _roleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await ref.read(weddingPartyProvider.notifier).updateMember(widget.person['id'] as int, {
      'wedding_party_role': _roleCtrl.text.trim(),
      'attire_status': _attireStatus,
      'rehearsal_status': _rehearsalStatus,
    });
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Saved.' : "Couldn't save. Try again.")));
  }

  Future<void> _remove() async {
    Navigator.pop(context);
    await ref.read(weddingPartyProvider.notifier).removeMember(widget.person['id'] as int);
  }

  @override
  Widget build(BuildContext context) {
    final person = widget.person;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, ctrl) => SafeArea(
        child: Column(children: [
          Container(margin: const EdgeInsets.only(top: 12, bottom: 8), width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.udoBorder, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(children: [
              _Avatar(name: _fullName(person), radius: 26),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_fullName(person), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                Text((person['wedding_party_role'] as String?)?.isNotEmpty == true ? person['wedding_party_role'] as String : 'Wedding party', style: const TextStyle(fontSize: 14, color: AppTheme.udoTextSecondary)),
              ])),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
          ),
          Expanded(child: SingleChildScrollView(controller: ctrl, padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SectionTitle('Role'),
            TextField(
              controller: _roleCtrl,
              decoration: InputDecoration(hintText: 'e.g. Best man', filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
            ),
            const SizedBox(height: 16),
            _SectionTitle('Attire status'),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final s in const ['not_started', 'ordered', 'fitted', 'ready'])
                ChoiceChip(
                  label: Text(s.replaceAll('_', ' '), style: const TextStyle(fontSize: 12)),
                  selected: _attireStatus == s,
                  onSelected: (_) => setState(() => _attireStatus = s),
                  selectedColor: AppTheme.udoGreen,
                  labelStyle: TextStyle(color: _attireStatus == s ? Colors.white : AppTheme.udoTextPrimary),
                  side: BorderSide(color: _attireStatus == s ? AppTheme.udoGreen : AppTheme.udoBorder),
                ),
            ]),
            const SizedBox(height: 16),
            _SectionTitle('Rehearsal status'),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final s in const ['pending', 'confirmed', 'declined'])
                ChoiceChip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  selected: _rehearsalStatus == s,
                  onSelected: (_) => setState(() => _rehearsalStatus = s),
                  selectedColor: AppTheme.udoGreen,
                  labelStyle: TextStyle(color: _rehearsalStatus == s ? Colors.white : AppTheme.udoTextPrimary),
                  side: BorderSide(color: _rehearsalStatus == s ? AppTheme.udoGreen : AppTheme.udoBorder),
                ),
            ]),
            const SizedBox(height: 16),
            _SectionTitle('Responsibilities'),
            if (widget.responsibilities.isEmpty)
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)), child: const Text('No responsibilities assigned yet.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)))
            else Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final r in widget.responsibilities) Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    Expanded(child: Text(r['title'] as String? ?? '', style: const TextStyle(fontSize: 13))),
                    _StatusBadge(r['status'] as String? ?? 'pending'),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            _SectionTitle('Contact'),
            _InfoRow('Phone', (person['phone'] as String?)?.isNotEmpty == true ? person['phone'] as String : 'Not on file'),
            _InfoRow('Email', (person['email'] as String?)?.isNotEmpty == true ? person['email'] as String : 'Not on file'),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () => _launchTel(context, person['phone'] as String?),
                icon: const Icon(Icons.call_outlined, size: 16),
                label: const Text('Call'),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_outlined, size: 16),
                label: Text(_saving ? 'Saving…' : 'Save'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
              )),
            ]),
            const SizedBox(height: 10),
            TextButton.icon(onPressed: _remove, icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red), label: const Text('Remove from wedding party', style: TextStyle(color: Colors.red))),
          ]))),
        ]),
      ),
    );
  }
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
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );
}

// ── ADD PERSON MODAL ───────────────────────────────────────────────────────────

class _AddPersonModal extends StatefulWidget {
  final Future<void> Function({required String firstName, required String lastName, required String role, String? email, String? phone}) onAdd;
  const _AddPersonModal({required this.onAdd});
  @override
  State<_AddPersonModal> createState() => _AddPersonModalState();
}

class _AddPersonModalState extends State<_AddPersonModal> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String _role = 'Bridesmaid';
  bool _saving = false;

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
            onPressed: _saving ? null : () async {
              final fullName = _name.text.trim();
              if (fullName.isEmpty) return;
              setState(() => _saving = true);
              final parts = fullName.split(' ');
              final firstName = parts.isNotEmpty ? parts.first : fullName;
              final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
              await widget.onAdd(
                firstName: firstName,
                lastName: lastName,
                role: _role,
                email: _email.text.trim(),
                phone: _phone.text.trim(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
            child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Add to wedding party'),
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
  final String? hint;
  const _FieldBox(this.label, this.ctrl, {this.type, this.hint});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    const SizedBox(height: 6),
    TextField(controller: ctrl, keyboardType: type, decoration: InputDecoration(hintText: hint ?? label, hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14), filled: true, fillColor: const Color(0xFFF3EFEA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.udoGreen, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
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
