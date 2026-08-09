import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../providers/registry_provider.dart';

/// Registry money fields (`price`, `fund_goal`, `fund_raised`) are
/// `decimal:2`-cast on the backend, which Laravel serializes to JSON as
/// strings (e.g. "500.00") rather than numbers — an unguarded `as num?`
/// cast throws on that shape. Parse defensively instead.
String _money(double value) =>
    NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(value);

String _moneyCents(double value) =>
    NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);

double _asDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

class RegistryScreen extends ConsumerStatefulWidget {
  const RegistryScreen({super.key});
  @override
  ConsumerState<RegistryScreen> createState() => _RegistryScreenState();
}

class _RegistryScreenState extends ConsumerState<RegistryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _thankYouTabs;

  @override
  void initState() {
    super.initState();
    _thankYouTabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _thankYouTabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registryProvider);
    final notifier = ref.read(registryProvider.notifier);
    final hasItems = state.items.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.udoBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.udoGreen,
            expandedHeight: 90,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Registry',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: 'Playfair',
                          fontWeight: FontWeight.w400)),
                  if (hasItems)
                    Text('${state.items.length} items',
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            actions: hasItems
                ? [
                    IconButton(
                      icon:
                          const Icon(Icons.share_outlined, color: Colors.white),
                      onPressed: () => _showShareModal(context),
                    ),
                    const SizedBox(width: 4),
                  ]
                : null,
          ),
          if (state.isLoading)
            const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: AppTheme.udoGreen)))
          else if (!hasItems)
            SliverFillRemaining(child: _SetupFlow(notifier: notifier))
          else
            SliverList(
              delegate: SliverChildListDelegate([
                _CashFundCard(state: state),
                _ItemsGrid(state: state),
                _ThankYouTracker(
                    state: state, tabs: _thankYouTabs, notifier: notifier),
                _SmartReminders(),
                const SizedBox(height: 100),
              ]),
            ),
        ],
      ),
      floatingActionButton: hasItems
          ? FloatingActionButton.extended(
              onPressed: () => _showAddRegistryActions(context, notifier),
              backgroundColor: AppTheme.udoGreen,
              foregroundColor: Colors.white,
              label: const Text('Add to registry'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showShareModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _ShareModal(),
    );
  }

  void _showAddRegistryActions(
      BuildContext context, RegistryNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) =>
          _AddRegistryActionsModal(parentContext: context, notifier: notifier),
    );
  }
}

// ── SETUP FLOW ─────────────────────────────────────────────────────────────────

class _SetupFlow extends StatelessWidget {
  final RegistryNotifier notifier;
  const _SetupFlow({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const SizedBox(height: 12),
        const Text(
          'What kind of registry\nwould you like?',
          style: TextStyle(
              fontFamily: 'Playfair',
              fontSize: 24,
              fontWeight: FontWeight.w400,
              height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'You can mix and match — add as many as you like.',
          style: TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        _SetupCard(
          icon: Icons.volunteer_activism_outlined,
          iconColor: AppTheme.udoGreen,
          title: 'Contribute to our future',
          description:
              'A cash fund guests can contribute to — honeymoon, home, adventures together.',
          action: 'Create cash fund',
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (_) => _CashFundCreateModal(notifier: notifier),
          ),
        ),
        const SizedBox(height: 12),
        _SetupCard(
          icon: Icons.link_outlined,
          iconColor: AppTheme.udoCrimson,
          title: 'Add something you love',
          description:
              'Paste a link from any store. We\'ll pull in the details automatically.',
          action: 'Add a link',
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (_) => _AddLinkModal(notifier: notifier),
          ),
        ),
        const SizedBox(height: 12),
        _SetupCard(
          icon: Icons.list_alt_outlined,
          iconColor: Colors.indigo,
          title: 'Create a wishlist',
          description:
              'Build a custom list with prices, quantities, and personal notes.',
          action: 'Start a wishlist',
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (_) => _AddItemModal(notifier: notifier),
          ),
        ),
      ]),
    );
  }
}

