import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/registry_models.dart';
import '../providers/registry_provider.dart';

class RegistryScreen extends ConsumerWidget {
  const RegistryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registryNotifierProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          surfaceTintColor: AppColors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: AppColors.grey700),
            onPressed: () => Navigator.of(context).pop(),
          ),
          titleSpacing: 0,
          title: Row(children: [
            Text('Registry',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey700)),
            const SizedBox(width: 8),
            if (state.loadStatus == RegistryLoadStatus.loaded &&
                state.summary.thankYousPending > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${state.summary.thankYousPending} pending',
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
          ]),
          bottom: TabBar(
            labelColor: AppColors.pinkGradientStart,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: AppColors.pinkGradientStart,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2,
            dividerColor: AppColors.grey200,
            labelStyle:
                GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle:
                GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'Gifts'),
              Tab(text: 'Cash Fund'),
              Tab(text: 'Thank-yous'),
            ],
          ),
        ),
        body: state.loadStatus == RegistryLoadStatus.loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.pinkGradientStart))
            : state.loadStatus == RegistryLoadStatus.error
                ? _ErrorView(
                    onRetry: () =>
                        ref.read(registryNotifierProvider.notifier).refresh())
                : TabBarView(children: [
                    _GiftsTab(state: state),
                    _CashFundTab(state: state),
                    _ThankYousTab(state: state),
                  ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GIFTS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _GiftsTab extends ConsumerStatefulWidget {
  const _GiftsTab({required this.state});
  final RegistryState state;

  @override
  ConsumerState<_GiftsTab> createState() => _GiftsTabState();
}

class _GiftsTabState extends ConsumerState<_GiftsTab> {
  String _filter = 'all'; // all | unclaimed | claimed

  List<RegistryItem> get _filtered => switch (_filter) {
        'unclaimed' => widget.state.unclaimed,
        'claimed'   => widget.state.claimed,
        _           => widget.state.items,
      };

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: RefreshIndicator(
        color: AppColors.pinkGradientStart,
        onRefresh: () =>
            ref.read(registryNotifierProvider.notifier).refresh(),
        child: CustomScrollView(slivers: [
          // Summary strip
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(children: [
                _SummaryChip(
                    label: 'Total', value: '${s.summary.totalItems}',
                    color: AppColors.grey600),
                const SizedBox(width: 8),
                _SummaryChip(
                    label: 'Claimed',
                    value: '${s.summary.claimed}',
                    color: AppColors.teal),
                const SizedBox(width: 8),
                _SummaryChip(
                    label: 'Value',
                    value: fmt.format(s.summary.claimedValue),
                    color: AppColors.pinkGradientStart),
              ]),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                children: [
                  for (final (val, label) in [
                    ('all', 'All ${s.summary.totalItems}'),
                    ('unclaimed', 'Available ${s.summary.unclaimed}'),
                    ('claimed', 'Claimed ${s.summary.claimed}'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: _filter == val,
                        onSelected: (_) => setState(() => _filter = val),
                        backgroundColor: AppColors.white,
                        selectedColor:
                            AppColors.pinkGradientStart.withValues(alpha: 0.1),
                        checkmarkColor: AppColors.pinkGradientStart,
                        side: BorderSide(
                          color: _filter == val
                              ? AppColors.pinkGradientStart
                              : AppColors.grey200,
                        ),
                        labelStyle: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _filter == val
                              ? AppColors.pinkGradientStart
                              : AppColors.grey600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Item list
          if (_filtered.isEmpty)
            SliverFillRemaining(child: _EmptyGifts(filter: _filter))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              sliver: SliverList.builder(
                itemCount: _filtered.length,
                itemBuilder: (_, i) => _GiftCard(item: _filtered[i]),
              ),
            ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _AddItemSheet.show(context),
        backgroundColor: AppColors.pinkGradientStart,
        elevation: 2,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(children: [
          Text(value,
              style: GoogleFonts.dmSans(
                  fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppColors.grey500)),
        ]),
      ),
    );
  }
}

class _GiftCard extends ConsumerWidget {
  const _GiftCard({required this.item});
  final RegistryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref
        .watch(registryNotifierProvider)
        .busyIds
        .contains(item.id);
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 20),
      ),
      confirmDismiss: (_) async => await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Remove gift?',
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.w700, fontSize: 17)),
          content: Text('Remove "${item.title}" from your registry?',
              style: GoogleFonts.dmSans(fontSize: 13)),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Remove',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
      onDismissed: (_) =>
          ref.read(registryNotifierProvider.notifier).deleteItem(item.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isClaimed
              ? const Color(0xFFF0FDF4)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isClaimed
                ? AppColors.teal.withValues(alpha: 0.3)
                : AppColors.grey200,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(item.title,
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey700,
                      decoration: item.isClaimed
                          ? TextDecoration.lineThrough
                          : null)),
            ),
            if (item.price != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(fmt.format(item.price),
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey600)),
              ),
          ]),
          if (item.description != null) ...[
            const SizedBox(height: 4),
            Text(item.description!,
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppColors.grey500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 10),
          Row(children: [
            if (item.url != null)
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: item.url!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Link copied',
                          style: GoogleFonts.dmSans(fontSize: 13)),
                      backgroundColor: AppColors.teal,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    const Icon(Icons.link_rounded,
                        size: 13, color: AppColors.grey500),
                    const SizedBox(width: 4),
                    Text('View item',
                        style: GoogleFonts.dmSans(
                            fontSize: 11, color: AppColors.grey500)),
                  ]),
                ),
              ),
            if (item.category != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.blushLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(item.category!,
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.pinkGradientStart)),
              ),
            ],
            const Spacer(),
            if (item.isClaimed)
              Row(children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.teal, size: 16),
                const SizedBox(width: 4),
                Text(
                  item.claimedByName != null
                      ? 'By ${item.claimedByName}'
                      : 'Claimed',
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: isBusy
                      ? null
                      : () => ref
                          .read(registryNotifierProvider.notifier)
                          .unclaimItem(item.id),
                  child: Text('Undo',
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.grey400,
                          decoration: TextDecoration.underline)),
                ),
              ])
            else
              GestureDetector(
                onTap: isBusy
                    ? null
                    : () => _ClaimSheet.show(context, item),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.pinkGradientStart,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: isBusy
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Mark claimed',
                          style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                ),
              ),
          ]),
        ]),
      ),
    );
  }
}

