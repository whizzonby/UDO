import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pdf/pdf.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/udo_design_system.dart';
import '../../../memories/presentation/providers/memories_provider.dart';
import '../providers/gallery_provider.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});
  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _drawerOpen = false;

  static const _pages = [
    _GalleryPageMeta('Overview', Icons.auto_awesome_mosaic_outlined),
    _GalleryPageMeta('Albums', Icons.photo_library_outlined),
    _GalleryPageMeta('Favourites', Icons.favorite_border),
    _GalleryPageMeta('Archive', Icons.archive_outlined),
    _GalleryPageMeta('Highlights', Icons.stars_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _pages.length, vsync: this);
    _tabs.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galleryProvider);
    final notifier = ref.read(galleryProvider.notifier);

    return Scaffold(
      backgroundColor: UdoDesign.bg,
      body: Stack(
        children: [
          Column(
            children: [
              _GalleryWorkspaceHeader(
                title: _pages[_tabs.index].title,
                totalAssets: state.assets.length,
                onMenuTap: () => setState(() => _drawerOpen = true),
                onSearchTap: () => _showGallerySearch(context, state, notifier),
                onUploadTap: () => _showUploadModal(context, notifier, state),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: _galleryAccent))
                    : TabBarView(
                        controller: _tabs,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _InspirationTab(state: state, notifier: notifier),
                          _GuestUploadsTab(state: state, notifier: notifier),
                          _SavedTab(state: state, notifier: notifier),
                          _ArchiveTab(state: state, notifier: notifier),
                          _MomentsTab(state: state, notifier: notifier),
                        ],
                      ),
              ),
            ],
          ),
          _GalleryWorkspaceDrawer(
            open: _drawerOpen,
            activeIndex: _tabs.index,
            state: state,
            onClose: () => setState(() => _drawerOpen = false),
            onNavigate: (index) {
              _tabs.animateTo(index);
              setState(() => _drawerOpen = false);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadModal(context, notifier, state),
        backgroundColor: AppTheme.udoGreen,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_photo_alternate_outlined),
      ),
    );
  }

  void _showUploadModal(
      BuildContext context, GalleryNotifier notifier, GalleryState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _UploadModal(notifier: notifier, state: state),
    );
  }
}

// â”€â”€ HEADER â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

const _galleryAccent = Color(0xFF6E5F7A);

class _GalleryPageMeta {
  final String title;
  final IconData icon;
  const _GalleryPageMeta(this.title, this.icon);
}

class _GalleryWorkspaceHeader extends StatelessWidget {
  final String title;
  final int totalAssets;
  final VoidCallback onMenuTap;
  final VoidCallback onSearchTap;
  final VoidCallback onUploadTap;

  const _GalleryWorkspaceHeader({
    required this.title,
    required this.totalAssets,
    required this.onMenuTap,
    required this.onSearchTap,
    required this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
        bottom: false,
        child: Container(
          color: UdoDesign.bg,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(children: [
            _GalleryRoundButton(icon: Icons.menu, onTap: onMenuTap),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('GALLERY',
                      style: UdoDesign.sans(
                          size: 12,
                          weight: FontWeight.w800,
                          color: _galleryAccent)),
                  const SizedBox(height: 2),
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UdoDesign.serif(size: 28)),
                  Text('$totalAssets memories, moments and references.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UdoDesign.sans(size: 12, color: UdoDesign.muted)),
                ])),
            _GalleryRoundButton(icon: Icons.search, onTap: onSearchTap),
            const SizedBox(width: 10),
            _GalleryRoundButton(
                icon: Icons.add_photo_alternate_outlined, onTap: onUploadTap),
          ]),
        ),
      );
}

class _GalleryRoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GalleryRoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: _galleryAccent, size: 21),
          ),
        ),
      );
}

class _GalleryWorkspaceDrawer extends StatelessWidget {
  final bool open;
  final int activeIndex;
  final GalleryState state;
  final VoidCallback onClose;
  final ValueChanged<int> onNavigate;

  const _GalleryWorkspaceDrawer({
    required this.open,
    required this.activeIndex,
    required this.state,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final inspiration =
        state.assets.where((a) => a['album'] == 'inspiration').length;
    final uploads = state.assets
        .where((a) =>
            a['uploaded_by_guest_id'] != null || a['album'] == 'guest_uploads')
        .length;
    final archived = state.assets.where((a) => a['album'] == 'archive').length;
    final moments = state.assets.where((a) => a['album'] == 'moments').length;
    final badges = [
      '${state.assets.length} total',
      '$inspiration boards',
      '$uploads uploads',
      '$archived hidden',
      '$moments moments',
    ];

    return IgnorePointer(
      ignoring: !open,
      child: AnimatedOpacity(
        opacity: open ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Stack(children: [
          GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.black.withValues(alpha: 0.16)),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            right: open ? 0 : -MediaQuery.sizeOf(context).width,
            width: MediaQuery.sizeOf(context).width * 0.86,
            child: SafeArea(
              child: UdoCard(
                radius: 0,
                border: BorderSide.none,
                padding: const EdgeInsets.fromLTRB(20, 20, 18, 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Text('Gallery',
                                style: UdoDesign.serif(size: 36))),
                        IconButton(
                            onPressed: onClose, icon: const Icon(Icons.close)),
                      ]),
                      Container(
                        margin: const EdgeInsets.only(top: 6, bottom: 18),
                        height: 2,
                        width: 68,
                        color: UdoDesign.gold,
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            for (var i = 0;
                                i < _GalleryScreenState._pages.length;
                                i++)
                              _GalleryDrawerRow(
                                meta: _GalleryScreenState._pages[i],
                                badge: badges[i],
                                active: i == activeIndex,
                                onTap: () => onNavigate(i),
                              ),
                          ],
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _GalleryDrawerRow extends StatelessWidget {
  final _GalleryPageMeta meta;
  final String badge;
  final bool active;
  final VoidCallback onTap;

  const _GalleryDrawerRow({
    required this.meta,
    required this.badge,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        onTap: onTap,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        color: active ? UdoDesign.bg : UdoDesign.card,
        border: BorderSide(
            color: active
                ? _galleryAccent.withValues(alpha: 0.22)
                : UdoDesign.border),
        child: Row(children: [
          Icon(meta.icon, color: active ? _galleryAccent : UdoDesign.muted),
          const SizedBox(width: 12),
          Expanded(
              child: Text(meta.title,
                  style: UdoDesign.sans(
                      size: 14,
                      weight: FontWeight.w800,
                      color: active ? _galleryAccent : UdoDesign.text))),
          UdoBadge(
              label: badge, color: active ? _galleryAccent : UdoDesign.muted),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 17, color: UdoDesign.muted),
        ]),
      );
}

void _showGallerySearch(
    BuildContext context, GalleryState state, GalleryNotifier notifier) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _GallerySearchSheet(state: state, notifier: notifier),
  );
}

class _GallerySearchSheet extends StatefulWidget {
  final GalleryState state;
  final GalleryNotifier notifier;
  const _GallerySearchSheet({required this.state, required this.notifier});

  @override
  State<_GallerySearchSheet> createState() => _GallerySearchSheetState();
}

class _GallerySearchSheetState extends State<_GallerySearchSheet> {
  final _query = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final q = _query.text.trim().toLowerCase();
    final results = q.isEmpty
        ? widget.state.assets.take(12).toList()
        : widget.state.assets.where((asset) {
            final haystack = [
              asset['caption'],
              asset['album'],
              asset['board_name'],
              asset['category'],
              asset['journey_stage'],
              asset['uploaded_by_role'],
            ].whereType<Object>().join(' ').toLowerCase();
            return haystack.contains(q);
          }).toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Expanded(
                child: Text('Search Gallery',
                    style: UdoDesign.sans(size: 18, weight: FontWeight.w800))),
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close)),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _query,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search albums, captions, stages...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: UdoDesign.bg,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 260,
            child: results.isEmpty
                ? Center(
                    child: Text('No matching memories.',
                        style:
                            UdoDesign.sans(size: 13, color: UdoDesign.muted)))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8),
                    itemCount: results.length,
                    itemBuilder: (_, i) => _AssetThumb(
                      asset: results[i],
                      onSaveToggle: () =>
                          widget.notifier.toggleSaved(results[i]['id'] as int),
                    ),
                  ),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }
}

