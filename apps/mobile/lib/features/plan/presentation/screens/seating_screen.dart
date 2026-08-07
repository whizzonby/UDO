import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../guests/presentation/providers/guests_provider.dart';
import '../providers/seating_provider.dart';

const _kRuleLabels = <String, String>{
  'keep_couples': 'Keep couples together',
  'avoid_do_not_seat': 'Do not seat together',
  'seat_elderly_together': 'Seat elderly together',
  'balance_groups': 'Balance groups at each table',
  'randomise': 'Randomise remaining guests',
};

class SeatingScreen extends ConsumerStatefulWidget {
  const SeatingScreen({super.key});
  @override
  ConsumerState<SeatingScreen> createState() => _SeatingScreenState();
}

class _SeatingScreenState extends ConsumerState<SeatingScreen> {
  bool _floorView = false;
  String _search = '';
  String? _statusFilter;
  final Map<String, bool> _rules = {
    'keep_couples': true,
    'avoid_do_not_seat': true,
    'seat_elderly_together': true,
    'balance_groups': true,
    'randomise': false,
  };

  String _tableStatus(Map<String, dynamic> table) {
    final capacity = (table['capacity'] as num?)?.toInt() ?? 0;
    final assigned = (table['assigned_count'] as num?)?.toInt() ?? 0;
    if (capacity == 0) return 'empty';
    if (assigned >= capacity) return 'full';
    if (assigned == 0) return 'empty';
    return 'partial';
  }

