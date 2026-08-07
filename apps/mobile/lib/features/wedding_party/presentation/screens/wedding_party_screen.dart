import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/place_search_field.dart';
import '../../../../shared/widgets/udo_design_system.dart';
import '../../../../shared/widgets/wedding_party_overview.dart';
import '../../../guests/presentation/providers/guests_provider.dart';
import '../../../guests/presentation/providers/logistics_provider.dart';
import '../../../guests/presentation/screens/guests_screen.dart' show AddHotelModal, AddTransportModal;
import '../../../home/presentation/providers/home_provider.dart';
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
    _tabs = TabController(length: 8, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });
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
                      _OverviewTab(state: state, onPersonTap: (id) => _showPersonDetail(context, state, id), onTabJump: _tabs.animateTo),
                      _PeopleTab(state: state, onPersonTap: (id) => _showPersonDetail(context, state, id)),
                      _ResponsibilitiesTab(state: state),
                      _BuzzesTab(state: state),
                      _WeddingTimelineTab(state: state),
                      _TravelTab(state: state),
                      _RehearsalTab(state: state),
                      _FilesSpeechesTab(state: state),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateMenu(context, state),
        backgroundColor: AppTheme.udoGreen,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  // One consistent "+Create" menu available from every tab, instead of a
  // single-action FAB whose meaning silently changed per tab (that was the
  // Phase-0 bug: it always opened "Add party member" regardless of context).
  // Accommodation/transport creation moved to inline "+Add" buttons on the
  // Travel tab itself so removing the per-tab FAB doesn't remove that
  // capability — this menu covers the 5 mockup-specified shortcuts only.
  void _showCreateMenu(BuildContext context, WeddingPartyState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        child: Wrap(children: [
          const Padding(padding: EdgeInsets.fromLTRB(20, 16, 20, 4), child: Text('Create', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
          ListTile(
            leading: const Icon(Icons.person_add_outlined, color: AppTheme.udoGreen),
            title: const Text('Member'),
            onTap: () { Navigator.pop(sheetContext); _showAddPersonModal(context); },
          ),
          ListTile(
            leading: const Icon(Icons.checklist_outlined, color: AppTheme.udoGreen),
            title: const Text('Responsibility'),
            onTap: () {
              Navigator.pop(sheetContext);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                builder: (_) => _ResponsibilityEditorSheet(task: null, members: state.members),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.send_outlined, color: AppTheme.udoGreen),
            title: const Text('Message'),
            onTap: () {
              Navigator.pop(sheetContext);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                builder: (_) => BuzzComposerSheet(
                  recipientCount: state.members.length,
                  onSend: (body, channel, urgent) => ref.read(weddingPartyProvider.notifier).sendBuzz(body: body, channel: channel, urgent: urgent),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_outlined, color: AppTheme.udoGreen),
            title: const Text('Event'),
            subtitle: const Text('Opens the day timeline', style: TextStyle(fontSize: 12)),
            onTap: () { Navigator.pop(sheetContext); context.push('/plan?section=timeline'); },
          ),
          ListTile(
            leading: const Icon(Icons.folder_open_outlined, color: AppTheme.udoGreen),
            title: const Text('File'),
            onTap: () async {
              Navigator.pop(sheetContext);
              final result = await FilePicker.pickFiles(withData: true);
              final picked = result?.files.single;
              if (picked == null || picked.bytes == null || !context.mounted) return;
              final ok = await ref.read(weddingPartyProvider.notifier).uploadFile(picked.bytes!, picked.name, category: 'file');
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Uploaded.' : "Couldn't upload that file. Try again.")));
            },
          ),
        ]),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        child: Wrap(children: [
          const Padding(padding: EdgeInsets.fromLTRB(20, 16, 20, 4), child: Text('Add to wedding party', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
          ListTile(
            leading: const Icon(Icons.person_search_outlined, color: AppTheme.udoGreen),
            title: const Text('Select an existing guest'),
            subtitle: const Text('Reuses their name, email and phone — no duplicate record.', style: TextStyle(fontSize: 12)),
            onTap: () {
              Navigator.pop(sheetContext);
              _showLinkExistingGuestSheet(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add_outlined, color: AppTheme.udoGreen),
            title: const Text('Add a new person'),
            onTap: () {
              Navigator.pop(sheetContext);
              _showAddNewPersonModal(context);
            },
          ),
        ]),
      ),
    );
  }

  void _showAddNewPersonModal(BuildContext context) {
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

  void _showLinkExistingGuestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _LinkExistingGuestSheet(
        onLink: (guestId, role) async {
          final ok = await ref.read(weddingPartyProvider.notifier).linkExistingGuest(guestId, role: role);
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
      color: UdoDesign.rose,
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
              Tab(text: 'Rehearsal'), Tab(text: 'Files & Speeches'),
            ],
            labelColor: UdoDesign.rose,
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
  final void Function(int) onTabJump;
  const _OverviewTab({required this.state, required this.onPersonTap, required this.onTabJump});

  String _initials(Map<String, dynamic> m) {
    final first = (m['first_name'] as String? ?? '').trim();
    final last = (m['last_name'] as String? ?? '').trim();
    if (first.isEmpty && last.isEmpty) return '?';
    return '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = state.members;
    final travelConfirmed = members.where((m) => m['hotel_assignment_id'] != null || m['transport_assignment_id'] != null).length;
    final attireReady = members.where((m) => m['attire_status'] == 'ready').length;
    final rehearsalConfirmed = members.where((m) => m['rehearsal_status'] == 'confirmed').length;
    final readyCount = members.where((m) {
      final attire = m['attire_status'] == 'ready';
      final rehearsal = m['rehearsal_status'] == 'confirmed';
      final travel = m['travel_required'] != true || m['hotel_assignment_id'] != null || m['transport_assignment_id'] != null;
      return attire && rehearsal && travel;
    }).length;
    final openResponsibilities = state.responsibilities.where((r) => r['status'] != 'done').length;
    DateTime? dueOf(Map<String, dynamic> r) {
      final raw = r['due_date'] as String?;
      return raw == null ? null : DateTime.tryParse(raw);
    }
    final topPriorities = state.responsibilities.where((r) => r['status'] != 'done').toList()
      ..sort((a, b) {
        final da = dueOf(a);
        final db = dueOf(b);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });
    final priorityPreview = topPriorities.take(3).toList();

    if (state.membersError != null) {
      return _errorBox("Couldn't load your wedding party.", state.membersError!);
    }

    return WeddingPartyOverview(
      isLoading: false,
      error: null,
      members: members,
      responsibilities: state.responsibilities,
      buzzes: state.buzzes,
      timelineItems: state.timelineItems,
      accommodations: state.accommodations,
      transportGroups: state.transportGroups,
      files: state.files,
      attireReady: attireReady,
      rehearsalConfirmed: rehearsalConfirmed,
      travelConfirmed: travelConfirmed,
      readyCount: readyCount,
      openResponsibilities: openResponsibilities,
      priorityTasks: priorityPreview,
      initialsFor: _initials,
      onPersonTap: onPersonTap,
      onOpenModule: (moduleKey) {
        switch (moduleKey) {
          case 'responsibilities':
            onTabJump(2);
          case 'rehearsal':
            onTabJump(6);
          case 'travel':
            onTabJump(5);
          case 'files':
            onTabJump(7);
          case 'people':
          default:
            onTabJump(1);
        }
      },
      trailingSection: UdoCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Send a buzz', style: UdoDesign.sans(size: 14, weight: FontWeight.w700)),
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
                side: BorderSide(color: UdoDesign.rose.withValues(alpha: 0.3)),
                backgroundColor: UdoDesign.rose.withValues(alpha: 0.06),
              ),
          ]),
        ]),
      ),
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

// ── PEOPLE TAB ─────────────────────────────────────────────────────────────────

class _PeopleTab extends ConsumerWidget {
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

  void _showAddContact(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _AddEmergencyContactModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.membersError != null) return _errorBox("Couldn't load your wedding party.", state.membersError!);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (state.members.isEmpty)
          _emptyBox('No one added to your wedding party yet. Tap + to add someone.', icon: Icons.people_outline)
        else for (final m in state.members) GestureDetector(
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
              GestureDetector(onTap: () => _launchTel(context, m['phone'] as String?), child: Icon(Icons.phone_outlined, color: (m['phone'] as String?)?.isNotEmpty == true ? AppTheme.udoGreen : AppTheme.udoBorder, size: 20)),
              const SizedBox(width: 12),
              GestureDetector(onTap: () => _launchSms(context, m['phone'] as String?), child: Icon(Icons.message_outlined, color: (m['phone'] as String?)?.isNotEmpty == true ? AppTheme.udoGreen : AppTheme.udoBorder, size: 20)),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppTheme.udoTextSecondary),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          const Expanded(child: Text('Additional emergency contacts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          TextButton.icon(onPressed: () => _showAddContact(context), icon: const Icon(Icons.add, size: 16), label: const Text('Add', style: TextStyle(fontSize: 13))),
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

class _ResponsibilitiesTab extends ConsumerStatefulWidget {
  final WeddingPartyState state;
  const _ResponsibilitiesTab({required this.state});
  @override
  ConsumerState<_ResponsibilitiesTab> createState() => _ResponsibilitiesTabState();
}

const _kResponsibilityFilters = <String, String>{
  'open': 'Open',
  'in_progress': 'In progress',
  'overdue': 'Overdue',
  'completed': 'Completed',
};

class _ResponsibilitiesTabState extends ConsumerState<_ResponsibilitiesTab> {
  final Set<int> _selected = {};
  String? _statusFilter;

  String _guestName(WeddingPartyState state, dynamic guestId) {
    if (guestId == null) return 'Unassigned';
    final g = state.members.firstWhere((m) => m['id'].toString() == guestId.toString(), orElse: () => {});
    return g.isEmpty ? 'Unassigned' : _fullName(g);
  }

  DateTime? _dueOf(Map<String, dynamic> r) {
    final raw = r['due_date'] as String?;
    return raw == null ? null : DateTime.tryParse(raw);
  }

  String _bucketOf(Map<String, dynamic> r, DateTime today) {
    if (r['status'] == 'done') return 'completed';
    final due = _dueOf(r);
    if (due != null && DateTime(due.year, due.month, due.day).isBefore(today)) return 'overdue';
    return r['status'] == 'in_progress' ? 'in_progress' : 'open';
  }

  Future<void> _exportTasks(BuildContext context, WeddingPartyState state) async {
    final buffer = StringBuffer('Title,Assigned To,Status,Priority,Due Date\n');
    for (final r in state.responsibilities) {
      final title = (r['title'] as String? ?? '').replaceAll(',', ';');
      final assignee = _guestName(state, r['guest_id']).replaceAll(',', ';');
      final status = r['status'] as String? ?? 'pending';
      final priority = r['priority'] as String? ?? 'medium';
      final due = r['due_date'] as String? ?? '';
      buffer.writeln('$title,$assignee,$status,$priority,$due');
    }
    await Share.share(buffer.toString(), subject: 'Wedding party responsibilities');
  }

  void _openGroupTaskSheet(BuildContext context, WeddingPartyState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _GroupTaskSheet(members: state.members),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state.responsibilitiesError != null) {
      return _errorBox("Couldn't load responsibilities.", state.responsibilitiesError!);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final buckets = <String, List<Map<String, dynamic>>>{'open': [], 'in_progress': [], 'overdue': [], 'completed': []};
    for (final r in state.responsibilities) {
      buckets[_bucketOf(r, today)]!.add(r);
    }
    final filtered = _statusFilter == null ? state.responsibilities : buckets[_statusFilter]!;
    final pending = filtered.where((r) => r['status'] != 'done').toList();
    final completed = filtered.where((r) => r['status'] == 'done').toList();

    DateTime? dueOf(Map<String, dynamic> r) => _dueOf(r);

    final groups = <String, List<Map<String, dynamic>>>{'Overdue': [], 'Today': [], 'Upcoming': [], 'No due date': []};
    for (final r in pending) {
      final due = dueOf(r);
      if (due == null) {
        groups['No due date']!.add(r);
      } else {
        final dueDay = DateTime(due.year, due.month, due.day);
        if (dueDay.isBefore(today)) {
          groups['Overdue']!.add(r);
        } else if (dueDay.isAtSameMomentAs(today)) {
          groups['Today']!.add(r);
        } else {
          groups['Upcoming']!.add(r);
        }
      }
    }

    return Column(children: [
      if (_selected.isNotEmpty) _BulkActionBar(
        count: _selected.length,
        onMarkComplete: () async {
          final ids = _selected.toList();
          setState(() => _selected.clear());
          await ref.read(weddingPartyProvider.notifier).bulkUpdateResponsibilities(ids, {'status': 'done'});
        },
        onSendReminder: () => _sendReminderToAssignees(context, state),
        onClear: () => setState(() => _selected.clear()),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            if (state.responsibilities.isNotEmpty) ...[
              _ResponsibilityDonut(buckets: buckets),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                FilterChip(
                  label: Text('All (${state.responsibilities.length})', style: const TextStyle(fontSize: 12)),
                  selected: _statusFilter == null,
                  onSelected: (_) => setState(() => _statusFilter = null),
                  selectedColor: AppTheme.udoGreen.withValues(alpha: 0.15),
                ),
                for (final entry in _kResponsibilityFilters.entries)
                  FilterChip(
                    label: Text('${entry.value} (${buckets[entry.key]!.length})', style: const TextStyle(fontSize: 12)),
                    selected: _statusFilter == entry.key,
                    onSelected: (sel) => setState(() => _statusFilter = sel ? entry.key : null),
                    selectedColor: AppTheme.udoGreen.withValues(alpha: 0.15),
                  ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _openGroupTaskSheet(context, state),
                  icon: const Icon(Icons.group_add_outlined, size: 16),
                  label: const Text('Create group task', style: TextStyle(fontSize: 12)),
                )),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _exportTasks(context, state),
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: const Text('Export tasks', style: TextStyle(fontSize: 12)),
                )),
              ]),
              const SizedBox(height: 16),
            ],
            Row(children: [
              const Expanded(child: Text('Day-of responsibilities', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
              TextButton.icon(
                onPressed: () => _openEditor(context, null),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add', style: TextStyle(fontSize: 13)),
              ),
            ]),
            const SizedBox(height: 8),
            if (state.responsibilities.isEmpty)
              _emptyBox('No responsibilities yet. Tap Add to assign one.', icon: Icons.checklist_outlined)
            else ...[
              for (final section in ['Overdue', 'Today', 'Upcoming', 'No due date'])
                if (groups[section]!.isNotEmpty) ...[
                  Padding(padding: const EdgeInsets.only(bottom: 8), child: _SectionHeader(section)),
                  for (final task in groups[section]!) _ResponsibilityCard(
                    task: task,
                    label: _guestName(state, task['guest_id']),
                    selected: _selected.contains(task['id'] as int),
                    onTap: () => _selected.isEmpty ? _openEditor(context, task) : _toggle(task['id'] as int),
                    onLongPress: () => _toggle(task['id'] as int),
                  ),
                  const SizedBox(height: 12),
                ],
              if (completed.isNotEmpty) ...[
                const Padding(padding: EdgeInsets.only(bottom: 8), child: _SectionHeader('Completed')),
                for (final task in completed) _ResponsibilityCard(
                  task: task,
                  label: _guestName(state, task['guest_id']),
                  selected: _selected.contains(task['id'] as int),
                  onTap: () => _selected.isEmpty ? _openEditor(context, task) : _toggle(task['id'] as int),
                  onLongPress: () => _toggle(task['id'] as int),
                ),
              ],
            ],
          ],
        ),
      ),
    ]);
  }

  void _toggle(int id) => setState(() => _selected.contains(id) ? _selected.remove(id) : _selected.add(id));

  Future<void> _sendReminderToAssignees(BuildContext context, WeddingPartyState state) async {
    final selectedTasks = state.responsibilities.where((r) => _selected.contains(r['id'] as int)).toList();
    final titles = selectedTasks.map((t) => t['title'] as String? ?? '').where((t) => t.isNotEmpty).join(', ');
    setState(() => _selected.clear());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      // Buzzes always broadcast to the whole wedding party (the backend has
      // no per-recipient targeting yet) — the message body names the
      // specific tasks, but this isn't sent only to their assignees.
      builder: (_) => BuzzComposerSheet(
        initialBody: 'A quick reminder about: $titles.',
        recipientCount: state.members.length,
        onSend: (body, channel, urgent) => ref.read(weddingPartyProvider.notifier).sendBuzz(body: body, channel: channel, urgent: urgent),
      ),
    );
  }

  void _openEditor(BuildContext context, Map<String, dynamic>? task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ResponsibilityEditorSheet(task: task, members: widget.state.members),
    );
  }
}

