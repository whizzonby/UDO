import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/gallery_models.dart';
import '../providers/gallery_provider.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(galleryNotifierProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          surfaceTintColor: AppColors.white,
          titleSpacing: 20,
          title: Text(
            'Gallery',
            style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.grey700),
          ),
          actions: [
            if (state.loadStatus == GalleryLoadStatus.loaded)
              IconButton(
                icon: const Icon(Icons.add_rounded,
                    color: AppColors.pinkGradientStart),
                onPressed: () => _AddItemSheet.show(context),
              ),
            const SizedBox(width: 4),
          ],
          bottom: TabBar(
            labelColor: AppColors.pinkGradientStart,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: AppColors.pinkGradientStart,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2,
            dividerColor: AppColors.grey200,
            labelStyle: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.w500),
            tabs: [
              Tab(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Inspiration'),
                  if (state.summary.inspiration > 0) ...[
                    const SizedBox(width: 5),
                    _TabCount(state.summary.inspiration),
                  ],
                ]),
              ),
              Tab(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Memories'),
                  if (state.summary.memories > 0) ...[
                    const SizedBox(width: 5),
                    _TabCount(state.summary.memories),
                  ],
                ]),
              ),
            ],
          ),
        ),
        body: state.loadStatus == GalleryLoadStatus.loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.pinkGradientStart))
            : state.loadStatus == GalleryLoadStatus.error
                ? _ErrorView(
                    onRetry: () =>
                        ref.read(galleryNotifierProvider.notifier).refresh())
                : TabBarView(children: [
                    _InspirationTab(state: state),
                    _MemoriesTab(state: state),
                  ]),
      ),
    );
  }
}

class _TabCount extends StatelessWidget {
  const _TabCount(this.count);
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.pinkGradientStart.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.pinkGradientStart),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INSPIRATION TAB
// ─────────────────────────────────────────────────────────────────────────────

class _InspirationTab extends ConsumerStatefulWidget {
  const _InspirationTab({required this.state});
  final GalleryState state;

  @override
  ConsumerState<_InspirationTab> createState() => _InspirationTabState();
}

class _InspirationTabState extends ConsumerState<_InspirationTab> {
  String? _activeCategory;

  List<GalleryItem> get _filtered {
    final items = widget.state.inspirationItems;
    if (_activeCategory == null) return items;
    return items.where((i) => i.category == _activeCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.state.summary.categories;

    if (widget.state.inspirationItems.isEmpty) {
      return _EmptyState(
        icon: Icons.lightbulb_outline_rounded,
        title: 'No inspiration yet',
        subtitle:
            'Pin images from the web or add photos to build your mood board.',
        onAdd: () => _AddItemSheet.show(context, type: 'inspiration'),
      );
    }

    return RefreshIndicator(
      color: AppColors.pinkGradientStart,
      onRefresh: () =>
          ref.read(galleryNotifierProvider.notifier).refresh(),
      child: CustomScrollView(slivers: [
        // Category filter
        if (categories.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: _activeCategory == null,
                    onTap: () =>
                        setState(() => _activeCategory = null),
                  ),
                  for (final cat in categories)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _CategoryChip(
                        label: cat,
                        selected: _activeCategory == cat,
                        onTap: () => setState(() =>
                            _activeCategory =
                                _activeCategory == cat ? null : cat),
                      ),
                    ),
                ],
              ),
            ),
          ),

        // Grid
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _InspirationCard(item: _filtered[i]),
              childCount: _filtered.length,
            ),
          ),
        ),
      ]),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.pinkGradientStart
              : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.pinkGradientStart
                : AppColors.grey200,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.grey600,
          ),
        ),
      ),
    );
  }
}

class _InspirationCard extends ConsumerWidget {
  const _InspirationCard({required this.item});
  final GalleryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref
        .watch(galleryNotifierProvider)
        .busyIds
        .contains(item.id);

    return GestureDetector(
      onLongPress: () => _ItemOptionsSheet.show(context, item),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(fit: StackFit.expand, children: [
          // Image
          _GalleryImage(url: item.imageUrl),

          // Gradient overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                if (item.category != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.category!,
                      style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                if (item.title != null)
                  Text(
                    item.title!,
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ]),
            ),
          ),

