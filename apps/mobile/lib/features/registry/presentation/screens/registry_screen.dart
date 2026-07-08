import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/registry_provider.dart';

class RegistryScreen extends ConsumerStatefulWidget {
  const RegistryScreen({super.key});
  @override
  ConsumerState<RegistryScreen> createState() => _RegistryScreenState();
}

class _RegistryScreenState extends ConsumerState<RegistryScreen> with SingleTickerProviderStateMixin {
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
                  const Text('Registry', style: TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'Playfair', fontWeight: FontWeight.w400)),
                  if (hasItems)
                    Text('${state.items.length} items', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            actions: hasItems
                ? [
                    IconButton(
                      icon: const Icon(Icons.share_outlined, color: Colors.white),
                      onPressed: () => _showShareModal(context),
                    ),
                    const SizedBox(width: 4),
                  ]
                : null,
          ),
          if (state.isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppTheme.udoGreen)))
          else if (!hasItems)
            SliverFillRemaining(child: _SetupFlow(notifier: notifier))
          else
            SliverList(
              delegate: SliverChildListDelegate([
                _CashFundCard(state: state),
                _ItemsGrid(state: state),
                _ThankYouTracker(state: state, tabs: _thankYouTabs),
                _SmartReminders(),
                const SizedBox(height: 100),
              ]),
            ),
        ],
      ),
      floatingActionButton: hasItems
          ? FloatingActionButton.extended(
              onPressed: () => _showAddItemModal(context, notifier),
              backgroundColor: AppTheme.udoGreen,
              foregroundColor: Colors.white,
              label: const Text('Add item'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showShareModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _ShareModal(),
    );
  }

  void _showAddItemModal(BuildContext context, RegistryNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddItemModal(notifier: notifier),
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
          style: TextStyle(fontFamily: 'Playfair', fontSize: 24, fontWeight: FontWeight.w400, height: 1.4),
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
          description: 'A cash fund guests can contribute to — honeymoon, home, adventures together.',
          action: 'Create cash fund',
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (_) => _CashFundCreateModal(notifier: notifier),
          ),
        ),
        const SizedBox(height: 12),
        _SetupCard(
          icon: Icons.link_outlined,
          iconColor: AppTheme.udoCrimson,
          title: 'Add something you love',
          description: 'Paste a link from any store. We\'ll pull in the details automatically.',
          action: 'Add a link',
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (_) => _AddLinkModal(notifier: notifier),
          ),
        ),
        const SizedBox(height: 12),
        _SetupCard(
          icon: Icons.list_alt_outlined,
          iconColor: Colors.indigo,
          title: 'Create a wishlist',
          description: 'Build a custom list with prices, quantities, and personal notes.',
          action: 'Start a wishlist',
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
  const _SetupCard({required this.icon, required this.iconColor, required this.title, required this.description, required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.udoBorder)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
      ]),
      const SizedBox(height: 10),
      Text(description, style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5)),
      const SizedBox(height: 14),
      OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: iconColor),
          foregroundColor: iconColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
    final cashFunds = state.items.where((i) => i['type'] == 'cash_fund').toList();
    if (cashFunds.isEmpty) return const SizedBox.shrink();

    final fund = cashFunds.first;
    final target = (fund['fund_goal'] as num? ?? fund['price'] as num? ?? 5000).toDouble();
    final raised = (fund['contributed'] as num? ?? 0).toDouble();
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
          const Icon(Icons.volunteer_activism_outlined, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(fund['name'] as String? ?? 'Cash Fund', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16))),
        ]),
        if (fund['description'] != null) ...[
          const SizedBox(height: 4),
          Text(fund['description'] as String, style: const TextStyle(color: Colors.white60, fontSize: 12)),
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
          Text('\$${raised.toStringAsFixed(0)} raised', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text('of \$${target.toStringAsFixed(0)} goal', style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
        const SizedBox(height: 4),
        Text('${(progress * 100).toStringAsFixed(0)}% funded', style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
    final physical = state.items.where((i) => i['type'] != 'cash_fund').toList();
    if (physical.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Gift list', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          Text('${physical.length} items', style: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13)),
        ]),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
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
      case 'Gifted': return const Color(0xFF22C55E);
      case 'Reserved': return AppTheme.udoCrimson;
      default: return AppTheme.udoGreen;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.card_giftcard_outlined, color: AppTheme.udoGreen, size: 32),
        const SizedBox(height: 8),
        Text(item['name'] as String? ?? 'Item', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
        if (item['price'] != null) ...[const SizedBox(height: 4), Text('\$${item['price']}', style: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13))],
      ])),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(_status, style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w500)),
      ),
    ]),
  );
}

