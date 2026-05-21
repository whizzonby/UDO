import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/udo_logo.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_progress_bar.dart';
import '../widgets/selection_card.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(onboardingStepNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            OnboardingProgressBar(
              currentStep: step,
              totalSteps: OnboardingStepNotifier.totalSteps,
            ),
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: PageController(initialPage: step),
                children: const [
                  _WelcomeStep(),
                  _CoupleNamesStep(),
                  _WeddingDateStep(),
                  _GuestCountStep(),
                  _UserRoleStep(),
                  _VenueStatusStep(),
                  _BudgetStep(),
                  _PlanningStageStep(),
                  _PlanningPrioritiesStep(),
                  _GuestExperienceStep(),
                  _CommunicationStyleStep(),
                  _InvitationChannelsStep(),
                  _WeddingVibesStep(),
                  _AllSetStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step navigation helper ────────────────────────────────────────────────

// ignore: unused_element
class _StepScaffold extends ConsumerWidget {
  // ignore: unused_element_parameter
  const _StepScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.ctaLabel = 'Continue',
    this.canContinue = true,
    this.onContinue,
    this.showBack = true,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final String ctaLabel;
  final bool canContinue;
  final VoidCallback? onContinue;
  final bool showBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingStepNotifierProvider.notifier);
    final step = ref.watch(onboardingStepNotifierProvider);

    return Column(
      children: [
        // Back button
        if (showBack && step > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 0, 0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                color: AppColors.forestGreen,
                onPressed: notifier.previous,
              ),
            ),
          )
        else
          const SizedBox(height: 52),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const UdoLogo(size: 28),
                const SizedBox(height: 28),
                Text(title, style: AppTypography.displaySmall),
                const SizedBox(height: 8),
                Text(subtitle, style: AppTypography.bodyMedium),
                const SizedBox(height: 28),
                child,
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: PrimaryButton(
            label: ctaLabel,
            onPressed: canContinue
                ? (onContinue ?? notifier.next)
                : null,
            backgroundColor: canContinue
                ? AppColors.forestGreen
                : AppColors.grey300,
          ),
        ),
      ],
    );
  }
}

// ─── Step 0: Welcome ──────────────────────────────────────────────────────

class _WelcomeStep extends ConsumerWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(onboardingStepNotifierProvider.notifier);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const UdoLogo(size: 56),
          const SizedBox(height: 24),
          Text(
            'Welcome to Udo',
            style: AppTypography.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Let's set up your wedding in just a few minutes. We'll personalise everything to your day.",
            style: AppTypography.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          PrimaryButton(
            label: "Let's get started",
            onPressed: notifier.next,
          ),
        ],
      ),
    );
  }
}

// ─── Step 1: Couple names ─────────────────────────────────────────────────

class _CoupleNamesStep extends ConsumerStatefulWidget {
  const _CoupleNamesStep();

  @override
  ConsumerState<_CoupleNamesStep> createState() => _CoupleNamesStepState();
}