class _SetupCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, description, action;
  final VoidCallback onTap;
  const _SetupCard(
      {required this.icon,
      required this.iconColor,
      required this.title,
      required this.description,
      required this.action,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.udoBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500))),
          ]),
          const SizedBox(height: 10),
          Text(description,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5)),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: iconColor),
              foregroundColor: iconColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(action, style: const TextStyle(fontSize: 13)),
          ),
        ]),
      );
}

// ── CASH FUND CARD ─────────────────────────────────────────────────────────────

class _CashFundCard extends StatelessWidget {
  final RegistryState state;
  const _CashFundCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final cashFunds =
        state.items.where((i) => i['type'] == 'cash_fund').toList();
    if (cashFunds.isEmpty) return const SizedBox.shrink();

    final fund = cashFunds.first;
    final rawTarget = _asDouble(fund['fund_goal']) > 0
        ? _asDouble(fund['fund_goal'])
        : _asDouble(fund['price']);
    final target = rawTarget > 0 ? rawTarget : 5000.0;
    final raised = _asDouble(fund['fund_raised']) > 0
        ? _asDouble(fund['fund_raised'])
        : _asDouble(fund['contributions_total']);
    final progress = target > 0 ? min(raised / target, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.udoGreen, AppTheme.udoGreen.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.volunteer_activism_outlined,
              color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(fund['name'] as String? ?? 'Cash Fund',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16))),
        ]),
        if (fund['description'] != null) ...[
          const SizedBox(height: 4),
          Text(fund['description'] as String,
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
        const SizedBox(height: 14),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withValues(alpha: 0.3),
          valueColor: const AlwaysStoppedAnimation(Colors.white),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Text('${_money(raised)} raised',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Text('of ${_money(target)} goal',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
        const SizedBox(height: 4),
        Text('${(progress * 100).toStringAsFixed(0)}% funded',
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }
}

// ── ITEMS GRID ─────────────────────────────────────────────────────────────────

class _ItemsGrid extends StatelessWidget {
  final RegistryState state;
  const _ItemsGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final physical =
        state.items.where((i) => i['type'] != 'cash_fund').toList();
    if (physical.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(
              child: Text('Gift list',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          Text('${physical.length} items',
              style: const TextStyle(
                  color: AppTheme.udoTextSecondary, fontSize: 13)),
        ]),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: physical.length,
          itemBuilder: (_, i) => _ItemCard(item: physical[i]),
        ),
      ]),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ItemCard({required this.item});

  String get _status {
    if (item['purchased'] == true) return 'Gifted';
    if (item['reserved'] == true) return 'Reserved';
    return 'Available';
  }

  Color get _statusColor {
    switch (_status) {
      case 'Gifted':
        return const Color(0xFF22C55E);
      case 'Reserved':
        return AppTheme.udoCrimson;
      default:
        return AppTheme.udoGreen;
    }
  }

  void _share() {
    final name = item['name'] as String? ?? 'this gift';
    final url = item['store_url'] as String?;
    final priceText =
        item['price'] != null ? ' (${_moneyCents(_asDouble(item['price']))})' : '';
    final message = url != null && url.isNotEmpty
        ? '$name$priceText from our registry: $url'
        : '$name$priceText is on our wedding registry — let us know if you\'d like to gift it!';
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.udoBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                const Icon(Icons.card_giftcard_outlined,
                    color: AppTheme.udoGreen, size: 32),
                const SizedBox(height: 8),
                Text(item['name'] as String? ?? 'Item',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (item['price'] != null) ...[
                  const SizedBox(height: 4),
                  Text(_moneyCents(_asDouble(item['price'])),
                      style: const TextStyle(
                          color: AppTheme.udoTextSecondary, fontSize: 13))
                ],
              ])),
          const SizedBox(height: 8),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(_status,
                  style: TextStyle(
                      fontSize: 11,
                      color: _statusColor,
                      fontWeight: FontWeight.w500)),
            ),
            const Spacer(),
            InkWell(
              onTap: _share,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.share_outlined,
                    size: 16, color: AppTheme.udoTextSecondary),
              ),
            ),
          ]),
        ]),
      );
}

