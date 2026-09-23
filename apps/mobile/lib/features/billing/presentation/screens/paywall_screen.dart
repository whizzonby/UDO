import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/udo_design_system.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/billing_provider.dart';

const _billingAccent = Color(0xFFC9A46A);
const _billingInk = Color(0xFF2E4A42);

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billing = ref.watch(billingProvider);
    final limitMessage = GoRouterState.of(context).extra as String?;

    return Scaffold(
      backgroundColor: UdoDesign.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            if (limitMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _billingAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(limitMessage,
                    style: UdoDesign.sans(
                        size: 13, weight: FontWeight.w600, color: _billingInk)),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                const _PassMark(),
                const Spacer(),
                TextButton(
                  onPressed: () => ref.read(authProvider.notifier).logout(),
                  child: Text('Sign out',
                      style: UdoDesign.sans(
                          size: 13,
                          weight: FontWeight.w600,
                          color: UdoDesign.muted)),
                ),
                IconButton(
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/home'),
                  icon: const Icon(Icons.close, color: UdoDesign.muted),
                  tooltip: 'Not now',
                ),
              ],
            ),
            const SizedBox(height: 34),
            Text('Choose your plan', style: UdoDesign.serif(size: 44)),
            const SizedBox(height: 10),
            Text(
              'Unlock the full operating system before the planning gets serious.',
              style:
                  UdoDesign.sans(size: 16, color: UdoDesign.sub, height: 1.45),
            ),
            const SizedBox(height: 24),
            _PlanOption(
              selected: billing.selected == BillingPlan.premium,
              title: 'Udo Premium',
              price: billing.premiumProduct?.price ?? r'$4.99',
              cadence: '/ month',
              detail: 'Full wedding-planning access. Cancel anytime.',
              onTap: () => ref
                  .read(billingProvider.notifier)
                  .select(BillingPlan.premium),
            ),
            const SizedBox(height: 12),
            _PlanOption(
              selected: billing.selected == BillingPlan.pass,
              title: 'Wedding Pass',
              price: billing.passProduct?.price ?? r'$49.99',
              cadence: 'one time',
              detail: 'One payment. Plan all the way to "I do."',
              badge: 'Best value',
              onTap: () =>
                  ref.read(billingProvider.notifier).select(BillingPlan.pass),
            ),
            const SizedBox(height: 18),
            UdoCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Everything included',
                      style: UdoDesign.sans(
                          size: 14,
                          weight: FontWeight.w700,
                          color: _billingInk)),
                  const SizedBox(height: 16),
                  const _PassDivider(),
                  const SizedBox(height: 18),
                  for (final feature in const [
                    _FeatureLine(
                        icon: Icons.groups_2_outlined,
                        title: 'Unlimited wedding workspace',
                        detail:
                            'Guests, collaborators, planning modules and day-of tools.'),
                    _FeatureLine(
                        icon: Icons.auto_awesome_outlined,
                        title: 'AI planning companion',
                        detail:
                            'Recommendations, timeline checks and decision support.'),
                    _FeatureLine(
                        icon: Icons.public_outlined,
                        title: 'Guest portal',
                        detail:
                            'RSVP, logistics, registry, photos and guest portal flows.'),
                    _FeatureLine(
                        icon: Icons.health_and_safety_outlined,
                        title: 'Live operations',
                        detail:
                            'Emergency contacts, broadcasts, weather and run-of-show control.'),
                  ])
                    feature,
                ],
              ),
            ),
            const SizedBox(height: 18),
            _StoreStatePanel(billing: billing),
            const SizedBox(height: 18),
            _PurchaseActions(billing: billing, ref: ref),
            const SizedBox(height: 18),
            _SubscriptionTerms(
                premiumPrice: billing.premiumProduct?.price ?? r'$4.99'),
          ],
        ),
      ),
    );
  }
}

class _PlanOption extends StatelessWidget {
  final bool selected;
  final String title;
  final String price;
  final String cadence;
  final String detail;
  final String? badge;
  final VoidCallback onTap;

  const _PlanOption({
    required this.selected,
    required this.title,
    required this.price,
    required this.cadence,
    required this.detail,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _billingInk : UdoDesign.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? _billingInk : UdoDesign.muted,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(title,
                      style: UdoDesign.sans(
                          size: 15,
                          weight: FontWeight.w700,
                          color: _billingInk)),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  UdoBadge(label: badge!, color: _billingAccent),
                ],
              ]),
              const SizedBox(height: 4),
              Text(detail,
                  style: UdoDesign.sans(
                      size: 12, color: UdoDesign.muted, height: 1.35)),
            ]),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(price,
                style: UdoDesign.serif(
                    size: 24, color: UdoDesign.text, height: 1)),
            const SizedBox(height: 4),
            Text(cadence,
                style: UdoDesign.sans(size: 11, color: UdoDesign.muted)),
          ]),
        ]),
      ),
    );
  }
}

class _PassMark extends StatelessWidget {
  const _PassMark();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: UdoDesign.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.workspace_premium_outlined,
            color: _billingAccent, size: 27),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Udo', style: UdoDesign.serif(size: 24)),
        Text('Premium & Wedding Pass',
            style: UdoDesign.sans(size: 11, color: UdoDesign.muted)),
      ]),
    ]);
  }
}

