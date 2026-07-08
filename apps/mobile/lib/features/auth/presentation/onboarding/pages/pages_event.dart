import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/udo_text_field.dart';
import '../onboarding_answers.dart';
import '../widgets/onboarding_scaffold.dart';
import '../widgets/onboarding_section.dart';
import '../widgets/selectable_card.dart';
import '../widgets/multi_select_chips.dart';

const kWeddingTypes = ['Destination', 'Local', 'Hometown', 'Multi-country'];
const kSeasons = ['Spring', 'Summer', 'Autumn', 'Winter'];
const kDateStatuses = ['Fixed', 'Flexible', 'Not decided'];
const kTimesOfDay = ['Morning', 'Afternoon', 'Evening', 'Multi-part celebration'];
const kEventStructureOptions = [
  'Ceremony', 'Reception', 'Civil ceremony', 'Traditional ceremony', 'Religious ceremony', 'Welcome dinner',
  'Engagement party', 'Rehearsal dinner', 'Bridal shower', 'Bachelor / stag party', 'Bachelorette / hen party',
  'Cultural ceremonies', 'Tea ceremony', 'Nikah / signing ceremony', 'After party', 'Day-after brunch',
  'Farewell gathering', 'Other',
];

class _GridPicker extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  const _GridPicker({required this.options, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.6,
      children: options.map((o) => SelectableCard(label: o, selected: selected == o, onTap: () => onSelect(o), dense: true, centered: true)).toList(),
    );
  }
}

class CoreEventArchitecturePage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const CoreEventArchitecturePage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Shape your wedding experience',
      preamble: 'This section helps us understand the structure, setting, and feeling of your celebration.',
      quote: 'The way your wedding unfolds should feel like you.',
      currentStep: 4,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingSection(title: 'Wedding type', child: _GridPicker(options: kWeddingTypes, selected: answers.weddingType, onSelect: (v) => setState(() => answers.weddingType = v))),
          OnboardingSection(title: 'Season', child: _GridPicker(options: kSeasons, selected: answers.season, onSelect: (v) => setState(() => answers.season = v))),
          OnboardingSection(
            title: 'Date',
            child: Column(
              children: [
                _GridPicker(options: kDateStatuses, selected: answers.dateStatus, onSelect: (v) => setState(() => answers.dateStatus = v)),
                if (answers.dateStatus == 'Fixed') ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: answers.weddingDate ?? DateTime.now().add(const Duration(days: 180)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (d != null) setState(() => answers.weddingDate = d);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppTheme.udoGreen, size: 18),
                          const SizedBox(width: 12),
                          Text(
                            answers.weddingDate == null ? 'Enter your wedding date' : '${answers.weddingDate!.day}/${answers.weddingDate!.month}/${answers.weddingDate!.year}',
                            style: TextStyle(color: answers.weddingDate == null ? AppTheme.udoTextSecondary : AppTheme.udoTextPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          OnboardingSection(title: 'Time of day', child: _GridPicker(options: kTimesOfDay, selected: answers.timeOfDay, onSelect: (v) => setState(() => answers.timeOfDay = v))),
          OnboardingSection(
            title: 'Event structure (select all that apply)',
            helper: 'You can always add more events later inside the app.',
            child: MultiSelectChips(
              options: kEventStructureOptions,
              selected: answers.eventStructure,
              onToggle: (v) => setState(() => answers.toggle(answers.eventStructure, v)),
            ),
          ),
        ],
      ),
    );
  }
}

const kVenueStatuses = ['Not started', 'Shortlisting', 'Booked'];
const kGuestTravelOptions = ['Mostly local', 'Mixed', 'Mostly international'];
const kTravelSupportOptions = ['Accommodation coordination', 'Travel booking support', 'Visa guidance', 'Shuttle services'];

class LocationTravelPage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const LocationTravelPage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Location & guest travel',
      preamble: 'This helps us plan around venue progress, travel needs, and guest coordination.',
      currentStep: 5,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingSection(
            title: 'Location details',
            child: Column(
              children: [
                UdoTextField(label: 'Country', hint: 'Enter country', onChanged: (v) => answers.country = v),
                const SizedBox(height: 12),
                UdoTextField(label: 'City', hint: 'Enter city', onChanged: (v) => answers.city = v),
              ],
            ),
          ),
          OnboardingSection(
            title: 'Venue status',
            child: Column(
              children: kVenueStatuses
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SelectableCard(label: s, selected: answers.venueStatus == s, onTap: () => setState(() => answers.venueStatus = s), dense: true),
                      ))
                  .toList(),
            ),
          ),
          OnboardingSection(
            title: 'Guest travel profile',
            child: Column(
              children: kGuestTravelOptions
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SelectableCard(label: s, selected: answers.guestTravel == s, onTap: () => setState(() => answers.guestTravel = s), dense: true),
                      ))
                  .toList(),
            ),
          ),
          OnboardingSection(
            title: 'Support needed',
            helper: 'The more we understand travel complexity, the better we can organize communication and logistics.',
            child: MultiSelectChips(
              options: kTravelSupportOptions,
              selected: answers.travelSupport,
              onToggle: (v) => setState(() => answers.toggle(answers.travelSupport, v)),
            ),
          ),
        ],
      ),
    );
  }
}

