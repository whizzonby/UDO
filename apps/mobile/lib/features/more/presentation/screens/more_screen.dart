import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/udo_design_system.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/about_provider.dart';
import '../providers/ai_assistant_provider.dart';
import '../providers/more_operations_provider.dart';
import 'ai_assistant_chat_screen.dart';
import 'content_page_screen.dart';
import 'release_notes_screen.dart';

const _moreAccent = Color(0xFF4B4D52);

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final operations = ref.watch(moreOperationsProvider);
    final planLabel = operations.entitlements?['label']?.toString() ??
        user?.subscription?['label']?.toString() ??
        'Free';
    final activeWedding = operations.activeWedding ??
        (operations.weddings
                .where((wedding) => wedding['is_active'] == true)
                .isNotEmpty
            ? operations.weddings
                .firstWhere((wedding) => wedding['is_active'] == true)
            : null);
    final pendingApprovals = operations.approvals
        .where((approval) => approval['status'] == 'pending')
        .length;
    final appVersion = ref.watch(packageInfoProvider).valueOrNull?.version ?? '1.0.0';

    return Scaffold(
      backgroundColor: UdoDesign.bg,
      drawerScrimColor: Colors.black.withValues(alpha: 0.16),
      drawer: _MoreNavigationDrawer(
        user: user,
        operations: operations,
        planLabel: planLabel,
        onWorkspace: () => _showWeddings(context),
        onSettings: () => _showWeddingSettings(context),
        onCollaborators: () => _showCollaborators(context, ref),
        onAssistant: () => _showAssistant(context, operations),
        onProfile: () => _showProfile(context, user),
        onSubscription: () => _showSubscription(
            context, operations.entitlements ?? user?.subscription),
        onActivity: () => _showActivity(context, ref),
        onNotifications: () => _showNotifications(context),
        onPrivacy: () => _showPrivacy(context),
        onHelp: () => _showHelp(context),
        onContact: () => _showContactSupport(context),
        onFeedback: () => _showFeedback(context),
        onAbout: () => _showAbout(context),
      ),
      appBar: AppBar(
        backgroundColor: UdoDesign.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'More sections',
            icon: const Icon(Icons.menu_rounded, color: UdoDesign.text),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text('More', style: UdoDesign.serif(size: 46, color: UdoDesign.text)),
          const SizedBox(height: 6),
          Text(
            'Manage your wedding workspace, account and preferences.',
            style: UdoDesign.sans(size: 15, color: UdoDesign.sub, height: 1.45),
          ),
          const SizedBox(height: 24),
          _WorkspaceProfileCard(
            user: user,
            wedding: activeWedding,
            planLabel: planLabel,
            onTap: () => _showProfile(context, user),
          ),
          const SizedBox(height: 24),
          _HubStatusStrip(
            items: [
              _HubStatusItem(
                  label: 'Workspaces',
                  value: operations.weddings.length.toString(),
                  icon: Icons.event_available_outlined),
              _HubStatusItem(
                  label: 'Collaborators',
                  value: operations.team.length.toString(),
                  icon: Icons.groups_2_outlined),
              _HubStatusItem(
                  label: 'Approvals',
                  value: pendingApprovals.toString(),
                  icon: Icons.how_to_vote_outlined),
              _HubStatusItem(
                  label: 'Activity',
                  value: operations.auditLogs.length.toString(),
                  icon: Icons.manage_search_outlined),
            ],
          ),
          const SizedBox(height: 28),
          _MoreCommandSection(
            title: 'Wedding',
            subtitle:
                'Run the workspace, permissions and connected wedding tools.',
            items: [
              _MoreCommandItem(
                  icon: Icons.event_available_outlined,
                  title: 'Wedding Workspace',
                  subtitle: 'Manage multiple weddings and archived workspaces.',
                  badge: operations.weddings.isEmpty
                      ? null
                      : '${operations.weddings.length}',
                  onTap: () => _showWeddings(context)),
              _MoreCommandItem(
                  icon: Icons.settings_outlined,
                  title: 'Wedding Settings',
                  subtitle:
                      'Everything about your wedding, venue and preferences.',
                  onTap: () => _showWeddingSettings(context)),
              _MoreCommandItem(
                  icon: Icons.people_outline,
                  title: 'Collaborators',
                  subtitle: 'Invite family, planners and vendors.',
                  badge: operations.team.isEmpty
                      ? null
                      : '${operations.team.length}',
                  onTap: () => _showCollaborators(context, ref)),
              _MoreCommandItem(
                  icon: Icons.how_to_vote_outlined,
                  title: 'Decision-makers',
                  subtitle: 'Approval roles for budget, vendors and key calls.',
                  badge: pendingApprovals == 0 ? null : '$pendingApprovals',
                  onTap: () => _showDecisionMakers(context)),
              _MoreCommandItem(
                  icon: Icons.auto_awesome_outlined,
                  title: 'AI Wedding Assistant',
                  subtitle:
                      'Daily recommendations, insights and planning guidance.',
                  onTap: () => _showAssistant(context, operations)),
            ],
          ),
          const SizedBox(height: 22),
          _MoreCommandSection(
            title: 'Account',
            subtitle:
                'Personal settings, pass access, notifications and security.',
            items: [
              _MoreCommandItem(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  subtitle: 'Name, email, photo, phone and preferences.',
                  onTap: () => _showProfile(context, user)),
              _MoreCommandItem(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Subscription & Wedding Pass',
                  subtitle: 'Plan, features, usage and billing access.',
                  badge: planLabel,
                  onTap: () => _showSubscription(
                      context, operations.entitlements ?? user?.subscription)),
              _MoreCommandItem(
                  icon: Icons.manage_search_outlined,
                  title: 'Activity Log',
                  subtitle:
                      'Track updates across guests, budget, gallery and team.',
                  badge: operations.auditLogs.isEmpty
                      ? null
                      : '${operations.auditLogs.length}',
                  onTap: () => _showActivity(context, ref)),
              _MoreCommandItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Push, email, reminders and quiet hours.',
                  onTap: () => _showNotifications(context)),
              _MoreCommandItem(
                  icon: Icons.security_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'Password, devices, sessions and data controls.',
                  onTap: () => _showPrivacy(context)),
            ],
          ),
          const SizedBox(height: 22),
          _MoreCommandSection(
            title: 'Support',
            subtitle: 'Help, contact options and product feedback.',
            items: [
              _MoreCommandItem(
                  icon: Icons.help_outline,
                  title: 'Help Centre',
                  subtitle: 'Search guides, FAQs and getting started notes.',
                  onTap: () => _showHelp(context)),
              _MoreCommandItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Contact Support',
                  subtitle: 'Live chat, email, WhatsApp and ticket history.',
                  onTap: () => _showContactSupport(context)),
              _MoreCommandItem(
                  icon: Icons.tune_outlined,
                  title: 'Support Preferences',
                  subtitle: 'Choose response channels and concierge style.',
                  onTap: () => _showSupportPrefs(context)),
              _MoreCommandItem(
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle:
                      'Submit ideas, report bugs and rate your experience.',
                  onTap: () => _showFeedback(context)),
            ],
          ),
          const SizedBox(height: 22),
          _MoreCommandSection(
            title: 'About',
            items: [
              _MoreCommandItem(
                  icon: Icons.new_releases_outlined,
                  title: 'What’s New',
                  subtitle:
                      'Version history, policies, licences and company details.',
                  onTap: () => _showAbout(context)),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => _confirmLogout(context, ref),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _moreAccent.withValues(alpha: 0.28)),
              foregroundColor: _moreAccent,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            child: Text('Sign Out',
                style: UdoDesign.sans(
                    size: 15, weight: FontWeight.w700, color: _moreAccent)),
          ),
          const SizedBox(height: 16),
          Center(
              child: Text('Udo v$appVersion',
                  style: UdoDesign.sans(size: 12, color: UdoDesign.muted))),
        ],
      ),
    );
  }

  void _showDecisionMakers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _DecisionMakersSheet(),
    );
  }

  void _showCollaborators(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _CollaboratorsSheet(),
    );
  }

  void _showWeddings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _WeddingWorkspacesSheet(),
    );
  }

  void _showWeddingSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const WeddingSettingsSheet(),
    );
  }

  void _showActivity(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _ActivitySheet(),
    );
  }

  void _showSubscription(
      BuildContext context, Map<String, dynamic>? entitlements) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _LiveSubscriptionSheet(entitlements: entitlements),
    );
  }

  void _showSupportPrefs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _SupportPrefsSheet(),
    );
  }

  void _showProfile(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ProfileSheet(user: user),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _NotificationsSheet(),
    );
  }

  void _showPrivacy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _PrivacySheet(),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _HelpSheet(),
    );
  }

  void _showFeedback(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _FeedbackSheet(),
    );
  }

  void _showAssistant(BuildContext context, MoreOperationsState operations) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AiAssistantSheet(operations: operations),
    );
  }

  void _showContactSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _ContactSupportSheet(),
    );
  }

  void _showAbout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _AboutSheet(),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
            'You\'ll need to sign in again to access your wedding workspace.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Log out',
                style: TextStyle(color: AppTheme.udoCrimson)),
          ),
        ],
      ),
    );
  }
}

