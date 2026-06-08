import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/guest_message_model.dart';
import '../providers/messages_provider.dart';

// Recipient filter options
const _kFilters = [
  ('all',         'Everyone',          Icons.groups_rounded),
  ('awaiting',    'Awaiting RSVP',     Icons.hourglass_empty_rounded),
  ('not_invited', 'Not yet invited',   Icons.mail_outline_rounded),
  ('rsvp_status_attending', 'Attending', Icons.check_circle_outline_rounded),
  ('rsvp_status_declined',  'Declined',  Icons.cancel_outlined),
  ('vip',         'VIP guests',        Icons.star_border_rounded),
];

class MessagesTab extends ConsumerStatefulWidget {
  const MessagesTab({super.key});

  @override
  ConsumerState<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends ConsumerState<MessagesTab> {
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _selectedFilter = 'all';
  String _channel = 'in_app';
  bool _composing = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _recipientFilter {
    if (_selectedFilter.startsWith('rsvp_status_')) {
      return {'type': 'rsvp_status', 'value': _selectedFilter.split('_').last};
    }
    return {'type': _selectedFilter};
  }

  String get _filterLabel {
    return _kFilters
        .firstWhere((f) => f.$1 == _selectedFilter,
            orElse: () => _kFilters.first)
        .$2;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesNotifierProvider);
    final isSending = state.status == MessagesStatus.sending;

    return Column(children: [
      // ── Compose panel ───────────────────────────────────────────────
      AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        child: _composing
            ? _ComposePanel(
                subjectCtrl: _subjectCtrl,
                bodyCtrl: _bodyCtrl,
                selectedFilter: _selectedFilter,
                channel: _channel,
                isSending: isSending,
                filterLabel: _filterLabel,
                onFilterTap: _pickFilter,
                onChannelChange: (c) => setState(() => _channel = c),
                onSend: _send,
                onDiscard: () => setState(() {
                  _composing = false;
                  _subjectCtrl.clear();
                  _bodyCtrl.clear();
                }),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _NewMessageButton(
                  onTap: () => setState(() => _composing = true),
                ),
              ),
      ),

      // ── History ─────────────────────────────────────────────────────
      Expanded(
        child: state.status == MessagesStatus.loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.pinkGradientStart))
            : state.messages.isEmpty
                ? _EmptyHistory()
                : RefreshIndicator(
                    color: AppColors.pinkGradientStart,
                    onRefresh: () =>
                        ref.read(messagesNotifierProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      itemCount: state.messages.length,
                      itemBuilder: (_, i) => _MessageCard(
                        msg: state.messages[i],
                        onDelete: () => ref
                            .read(messagesNotifierProvider.notifier)
                            .delete(state.messages[i].id),
                      ),
                    ),
                  ),
      ),
    ]);
  }

  void _pickFilter() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(current: _selectedFilter),
    );
    if (picked != null) setState(() => _selectedFilter = picked);
  }

  Future<void> _send() async {
    final body = _bodyCtrl.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message body is required')),
      );
      return;
    }

    final ok = await ref.read(messagesNotifierProvider.notifier).send(
          subject: _subjectCtrl.text.trim().isEmpty
              ? null
              : _subjectCtrl.text.trim(),
          body: body,
          channel: _channel,
          recipientFilter: _recipientFilter,
        );

    if (!mounted) return;

    if (ok) {
      setState(() {
        _composing = false;
        _subjectCtrl.clear();
        _bodyCtrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message sent to $_filterLabel',
              style: GoogleFonts.dmSans(fontSize: 13)),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to send. Please try again.'),
            backgroundColor: Colors.redAccent),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NewMessageButton extends StatelessWidget {
  const _NewMessageButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.pinkGradientStart, AppColors.pinkGradientEnd],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text('New message',
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ]),
      ),
    );
  }
}

class _ComposePanel extends StatelessWidget {
  const _ComposePanel({
    required this.subjectCtrl,
    required this.bodyCtrl,
    required this.selectedFilter,
    required this.channel,
    required this.isSending,
    required this.filterLabel,
    required this.onFilterTap,
    required this.onChannelChange,
    required this.onSend,
    required this.onDiscard,
  });

