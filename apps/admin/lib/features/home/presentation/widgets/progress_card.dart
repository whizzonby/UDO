import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/home_stats_model.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, required this.plan});
  final PlanProgress plan;

  @override
  Widget build(BuildContext context) {
    final pct = plan.totalTasks == 0
        ? 0.0
        : plan.completedTasks / plan.totalTasks;
    final pctInt = (pct * 100).round();

    return GestureDetector(
      onTap: () => _ProgressModal.show(context, plan),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppSpacing.borderXl,
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROGRESS',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "You're $pctInt% there",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        value: pct,
                        strokeWidth: 6,
                        backgroundColor: AppColors.grey100,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.hotPink),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '$pctInt%',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (plan.categories.isNotEmpty) ...[
              ...plan.categories.take(3).map((cat) {
                final catPct = cat.total == 0
                    ? 0.0
                    : cat.completed / cat.total;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cat.name,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.grey600,
                              ),
                            ),
                          ),
                          Text(
                            '${(catPct * 100).round()}%',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: AppSpacing.borderFull,
                        child: LinearProgressIndicator(
                          value: catPct,
                          minHeight: 6,
                          backgroundColor: AppColors.grey100,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.hotPink),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              _DefaultCategories(pct: pct),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'See full breakdown',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.hotPink,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 10, color: AppColors.hotPink),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Fallback when API hasn't returned category data yet
class _DefaultCategories extends StatelessWidget {
  const _DefaultCategories({required this.pct});
  final double pct;

  static const _cats = [
    ('Venue & Logistics', 0.85),
    ('Guest Management', 0.70),
    ('Vendors', 0.60),
    ('Styling & Decor', 0.45),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _cats.map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      c.$1,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                  Text(
                    '${(c.$2 * 100).round()}%',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: AppSpacing.borderFull,
                child: LinearProgressIndicator(
                  value: c.$2,
                  minHeight: 6,
                  backgroundColor: AppColors.grey100,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.hotPink),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ProgressModal extends StatelessWidget {
  const _ProgressModal({required this.plan});
  final PlanProgress plan;

  static void show(BuildContext context, PlanProgress plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProgressModal(plan: plan),
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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: AppSpacing.borderFull,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.checklist_rounded,
                    color: AppColors.hotPink, size: 22),
                const SizedBox(width: 8),
                Text(
                  'PROGRESS',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.hotPink,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "You're $pctInt% there",
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${plan.completedTasks} of ${plan.totalTasks} tasks complete',
              style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.grey500),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 20),
            Text(
              'By category',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 16),
            if (plan.categories.isNotEmpty)
              ...plan.categories.map((cat) => _CategoryRow(cat: cat))
            else
              ...const [
                ('Venue & Logistics', 0.85),
                ('Guest Management', 0.70),
                ('Vendors', 0.60),
                ('Styling & Decor', 0.45),
                ('Invitations & Comms', 0.55),
              ].map((c) => _SimpleCategoryRow(name: c.$1, pct: c.$2)),
            if (plan.overdueTasks > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.06),
                  borderRadius: AppSpacing.borderLg,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text(
                      '${plan.overdueTasks} overdue task${plan.overdueTasks == 1 ? '' : 's'} need attention',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  cat.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey700,
                  ),
                ),
              ),
              Text(
                '${cat.completed}/${cat.total}',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(pct * 100).round()}%',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: AppSpacing.borderFull,
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.grey100,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.hotPink),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleCategoryRow extends StatelessWidget {
  const _SimpleCategoryRow({required this.name, required this.pct});
  final String name;
  final double pct;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey700,
                  ),
                ),
              ),
              Text(
                '${(pct * 100).round()}%',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: AppSpacing.borderFull,
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.grey100,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.hotPink),
            ),
          ),
        ],
      ),
    );
  }
}
