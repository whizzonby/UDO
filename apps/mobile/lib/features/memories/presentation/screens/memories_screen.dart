import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/udo_design_system.dart';
import '../providers/memories_provider.dart';

const _kSpeechRoles = [
  'Best Man',
  'Maid of Honour',
  'Father of the Bride',
  'Mother of the Bride',
  'Groom',
  'Bride',
  'Friend',
  'Other'
];
const _memoriesAccent = Color(0xFFC9867A);

InputDecoration _dec(String hint) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppTheme.udoCardFill,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );

class MemoriesScreen extends ConsumerStatefulWidget {
  const MemoriesScreen({super.key});
  @override
  ConsumerState<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends ConsumerState<MemoriesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  static const _labels = [
    'Overview',
    'Speeches',
    'Vows',
    'Traditions',
    'Guestbook',
    'Photo Booth',
    'Music'
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _labels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memoriesProvider);

    return Scaffold(
      backgroundColor: UdoDesign.bg,
      appBar: AppBar(
        backgroundColor: UdoDesign.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: UdoDesign.text,
        title: Text('Memories',
            style: UdoDesign.sans(size: 17, weight: FontWeight.w700)),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: _MemoriesHero(state: state),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 0, 12),
          height: 44,
          child: TabBar(
            controller: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: _memoriesAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border:
                  Border.all(color: _memoriesAccent.withValues(alpha: 0.22)),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: const EdgeInsets.symmetric(horizontal: 14),
            tabs: _labels.map((l) => Tab(text: l)).toList(),
            labelColor: UdoDesign.text,
            unselectedLabelColor: UdoDesign.muted,
            labelStyle: UdoDesign.sans(size: 12, weight: FontWeight.w700),
            unselectedLabelStyle:
                UdoDesign.sans(size: 12, weight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: _memoriesAccent, strokeWidth: 2))
              : state.error != null
                  ? _MemoriesError(
                      message: state.error!,
                      onRetry: () =>
                          ref.read(memoriesProvider.notifier).refresh())
                  : TabBarView(controller: _tabs, children: [
                      _OverviewTab(state: state),
                      const _SpeechesTab(),
                      const _VowsTab(),
                      const _TraditionsTab(),
                      const _GuestbookTab(),
                      const _PhotoBoothTab(),
                      const _MusicTab(),
                    ]),
        ),
      ]),
    );
  }
}

class _MemoriesHero extends StatelessWidget {
  final MemoriesState state;
  const _MemoriesHero({required this.state});

  @override
  Widget build(BuildContext context) {
    final approvedEntries =
        state.guestbookEntries.where((e) => e['approved'] == true).length;
    final totalArtifacts = state.speeches.length +
        state.vows.length +
        state.traditions.length +
        approvedEntries +
        ((state.photoBooth?['vendor_name'] as String?)?.isNotEmpty == true
            ? 1
            : 0) +
        _musicCount(state);

    return UdoCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const UdoBadge(label: 'Keepsakes', color: _memoriesAccent),
          const Spacer(),
          IconButton(
            tooltip: 'Wedding Story',
            onPressed: () => context.push('/wedding-story'),
            icon:
                const Icon(Icons.auto_stories_outlined, color: _memoriesAccent),
          ),
        ]),
        const SizedBox(height: 12),
        Text('Preserve the moments people will ask about later',
            style: UdoDesign.serif(size: 35, height: 1.04)),
        const SizedBox(height: 10),
        Text(
          'Speeches, vows, traditions, guestbook notes, photo booth details and the music that marks the day.',
          style: UdoDesign.sans(size: 14, color: UdoDesign.sub, height: 1.45),
        ),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
              child: _MemoryMetric(
                  value: '$totalArtifacts', label: 'saved signals')),
          Container(width: 1, height: 40, color: UdoDesign.border),
          Expanded(
              child: _MemoryMetric(
                  value:
                      '${state.speeches.where((s) => s['confirmed'] == true).length}',
                  label: 'confirmed speeches')),
          Container(width: 1, height: 40, color: UdoDesign.border),
          Expanded(
              child: _MemoryMetric(
                  value: '$approvedEntries', label: 'guest notes')),
        ]),
      ]),
    );
  }

  int _musicCount(MemoriesState state) {
    const slots = [
      'first_dance_song',
      'parent_dance_song',
      'entrance_music',
      'exit_song',
      'cake_cutting_song',
      'bouquet_toss_song'
    ];
    return slots
        .where((key) => (state.music?[key] as String?)?.isNotEmpty == true)
        .length;
  }
}

class _MemoryMetric extends StatelessWidget {
  final String value;
  final String label;
  const _MemoryMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UdoDesign.sans(size: 15, weight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UdoDesign.sans(size: 10, color: UdoDesign.muted)),
      ]);
}