class _MoreNavigationDrawer extends StatelessWidget {
  final dynamic user;
  final MoreOperationsState operations;
  final String planLabel;
  final VoidCallback onWorkspace;
  final VoidCallback onSettings;
  final VoidCallback onCollaborators;
  final VoidCallback onAssistant;
  final VoidCallback onProfile;
  final VoidCallback onSubscription;
  final VoidCallback onActivity;
  final VoidCallback onNotifications;
  final VoidCallback onPrivacy;
  final VoidCallback onHelp;
  final VoidCallback onContact;
  final VoidCallback onFeedback;
  final VoidCallback onAbout;

  const _MoreNavigationDrawer({
    required this.user,
    required this.operations,
    required this.planLabel,
    required this.onWorkspace,
    required this.onSettings,
    required this.onCollaborators,
    required this.onAssistant,
    required this.onProfile,
    required this.onSubscription,
    required this.onActivity,
    required this.onNotifications,
    required this.onPrivacy,
    required this.onHelp,
    required this.onContact,
    required this.onFeedback,
    required this.onAbout,
  });

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName ?? 'Welcome';
    final email = user?.email ?? '';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.85,
      backgroundColor: UdoDesign.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(28))),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 18, 24),
          children: [
            Row(children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _moreAccent,
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl as String)
                    : null,
                child: user?.avatarUrl == null
                    ? Text(initials,
                        style: UdoDesign.sans(
                            size: 18,
                            weight: FontWeight.w700,
                            color: Colors.white))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            UdoDesign.sans(size: 15, weight: FontWeight.w700)),
                    Text(email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            UdoDesign.sans(size: 12, color: UdoDesign.muted)),
                  ])),
            ]),
            const SizedBox(height: 26),
            Text('More', style: UdoDesign.serif(size: 34)),
            const SizedBox(height: 4),
            Text('Workspace and account controls.',
                style: UdoDesign.sans(size: 13, color: UdoDesign.sub)),
            const SizedBox(height: 24),
            _DrawerLink(
                icon: Icons.event_available_outlined,
                label: 'Wedding Workspace',
                onTap: onWorkspace,
                badge: operations.weddings.isEmpty
                    ? null
                    : '${operations.weddings.length}'),
            _DrawerLink(
                icon: Icons.settings_outlined,
                label: 'Wedding Settings',
                onTap: onSettings),
            _DrawerLink(
                icon: Icons.people_outline,
                label: 'Collaborators',
                onTap: onCollaborators,
                badge: operations.team.isEmpty
                    ? null
                    : '${operations.team.length}'),
            _DrawerLink(
                icon: Icons.auto_awesome_outlined,
                label: 'AI Wedding Assistant',
                onTap: onAssistant),
            _DrawerLink(
                icon: Icons.person_outline, label: 'Profile', onTap: onProfile),
            _DrawerLink(
                icon: Icons.workspace_premium_outlined,
                label: 'Subscription',
                onTap: onSubscription,
                badge: planLabel),
            _DrawerLink(
                icon: Icons.manage_search_outlined,
                label: 'Activity Log',
                onTap: onActivity),
            _DrawerLink(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: onNotifications),
            _DrawerLink(
                icon: Icons.security_outlined,
                label: 'Privacy & Security',
                onTap: onPrivacy),
            _DrawerLink(
                icon: Icons.help_outline, label: 'Help Centre', onTap: onHelp),
            _DrawerLink(
                icon: Icons.chat_bubble_outline,
                label: 'Contact Support',
                onTap: onContact),
            _DrawerLink(
                icon: Icons.feedback_outlined,
                label: 'Send Feedback',
                onTap: onFeedback),
            _DrawerLink(
                icon: Icons.info_outline, label: 'About', onTap: onAbout),
          ],
        ),
      ),
    );
  }
}

class _DrawerLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;

  const _DrawerLink(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.badge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        minLeadingWidth: 20,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon, size: 20, color: _moreAccent),
        title: Text(label,
            style: UdoDesign.sans(size: 14, weight: FontWeight.w600)),
        trailing: badge == null
            ? const Icon(Icons.chevron_right, size: 16, color: UdoDesign.muted)
            : UdoBadge(label: badge!, color: _moreAccent),
        onTap: () {
          Navigator.pop(context);
          Future<void>.delayed(const Duration(milliseconds: 180), onTap);
        },
      ),
    );
  }
}

class _WorkspaceProfileCard extends StatelessWidget {
  final dynamic user;
  final Map<String, dynamic>? wedding;
  final String planLabel;
  final VoidCallback onTap;

  const _WorkspaceProfileCard(
      {required this.user,
      required this.wedding,
      required this.planLabel,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName?.toString() ?? 'Your wedding team';
    final email = user?.email?.toString() ?? 'Account owner';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final weddingTitle =
        wedding == null ? 'Wedding workspace' : _weddingTitle(wedding!);
    final weddingDate = _dateOnly(wedding?['event_date']);
    final city = [wedding?['city']?.toString(), wedding?['country']?.toString()]
        .where((item) => item != null && item.trim().isNotEmpty)
        .join(', ');
    final stage = wedding?['planning_stage']?.toString() ??
        wedding?['status']?.toString() ??
        'Planning';

    return UdoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: _moreAccent,
            backgroundImage: user?.avatarUrl != null
                ? NetworkImage(user!.avatarUrl as String)
                : null,
            child: user?.avatarUrl == null
                ? Text(initials,
                    style: UdoDesign.sans(
                        size: 23, weight: FontWeight.w700, color: Colors.white))
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UdoDesign.sans(size: 17, weight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UdoDesign.sans(size: 13, color: UdoDesign.muted)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  UdoBadge(label: _humanize(stage), color: _moreAccent),
                  UdoBadge(label: planLabel, color: UdoDesign.gold),
                ]),
              ])),
          const Icon(Icons.chevron_right, color: UdoDesign.muted),
        ]),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: UdoDesign.bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: UdoDesign.border),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(weddingTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UdoDesign.serif(size: 24, height: 1.05)),
            const SizedBox(height: 6),
            Text(
              [
                if (weddingDate.isNotEmpty) weddingDate,
                if (city.isNotEmpty) city
              ].join(' - ').isEmpty
                  ? 'Workspace details ready to complete'
                  : [
                      if (weddingDate.isNotEmpty) weddingDate,
                      if (city.isNotEmpty) city
                    ].join(' - '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.sans(size: 13, color: UdoDesign.sub),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _HubStatusItem {
  final String label;
  final String value;
  final IconData icon;
  const _HubStatusItem(
      {required this.label, required this.value, required this.icon});
}

class _HubStatusStrip extends StatelessWidget {
  final List<_HubStatusItem> items;
  const _HubStatusStrip({required this.items});

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(children: [
        for (var index = 0; index < items.length; index++) ...[
          Expanded(child: _HubStatusTile(item: items[index])),
          if (index != items.length - 1)
            Container(width: 1, height: 42, color: UdoDesign.border),
        ],
      ]),
    );
  }
}

class _HubStatusTile extends StatelessWidget {
  final _HubStatusItem item;
  const _HubStatusTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(item.icon, color: _moreAccent, size: 19),
      const SizedBox(height: 6),
      Text(item.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: UdoDesign.sans(size: 15, weight: FontWeight.w700)),
      Text(item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: UdoDesign.sans(size: 10, color: UdoDesign.muted)),
    ]);
  }
}

class _MoreCommandSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<_MoreCommandItem> items;

  const _MoreCommandSection(
      {required this.title, required this.items, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      UdoSectionHeader(title: title, subtitle: subtitle),
      UdoCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          for (var index = 0; index < items.length; index++) ...[
            items[index],
            if (index != items.length - 1)
              const Divider(height: 1, thickness: 1, color: UdoDesign.border),
          ],
        ]),
      ),
    ]);
  }
}

class _MoreCommandItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  const _MoreCommandItem(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.badge});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: _moreAccent.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, size: 19, color: _moreAccent),
          ),
          const SizedBox(width: 13),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UdoDesign.sans(size: 14, weight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: UdoDesign.sans(
                        size: 12, color: UdoDesign.muted, height: 1.3)),
              ])),
          const SizedBox(width: 10),
          if (badge != null) UdoBadge(label: badge!, color: _moreAccent),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: UdoDesign.muted),
        ]),
      ),
    );
  }
}

// ── DECISION MAKERS SHEET ──────────────────────────────────────────────────────

