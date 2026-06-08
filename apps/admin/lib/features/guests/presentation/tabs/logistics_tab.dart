import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/guest_model.dart';
import '../../domain/guests_state.dart';
import '../providers/guests_provider.dart';

class LogisticsTab extends ConsumerWidget {
  const LogisticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guestsListNotifierProvider);

    return state.map(
      loading: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.pinkGradientStart)),
      error: (s) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: AppColors.grey400, size: 40),
          const SizedBox(height: 12),
          Text(s.message, style: GoogleFonts.dmSans(color: AppColors.grey500)),
          TextButton(
            onPressed: () =>
                ref.read(guestsListNotifierProvider.notifier).refresh(),
            child: const Text('Retry'),
          ),
        ]),
      ),
      loaded: (s) {
        final guests = s.guests;
        final transport = guests.where((g) => g.needsTransport).toList();
        final accommodation = guests.where((g) => g.needsAccommodation).toList();
        final both = guests
            .where((g) => g.needsTransport && g.needsAccommodation)
            .toList();

        if (transport.isEmpty && accommodation.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.directions_car_outlined,
                    size: 52, color: AppColors.grey300),
                const SizedBox(height: 14),
                Text('No logistics needs',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey700)),
                const SizedBox(height: 6),
                Text(
                  'No guests have flagged transport or accommodation needs yet.',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.grey500, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.pinkGradientStart,
          onRefresh: () =>
              ref.read(guestsListNotifierProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              // ── Summary row ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(children: [
                    _SummaryTile(
                      icon: Icons.directions_car_rounded,
                      label: 'Transport',
                      count: transport.length,
                      color: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 8),
                    _SummaryTile(
                      icon: Icons.hotel_rounded,
                      label: 'Accommodation',
                      count: accommodation.length,
                      color: const Color(0xFF8B5CF6),
                    ),
                    const SizedBox(width: 8),
                    _SummaryTile(
                      icon: Icons.person_rounded,
                      label: 'Both',
                      count: both.length,
                      color: AppColors.pinkGradientStart,
                    ),
                  ]),
                ),
              ),

              // ── Transport ───────────────────────────────────────────
              if (transport.isNotEmpty) ...[
                _LogisticsHeader(
                  icon: Icons.directions_car_rounded,
                  label: 'NEEDS TRANSPORT',
                  count: transport.length,
                  color: const Color(0xFF3B82F6),
                ),
                SliverList.builder(
                  itemCount: transport.length,
                  itemBuilder: (_, i) => _LogisticsGuestRow(
                    guest: transport[i],
                    badge: transport[i].needsAccommodation
                        ? 'Also needs accommodation'
                        : null,
                  ),
                ),
              ],

              // ── Accommodation ────────────────────────────────────────
              if (accommodation.isNotEmpty) ...[
                _LogisticsHeader(
                  icon: Icons.hotel_rounded,
                  label: 'NEEDS ACCOMMODATION',
                  count: accommodation.length,
                  color: const Color(0xFF8B5CF6),
                ),
                SliverList.builder(
                  itemCount: accommodation.length,
                  itemBuilder: (_, i) => _LogisticsGuestRow(
                    guest: accommodation[i],
                    badge: accommodation[i].needsTransport
                        ? 'Also needs transport'
                        : null,
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text('$count',
              style: GoogleFonts.dmSans(
                  fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: AppColors.grey500,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _LogisticsHeader extends SliverToBoxAdapter {
  _LogisticsHeader({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) : super(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Row(children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey500,
                      letterSpacing: 0.8)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$count',
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ),
            ]),
          ),
        );
}

class _LogisticsGuestRow extends StatelessWidget {
  const _LogisticsGuestRow({required this.guest, this.badge});

  final GuestModel guest;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey100),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.blushLight,
            child: Text(
              _initials(guest.fullName),
              style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pinkGradientStart),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(guest.fullName,
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey700)),
              if (guest.email != null || guest.phone != null)
                Text(guest.email ?? guest.phone ?? '',
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: AppColors.grey500),
                    overflow: TextOverflow.ellipsis),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _RsvpPill(status: guest.rsvpStatus),
            if (badge != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.blushLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge!,
                    style: GoogleFonts.dmSans(
                        fontSize: 10, color: AppColors.pinkGradientStart)),
              ),
            ],
          ]),
        ]),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }
}

class _RsvpPill extends StatelessWidget {
  const _RsvpPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      'attending' => ('Going', const Color(0xFFD1FAE5), const Color(0xFF065F46)),
      'declined'  => ('Declined', const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
      'maybe'     => ('Maybe', const Color(0xFFFEF3C7), const Color(0xFF92400E)),
      _           => ('Pending', AppColors.grey100, AppColors.grey600),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}