// ── THANK YOU TRACKER ──────────────────────────────────────────────────────────

class _ThankYouTracker extends StatelessWidget {
  final RegistryState state;
  final TabController tabs;
  final RegistryNotifier notifier;
  const _ThankYouTracker(
      {required this.state, required this.tabs, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final thankYous = state.summary['thank_yous'] is Map
        ? Map<String, dynamic>.from(state.summary['thank_yous'] as Map)
        : <String, dynamic>{};
    final pending =
        (thankYous['pending'] as List? ?? []).cast<Map<String, dynamic>>();
    final thanked =
        (thankYous['completed'] as List? ?? []).cast<Map<String, dynamic>>();
    final giftedCount = pending.length + thanked.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.udoBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.favorite_outline,
              color: AppTheme.udoCrimson, size: 18),
          const SizedBox(width: 8),
          const Text('Thank-you tracker',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: AppTheme.udoCrimson.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text('${thanked.length}/$giftedCount sent',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.udoCrimson,
                    fontWeight: FontWeight.w500)),
          ),
        ]),
        const SizedBox(height: 12),
        if (giftedCount == 0)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Your thank-you notes will appear here once gifts start arriving.',
              style: TextStyle(
                  color: AppTheme.udoTextSecondary, fontSize: 13, height: 1.5),
            ),
          )
        else ...[
          TabBar(
            controller: tabs,
            indicatorColor: AppTheme.udoGreen,
            labelColor: AppTheme.udoGreen,
            unselectedLabelColor: AppTheme.udoTextSecondary,
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            tabs: [
              Tab(text: 'Pending (${pending.length})'),
              Tab(text: 'Completed (${thanked.length})')
            ],
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: TabBarView(controller: tabs, children: [
              _ThankYouList(
                  items: pending, completed: false, notifier: notifier),
              _ThankYouList(
                  items: thanked, completed: true, notifier: notifier),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _ThankYouList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool completed;
  final RegistryNotifier notifier;
  const _ThankYouList(
      {required this.items, required this.completed, required this.notifier});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
          child: Text(
        completed ? 'No completed notes yet.' : 'All thank-yous sent!',
        style: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13),
      ));
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final item = items[i];
        final contribution = item['contribution'] is Map
            ? Map<String, dynamic>.from(item['contribution'] as Map)
            : <String, dynamic>{};
        final registryItem = contribution['item'] is Map
            ? Map<String, dynamic>.from(contribution['item'] as Map)
            : <String, dynamic>{};
        final guest = item['guest'] is Map
            ? Map<String, dynamic>.from(item['guest'] as Map)
            : null;
        final contributionId =
            item['contribution_id'] as int? ?? item['id'] as int?;
        final recipientName = item['recipient_name'] as String? ?? 'Guest';
        final giftName = registryItem['name'] as String? ?? 'Registry gift';
        final hasEmail = (guest?['email'] as String?)?.isNotEmpty == true;
        final hasPhone = (guest?['phone'] as String?)?.isNotEmpty == true;

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          title: Text(recipientName, style: const TextStyle(fontSize: 14)),
          subtitle: Text(giftName,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary)),
          trailing: completed
              ? const Icon(Icons.check_circle,
                  color: Color(0xFF22C55E), size: 20)
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    tooltip: 'Download printable card',
                    icon: const Icon(Icons.print_outlined, size: 18),
                    onPressed: () => _downloadCard(recipientName, giftName),
                  ),
                  if (contributionId != null && (hasEmail || hasPhone))
                    TextButton(
                      onPressed: () => showModalBottomSheet(
                        context: ctx,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24))),
                        builder: (_) => _ThankYouComposeSheet(
                          notifier: notifier,
                          contributionId: contributionId,
                          guestId: guest!['id'] as int,
                          recipientName: recipientName,
                          giftName: giftName,
                          hasEmail: hasEmail,
                          hasPhone: hasPhone,
                        ),
                      ),
                      child: const Text('Send message',
                          style: TextStyle(fontSize: 12)),
                    )
                  else
                    TextButton(
                      onPressed: contributionId == null
                          ? null
                          : () => notifier.markThanked(contributionId),
                      child: const Text('Mark sent',
                          style: TextStyle(fontSize: 12)),
                    ),
                ]),
        );
      },
    );
  }

  Future<void> _downloadCard(String recipientName, String giftName) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a5,
      build: (pw.Context ctx) => pw.Center(
        child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('Thank You',
                  style: pw.TextStyle(
                      fontSize: 32, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Dear $recipientName,',
                  style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
              pw.Text(
                'Thank you so much for the $giftName. Your generosity and thoughtfulness meant the world to us as we celebrated this new chapter together.',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Text('With love and gratitude',
                  style: const pw.TextStyle(fontSize: 12)),
            ]),
      ),
    ));
    await Printing.layoutPdf(
        onLayout: (_) => doc.save(), name: 'Thank-You-Card.pdf');
  }
}

