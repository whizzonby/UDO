import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/guest_model.dart';
import '../../domain/guests_state.dart';
import '../providers/guests_provider.dart';
import '../drawers/guest_detail_drawer.dart';

class GuestListTab extends ConsumerStatefulWidget {
  const GuestListTab({super.key});

  @override
  ConsumerState<GuestListTab> createState() => _GuestListTabState();
}

class _GuestListTabState extends ConsumerState<GuestListTab> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'all';

  static const _filters = [
    ('all', 'All'),
    ('attending', 'Going'),
    ('pending', 'Pending'),
    ('declined', 'Declined'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guestsListNotifierProvider);

    return Column(
      children: [
        // Search + filter bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              TextField(
                controller: _searchCtrl,
                onChanged: (v) => ref
                    .read(guestsListNotifierProvider.notifier)
                    .search(v),
                decoration: InputDecoration(
                  hintText: 'Search guests…',
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppColors.grey400,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.grey400, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              size: 18, color: AppColors.grey400),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref
                                .read(guestsListNotifierProvider.notifier)
                                .search('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.grey100,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderLg,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((f) {
                    final isActive = _statusFilter == f.$1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(f.$2),
                        selected: isActive,
                        onSelected: (_) {
                          setState(() => _statusFilter = f.$1);
                          ref
                              .read(guestsListNotifierProvider.notifier)
                              .filterByStatus(f.$1);
                        },
                        selectedColor:
                            AppColors.hotPink.withValues(alpha: 0.12),
                        checkmarkColor: AppColors.hotPink,
                        labelStyle: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? AppColors.hotPink
                              : AppColors.grey600,
                        ),
                        side: BorderSide(
                          color: isActive
                              ? AppColors.hotPink.withValues(alpha: 0.3)
                              : AppColors.grey200,
                        ),
                        backgroundColor: AppColors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        Expanded(
          child: state.map(
            loading: (_) => const Center(
              child: CircularProgressIndicator(color: AppColors.hotPink),
            ),
            loaded: (s) => s.guests.isEmpty
                ? _EmptyState(hasSearch: s.query.isNotEmpty)
                : RefreshIndicator(
                    color: AppColors.hotPink,
                    onRefresh: () => ref
                        .read(guestsListNotifierProvider.notifier)
                        .refresh(),
                    child: ListView.separated(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      itemCount: s.guests.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) => GuestListTile(
                        guest: s.guests[i],
                        onTap: () => GuestDetailDrawer.show(
                          context,
                          ref,
                          s.guests[i],
                        ),
                      ),
                    ),
                  ),
            error: (e) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.message,
                      style: GoogleFonts.dmSans(color: AppColors.grey500)),
                  TextButton(
                    onPressed: () => ref
                        .read(guestsListNotifierProvider.notifier)
                        .refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Guest tile ───────────────────────────────────────────────────────────────

class GuestListTile extends StatelessWidget {
  const GuestListTile({
    super.key,
    required this.guest,
    required this.onTap,
  });

  final GuestModel guest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppSpacing.borderLg,
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _rsvpColor(guest.rsvpStatus).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _initials(guest.firstName, guest.lastName),
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _rsvpColor(guest.rsvpStatus),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name + details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          guest.fullName,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey700,
                          ),
                        ),
                      ),
                      if (guest.isVip)
                        const Icon(Icons.star_rounded,
                            size: 14, color: Color(0xFFD69E2E)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (guest.group != null)
                        Text(
                          guest.group!,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColors.grey500,
                          ),
                        ),
                      if (guest.group != null &&
                          guest.dietaryRequirements != null)
                        Text(' · ',
                            style: GoogleFonts.dmSans(
                                fontSize: 11, color: AppColors.grey400)),
                      if (guest.dietaryRequirements != null)
                        Text(
                          guest.dietaryRequirements!,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppColors.grey500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // RSVP chip
            _RsvpChip(status: guest.rsvpStatus),
          ],
        ),
      ),
    );
  }

  Color _rsvpColor(String status) {
    return switch (status) {
      'attending' => AppColors.teal,
      'declined' => AppColors.dustyRose,
      'maybe' => const Color(0xFF8B5CF6),
      _ => AppColors.grey400,
    };
  }

  String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$f$l';
  }
}

class _RsvpChip extends StatelessWidget {
  const _RsvpChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (status) {
      'attending' => ('Going', AppColors.teal, const Color(0xFFE8F7F5)),
      'declined' => ('Declined', AppColors.dustyRose, AppColors.blushLight),
      'maybe' => ('Maybe', const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
      _ => ('Pending', AppColors.grey500, AppColors.grey100),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppSpacing.borderFull,
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasSearch});
  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearch
                  ? Icons.search_off_rounded
                  : Icons.people_outline_rounded,
              size: 48,
              color: AppColors.grey300,
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch ? 'No guests match your search' : 'No guests yet',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              hasSearch
                  ? 'Try a different name or filter'
                  : 'Add your first guest to get started',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
