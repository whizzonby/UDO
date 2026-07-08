import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppTheme.udoBackground,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        title: const Text('More', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
      ),
      body: ListView(
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: 8),
          _Section(title: 'Wedding', items: [
            _MenuItem(icon: Icons.people_outline, label: 'Collaborators', onTap: () => context.go('/guests')),
            _MenuItem(icon: Icons.how_to_vote_outlined, label: 'Decision-makers', onTap: () => _showDecisionMakers(context)),
            _MenuItem(icon: Icons.send_outlined, label: 'Messages', onTap: () => context.go('/guests')),
            _MenuItem(icon: Icons.chair_outlined, label: 'Seating plan', onTap: () => context.go('/guests')),
            _MenuItem(icon: Icons.local_taxi_outlined, label: 'Logistics', onTap: () => context.go('/guests')),
            _MenuItem(icon: Icons.web_outlined, label: 'Guest experience', onTap: () => context.go('/guests')),
          ]),
          const SizedBox(height: 8),
          _Section(title: 'Account', items: [
            _MenuItem(icon: Icons.person_outline, label: 'Profile', onTap: () => _showProfile(context, user)),
            _MenuItem(
              icon: Icons.workspace_premium_outlined,
              label: 'Subscription & Wedding Pass',
              onTap: () => _showSubscription(context),
              badge: 'Pro',
            ),
            _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () => _showNotifications(context)),
            _MenuItem(icon: Icons.security_outlined, label: 'Privacy & Security', onTap: () => _showPrivacy(context)),
          ]),
          const SizedBox(height: 8),
          _Section(title: 'Support', items: [
            _MenuItem(icon: Icons.help_outline, label: 'Help centre', onTap: () => _showHelp(context)),
            _MenuItem(icon: Icons.tune_outlined, label: 'Support preferences', onTap: () => _showSupportPrefs(context)),
            _MenuItem(icon: Icons.feedback_outlined, label: 'Send feedback', onTap: () => _showFeedback(context)),
          ]),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => _confirmLogout(context, ref),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.udoCrimson),
                foregroundColor: AppTheme.udoCrimson,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 32),
          const Center(child: Text('Udo v1.0.0', style: TextStyle(color: AppTheme.udoTextSecondary, fontSize: 12))),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showDecisionMakers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _DecisionMakersSheet(),
    );
  }

  void _showSubscription(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _SubscriptionSheet(),
    );
  }

  void _showSupportPrefs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _SupportPrefsSheet(),
    );
  }

  void _showProfile(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ProfileSheet(user: user),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _NotificationsSheet(),
    );
  }

  void _showPrivacy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _PrivacySheet(),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _HelpSheet(),
    );
  }

  void _showFeedback(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _FeedbackSheet(),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You\'ll need to sign in again to access your wedding plan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Log out', style: TextStyle(color: AppTheme.udoCrimson)),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName ?? 'Welcome';
    final email = user?.email ?? '';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        CircleAvatar(
          radius: 28, backgroundColor: AppTheme.udoGreen,
          backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl as String) : null,
          child: user?.avatarUrl == null ? Text(initials, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)) : null,
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Text(email, style: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13)),
        ])),
        const Icon(Icons.chevron_right, color: AppTheme.udoTextSecondary),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.udoTextSecondary, letterSpacing: 0.5)),
      ),
      Container(
        color: Colors.white,
        child: Column(children: items),
      ),
    ]);
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Icon(icon, size: 20, color: AppTheme.udoTextPrimary),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          if (badge != null) Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppTheme.udoGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(badge!, style: const TextStyle(fontSize: 11, color: AppTheme.udoGreen, fontWeight: FontWeight.w600)),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppTheme.udoTextSecondary),
        ]),
      ),
    );
  }
}

// ── DECISION MAKERS SHEET ──────────────────────────────────────────────────────

class _DecisionMakersSheet extends StatefulWidget {
  const _DecisionMakersSheet();
  @override
  State<_DecisionMakersSheet> createState() => _DecisionMakersSheetState();
}

