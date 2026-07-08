import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/gallery_provider.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});
  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _savedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
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
      backgroundColor: AppTheme.udoBackground,
      body: Column(
        children: [
          _GalleryHeader(tabs: _tabs),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _InspirationTab(),
                _MomentsTab(state: state),
                _GuestUploadsTab(state: state, notifier: notifier),
                _SavedTab(filter: _savedFilter, onFilterChanged: (v) => setState(() => _savedFilter = v)),
                _ArchiveTab(state: state),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadModal(context, notifier),
        backgroundColor: AppTheme.udoGreen,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_photo_alternate_outlined),
      ),
    );
  }

  void _showUploadModal(BuildContext context, GalleryNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _UploadModal(notifier: notifier),
    );
  }
}

// ── HEADER ─────────────────────────────────────────────────────────────────────

class _GalleryHeader extends StatelessWidget {
  final TabController tabs;
  const _GalleryHeader({required this.tabs});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    child: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Gallery', style: TextStyle(fontFamily: 'Playfair', fontSize: 28, fontWeight: FontWeight.w500, color: AppTheme.udoGreen)),
              const SizedBox(height: 2),
              const Text('Every detail, beautifully preserved', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, fontStyle: FontStyle.italic)),
            ]),
          ),
          const SizedBox(height: 10),
          TabBar(
            controller: tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            tabs: const [Tab(text: 'Inspiration'), Tab(text: 'Moments'), Tab(text: 'Guest Uploads'), Tab(text: 'Saved'), Tab(text: 'Archive')],
            labelColor: AppTheme.udoGreen,
            unselectedLabelColor: AppTheme.udoTextSecondary,
            indicatorColor: AppTheme.udoGreen,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            dividerColor: AppTheme.udoBorder,
          ),
        ],
      ),
    ),
  );
}

// ── INSPIRATION TAB ────────────────────────────────────────────────────────────

class _InspirationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final boards = [
      ('Rustic Garden Ceremony', 127, true),
      ('Romantic Florals', 89, true),
      ('Bridal Attire Inspo', 156, false),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Pinterest connect banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFFE60023).withValues(alpha: 0.05), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE60023).withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: const BoxDecoration(color: Color(0xFFE60023), shape: BoxShape.circle), child: const Icon(Icons.push_pin_outlined, color: Colors.white, size: 18)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Pinterest boards', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Text('2 boards connected • 216 pins', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
            ])),
            TextButton(onPressed: () {}, child: const Text('Manage', style: TextStyle(fontSize: 13, color: Color(0xFFE60023)))),
          ]),
        ),
        const SizedBox(height: 12),
        for (final (name, pins, connected) in boards)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.image_outlined, color: AppTheme.udoGreen, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text('$pins pins', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
              ])),
              if (connected)
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.udoGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: const Text('Connected', style: TextStyle(fontSize: 11, color: AppTheme.udoGreen, fontWeight: FontWeight.w500)))
              else
                OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), minimumSize: Size.zero, side: const BorderSide(color: AppTheme.udoGreen)), child: const Text('Connect', style: TextStyle(fontSize: 12, color: AppTheme.udoGreen))),
            ]),
          ),
        const SizedBox(height: 8),
        const Text('Saved images', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 4, crossAxisSpacing: 4),
          itemCount: 12,
          itemBuilder: (_, i) => Container(
            decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Icon(Icons.image_outlined, color: AppTheme.udoGreen.withValues(alpha: 0.5), size: 28)),
          ),
        ),
      ],
    );
  }
}

// ── MOMENTS TAB ────────────────────────────────────────────────────────────────

class _MomentsTab extends StatelessWidget {
  final GalleryState state;
  const _MomentsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final moments = [
      ('Engagement shoot at the park', 'March 15, 2026', 24, 'Central Park'),
      ('Venue walkthrough', 'February 20, 2026', 18, 'The Botanical Gardens'),
      ('Dress shopping day', 'January 12, 2026', 31, 'Bella Bridal'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          const Expanded(child: Text('Memory albums', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('Create album', style: TextStyle(fontSize: 13))),
        ]),
        const SizedBox(height: 8),
        for (final (title, date, count, location) in moments)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                height: 120,
                decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                child: Center(child: Icon(Icons.camera_alt_outlined, size: 40, color: AppTheme.udoGreen.withValues(alpha: 0.4))),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.udoTextSecondary),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                    const Spacer(),
                    const Icon(Icons.photo_outlined, size: 14, color: AppTheme.udoTextSecondary),
                    const SizedBox(width: 4),
                    Text('$count photos', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                  ]),
                  const SizedBox(height: 4),
                  Text(date, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
                ]),
              ),
            ]),
          ),
      ],
    );
  }
}

// ── GUEST UPLOADS TAB ──────────────────────────────────────────────────────────

class _GuestUploadsTab extends StatelessWidget {
  final GalleryState state;
  final GalleryNotifier notifier;
  const _GuestUploadsTab({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final uploads = state.assets.where((a) => a['uploaded_by_guest'] == true).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // QR code share card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.udoBorder)),
          child: Row(children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.qr_code_2_outlined, size: 36, color: AppTheme.udoGreen),
            ),
            const SizedBox(width: 14),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Guest upload link', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              SizedBox(height: 2),
              Text('Share with guests so they can upload their photos directly.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary, height: 1.4)),
            ])),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), minimumSize: Size.zero),
              child: const Text('Share', style: TextStyle(fontSize: 13)),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: Text('${uploads.length} uploads', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          if (uploads.isNotEmpty) TextButton(onPressed: () {}, child: const Text('Approve all', style: TextStyle(fontSize: 13, color: AppTheme.udoGreen))),
        ]),
        const SizedBox(height: 8),
        if (uploads.isEmpty)
          Container(
            height: 200,
            decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.cloud_upload_outlined, size: 48, color: AppTheme.udoGreen),
              SizedBox(height: 12),
              Text('No guest uploads yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text('Share the link above to collect photos.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary)),
            ])),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 4, crossAxisSpacing: 4),
            itemCount: uploads.length,
            itemBuilder: (_, i) => _UploadThumb(asset: uploads[i], onApprove: () => notifier.approve(uploads[i]['id'] as int)),
          ),
      ],
    );
  }
}