class _EmptyGifts extends StatelessWidget {
  const _EmptyGifts({required this.filter});
  final String filter;

  @override
  Widget build(BuildContext context) {
    final (icon, label, sub) = switch (filter) {
      'claimed' => (
          Icons.check_circle_outline_rounded,
          'Nothing claimed yet',
          'Items will appear here when guests claim them.'
        ),
      'unclaimed' => (
          Icons.card_giftcard_rounded,
          'All gifts claimed!',
          'Your guests have claimed everything on your list.'
        ),
      _ => (
          Icons.card_giftcard_rounded,
          'No gifts yet',
          'Tap + to add items to your registry.'
        ),
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 48, color: AppColors.grey300),
          const SizedBox(height: 14),
          Text(label,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey700)),
          const SizedBox(height: 6),
          Text(sub,
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppColors.grey500, height: 1.5),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CASH FUND TAB
// ─────────────────────────────────────────────────────────────────────────────

class _CashFundTab extends ConsumerStatefulWidget {
  const _CashFundTab({required this.state});
  final RegistryState state;

  @override
  ConsumerState<_CashFundTab> createState() => _CashFundTabState();
}

class _CashFundTabState extends ConsumerState<_CashFundTab> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _targetCtrl;
  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final f = widget.state.fund;
    _titleCtrl = TextEditingController(text: f?.title ?? 'Our Honeymoon Fund');
    _descCtrl = TextEditingController(text: f?.description ?? '');
    _targetCtrl = TextEditingController(
        text: f?.targetAmount != null ? f!.targetAmount!.toStringAsFixed(0) : '');

