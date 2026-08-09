import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/utils/date_formatters.dart' as udo_dates;
import '../../../../shared/widgets/udo_design_system.dart';
import '../providers/home_provider.dart';

class EditorialHome extends StatelessWidget {
  final HomeState state;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onEditCoverPhoto;
  final int notificationCount;

  const EditorialHome({
    super.key,
    required this.state,
    required this.onProfileTap,
    required this.onNotificationTap,
    required this.onSettingsTap,
    required this.onEditCoverPhoto,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _EditorialHero(
          state: state,
          onProfileTap: onProfileTap,
          onNotificationTap: onNotificationTap,
          onSettingsTap: onSettingsTap,
          onEditCoverPhoto: onEditCoverPhoto,
          notificationCount: notificationCount,
        ),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: _HomeNotice(message: state.error!),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _TodayFocusCard(
              title: _focusTitle,
              subtitle: _focusSubtitle,
              estimate:
                  state.upcomingTasks.isNotEmpty ? '15 minutes' : '10 minutes',
              action: _focusAction,
              onTap: () => context.go(_focusRoute),
            ),
            const SizedBox(height: 24),
            _WeddingInvitationCard(
              state: state,
              onOpenPortal: () => _openGuestPortal(context),
            ),
            const SizedBox(height: 24),
            const UdoSectionHeader(title: 'Planning snapshot'),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.18,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                _SnapshotCard(
                  icon: Icons.task_alt_outlined,
                  label: 'Planning',
                  value: state.pendingTasks == 0
                      ? 'Clear'
                      : '${state.pendingTasks} left',
                  status: state.pendingTasks > 0 ? 'Needs focus' : 'On track',
                  color: UdoDesign.sage,
                  onTap: () => context.go('/plan?section=overview'),
                ),
                _SnapshotCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Budget',
                  value: _budgetLabel,
                  status: 'Review',
                  color: UdoDesign.gold,
                  onTap: () => context.go('/plan?section=budget'),
                ),
                _SnapshotCard(
                  icon: Icons.people_outline,
                  label: 'Guests',
                  value: '${state.confirmedGuests} RSVPs',
                  status: '${state.totalGuests} invited',
                  color: UdoDesign.blue,
                  onTap: () => context.go('/guests'),
                ),
                _SnapshotCard(
                  icon: Icons.schedule_outlined,
                  label: 'Timeline',
                  value: state.daysUntil == null
                      ? 'Set date'
                      : '${state.daysUntil} days',
                  status: 'Wedding clock',
                  color: UdoDesign.amber,
                  onTap: () => context.go('/plan?section=timeline'),
                ),
              ],
            ),
            const SizedBox(height: 26),
            UdoSectionHeader(
                title: 'Upcoming moments',
                action: 'See all',
                onAction: () => context.go('/plan?section=tasks')),
            _MomentsCard(tasks: state.upcomingTasks),
            const SizedBox(height: 24),
            const UdoSectionHeader(title: 'Recent activity'),
            _ActivityCard(state: state),
            const SizedBox(height: 24),
            _PlannerNoteCard(onTap: () => context.go('/plan')),
            const SizedBox(height: 24),
            const UdoSectionHeader(title: 'Quick actions'),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.55,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                _HomeActionButton(
                    icon: Icons.playlist_add,
                    label: 'Add Task',
                    subtitle: 'Plan your next step',
                    onTap: () => context.go('/plan?section=tasks')),
                _HomeActionButton(
                    icon: Icons.mark_email_read_outlined,
                    label: 'Invite Guests',
                    subtitle: 'Send an invitation',
                    onTap: () => context.go('/guests')),
                _HomeActionButton(
                    icon: Icons.auto_awesome_mosaic_outlined,
                    label: 'Upload Inspiration',
                    subtitle: 'Grow your vision board',
                    onTap: () => context.go('/plan?section=vision')),
                _HomeActionButton(
                    icon: Icons.photo_camera_outlined,
                    label: 'Upload Memory',
                    subtitle: 'Capture your journey',
                    onTap: () => context.go('/gallery')),
              ],
            ),
            const SizedBox(height: 24),
            UdoSectionHeader(
                title: 'Your Story',
                action: 'Gallery',
                onAction: () => context.go('/gallery')),
            _MemoryCard(state: state, onTap: () => context.go('/gallery')),
            const SizedBox(height: 12),
            _WeddingStoryPromoCard(onTap: () => context.push('/wedding-story')),
          ]),
        ),
      ],
    );
  }

  String get _focusTitle {
    if (state.upcomingTasks.isNotEmpty) {
      return state.upcomingTasks.first['title'] as String? ??
          'Finish your next planning task';
    }
    if (state.confirmedGuests < state.totalGuests) {
      return 'Review your RSVPs';
    }
    if ((state.budgetTotal ?? 0) > 0) {
      return 'Review your wedding budget';
    }
    return 'Set your wedding priorities';
  }

  String get _focusSubtitle {
    if (state.upcomingTasks.isNotEmpty) {
      return 'One focused planning step will move the day forward.';
    }
    if (state.confirmedGuests < state.totalGuests) {
      return '${state.totalGuests - state.confirmedGuests} guests still need attention.';
    }
    if ((state.budgetTotal ?? 0) > 0) {
      return 'Keep the money picture calm before it becomes urgent.';
    }
    return 'Start with the details that shape every decision after this.';
  }

  String get _focusAction {
    if (state.upcomingTasks.isNotEmpty) return 'Continue';
    if (state.confirmedGuests < state.totalGuests) return 'Review RSVPs';
    if ((state.budgetTotal ?? 0) > 0) return 'Review Budget';
    return 'Start Planning';
  }

  String get _focusRoute {
    if (state.confirmedGuests < state.totalGuests &&
        state.upcomingTasks.isEmpty) {
      return '/guests';
    }
    return '/plan';
  }

  Future<void> _openGuestPortal(BuildContext context) async {
    final url = state.guestPortalUrl;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guest portal link is not ready yet.')),
      );
      return;
    }
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  String get _budgetLabel {
    final total = state.budgetTotal ?? 0;
    final spent = state.budgetSpent ?? 0;
    if (total <= 0) return 'Not set';
    final remaining = (total - spent).clamp(0, double.infinity);
    final formatted =
        NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(remaining);
    return '$formatted left';
  }
}

