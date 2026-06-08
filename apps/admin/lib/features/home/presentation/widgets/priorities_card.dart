import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/home_stats_model.dart';

class PrioritiesCard extends StatelessWidget {
  const PrioritiesCard({
    super.key,
    required this.alerts,
    required this.priorities,
  });

  final List<SmartAlert> alerts;
  final List<PriorityAlert> priorities;

  bool get _hasItems => alerts.isNotEmpty || priorities.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_hasItems) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _PrioritiesModal.show(context, alerts, priorities),
      child: Container(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRIORITIES',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'What needs attention',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: AppSpacing.borderFull,
                  ),
                  child: Text(
                    '${alerts.length + priorities.length}',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...alerts.take(2).map((a) => _AlertRow(
                  title: a.title,
                  body: a.body,
                  actionLabel: a.actionLabel,
                  level: PriorityAlertLevel.warning,
                )),
            ...priorities.take(2).map((p) => _AlertRow(
                  title: p.title,
                  body: p.body,
                  actionLabel: p.actionLabel,
                  level: p.level,
                  amount: p.amount,
                )),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'See all',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.hotPink,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 10, color: AppColors.hotPink),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.title,
    required this.body,
    required this.level,
    this.actionLabel,
    this.amount,
  });

  final String title;
  final String body;
  final PriorityAlertLevel level;
  final String? actionLabel;
  final String? amount;

  Color get _levelColor {
    switch (level) {
      case PriorityAlertLevel.urgent:
        return AppColors.error;
      case PriorityAlertLevel.warning:
        return AppColors.warning;
      case PriorityAlertLevel.info:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _levelColor.withValues(alpha: 0.06),
        borderRadius: AppSpacing.borderLg,
        border: Border.all(color: _levelColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: _levelColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                    if (amount != null)
                      Text(
                        amount!,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _levelColor,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 8),
            Text(
              '$actionLabel →',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _levelColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrioritiesModal extends StatelessWidget {
  const _PrioritiesModal({required this.alerts, required this.priorities});
  final List<SmartAlert> alerts;
  final List<PriorityAlert> priorities;

  static void show(
    BuildContext context,
    List<SmartAlert> alerts,
    List<PriorityAlert> priorities,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _PrioritiesModal(alerts: alerts, priorities: priorities),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
        child: Column(
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
              'What needs attention',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 20),
            ...alerts.map((a) => _AlertRow(
                  title: a.title,
                  body: a.body,
                  actionLabel: a.actionLabel,
                  level: PriorityAlertLevel.warning,
                )),
            ...priorities.map((p) => _AlertRow(
                  title: p.title,
                  body: p.body,
                  actionLabel: p.actionLabel,
                  level: p.level,
                  amount: p.amount,
                )),
          ],
        ),
      ),
    );
  }
}
