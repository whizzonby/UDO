import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/plan_state.dart';
import '../providers/plan_provider.dart';
import '../tabs/tasks_tab.dart';
import '../tabs/timeline_tab.dart';
import '../tabs/vendors_tab.dart';
import '../tabs/budget_tab.dart';
import '../tabs/seating_tab.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(planNotifierProvider);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          surfaceTintColor: AppColors.white,
          titleSpacing: 20,
          title: Row(
            children: [
              Text('Plan', style: AppTypography.headingLarge),
              const SizedBox(width: 10),
              state.maybeMap(
                loaded: (s) {
                  final total = s.data.tasks.length;
                  final done = s.data.tasks.where((t) => t.isComplete).length;
                  final pct = total > 0 ? (done / total * 100).round() : 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.hotPink.withValues(alpha: 0.1),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Text(
                      '$pct%',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.hotPink,
                      ),
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          bottom: TabBar(
            labelColor: AppColors.hotPink,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: AppColors.hotPink,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2,
            dividerColor: AppColors.grey200,
            labelStyle: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'Tasks'),
              Tab(text: 'Timeline'),
              Tab(text: 'Vendors'),
              Tab(text: 'Budget'),
              Tab(text: 'Seating'),
            ],
          ),
        ),
        body: state.map(
          loading: (_) => const _PlanLoadingView(),
          loaded: (s) => TabBarView(
            children: [
              TasksTab(data: s.data),
              TimelineTab(data: s.data),
              VendorsTab(data: s.data),
              BudgetTab(data: s.data),
              const SeatingTab(),
            ],
          ),
          error: (e) => _PlanErrorView(
            message: e.message,
            onRetry: () =>
                ref.read(planNotifierProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}

class _PlanLoadingView extends StatelessWidget {
  const _PlanLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.hotPink,
        strokeWidth: 2,
      ),
    );
  }
}

class _PlanErrorView extends StatelessWidget {
  const _PlanErrorView({required this.message, required this.onRetry});
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
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text('Could not load your plan',
                style: AppTypography.headingSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text('Check your connection and try again.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