class _ThankYouComposeSheet extends StatefulWidget {
  final RegistryNotifier notifier;
  final int contributionId;
  final int guestId;
  final String recipientName;
  final String giftName;
  final bool hasEmail;
  final bool hasPhone;
  const _ThankYouComposeSheet({
    required this.notifier,
    required this.contributionId,
    required this.guestId,
    required this.recipientName,
    required this.giftName,
    required this.hasEmail,
    required this.hasPhone,
  });

  @override
  State<_ThankYouComposeSheet> createState() => _ThankYouComposeSheetState();
}

class _ThankYouComposeSheetState extends State<_ThankYouComposeSheet> {
  late String _channel = widget.hasEmail ? 'email' : 'sms';
  bool _sending = false;
  late final String _firstName = widget.recipientName.split(' ').first;
  late final _subject = TextEditingController(text: 'Thank you, $_firstName!');
  late final _body = TextEditingController(
    text:
        "Thank you so much for the ${widget.giftName}, $_firstName! Your generosity meant so much to us.",
  );

  Future<void> _send() async {
    setState(() => _sending = true);
    final ok = await widget.notifier.sendThankYouMessage(
      contributionId: widget.contributionId,
      guestId: widget.guestId,
      channel: _channel,
      subject: _subject.text.trim(),
      body: _body.text.trim(),
    );
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(ok ? 'Thank-you message sent.' : "Couldn't send. Try again."),
      backgroundColor: ok ? AppTheme.udoGreen : AppTheme.udoCrimson,
    ));
    if (ok) Navigator.pop(context);
  }

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
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
                Expanded(
                    child: Text('Thank ${widget.recipientName}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero),
              ]),
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: [
                if (widget.hasEmail)
                  ChoiceChip(
                      label: const Text('Email'),
                      selected: _channel == 'email',
                      onSelected: (_) => setState(() => _channel = 'email')),
                if (widget.hasPhone)
                  ChoiceChip(
                      label: const Text('SMS'),
                      selected: _channel == 'sms',
                      onSelected: (_) => setState(() => _channel = 'sms')),
                if (widget.hasPhone)
                  ChoiceChip(
                      label: const Text('WhatsApp'),
                      selected: _channel == 'whatsapp',
                      onSelected: (_) => setState(() => _channel = 'whatsapp')),
              ]),
              const SizedBox(height: 14),
              TextField(
                  controller: _subject,
                  decoration: InputDecoration(
                      labelText: 'Subject',
                      filled: true,
                      fillColor: AppTheme.udoCardFill,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none))),
              const SizedBox(height: 12),
              TextField(
                  controller: _body,
                  maxLines: 4,
                  decoration: InputDecoration(
                      labelText: 'Message',
                      filled: true,
                      fillColor: AppTheme.udoCardFill,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sending ? null : _send,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    backgroundColor: AppTheme.udoGreen,
                    foregroundColor: Colors.white),
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Send thank-you'),
              ),
              const SizedBox(height: 8),
            ]),
      ));
}