class _BulkActionBar extends StatelessWidget {
  final int count;
  final VoidCallback onMarkComplete;
  final VoidCallback onSendReminder;
  final VoidCallback onClear;
  const _BulkActionBar({required this.count, required this.onMarkComplete, required this.onSendReminder, required this.onClear});

  @override
  Widget build(BuildContext context) => Container(
    color: AppTheme.udoGreen.withValues(alpha: 0.08),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      Text('$count selected', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.udoGreen)),
      const Spacer(),
      TextButton.icon(onPressed: onSendReminder, icon: const Icon(Icons.send_outlined, size: 16), label: const Text('Remind', style: TextStyle(fontSize: 12))),
      TextButton.icon(onPressed: onMarkComplete, icon: const Icon(Icons.check, size: 16), label: const Text('Complete', style: TextStyle(fontSize: 12))),
      IconButton(onPressed: onClear, icon: const Icon(Icons.close, size: 18), padding: EdgeInsets.zero),
    ]),
  );
}

const _kResponsibilityDonutColors = <String, Color>{
  'open': Colors.pink,
  'in_progress': Colors.orange,
  'overdue': AppTheme.udoCrimson,
  'completed': Color(0xFF22C55E),
};

class _ResponsibilityDonut extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> buckets;
  const _ResponsibilityDonut({required this.buckets});

  @override
  Widget build(BuildContext context) {
    final counts = buckets.map((k, v) => MapEntry(k, v.length));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
      child: Row(children: [
        SizedBox(width: 72, height: 72, child: CustomPaint(painter: _ResponsibilityDonutPainter(counts: counts))),
        const SizedBox(width: 16),
        Expanded(child: Wrap(spacing: 12, runSpacing: 6, children: [
          for (final key in const ['open', 'in_progress', 'overdue', 'completed'])
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: _kResponsibilityDonutColors[key], shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('${_kResponsibilityFilters[key]} (${counts[key]})', style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
            ]),
        ])),
      ]),
    );
  }
}

class _ResponsibilityDonutPainter extends CustomPainter {
  final Map<String, int> counts;
  const _ResponsibilityDonutPainter({required this.counts});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth);
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      final paint = Paint()
        ..color = AppTheme.udoBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, 0, 2 * pi, false, paint);
      return;
    }
    var startAngle = -pi / 2;
    for (final key in const ['open', 'in_progress', 'overdue', 'completed']) {
      final count = counts[key] ?? 0;
      if (count == 0) continue;
      final sweep = (count / total) * 2 * pi;
      final paint = Paint()
        ..color = _kResponsibilityDonutColors[key]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _ResponsibilityDonutPainter oldDelegate) => oldDelegate.counts != counts;
}