class _DecisionMakersSheet extends ConsumerWidget {
  const _DecisionMakersSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operations = ref.watch(moreOperationsProvider);
    final makers =
        operations.team.where((m) => m['is_decision_maker'] == true).toList();
    final currentUserId = ref.watch(authProvider).user?.id;
    final myCollaboratorId = operations.team.firstWhere(
        (m) => m['user_id'] == currentUserId,
        orElse: () => const {})['id'] as int?;
    final pendingApprovals =
        operations.approvals.where((a) => a['status'] == 'pending').toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(
                    child: Text('Decision-makers',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero),
              ]),
              const SizedBox(height: 4),
              const Text(
                  'Collaborators marked to consult before key decisions in specific areas.',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.udoTextSecondary)),
              const SizedBox(height: 16),
              if (pendingApprovals.isNotEmpty) ...[
                const Text('Pending approvals',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                for (final approval in pendingApprovals)
                  _ApprovalRow(
                      approval: approval, myCollaboratorId: myCollaboratorId),
                const SizedBox(height: 16),
              ],
              if (makers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppTheme.udoCardFill,
                      borderRadius: BorderRadius.circular(14)),
                  child: const Center(
                      child: Column(children: [
                    Icon(Icons.people_outline,
                        size: 36, color: AppTheme.udoTextSecondary),
                    SizedBox(height: 8),
                    Text('No decision-makers yet',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Text(
                        'Mark a collaborator as a decision-maker from Collaborators.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.udoTextSecondary)),
                  ])),
                )
              else
                for (final m in makers)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: AppTheme.udoCardFill,
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              AppTheme.udoGreen.withValues(alpha: 0.15),
                          child: Text(
                              ((m['name'] as String?) ?? '?').isEmpty
                                  ? '?'
                                  : (m['name'] as String)[0].toUpperCase(),
                              style: const TextStyle(
                                  color: AppTheme.udoGreen,
                                  fontWeight: FontWeight.w700))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(m['name']?.toString() ?? '',
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w500)),
                            Text(_humanize(m['role']?.toString() ?? ''),
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.udoTextSecondary)),
                            if ((m['approval_categories'] as List? ?? [])
                                .isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: (m['approval_categories'] as List)
                                      .map((c) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                                color: AppTheme.udoGreen
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Text(_humanize(c.toString()),
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: AppTheme.udoGreen,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ))
                                      .toList()),
                            ],
                          ])),
                    ]),
                  ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (_) => const _CollaboratorsSheet(),
                  );
                },
                icon: const Icon(Icons.people_outline, size: 16),
                label: const Text('Manage in Collaborators'),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: AppTheme.udoGreen),
                    foregroundColor: AppTheme.udoGreen),
              ),
            ]),
      ),
    );
  }
}

class _ApprovalRow extends ConsumerStatefulWidget {
  final Map<String, dynamic> approval;
  final int? myCollaboratorId;
  const _ApprovalRow({required this.approval, required this.myCollaboratorId});

  @override
  ConsumerState<_ApprovalRow> createState() => _ApprovalRowState();
}

class _ApprovalRowState extends ConsumerState<_ApprovalRow> {
  bool _voting = false;

  Future<void> _vote(String decision) async {
    setState(() => _voting = true);
    final ok = await ref
        .read(moreOperationsProvider.notifier)
        .voteOnApproval(widget.approval['id'] as int, decision);
    if (!mounted) return;
    setState(() => _voting = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Couldn't record your decision. Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final approval = widget.approval;
    final requiredApprovers = (approval['required_approvers'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    final votes =
        (approval['votes'] as List? ?? []).cast<Map<String, dynamic>>();
    final approvedIds = votes
        .where((v) => v['decision'] == 'approve')
        .map((v) => v['collaborator_id'])
        .toSet();
    final canVote = widget.myCollaboratorId != null &&
        requiredApprovers.any((a) => a['id'] == widget.myCollaboratorId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFFFF7E6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(approval['title']?.toString() ?? 'Awaiting approval',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        if ((approval['description'] as String?)?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(approval['description'] as String,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary)),
        ],
        const SizedBox(height: 6),
        Text(
          '${approvedIds.length} of ${requiredApprovers.length} approvals · requested by ${approval['requested_by'] ?? 'a collaborator'}',
          style:
              const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary),
        ),
        if (canVote) ...[
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: OutlinedButton(
              onPressed: _voting ? null : () => _vote('reject'),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  side: const BorderSide(color: AppTheme.udoCrimson),
                  foregroundColor: AppTheme.udoCrimson),
              child: const Text('Reject', style: TextStyle(fontSize: 12)),
            )),
            const SizedBox(width: 8),
            Expanded(
                child: ElevatedButton(
              onPressed: _voting ? null : () => _vote('approve'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  backgroundColor: AppTheme.udoGreen,
                  foregroundColor: Colors.white),
              child: _voting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Approve', style: TextStyle(fontSize: 12)),
            )),
          ]),
        ],
      ]),
    );
  }
}

// ── SUBSCRIPTION SHEET ─────────────────────────────────────────────────────────

class SubscriptionSheet extends StatelessWidget {
  const SubscriptionSheet({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Expanded(
                      child: Text('Wedding Pass',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600))),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero),
                ]),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppTheme.udoGreen, Color(0xFF3D7A01)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.workspace_premium,
                              color: Colors.amber, size: 22),
                          SizedBox(width: 8),
                          Text('Pro Plan · Active',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ]),
                        SizedBox(height: 8),
                        Text('Renews August 14, 2026',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13)),
                      ]),
                ),
                const SizedBox(height: 16),
                const Text('Included features',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                for (final f in [
                  'Unlimited guests',
                  'AI day simulation',
                  'Guest portal & RSVP',
                  'Real-time coordinator mode',
                  'Registry & gift tracking',
                  'Priority support'
                ])
                  Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(children: [
                        const Icon(Icons.check_circle_outline,
                            color: AppTheme.udoGreen, size: 18),
                        const SizedBox(width: 10),
                        Text(f, style: const TextStyle(fontSize: 14)),
                      ])),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: AppTheme.udoBorder),
                      foregroundColor: AppTheme.udoTextSecondary),
                  child: const Text('Manage subscription'),
                ),
              ]),
        ),
      );
}

// ── SUPPORT PREFERENCES SHEET ──────────────────────────────────────────────────

class _LiveSubscriptionSheet extends StatelessWidget {
  final Map<String, dynamic>? entitlements;
  const _LiveSubscriptionSheet({required this.entitlements});

  @override
  Widget build(BuildContext context) {
    final plan = entitlements?['label']?.toString() ?? 'Free';
    final status = entitlements?['status']?.toString() ?? 'active';
    final limits = entitlements?['limits'] as Map? ?? {};
    final usage = entitlements?['usage'] as Map? ?? {};
    final features = (entitlements?['features'] as List? ?? [])
        .map((item) => item.toString())
        .toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(
                    child: Text('Wedding Pass',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero),
              ]),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppTheme.udoGreen, Color(0xFF3D7A01)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.workspace_premium,
                            color: Colors.amber, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text('$plan - ${_humanize(status)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600))),
                      ]),
                      const SizedBox(height: 8),
                      Text(
                          limits.isEmpty
                              ? 'Usage limits will appear after billing syncs.'
                              : 'Your current wedding workspace limits.',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ]),
              ),
              const SizedBox(height: 16),
              const Text('Plan usage',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (limits.isEmpty)
                const Text('No limits returned for this plan yet.',
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.udoTextSecondary))
              else
                for (final entry in limits.entries)
                  _LimitRow(
                      label: _humanize(entry.key.toString()),
                      used: usage[entry.key],
                      limit: entry.value,
                      onTap: _actionFor(entry.key.toString(), context),
                      actionLabel: _actionLabelFor(entry.key.toString())),
              if (features.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text('Included features',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                for (final feature in features.take(8))
                  Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(children: [
                        const Icon(Icons.check_circle_outline,
                            color: AppTheme.udoGreen, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(_humanize(feature),
                                style: const TextStyle(fontSize: 14))),
                      ])),
              ],
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: AppTheme.udoBorder),
                    foregroundColor: AppTheme.udoTextSecondary),
                child: const Text('Close'),
              ),
            ]),
      ),
    );
  }

  VoidCallback? _actionFor(String key, BuildContext context) {
    switch (key) {
      case 'guests':
        return () => context.push('/guests');
      case 'team_members':
        return () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              builder: (_) => const _CollaboratorsSheet(),
            );
      case 'messages_per_month':
        return () => context.push('/guests?tab=Messages');
      case 'gallery_assets':
        return () => context.push('/gallery');
      case 'weddings':
        return () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              builder: (_) => const _WeddingWorkspacesSheet(),
            );
      case 'ai_assistant_calls_per_month':
        return () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AiAssistantChatScreen()));
      default:
        return null;
    }
  }

  String? _actionLabelFor(String key) {
    switch (key) {
      case 'guests':
        return 'Add guests →';
      case 'team_members':
        return 'Add collaborators →';
      case 'messages_per_month':
        return 'Send a message →';
      case 'gallery_assets':
        return 'Open Gallery →';
      case 'weddings':
        return 'Manage weddings →';
      case 'ai_assistant_calls_per_month':
        return 'Open AI Chat →';
      default:
        return null;
    }
  }
}

class _WeddingWorkspacesSheet extends ConsumerStatefulWidget {
  const _WeddingWorkspacesSheet();

  @override
  ConsumerState<_WeddingWorkspacesSheet> createState() =>
      _WeddingWorkspacesSheetState();
}

