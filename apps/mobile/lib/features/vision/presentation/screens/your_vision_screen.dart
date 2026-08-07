import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/udo_design_system.dart';

const _visionAccent = Color(0xFFC9867A);

final _visionTimelineProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get('/plan/timeline') as Map<String, dynamic>;
  final items = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
  items
      .sort((a, b) => (a['start_time'] ?? '').compareTo(b['start_time'] ?? ''));
  return items;
});

class YourVisionScreen extends ConsumerStatefulWidget {
  const YourVisionScreen({super.key});

  @override
  ConsumerState<YourVisionScreen> createState() => _YourVisionScreenState();
}

class _YourVisionScreenState extends ConsumerState<YourVisionScreen> {
  bool _generatingPdf = false;

  String _formatTime(String? value) {
    if (value == null || value.isEmpty) return '';
    final parts = value.split(':');
    if (parts.length < 2) return value;
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
      backgroundColor: UdoDesign.bg,
      body: RefreshIndicator(
        color: _visionAccent,
        onRefresh: () => ref.refresh(_visionTimelineProvider.future),
        child: timelineAsync.when(
          loading: () => const _VisionLoading(),
          error: (error, _) => _VisionError(
            message: error.toString(),
            onRetry: () => ref.invalidate(_visionTimelineProvider),
          ),
          data: (items) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              const _VisionTopBar(),
              const SizedBox(height: 24),
              _VisionHero(items: items, formatTime: _formatTime),
              const SizedBox(height: 20),
              _TimelineSummary(items: items, formatTime: _formatTime),
              const SizedBox(height: 22),
              _DaySimulation(items: items, formatTime: _formatTime),
              const SizedBox(height: 26),
              _VisionExportCard(
                generating: _generatingPdf,
                onDownload: () => _downloadDayPlan(context, items),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadDayPlan(
      BuildContext context, List<Map<String, dynamic>> items) async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Add events to your timeline first; nothing to export yet.')),
      );
      return;
    }
    setState(() => _generatingPdf = true);
    try {
      final doc = pw.Document();
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) => [
            pw.Header(level: 0, text: 'Your Wedding Day Plan'),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: const {0: pw.FixedColumnWidth(70)},
              children: [
                pw.TableRow(children: [
                  _pdfCell('Time', bold: true),
                  _pdfCell('Event', bold: true),
                ]),
                for (final item in items)
                  pw.TableRow(children: [
                    _pdfCell(_formatTime(item['start_time'] as String?)),
                    _pdfCell([
                      item['title'] as String? ?? '',
                      if ((item['description'] as String?)?.isNotEmpty == true)
                        item['description'] as String,
                      if ((item['location'] as String?)?.isNotEmpty == true)
                        'Location: ${item['location']}',
                    ].join('\n')),
                  ]),
              ],
            ),
          ],
        ),
      );
      await Printing.layoutPdf(
          onLayout: (_) => doc.save(), name: 'Wedding-Day-Plan.pdf');
    } catch (_) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Couldn't generate the PDF. Try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  pw.Widget _pdfCell(String text, {bool bold = false}) => pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(text,
            style: pw.TextStyle(
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                fontSize: 10)),
      );
}

class _VisionTopBar extends StatelessWidget {
  const _VisionTopBar();

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
      const UdoBadge(label: 'Day plan', color: _visionAccent),
    ]);
  }
}

class _VisionHero extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String Function(String?) formatTime;

  const _VisionHero({required this.items, required this.formatTime});

  @override
  Widget build(BuildContext context) {
    final first = items.isEmpty ? null : items.first;
    final last = items.isEmpty ? null : items.last;

    return UdoCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your day, rehearsed before it happens',
            style: UdoDesign.serif(size: 39, height: 1.02)),
        const SizedBox(height: 10),
        Text(
          'A clean run-through of your wedding day from the first setup call to the last planned moment.',
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
              child: _HeroMetric(
                  value: '${items.length}',
                  label: items.length == 1 ? 'event' : 'events'),
            ),
            Container(width: 1, height: 42, color: UdoDesign.border),
            Expanded(
              child: _HeroMetric(
                value: first == null
                    ? '--'
                    : formatTime(first['start_time'] as String?),
                label: 'first call',
              ),
            ),
            Container(width: 1, height: 42, color: UdoDesign.border),
            Expanded(
              child: _HeroMetric(
                value: last == null
                    ? '--'
                    : formatTime(last['start_time'] as String?),
                label: 'last moment',
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String value;
  final String label;
  const _HeroMetric({required this.value, required this.label});

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

class _TimelineSummary extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String Function(String?) formatTime;

  const _TimelineSummary({required this.items, required this.formatTime});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return UdoCard(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined,
              color: UdoDesign.muted, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add events in Plan to preview your wedding day here.',
              style: UdoDesign.sans(size: 13, color: UdoDesign.sub),
            ),
          ),
        ]),
      );
    }

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 148,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: UdoDesign.border),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(formatTime(item['start_time'] as String?),
                  style: UdoDesign.sans(
                      size: 13, weight: FontWeight.w800, color: _visionAccent)),
              const SizedBox(height: 7),
              Text(item['title']?.toString() ?? 'Timeline event',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: UdoDesign.sans(size: 12, weight: FontWeight.w700)),
            ]),
          );
        },
      ),
    );
  }
}

