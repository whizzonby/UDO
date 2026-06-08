import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/seating_models.dart';
import '../providers/seating_provider.dart';

class SeatingTab extends ConsumerWidget {
  const SeatingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(seatingNotifierProvider);

    return state.map(
      loading: (_) => const Center(
        child: CircularProgressIndicator(
            color: AppColors.hotPink, strokeWidth: 2),
      ),
      error: (e) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text('Could not load seating',
                style: AppTypography.headingSmall),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  ref.read(seatingNotifierProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      loaded: (s) => _SeatingContent(data: s.data),
    );
  }
}

class _SeatingContent extends ConsumerWidget {
  const _SeatingContent({required this.data});
  final SeatingData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _StatsBar(stats: data.stats),
        Expanded(
          child: data.tables.isEmpty
              ? _EmptyState(onAdd: () => _showAddTableSheet(context, ref))
              : RefreshIndicator(
                  color: AppColors.hotPink,
                  onRefresh: () =>
                      ref.read(seatingNotifierProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: data.tables.length,
                    itemBuilder: (_, i) => _TableCard(
                      table: data.tables[i],
                      unassignedGuests: data.unassignedGuests,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  void _showAddTableSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTableSheet(notifier: ref.read(seatingNotifierProvider.notifier)),
    );
  }
}

// ─── Stats bar ────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.stats});
  final SeatingStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border:
            Border(bottom: BorderSide(color: AppColors.grey200, width: 1)),
      ),
      child: Row(
        children: [
          _StatChip(
            label: 'Attending',
            value: stats.totalAttending.toString(),
            color: AppColors.teal,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Seated',
            value: stats.assigned.toString(),
            color: AppColors.hotPink,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Unseated',
            value: stats.unassigned.toString(),
            color: stats.unassigned > 0
                ? const Color(0xFFF4A261)
                : AppColors.grey400,
          ),
          const Spacer(),
          Consumer(
            builder: (_, ref, __) => GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _AddTableSheet(
                  notifier: ref.read(seatingNotifierProvider.notifier),
                ),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.pinkGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        size: 16, color: AppColors.white),
                    const SizedBox(width: 4),
                    Text('Add Table',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color)),
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.grey500)),
      ],
    );
  }
}

// ─── Table card ───────────────────────────────────────────────────────────────

class _TableCard extends ConsumerWidget {
  const _TableCard({
    required this.table,
    required this.unassignedGuests,
  });
  final SeatingTable table;
  final List<UnassignedGuest> unassignedGuests;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occupancy = table.assignments.length;
    final isFull = occupancy >= table.capacity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _parseColor(table.color),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(table.name,
                      style: AppTypography.headingSmall
                          .copyWith(fontSize: 14)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isFull
                        ? AppColors.hotPink.withValues(alpha: 0.1)
                        : AppColors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$occupancy / ${table.capacity}',
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isFull
                            ? AppColors.hotPink
                            : AppColors.teal),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      size: 18, color: AppColors.grey500),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 16, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Delete table'),
                        ])),
                  ],
                  onSelected: (v) async {
                    if (v == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete table?'),
                          content: Text(
                              'All ${table.assignments.length} assignment(s) will be removed.'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Delete',
                                    style: TextStyle(
                                        color: Colors.redAccent))),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref
                            .read(seatingNotifierProvider.notifier)
                            .deleteTable(table.id);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          // Guest chips
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...table.assignments.map((a) => _GuestChip(
                      assignment: a,
                      tableId: table.id,
                    )),
                if (!isFull)
                  GestureDetector(
                    onTap: () => _showAssignSheet(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.hotPink, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_add_alt_1_rounded,
                              size: 13, color: AppColors.hotPink),
                          const SizedBox(width: 4),
                          Text('Add guest',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.hotPink)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (table.section != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(table.section!,
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: AppColors.grey500)),
            ),
        ],
      ),
    );
  }

  void _showAssignSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AssignGuestSheet(
        table: table,
        unassignedGuests: unassignedGuests,
        notifier: ref.read(seatingNotifierProvider.notifier),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.hotPink;
    }
  }
}

class _GuestChip extends ConsumerWidget {
  const _GuestChip({required this.assignment, required this.tableId});
  final TableAssignment assignment;
  final String tableId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onLongPress: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Remove guest?'),
            content: Text(
                'Remove ${assignment.guestFirstName} ${assignment.guestLastName} from this table?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Remove',
                      style: TextStyle(color: Colors.redAccent))),
            ],
          ),
        );
        if (confirm == true) {
          await ref.read(seatingNotifierProvider.notifier).unassignGuest(
                tableId: tableId,
                guestId: assignment.guestId,
              );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Text(
          '${assignment.guestFirstName} ${assignment.guestLastName}',
          style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.grey700),
        ),
      ),
    );
  }
}

