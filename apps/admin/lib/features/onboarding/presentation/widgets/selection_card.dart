import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class SelectionCard extends StatelessWidget {
  const SelectionCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.emoji,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? subtitle;
  final String? emoji;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectionFill : AppColors.white,
          borderRadius: AppSpacing.borderLg,
          border: Border.all(
            color: isSelected
                ? AppColors.selectionBorder
                : AppColors.grey200,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            if (emoji != null)
              Text(emoji!, style: const TextStyle(fontSize: 20)),
            if (icon != null)
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.dustyRose : AppColors.grey500,
              ),
            if (emoji != null || icon != null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.dustyRose : AppColors.grey700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.dustyRose : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.dustyRose : AppColors.grey300,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