          // Featured star
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: isBusy
                  ? null
                  : () => ref
                      .read(galleryNotifierProvider.notifier)
                      .featureItem(item.id),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: item.isFeatured
                      ? const Color(0xFFF59E0B)
                      : Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: isBusy
                    ? const Padding(
                        padding: EdgeInsets.all(6),
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white),
                      )
                    : Icon(
                        item.isFeatured
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEMORIES TAB
// ─────────────────────────────────────────────────────────────────────────────

class _MemoriesTab extends ConsumerWidget {
  const _MemoriesTab({required this.state});
  final GalleryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = state.memoryItems;

    if (items.isEmpty) {
      return _EmptyState(
        icon: Icons.photo_album_outlined,
        title: 'No memories yet',
        subtitle:
            'Add photos from your wedding day. Guests can also upload via their link.',
        onAdd: () => _AddItemSheet.show(context, type: 'memory'),
      );
    }

    return RefreshIndicator(
      color: AppColors.pinkGradientStart,
      onRefresh: () =>
          ref.read(galleryNotifierProvider.notifier).refresh(),
      child: CustomScrollView(slivers: [
        // Stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(children: [
              _MemoryStat(
                  label: 'Photos',
                  value: '${items.length}',
                  color: AppColors.pinkGradientStart),
              const SizedBox(width: 8),
              _MemoryStat(
                  label: 'Starred',
                  value: '${items.where((i) => i.isFeatured).length}',
                  color: const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              _MemoryStat(
                  label: 'Guest uploads',
                  value: '${items.where((i) => i.uploadedBy != null).length}',
                  color: AppColors.teal),
            ]),
          ),
        ),

        // Grid
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
          sliver: SliverGrid(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _MemoryCell(item: items[i]),
              childCount: items.length,
            ),
          ),
        ),
      ]),
    );
  }
}

class _MemoryStat extends StatelessWidget {
  const _MemoryStat(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Text(value,
              style: GoogleFonts.dmSans(
                  fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppColors.grey500)),
        ]),
      ),
    );
  }
}

class _MemoryCell extends ConsumerWidget {
  const _MemoryCell({required this.item});
  final GalleryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _MemoryDetailSheet.show(context, item),
      onLongPress: () => _ItemOptionsSheet.show(context, item),
      child: Stack(fit: StackFit.expand, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: _GalleryImage(url: item.imageUrl),
        ),
        if (item.isFeatured)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFF59E0B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded,
                  color: Colors.white, size: 12),
            ),
          ),
        if (item.uploadedBy != null)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Guest',
                style: GoogleFonts.dmSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _GalleryImage extends StatelessWidget {
  const _GalleryImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : Container(
              color: AppColors.grey100,
              child: Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: AppColors.pinkGradientStart,
                ),
              ),
            ),
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.grey100,
        child: const Icon(Icons.broken_image_outlined,
            color: AppColors.grey300, size: 28),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onAdd,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 52, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text(title,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey700)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppColors.grey500, height: 1.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinkGradientStart,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: AppColors.grey400, size: 40),
        const SizedBox(height: 12),
        Text('Failed to load gallery',
            style: GoogleFonts.dmSans(color: AppColors.grey500)),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHEETS
// ─────────────────────────────────────────────────────────────────────────────

class _AddItemSheet extends ConsumerStatefulWidget {
  const _AddItemSheet({this.initialType = 'inspiration'});
  final String initialType;

