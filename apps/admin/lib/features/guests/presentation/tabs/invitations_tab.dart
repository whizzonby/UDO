import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class InvitationsTab extends StatelessWidget {
  const InvitationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mail_outline_rounded,
                size: 48, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text(
              'Invitations',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Send personalized invitations and track responses — coming soon.',
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
