import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/home_stats_model.dart';
import '../providers/home_provider.dart';

class HeroCard extends ConsumerWidget {
  const HeroCard({super.key, required this.wedding});
  final WeddingInfo wedding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4D8C), Color(0xFFD4006A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppSpacing.borderXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.hotPink.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
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
                      '${wedding.partnerOneName} & ${wedding.partnerTwoName}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    if (wedding.weddingDate != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _dateAndLocation(wedding),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 22),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 20),

          if (wedding.weddingDate != null)
            _CountdownRow(weddingDate: wedding.weddingDate!)
          else
            Text(
              'Set your wedding date to see the countdown',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
    );
  }

  String _dateAndLocation(WeddingInfo w) {
    final parts = <String>[];
    if (w.weddingDate != null) {
      parts.add(DateFormat('MMMM d, yyyy').format(w.weddingDate!));
    }
    if (w.venueCity != null && w.venueCity!.isNotEmpty) {
      parts.add(w.venueCity!);
    }
    return parts.join(' • ');
  }
}

class _CountdownRow extends ConsumerWidget {
  const _CountdownRow({required this.weddingDate});
  final DateTime weddingDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdown = ref.watch(weddingCountdownProvider(weddingDate));

    return countdown.when(
      data: (duration) {
        if (duration == Duration.zero) {
          return Text(
            "Today's the day!",
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          );
        }
        final days = duration.inDays;
        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$days',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 0.9,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        days == 1 ? 'day to go' : 'days to go',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(weddingDate),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}