    for (final c in [_titleCtrl, _descCtrl, _targetCtrl]) {
      c.addListener(() => setState(() => _dirty = true));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fund = widget.state.fund;
    final isActive = fund?.isActive ?? false;
    final shareToken = fund?.shareToken;
    final shareUrl = shareToken != null
        ? 'https://udo.app/fund/$shareToken'
        : 'https://udo.app/fund/—';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // Active toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [AppColors.pinkGradientStart, AppColors.pinkGradientEnd])
                : null,
            color: isActive ? null : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: isActive ? null : Border.all(color: AppColors.grey200),
          ),
          child: Row(children: [
            Icon(
              isActive ? Icons.volunteer_activism_rounded : Icons.volunteer_activism_outlined,
              color: isActive ? Colors.white : AppColors.grey400,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  isActive ? 'Fund is live' : 'Cash fund disabled',
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : AppColors.grey700),
                ),
                Text(
                  isActive
                      ? 'Guests can see and contribute to your fund.'
                      : 'Enable to let guests contribute directly.',
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.85)
                          : AppColors.grey500),
                ),
              ]),
            ),
            Switch.adaptive(
              value: isActive,
              onChanged: (_) => ref
                  .read(registryNotifierProvider.notifier)
                  .updateFund({'is_active': !isActive}),
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.white.withValues(alpha: 0.4),
              inactiveThumbColor: AppColors.grey400,
              inactiveTrackColor: AppColors.grey200,
            ),
          ]),
        ),
        const SizedBox(height: 12),

        // Share link
        if (isActive) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Share link',
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal)),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(
                  child: Text(shareUrl,
                      style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppColors.grey700,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: shareUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Link copied',
                            style: GoogleFonts.dmSans(fontSize: 13)),
                        backgroundColor: AppColors.teal,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Copy',
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
        ],

        // Fund details form
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Fund details',
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700)),
            const SizedBox(height: 12),
            _InputField(label: 'Title', ctrl: _titleCtrl, hint: 'e.g. Our Honeymoon Fund'),
            const SizedBox(height: 10),
            _InputField(
                label: 'Description',
                ctrl: _descCtrl,
                hint: 'Tell guests what you\'re saving for…',
                maxLines: 3),
            const SizedBox(height: 10),
            _InputField(
              label: 'Target amount (optional)',
              ctrl: _targetCtrl,
              hint: 'e.g. 5000',
              keyboardType: TextInputType.number,
            ),
            if (_dirty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pinkGradientStart,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text('Save changes',
                          style: GoogleFonts.dmSans(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ]),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final target = double.tryParse(_targetCtrl.text.trim());
    await ref.read(registryNotifierProvider.notifier).updateFund({
      'title': _titleCtrl.text.trim(),
      if (_descCtrl.text.trim().isNotEmpty)
        'description': _descCtrl.text.trim(),
      if (target != null) 'target_amount': target,
    });
    if (mounted) setState(() { _saving = false; _dirty = false; });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THANK-YOUS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _ThankYousTab extends ConsumerWidget {
  const _ThankYousTab({required this.state});
  final RegistryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = state.thankYouPending;
    final done = state.thanked;

    if (state.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.favorite_border_rounded,
                size: 48, color: AppColors.grey300),
            const SizedBox(height: 14),
            Text('No gifts yet',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey700)),
            const SizedBox(height: 6),
            Text('Add gifts to your registry and track thank-yous here.',
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: AppColors.grey500, height: 1.5),
                textAlign: TextAlign.center),
          ]),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.pinkGradientStart,
      onRefresh: () =>
          ref.read(registryNotifierProvider.notifier).refresh(),
      child: CustomScrollView(slivers: [
        // Progress header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: done.isNotEmpty
                    ? const Color(0xFFE8F7F5)
                    : AppColors.blushLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Icon(
                  done.length == state.claimed.length && state.claimed.isNotEmpty
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: done.isNotEmpty
                      ? AppColors.teal
                      : AppColors.pinkGradientStart,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                      pending.isEmpty
                          ? 'All thank-yous sent!'
                          : '${pending.length} thank-you${pending.length == 1 ? '' : 's'} to send',
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: pending.isEmpty
                              ? AppColors.teal
                              : AppColors.grey700),
                    ),
                    if (state.claimed.isNotEmpty)
                      Text(
                        '${done.length} of ${state.claimed.length} sent',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppColors.grey500),
                      ),
                  ]),
                ),
              ]),
            ),
          ),
        ),

        // Pending thank-yous
        if (pending.isNotEmpty) ...[
          _Header('SEND THANK-YOU', count: pending.length,
              color: const Color(0xFFF59E0B)),
          SliverList.builder(
            itemCount: pending.length,
            itemBuilder: (_, i) => _ThankYouRow(
              item: pending[i],
              isBusy: ref
                  .watch(registryNotifierProvider)
                  .busyIds
                  .contains(pending[i].id),
              onMark: () => ref
                  .read(registryNotifierProvider.notifier)
                  .markThanked(pending[i].id),
            ),
          ),
        ],

        // Done
        if (done.isNotEmpty) ...[
          _Header('SENT', count: done.length, color: AppColors.teal),
          SliverList.builder(
            itemCount: done.length,
            itemBuilder: (_, i) => _ThankYouRow(
                item: done[i], isBusy: false, onMark: null, isDone: true),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ]),
    );
  }
}

class _Header extends SliverToBoxAdapter {
  _Header(String label, {required int count, required Color color})
      : super(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Row(children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(label,
                  style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey500,
                      letterSpacing: 0.8)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$count',
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ),
            ]),
          ),
        );
}