class _WeddingWorkspacesSheetState
    extends ConsumerState<_WeddingWorkspacesSheet> {
  int? _switchingId;
  final _workspaceTitle = TextEditingController();
  final _primaryName = TextEditingController();
  final _secondaryName = TextEditingController();
  final _eventDate = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController();
  bool _creating = false;

  @override
  void dispose() {
    _workspaceTitle.dispose();
    _primaryName.dispose();
    _secondaryName.dispose();
    _eventDate.dispose();
    _city.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final operations = ref.watch(moreOperationsProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(
                    child: Text('Wedding workspaces',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero),
              ]),
              const SizedBox(height: 4),
              const Text(
                  'Switch between weddings you own or have been invited to help manage.',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.udoTextSecondary)),
              const SizedBox(height: 16),
              if (operations.isLoading)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                            color: AppTheme.udoGreen)))
              else if (operations.weddings.isEmpty)
                const _EmptyPanel(
                    icon: Icons.event_available_outlined,
                    title: 'No workspaces found',
                    subtitle:
                        'Your weddings will appear here once you own or join one.')
              else
                for (final wedding in operations.weddings)
                  _WeddingWorkspaceRow(
                      wedding: wedding,
                      switchingId: _switchingId,
                      onSwitch: _switchWedding),
              if (operations.error != null) ...[
                const SizedBox(height: 10),
                Text(operations.error!,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.udoCrimson)),
              ],
              const SizedBox(height: 16),
              const Text('Create another wedding',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                  controller: _workspaceTitle,
                  decoration: _sheetInput('Workspace name')),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: _primaryName,
                        decoration: _sheetInput('Primary name'))),
                const SizedBox(width: 8),
                Expanded(
                    child: TextField(
                        controller: _secondaryName,
                        decoration: _sheetInput('Partner name'))),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: _eventDate,
                        keyboardType: TextInputType.datetime,
                        decoration: _sheetInput('YYYY-MM-DD'))),
                const SizedBox(width: 8),
                Expanded(
                    child: TextField(
                        controller: _city, decoration: _sheetInput('City'))),
              ]),
              const SizedBox(height: 8),
              TextField(
                  controller: _country, decoration: _sheetInput('Country')),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _creating ? null : _createWedding,
                icon: _creating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.add, size: 16),
                label: Text(_creating ? 'Creating...' : 'Create workspace'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: AppTheme.udoGreen,
                    foregroundColor: Colors.white),
              ),
            ]),
      ),
    );
  }

  Future<void> _switchWedding(int weddingId) async {
    if (_switchingId != null) return;
    setState(() => _switchingId = weddingId);
    final ok = await ref
        .read(moreOperationsProvider.notifier)
        .switchWedding(weddingId);
    if (ok) {
      await ref.read(authProvider.notifier).refreshUser();
    }
    if (!mounted) return;
    setState(() => _switchingId = null);
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wedding workspace switched')));
    }
  }

  Future<void> _createWedding() async {
    if (_creating || _primaryName.text.trim().isEmpty) return;
    setState(() => _creating = true);
    final ok = await ref.read(moreOperationsProvider.notifier).createWedding(
          title: _workspaceTitle.text,
          primaryName: _primaryName.text,
          secondaryName: _secondaryName.text,
          eventDate: _eventDate.text,
          city: _city.text,
          country: _country.text,
        );
    if (ok) {
      await ref.read(authProvider.notifier).refreshUser();
    }
    if (!mounted) return;
    setState(() => _creating = false);
    if (ok) {
      _workspaceTitle.clear();
      _primaryName.clear();
      _secondaryName.clear();
      _eventDate.clear();
      _city.clear();
      _country.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wedding workspace created')));
    }
  }
}

class _WeddingWorkspaceRow extends StatelessWidget {
  final Map<String, dynamic> wedding;
  final int? switchingId;
  final ValueChanged<int> onSwitch;
  const _WeddingWorkspaceRow(
      {required this.wedding,
      required this.switchingId,
      required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    final id = wedding['id'] as int?;
    final isActive = wedding['is_active'] == true;
    final isSwitching = id != null && switchingId == id;
    final access = wedding['access'] as Map?;
    final title = _weddingTitle(wedding);
    final meta = _weddingMeta(wedding);
    final role = access?['is_owner'] == true
        ? 'Owner'
        : _humanize(access?['role']?.toString() ?? 'Collaborator');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(14)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(
            isActive
                ? Icons.check_circle_outline
                : Icons.event_available_outlined,
            size: 22,
            color: AppTheme.udoGreen),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600))),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppTheme.udoGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('Active',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.udoGreen,
                        fontWeight: FontWeight.w600)),
              ),
          ]),
          const SizedBox(height: 3),
          Text(meta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary)),
          const SizedBox(height: 3),
          Text(role,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.udoTextSecondary)),
        ])),
        if (!isActive && id != null) ...[
          const SizedBox(width: 10),
          TextButton(
            onPressed: switchingId == null ? () => onSwitch(id) : null,
            child: Text(isSwitching ? 'Switching' : 'Switch'),
          ),
        ],
      ]),
    );
  }
}

class WeddingSettingsSheet extends ConsumerStatefulWidget {
  const WeddingSettingsSheet({super.key});

  @override
  ConsumerState<WeddingSettingsSheet> createState() =>
      _WeddingSettingsSheetState();
}

class _WeddingSettingsSheetState extends ConsumerState<WeddingSettingsSheet> {
  final _title = TextEditingController();
  final _primaryName = TextEditingController();
  final _secondaryName = TextEditingController();
  final _eventDate = TextEditingController();
  final _rsvpDeadline = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController();
  final _venueName = TextEditingController();
  final _venueAddress = TextEditingController();
  final _hashtag = TextEditingController();
  final _coverPhotoPath = TextEditingController();
  final _couplePhotoPath = TextEditingController();
  final _timezone = TextEditingController();
  final _approvalThreshold = TextEditingController();
  bool _seeded = false;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _primaryName.dispose();
    _secondaryName.dispose();
    _eventDate.dispose();
    _rsvpDeadline.dispose();
    _city.dispose();
    _country.dispose();
    _venueName.dispose();
    _venueAddress.dispose();
    _hashtag.dispose();
    _coverPhotoPath.dispose();
    _couplePhotoPath.dispose();
    _timezone.dispose();
    _approvalThreshold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final operations = ref.watch(moreOperationsProvider);
    final user = ref.watch(authProvider).user;
    final canManage = (user?.isWeddingOwner ?? false) ||
        (user?.weddingPermissions.contains('manage_wedding') ?? false);
    final wedding = operations.activeWedding;

    if (!_seeded && wedding != null) {
      _seed(wedding);
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(
                    child: Text('Wedding settings',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero),
              ]),
              const SizedBox(height: 4),
              Text(
                canManage
                    ? 'Update details used across RSVP, guest experience, live mode, and planning.'
                    : 'You need wedding management access to edit these details.',
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.udoTextSecondary),
              ),
              const SizedBox(height: 16),
              if (operations.isLoading && wedding == null)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                            color: AppTheme.udoGreen)))
              else if (wedding == null)
                const _EmptyPanel(
                    icon: Icons.settings_outlined,
                    title: 'No active wedding',
                    subtitle: 'Create or switch to a wedding workspace first.')
              else ...[
                TextField(
                    controller: _title,
                    enabled: canManage,
                    decoration: _sheetInput('Workspace title')),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: _primaryName,
                          enabled: canManage,
                          decoration: _sheetInput('Primary name'))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          controller: _secondaryName,
                          enabled: canManage,
                          decoration: _sheetInput('Partner name'))),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: _eventDate,
                          enabled: canManage,
                          keyboardType: TextInputType.datetime,
                          decoration: _sheetInput('Wedding date YYYY-MM-DD'))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          controller: _rsvpDeadline,
                          enabled: canManage,
                          keyboardType: TextInputType.datetime,
                          decoration: _sheetInput('RSVP YYYY-MM-DD'))),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: _city,
                          enabled: canManage,
                          decoration: _sheetInput('City'))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextField(
                          controller: _country,
                          enabled: canManage,
                          decoration: _sheetInput('Country'))),
                ]),
                const SizedBox(height: 8),
                TextField(
                    controller: _venueName,
                    enabled: canManage,
                    decoration: _sheetInput('Venue name')),
                const SizedBox(height: 8),
                TextField(
                    controller: _venueAddress,
                    enabled: canManage,
                    maxLines: 3,
                    decoration: _sheetInput('Venue address')),
                const SizedBox(height: 8),
                TextField(
                    controller: _hashtag,
                    enabled: canManage,
                    decoration: _sheetInput('Wedding hashtag (optional)')),
                const SizedBox(height: 8),
                TextField(
                    controller: _coverPhotoPath,
                    enabled: canManage,
                    decoration: _sheetInput('Cover photo URL (optional)')),
                const SizedBox(height: 12),
                TextField(
                    controller: _couplePhotoPath,
                    enabled: canManage,
                    decoration: _sheetInput('Couple photo URL (optional)')),
                const SizedBox(height: 8),
                TextField(
                    controller: _timezone,
                    enabled: canManage,
                    decoration:
                        _sheetInput('Timezone (e.g. America/New_York)')),
                const SizedBox(height: 8),
                TextField(
                  controller: _approvalThreshold,
                  enabled: canManage,
                  keyboardType: TextInputType.number,
                  decoration: _sheetInput(
                      'Auto-approve budget changes under \$ (optional)'),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Budget increases below this amount skip Decision-maker approval entirely.',
                  style:
                      TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary),
                ),
                if (operations.error != null) ...[
                  const SizedBox(height: 10),
                  Text(operations.error!,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.udoCrimson)),
                ],
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: !canManage || _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined, size: 16),
                  label: Text(_saving ? 'Saving...' : 'Save settings'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: AppTheme.udoGreen,
                      foregroundColor: Colors.white),
                ),
              ],
            ]),
      ),
    );
  }

  void _seed(Map<String, dynamic> wedding) {
    _title.text = wedding['title']?.toString() ?? '';
    _primaryName.text = wedding['couple_name_primary']?.toString() ?? '';
    _secondaryName.text = wedding['couple_name_secondary']?.toString() ?? '';
    _eventDate.text = _dateOnly(wedding['event_date']);
    _rsvpDeadline.text = _dateOnly(wedding['rsvp_deadline']);
    _city.text = wedding['city']?.toString() ?? '';
    _country.text = wedding['country']?.toString() ?? '';
    _venueName.text = wedding['primary_venue_name']?.toString() ?? '';
    _venueAddress.text = wedding['primary_venue_address']?.toString() ?? '';
    _hashtag.text = wedding['hashtag']?.toString() ?? '';
    _coverPhotoPath.text = wedding['cover_photo_path']?.toString() ?? '';
    _couplePhotoPath.text = wedding['couple_photo_path']?.toString() ?? '';
    _timezone.text = wedding['timezone']?.toString() ?? '';
    final settings = wedding['settings'] is Map
        ? Map<String, dynamic>.from(wedding['settings'] as Map)
        : <String, dynamic>{};
    _approvalThreshold.text =
        settings['approval_auto_threshold']?.toString() ?? '';
    _seeded = true;
  }

  Future<void> _save() async {
    if (_primaryName.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final wedding = ref.read(moreOperationsProvider).activeWedding;
    final settings = wedding?['settings'] is Map
        ? Map<String, dynamic>.from(wedding!['settings'] as Map)
        : <String, dynamic>{};
    final thresholdText = _approvalThreshold.text.trim();
    if (thresholdText.isEmpty) {
      settings.remove('approval_auto_threshold');
    } else {
      settings['approval_auto_threshold'] = num.tryParse(thresholdText);
    }
    final ok = await ref.read(moreOperationsProvider.notifier).updateWedding({
      'title': _nullIfBlank(_title.text),
      'couple_name_primary': _nullIfBlank(_primaryName.text),
      'couple_name_secondary': _nullIfBlank(_secondaryName.text),
      'event_date': _nullIfBlank(_eventDate.text),
      'rsvp_deadline': _nullIfBlank(_rsvpDeadline.text),
      'city': _nullIfBlank(_city.text),
      'country': _nullIfBlank(_country.text),
      'primary_venue_name': _nullIfBlank(_venueName.text),
      'primary_venue_address': _nullIfBlank(_venueAddress.text),
      'hashtag': _nullIfBlank(_hashtag.text),
      'cover_photo_path': _nullIfBlank(_coverPhotoPath.text),
      'couple_photo_path': _nullIfBlank(_couplePhotoPath.text),
      'timezone': _nullIfBlank(_timezone.text),
      'settings': settings,
    });
    if (ok) {
      await ref.read(authProvider.notifier).refreshUser();
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wedding settings saved')));
      Navigator.pop(context);
    }
  }
}

