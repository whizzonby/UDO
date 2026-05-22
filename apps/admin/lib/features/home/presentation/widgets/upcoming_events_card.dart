import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/home_stats_model.dart';
import 'section_card.dart';

class UpcomingEventsCard extends StatelessWidget {
  const UpcomingEventsCard({
    super.key,
    required this.events,
    required this.onTap,
  });

  final List<UpcomingEvent> events;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            icon: Icons.calendar_month_outlined,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Upcoming',
            subtitle: 'Next appointments & milestones',
            trailing: ViewAllButton(onTap: onTap),
          ),
          const SizedBox(height: 16),
          ...events.map((event) => _EventRow(event: event)),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});
  final UpcomingEvent event;

  static const _categoryColors = {
    'Vendor': AppColors.teal,
    'Venue': AppColors.forestGreen,
    'Ceremony': AppColors.hotPink,
    'Reception': AppColors.dustyRose,
  };

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[event.category] ?? AppColors.grey400;
    final isToday = _isToday(event.date);
    final isTomorrow = _isTomorrow(event.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date block
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isToday
                  ? AppColors.hotPink.withValues(alpha: 0.08)
                  : AppColors.grey100,
              borderRadius: AppSpacing.borderMd,
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('d').format(event.date),
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isToday ? AppColors.hotPink : AppColors.grey700,
                    height: 1,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(event.date).toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isToday ? AppColors.hotPink : AppColors.grey500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                    if (isToday || isTomorrow)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppColors.hotPink.withValues(alpha: 0.1)
                              : AppColors.grey100,
                          borderRadius: AppSpacing.borderFull,
                        ),
                        child: Text(
                          isToday ? 'Today' : 'Tomorrow',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isToday ? AppColors.hotPink : AppColors.grey500,
                          ),
                        ),
                      ),
                  ],
                ),
                if (event.location != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 11, color: AppColors.grey400),
                      const SizedBox(width: 3),
                      Text(
                        event.location!,
                        style: AppTypography.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: AppSpacing.borderFull,
                  ),
                  child: Text(
                    event.category,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }
}