class _ThankYouRow extends StatelessWidget {
  const _ThankYouRow({
    required this.item,
    required this.isBusy,
    required this.onMark,
    this.isDone = false,
  });
  final RegistryItem item;
  final bool isBusy;
  final VoidCallback? onMark;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDone ? const Color(0xFFF0FDF4) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone
                ? AppColors.teal.withValues(alpha: 0.25)
                : AppColors.grey200,
          ),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(item.title,
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey700)),
              if (item.claimedByName != null || item.price != null)
                Text(
                  [
                    if (item.claimedByName != null) 'From ${item.claimedByName}',
                    if (item.price != null) fmt.format(item.price),
                  ].join(' · '),
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: AppColors.grey500),
                ),
            ]),
          ),
          const SizedBox(width: 8),
          if (isDone)
            Row(children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.teal, size: 18),
              const SizedBox(width: 4),
              Text('Sent',
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal)),
            ])
          else
            GestureDetector(
              onTap: isBusy ? null : onMark,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isBusy
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF92400E)),
                      )
                    : Text('Mark sent',
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF92400E))),
              ),
            ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHEETS + HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _AddItemSheet extends ConsumerStatefulWidget {
  const _AddItemSheet();

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _AddItemSheet(),
      );

  @override
  ConsumerState<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<_AddItemSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  String? _category;
  bool _saving = false;

  static const _categories = [
    'Kitchen', 'Bedroom', 'Travel', 'Experiences',
    'Home', 'Tech', 'Entertainment', 'Other'
  ];

  @override
  void dispose() {
    for (final c in [_titleCtrl, _descCtrl, _priceCtrl, _urlCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Text('Add gift',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 20, fontWeight: FontWeight.w700,
                        color: AppColors.grey700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.grey400, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]),
              const SizedBox(height: 14),
              _InputField(label: 'Gift title', ctrl: _titleCtrl,
                  hint: 'e.g. KitchenAid Stand Mixer'),
              const SizedBox(height: 10),
              _InputField(label: 'Description (optional)', ctrl: _descCtrl,
                  hint: 'Any notes…', maxLines: 2),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: _InputField(
                    label: 'Price (optional)',
                    ctrl: _priceCtrl,
                    hint: '0',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Category',
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey500)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _category,
                      hint: Text('Optional',
                          style: GoogleFonts.dmSans(
                              fontSize: 13, color: AppColors.grey400)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.grey100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        isDense: true,
                      ),
                      items: _categories
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v),
                    ),
                  ]),
                ),
              ]),
              const SizedBox(height: 10),
              _InputField(label: 'Product link (optional)', ctrl: _urlCtrl,
                  hint: 'https://...'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pinkGradientStart,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : Text('Add to registry',
                          style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await ref.read(registryNotifierProvider.notifier).addItem({
      'title': _titleCtrl.text.trim(),
      if (_descCtrl.text.trim().isNotEmpty) 'description': _descCtrl.text.trim(),
      if (double.tryParse(_priceCtrl.text) != null)
        'price': double.parse(_priceCtrl.text),
      if (_urlCtrl.text.trim().isNotEmpty) 'url': _urlCtrl.text.trim(),
      if (_category != null) 'category': _category,
    });
    if (mounted) Navigator.of(context).pop();
  }
}

class _ClaimSheet extends ConsumerStatefulWidget {
  const _ClaimSheet({required this.item});
  final RegistryItem item;

  static Future<void> show(BuildContext context, RegistryItem item) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _ClaimSheet(item: item),
      );

  @override
  ConsumerState<_ClaimSheet> createState() => _ClaimSheetState();
}

class _ClaimSheetState extends ConsumerState<_ClaimSheet> {
  final _nameCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(
              child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text('Mark as claimed',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.grey700)),
            const SizedBox(height: 4),
            Text(widget.item.title,
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: AppColors.grey500)),
            const SizedBox(height: 16),
            _InputField(
                label: 'Claimed by (optional)',
                ctrl: _nameCtrl,
                hint: 'Guest name…'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Confirm',
                    style: GoogleFonts.dmSans(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);
    await ref.read(registryNotifierProvider.notifier).claimItem(
          widget.item.id,
          claimedByName: _nameCtrl.text.trim().isEmpty
              ? null
              : _nameCtrl.text.trim(),
        );
    if (mounted) Navigator.of(context).pop();
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.grey500)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey700),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey400),
          filled: true,
          fillColor: AppColors.grey100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          isDense: true,
        ),
      ),
    ]);
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: AppColors.grey400, size: 40),
        const SizedBox(height: 12),
        Text('Failed to load registry',
            style: GoogleFonts.dmSans(color: AppColors.grey500)),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ]),
    );
  }
}