class _EditorialHero extends StatelessWidget {
  final HomeState state;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onEditCoverPhoto;
  final int notificationCount;

  const _EditorialHero({
    required this.state,
    required this.onProfileTap,
    required this.onNotificationTap,
    required this.onSettingsTap,
    required this.onEditCoverPhoto,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 470,
      child: Stack(fit: StackFit.expand, children: [
        _HeroImage(
          path: state.coverPhotoPath,
          coupleName: state.coupleName,
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x661C1917),
                Color(0x111C1917),
                Color(0xDDF8F8F5),
                UdoDesign.bg
              ],
              stops: [0, 0.38, 0.78, 1],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _ProfileButton(
                    photoPath: state.couplePhotoPath, onTap: onProfileTap),
                const Spacer(),
                Text('Udo',
                    style: UdoDesign.serif(size: 24, color: Colors.white)),
                const Spacer(),
                _HeroRoundButton(
                    icon: Icons.notifications_none,
                    onTap: onNotificationTap,
                    badgeCount: notificationCount),
                const SizedBox(width: 8),
                _HeroRoundButton(
                    icon: Icons.camera_alt_outlined, onTap: onEditCoverPhoto),
                const SizedBox(width: 8),
                _HeroRoundButton(
                    icon: Icons.settings_outlined, onTap: onSettingsTap),
              ]),
              if (state.eventDate != null) ...[
                const SizedBox(height: 16),
                _HeroDateBadge(date: state.eventDate!),
              ],
              const Spacer(),
              Text('${state.greeting}, ${_firstName(state.coupleName)}',
                  style: UdoDesign.serif(size: 34, color: UdoDesign.text)),
              const SizedBox(height: 8),
              Text(_countdownLine,
                  style: UdoDesign.sans(
                      size: 17, weight: FontWeight.w600, color: UdoDesign.sub)),
              const SizedBox(height: 8),
              Text(_dynamicLine,
                  style: UdoDesign.sans(
                      size: 14, color: UdoDesign.muted, height: 1.45)),
            ]),
          ),
        ),
      ]),
    );
  }

  String get _countdownLine {
    final days = state.daysUntil;
    if (days == null) {
      return 'Your wedding journey starts here.';
    }
    if (days > 1) {
      return '$days days until forever.';
    }
    if (days == 1) {
      return 'Tomorrow is the day.';
    }
    if (days == 0) {
      return 'Today is the day.';
    }
    return 'Your wedding story continues.';
  }

  String get _dynamicLine {
    if (state.pendingTasks == 0) {
      return 'Everything important is calm today.';
    }
    if (state.upcomingTasks.isNotEmpty) {
      return 'Your next planning step is ready when you are.';
    }
    return '${state.pendingTasks} planning tasks are waiting for attention.';
  }

  static String _firstName(String names) {
    final cleaned = names.trim();
    if (cleaned.isEmpty) return 'there';
    final firstSide = cleaned
        .split(RegExp(r'\s*&\s*|\s+and\s+', caseSensitive: false))
        .first
        .trim();
    return firstSide.split(RegExp(r'\s+')).first;
  }
}

