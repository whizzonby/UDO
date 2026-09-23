import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'udo_design_system.dart';

/// "See plans" prompt shown to free-plan users on Home and More. Prices are
/// deliberately left to the paywall, which shows the store's localized ones.
class UpgradeCard extends StatelessWidget {
  const UpgradeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      onTap: () => context.push('/paywall'),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: UdoDesign.gold.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.workspace_premium_outlined,
              color: UdoDesign.goldText, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("You're on the Free plan",
                style: UdoDesign.sans(size: 15, weight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(
              'Unlock unlimited guests, vendors and every planning tool. '
              'Monthly or one-time, your choice.',
              style: UdoDesign.sans(
                  size: 13, weight: FontWeight.w500, color: UdoDesign.sub),
            ),
          ]),
        ),
        const SizedBox(width: 10),
        FilledButton(
          onPressed: () => context.push('/paywall'),
          style: FilledButton.styleFrom(
            backgroundColor: UdoDesign.plan,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            minimumSize: const Size(0, 40),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('See plans',
              style: UdoDesign.sans(
                  size: 13, weight: FontWeight.w700, color: Colors.white)),
        ),
      ]),
    );
  }
}
