import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/home_stats_model.dart';

class TodaysFocusSection extends StatelessWidget {
  const TodaysFocusSection({super.key, required this.items});
  final List<TodaysFocusItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderXl,
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.hotPink,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "TODAY'S FOCUS",
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey500,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _FocusItem(item: item),
                if (i < items.length - 1) ...[
                  const SizedBox(height: 2),
                  const Divider(height: 16),
                  const SizedBox(height: 2),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _FocusItem extends StatelessWidget {
  const _FocusItem({required this.item});
  final TodaysFocusItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item.isDone
                ? AppColors.hotPink
                : Colors.transparent,
            border: Border.all(
              color: item.isDone ? AppColors.hotPink : AppColors.grey300,
              width: 1.5,
            ),
          ),
          child: item.isDone
              ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: item.isDone ? AppColors.grey400 : AppColors.grey700,
                  decoration: item.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.reason,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.grey500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {},
                child: Text(
                  item.actionLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.hotPink,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.hotPink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
