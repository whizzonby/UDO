import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppSpacing.borderXl,
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class CardHeader extends StatelessWidget {
  const CardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.hotPink).withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderMd,
            ),
            child: Icon(icon, size: 16, color: iconColor ?? AppColors.hotPink),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.headingSmall),
              if (subtitle != null)
                Text(subtitle!, style: AppTypography.caption),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class ViewAllButton extends StatelessWidget {
  const ViewAllButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'View all',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.hotPink,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.chevron_right_rounded,
              size: 16, color: AppColors.hotPink),
        ],
      ),
    );
  }
}