// ── THANK YOU TRACKER ──────────────────────────────────────────────────────────

class _ThankYouTracker extends StatelessWidget {
  final RegistryState state;
  final TabController tabs;
  const _ThankYouTracker({required this.state, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final gifted = state.items.where((i) => i['purchased'] == true).toList();
    final thanked = gifted.where((i) => i['thank_you_sent'] == true).toList();
    final pending = gifted.where((i) => i['thank_you_sent'] != true).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.udoBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.favorite_outline, color: AppTheme.udoCrimson, size: 18),
          const SizedBox(width: 8),
          const Text('Thank-you tracker', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.udoCrimson.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: Text('${thanked.length}/${gifted.length} sent', style: const TextStyle(fontSize: 11, color: AppTheme.udoCrimson, fontWeight: FontWeight.w500)),
          ),
        ]),
        const SizedBox(height: 12),
        if (gifted.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Your thank-you notes will appear here once gifts start arriving.',
              style: TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13, height: 1.5),
            ),
          )
        else ...[
          TabBar(
            controller: tabs,
            indicatorColor: AppTheme.udoGreen,
            labelColor: AppTheme.udoGreen,
            unselectedLabelColor: AppTheme.udoTextSecondary,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            tabs: [Tab(text: 'Pending (${pending.length})'), Tab(text: 'Completed (${thanked.length})')],
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: TabBarView(controller: tabs, children: [
              _ThankYouList(items: pending, completed: false),
              _ThankYouList(items: thanked, completed: true),
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
  const _ThankYouList({required this.items, required this.completed});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text(
        completed ? 'No completed notes yet.' : 'All thank-yous sent!',
        style: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13),
      ));
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final item = items[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          title: Text(item['name'] as String? ?? 'Gift', style: const TextStyle(fontSize: 14)),
          subtitle: Text(item['gifted_by'] as String? ?? 'Anonymous', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          trailing: completed
              ? const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20)
              : TextButton(
                  onPressed: () => showModalBottomSheet(
                    context: ctx,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                    builder: (_) => _ThankYouModal(item: item),
                  ),
                  child: const Text('Write note', style: TextStyle(fontSize: 12)),
                ),
        );
      },
    );
  }
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.udoBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.notifications_outlined, color: AppTheme.udoGreen, size: 18),
          const SizedBox(width: 8),
          const Text('Smart reminders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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
        const Text('Message tone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(children: [
          for (final t in ['gentle', 'warm', 'playful']) Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(t[0].toUpperCase() + t.substring(1), style: const TextStyle(fontSize: 13)),
              selected: _tone == t,
              selectedColor: AppTheme.udoGreen,
              labelStyle: TextStyle(color: _tone == t ? Colors.white : AppTheme.udoTextPrimary),
              onSelected: (_) => setState(() => _tone = t),
              side: BorderSide(color: _tone == t ? AppTheme.udoGreen : AppTheme.udoBorder),
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
  const _ReminderRow({required this.title, required this.description, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 2),
      Text(description, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary, height: 1.4)),
    ])),
    Switch(value: value, onChanged: onChanged, activeColor: AppTheme.udoGreen),
  ]);
}

// ── MODALS ─────────────────────────────────────────────────────────────────────

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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _ModalShell(
        title: 'Create cash fund',
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _Field(ctrl: _name, label: 'Fund name', hint: 'e.g. Honeymoon fund'),
          const SizedBox(height: 12),
          _Field(ctrl: _desc, label: 'Description', hint: 'What\'s this fund for?', maxLines: 2),
          const SizedBox(height: 12),
          _Field(ctrl: _target, label: 'Target amount', hint: '5000', keyboardType: TextInputType.number, prefix: '\$'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
            child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Create fund'),
          ),
        ]),
      ),
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
    _name.dispose(); _desc.dispose(); _target.dispose();
    super.dispose();
  }
}

class _AddLinkModal extends StatefulWidget {
  final RegistryNotifier notifier;
  const _AddLinkModal({required this.notifier});