class _MemoriesError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _MemoriesError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        UdoCard(
          padding: const EdgeInsets.all(22),
          child: Column(children: [
            const Icon(Icons.error_outline,
                size: 42, color: AppTheme.udoCrimson),
            const SizedBox(height: 14),
            Text("Couldn't load Memories",
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
                    foregroundColor: Colors.white),
                child: const Text('Retry')),
          ]),
        ),
      ],
    );
  }
}

// ── OVERVIEW ─────────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final MemoriesState state;
  const _OverviewTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final confirmedSpeeches =
        state.speeches.where((s) => s['confirmed'] == true).length;
    final draftedVows = state.vows
        .where((v) =>
            (v['draft_text'] as String?)?.isNotEmpty == true ||
            v['file_path'] != null)
        .length;
    final approvedEntries =
        state.guestbookEntries.where((e) => e['approved'] == true).length;
    final pendingEntries = state.guestbookEntries.length - approvedEntries;
    final musicSlots = [
      'first_dance_song',
      'parent_dance_song',
      'entrance_music',
      'exit_song',
      'cake_cutting_song',
      'bouquet_toss_song'
    ];
    final musicSet = musicSlots
        .where((k) => (state.music?[k] as String?)?.isNotEmpty == true)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        UdoSectionHeader(
          title: 'Memory dashboard',
          subtitle: 'Plan the moments and keepsakes you want to preserve.',
          action: 'Story',
          onAction: () => context.push('/wedding-story'),
        ),
        _OverviewRow(
            Icons.mic_outlined,
            'Speeches',
            state.speeches.isEmpty
                ? 'Not started'
                : '$confirmedSpeeches of ${state.speeches.length} confirmed'),
        _OverviewRow(
            Icons.favorite_border,
            'Vows',
            state.vows.isEmpty
                ? 'Not started'
                : '$draftedVows of ${state.vows.length} drafted'),
        _OverviewRow(
            Icons.groups_outlined,
            'Traditions',
            state.traditions.isEmpty
                ? 'Not started'
                : '${state.traditions.length} planned'),
        _OverviewRow(
            Icons.menu_book_outlined,
            'Guestbook',
            state.guestbook == null
                ? 'Not started'
                : '$approvedEntries message${approvedEntries == 1 ? '' : 's'}${pendingEntries > 0 ? ' · $pendingEntries pending review' : ''}'),
        _OverviewRow(
            Icons.camera_alt_outlined,
            'Photo Booth',
            (state.photoBooth?['vendor_name'] as String?)?.isNotEmpty == true
                ? state.photoBooth!['status'] as String? ?? 'Planned'
                : 'Not started'),
        _OverviewRow(Icons.music_note_outlined, 'Music & Signature Moments',
            musicSet == 0 ? 'Not started' : '$musicSet of 6 moments set'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => context.push('/wedding-story'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppTheme.udoGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.udoGreen.withValues(alpha: 0.3))),
            child: const Row(children: [
              Icon(Icons.auto_stories_outlined, color: AppTheme.udoGreen),
              SizedBox(width: 12),
              Expanded(
                  child: Text('Your Wedding Story',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.udoGreen))),
              Icon(Icons.chevron_right, color: AppTheme.udoGreen),
            ]),
          ),
        ),
      ],
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final IconData icon;
  final String title, status;
  const _OverviewRow(this.icon, this.title, this.status);

  @override
  Widget build(BuildContext context) => UdoCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        radius: 20,
        child: Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: _memoriesAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: _memoriesAccent, size: 19)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(title,
                  style: UdoDesign.sans(size: 14, weight: FontWeight.w700))),
          const SizedBox(width: 10),
          Flexible(
              child: Text(status,
                  textAlign: TextAlign.right,
                  style: UdoDesign.sans(size: 12, color: UdoDesign.muted))),
        ]),
      );
}

Widget _emptyState(IconData icon, String title, String subtitle) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.udoBorder)),
      child: Column(children: [
        Icon(icon, size: 36, color: AppTheme.udoTextSecondary),
        const SizedBox(height: 10),
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.udoTextSecondary)),
      ]),
    );

class _VisibilityBadge extends StatelessWidget {
  final bool isPrivate;
  const _VisibilityBadge(this.isPrivate);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: (isPrivate ? Colors.orange : AppTheme.udoGreen)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(isPrivate ? Icons.lock_outline : Icons.people_outline,
              size: 11, color: isPrivate ? Colors.orange : AppTheme.udoGreen),
          const SizedBox(width: 4),
          Text(isPrivate ? 'Private' : 'Shared',
              style: TextStyle(
                  fontSize: 10,
                  color: isPrivate ? Colors.orange : AppTheme.udoGreen,
                  fontWeight: FontWeight.w500)),
        ]),
      );
}

// ── SPEECHES ─────────────────────────────────────────────────────────────────