  final TextEditingController subjectCtrl;
  final TextEditingController bodyCtrl;
  final String selectedFilter;
  final String channel;
  final bool isSending;
  final String filterLabel;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onChannelChange;
  final VoidCallback onSend;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Text('New message',
              style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey700)),
          const Spacer(),
          GestureDetector(
            onTap: onDiscard,
            child: const Icon(Icons.close_rounded,
                size: 20, color: AppColors.grey400),
          ),
        ]),
        const SizedBox(height: 12),

        // To: filter selector
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.blushLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              Text('To: ',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.grey500)),
              Text(filterLabel,
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pinkGradientStart)),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: AppColors.grey400),
            ]),
          ),
        ),
        const SizedBox(height: 10),

        // Channel selector
        Row(children: [
          Text('Via: ',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.grey500)),
          const SizedBox(width: 6),
          ...[
            ('in_app', 'In-app', Icons.notifications_rounded),
            ('email', 'Email', Icons.email_outlined),
            ('sms', 'SMS', Icons.sms_outlined),
          ].map((c) {
            final (val, label, icon) = c;
            final selected = channel == val;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => onChannelChange(val),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.pinkGradientStart
                        : AppColors.grey100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon,
                        size: 13,
                        color: selected ? Colors.white : AppColors.grey500),
                    const SizedBox(width: 4),
                    Text(label,
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: selected ? Colors.white : AppColors.grey600)),
                  ]),
                ),
              ),
            );
          }),
        ]),
        const SizedBox(height: 10),

        // Subject
        TextField(
          controller: subjectCtrl,
          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey700),
          decoration: InputDecoration(
            hintText: 'Subject (optional)',
            hintStyle: GoogleFonts.dmSans(
                fontSize: 13, color: AppColors.grey400),
            filled: true,
            fillColor: AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),

        // Body
        TextField(
          controller: bodyCtrl,
          maxLines: 4,
          maxLength: 5000,
          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey700),
          decoration: InputDecoration(
            hintText: 'Write your message…',
            hintStyle: GoogleFonts.dmSans(
                fontSize: 13, color: AppColors.grey400),
            filled: true,
            fillColor: AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 10),

        // Send button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSending ? null : onSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinkGradientStart,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.grey300,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Text('Send message',
                    style: GoogleFonts.dmSans(
                        fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({required this.current});
  final String current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Send to',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey700)),
        ),
        const SizedBox(height: 12),
        ..._kFilters.map((f) {
          final (val, label, icon) = f;
          final selected = current == val;
          return ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.pinkGradientStart.withValues(alpha: 0.12)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 18,
                  color: selected
                      ? AppColors.pinkGradientStart
                      : AppColors.grey500),
            ),
            title: Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? AppColors.pinkGradientStart
                        : AppColors.grey700)),
            trailing: selected
                ? const Icon(Icons.check_rounded,
                    color: AppColors.pinkGradientStart, size: 20)
                : null,
            onTap: () => Navigator.of(context).pop(val),
          );
        }),
      ]),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.msg, required this.onDelete});

  final GuestMessageModel msg;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey100),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _ChannelBadge(channel: msg.channel),
            const SizedBox(width: 8),
            _RecipientBadge(filter: msg.recipientFilter, count: msg.recipientCount),
            const Spacer(),
            GestureDetector(
              onTap: () => _confirmDelete(context),
              child: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColors.grey300),
            ),
          ]),
          if (msg.subject != null && msg.subject!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(msg.subject!,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey700)),
          ],
          const SizedBox(height: 6),
          Text(msg.body,
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppColors.grey600, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text(_formatDate(msg.sentAt ?? msg.createdAt),
              style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppColors.grey400)),
        ]),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete message',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.w700, fontSize: 17)),
        content: Text('This will permanently remove the message from your history.',
            style: GoogleFonts.dmSans(fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month]} ${dt.day}, ${dt.year} · ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}

class _ChannelBadge extends StatelessWidget {
  const _ChannelBadge({required this.channel});
  final String channel;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (channel) {
      'email'  => ('Email', const Color(0xFF3B82F6)),
      'sms'    => ('SMS', const Color(0xFF10B981)),
      _        => ('In-app', AppColors.pinkGradientStart),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _RecipientBadge extends StatelessWidget {
  const _RecipientBadge({required this.filter, required this.count});
  final Map<String, dynamic> filter;
  final int count;

  @override
  Widget build(BuildContext context) {
    final type = (filter['type'] as String?) ?? 'all';
    final label = switch (type) {
      'rsvp_status' => (filter['value'] as String?) ?? type,
      'awaiting'    => 'awaiting',
      'not_invited' => 'not invited',
      'vip'         => 'VIP',
      _             => 'everyone',
    };
    return Text('→ $label ($count)',
        style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.grey500));
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.chat_bubble_outline_rounded,
              size: 52, color: AppColors.grey300),
          const SizedBox(height: 14),
          Text('No messages yet',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey700)),
          const SizedBox(height: 6),
          Text(
            'Send your first broadcast to keep guests informed.',
            style: GoogleFonts.dmSans(
                fontSize: 13, color: AppColors.grey500, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }
}
