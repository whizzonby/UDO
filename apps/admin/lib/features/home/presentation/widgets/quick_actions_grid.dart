import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  static const _actions = [
    _Action(icon: Icons.storefront_outlined, label: 'Add vendor'),
    _Action(icon: Icons.person_add_alt_1_outlined, label: 'Invite guest'),
    _Action(icon: Icons.flag_outlined, label: 'Set milestone'),
    _Action(icon: Icons.chat_bubble_outline_rounded, label: 'Message guests'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.grey500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _ActionButton(action: _actions[0])),
            const SizedBox(width: 12),
            Expanded(child: _ActionButton(action: _actions[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _ActionButton(action: _actions[2])),
            const SizedBox(width: 12),
            Expanded(child: _ActionButton(action: _actions[3])),
          ],
        ),
      ],
    );
  }
}

class _Action {
  const _Action({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});
  final _Action action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppSpacing.borderLg,
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.hotPink,
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                action.label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