const kGuestExperienceOptions = [
  'Children included', 'Adults-only event', 'Accommodation required', 'Transport required', 'Meal selection required',
  'Dietary tracking required', 'Accessibility needs', 'Welcome packs / gifting', 'Guest communication portal',
  'Seating optimization', 'Multi-language support', 'RSVP reminders', 'Hotel block coordination',
  'Airport transfer support', 'Local activity suggestions', 'Dress code support', 'FAQ page for guests',
  'Gift registry guidance', 'Event map / directions', 'Shuttle timing communication',
];

class GuestExperiencePage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const GuestExperiencePage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Design your guest experience',
      preamble: 'The choices you make here will shape your guest dashboard, communications, reminders, and planning recommendations.',
      quote: 'Think about how you want guests to feel from the moment they are invited.',
      currentStep: 6,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          MultiSelectChips(
            options: kGuestExperienceOptions,
            selected: answers.guestExperience,
            onToggle: (v) => setState(() => answers.toggle(answers.guestExperience, v)),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.udoLightBlush, borderRadius: BorderRadius.circular(14)),
            child: const Text(
              'These choices will feed directly into your guest-facing experience inside Udo.',
              style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary),
            ),
          ),
          const SizedBox(height: 8),
          Text('Expected guest count: ${answers.guestCount}', style: const TextStyle(fontWeight: FontWeight.w500)),
          Slider(
            value: answers.guestCount.toDouble(),
            min: 10, max: 800, divisions: 79,
            activeColor: AppTheme.udoGreen,
            onChanged: (v) => setState(() => answers.guestCount = v.round()),
          ),
        ],
      ),
    );
  }
}

const kBudgetStructures = ['Fixed budget', 'Flexible budget', 'Priority-led budget'];
const kAllocationPreferences = ['Even distribution', 'Experience-focused', 'Aesthetic-focused', 'Cost-conscious / controlled', 'Luxury-led', 'Logistics-first'];
const kFundingOptions = ['Self-funded', 'Family-funded', 'Joint contributions', 'Shared support from multiple people', 'Prefer not to say'];
const kBudgetConfidences = ['Early estimate', 'Moderately defined', 'Finalised'];

class BudgetPage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const BudgetPage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Budget & spending style',
      preamble: 'We are not just asking how much you want to spend — we are learning how you want to spend it.',
      currentStep: 7,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingSection(
            title: 'Total budget',
            helper: 'Your working budget can always be refined later.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\$${answers.totalBudget.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.udoGreen)),
                Slider(
                  value: answers.totalBudget.clamp(1000, 250000),
                  min: 1000, max: 250000, divisions: 249,
                  activeColor: AppTheme.udoGreen,
                  onChanged: (v) => setState(() => answers.totalBudget = v),
                ),
              ],
            ),
          ),
          OnboardingSection(
            title: 'Structure',
            helper: 'Structure tells us how firmly your budget is set.',
            child: Column(
              children: kBudgetStructures
                  .map((s) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SelectableCard(label: s, selected: answers.budgetStructure == s, onTap: () => setState(() => answers.budgetStructure = s), dense: true)))
                  .toList(),
            ),
          ),
          OnboardingSection(
            title: 'Allocation preference',
            helper: 'This shows how you want your spending to feel overall.',
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.4,
              children: kAllocationPreferences.map((p) => SelectableCard(label: p, selected: answers.allocationPreference == p, onTap: () => setState(() => answers.allocationPreference = p), dense: true, centered: true)).toList(),
            ),
          ),
          OnboardingSection(
            title: 'Funding',
            helper: 'Understanding who is contributing helps us frame planning conversations realistically.',
            child: Column(
              children: kFundingOptions
                  .map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SelectableCard(label: f, selected: answers.funding == f, onTap: () => setState(() => answers.funding = f), dense: true)))
                  .toList(),
            ),
          ),
          OnboardingSection(
            title: 'Confidence',
            helper: 'Confidence shows how certain you feel about your current budget choices.',
            child: Column(
              children: kBudgetConfidences
                  .map((c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SelectableCard(label: c, selected: answers.budgetConfidence == c, onTap: () => setState(() => answers.budgetConfidence = c), dense: true)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

const kPriorityOptions = [
  'Guest experience', 'Food & beverage quality', 'Photography & videography', 'Visual design & decor', 'Entertainment',
  'Convenience & ease', 'Cultural traditions', 'Budget efficiency', 'Luxury / exclusivity', 'Intimacy',
  'Family involvement', 'Emotional meaning', 'Timeless elegance', 'Stress reduction', 'Smooth logistics',
];

class PrioritiesPage extends StatelessWidget {
  final OnboardingAnswers answers;
  final VoidCallback onNext, onBack, onSkip;
  final void Function(void Function()) setState;
  const PrioritiesPage({super.key, required this.answers, required this.onNext, required this.onBack, required this.onSkip, required this.setState});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      title: 'Your wedding priorities',
      preamble: 'We really want to know what makes you light up. Your priorities will help us guide you beautifully.',
      quote: 'The most memorable weddings feel intentional.',
      currentStep: 8,
      totalSteps: 24,
      onNext: onNext,
      onBack: onBack,
      onSkip: onSkip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Choose up to 5 priorities. These will influence your dashboard, reminders, and recommendations.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
          const SizedBox(height: 14),
          MultiSelectChips(
            options: kPriorityOptions,
            selected: answers.priorities,
            maxSelections: 5,
            onToggle: (v) => setState(() => answers.toggle(answers.priorities, v, max: 5)),
          ),
        ],
      ),
    );
  }
}
