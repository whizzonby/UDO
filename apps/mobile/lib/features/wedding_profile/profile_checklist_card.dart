import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/udo_design_system.dart';
import 'profile_section_screen.dart';
import 'profile_sections.dart';

/// "Complete your wedding profile" — the optional questions that used to be a
/// mandatory 24-screen onboarding. Collapsed by default to the single next
/// section; expands to the full checklist. Disappears once everything is done.
class ProfileChecklistCard extends ConsumerStatefulWidget {
  const ProfileChecklistCard({super.key});

  @override
  ConsumerState<ProfileChecklistCard> createState() =>
      _ProfileChecklistCardState();
}

class _ProfileChecklistCardState extends ConsumerState<ProfileChecklistCard> {
  bool _expanded = false;

  void _open(ProfileSection section) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProfileSectionScreen(section: section)));
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(profileProgressProvider);
    if (!progress.loaded || progress.complete) return const SizedBox.shrink();

    final total = kProfileSections.length;
    final next =
        kProfileSections.firstWhere((s) => !progress.done.contains(s.id));

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: UdoCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Complete your wedding profile',
                        style: UdoDesign.serif(size: 20)),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      color: UdoDesign.muted),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${progress.doneCount} of $total done · helps Udo tailor your plan',
              style: UdoDesign.sans(size: 13, color: UdoDesign.sub),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: progress.doneCount / total,
                minHeight: 4,
                backgroundColor: UdoDesign.border,
                valueColor: const AlwaysStoppedAnimation<Color>(UdoDesign.plan),
              ),
            ),
            const SizedBox(height: 14),
            if (!_expanded)
              _SectionRow(
                section: next,
                done: false,
                highlighted: true,
                onTap: () => _open(next),
              )
            else
              for (final s in kProfileSections)
                _SectionRow(
                  section: s,
                  done: progress.done.contains(s.id),
                  highlighted: false,
                  onTap: () => _open(s),
                ),
          ],
        ),
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  final ProfileSection section;
  final bool done;
  final bool highlighted;
  final VoidCallback onTap;

  const _SectionRow({
    required this.section,
    required this.done,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(done ? Icons.check_circle : section.icon,
                color: done ? UdoDesign.sage : UdoDesign.plan, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    highlighted ? 'Next: ${section.title}' : section.title,
                    style: UdoDesign.sans(size: 14, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${section.subtitle} · ${section.minutes} min',
                    style: UdoDesign.sans(size: 12, color: UdoDesign.sub),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: UdoDesign.muted),
          ],
        ),
      ),
    );
  }
}
