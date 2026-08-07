import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../gallery/presentation/providers/gallery_provider.dart';
import '../providers/vision_style_provider.dart';

const _kPresetPalettes = [
  {'name': 'Tropical Garden', 'colors': [
    {'hex': '#1F5B00', 'label': 'Forest Green'},
    {'hex': '#F5F2EC', 'label': 'Cream'},
    {'hex': '#F43893', 'label': 'Hibiscus'},
  ]},
  {'name': 'Sunset Grove', 'colors': [
    {'hex': '#F4A261', 'label': 'Amber'},
    {'hex': '#E76F51', 'label': 'Terracotta'},
    {'hex': '#2A9D8F', 'label': 'Teal'},
  ]},
  {'name': 'Classic Ivory', 'colors': [
    {'hex': '#FDFBF7', 'label': 'Ivory'},
    {'hex': '#C9A66B', 'label': 'Gold'},
    {'hex': '#4A4A4A', 'label': 'Charcoal'},
  ]},
  {'name': 'Modern Blush', 'colors': [
    {'hex': '#F8EDEB', 'label': 'Blush'},
    {'hex': '#D45D78', 'label': 'Rose'},
    {'hex': '#F194B2', 'label': 'Pink'},
  ]},
  {'name': 'Modern Sage', 'colors': [
    {'hex': '#87986A', 'label': 'Sage'},
    {'hex': '#F5F5DC', 'label': 'Cream'},
    {'hex': '#6B4226', 'label': 'Walnut'},
  ]},
  {'name': 'Navy & Gold', 'colors': [
    {'hex': '#1B263B', 'label': 'Navy'},
    {'hex': '#D4AF37', 'label': 'Gold'},
    {'hex': '#FFFFFF', 'label': 'White'},
  ]},
];

const _kInspirationCategories = [
  'flowers', 'cake', 'tables', 'ceremony', 'dresses', 'suits',
  'lighting', 'stationery', 'photography', 'hair', 'makeup',
];

String _resolveUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  return url.startsWith('http') ? url : '${AppConstants.apiOrigin}$url';
}

String _humanizeCategory(String value) => value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

Color _colorFromHex(String hex) {
  final cleaned = hex.replaceAll('#', '');
  return Color(int.parse('FF$cleaned', radix: 16));
}

String _hexFromColor(Color color) => '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

class VisionStyleScreen extends ConsumerStatefulWidget {
  const VisionStyleScreen({super.key});
  @override
  ConsumerState<VisionStyleScreen> createState() => _VisionStyleScreenState();
}

class _VisionStyleScreenState extends ConsumerState<VisionStyleScreen> {
  final _themeCtrl = TextEditingController();
  final _moodCtrl = TextEditingController();
  final _mustHaveCtrl = TextEditingController();
  final _avoidCtrl = TextEditingController();
  final _paletteNameCtrl = TextEditingController();

  List<String> _moodWords = [];
  List<String> _mustHaves = [];
  List<String> _avoids = [];
  List<Map<String, String>> _paletteColors = [];
  int? _primaryIndex;
  int? _accentIndex;
  String? _categoryFilter;
  bool _seeded = false;
  bool _saving = false;
  bool _generatingBrief = false;

  @override
  void dispose() {
    _themeCtrl.dispose();
    _moodCtrl.dispose();
    _mustHaveCtrl.dispose();
    _avoidCtrl.dispose();
    _paletteNameCtrl.dispose();
    super.dispose();
  }

  void _seed(Map<String, dynamic>? visionStyle) {
    if (_seeded || visionStyle == null) return;
    _themeCtrl.text = visionStyle['theme']?.toString() ?? '';
    _moodWords = ((visionStyle['mood_words'] as List?) ?? []).map((e) => e.toString()).toList();
    _mustHaves = ((visionStyle['must_have_elements'] as List?) ?? []).map((e) => e.toString()).toList();
    _avoids = ((visionStyle['elements_to_avoid'] as List?) ?? []).map((e) => e.toString()).toList();
    final palette = visionStyle['color_palette'] as Map?;
    if (palette != null) {
      _paletteNameCtrl.text = palette['name']?.toString() ?? '';
      _paletteColors = ((palette['colors'] as List?) ?? []).map((c) => {
        'hex': (c as Map)['hex']?.toString() ?? '#000000',
        'label': c['label']?.toString() ?? '',
      }).toList();
      _primaryIndex = (palette['primary_index'] as num?)?.toInt();
      _accentIndex = (palette['accent_index'] as num?)?.toInt();
    }
    _seeded = true;
  }