// â”€â”€ SHARED THUMBNAIL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

String _resolveUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  return url.startsWith('http') ? url : '${AppConstants.apiOrigin}$url';
}

const _kJourneyStageLabels = {
  'engagement': 'Engagement',
  'planning': 'Planning',
  'wedding_weekend': 'Wedding Weekend',
  'honeymoon': 'Honeymoon',
  'anniversary': 'Anniversary',
  'other': 'Other',
};

void _showTagMilestoneSheet(
    BuildContext context, WidgetRef ref, Map<String, dynamic> asset) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tag this moment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('Add it to your journey timeline.',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.udoTextSecondary)),
              const SizedBox(height: 16),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final entry in _kJourneyStageLabels.entries)
                  ChoiceChip(
                    label:
                        Text(entry.value, style: const TextStyle(fontSize: 12)),
                    selected: asset['journey_stage'] == entry.key,
                    onSelected: (_) {
                      ref
                          .read(galleryProvider.notifier)
                          .setJourneyStage(asset['id'] as int, entry.key);
                      Navigator.pop(context);
                    },
                    selectedColor: AppTheme.udoGreen,
                    labelStyle: TextStyle(
                        color: asset['journey_stage'] == entry.key
                            ? Colors.white
                            : AppTheme.udoTextPrimary,
                        fontSize: 12),
                  ),
              ]),
              if (asset['journey_stage'] != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    ref
                        .read(galleryProvider.notifier)
                        .setJourneyStage(asset['id'] as int, null);
                    Navigator.pop(context);
                  },
                  child: const Text('Remove milestone tag'),
                ),
              ],
            ]),
      ),
    ),
  );
}

class _AssetThumb extends ConsumerWidget {
  final Map<String, dynamic> asset;
  final VoidCallback? onSaveToggle;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onFeature;
  final VoidCallback? onArchive;
  final bool showRoleBadge;

  const _AssetThumb(
      {required this.asset,
      this.onSaveToggle,
      this.onApprove,
      this.onReject,
      this.onFeature,
      this.onArchive,
      this.showRoleBadge = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url =
        _resolveUrl((asset['thumbnail_url'] ?? asset['url']) as String?);
    final isSaved = asset['is_saved'] == true;
    final type = asset['type'] as String? ?? 'photo';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: type == 'video'
                ? () => _openVideoPlayer(context, url)
                : type == 'voice'
                    ? () => _openVoicePlayer(context, url)
                    : () => _openPhotoViewer(
                        context, _resolveUrl(asset['url'] as String?)),
            onLongPress: () => _showTagMilestoneSheet(context, ref, asset),
            child: Container(
              color: AppTheme.udoCardFill,
              child: type == 'voice'
                  ? const Center(
                      child:
                          Icon(Icons.mic, color: AppTheme.udoGreen, size: 28))
                  : type == 'video'
                      ? const Center(
                          child: Icon(Icons.play_circle_fill,
                              color: AppTheme.udoGreen, size: 32))
                      : url.isEmpty
                          ? Center(
                              child: Icon(Icons.image_outlined,
                                  color:
                                      AppTheme.udoGreen.withValues(alpha: 0.5),
                                  size: 28))
                          : Image.network(
                              url,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) =>
                                  progress == null
                                      ? child
                                      : const Center(
                                          child: SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppTheme.udoGreen))),
                              errorBuilder: (context, error, stack) => Center(
                                  child: Icon(Icons.broken_image_outlined,
                                      color: AppTheme.udoGreen
                                          .withValues(alpha: 0.4),
                                      size: 28)),
                            ),
            ),
          ),
          if (onSaveToggle != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onSaveToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle),
                  child: Icon(isSaved ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white, size: 14),
                ),
              ),
            ),
          if (onApprove != null && asset['approved'] != true)
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: onApprove,
                child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                        color: AppTheme.udoGreen, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 14)),
              ),
            ),
          if (onReject != null && asset['approved'] != true)
            Positioned(
              bottom: 4,
              left: 4,
              child: GestureDetector(
                onTap: onReject,
                child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                        color: AppTheme.udoCrimson, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 14)),
              ),
            ),
          if (onFeature != null && asset['approved'] == true)
            Positioned(
              bottom: 4,
              left: 4,
              child: GestureDetector(
                onTap: onFeature,
                child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle),
                    child: Icon(
                        asset['is_featured'] == true
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.white,
                        size: 14)),
              ),
            ),
          if (onArchive != null && asset['approved'] == true)
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: onArchive,
                child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.archive_outlined,
                        color: Colors.white, size: 14)),
              ),
            ),
          if (showRoleBadge &&
              (asset['uploaded_by_role'] as String?)?.isNotEmpty == true)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                    color: AppTheme.udoGreen.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(asset['uploaded_by_role'] as String,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
        ],
      ),
    );
  }

  void _openPhotoViewer(BuildContext context, String url) {
    if (url.isEmpty) return;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => _PhotoViewerScreen(url: url)));
  }

  void _openVideoPlayer(BuildContext context, String url) {
    if (url.isEmpty) return;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => _VideoPlayerScreen(url: url)));
  }

  void _openVoicePlayer(BuildContext context, String url) {
    if (url.isEmpty) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _VoicePlayerSheet(url: url),
    );
  }
}

