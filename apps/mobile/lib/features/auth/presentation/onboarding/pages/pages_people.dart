import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/udo_text_field.dart';
import '../onboarding_answers.dart';
import '../widgets/onboarding_scaffold.dart';
import '../widgets/onboarding_section.dart';
import '../widgets/selectable_card.dart';
import '../widgets/multi_select_chips.dart';
import '../widgets/toggle_row.dart';
import '../widgets/info_sheet.dart';

const kDiningStyles = ['Formal plated', 'Buffet', 'Family-style', 'Shared banquet', 'Cocktail-style reception', 'Food stations', 'Cultural cuisine', 'Mixed format', 'Not decided yet'];
const kDietaryOptions = ['Vegetarian', 'Vegan', 'Halal', 'Kosher', 'Gluten-free', 'Dairy-free', 'Nut allergy', 'Seafood allergy', 'Egg-free', 'Low-sugar / diabetic-friendly', 'No pork', 'No alcohol', 'Child-friendly meals', 'Other', 'Unsure for now'];
const kDiningEnhancements = ['Cocktail hour', 'Signature drinks', 'Champagne tower', 'Late-night snacks', 'Dessert station', 'Sweet table', 'Coffee cart', 'Food truck', 'Interactive food stations', 'Cultural food moments', 'Welcome drinks', 'Brunch station', 'Custom cake experience', 'Other'];

class FoodDiningPage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const FoodDiningPage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Food, dining & guest preferences',
      preamble: 'Great food is one of the most memorable parts of a wedding. Tell us what matters here — even if you only know part of it for now.',
      currentStep: 9,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingSection(
            title: 'Dining style',
            helper: 'How do you imagine the meal experience?',
            child: Column(
              children: kDiningStyles.map((s) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SelectableCard(label: s, selected: answers.diningStyle == s, onTap: () => setState(() => answers.diningStyle = s), dense: true))).toList(),
            ),
          ),
          OnboardingSection(
            title: 'Dietary needs',
            helper: 'Guest dietary requirements or meal restrictions you may need to accommodate.',
            child: MultiSelectChips(options: kDietaryOptions, selected: answers.dietary, onToggle: (v) => setState(() => answers.toggle(answers.dietary, v))),
          ),
          OnboardingSection(
            title: 'Dining enhancements',
            helper: 'Additional touches that elevate the food and drink experience.',
            child: MultiSelectChips(options: kDiningEnhancements, selected: answers.diningEnhancements, onToggle: (v) => setState(() => answers.toggle(answers.diningEnhancements, v))),
          ),
        ],
      ),
    );
  }
}

const kCoreVendors = ['Venue', 'Planner', 'Photographer', 'Videographer', 'Catering', 'Florist', 'Decor stylist', 'DJ / Band'];
const kExpandedVendors = ['Lighting designer', 'Content creator', 'Photo booth', 'Live streaming', 'Wedding website', 'Stationery designer', 'Security', 'Transport provider', 'Rentals', 'Marquee / tipi hire', 'Celebrant / officiant', 'Hair & makeup', 'Cake designer', 'MC / host', 'AV / sound support'];
const kUniqueSuppliers = ['Fireworks', 'Drone shows', 'Live performers', 'Cultural performers', 'Luxury experiences', 'Custom installations', 'Interactive guest experiences', 'Surprise entertainment'];

class VendorsPage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const VendorsPage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Vendors & supplier needs',
      preamble: 'The vendors you expect to use will help us personalize your dashboard, recommendations, task lists, and planning timeline.',
      currentStep: 10,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const Text('Select what you expect to need now — you can always refine later.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
          OnboardingSection(title: 'Core vendors', child: MultiSelectChips(options: kCoreVendors, selected: answers.coreVendors, onToggle: (v) => setState(() => answers.toggle(answers.coreVendors, v)))),
          OnboardingSection(title: 'Expanded vendors', child: MultiSelectChips(options: kExpandedVendors, selected: answers.expandedVendors, onToggle: (v) => setState(() => answers.toggle(answers.expandedVendors, v)))),
          OnboardingSection(title: 'Unique suppliers', child: MultiSelectChips(options: kUniqueSuppliers, selected: answers.uniqueSuppliers, onToggle: (v) => setState(() => answers.toggle(answers.uniqueSuppliers, v)))),
        ],
      ),
    );
  }
}