/// Bundled fallback so the hero always shows a real photo — used when the
/// couple hasn't set a cover photo yet, and as the error fallback if a
/// stored `cover_photo_path` fails to load (e.g. a stale/bad value).
const _kDefaultHeroAsset = 'assets/images/home_hero_default.png';

class _HeroImage extends StatelessWidget {
  final String? path;
  final String coupleName;
  const _HeroImage({required this.path, required this.coupleName});

  @override
  Widget build(BuildContext context) {
    final imagePath = path?.trim();
    if (imagePath != null && imagePath.isNotEmpty) {
      if (_isRemote(imagePath)) {
        return Image.network(
          _resolveRemote(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultPhoto(),
        );
      }
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => _defaultPhoto(),
      );
    }
    return _defaultPhoto();
  }

  Widget _defaultPhoto() => Image.asset(_kDefaultHeroAsset,
      fit: BoxFit.cover, alignment: Alignment.center);

  bool _isRemote(String value) =>
      value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('/storage/');

  String _resolveRemote(String value) {
    if (value.startsWith('/storage/')) return '${AppConstants.apiOrigin}$value';
    return value;
  }
}

class _HeroDateBadge extends StatelessWidget {
  final DateTime date;
  const _HeroDateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.calendar_today_outlined,
              size: 13, color: UdoDesign.sub),
          const SizedBox(width: 6),
          Text(DateFormat('EEE, MMM d, yyyy').format(date),
              style: UdoDesign.sans(
                  size: 12.5, weight: FontWeight.w600, color: UdoDesign.text)),
        ]),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String? photoPath;
  final VoidCallback onTap;
  const _ProfileButton({required this.photoPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && photoPath!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.72),
          border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
        ),
        child: hasPhoto
            ? ClipOval(
                child: Image.network(photoPath!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person_outline)))
            : const Icon(Icons.person_outline, color: UdoDesign.sub, size: 20),
      ),
    );
  }
}

class _HeroRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
  const _HeroRoundButton(
      {required this.icon, required this.onTap, this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
          ),
          child: Icon(icon, color: UdoDesign.sub, size: 19),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16),
              decoration: BoxDecoration(
                color: UdoDesign.rose,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
      ]),
    );
  }
}

class _TodayFocusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String estimate;
  final String action;
  final VoidCallback onTap;

  const _TodayFocusCard({
    required this.title,
    required this.subtitle,
    required this.estimate,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text("Today's focus",
              style: UdoDesign.sans(
                  size: 12, weight: FontWeight.w700, color: UdoDesign.gold)),
          const Spacer(),
          UdoBadge(label: estimate, color: UdoDesign.amber),
        ]),
        const SizedBox(height: 14),
        Text(title, style: UdoDesign.serif(size: 27)),
        const SizedBox(height: 8),
        Text(subtitle,
            style:
                UdoDesign.sans(size: 14, color: UdoDesign.muted, height: 1.5)),
        const SizedBox(height: 18),
        Row(children: [
          Text(action,
              style: UdoDesign.sans(
                  size: 14, weight: FontWeight.w700, color: UdoDesign.plan)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward, size: 16, color: UdoDesign.plan),
        ]),
      ]),
    );
  }
}

class _WeddingInvitationCard extends StatelessWidget {
  final HomeState state;
  final VoidCallback onOpenPortal;
  const _WeddingInvitationCard({
    required this.state,
    required this.onOpenPortal,
  });

