import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/analytics/meta_events.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/udo_text_field.dart';
import '../onboarding/widgets/onboarding_scaffold.dart';
import '../providers/auth_provider.dart';

const int kOnboardingPageCount = 3;

/// The whole first-run flow: your name, your partner's name, the date — all
/// skippable except your own name (prefilled from the account). Everything
/// else (budget, guests, culture…) is collected later from the "Complete your
/// wedding profile" checklist on Home.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  late final TextEditingController _nameCtrl;
  final _partnerCtrl = TextEditingController();
  DateTime? _date;
  int _page = 0;
  bool _submitting = false;
  bool _completed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final first = ref.read(authProvider).user?.firstName ?? '';
    _nameCtrl = TextEditingController(text: first)
      ..addListener(() => setState(() {}));
    MetaEvents.instance
        .onboardingStepViewed(index: 0, totalSteps: kOnboardingPageCount);
  }

  @override
  void dispose() {
    if (!_completed) {
      MetaEvents.instance.onboardingAbandoned(
          lastIndex: _page, totalSteps: kOnboardingPageCount);
    }
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _partnerCtrl.dispose();
    super.dispose();
  }

  void _goTo(int index) => _pageCtrl.animateToPage(index,
      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

  void _next() {
    if (_page < kOnboardingPageCount - 1) {
      _goTo(_page + 1);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page > 0) _goTo(_page - 1);
  }

  void _skip() {
    MetaEvents.instance.onboardingStepSkipped(index: _page);
    if (_page == 1) _partnerCtrl.clear();
    if (_page == 2) _date = null;
    _next();
  }

  Map<String, dynamic> _payload() {
    final you = _nameCtrl.text.trim();
    final partner = _partnerCtrl.text.trim();
    return {
      'user_name': you,
      if (partner.isNotEmpty) 'partner_name': partner,
      'couple_name': partner.isEmpty ? you : '$you & $partner',
      'date_status': _date == null ? 'Undecided' : 'Fixed',
      if (_date != null)
        'event_date': DateFormat('yyyy-MM-dd').format(_date!),
      'profile_section': 'quick_start',
    };
  }

  Future<void> _finish() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(apiClientProvider).post('/onboarding', data: _payload());
      _completed = true;
      MetaEvents.instance.onboardingCompleted();
      final refreshError =
          await ref.read(authProvider.notifier).finishOnboardingRefresh();
      if (refreshError != null && mounted) setState(() => _error = refreshError);
    } catch (e) {
      if (mounted) setState(() => _error = humanizeError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 180)),
      firstDate: now,
      lastDate: DateTime(now.year + 6),
      helpText: 'Wedding date',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Widget _skipLink(String label) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: TextButton(
          onPressed: _submitting ? null : _skip,
          child: Text(label,
              style: const TextStyle(
                  color: AppTheme.udoGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (p) {
          setState(() => _page = p);
          MetaEvents.instance
              .onboardingStepViewed(index: p, totalSteps: kOnboardingPageCount);
        },
        children: [
          OnboardingScaffold(
            title: "What's your name?",
            preamble: 'So Udo can greet you properly. That is all we need to get started.',
            currentStep: 1,
            totalSteps: kOnboardingPageCount,
            onNext: _next,
            nextEnabled: _nameCtrl.text.trim().isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: UdoTextField(
                label: 'Your first name',
                controller: _nameCtrl,
              ),
            ),
          ),
          OnboardingScaffold(
            title: "Your partner's name",
            preamble: 'Add them now, or come back to it later. Nothing else depends on it.',
            currentStep: 2,
            totalSteps: kOnboardingPageCount,
            onBack: _back,
            onNext: _next,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                UdoTextField(
                  label: "Partner's first name",
                  controller: _partnerCtrl,
                ),
                _skipLink('Add later'),
              ],
            ),
          ),
          OnboardingScaffold(
            title: 'When is the big day?',
            preamble: 'A rough date is fine. It powers your countdown and planning timeline.',
            currentStep: 3,
            totalSteps: kOnboardingPageCount,
            onBack: _back,
            onNext: _next,
            nextLabel: _submitting ? 'Setting things up…' : 'Enter my dashboard',
            nextEnabled: !_submitting,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _submitting ? null : _pickDate,
                  icon: const Icon(Icons.event_outlined),
                  label: Text(_date == null
                      ? 'Choose a date'
                      : DateFormat('EEEE, d MMMM yyyy').format(_date!)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    foregroundColor: AppTheme.udoGreen,
                    side: const BorderSide(color: AppTheme.udoGreen),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                _skipLink("I haven't decided yet"),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.udoCrimson.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline,
                          color: AppTheme.udoCrimson, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                color: AppTheme.udoCrimsonText, fontSize: 13)),
                      ),
                    ]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