  Map<String, dynamic> get _currentVisionStyle => {
    'theme': _themeCtrl.text.trim().isEmpty ? null : _themeCtrl.text.trim(),
    'mood_words': _moodWords,
    'must_have_elements': _mustHaves,
    'elements_to_avoid': _avoids,
    'color_palette': _paletteColors.isEmpty
        ? null
        : {
            'name': _paletteNameCtrl.text.trim().isEmpty ? null : _paletteNameCtrl.text.trim(),
            'colors': _paletteColors,
            'primary_index': _primaryIndex,
            'accent_index': _accentIndex,
          },
  };

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await ref.read(visionStyleProvider.notifier).save(_currentVisionStyle);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Vision & Style saved.' : "Couldn't save. Try again.")));
  }

  void _applyPreset(Map<String, dynamic> preset) {
    setState(() {
      _paletteNameCtrl.text = preset['name'] as String;
      _paletteColors = (preset['colors'] as List).map((c) => Map<String, String>.from(c as Map)).toList();
      _primaryIndex = 0;
      _accentIndex = _paletteColors.length > 1 ? 1 : null;
    });
  }

  Future<void> _pickCustomColor() async {
    Color picked = AppTheme.udoGreen;
    final labelCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add a colour'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ColorPicker(pickerColor: picked, onColorChanged: (c) => picked = c, enableAlpha: false),
            const SizedBox(height: 12),
            TextField(controller: labelCtrl, decoration: const InputDecoration(hintText: 'Colour name (optional)')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Add')),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      _paletteColors = [..._paletteColors, {'hex': _hexFromColor(picked), 'label': labelCtrl.text.trim()}];
      _primaryIndex ??= 0;
    });
  }

  Future<void> _uploadInspiration() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final notifier = ref.read(galleryProvider.notifier);
    final asset = await notifier.upload(file, 'inspiration');
    if (asset == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed. Try again.')));
      return;
    }
    if (_categoryFilter != null) {
      await notifier.setCategory(asset['id'] as int, _categoryFilter);
    }
  }

  Future<void> _generateStyleBrief(List<Map<String, dynamic>> images) async {
    setState(() => _generatingBrief = true);
    try {
      final dio = Dio();
      final imageWidgets = <pw.Widget>[];
      for (final asset in images.take(6)) {
        final url = _resolveUrl((asset['thumbnail_url'] ?? asset['url']) as String?);
        if (url.isEmpty) continue;
        try {
          final res = await dio.get<List<int>>(url, options: Options(responseType: ResponseType.bytes));
          if (res.data != null) {
            imageWidgets.add(pw.Container(
              width: 110, height: 110, margin: const pw.EdgeInsets.all(4),
              child: pw.Image(pw.MemoryImage(res.data! is Uint8List ? res.data! as Uint8List : Uint8List.fromList(res.data!)), fit: pw.BoxFit.cover),
            ));
          }
        } catch (_) {}
      }

      final vs = _currentVisionStyle;
      final palette = vs['color_palette'] as Map<String, dynamic>?;

      final doc = pw.Document();
      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => [
          pw.Header(level: 0, text: 'Wedding Style Brief'),
          if ((vs['theme'] as String?)?.isNotEmpty == true) pw.Text('Theme: ${vs['theme']}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          if (palette != null) ...[
            pw.Text('Colour palette${(palette['name'] as String?)?.isNotEmpty == true ? ': ${palette['name']}' : ''}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Row(children: (palette['colors'] as List).map((c) {
              final map = c as Map;
              return pw.Container(
                margin: const pw.EdgeInsets.only(right: 8),
                child: pw.Column(children: [
                  pw.Container(width: 40, height: 40, decoration: pw.BoxDecoration(color: PdfColor.fromInt(_colorFromHex(map['hex'].toString()).toARGB32()), borderRadius: pw.BorderRadius.circular(6))),
                  pw.SizedBox(height: 4),
                  pw.Text(map['label']?.toString().isEmpty == true ? map['hex'].toString() : map['label'].toString(), style: const pw.TextStyle(fontSize: 8)),
                ]),
              );
            }).toList()),
            pw.SizedBox(height: 14),
          ],
          if ((vs['mood_words'] as List).isNotEmpty) ...[
            pw.Text('Mood: ${(vs['mood_words'] as List).join(', ')}'),
            pw.SizedBox(height: 8),
          ],
          if ((vs['must_have_elements'] as List).isNotEmpty) ...[
            pw.Text('Must-haves: ${(vs['must_have_elements'] as List).join(', ')}'),
            pw.SizedBox(height: 8),
          ],
          if ((vs['elements_to_avoid'] as List).isNotEmpty) ...[
            pw.Text('Avoid: ${(vs['elements_to_avoid'] as List).join(', ')}'),
            pw.SizedBox(height: 8),
          ],
          if (imageWidgets.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text('Inspiration', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            pw.Wrap(children: imageWidgets),
          ],
        ],
      ));
      await Printing.layoutPdf(onLayout: (_) => doc.save(), name: 'Wedding-Style-Brief.pdf');
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't generate the brief. Try again.")));
    } finally {
      if (mounted) setState(() => _generatingBrief = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visionState = ref.watch(visionStyleProvider);
    _seed(visionState.visionStyle);
    final galleryState = ref.watch(galleryProvider);
    final inspiration = galleryState.assets.where((a) => a['album'] == 'inspiration').toList();
    final filtered = _categoryFilter == null ? inspiration : inspiration.where((a) => a['category'] == _categoryFilter).toList();

    return Scaffold(
      backgroundColor: AppTheme.udoBackground,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        title: const Text('Vision & Style', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          IconButton(
            onPressed: _generatingBrief ? null : () => _generateStyleBrief(inspiration),
            icon: _generatingBrief
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Share style brief',
          ),
        ],
      ),
      body: visionState.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.udoGreen))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Theme', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(controller: _themeCtrl, decoration: _decoration('e.g. Tropical Garden')),
                const SizedBox(height: 20),

                _ChipListEditor(
                  title: 'Mood words',
                  controller: _moodCtrl,
                  hint: 'e.g. romantic',
                  items: _moodWords,
                  onAdd: (v) => setState(() => _moodWords = [..._moodWords, v]),
                  onRemove: (v) => setState(() => _moodWords = _moodWords.where((m) => m != v).toList()),
                ),
                const SizedBox(height: 20),

                _ChipListEditor(
                  title: 'Must-have elements',
                  controller: _mustHaveCtrl,
                  hint: 'e.g. live band',
                  items: _mustHaves,
                  onAdd: (v) => setState(() => _mustHaves = [..._mustHaves, v]),
                  onRemove: (v) => setState(() => _mustHaves = _mustHaves.where((m) => m != v).toList()),
                ),
                const SizedBox(height: 20),

                _ChipListEditor(
                  title: 'Elements to avoid',
                  controller: _avoidCtrl,
                  hint: 'e.g. confetti',
                  items: _avoids,
                  onAdd: (v) => setState(() => _avoids = [..._avoids, v]),
                  onRemove: (v) => setState(() => _avoids = _avoids.where((m) => m != v).toList()),
                ),
                const SizedBox(height: 24),

                const Text('Colour palette', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 84,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _kPresetPalettes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final preset = _kPresetPalettes[i];
                      return GestureDetector(
                        onTap: () => _applyPreset(preset),
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.udoBorder)),
                          child: Column(children: [
                            Row(children: (preset['colors'] as List).map((c) => Expanded(child: Container(height: 22, color: _colorFromHex((c as Map)['hex'] as String)))).toList()),
                            const SizedBox(height: 6),
                            Text(preset['name'] as String, style: const TextStyle(fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextField(controller: _paletteNameCtrl, decoration: _decoration('Palette name')),
                const SizedBox(height: 10),
                if (_paletteColors.isEmpty)
                  const Text('No colours yet. Choose a preset above or add a custom colour.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))
                else
                  ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    onReorder: (oldIndex, newIndex) => setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _paletteColors.removeAt(oldIndex);
                      _paletteColors.insert(newIndex, item);
                      if (_primaryIndex == oldIndex) _primaryIndex = newIndex;
                      if (_accentIndex == oldIndex) _accentIndex = newIndex;
                    }),
                    children: [
                      for (int i = 0; i < _paletteColors.length; i++)
                        Container(
                          key: ValueKey('palette-color-$i'),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.udoBorder)),
                          child: Row(children: [
                            Container(width: 28, height: 28, decoration: BoxDecoration(color: _colorFromHex(_paletteColors[i]['hex']!), shape: BoxShape.circle, border: Border.all(color: AppTheme.udoBorder))),
                            const SizedBox(width: 10),
                            Expanded(child: Text(_paletteColors[i]['label']?.isNotEmpty == true ? _paletteColors[i]['label']! : _paletteColors[i]['hex']!, style: const TextStyle(fontSize: 13))),
                            IconButton(
                              icon: Icon(i == _primaryIndex ? Icons.star : Icons.star_border, size: 18, color: i == _primaryIndex ? AppTheme.udoGreen : AppTheme.udoTextSecondary),
                              tooltip: 'Primary colour',
                              onPressed: () => setState(() => _primaryIndex = i),
                            ),
                            IconButton(
                              icon: Icon(i == _accentIndex ? Icons.circle : Icons.circle_outlined, size: 16, color: i == _accentIndex ? AppTheme.udoCrimson : AppTheme.udoTextSecondary),
                              tooltip: 'Accent colour',
                              onPressed: () => setState(() => _accentIndex = i),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18, color: AppTheme.udoTextSecondary),
                              onPressed: () => setState(() {
                                _paletteColors = [..._paletteColors]..removeAt(i);
                                if (_primaryIndex == i) _primaryIndex = null;
                                if (_accentIndex == i) _accentIndex = null;
                              }),
                            ),
                          ]),
                        ),
                    ],
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickCustomColor,
                  icon: const Icon(Icons.colorize_outlined, size: 16),
                  label: const Text('Add custom colour'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44), side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
                ),
                const SizedBox(height: 24),

                Row(children: [
                  const Expanded(child: Text('Inspiration images', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                  IconButton(onPressed: _uploadInspiration, icon: const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.udoGreen)),
                ]),
                const Text('Shared with Gallery → Inspiration — one library, tagged by category.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                const SizedBox(height: 10),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  ChoiceChip(
                    label: const Text('All', style: TextStyle(fontSize: 12)),
                    selected: _categoryFilter == null,
                    onSelected: (_) => setState(() => _categoryFilter = null),
                    selectedColor: AppTheme.udoGreen,
                    labelStyle: TextStyle(color: _categoryFilter == null ? Colors.white : AppTheme.udoTextPrimary),
                  ),
                  for (final category in _kInspirationCategories)
                    ChoiceChip(
                      label: Text(_humanizeCategory(category), style: const TextStyle(fontSize: 12)),
                      selected: _categoryFilter == category,
                      onSelected: (_) => setState(() => _categoryFilter = category),
                      selectedColor: AppTheme.udoGreen,
                      labelStyle: TextStyle(color: _categoryFilter == category ? Colors.white : AppTheme.udoTextPrimary),
                    ),
                ]),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  Container(
                    height: 140,
                    decoration: BoxDecoration(color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(16)),
                    child: const Center(child: Text('No inspiration images yet.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary))),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _InspirationThumb(
                      asset: filtered[i],
                      categories: _kInspirationCategories,
                      onCategorySelected: (c) => ref.read(galleryProvider.notifier).setCategory(filtered[i]['id'] as int, c),
                    ),
                  ),
                const SizedBox(height: 28),

                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined, size: 16),
                  label: Text(_saving ? 'Saving...' : 'Save details'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true, fillColor: AppTheme.udoCardFill,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

class _ChipListEditor extends StatelessWidget {
  final String title, hint;
  final TextEditingController controller;
  final List<String> items;
  final void Function(String) onAdd;
  final void Function(String) onRemove;

  const _ChipListEditor({required this.title, required this.hint, required this.controller, required this.items, required this.onAdd, required this.onRemove});

  void _submit() {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    onAdd(value);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    const SizedBox(height: 8),
    Row(children: [
      Expanded(child: TextField(
        controller: controller,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: hint,
          filled: true, fillColor: AppTheme.udoCardFill,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      )),
      const SizedBox(width: 8),
      IconButton(onPressed: _submit, icon: const Icon(Icons.add_circle, color: AppTheme.udoGreen)),
    ]),
    if (items.isNotEmpty) ...[
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: items.map((item) => Chip(
        label: Text(item, style: const TextStyle(fontSize: 12)),
        onDeleted: () => onRemove(item),
        backgroundColor: AppTheme.udoCardFill,
      )).toList()),
    ],
  ]);
}