  Future<void> _generateSuggestions() async {
    final result =
        await ref.read(seatingPlannerProvider.notifier).autoAssign(_rules);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result == null
          ? "Couldn't generate seating. Try again."
          : 'Seated ${result.seated} of ${result.totalUnassigned} unassigned guests.'),
    ));
  }

  Future<void> _addTable() async {
    setState(() {
      _search = '';
      _statusFilter = null;
      _floorView = false;
    });
    final ok = await ref.read(seatingPlannerProvider.notifier).addTable();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Table added.' : "Couldn't add a table. Try again."),
    ));
  }

  void _openPairingPicker(List<Map<String, dynamic>> guests, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PairGuestsSheet(
        guests: guests,
        title: type == 'couple' ? 'Pair as a couple' : 'Keep these two apart',
        onPicked: (a, b) => ref
            .read(seatingPlannerProvider.notifier)
            .addPairing(guestId: a, relatedGuestId: b, type: type),
      ),
    );
  }

  void _openSeatSheet(
      Map<String, dynamic> table, List<Map<String, dynamic>> guests) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _SeatAssignmentSheet(table: table, guests: guests),
    );
  }

  void _openGuestFlagsSheet(Map<String, dynamic> guest) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _GuestFlagsSheet(guest: guest),
    );
  }

  void _showDetectedConflicts(
      List<Map<String, dynamic>> tables, List<Map<String, dynamic>> pairings) {
    final conflicts = _detectSeatingConflicts(tables, pairings);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _DetectedConflictsSheet(
        conflicts: conflicts,
        onResolve: (conflict) {
          Navigator.pop(context);
          final table = tables.firstWhere(
            (item) => _valueId(item['id']) == conflict.tableId,
            orElse: () => <String, dynamic>{},
          );
          if (table.isNotEmpty) {
            _openSeatSheet(table, ref.read(guestsProvider).guests);
          }
        },
        onResolveAll: conflicts.isEmpty
            ? null
            : () async {
                Navigator.pop(context);
                await _generateSuggestions();
              },
      ),
    );
  }

  void _showSeatingSuggestions(
    List<Map<String, dynamic>> tables,
    Map<String, dynamic> summary,
    List<Map<String, dynamic>> pairings,
    List<Map<String, dynamic>> guests,
  ) {
    final unassignedGuests = (summary['unassigned_guests'] is List)
        ? (summary['unassigned_guests'] as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];
    final suggestions = _buildSeatingSuggestions(
      tables: tables,
      unassignedGuests: unassignedGuests,
      allGuests: guests,
      pairings: pairings,
      rules: _rules,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _SeatingSuggestionsSheet(
        suggestions: suggestions,
        pendingCount: unassignedGuests.length,
        onAcceptAll: () async {
          Navigator.pop(context);
          await _generateSuggestions();
        },
        onReviewOneByOne: suggestions.isEmpty
            ? null
            : () {
                Navigator.pop(context);
                final table = tables.firstWhere(
                  (item) => _valueId(item['id']) == suggestions.first.tableId,
                  orElse: () => <String, dynamic>{},
                );
                if (table.isNotEmpty) {
                  _openSeatSheet(table, ref.read(guestsProvider).guests);
                }
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seating = ref.watch(seatingPlannerProvider);
    final notifier = ref.read(seatingPlannerProvider.notifier);
    final guests = ref.watch(guestsProvider).guests;
    final summary = seating.summary;
    final unassignedGuests = (summary['unassigned_guests'] is List)
        ? (summary['unassigned_guests'] as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    var visibleTables = seating.tables.where((t) {
      if (_search.trim().isNotEmpty &&
          !('${t['name'] ?? ''}'
              .toLowerCase()
              .contains(_search.trim().toLowerCase()))) {
        return false;
      }
      if (_statusFilter != null && _tableStatus(t) != _statusFilter) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.udoBackground,
      appBar: AppBar(title: const Text('Seating')),
      body: seating.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.udoGreen))
          : RefreshIndicator(
              onRefresh: notifier.refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(children: [
                    Expanded(
                        child: _SeatStat('Tables',
                            '${summary['table_count'] ?? seating.tables.length}')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _SeatStat(
                            'Assigned', '${summary['assigned_count'] ?? 0}')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _SeatStat(
                            'Open seats', '${summary['open_seats'] ?? 0}')),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: _SeatStat('Couples together',
                            '${summary['couples_seated_together'] ?? 0}')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _SeatStat('Dietary needs',
                            '${summary['dietary_needs_count'] ?? 0}')),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _SeatStat('Accessibility',
                            '${summary['accessibility_count'] ?? 0}')),
                  ]),
                  const SizedBox(height: 12),
                  _ModalInfoRow('Attending guests',
                      '${summary['attending_guest_count'] ?? 0}'),
                  _ModalInfoRow('Still to place',
                      '${summary['unassigned_attending_count'] ?? 0}'),
                  if (seating.error != null) ...[
                    const SizedBox(height: 8),
                    Text(seating.error!,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.udoCrimson)),
                  ],
                  const SizedBox(height: 16),
                  _RulesCard(
                    rules: _rules,
                    pairings: seating.pairings,
                    isSaving: seating.isSaving,
                    onRuleChanged: (k, v) => setState(() => _rules[k] = v),
                    onGenerate: () => _showSeatingSuggestions(
                      seating.tables,
                      seating.summary,
                      seating.pairings,
                      guests,
                    ),
                    onAddPairing: (type) => _openPairingPicker(guests, type),
                    onRemovePairing: notifier.removePairing,
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: seating.isSaving ? null : _addTable,
                        icon: seating.isSaving
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.add, size: 16),
                        label: const Text('Add table'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.udoGreen,
                            foregroundColor: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                        onPressed: notifier.refresh,
                        icon: const Icon(Icons.refresh),
                        color: AppTheme.udoGreen,
                        tooltip: 'Refresh seating'),
                  ]),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showDetectedConflicts(
                        seating.tables, seating.pairings),
                    icon: const Icon(Icons.warning_amber_outlined, size: 16),
                    label: const Text('Detect conflicts'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      foregroundColor: AppTheme.udoGreen,
                      side: const BorderSide(color: AppTheme.udoGreen),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (unassignedGuests.isNotEmpty) ...[
                    const Text('Unassigned guests',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final guest in unassignedGuests)
                          GestureDetector(
                            onTap: () => _openGuestFlagsSheet(guest),
                            child: Chip(
                              avatar: guest['is_elderly'] == true ||
                                      guest['accessibility_needs'] == true
                                  ? const Icon(Icons.info_outline,
                                      size: 14, color: AppTheme.udoGreen)
                                  : null,
                              label: Text('${guest['name'] ?? 'Guest'}',
                                  style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppTheme.udoCardFill,
                              side: BorderSide.none,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (seating.tables.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: AppTheme.udoCrimson.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color:
                                  AppTheme.udoCrimson.withValues(alpha: 0.2))),
                      child: const Text(
                          'No tables yet. Add the first table, then tap it to assign guests.',
                          style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: AppTheme.udoCrimson)),
                    )
                  else ...[
                    Row(children: [
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _search = v),
                          decoration: const InputDecoration(
                            hintText: 'Search tables',
                            prefixIcon: Icon(Icons.search, size: 18),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () =>
                            setState(() => _floorView = !_floorView),
                        icon: Icon(_floorView
                            ? Icons.view_list_outlined
                            : Icons.grid_view_outlined),
                        color: AppTheme.udoGreen,
                        tooltip: _floorView ? 'List view' : 'Floor plan view',
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, children: [
                      for (final entry in const {
                        'full': 'Full',
                        'partial': 'Partial',
                        'empty': 'Empty'
                      }.entries)
                        FilterChip(
                          label: Text(entry.value,
                              style: const TextStyle(fontSize: 12)),
                          selected: _statusFilter == entry.key,
                          onSelected: (sel) => setState(
                              () => _statusFilter = sel ? entry.key : null),
                          selectedColor:
                              AppTheme.udoGreen.withValues(alpha: 0.15),
                        ),
                    ]),
                    const SizedBox(height: 12),
                    if (_floorView)
                      _SeatingFloorPlan(
                          tables: visibleTables,
                          onTableTap: (t) => _openSeatSheet(t, guests))
                    else
                      for (final table in visibleTables)
                        GestureDetector(
                          onTap: () => _openSeatSheet(table, guests),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF9F7F3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.udoBorder)),
                            child: Row(children: [
                              const Icon(Icons.table_bar_outlined,
                                  color: AppTheme.udoGreen, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Text('${table['name'] ?? 'Table'}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600))),
                              Text(
                                  '${table['assigned_count'] ?? 0}/${table['capacity'] ?? 0}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.udoTextSecondary)),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right,
                                  size: 18, color: AppTheme.udoTextSecondary),
                            ]),
                          ),
                        ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _RulesCard extends StatelessWidget {
  final Map<String, bool> rules;
  final List<Map<String, dynamic>> pairings;
  final bool isSaving;
  final void Function(String key, bool value) onRuleChanged;
  final VoidCallback onGenerate;
  final void Function(String type) onAddPairing;
  final Future<bool> Function(int id) onRemovePairing;

  const _RulesCard({
    required this.rules,
    required this.pairings,
    required this.isSaving,
    required this.onRuleChanged,
    required this.onGenerate,
    required this.onAddPairing,
    required this.onRemovePairing,
  });

  @override
  Widget build(BuildContext context) {
    final doNotSeatPairs =
        pairings.where((p) => p['type'] == 'do_not_seat').toList();
    final couplePairs = pairings.where((p) => p['type'] == 'couple').toList();

    String pairLabel(Map<String, dynamic> p) {
      final a = p['guest'] as Map<String, dynamic>?;
      final b = p['related_guest'] as Map<String, dynamic>?;
      final aName = '${a?['first_name'] ?? ''} ${a?['last_name'] ?? ''}'.trim();
      final bName = '${b?['first_name'] ?? ''} ${b?['last_name'] ?? ''}'.trim();
      return '$aName & $bName';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.udoBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.rule_outlined, color: AppTheme.udoGreen, size: 18),
          SizedBox(width: 8),
          Text('Rules',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        for (final key in const [
          'keep_couples',
          'seat_elderly_together',
          'balance_groups',
          'randomise'
        ])
          _RuleToggle(
              label: _kRuleLabels[key]!,
              value: rules[key] ?? false,
              onChanged: (v) => onRuleChanged(key, v)),
        _RuleToggle(
            label: _kRuleLabels['avoid_do_not_seat']!,
            value: rules['avoid_do_not_seat'] ?? false,
            onChanged: (v) => onRuleChanged('avoid_do_not_seat', v)),
        if (doNotSeatPairs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 6),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final p in doNotSeatPairs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Expanded(
                        child: Text(pairLabel(p),
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.udoTextSecondary))),
                    GestureDetector(
                        onTap: () => onRemovePairing(p['id'] as int),
                        child: const Icon(Icons.close,
                            size: 14, color: AppTheme.udoTextSecondary)),
                  ]),
                ),
            ]),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: GestureDetector(
            onTap: () => onAddPairing('do_not_seat'),
            child: const Text('+ Add a pair to keep apart',
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.udoGreen,
                    fontWeight: FontWeight.w500)),
          ),
        ),
        if (couplePairs.isNotEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 6),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Couples',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.udoTextSecondary,
                      fontWeight: FontWeight.w600)),
              for (final p in couplePairs)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(children: [
                    Expanded(
                        child: Text(pairLabel(p),
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.udoTextSecondary))),
                    GestureDetector(
                        onTap: () => onRemovePairing(p['id'] as int),
                        child: const Icon(Icons.close,
                            size: 14, color: AppTheme.udoTextSecondary)),
                  ]),
                ),
            ]),
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => onAddPairing('couple'),
            child: const Text('+ Add a couple',
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.udoGreen,
                    fontWeight: FontWeight.w500)),
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: isSaving ? null : onGenerate,
          icon: isSaving
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.auto_fix_high_outlined, size: 18),
          label: const Text('Generate Seating Suggestions'),
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: AppTheme.udoGreen,
              foregroundColor: Colors.white),
        ),
      ]),
    );
  }
}