const kWeddingPartyInfo = {
  'Maid of Honour': 'Supports the bride throughout planning and on the wedding day, including coordination, emotional support, and logistics.',
  'Best Man': 'Assists the groom, manages key logistics, and often delivers a speech.',
  'Bridesmaids': 'Support the bride, assist with events, and contribute to planning tasks.',
  'Groomsmen': 'Support the groom, assist with coordination, and participate in pre-wedding events.',
  'Ushers': 'Help guests find their seats and assist with ceremony logistics.',
  'Flower Girl': 'Young girl who walks down the aisle scattering flower petals before the bride.',
  'Page Boy': 'Young boy who carries the rings or walks down the aisle during the ceremony.',
  'Ring Bearer': 'Child responsible for carrying the wedding rings down the aisle.',
};

class WeddingPartyOnboardingPage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const WeddingPartyOnboardingPage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Your wedding party',
      preamble: 'These roles will help us organize timelines, reminders, responsibilities, and key moments throughout your planning.',
      currentStep: 11,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          for (final role in kWeddingPartyInfo.keys)
            ToggleRow(
              label: role,
              value: answers.weddingParty[role] ?? false,
              onChanged: (v) => setState(() => answers.weddingParty[role] = v),
              onInfoTap: () => showInfoSheet(context, title: role, description: kWeddingPartyInfo[role]!),
            ),
        ],
      ),
    );
  }
}

const kTributeTypes = ['Speech', 'Memory table', 'Candle lighting', 'Moment of silence', 'Photo display', 'Tribute mention', 'Custom'];
const kWhoSpeakingOptions = ['Groom', 'Bride', 'Parent', 'Sibling', 'Best man', 'Maid of honour', 'Friend', 'Other'];

class PersonalMomentsPage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const PersonalMomentsPage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  Widget _yesNo(String value, ValueChanged<String> onSelect) {
    return Row(
      children: ['Yes', 'No'].map((o) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: o == 'Yes' ? 8 : 0),
          child: SelectableCard(label: o, selected: value == o, onTap: () => onSelect(o), dense: true, centered: true),
        ),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Personal moments',
      preamble: 'What special moments do you want your wedding to hold?',
      currentStep: 12,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('These details help us honor the emotional heart of your celebration — not just the logistics.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
          OnboardingSection(title: 'Speeches planned?', child: _yesNo(answers.speeches, (v) => setState(() => answers.speeches = v))),
          if (answers.speeches == 'Yes')
            OnboardingSection(
              title: 'Who is speaking?',
              child: MultiSelectChips(options: kWhoSpeakingOptions, selected: answers.whoSpeaking, onToggle: (v) => setState(() => answers.toggle(answers.whoSpeaking, v))),
            ),
          OnboardingSection(title: 'Honouring loved ones?', child: _yesNo(answers.honouringLovedOnes, (v) => setState(() => answers.honouringLovedOnes = v))),
          if (answers.honouringLovedOnes == 'Yes')
            OnboardingSection(
              title: 'Tribute type',
              child: Column(
                children: kTributeTypes.map((t) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SelectableCard(label: t, selected: answers.tributeType == t, onTap: () => setState(() => answers.tributeType = t), dense: true))).toList(),
              ),
            ),
          const SizedBox(height: 24),
          UdoTextField(
            label: 'Any meaningful personal touches you already know you want?',
            hint: 'Describe special moments or traditions',
            onChanged: (v) => answers.personalTouches = v,
          ),
        ],
      ),
    );
  }
}

const kAdditionalEventOptions = ['Stag party', 'Hen party', 'Engagement party', 'Rehearsal dinner', 'Post-wedding brunch', 'Bridal shower', 'Welcome drinks', 'Family dinner', 'Farewell breakfast', 'Other'];
const kEventOrganizers = ['I am', 'My planner is', 'Friends / family are', 'Different people for different events'];

class AdditionalCelebrationsPage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const AdditionalCelebrationsPage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Additional celebrations',
      preamble: 'Many weddings include more than one moment. Let us know what else is part of your celebration.',
      currentStep: 13,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          MultiSelectChips(options: kAdditionalEventOptions, selected: answers.additionalEvents, onToggle: (v) => setState(() => answers.toggle(answers.additionalEvents, v))),
          if (answers.additionalEvents.isNotEmpty)
            OnboardingSection(
              title: 'Who is organizing these events?',
              child: Column(
                children: kEventOrganizers.map((o) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SelectableCard(label: o, selected: answers.eventOrganizer == o, onTap: () => setState(() => answers.eventOrganizer = o), dense: true))).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