class _DecisionMakersSheetState extends State<_DecisionMakersSheet> {
  final _makers = <Map<String, String>>[];

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Decision-makers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
        ]),
        const SizedBox(height: 4),
        const Text('People who can approve decisions and access your wedding plan.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
        const SizedBox(height: 16),
        if (_makers.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Column(children: [
              Icon(Icons.people_outline, size: 36, color: AppTheme.udoTextSecondary),
              SizedBox(height: 8),
              Text('No decision-makers yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text('Add people who can approve decisions for your wedding.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
            ])),
          )
        else
          for (final m in _makers) Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              CircleAvatar(radius: 18, backgroundColor: AppTheme.udoGreen.withValues(alpha: 0.15), child: Text((m['name'] ?? '?')[0], style: const TextStyle(color: AppTheme.udoGreen, fontWeight: FontWeight.w700))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m['name'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(m['role'] ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: m['access'] == 'full' ? AppTheme.udoGreen.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(m['access'] == 'full' ? 'Full access' : 'Budget only', style: TextStyle(fontSize: 10, color: m['access'] == 'full' ? AppTheme.udoGreen : Colors.orange, fontWeight: FontWeight.w500)),
              ),
            ]),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.person_add_outlined, size: 16),
          label: const Text('Add decision-maker'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
        ),
      ]),
    ),
  );
}

// ── SUBSCRIPTION SHEET ─────────────────────────────────────────────────────────

class _SubscriptionSheet extends StatelessWidget {
  const _SubscriptionSheet();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Wedding Pass', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
        ]),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.udoGreen, Color(0xFF3D7A01)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.workspace_premium, color: Colors.amber, size: 22),
              SizedBox(width: 8),
              Text('Pro Plan · Active', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ]),
            SizedBox(height: 8),
            Text('Renews August 14, 2026', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 16),
        const Text('Included features', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        for (final f in ['Unlimited guests', 'AI day simulation', 'Guest portal & RSVP', 'Real-time coordinator mode', 'Registry & gift tracking', 'Priority support'])
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.udoGreen, size: 18),
            const SizedBox(width: 10),
            Text(f, style: const TextStyle(fontSize: 14)),
          ])),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: AppTheme.udoBorder), foregroundColor: AppTheme.udoTextSecondary),
          child: const Text('Manage subscription'),
        ),
      ]),
    ),
  );
}

// ── SUPPORT PREFERENCES SHEET ──────────────────────────────────────────────────

class _SupportPrefsSheet extends StatefulWidget {
  const _SupportPrefsSheet();
  @override
  State<_SupportPrefsSheet> createState() => _SupportPrefsSheetState();
}

class _SupportPrefsSheetState extends State<_SupportPrefsSheet> {
  bool _emailSupport = true;
  bool _chatSupport = false;
  bool _proactiveCheckins = true;
  String _responseTime = 'within-24h';

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Support preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
        ]),
        const SizedBox(height: 16),
        _ToggleRow('Email support', 'Receive support via email', _emailSupport, (v) => setState(() => _emailSupport = v)),
        _ToggleRow('Live chat', 'Chat with our support team', _chatSupport, (v) => setState(() => _chatSupport = v)),
        _ToggleRow('Proactive check-ins', 'We\'ll check in on key planning milestones', _proactiveCheckins, (v) => setState(() => _proactiveCheckins = v)),
        const SizedBox(height: 12),
        const Text('Preferred response time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        for (final (val, label) in [('within-1h', 'Within 1 hour'), ('within-24h', 'Within 24 hours'), ('within-3d', 'Within 3 days')])
          RadioListTile<String>(
            value: val, groupValue: _responseTime,
            title: Text(label, style: const TextStyle(fontSize: 14)),
            activeColor: AppTheme.udoGreen,
            contentPadding: EdgeInsets.zero,
            onChanged: (v) => setState(() => _responseTime = v ?? 'within-24h'),
          ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
          child: const Text('Save preferences'),
        ),
      ]),
    ),
  );
}

Widget _ToggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
      ])),
      Switch(value: value, onChanged: onChanged, activeColor: AppTheme.udoGreen),
    ]),
  ),
);

// ── PROFILE SHEET ──────────────────────────────────────────────────────────────

