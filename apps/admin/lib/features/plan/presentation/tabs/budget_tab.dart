import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/plan_models.dart';
import '../providers/plan_provider.dart';
import '../sheets/budget_item_form_sheet.dart';

class BudgetTab extends StatefulWidget {
  const BudgetTab({super.key, required this.data});
  final PlanData data;

  @override
  State<BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<BudgetTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  double get _totalBudgeted =>
      widget.data.budgetItems.fold(0.0, (s, b) => s + b.budgetedAmount);

  double get _totalPaid =>
      widget.data.budgetItems.fold(0.0, (s, b) => s + b.paidAmount);

  double get _remaining => widget.data.totalBudget - _totalPaid;

  double get _unallocated =>
      widget.data.totalBudget - _totalBudgeted;

  Map<String, List<BudgetItem>> get _byCategory {
    final map = <String, List<BudgetItem>>{};
    for (final item in widget.data.budgetItems) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final spentPct =
        widget.data.totalBudget > 0
            ? (_totalPaid / widget.data.totalBudget).clamp(0.0, 1.0)
            : 0.0;
    final barColor = spentPct > 0.9
        ? AppColors.error
        : spentPct > 0.7
            ? const Color(0xFFF59E0B)
            : AppColors.teal;

    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Hero summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2D5016), Color(0xFF3A5F0B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppSpacing.borderXl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget Overview',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      fmt.format(_totalPaid),
                      style: GoogleFonts.dmSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'of ${fmt.format(widget.data.totalBudget)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: AppSpacing.borderFull,
                  child: LinearProgressIndicator(
                    value: spentPct,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _SummaryCol(
                        label: 'Spent',
                        value: fmt.format(_totalPaid),
                        valueColor: Colors.white),
                    _SummaryCol(
                        label: 'Remaining',
                        value: fmt.format(_remaining),
                        valueColor: _remaining < 0
                            ? AppColors.dustyRose
                            : Colors.white),
                    _SummaryCol(
                        label: 'Budgeted',
                        value: fmt.format(_totalBudgeted),
                        valueColor: Colors.white.withValues(alpha: 0.7)),
                  ],
                ),
              ],
            ),
          ),
          // Unallocated banner
          if (_unallocated > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.08),
                borderRadius: AppSpacing.borderMd,
                border: Border.all(
                    color: AppColors.teal.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.teal),
                  const SizedBox(width: 8),
                  Text(
                    '${fmt.format(_unallocated)} unallocated in your budget',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Category breakdown
          ..._byCategory.entries.map((entry) => _CategorySection(
                category: entry.key,
                items: entry.value,
                totalBudget: widget.data.totalBudget,
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => BudgetItemFormSheet.show(context),
        backgroundColor: AppColors.forestGreen,
        elevation: 2,
        child: const Icon(Icons.add_rounded, color: AppColors.white),
      ),
    );
  }
}

class _SummaryCol extends StatelessWidget {
  const _SummaryCol(
      {required this.label,
      required this.value,
      required this.valueColor});
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends ConsumerWidget {
  const _CategorySection({
    required this.category,
    required this.items,
    required this.totalBudget,
  });
  final String category;
  final List<BudgetItem> items;
  final double totalBudget;

  static const _categoryColors = [
    AppColors.teal,
    AppColors.hotPink,
    AppColors.forestGreen,
    AppColors.dustyRose,
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    AppColors.info,
  ];

  static const _categoryList = [
    'Venue', 'Catering', 'Photography', 'Florals & Decor',
    'Entertainment', 'Attire', 'Other'
  ];

  Color get _color {
    final idx = _categoryList.indexOf(category);
    return idx >= 0
        ? _categoryColors[idx % _categoryColors.length]
        : AppColors.grey400;
  }

  double get _budgeted =>
      items.fold(0.0, (s, b) => s + b.budgetedAmount);
  double get _paid =>
      items.fold(0.0, (s, b) => s + b.paidAmount);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final pct = _budgeted > 0
        ? (_paid / _budgeted).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppSpacing.borderLg,
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          // Category header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                    Text(
                      '${fmt.format(_paid)} / ${fmt.format(_budgeted)}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: AppSpacing.borderFull,
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 4,
                    backgroundColor: AppColors.grey200,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_color),
                  ),
                ),
              ],
            ),
          ),
          // Line items
          const Divider(height: 1, color: AppColors.grey200),
          ...items.map((item) => _BudgetLineItem(
                item: item,
                accentColor: _color,
              )),
        ],
      ),
    );
  }
}

class _BudgetLineItem extends ConsumerWidget {
  const _BudgetLineItem(
      {required this.item, required this.accentColor});
  final BudgetItem item;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.error.withValues(alpha: 0.08),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 18),
      ),
      confirmDismiss: (_) async => await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete item?'),
          content: Text('Remove "${item.title}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete',
                    style: TextStyle(color: AppColors.error))),
          ],
        ),
      ),
      onDismissed: (_) => ref
          .read(planNotifierProvider.notifier)
          .deleteBudgetItem(item.id),
      child: InkWell(
        onTap: () => BudgetItemFormSheet.show(context, item: item),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey700,
                      ),
                    ),
                    if (item.paidAmount > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${fmt.format(item.paidAmount)} paid',
                        style: AppTypography.caption,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fmt.format(item.budgetedAmount),
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey700,
                    ),
                  ),
                  if (item.paidAmount >= item.budgetedAmount &&
                      item.budgetedAmount > 0)
                    Text(
                      'Paid in full',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