class _SeatingConflict {
  final int tableId;
  final String title;
  final String detail;
  final String severity;
  final IconData icon;

  const _SeatingConflict({
    required this.tableId,
    required this.title,
    required this.detail,
    required this.severity,
    required this.icon,
  });
}

List<_SeatingConflict> _detectSeatingConflicts(
  List<Map<String, dynamic>> tables,
  List<Map<String, dynamic>> pairings,
) {
  final conflicts = <_SeatingConflict>[];
  final tableByGuest = <int, Map<String, dynamic>>{};

  for (final table in tables) {
    final tableId = _valueId(table['id']) ?? 0;
    final tableName = table['name']?.toString() ?? 'Table';
    final seats = (table['seats'] as List?)?.whereType<Map>().toList() ?? [];
    final seatedGuests = <Map<String, dynamic>>[];

    for (final seat in seats) {
      final guest = seat['guest'];
      if (guest is! Map) continue;
      final mapped = Map<String, dynamic>.from(guest);
      seatedGuests.add(mapped);
      final id = _valueId(mapped['id']);
      if (id != null) tableByGuest[id] = table;
    }

    final allergyGuests = seatedGuests.where((guest) {
      return (guest['allergies']?.toString().trim().isNotEmpty ?? false) ||
          (guest['dietary_note']?.toString().trim().isNotEmpty ?? false);
    }).toList();
    if (allergyGuests.isNotEmpty) {
      conflicts.add(_SeatingConflict(
        tableId: tableId,
        title: 'Dietary conflict at $tableName',
        detail:
            '${_guestNames(allergyGuests)} ${allergyGuests.length == 1 ? 'has' : 'have'} dietary or allergy needs seated here.',
        severity: 'High',
        icon: Icons.warning_amber_outlined,
      ));
    }

    final accessibilityGuests = seatedGuests
        .where((guest) => guest['accessibility_needs'] == true)
        .toList();
    if (accessibilityGuests.isNotEmpty) {
      conflicts.add(_SeatingConflict(
        tableId: tableId,
        title: 'Accessibility concern at $tableName',
        detail:
            '${_guestNames(accessibilityGuests)} ${accessibilityGuests.length == 1 ? 'needs' : 'need'} wheelchair or accessibility-aware seating.',
        severity: 'High',
        icon: Icons.accessible_forward_outlined,
      ));
    }
  }

  for (final pairing
      in pairings.where((item) => item['type'] == 'do_not_seat')) {
    final aId = _valueId(pairing['guest_id']);
    final bId = _valueId(pairing['related_guest_id']);
    if (aId == null || bId == null) continue;
    final aTable = tableByGuest[aId];
    final bTable = tableByGuest[bId];
    if (aTable == null ||
        bTable == null ||
        _valueId(aTable['id']) != _valueId(bTable['id'])) {
      continue;
    }
    conflicts.add(_SeatingConflict(
      tableId: _valueId(aTable['id']) ?? 0,
      title: 'Relationship tension at ${aTable['name'] ?? 'Table'}',
      detail:
          '${_pairingGuestName(pairing, 'guest')} and ${_pairingGuestName(pairing, 'related_guest')} requested separation.',
      severity: 'Medium',
      icon: Icons.groups_outlined,
    ));
  }

  return conflicts;
}