class _CollaboratorsSheet extends ConsumerStatefulWidget {
  const _CollaboratorsSheet();

  @override
  ConsumerState<_CollaboratorsSheet> createState() =>
      _CollaboratorsSheetState();
}

class _CollaboratorsSheetState extends ConsumerState<_CollaboratorsSheet> {
  final _email = TextEditingController();
  String _role = 'viewer';
  bool _isDecisionMaker = false;
  final _approvalCategories = <String>{};
  bool _saving = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final operations = ref.watch(moreOperationsProvider);
    final user = ref.watch(authProvider).user;
    final canManage = user?.weddingPermissions.contains('manage_team') ?? false;
    final roles = operations.roles.isEmpty
        ? <Map<String, dynamic>>[
            {'role': 'viewer', 'label': 'Viewer'},
          ]
        : operations.roles;

    if (!roles.any((item) => item['role'] == _role)) {
      _role = roles.first['role'].toString();
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(
                    child: Text('Collaborators',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero),
              ]),
              const SizedBox(height: 4),
              const Text(
                  'Invite existing Udo users and control what they can manage.',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.udoTextSecondary)),
              const SizedBox(height: 16),
              if (operations.isLoading)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                            color: AppTheme.udoGreen)))
              else if (operations.team.isEmpty)
                _EmptyPanel(
                    icon: Icons.people_outline,
                    title: 'No collaborators visible',
                    subtitle: canManage
                        ? 'Add a teammate by email.'
                        : 'You do not have access to manage this team.')
              else
                for (final member in operations.team)
                  _CollaboratorRow(
                    member: member,
                    onTap: (canManage &&
                            member['is_owner'] != true &&
                            member['id'] != null)
                        ? () => _editDecisionMaker(
                            context, member, operations.approvalCategories)
                        : null,
                  ),
              if (canManage) ...[
                const SizedBox(height: 16),
                const Text('Add collaborator',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _sheetInput('Email address')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _role,
                  items: roles.map((role) {
                    final value = role['role'].toString();
                    return DropdownMenuItem(
                        value: value,
                        child: Text(
                            role['label']?.toString() ?? _humanize(value)));
                  }).toList(),
                  onChanged: (value) => setState(() => _role = value ?? _role),
                  decoration: _sheetInput('Role'),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  const Expanded(
                      child: Text('Decision-maker',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500))),
                  Switch(
                      value: _isDecisionMaker,
                      onChanged: (v) => setState(() => _isDecisionMaker = v),
                      activeColor: AppTheme.udoGreen),
                ]),
                if (_isDecisionMaker &&
                    operations.approvalCategories.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: operations.approvalCategories
                          .map((c) => FilterChip(
                                label: Text(_humanize(c),
                                    style: const TextStyle(fontSize: 12)),
                                selected: _approvalCategories.contains(c),
                                onSelected: (sel) => setState(() => sel
                                    ? _approvalCategories.add(c)
                                    : _approvalCategories.remove(c)),
                                selectedColor:
                                    AppTheme.udoGreen.withValues(alpha: 0.2),
                                checkmarkColor: AppTheme.udoGreen,
                              ))
                          .toList()),
                ],
                const SizedBox(height: 12),
                if (operations.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(operations.error!,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.udoCrimson)),
                  ),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _addCollaborator,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.person_add_outlined, size: 16),
                  label: Text(_saving ? 'Adding...' : 'Add collaborator'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: AppTheme.udoGreen,
                      foregroundColor: Colors.white),
                ),
              ],
            ]),
      ),
    );
  }

  Future<void> _addCollaborator() async {
    final email = _email.text.trim();
    if (email.isEmpty) return;
    setState(() => _saving = true);
    final ok = await ref.read(moreOperationsProvider.notifier).addCollaborator(
          email: email,
          role: _role,
          isDecisionMaker: _isDecisionMaker,
          approvalCategories:
              _isDecisionMaker ? _approvalCategories.toList() : [],
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      _email.clear();
      _isDecisionMaker = false;
      _approvalCategories.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Collaborator added')));
    }
  }

  void _editDecisionMaker(BuildContext context, Map<String, dynamic> member,
      List<String> allCategories) {
    var isDecisionMaker = member['is_decision_maker'] == true;
    final categories = <String>{
      ...(member['approval_categories'] as List? ?? []).map((c) => c.toString())
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 24),
          child: SafeArea(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(
                            member['name']?.toString() ?? 'Collaborator',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600))),
                    IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Expanded(
                        child: Text('Decision-maker',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500))),
                    Switch(
                        value: isDecisionMaker,
                        onChanged: (v) =>
                            setSheetState(() => isDecisionMaker = v),
                        activeColor: AppTheme.udoGreen),
                  ]),
                  if (isDecisionMaker) ...[
                    const SizedBox(height: 4),
                    Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: allCategories
                            .map((c) => FilterChip(
                                  label: Text(_humanize(c),
                                      style: const TextStyle(fontSize: 12)),
                                  selected: categories.contains(c),
                                  onSelected: (sel) => setSheetState(() => sel
                                      ? categories.add(c)
                                      : categories.remove(c)),
                                  selectedColor:
                                      AppTheme.udoGreen.withValues(alpha: 0.2),
                                  checkmarkColor: AppTheme.udoGreen,
                                ))
                            .toList()),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      await ref
                          .read(moreOperationsProvider.notifier)
                          .updateCollaborator(
                            member['id'] as int,
                            isDecisionMaker: isDecisionMaker,
                            approvalCategories:
                                isDecisionMaker ? categories.toList() : [],
                          );
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: AppTheme.udoGreen,
                        foregroundColor: Colors.white),
                    child: const Text('Save'),
                  ),
                  const SizedBox(height: 8),
                ]),
          ),
        ),
      ),
    );
  }
}

class _CollaboratorRow extends StatelessWidget {
  final Map<String, dynamic> member;
  final VoidCallback? onTap;
  const _CollaboratorRow({required this.member, this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = member['name']?.toString() ??
        member['email']?.toString() ??
        'Collaborator';
    final role = member['role']?.toString() ?? 'viewer';
    final permissions = (member['permissions'] as List? ?? [])
        .map((item) => _humanize(item.toString()))
        .join(', ');
    final isDecisionMaker = member['is_decision_maker'] == true;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.udoCardFill,
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.udoGreen.withValues(alpha: 0.15),
              child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: const TextStyle(
                      color: AppTheme.udoGreen, fontWeight: FontWeight.w700))),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Expanded(
                      child: Text(name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600))),
                  if (member['is_owner'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: AppTheme.udoGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('Owner',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.udoGreen,
                              fontWeight: FontWeight.w600)),
                    ),
                  if (isDecisionMaker)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('Decision-maker',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600)),
                    ),
                ]),
                const SizedBox(height: 2),
                Text(
                    '${_humanize(role)}${permissions.isEmpty ? '' : ' - $permissions'}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.udoTextSecondary)),
              ])),
          if (onTap != null)
            const Icon(Icons.chevron_right,
                size: 18, color: AppTheme.udoTextSecondary),
        ]),
      ),
    );
  }
}