class _PhotoViewerScreen extends StatelessWidget {
  final String url;
  const _PhotoViewerScreen({required this.url});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0),
        body: PhotoView(
          imageProvider: NetworkImage(url),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(color: Colors.white)),
          errorBuilder: (context, error, stack) => const Center(
              child: Text("Couldn't load this photo.",
                  style: TextStyle(color: Colors.white))),
        ),
      );
}

class _VideoPlayerScreen extends StatefulWidget {
  final String url;
  const _VideoPlayerScreen({required this.url});
  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late final VideoPlayerController _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _controller.play();
      }).catchError((_) {
        if (mounted) setState(() => _failed = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0),
        body: Center(
          child: _failed
              ? const Text("Couldn't play this video.",
                  style: TextStyle(color: Colors.white))
              : _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller))
                  : const CircularProgressIndicator(color: Colors.white),
        ),
        floatingActionButton: (_controller.value.isInitialized && !_failed)
            ? FloatingActionButton(
                backgroundColor: AppTheme.udoGreen,
                onPressed: () => setState(() => _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play()),
                child: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white),
              )
            : null,
      );
}

class _VoicePlayerSheet extends StatefulWidget {
  final String url;
  const _VoicePlayerSheet({required this.url});
  @override
  State<_VoicePlayerSheet> createState() => _VoicePlayerSheetState();
}

class _VoicePlayerSheetState extends State<_VoicePlayerSheet> {
  final _player = AudioPlayer();
  bool _failed = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _player.setUrl(widget.url).then((_) {
      if (mounted) {
        setState(() => _loading = false);
      }
      _player.play();
    }).catchError((_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.mic, color: AppTheme.udoGreen, size: 36),
            const SizedBox(height: 12),
            const Text('Voice message',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            if (_loading)
              const CircularProgressIndicator(color: AppTheme.udoGreen)
            else if (_failed)
              const Text("Couldn't play this voice message.",
                  style: TextStyle(color: AppTheme.udoTextSecondary))
            else
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  return IconButton(
                    iconSize: 48,
                    color: AppTheme.udoGreen,
                    icon: Icon(playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill),
                    onPressed: () => playing ? _player.pause() : _player.play(),
                  );
                },
              ),
          ]),
        ),
      );
}

Widget _emptyState(IconData icon, String title, String subtitle) => Container(
      height: 200,
      decoration: BoxDecoration(
          color: AppTheme.udoCardFill, borderRadius: BorderRadius.circular(16)),
      child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 48, color: AppTheme.udoGreen),
        const SizedBox(height: 12),
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(subtitle,
            style:
                const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary),
            textAlign: TextAlign.center),
      ])),
    );

// â”€â”€ INSPIRATION TAB â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

String _boardTimeAgo(String? iso) {
  if (iso == null) return '';
  final d = DateTime.tryParse(iso);
  if (d == null) return '';
  final diff = DateTime.now().difference(d);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  return '${diff.inDays} d ago';
}

class _InspirationTab extends ConsumerStatefulWidget {
  final GalleryState state;
  final GalleryNotifier notifier;
  const _InspirationTab({required this.state, required this.notifier});

  @override
  ConsumerState<_InspirationTab> createState() => _InspirationTabState();
}

class _InspirationTabState extends ConsumerState<_InspirationTab>
    with WidgetsBindingObserver {
  String? _selectedBoard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.notifier.fetchPinterestStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The user completes the Pinterest OAuth flow in an external browser â€”
    // re-check connection status when they switch back to the app.
    if (state == AppLifecycleState.resumed) {
      widget.notifier.fetchPinterestStatus();
    }
  }

  Future<void> _connectPinterest(BuildContext context) async {
    final url = await widget.notifier.connectPinterest();
    if (url == null) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _openBoardPicker(BuildContext context) {
    widget.notifier.fetchPinterestBoards();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PinterestBoardsSheet(notifier: widget.notifier),
    );
  }

  Map<String, List<Map<String, dynamic>>> _grouped(
      List<Map<String, dynamic>> items) {
    final byBoard = <String, List<Map<String, dynamic>>>{};
    for (final item in items) {
      final board = (item['board_name'] as String?)?.trim();
      final key = (board == null || board.isEmpty) ? 'Unsorted' : board;
      byBoard.putIfAbsent(key, () => []).add(item);
    }
    return byBoard;
  }

  void _showBoardPicker(BuildContext context, Map<String, dynamic> asset,
      List<String> boardNames) {
    final ctrl =
        TextEditingController(text: (asset['board_name'] as String?) ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Move to board',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(
                  controller: ctrl,
                  decoration: InputDecoration(
                    hintText: 'Board name',
                    filled: true,
                    fillColor: AppTheme.udoCardFill,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                  )),
              if (boardNames.where((b) => b != 'Unsorted').isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: boardNames
                        .where((b) => b != 'Unsorted')
                        .map((b) => GestureDetector(
                              onTap: () => ctrl.text = b,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                    color: AppTheme.udoCardFill,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Text(b,
                                    style: const TextStyle(fontSize: 12)),
                              ),
                            ))
                        .toList()),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await widget.notifier.setBoardName(asset['id'] as int,
                      ctrl.text.trim().isEmpty ? null : ctrl.text.trim());
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: AppTheme.udoGreen,
                    foregroundColor: Colors.white),
                child: const Text('Save'),
              ),
              const SizedBox(height: 8),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final notifier = widget.notifier;
    final items =
        state.assets.where((a) => a['album'] == 'inspiration').toList();
    final byBoard = _grouped(items);
    final boardNames = byBoard.keys.where((k) => k != 'Unsorted').toList()
      ..sort();
    if (byBoard.containsKey('Unsorted')) boardNames.add('Unsorted');

    if (_selectedBoard != null) {
      final boardItems = byBoard[_selectedBoard] ?? [];
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            IconButton(
                onPressed: () => setState(() => _selectedBoard = null),
                icon: const Icon(Icons.arrow_back, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints()),
            const SizedBox(width: 8),
            Expanded(
                child: Text(_selectedBoard!,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 12),
          if (boardItems.isEmpty)
            _emptyState(Icons.image_outlined, 'No images in this board yet',
                'Tag an inspiration image into "$_selectedBoard".')
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 4, crossAxisSpacing: 4),
              itemCount: boardItems.length,
              itemBuilder: (_, i) => GestureDetector(
                onLongPress: () =>
                    _showBoardPicker(context, boardItems[i], boardNames),
                child: _AssetThumb(
                    asset: boardItems[i],
                    onSaveToggle: () =>
                        notifier.toggleSaved(boardItems[i]['id'] as int)),
              ),
            ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _GalleryOverviewHero(
          total: state.assets.length,
          inspiration: items.length,
          uploads: state.assets
              .where((a) =>
                  a['uploaded_by_guest_id'] != null ||
                  a['album'] == 'guest_uploads')
              .length,
          saved: state.assets.where((a) => a['is_saved'] == true).length,
          featured: state.assets.where((a) => a['is_featured'] == true).length,
          cover: state.assets.isEmpty ? null : state.assets.first,
        ),
        const SizedBox(height: 16),
        _PinterestCard(
          state: state,
          onConnect: () => _connectPinterest(context),
          onImport: () => _openBoardPicker(context),
          onDisconnect: () => widget.notifier.disconnectPinterest(),
        ),
        const SizedBox(height: 16),
        Text('${items.length} saved for inspiration',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        if (items.isEmpty)
          _emptyState(Icons.image_outlined, 'No inspiration images yet',
              'Add a photo and tag it "Inspiration".')
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95,
            children: [
              for (final name in boardNames)
                Builder(builder: (context) {
                  final boardItems = byBoard[name]!;
                  final sorted = [...boardItems]..sort((a, b) =>
                      (b['created_at'] as String? ?? '')
                          .compareTo(a['created_at'] as String? ?? ''));
                  final cover = sorted.first;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBoard = name),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.udoBorder)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _AssetThumb(asset: cover)),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text(
                                        '${boardItems.length} image${boardItems.length == 1 ? '' : 's'} Â· ${_boardTimeAgo(cover['created_at'] as String?)}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.udoTextSecondary)),
                                  ]),
                            ),
                          ]),
                    ),
                  );
                }),
            ],
          ),
      ],
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final Map<String, dynamic> album;
  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context) {
    final name = (album['name'] as String?)?.trim() ?? 'Untitled album';
    final description = (album['description'] as String?)?.trim();
    final count = album['asset_count'] is int
        ? album['asset_count'] as int
        : int.tryParse('${album['asset_count']}') ?? 0;
    final cover = _resolveUrl(album['cover_thumbnail_url'] as String?);

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.udoBorder)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppTheme.udoCardFill,
              child: cover.isEmpty
                  ? const Icon(Icons.photo_album_outlined,
                      color: AppTheme.udoGreen, size: 38)
                  : Image.network(
                      cover,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.photo_album_outlined,
                          color: AppTheme.udoGreen,
                          size: 38),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(
                  description?.isNotEmpty == true
                      ? description!
                      : '$count item${count == 1 ? '' : 's'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.udoTextSecondary)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _CreateAlbumSheet extends StatefulWidget {
  final GalleryNotifier notifier;
  const _CreateAlbumSheet({required this.notifier});

  @override
  State<_CreateAlbumSheet> createState() => _CreateAlbumSheetState();
}

