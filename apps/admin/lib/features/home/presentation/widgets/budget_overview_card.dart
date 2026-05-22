import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/home_stats_model.dart';
import 'section_card.dart';

class BudgetOverviewCard extends StatelessWidget {
  const BudgetOverviewCard({
    super.key,
    required this.budget,
    required this.onTap,
  });

  final BudgetOverview budget;
  final VoidCallback onTap;

  static const _categoryColors = [
    AppColors.teal,
    AppColors.hotPink,
    AppColors.forestGreen,
    AppColors.dustyRose,
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
  ];

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    );
    final spentPct = budget.total > 0 ? budget.spent / budget.total : 0.0;
    final remaining = budget.total - budget.spent;
    final spentPctInt = (spentPct * 100).round();

    return SectionCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.dustyRose,
            title: 'Budget',
            subtitle: '${currencyFmt.format(budget.spent)} spent of ${currencyFmt.format(budget.total)}',
            trailing: ViewAllButton(onTap: onTap),
          ),
          const SizedBox(height: 16),

          // Amounts row
          Row(
            children: [
              Expanded(
                child: _AmountBlock(
                  label: 'Spent',
                  amount: currencyFmt.format(budget.spent),
                  color: AppColors.dustyRose,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.grey200),
              Expanded(
                child: _AmountBlock(
                  label: 'Remaining',
                  amount: currencyFmt.format(remaining < 0 ? 0 : remaining),
                  color: remaining < 0
                      ? AppColors.error
                      : AppColors.forestGreen,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.grey200),
              Expanded(
                child: _AmountBlock(
                  label: 'Budget',
                  amount: currencyFmt.format(budget.total),
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: AppSpacing.borderFull,
                  child: LinearProgressIndicator(
                    value: spentPct.clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: AppColors.grey100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      spentPctInt > 90
                          ? AppColors.error
                          : spentPctInt > 70
                              ? const Color(0xFFF59E0B)
                              : AppColors.dustyRose,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$spentPctInt%',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Category breakdown
          Text('Breakdown', style: AppTypography.labelMedium.copyWith(color: AppColors.grey500)),
          const SizedBox(height: 10),
          ...budget.categories.take(4).toList().asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value;
            final catPct = cat.allocated > 0 ? cat.spent / cat.allocated : 0.0;
            final catColor = _categoryColors[i % _categoryColors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: catColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cat.name,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.grey600),
                        ),
                      ),
                      Text(
                        '${currencyFmt.format(cat.spent)} / ${currencyFmt.format(cat.allocated)}',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: AppSpacing.borderFull,
                    child: LinearProgressIndicator(
                      value: catPct.clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: AppColors.grey100,
                      valueColor: AlwaysStoppedAnimation<Color>(catColor),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AmountBlock extends StatelessWidget {
  const _AmountBlock({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          amount,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            color: AppColors.grey500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
