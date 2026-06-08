import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class CheckInCard extends StatelessWidget {
  const CheckInCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _CheckInModal.show(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.blushLight,
          borderRadius: AppSpacing.borderXl,
          border: Border.all(color: AppColors.hotPink.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.hotPink.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_border_rounded,
                  color: AppColors.hotPink, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How are you feeling?',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Take a moment to check in with yourself',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.grey400, size: 22),
          ],
        ),
      ),
    );
  }
}

class _CheckInModal extends StatefulWidget {
  const _CheckInModal();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CheckInModal(),
    );
  }

  @override
  State<_CheckInModal> createState() => _CheckInModalState();
}

class _CheckInModalState extends State<_CheckInModal> {
  String? _selected;

  static const _moods = [
    _Mood('calm', 'Calm', Icons.spa_outlined, Color(0xFF2A9D8F)),
    _Mood('excited', 'Excited', Icons.celebration_outlined, Color(0xFFFF4D8C)),
    _Mood('overwhelmed', 'Overwhelmed', Icons.cloud_outlined, Color(0xFF6B7280)),
    _Mood('balanced', 'Balanced', Icons.balance_outlined, Color(0xFF8B5CF6)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: AppSpacing.borderFull,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'How are you feeling about\nyour wedding?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.grey700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No right or wrong answer — just checking in.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.grey500,
            ),
          ),
          const SizedBox(height: 28),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: _moods
                .map((mood) => _MoodTile(
                      mood: mood,
                      isSelected: _selected == mood.key,
                      onTap: () => setState(() => _selected = mood.key),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.hotPink,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.grey200,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                elevation: 0,
              ),
              child: Text(
                'Save',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Mood {
  const _Mood(this.key, this.label, this.icon, this.color);
  final String key;
  final String label;
  final IconData icon;
  final Color color;
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });
  final _Mood mood;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? mood.color.withValues(alpha: 0.1)
              : AppColors.grey100,
          borderRadius: AppSpacing.borderLg,
          border: Border.all(
            color: isSelected ? mood.color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(mood.icon,
                size: 22,
                color: isSelected ? mood.color : AppColors.grey400),
            const SizedBox(width: 10),
            Text(
              mood.label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? mood.color : AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