class _CreateAlbumSheetState extends State<_CreateAlbumSheet> {
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    final ok = await widget.notifier.createAlbum(
      name: name,
      description: _descriptionCtrl.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Album created.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create album.')));
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              left: 20,
              right: 20,
              top: 24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(
                  child: Text('New album',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600))),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero),
            ]),
            const SizedBox(height: 16),
            const Text('Album name',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              decoration: _sheetInputDecoration('e.g. Reception'),
            ),
            const SizedBox(height: 14),
            const Text('Description',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _descriptionCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: _sheetInputDecoration('Optional note for this album'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: AppTheme.udoGreen,
                  foregroundColor: Colors.white),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Create album'),
            ),
          ]),
        ),
      );
}

InputDecoration _sheetInputDecoration(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppTheme.udoCardFill,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

List<Map<String, dynamic>> _galleryAlbumSummaries(GalleryState state) {
  final keyed = <String, Map<String, dynamic>>{};
  for (final album in state.albums) {
    final name = (album['name'] as String?)?.trim();
    if (name == null || name.isEmpty) continue;
    keyed[name.toLowerCase()] = {...album, 'name': name};
  }
  for (final asset in state.assets) {
    final name = (asset['board_name'] as String?)?.trim();
    if (name == null || name.isEmpty) continue;
    final key = name.toLowerCase();
    final existing = keyed[key] ?? {'name': name, 'asset_count': 0};
    if (keyed.containsKey(key)) {
      keyed[key] = {
        ...existing,
        'cover_thumbnail_url': existing['cover_thumbnail_url'] ??
            asset['thumbnail_url'] ??
            asset['url'],
      };
      continue;
    }
    final count = existing['asset_count'] is int
        ? existing['asset_count'] as int
        : int.tryParse('${existing['asset_count']}') ?? 0;
    keyed[key] = {
      ...existing,
      'asset_count': count + 1,
      'cover_thumbnail_url': existing['cover_thumbnail_url'] ??
          asset['thumbnail_url'] ??
          asset['url'],
    };
  }
  final values = keyed.values.toList();
  values.sort((a, b) => '${a['name']}'.compareTo('${b['name']}'));
  return values;
}

void _showCreateAlbumSheet(BuildContext context, GalleryNotifier notifier) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _CreateAlbumSheet(notifier: notifier),
  );
}

class _GalleryOverviewHero extends StatelessWidget {
  final int total;
  final int inspiration;
  final int uploads;
  final int saved;
  final int featured;
  final Map<String, dynamic>? cover;

  const _GalleryOverviewHero({
    required this.total,
    required this.inspiration,
    required this.uploads,
    required this.saved,
    required this.featured,
    required this.cover,
  });

  @override
  Widget build(BuildContext context) {
    final coverUrl =
        _resolveUrl((cover?['thumbnail_url'] ?? cover?['url']) as String?);
    return UdoCard(
      color: _galleryAccent,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(children: [
          Positioned.fill(
            child: coverUrl.isEmpty
                ? Container(color: _galleryAccent)
                : Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: _galleryAccent),
                  ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.42),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const UdoBadge(
                  label: 'Memory command',
                  color: UdoDesign.gold,
                  background: Color(0x22FFFFFF)),
              const SizedBox(height: 74),
              Text('Every image becomes part of the wedding record.',
                  style: UdoDesign.serif(size: 30, color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                  '$total assets across inspiration, guest uploads, favourites and highlights.',
                  style: UdoDesign.sans(
                      size: 13, color: Colors.white70, height: 1.42)),
              const SizedBox(height: 16),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _GalleryHeroPill('$inspiration inspiration'),
                _GalleryHeroPill('$uploads uploads'),
                _GalleryHeroPill('$saved favourites'),
                _GalleryHeroPill('$featured highlights'),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _GalleryHeroPill extends StatelessWidget {
  final String label;
  const _GalleryHeroPill(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white24)),
        child: Text(label,
            style: UdoDesign.sans(
                size: 11.5, weight: FontWeight.w700, color: Colors.white)),
      );
}

class _GallerySectionHero extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String badge;

  const _GallerySectionHero({
    required this.icon,
    required this.title,
    required this.body,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) => UdoCard(
        color: _galleryAccent,
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Expanded(
                      child: Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: UdoDesign.sans(
                              size: 15,
                              weight: FontWeight.w800,
                              color: Colors.white))),
                  UdoBadge(
                      label: badge,
                      color: UdoDesign.gold,
                      background: const Color(0x22FFFFFF)),
                ]),
                const SizedBox(height: 5),
                Text(body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: UdoDesign.sans(
                        size: 12.5, color: Colors.white70, height: 1.4)),
              ])),
        ]),
      );
}

