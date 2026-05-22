import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/plan_models.dart';
import '../providers/plan_provider.dart';
import '../sheets/task_form_sheet.dart';

enum TaskFilter { all, pending, overdue, complete }

class TasksTab extends StatefulWidget {
  const TasksTab({super.key, required this.data});
  final PlanData data;

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab>
    with AutomaticKeepAliveClientMixin {
  TaskFilter _filter = TaskFilter.all;

  @override
  bool get wantKeepAlive => true;

  List<PlanTask> get _filtered {
    final now = DateTime.now();
    return switch (_filter) {
      TaskFilter.all => widget.data.tasks,
      TaskFilter.pending => widget.data.tasks
          .where((t) =>
              !t.isComplete &&
              (t.dueDate == null || !t.dueDate!.isBefore(now)))
          .toList(),
      TaskFilter.overdue => widget.data.tasks
          .where((t) =>
              !t.isComplete &&
              t.dueDate != null &&
              t.dueDate!.isBefore(now))
          .toList(),
      TaskFilter.complete =>
        widget.data.tasks.where((t) => t.isComplete).toList(),
    };
  }

  int _countFor(TaskFilter f) {
    final now = DateTime.now();
    return switch (f) {
      TaskFilter.all => widget.data.tasks.length,
      TaskFilter.pending => widget.data.tasks
          .where((t) =>
              !t.isComplete &&
              (t.dueDate == null || !t.dueDate!.isBefore(now)))
          .length,
      TaskFilter.overdue => widget.data.tasks
          .where((t) =>
              !t.isComplete &&
              t.dueDate != null &&
              t.dueDate!.isBefore(now))
          .length,
      TaskFilter.complete =>
        widget.data.tasks.where((t) => t.isComplete).length,
    };
  }

  // Group filtered tasks by category
  Map<String, List<PlanTask>> get _grouped {
    final map = <String, List<PlanTask>>{};
    for (final t in _filtered) {
      map.putIfAbsent(t.category, () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: TaskFilter.values.map((f) {
                final count = _countFor(f);
                final isSelected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('${_filterLabel(f)} $count'),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _filter = f),
                    backgroundColor: AppColors.grey100,
                    selectedColor: AppColors.hotPink.withValues(alpha: 0.1),
                    checkmarkColor: AppColors.hotPink,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.hotPink
                          : Colors.transparent,
                    ),
                    labelStyle: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.hotPink
                          : AppColors.grey600,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: AppColors.grey200),
          // Task list
          Expanded(
            child: _filtered.isEmpty
                ? _EmptyTasks(filter: _filter)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: _grouped.length,
                    itemBuilder: (context, idx) {
                      final category =
                          _grouped.keys.elementAt(idx);
                      final tasks = _grouped[category]!;
                      return _CategoryGroup(
                        category: category,
                        tasks: tasks,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => TaskFormSheet.show(context),
        backgroundColor: AppColors.hotPink,
        elevation: 2,
        child: const Icon(Icons.add_rounded, color: AppColors.white),
      ),
    );
  }

  String _filterLabel(TaskFilter f) => switch (f) {
        TaskFilter.all => 'All',
        TaskFilter.pending => 'Pending',
        TaskFilter.overdue => 'Overdue',
        TaskFilter.complete => 'Done',
      };
}

class _CategoryGroup extends ConsumerWidget {
  const _CategoryGroup({required this.category, required this.tasks});
  final String category;
  final List<PlanTask> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = tasks.where((t) => t.isComplete).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category,
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.grey500),
                ),
              ),
              Text(
                '$done/${tasks.length}',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
        ...tasks.map((task) => _TaskRow(task: task)),
      ],
    );
  }
}

class _TaskRow extends ConsumerWidget {
  const _TaskRow({required this.task});
  final PlanTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isOverdue = !task.isComplete &&
        task.dueDate != null &&
        task.dueDate!.isBefore(now);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: AppSpacing.borderMd,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 20),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete task?'),
            content: Text('Remove "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) =>
          ref.read(planNotifierProvider.notifier).deleteTask(task.id),
      child: GestureDetector(
        onTap: () => TaskFormSheet.show(context, task: task),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: task.isComplete
                ? AppColors.grey100
                : AppColors.white,
            borderRadius: AppSpacing.borderMd,
            border: Border.all(
              color: isOverdue
                  ? AppColors.error.withValues(alpha: 0.3)
                  : AppColors.grey200,
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: () => ref
                    .read(planNotifierProvider.notifier)
                    .toggleTask(task.id),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isComplete
                        ? AppColors.teal
                        : Colors.transparent,
                    border: Border.all(
                      color: task.isComplete
                          ? AppColors.teal
                          : AppColors.grey300,
                      width: 1.5,
                    ),
                  ),
                  child: task.isComplete
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: AppColors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Title + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: task.isComplete
                            ? AppColors.grey400
                            : AppColors.grey700,
                        decoration: task.isComplete
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            isOverdue
                                ? Icons.warning_amber_rounded
                                : Icons.calendar_today_outlined,
                            size: 11,
                            color: isOverdue
                                ? AppColors.error
                                : AppColors.grey400,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isOverdue
                                ? 'Overdue · ${DateFormat('d MMM').format(task.dueDate!)}'
                                : DateFormat('d MMM').format(task.dueDate!),
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isOverdue
                                  ? AppColors.error
                                  : AppColors.grey400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Priority dot
              if (!task.isComplete)
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _priorityColor(task.priority),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(TaskPriority p) => switch (p) {
        TaskPriority.high => AppColors.error,
        TaskPriority.medium => const Color(0xFFF59E0B),
        TaskPriority.low => AppColors.grey300,
      };
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks({required this.filter});
  final TaskFilter filter;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (filter) {
      TaskFilter.overdue => (
          Icons.check_circle_outline_rounded,
          'No overdue tasks'
        ),
      TaskFilter.complete => (
          Icons.assignment_outlined,
          'No completed tasks yet'
        ),
      _ => (Icons.checklist_rounded, 'No tasks here'),
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: AppColors.grey300),
          const SizedBox(height: 12),
          Text(label, style: AppTypography.headingSmall),
          const SizedBox(height: 4),
          Text('Tap + to add a task',
              style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
