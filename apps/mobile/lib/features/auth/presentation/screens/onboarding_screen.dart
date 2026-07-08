import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_service.dart';
import '../providers/auth_provider.dart';
import '../onboarding/onboarding_answers.dart';
import '../onboarding/pages/pages_intro.dart';
import '../onboarding/pages/pages_event.dart';
import '../onboarding/pages/pages_people.dart';
import '../onboarding/pages/pages_cultural.dart';
import '../onboarding/pages/pages_final.dart';

const int kOnboardingPageCount = 24;
const int kOnboardingLastIndex = kOnboardingPageCount - 1;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;
  bool _submitting = false;
  final _answers = OnboardingAnswers();

  void _goTo(int index) {
    _pageCtrl.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _next() {
    if (_page < kOnboardingLastIndex) {
      _goTo(_page + 1);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page > 0) _goTo(_page - 1);
  }

  void _skipToEnd() => _goTo(kOnboardingLastIndex);

  Future<void> _finish() async {
    setState(() => _submitting = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/onboarding', data: _answers.toJson());
      final authSvc = ref.read(authServiceProvider);
      final user = await authSvc.me();
      final token = await authSvc.getToken();
      await authSvc.saveSession(token!, user);
      if (mounted) ref.invalidate(authProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void rebuild(void Function() fn) => setState(fn);

    final pages = <Widget>[
      WelcomeRolePage(answers: _answers, onNext: _next, onSkip: _skipToEnd, setState: rebuild),
      DecisionMakingPage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      PlanningStructurePage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      CoreEventArchitecturePage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      LocationTravelPage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      GuestExperiencePage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      BudgetPage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      PrioritiesPage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      FoodDiningPage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      VendorsPage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      WeddingPartyOnboardingPage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      PersonalMomentsPage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      AdditionalCelebrationsPage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      CulturalTransitionPage(onNext: _next, onBack: _back),
      CulturalCelebrationTypePage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      CeremoniesTraditionsPage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      ReligiousStructurePage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      FamilyInvolvementPage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      GuestHospitalityPage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      AttirePresentationPage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      CelebrationStructurePage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      HowUdoAdaptsPage(answers: _answers, onNext: _next, onBack: _back, setState: rebuild),
      HoneymoonPage(answers: _answers, onNext: _next, onBack: _back, onSkip: _skipToEnd, setState: rebuild),
      InsurancePage(answers: _answers, onFinish: _finish, onBack: _back, setState: rebuild, loading: _submitting),
    ];

    assert(pages.length == kOnboardingPageCount);

    return PageView(
      controller: _pageCtrl,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (p) => setState(() => _page = p),
      children: pages,
    );
  }
}
