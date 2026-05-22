import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class HomeSheetScaffold extends StatelessWidget {
  const HomeSheetScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.initialSize = 0.65,
    this.maxSize = 0.92,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final double initialSize;
  final double maxSize;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    double initialSize = 0.65,
    double maxSize = 0.92,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: initialSize,
        minChildSize: 0.4,
        maxChildSize: maxSize,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drag handle
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

        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppColors.grey500,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.grey400, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),

        const Divider(height: 1),
        Expanded(child: child),
      ],
    );
  }
}
