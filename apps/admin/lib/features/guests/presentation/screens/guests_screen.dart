import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../tabs/overview_tab.dart';
import '../tabs/guest_list_tab.dart';
import '../tabs/invitations_tab.dart';
import '../tabs/experience_tab.dart';
import '../tabs/messages_tab.dart';
import '../tabs/logistics_tab.dart';
import '../sheets/add_guest_sheet.dart';

class GuestsScreen extends ConsumerStatefulWidget {
  const GuestsScreen({super.key});

  @override
  ConsumerState<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends ConsumerState<GuestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  static const _tabLabels = [
    'Overview',
    'Guest List',
    'Invitations',
    'Experience',
    'Messages',
    'Logistics',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _tabLabels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: AppColors.white,
            elevation: 0,
            scrolledUnderElevation: 1,
            titleSpacing: 20,
            title: Text(
              'Guests',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.grey700,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded,
                    color: AppColors.grey600),
                onPressed: () {
                  _tabs.animateTo(1);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton.icon(
                  onPressed: () => AddGuestSheet.show(context, ref),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.hotPink,
                    textStyle: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.hotPink,
              indicatorWeight: 2,
              labelColor: AppColors.hotPink,
              unselectedLabelColor: AppColors.grey500,
              labelStyle: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              tabs: _tabLabels.map((t) => Tab(text: t)).toList(),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: const [
            GuestsOverviewTab(),
            GuestListTab(),
            InvitationsTab(),
            ExperienceTab(),
            MessagesTab(),
            LogisticsTab(),
          ],
        ),
      ),
    );
  }
}
