import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/udo_design_system.dart';
import '../providers/wedding_story_provider.dart';

const _storyAccent = Color(0xFF8A9E8A);

const _phaseIcons = {
  'engagement_planning': Icons.favorite_border,
  'wedding_week': Icons.event_note_outlined,
  'wedding_day': Icons.celebration_outlined,
  'honeymoon': Icons.flight_takeoff_outlined,
  'happily_ever_after': Icons.auto_awesome_outlined,
};

class WeddingStoryScreen extends ConsumerWidget {
  const WeddingStoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weddingStoryProvider);

    return Scaffold(
      backgroundColor: UdoDesign.bg,
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: _storyAccent, strokeWidth: 2))
          : state.error != null && state.phases.isEmpty
              ? _StoryError(
                  message: state.error!,
                  onRetry: () =>
                      ref.read(weddingStoryProvider.notifier).refresh(),
                )
              : RefreshIndicator(
                  color: _storyAccent,
                  onRefresh: () =>
                      ref.read(weddingStoryProvider.notifier).refresh(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    children: [
                      const _StoryTopBar(),
                      const SizedBox(height: 24),
                      _StoryHero(state: state),
                      const SizedBox(height: 24),
                      if (!state.hasEventDate)
                        const _StoryDateEmpty()
                      else ...[
                        const UdoSectionHeader(
                          title: 'Chapters',
                          subtitle:
                              'Built from the details already saved across your wedding.',
                        ),
                        for (var index = 0;
                            index < state.phases.length;
                            index++)
                          _PhaseCard(
                            phase: state.phases[index],
                            isLast: index == state.phases.length - 1,
                          ),
                        const SizedBox(height: 8),
                        _MemoriesSection(memories: state.memories),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class _StoryTopBar extends StatelessWidget {
  const _StoryTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.maybePop(context),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: UdoDesign.text,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: UdoDesign.border),
          ),
        ),
        icon: const Icon(Icons.arrow_back),
      ),
      const Spacer(),
      const UdoBadge(label: 'Wedding Story', color: _storyAccent),
    ]);
  }
}

class _StoryHero extends StatelessWidget {
  final WeddingStoryState state;
  const _StoryHero({required this.state});

  @override
  Widget build(BuildContext context) {
    final completeChapters =
        state.phases.where((phase) => phase['stats'] is Map).length;
    final totalChapters = state.phases.isEmpty ? 5 : state.phases.length;

    return UdoCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your wedding, becoming a story',
            style: UdoDesign.serif(size: 40, height: 1.02)),
        const SizedBox(height: 10),
        Text(
          'From engagement decisions to guest memories, Udo turns the working plan into a living keepsake.',
          style: UdoDesign.sans(size: 14, color: UdoDesign.sub, height: 1.45),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: UdoDesign.bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: UdoDesign.border),
          ),
          child: Row(children: [
            Expanded(
              child: _StoryMetric(
                  value: '$completeChapters/$totalChapters',
                  label: 'chapters active'),
            ),
            Container(width: 1, height: 42, color: UdoDesign.border),
            Expanded(
              child: _StoryMetric(
                  value: state.hasEventDate ? 'Set' : 'Missing',
                  label: 'wedding date'),
            ),
            Container(width: 1, height: 42, color: UdoDesign.border),
            Expanded(
              child: _StoryMetric(
                  value: _memoryCount(state.memories).toString(),
                  label: 'memory signals'),
            ),
          ]),
        ),
      ]),
    );
  }

  int _memoryCount(Map<String, dynamic> memories) {
    final speeches = (memories['speeches_confirmed'] as List?)?.length ?? 0;
    final vows = (memories['vows'] as List?)?.length ?? 0;
    final traditions = (memories['traditions'] as List?)?.length ?? 0;
    final music = memories['has_music_moments'] == true ? 1 : 0;
    return speeches + vows + traditions + music;
  }
}

class _StoryMetric extends StatelessWidget {
  final String value;
  final String label;
  const _StoryMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: UdoDesign.sans(size: 14, weight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: UdoDesign.sans(size: 10, color: UdoDesign.muted)),
    ]);
  }
}

class _StoryDateEmpty extends StatelessWidget {
  const _StoryDateEmpty();

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const Icon(Icons.auto_stories_outlined,
            size: 44, color: UdoDesign.muted),
        const SizedBox(height: 14),
        Text('Set your wedding date to start the story',
            textAlign: TextAlign.center,
            style: UdoDesign.sans(size: 16, weight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          'Wedding Story is built from real dates across your planning. Add the date in Wedding Settings to unlock the chapters.',
          textAlign: TextAlign.center,
          style: UdoDesign.sans(size: 13, color: UdoDesign.muted, height: 1.45),
        ),
      ]),
    );
  }
}

