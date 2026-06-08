import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/home_stats_model.dart';

class UdoGuidanceCarousel extends StatefulWidget {
  const UdoGuidanceCarousel({super.key, required this.prompts});
  final List<GuidancePrompt> prompts;

  @override
  State<UdoGuidanceCarousel> createState() => _UdoGuidanceCarouselState();
}

class _UdoGuidanceCarouselState extends State<UdoGuidanceCarousel> {
  final PageController _ctrl = PageController(viewportFraction: 0.92);
  int _current = 0;

  static final _fallback = [
    const GuidancePrompt(
      id: '1',
      question: 'What does your dream morning-of feel like?',
      context: 'Setting the tone for the day before it begins.',
      category: 'Mindset',
    ),
    const GuidancePrompt(
      id: '2',
      question: 'Have you talked to your vendors about your vision recently?',
      context: 'A quick check-in can prevent day-of surprises.',
      category: 'Vendors',
    ),
    const GuidancePrompt(
      id: '3',
      question: 'Which guests might need extra care or consideration?',
      context: 'Guests who travel far or have accessibility needs.',
      category: 'Guests',
    ),
    const GuidancePrompt(
      id: '4',
      question: 'Is there a moment you want to protect from the schedule?',
      context: 'A quiet first look, a family photo, a shared breath.',
      category: 'Moments',
    ),
    const GuidancePrompt(
      id: '5',
      question: 'What would make you feel most prepared right now?',
      context: 'Focus on the one thing that would bring the most calm.',
      category: 'Mindset',
    ),
  ];

  List<GuidancePrompt> get _prompts =>
      widget.prompts.isNotEmpty ? widget.prompts : _fallback;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 14, color: AppColors.hotPink),
              const SizedBox(width: 6),
              Text(
                'UDO GUIDANCE',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey500,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Text(
            'Thoughtful questions worth considering',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.grey500,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: _prompts.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _GuidanceCard(prompt: _prompts[i]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _prompts.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _current ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _current
                    ? AppColors.hotPink
                    : AppColors.grey300,
                borderRadius: AppSpacing.borderFull,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({required this.prompt});
  final GuidancePrompt prompt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blushLight,
        borderRadius: AppSpacing.borderXl,
        border: Border.all(
          color: AppColors.hotPink.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prompt.category != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.hotPink.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderFull,
              ),
              child: Text(
                prompt.category!,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.hotPink,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          Expanded(
            child: Text(
              prompt.question,
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
                height: 1.35,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (prompt.context != null) ...[
            const SizedBox(height: 6),
            Text(
              prompt.context!,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.grey500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
