import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/presentation/onboarding/onboarding_answers.dart';
import '../auth/presentation/onboarding/pages/pages_cultural.dart';
import '../auth/presentation/onboarding/pages/pages_event.dart';
import '../auth/presentation/onboarding/pages/pages_final.dart';
import '../auth/presentation/onboarding/pages/pages_intro.dart';
import '../auth/presentation/onboarding/pages/pages_people.dart';
import '../auth/presentation/providers/auth_provider.dart';

/// Builds one question page inside a section flow.
typedef SectionPageBuilder = Widget Function(SectionPageContext c);

class SectionPageContext {
  final OnboardingAnswers answers;
  final VoidCallback next, back, skip;
  final void Function(void Function()) setState;
  final bool saving;
  const SectionPageContext({
    required this.answers,
    required this.next,
    required this.back,
    required this.skip,
    required this.setState,
    required this.saving,
  });
}

class ProfileSection {
  final String id;
  final String title;
  final String subtitle;
  final int minutes;
  final IconData icon;

  /// The `POST /onboarding` fields this section owns.
  final List<String> keys;
  final List<SectionPageBuilder> pages;

  const ProfileSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.icon,
    required this.keys,
    required this.pages,
  });
}

SectionPageBuilder _std(
  Widget Function({
    required OnboardingAnswers answers,
    required VoidCallback onNext,
    required VoidCallback onBack,
    required VoidCallback onSkip,
    required void Function(void Function()) setState,
  }) make,
) =>
    (c) => make(
          answers: c.answers,
          onNext: c.next,
          onBack: c.back,
          onSkip: c.skip,
          setState: c.setState,
        );

/// The detailed questions that used to be a mandatory 24-screen onboarding,
/// regrouped into short optional sections.
final List<ProfileSection> kProfileSections = [
  ProfileSection(
    id: 'budget',
    title: 'Budget',
    subtitle: 'Total budget and how you want to spend it',
    minutes: 1,
    icon: Icons.account_balance_wallet_outlined,
    keys: const [
      'total_budget',
      'budget_structure',
      'allocation_preference',
      'funding',
      'budget_confidence',
    ],
    pages: [
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          BudgetPage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
    ],
  ),
  ProfileSection(
    id: 'guests_location',
    title: 'Guests & location',
    subtitle: 'Where, roughly how many, and guest needs',
    minutes: 2,
    icon: Icons.people_outline,
    keys: const [
      'country',
      'city',
      'venue_status',
      'guest_travel',
      'guest_experience',
      'guest_count',
    ],
    pages: [
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          LocationTravelPage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          GuestExperiencePage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
    ],
  ),
  ProfileSection(
    id: 'style_priorities',
    title: 'Style & priorities',
    subtitle: 'Type of wedding, season and what matters most',
    minutes: 2,
    icon: Icons.auto_awesome_outlined,
    keys: const [
      'wedding_type',
      'season',
      'date_status',
      'event_date',
      'time_of_day',
      'event_structure',
      'priorities',
    ],
    pages: [
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          CoreEventArchitecturePage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          PrioritiesPage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
    ],
  ),
  ProfileSection(
    id: 'food_vendors',
    title: 'Food & vendors',
    subtitle: 'Dining style and the suppliers you need',
    minutes: 2,
    icon: Icons.restaurant_outlined,
    keys: const [
      'dining_style',
      'dietary',
      'dining_enhancements',
      'core_vendors',
      'expanded_vendors',
      'unique_suppliers',
    ],
    pages: [
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          FoodDiningPage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          VendorsPage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
    ],
  ),
  ProfileSection(
    id: 'team_party',
    title: 'Planning team & wedding party',
    subtitle: 'Who helps decide, and who stands with you',
    minutes: 2,
    icon: Icons.groups_2_outlined,
    keys: const [
      'decision_style',
      'collaborators',
      'planning_approach',
      'planner_email',
      'wedding_party',
    ],
    pages: [
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          DecisionMakingPage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          PlanningStructurePage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          WeddingPartyOnboardingPage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
    ],
  ),
  ProfileSection(
    id: 'culture',
    title: 'Culture & traditions',
    subtitle: 'Ceremonies, family involvement and attire',
    minutes: 4,
    icon: Icons.celebration_outlined,
    keys: const [
      'cultural_celebration_type',
      'cultural_traditions',
      'other_traditions',
      'religious_structure',
      'family_involvement',
      'shared_planning_access',
      'guest_hospitality',
      'attire_planning',
      'celebration_duration',
      'celebration_atmosphere',
      'planning_support_style',
    ],
    pages: [
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          CulturalCelebrationTypePage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          CeremoniesTraditionsPage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          ReligiousStructurePage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          FamilyInvolvementPage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          GuestHospitalityPage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          AttirePresentationPage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          CelebrationStructurePage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
    ],
  ),
  ProfileSection(
    id: 'extras',
    title: 'Personal touches, honeymoon & insurance',
    subtitle: 'Speeches, tributes, honeymoon and cover',
    minutes: 3,
    icon: Icons.favorite_border,
    keys: const [
      'speeches',
      'who_speaking',
      'honouring_loved_ones',
      'tribute_type',
      'personal_touches',
      'additional_events',
      'event_organizer',
      'planning_honeymoon',
      'honeymoon_destination',
      'honeymoon_budget',
      'honeymoon_timing',
      'insurance',
    ],
    pages: [
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          PersonalMomentsPage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          AdditionalCelebrationsPage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
      _std(({required answers, required onNext, required onBack, required onSkip, required setState}) =>
          HoneymoonPage(answers: answers, onNext: onNext, onBack: onBack, onSkip: onSkip, setState: setState)),
      (c) => InsurancePage(
            answers: c.answers,
            onFinish: c.next,
            onBack: c.back,
            setState: c.setState,
            loading: c.saving,
          ),
    ],
  ),
];

class ProfileProgress {
  final Set<String> done;
  final bool loaded;
  const ProfileProgress({this.done = const {}, this.loaded = false});

  int get doneCount =>
      kProfileSections.where((s) => done.contains(s.id)).length;
  bool get complete => doneCount == kProfileSections.length;
}

/// Which optional profile sections this user has finished. Stored on-device
/// per user id — the answers themselves are saved server-side.
class ProfileProgressNotifier extends StateNotifier<ProfileProgress> {
  final int? _userId;
  ProfileProgressNotifier(this._userId) : super(const ProfileProgress()) {
    _load();
  }

  String get _key => 'profile_sections_done_$_userId';

  Future<void> _load() async {
    if (_userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    state = ProfileProgress(
        done: (prefs.getStringList(_key) ?? const []).toSet(), loaded: true);
  }

  Future<void> markDone(String sectionId) async {
    if (_userId == null) return;
    final next = {...state.done, sectionId};
    state = ProfileProgress(done: next, loaded: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, next.toList());
  }
}

final profileProgressProvider =
    StateNotifierProvider<ProfileProgressNotifier, ProfileProgress>((ref) {
  final userId = ref.watch(authProvider.select((s) => s.user?.id));
  return ProfileProgressNotifier(userId);
});