class _ActivitySheet extends ConsumerWidget {
  const _ActivitySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operations = ref.watch(moreOperationsProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(
                    child: Text('Activity log',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero),
              ]),
              const SizedBox(height: 4),
              const Text('Recent changes across your wedding workspace.',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.udoTextSecondary)),
              const SizedBox(height: 16),
              if (operations.isLoading)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                            color: AppTheme.udoGreen)))
              else if (operations.auditLogs.isEmpty)
                const _EmptyPanel(
                    icon: Icons.manage_search_outlined,
                    title: 'No activity visible',
                    subtitle:
                        'Activity appears here when you have reporting access.')
              else
                for (final log in operations.auditLogs) _AuditLogRow(log: log),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(moreOperationsProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: AppTheme.udoGreen),
                    foregroundColor: AppTheme.udoGreen),
              ),
            ]),
      ),
    );
  }
}

class _AuditLogRow extends StatelessWidget {
  final Map<String, dynamic> log;
  const _AuditLogRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final user = log['user'] as Map?;
    final actor = user?['email']?.toString() ??
        user?['full_name']?.toString() ??
        'System';
    final action = _humanize(log['action']?.toString() ?? 'activity');
    final created = log['created_at']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(14)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.history, size: 20, color: AppTheme.udoTextPrimary),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(action,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('$actor${created.isEmpty ? '' : ' - $created'}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary)),
        ])),
      ]),
    );
  }
}

class _LimitRow extends StatelessWidget {
  final String label;
  final dynamic used;
  final dynamic limit;
  final VoidCallback? onTap;
  final String? actionLabel;
  const _LimitRow(
      {required this.label,
      required this.used,
      required this.limit,
      this.onTap,
      this.actionLabel});

  @override
  Widget build(BuildContext context) {
    final usedNumber =
        used is num ? used : num.tryParse(used?.toString() ?? '') ?? 0;
    final limitNumber =
        limit is num ? limit : num.tryParse(limit?.toString() ?? '');
    final hasLimit = limitNumber != null && limitNumber > 0;
    final progress =
        hasLimit ? (usedNumber / limitNumber).clamp(0.0, 1.0).toDouble() : 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600))),
            Text(
                hasLimit
                    ? '$usedNumber / $limitNumber'
                    : '$usedNumber / Unlimited',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.udoTextSecondary)),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right,
                  size: 16, color: AppTheme.udoTextSecondary),
            ],
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(
              value: hasLimit ? progress : 0,
              minHeight: 6,
              backgroundColor: Colors.white,
              color: AppTheme.udoGreen,
              borderRadius: BorderRadius.circular(12)),
          if (onTap != null && actionLabel != null) ...[
            const SizedBox(height: 8),
            Text(actionLabel!,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.udoGreen)),
          ],
        ]),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyPanel(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppTheme.udoCardFill,
            borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Icon(icon, size: 36, color: AppTheme.udoTextSecondary),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary)),
        ]),
      );
}

InputDecoration _sheetInput(String hint) => InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14),
      filled: true,
      fillColor: AppTheme.udoCardFill,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.udoGreen, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

String _humanize(String value) {
  return value
      .replaceAll('.', ' ')
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) =>
          '${part[0].toUpperCase()}${part.length == 1 ? '' : part.substring(1)}')
      .join(' ');
}

String _weddingTitle(Map<String, dynamic> wedding) {
  final title = wedding['title']?.toString();
  if (title != null && title.trim().isNotEmpty) return title;
  final names = [
    wedding['couple_name_primary']?.toString(),
    wedding['couple_name_secondary']?.toString(),
  ].where((name) => name != null && name.trim().isNotEmpty).join(' & ');
  return names.isEmpty ? 'Untitled wedding' : names;
}

String _weddingMeta(Map<String, dynamic> wedding) {
  final parts = [
    wedding['event_date']?.toString(),
    wedding['city']?.toString(),
    wedding['country']?.toString(),
  ].where((part) => part != null && part.trim().isNotEmpty).toList();
  return parts.isEmpty ? 'Wedding workspace' : parts.join(' - ');
}

String _dateOnly(dynamic value) {
  final text = value?.toString() ?? '';
  return text.length >= 10 ? text.substring(0, 10) : text;
}

String? _nullIfBlank(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

class _SupportPrefsSheet extends ConsumerStatefulWidget {
  const _SupportPrefsSheet();
  @override
  ConsumerState<_SupportPrefsSheet> createState() => _SupportPrefsSheetState();
}

class _SupportPrefsSheetState extends ConsumerState<_SupportPrefsSheet> {
  bool _emailSupport = true;
  bool _chatSupport = false;
  bool _proactiveCheckins = true;
  String _responseTime = 'within-24h';
  bool _seeded = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(authProvider).user?.supportPreferences ?? const {};
    if (!_seeded) {
      _emailSupport = prefs['email_support'] as bool? ?? true;
      _chatSupport = prefs['chat_support'] as bool? ?? false;
      _proactiveCheckins = prefs['proactive_checkins'] as bool? ?? true;
      _responseTime = prefs['response_time']?.toString() ?? 'within-24h';
      _seeded = true;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(
                    child: Text('Support preferences',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero),
              ]),
              const SizedBox(height: 16),
              _ToggleRow('Email support', 'Receive support via email',
                  _emailSupport, (v) => setState(() => _emailSupport = v)),
              _ToggleRow('Live chat', 'Chat with our support team',
                  _chatSupport, (v) => setState(() => _chatSupport = v)),
              _ToggleRow(
                  'Proactive check-ins',
                  'We\'ll check in on key planning milestones',
                  _proactiveCheckins,
                  (v) => setState(() => _proactiveCheckins = v)),
              const SizedBox(height: 12),
              const Text('Preferred response time',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              for (final (val, label) in [
                ('within-1h', 'Within 1 hour'),
                ('within-24h', 'Within 24 hours'),
                ('within-3d', 'Within 3 days')
              ])
                RadioListTile<String>(
                  value: val,
                  groupValue: _responseTime,
                  title: Text(label, style: const TextStyle(fontSize: 14)),
                  activeColor: AppTheme.udoGreen,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) =>
                      setState(() => _responseTime = v ?? 'within-24h'),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: AppTheme.udoGreen,
                    foregroundColor: Colors.white),
                child: Text(_saving ? 'Saving...' : 'Save preferences'),
              ),
            ]),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await ref.read(authProvider.notifier).updatePreferences(
      supportPreferences: {
        'email_support': _emailSupport,
        'chat_support': _chatSupport,
        'proactive_checkins': _proactiveCheckins,
        'response_time': _responseTime,
      },
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Support preferences saved')));
      Navigator.pop(context);
    }
  }
}

Widget _ToggleRow(String title, String subtitle, bool value,
        ValueChanged<bool> onChanged) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.udoCardFill,
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.udoTextSecondary)),
              ])),
          Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.udoGreen),
        ]),
      ),
    );

// ── PROFILE SHEET ──────────────────────────────────────────────────────────────

class _ProfileSheet extends ConsumerStatefulWidget {
  final dynamic user;
  const _ProfileSheet({required this.user});
  @override
  ConsumerState<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends ConsumerState<_ProfileSheet> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _avatarUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user?.fullName ?? '');
    _email = TextEditingController(text: widget.user?.email ?? '');
    _avatarUrl = TextEditingController(text: widget.user?.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _avatarUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Expanded(
                      child: Text('Profile',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600))),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero),
                ]),
                const SizedBox(height: 16),
                const Text('Full name',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(controller: _name, decoration: _dec('Your name')),
                const SizedBox(height: 12),
                const Text('Email',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _dec('Email address')),
                const SizedBox(height: 12),
                const Text('Avatar URL',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                    controller: _avatarUrl,
                    keyboardType: TextInputType.url,
                    decoration: _dec('https://...')),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: AppTheme.udoGreen,
                      foregroundColor: Colors.white),
                  child: Text(_saving ? 'Saving...' : 'Save changes'),
                ),
              ]),
        ),
      );

  Future<void> _save() async {
    final parts = _name.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final firstName = parts.isEmpty ? '' : parts.first;
    final lastName = parts.length > 1 ? parts.skip(1).join(' ') : '';
    final email = _email.text.trim();
    if (firstName.isEmpty || email.isEmpty) return;

    setState(() => _saving = true);
    final ok = await ref.read(authProvider.notifier).updateProfile(
          firstName: firstName,
          lastName: lastName,
          email: email,
          avatarUrl: _avatarUrl.text,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile saved')));
      Navigator.pop(context);
    }
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14),
        filled: true,
        fillColor: AppTheme.udoCardFill,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.udoGreen, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}

// ── NOTIFICATIONS SHEET ────────────────────────────────────────────────────────

class _NotificationsSheet extends ConsumerStatefulWidget {
  const _NotificationsSheet();
  @override
  ConsumerState<_NotificationsSheet> createState() =>
      _NotificationsSheetState();
}