class _GroupTaskSheet extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> members;
  const _GroupTaskSheet({required this.members});
  @override
  ConsumerState<_GroupTaskSheet> createState() => _GroupTaskSheetState();
}

class _GroupTaskSheetState extends ConsumerState<_GroupTaskSheet> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _customTitle = TextEditingController();
  String? _category;
  String? _titleSelection;
  String? _role;
  DateTime? _dueDate;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _customTitle.dispose();
    super.dispose();
  }

  void _syncTitle() {
    if (_titleSelection == _customResponsibilityTitleSentinel) {
      _title.text = _customTitle.text.trim();
    } else {
      _title.text = _titleSelection ?? '';
    }
  }

  List<String> get _roles => widget.members
      .map((m) => m['wedding_party_role'] as String?)
      .whereType<String>()
      .where((r) => r.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  Future<void> _save() async {
    _syncTitle();
    if (_title.text.trim().isEmpty || _role == null) {
      setState(() => _error = 'Give this task a title and pick a group.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    final matching = widget.members.where((m) => m['wedding_party_role'] == _role).toList();
    final notifier = ref.read(weddingPartyProvider.notifier);
    var allOk = true;
    for (final m in matching) {
      final ok = await notifier.createResponsibility(
        title: _title.text.trim(),
        description: _description.text.trim(),
        guestId: m['id'] as int,
        dueDate: _dueDate,
      );
      if (!ok) allOk = false;
    }
    if (!mounted) return;
    if (allOk) {
      Navigator.pop(context);
    } else {
      setState(() { _saving = false; _error = "Couldn't create tasks for everyone. Try again."; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roles = _roles;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Create group task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Creates the same task for everyone sharing a role — e.g. all Groomsmen.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          const SizedBox(height: 16),
          _responsibilityTitlePicker(
            category: _category,
            titleSelection: _titleSelection,
            customTitleController: _customTitle,
            onCategoryChanged: (v) => setState(() {
              _category = v;
              _titleSelection = null;
            }),
            onTitleChanged: (v) => setState(() {
              _titleSelection = v;
              _syncTitle();
            }),
          ),
          const SizedBox(height: 14),
          _SheetField('Description', _description, maxLines: 2, hint: 'Optional'),
          const SizedBox(height: 14),
          const Text('Group', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          if (roles.isEmpty)
            const Text('No shared roles yet — add roles to members first.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary))
          else
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: _sheetDecoration(),
              items: roles.map((r) => DropdownMenuItem(value: r, child: Text('$r (${widget.members.where((m) => m['wedding_party_role'] == r).length})'))).toList(),
              onChanged: (v) => setState(() => _role = v),
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
              decoration: BoxDecoration(color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Expanded(child: Text(_dueDate != null ? DateFormat('EEE, MMM d, yyyy').format(_dueDate!) : 'No due date', style: const TextStyle(fontSize: 14))),
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.udoTextSecondary),
              ]),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(fontSize: 12, color: AppTheme.udoCrimson)),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: (_saving || roles.isEmpty) ? null : _save,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Create for group'),
          ),
        ])),
      ),
      ),
    );
  }
}

class _ResponsibilityCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const _ResponsibilityCard({required this.task, required this.label, required this.selected, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    onLongPress: onLongPress,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? AppTheme.udoGreen.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? AppTheme.udoGreen : (task['status'] == 'in_progress' ? AppTheme.udoGreen.withValues(alpha: 0.4) : AppTheme.udoBorder)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (selected) const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.check_circle, color: AppTheme.udoGreen, size: 18)),
          _PriorityDot(task['priority'] as String? ?? 'medium'),
          const SizedBox(width: 8),
          Expanded(child: Text(task['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          _StatusBadge(task['status'] as String? ?? 'pending'),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.person_outline, size: 14, color: AppTheme.udoTextSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
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
  );
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: AppTheme.udoTextSecondary));
}

class _PriorityDot extends StatelessWidget {
  final String priority;
  const _PriorityDot(this.priority);

  @override
  Widget build(BuildContext context) {
    final color = priority == 'high' ? AppTheme.udoCrimson : priority == 'low' ? const Color(0xFF22C55E) : Colors.orange;
    return Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
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

const _customResponsibilityTitleSentinel = '__custom_title__';

const _responsibilityTitleOptionsByCategory = {
  'General': [
    'General Task',
    'Reminder',
    'Follow-up',
    'Review',
    'Approval Needed',
    'Decision Required',
    'Deadline',
    'Milestone',
    'Personal Note',
  ],
  'Attire': [
    'Order Dress',
    'Dress Fitting',
    'Suit Fitting',
    'Final Alterations',
    'Shoes',
    'Accessories',
    'Jewelry Pickup',
    'Veil Pickup',
    'Tux Pickup',
    'Steam Attire',
  ],
  'Beauty & Grooming': [
    'Hair Trial',
    'Makeup Trial',
    'Hair Appointment',
    'Makeup Appointment',
    'Facial',
    'Nails',
    'Waxing',
    'Barber Appointment',
    'Spray Tan',
    'Skincare',
  ],
  'Ceremony': [
    'Ceremony Rehearsal',
    'Write Vows',
    'Print Vows',
    'Marriage Licence',
    'Officiant Meeting',
    'Ceremony Music',
    'Ceremony Readings',
    'Ring Check',
    'Unity Ceremony',
    'Seating Plan',
  ],
  'Reception': [
    'Reception Timeline',
    'Speech Preparation',
    'Confirm DJ Playlist',
    'Confirm Band Setlist',
    'First Dance Practice',
    'Parent Dance',
    'Toasts',
    'Cake Cutting',
    'Grand Entrance',
    'Reception Setup',
  ],
  'Vendors': [
    'Confirm Vendor',
    'Vendor Payment',
    'Vendor Meeting',
    'Vendor Follow-up',
    'Final Confirmation',
    'Contract Review',
    'Schedule Call',
    'Send Inspiration',
    'Collect Invoice',
    'Leave Review',
  ],
  'Photography & Video': [
    'Engagement Shoot',
    'Photo Timeline',
    'Family Photo List',
    'Bridal Party Photos',
    'Detail Shots',
    'First Look',
    'Sunset Photos',
    'Drone Photos',
    'Album Selection',
    'Video Review',
  ],
  'Florals & Decor': [
    'Floral Consultation',
    'Decor Selection',
    'Centrepieces',
    'Bouquet Pickup',
    'Ceremony Decor',
    'Reception Decor',
    'Signage',
    'Candles',
    'Table Styling',
    'Final Walkthrough',
  ],
  'Guests': [
    'Send Invitations',
    'RSVP Reminder',
    'Seat Guests',
    'Confirm Attendance',
    'Meal Selection',
    'Dietary Requirements',
    'Welcome Bags',
    'Guest Transport',
    'Hotel Assignment',
    'Thank You Notes',
  ],
  'Wedding Party': [
    'Bridesmaid Task',
    'Groomsman Task',
    'Maid of Honour Task',
    'Best Man Task',
    'Flower Girl Task',
    'Ring Bearer Task',
    'Dress Collection',
    'Suit Collection',
    'Gift Purchase',
    'Rehearsal Reminder',
  ],
  'Travel': [
    'Book Flights',
    'Hotel Booking',
    'Airport Transfer',
    'Shuttle Schedule',
    'Passport Check',
    'Visa Check',
    'Packing',
    'Travel Insurance',
    'Check-in Online',
    'Itinerary Review',
  ],
  'Honeymoon': [
    'Book Resort',
    'Book Excursion',
    'Restaurant Reservation',
    'Spa Booking',
    'Currency Exchange',
    'Packing List',
    'Travel Documents',
    'Insurance Check',
    'Airport Transfer',
    'Honeymoon Budget',
  ],
  'Budget & Payments': [
    'Pay Deposit',
    'Final Payment',
    'Review Budget',
    'Collect Receipt',
    'Approve Invoice',
    'Payment Reminder',
    'Refund Follow-up',
    'Expense Review',
    'Add Purchase',
    'Update Budget',
  ],
  'Legal': [
    'Marriage Licence',
    'Name Change',
    'Witness Confirmation',
    'Sign Documents',
    'Insurance',
    'Passport Update',
    'Banking Update',
    'Certificate Collection',
  ],
  'Shopping': [
    'Buy Decorations',
    'Buy Gifts',
    'Buy Favours',
    'Buy Stationery',
    'Buy Cake Topper',
    'Buy Guest Book',
    'Buy Accessories',
    'Buy Shoes',
    'Buy Rings',
    'Buy Emergency Kit',
  ],
  'Day Of': [
    'Morning Checklist',
    'Hair & Makeup',
    'Photographer Arrival',
    'Vendor Check-in',
    'Ceremony Setup',
    'Guest Arrival',
    'Transport Check',
    'Reception Setup',
    'Emergency Task',
    'End-of-Night Wrap-up',
  ],
};

const _responsibilityCategoryOptions = [
  'General',
  'Attire',
  'Beauty & Grooming',
  'Ceremony',
  'Reception',
  'Vendors',
  'Photography & Video',
  'Florals & Decor',
  'Guests',
  'Wedding Party',
  'Travel',
  'Honeymoon',
  'Budget & Payments',
  'Legal',
  'Shopping',
  'Day Of',
];

class _ResponsibilityEditorSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? task;
  final List<Map<String, dynamic>> members;
  const _ResponsibilityEditorSheet({required this.task, required this.members});
  @override
  ConsumerState<_ResponsibilityEditorSheet> createState() => _ResponsibilityEditorSheetState();
}

class _ResponsibilityEditorSheetState extends ConsumerState<_ResponsibilityEditorSheet> {
  late final TextEditingController _title, _description, _customTitle;
  String? _category;
  String? _titleSelection;
  String? _guestId;
  final Set<String> _assigneeIds = {};
  String _status = 'pending';
  String _priority = 'medium';
  DateTime? _dueDate;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    final existingTitle = t?['title'] as String?;
    _title = TextEditingController(text: existingTitle ?? '');
    _description = TextEditingController(text: t?['description'] as String? ?? '');
    _customTitle = TextEditingController();
    _guestId = t?['guest_id']?.toString();
    _status = t?['status'] as String? ?? 'pending';
    _priority = t?['priority'] as String? ?? 'medium';
    final due = t?['due_date'] as String?;
    _dueDate = due != null ? DateTime.tryParse(due) : null;

