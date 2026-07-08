import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';

final _visionTimelineProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.read(apiClientProvider);
  try {
    final res = await client.get('/plan/timeline') as Map<String, dynamic>;
    final items = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
    items.sort((a, b) => (a['start_time'] ?? '').compareTo(b['start_time'] ?? ''));
    return items;
  } catch (_) {
    return [];
  }
});

class YourVisionScreen extends ConsumerStatefulWidget {
  const YourVisionScreen({super.key});
  @override
  ConsumerState<YourVisionScreen> createState() => _YourVisionScreenState();
}

class _YourVisionScreenState extends ConsumerState<YourVisionScreen> {
  bool _showDownloadModal = false;

  String _formatTime(String? t) {
    if (t == null || t.isEmpty) return '';
    final parts = t.split(':');
    if (parts.length < 2) return t;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final suffix = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:${m.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(_visionTimelineProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeader(context),
              _buildTimelineBar(timelineAsync),
              _buildSimulationSection(timelineAsync),
              _buildFooterCTA(context),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
          if (_showDownloadModal) _DownloadModal(onClose: () => setState(() => _showDownloadModal = false)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHeader(BuildContext context) => SliverToBoxAdapter(
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.udoLightBlush.withValues(alpha: 0.5), Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        border: const Border(bottom: BorderSide(color: Color(0xFFF0EBEB))),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const BackButton(color: AppTheme.udoTextPrimary),
              const Spacer(),
            ]),
            const SizedBox(height: 4),
            const Center(child: Text('YOUR DAY PLAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: AppTheme.udoTextSecondary))),
            const SizedBox(height: 12),
            const Center(
              child: Text('What your day looks like', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Playfair', fontSize: 30, fontWeight: FontWeight.w400, height: 1.25, color: AppTheme.udoTextPrimary)),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'A view of your wedding day from start to finish — every event and moment you have planned.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.udoTextSecondary, height: 1.6),
              ),
            ),
          ]),
        ),
      ),
    ),
  );

  SliverToBoxAdapter _buildTimelineBar(AsyncValue<List<Map<String, dynamic>>> timelineAsync) => SliverToBoxAdapter(
    child: Container(
      color: AppTheme.udoBackground,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: timelineAsync.when(
        loading: () => const SizedBox(height: 56, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        error: (_, __) => const SizedBox.shrink(),
        data: (items) {
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Add events in the Plan section to see your timeline here.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            );
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: items.map((item) {
              final title = item['title'] as String? ?? '';
              final time = _formatTime(item['start_time'] as String?);
              return Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.udoBorder)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppTheme.udoTextSecondary)),
                  const SizedBox(height: 4),
                  Text(time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.udoTextPrimary)),
                ]),
              );
            }).toList()),
          );
        },
      ),
    ),
  );

  SliverToBoxAdapter _buildSimulationSection(AsyncValue<List<Map<String, dynamic>>> timelineAsync) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: timelineAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) => const SizedBox.shrink(),
        data: (items) {
          if (items.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppTheme.udoBackground, borderRadius: BorderRadius.circular(16)),
              child: const Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.calendar_today_outlined, size: 48, color: AppTheme.udoTextSecondary),
                SizedBox(height: 16),
                Text('No events planned yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text(
                  'Add events to your timeline in the Plan section and they will appear here as your day simulation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.5),
                ),
              ]),
            );
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('TIMELINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: AppTheme.udoTextSecondary)),
            const SizedBox(height: 24),
            ...items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final isLast = i == items.length - 1;
              final time = _formatTime(item['start_time'] as String?);
              final title = item['title'] as String? ?? '';
              final desc = item['description'] as String? ?? item['location'] as String? ?? '';
              final tag = (item['event_type'] as String? ?? 'Event').toUpperCase();
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Column(children: [
                  Container(width: 10, height: 10, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: AppTheme.udoGreen, shape: BoxShape.circle)),
                  if (!isLast) Container(width: 1, height: 80, color: const Color(0xFFE5E7EB)),
                ]),
                const SizedBox(width: 16),
                Expanded(child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.udoCrimson)),
                    const SizedBox(height: 4),
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3)),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(desc, style: const TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.65)),
                    ],
                    const SizedBox(height: 8),
                    Text(tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.udoGreen, letterSpacing: 0.3)),
                  ]),
                )),
              ]);
            }),
          ]);
        },
      ),
    ),
  );

  SliverToBoxAdapter _buildFooterCTA(BuildContext context) => SliverToBoxAdapter(
    child: Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Color(0xFFFFF0F3)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(children: [
        const Text('Your wedding, your way', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Playfair', fontSize: 26, fontWeight: FontWeight.w400)),
        const SizedBox(height: 12),
        const Text(
          'Keep adding events and details to your plan and watch your wedding day come to life here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppTheme.udoTextSecondary, height: 1.65),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PDF export coming soon')),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            backgroundColor: AppTheme.udoCrimson,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Download day plan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ),
      ]),
    ),
  );
}

// ── DOWNLOAD MODAL ─────────────────────────────────────────────────────────────

class _DownloadModal extends StatelessWidget {
  final VoidCallback onClose;
  const _DownloadModal({required this.onClose});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onClose,
    child: Container(
      color: Colors.black54,
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(child: Text('Download day plan', style: TextStyle(fontFamily: 'Playfair', fontSize: 22, fontWeight: FontWeight.w500))),
                GestureDetector(onTap: onClose, child: const Icon(Icons.close, color: Color(0xFF9CA3AF))),
              ]),
              const SizedBox(height: 12),
              const Text(
                'PDF export is coming soon. Your complete day plan will be available to download and share with your planning team.',
                style: TextStyle(fontSize: 14, color: AppTheme.udoTextSecondary, height: 1.6),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoCrimson, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ]),
          ),
        ),
      ),
    ),
  );
}