  static Future<void> show(BuildContext context,
          {String type = 'inspiration'}) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _AddItemSheet(initialType: type),
      );

  @override
  ConsumerState<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<_AddItemSheet> {
  late String _type;
  final _titleCtrl = TextEditingController();
  final _captionCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _sourceUrlCtrl = TextEditingController();
  String? _category;
  bool _saving = false;

  static const _inspirationCategories = [
    'Venues', 'Florals', 'Decor', 'Attire', 'Food & Cake',
    'Photography', 'Hair & Makeup', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    for (final c in [_titleCtrl, _captionCtrl, _imageUrlCtrl, _sourceUrlCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Text('Add to gallery',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.grey400, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]),
              const SizedBox(height: 12),

              // Type toggle
              Row(children: [
                Expanded(
                    child: _TypeToggle(
                        label: 'Inspiration',
                        selected: _type == 'inspiration',
                        onTap: () =>
                            setState(() => _type = 'inspiration'))),
                const SizedBox(width: 8),
                Expanded(
                    child: _TypeToggle(
                        label: 'Memory',
                        selected: _type == 'memory',
                        onTap: () =>
                            setState(() => _type = 'memory'))),
              ]),
              const SizedBox(height: 14),

              _InputField(
                  label: 'Image URL',
                  ctrl: _imageUrlCtrl,
                  hint: 'https://...'),
              const SizedBox(height: 10),
              _InputField(
                  label: 'Title (optional)',
                  ctrl: _titleCtrl,
                  hint: 'e.g. Garden reception'),
              const SizedBox(height: 10),
              _InputField(
                  label: 'Caption (optional)',
                  ctrl: _captionCtrl,
                  hint: 'Notes…',
                  maxLines: 2),
              if (_type == 'inspiration') ...[
                const SizedBox(height: 10),
                _InputField(
                    label: 'Source URL (optional)',
                    ctrl: _sourceUrlCtrl,
                    hint: 'Original pin link…'),
                const SizedBox(height: 10),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Category',
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey500)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final cat in _inspirationCategories)
                      GestureDetector(
                        onTap: () => setState(() =>
                            _category =
                                _category == cat ? null : cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _category == cat
                                ? AppColors.pinkGradientStart
                                    .withValues(alpha: 0.1)
                                : AppColors.grey100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _category == cat
                                  ? AppColors.pinkGradientStart
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(cat,
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _category == cat
                                      ? AppColors.pinkGradientStart
                                      : AppColors.grey600)),
                        ),
                      ),
                  ]),
                ]),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _saving || _imageUrlCtrl.text.trim().isEmpty
                          ? null
                          : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pinkGradientStart,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.grey200,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white))
                      : Text('Add to gallery',
                          style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(galleryNotifierProvider.notifier).addItem({
      'type': _type,
      'image_url': _imageUrlCtrl.text.trim(),
      if (_titleCtrl.text.trim().isNotEmpty) 'title': _titleCtrl.text.trim(),
      if (_captionCtrl.text.trim().isNotEmpty)
        'caption': _captionCtrl.text.trim(),
      if (_sourceUrlCtrl.text.trim().isNotEmpty)
        'source_url': _sourceUrlCtrl.text.trim(),
      if (_category != null) 'category': _category,
    });
    if (mounted) Navigator.of(context).pop();
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.pinkGradientStart
              : AppColors.grey100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.grey500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemOptionsSheet extends ConsumerWidget {
  const _ItemOptionsSheet({required this.item});
  final GalleryItem item;

  static Future<void> show(BuildContext context, GalleryItem item) =>
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _ItemOptionsSheet(item: item),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (item.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(item.title!,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey700)),
            ),
          _OptionTile(
            icon: item.isFeatured
                ? Icons.star_border_rounded
                : Icons.star_rounded,
            color: const Color(0xFFF59E0B),
            label: item.isFeatured ? 'Unstar' : 'Star (feature)',
            onTap: () {
              Navigator.of(context).pop();
              ref
                  .read(galleryNotifierProvider.notifier)
                  .featureItem(item.id);
            },
          ),
          if (item.sourceUrl != null)
            _OptionTile(
              icon: Icons.open_in_new_rounded,
              color: AppColors.teal,
              label: 'Open source link',
              onTap: () {
                Navigator.of(context).pop();
                Clipboard.setData(ClipboardData(text: item.sourceUrl!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Link copied',
                        style: GoogleFonts.dmSans(fontSize: 13)),
                    backgroundColor: AppColors.teal,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          _OptionTile(
            icon: Icons.delete_outline_rounded,
            color: AppColors.error,
            label: 'Remove from gallery',
            onTap: () async {
              Navigator.of(context).pop();
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Remove photo?',
                      style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.w700, fontSize: 17)),
                  content: Text(
                      item.title != null
                          ? 'Remove "${item.title}" from your gallery?'
                          : 'Remove this photo from your gallery?',
                      style: GoogleFonts.dmSans(fontSize: 13)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Remove',
                          style:
                              TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                ref
                    .read(galleryNotifierProvider.notifier)
                    .deleteItem(item.id);
              }
            },
          ),
        ]),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.grey700)),
      onTap: onTap,
    );
  }
}

class _MemoryDetailSheet extends StatelessWidget {
  const _MemoryDetailSheet({required this.item});
  final GalleryItem item;

  static Future<void> show(BuildContext context, GalleryItem item) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _MemoryDetailSheet(item: item),
      );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                // Full image
                AspectRatio(
                  aspectRatio: 1,
                  child: _GalleryImage(url: item.imageUrl),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    if (item.title != null)
                      Text(item.title!,
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey700)),
                    if (item.caption != null) ...[
                      const SizedBox(height: 6),
                      Text(item.caption!,
                          style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.grey500,
                              height: 1.5)),
                    ],
                    if (item.uploadedBy != null) ...[
                      const SizedBox(height: 12),
                      Row(children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 15, color: AppColors.grey400),
                        const SizedBox(width: 6),
                        Text('Uploaded by ${item.uploadedBy}',
                            style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: AppColors.grey500)),
                      ]),
                    ],
                  ]),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.maxLines = 1,
  });
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.grey500)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        style:
            GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey700),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
              fontSize: 13, color: AppColors.grey400),
          filled: true,
          fillColor: AppColors.grey100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 12),
          isDense: true,
        ),
      ),
    ]);
  }
}