class _PinterestCard extends StatelessWidget {
  final GalleryState state;
  final VoidCallback onConnect;
  final VoidCallback onImport;
  final VoidCallback onDisconnect;
  const _PinterestCard(
      {required this.state,
      required this.onConnect,
      required this.onImport,
      required this.onDisconnect});

  @override
  Widget build(BuildContext context) {
    final configured = state.pinterestConfigured;
    final connected = state.pinterestConnected;

    String title;
    String subtitle;
    Widget? action;

    if (configured == false) {
      // The doc's own explicit ask: a graceful fallback when Pinterest
      // integration isn't set up â€” no dead-end button, just honest copy.
      title = 'Pinterest boards';
      subtitle =
          'Pinterest integration is not yet configured for this wedding.';
    } else if (connected) {
      title = 'Pinterest connected';
      subtitle = state.pinterestUsername != null
          ? '@${state.pinterestUsername}'
          : 'Connected';
      action = Row(mainAxisSize: MainAxisSize.min, children: [
        TextButton(
            onPressed: onImport,
            child:
                const Text('Import a board', style: TextStyle(fontSize: 12))),
        TextButton(
            onPressed: onDisconnect,
            child: const Text('Disconnect',
                style:
                    TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary))),
      ]);
    } else {
      title = 'Pinterest boards';
      subtitle = 'Not connected yet';
      action = TextButton(
          onPressed: onConnect,
          child: const Text('Connect Pinterest',
              style: TextStyle(fontSize: 12, color: Color(0xFFE60023))));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color(0xFFE60023).withValues(alpha: 0.05),
          Colors.white
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFFE60023).withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
                color: Color(0xFFE60023), shape: BoxShape.circle),
            child: const Icon(Icons.push_pin_outlined,
                color: Colors.white, size: 18)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.udoTextSecondary)),
          if (action != null) action,
        ])),
      ]),
    );
  }
}

class _PinterestBoardsSheet extends ConsumerWidget {
  final GalleryNotifier notifier;
  const _PinterestBoardsSheet({required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(galleryProvider);

    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Expanded(
                  child: Text('Choose a board to import',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600))),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero),
            ]),
            const SizedBox(height: 12),
            if (state.isLoadingPinterest)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                      child:
                          CircularProgressIndicator(color: AppTheme.udoGreen)))
            else if (state.pinterestBoards.isEmpty)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No boards found on this Pinterest account.',
                      style: TextStyle(
                          color: AppTheme.udoTextSecondary, fontSize: 13)))
            else
              SizedBox(
                height: 320,
                child: ListView.separated(
                  itemCount: state.pinterestBoards.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final board = state.pinterestBoards[i];
                    return ListTile(
                      leading: CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              const Color(0xFFE60023).withValues(alpha: 0.1),
                          child: const Icon(Icons.push_pin_outlined,
                              color: Color(0xFFE60023), size: 16)),
                      title: Text(board['name']?.toString() ?? 'Board',
                          style: const TextStyle(fontSize: 13)),
                      subtitle: board['pin_count'] != null
                          ? Text('${board['pin_count']} pins',
                              style: const TextStyle(fontSize: 11))
                          : null,
                      trailing: TextButton(
                        onPressed: () async {
                          final count = await notifier
                              .importPinterestBoard(board['id'].toString());
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Imported $count image${count == 1 ? '' : 's'} for inspiration')));
                          }
                        },
                        child: const Text('Import',
                            style: TextStyle(fontSize: 12)),
                      ),
                    );
                  },
                ),
              ),
          ]),
    ));
  }
}

// â”€â”€ MOMENTS TAB â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _MomentsTab extends StatelessWidget {
  final GalleryState state;
  final GalleryNotifier notifier;
  const _MomentsTab({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final items = state.assets.where((a) => a['album'] == 'moments').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _GallerySectionHero(
          icon: Icons.stars_outlined,
          title: 'Highlights',
          body:
              'Feature the moments that should lead albums, stories and recaps.',
          badge: '${items.length} moments',
        ),
        const SizedBox(height: 16),
        const Text('Moments',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        if (items.isEmpty)
          _emptyState(Icons.camera_alt_outlined, 'No moments captured yet',
              'Add a photo and tag it "Moments" to start building your timeline.')
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final asset = items[i];
              final caption = asset['caption'] as String?;
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppTheme.udoBorder)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _AssetThumb(
                          asset: asset,
                          onSaveToggle: () =>
                              notifier.toggleSaved(asset['id'] as int),
                          onFeature: () =>
                              notifier.toggleFeatured(asset['id'] as int),
                          onArchive: () => notifier.archive(asset['id'] as int),
                        )),
                        if (caption != null && caption.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(caption,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                      ]),
                ),
              );
            },
          ),
      ],
    );
  }
}

// â”€â”€ GUEST UPLOADS TAB â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GuestUploadsTab extends ConsumerStatefulWidget {
  final GalleryState state;
  final GalleryNotifier notifier;
  const _GuestUploadsTab({required this.state, required this.notifier});

  @override
  ConsumerState<_GuestUploadsTab> createState() => _GuestUploadsTabState();
}

