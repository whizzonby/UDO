import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/guest_model.dart';
import '../providers/guests_provider.dart';

class InvitationsTab extends ConsumerWidget {
  const InvitationsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(invitationsNotifierProvider);

    if (state.status == InvitationsStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.pinkGradientStart));
    }

    if (state.status == InvitationsStatus.error) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: AppColors.grey400, size: 40),
          const SizedBox(height: 12),
          Text(state.error ?? 'Failed to load',
              style: GoogleFonts.dmSans(color: AppColors.grey500)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => ref.read(invitationsNotifierProvider.notifier).refresh(),
            child: const Text('Retry'),
          ),
        ]),
      );
    }

    final total = state.guests.length;
    final invitedCount = state.awaiting.length + state.responded.length;
    final notInvited = state.notInvited;
    final isBusy = state.status == InvitationsStatus.busy;

    return RefreshIndicator(
      color: AppColors.pinkGradientStart,
      onRefresh: () => ref.read(invitationsNotifierProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          // ── Stats row ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                _StatChip(label: 'Total', count: total, bg: AppColors.grey100, fg: AppColors.grey700),
                const SizedBox(width: 8),
                _StatChip(label: 'Invited', count: invitedCount, bg: const Color(0xFFE8F7F5), fg: AppColors.teal),
                const SizedBox(width: 8),
                _StatChip(label: 'Not sent', count: notInvited.length, bg: AppColors.blushLight, fg: AppColors.pinkGradientStart),
              ]),
            ),
          ),

          // ── Bulk invite banner ────────────────────────────────────────────
          if (notInvited.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _BulkInviteBanner(
                  count: notInvited.length,
                  isBusy: isBusy,
                  onInviteAll: () =>
                      ref.read(invitationsNotifierProvider.notifier).bulkInviteAll(),
                ),
              ),
            ),

          // ── Section: Not invited yet ──────────────────────────────────────
          if (notInvited.isNotEmpty) ...[
            _SectionHeader(
              label: 'NOT YET INVITED',
              count: notInvited.length,
              dot: AppColors.pinkGradientStart,
            ),
            SliverList.builder(
              itemCount: notInvited.length,
              itemBuilder: (_, i) => _GuestInviteRow(
                guest: notInvited[i],
                onMarkInvited: () => ref
                    .read(invitationsNotifierProvider.notifier)
                    .markInvited(notInvited[i].id),
                onCopyLink: () => _copyLink(context, notInvited[i].token),
              ),
            ),
          ],

          // ── Section: Awaiting response ────────────────────────────────────
          if (state.awaiting.isNotEmpty) ...[
            _SectionHeader(
              label: 'AWAITING RESPONSE',
              count: state.awaiting.length,
              dot: const Color(0xFFF59E0B),
            ),
            SliverList.builder(
              itemCount: state.awaiting.length,
              itemBuilder: (_, i) => _GuestInviteRow(
                guest: state.awaiting[i],
                showResend: true,
                onMarkInvited: () => ref
                    .read(invitationsNotifierProvider.notifier)
                    .markInvited(state.awaiting[i].id),
                onCopyLink: () => _copyLink(context, state.awaiting[i].token),
              ),
            ),
          ],

          // ── Section: Responded ────────────────────────────────────────────
          if (state.responded.isNotEmpty) ...[
            _SectionHeader(
              label: 'RESPONDED',
              count: state.responded.length,
              dot: AppColors.teal,
            ),
            SliverList.builder(
              itemCount: state.responded.length,
              itemBuilder: (_, i) => _GuestInviteRow(
                guest: state.responded[i],
                onMarkInvited: null,
                onCopyLink: () => _copyLink(context, state.responded[i].token),
              ),
            ),
          ],

          if (total == 0)
            SliverFillRemaining(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.mail_outline_rounded,
                      size: 52, color: AppColors.grey300),
                  const SizedBox(height: 14),
                  Text('No guests yet',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.grey700)),
                  const SizedBox(height: 6),
                  Text('Add guests first, then send invitations.',
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey500)),
                ]),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _copyLink(BuildContext context, String? token) {
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No link available for this guest')),
      );
      return;
    }
    final url = 'https://udo.app/g/$token';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $url',
            style: GoogleFonts.dmSans(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.teal,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.bg,
    required this.fg,
  });

  final String label;
  final int count;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Text('$count',
              style: GoogleFonts.dmSans(
                  fontSize: 20, fontWeight: FontWeight.w700, color: fg)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.grey500)),
        ]),
      ),
    );
  }
}

class _BulkInviteBanner extends StatelessWidget {
  const _BulkInviteBanner({
    required this.count,
    required this.isBusy,
    required this.onInviteAll,
  });

