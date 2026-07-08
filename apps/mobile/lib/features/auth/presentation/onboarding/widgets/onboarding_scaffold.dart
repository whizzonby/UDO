import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/udo_button.dart';

/// Mirrors the design system's `ScreenLayout` component: a title + preamble
/// header, an optional quote nugget, a scrollable body, a progress bar, and
/// a back/next/skip footer.
class OnboardingScaffold extends StatelessWidget {
  final String title;
  final String? preamble;
  final String? quote;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final VoidCallback? onSkip;
  final String nextLabel;
  final bool nextEnabled;
  final Widget child;

  const OnboardingScaffold({
    super.key,
    required this.title,
    this.preamble,
    this.quote,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    required this.onNext,
    this.onSkip,
    this.nextLabel = 'Continue',
    this.nextEnabled = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.udoBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: currentStep / totalSteps,
                  minHeight: 4,
                  backgroundColor: AppTheme.udoBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.udoGreen),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back, color: AppTheme.udoTextPrimary),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  if (onSkip != null)
                    TextButton(
                      onPressed: onSkip,
                      child: const Text('Skip', style: TextStyle(color: AppTheme.udoTextSecondary, fontSize: 14)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Playfair', fontSize: 25, fontWeight: FontWeight.w600,
                          color: AppTheme.udoGreen, height: 1.2,
                        ),
                      ),
                    if (preamble != null && preamble!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(preamble!, style: const TextStyle(fontSize: 14, color: AppTheme.udoTextSecondary, height: 1.5)),
                    ],
                    if (quote != null && quote!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.udoLightBlush,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          quote!,
                          style: const TextStyle(fontFamily: 'Playfair', fontStyle: FontStyle.italic, fontSize: 14, color: AppTheme.udoGreen),
                        ),
                      ),
                    ],
                    child,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: UdoButton(label: nextLabel, onPressed: nextEnabled ? onNext : null),
            ),
          ],
        ),
      ),
    );
  }
}
