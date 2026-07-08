import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../plan/presentation/providers/plan_provider.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppTheme.udoBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.udoGreen,
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      state.greeting,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      state.coupleName.isEmpty ? 'Your Wedding' : state.coupleName,
                      style: const TextStyle(
                        color: Colors.white, fontFamily: 'Playfair',
                        fontSize: 26, fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (state.daysUntil != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          state.daysUntil! > 0
                              ? '${state.daysUntil} days to go'
                              : state.daysUntil == 0 ? 'Today is the day!' : 'Congratulations!',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: state.isLoading
                ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: AppTheme.udoGreen)))
                : _HomeBody(state: state),
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends StatefulWidget {
  final HomeState state;
  const _HomeBody({required this.state});
  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  String? _mood;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Mood check-in
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('How are you feeling today?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Row(children: [
                for (final (key, emoji, label) in [('calm', '😌', 'Calm'), ('excited', '🤩', 'Excited'), ('overwhelmed', '😅', 'Overwhelmed'), ('balanced', '✨', 'Balanced')])
                  Expanded(child: GestureDetector(
                    onTap: () => setState(() => _mood = key),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _mood == key ? AppTheme.udoGreen.withValues(alpha: 0.1) : const Color(0xFFF3EFEA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _mood == key ? AppTheme.udoGreen : Colors.transparent),
                      ),
                      child: Column(children: [
                        Text(emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 2),
                        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.udoTextSecondary)),
                      ]),
                    ),
                  )),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _StatCard(label: 'Guests', value: '${widget.state.totalGuests}', icon: Icons.people_outline, color: AppTheme.udoGreen),
              const SizedBox(width: 12),
              _StatCard(label: 'Confirmed', value: '${widget.state.confirmedGuests}', icon: Icons.check_circle_outline, color: const Color(0xFF22C55E)),
              const SizedBox(width: 12),
              _StatCard(label: 'Tasks left', value: '${widget.state.pendingTasks}', icon: Icons.task_alt, color: AppTheme.udoCrimson),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (widget.state.upcomingTasks.isNotEmpty) ...[
          _SectionHeader(title: 'Upcoming tasks', onSeeAll: () {}),
          ...widget.state.upcomingTasks.take(3).map((task) => _TaskTile(task: task)),
          const SizedBox(height: 8),
        ],
        _SectionHeader(title: 'Quick actions', onSeeAll: null),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1,
            children: [
              _QuickAction(icon: Icons.person_add_outlined, label: 'Add guest', onTap: () => _showModal(context, 'add_guest')),
              _QuickAction(icon: Icons.check_box_outlined, label: 'Add task', onTap: () => _showModal(context, 'add_task')),
              _QuickAction(icon: Icons.photo_outlined, label: 'Gallery', onTap: () {}),
              _QuickAction(icon: Icons.send_outlined, label: 'Message', onTap: () => _showModal(context, 'message')),
              _QuickAction(icon: Icons.card_giftcard_outlined, label: 'Registry', onTap: () {}),
              _QuickAction(icon: Icons.share_outlined, label: 'Share invite', onTap: () => _showModal(context, 'invite')),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (widget.state.budgetSpent != null) ...[
          _SectionHeader(title: 'Budget overview', onSeeAll: null),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _BudgetCard(spent: widget.state.budgetSpent!, total: widget.state.budgetTotal ?? 0),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  void _showModal(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _QuickActionModal(type: type),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.udoBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
        ],
      ),
    ));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text('See all', style: TextStyle(fontSize: 13, color: AppTheme.udoGreen)),
          ),
      ]),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Map<String, dynamic> task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.udoBorder),
        ),
        child: Row(children: [
          Icon(Icons.radio_button_unchecked, color: AppTheme.udoGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(task['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            if (task['due_date'] != null)
              Text('Due ${task['due_date']}', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          ])),
          const Icon(Icons.chevron_right, color: AppTheme.udoTextSecondary, size: 18),
        ]),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _QuickAction({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.udoBorder),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: AppTheme.udoGreen, size: 24),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

// ── QUICK ACTION MODALS ────────────────────────────────────────────────────────

class _QuickActionModal extends ConsumerStatefulWidget {
  final String type;
  const _QuickActionModal({required this.type});
  @override
  ConsumerState<_QuickActionModal> createState() => _QuickActionModalState();
}

class _QuickActionModalState extends ConsumerState<_QuickActionModal> {
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  final _c3 = TextEditingController();
  String _sendMethod = 'email';
  bool _plusOne = false;
  bool _saving = false;
  String? _error;

  Future<void> _submit() async {
    if (widget.type == 'add_task') {
      if (_c1.text.trim().isEmpty) {
        setState(() => _error = 'Give the task a title.');
        return;
      }
      setState(() {
        _saving = true;
        _error = null;
      });
      final priority = switch (_sendMethod) { 'High' => 'high', 'Low' => 'low', _ => 'medium' };
      final ok = await ref.read(planProvider.notifier).createTask(
            title: _c1.text.trim(),
            description: _c2.text.trim().isEmpty ? null : _c2.text.trim(),
            priority: priority,
          );
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context);
      } else {
        setState(() {
          _saving = false;
          _error = "Couldn't save this task. Try again.";
        });
      }
      return;
    }

    // Other quick actions (add_guest, message, invite) aren't wired to a
    // real backend flow yet — closing without a false "success" claim.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(_title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
            ]),
            const SizedBox(height: 16),
            ..._fields,
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppTheme.udoCrimson, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_action),
            ),
          ]),
        ),
      ),
    );
  }

  String get _title {
    switch (widget.type) {
      case 'add_guest': return 'Add guest';
      case 'add_task': return 'Add task';
      case 'message': return 'Message guests';
      case 'invite': return 'Share invite';
      default: return 'Action';
    }
  }

  String get _action {
    switch (widget.type) {
      case 'add_guest': return 'Add & send invite';
      case 'add_task': return 'Create task';
      case 'message': return 'Send message';
      case 'invite': return 'Share link';
      default: return 'Done';
    }
  }

  List<Widget> get _fields {
    switch (widget.type) {
      case 'add_guest': return [
        Row(children: [
          Expanded(child: _F('First name', _c1)),
          const SizedBox(width: 12),
          Expanded(child: _F('Last name', _c2)),
        ]),
        const SizedBox(height: 12),
        _F('Email', _c3, type: TextInputType.emailAddress),
        const SizedBox(height: 12),
        Row(children: [
          for (final (key, label) in [('email', 'Email'), ('sms', 'SMS'), ('whatsapp', 'WhatsApp')])
            Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
              label: Text(label, style: const TextStyle(fontSize: 12)),
              selected: _sendMethod == key,
              onSelected: (_) => setState(() => _sendMethod = key),
              selectedColor: AppTheme.udoGreen,
              labelStyle: TextStyle(color: _sendMethod == key ? Colors.white : AppTheme.udoTextPrimary),
              side: BorderSide(color: _sendMethod == key ? AppTheme.udoGreen : AppTheme.udoBorder),
            )),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Expanded(child: Text('Plus one', style: TextStyle(fontSize: 14))),
          Switch(value: _plusOne, onChanged: (v) => setState(() => _plusOne = v), activeColor: AppTheme.udoGreen),
        ]),
      ];
      case 'add_task': return [
        _F('Task title', _c1),
        const SizedBox(height: 12),
        _F('Notes (optional)', _c2, maxLines: 3),
        const SizedBox(height: 12),
        Row(children: [
          for (final label in ['High', 'Medium', 'Low'])
            Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
              label: Text(label, style: const TextStyle(fontSize: 12)),
              selected: _sendMethod == label,
              onSelected: (_) => setState(() => _sendMethod = label),
              selectedColor: label == 'High' ? AppTheme.udoCrimson : label == 'Medium' ? Colors.orange : AppTheme.udoGreen,
              labelStyle: TextStyle(color: _sendMethod == label ? Colors.white : AppTheme.udoTextPrimary),
              side: BorderSide(color: _sendMethod == label ? AppTheme.udoGreen : AppTheme.udoBorder),
            )),
        ]),
      ];
      case 'message': return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Text('To: ', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.udoGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: const Text('All guests', style: TextStyle(fontSize: 12, color: AppTheme.udoGreen, fontWeight: FontWeight.w500))),
          ]),
        ),
        const SizedBox(height: 10),
        _F('Your message', _c1, maxLines: 4),
      ];
      case 'invite': return [
        for (final (icon, label, color) in [
          (Icons.link_outlined, 'Copy invite link', AppTheme.udoGreen),
          (Icons.chat_bubble_outline, 'Share via WhatsApp', const Color(0xFF25D366)),
          (Icons.sms_outlined, 'Share via SMS', Colors.indigo),
          (Icons.qr_code_2_outlined, 'Show QR code', Colors.purple),
        ]) Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(icon, color: color, size: 18),
            label: Text(label, style: TextStyle(color: color, fontSize: 14)),
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), side: BorderSide(color: color.withValues(alpha: 0.3))),
          ),
        ),
      ];
      default: return [];
    }
  }

  @override
  void dispose() { _c1.dispose(); _c2.dispose(); _c3.dispose(); super.dispose(); }
}

class _F extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final TextInputType? type;
  final int maxLines;
  const _F(this.label, this.ctrl, {this.type, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl, keyboardType: type, maxLines: maxLines,
    decoration: InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14),
      filled: true, fillColor: const Color(0xFFF3EFEA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.udoGreen, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

class _BudgetCard extends StatelessWidget {
  final double spent, total;
  const _BudgetCard({required this.spent, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.udoBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Text('Total budget', style: TextStyle(fontWeight: FontWeight.w500))),
          Text('\$${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.udoGreen)),
        ]),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: pct,
          backgroundColor: AppTheme.udoBorder,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.udoGreen),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
        const SizedBox(height: 8),
        Row(children: [
          Text('\$${spent.toStringAsFixed(0)} spent', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          const Spacer(),
          Text('${(pct * 100).round()}%', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        ]),
      ]),
    );
  }
}