    if (existingTitle != null && existingTitle.isNotEmpty) {
      for (final entry in _responsibilityTitleOptionsByCategory.entries) {
        if (entry.value.contains(existingTitle)) {
          _category = entry.key;
          _titleSelection = existingTitle;
          break;
        }
      }
      if (_titleSelection == null) {
        _titleSelection = _customResponsibilityTitleSentinel;
        _customTitle.text = existingTitle;
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _customTitle.dispose();
    super.dispose();
  }

  /// Keeps [_title] (the field actually sent to the API) in sync with
  /// whichever of the category/title dropdowns or the custom-title field is
  /// currently driving the selection.
  void _syncTitle() {
    if (_titleSelection == _customResponsibilityTitleSentinel) {
      _title.text = _customTitle.text.trim();
    } else {
      _title.text = _titleSelection ?? '';
    }
  }

  Future<void> _save() async {
    _syncTitle();
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'Give this responsibility a title.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    final notifier = ref.read(weddingPartyProvider.notifier);
    bool ok;
    if (_isEdit) {
      ok = await notifier.updateResponsibility(widget.task!['id'] as int, {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'guest_id': _guestId != null ? int.parse(_guestId!) : null,
        'status': _status,
        'priority': _priority,
        if (_dueDate != null) 'due_date': _dueDate!.toIso8601String().split('T').first,
      });
    } else if (_assigneeIds.isEmpty) {
      ok = await notifier.createResponsibility(
        title: _title.text.trim(),
        description: _description.text.trim(),
        status: _status,
        priority: _priority,
        dueDate: _dueDate,
      );
    } else {
      // One task per selected person — a single "New responsibility" submit
      // can target several specific people at once (not just a shared role,
      // which is what "Create group task" is limited to).
      ok = true;
      for (final id in _assigneeIds) {
        final created = await notifier.createResponsibility(
          title: _title.text.trim(),
          description: _description.text.trim(),
          guestId: int.parse(id),
          status: _status,
          priority: _priority,
          dueDate: _dueDate,
        );
        if (!created) ok = false;
      }
    }
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() { _saving = false; _error = _isEdit ? "Couldn't save. Try again." : "Couldn't create tasks for everyone. Try again."; });
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
          _responsibilityTitlePicker(
            category: _category,
            titleSelection: _titleSelection,
            customTitleController: _customTitle,
            onCategoryChanged: (v) => setState(() {
              _category = v;
              _titleSelection = null;
            }),
            onTitleChanged: (v) => setState(() {
              _titleSelection = v;
              _syncTitle();
            }),
          ),
          const SizedBox(height: 14),
          _SheetField('Description', _description, maxLines: 3, hint: 'Optional'),
          const SizedBox(height: 14),
          const Text('Assigned to', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          if (_isEdit)
            DropdownButtonFormField<String?>(
              initialValue: _guestId,
              decoration: _sheetDecoration(),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Unassigned')),
                ...widget.members.map((m) => DropdownMenuItem<String?>(value: m['id'].toString(), child: Text(_fullName(m)))),
              ],
              onChanged: (v) => setState(() => _guestId = v),
            )
          else ...[
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final m in widget.members)
                FilterChip(
                  label: Text(_fullName(m)),
                  selected: _assigneeIds.contains(m['id'].toString()),
                  onSelected: (sel) => setState(() {
                    final id = m['id'].toString();
                    if (sel) {
                      _assigneeIds.add(id);
                    } else {
                      _assigneeIds.remove(id);
                    }
                  }),
                  selectedColor: AppTheme.udoGreen.withValues(alpha: 0.15),
                ),
            ]),
            if (_assigneeIds.length > 1) ...[
              const SizedBox(height: 6),
              Text('Creates one task for each of the ${_assigneeIds.length} people selected.', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
            ] else if (_assigneeIds.isEmpty) ...[
              const SizedBox(height: 6),
              const Text('No one selected — this task will be unassigned.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
            ],
          ],
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
              decoration: BoxDecoration(color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(12)),
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
          const SizedBox(height: 14),
          const Text('Priority', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _priority,
            decoration: _sheetDecoration(),
            items: const [
              DropdownMenuItem(value: 'high', child: Text('High')),
              DropdownMenuItem(value: 'medium', child: Text('Medium')),
              DropdownMenuItem(value: 'low', child: Text('Low')),
            ],
            onChanged: (v) => setState(() => _priority = v ?? 'medium'),
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

InputDecoration _sheetDecoration() => InputDecoration(filled: true, fillColor: AppTheme.udoCardFill, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4));

Widget _SheetField(String label, TextEditingController ctrl, {int maxLines = 1, String? hint}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
  const SizedBox(height: 6),
  TextField(controller: ctrl, maxLines: maxLines, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13), filled: true, fillColor: AppTheme.udoCardFill, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.udoGreen, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))),
]);

/// "Category" + "Title" dropdowns driven by the responsibility title
/// taxonomy, with a "+ Custom title" escape hatch for anything not in the
/// list. Shared by [_ResponsibilityEditorSheet] and [_GroupTaskSheet] since
/// both create/edit a responsibility title.
Widget _responsibilityTitlePicker({
  required String? category,
  required String? titleSelection,
  required TextEditingController customTitleController,
  required void Function(String? category) onCategoryChanged,
  required void Function(String? titleSelection) onTitleChanged,
}) {
  final titleChoices = category == null
      ? const <String>[]
      : _responsibilityTitleOptionsByCategory[category] ?? const <String>[];
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    const SizedBox(height: 6),
    DropdownButtonFormField<String>(
      initialValue: category,
      isExpanded: true,
      menuMaxHeight: 360,
      decoration: _sheetDecoration(),
      hint: const Text('Select category'),
      items: _responsibilityCategoryOptions
          .map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
          .toList(),
      onChanged: onCategoryChanged,
    ),
    const SizedBox(height: 14),
    const Text('Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    const SizedBox(height: 6),
    DropdownButtonFormField<String>(
      initialValue: titleSelection,
      isExpanded: true,
      menuMaxHeight: 360,
      decoration: _sheetDecoration(),
      hint: Text(category == null ? 'Pick a category first' : 'Select title'),
      items: [
        for (final t in titleChoices) DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis)),
        const DropdownMenuItem(value: _customResponsibilityTitleSentinel, child: Text('+ Custom title')),
      ],
      onChanged: category == null ? null : onTitleChanged,
    ),
    if (titleSelection == _customResponsibilityTitleSentinel) ...[
      const SizedBox(height: 10),
      TextField(
        controller: customTitleController,
        decoration: InputDecoration(
          hintText: 'e.g. Steam the veil',
          filled: true,
          fillColor: AppTheme.udoCardFill,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    ],
  ]);
}

// ── BUZZES TAB ─────────────────────────────────────────────────────────────────

const _kBuzzChannelLabels = {'email': 'Email', 'sms': 'SMS', 'whatsapp': 'WhatsApp', 'in_app': 'Guest Portal Link'};

const _kBuzzTemplates = {
  'Morning check-in': "Good morning! Just checking in — let us know if you need anything today.",
  'Rehearsal reminder': 'A quick reminder that our rehearsal is scheduled soon. Please confirm that you will be there.',
  'Attire reminder': "Reminder: please confirm your attire status if you haven't already.",
  'Travel reminder': "Reminder: please share your travel details if you haven't already, so we can plan pickups and hotel rooms.",
  'Thank you message': "Thank you so much for everything you're doing to help make this day special. We're so grateful for you.",
};

const _kBuzzDateFilters = ['All', 'Today', 'This week'];

class _BuzzesTab extends ConsumerStatefulWidget {
  final WeddingPartyState state;
  const _BuzzesTab({required this.state});
  @override
  ConsumerState<_BuzzesTab> createState() => _BuzzesTabState();
}

class _BuzzesTabState extends ConsumerState<_BuzzesTab> {
  String _dateFilter = 'All';

