import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/home_stats_model.dart';

class BudgetSheet extends StatelessWidget {
  const BudgetSheet({super.key, required this.budget});

  final BudgetOverview budget;

  static const _categoryColors = [
    AppColors.teal,
    AppColors.hotPink,
    AppColors.forestGreen,
    AppColors.dustyRose,
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
  ];

  static Future<void> show(BuildContext context, BudgetOverview budget) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, __) => BudgetSheet(budget: budget),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    );
    final spentPct = budget.total > 0 ? budget.spent / budget.total : 0.0;
    final remaining = budget.total - budget.spent;
    final unallocated = budget.total - budget.allocated;

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
                      Text('Budget Overview', style: AppTypography.headingLarge),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.grey400),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Hero numbers
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBE5B73), Color(0xFFC1637A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppSpacing.borderXl,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _HeroStat(
                                label: 'Total Budget',
                                value: fmt.format(budget.total),
                                textColor: Colors.white,
                              ),
                            ),
                            Container(width: 1, height: 48, color: Colors.white24),
                            Expanded(
                              child: _HeroStat(
                                label: 'Spent',
                                value: fmt.format(budget.spent),
                                textColor: Colors.white,
                              ),
                            ),
                            Container(width: 1, height: 48, color: Colors.white24),
                            Expanded(
                              child: _HeroStat(
                                label: 'Remaining',
                                value: fmt.format(remaining < 0 ? 0 : remaining),
                                textColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: AppSpacing.borderFull,
                          child: LinearProgressIndicator(
                            value: spentPct.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: Colors.white24,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${(spentPct * 100).round()}% used',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (unallocated > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.06),
                        borderRadius: AppSpacing.borderMd,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 16, color: AppColors.info),
                          const SizedBox(width: 8),
                          Text(
                            '${fmt.format(unallocated)} unallocated',
                            style: AppTypography.labelMedium
                                .copyWith(color: AppColors.info),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Category breakdown
                  Text('Category Breakdown',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.grey500)),
                  const SizedBox(height: 12),

                  ...budget.categories.asMap().entries.map((entry) {
                    final i = entry.key;
                    final cat = entry.value;
                    final catColor =
                        _categoryColors[i % _categoryColors.length];
                    final catPct = cat.allocated > 0
                        ? cat.spent / cat.allocated
                        : 0.0;
                    final catRemaining = cat.allocated - cat.spent;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: catColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(cat.name,
                                    style: AppTypography.labelMedium),
                              ),
                              Text(
                                '${fmt.format(cat.spent)} / ${fmt.format(cat.allocated)}',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: AppSpacing.borderFull,
                            child: LinearProgressIndicator(
                              value: catPct.clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: AppColors.grey100,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(catColor),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            catRemaining >= 0
                                ? '${fmt.format(catRemaining)} remaining'
                                : '${fmt.format(-catRemaining)} over budget',
                            style: AppTypography.caption.copyWith(
                              color: catRemaining < 0
                                  ? AppColors.error
                                  : AppColors.grey400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                      label: const Text('Go to Budget'),
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

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.textColor,
  });
  final String label;
  final String value;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            color: textColor.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