class _GuestUploadsTabState extends ConsumerState<_GuestUploadsTab> {
  @override
  void initState() {
    super.initState();
    widget.notifier.fetchUploadLink();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final notifier = widget.notifier;
    final uploads = state.assets
        .where((a) =>
            a['uploaded_by_guest_id'] != null || a['album'] == 'guest_uploads')
        .toList();
    final photoCount = uploads.where((a) => a['type'] == 'photo').length;
    final videoCount = uploads.where((a) => a['type'] == 'video').length;
    final voiceCount = uploads.where((a) => a['type'] == 'voice').length;
    final url = state.uploadLinkUrl;
    final albums = _galleryAlbumSummaries(state);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _GallerySectionHero(
          icon: Icons.photo_library_outlined,
          title: 'Albums',
          body:
              'Create named albums for ceremony, reception, family, details and guest memories.',
          badge: '${albums.length} album${albums.length == 1 ? '' : 's'}',
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _showCreateAlbumSheet(context, notifier),
          icon: const Icon(Icons.create_new_folder_outlined, size: 18),
          label: const Text('New album'),
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppTheme.udoGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
        ),
        const SizedBox(height: 16),
        if (albums.isEmpty)
          _emptyState(Icons.photo_album_outlined, 'No albums yet',
              'Create albums like Ceremony, Reception, Family and Guest uploads.')
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.05),
            itemCount: albums.length,
            itemBuilder: (_, i) => _AlbumCard(album: albums[i]),
          ),
        const SizedBox(height: 16),
        _GallerySectionHero(
          icon: Icons.cloud_upload_outlined,
          title: 'Guest uploads',
          body:
              '$photoCount photos, $videoCount videos and $voiceCount voice notes received from guests.',
          badge: url == null ? 'Preparing link' : 'QR ready',
        ),
        const SizedBox(height: 16),
        // QR code share card â€” a real, scannable wedding-wide upload link.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.udoBorder)),
          child: Column(children: [
            const Text('Guest upload link',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            const Text(
                'Scan to share photos, videos, or voice messages from the venue â€” no app or invite needed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.udoTextSecondary,
                    height: 1.4)),
            const SizedBox(height: 14),
            if (url == null)
              const SizedBox(
                  height: 160,
                  child: Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.udoGreen)))
            else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.udoBorder)),
                child: QrImageView(
                    data: url, size: 160, backgroundColor: Colors.white),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied.')));
                },
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(
                      child: Text(url,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.udoGreen),
                          overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 6),
                  const Icon(Icons.copy_outlined,
                      size: 14, color: AppTheme.udoGreen),
                ]),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          _UploadStatChip(Icons.photo_outlined, '$photoCount', 'Photos'),
          const SizedBox(width: 10),
          _UploadStatChip(Icons.videocam_outlined, '$videoCount', 'Videos'),
          const SizedBox(width: 10),
          _UploadStatChip(Icons.mic_outlined, '$voiceCount', 'Voice'),
        ]),
        const SizedBox(height: 16),
        if (uploads.isEmpty)
          _emptyState(Icons.cloud_upload_outlined, 'No guest uploads yet',
              'Guests can share photos by scanning the code above or from their invitation link.')
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 4,
                childAspectRatio: 0.78),
            itemCount: uploads.length,
            itemBuilder: (_, i) =>
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: _AssetThumb(
                asset: uploads[i],
                onApprove: () => notifier.approve(uploads[i]['id'] as int),
                onReject: () => notifier.reject(uploads[i]['id'] as int),
                onFeature: uploads[i]['approved'] == true
                    ? () => notifier.toggleFeatured(uploads[i]['id'] as int)
                    : null,
                onArchive: uploads[i]['approved'] == true
                    ? () => notifier.archive(uploads[i]['id'] as int)
                    : null,
                showRoleBadge: true,
              )),
              const SizedBox(height: 2),
              Text(
                [
                  if ((uploads[i]['uploaded_by_role'] as String?)?.isNotEmpty ==
                      true)
                    uploads[i]['uploaded_by_role'],
                  _boardTimeAgo(uploads[i]['created_at'] as String?),
                ]
                    .where((s) => s != null && (s as String).isNotEmpty)
                    .join(' Â· '),
                style: const TextStyle(
                    fontSize: 9, color: AppTheme.udoTextSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ]),
          ),
      ],
    );
  }
}

class _UploadStatChip extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _UploadStatChip(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: AppTheme.udoCardFill,
              borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Icon(icon, color: AppTheme.udoGreen, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.udoTextSecondary)),
          ]),
        ),
      );
}

// â”€â”€ SAVED TAB â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SavedTab extends StatelessWidget {
  final GalleryState state;
  final GalleryNotifier notifier;
  const _SavedTab({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final saved = state.assets.where((a) => a['is_saved'] == true).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _GallerySectionHero(
          icon: Icons.favorite_border,
          title: 'Favourites',
          body:
              'Curate the photographs and messages that should become keepsakes.',
          badge: '${saved.length} saved',
        ),
        const SizedBox(height: 16),
        Text('${saved.length} Favourite moment${saved.length == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (_) => _MemoryBookSheet(savedAssets: saved),
          ),
          icon: const Icon(Icons.menu_book_outlined, size: 16),
          label: const Text('Create Memory Book'),
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              side: const BorderSide(color: AppTheme.udoGreen),
              foregroundColor: AppTheme.udoGreen),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: saved.isEmpty
              ? _emptyState(Icons.favorite_border, 'Nothing saved yet',
                  'Tap the heart on any photo to save it here.')
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.9),
                  itemCount: saved.length,
                  itemBuilder: (_, i) => _AssetThumb(
                      asset: saved[i],
                      onSaveToggle: () =>
                          notifier.toggleSaved(saved[i]['id'] as int)),
                ),
        ),
      ]),
    );
  }
}

class _MemoryBookSheet extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> savedAssets;
  const _MemoryBookSheet({required this.savedAssets});
  @override
  ConsumerState<_MemoryBookSheet> createState() => _MemoryBookSheetState();
}

class _MemoryBookSheetState extends ConsumerState<_MemoryBookSheet> {
  bool _includeSpeeches = true;
  bool _includeVows = true;
  bool _includeGuestbook = true;
  bool _generating = false;

