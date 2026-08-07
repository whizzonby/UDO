import 'package:flutter/material.dart';
import '../../../../../shared/widgets/udo_button.dart';
import '../../../../../shared/widgets/udo_design_system.dart';

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
      backgroundColor: UdoDesign.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: currentStep / totalSteps,
                  minHeight: 4,
                  backgroundColor: UdoDesign.border,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(UdoDesign.plan),
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
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: UdoDesign.text,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: UdoDesign.border),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  if (onSkip != null)
                    TextButton(
                      onPressed: onSkip,
                      child: Text('Skip',
                          style: UdoDesign.sans(
                              size: 14,
                              weight: FontWeight.w600,
                              color: UdoDesign.muted)),
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
                        style: UdoDesign.serif(size: 34, height: 1.08),
                      ),
                    if (preamble != null && preamble!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(preamble!,
                          style: UdoDesign.sans(
                              size: 14, color: UdoDesign.sub, height: 1.5)),
                    ],
                    if (quote != null && quote!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      UdoCard(
                        padding: const EdgeInsets.all(16),
                        radius: 20,
                        color: Colors.white,
                        child: Text(
                          quote!,
                          style: UdoDesign.serif(
                            size: 18,
                            color: UdoDesign.plan,
                            height: 1.2,
                          ).copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    child,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: UdoButton(
                  label: nextLabel, onPressed: nextEnabled ? onNext : null),
            ),
          ],
        ),
      ),
    );
  }
}