  bool _isThisWeek(DateTime? d) => d != null && !d.isBefore(DateTime.now().subtract(const Duration(days: 7)));
  bool _isToday(DateTime? d) {
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final sentThisWeek = state.buzzes.where((m) => _isThisWeek(DateTime.tryParse(m['sent_at'] as String? ?? ''))).toList();
    final peopleReached = sentThisWeek.fold<int>(0, (sum, m) => sum + ((m['recipient_count'] as num?)?.toInt() ?? 0));
    var deliveredSum = 0;
    var attemptedSum = 0;
    for (final m in sentThisWeek) {
      final summary = m['delivery_summary'] as Map<String, dynamic>?;
      deliveredSum += (summary?['delivered_count'] as num?)?.toInt() ?? 0;
      attemptedSum += (summary?['total'] as num?)?.toInt() ?? 0;
    }
    final deliveryRate = attemptedSum > 0 ? ((deliveredSum / attemptedSum) * 100).round() : null;

    final visibleBuzzes = state.buzzes.where((m) {
      final sentAt = DateTime.tryParse(m['sent_at'] as String? ?? '');
      if (_dateFilter == 'Today') return _isToday(sentAt);
      if (_dateFilter == 'This week') return _isThisWeek(sentAt);
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (state.buzzes.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
            child: Row(children: [
              _MiniStat('${sentThisWeek.length}', 'Sent\nthis week', AppTheme.udoGreen),
              _MiniStat('$peopleReached', 'People\nreached', Colors.blue),
              _MiniStat(deliveryRate != null ? '$deliveryRate%' : '—', 'Delivery\nrate', const Color(0xFF22C55E)),
            ]),
          ),
          const SizedBox(height: 16),
        ],
        const Text('Quick send', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final entry in _kBuzzTemplates.entries)
            ActionChip(
              label: Text(entry.key, style: const TextStyle(fontSize: 12)),
              onPressed: state.members.isEmpty ? null : () => _openComposer(context, ref, initialBody: entry.value),
              side: const BorderSide(color: AppTheme.udoBorder),
            ),
        ]),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: state.members.isEmpty ? null : () => _openComposer(context, ref),
          icon: const Icon(Icons.send_outlined, size: 18),
          label: const Text('New message'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
        ),
        if (state.members.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 8), child: Text('Add someone to your wedding party first.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary))),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: state.members.isEmpty ? null : () => _openComposer(context, ref, initialUrgent: true),
          icon: const Icon(Icons.warning_amber_outlined, size: 18, color: AppTheme.udoCrimson),
          label: const Text('Send emergency broadcast', style: TextStyle(color: AppTheme.udoCrimson)),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: AppTheme.udoCrimson)),
        ),
        const SizedBox(height: 20),
        const Text('Recent messages', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        if (state.buzzes.isNotEmpty) ...[
          Wrap(spacing: 8, children: [
            for (final label in _kBuzzDateFilters)
              ChoiceChip(
                label: Text(label, style: const TextStyle(fontSize: 12)),
                selected: _dateFilter == label,
                onSelected: (_) => setState(() => _dateFilter = label),
                selectedColor: AppTheme.udoGreen.withValues(alpha: 0.15),
              ),
          ]),
          const SizedBox(height: 8),
        ],
        if (state.buzzesError != null)
          _errorBox("Couldn't load recent buzzes.", state.buzzesError!)
        else if (state.buzzes.isEmpty)
          _emptyBox('No buzzes sent yet.', icon: Icons.campaign_outlined)
        else if (visibleBuzzes.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('No messages in this range.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)))
        else
          for (final msg in visibleBuzzes) Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(msg['body'] as String? ?? '', style: const TextStyle(fontSize: 13, height: 1.4)),
              const SizedBox(height: 6),
              Row(children: [
                Text('Via ${_kBuzzChannelLabels[msg['channel']] ?? msg['channel']} · ${msg['recipient_count'] ?? 0} recipient${(msg['recipient_count'] ?? 0) == 1 ? '' : 's'}', style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
                const Spacer(),
                if (msg['message_type'] == 'emergency') ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.udoCrimson.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Emergency', style: TextStyle(fontSize: 10, color: AppTheme.udoCrimson, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 6),
                ],
                _DeliveryBadge(msg['delivery_summary'] as Map<String, dynamic>?),
              ]),
              const SizedBox(height: 4),
              Text(_formatDate(msg['sent_at'] as String?), style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
            ]),
          ),
      ],
    );
  }

  void _openComposer(BuildContext context, WidgetRef ref, {String initialBody = '', bool initialUrgent = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BuzzComposerSheet(
        initialBody: initialBody,
        initialUrgent: initialUrgent,
        recipientCount: widget.state.members.length,
        onSend: (body, channel, urgent) => ref.read(weddingPartyProvider.notifier).sendBuzz(body: body, channel: channel, urgent: urgent),
      ),
    );
  }
}

/// Real per-message delivery status from [MessageAnalyticsService]'s already-
/// computed summary — Delivered/Partial when every/some recipient's delivery
/// succeeded, Sending while no delivery events have landed yet.
class _DeliveryBadge extends StatelessWidget {
  final Map<String, dynamic>? summary;
  const _DeliveryBadge(this.summary);

  @override
  Widget build(BuildContext context) {
    final total = (summary?['total'] as num?)?.toInt() ?? 0;
    final delivered = (summary?['delivered_count'] as num?)?.toInt() ?? 0;
    final failed = (summary?['failed_count'] as num?)?.toInt() ?? 0;

    String label;
    Color color;
    if (total == 0) {
      label = 'Sending';
      color = Colors.orange;
    } else if (delivered >= total) {
      label = 'Delivered';
      color = const Color(0xFF22C55E);
    } else if (failed > 0 && delivered == 0) {
      label = 'Failed';
      color = AppTheme.udoCrimson;
    } else {
      label = 'Partial';
      color = Colors.orange;
    }

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: color)),
    ]);
  }
}

/// Shared composer used by the Buzz tab's Quick Send/New Message actions,
/// Responsibilities' bulk "Send Reminder", Travel's "Request travel details",
/// and the Emergency tab's urgent-broadcast shortcut — one delivery path
/// (sendBuzz) instead of several different messaging flows.
class BuzzComposerSheet extends ConsumerStatefulWidget {
  final String initialBody;
  final bool initialUrgent;
  final int recipientCount;
  final Future<bool> Function(String body, String channel, bool urgent) onSend;
  const BuzzComposerSheet({this.initialBody = '', this.initialUrgent = false, required this.recipientCount, required this.onSend});
  @override
  ConsumerState<BuzzComposerSheet> createState() => BuzzComposerSheetState();
}