  final int count;
  final bool isBusy;
  final VoidCallback onInviteAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.pinkGradientStart, AppColors.pinkGradientEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        const Icon(Icons.send_rounded, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$count guest${count == 1 ? '' : 's'} haven\'t received their invitation yet.',
            style: GoogleFonts.dmSans(
                fontSize: 13, color: Colors.white, height: 1.4),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: isBusy ? null : onInviteAll,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: isBusy
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.pinkGradientStart),
                  )
                : Text('Invite all',
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pinkGradientStart)),
          ),
        ),
      ]),
    );
  }
}

class _SectionHeader extends SliverToBoxAdapter {
  _SectionHeader({required String label, required int count, required Color dot})
      : super(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Row(children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
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
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$count',
                    style: GoogleFonts.dmSans(
                        fontSize: 11, color: AppColors.grey600)),
              ),
            ]),
          ),
        );
}

class _GuestInviteRow extends StatelessWidget {
  const _GuestInviteRow({
    required this.guest,
    required this.onCopyLink,
    this.onMarkInvited,
    this.showResend = false,
  });

  final GuestModel guest;
  final VoidCallback? onMarkInvited;
  final VoidCallback onCopyLink;
  final bool showResend;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(guest.fullName);
    final avatarColor = _colorFromName(guest.fullName);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey100),
        ),
        child: Row(children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor.withValues(alpha: 0.15),
            child: Text(initials,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: avatarColor)),
          ),
          const SizedBox(width: 12),

          // Name + subtitle
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(guest.fullName,
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey700),
                      overflow: TextOverflow.ellipsis),
                ),
                if (guest.isVip) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('VIP',
                        style: GoogleFonts.dmSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF856404))),
                  ),
                ],
              ]),
              const SizedBox(height: 2),
              Text(
                guest.email ?? guest.phone ?? 'No contact',
                style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.grey500),
                overflow: TextOverflow.ellipsis,
              ),
              if (guest.invitationSentAt != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Invited ${_formatDate(guest.invitationSentAt!)}',
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: AppColors.teal),
                ),
              ],
            ]),
          ),

          const SizedBox(width: 8),

          // RSVP chip
          _RsvpChip(status: guest.rsvpStatus),
          const SizedBox(width: 8),

          // Actions
          _ActionMenu(
            guest: guest,
            onMarkInvited: onMarkInvited,
            onCopyLink: onCopyLink,
            showResend: showResend,
          ),
        ]),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }

  Color _colorFromName(String name) {
    const palette = [
      AppColors.pinkGradientStart,
      AppColors.teal,
      Color(0xFF8B5CF6),
      Color(0xFFF59E0B),
      Color(0xFF10B981),
      Color(0xFFEF4444),
    ];
    return palette[name.isEmpty ? 0 : name.codeUnitAt(0) % palette.length];
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month]} ${dt.day}';
    } catch (_) {
      return '';
    }
  }
}

class _RsvpChip extends StatelessWidget {
  const _RsvpChip({required this.status});

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

class _ActionMenu extends StatelessWidget {
  const _ActionMenu({
    required this.guest,
    required this.onCopyLink,
    this.onMarkInvited,
    this.showResend = false,
  });

  final GuestModel guest;
  final VoidCallback? onMarkInvited;
  final VoidCallback onCopyLink;
  final bool showResend;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded,
          size: 18, color: AppColors.grey400),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (val) {
        switch (val) {
          case 'invite':
            onMarkInvited?.call();
          case 'copy':
            onCopyLink();
          case 'resend':
            onCopyLink();
        }
      },
      itemBuilder: (_) => [
        if (onMarkInvited != null)
          PopupMenuItem(
            value: 'invite',
            child: Row(children: [
              const Icon(Icons.mark_email_read_outlined,
                  size: 16, color: AppColors.teal),
              const SizedBox(width: 8),
              Text('Mark as invited',
                  style: GoogleFonts.dmSans(fontSize: 13)),
            ]),
          ),
        if (showResend)
          PopupMenuItem(
            value: 'resend',
            child: Row(children: [
              const Icon(Icons.refresh_rounded,
                  size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Text('Resend / copy link',
                  style: GoogleFonts.dmSans(fontSize: 13)),
            ]),
          ),
        PopupMenuItem(
          value: 'copy',
          child: Row(children: [
            const Icon(Icons.link_rounded,
                size: 16, color: AppColors.grey500),
            const SizedBox(width: 8),
            Text('Copy guest link',
                style: GoogleFonts.dmSans(fontSize: 13)),
          ]),
        ),
      ],
    );
  }
}