  @override
  Widget build(BuildContext context) {
    final memories = ref.watch(memoriesProvider);
    final photos =
        widget.savedAssets.where((a) => a['type'] == 'photo').toList();
    final nonPhotos =
        widget.savedAssets.where((a) => a['type'] != 'photo').toList();
    final speeches =
        memories.speeches.where((s) => s['confirmed'] == true).toList();
    final vows = memories.vows.where((v) => v['is_private'] != true).toList();
    final guestbookMessages =
        memories.guestbookEntries.where((e) => e['approved'] == true).toList();

    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Expanded(
                  child: Text('Create Memory Book',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600))),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero),
            ]),
            const SizedBox(height: 4),
            const Text(
                'A real, downloadable PDF built from what you\'ve actually saved and confirmed.',
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.udoTextSecondary,
                    height: 1.4)),
            const SizedBox(height: 16),
            if (photos.isEmpty && nonPhotos.isEmpty)
              const Text(
                  'No saved photos yet â€” save some from your Gallery first.',
                  style:
                      TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary))
            else ...[
              Text('${photos.length} saved photo(s) will be included',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
              if (nonPhotos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                      '${nonPhotos.length} saved video/voice item(s) are viewable in-app but can\'t be embedded in a PDF.',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.udoTextSecondary)),
                ),
            ],
            if (speeches.isNotEmpty)
              CheckboxListTile(
                value: _includeSpeeches,
                onChanged: (v) => setState(() => _includeSpeeches = v ?? true),
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.udoGreen,
                title: Text('Include ${speeches.length} confirmed speech(es)',
                    style: const TextStyle(fontSize: 13)),
              ),
            if (vows.isNotEmpty)
              CheckboxListTile(
                value: _includeVows,
                onChanged: (v) => setState(() => _includeVows = v ?? true),
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.udoGreen,
                title: Text('Include ${vows.length} shared vow(s)',
                    style: const TextStyle(fontSize: 13)),
              ),
            if (guestbookMessages.isNotEmpty)
              CheckboxListTile(
                value: _includeGuestbook,
                onChanged: (v) => setState(() => _includeGuestbook = v ?? true),
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.udoGreen,
                title: Text(
                    'Include ${guestbookMessages.length} guestbook message(s)',
                    style: const TextStyle(fontSize: 13)),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_generating || photos.isEmpty)
                  ? null
                  : () => _generate(
                      photos,
                      _includeSpeeches ? speeches : [],
                      _includeVows ? vows : [],
                      _includeGuestbook ? guestbookMessages : []),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: AppTheme.udoGreen,
                  foregroundColor: Colors.white),
              child: _generating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Generate Memory Book'),
            ),
          ]),
    ));
  }

  Future<void> _generate(
    List<Map<String, dynamic>> photos,
    List<Map<String, dynamic>> speeches,
    List<Map<String, dynamic>> vows,
    List<Map<String, dynamic>> guestbookMessages,
  ) async {
    setState(() => _generating = true);
    try {
      final dio = Dio();
      final imageWidgets = <pw.Widget>[];
      var failedDownloads = 0;
      for (final asset in photos) {
        final url =
            _resolveUrl((asset['thumbnail_url'] ?? asset['url']) as String?);
        if (url.isEmpty) {
          failedDownloads++;
          continue;
        }
        try {
          final res = await dio.get<List<int>>(url,
              options: Options(responseType: ResponseType.bytes));
          if (res.data != null) {
            final bytes = res.data! is Uint8List
                ? res.data! as Uint8List
                : Uint8List.fromList(res.data!);
            imageWidgets.add(pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              child: pw.Image(pw.MemoryImage(bytes),
                  fit: pw.BoxFit.contain, height: 320),
            ));
          } else {
            failedDownloads++;
          }
        } catch (_) {
          failedDownloads++;
        }
      }

      final doc = pw.Document();
      doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => pw.Center(
          child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Our Wedding Memory Book',
                    style: pw.TextStyle(
                        fontSize: 28, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text(
                    '${imageWidgets.length} photo(s) Â· ${speeches.length} speech(es) Â· ${vows.length} vow(s) Â· ${guestbookMessages.length} message(s)',
                    style: const pw.TextStyle(fontSize: 12)),
              ]),
        ),
      ));

      for (final imageWidget in imageWidgets) {
        doc.addPage(pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context ctx) => pw.Center(child: imageWidget)));
      }

      if (speeches.isNotEmpty) {
        doc.addPage(pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context ctx) => [
                  pw.Header(level: 0, text: 'Speeches'),
                  for (final s in speeches)
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Text(
                            '${s['speaker_name'] ?? 'A speaker'} (${s['role'] ?? 'Guest'})')),
                ]));
      }

      if (vows.isNotEmpty) {
        doc.addPage(pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context ctx) => [
                  pw.Header(level: 0, text: 'Vows'),
                  for (final v in vows) ...[
                    pw.Text(v['title'] as String? ?? 'Vow',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text((v['draft_text'] as String?) ?? '',
                        style: const pw.TextStyle(fontSize: 11)),
                    pw.SizedBox(height: 14),
                  ],
                ]));
      }

      if (guestbookMessages.isNotEmpty) {
        doc.addPage(pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context ctx) => [
                  pw.Header(level: 0, text: 'Guestbook'),
                  for (final m in guestbookMessages)
                    pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Text(
                            '"${m['message']}" â€” ${m['guest_name'] ?? 'A guest'}',
                            style: const pw.TextStyle(fontSize: 11))),
                ]));
      }

      await Printing.layoutPdf(
          onLayout: (_) => doc.save(), name: 'Wedding-Memory-Book.pdf');
      if (mounted && failedDownloads > 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(failedDownloads == photos.length
                ? "None of the $failedDownloads photo(s) could be downloaded â€” check your connection and try again."
                : '$failedDownloads of ${photos.length} photo(s) couldn\'t be downloaded and were skipped.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Couldn't generate the memory book. Try again.")));
      }
    } finally {
      if (mounted) {
        setState(() => _generating = false);
      }
    }
  }
}

// â”€â”€ ARCHIVE TAB â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ArchiveTab extends StatefulWidget {
  final GalleryState state;
  final GalleryNotifier notifier;
  const _ArchiveTab({required this.state, required this.notifier});
  @override
  State<_ArchiveTab> createState() => _ArchiveTabState();
}

class _ArchiveTabState extends State<_ArchiveTab> {
  String? _stageFilter;

  @override
  Widget build(BuildContext context) {
    final archived =
        widget.state.assets.where((a) => a['album'] == 'archive').toList();
    final journeyGroups = (widget.state.summary['journey'] as List? ?? [])
        .whereType<Map>()
        .map((j) => Map<String, dynamic>.from(j))
        .toList();
    final journeyAssets = widget.state.assets.where((a) {
      final stage = a['journey_stage'] as String?;
      if (stage == null) return false;
      return _stageFilter == null || stage == _stageFilter;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _GallerySectionHero(
          icon: Icons.archive_outlined,
          title: 'Archive',
          body:
              'Keep hidden media and milestone-tagged memories organized without deleting anything.',
          badge: '${journeyAssets.length + archived.length} items',
        ),
        const SizedBox(height: 16),
        const Text('Archive â€“ Our Journey',
            style: TextStyle(
                fontFamily: 'Playfair',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppTheme.udoGreen)),
        const SizedBox(height: 4),
        const Text('Photos tagged to a milestone in your story.',
            style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        const SizedBox(height: 12),
        if (journeyGroups.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppTheme.udoCardFill,
                borderRadius: BorderRadius.circular(14)),
            child: const Text(
                'Long-press any photo to tag it with a milestone â€” Engagement, Planning, Wedding Weekend, Honeymoon, or Anniversary.',
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.udoTextSecondary,
                    height: 1.4)),
          )
        else ...[
          SizedBox(
            height: 88,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final group in journeyGroups)
                  _JourneyStageChip(
                    label: _kJourneyStageLabels[group['stage']] ??
                        group['stage'] as String,
                    count: group['count'] as int,
                    coverUrl: group['cover_thumbnail_url'] as String?,
                    selected: _stageFilter == group['stage'],
                    onTap: () => setState(() => _stageFilter =
                        _stageFilter == group['stage']
                            ? null
                            : group['stage'] as String?),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 4, crossAxisSpacing: 4),
            itemCount: journeyAssets.length,
            itemBuilder: (_, i) => _AssetThumb(asset: journeyAssets[i]),
          ),
        ],
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.udoCardFill,
              borderRadius: BorderRadius.circular(14)),
          child: const Row(children: [
            Icon(Icons.archive_outlined,
                color: AppTheme.udoTextSecondary, size: 18),
            SizedBox(width: 10),
            Expanded(
                child: Text(
                    'Removed photos are hidden from the main gallery but never deleted.',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.udoTextSecondary,
                        height: 1.4))),
          ]),
        ),
        const SizedBox(height: 12),
        const Text('Removed photos',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        if (archived.isEmpty)
          const Center(
              child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('Nothing archived yet.',
                      style: TextStyle(
                          color: AppTheme.udoTextSecondary, fontSize: 13))))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 4, crossAxisSpacing: 4),
            itemCount: archived.length,
            itemBuilder: (_, i) => _AssetThumb(asset: archived[i]),
          ),
      ],
    );
  }
}

