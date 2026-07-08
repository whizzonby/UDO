import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/udo_text_field.dart';
import '../onboarding_answers.dart';
import '../widgets/onboarding_scaffold.dart';
import '../widgets/onboarding_section.dart';
import '../widgets/selectable_card.dart';
import '../widgets/multi_select_chips.dart';

class CulturalTransitionPage extends StatelessWidget {
  final VoidCallback onNext, onBack;
  const CulturalTransitionPage({super.key, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: '',
      currentStep: 14,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      nextLabel: 'Continue',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: AppTheme.udoLightBlush, shape: BoxShape.circle),
              child: const Icon(Icons.diversity_3, color: AppTheme.udoCrimson, size: 30),
            ),
            const SizedBox(height: 24),
            const Text(
              'Many celebrations carry traditions, rituals, and meaningful family moments.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppTheme.udoTextSecondary, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              "We'd love to understand yours more deeply.",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Playfair', fontStyle: FontStyle.italic, fontSize: 18, color: AppTheme.udoGreen),
            ),
          ],
        ),
      ),
    );
  }
}

const kCulturalCelebrationTypes = [
  'Single-day celebration', 'Multi-day celebration', 'Destination wedding', 'Religious ceremony',
  'Traditional cultural ceremony', 'Fusion / multicultural wedding', 'Private elopement', 'Civil ceremony',
  'Community-centered celebration', 'Not sure yet',
];

class CulturalCelebrationTypePage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const CulturalCelebrationTypePage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Cultural traditions & wedding structure',
      preamble: 'Every celebration carries meaning, traditions, and stories. Tell us what cultural, spiritual, or family elements matter to you so Udo can support them thoughtfully.',
      currentStep: 15,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.udoLightBlush, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoPastelCrimson)),
            child: const Text(
              'These selections help Udo personalize timelines, reminders, guest planning, vendor recommendations, and ceremony flow.',
              style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary),
            ),
          ),
          OnboardingSection(
            title: 'What best describes your celebration?',
            child: MultiSelectChips(options: kCulturalCelebrationTypes, selected: answers.culturalCelebrationType, onToggle: (v) => setState(() => answers.toggle(answers.culturalCelebrationType, v))),
          ),
        ],
      ),
    );
  }
}

const kCulturalTraditionOptions = [
  'Mehndi / Henna night', 'Sangeet', 'Baraat', 'Tea ceremony', 'Libation ceremony', 'Kola nut ceremony',
  'Jumping the broom', 'Unity candle', 'Handfasting', 'Breaking the glass', 'Haka / cultural performance',
  'Elders blessing', 'Traditional drumming', 'Family procession', 'Prayer ceremony', 'Ancestor honoring',
  'Traditional dance performances', 'Gift exchange rituals', 'Dowry / bride price traditions',
  'Traditional attire changes', 'Naming ceremony', 'Other',
];

class CeremoniesTraditionsPage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const CeremoniesTraditionsPage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Ceremonies & traditions',
      preamble: 'Many weddings include rituals, celebrations, or meaningful customs beyond the main ceremony.',
      currentStep: 16,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingSection(
            title: 'Which traditions or ceremonies are important to your celebration?',
            child: MultiSelectChips(options: kCulturalTraditionOptions, selected: answers.culturalTraditions, onToggle: (v) => setState(() => answers.toggle(answers.culturalTraditions, v))),
          ),
          if (answers.culturalTraditions.contains('Other')) ...[
            const SizedBox(height: 16),
            UdoTextField(label: 'Other traditions we should know about?', hint: 'Describe your traditions', onChanged: (v) => answers.otherTraditions = v),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.udoLightBlush, borderRadius: BorderRadius.circular(14)),
            child: const Text('Udo uses these details to create more culturally aware timelines and planning suggestions.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          ),
        ],
      ),
    );
  }
}

const kReligiousStructureOptions = [
  'Christian ceremony', 'Muslim ceremony', 'Hindu ceremony', 'Sikh ceremony', 'Jewish ceremony', 'Buddhist ceremony',
  'Indigenous spiritual traditions', 'Traditional African spiritual traditions', 'Interfaith ceremony',
  'Secular / non-religious', 'Prefer not to say', 'Other',
];

class ReligiousStructurePage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const ReligiousStructurePage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Religious & spiritual structure',
      preamble: 'If faith or spirituality plays a role in your celebration, we want to support it respectfully.',
      currentStep: 17,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: OnboardingSection(
        title: 'Will faith or spirituality shape your wedding experience?',
        child: MultiSelectChips(options: kReligiousStructureOptions, selected: answers.religiousStructure, onToggle: (v) => setState(() => answers.toggle(answers.religiousStructure, v))),
      ),
    );
  }
}

const kFamilyInvolvementOptions = ['Mostly couple-led', 'Collaborative with family', 'Family-led decisions', 'Elders heavily involved', 'Shared planning across households', 'Planner-led coordination'];
const kSharedAccessOptions = ['Yes', 'Maybe later', 'No'];

class FamilyInvolvementPage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const FamilyInvolvementPage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Family involvement',
      preamble: 'Every wedding has a different planning dynamic. Help us understand how decisions are typically being made.',
      currentStep: 18,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingSection(
            title: 'How involved are family members in planning?',
            child: Column(children: kFamilyInvolvementOptions.map((v) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SelectableCard(label: v, selected: answers.familyInvolvement == v, onTap: () => setState(() => answers.familyInvolvement = v), dense: true))).toList()),
          ),
          OnboardingSection(
            title: 'Would you like shared planning access later?',
            child: Column(children: kSharedAccessOptions.map((v) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SelectableCard(label: v, selected: answers.sharedPlanningAccess == v, onTap: () => setState(() => answers.sharedPlanningAccess = v), dense: true))).toList()),
          ),
        ],
      ),
    );
  }
}