class _NotificationsSheetState extends ConsumerState<_NotificationsSheet> {
  bool _rsvpUpdates = true;
  bool _taskReminders = true;
  bool _guestMessages = true;
  bool _liveMode = true;
  bool _vendorUpdates = false;
  bool _seeded = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final prefs =
        ref.watch(authProvider).user?.notificationPreferences ?? const {};
    if (!_seeded) {
      _rsvpUpdates = prefs['rsvp_updates'] as bool? ?? true;
      _taskReminders = prefs['task_reminders'] as bool? ?? true;
      _guestMessages = prefs['guest_messages'] as bool? ?? true;
      _liveMode = prefs['live_mode'] as bool? ?? true;
      _vendorUpdates = prefs['vendor_updates'] as bool? ?? false;
      _seeded = true;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(
                    child: Text('Notifications',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero),
              ]),
              const SizedBox(height: 16),
              _ToggleRow('RSVP updates', 'When guests respond to invitations',
                  _rsvpUpdates, (v) => setState(() => _rsvpUpdates = v)),
              _ToggleRow('Task reminders', 'Upcoming planning deadlines',
                  _taskReminders, (v) => setState(() => _taskReminders = v)),
              _ToggleRow('Guest messages', 'New messages from guests',
                  _guestMessages, (v) => setState(() => _guestMessages = v)),
              _ToggleRow('Live mode', 'Day-of alerts and coordinator updates',
                  _liveMode, (v) => setState(() => _liveMode = v)),
              _ToggleRow('Vendor updates', 'Confirmations and reminders',
                  _vendorUpdates, (v) => setState(() => _vendorUpdates = v)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: AppTheme.udoGreen,
                    foregroundColor: Colors.white),
                child: Text(_saving ? 'Saving...' : 'Save'),
              ),
            ]),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await ref.read(authProvider.notifier).updatePreferences(
      notificationPreferences: {
        'rsvp_updates': _rsvpUpdates,
        'task_reminders': _taskReminders,
        'guest_messages': _guestMessages,
        'live_mode': _liveMode,
        'vendor_updates': _vendorUpdates,
      },
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification preferences saved')));
      Navigator.pop(context);
    }
  }
}

// ── PRIVACY SHEET ──────────────────────────────────────────────────────────────

class _PrivacySheet extends StatelessWidget {
  const _PrivacySheet();

  void _openChangePassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  void _openTwoFactor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _TwoFactorSheet(),
    );
  }

  void _openGuestPortalVisibility(BuildContext context) {
    Navigator.pop(context);
    context.push('/guests?tab=Experience');
  }

  void _openDeleteAccount(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _DeleteAccountSheet(),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Expanded(
                      child: Text('Privacy & Security',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600))),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero),
                ]),
                const SizedBox(height: 16),
                for (final (icon, title, subtitle, onTap) in [
                  (
                    Icons.lock_outline,
                    'Password',
                    'Change your account password',
                    () => _openChangePassword(context),
                  ),
                  (
                    Icons.phone_iphone_outlined,
                    'Two-factor authentication',
                    'Add an extra layer of security',
                    () => _openTwoFactor(context),
                  ),
                  (
                    Icons.visibility_outlined,
                    'Guest portal visibility',
                    'Control what guests can see',
                    () => _openGuestPortalVisibility(context),
                  ),
                  (
                    Icons.delete_outline,
                    'Delete account',
                    'Permanently remove your account',
                    () => _openDeleteAccount(context),
                  ),
                ])
                  ListTile(
                    leading:
                        Icon(icon, color: AppTheme.udoTextPrimary, size: 20),
                    title: Text(title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.udoTextSecondary)),
                    trailing: const Icon(Icons.chevron_right,
                        size: 18, color: AppTheme.udoTextSecondary),
                    contentPadding: EdgeInsets.zero,
                    onTap: onTap,
                  ),
              ]),
        ),
      );
}

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_currentCtrl.text.isEmpty || _newCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in every field.');
      return;
    }
    if (_newCtrl.text.length < 8) {
      setState(() => _error = 'New password must be at least 8 characters.');
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'New password and confirmation don\'t match.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await ref.read(authProvider.notifier).changePassword(
          currentPassword: _currentCtrl.text,
          newPassword: _newCtrl.text,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated.')));
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Expanded(
                        child: Text('Change password',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600))),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero),
                  ]),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _currentCtrl,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Current password'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'New password',
                        helperText: 'At least 8 characters'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Confirm new password'),
                    onSubmitted: (_) => _saving ? null : _submit(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.udoCrimson)),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: AppTheme.udoGreen,
                        foregroundColor: Colors.white),
                    child: Text(_saving ? 'Saving...' : 'Update password'),
                  ),
                ]),
          ),
        ),
      );
}

class _TwoFactorSheet extends ConsumerStatefulWidget {
  const _TwoFactorSheet();

  @override
  ConsumerState<_TwoFactorSheet> createState() => _TwoFactorSheetState();
}

class _TwoFactorSheetState extends ConsumerState<_TwoFactorSheet> {
  final _passwordCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(bool enable) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await ref.read(authProvider.notifier).setTwoFactorEnabled(
          enable,
          currentPassword: _passwordCtrl.text,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(enable
              ? 'Two-factor authentication turned on. You\'ll get a code by email each time you sign in.'
              : 'Two-factor authentication turned off.')));
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(authProvider).user?.twoFactorEnabled ?? false;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.phone_iphone_outlined,
                      color: AppTheme.udoTextPrimary, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                      child: Text('Two-factor authentication',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600))),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero),
                ]),
                const SizedBox(height: 12),
                Text(
                    enabled
                        ? 'Two-factor authentication is on. Every time you sign in, we\'ll email a 6-digit code you\'ll need to enter.'
                        : 'When turned on, we\'ll email you a 6-digit code to enter each time you sign in, in addition to your password.',
                    style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: AppTheme.udoTextSecondary)),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Current password',
                      helperText:
                          'Leave blank if you signed in with Google or Apple'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppTheme.udoCrimson)),
                ],
                const SizedBox(height: 20),
                if (enabled)
                  OutlinedButton(
                    onPressed: _saving ? null : () => _submit(false),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        foregroundColor: AppTheme.udoCrimson,
                        side: const BorderSide(color: AppTheme.udoCrimson)),
                    child: Text(_saving
                        ? 'Turning off...'
                        : 'Turn off two-factor authentication'),
                  )
                else
                  ElevatedButton(
                    onPressed: _saving ? null : () => _submit(true),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: AppTheme.udoGreen,
                        foregroundColor: Colors.white),
                    child: Text(_saving
                        ? 'Turning on...'
                        : 'Turn on two-factor authentication'),
                  ),
              ]),
        ),
      ),
    );
  }
}

class _DeleteAccountSheet extends ConsumerStatefulWidget {
  const _DeleteAccountSheet();

  @override
  ConsumerState<_DeleteAccountSheet> createState() =>
      _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends ConsumerState<_DeleteAccountSheet> {
  final _confirmCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _deleting = false;
  String? _error;

  @override
  void dispose() {
    _confirmCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_confirmCtrl.text.trim().toUpperCase() != 'DELETE') {
      setState(() => _error = 'Type DELETE to confirm.');
      return;
    }
    setState(() {
      _deleting = true;
      _error = null;
    });
    final error = await ref.read(authProvider.notifier).deleteAccount(
          currentPassword: _passwordCtrl.text,
        );
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      context.go('/login');
    } else {
      setState(() {
        _deleting = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Expanded(
                        child: Text('Delete account',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.udoCrimson))),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero),
                  ]),
                  const SizedBox(height: 12),
                  const Text(
                      'This permanently removes your login and profile details. Your weddings, guest lists and messages are not deleted automatically — transfer ownership first if other collaborators still need access.',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.udoTextSecondary)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Current password',
                        helperText:
                            'Leave blank if you signed in with Google or Apple'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                        labelText: 'Type DELETE to confirm'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppTheme.udoCrimson)),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _deleting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: AppTheme.udoCrimson,
                        foregroundColor: Colors.white),
                    child: Text(
                        _deleting ? 'Deleting...' : 'Permanently delete account'),
                  ),
                ]),
          ),
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
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Expanded(
                      child: Text('Help centre',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600))),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero),
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
                      trailing: const Icon(Icons.chevron_right,
                          size: 18, color: AppTheme.udoTextSecondary),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      tileColor: AppTheme.udoCardFill,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onTap: () {},
                    ),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text('Contact support'),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: AppTheme.udoGreen),
                      foregroundColor: AppTheme.udoGreen),
                ),
              ]),
        ),
      );
}

// ── FEEDBACK SHEET ─────────────────────────────────────────────────────────────

