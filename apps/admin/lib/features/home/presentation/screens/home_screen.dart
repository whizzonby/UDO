import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/home_stats_model.dart';
import '../../domain/home_state.dart';
import '../providers/home_provider.dart';
import '../widgets/hero_card.dart';
import '../widgets/todays_focus_section.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/udo_guidance_carousel.dart';
import '../widgets/check_in_card.dart';
import '../widgets/progress_card.dart';
import '../widgets/priorities_card.dart';
import '../widgets/guests_summary_card.dart';
import '../widgets/budget_card.dart';
import '../../../plan/presentation/screens/plan_screen.dart';
import '../../../guests/presentation/screens/guests_screen.dart';

// ─── Root screen — manages tab navigation ────────────────────────────────────

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
          const HomeDashboard(),
          const PlanScreen(),
          const GuestsScreen(),
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

// ─── Home Dashboard ───────────────────────────────────────────────────────────

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);

    return homeState.map(
      loading: (_) => const _LoadingView(),
      loaded: (s) => _LoadedView(stats: s.stats),
      error: (e) => _ErrorView(
        message: e.message,
        onRetry: () => ref.read(homeNotifierProvider.notifier).refresh(),
      ),
    );
  }
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBar(width: 80, height: 28),
            const SizedBox(height: 24),
            _SkeletonBar(width: double.infinity, height: 160),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _SkeletonBar(height: 80)),
                const SizedBox(width: 12),
                Expanded(child: _SkeletonBar(height: 80)),
              ],
            ),
            const SizedBox(height: 16),
            _SkeletonBar(width: double.infinity, height: 200),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatefulWidget {
  const _SkeletonBar({this.width = double.infinity, required this.height});
  final double width;
  final double height;

  @override
  State<_SkeletonBar> createState() => _SkeletonBarState();
}

class _SkeletonBarState extends State<_SkeletonBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.grey200.withValues(alpha: _anim.value),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text('Could not load your dashboard',
                style: AppTypography.headingSmall, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              'Check your connection and try again.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

// ─── Loaded dashboard ─────────────────────────────────────────────────────────

class _LoadedView extends ConsumerWidget {
  const _LoadedView({required this.stats});
  final HomeStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColors.hotPink,
      onRefresh: () => ref.read(homeNotifierProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          _HomeAppBar(wedding: stats.wedding),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Pink gradient hero with countdown
                HeroCard(wedding: stats.wedding),
                const SizedBox(height: 20),

                // 2. Today's focus checklist
                TodaysFocusSection(items: stats.todaysFocus),
                if (stats.todaysFocus.isNotEmpty) const SizedBox(height: 20),

                // 3. Quick actions 2×2 grid
                const QuickActionsGrid(),
                const SizedBox(height: 24),

                // 4. Udo guidance carousel
                UdoGuidanceCarousel(prompts: stats.guidancePrompts),
                const SizedBox(height: 24),

                // 5. Emotional check-in card
                const CheckInCard(),
                const SizedBox(height: 16),

                // 6. Progress card with category breakdown
                ProgressCard(plan: stats.plan),
                const SizedBox(height: 12),

                // 7. Priorities / alerts
                PrioritiesCard(
                  alerts: stats.alerts,
                  priorities: stats.priorities,
                ),
                if (stats.alerts.isNotEmpty || stats.priorities.isNotEmpty)
                  const SizedBox(height: 12),

                // 8. Guests summary card
                GuestsSummaryCard(overview: stats.guests),
                const SizedBox(height: 12),

                // 9. Budget card
                BudgetCard(budget: stats.budget),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── App bar ──────────────────────────────────────────────────────────────────

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.wedding});
  final WeddingInfo wedding;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 20,
      title: Text(
        'udo',
        style: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.hotPink,
          height: 1,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded,
              color: AppColors.grey600, size: 24),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.hotPink.withValues(alpha: 0.12),
            child: Text(
              wedding.partnerOneName.isNotEmpty
                  ? wedding.partnerOneName[0].toUpperCase()
                  : '?',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.hotPink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Bottom navigation ────────────────────────────────────────────────────────

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
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
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

// ─── Coming soon placeholder for future tabs ──────────────────────────────────

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