class _ProfileSheet extends StatefulWidget {
  final dynamic user;
  const _ProfileSheet({required this.user});
  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  late final TextEditingController _name;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user?.fullName ?? '');
    _email = TextEditingController(text: widget.user?.email ?? '');
  }

  @override
  void dispose() { _name.dispose(); _email.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
        ]),
        const SizedBox(height: 16),
        const Text('Full name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(controller: _name, decoration: _dec('Your name')),
        const SizedBox(height: 12),
        const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: _dec('Email address')),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
          child: const Text('Save changes'),
        ),
      ]),
    ),
  );

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14),
    filled: true, fillColor: const Color(0xFFF3EFEA),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.udoGreen, width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

// ── NOTIFICATIONS SHEET ────────────────────────────────────────────────────────

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet();
  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  bool _rsvpUpdates = true;
  bool _taskReminders = true;
  bool _guestMessages = true;
  bool _liveMode = true;
  bool _vendorUpdates = false;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
        ]),
        const SizedBox(height: 16),
        _ToggleRow('RSVP updates', 'When guests respond to invitations', _rsvpUpdates, (v) => setState(() => _rsvpUpdates = v)),
        _ToggleRow('Task reminders', 'Upcoming planning deadlines', _taskReminders, (v) => setState(() => _taskReminders = v)),
        _ToggleRow('Guest messages', 'New messages from guests', _guestMessages, (v) => setState(() => _guestMessages = v)),
        _ToggleRow('Live mode', 'Day-of alerts and coordinator updates', _liveMode, (v) => setState(() => _liveMode = v)),
        _ToggleRow('Vendor updates', 'Confirmations and reminders', _vendorUpdates, (v) => setState(() => _vendorUpdates = v)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
          child: const Text('Save'),
        ),
      ]),
    ),
  );
}

// ── PRIVACY SHEET ──────────────────────────────────────────────────────────────

class _PrivacySheet extends StatelessWidget {
  const _PrivacySheet();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Privacy & Security', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
        ]),
        const SizedBox(height: 16),
        for (final (icon, title, subtitle) in [
          (Icons.lock_outline, 'Password', 'Change your account password'),
          (Icons.phone_iphone_outlined, 'Two-factor authentication', 'Add an extra layer of security'),
          (Icons.visibility_outlined, 'Guest portal visibility', 'Control what guests can see'),
          (Icons.delete_outline, 'Delete account', 'Permanently remove your account'),
        ])
          ListTile(
            leading: Icon(icon, color: AppTheme.udoTextPrimary, size: 20),
            title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
            trailing: const Icon(Icons.chevron_right, size: 18, color: AppTheme.udoTextSecondary),
            contentPadding: EdgeInsets.zero,
            onTap: () {},
          ),
      ]),
    ),
  );
}

// ── HELP SHEET ─────────────────────────────────────────────────────────────────

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Help centre', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
        ]),
        const SizedBox(height: 16),
        for (final q in [
          'How do I add guests?',
          'How does the RSVP system work?',
          'Can I add multiple collaborators?',
          'How do I set up the guest portal?',
          'How do I export my guest list?',
        ])
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(q, style: const TextStyle(fontSize: 14)),
              trailing: const Icon(Icons.chevron_right, size: 18, color: AppTheme.udoTextSecondary),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              tileColor: const Color(0xFFF3EFEA),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {},
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chat_bubble_outline, size: 16),
          label: const Text('Contact support'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
        ),
      ]),
    ),
  );
}

// ── FEEDBACK SHEET ─────────────────────────────────────────────────────────────

class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet();
  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final _ctrl = TextEditingController();
  int _rating = 0;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Send feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
        ]),
        const SizedBox(height: 8),
        const Text('How would you rate Udo?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(children: List.generate(5, (i) => GestureDetector(
          onTap: () => setState(() => _rating = i + 1),
          child: Icon(i < _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
        ))),
        const SizedBox(height: 16),
        const Text('Tell us more', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: _ctrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'What could we improve?',
            hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14),
            filled: true, fillColor: const Color(0xFFF3EFEA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for your feedback!')));
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
          child: const Text('Submit feedback'),
        ),
      ]),
    ),
  );
}
