import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/udo_design_system.dart';
import '../providers/about_provider.dart';

const _aboutAccent = Color(0xFF4B4D52);

class ReleaseNotesScreen extends ConsumerWidget {
  final bool latestOnly;

  const ReleaseNotesScreen({super.key, this.latestOnly = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(releaseNotesProvider);

    return Scaffold(
      backgroundColor: UdoDesign.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(latestOnly ? 'What\'s New' : 'Version History',
            style: UdoDesign.sans(size: 16, weight: FontWeight.w700)),
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _aboutAccent)),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: UdoDesign.muted, size: 32),
                const SizedBox(height: 12),
                Text('Couldn\'t load release notes.',
                    textAlign: TextAlign.center,
                    style: UdoDesign.sans(size: 14, color: UdoDesign.sub)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.invalidate(releaseNotesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (notes) {
          final shown = latestOnly && notes.isNotEmpty ? [notes.first] : notes;
          if (shown.isEmpty) {
            return Center(
              child: Text('No release notes yet.',
                  style: UdoDesign.sans(size: 14, color: UdoDesign.muted)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            itemCount: shown.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final note = shown[index];
              final body = (note['body'] as String? ?? '').trim();
              final paragraphs = body.split(RegExp(r'\n\s*\n'));

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: UdoDesign.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: UdoDesign.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _aboutAccent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('v${note['version']}',
                              style: UdoDesign.sans(
                                  size: 12, weight: FontWeight.w700, color: _aboutAccent)),
                        ),
                        const SizedBox(width: 8),
                        if (note['released_at'] != null)
                          Text(_formatDate(note['released_at'] as String),
                              style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(note['title'] as String? ?? '',
                        style: UdoDesign.sans(size: 15, weight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    for (final paragraph in paragraphs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(paragraph.trim(),
                            style: UdoDesign.sans(size: 13, color: UdoDesign.sub, height: 1.5)),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String _formatDate(String iso) {
  final date = DateTime.tryParse(iso);
  if (date == null) return iso;
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
