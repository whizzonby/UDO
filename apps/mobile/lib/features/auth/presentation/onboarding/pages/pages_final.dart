import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/udo_text_field.dart';
import '../onboarding_answers.dart';
import '../widgets/onboarding_scaffold.dart';
import '../widgets/onboarding_section.dart';
import '../widgets/selectable_card.dart';

class HoneymoonPage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const HoneymoonPage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Honeymoon plans',
      preamble: 'If a honeymoon is part of your plans, we can keep it in mind as part of your wider journey.',
      currentStep: 23,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('You can keep this simple for now.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          const SizedBox(height: 14),
          Row(
            children: ['Yes', 'Not yet', 'No'].map((o) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: o == 'No' ? 0 : 8),
                child: SelectableCard(label: o, selected: answers.planningHoneymoon == o, onTap: () => setState(() => answers.planningHoneymoon = o), dense: true, centered: true),
              ),
            )).toList(),
          ),
          if (answers.planningHoneymoon == 'Yes') ...[
            const SizedBox(height: 20),
            UdoTextField(label: 'Destination', hint: 'Where are you going?', onChanged: (v) => answers.honeymoonDestination = v),
            const SizedBox(height: 16),
            Text('Budget: ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(answers.honeymoonBudget)}', style: const TextStyle(fontWeight: FontWeight.w500)),
            Slider(
              value: answers.honeymoonBudget.clamp(500, 50000),
              min: 500, max: 50000, divisions: 99,
              activeColor: AppTheme.udoGreen,
              onChanged: (v) => setState(() => answers.honeymoonBudget = v),
            ),
            OnboardingSection(
              title: 'Timing',
              child: Row(
                children: ['Immediate', 'Delayed'].map((t) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: t == 'Immediate' ? 8 : 0),
                    child: SelectableCard(label: t, selected: answers.honeymoonTiming == t, onTap: () => setState(() => answers.honeymoonTiming = t), dense: true, centered: true),
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class InsurancePage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onFinish, onBack;
  final void Function(void Function()) setState;
  final bool loading;
  const InsurancePage({super.key, required this.answers, required this.onFinish, required this.onBack, required this.setState, required this.loading});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Wedding insurance',
      preamble: 'A little protection can bring peace of mind.',
      currentStep: 24,
      totalSteps: 24,
      onNext: onFinish,
      onBack: onBack,
      nextLabel: loading ? 'Creating your wedding…' : 'Enter dashboard',
      nextEnabled: !loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.udoLightBlush, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoPastelCrimson)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppTheme.udoCrimson, size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Wedding insurance can help protect you against disruptions such as cancellations, supplier issues, or event-day problems.',
                    style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: ['Yes', 'No', 'Not sure'].map((o) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: o == 'Not sure' ? 0 : 8),
                child: SelectableCard(label: o, selected: answers.insurance == o, onTap: () => setState(() => answers.insurance = o), dense: true, centered: true),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          const Text('If you are unsure, that is completely fine — we can revisit this later.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        ],
      ),
    );
  }
}
