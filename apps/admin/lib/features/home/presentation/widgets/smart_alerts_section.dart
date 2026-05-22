import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/home_stats_model.dart';

class SmartAlertsSection extends StatelessWidget {
  const SmartAlertsSection({
    super.key,
    required this.alerts,
  });

  final List<SmartAlert> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.notifications_active_outlined,
                  size: 16, color: AppColors.grey500),
              const SizedBox(width: 6),
              Text(
                'Smart Alerts',
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.grey500),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.hotPink,
                  borderRadius: AppSpacing.borderFull,
                ),
                child: Text(
                  '${alerts.length}',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...alerts.map((alert) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AlertCard(alert: alert),
            )),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});
  final SmartAlert alert;

  static const _typeConfig = {
    SmartAlertType.rsvp: (AppColors.hotPink, Icons.mail_outline_rounded),
    SmartAlertType.budget: (Color(0xFFF59E0B), Icons.account_balance_wallet_outlined),
    SmartAlertType.vendor: (AppColors.teal, Icons.handshake_outlined),
    SmartAlertType.reminder: (Color(0xFF8B5CF6), Icons.alarm_outlined),
    SmartAlertType.info: (AppColors.info, Icons.info_outline_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final config = _typeConfig[alert.type] ??
        (AppColors.grey500, Icons.info_outline_rounded);
    final (color, icon) = config;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderLg,
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored left accent bar
          Container(
            width: 4,
            height: double.infinity,
            constraints: const BoxConstraints(minHeight: 68),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 15, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          alert.title,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.body,
                    style: AppTypography.bodySmall,
                  ),
                  if (alert.actionLabel != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {/* TODO: navigate to actionRoute */},
                      child: Text(
                        alert.actionLabel!,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
