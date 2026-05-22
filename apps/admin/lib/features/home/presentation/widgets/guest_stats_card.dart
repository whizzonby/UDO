import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/home_stats_model.dart';
import 'section_card.dart';

class GuestStatsCard extends StatelessWidget {
  const GuestStatsCard({
    super.key,
    required this.overview,
    required this.onTap,
  });

  final GuestOverview overview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final invited = overview.total - overview.notInvited;

    return SectionCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            icon: Icons.people_outline_rounded,
            iconColor: AppColors.teal,
            title: 'Guests',
            subtitle: '$invited invited of ${overview.total} total',
            trailing: ViewAllButton(onTap: onTap),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              // Donut chart
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(100, 100),
                      painter: _DonutChartPainter(
                        confirmed: overview.confirmed,
                        pending: overview.pending,
                        declined: overview.declined,
                        notInvited: overview.notInvited,
                        total: overview.total,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${overview.confirmed}',
                          style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                            height: 1,
                          ),
                        ),
                        Text(
                          'confirmed',
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            color: AppColors.grey500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendItem(
                      color: AppColors.teal,
                      label: 'Confirmed',
                      count: overview.confirmed,
                    ),
                    const SizedBox(height: 10),
                    _LegendItem(
                      color: const Color(0xFFF59E0B),
                      label: 'Awaiting',
                      count: overview.pending,
                    ),
                    const SizedBox(height: 10),
                    _LegendItem(
                      color: AppColors.dustyRose,
                      label: 'Declined',
                      count: overview.declined,
                    ),
                    const SizedBox(height: 10),
                    _LegendItem(
                      color: AppColors.grey300,
                      label: 'Not invited',
                      count: overview.notInvited,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 16, color: AppColors.teal),
                const SizedBox(width: 8),
                Text(
                  '${overview.confirmed} of ${overview.total} guests confirmed',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.teal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.grey600),
          ),
        ),
        Text(
          '$count',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.grey700,
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({
    required this.confirmed,
    required this.pending,
    required this.declined,
    required this.notInvited,
    required this.total,
  });

  final int confirmed;
  final int pending;
  final int declined;
  final int notInvited;
  final int total;

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    const strokeWidth = 13.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    const gapAngle = 0.04;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final segments = [
      (confirmed / total, AppColors.teal),
      (pending / total, const Color(0xFFF59E0B)),
      (declined / total, AppColors.dustyRose),
      (notInvited / total, AppColors.grey200),
    ];

    double startAngle = -math.pi / 2;

    for (final (fraction, color) in segments) {
      if (fraction == 0) continue;
      final sweep = fraction * (math.pi * 2) - gapAngle;
      paint.color = color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += fraction * (math.pi * 2);
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter old) =>
      old.confirmed != confirmed ||
      old.pending != pending ||
      old.declined != declined ||
      old.notInvited != notInvited;
}
