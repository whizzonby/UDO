import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/home_stats_model.dart';

class PlanSheet extends StatelessWidget {
  const PlanSheet({super.key, required this.plan});

  final PlanProgress plan;

  static Future<void> show(BuildContext context, PlanProgress plan) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, __) => PlanSheet(plan: plan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pct = plan.totalTasks == 0
        ? 0.0
        : plan.completedTasks / plan.totalTasks;
    final pctInt = (pct * 100).round();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: AppSpacing.borderFull,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Planning Progress', style: AppTypography.headingLarge),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.grey400),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${plan.completedTasks} of ${plan.totalTasks} tasks complete',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: 20),

                  // Overall progress
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.05),
                      borderRadius: AppSpacing.borderLg,
                      border: Border.all(
                          color: AppColors.forestGreen.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '$pctInt%',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: AppColors.forestGreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Overall completion',
                                      style: AppTypography.labelLarge),
                                  Text(
                                    '${plan.completedTasks} done · ${plan.totalTasks - plan.completedTasks} remaining',
                                    style: AppTypography.caption,
                                  ),
                                  if (plan.overdueTasks > 0)
                                    Text(
                                      '${plan.overdueTasks} overdue',
                                      style: AppTypography.caption
                                          .copyWith(color: AppColors.error),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: AppSpacing.borderFull,
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 8,
                            backgroundColor: AppColors.grey100,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.forestGreen),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Categories
                  Text('By Category',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.grey500)),
                  const SizedBox(height: 12),
                  ...plan.categories.map((cat) => _CategoryRow(cat: cat)),

                  const SizedBox(height: 24),

                  // All tasks
                  Text('All Tasks',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.grey500)),
                  const SizedBox(height: 12),
                  ...plan.recentTasks.map((task) => _FullTaskRow(task: task)),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.checklist_rounded, size: 18),
                      label: const Text('Go to Plan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.cat});
  final PlanCategory cat;

  @override
  Widget build(BuildContext context) {
    final pct = cat.total == 0 ? 0.0 : cat.completed / cat.total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(cat.name,
                    style: AppTypography.labelMedium),
              ),
              Text(
                '${cat.completed}/${cat.total}',
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: AppSpacing.borderFull,
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.grey100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.forestGreen),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullTaskRow extends StatelessWidget {
  const _FullTaskRow({required this.task});
  final RecentTask task;

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.isComplete;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isComplete ? AppColors.forestGreen : Colors.transparent,
              border: Border.all(
                color: task.isComplete
                    ? AppColors.forestGreen
                    : isOverdue
                        ? AppColors.error
                        : AppColors.grey300,
                width: 1.5,
              ),
            ),
            child: task.isComplete
                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
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
                    decoration:
                        task.isComplete ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (task.category != null || task.dueDate != null)
                  Row(
                    children: [
                      if (task.category != null)
                        Text(
                          task.category!,
                          style: AppTypography.caption,
                        ),
                      if (task.category != null && task.dueDate != null)
                        Text(' · ',
                            style: AppTypography.caption),
                      if (task.dueDate != null)
                        Text(
                          isOverdue
                              ? 'Overdue'
                              : 'Due ${DateFormat('d MMM').format(task.dueDate!)}',
                          style: AppTypography.caption.copyWith(
                            color: isOverdue ? AppColors.error : null,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