  @override
  Widget build(BuildContext context) {
    final venueValue = (state.venueName ?? '').isNotEmpty
        ? state.venueName
        : state.receptionVenueName;
    final venue = (venueValue ?? '').isEmpty ? 'Not set' : venueValue!;
    final location =
        (state.destination ?? '').isEmpty ? 'Not set' : state.destination!;
    final ceremony = (state.ceremonyTime ?? '').isEmpty
        ? 'Not set'
        : _formatTime(state.ceremonyTime);
    final reception = (state.receptionTime ?? '').isEmpty
        ? 'Not set'
        : _formatTime(state.receptionTime);
    final dressCode =
        (state.dressCode ?? '').isEmpty ? 'Not set' : state.dressCode!;
    final website =
        (state.websiteUrl ?? '').isEmpty ? 'Not set' : state.websiteUrl!;

    return UdoCard(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your wedding',
            style: UdoDesign.sans(
                size: 12, weight: FontWeight.w700, color: UdoDesign.gold)),
        const SizedBox(height: 12),
        Text(state.coupleName.isEmpty ? 'Your Wedding' : state.coupleName,
            style: UdoDesign.serif(size: 30)),
        const SizedBox(height: 6),
        Text(
            [
              if (state.eventDate != null) _formatDate(state.eventDate!),
              if ((state.destination ?? '').isNotEmpty) state.destination!,
            ].join(' - '),
            style: UdoDesign.sans(size: 14, color: UdoDesign.muted)),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _WeddingFact(label: 'Venue', value: venue)),
          Expanded(child: _WeddingFact(label: 'Location', value: location)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _WeddingFact(label: 'Ceremony', value: ceremony)),
          Expanded(child: _WeddingFact(label: 'Reception', value: reception)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _WeddingFact(label: 'Dress code', value: dressCode)),
          Expanded(child: _WeddingFact(label: 'Website', value: website)),
        ]),
        if ((state.hashtag ?? '').isNotEmpty) ...[
          const SizedBox(height: 16),
          _WeddingFact(label: 'Hashtag', value: '#${state.hashtag}'),
        ],
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: onOpenPortal,
          icon: const Icon(Icons.link_outlined, size: 18),
          label: const Text('View guest portal'),
          style: OutlinedButton.styleFrom(
            foregroundColor: UdoDesign.plan,
            minimumSize: const Size(double.infinity, 46),
            side: BorderSide(color: UdoDesign.plan.withValues(alpha: 0.35)),
          ),
        ),
      ]),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  static String _formatTime(String? t) {
    return udo_dates.formatApiTime(t, fallback: 'Not set');
  }
}

class _WeddingFact extends StatelessWidget {
  final String label;
  final String value;
  const _WeddingFact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: UdoDesign.sans(
              size: 11, weight: FontWeight.w700, color: UdoDesign.muted)),
      const SizedBox(height: 4),
      Text(value,
          style: UdoDesign.sans(size: 15, weight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis),
    ]);
  }
}

class _SnapshotCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String status;
  final Color color;
  final VoidCallback onTap;

  const _SnapshotCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.status,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 19),
        ),
        const Spacer(),
        Text(label,
            style: UdoDesign.sans(
                size: 12, weight: FontWeight.w600, color: UdoDesign.muted)),
        const SizedBox(height: 5),
        Text(value,
            style: UdoDesign.sans(size: 18, weight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        UdoBadge(label: status, color: color),
      ]),
    );
  }
}

class _MomentsCard extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  const _MomentsCard({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final items = tasks.isEmpty
        ? [
            {'title': 'Review your wedding plan', 'due_date': 'Today'},
            {
              'title': 'Invite guests into the experience',
              'due_date': 'This week'
            },
            {
              'title': 'Add your next inspiration photo',
              'due_date': 'Any time'
            },
          ]
        : tasks.take(6).toList();
    return UdoCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        for (var i = 0; i < items.length; i++)
          _MomentRow(
            title: _momentTitle(items[i]),
            due: _momentDueLabel(items[i]),
            icon: _momentIcon(items[i], i),
            last: i == items.length - 1,
            onTap: () => context.go('/plan?section=tasks'),
          ),
      ]),
    );
  }

  String _momentTitle(Map<String, dynamic> task) {
    final display = (task['display_title'] as String?)?.trim();
    if (display != null && display.isNotEmpty) return display;
    final title = (task['title'] as String?)?.trim();
    return title == null || title.isEmpty ? 'Wedding moment' : title;
  }

  String _momentDueLabel(Map<String, dynamic> task) {
    final raw = task['due_date'];
    if (raw == null || raw.toString().trim().isEmpty) return 'No date set';
    final due = DateTime.tryParse(raw.toString());
    if (due == null) return raw.toString();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(due.year, due.month, due.day);
    final days = date.difference(today).inDays;
    final dateLabel = _shortDate(date);

    if (days < 0) return 'Overdue · $dateLabel';
    if (days == 0) return 'Today · $dateLabel';
    if (days == 1) return 'Tomorrow · $dateLabel';
    if (days < 7) return 'This week · $dateLabel';
    return dateLabel;
  }

  String _shortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  IconData _momentIcon(Map<String, dynamic> task, int index) {
    final text =
        '${task['display_title'] ?? ''} ${task['title'] ?? ''} ${task['category'] ?? ''}'
            .toLowerCase();
    if (text.contains('cake')) return Icons.cake_outlined;
    if (text.contains('menu') ||
        text.contains('meal') ||
        text.contains('food') ||
        text.contains('catering')) {
      return Icons.restaurant_menu_outlined;
    }
    if (text.contains('dress') ||
        text.contains('suit') ||
        text.contains('attire')) {
      return Icons.checkroom_outlined;
    }
    if (text.contains('venue') || text.contains('walkthrough')) {
      return Icons.account_balance_outlined;
    }
    if (text.contains('flower') || text.contains('florist')) {
      return Icons.local_florist_outlined;
    }
    return index == 0 ? Icons.event_available_outlined : Icons.task_alt;
  }
}

