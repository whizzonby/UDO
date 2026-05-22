import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/home_stats_model.dart';
import '../providers/home_provider.dart';

class CountdownCard extends ConsumerWidget {
  const CountdownCard({super.key, required this.wedding});

  final WeddingInfo wedding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D5016), Color(0xFF3A7020)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppSpacing.borderXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.forestGreen.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wedding title
          Row(
            children: [
              Expanded(
                child: Text(
                  '${wedding.partnerOneName} & ${wedding.partnerTwoName}',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.borderFull,
                ),
                child: Text(
                  _statusLabel(wedding.status),
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          if (wedding.venueName != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 12,
                    color: Colors.white.withValues(alpha: 0.7)),
                const SizedBox(width: 4),
                Text(
                  '${wedding.venueName}${wedding.venueCity != null ? ' · ${wedding.venueCity}' : ''}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 20),

          // Countdown display
          if (wedding.weddingDate != null)
            _CountdownDisplay(weddingDate: wedding.weddingDate!)
          else
            Text(
              'No date set yet',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),

          if (wedding.weddingDate != null) ...[
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(wedding.weddingDate!),
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(WeddingStatus status) {
    switch (status) {
      case WeddingStatus.planning:
        return 'PLANNING';
      case WeddingStatus.live:
        return 'LIVE';
      case WeddingStatus.past:
        return 'COMPLETED';
    }
  }
}

class _CountdownDisplay extends ConsumerWidget {
  const _CountdownDisplay({required this.weddingDate});
  final DateTime weddingDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdown = ref.watch(weddingCountdownProvider(weddingDate));

    return countdown.when(
      data: (duration) {
        if (duration == Duration.zero) {
          return _WeddingDayDisplay();
        }
        final days = duration.inDays;
        final hours = duration.inHours % 24;
        final minutes = duration.inMinutes % 60;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$days',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 0.9,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    days == 1 ? 'day' : 'days',
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _TimeChip(value: hours, unit: 'hrs'),
                const SizedBox(width: 8),
                _TimeChip(value: minutes, unit: 'min'),
              ],
            ),
          ],
        );
      },
      loading: () => Text(
        '...',
        style: GoogleFonts.playfairDisplay(
          fontSize: 48,
          color: Colors.white70,
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.value, required this.unit});
  final int value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: AppSpacing.borderMd,
      ),
      child: Text(
        '${value.toString().padLeft(2, '0')} $unit',
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.9),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _WeddingDayDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Today\'s the day! 🎉',
      style: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}