class _UploadThumb extends StatelessWidget {
  final Map<String, dynamic> asset;
  final VoidCallback onApprove;
  const _UploadThumb({required this.asset, required this.onApprove});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Container(decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(4)), child: const Center(child: Icon(Icons.image_outlined, color: AppTheme.udoGreen, size: 28))),
      if (asset['approved'] != true)
        Positioned(bottom: 4, right: 4, child: GestureDetector(
          onTap: onApprove,
          child: Container(width: 24, height: 24, decoration: const BoxDecoration(color: AppTheme.udoGreen, shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 14)),
        )),
    ],
  );
}

// ── SAVED TAB ──────────────────────────────────────────────────────────────────

class _SavedTab extends StatelessWidget {
  final String filter;
  final ValueChanged<String> onFilterChanged;
  const _SavedTab({required this.filter, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    final filters = [('all', 'All'), ('florals', 'Florals'), ('attire', 'Attire'), ('venues', 'Venues'), ('decor', 'Décor')];

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            children: filters.map((f) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(f.$2, style: const TextStyle(fontSize: 13)),
                selected: filter == f.$1,
                onSelected: (_) => onFilterChanged(f.$1),
                selectedColor: AppTheme.udoGreen,
                labelStyle: TextStyle(color: filter == f.$1 ? Colors.white : AppTheme.udoTextPrimary),
                side: BorderSide(color: filter == f.$1 ? AppTheme.udoGreen : AppTheme.udoBorder),
                checkmarkColor: Colors.white,
              ),
            )).toList(),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85),
            itemCount: 8,
            itemBuilder: (_, i) => Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
              child: Column(children: [
                Expanded(child: Container(decoration: const BoxDecoration(color: Color(0xFFF3EFEA), borderRadius: BorderRadius.vertical(top: Radius.circular(14))), child: Center(child: Icon(Icons.favorite_outline, color: AppTheme.udoCrimson.withValues(alpha: 0.4), size: 32)))),
                const Padding(padding: EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Saved image', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  Text('Tap to view', style: TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
                ])),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

// ── ARCHIVE TAB ────────────────────────────────────────────────────────────────

class _ArchiveTab extends StatelessWidget {
  final GalleryState state;
  const _ArchiveTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final archived = state.assets.where((a) => a['album'] == 'archive').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(14)),
          child: const Row(children: [
            Icon(Icons.archive_outlined, color: AppTheme.udoTextSecondary, size: 18),
            SizedBox(width: 10),
            Expanded(child: Text('Archived photos are hidden from the main gallery but never deleted.', style: TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary, height: 1.4))),
          ]),
        ),
        const SizedBox(height: 16),
        if (archived.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: Text('Nothing archived yet.', style: TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13))))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 4, crossAxisSpacing: 4),
            itemCount: archived.length,
            itemBuilder: (_, i) => Container(
              decoration: BoxDecoration(color: const Color(0xFFF3EFEA), borderRadius: BorderRadius.circular(4)),
              child: Center(child: Icon(Icons.image_outlined, color: AppTheme.udoTextSecondary.withValues(alpha: 0.5), size: 28)),
            ),
          ),
      ],
    );
  }
}

// ── UPLOAD MODAL ───────────────────────────────────────────────────────────────

class _UploadModal extends StatefulWidget {
  final GalleryNotifier notifier;
  const _UploadModal({required this.notifier});

  @override
  State<_UploadModal> createState() => _UploadModalState();
}

class _UploadModalState extends State<_UploadModal> {
  String _album = 'moments';
  bool _loading = false;
  File? _pickedFile;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final xfile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile != null) setState(() => _pickedFile = File(xfile.path));
  }

  Future<void> _submit() async {
    if (_pickedFile == null) return;
    setState(() => _loading = true);
    final ok = await widget.notifier.upload(_pickedFile!, _album);
    setState(() => _loading = false);
    if (mounted) {
      if (ok) Navigator.pop(context);
      else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Add to gallery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close), padding: EdgeInsets.zero),
          ]),
          const SizedBox(height: 16),
          const Text('Album', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _album,
            decoration: _dropDec(),
            items: const [
              DropdownMenuItem(value: 'moments', child: Text('Moments')),
              DropdownMenuItem(value: 'inspiration', child: Text('Inspiration')),
              DropdownMenuItem(value: 'archive', child: Text('Archive')),
            ],
            onChanged: (v) => setState(() => _album = v ?? 'moments'),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _loading ? null : _pickImage,
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EFEA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _pickedFile != null ? AppTheme.udoGreen : AppTheme.udoBorder),
              ),
              child: _pickedFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(_pickedFile!, fit: BoxFit.cover, width: double.infinity),
                    )
                  : const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppTheme.udoGreen),
                      SizedBox(height: 10),
                      Text('Tap to choose a photo or video', style: TextStyle(fontSize: 14, color: AppTheme.udoTextSecondary)),
                    ])),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: (_loading || _pickedFile == null) ? null : _submit,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Add to gallery'),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  InputDecoration _dropDec() => InputDecoration(
    filled: true, fillColor: const Color(0xFFF3EFEA),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