class _SpeechesTab extends ConsumerWidget {
  const _SpeechesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memoriesProvider);
    final notifier = ref.read(memoriesProvider.notifier);
    final speeches = [...state.speeches]..sort((a, b) =>
        ((a['speaking_order'] as num?) ?? 999)
            .compareTo((b['speaking_order'] as num?) ?? 999));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.udoGreen,
        onPressed: () => _showSpeechSheet(context, notifier),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (speeches.isEmpty)
            _emptyState(Icons.mic_outlined, 'No speeches yet',
                'Add speakers, their order, and any drafts to keep track of.')
          else
            for (final speech in speeches)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.udoBorder)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Text(speech['speaker_name'] as String? ?? '',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600))),
                        _VisibilityBadge(speech['visibility'] == 'private'),
                        const SizedBox(width: 6),
                        GestureDetector(
                            onTap: () =>
                                notifier.deleteSpeech(speech['id'] as int),
                            child: const Icon(Icons.close,
                                size: 18, color: AppTheme.udoTextSecondary)),
                      ]),
                      const SizedBox(height: 6),
                      if ((speech['role'] as String?)?.isNotEmpty == true)
                        Text(speech['role'] as String,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.udoTextSecondary)),
                      const SizedBox(height: 8),
                      Row(children: [
                        GestureDetector(
                          onTap: () => notifier.updateSpeech(
                              speech['id'] as int,
                              {'confirmed': speech['confirmed'] != true}),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(
                                speech['confirmed'] == true
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 16,
                                color: speech['confirmed'] == true
                                    ? AppTheme.udoGreen
                                    : AppTheme.udoTextSecondary),
                            const SizedBox(width: 6),
                            Text(
                                speech['confirmed'] == true
                                    ? 'Confirmed'
                                    : 'Not confirmed',
                                style: const TextStyle(fontSize: 12)),
                          ]),
                        ),
                        if (speech['duration_minutes'] != null) ...[
                          const SizedBox(width: 14),
                          Text('${speech['duration_minutes']} min',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.udoTextSecondary)),
                        ],
                      ]),
                      if (speech['draft_file_path'] != null) ...[
                        const SizedBox(height: 8),
                        const Row(children: [
                          Icon(Icons.attach_file,
                              size: 14, color: AppTheme.udoGreen),
                          SizedBox(width: 4),
                          Text('Draft uploaded',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.udoGreen))
                        ]),
                      ],
                      const SizedBox(height: 8),
                      Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              onPressed: () => _showSpeechSheet(
                                  context, notifier,
                                  speech: speech),
                              child: const Text('Edit'))),
                    ]),
              ),
        ],
      ),
    );
  }

  void _showSpeechSheet(BuildContext context, MemoriesNotifier notifier,
      {Map<String, dynamic>? speech}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _SpeechSheet(notifier: notifier, speech: speech),
    );
  }
}

class _SpeechSheet extends StatefulWidget {
  final MemoriesNotifier notifier;
  final Map<String, dynamic>? speech;
  const _SpeechSheet({required this.notifier, this.speech});
  @override
  State<_SpeechSheet> createState() => _SpeechSheetState();
}

class _SpeechSheetState extends State<_SpeechSheet> {
  late final _name = TextEditingController(
      text: widget.speech?['speaker_name'] as String? ?? '');
  late final _duration = TextEditingController(
      text: widget.speech?['duration_minutes']?.toString() ?? '');
  late final _order = TextEditingController(
      text: widget.speech?['speaking_order']?.toString() ?? '');
  late final _notes =
      TextEditingController(text: widget.speech?['notes'] as String? ?? '');
  late String _role = widget.speech?['role'] as String? ?? _kSpeechRoles.first;
  late String _visibility = widget.speech?['visibility'] as String? ?? 'shared';
  XFile? _file;
  bool _saving = false;

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                                child: Text(
                                    widget.speech == null
                                        ? 'Add speech'
                                        : 'Edit speech',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600))),
                            IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                                padding: EdgeInsets.zero),
                          ]),
                          const SizedBox(height: 14),
                          TextField(
                              controller: _name,
                              decoration: _dec('Speaker name')),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: _role,
                            items: _kSpeechRoles
                                .map((r) =>
                                    DropdownMenuItem(value: r, child: Text(r)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _role = v ?? _role),
                            decoration: _dec('Role'),
                          ),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(
                                child: TextField(
                                    controller: _duration,
                                    keyboardType: TextInputType.number,
                                    decoration: _dec('Duration (min)'))),
                            const SizedBox(width: 10),
                            Expanded(
                                child: TextField(
                                    controller: _order,
                                    keyboardType: TextInputType.number,
                                    decoration: _dec('Speaking order'))),
                          ]),
                          const SizedBox(height: 10),
                          TextField(
                              controller: _notes,
                              maxLines: 3,
                              decoration: _dec('Notes')),
                          const SizedBox(height: 10),
                          Row(children: [
                            const Expanded(
                                child: Text('Visibility',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500))),
                            Switch(
                              value: _visibility == 'shared',
                              onChanged: (v) => setState(
                                  () => _visibility = v ? 'shared' : 'private'),
                              activeColor: AppTheme.udoGreen,
                            ),
                            Text(_visibility == 'shared' ? 'Shared' : 'Private',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.udoTextSecondary)),
                          ]),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (picked != null) {
                                setState(() => _file = picked);
                              }
                            },
                            icon: const Icon(Icons.attach_file, size: 16),
                            label: Text(_file != null
                                ? 'Draft selected'
                                : 'Attach a draft (optional)'),
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 44),
                                side:
                                    const BorderSide(color: AppTheme.udoGreen),
                                foregroundColor: AppTheme.udoGreen),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _saving ? null : _submit,
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                                backgroundColor: AppTheme.udoGreen,
                                foregroundColor: Colors.white),
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : Text(widget.speech == null
                                    ? 'Add speech'
                                    : 'Save changes'),
                          ),
                        ])))),
      );

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final data = {
      'speaker_name': _name.text.trim(),
      'role': _role,
      'duration_minutes': int.tryParse(_duration.text),
      'speaking_order': int.tryParse(_order.text),
      'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      'visibility': _visibility,
    };
    final ok = widget.speech == null
        ? await widget.notifier.addSpeech(data, file: _file)
        : await widget.notifier.updateSpeech(widget.speech!['id'] as int, data);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context);
  }
}