class _CoupleNamesStepState extends ConsumerState<_CoupleNamesStep> {
  final _one = TextEditingController();
  final _two = TextEditingController();

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingNotifierProvider);
    _one.text = data.partnerOneName ?? '';
    _two.text = data.partnerTwoName ?? '';
  }

  @override
  void dispose() {
    _one.dispose();
    _two.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: "What are the couple's names?",
      subtitle: 'This is how your wedding will be personalised throughout the app.',
      canContinue: _one.text.isNotEmpty && _two.text.isNotEmpty,
      onContinue: () {
        ref.read(onboardingNotifierProvider.notifier).updatePartnerNames(
              one: _one.text.trim(),
              two: _two.text.trim(),
            );
        ref.read(onboardingStepNotifierProvider.notifier).next();
      },
      child: Column(
        children: [
          TextFormField(
            controller: _one,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: "Partner 1's first name"),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _two,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: "Partner 2's first name"),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Wedding date ─────────────────────────────────────────────────

class _WeddingDateStep extends ConsumerStatefulWidget {
  const _WeddingDateStep();

  @override
  ConsumerState<_WeddingDateStep> createState() => _WeddingDateStepState();
}

class _WeddingDateStepState extends ConsumerState<_WeddingDateStep> {
  DateTime? _selectedDate;
  bool _notSet = false;

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingNotifierProvider);
    _selectedDate = data.weddingDate;
    _notSet = data.dateNotSet;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.forestGreen,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _notSet = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: "When's the big day?",
      subtitle: "Set your wedding date so we can count down and plan reminders.",
      canContinue: _selectedDate != null || _notSet,
      onContinue: () {
        ref.read(onboardingNotifierProvider.notifier).updateWeddingDate(
              _selectedDate,
              notSet: _notSet,
            );
        ref.read(onboardingStepNotifierProvider.notifier).next();
      },
      child: Column(
        children: [
          GestureDetector(
            onTap: _notSet ? null : _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: _selectedDate != null && !_notSet
                    ? AppColors.selectionFill
                    : AppColors.white,
                borderRadius: AppSpacing.borderLg,
                border: Border.all(
                  color: _selectedDate != null && !_notSet
                      ? AppColors.selectionBorder
                      : AppColors.grey200,
                  width: _selectedDate != null && !_notSet ? 1.8 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: _selectedDate != null && !_notSet
                        ? AppColors.dustyRose
                        : AppColors.grey500,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedDate != null && !_notSet
                        ? DateFormat('EEEE, d MMMM yyyy').format(_selectedDate!)
                        : 'Select wedding date',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: _selectedDate != null && !_notSet
                          ? AppColors.dustyRose
                          : AppColors.grey500,
                      fontWeight: _selectedDate != null && !_notSet
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SelectionCard(
            label: "We haven't set a date yet",
            subtitle: 'You can add it later',
            isSelected: _notSet,
            onTap: () => setState(() {
              _notSet = !_notSet;
              if (_notSet) _selectedDate = null;
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Guest count ──────────────────────────────────────────────────

class _GuestCountStep extends ConsumerWidget {
  const _GuestCountStep();

  static const _options = [
    ('Under 50', 'Intimate gathering'),
    ('50 – 100', 'Medium wedding'),
    ('100 – 200', 'Classic wedding'),
    ('200 – 300', 'Large celebration'),
    ('300+', 'Grand event'),
    ("We're still deciding", null),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return _StepScaffold(
      title: 'How many guests are you expecting?',
      subtitle: "This helps us set up the right capacity defaults for seating and tables.",
      canContinue: data.guestCountRange != null,
      child: Column(
        children: _options.map((opt) {
          final (label, subtitle) = opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionCard(
              label: label,
              subtitle: subtitle,
              isSelected: data.guestCountRange == label,
              onTap: () => notifier.updateGuestCount(label),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 4: User role ────────────────────────────────────────────────────

class _UserRoleStep extends ConsumerWidget {
  const _UserRoleStep();

  static const _options = [
    ('One of the couple', "It's my wedding!", Icons.favorite_border_rounded),
    ('Wedding Planner', 'Planning on behalf of a couple', Icons.event_note_outlined),
    ('Close Friend / Family', 'Helping organise the big day', Icons.people_outline_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return _StepScaffold(
      title: 'What is your role?',
      subtitle: "We'll personalise your experience based on how you're involved.",
      canContinue: data.userRole != null,
      child: Column(
        children: _options.map((opt) {
          final (label, subtitle, icon) = opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionCard(
              label: label,
              subtitle: subtitle,
              icon: icon,
              isSelected: data.userRole == label,
              onTap: () => notifier.updateUserRole(label),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 5: Venue status ─────────────────────────────────────────────────

class _VenueStatusStep extends ConsumerWidget {
  const _VenueStatusStep();

  static const _options = [
    ('Yes, we have a venue', null, '🏛️'),
    ('We are still looking', null, '🔍'),
    ("We haven't started looking", null, '📋'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return _StepScaffold(
      title: 'Have you chosen a venue?',
      subtitle: "We'll set up the logistics section based on your venue status.",
      canContinue: data.venueStatus != null,
      child: Column(
        children: _options.map((opt) {
          final (label, subtitle, emoji) = opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionCard(
              label: label,
              subtitle: subtitle,
              emoji: emoji,
              isSelected: data.venueStatus == label,
              onTap: () => notifier.updateVenueStatus(label),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 6: Budget ───────────────────────────────────────────────────────

class _BudgetStep extends ConsumerWidget {
  const _BudgetStep();

  static const _options = [
    'Under \$5,000',
    '\$5,000 – \$15,000',
    '\$15,000 – \$30,000',
    '\$30,000 – \$50,000',
    '\$50,000 – \$100,000',
    '\$100,000+',
    "I'd prefer not to say",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return _StepScaffold(
      title: "What's your approximate budget?",
      subtitle: "This helps us recommend the right tools and set realistic expectations.",
      canContinue: data.budgetRange != null,
      child: Column(
        children: _options.map((label) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionCard(
              label: label,
              isSelected: data.budgetRange == label,
              onTap: () => notifier.updateBudgetRange(label),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 7: Planning stage ───────────────────────────────────────────────

class _PlanningStageStep extends ConsumerWidget {
  const _PlanningStageStep();

  static const _options = [
    ('Just getting started', 'Exploring and figuring out the basics'),
    ('Early planning', 'Dates, venue, and guest list'),
    ('Mid planning', 'Vendors booked, details being finalised'),
    ('Almost there', 'Finishing touches and final confirmations'),
    ("It's happening soon!", "Wedding is within a month"),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return _StepScaffold(
      title: 'Where are you in your planning?',
      subtitle: "We'll prioritise the most relevant features for your stage.",
      canContinue: data.planningStage != null,
      child: Column(
        children: _options.map((opt) {
          final (label, subtitle) = opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionCard(
              label: label,
              subtitle: subtitle,
              isSelected: data.planningStage == label,
              onTap: () => notifier.updatePlanningStage(label),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 8: Planning priorities ─────────────────────────────────────────

class _PlanningPrioritiesStep extends ConsumerWidget {
  const _PlanningPrioritiesStep();

  static const _options = [
    ('Guest Management', '💌'),
    ('Seating & Tables', '🪑'),
    ('Budget Tracking', '💰'),
    ('Vendor Coordination', '🤝'),
    ('Guest Experience', '✨'),
    ('Invitations', '📩'),
    ('Timeline & Schedule', '🗓️'),
    ('Gallery & Photos', '📸'),
    ('Registry', '🎁'),
    ('Logistics & Travel', '🚗'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return _StepScaffold(
      title: "What matters most to you?",
      subtitle: "Select all that apply. We'll highlight these features in your dashboard.",
      canContinue: data.planningPriorities.isNotEmpty,
      child: Column(
        children: _options.map((opt) {
          final (label, emoji) = opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionCard(
              label: label,
              emoji: emoji,
              isSelected: data.planningPriorities.contains(label),
              onTap: () => notifier.togglePlanningPriority(label),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 9: Guest experience ─────────────────────────────────────────────

class _GuestExperienceStep extends ConsumerWidget {
  const _GuestExperienceStep();

  static const _options = [
    ('Elegant & minimal', 'Clean, simple, focused on the essentials', '🤍'),
    ('Warm & personal', 'Heartfelt with personal touches and stories', '💛'),
    ('Bold & celebratory', 'Vibrant, energetic, and festive', '🎉'),
    ('Traditional & classic', 'Timeless and formal', '🏛️'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return _StepScaffold(
      title: "What kind of guest experience do you want to create?",
      subtitle: "This shapes the design and tone of everything your guests see.",
      canContinue: data.guestExperience != null,
      child: Column(
        children: _options.map((opt) {
          final (label, subtitle, emoji) = opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionCard(
              label: label,
              subtitle: subtitle,
              emoji: emoji,
              isSelected: data.guestExperience == label,
              onTap: () => notifier.updateGuestExperience(label),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 10: Communication style ────────────────────────────────────────

class _CommunicationStyleStep extends ConsumerWidget {
  const _CommunicationStyleStep();

  static const _options = [
    ('Proactive', 'I like to send updates frequently and keep guests in the loop', '📢'),
    ('Need-to-know', 'I only communicate key info when it matters', '📌'),
    ('Mixed', "Depends on the type of update — I'll decide case by case", '⚖️'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return _StepScaffold(
      title: "How do you like to communicate with guests?",
      subtitle: "This helps us suggest the right messaging tools and frequency.",
      canContinue: data.communicationStyle != null,
      child: Column(
        children: _options.map((opt) {
          final (label, subtitle, emoji) = opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionCard(
              label: label,
              subtitle: subtitle,
              emoji: emoji,
              isSelected: data.communicationStyle == label,
              onTap: () => notifier.updateCommunicationStyle(label),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 11: Invitation channels ────────────────────────────────────────

class _InvitationChannelsStep extends ConsumerWidget {
  const _InvitationChannelsStep();

  static const _options = [
    ('Email', '✉️'),
    ('WhatsApp', '💬'),
    ('SMS', '📱'),
    ('Physical (printed) invitations', '📮'),
    ("We haven't decided yet", '🤔'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return _StepScaffold(
      title: "How will you send invitations?",
      subtitle: "Select all the channels you plan to use.",
      canContinue: data.invitationChannels.isNotEmpty,
      child: Column(
        children: _options.map((opt) {
          final (label, emoji) = opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectionCard(
              label: label,
              emoji: emoji,
              isSelected: data.invitationChannels.contains(label),
              onTap: () => notifier.toggleInvitationChannel(label),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 12: Wedding vibes ───────────────────────────────────────────────

class _WeddingVibesStep extends ConsumerWidget {
  const _WeddingVibesStep();

  static const _options = [
    ('Garden / Outdoor', '🌿'),
    ('Beach / Coastal', '🌊'),
    ('Rustic / Barn', '🌾'),
    ('Modern / Minimalist', '🖤'),
    ('Luxury / Black tie', '👑'),
    ('Cultural / Traditional', '🪔'),
    ('Boho / Eclectic', '🌸'),
    ('Destination', '✈️'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return _StepScaffold(
      title: "What's your wedding vibe?",
      subtitle: "Pick everything that resonates. This shapes your Gallery inspiration and aesthetic.",
      canContinue: data.weddingVibes.isNotEmpty,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _options.map((opt) {
          final (label, emoji) = opt;
          final isSelected = data.weddingVibes.contains(label);
          return GestureDetector(
            onTap: () => notifier.toggleWeddingVibe(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.selectionFill : AppColors.white,
                borderRadius: AppSpacing.borderFull,
                border: Border.all(
                  color: isSelected ? AppColors.selectionBorder : AppColors.grey200,
                  width: isSelected ? 1.8 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.dustyRose : AppColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 13: All set ─────────────────────────────────────────────────────

class _AllSetStep extends ConsumerWidget {
  const _AllSetStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(onboardingNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 20),
          Text(
            data.partnerOneName != null && data.partnerTwoName != null
                ? "${data.partnerOneName} & ${data.partnerTwoName}"
                : "You're all set!",
            style: AppTypography.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Your wedding space is ready. Let's start planning the most important day of your life.",
            style: AppTypography.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          PrimaryButton(
            label: 'Take me to my wedding',
            onPressed: () {/* TODO: submit onboarding → API, then navigate to Home */},
          ),
        ],
      ),
    );
  }
}