class BuzzComposerSheetState extends ConsumerState<BuzzComposerSheet> {
  late final _ctrl = TextEditingController(text: widget.initialBody);
  late String _channel = widget.initialUrgent ? 'sms' : 'email';
  late bool _urgent = widget.initialUrgent;
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final guestPortalUrl = ref.watch(homeProvider).guestPortalUrl;
    return Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: Text('New message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
      ]),
      const SizedBox(height: 4),
      Text(
        'Sending to ${widget.recipientCount} wedding party member${widget.recipientCount == 1 ? '' : 's'}.',
        style: const TextStyle(fontSize: 12.5, color: AppTheme.udoTextSecondary, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 8),
      Row(children: [
        const Expanded(child: Text('Urgent', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        Switch(value: _urgent, onChanged: (v) => setState(() { _urgent = v; if (v) _channel = 'sms'; }), activeColor: AppTheme.udoCrimson),
      ]),
      if (_urgent)
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.udoCrimson.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
          child: const Text('Marked urgent — you\'ll be asked to confirm before this sends.', style: TextStyle(fontSize: 12, color: AppTheme.udoCrimson)),
        ),
      TextField(
        controller: _ctrl, maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Write your message...',
          hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14),
          filled: true, fillColor: AppTheme.udoCardFill,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
      const SizedBox(height: 12),
      const Text('Channel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      Wrap(spacing: 8, children: [
        for (final entry in _kBuzzChannelLabels.entries)
          ChoiceChip(
            label: Text(entry.value, style: const TextStyle(fontSize: 12)),
            selected: _channel == entry.key,
            onSelected: (_) => setState(() => _channel = entry.key),
            selectedColor: AppTheme.udoGreen,
            labelStyle: TextStyle(color: _channel == entry.key ? Colors.white : AppTheme.udoTextPrimary),
            side: BorderSide(color: _channel == entry.key ? AppTheme.udoGreen : AppTheme.udoBorder),
          ),
      ]),
      if (_channel == 'in_app') ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.udoGreen.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.info_outline, size: 15, color: AppTheme.udoGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                guestPortalUrl != null && guestPortalUrl.isNotEmpty
                    ? 'No native inbox yet — guests will see this on their wedding portal:\n$guestPortalUrl'
                    : "No native inbox yet — guests will see this on their wedding portal page once it's set up.",
                style: const TextStyle(fontSize: 12, color: AppTheme.udoGreen, height: 1.4),
              ),
            ),
          ]),
        ),
      ],
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: _sending ? null : _submit,
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: _urgent ? AppTheme.udoCrimson : AppTheme.udoGreen, foregroundColor: Colors.white),
        child: _sending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_urgent ? 'Review & send urgent message' : 'Send message'),
      ),
    ]))));
  }

  Future<void> _submit() async {
    if (_ctrl.text.trim().isEmpty) return;
    if (_urgent) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Send urgent message?'),
          content: Text('You are about to send an urgent message to ${widget.recipientCount} ${widget.recipientCount == 1 ? 'person' : 'people'} via ${_kBuzzChannelLabels[_channel]}.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Send', style: TextStyle(color: AppTheme.udoCrimson))),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    setState(() => _sending = true);
    final ok = await widget.onSend(_ctrl.text.trim(), _channel, _urgent);
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't send that message. Try again.")));
    }
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
      return ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), children: [
        _emptyBox('No timeline events yet.', icon: Icons.schedule_outlined),
        const SizedBox(height: 8),
        Center(child: TextButton(onPressed: () => context.push('/plan?section=timeline'), child: const Text('Build your day timeline'))),
      ]);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Row(children: [
          const Expanded(child: Text('Day timeline', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          TextButton(onPressed: () => context.push('/plan?section=timeline'), child: const Text('Edit in Plan', style: TextStyle(fontSize: 13))),
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

class _TravelTab extends ConsumerWidget {
  final WeddingPartyState state;
  const _TravelTab({required this.state});

  String _travelStatus(Map<String, dynamic> m) {
    if (m['travel_required'] != true) return 'not-required';
    if (m['hotel_assignment_id'] != null && m['transport_assignment_id'] != null) return 'arranged';
    if (m['arrival_date'] != null) return 'arriving';
    return 'needs-info';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.travelError != null) return _errorBox("Couldn't load travel details.", state.travelError!);

    final needsInfo = state.members.where((m) => _travelStatus(m) == 'needs-info').toList();
    final travelling = state.members.where((m) => m['travel_required'] == true).toList();
    final local = state.members.where((m) => m['travel_required'] != true).length;
    final arranged = travelling.where((m) => _travelStatus(m) == 'arranged').length;
    final coveragePct = travelling.isNotEmpty ? ((arranged / travelling.length) * 100).round() : null;

    final arrivalGroups = <String, List<Map<String, dynamic>>>{};
    for (final m in travelling) {
      final raw = m['arrival_date'] as String?;
      if (raw == null) continue;
      final d = DateTime.tryParse(raw);
      if (d == null) continue;
      final key = DateFormat('EEE, MMM d').format(d);
      (arrivalGroups[key] ??= []).add(m);
    }
    final sortedArrivalKeys = arrivalGroups.keys.toList()
      ..sort((a, b) => arrivalGroups[a]!.first['arrival_date'].toString().compareTo(arrivalGroups[b]!.first['arrival_date'].toString()));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            _MiniStat('${travelling.length}', 'Travelling', Colors.blue),
            _MiniStat('$local', 'Local', Colors.purple),
            _MiniStat('${needsInfo.length}', 'Details\npending', AppTheme.udoCrimson),
            _MiniStat(coveragePct != null ? '$coveragePct%' : '—', 'Group\ncoverage', const Color(0xFF22C55E)),
          ]),
        ),
        const SizedBox(height: 12),
        if (sortedArrivalKeys.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Arrivals', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              for (final key in sortedArrivalKeys)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('${arrivalGroups[key]!.length} arriving $key', style: const TextStyle(fontSize: 13)),
                ),
            ]),
          ),
          const SizedBox(height: 12),
        ],
        if (needsInfo.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.udoCrimson.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoCrimson.withValues(alpha: 0.2))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.info_outline, color: AppTheme.udoCrimson, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('${needsInfo.length} ${needsInfo.length == 1 ? 'person is' : 'people are'} missing travel details', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.udoCrimson))),
              ]),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _requestTravelDetails(context, ref, needsInfo),
                icon: const Icon(Icons.send_outlined, size: 16),
                label: const Text('Request travel details'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44), backgroundColor: AppTheme.udoCrimson, foregroundColor: Colors.white),
              ),
            ]),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Hotels', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
              TextButton.icon(
                onPressed: () => showModalBottomSheet(
                  context: context, isScrollControlled: true,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  builder: (_) => AddHotelModal(notifier: ref.read(logisticsProvider.notifier)),
                // AddHotelModal saves through logisticsProvider, a separate
                // state container from weddingPartyProvider (which supplies
                // state.accommodations above) — without this refresh, a
                // newly added hotel wouldn't show up here until the next
                // manual pull-to-refresh.
                ).then((_) => ref.read(weddingPartyProvider.notifier).refresh()),
                icon: const Icon(Icons.add, size: 16), label: const Text('Add', style: TextStyle(fontSize: 13)),
              ),
            ]),
            const SizedBox(height: 10),
            if (state.accommodations.isEmpty)
              const Text('No accommodation options added yet.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary))
            else for (final a in state.accommodations) Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(12)),
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
            Row(children: [
              const Expanded(child: Text('Transport', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
              TextButton.icon(
                onPressed: () => showModalBottomSheet(
                  context: context, isScrollControlled: true,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  builder: (_) => AddTransportModal(notifier: ref.read(logisticsProvider.notifier)),
                ).then((_) => ref.read(weddingPartyProvider.notifier).refresh()),
                icon: const Icon(Icons.add, size: 16), label: const Text('Add', style: TextStyle(fontSize: 13)),
              ),
            ]),
            const SizedBox(height: 10),
            if (state.transportGroups.isEmpty)
              const Text('No transport groups added yet.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary))
            else for (final t in state.transportGroups) Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(12)),
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
            if (_travelStatus(m) == 'needs-info')
              TextButton(
                onPressed: () => _requestTravelDetails(context, ref, [m]),
                child: const Text('Request info', style: TextStyle(fontSize: 12)),
              )
            else
              _TravelBadge(_travelStatus(m)),
          ]),
        ),
      ],
    );
  }

  void _requestTravelDetails(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> needsInfo) {
    final names = needsInfo.map(_fullName).join(', ');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      // Same caveat as Responsibilities' bulk reminder: sendBuzz broadcasts
      // to the whole wedding party, it can't target only these named people
      // yet — the message names them so recipients know who's being asked.
      builder: (_) => BuzzComposerSheet(
        initialBody: "Hi everyone — we're missing travel details for $names. Please share your arrival date, accommodation and transport needs so we can finalise arrangements.",
        recipientCount: state.members.length,
        onSend: (body, channel, urgent) => ref.read(weddingPartyProvider.notifier).sendBuzz(body: body, channel: channel, urgent: urgent),
      ),
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

  Map<String, dynamic>? _upcomingRehearsal() {
    if (state.rehearsals.isEmpty) return null;
    final sorted = [...state.rehearsals]..sort((a, b) {
      final da = DateTime.tryParse(a['event_date'] as String? ?? '');
      final db = DateTime.tryParse(b['event_date'] as String? ?? '');
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });
    return sorted.first;
  }

  void _openAddRehearsal(BuildContext context, {Map<String, dynamic>? rehearsal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddRehearsalSheet(members: state.members, rehearsal: rehearsal),
    );
  }

  Future<void> _sendReminder(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(weddingPartyProvider.notifier).sendBuzz(
          body: 'Reminder: please confirm your attendance for the rehearsal.',
          channel: 'email',
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Reminder sent to your wedding party.' : "Couldn't send that reminder.")));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.rehearsalsError != null) return _errorBox("Couldn't load the rehearsal.", state.rehearsalsError!);

    final rehearsal = _upcomingRehearsal();

    if (rehearsal == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('No rehearsal scheduled yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              const Text('Add the details for your rehearsal so your wedding party knows when and where to be.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => _openAddRehearsal(context),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Setup Rehearsal'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
              ),
            ]),
          ),
        ],
      );
    }

    final color = _parseHexColor(rehearsal['color'] as String?) ?? AppTheme.udoGreen;
    final attendeeIds = (rehearsal['attendee_guest_ids'] as List?)?.map((id) => id.toString()).toSet();
    final attendance = (attendeeIds != null && attendeeIds.isNotEmpty)
        ? state.members.where((m) => attendeeIds.contains(m['id'].toString())).toList()
        : state.members;

    final invited = attendance.length;
    final responded = attendance.where((m) => (m['rehearsal_status'] as String? ?? 'pending') != 'pending').length;
    final pending = invited - responded;
    final unavailable = attendance.where((m) => m['rehearsal_status'] == 'declined').length;

    final scheduleItems = (rehearsal['schedule_items'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        // ── Rehearsal Overview ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Rehearsal Overview', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
              IconButton(
                onPressed: () => _openAddRehearsal(context, rehearsal: rehearsal),
                icon: const Icon(Icons.edit_outlined, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ]),
            const SizedBox(height: 8),
            Wrap(spacing: 12, runSpacing: 4, children: [
              _InfoChip(Icons.calendar_today_outlined, _formatDate(rehearsal['event_date'] as String?)),
              _InfoChip(Icons.schedule_outlined, '${_formatTime(rehearsal['start_time'] as String?)}${(rehearsal['end_time'] as String?)?.isNotEmpty == true ? ' – ${_formatTime(rehearsal['end_time'] as String?)}' : ''}'),
              if ((rehearsal['location'] as String?)?.isNotEmpty == true) _InfoChip(Icons.place_outlined, rehearsal['location'] as String),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _RehearsalStat(color: color, icon: Icons.groups_outlined, count: invited, label: 'Invited', action: 'View all')),
              Expanded(child: _RehearsalStat(color: const Color(0xFF22C55E), icon: Icons.check_circle_outline, count: responded, label: 'Responded', action: 'View responses')),
              Expanded(child: _RehearsalStat(color: Colors.orange, icon: Icons.hourglass_empty, count: pending, label: 'Pending', action: 'Send reminder', onAction: pending > 0 ? () => _sendReminder(context, ref) : null)),
              Expanded(child: _RehearsalStat(color: AppTheme.udoCrimson, icon: Icons.cancel_outlined, count: unavailable, label: 'Unavailable', action: 'View details')),
            ]),
          ]),
        ),
        const SizedBox(height: 12),

        // ── Rehearsal Details ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Rehearsal Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            if ((rehearsal['location'] as String?)?.isNotEmpty == true) _DetailRow(Icons.place_outlined, 'Location', rehearsal['location'] as String),
            _DetailRow(Icons.calendar_today_outlined, 'Date & Time',
                '${_formatDate(rehearsal['event_date'] as String?)} · ${_formatTime(rehearsal['start_time'] as String?)}${(rehearsal['end_time'] as String?)?.isNotEmpty == true ? ' – ${_formatTime(rehearsal['end_time'] as String?)}' : ''}'),
            if ((rehearsal['dress_code'] as String?)?.isNotEmpty == true) _DetailRow(Icons.checkroom_outlined, 'Attire', rehearsal['dress_code'] as String),
            if ((rehearsal['notes'] as String?)?.isNotEmpty == true) _DetailRow(Icons.notes_outlined, 'Notes', rehearsal['notes'] as String, isLast: true),
          ]),
        ),

        if (scheduleItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Schedule', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              for (var i = 0; i < scheduleItems.length; i++)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Column(children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    if (i != scheduleItems.length - 1) Container(width: 2, height: 44, color: AppTheme.udoBorder),
                  ]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_formatTime(scheduleItems[i]['time'] as String?), style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(scheduleItems[i]['title'] as String? ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        if ((scheduleItems[i]['description'] as String?)?.isNotEmpty == true)
                          Text(scheduleItems[i]['description'] as String, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                      ]),
                    ),
                  ),
                ]),
            ]),
          ),
        ],

        const SizedBox(height: 12),
        Row(children: [
          const Expanded(child: Text('Attendance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          TextButton.icon(
            onPressed: () => _openAddRehearsal(context, rehearsal: rehearsal),
            icon: const Icon(Icons.people_outline, size: 16),
            label: const Text('Manage Attendees', style: TextStyle(fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 8),
        if (attendance.isEmpty)
          _emptyBox('No wedding party members yet.', icon: Icons.people_outline)
        else for (final m in attendance) GestureDetector(
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppTheme.udoTextSecondary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
      ]);
}

class _RehearsalStat extends StatelessWidget {
  final Color color;
  final IconData icon;
  final int count;
  final String label;
  final String action;
  final VoidCallback? onAction;
  const _RehearsalStat({required this.color, required this.icon, required this.count, required this.label, required this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 6),
        Text('$count', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary), textAlign: TextAlign.center),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: onAction,
          child: Text(action, style: TextStyle(fontSize: 10, color: onAction != null ? color : AppTheme.udoTextSecondary, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ),
      ]);
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _DetailRow(this.icon, this.label, this.value, {this.isLast = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: AppTheme.udoTextSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ]),
          ),
        ]),
      );
}