// ── VOWS ─────────────────────────────────────────────────────────────────────

class _VowsTab extends ConsumerWidget {
  const _VowsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memoriesProvider);
    final notifier = ref.read(memoriesProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.udoGreen,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => _VowSheet(notifier: notifier),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
                'Vows are private by default — only you and your partner can see them unless shared.',
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.udoTextSecondary,
                    height: 1.4)),
          ),
          if (state.vows.isEmpty)
            _emptyState(Icons.favorite_border, 'No vows yet',
                'Draft or upload each partner\'s vows here.')
          else
            for (final vow in state.vows)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.udoBorder)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Text(vow['title'] as String? ?? '',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600))),
                        _VisibilityBadge(vow['is_private'] != false),
                        const SizedBox(width: 6),
                        GestureDetector(
                            onTap: () => notifier.deleteVow(vow['id'] as int),
                            child: const Icon(Icons.close,
                                size: 18, color: AppTheme.udoTextSecondary)),
                      ]),
                      const SizedBox(height: 8),
                      Wrap(spacing: 12, runSpacing: 6, children: [
                        _StatusChip(
                            vow['is_final'] == true ? 'Final' : 'Draft',
                            vow['is_final'] == true
                                ? AppTheme.udoGreen
                                : Colors.orange),
                        if (vow['file_path'] != null)
                          const _StatusChip(
                              'Document attached', AppTheme.udoGreen),
                        if (vow['has_backup'] == true)
                          const _StatusChip('Backed up', AppTheme.udoGreen),
                        if ((vow['printing_status'] as String?)?.isNotEmpty ==
                            true)
                          _StatusChip(vow['printing_status'] as String,
                              AppTheme.udoTextSecondary),
                      ]),
                      const SizedBox(height: 8),
                      Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              notifier.markVowViewed(vow['id'] as int);
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(24))),
                                builder: (_) =>
                                    _VowSheet(notifier: notifier, vow: vow),
                              );
                            },
                            child: const Text('Edit'),
                          )),
                    ]),
              ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      );
}

class _VowSheet extends StatefulWidget {
  final MemoriesNotifier notifier;
  final Map<String, dynamic>? vow;
  const _VowSheet({required this.notifier, this.vow});
  @override
  State<_VowSheet> createState() => _VowSheetState();
}