// ─── Add table sheet ──────────────────────────────────────────────────────────

class _AddTableSheet extends StatefulWidget {
  const _AddTableSheet({required this.notifier});
  final SeatingNotifier notifier;

  @override
  State<_AddTableSheet> createState() => _AddTableSheetState();
}

class _AddTableSheetState extends State<_AddTableSheet> {
  final _nameCtrl = TextEditingController();
  int _capacity = 8;
  String _shape = 'round';
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Add Table', style: AppTypography.headingMedium),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Table name',
                hintText: 'e.g. Table 1, Bridal Table',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Capacity',
                          style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _CounterButton(
                            icon: Icons.remove_rounded,
                            onTap: () => setState(
                                () => _capacity = (_capacity - 1).clamp(1, 50)),
                          ),
                          const SizedBox(width: 12),
                          Text('$_capacity',
                              style: AppTypography.headingSmall),
                          const SizedBox(width: 12),
                          _CounterButton(
                            icon: Icons.add_rounded,
                            onTap: () => setState(
                                () => _capacity = (_capacity + 1).clamp(1, 50)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shape',
                          style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _shape,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.grey300),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'round', child: Text('Round')),
                          DropdownMenuItem(
                              value: 'rectangular',
                              child: Text('Rectangular')),
                          DropdownMenuItem(
                              value: 'oval', child: Text('Oval')),
                        ],
                        onChanged: (v) => setState(() => _shape = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.hotPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Add Table'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      await widget.notifier.createTable(
        name: name,
        capacity: _capacity,
        shape: _shape,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _saving = false);
    }
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.grey300),
        ),
        child: Icon(icon, size: 16, color: AppColors.grey700),
      ),
    );
  }
}

// ─── Assign guest sheet ───────────────────────────────────────────────────────

class _AssignGuestSheet extends StatefulWidget {
  const _AssignGuestSheet({
    required this.table,
    required this.unassignedGuests,
    required this.notifier,
  });
  final SeatingTable table;
  final List<UnassignedGuest> unassignedGuests;
  final SeatingNotifier notifier;

  @override
  State<_AssignGuestSheet> createState() => _AssignGuestSheetState();
}

class _AssignGuestSheetState extends State<_AssignGuestSheet> {
  String _query = '';
  String? _assigning;

  @override
  Widget build(BuildContext context) {
    final filtered = widget.unassignedGuests
        .where((g) =>
            '${g.firstName} ${g.lastName}'
                .toLowerCase()
                .contains(_query.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assign to ${widget.table.name}',
                    style: AppTypography.headingMedium),
                const SizedBox(height: 4),
                Text(
                  '${widget.unassignedGuests.length} unseated guest(s)',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.grey500),
                ),
                const SizedBox(height: 12),
                TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search guests…',
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 18, color: AppColors.grey500),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.grey300),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      _query.isEmpty
                          ? 'All attending guests are seated!'
                          : 'No guests match "$_query"',
                      style: GoogleFonts.dmSans(
                          fontSize: 14, color: AppColors.grey500),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: AppColors.grey200, height: 1),
                    itemBuilder: (_, i) {
                      final g = filtered[i];
                      final isAssigning = _assigning == g.id;
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              AppColors.hotPink.withValues(alpha: 0.1),
                          child: Text(
                            g.firstName[0].toUpperCase(),
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.hotPink),
                          ),
                        ),
                        title: Text('${g.firstName} ${g.lastName}',
                            style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w500)),
                        trailing: isAssigning
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: AppColors.hotPink,
                                    strokeWidth: 2))
                            : const Icon(Icons.add_circle_outline_rounded,
                                color: AppColors.hotPink),
                        onTap: isAssigning ? null : () => _assign(g),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _assign(UnassignedGuest guest) async {
    setState(() => _assigning = guest.id);
    try {
      await widget.notifier.assignGuest(
        tableId: widget.table.id,
        guestId: guest.id,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _assigning = null);
    }
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.hotPink.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.table_restaurant_rounded,
                  size: 34, color: AppColors.hotPink),
            ),
            const SizedBox(height: 16),
            Text('No tables yet', style: AppTypography.headingMedium),
            const SizedBox(height: 6),
            Text(
              'Add tables and assign your attending guests to seats.',
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: AppColors.grey500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add First Table'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.hotPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
