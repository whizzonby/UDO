import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/guest_model.dart';
import '../providers/guests_provider.dart';

class GuestDetailDrawer extends ConsumerStatefulWidget {
  const GuestDetailDrawer({super.key, required this.guest});
  final GuestModel guest;

  static void show(BuildContext context, WidgetRef ref, GuestModel guest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GuestDetailDrawer(guest: guest),
    );
  }

  @override
  ConsumerState<GuestDetailDrawer> createState() =>
      _GuestDetailDrawerState();
}

class _GuestDetailDrawerState extends ConsumerState<GuestDetailDrawer> {
  late GuestModel _guest;

  @override
  void initState() {
    super.initState();
    _guest = widget.guest;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: AppSpacing.borderFull,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding:
                    const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GuestHeader(guest: _guest),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // RSVP section
                    _SectionTitle(title: 'RSVP'),
                    const SizedBox(height: 12),
                    _RsvpSelector(
                      current: _guest.rsvpStatus,
                      onChanged: (status) async {
                        final updated = await ref
                            .read(guestsListNotifierProvider.notifier)
                            .updateGuest(
                              _guest.id,
                              {'rsvp_status': status},
                            );
                        setState(() => _guest = updated);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Contact
                    if (_guest.email != null || _guest.phone != null) ...[
                      _SectionTitle(title: 'CONTACT'),
                      const SizedBox(height: 12),
                      _ContactCard(guest: _guest),
                      const SizedBox(height: 20),
                    ],

                    // Details
                    _SectionTitle(title: 'DETAILS'),
                    const SizedBox(height: 12),
                    _DetailCard(guest: _guest),
                    const SizedBox(height: 20),

                    // Plus one
                    if (_guest.plusOneAllowed) ...[
                      _SectionTitle(title: 'PLUS ONE'),
                      const SizedBox(height: 12),
                      _PlusOneCard(guest: _guest),
                      const SizedBox(height: 20),
                    ],

                    // Dietary
                    if (_guest.dietaryRequirements != null &&
                        _guest.dietaryRequirements!.isNotEmpty) ...[
                      _SectionTitle(title: 'DIETARY'),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: AppSpacing.borderLg,
                        ),
                        child: Text(
                          _guest.dietaryRequirements!,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.grey700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Notes
                    if (_guest.notes != null &&
                        _guest.notes!.isNotEmpty) ...[
                      _SectionTitle(title: 'NOTES'),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: AppSpacing.borderLg,
                        ),
                        child: Text(
                          _guest.notes!,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.grey600,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Logistics flags
                    if (_guest.needsTransport || _guest.needsAccommodation) ...[
                      _SectionTitle(title: 'LOGISTICS'),
                      const SizedBox(height: 12),
                      _LogisticsFlags(guest: _guest),
                      const SizedBox(height: 20),
                    ],

                    // Timestamps
                    _GuestTimestamps(guest: _guest),
                    const SizedBox(height: 24),

                    // Delete button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 16),
                        label: const Text('Remove guest'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove guest?',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        content: Text(
          'This will permanently remove ${_guest.fullName} from your list.',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(guestsListNotifierProvider.notifier)
          .deleteGuest(_guest.id);
      if (mounted) Navigator.pop(context);
    }
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _GuestHeader extends StatelessWidget {
  const _GuestHeader({required this.guest});
  final GuestModel guest;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _rsvpColor(guest.rsvpStatus).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _initials(guest.firstName, guest.lastName),
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _rsvpColor(guest.rsvpStatus),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      guest.fullName,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                  if (guest.isVip)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: AppSpacing.borderFull,
                        border: Border.all(
                          color: const Color(0xFFD69E2E).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 12, color: Color(0xFFD69E2E)),
                          const SizedBox(width: 3),
                          Text(
                            'VIP',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (guest.group != null)
                Text(
                  guest.group!,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.grey500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Color _rsvpColor(String status) => switch (status) {
        'attending' => AppColors.teal,
        'declined' => AppColors.dustyRose,
        _ => AppColors.grey400,
      };

  String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$f$l';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.grey500,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _RsvpSelector extends StatelessWidget {
  const _RsvpSelector({required this.current, required this.onChanged});
  final String current;
  final ValueChanged<String> onChanged;

  static const _options = [
    ('attending', 'Going', AppColors.teal),
    ('declined', 'Declined', AppColors.dustyRose),
    ('pending', 'Pending', AppColors.grey500),
    ('maybe', 'Maybe', Color(0xFF8B5CF6)),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((opt) {
        final isSelected = current == opt.$1;
        return GestureDetector(
          onTap: () => onChanged(opt.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? opt.$3.withValues(alpha: 0.12)
                  : AppColors.grey100,
              borderRadius: AppSpacing.borderFull,
              border: Border.all(
                color: isSelected ? opt.$3 : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              opt.$2,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? opt.$3 : AppColors.grey500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.guest});
  final GuestModel guest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: AppSpacing.borderLg,
      ),
      child: Column(
        children: [
          if (guest.email != null)
            _ContactRow(
              icon: Icons.email_outlined,
              label: guest.email!,
            ),
          if (guest.email != null && guest.phone != null)
            const SizedBox(height: 8),
          if (guest.phone != null)
            _ContactRow(
              icon: Icons.phone_outlined,
              label: guest.phone!,
            ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey500),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: AppColors.grey700,
          ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.guest});
  final GuestModel guest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: AppSpacing.borderLg,
      ),
      child: Column(
        children: [
          if (guest.relationship != null)
            _DetailRow(label: 'Side', value: _formatRelationship(guest.relationship!)),
          if (guest.ageGroup != 'adult')
            _DetailRow(label: 'Age group', value: _formatAgeGroup(guest.ageGroup)),
          _DetailRow(
            label: 'Invitation',
            value: guest.invitationSentAt != null ? 'Sent' : 'Not sent yet',
          ),
        ],
      ),
    );
  }

  String _formatRelationship(String r) => switch (r) {
        'bride_side' => "Bride's side",
        'groom_side' => "Groom's side",
        'mutual' => 'Mutual',
        _ => 'Other',
      };

  String _formatAgeGroup(String a) => switch (a) {
        'child' => 'Child',
        'baby' => 'Baby/Infant',
        _ => 'Adult',
      };
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.grey500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.grey700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlusOneCard extends StatelessWidget {
  const _PlusOneCard({required this.guest});
  final GuestModel guest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: AppSpacing.borderLg,
      ),
      child: Row(
        children: [
          const Icon(Icons.person_add_outlined,
              size: 18, color: AppColors.grey500),
          const SizedBox(width: 10),
          Text(
            guest.plusOneName?.isNotEmpty == true
                ? guest.plusOneName!
                : 'Plus one (name not set)',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.grey700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogisticsFlags extends StatelessWidget {
  const _LogisticsFlags({required this.guest});
  final GuestModel guest;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (guest.needsTransport)
          _Flag(
            icon: Icons.directions_car_outlined,
            label: 'Needs transport',
            color: AppColors.info,
          ),
        if (guest.needsTransport && guest.needsAccommodation)
          const SizedBox(width: 8),
        if (guest.needsAccommodation)
          _Flag(
            icon: Icons.hotel_outlined,
            label: 'Needs accommodation',
            color: AppColors.forestGreen,
          ),
      ],
    );
  }
}

class _Flag extends StatelessWidget {
  const _Flag({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppSpacing.borderLg,
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestTimestamps extends StatelessWidget {
  const _GuestTimestamps({required this.guest});
  final GuestModel guest;

  @override
  Widget build(BuildContext context) {
    final timestamps = <(String, String?)>[
      ('Invitation sent', _fmt(guest.invitationSentAt)),
      ('RSVP received', _fmt(guest.rsvpRespondedAt)),
      ('Checked in', _fmt(guest.checkedInAt)),
    ].where((t) => t.$2 != null).toList();

    if (timestamps.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIMELINE',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.grey500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        ...timestamps.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text(
                    t.$1,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.grey500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    t.$2!,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  String? _fmt(String? iso) {
    if (iso == null) return null;
    final dt = DateTime.tryParse(iso);
    if (dt == null) return null;
    return DateFormat('d MMM yyyy').format(dt);
  }
}