class _VowSheetState extends State<_VowSheet> {
  late final _title =
      TextEditingController(text: widget.vow?['title'] as String? ?? '');
  late final _draft =
      TextEditingController(text: widget.vow?['draft_text'] as String? ?? '');
  late final _printing = TextEditingController(
      text: widget.vow?['printing_status'] as String? ?? '');
  late bool _isPrivate = widget.vow?['is_private'] != false;
  late bool _isFinal = widget.vow?['is_final'] == true;
  late bool _hasBackup = widget.vow?['has_backup'] == true;
  XFile? _file;
  bool _saving = false;

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                                child: Text(
                                    widget.vow == null
                                        ? 'Add vows'
                                        : 'Edit vows',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600))),
                            IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                                padding: EdgeInsets.zero),
                          ]),
                          const SizedBox(height: 14),
                          TextField(
                              controller: _title,
                              decoration:
                                  _dec('Whose vows (e.g. "Amara\'s vows")')),
                          const SizedBox(height: 10),
                          TextField(
                              controller: _draft,
                              maxLines: 6,
                              decoration: _dec('Draft text (optional)')),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (picked != null) {
                                setState(() => _file = picked);
                              }
                            },
                            icon: const Icon(Icons.attach_file, size: 16),
                            label: Text(_file != null
                                ? 'Document selected'
                                : 'Attach a document (optional)'),
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 44),
                                side:
                                    const BorderSide(color: AppTheme.udoGreen),
                                foregroundColor: AppTheme.udoGreen),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                              controller: _printing,
                              decoration: _dec('Printing status (optional)')),
                          const SizedBox(height: 10),
                          Row(children: [
                            const Expanded(
                                child: Text('Private',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500))),
                            Switch(
                                value: _isPrivate,
                                onChanged: (v) =>
                                    setState(() => _isPrivate = v),
                                activeColor: AppTheme.udoGreen)
                          ]),
                          Row(children: [
                            const Expanded(
                                child: Text('Final version',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500))),
                            Switch(
                                value: _isFinal,
                                onChanged: (v) => setState(() => _isFinal = v),
                                activeColor: AppTheme.udoGreen)
                          ]),
                          Row(children: [
                            const Expanded(
                                child: Text('Backup copy saved',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500))),
                            Switch(
                                value: _hasBackup,
                                onChanged: (v) =>
                                    setState(() => _hasBackup = v),
                                activeColor: AppTheme.udoGreen)
                          ]),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _saving ? null : _submit,
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                                backgroundColor: AppTheme.udoGreen,
                                foregroundColor: Colors.white),
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : Text(widget.vow == null
                                    ? 'Add vows'
                                    : 'Save changes'),
                          ),
                        ])))),
      );

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final data = {
      'title': _title.text.trim(),
      'draft_text': _draft.text.trim().isEmpty ? null : _draft.text.trim(),
      'is_private': _isPrivate,
      'is_final': _isFinal,
      'has_backup': _hasBackup,
      'printing_status':
          _printing.text.trim().isEmpty ? null : _printing.text.trim(),
    };
    final ok = widget.vow == null
        ? await widget.notifier.addVow(data, file: _file)
        : await widget.notifier.updateVow(widget.vow!['id'] as int, data);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context);
  }
}

// ── TRADITIONS ───────────────────────────────────────────────────────────────

class _TraditionsTab extends ConsumerWidget {
  const _TraditionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memoriesProvider);
    final notifier = ref.read(memoriesProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.udoGreen,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (_) => _TraditionSheet(notifier: notifier),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.traditions.isEmpty)
            _emptyState(Icons.groups_outlined, 'No traditions yet',
                'Track cultural and family traditions you want to include.')
          else
            for (final tradition in state.traditions)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.udoBorder)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Text(tradition['name'] as String? ?? '',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600))),
                        _VisibilityBadge(tradition['visibility'] == 'private'),
                        const SizedBox(width: 6),
                        GestureDetector(
                            onTap: () => notifier
                                .deleteTradition(tradition['id'] as int),
                            child: const Icon(Icons.close,
                                size: 18, color: AppTheme.udoTextSecondary)),
                      ]),
                      if ((tradition['description'] as String?)?.isNotEmpty ==
                          true) ...[
                        const SizedBox(height: 6),
                        Text(tradition['description'] as String,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.udoTextSecondary,
                                height: 1.4)),
                      ],
                      const SizedBox(height: 8),
                      if ((tradition['person_responsible'] as String?)
                              ?.isNotEmpty ==
                          true)
                        Text('Responsible: ${tradition['person_responsible']}',
                            style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 8),
                      Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24))),
                              builder: (_) => _TraditionSheet(
                                  notifier: notifier, tradition: tradition),
                            ),
                            child: const Text('Edit'),
                          )),
                    ]),
              ),
        ],
      ),
    );
  }
}

class _TraditionSheet extends StatefulWidget {
  final MemoriesNotifier notifier;
  final Map<String, dynamic>? tradition;
  const _TraditionSheet({required this.notifier, this.tradition});
  @override
  State<_TraditionSheet> createState() => _TraditionSheetState();
}

