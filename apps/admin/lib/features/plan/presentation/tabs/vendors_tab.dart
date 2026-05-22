import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/plan_models.dart';
import '../providers/plan_provider.dart';
import '../sheets/vendor_form_sheet.dart';

class VendorsTab extends StatefulWidget {
  const VendorsTab({super.key, required this.data});
  final PlanData data;

  @override
  State<VendorsTab> createState() => _VendorsTabState();
}

class _VendorsTabState extends State<VendorsTab>
    with AutomaticKeepAliveClientMixin {
  String? _selectedCategory;

  @override
  bool get wantKeepAlive => true;

  List<String> get _categories {
    final cats = widget.data.vendors.map((v) => v.category).toSet().toList()
      ..sort();
    return cats;
  }

  List<Vendor> get _filtered {
    if (_selectedCategory == null) return widget.data.vendors;
    return widget.data.vendors
        .where((v) => v.category == _selectedCategory)
        .toList();
  }

  int get _confirmedCount => widget.data.vendors
      .where((v) => v.status == VendorStatus.confirmed)
      .length;

  int get _bookedCount => widget.data.vendors
      .where((v) =>
          v.status == VendorStatus.booked ||
          v.status == VendorStatus.confirmed)
      .length;

  double get _totalContract =>
      widget.data.vendors.fold(0.0, (s, v) => s + v.contractAmount);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Stats row
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: AppColors.grey200)),
            ),
            child: Row(
              children: [
                _StatChip(
                  label: 'Total',
                  value: '${widget.data.vendors.length}',
                  color: AppColors.grey600,
                ),
                const SizedBox(width: 12),
                _StatChip(
                  label: 'Booked',
                  value: '$_bookedCount',
                  color: AppColors.teal,
                ),
                const SizedBox(width: 12),
                _StatChip(
                  label: 'Confirmed',
                  value: '$_confirmedCount',
                  color: AppColors.forestGreen,
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      fmt.format(_totalContract),
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey700,
                      ),
                    ),
                    Text('total contracted',
                        style: AppTypography.caption),
                  ],
                ),
              ],
            ),
          ),
          // Category filter
          if (_categories.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = null),
                      backgroundColor: AppColors.grey100,
                      selectedColor:
                          AppColors.hotPink.withValues(alpha: 0.1),
                      checkmarkColor: AppColors.hotPink,
                      side: BorderSide(
                        color: _selectedCategory == null
                            ? AppColors.hotPink
                            : Colors.transparent,
                      ),
                      labelStyle: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _selectedCategory == null
                            ? AppColors.hotPink
                            : AppColors.grey600,
                      ),
                    ),
                  ),
                  ..._categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _selectedCategory =
                                isSelected ? null : cat),
                        backgroundColor: AppColors.grey100,
                        selectedColor:
                            AppColors.hotPink.withValues(alpha: 0.1),
                        checkmarkColor: AppColors.hotPink,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.hotPink
                              : Colors.transparent,
                        ),
                        labelStyle: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.hotPink
                              : AppColors.grey600,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          const Divider(height: 1, color: AppColors.grey200),
          // Vendor list
          Expanded(
            child: _filtered.isEmpty
                ? const _EmptyVendors()
                : ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: _filtered.length,
                    itemBuilder: (context, idx) =>
                        _VendorCard(vendor: _filtered[idx]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => VendorFormSheet.show(context),
        backgroundColor: AppColors.teal,
        elevation: 2,
        child: const Icon(Icons.add_rounded, color: AppColors.white),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1,
          ),
        ),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

class _VendorCard extends ConsumerWidget {
  const _VendorCard({required this.vendor});
  final Vendor vendor;

  static const _statusColors = {
    VendorStatus.potential: AppColors.grey400,
    VendorStatus.booked: Color(0xFFF59E0B),
    VendorStatus.confirmed: AppColors.teal,
    VendorStatus.cancelled: AppColors.dustyRose,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _statusColors[vendor.status] ?? AppColors.grey400;
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final paidPct = vendor.contractAmount > 0
        ? (vendor.paidAmount / vendor.contractAmount).clamp(0.0, 1.0)
        : 0.0;

    return Dismissible(
      key: Key(vendor.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: AppSpacing.borderLg,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 20),
      ),
      confirmDismiss: (_) async => await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Remove vendor?'),
          content: Text('Remove "${vendor.name}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Remove',
                    style: TextStyle(color: AppColors.error))),
          ],
        ),
      ),
      onDismissed: (_) =>
          ref.read(planNotifierProvider.notifier).deleteVendor(vendor.id),
      child: GestureDetector(
        onTap: () => VendorFormSheet.show(context, vendor: vendor),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppSpacing.borderLg,
            border: Border.all(color: AppColors.grey200),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.grey100,
                                borderRadius: AppSpacing.borderFull,
                              ),
                              child: Text(
                                vendor.category,
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.borderFull,
                    ),
                    child: Text(
                      vendor.status.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (vendor.contactName != null || vendor.contactPhone != null) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.grey200),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (vendor.contactName != null) ...[
                      const Icon(Icons.person_outline_rounded,
                          size: 13, color: AppColors.grey400),
                      const SizedBox(width: 4),
                      Text(vendor.contactName!,
                          style: AppTypography.caption),
                      const SizedBox(width: 12),
                    ],
                    if (vendor.contactPhone != null) ...[
                      const Icon(Icons.phone_outlined,
                          size: 13, color: AppColors.grey400),
                      const SizedBox(width: 4),
                      Text(vendor.contactPhone!,
                          style: AppTypography.caption),
                    ],
                  ],
                ),
              ],
              if (vendor.contractAmount > 0) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${fmt.format(vendor.paidAmount)} paid of ${fmt.format(vendor.contractAmount)}',
                      style: AppTypography.caption,
                    ),
                    Text(
                      '${(paidPct * 100).round()}%',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: paidPct >= 1.0
                            ? AppColors.teal
                            : AppColors.grey500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: AppSpacing.borderFull,
                  child: LinearProgressIndicator(
                    value: paidPct,
                    minHeight: 4,
                    backgroundColor: AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      paidPct >= 1.0 ? AppColors.teal : const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyVendors extends StatelessWidget {
  const _EmptyVendors();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.handshake_outlined,
              size: 44, color: AppColors.grey300),
          const SizedBox(height: 12),
          Text('No vendors added', style: AppTypography.headingSmall),
          const SizedBox(height: 4),
          Text('Tap + to add a vendor', style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
