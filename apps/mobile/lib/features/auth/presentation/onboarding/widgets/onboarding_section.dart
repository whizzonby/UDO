import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class OnboardingSection extends StatelessWidget {
  final String title;
  final String? helper;
  final Widget child;

  const OnboardingSection({super.key, required this.title, this.helper, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.udoTextPrimary)),
          if (helper != null && helper!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(helper!, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