int? _valueId(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

String _guestNames(List<Map<String, dynamic>> guests) {
  final names = guests
      .map((guest) =>
          '${guest['first_name'] ?? ''} ${guest['last_name'] ?? ''}'.trim())
      .where((name) => name.isNotEmpty)
      .toList();
  if (names.isEmpty) return 'Guest';
  if (names.length == 1) return names.first;
  if (names.length == 2) return '${names.first} and ${names.last}';
  return '${names.first} and ${names.length - 1} others';
}

String _pairingGuestName(Map<String, dynamic> pairing, String key) {
  final guest = pairing[key];
  if (guest is Map) {
    final name =
        '${guest['first_name'] ?? ''} ${guest['last_name'] ?? ''}'.trim();
    if (name.isNotEmpty) return name;
    if (guest['name'] != null) return guest['name'].toString();
  }
  return 'Guest';
}

class _DetectedConflictsSheet extends StatelessWidget {
  final List<_SeatingConflict> conflicts;
  final ValueChanged<_SeatingConflict> onResolve;
  final VoidCallback? onResolveAll;

  const _DetectedConflictsSheet({
    required this.conflicts,
    required this.onResolve,
    required this.onResolveAll,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Expanded(
                    child: Text('Detected Conflicts',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ]),
                const Divider(height: 22),
                if (conflicts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Text('No seating conflicts detected.',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.udoTextSecondary)),
                  )
                else
                  for (final conflict in conflicts)
                    _ConflictRow(conflict: conflict, onResolve: onResolve),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onResolveAll,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF5A4B58),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Resolve All Conflicts'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50)),
                  child: const Text('Close'),
                ),
              ]),
        ),
      );
}

class _ConflictRow extends StatelessWidget {
  final _SeatingConflict conflict;
  final ValueChanged<_SeatingConflict> onResolve;

  const _ConflictRow({required this.conflict, required this.onResolve});

