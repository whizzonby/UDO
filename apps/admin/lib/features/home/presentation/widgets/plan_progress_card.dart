import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/home_stats_model.dart';
import 'section_card.dart';

class PlanProgressCard extends StatelessWidget {
  const PlanProgressCard({
    super.key,
    required this.plan,
    required this.onTap,
  });

  final PlanProgress plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pct = plan.totalTasks == 0
        ? 0.0
        : plan.completedTasks / plan.totalTasks;
    final pctInt = (pct * 100).round();

    return SectionCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            icon: Icons.checklist_rounded,
            iconColor: AppColors.forestGreen,
            title: 'Planning Progress',
            subtitle: '${plan.completedTasks} of ${plan.totalTasks} tasks done',
            trailing: ViewAllButton(onTap: onTap),
          ),
          const SizedBox(height: 16),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: AppSpacing.borderFull,
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 10,
                    backgroundColor: AppColors.grey100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pctInt < 30
                          ? AppColors.dustyRose
                          : pctInt < 70
                              ? const Color(0xFFF59E0B)
                              : AppColors.forestGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$pctInt%',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),

          if (plan.overdueTasks > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.06),
                borderRadius: AppSpacing.borderMd,
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 14, color: AppColors.error),
                  const SizedBox(width: 6),
                  Text(
                    '${plan.overdueTasks} task${plan.overdueTasks == 1 ? '' : 's'} overdue',
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.error),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Recent tasks
          ...plan.recentTasks.take(4).map((task) => _TaskRow(task: task)),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task});
  final RecentTask task;

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.isComplete;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isComplete
                  ? AppColors.forestGreen
                  : Colors.transparent,
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
                ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.title,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: task.isComplete ? AppColors.grey400 : AppColors.grey700,
                decoration:
                    task.isComplete ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (task.dueDate != null && !task.isComplete)
            Text(
              isOverdue
                  ? 'Overdue'
                  : DateFormat('d MMM').format(task.dueDate!),
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isOverdue ? AppColors.error : AppColors.grey400,
              ),
            ),
        ],
      ),
    );
  }
}
