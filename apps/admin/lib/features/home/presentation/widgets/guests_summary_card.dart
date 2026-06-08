import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/home_stats_model.dart';
import '../sheets/guest_overview_sheet.dart';

class GuestsSummaryCard extends StatelessWidget {
  const GuestsSummaryCard({
    super.key,
    required this.overview,
  });
  final GuestOverview overview;

  @override
  Widget build(BuildContext context) {
    final invited = overview.total - overview.notInvited;
    final rsvpRate = invited > 0
        ? ((overview.confirmed + overview.declined) / invited * 100).round()
        : 0;

    return GestureDetector(
      onTap: () => GuestOverviewSheet.show(context, overview),
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
                        'GUESTS',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$invited invited',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey700,
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
            Row(
              children: [
                _StatChip(
                  label: 'Confirmed',
                  value: '${overview.confirmed}',
                  color: AppColors.teal,
                  bgColor: AppColors.tealLight,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: "Can't make it",
                  value: '${overview.declined}',
                  color: AppColors.dustyRose,
                  bgColor: AppColors.blushLight,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Pending',
                  value: '${overview.pending}',
                  color: AppColors.grey500,
                  bgColor: AppColors.grey100,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Response rate bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Response rate',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.grey500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$rsvpRate%',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: AppSpacing.borderFull,
                  child: LinearProgressIndicator(
                    value: rsvpRate / 100,
                    minHeight: 6,
                    backgroundColor: AppColors.grey100,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.teal),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppSpacing.borderLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