class _TraditionSheetState extends State<_TraditionSheet> {
  late final _name =
      TextEditingController(text: widget.tradition?['name'] as String? ?? '');
  late final _description = TextEditingController(
      text: widget.tradition?['description'] as String? ?? '');
  late final _person = TextEditingController(
      text: widget.tradition?['person_responsible'] as String? ?? '');
  late final _items = TextEditingController(
      text: widget.tradition?['required_items'] as String? ?? '');
  late final _timing =
      TextEditingController(text: widget.tradition?['timing'] as String? ?? '');
  late final _location = TextEditingController(
      text: widget.tradition?['location'] as String? ?? '');
  late String _visibility =
      widget.tradition?['visibility'] as String? ?? 'shared';
  bool _saving = false;

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                                child: Text(
                                    widget.tradition == null
                                        ? 'Add tradition'
                                        : 'Edit tradition',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600))),
                            IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                                padding: EdgeInsets.zero),
                          ]),
                          const SizedBox(height: 14),
                          TextField(
                              controller: _name,
                              decoration: _dec('Tradition name')),
                          const SizedBox(height: 10),
                          TextField(
                              controller: _description,
                              maxLines: 2,
                              decoration: _dec('Description')),
                          const SizedBox(height: 10),
                          TextField(
                              controller: _person,
                              decoration: _dec('Person responsible')),
                          const SizedBox(height: 10),
                          TextField(
                              controller: _items,
                              decoration: _dec('Required items')),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(
                                child: TextField(
                                    controller: _timing,
                                    decoration: _dec('Timing'))),
                            const SizedBox(width: 10),
                            Expanded(
                                child: TextField(
                                    controller: _location,
                                    decoration: _dec('Location'))),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            const Expanded(
                                child: Text('Visibility',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500))),
                            Switch(
                                value: _visibility == 'shared',
                                onChanged: (v) => setState(() =>
                                    _visibility = v ? 'shared' : 'private'),
                                activeColor: AppTheme.udoGreen),
                            Text(_visibility == 'shared' ? 'Shared' : 'Private',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.udoTextSecondary)),
                          ]),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _saving ? null : _submit,
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                                backgroundColor: AppTheme.udoGreen,
                                foregroundColor: Colors.white),
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : Text(widget.tradition == null
                                    ? 'Add tradition'
                                    : 'Save changes'),
                          ),
                        ])))),
      );

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final data = {
      'name': _name.text.trim(),
      'description':
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      'person_responsible':
          _person.text.trim().isEmpty ? null : _person.text.trim(),
      'required_items': _items.text.trim().isEmpty ? null : _items.text.trim(),
      'timing': _timing.text.trim().isEmpty ? null : _timing.text.trim(),
      'location': _location.text.trim().isEmpty ? null : _location.text.trim(),
      'visibility': _visibility,
    };
    final ok = widget.tradition == null
        ? await widget.notifier.addTradition(data)
        : await widget.notifier
            .updateTradition(widget.tradition!['id'] as int, data);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context);
  }
}

// ── GUESTBOOK ────────────────────────────────────────────────────────────────

class _GuestbookTab extends ConsumerStatefulWidget {
  const _GuestbookTab();
  @override
  ConsumerState<_GuestbookTab> createState() => _GuestbookTabState();
}

class _GuestbookTabState extends ConsumerState<_GuestbookTab> {
  late final _vendor = TextEditingController();
  late final _location = TextEditingController();
  late final _instructions = TextEditingController();
  String _type = 'physical';
  bool _digitalEnabled = false;
  bool _seeded = false;

  void _seed(Map<String, dynamic>? gb) {
    if (_seeded || gb == null) return;
    _vendor.text = gb['vendor_name'] as String? ?? '';
    _location.text = gb['setup_location'] as String? ?? '';
    _instructions.text = gb['instructions'] as String? ?? '';
    _type = gb['type'] as String? ?? 'physical';
    _digitalEnabled = gb['digital_enabled'] == true;
    _seeded = true;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memoriesProvider);
    final notifier = ref.read(memoriesProvider.notifier);
    _seed(state.guestbook);
    final entries = state.guestbookEntries;
    final pending = entries.where((e) => e['approved'] != true).toList();
    final approved = entries.where((e) => e['approved'] == true).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Guestbook setup',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _type,
          items: const [
            DropdownMenuItem(value: 'physical', child: Text('Physical')),
            DropdownMenuItem(value: 'digital', child: Text('Digital')),
            DropdownMenuItem(value: 'both', child: Text('Both')),
          ],
          onChanged: (v) => setState(() => _type = v ?? _type),
          decoration: _dec('Type'),
        ),
        const SizedBox(height: 10),
        TextField(controller: _vendor, decoration: _dec('Vendor (optional)')),
        const SizedBox(height: 10),
        TextField(
            controller: _location,
            decoration: _dec('Setup location (optional)')),
        const SizedBox(height: 10),
        TextField(
            controller: _instructions,
            maxLines: 2,
            decoration: _dec('Instructions (optional)')),
        const SizedBox(height: 10),
        Row(children: [
          const Expanded(
              child: Text('Enable digital guestbook via guest portal',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          Switch(
              value: _digitalEnabled,
              onChanged: (v) => setState(() => _digitalEnabled = v),
              activeColor: AppTheme.udoGreen),
        ]),
        const Text(
            'Also enable "Guest Messages" in Guests → Experience for this to appear on your guests\' portal.',
            style: TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => notifier.updateGuestbook({
            'type': _type,
            'vendor_name':
                _vendor.text.trim().isEmpty ? null : _vendor.text.trim(),
            'setup_location':
                _location.text.trim().isEmpty ? null : _location.text.trim(),
            'instructions': _instructions.text.trim().isEmpty
                ? null
                : _instructions.text.trim(),
            'digital_enabled': _digitalEnabled,
          }),
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: AppTheme.udoGreen,
              foregroundColor: Colors.white),
          child: const Text('Save setup'),
        ),
        const SizedBox(height: 24),
        Text(
            'Guest messages${pending.isNotEmpty ? ' · ${pending.length} awaiting review' : ''}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        if (entries.isEmpty)
          _emptyState(Icons.menu_book_outlined, 'No messages yet',
              'Guest messages will appear here once your digital guestbook is open.')
        else ...[
          for (final entry in pending)
            _GuestbookEntryRow(
                entry: entry, notifier: notifier, showActions: true),
          for (final entry in approved)
            _GuestbookEntryRow(
                entry: entry, notifier: notifier, showActions: false),
        ],
      ],
    );
  }
}