class _AiAssistantSheet extends ConsumerWidget {
  final MoreOperationsState operations;
  const _AiAssistantSheet({required this.operations});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wedding = operations.activeWedding;
    final usage = ref.watch(aiAssistantProvider);
    final nextSteps = [
      (
        Icons.today_outlined,
        'Daily recommendations',
        operations.auditLogs.isEmpty
            ? 'Review your planning priorities for today.'
            : 'Review ${operations.auditLogs.length} recent workspace updates.',
        'Give me my daily planning recommendations — what should I prioritise today?',
      ),
      (
        Icons.insights_outlined,
        'Planning insights',
        operations.team.isEmpty
            ? 'Invite key collaborators so Udo can route decisions faster.'
            : '${operations.team.length} collaborators are helping this wedding move.',
        'What planning insights do you have for my wedding right now?',
      ),
      (
        Icons.chair_outlined,
        'Seating suggestions',
        'Use guest groups, meals and RSVP status to improve table assignments.',
        'Give me seating suggestions based on my guest list and current tables.',
      ),
      (
        Icons.account_balance_wallet_outlined,
        'Budget advice',
        'Compare committed spend against payments, deposits and vendor balances.',
        'Give me budget advice based on what I have spent and paid so far.',
      ),
      (
        Icons.search_outlined,
        'Search your wedding',
        wedding == null
            ? 'Ask about guests, vendors, tasks and details in this workspace.'
            : 'Ask anything about ${_weddingTitle(wedding)}.',
        '',
      ),
    ];

    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        minChildSize: 0.45,
        maxChildSize: 0.94,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Row(children: [
              Expanded(
                  child: Text('AI Wedding Assistant',
                      style: UdoDesign.serif(size: 30))),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero),
            ]),
            const SizedBox(height: 8),
            Text(
                'Recommendations, search and planning guidance for the active workspace.',
                style: UdoDesign.sans(size: 13, color: UdoDesign.sub)),
            const SizedBox(height: 4),
            Text(
                usage.usageLimit == null
                    ? 'Unlimited assistant questions on your plan.'
                    : '${usage.usageUsed} of ${usage.usageLimit} assistant questions used this month.',
                style: UdoDesign.sans(
                    size: 11.5,
                    weight: FontWeight.w600,
                    color: usage.limitReached
                        ? AppTheme.udoCrimson
                        : UdoDesign.muted)),
            const SizedBox(height: 18),
            UdoCard(
              color: UdoDesign.bg,
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                      color: _moreAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.auto_awesome_outlined,
                      color: _moreAccent),
                ),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Today\'s planning brief',
                          style: UdoDesign.sans(
                              size: 15, weight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                          'Prioritise decisions, check overdue tasks and ask Udo for the best next move.',
                          style:
                              UdoDesign.sans(size: 12, color: UdoDesign.muted)),
                    ])),
              ]),
            ),
            const SizedBox(height: 16),
            for (final item in nextSteps)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: UdoDesign.border)),
                  leading: Icon(item.$1, color: _moreAccent, size: 20),
                  title: Text(item.$2,
                      style: UdoDesign.sans(size: 14, weight: FontWeight.w700)),
                  subtitle: Text(item.$3,
                      style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
                  trailing: const Icon(Icons.chevron_right,
                      size: 18, color: UdoDesign.muted),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AiAssistantChatScreen(
                          initialPrompt: item.$4.isEmpty ? null : item.$4))),
                ),
              ),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const AiAssistantChatScreen())),
              icon: const Icon(Icons.chat_bubble_outline, size: 17),
              label: const Text('Open AI Chat'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: _moreAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _kSupportEmail = 'hello@whizzonby.com';
const _kSupportWhatsapp = '+447355614524';

class _ContactSupportSheet extends StatelessWidget {
  const _ContactSupportSheet();

  Future<void> _openMailto(BuildContext context, String subject) async {
    Navigator.pop(context);
    final uri = Uri(
        scheme: 'mailto',
        path: _kSupportEmail,
        query: 'subject=${Uri.encodeComponent(subject)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open an email app.')));
    }
  }

  Future<void> _openWhatsapp(BuildContext context) async {
    Navigator.pop(context);
    final uri = Uri.parse('https://wa.me/$_kSupportWhatsapp');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
    }
  }

  void _openLiveChat(BuildContext context) {
    Navigator.pop(context);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AiAssistantChatScreen()));
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Text('Contact Support',
                          style: UdoDesign.serif(size: 30))),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero),
                ]),
                const SizedBox(height: 10),
                Text('Choose the support channel that fits the issue.',
                    style: UdoDesign.sans(size: 13, color: UdoDesign.sub)),
                const SizedBox(height: 16),
                for (final item in [
                  (
                    Icons.chat_bubble_outline,
                    'Live Chat',
                    'Fast help for urgent planning blockers',
                    _openLiveChat,
                  ),
                  (
                    Icons.email_outlined,
                    'Email Support',
                    'Send files, screenshots and detailed notes',
                    (BuildContext c) => _openMailto(c, 'Udo support request'),
                  ),
                  (
                    Icons.call_outlined,
                    'WhatsApp Support',
                    'Coordinate with a support specialist',
                    _openWhatsapp,
                  ),
                  (
                    Icons.confirmation_number_outlined,
                    'Submit Ticket',
                    'Create and track a formal request',
                    (BuildContext c) => _openMailto(c, 'Support ticket'),
                  ),
                  (
                    Icons.history_outlined,
                    'Support History',
                    'Review earlier conversations and decisions',
                    (BuildContext c) =>
                        _openMailto(c, 'Request: past support history'),
                  ),
                ])
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    child: ListTile(
                      leading: Icon(item.$1, color: _moreAccent, size: 20),
                      title: Text(item.$2,
                          style: UdoDesign.sans(
                              size: 14, weight: FontWeight.w700)),
                      subtitle: Text(item.$3,
                          style:
                              UdoDesign.sans(size: 12, color: UdoDesign.muted)),
                      trailing: const Icon(Icons.chevron_right,
                          size: 18, color: UdoDesign.muted),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      tileColor: UdoDesign.card,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: UdoDesign.border)),
                      onTap: () => item.$4(context),
                    ),
                  ),
              ]),
        ),
      );
}

class _AboutSheet extends ConsumerWidget {
  const _AboutSheet();

  void _openContentPage(BuildContext context, String slug, String title) {
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ContentPageScreen(slug: slug, title: title)));
  }

  void _openReleaseNotes(BuildContext context, {required bool latestOnly}) {
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ReleaseNotesScreen(latestOnly: latestOnly)));
  }

  Future<void> _openLicences(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    final info = await ref.read(packageInfoProvider.future);
    if (!context.mounted) return;
    showLicensePage(
      context: context,
      applicationName: 'Udo',
      applicationVersion: info.version,
      applicationLegalese: '© ${DateTime.now().year} Udo Weddings',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(packageInfoProvider).valueOrNull?.version ?? '1.0.0';

    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child:
                          Text('About Udo', style: UdoDesign.serif(size: 30))),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero),
                ]),
                const SizedBox(height: 8),
                Text('Udo v$version',
                    style: UdoDesign.sans(size: 13, color: UdoDesign.sub)),
                const SizedBox(height: 16),
                for (final item in [
                  (
                    Icons.new_releases_outlined,
                    'What\'s New',
                    'Recent product improvements',
                    (BuildContext c) =>
                        _openReleaseNotes(c, latestOnly: true),
                  ),
                  (
                    Icons.history_toggle_off_outlined,
                    'Version History',
                    'Release notes and app changes',
                    (BuildContext c) =>
                        _openReleaseNotes(c, latestOnly: false),
                  ),
                  (
                    Icons.privacy_tip_outlined,
                    'Privacy Policy',
                    'How wedding and account data is handled',
                    (BuildContext c) =>
                        _openContentPage(c, 'privacy-policy', 'Privacy Policy'),
                  ),
                  (
                    Icons.description_outlined,
                    'Terms of Service',
                    'Product and subscription terms',
                    (BuildContext c) => _openContentPage(
                        c, 'terms-of-service', 'Terms of Service'),
                  ),
                  (
                    Icons.fact_check_outlined,
                    'Licences',
                    'Open source and third-party acknowledgements',
                    (BuildContext c) => _openLicences(c, ref),
                  ),
                  (
                    Icons.business_outlined,
                    'Company Information',
                    'About the Udo wedding platform',
                    (BuildContext c) => _openContentPage(
                        c, 'company-information', 'Company Information'),
                  ),
                ])
                  ListTile(
                    leading: Icon(item.$1, color: _moreAccent, size: 20),
                    title: Text(item.$2,
                        style:
                            UdoDesign.sans(size: 14, weight: FontWeight.w700)),
                    subtitle: Text(item.$3,
                        style:
                            UdoDesign.sans(size: 12, color: UdoDesign.muted)),
                    trailing: const Icon(Icons.chevron_right,
                        size: 18, color: UdoDesign.muted),
                    contentPadding: EdgeInsets.zero,
                    onTap: () => item.$4(context),
                  ),
              ]),
        ),
      );
  }
}

class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet();
  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final _ctrl = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Expanded(
                      child: Text('Send feedback',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600))),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero),
                ]),
                const SizedBox(height: 8),
                const Text('How would you rate Udo?',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                    children: List.generate(
                        5,
                        (i) => GestureDetector(
                              onTap: () => setState(() => _rating = i + 1),
                              child: Icon(
                                  i < _rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 32),
                            ))),
                const SizedBox(height: 16),
                const Text('Tell us more',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: _ctrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'What could we improve?',
                    hintStyle: const TextStyle(
                        color: AppTheme.udoTextSecondary, fontSize: 14),
                    filled: true,
                    fillColor: AppTheme.udoCardFill,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Thank you for your feedback!')));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: AppTheme.udoGreen,
                      foregroundColor: Colors.white),
                  child: const Text('Submit feedback'),
                ),
              ]),
        ),
      );
}