class _MomentRow extends StatelessWidget {
  final String title;
  final String due;
  final IconData icon;
  final bool last;
  final VoidCallback? onTap;

  const _MomentRow(
      {required this.title,
      required this.due,
      required this.icon,
      required this.last,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
            border: last
                ? null
                : const Border(bottom: BorderSide(color: UdoDesign.stone))),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: UdoDesign.stone.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: UdoDesign.sub, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: UdoDesign.sans(size: 14.5, weight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(due,
                    style: UdoDesign.sans(size: 12.5, color: UdoDesign.muted)),
              ])),
          const Icon(Icons.chevron_right, color: UdoDesign.muted, size: 18),
        ]),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final HomeState state;
  const _ActivityCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final rows = state.recentActivity.isEmpty
        ? [
            {
              'message': 'Your wedding workspace is ready',
              'time_ago': 'Start planning',
              'type': 'task',
              'target': 'tasks',
            }
          ]
        : state.recentActivity.take(6).toList();
    return UdoCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        for (var i = 0; i < rows.length; i++)
          _MomentRow(
            title: (rows[i]['message'] as String?) ??
                (rows[i]['title'] as String?) ??
                'Recent update',
            due: rows[i]['time_ago'] as String? ?? 'Recently',
            icon: _activityIcon(rows[i]['type'] as String?),
            last: i == rows.length - 1,
            onTap: () => context.go(_activityRoute(rows[i]['target'])),
          ),
      ]),
    );
  }

  IconData _activityIcon(String? type) {
    switch (type) {
      case 'rsvp':
        return Icons.mark_email_read_outlined;
      case 'timeline':
        return Icons.timeline_outlined;
      case 'weather':
        return Icons.wb_cloudy_outlined;
      case 'document':
        return Icons.description_outlined;
      case 'task':
      default:
        return Icons.task_alt_outlined;
    }
  }

  String _activityRoute(dynamic target) {
    switch (target) {
      case 'guests':
        return '/guests';
      case 'timeline':
        return '/plan?section=timeline';
      case 'weather':
        return '/live';
      case 'documents':
        return '/plan?section=documents';
      case 'tasks':
      default:
        return '/plan?section=tasks';
    }
  }
}

class _PlannerNoteCard extends StatelessWidget {
  final VoidCallback onTap;
  const _PlannerNoteCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(22),
      color: const Color(0xFFFFFCF6),
      border: BorderSide(color: UdoDesign.gold.withValues(alpha: 0.34)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Today's planner note",
            style: UdoDesign.sans(
                size: 12, weight: FontWeight.w800, color: UdoDesign.gold)),
        const SizedBox(height: 12),
        Text(
          "Once your next priority is handled, the rest of today's planning can stay light. Focus on one useful decision, then close the planner.",
          style: UdoDesign.serif(size: 23, height: 1.22),
        ),
        const SizedBox(height: 18),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
              foregroundColor: UdoDesign.plan, padding: EdgeInsets.zero),
          child: Text('Continue Planning',
              style: UdoDesign.sans(
                  size: 14, weight: FontWeight.w800, color: UdoDesign.plan)),
        ),
      ]),
    );
  }
}