class _GuestbookEntryRow extends StatelessWidget {
  final Map<String, dynamic> entry;
  final MemoriesNotifier notifier;
  final bool showActions;
  const _GuestbookEntryRow(
      {required this.entry, required this.notifier, required this.showActions});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.udoBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(entry['guest_name'] as String? ?? 'A guest',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600))),
            if (entry['approved'] == true)
              const _StatusChip('Visible on portal', AppTheme.udoGreen)
            else
              const _StatusChip('Pending', Colors.orange),
          ]),
          const SizedBox(height: 6),
          Text(entry['message'] as String? ?? '',
              style: const TextStyle(fontSize: 13, height: 1.4)),
          if (showActions) ...[
            const SizedBox(height: 8),
            Row(children: [
              TextButton(
                  onPressed: () =>
                      notifier.moderateGuestbookEntry(entry['id'] as int, true),
                  child: const Text('Approve')),
              TextButton(
                  onPressed: () =>
                      notifier.deleteGuestbookEntry(entry['id'] as int),
                  child: const Text('Remove',
                      style: TextStyle(color: AppTheme.udoCrimson))),
            ]),
          ],
        ]),
      );
}

// ── PHOTO BOOTH ──────────────────────────────────────────────────────────────

class _PhotoBoothTab extends ConsumerStatefulWidget {
  const _PhotoBoothTab();
  @override
  ConsumerState<_PhotoBoothTab> createState() => _PhotoBoothTabState();
}

class _PhotoBoothTabState extends ConsumerState<_PhotoBoothTab> {
  late final _vendor = TextEditingController();
  late final _setupTime = TextEditingController();
  late final _location = TextEditingController();
  late final _props = TextEditingController();
  late final _backdrop = TextEditingController();
  late final _sharing = TextEditingController();
  String _status = '';
  bool _guestAccess = false;
  bool _seeded = false;

