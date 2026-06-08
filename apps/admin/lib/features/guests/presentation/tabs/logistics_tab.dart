import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class LogisticsTab extends StatelessWidget {
  const LogisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_car_outlined,
                size: 48, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text(
              'Guest Logistics',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Manage accommodation, transport, and travel arrangements — coming soon.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.grey500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