  @override
  Widget build(BuildContext context) {
    final color =
        conflict.severity == 'High' ? AppTheme.udoCrimson : Colors.orange;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.udoCardFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.udoBorder),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(conflict.icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text(conflict.title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(conflict.severity,
                    style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 4),
            Text(conflict.detail,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.udoTextSecondary)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => onResolve(conflict),
              child: const Text('Resolve ->',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.udoGreen)),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _SeatingSuggestion {
  final int guestId;
  final int tableId;
  final String guestName;
  final String tableName;
  final String tableLabel;
  final String reason;
  final int score;

  const _SeatingSuggestion({
    required this.guestId,
    required this.tableId,
    required this.guestName,
    required this.tableName,
    required this.tableLabel,
    required this.reason,
    required this.score,
  });
}

List<_SeatingSuggestion> _buildSeatingSuggestions({
  required List<Map<String, dynamic>> tables,
  required List<Map<String, dynamic>> unassignedGuests,
  required List<Map<String, dynamic>> allGuests,
  required List<Map<String, dynamic>> pairings,
  required Map<String, bool> rules,
}) {
  final guestById = {
    for (final guest in allGuests)
      if (_valueId(guest['id']) != null) _valueId(guest['id'])!: guest,
  };
  final suggestions = <_SeatingSuggestion>[];
  final openTables = tables.where((table) => _openSeatCount(table) > 0).toList()
    ..sort((a, b) => _openSeatCount(b).compareTo(_openSeatCount(a)));

  for (final summaryGuest in unassignedGuests) {
    final guestId = _valueId(summaryGuest['id']);
    if (guestId == null || openTables.isEmpty) continue;
    final guest = <String, dynamic>{
      ...summaryGuest,
      ...?guestById[guestId],
    };
    final rankedTables = openTables
        .map((table) => _rankSuggestionTable(
              guest: guest,
              table: table,
              pairings: pairings,
              rules: rules,
            ))
        .where((rank) => rank != null)
        .cast<_SeatingSuggestion>()
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    if (rankedTables.isNotEmpty) suggestions.add(rankedTables.first);
  }

  suggestions.sort((a, b) => b.score.compareTo(a.score));
  return suggestions.take(8).toList();
}

_SeatingSuggestion? _rankSuggestionTable({
  required Map<String, dynamic> guest,
  required Map<String, dynamic> table,
  required List<Map<String, dynamic>> pairings,
  required Map<String, bool> rules,
}) {
  final guestId = _valueId(guest['id']);
  final tableId = _valueId(table['id']) ?? 0;
  if (guestId == null) return null;
  if ((rules['avoid_do_not_seat'] ?? true) &&
      _wouldBreakDoNotSeatRule(guestId, table, pairings)) {
    return null;
  }

  var score = _openSeatCount(table) * 3;
  var reason = 'Available seats match current seating needs';
  final seatedGuests = _seatedGuests(table);
  final group = guest['guest_group']?.toString().trim();

  if ((rules['balance_groups'] ?? true) &&
      group != null &&
      group.isNotEmpty &&
      seatedGuests.any((item) => item['guest_group'] == group)) {
    score += 45;
    reason = 'Related to $group group';
  }
  if (guest['accessibility_needs'] == true) {
    score += 30;
    reason = 'Accessible placement with open seats';
  }
  if (guest['is_elderly'] == true) {
    score += seatedGuests.any((item) => item['is_elderly'] == true) ? 35 : 20;
    reason = seatedGuests.any((item) => item['is_elderly'] == true)
        ? 'Keeps elderly guests seated near each other'
        : 'Comfort-aware table with available seats';
  }
  if (_hasDietaryNeed(guest)) {
    score += 18;
    reason = 'Catering notes can be planned for this table';
  }
  if (guest['vip_flag'] == true) {
    score += 12;
    reason = 'Priority guest with a strong available placement';
  }

  return _SeatingSuggestion(
    guestId: guestId,
    tableId: tableId,
    guestName: _guestDisplayName(guest),
    tableName: table['name']?.toString() ?? 'Table',
    tableLabel: _tableLabel(table),
    reason: reason,
    score: score,
  );
}

bool _wouldBreakDoNotSeatRule(
  int guestId,
  Map<String, dynamic> table,
  List<Map<String, dynamic>> pairings,
) {
  final seatedIds = _seatedGuests(table)
      .map((guest) => _valueId(guest['id']))
      .whereType<int>()
      .toSet();
  for (final pairing
      in pairings.where((item) => item['type'] == 'do_not_seat')) {
    final aId = _valueId(pairing['guest_id']);
    final bId = _valueId(pairing['related_guest_id']);
    if ((aId == guestId && seatedIds.contains(bId)) ||
        (bId == guestId && seatedIds.contains(aId))) {
      return true;
    }
  }
  return false;
}

List<Map<String, dynamic>> _seatedGuests(Map<String, dynamic> table) {
  final seats = (table['seats'] as List?)?.whereType<Map>().toList() ?? [];
  return seats
      .map((seat) => seat['guest'])
      .whereType<Map>()
      .map((guest) => Map<String, dynamic>.from(guest))
      .toList();
}

int _openSeatCount(Map<String, dynamic> table) {
  final seats = (table['seats'] as List?)?.whereType<Map>().toList() ?? [];
  if (seats.isNotEmpty) {
    return seats.where((seat) => seat['guest'] == null).length;
  }
  final capacity = (table['capacity'] as num?)?.toInt() ?? 0;
  final assigned = (table['assigned_count'] as num?)?.toInt() ?? 0;
  return (capacity - assigned).clamp(0, capacity);
}

String _tableLabel(Map<String, dynamic> table) {
  final assigned = (table['assigned_count'] as num?)?.toInt() ?? 0;
  final capacity = (table['capacity'] as num?)?.toInt() ?? 0;
  final groupNames = _seatedGuests(table)
      .map((guest) => guest['guest_group']?.toString().trim())
      .whereType<String>()
      .where((group) => group.isNotEmpty)
      .toSet()
      .take(2)
      .join(', ');
  final suffix = groupNames.isEmpty ? 'Mixed' : groupNames;
  return '$assigned/$capacity - $suffix';
}

bool _hasDietaryNeed(Map<String, dynamic> guest) {
  return (guest['allergies']?.toString().trim().isNotEmpty ?? false) ||
      (guest['dietary_note']?.toString().trim().isNotEmpty ?? false) ||
      (guest['meal_preference']?.toString().trim().isNotEmpty ?? false);
}

String _guestDisplayName(Map<String, dynamic> guest) {
  final explicit = guest['name']?.toString().trim();
  if (explicit != null && explicit.isNotEmpty) return explicit;
  final name =
      '${guest['first_name'] ?? ''} ${guest['last_name'] ?? ''}'.trim();
  return name.isEmpty ? 'Guest' : name;
}

class _SeatingSuggestionsSheet extends StatelessWidget {
  final List<_SeatingSuggestion> suggestions;
  final int pendingCount;
  final Future<void> Function() onAcceptAll;
  final VoidCallback? onReviewOneByOne;

  const _SeatingSuggestionsSheet({
    required this.suggestions,
    required this.pendingCount,
    required this.onAcceptAll,
    required this.onReviewOneByOne,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.udoBorder,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  const Expanded(
                    child: Text('Seating Suggestions',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ]),
                const Divider(height: 22),
                if (suggestions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Text('No seating suggestions are available yet.',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.udoTextSecondary)),
                  )
                else
                  for (final suggestion in suggestions)
                    _SuggestionRow(suggestion: suggestion),
                const SizedBox(height: 4),
                Text('$pendingCount pending guests',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text(
                    'Generated from guest groups, needs, rules, and open seats',
                    style: TextStyle(
                        fontSize: 11, color: AppTheme.udoTextSecondary)),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: suggestions.isEmpty ? null : onAcceptAll,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF5A4B58),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Accept All Suggestions'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: onReviewOneByOne,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF7FA1CE),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Review One by One'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50)),
                  child: const Text('Dismiss'),
                ),
              ]),
        ),
      );
}