class _DaySimulation extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final String Function(String?) formatTime;

  const _DaySimulation({required this.items, required this.formatTime});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      UdoSectionHeader(
        title: 'Run of day',
        subtitle: items.isEmpty
            ? 'Your simulation will appear after timeline events are added.'
            : 'Every planned event in the order the day unfolds.',
      ),
      if (items.isEmpty)
        const _EmptyVisionCard()
      else
        UdoCard(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 2),
          child: Column(children: [
            for (var index = 0; index < items.length; index++)
              _TimelineEventRow(
                item: items[index],
                isLast: index == items.length - 1,
                formatTime: formatTime,
              ),
          ]),
        ),
    ]);
  }
}

class _TimelineEventRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isLast;
  final String Function(String?) formatTime;

  const _TimelineEventRow({
    required this.item,
    required this.isLast,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final desc = item['description']?.toString();
    final location = item['location']?.toString();
    final tag = (item['event_type']?.toString() ?? 'Event').toUpperCase();

    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 13,
            height: 13,
            margin: const EdgeInsets.only(top: 3),
            decoration: const BoxDecoration(
                color: _visionAccent, shape: BoxShape.circle),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 1,
                margin: const EdgeInsets.symmetric(vertical: 6),
                color: UdoDesign.border,
              ),
            ),
        ]),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(formatTime(item['start_time'] as String?),
                  style: UdoDesign.sans(
                      size: 13, weight: FontWeight.w800, color: _visionAccent)),
              const SizedBox(height: 5),
              Text(item['title']?.toString() ?? 'Timeline event',
                  style: UdoDesign.serif(size: 25, height: 1.05)),
              if (desc != null && desc.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(desc,
                    style: UdoDesign.sans(
                        size: 13, color: UdoDesign.sub, height: 1.5)),
              ],
              if (location != null && location.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.place_outlined,
                      size: 15, color: UdoDesign.muted),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(location,
                        style:
                            UdoDesign.sans(size: 12, color: UdoDesign.muted)),
                  ),
                ]),
              ],
              const SizedBox(height: 10),
              UdoBadge(label: tag, color: _visionAccent),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _EmptyVisionCard extends StatelessWidget {
  const _EmptyVisionCard();

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const Icon(Icons.calendar_today_outlined,
            size: 42, color: UdoDesign.muted),
        const SizedBox(height: 14),
        Text('No events planned yet',
            textAlign: TextAlign.center,
            style: UdoDesign.sans(size: 16, weight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          'Add events to your timeline in Plan and they will appear here as a readable day simulation.',
          textAlign: TextAlign.center,
          style: UdoDesign.sans(size: 13, color: UdoDesign.muted, height: 1.45),
        ),
      ]),
    );
  }
}

class _VisionExportCard extends StatelessWidget {
  final bool generating;
  final VoidCallback onDownload;

  const _VisionExportCard({required this.generating, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return UdoCard(
      padding: const EdgeInsets.all(18),
      color: Colors.white,
      child: Column(children: [
        Text('Carry the plan offline',
            textAlign: TextAlign.center, style: UdoDesign.serif(size: 30)),
        const SizedBox(height: 8),
        Text(
          'Download a clean PDF for planners, family and anyone who needs the run of day.',
          textAlign: TextAlign.center,
          style: UdoDesign.sans(size: 13, color: UdoDesign.muted, height: 1.45),
        ),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: generating ? null : onDownload,
          icon: generating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.download_outlined, size: 18),
          label: Text(generating ? 'Preparing PDF' : 'Download day plan'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            backgroundColor: _visionAccent,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
      ]),
    );
  }
}

class _VisionLoading extends StatelessWidget {
  const _VisionLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: _visionAccent, strokeWidth: 2),
    );
  }
}

class _VisionError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _VisionError({required this.message, required this.onRetry});

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
            Text("Couldn't load your day plan",
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
