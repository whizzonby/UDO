import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/udo_design_system.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _markedSeen = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    if (!_markedSeen && !state.isLoading && state.alerts.isNotEmpty) {
      _markedSeen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) notifier.markVisibleAsSeen();
      });
    }

    return Scaffold(
      backgroundColor: UdoDesign.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text('Notifications',
            style: UdoDesign.sans(size: 16, weight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () => notifier.toggleShowResolved(!state.showResolved),
            child: Text(state.showResolved ? 'Hide resolved' : 'Show resolved',
                style: UdoDesign.sans(
                    size: 12, weight: FontWeight.w600, color: UdoDesign.plan)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        color: UdoDesign.plan,
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: UdoDesign.plan))
            : state.error != null
                ? _ErrorState(message: state.error!, onRetry: notifier.refresh)
                : state.alerts.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.alerts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _AlertCard(
                          alert: state.alerts[index],
                          onResolve: () => notifier
                              .resolve(state.alerts[index]['id'] as int),
                        ),
                      ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 100),
        children: [
          const Icon(Icons.notifications_none,
              size: 48, color: UdoDesign.muted),
          const SizedBox(height: 16),
          Text("You're all caught up",
              textAlign: TextAlign.center, style: UdoDesign.serif(size: 22)),
          const SizedBox(height: 8),
          Text(
              'No active alerts right now — anything that needs your attention will show up here.',
              textAlign: TextAlign.center,
              style: UdoDesign.sans(size: 13, color: UdoDesign.sub)),
        ],
      );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 100),
        children: [
          const Icon(Icons.error_outline, size: 40, color: UdoDesign.muted),
          const SizedBox(height: 12),
          Text("Couldn't load notifications.",
              textAlign: TextAlign.center,
              style: UdoDesign.sans(size: 14, color: UdoDesign.sub)),
          const SizedBox(height: 16),
          Center(
              child: OutlinedButton(
                  onPressed: onRetry, child: const Text('Retry'))),
        ],
      );
}

class _AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;
  final VoidCallback onResolve;
  const _AlertCard({required this.alert, required this.onResolve});

  Color get _severityColor {
    switch (alert['severity'] as String?) {
      case 'critical':
        return UdoDesign.rose;
      case 'high':
        return UdoDesign.amber;
      case 'medium':
        return UdoDesign.blue;
      default:
        return UdoDesign.muted;
    }
  }

  IconData get _typeIcon {
    switch (alert['alert_type'] as String?) {
      case 'rsvp':
        return Icons.mark_email_unread_outlined;
      case 'guest':
        return Icons.groups_outlined;
      case 'budget':
        return Icons.account_balance_wallet_outlined;
      case 'live':
        return Icons.bolt_outlined;
      case 'timeline':
        return Icons.event_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolved = alert['status'] == 'resolved';
    final target = alert['target'] as String?;
    final actionLabel = alert['action_label'] as String?;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UdoDesign.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UdoDesign.border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: _severityColor.withValues(alpha: 0.12),
              shape: BoxShape.circle),
          child: Icon(_typeIcon, color: _severityColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(alert['title'] as String? ?? '',
                style: UdoDesign.sans(
                    size: 14,
                    weight: FontWeight.w700,
                    color: resolved ? UdoDesign.muted : UdoDesign.text)),
            const SizedBox(height: 4),
            Text(alert['body'] as String? ?? '',
                style: UdoDesign.sans(
                    size: 12, color: UdoDesign.sub, height: 1.4)),
            const SizedBox(height: 8),
            Row(children: [
              Text(_timeAgo(alert['trigger_at'] as String?),
                  style: UdoDesign.sans(size: 11, color: UdoDesign.muted)),
              const Spacer(),
              if (resolved)
                Text('Resolved',
                    style: UdoDesign.sans(
                        size: 11,
                        weight: FontWeight.w600,
                        color: UdoDesign.sage))
              else ...[
                if (target != null)
                  TextButton(
                    onPressed: () => context.push('/$target'),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text(actionLabel ?? 'View',
                        style: UdoDesign.sans(
                            size: 12,
                            weight: FontWeight.w700,
                            color: UdoDesign.plan)),
                  ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: onResolve,
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text('Dismiss',
                      style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
                ),
              ],
            ]),
          ]),
        ),
      ]),
    );
  }
}

String _timeAgo(String? iso) {
  if (iso == null) return '';
  final date = DateTime.tryParse(iso);
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${date.month}/${date.day}/${date.year}';
}
