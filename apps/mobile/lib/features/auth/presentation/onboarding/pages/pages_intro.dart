import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/udo_text_field.dart';
import '../onboarding_answers.dart';
import '../widgets/onboarding_scaffold.dart';
import '../widgets/onboarding_section.dart';
import '../widgets/selectable_card.dart';

const kRoleOptions = [
  'This is my wedding',
  'We are planning together',
  'I am supporting the planning',
  'I am the wedding planner',
  'I am part of a planning team',
];

const kDecisionStyles = [
  'One person is leading',
  'We make decisions together',
  'Family input matters',
  'A planner helps guide decisions',
  'Final decisions are still evolving',
];

const kPlanningApproaches = ['Planner-led', 'Hybrid planning', 'Self-managed', 'Family-supported', 'Still deciding'];

class WelcomeRolePage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onSkip;
  final void Function(void Function()) setState;
  const WelcomeRolePage({super.key, required this.answers, required this.onNext, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Welcome to Udo',
      preamble: "Let's personalise your planning experience. Tell us a little about who's planning and your role.",
      currentStep: 1,
      totalSteps: 24,
      onNext: onNext,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          UdoTextField(
            label: "Couple's names",
            hint: 'e.g. Amara & James',
            onChanged: (v) => answers.coupleName = v,
          ),
          OnboardingSection(
            title: 'Your role',
            child: Column(
              children: kRoleOptions
                  .map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SelectableCard(label: r, selected: answers.role == r, onTap: () => setState(() => answers.role = r)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class DecisionMakingPage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const DecisionMakingPage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  void _addCollaborator(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Invite a collaborator', style: TextStyle(fontFamily: 'Playfair', fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.udoGreen)),
            const SizedBox(height: 16),
            UdoTextField(label: 'Name', controller: nameCtrl),
            const SizedBox(height: 12),
            UdoTextField(label: 'Email', controller: emailCtrl, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;
                  setState(() => answers.collaborators.add(Collaborator(name: nameCtrl.text.trim(), email: emailCtrl.text.trim())));
                  Navigator.of(ctx).pop();
                },
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Who is involved in decision-making?',
      preamble: 'Planning is easier when the right people are included from the start. Invite anyone helping shape important decisions.',
      currentStep: 2,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingSection(
            title: 'Decision style',
            child: Column(
              children: kDecisionStyles
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SelectableCard(label: s, selected: answers.decisionStyle == s, onTap: () => setState(() => answers.decisionStyle = s), dense: true),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppTheme.udoLightBlush, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.udoPastelCrimson)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Invite key people', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.udoGreen)),
                const SizedBox(height: 6),
                const Text('You can invite people now, or copy a link to share later.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                const SizedBox(height: 14),
                for (final c in answers.collaborators)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text('${c.name} · ${c.email}', style: const TextStyle(fontSize: 13))),
                        GestureDetector(
                          onTap: () => setState(() => answers.collaborators.remove(c)),
                          child: const Icon(Icons.close, size: 16, color: AppTheme.udoTextSecondary),
                        ),
                      ],
                    ),
                  ),
                OutlinedButton(onPressed: () => _addCollaborator(context), child: const Text('Add collaborator')),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite link copied.')));
                  },
                  child: const Text('Copy invite link'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlanningStructurePage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const PlanningStructurePage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    final needsPlanner = answers.planningApproach == 'Planner-led' || answers.planningApproach == 'Hybrid planning';
    return OnboardingScaffold(
      title: 'How are you approaching the planning?',
      preamble: 'This helps us understand how hands-on Udo should be and where to support you most.',
      currentStep: 3,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Column(
            children: kPlanningApproaches
                .map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SelectableCard(label: a, selected: answers.planningApproach == a, onTap: () => setState(() => answers.planningApproach = a)),
                    ))
                .toList(),
          ),
          if (needsPlanner) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.udoLightBlush, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('If you already have a planner, we can bring them into your workspace.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                  const SizedBox(height: 10),
                  UdoTextField(label: '', hint: 'Add planner email', onChanged: (v) => answers.plannerEmail = v),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
