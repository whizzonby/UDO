import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/guest_model.dart';
import '../../domain/guests_state.dart';
import '../providers/guests_provider.dart';

class GuestsOverviewTab extends ConsumerWidget {
  const GuestsOverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guestsOverviewNotifierProvider);

    return state.map(
      loading: (_) => const Center(child: CircularProgressIndicator()),
      loaded: (s) => _OverviewBody(overview: s.overview),
      error: (e) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(e.message,
                style: GoogleFonts.dmSans(color: AppColors.grey500)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  ref.read(guestsOverviewNotifierProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({required this.overview});
  final GuestsOverview overview;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.hotPink,
      onRefresh: Future.value,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guest Summary header card
            _GuestSummaryCard(overview: overview),
            const SizedBox(height: 20),

            // Quick stats
            Text(
              'QUICK STATS',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.grey500,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.7,
              children: [
                _QuickStat(
                  label: 'Vegetarian',
                  value: '${overview.quickStats.vegetarian}',
                  icon: Icons.eco_outlined,
                  color: AppColors.forestGreen,
                ),
                _QuickStat(
                  label: 'Kids',
                  value: '${overview.quickStats.kids}',
                  icon: Icons.child_care_outlined,
                  color: AppColors.teal,
                ),
                _QuickStat(
                  label: 'Plus ones',
                  value: '${overview.quickStats.plusOnes}',
                  icon: Icons.person_add_outlined,
                  color: AppColors.hotPink,
                ),
                _QuickStat(
                  label: 'Allergies',
                  value: '${overview.quickStats.allergies}',
                  icon: Icons.warning_amber_outlined,
                  color: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Invitation status
            Text(
              'INVITATIONS',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.grey500,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _InvitationStatusCard(overview: overview),

            if (overview.vipCount > 0) ...[
              const SizedBox(height: 20),
              _VipBadge(count: overview.vipCount),
            ],
          ],
        ),
      ),
    );
  }
}

class _GuestSummaryCard extends StatelessWidget {
  const _GuestSummaryCard({required this.overview});
  final GuestsOverview overview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderXl,
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _BigStat(
                value: '${overview.attending}',
                label: 'Coming',
                color: AppColors.teal,
                bgColor: const Color(0xFFE8F7F5),
              ),
              _BigStat(
                value: '${overview.declined}',
                label: "Can't make it",
                color: AppColors.dustyRose,
                bgColor: AppColors.blushLight,
              ),
              _BigStat(
                value: '${overview.pending}',
                label: 'Pending',
                color: AppColors.grey500,
                bgColor: AppColors.grey100,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'RESPONSE RATE',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey500,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${overview.responseRate}% of guests have responded',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: AppSpacing.borderFull,
                child: LinearProgressIndicator(
                  value: overview.responseRate / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.grey100,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.teal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  const _BigStat({
    required this.value,
    required this.label,
    required this.color,
    required this.bgColor,
  });
  final String value;
  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppSpacing.borderLg,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderLg,
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.grey700,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvitationStatusCard extends StatelessWidget {
  const _InvitationStatusCard({required this.overview});
  final GuestsOverview overview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderLg,
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          _InviteChip(
            label: 'Invited',
            count: overview.invitedCount,
            color: AppColors.forestGreen,
          ),
          const SizedBox(width: 8),
          _InviteChip(
            label: 'Not sent',
            count: overview.notInvitedYet,
            color: AppColors.grey500,
          ),
          const SizedBox(width: 8),
          _InviteChip(
            label: 'Total',
            count: overview.totalGuests,
            color: AppColors.grey700,
          ),
        ],
      ),
    );
  }
}

class _InviteChip extends StatelessWidget {
  const _InviteChip({
    required this.label,
    required this.count,
    required this.color,
  });
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

class _VipBadge extends StatelessWidget {
  const _VipBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: AppSpacing.borderLg,
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFD69E2E), size: 20),
          const SizedBox(width: 10),
          Text(
            '$count VIP guest${count == 1 ? '' : 's'} on your list',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}