class _JourneyStageChip extends StatelessWidget {
  final String label;
  final int count;
  final String? coverUrl;
  final bool selected;
  final VoidCallback onTap;
  const _JourneyStageChip(
      {required this.label,
      required this.count,
      required this.coverUrl,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final url = _resolveUrl(coverUrl);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 84,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.udoGreen.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? AppTheme.udoGreen : AppTheme.udoBorder),
        ),
        child: Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: url.isEmpty
                  ? Container(
                      color: AppTheme.udoCardFill,
                      child: const Icon(Icons.photo_outlined,
                          size: 18, color: AppTheme.udoTextSecondary))
                  : Image.network(url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppTheme.udoCardFill)),
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center),
          Text('$count',
              style: const TextStyle(
                  fontSize: 9, color: AppTheme.udoTextSecondary)),
        ]),
      ),
    );
  }
}

// â”€â”€ UPLOAD MODAL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _UploadModal extends StatefulWidget {
  final GalleryNotifier notifier;
  final GalleryState state;
  const _UploadModal({required this.notifier, required this.state});

  @override
  State<_UploadModal> createState() => _UploadModalState();
}

class _UploadModalState extends State<_UploadModal> {
  String _album = 'moments';
  bool _loading = false;
  XFile? _pickedFile;
  Uint8List? _pickedBytes;
  final _picker = ImagePicker();
  final _boardCtrl = TextEditingController();

  List<String> get _existingBoards => widget.state.assets
      .where((a) => a['album'] == 'inspiration')
      .map((a) => (a['board_name'] as String?)?.trim())
      .where((b) => b != null && b.isNotEmpty)
      .cast<String>()
      .toSet()
      .toList();

  List<String> get _albumNames => widget.state.albums
      .map((a) => (a['name'] as String?)?.trim())
      .where((name) => name != null && name.isNotEmpty)
      .cast<String>()
      .toSet()
      .toList()
    ..sort();

  bool get _pickedIsVideo {
    final name = _pickedFile?.name.toLowerCase() ?? '';
    return name.endsWith('.mp4') || name.endsWith('.mov');
  }

  Future<void> _pickImage() async {
    final xfile = await _picker.pickMedia(imageQuality: 85);
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() {
      _pickedFile = xfile;
      _pickedBytes = bytes;
    });
  }

  Future<void> _submit() async {
    if (_pickedFile == null) return;
    setState(() => _loading = true);
    final asset = await widget.notifier.upload(_pickedFile!, _album);
    if (asset != null && _boardCtrl.text.trim().isNotEmpty) {
      await widget.notifier.setBoardName(
        asset['id'] as int,
        _boardCtrl.text.trim(),
      );
    }
    setState(() => _loading = false);
    if (mounted) {
      if (asset != null) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload failed. Please try again.')));
      }
    }
  }

  @override
  void dispose() {
    _boardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(
                    child: Text('Add to gallery',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600))),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero),
              ]),
              const SizedBox(height: 16),
              const Text('Album',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _album,
                decoration: _dropDec(),
                items: const [
                  DropdownMenuItem(value: 'moments', child: Text('Moments')),
                  DropdownMenuItem(
                      value: 'inspiration', child: Text('Inspiration')),
                  DropdownMenuItem(value: 'archive', child: Text('Archive')),
                ],
                onChanged: (v) => setState(() => _album = v ?? 'moments'),
              ),
              if (_albumNames.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Save into album (optional)',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _albumNames
                        .map((name) => ChoiceChip(
                              label: Text(name),
                              selected: _boardCtrl.text.trim() == name,
                              selectedColor:
                                  AppTheme.udoGreen.withValues(alpha: 0.16),
                              onSelected: (_) =>
                                  setState(() => _boardCtrl.text = name),
                            ))
                        .toList()),
              ],
              if (_album == 'inspiration') ...[
                const SizedBox(height: 16),
                const Text('Board (optional)',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                    controller: _boardCtrl,
                    decoration: _dropDec()
                        .copyWith(hintText: 'e.g. Floral Inspiration')),
                if (_existingBoards.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _existingBoards
                          .map((b) => GestureDetector(
                                onTap: () =>
                                    setState(() => _boardCtrl.text = b),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                      color: AppTheme.udoCardFill,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Text(b,
                                      style: const TextStyle(fontSize: 12)),
                                ),
                              ))
                          .toList()),
                ],
              ],
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _loading ? null : _pickImage,
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: AppTheme.udoCardFill,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: _pickedFile != null
                            ? AppTheme.udoGreen
                            : AppTheme.udoBorder),
                  ),
                  child: _pickedBytes != null
                      ? (_pickedIsVideo
                          ? const Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                  Icon(Icons.videocam,
                                      size: 40, color: AppTheme.udoGreen),
                                  SizedBox(height: 10),
                                  Text('Video selected',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.udoTextSecondary)),
                                ]))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.memory(_pickedBytes!,
                                  fit: BoxFit.cover, width: double.infinity),
                            ))
                      : const Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  size: 40, color: AppTheme.udoGreen),
                              SizedBox(height: 10),
                              Text('Tap to choose a photo or video',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.udoTextSecondary)),
                            ])),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (_loading || _pickedFile == null) ? null : _submit,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    backgroundColor: AppTheme.udoGreen,
                    foregroundColor: Colors.white),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Add to gallery'),
              ),
              const SizedBox(height: 8),
            ]),
      ),
    );
  }

  InputDecoration _dropDec() => InputDecoration(
        filled: true,
        fillColor: AppTheme.udoCardFill,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}