const kGuestHospitalityOptions = [
  'Mostly local guests', 'International guests', 'Guests traveling from multiple countries', 'Visa coordination needed',
  'Hotel blocks needed', 'Airport coordination needed', 'Elderly guest accommodations', 'Child-friendly accommodations',
  'Group transportation needed', 'Large family travel groups', 'Welcome events planned',
];

class GuestHospitalityPage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const GuestHospitalityPage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Guest travel & hospitality',
      preamble: 'Some weddings involve complex guest travel and hospitality planning.',
      currentStep: 19,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: OnboardingSection(
        title: 'What best describes your guest situation?',
        child: MultiSelectChips(options: kGuestHospitalityOptions, selected: answers.guestHospitality, onToggle: (v) => setState(() => answers.toggle(answers.guestHospitality, v))),
      ),
    );
  }
}

const kAttirePlanningOptions = [
  'Multiple outfit changes', 'Traditional attire', 'Western attire', 'Coordinated family attire', 'Bridal styling support',
  'Groom styling support', 'Beauty timeline planning', 'Jewelry coordination', 'Custom tailoring',
  'Cultural dressing assistance', 'Headpiece / turban coordination', 'Not sure yet',
];

class AttirePresentationPage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const AttirePresentationPage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Attire & presentation',
      preamble: 'Outfits and presentation are often a meaningful part of the celebration.',
      currentStep: 20,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: OnboardingSection(
        title: 'What matters most for attire planning?',
        child: MultiSelectChips(options: kAttirePlanningOptions, selected: answers.attirePlanning, onToggle: (v) => setState(() => answers.toggle(answers.attirePlanning, v))),
      ),
    );
  }
}

const kCelebrationDurations = ['Short ceremony', 'Half-day celebration', 'Full-day wedding', 'Weekend celebration', 'Three-day celebration', 'Flexible / open format', 'Not sure yet'];
const kCelebrationAtmospheres = ['Intimate & emotional', 'High-energy & social', 'Elegant & formal', 'Family-centered', 'Cultural & traditional', 'Luxury experience', 'Relaxed & peaceful', 'Community celebration'];

class CelebrationStructurePage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const CelebrationStructurePage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Celebration structure',
      preamble: 'Wedding celebrations vary greatly in timing and flow.',
      currentStep: 21,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingSection(
            title: 'How long will your celebration likely be?',
            child: Column(children: kCelebrationDurations.map((d) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SelectableCard(label: d, selected: answers.celebrationDuration == d, onTap: () => setState(() => answers.celebrationDuration = d), dense: true))).toList()),
          ),
          OnboardingSection(
            title: 'What atmosphere feels most like your celebration?',
            child: Column(children: kCelebrationAtmospheres.map((a) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SelectableCard(label: a, selected: answers.celebrationAtmosphere == a, onTap: () => setState(() => answers.celebrationAtmosphere = a), dense: true))).toList()),
          ),
        ],
      ),
    );
  }
}

const kPlanningSupportStyles = ['Minimal reminders', 'Weekly guidance', 'Structured planning support', 'Hands-on support'];

class HowUdoAdaptsPage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack;
  final void Function(void Function()) setState;
  const HowUdoAdaptsPage({super.key, required this.answers, required this.onNext, required this.onBack, required this.setState});

  List<String> _insights() {
    final insights = <String>[];
    if (answers.culturalCelebrationType.contains('Multi-day celebration')) {
      insights.add('Udo will help structure your multi-day celebration thoughtfully.');
    }
    if (answers.guestHospitality.contains('International guests') || answers.guestHospitality.contains('Guests traveling from multiple countries')) {
      insights.add("We'll help coordinate hospitality and travel details.");
    }
    if (answers.culturalTraditions.length > 3) {
      insights.add('Your planning journey may involve multiple ceremonies and traditions.');
    }
    if (answers.familyInvolvement.contains('Family-led') || answers.familyInvolvement.contains('Elders heavily involved')) {
      insights.add('Family collaboration tools may be especially helpful for your wedding.');
    }
    if (answers.culturalCelebrationType.contains('Fusion / multicultural wedding')) {
      insights.add('Your selections suggest a beautifully blended cultural experience.');
    }
    if (answers.celebrationDuration == 'Weekend celebration' || answers.celebrationDuration == 'Three-day celebration') {
      insights.add('Multi-day timelines will be specially adapted to your needs.');
    }
    if (insights.isEmpty) {
      insights.add('Udo will create a personalized planning experience just for you.');
      insights.add('Your selections will help us provide thoughtful, relevant guidance.');
    }
    return insights;
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'How Udo adapts to you',
      currentStep: 22,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          for (final insight in _insights())
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.udoLightBlush, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoPastelCrimson)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22, height: 22,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: const BoxDecoration(color: AppTheme.udoCrimson, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 13),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(insight, style: const TextStyle(fontSize: 13, color: AppTheme.udoGreen))),
                ],
              ),
            ),
          OnboardingSection(
            title: 'Planning support style',
            child: Column(children: kPlanningSupportStyles.map((s) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SelectableCard(label: s, selected: answers.planningSupportStyle == s, onTap: () => setState(() => answers.planningSupportStyle = s), dense: true))).toList()),
          ),
        ],
      ),
    );
  }
}