  void _seed(Map<String, dynamic>? pb) {
    if (_seeded || pb == null) return;
    _vendor.text = pb['vendor_name'] as String? ?? '';
    _setupTime.text = pb['setup_time'] as String? ?? '';
    _location.text = pb['location'] as String? ?? '';
    _props.text = pb['props'] as String? ?? '';
    _backdrop.text = pb['backdrop'] as String? ?? '';
    _sharing.text = pb['sharing_method'] as String? ?? '';
    _status = pb['status'] as String? ?? '';
    _guestAccess = pb['guest_access'] == true;
    _seeded = true;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memoriesProvider);
    final notifier = ref.read(memoriesProvider.notifier);
    _seed(state.photoBooth);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(controller: _vendor, decoration: _dec('Vendor')),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: TextField(
                  controller: _setupTime, decoration: _dec('Setup time'))),
          const SizedBox(width: 10),
          Expanded(
              child: TextField(
                  controller: _location, decoration: _dec('Location'))),
        ]),
        const SizedBox(height: 10),
        TextField(controller: _props, decoration: _dec('Props')),
        const SizedBox(height: 10),
        TextField(controller: _backdrop, decoration: _dec('Backdrop')),
        const SizedBox(height: 10),
        TextField(controller: _sharing, decoration: _dec('Sharing method')),
        const SizedBox(height: 10),
        TextField(
            onChanged: (v) => _status = v,
            controller: TextEditingController(text: _status),
            decoration: _dec('Status')),
        const SizedBox(height: 10),
        Row(children: [
          const Expanded(
              child: Text('Guests can access photos',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          Switch(
              value: _guestAccess,
              onChanged: (v) => setState(() => _guestAccess = v),
              activeColor: AppTheme.udoGreen),
        ]),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => notifier.updatePhotoBooth({
            'vendor_name':
                _vendor.text.trim().isEmpty ? null : _vendor.text.trim(),
            'setup_time':
                _setupTime.text.trim().isEmpty ? null : _setupTime.text.trim(),
            'location':
                _location.text.trim().isEmpty ? null : _location.text.trim(),
            'props': _props.text.trim().isEmpty ? null : _props.text.trim(),
            'backdrop':
                _backdrop.text.trim().isEmpty ? null : _backdrop.text.trim(),
            'sharing_method':
                _sharing.text.trim().isEmpty ? null : _sharing.text.trim(),
            'status': _status.trim().isEmpty ? null : _status.trim(),
            'guest_access': _guestAccess,
          }),
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: AppTheme.udoGreen,
              foregroundColor: Colors.white),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ── MUSIC ────────────────────────────────────────────────────────────────────

class _MusicTab extends ConsumerStatefulWidget {
  const _MusicTab();
  @override
  ConsumerState<_MusicTab> createState() => _MusicTabState();
}

class _MusicTabState extends ConsumerState<_MusicTab> {
  late final _firstDance = TextEditingController();
  late final _parentDance = TextEditingController();
  late final _entrance = TextEditingController();
  late final _exit = TextEditingController();
  late final _cakeCutting = TextEditingController();
  late final _bouquetToss = TextEditingController();
  List<Map<String, String>> _otherMoments = [];
  bool _seeded = false;

  void _seed(Map<String, dynamic>? m) {
    if (_seeded || m == null) return;
    _firstDance.text = m['first_dance_song'] as String? ?? '';
    _parentDance.text = m['parent_dance_song'] as String? ?? '';
    _entrance.text = m['entrance_music'] as String? ?? '';
    _exit.text = m['exit_song'] as String? ?? '';
    _cakeCutting.text = m['cake_cutting_song'] as String? ?? '';
    _bouquetToss.text = m['bouquet_toss_song'] as String? ?? '';
    _otherMoments = ((m['other_moments'] as List?) ?? [])
        .map((e) => {
              'label': (e as Map)['label']?.toString() ?? '',
              'song': e['song']?.toString() ?? '',
            })
        .toList();
    _seeded = true;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memoriesProvider);
    final notifier = ref.read(memoriesProvider.notifier);
    _seed(state.music);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
            controller: _firstDance, decoration: _dec('First dance song')),
        const SizedBox(height: 10),
        TextField(
            controller: _parentDance, decoration: _dec('Parent dance song')),
        const SizedBox(height: 10),
        TextField(controller: _entrance, decoration: _dec('Entrance music')),
        const SizedBox(height: 10),
        TextField(controller: _exit, decoration: _dec('Exit song')),
        const SizedBox(height: 10),
        TextField(
            controller: _cakeCutting, decoration: _dec('Cake-cutting song')),
        const SizedBox(height: 10),
        TextField(
            controller: _bouquetToss, decoration: _dec('Bouquet toss song')),
        const SizedBox(height: 16),
        const Text('Other signature moments',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        for (int i = 0; i < _otherMoments.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(
                  child: TextField(
                controller:
                    TextEditingController(text: _otherMoments[i]['label']),
                onChanged: (v) => _otherMoments[i]['label'] = v,
                decoration: _dec('Moment'),
              )),
              const SizedBox(width: 8),
              Expanded(
                  child: TextField(
                controller:
                    TextEditingController(text: _otherMoments[i]['song']),
                onChanged: (v) => _otherMoments[i]['song'] = v,
                decoration: _dec('Song'),
              )),
              IconButton(
                  onPressed: () => setState(() => _otherMoments.removeAt(i)),
                  icon: const Icon(Icons.close,
                      size: 18, color: AppTheme.udoTextSecondary)),
            ]),
          ),
        TextButton.icon(
          onPressed: () => setState(() => _otherMoments = [
                ..._otherMoments,
                {'label': '', 'song': ''}
              ]),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add another moment'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => notifier.updateMusic({
            'first_dance_song': _firstDance.text.trim().isEmpty
                ? null
                : _firstDance.text.trim(),
            'parent_dance_song': _parentDance.text.trim().isEmpty
                ? null
                : _parentDance.text.trim(),
            'entrance_music':
                _entrance.text.trim().isEmpty ? null : _entrance.text.trim(),
            'exit_song': _exit.text.trim().isEmpty ? null : _exit.text.trim(),
            'cake_cutting_song': _cakeCutting.text.trim().isEmpty
                ? null
                : _cakeCutting.text.trim(),
            'bouquet_toss_song': _bouquetToss.text.trim().isEmpty
                ? null
                : _bouquetToss.text.trim(),
            'other_moments': _otherMoments
                .where((m) => (m['label'] ?? '').trim().isNotEmpty)
                .toList(),
          }),
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: AppTheme.udoGreen,
              foregroundColor: Colors.white),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
