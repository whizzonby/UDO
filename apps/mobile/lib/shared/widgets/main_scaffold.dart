import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'udo_design_system.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final _tabHistory = <int>[];
  int? _lastTabIndex;
  double? _dragStartX;
  double _dragDeltaX = 0;

  static const _tabs = [
    _TabItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        path: '/home'),
    _TabItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today,
        label: 'Plan',
        path: '/plan'),
    _TabItem(
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        label: 'Guests',
        path: '/guests'),
    _TabItem(
        icon: Icons.radio_button_checked_outlined,
        activeIcon: Icons.radio_button_checked,
        label: 'Live',
        path: '/live'),
    _TabItem(
        icon: Icons.photo_library_outlined,
        activeIcon: Icons.photo_library,
        label: 'Gallery',
        path: '/gallery'),
    _TabItem(
        icon: Icons.more_horiz,
        activeIcon: Icons.more_horiz,
        label: 'More',
        path: '/more'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final activeIndex = _activeTabIndex(location);
    _trackRoute(activeIndex);

    return Scaffold(
      backgroundColor: UdoDesign.bg,
      body: _shouldUseShellSwipe(location)
          ? GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragStart: (details) {
                _dragStartX = details.localPosition.dx;
                _dragDeltaX = 0;
              },
              onHorizontalDragUpdate: (details) {
                _dragDeltaX += details.delta.dx;
              },
              onHorizontalDragEnd: (details) {
                final fromLeftEdge = (_dragStartX ?? double.infinity) <= 36;
                final fastRightSwipe = details.primaryVelocity != null &&
                    details.primaryVelocity! > 450;
                if (fromLeftEdge && (_dragDeltaX > 72 || fastRightSwipe)) {
                  _goBackSection(activeIndex);
                }
                _dragStartX = null;
                _dragDeltaX = 0;
              },
              child: widget.child,
            )
          : widget.child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: UdoDesign.card,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: UdoDesign.stone),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs.map((tab) {
              final isActive = location.startsWith(tab.path);
              return _NavItem(
                  tab: tab,
                  isActive: isActive,
                  onTap: () => _navigateTo(tab.path));
            }).toList(),
          ),
        ),
      ),
    );
  }

  bool _shouldUseShellSwipe(String location) {
    if (location == '/plan') return false;
    if (_activeTabIndex(location) != -1) return true;
    // Shell pages with no bottom-tab of their own (e.g. /registry) still
    // swipe back to whichever tab was active before opening them.
    return _lastTabIndex != null;
  }

  int _activeTabIndex(String location) {
    return _tabs.indexWhere((tab) => location.startsWith(tab.path));
  }

  void _trackRoute(int activeIndex) {
    if (activeIndex == -1 || activeIndex == _lastTabIndex) return;
    final previous = _lastTabIndex;
    if (previous != null && previous >= 0) {
      _tabHistory.remove(previous);
      _tabHistory.add(previous);
      if (_tabHistory.length > 12) _tabHistory.removeAt(0);
    }
    _lastTabIndex = activeIndex;
  }

  Future<void> _navigateTo(String path) async {
    final index = _tabs.indexWhere((tab) => tab.path == path);
    final currentLocation = GoRouterState.of(context).matchedLocation;
    if (index == _lastTabIndex && currentLocation == path) {
      if (path == '/live') {
        context.go('/live?reset=${DateTime.now().millisecondsSinceEpoch}');
      }
      return;
    }
    if (ModalRoute.of(context)?.isCurrent == false) {
      await Navigator.of(context).maybePop();
      if (!mounted) return;
    }
    context.go(path);
  }

  void _goBackSection(int activeIndex) {
    if (activeIndex == -1) {
      // On a tab-less shell page (e.g. /registry): swipe back to the tab
      // that was active before this page was opened.
      final last = _lastTabIndex;
      if (last == null || last < 0 || last >= _tabs.length) return;
      context.go(_tabs[last].path);
      return;
    }
    if (activeIndex <= 0) return;
    final previous =
        _tabHistory.isNotEmpty ? _tabHistory.removeLast() : activeIndex - 1;
    if (previous == activeIndex || previous < 0 || previous >= _tabs.length) {
      return;
    }
    _lastTabIndex = previous;
    context.go(_tabs[previous].path);
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
  const _TabItem(
      {required this.icon,
      required this.activeIcon,
      required this.label,
      required this.path});
}

class _NavItem extends StatelessWidget {
  final _TabItem tab;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem(
      {required this.tab, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? UdoDesign.plan : UdoDesign.muted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 54,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 34,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isActive
                        ? UdoDesign.plan.withValues(alpha: 0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(isActive ? tab.activeIcon : tab.icon,
                      color: color, size: 21),
                ),
                const SizedBox(height: 3),
                Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(
                    size: 10,
                    color: color,
                    weight: isActive ? FontWeight.w700 : FontWeight.w500,
                    height: 1,
                  ),
                ),
              ],
            ),
            if (isActive)
              Positioned(
                bottom: 3,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: UdoDesign.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
