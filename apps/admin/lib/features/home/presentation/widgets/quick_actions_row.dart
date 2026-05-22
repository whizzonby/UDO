import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  static const _actions = [
    _QuickAction(
      icon: Icons.person_add_alt_1_outlined,
      label: 'Add Guest',
      color: AppColors.teal,
    ),
    _QuickAction(
      icon: Icons.send_outlined,
      label: 'Send Invite',
      color: AppColors.hotPink,
    ),
    _QuickAction(
      icon: Icons.add_task_outlined,
      label: 'Add Task',
      color: AppColors.forestGreen,
    ),
    _QuickAction(
      icon: Icons.receipt_long_outlined,
      label: 'Add Expense',
      color: AppColors.dustyRose,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _actions
          .map(
            (action) => Expanded(
              child: _QuickActionButton(action: action),
            ),
          )
          .toList(),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action});
  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {/* TODO: navigate */},
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderLg,
            ),
            child: Icon(action.icon, size: 22, color: action.color),
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