Color? _parseHexColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
  return value == null ? null : Color(value + 0xFF000000);
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

const _rehearsalColorOptions = ['#2F6F4E', '#E8A7B0', '#B79CDB', '#D99A52', '#7FA8D9'];

const _rehearsalAudienceOptions = {
  'wedding_party': 'Wedding Party',
  'family': 'Immediate Family',
  'vendors': 'Vendors',
  'all': 'Everyone',
  'selected': 'Custom',
};

const _dressCodeOptions = ['Casual', 'Semi-Formal', 'Formal', 'Black Tie', 'Cocktail', 'Beach Casual', 'Custom'];

const _timezoneOptions = [
  '(GMT-08:00) Pacific Time (US & Canada)',
  '(GMT-07:00) Mountain Time (US & Canada)',
  '(GMT-06:00) Central Time (US & Canada)',
  '(GMT-05:00) Eastern Time (US & Canada)',
  '(GMT-04:00) Atlantic Time (Canada)',
  '(GMT-03:00) Buenos Aires',
  '(GMT+00:00) London, Dublin',
  '(GMT+01:00) Paris, Berlin, Rome',
  '(GMT+02:00) Athens, Cairo, Johannesburg',
  '(GMT+03:00) Nairobi, Moscow',
  '(GMT+04:00) Dubai',
  '(GMT+05:30) Mumbai, New Delhi',
  '(GMT+08:00) Singapore, Beijing, Perth',
  '(GMT+09:00) Tokyo, Seoul',
  '(GMT+10:00) Sydney, Melbourne',
  '(GMT+12:00) Auckland',
];

String _fmtTimeOfDay(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

TimeOfDay? _parseTimeOfDay(String? raw) {
  if (raw == null) return null;
  final parts = raw.split(':');
  if (parts.length < 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return TimeOfDay(hour: h, minute: m);
}

class _ColorSwatchPicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _ColorSwatchPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(children: [
    for (final hex in _rehearsalColorOptions)
      Padding(
        padding: const EdgeInsets.only(right: 10),
        child: GestureDetector(
          onTap: () => onChanged(hex),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _parseHexColor(hex),
              shape: BoxShape.circle,
              border: value == hex ? Border.all(color: AppTheme.udoTextPrimary, width: 2) : null,
            ),
            child: value == hex ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
          ),
        ),
      ),
  ]);
}

class _RehearsalScheduleRow {
  TimeOfDay? time;
  final TextEditingController title;
  final TextEditingController description;
  _RehearsalScheduleRow({this.time, String initialTitle = '', String initialDescription = ''})
      : title = TextEditingController(text: initialTitle),
        description = TextEditingController(text: initialDescription);

  void dispose() {
    title.dispose();
    description.dispose();
  }
}

class _AddRehearsalSheet extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> members;
  final Map<String, dynamic>? rehearsal;
  const _AddRehearsalSheet({required this.members, this.rehearsal});

  @override
  ConsumerState<_AddRehearsalSheet> createState() => _AddRehearsalSheetState();
}

class _AddRehearsalSheetState extends ConsumerState<_AddRehearsalSheet> {
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _description;
  late final TextEditingController _bringItems;
  late final TextEditingController _notes;
  late String _color;
  String? _locationPlaceId;
  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _timezone;
  late String _audience;
  late final Set<String> _attendeeIds;
  late final List<_RehearsalScheduleRow> _scheduleRows;
  String? _dressCode;
  bool _addToTimeline = true;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.rehearsal != null;