class _StoryError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _StoryError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        UdoCard(
          padding: const EdgeInsets.all(22),
          child: Column(children: [
            const Icon(Icons.error_outline,
                size: 42, color: AppTheme.udoCrimson),
            const SizedBox(height: 14),
            Text("Couldn't load your Wedding Story",
                style: UdoDesign.sans(size: 16, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: UdoDesign.sans(
                    size: 12, color: UdoDesign.muted, height: 1.4)),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.udoCrimson,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ]),
        ),
      ],
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final Map<String, dynamic> phase;
  final bool isLast;
  const _PhaseCard({required this.phase, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final key = phase['key'] as String;
    final stats = phase['stats'] as Map<String, dynamic>?;

    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: _storyAccent.withValues(alpha: 0.14),
                shape: BoxShape.circle),
            child: Icon(_phaseIcons[key] ?? Icons.circle,
                color: _storyAccent, size: 19),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 1,
                color: UdoDesign.border,
                margin: const EdgeInsets.symmetric(vertical: 5),
              ),
            ),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: UdoCard(
              padding: const EdgeInsets.all(16),
              radius: 22,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(phase['title'] as String,
                        style: UdoDesign.serif(size: 26, height: 1.05)),
                    const SizedBox(height: 10),
                    if (stats == null)
                      _notYetText(key)
                    else
                      _statsFor(context, key, stats),
                  ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _notYetText(String key) => Text(
        key == 'honeymoon'
            ? 'No honeymoon trip planned yet.'
            : "This chapter hasn't started yet.",
        style: UdoDesign.sans(size: 12, color: UdoDesign.muted, height: 1.4)
            .copyWith(fontStyle: FontStyle.italic),
      );

  Widget _statsFor(
      BuildContext context, String key, Map<String, dynamic> stats) {
    switch (key) {
      case 'engagement_planning':
        return _chips([
          _stat('${stats['tasks_completed']}', 'tasks done'),
          _stat('${stats['vendors_booked']}', 'vendors booked'),
          _stat('${stats['invitations_sent']}', 'invitations sent'),
          _stat('${stats['inspiration_saved']}', 'inspiration saved'),
        ]);
      case 'wedding_week':
        final rate = stats['rsvp_completion_rate'];
        return _chips([
          if (rate != null) _stat('$rate%', 'RSVP completion'),
          _stat('${stats['attending_guests']}', 'attending'),
          _stat('${stats['guests_seated']}', 'seated'),
        ]);
      case 'wedding_day':
        final items = (stats['timeline_items'] as List?) ?? [];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _chips([
            _stat('${stats['photos']}', 'photos'),
            _stat('${stats['videos']}', 'videos'),
            _stat('${stats['voice_notes']}', 'voice notes'),
            _stat('${stats['guestbook_messages']}', 'guestbook messages'),
          ]),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final item in items.cast<Map<String, dynamic>>())
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(children: [
                  const Icon(Icons.circle, size: 5, color: UdoDesign.muted),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(item['title']?.toString() ?? 'Timeline event',
                        style: UdoDesign.sans(
                            size: 12, color: UdoDesign.muted, height: 1.35)),
                  ),
                ]),
              ),
          ],
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => context.go('/gallery'),
            icon: const Icon(Icons.photo_library_outlined, size: 16),
            label: const Text('View in Gallery'),
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          ),
        ]);
      case 'honeymoon':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if ((stats['destination'] as String?)?.isNotEmpty == true)
            Text(stats['destination'] as String,
                style: UdoDesign.sans(size: 14, weight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(
            [stats['departure_date'], stats['return_date']]
                .where((value) => value != null)
                .join(' - '),
            style: UdoDesign.sans(size: 12, color: UdoDesign.muted),
          ),
        ]);
      case 'happily_ever_after':
        return _chips([
          _stat('${stats['days_married']}', 'days married'),
          _stat('${stats['photos_since']}', 'photos since'),
          _stat('${stats['videos_since']}', 'videos since'),
          _stat('${stats['guestbook_messages_since']}', 'new messages'),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _stat(String value, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: UdoDesign.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: UdoDesign.border),
        ),
        child: Text('$value $label',
            style: UdoDesign.sans(size: 11, color: UdoDesign.text)),
      );

  Widget _chips(List<Widget> chips) =>
      Wrap(spacing: 7, runSpacing: 7, children: chips);
}

class _MemoriesSection extends StatelessWidget {
  final Map<String, dynamic> memories;
  const _MemoriesSection({required this.memories});

  @override
  Widget build(BuildContext context) {
    final speeches = (memories['speeches_confirmed'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final vows =
        (memories['vows'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final traditions = (memories['traditions'] as List?)?.cast<dynamic>() ?? [];
    final hasMusic = memories['has_music_moments'] == true;

    if (speeches.isEmpty && vows.isEmpty && traditions.isEmpty && !hasMusic) {
      return const SizedBox.shrink();
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const UdoSectionHeader(
        title: 'Memory signals',
        subtitle:
            'Speeches, vows, traditions and guest keepsakes already saved.',
      ),
      UdoCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (speeches.isNotEmpty)
            _MemoryLine(
              icon: Icons.record_voice_over_outlined,
              text:
                  '${speeches.length} speech${speeches.length == 1 ? '' : 'es'} confirmed: ${speeches.map((speech) => speech['speaker_name']).join(', ')}',
            ),
          if (vows.isNotEmpty)
            for (final vow in vows)
              _MemoryLine(
                icon: vow['viewed'] == true
                    ? Icons.check_circle_outline
                    : Icons.circle_outlined,
                text:
                    '${vow['title']}${vow['is_private'] == true ? ' (private)' : ''}',
              ),
          if (traditions.isNotEmpty)
            _MemoryLine(
              icon: Icons.diversity_1_outlined,
              text: 'Traditions: ${traditions.join(', ')}',
            ),
          if (hasMusic)
            const _MemoryLine(
              icon: Icons.music_note_outlined,
              text: 'Music moments planned',
            ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => context.push('/memories'),
            icon: const Icon(Icons.collections_bookmark_outlined, size: 16),
            label: const Text('View in Memories'),
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          ),
        ]),
      ),
    ]);
  }
}

class _MemoryLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MemoryLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: _storyAccent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style:
                  UdoDesign.sans(size: 12, color: UdoDesign.sub, height: 1.4)),
        ),
      ]),
    );
  }
}