// ── SMART REMINDERS ────────────────────────────────────────────────────────────

class _SmartReminders extends StatefulWidget {
  @override
  State<_SmartReminders> createState() => _SmartRemindersState();
}

class _SmartRemindersState extends State<_SmartReminders> {
  bool _guestReminders = true;
  bool _thankYouReminders = true;
  String _tone = 'gentle';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.udoBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.notifications_outlined,
              color: AppTheme.udoGreen, size: 18),
          const SizedBox(width: 8),
          const Text('Smart reminders',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 14),
        _ReminderRow(
          title: 'Guest reminders',
          description: 'Remind guests to check your registry after RSVP',
          value: _guestReminders,
          onChanged: (v) => setState(() => _guestReminders = v),
        ),
        const Divider(height: 20),
        _ReminderRow(
          title: 'Thank-you prompts',
          description: 'Remind you to send thank-you notes after the wedding',
          value: _thankYouReminders,
          onChanged: (v) => setState(() => _thankYouReminders = v),
        ),
        const Divider(height: 20),
        const Text('Message tone',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(children: [
          for (final t in ['gentle', 'warm', 'playful'])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(t[0].toUpperCase() + t.substring(1),
                    style: const TextStyle(fontSize: 13)),
                selected: _tone == t,
                selectedColor: AppTheme.udoGreen,
                labelStyle: TextStyle(
                    color: _tone == t ? Colors.white : AppTheme.udoTextPrimary),
                onSelected: (_) => setState(() => _tone = t),
                side: BorderSide(
                    color: _tone == t ? AppTheme.udoGreen : AppTheme.udoBorder),
              ),
            ),
        ]),
      ]),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final String title, description;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ReminderRow(
      {required this.title,
      required this.description,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(description,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary, height: 1.4)),
        ])),
        Switch(
            value: value, onChanged: onChanged, activeColor: AppTheme.udoGreen),
      ]);
}

// ── MODALS ─────────────────────────────────────────────────────────────────────

class _AddRegistryActionsModal extends StatelessWidget {
  final BuildContext parentContext;
  final RegistryNotifier notifier;
  const _AddRegistryActionsModal({
    required this.parentContext,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return _ModalShell(
      title: 'Add to Registry',
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _RegistryActionButton(
          icon: Icons.card_giftcard_outlined,
          label: 'Add Gift',
          color: AppTheme.udoGreen,
          onTap: () => _open(
            context,
            _AddItemModal(
              notifier: notifier,
              title: 'Add gift',
              buttonLabel: 'Add gift',
              initialType: 'item',
            ),
          ),
        ),
        _RegistryActionButton(
          icon: Icons.volunteer_activism_outlined,
          label: 'Create Fund',
          color: AppTheme.udoGreen,
          onTap: () => _open(context, _CashFundCreateModal(notifier: notifier)),
        ),
        _RegistryActionButton(
          icon: Icons.ios_share_outlined,
          label: 'Import Registry',
          color: AppTheme.udoCrimson,
          onTap: () => _open(
            context,
            _AddLinkModal(
              notifier: notifier,
              title: 'Import registry',
              buttonLabel: 'Import link',
              itemType: 'external_registry',
            ),
          ),
        ),
        _RegistryActionButton(
          icon: Icons.storefront_outlined,
          label: 'Connect Retailer',
          color: Colors.indigo,
          onTap: () =>
              _open(context, _ConnectRetailerModal(notifier: notifier)),
        ),
        _RegistryActionButton(
          icon: Icons.category_outlined,
          label: 'Create Category',
          color: Colors.orange,
          onTap: () =>
              _open(context, _CreateRegistryCategoryModal(notifier: notifier)),
        ),
      ]),
    );
  }

  void _open(BuildContext context, Widget sheet) {
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!parentContext.mounted) return;
      showModalBottomSheet(
        context: parentContext,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => sheet,
      );
    });
  }
}