class _PassDivider extends StatelessWidget {
  const _PassDivider();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Container(height: 1, color: UdoDesign.border)),
      Container(
        width: 9,
        height: 9,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration:
            const BoxDecoration(color: _billingAccent, shape: BoxShape.circle),
      ),
      Expanded(child: Container(height: 1, color: UdoDesign.border)),
    ]);
  }
}

class _FeatureLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const _FeatureLine({
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _billingAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 18, color: _billingInk),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: UdoDesign.sans(size: 14, weight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(detail,
                style: UdoDesign.sans(
                    size: 12, color: UdoDesign.muted, height: 1.35)),
          ]),
        ),
      ]),
    );
  }
}

class _StoreStatePanel extends StatelessWidget {
  final BillingState billing;
  const _StoreStatePanel({required this.billing});

  @override
  Widget build(BuildContext context) {
    final ready = billing.storeAvailable && billing.product != null;
    // Store works on the device but the product / server side isn't live yet.
    final comingSoon = !ready &&
        !billing.isLoading &&
        (billing.serverConfigured == false ||
            (billing.storeAvailable && billing.product == null));

    final title = billing.isLoading
        ? 'Checking availability'
        : ready
            ? 'Ready to purchase'
            : comingSoon
                ? 'Payments coming soon'
                : 'Store unavailable';
    final detail = billing.isLoading
        ? 'Udo is checking the app store before purchase.'
        : ready
            ? 'Purchases are available on this device.'
            : billing.error ??
                'The store is not available on this device right now.';
    final icon = billing.isLoading
        ? Icons.sync_outlined
        : ready
            ? Icons.verified_outlined
            : comingSoon
                ? Icons.schedule_outlined
                : Icons.info_outline;
    final accent = ready || comingSoon ? _billingInk : AppTheme.udoCrimson;

    return UdoCard(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: accent, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: UdoDesign.sans(size: 14, weight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(detail,
                style: UdoDesign.sans(
                    size: 12,
                    color: ready ? UdoDesign.muted : accent,
                    height: 1.35)),
          ]),
        ),
        if (billing.isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: _billingInk),
          ),
      ]),
    );
  }
}

class _PurchaseActions extends StatelessWidget {
  final BillingState billing;
  final WidgetRef ref;
  const _PurchaseActions({required this.billing, required this.ref});

  @override
  Widget build(BuildContext context) {
    final canBuy = billing.canPurchase;

    return Column(children: [
      ElevatedButton(
        onPressed: canBuy
            ? () => ref.read(billingProvider.notifier).buySelected()
            : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          backgroundColor: _billingInk,
          foregroundColor: Colors.white,
          disabledBackgroundColor: UdoDesign.stone,
          disabledForegroundColor: UdoDesign.muted,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: billing.isPurchasing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(
                billing.selected == BillingPlan.premium
                    ? 'Start Udo Premium'
                    : 'Get the Wedding Pass',
                style: UdoDesign.sans(
                    size: 15, weight: FontWeight.w700, color: Colors.white)),
      ),
      const SizedBox(height: 10),
      OutlinedButton(
        onPressed: billing.isPurchasing
            ? null
            : () => ref.read(billingProvider.notifier).restorePurchases(),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(color: UdoDesign.border),
          foregroundColor: _billingInk,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text('Restore purchases',
            style: UdoDesign.sans(
                size: 14, weight: FontWeight.w700, color: _billingInk)),
      ),
      if (billing.error != null && billing.storeAvailable) ...[
        const SizedBox(height: 12),
        Text(billing.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.udoCrimsonText, fontSize: 13)),
      ],
    ]);
  }
}

/// Auto-renewal disclosure plus Terms / Privacy links — required by App
/// Store guideline 3.1.2 (and Play policy) wherever a subscription is sold.
class _SubscriptionTerms extends StatelessWidget {
  final String premiumPrice;
  const _SubscriptionTerms({required this.premiumPrice});

  @override
  Widget build(BuildContext context) {
    final store = defaultTargetPlatform == TargetPlatform.iOS
        ? 'App Store account settings'
        : 'Google Play subscriptions';
    final small = UdoDesign.sans(size: 12, color: UdoDesign.sub, height: 1.45);
    final link = UdoDesign.sans(
        size: 12, weight: FontWeight.w700, color: UdoDesign.plan);

    return Column(children: [
      Text(
        'Udo Premium renews automatically at $premiumPrice per month until '
        'cancelled. Cancel anytime in your $store at least 24 hours before '
        'the end of the current period. The Wedding Pass is a single '
        'payment and never renews.',
        textAlign: TextAlign.center,
        style: small,
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextButton(
          onPressed: () => launchUrl(Uri.parse(AppConstants.termsUrl),
              mode: LaunchMode.externalApplication),
          child: Text('Terms of Use', style: link),
        ),
        Text('·', style: small),
        TextButton(
          onPressed: () => launchUrl(Uri.parse(AppConstants.privacyUrl),
              mode: LaunchMode.externalApplication),
          child: Text('Privacy Policy', style: link),
        ),
      ]),
    ]);
  }
}