class _SuggestionRow extends StatelessWidget {
  final _SeatingSuggestion suggestion;

  const _SuggestionRow({required this.suggestion});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.udoCardFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.udoBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(suggestion.guestName,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(
              'Unassigned -> ${suggestion.tableName} - ${suggestion.tableLabel}',
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.udoTextSecondary)),
          const SizedBox(height: 4),
          Text(suggestion.reason,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.udoTextSecondary)),
        ]),
      );
}

class _RuleToggle extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;
  const _RuleToggle(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppTheme.udoGreen),
        ]),
      );
}

class _PairGuestsSheet extends StatefulWidget {
  final List<Map<String, dynamic>> guests;
  final String title;
  final Future<bool> Function(int guestId, int relatedGuestId) onPicked;
  const _PairGuestsSheet(
      {required this.guests, required this.title, required this.onPicked});

  @override
  State<_PairGuestsSheet> createState() => _PairGuestsSheetState();
}

class _PairGuestsSheetState extends State<_PairGuestsSheet> {
  int? _first;
  int? _second;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _GuestDropdown(
                  label: 'First guest',
                  guests: widget.guests,
                  value: _first,
                  onChanged: (v) => setState(() => _first = v)),
              const SizedBox(height: 12),
              _GuestDropdown(
                  label: 'Second guest',
                  guests: widget.guests,
                  value: _second,
                  onChanged: (v) => setState(() => _second = v)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    (_first != null && _second != null && _first != _second)
                        ? () async {
                            await widget.onPicked(_first!, _second!);
                            if (context.mounted) Navigator.pop(context);
                          }
                        : null,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: AppTheme.udoGreen,
                    foregroundColor: Colors.white),
                child: const Text('Save pairing'),
              ),
            ]),
      ),
    );
  }
}

class _GuestDropdown extends StatelessWidget {
  final String label;
  final List<Map<String, dynamic>> guests;
  final int? value;
  final void Function(int?) onChanged;
  const _GuestDropdown(
      {required this.label,
      required this.guests,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
        initialValue: value,
        decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: AppTheme.udoCardFill,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none)),
        items: guests.map((g) {
          final name =
              '${g['first_name'] ?? ''} ${g['last_name'] ?? ''}'.trim();
          return DropdownMenuItem(
              value: g['id'] as int,
              child: Text(name.isEmpty ? 'Guest' : name,
                  overflow: TextOverflow.ellipsis));
        }).toList(),
        onChanged: onChanged,
      );
}

String _initials(Map<String, dynamic> guest) {
  final first =
      guest['first_name']?.toString() ?? guest['name']?.toString() ?? '';
  final last = guest['last_name']?.toString() ?? '';
  final letters = [
    if (first.trim().isNotEmpty) first.trim()[0],
    if (last.trim().isNotEmpty) last.trim()[0],
  ].join();
  return letters.isEmpty ? '?' : letters.toUpperCase();
}