class _RegistryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _RegistryActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color, size: 20),
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(label,
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.w500)),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          alignment: Alignment.centerLeft,
          side: BorderSide(color: color.withValues(alpha: 0.3)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _CashFundCreateModal extends StatefulWidget {
  final RegistryNotifier notifier;
  const _CashFundCreateModal({required this.notifier});

  @override
  State<_CashFundCreateModal> createState() => _CashFundCreateModalState();
}

class _CashFundCreateModalState extends State<_CashFundCreateModal> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _target = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return _ModalShell(
      title: 'Create cash fund',
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _Field(ctrl: _name, label: 'Fund name', hint: 'e.g. Honeymoon fund'),
        const SizedBox(height: 12),
        _Field(
            ctrl: _desc,
            label: 'Description',
            hint: 'What\'s this fund for?',
            maxLines: 2),
        const SizedBox(height: 12),
        _Field(
            ctrl: _target,
            label: 'Target amount',
            hint: '5000',
            keyboardType: TextInputType.number,
            prefix: '\$'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: AppTheme.udoGreen,
              foregroundColor: Colors.white),
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Create fund'),
        ),
      ]),
    );
  }

  Future<void> _submit() async {
    if (_name.text.isEmpty) return;
    setState(() => _loading = true);
    await widget.notifier.addItem({
      'name': _name.text,
      'description': _desc.text,
      'price': double.tryParse(_target.text) ?? 5000,
      'type': 'cash_fund',
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _target.dispose();
    super.dispose();
  }
}

class _AddLinkModal extends StatefulWidget {
  final RegistryNotifier notifier;
  final String title;
  final String buttonLabel;
  final String itemType;
  const _AddLinkModal({
    required this.notifier,
    this.title = 'Add from a store',
    this.buttonLabel = 'Add item',
    this.itemType = 'item',
  });

  @override
  State<_AddLinkModal> createState() => _AddLinkModalState();
}

class _AddLinkModalState extends State<_AddLinkModal> {
  final _url = TextEditingController();
  final _note = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return _ModalShell(
      title: widget.title,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _Field(
            ctrl: _url,
            label: 'Product URL',
            hint: 'https://...',
            keyboardType: TextInputType.url),
        const SizedBox(height: 8),
        const Text('We\'ll pull in the name, price, and photo automatically.',
            style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        const SizedBox(height: 12),
        _Field(
            ctrl: _note,
            label: 'Personal note (optional)',
            hint: 'e.g. Any colour works'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: AppTheme.udoGreen,
              foregroundColor: Colors.white),
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(widget.buttonLabel),
        ),
      ]),
    );
  }

  Future<void> _submit() async {
    if (_url.text.isEmpty) return;
    setState(() => _loading = true);
    await widget.notifier.addItem({
      'url': _url.text,
      'note': _note.text,
      'name': _url.text,
      'type': widget.itemType
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _url.dispose();
    _note.dispose();
    super.dispose();
  }
}

class _AddItemModal extends StatefulWidget {
  final RegistryNotifier notifier;
  final String title;
  final String buttonLabel;
  final String initialType;
  const _AddItemModal({
    required this.notifier,
    this.title = 'Add item',
    this.buttonLabel = 'Add to registry',
    this.initialType = 'item',
  });

  @override
  State<_AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends State<_AddItemModal> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _note = TextEditingController();
  final _category = TextEditingController();
  final _store = TextEditingController();
  final _url = TextEditingController();
  late String _type = widget.initialType;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return _ModalShell(
      title: widget.title,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Type',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: _inputDecoration('Type'),
              items: const [
                DropdownMenuItem(value: 'item', child: Text('Physical item')),
                DropdownMenuItem(value: 'cash_fund', child: Text('Cash fund')),
                DropdownMenuItem(
                    value: 'experience', child: Text('Experience')),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'item'),
            ),
            const SizedBox(height: 12),
            _Field(
                ctrl: _name,
                label: 'Item name',
                hint: 'e.g. KitchenAid Stand Mixer'),
            const SizedBox(height: 12),
            _Field(
                ctrl: _price,
                label: 'Price',
                hint: '250',
                keyboardType: TextInputType.number,
                prefix: '\$'),
            const SizedBox(height: 12),
            _Field(
                ctrl: _category,
                label: 'Category',
                hint: 'Kitchen, travel, home'),
            const SizedBox(height: 12),
            _Field(
                ctrl: _store,
                label: 'Store (optional)',
                hint: 'Target, Amazon, local shop'),
            const SizedBox(height: 12),
            _Field(
                ctrl: _url,
                label: 'Product link (optional)',
                hint: 'https://...',
                keyboardType: TextInputType.url),
            const SizedBox(height: 12),
            _Field(
                ctrl: _note,
                label: 'Note (optional)',
                hint: 'Any colour or size preferences',
                maxLines: 2),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: AppTheme.udoGreen,
                  foregroundColor: Colors.white),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(widget.buttonLabel),
            ),
          ]),
    );
  }

  Future<void> _submit() async {
    if (_name.text.isEmpty) return;
    setState(() => _loading = true);
    await widget.notifier.addItem({
      'name': _name.text,
      'price': double.tryParse(_price.text),
      'note': _note.text,
      'type': _type,
      if (_category.text.trim().isNotEmpty) 'category': _category.text.trim(),
      if (_store.text.trim().isNotEmpty) 'store': _store.text.trim(),
      if (_url.text.trim().isNotEmpty) 'store_url': _url.text.trim(),
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _note.dispose();
    _category.dispose();
    _store.dispose();
    _url.dispose();
    super.dispose();
  }
}

class _ConnectRetailerModal extends StatefulWidget {
  final RegistryNotifier notifier;
  const _ConnectRetailerModal({required this.notifier});

  @override
  State<_ConnectRetailerModal> createState() => _ConnectRetailerModalState();
}

class _ConnectRetailerModalState extends State<_ConnectRetailerModal> {
  final _store = TextEditingController();
  final _url = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return _ModalShell(
      title: 'Connect retailer',
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _Field(
            ctrl: _store, label: 'Retailer name', hint: 'e.g. Amazon, Target'),
        const SizedBox(height: 12),
        _Field(
            ctrl: _url,
            label: 'Registry URL',
            hint: 'https://...',
            keyboardType: TextInputType.url),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: AppTheme.udoGreen,
              foregroundColor: Colors.white),
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Connect retailer'),
        ),
      ]),
    );
  }

  Future<void> _submit() async {
    if (_store.text.trim().isEmpty || _url.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await widget.notifier.addItem({
      'name': _store.text.trim(),
      'store': _store.text.trim(),
      'store_url': _url.text.trim(),
      'category': 'Retailer',
      'type': 'external_registry',
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _store.dispose();
    _url.dispose();
    super.dispose();
  }
}

class _CreateRegistryCategoryModal extends StatefulWidget {
  final RegistryNotifier notifier;
  const _CreateRegistryCategoryModal({required this.notifier});

  @override
  State<_CreateRegistryCategoryModal> createState() =>
      _CreateRegistryCategoryModalState();
}

class _CreateRegistryCategoryModalState
    extends State<_CreateRegistryCategoryModal> {
  final _category = TextEditingController();
  final _note = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return _ModalShell(
      title: 'Create category',
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _Field(
            ctrl: _category,
            label: 'Category name',
            hint: 'Kitchen, honeymoon, home'),
        const SizedBox(height: 12),
        _Field(
            ctrl: _note,
            label: 'Description (optional)',
            hint: 'What belongs here?',
            maxLines: 2),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: AppTheme.udoGreen,
              foregroundColor: Colors.white),
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Create category'),
        ),
      ]),
    );
  }

  Future<void> _submit() async {
    if (_category.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await widget.notifier.addItem({
      'name': '${_category.text.trim()} category',
      'category': _category.text.trim(),
      'description': _note.text.trim(),
      'type': 'category',
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _category.dispose();
    _note.dispose();
    super.dispose();
  }
}

class _ThankYouModal extends StatefulWidget {
  final Map<String, dynamic> item;
  const _ThankYouModal({required this.item});

  @override
  State<_ThankYouModal> createState() => _ThankYouModalState();
}

class _ThankYouModalState extends State<_ThankYouModal> {
  final _msg = TextEditingController();

  @override
  void initState() {
    super.initState();
    final by = widget.item['gifted_by'] as String? ?? '';
    _msg.text =
        'Dear ${by.isNotEmpty ? by : 'friend'},\n\nThank you so much for the generous gift. It means more than you know.\n\nWith love,\n[Couple Names]';
  }

  @override
  Widget build(BuildContext context) {
    return _ModalShell(
      title: 'Write thank-you note',
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For ${widget.item['name'] as String? ?? 'gift'} from ${widget.item['gifted_by'] as String? ?? 'guest'}',
              style: const TextStyle(
                  color: AppTheme.udoTextSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
                controller: _msg,
                maxLines: 6,
                decoration: _inputDecoration('Message')),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'))),
              const SizedBox(width: 12),
              Expanded(
                  child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.udoGreen,
                    foregroundColor: Colors.white),
                child: const Text('Mark as sent'),
              )),
            ]),
          ]),
    );
  }

  @override
  void dispose() {
    _msg.dispose();
    super.dispose();
  }
}

