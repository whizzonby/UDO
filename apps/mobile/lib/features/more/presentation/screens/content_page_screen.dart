import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/udo_design_system.dart';
import '../providers/about_provider.dart';

const _aboutAccent = Color(0xFF4B4D52);

class ContentPageScreen extends ConsumerWidget {
  final String slug;
  final String title;

  const ContentPageScreen({super.key, required this.slug, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(contentPageProvider(slug));

    return Scaffold(
      backgroundColor: UdoDesign.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(title, style: UdoDesign.sans(size: 16, weight: FontWeight.w700)),
      ),
      body: pageAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _aboutAccent)),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: UdoDesign.muted, size: 32),
                const SizedBox(height: 12),
                Text('This page isn\'t available right now.',
                    textAlign: TextAlign.center,
                    style: UdoDesign.sans(size: 14, color: UdoDesign.sub)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.invalidate(contentPageProvider(slug)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (page) {
          final body = (page['body'] as String? ?? '').trim();
          final paragraphs = body.split(RegExp(r'\n\s*\n'));
          final updatedAt = page['updated_at'] as String?;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(page['title'] as String? ?? title, style: UdoDesign.serif(size: 26)),
                if (updatedAt != null) ...[
                  const SizedBox(height: 6),
                  Text('Last updated ${_formatDate(updatedAt)}',
                      style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
                ],
                const SizedBox(height: 20),
                for (final paragraph in paragraphs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(paragraph.trim(),
                        style: UdoDesign.sans(size: 14, color: UdoDesign.sub, height: 1.5)),
                  ),
              ],
            ),
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