  @override
  void initState() {
    super.initState();
    final r = widget.rehearsal;
    _title = TextEditingController(text: r?['title'] as String? ?? '');
    _location = TextEditingController(text: r?['location'] as String? ?? '');
    _description = TextEditingController(text: r?['description'] as String? ?? '');
    final bringItems = (r?['bring_items'] as List?)?.map((e) => e.toString()).toList();
    _bringItems = TextEditingController(text: bringItems?.join(', ') ?? '');
    _notes = TextEditingController(text: r?['notes'] as String? ?? '');
    _color = r?['color'] as String? ?? _rehearsalColorOptions.first;
    _locationPlaceId = r?['location_place_id'] as String?;
    final rawDate = r?['event_date'] as String?;
    _eventDate = rawDate != null ? DateTime.tryParse(rawDate) : null;
    _startTime = _parseTimeOfDay(r?['start_time'] as String?);
    _endTime = _parseTimeOfDay(r?['end_time'] as String?);
    _timezone = r?['timezone'] as String?;
    _audience = r?['audience'] as String? ?? 'wedding_party';
    _attendeeIds = (r?['attendee_guest_ids'] as List?)?.map((id) => id.toString()).toSet() ?? {};
    _dressCode = r?['dress_code'] as String?;
    _addToTimeline = r?['add_to_timeline'] as bool? ?? true;

    final rawSchedule = r?['schedule_items'] as List?;
    if (rawSchedule != null) {
      _scheduleRows = rawSchedule.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return _RehearsalScheduleRow(
          time: _parseTimeOfDay(map['time'] as String?),
          initialTitle: map['title'] as String? ?? '',
          initialDescription: map['description'] as String? ?? '',
        );
      }).toList();
    } else {
      // A brand-new rehearsal starts with a sensible run-of-show template —
      // fully editable/removable, not required.
      _scheduleRows = [
        _RehearsalScheduleRow(initialTitle: 'Arrival & Check-in', initialDescription: 'Please sign in when you arrive'),
        _RehearsalScheduleRow(initialTitle: 'Welcome & Instructions', initialDescription: 'Overview of the rehearsal flow and key notes'),
        _RehearsalScheduleRow(initialTitle: 'Full Processional Run-through', initialDescription: 'Walking order and timing'),
        _RehearsalScheduleRow(initialTitle: 'Ceremony Run-through', initialDescription: 'Vows, readings and special moments'),
      ];
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    _bringItems.dispose();
    _notes.dispose();
    for (final row in _scheduleRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addScheduleRow() => setState(() => _scheduleRows.add(_RehearsalScheduleRow()));

  void _removeScheduleRow(int index) => setState(() {
        _scheduleRows[index].dispose();
        _scheduleRows.removeAt(index);
      });

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _eventDate == null) {
      setState(() => _error = 'Give the rehearsal a title and a date.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final notifier = ref.read(weddingPartyProvider.notifier);
    final data = {
      'title': _title.text.trim(),
      'color': _color,
      if (_location.text.trim().isNotEmpty) 'location': _location.text.trim(),
      if (_locationPlaceId != null) 'location_place_id': _locationPlaceId,
      if (_description.text.trim().isNotEmpty) 'description': _description.text.trim(),
      'event_date': _eventDate!.toIso8601String().split('T').first,
      if (_startTime != null) 'start_time': _fmtTimeOfDay(_startTime!),
      if (_endTime != null) 'end_time': _fmtTimeOfDay(_endTime!),
      if (_timezone != null) 'timezone': _timezone,
      'audience': _audience,
      'attendee_guest_ids': _attendeeIds.map(int.parse).toList(),
      if (_dressCode != null) 'dress_code': _dressCode,
      'bring_items': _bringItems.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      'schedule_items': _scheduleRows
          .where((row) => row.title.text.trim().isNotEmpty)
          .map((row) => {
                if (row.time != null) 'time': _fmtTimeOfDay(row.time!),
                'title': row.title.text.trim(),
                if (row.description.text.trim().isNotEmpty) 'description': row.description.text.trim(),
              })
          .toList(),
      if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
      'add_to_timeline': _addToTimeline,
    };
    final ok = _isEdit
        ? await notifier.updateRehearsal(widget.rehearsal!['id'] as int, data)
        : await notifier.createRehearsal(data);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save the rehearsal. Try again.";
      });
    }
  }

  Widget _datePickButton() => GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(context: context, initialDate: _eventDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
          if (picked != null) setState(() => _eventDate = picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.udoTextSecondary),
            const SizedBox(width: 6),
            Expanded(child: Text(_eventDate != null ? _formatDate(_eventDate!.toIso8601String()) : 'Select date', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
          ]),
        ),
      );

  Widget _timePickButton(String label, TimeOfDay? value, ValueChanged<TimeOfDay> onPicked) => GestureDetector(
        onTap: () async {
          final picked = await showTimePicker(context: context, initialTime: value ?? TimeOfDay.now());
          if (picked != null) onPicked(picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(Icons.schedule_outlined, size: 14, color: AppTheme.udoTextSecondary),
            const SizedBox(width: 6),
            Expanded(child: Text(value != null ? value.format(context) : label, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          builder: (_, ctrl) => Column(children: [
            Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(children: [
                Expanded(child: Text(_isEdit ? 'Edit rehearsal' : 'Add Rehearsal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('BASIC DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.udoTextSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  _SheetField('Rehearsal title', _title, hint: 'e.g. Wedding Rehearsal'),
                  const SizedBox(height: 14),
                  const Text('Color', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  _ColorSwatchPicker(value: _color, onChanged: (v) => setState(() => _color = v)),
                  const SizedBox(height: 14),
                  const Text('Location', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  PlaceSearchField(
                    controller: _location,
                    search: ref.read(weddingPartyProvider.notifier).searchPlaces,
                    hint: 'Enter venue or address',
                    useFullDescriptionOnSelect: true,
                  ),
                  const SizedBox(height: 14),
                  const Text('Description (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _description,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Add any notes or details about the rehearsal...',
                      hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13),
                      filled: true,
                      fillColor: AppTheme.udoCardFill,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('DATE & TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.udoTextSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _datePickButton()),
                    const SizedBox(width: 8),
                    Expanded(child: _timePickButton('Start time', _startTime, (t) => setState(() => _startTime = t))),
                    const SizedBox(width: 8),
                    Expanded(child: _timePickButton('End time', _endTime, (t) => setState(() => _endTime = t))),
                  ]),
                  const SizedBox(height: 14),
                  const Text('Time zone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _timezone,
                    decoration: _sheetDecoration(),
                    isExpanded: true,
                    items: [
                      for (final tz in _timezoneOptions) DropdownMenuItem(value: tz, child: Text(tz, overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (v) => setState(() => _timezone = v),
                  ),
                  const SizedBox(height: 16),
                  const Text('SCHEDULE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.udoTextSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  const Text('Optional run-of-show for the rehearsal itself.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                  const SizedBox(height: 10),
                  for (var i = 0; i < _scheduleRows.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(12)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showTimePicker(context: context, initialTime: _scheduleRows[i].time ?? TimeOfDay.now());
                                  if (picked != null) setState(() => _scheduleRows[i].time = picked);
                                },
                                child: Row(children: [
                                  const Icon(Icons.schedule_outlined, size: 14, color: AppTheme.udoTextSecondary),
                                  const SizedBox(width: 6),
                                  Text(_scheduleRows[i].time != null ? _scheduleRows[i].time!.format(context) : 'Set time', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                ]),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _scheduleRows[i].title,
                                style: const TextStyle(fontSize: 13),
                                decoration: const InputDecoration(hintText: 'Step title', isDense: true, border: InputBorder.none),
                              ),
                              TextField(
                                controller: _scheduleRows[i].description,
                                style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary),
                                decoration: const InputDecoration(hintText: 'Description (optional)', isDense: true, border: InputBorder.none),
                              ),
                            ]),
                          ),
                        ),
                        IconButton(onPressed: () => _removeScheduleRow(i), icon: const Icon(Icons.remove_circle_outline, size: 20)),
                      ]),
                    ),
                  TextButton.icon(
                    onPressed: _addScheduleRow,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add schedule item', style: TextStyle(fontSize: 13)),
                  ),
                  const SizedBox(height: 6),
                  const Text('ATTENDANCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.udoTextSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  const Text('Who should attend?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final entry in _rehearsalAudienceOptions.entries)
                      ChoiceChip(
                        label: Text(entry.value, style: const TextStyle(fontSize: 12)),
                        selected: _audience == entry.key,
                        onSelected: (_) => setState(() => _audience = entry.key),
                        selectedColor: AppTheme.udoGreen,
                        labelStyle: TextStyle(color: _audience == entry.key ? Colors.white : AppTheme.udoTextPrimary),
                      ),
                  ]),
                  const SizedBox(height: 14),
                  const Text('Add specific people', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('Select from your wedding party or add guests.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final m in widget.members)
                      FilterChip(
                        label: Text(_fullName(m)),
                        selected: _attendeeIds.contains(m['id'].toString()),
                        onSelected: (sel) => setState(() {
                          final id = m['id'].toString();
                          if (sel) {
                            _attendeeIds.add(id);
                          } else {
                            _attendeeIds.remove(id);
                          }
                        }),
                        selectedColor: AppTheme.udoGreen.withValues(alpha: 0.15),
                      ),
                  ]),
                  const SizedBox(height: 16),
                  const Text('ADDITIONAL DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.udoTextSecondary, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Attire', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _dressCode,
                          decoration: _sheetDecoration(),
                          items: [
                            for (final d in _dressCodeOptions) DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13))),
                          ],
                          onChanged: (v) => setState(() => _dressCode = v),
                        ),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _SheetField('Bring anything?', _bringItems, hint: 'e.g. Vows, attire, scripts')),
                  ]),
                  const SizedBox(height: 4),
                  const Text('Separate multiple items with commas', style: TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
                  const SizedBox(height: 14),
                  _SheetField('Notes (Optional)', _notes, maxLines: 3, hint: 'Any other notes or reminders...'),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Add to timeline', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        const Text('Add this rehearsal to your wedding timeline', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                      ]),
                    ),
                    Switch(value: _addToTimeline, onChanged: (v) => setState(() => _addToTimeline = v), activeThumbColor: AppTheme.udoGreen),
                  ]),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!, style: const TextStyle(fontSize: 12, color: AppTheme.udoCrimson)),
                  ],
                  const SizedBox(height: 24),
                ]),
              ),
            ),
            const Divider(height: 1),
            Container(
              color: AppTheme.udoBackground,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: SafeArea(
                top: false,
                child: Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save_outlined, size: 16),
                      label: Text(_saving ? 'Saving…' : 'Save Rehearsal', style: const TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
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
              decoration: InputDecoration(hintText: 'e.g. Best man', filled: true, fillColor: AppTheme.udoCardFill, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
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
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(14)), child: const Text('No responsibilities assigned yet.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)))
            else Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(14)),
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

class _LinkExistingGuestSheet extends ConsumerStatefulWidget {
  final Future<void> Function(int guestId, String role) onLink;
  const _LinkExistingGuestSheet({required this.onLink});
  @override
  ConsumerState<_LinkExistingGuestSheet> createState() => _LinkExistingGuestSheetState();
}

class _LinkExistingGuestSheetState extends ConsumerState<_LinkExistingGuestSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final guestsState = ref.watch(guestsProvider);
    final partyState = ref.watch(weddingPartyProvider);
    final existingIds = partyState.members.map((m) => m['id']).toSet();

    final candidates = guestsState.guests.where((g) {
      if (existingIds.contains(g['id'])) return false;
      if (_query.isEmpty) return true;
      return _fullName(g).toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(children: [
              const Expanded(child: Text('Select an existing guest', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search guests',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true, fillColor: AppTheme.udoCardFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: guestsState.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.udoGreen))
                : candidates.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            guestsState.guests.isEmpty ? 'No guests yet. Add guests first, or add this person directly.' : 'No matching guests, or everyone matching is already in your wedding party.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: candidates.length,
                        itemBuilder: (_, i) {
                          final g = candidates[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: _Avatar(name: _fullName(g), radius: 18),
                            title: Text(_fullName(g), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            subtitle: Text((g['email'] as String?) ?? (g['phone'] as String?) ?? 'No contact info', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                            onTap: () => _pickRoleAndLink(context, g),
                          );
                        },
                      ),
          ),
        ]),
      ),
    );
  }

  void _pickRoleAndLink(BuildContext context, Map<String, dynamic> guest) {
    String role = 'Bridesmaid';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => StatefulBuilder(builder: (sheetContext, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Add ${_fullName(guest)} as...', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: role,
              decoration: InputDecoration(filled: true, fillColor: AppTheme.udoCardFill, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
              items: const [
                DropdownMenuItem(value: 'Maid of honour', child: Text('Maid of honour')),
                DropdownMenuItem(value: 'Best man', child: Text('Best man')),
                DropdownMenuItem(value: 'Bridesmaid', child: Text('Bridesmaid')),
                DropdownMenuItem(value: 'Groomsman', child: Text('Groomsman')),
                DropdownMenuItem(value: 'Parent', child: Text('Parent')),
                DropdownMenuItem(value: 'Flower girl', child: Text('Flower girl')),
                DropdownMenuItem(value: 'Ring bearer', child: Text('Ring bearer')),
              ],
              onChanged: (v) => setSheetState(() => role = v ?? role),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await widget.onLink(guest['id'] as int, role);
                if (sheetContext.mounted) Navigator.pop(sheetContext);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
              child: const Text('Add to wedding party'),
            ),
          ]))),
        );
      }),
    );
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }
}

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

  InputDecoration _dec() => InputDecoration(filled: true, fillColor: AppTheme.udoCardFill, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14));

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
    TextField(controller: ctrl, keyboardType: type, decoration: InputDecoration(hintText: hint ?? label, hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14), filled: true, fillColor: AppTheme.udoCardFill, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.udoGreen, width: 1.5)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
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