class _HomeActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _HomeActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 20,
      child: Row(children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: UdoDesign.rose.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: UdoDesign.plan, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: UdoDesign.sans(size: 13, weight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(subtitle,
              style: UdoDesign.sans(size: 11.5, color: UdoDesign.muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }
}

class _WeddingStoryPromoCard extends StatelessWidget {
  final VoidCallback onTap;
  const _WeddingStoryPromoCard({required this.onTap});

  @override
  Widget build(BuildContext context) => UdoCard(
        onTap: onTap,
        padding: const EdgeInsets.all(20),
        color: UdoDesign.plan,
        border: BorderSide.none,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.auto_stories_outlined,
              color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Your Wedding Story',
                    style: UdoDesign.serif(size: 19, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                    'Engagement, planning, the big day, and beyond — turned into a living keepsake.',
                    style: UdoDesign.sans(
                        size: 12.5, color: Colors.white70, height: 1.4)),
                const SizedBox(height: 12),
                Row(children: [
                  Text('View full story',
                      style: UdoDesign.sans(
                          size: 13,
                          weight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward,
                      color: Colors.white, size: 16),
                ]),
              ])),
        ]),
      );
}

class _MemoryCard extends StatelessWidget {
  final HomeState state;
  final VoidCallback onTap;
  const _MemoryCard({required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imagePath = _bestImagePath;
    final hasImage = imagePath != null && imagePath.isNotEmpty;
    final count = state.galleryPhotoCount;
    return UdoCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 230,
          child: Stack(fit: StackFit.expand, children: [
            if (hasImage)
              _MemoryCardImage(path: imagePath)
            else
              _MemoryPlaceholder(coupleName: state.coupleName),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xC41C1917)],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Memory of the day',
                        style: UdoDesign.sans(
                            size: 12,
                            weight: FontWeight.w800,
                            color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(
                        hasImage
                            ? (count > 1
                                ? '$count moments added to your wedding story'
                                : 'Recently added to your wedding story')
                            : 'Your wedding gallery will appear here',
                        style: UdoDesign.serif(size: 24, color: Colors.white)),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }

  String? get _bestImagePath {
    final choices = [
      state.galleryPreviewPhotoPath,
      state.coverPhotoPath,
      state.couplePhotoPath,
    ];
    for (final choice in choices) {
      final trimmed = choice?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }
}

class _MemoryCardImage extends StatelessWidget {
  final String path;
  const _MemoryCardImage({required this.path});

  @override
  Widget build(BuildContext context) {
    if (_isRemote(path)) {
      return Image.network(
        _resolveRemote(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _MemoryPlaceholder(),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _MemoryPlaceholder(),
    );
  }

  bool _isRemote(String value) =>
      value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('/storage/');

  String _resolveRemote(String value) {
    if (value.startsWith('/storage/')) return '${AppConstants.apiOrigin}$value';
    return value;
  }
}

class _MemoryPlaceholder extends StatelessWidget {
  final String? coupleName;
  const _MemoryPlaceholder({this.coupleName});

  @override
  Widget build(BuildContext context) {
    final names = coupleName?.trim();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7EEE9),
            Color(0xFFE7DED4),
            Color(0xFFD6E1D2),
          ],
        ),
      ),
      child: Stack(children: [
        Positioned(
          top: 24,
          right: 26,
          child: Icon(Icons.photo_library_outlined,
              size: 78, color: Colors.white.withValues(alpha: 0.38)),
        ),
        Positioned(
          left: 28,
          bottom: 34,
          child: Icon(Icons.auto_awesome,
              size: 48, color: Colors.white.withValues(alpha: 0.34)),
        ),
        Center(
          child: Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.58),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.72), width: 1.2),
            ),
            child: const Icon(Icons.add_photo_alternate_outlined,
                color: UdoDesign.sub, size: 34),
          ),
        ),
        if (names != null && names.isNotEmpty)
          Positioned(
            top: 26,
            left: 22,
            child: Text(
              names,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UdoDesign.serif(
                  size: 21, color: UdoDesign.text.withValues(alpha: 0.78)),
            ),
          ),
      ]),
    );
  }
}

class _HomeNotice extends StatelessWidget {
  final String message;
  const _HomeNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(14),
      radius: 18,
      color: const Color(0xFFFFF8E8),
      border: const BorderSide(color: Color(0xFFE8C36A)),
      child: Row(children: [
        const Icon(Icons.wifi_off_outlined, size: 18, color: Color(0xFF9A6B00)),
        const SizedBox(width: 10),
        Expanded(
            child: Text(message,
                style:
                    UdoDesign.sans(size: 12, color: const Color(0xFF6B4B00)))),
      ]),
    );
  }
}
