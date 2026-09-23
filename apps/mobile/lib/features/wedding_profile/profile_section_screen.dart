import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/meta_events.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../auth/presentation/onboarding/onboarding_answers.dart';
import '../auth/presentation/onboarding/widgets/onboarding_scaffold.dart';
import '../home/presentation/providers/home_provider.dart';
import 'profile_sections.dart';

/// Runs one optional profile section: its questions as a short paged flow
/// with its own "step n of m" progress. Skip / close leaves without saving
/// anything; finishing the last page saves only this section's answers.
class ProfileSectionScreen extends ConsumerStatefulWidget {
  final ProfileSection section;
  const ProfileSectionScreen({super.key, required this.section});

  @override
  ConsumerState<ProfileSectionScreen> createState() =>
      _ProfileSectionScreenState();
}

class _ProfileSectionScreenState extends ConsumerState<ProfileSectionScreen> {
  final _pageCtrl = PageController();
  final _answers = OnboardingAnswers();
  int _page = 0;
  bool _saving = false;

  int get _count => widget.section.pages.length;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _goTo(int i) => _pageCtrl.animateToPage(i,
      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

  void _next() {
    if (_page < _count - 1) {
      _goTo(_page + 1);
    } else {
      _save();
    }
  }

  void _back() {
    if (_page > 0) {
      _goTo(_page - 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _skip() => Navigator.of(context).pop();

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final body = _answers.toJsonFor(widget.section.keys);
      // The event-architecture page defaults to "Fixed" even when no date
      // was picked; don't let that overwrite an "undecided" first-run answer.
      if (body['event_date'] == null) body.remove('date_status');
      body['profile_section'] = widget.section.id;

      await ref.read(apiClientProvider).post('/onboarding', data: body);
      await ref.read(profileProgressProvider.notifier).markDone(widget.section.id);
      MetaEvents.instance.profileSectionCompleted(section: widget.section.id);
      ref.read(homeProvider.notifier).refresh();
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
          SnackBar(content: Text('${widget.section.title} saved.')));
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(humanizeError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    void rebuild(void Function() fn) => setState(fn);

    return OnboardingProgressOverride(
      currentStep: _page + 1,
      totalSteps: _count,
      lastStepLabel: _saving ? 'Saving…' : 'Save',
      child: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (p) => setState(() => _page = p),
        children: [
          for (final build in widget.section.pages)
            build(SectionPageContext(
              answers: _answers,
              next: _next,
              back: _back,
              skip: _skip,
              setState: rebuild,
              saving: _saving,
            )),
        ],
      ),
    );
  }
}