class _ShareModal extends ConsumerWidget {
  const _ShareModal();

  Future<void> _copyLink(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registry link copied.')),
    );
  }

  Future<void> _shareWhatsApp(BuildContext context, String message) async {
    Navigator.pop(context);
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await Share.share(message);
    }
  }

  Future<void> _shareSms(BuildContext context, String message) async {
    Navigator.pop(context);
    final uri = Uri(scheme: 'sms', queryParameters: {'body': message});
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await Share.share(message);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(homeProvider).guestPortalUrl;
    final hasUrl = url != null && url.isNotEmpty;
    final message =
        hasUrl ? 'Check out our wedding registry: $url' : 'Our wedding registry link isn\'t ready yet.';

    final actions = [
      (
        Icons.link_outlined,
        'Copy registry link',
        AppTheme.udoGreen,
        hasUrl ? () => _copyLink(context, url) : null,
      ),
      (
        Icons.chat_bubble_outline,
        'Share via WhatsApp',
        const Color(0xFF25D366),
        hasUrl ? () => _shareWhatsApp(context, message) : null,
      ),
      (
        Icons.sms_outlined,
        'Share via SMS',
        Colors.indigo,
        hasUrl ? () => _shareSms(context, message) : null,
      ),
    ];

    return _ModalShell(
      title: 'Share your registry',
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (!hasUrl) ...[
          const Text(
            'Your guest portal link isn\'t ready yet — open Home once your wedding details are set up, then try sharing again.',
            style: TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
        ],
        for (final item in actions) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton.icon(
              onPressed: item.$4,
              icon: Icon(item.$1, color: item.$3, size: 20),
              label:
                  Text(item.$2, style: TextStyle(color: item.$3, fontSize: 14)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: BorderSide(color: (item.$3).withValues(alpha: 0.3)),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

// ── SHARED ─────────────────────────────────────────────────────────────────────

class _ModalShell extends StatelessWidget {
  final String title;
  final Widget child;
  const _ModalShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              20, 24, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600))),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero),
                  ]),
                  const SizedBox(height: 16),
                  child,
                ]),
          ),
        ),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? prefix;
  const _Field(
      {required this.ctrl,
      required this.label,
      required this.hint,
      this.maxLines = 1,
      this.keyboardType,
      this.prefix});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hint, prefix: prefix),
        ),
      ]);
}

InputDecoration _inputDecoration(String hint, {String? prefix}) =>
    InputDecoration(
      hintText: hint,
      prefixText: prefix,
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
