import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  static const _tabs = [
    _TabItem(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home_rounded),
    _TabItem(label: 'Plan', icon: Icons.checklist_outlined, activeIcon: Icons.checklist_rounded),
    _TabItem(label: 'Guests', icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded),
    _TabItem(label: 'Live', icon: Icons.radio_button_checked_outlined, activeIcon: Icons.radio_button_checked_rounded),
    _TabItem(label: 'Gallery', icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library_rounded),
    _TabItem(label: 'More', icon: Icons.menu_rounded, activeIcon: Icons.menu_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: IndexedStack(
        index: _currentTab,
        children: [
          const _HomeDashboard(),
          _ComingSoon(label: 'Plan', icon: Icons.checklist_rounded),
          _ComingSoon(label: 'Guests', icon: Icons.people_rounded),
          _ComingSoon(label: 'Live', icon: Icons.radio_button_checked_rounded),
          _ComingSoon(label: 'Gallery', icon: Icons.photo_library_rounded),
          _ComingSoon(label: 'More', icon: Icons.menu_rounded),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        tabs: _tabs,
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
      ),
    );
  }
}

// ─── Bottom navigation ────────────────────────────────────────────────────

class _TabItem {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_TabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.grey200)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: tabs.asMap().entries.map((entry) {
              final i = entry.key;
              final tab = entry.value;
              final isActive = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? tab.activeIcon : tab.icon,
                        size: 22,
                        color: isActive ? AppColors.hotPink : AppColors.grey400,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tab.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? AppColors.hotPink : AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Home dashboard placeholder (Phase 2 will flesh this out) ─────────────

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Row(
            children: [
              Text(
                'udo',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.hotPink,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.grey600),
              onPressed: () {},
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.grey200,
                child: const Icon(Icons.person_outline_rounded,
                    size: 18, color: AppColors.grey500),
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                'Your Wedding',
                style: AppTypography.headingLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Dashboard coming in Phase 2',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 32),
              _PlaceholderCard(
                title: 'Countdown',
                icon: Icons.timer_outlined,
                color: AppColors.hotPink,
              ),
              const SizedBox(height: 12),
              _PlaceholderCard(
                title: 'Guest Overview',
                icon: Icons.people_outline_rounded,
                color: AppColors.teal,
              ),
              const SizedBox(height: 12),
              _PlaceholderCard(
                title: 'Plan Progress',
                icon: Icons.checklist_rounded,
                color: AppColors.forestGreen,
              ),
              const SizedBox(height: 12),
              _PlaceholderCard(
                title: 'Budget Overview',
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.dustyRose,
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.headingSmall),
                const SizedBox(height: 2),
                Text(
                  'Phase 2 — coming soon',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.grey300, size: 20),
        ],
      ),
    );
  }
}

// ─── Coming soon placeholder for other tabs ───────────────────────────────

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.grey300),
          const SizedBox(height: 12),
          Text(label, style: AppTypography.headingMedium),
          const SizedBox(height: 4),
          Text('Coming in a future phase', style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
