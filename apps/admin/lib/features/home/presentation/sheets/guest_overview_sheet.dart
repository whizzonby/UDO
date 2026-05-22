import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/home_stats_model.dart';

class GuestOverviewSheet extends StatelessWidget {
  const GuestOverviewSheet({super.key, required this.overview});

  final GuestOverview overview;

  static Future<void> show(BuildContext context, GuestOverview overview) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, __) => GuestOverviewSheet(overview: overview),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invited = overview.total - overview.notInvited;
    final rsvpRate = invited > 0
        ? ((overview.confirmed + overview.declined) / invited * 100).round()
        : 0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
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
                      Text('Guests', style: AppTypography.headingLarge),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.grey400),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Summary row
                  Row(
                    children: [
                      _StatTile(
                        value: '${overview.total}',
                        label: 'Total',
                        color: AppColors.grey600,
                      ),
                      _StatTile(
                        value: '$invited',
                        label: 'Invited',
                        color: AppColors.forestGreen,
                      ),
                      _StatTile(
                        value: '$rsvpRate%',
                        label: 'RSVP rate',
                        color: AppColors.hotPink,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _RsvpStatusBar(overview: overview),
                  const SizedBox(height: 24),

                  // Status cards
                  _StatusDetailCard(
                    label: 'Confirmed',
                    count: overview.confirmed,
                    color: AppColors.teal,
                    icon: Icons.check_circle_outline_rounded,
                    description: 'These guests have confirmed attendance.',
                  ),
                  const SizedBox(height: 10),
                  _StatusDetailCard(
                    label: 'Awaiting response',
                    count: overview.pending,
                    color: const Color(0xFFF59E0B),
                    icon: Icons.schedule_outlined,
                    description: 'Invited but no response yet.',
                  ),
                  const SizedBox(height: 10),
                  _StatusDetailCard(
                    label: 'Declined',
                    count: overview.declined,
                    color: AppColors.dustyRose,
                    icon: Icons.cancel_outlined,
                    description: 'These guests cannot attend.',
                  ),
                  const SizedBox(height: 10),
                  _StatusDetailCard(
                    label: 'Not yet invited',
                    count: overview.notInvited,
                    color: AppColors.grey400,
                    icon: Icons.person_add_alt_outlined,
                    description: 'On your list but not yet sent an invitation.',
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.people_outline_rounded, size: 18),
                      label: const Text('Go to Guest List'),
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.color,
  });
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

class _RsvpStatusBar extends StatelessWidget {
  const _RsvpStatusBar({required this.overview});
  final GuestOverview overview;

  @override
  Widget build(BuildContext context) {
    final total = overview.total;
    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RSVP Breakdown', style: AppTypography.labelMedium.copyWith(color: AppColors.grey500)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: AppSpacing.borderFull,
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                _BarSegment(flex: overview.confirmed, total: total, color: AppColors.teal),
                _BarSegment(flex: overview.pending, total: total, color: const Color(0xFFF59E0B)),
                _BarSegment(flex: overview.declined, total: total, color: AppColors.dustyRose),
                _BarSegment(flex: overview.notInvited, total: total, color: AppColors.grey200),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BarSegment extends StatelessWidget {
  const _BarSegment({required this.flex, required this.total, required this.color});
  final int flex;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (flex == 0) return const SizedBox.shrink();
    return Expanded(
      flex: flex,
      child: Container(color: color),
    );
  }
}

class _StatusDetailCard extends StatelessWidget {
  const _StatusDetailCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.description,
  });
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: AppSpacing.borderLg,
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelLarge),
                Text(description, style: AppTypography.caption),
              ],
            ),
          ),
          Text(
            '$count',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