class _SeatAssignmentSheet extends ConsumerWidget {
  final Map<String, dynamic> table;
  final List<Map<String, dynamic>> guests;
  const _SeatAssignmentSheet({required this.table, required this.guests});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seats = (table['seats'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final notifier = ref.read(seatingPlannerProvider.notifier);
    final tableId = table['id'] as int;
    final capacity = (table['capacity'] as num?)?.toInt() ?? seats.length;
    final seated = seats.where((seat) => seat['guest'] != null).toList();
    final assignedCount =
        (table['assigned_count'] as num?)?.toInt() ?? seated.length;
    final openSeats = seats.where((seat) => seat['guest'] == null).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text('${table['name'] ?? 'Table'}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ]),
                const SizedBox(height: 12),
                _ModalInfoRow('Capacity', '$assignedCount / $capacity'),
                LinearProgressIndicator(
                  value: capacity == 0
                      ? 0
                      : (assignedCount / capacity).clamp(0, 1).toDouble(),
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(999),
                  backgroundColor: AppTheme.udoBorder,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                const Text('Seated guests',
                    style: TextStyle(
                        fontSize: 11, color: AppTheme.udoTextSecondary)),
                const SizedBox(height: 8),
                if (seated.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No guests seated at this table yet.',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.udoTextSecondary)),
                  )
                else
                  for (final seat in seated)
                    _SeatedGuestRow(
                      seat: seat,
                      onRemove: () async {
                        await notifier.clearSeat(
                            tableId: tableId, seatId: seat['id'] as int);
                      },
                    ),
                if (openSeats.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.udoBorder),
                    ),
                    child: Text(
                      '+ Add ${openSeats.length} more guest${openSeats.length == 1 ? '' : 's'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.udoTextSecondary),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: openSeats.isEmpty
                      ? null
                      : () => _openAssignGuestToTableSheet(
                            context: context,
                            tableId: tableId,
                            nextSeatNumber:
                                openSeats.first['seat_number'] as int,
                            guests: guests,
                            notifier: notifier,
                          ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF5A4B58),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Guest to Table'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _openEditTableSheet(
                    context: context,
                    table: table,
                    notifier: notifier,
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF7EA2CF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Edit Table Name'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: seated.isEmpty
                      ? null
                      : () async {
                          final ok = await notifier.clearTable(table);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(ok
                                  ? 'Table cleared.'
                                  : "Couldn't clear this table.")));
                        },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    foregroundColor: AppTheme.udoTextPrimary,
                  ),
                  child: const Text('Clear Table'),
                ),
              ]),
        ),
      ),
    );
  }
}

class _GuestPickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> guests;
  final void Function(int guestId) onPicked;
  const _GuestPickerSheet({required this.guests, required this.onPicked});
  @override
  State<_GuestPickerSheet> createState() => _GuestPickerSheetState();
}

class _GuestPickerSheetState extends State<_GuestPickerSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.guests.where((g) {
      if (_search.trim().isEmpty) return true;
      final name =
          '${g['first_name'] ?? ''} ${g['last_name'] ?? ''}'.toLowerCase();
      return name.contains(_search.trim().toLowerCase());
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select a guest',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: const InputDecoration(
                    hintText: 'Search guests',
                    prefixIcon: Icon(Icons.search, size: 18),
                    isDense: true),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5),
                child: filtered.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('No guests found.',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.udoTextSecondary)))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final g = filtered[i];
                          final name =
                              '${g['first_name'] ?? ''} ${g['last_name'] ?? ''}'
                                  .trim();
                          return ListTile(
                            title: Text(name.isEmpty ? 'Guest' : name),
                            onTap: () {
                              widget.onPicked(g['id'] as int);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ]),
      ),
    );
  }
}

class _SeatedGuestRow extends StatelessWidget {
  final Map<String, dynamic> seat;
  final Future<void> Function() onRemove;
  const _SeatedGuestRow({required this.seat, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final guest = seat['guest'] as Map<String, dynamic>? ?? {};
    final name =
        '${guest['first_name'] ?? ''} ${guest['last_name'] ?? ''}'.trim();
    final meal = (guest['meal_preference'] ?? guest['dietary_note'] ?? '')
        .toString()
        .trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppTheme.udoGreen.withValues(alpha: 0.10),
          child: Text(_initials(guest),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.udoGreen)),
        ),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name.isEmpty ? 'Guest' : name,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          if (meal.isNotEmpty)
            Text(meal,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.udoTextSecondary)),
        ])),
        TextButton(onPressed: onRemove, child: const Text('Remove')),
      ]),
    );
  }
}

void _openAssignGuestToTableSheet({
  required BuildContext context,
  required int tableId,
  required int nextSeatNumber,
  required List<Map<String, dynamic>> guests,
  required SeatingPlannerNotifier notifier,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _GuestPickerSheet(
      guests: guests,
      onPicked: (guestId) async {
        final ok = await notifier.assignSeat(
            tableId: tableId, seatNumber: nextSeatNumber, guestId: guestId);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ok
                ? 'Guest added to table.'
                : "Couldn't add this guest to the table.")));
      },
    ),
  );
}

