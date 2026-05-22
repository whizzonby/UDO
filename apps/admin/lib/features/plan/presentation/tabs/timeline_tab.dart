import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/plan_models.dart';
import '../providers/plan_provider.dart';

class TimelineTab extends StatefulWidget {
  const TimelineTab({super.key, required this.data});
  final PlanData data;

  @override
  State<TimelineTab> createState() => _TimelineTabState();
}

class _TimelineTabState extends State<TimelineTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Group events by month key
  Map<String, List<TimelineEvent>> get _grouped {
    final map = <String, List<TimelineEvent>>{};
    for (final e in widget.data.timeline) {
      final key = DateFormat('MMMM yyyy').format(e.date);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: widget.data.timeline.isEmpty
          ? const _EmptyTimeline()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: _grouped.length,
              itemBuilder: (context, idx) {
                final month = _grouped.keys.elementAt(idx);
                final events = _grouped[month]!;
                return _MonthGroup(month: month, events: events);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _AddTimelineEventSheet.show(context),
        backgroundColor: const Color(0xFF8B5CF6),
        elevation: 2,
        child: const Icon(Icons.add_rounded, color: AppColors.white),
      ),
    );
  }
}

class _MonthGroup extends StatelessWidget {
  const _MonthGroup({required this.month, required this.events});
  final String month;
  final List<TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
          child: Text(
            month,
            style: AppTypography.labelMedium
                .copyWith(color: AppColors.grey500),
          ),
        ),
        ...events.asMap().entries.map((entry) => _EventRow(
              event: entry.value,
              isLast: entry.key == events.length - 1,
            )),
      ],
    );
  }
}

class _EventRow extends ConsumerWidget {
  const _EventRow({required this.event, required this.isLast});
  final TimelineEvent event;
  final bool isLast;

  static const _categoryColors = {
    'Venue': AppColors.forestGreen,
    'Ceremony': AppColors.hotPink,
    'Vendor': AppColors.teal,
    'Attire': AppColors.dustyRose,
    'Admin': AppColors.grey400,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isPast = event.date.isBefore(now);
    final isToday = event.date.year == now.year &&
        event.date.month == now.month &&
        event.date.day == now.day;
    final color =
        _categoryColors[event.category] ?? const Color(0xFF8B5CF6);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline spine
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Container(
                  width: 36,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.hotPink.withValues(alpha: 0.08)
                        : isPast
                            ? AppColors.grey100
                            : AppColors.grey100,
                    borderRadius: AppSpacing.borderMd,
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('d').format(event.date),
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isToday
                              ? AppColors.hotPink
                              : isPast
                                  ? AppColors.grey400
                                  : AppColors.grey700,
                          height: 1,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(event.date).toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? AppColors.hotPink
                              : AppColors.grey400,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.grey200,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Event card
          Expanded(
            child: Dismissible(
              key: Key(event.id),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderMd,
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error, size: 20),
              ),
              confirmDismiss: (_) async => await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete event?'),
                  content: Text('Remove "${event.title}"?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Delete',
                            style: TextStyle(color: AppColors.error))),
                  ],
                ),
              ),
              onDismissed: (_) => ref
                  .read(planNotifierProvider.notifier)
                  .deleteTimelineEvent(event.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppSpacing.borderMd,
                  border: Border.all(
                    color: isToday
                        ? AppColors.hotPink.withValues(alpha: 0.3)
                        : AppColors.grey200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isPast
                                  ? AppColors.grey400
                                  : AppColors.grey700,
                            ),
                          ),
                        ),
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.hotPink
                                  .withValues(alpha: 0.1),
                              borderRadius: AppSpacing.borderFull,
                            ),
                            child: Text('Today',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.hotPink,
                                )),
                          ),
                      ],
                    ),
                    if (event.time != null || event.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (event.time != null) ...[
                            Icon(Icons.access_time_rounded,
                                size: 11, color: AppColors.grey400),
                            const SizedBox(width: 3),
                            Text(event.time!,
                                style: AppTypography.caption),
                            if (event.location != null)
                              const SizedBox(width: 10),
                          ],
                          if (event.location != null) ...[
                            Icon(Icons.location_on_outlined,
                                size: 11, color: AppColors.grey400),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                event.location!,
                                style: AppTypography.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (event.description != null) ...[
                      const SizedBox(height: 4),
                      Text(event.description!,
                          style: AppTypography.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: AppSpacing.borderFull,
                      ),
                      child: Text(
                        event.category ?? 'Other',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
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

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_month_outlined,
              size: 44, color: AppColors.grey300),
          const SizedBox(height: 12),
          Text('No timeline events', style: AppTypography.headingSmall),
          const SizedBox(height: 4),
          Text('Tap + to add a milestone', style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

// ─── Add timeline event sheet ─────────────────────────────────────────────────

class _AddTimelineEventSheet extends ConsumerStatefulWidget {
  const _AddTimelineEventSheet();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddTimelineEventSheet(),
    );
  }

  @override
  ConsumerState<_AddTimelineEventSheet> createState() =>
      _AddTimelineEventSheetState();
}

class _AddTimelineEventSheetState
    extends ConsumerState<_AddTimelineEventSheet> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  String? _time;
  String _category = 'Vendor';
  bool _saving = false;

  static const _categories = [
    'Venue', 'Ceremony', 'Vendor', 'Attire', 'Admin', 'Other'
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final event = TimelineEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      date: _date,
      time: _time,
      category: _category,
      location: _locationCtrl.text.trim().isEmpty
          ? null
          : _locationCtrl.text.trim(),
      description:
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );
    await ref
        .read(planNotifierProvider.notifier)
        .addTimelineEvent(event);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: AppSpacing.borderFull,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Add Timeline Event',
                        style: AppTypography.headingMedium),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.grey400),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'Event title',
                  child: TextFormField(
                    controller: _titleCtrl,
                    decoration:
                        _inputDec('e.g. Venue walkthrough'),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(height: 14),
                _Field(
                  label: 'Date',
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 365)),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 730)),
                      );
                      if (picked != null) {
                        setState(() => _date = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius: AppSpacing.borderMd,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 16, color: AppColors.grey400),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('d MMMM yyyy').format(_date),
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: AppColors.grey700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _Field(
                  label: 'Category',
                  child: DropdownButtonFormField<String>(
                    value: _category,
                    decoration: _inputDec(''),
                    items: _categories
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _category = v ?? _category),
                  ),
                ),
                const SizedBox(height: 14),
                _Field(
                  label: 'Location (optional)',
                  child: TextFormField(
                    controller: _locationCtrl,
                    decoration: _inputDec('e.g. Grand Palm Estate'),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: AppColors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppSpacing.borderMd,
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Add Event'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDec(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(
          fontSize: 14, color: AppColors.grey400),
      border: OutlineInputBorder(
        borderRadius: AppSpacing.borderMd,
        borderSide: const BorderSide(color: AppColors.grey300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderMd,
        borderSide: const BorderSide(color: AppColors.grey300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderMd,
        borderSide: const BorderSide(color: AppColors.hotPink),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.labelSmall
                .copyWith(color: AppColors.grey500)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