class _InspirationThumb extends StatelessWidget {
  final Map<String, dynamic> asset;
  final List<String> categories;
  final void Function(String?) onCategorySelected;

  const _InspirationThumb({required this.asset, required this.categories, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    final url = _resolveUrl((asset['thumbnail_url'] ?? asset['url']) as String?);
    final category = asset['category'] as String?;

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Tag category', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: categories.map((c) => ChoiceChip(
                label: Text(_humanizeCategory(c), style: const TextStyle(fontSize: 12)),
                selected: category == c,
                onSelected: (_) {
                  onCategorySelected(category == c ? null : c);
                  Navigator.pop(context);
                },
                selectedColor: AppTheme.udoGreen,
                labelStyle: TextStyle(color: category == c ? Colors.white : AppTheme.udoTextPrimary),
              )).toList()),
            ]),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(fit: StackFit.expand, children: [
          Container(
            color: AppTheme.udoCardFill,
            child: url.isEmpty
                ? const Center(child: Icon(Icons.image_outlined, color: AppTheme.udoGreen, size: 24))
                : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, color: AppTheme.udoGreen, size: 24))),
          ),
          if (category != null)
            Positioned(
              bottom: 4, left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.udoGreen.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(6)),
                child: Text(_humanizeCategory(category), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
              ),
            ),
        ]),
      ),
    );
  }
}