void _openEditTableSheet({
  required BuildContext context,
  required Map<String, dynamic> table,
  required SeatingPlannerNotifier notifier,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _EditTableSheet(table: table, notifier: notifier),
  );
}

class _EditTableSheet extends StatefulWidget {
  final Map<String, dynamic> table;
  final SeatingPlannerNotifier notifier;
  const _EditTableSheet({required this.table, required this.notifier});

  @override
  State<_EditTableSheet> createState() => _EditTableSheetState();
}

class _EditTableSheetState extends State<_EditTableSheet> {
  late final _name =
      TextEditingController(text: widget.table['name']?.toString() ?? '');
  late final _capacity = TextEditingController(
      text: ((widget.table['capacity'] as num?)?.toInt() ?? 8).toString());
  bool _saving = false;
  String? _error;

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                const Expanded(
                  child: Text('Edit table',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ]),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Table name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _capacity,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacity'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.udoCrimson)),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: AppTheme.udoGreen,
                    foregroundColor: Colors.white),
                child: Text(_saving ? 'Saving...' : 'Save table'),
              ),
            ]),
          ),
        ),
      );

  Future<void> _save() async {
    final name = _name.text.trim();
    final capacity = int.tryParse(_capacity.text.trim());
    if (name.isEmpty || capacity == null || capacity < 1) {
      setState(() => _error = 'Add a table name and valid capacity.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await widget.notifier.updateTable(
      tableId: widget.table['id'] as int,
      name: name,
      capacity: capacity,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save this table.";
      });
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _capacity.dispose();
    super.dispose();
  }
}

class _GuestFlagsSheet extends ConsumerWidget {
  final Map<String, dynamic> guest;
  const _GuestFlagsSheet({required this.guest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(seatingPlannerProvider.notifier);
    final guestId = guest['id'] as int;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${guest['name'] ?? 'Guest'}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Elderly', style: TextStyle(fontSize: 14)),
                value: guest['is_elderly'] == true,
                activeThumbColor: AppTheme.udoGreen,
                onChanged: (v) => notifier.setGuestFlags(guestId, isElderly: v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Accessibility needs',
                    style: TextStyle(fontSize: 14)),
                value: guest['accessibility_needs'] == true,
                activeThumbColor: AppTheme.udoGreen,
                onChanged: (v) =>
                    notifier.setGuestFlags(guestId, accessibilityNeeds: v),
              ),
            ]),
      ),
    );
  }
}

class _SeatingFloorPlan extends StatelessWidget {
  final List<Map<String, dynamic>> tables;
  final void Function(Map<String, dynamic> table) onTableTap;
  const _SeatingFloorPlan({required this.tables, required this.onTableTap});

  @override
  Widget build(BuildContext context) {
    if (tables.isEmpty) {
      return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
              child: Text('No tables match this filter.',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.udoTextSecondary))));
    }

    const areaSize = 320.0;
    const markerSize = 64.0;
    return Container(
      height: areaSize,
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppTheme.udoCardFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.udoBorder)),
      child: Stack(children: [
        for (var i = 0; i < tables.length; i++)
          Builder(builder: (context) {
            final table = tables[i];
            final rawX = (table['pos_x'] as num?)?.toDouble();
            final rawY = (table['pos_y'] as num?)?.toDouble();
            final columns = (areaSize / (markerSize + 16)).floor().clamp(1, 10);
            final fallbackX = 12.0 + (i % columns) * (markerSize + 16);
            final fallbackY = 12.0 + (i ~/ columns) * (markerSize + 16);
            final capacity = (table['capacity'] as num?)?.toInt() ?? 0;
            final assigned = (table['assigned_count'] as num?)?.toInt() ?? 0;
            final full = capacity > 0 && assigned >= capacity;

            return Positioned(
              left: (rawX ?? fallbackX).clamp(0.0, areaSize - markerSize),
              top: (rawY ?? fallbackY).clamp(0.0, areaSize - markerSize),
              child: GestureDetector(
                onTap: () => onTableTap(table),
                child: Container(
                  width: markerSize,
                  height: markerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: full
                        ? AppTheme.udoGreen.withValues(alpha: 0.15)
                        : Colors.white,
                    border: Border.all(
                        color: full ? AppTheme.udoGreen : AppTheme.udoBorder,
                        width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('${table['name'] ?? ''}',
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('$assigned/$capacity',
                        style: const TextStyle(
                            fontSize: 9, color: AppTheme.udoTextSecondary)),
                  ]),
                ),
              ),
            );
          }),
      ]),
    );
  }
}

class _ModalInfoRow extends StatelessWidget {
  final String label, value;
  const _ModalInfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          SizedBox(
              width: 140,
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

class _SeatStat extends StatelessWidget {
  final String label, value;
  const _SeatStat(this.label, this.value);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F7F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.udoBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.udoTextSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.udoGreen)),
        ]),
      );
}