  @override
  State<_AddLinkModal> createState() => _AddLinkModalState();
}

class _AddLinkModalState extends State<_AddLinkModal> {
  final _url = TextEditingController();
  final _note = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _ModalShell(
        title: 'Add from a store',
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _Field(ctrl: _url, label: 'Product URL', hint: 'https://...', keyboardType: TextInputType.url),
          const SizedBox(height: 8),
          const Text('We\'ll pull in the name, price, and photo automatically.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          const SizedBox(height: 12),
          _Field(ctrl: _note, label: 'Personal note (optional)', hint: 'e.g. Any colour works'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
            child: const Text('Add item'),
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    if (_url.text.isEmpty) return;
    setState(() => _loading = true);
    await widget.notifier.addItem({'url': _url.text, 'note': _note.text, 'name': _url.text, 'type': 'item'});
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() { _url.dispose(); _note.dispose(); super.dispose(); }
}

class _AddItemModal extends StatefulWidget {
  final RegistryNotifier notifier;
  const _AddItemModal({required this.notifier});

  @override
  State<_AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends State<_AddItemModal> {
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _note = TextEditingController();
  String _type = 'item';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _ModalShell(
        title: 'Add item',
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: _inputDecoration('Type'),
            items: const [
              DropdownMenuItem(value: 'item', child: Text('Physical item')),
              DropdownMenuItem(value: 'cash_fund', child: Text('Cash fund')),
              DropdownMenuItem(value: 'experience', child: Text('Experience')),
            ],
            onChanged: (v) => setState(() => _type = v ?? 'item'),
          ),
          const SizedBox(height: 12),
          _Field(ctrl: _name, label: 'Item name', hint: 'e.g. KitchenAid Stand Mixer'),
          const SizedBox(height: 12),
          _Field(ctrl: _price, label: 'Price', hint: '250', keyboardType: TextInputType.number, prefix: '\$'),
          const SizedBox(height: 12),
          _Field(ctrl: _note, label: 'Note (optional)', hint: 'Any colour or size preferences', maxLines: 2),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
            child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Add to registry'),
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    if (_name.text.isEmpty) return;
    setState(() => _loading = true);
    await widget.notifier.addItem({'name': _name.text, 'price': double.tryParse(_price.text), 'note': _note.text, 'type': _type});
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() { _name.dispose(); _price.dispose(); _note.dispose(); super.dispose(); }
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
    _msg.text = 'Dear ${by.isNotEmpty ? by : 'friend'},\n\nThank you so much for the generous gift. It means more than you know.\n\nWith love,\n[Couple Names]';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _ModalShell(
        title: 'Write thank-you note',
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'For ${widget.item['name'] as String? ?? 'gift'} from ${widget.item['gifted_by'] as String? ?? 'guest'}',
            style: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(controller: _msg, maxLines: 6, decoration: _inputDecoration('Message')),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
              child: const Text('Mark as sent'),
            )),
          ]),
        ]),
      ),
    );
  }

  @override
  void dispose() { _msg.dispose(); super.dispose(); }
}

class _ShareModal extends StatelessWidget {
  const _ShareModal();

  @override
  Widget build(BuildContext context) {
    return _ModalShell(
      title: 'Share your registry',
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        for (final item in [
          (Icons.link_outlined, 'Copy registry link', AppTheme.udoGreen),
          (Icons.chat_bubble_outline, 'Share via WhatsApp', const Color(0xFF25D366)),
          (Icons.sms_outlined, 'Share via SMS', Colors.indigo),
        ]) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(item.$1, color: item.$3, size: 20),
              label: Text(item.$2, style: TextStyle(color: item.$3, fontSize: 14)),
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? prefix;
  const _Field({required this.ctrl, required this.label, required this.hint, this.maxLines = 1, this.keyboardType, this.prefix});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    const SizedBox(height: 6),
    TextField(
      controller: ctrl, maxLines: maxLines, keyboardType: keyboardType,
      decoration: _inputDecoration(hint, prefix: prefix),
    ),
  ]);
}

InputDecoration _inputDecoration(String hint, {String? prefix}) => InputDecoration(
  hintText: hint,
  prefixText: prefix,
  hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14),
  filled: true, fillColor: const Color(0xFFF3EFEA),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.udoGreen, width: 1.5)),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
);
