import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/home_stats_model.dart';
import '../sheets/budget_sheet.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({super.key, required this.budget});
  final BudgetOverview budget;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    );
    final pct = budget.total > 0
        ? (budget.spent / budget.total).clamp(0.0, 1.0)
        : 0.0;
    final remaining = (budget.total - budget.spent).clamp(0.0, double.infinity);
    final topCat = budget.categories.isNotEmpty ? budget.categories.first : null;

    return GestureDetector(
      onTap: () => BudgetSheet.show(context, budget),
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
                        'BUDGET',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: fmt.format(budget.spent),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.grey700,
                              ),
                            ),
                            TextSpan(
                              text: ' of ${fmt.format(budget.total)}',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.grey400, size: 22),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: AppSpacing.borderFull,
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: AppColors.grey100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  pct > 0.9 ? AppColors.error : AppColors.hotPink,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _BudgetStat(
                    label: 'Remaining',
                    value: fmt.format(remaining),
                    color: remaining < budget.total * 0.1
                        ? AppColors.error
                        : AppColors.forestGreen,
                  ),
                ),
                if (topCat != null) ...[
                  Container(
                      width: 1, height: 32, color: AppColors.grey200),
                  Expanded(
                    child: _BudgetStat(
                      label: 'Top: ${topCat.name}',
                      value: fmt.format(topCat.spent),
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetStat extends StatelessWidget {
  const _BudgetStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.grey500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
