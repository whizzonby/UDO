import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/experience_provider.dart';
import '../providers/guests_provider.dart';
import '../providers/invitation_provider.dart';
import 'invitation_shared.dart';

const _stepTitles = ['Recipients', 'Design', 'Wording', 'Preview', 'Send'];

const _guestPortalToggles = [
  ('show_schedule', 'Wedding schedule'),
  ('show_venue_map', 'Venue map'),
  ('show_accommodation', 'Accommodation info'),
  ('show_transport', 'Transport info'),
  ('show_dress_code', 'Dress code'),
  ('show_registry', 'Gift registry'),
];

class InvitationWizardScreen extends ConsumerStatefulWidget {
  final int initialStep;
  const InvitationWizardScreen({super.key, this.initialStep = 0});

  @override
  ConsumerState<InvitationWizardScreen> createState() => _InvitationWizardScreenState();
}

class _InvitationWizardScreenState extends ConsumerState<InvitationWizardScreen> {
  late int _step;

  // Recipients
  bool _fNotYetInvited = false;
  bool _fVip = false;
  bool _fTravelling = false;
  bool _fHasPhone = false;
  DateTime? _fAddedAfter;
  Set<int> _manualGuestIds = {};

  // Design
  String? _templateId;

  // Wording
  late final TextEditingController _titleLine;
  late final TextEditingController _introText;
  late final TextEditingController _mainWording;
  late final TextEditingController _dateText;
  late final TextEditingController _venueText;
  late final TextEditingController _rsvpDeadlineText;
  bool _wordingLoaded = false;
  bool _wordingSaving = false;
  bool _importingAsset = false;
  bool _removingImport = false;

  // Send
  String _channel = 'email';
  bool _scheduleLater = false;
  DateTime? _scheduledAt;
  bool _sending = false;

  static const _subjectTemplate = "You're invited to {{wedding_title}}";
  static const _bodyTemplate = "Hi {{first_name}}, we'd love to celebrate with you. Open your personal invitation here: {{rsvp_url}}";

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
    _titleLine = TextEditingController();
    _introText = TextEditingController();
    _mainWording = TextEditingController();
    _dateText = TextEditingController();
    _venueText = TextEditingController();
    _rsvpDeadlineText = TextEditingController();
    for (final c in [_titleLine, _introText, _mainWording, _dateText, _venueText, _rsvpDeadlineText]) {
      c.addListener(() => setState(() {}));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialStep == 0) {
        ref.read(invitationProvider.notifier).resetCampaignDraft();
      }
      _refreshPreview();
    });
  }

  @override
  void dispose() {
    for (final c in [_titleLine, _introText, _mainWording, _dateText, _venueText, _rsvpDeadlineText]) {
      c.dispose();
    }
    super.dispose();
  }

  void _seedWordingIfNeeded(Map<String, dynamic>? invitation) {
    if (_wordingLoaded) return;
    _wordingLoaded = true;
    _titleLine.text = invitation?['title_line'] as String? ?? '';
    _introText.text = invitation?['optional_quote'] as String? ?? '';
    _mainWording.text = invitation?['invitation_text'] as String? ?? '';
    _dateText.text = invitation?['date_text'] as String? ?? '';
    _venueText.text = invitation?['venue_text'] as String? ?? '';
    _rsvpDeadlineText.text = invitation?['rsvp_deadline_text'] as String? ?? '';
  }

  Map<String, dynamic> _buildFilter() {
    if (_manualGuestIds.isNotEmpty) return {'guest_ids': _manualGuestIds.toList()};
    final f = <String, dynamic>{};
    if (_fNotYetInvited) f['invite_status'] = 'not_sent';
    if (_fVip) f['vip_flag'] = true;
    if (_fTravelling) f['travel_required'] = true;
    if (_fHasPhone) f['has_phone'] = true;
    if (_fAddedAfter != null) f['added_after'] = _fAddedAfter!.toIso8601String().split('T').first;
    return f;
  }

  Future<void> _refreshPreview() async {
    await ref.read(invitationProvider.notifier).previewAudience(_buildFilter());
  }

  void _clearManualSelection() => setState(() => _manualGuestIds = {});

  void _selectWeddingParty() {
    final guests = ref.read(guestsProvider).guests;
    final ids = guests
        .where((g) => (g['wedding_party_role'] as String?)?.isNotEmpty == true)
        .map((g) => g['id'] as int)
        .toSet();
    setState(() {
      _manualGuestIds = ids;
      _fNotYetInvited = _fVip = _fTravelling = _fHasPhone = false;
      _fAddedAfter = null;
    });
    _refreshPreview();
  }

  Future<void> _pickAddedAfterDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fAddedAfter ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _fAddedAfter = picked;
      _manualGuestIds = {};
    });
    _refreshPreview();
  }

  Future<bool> _saveWording() async {
    setState(() => _wordingSaving = true);
    final ok = await ref.read(invitationProvider.notifier).save(
          titleLine: _titleLine.text.trim(),
          invitationText: _mainWording.text.trim(),
          dateText: _dateText.text.trim(),
          venueText: _venueText.text.trim(),
          optionalQuote: _introText.text.trim(),
          rsvpDeadlineText: _rsvpDeadlineText.text.trim(),
          templateId: _templateId,
        );
    if (mounted) setState(() => _wordingSaving = false);
    return ok;
  }

  Future<void> _prepareDraftForPreviewAndSend() async {
    final notifier = ref.read(invitationProvider.notifier);
    await notifier.saveDraft(
      campaignName: 'Wedding invitation campaign',
      subject: _subjectTemplate,
      body: _bodyTemplate,
      channel: _channel,
      filter: _buildFilter(),
      templateId: _templateId,
      scheduledAt: _scheduleLater ? _scheduledAt : null,
    );
    await notifier.fetchGuestLinks();
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    final notifier = ref.read(invitationProvider.notifier);
    await notifier.saveDraft(
      campaignName: 'Wedding invitation campaign',
      subject: _subjectTemplate,
      body: _bodyTemplate,
      channel: _channel,
      filter: _buildFilter(),
      templateId: _templateId,
      scheduledAt: _scheduleLater ? _scheduledAt : null,
    );
    final ok = await notifier.sendCampaign();
    if (mounted) setState(() => _sending = false);
    if (ok) await notifier.refreshCampaignStatus();
  }

  void _goTo(int step) {
    setState(() => _step = step);
    if (step == 3) _prepareDraftForPreviewAndSend();
  }

  bool _savingDraft = false;

  Future<void> _saveDraft() async {
    setState(() => _savingDraft = true);
    final notifier = ref.read(invitationProvider.notifier);
    await notifier.saveDraft(
      campaignName: 'Wedding invitation campaign',
      subject: _subjectTemplate,
      body: _bodyTemplate,
      channel: _channel,
      filter: _buildFilter(),
      templateId: _templateId,
      scheduledAt: _scheduleLater ? _scheduledAt : null,
    );
    if (!mounted) return;
    setState(() => _savingDraft = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved.')));
  }

  @override
  Widget build(BuildContext context) {
    final invState = ref.watch(invitationProvider);
    _seedWordingIfNeeded(invState.invitation);
    _templateId ??= invState.invitation?['template_id'] as String?;

    return Scaffold(
      backgroundColor: AppTheme.udoCardFill,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.udoTextPrimary,
        title: const Text('Send invitations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: _savingDraft ? null : _saveDraft,
            child: _savingDraft
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save Draft'),
          ),
        ],
      ),
      body: Column(children: [
        _StepIndicator(step: _step, onTap: (i) => i <= _step ? _goTo(i) : null),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: switch (_step) {
              0 => _buildRecipientsStep(invState),
              1 => _buildDesignStep(invState),
              2 => _buildWordingStep(invState),
              3 => _buildPreviewStep(invState),
              _ => _buildSendStep(invState),
            },
          ),
        ),
        _buildBottomBar(invState),
      ]),
    );
  }

  // ── STEP 1: RECIPIENTS ────────────────────────────────────────────────────

  Widget _buildRecipientsStep(InvitationState invState) {
    final preview = invState.campaignPreview;
    final breakdown = preview?['contact_breakdown'] as Map<String, dynamic>?;
    final recipientCount = preview?['recipient_count'] as int? ?? 0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Who should receive this?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _filterChip('Not yet invited', _manualGuestIds.isEmpty && _fNotYetInvited, () => _toggleFilter(() => _fNotYetInvited = !_fNotYetInvited)),
        _filterChip('VIP', _manualGuestIds.isEmpty && _fVip, () => _toggleFilter(() => _fVip = !_fVip)),
        _filterChip('Travelling', _manualGuestIds.isEmpty && _fTravelling, () => _toggleFilter(() => _fTravelling = !_fTravelling)),
        _filterChip('Has phone', _manualGuestIds.isEmpty && _fHasPhone, () => _toggleFilter(() => _fHasPhone = !_fHasPhone)),
        _filterChip('Wedding party', _manualGuestIds.isNotEmpty, _selectWeddingParty),
        ActionChip(
          label: Text(_fAddedAfter == null ? 'Added after...' : 'Added after ${_fAddedAfter!.month}/${_fAddedAfter!.day}'),
          onPressed: _pickAddedAfterDate,
          backgroundColor: _fAddedAfter != null ? AppTheme.udoGreen.withValues(alpha: 0.12) : AppTheme.udoCardFill,
        ),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: OutlinedButton(
          onPressed: () => _openManualPicker(context),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.udoBorder), foregroundColor: AppTheme.udoTextPrimary),
          child: const Text('Select individual guests'),
        )),
        if (_manualGuestIds.isNotEmpty) IconButton(onPressed: () { _clearManualSelection(); _refreshPreview(); }, icon: const Icon(Icons.close)),
      ]),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$recipientCount guest${recipientCount == 1 ? '' : 's'} selected', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.udoGreen)),
          if (breakdown != null) ...[
            const SizedBox(height: 8),
            Text('${breakdown['with_email'] ?? 0} with email · ${breakdown['with_phone'] ?? 0} with phone · ${breakdown['missing_contact'] ?? 0} missing contact info', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
            if ((breakdown['missing_contact'] as int? ?? 0) > 0) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Text('Fix missing information', style: TextStyle(fontSize: 12, color: AppTheme.udoCrimson, fontWeight: FontWeight.w500, decoration: TextDecoration.underline)),
              ),
            ],
          ],
        ]),
      ),
    ]);
  }

  void _toggleFilter(VoidCallback change) {
    setState(() { change(); _manualGuestIds = {}; });
    _refreshPreview();
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) => FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.udoGreen.withValues(alpha: 0.15),
        checkmarkColor: AppTheme.udoGreen,
        backgroundColor: AppTheme.udoCardFill,
        side: BorderSide(color: selected ? AppTheme.udoGreen : AppTheme.udoBorder),
      );

  void _openManualPicker(BuildContext context) {
    final guests = ref.read(guestsProvider).guests;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => StatefulBuilder(builder: (sheetContext, setSheetState) {
        return SafeArea(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(child: Text('Select guests', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
                TextButton(onPressed: () { Navigator.pop(sheetContext); setState(() {}); _refreshPreview(); }, child: const Text('Done')),
              ]),
              const Divider(),
              Expanded(child: ListView.builder(
                itemCount: guests.length,
                itemBuilder: (_, i) {
                  final g = guests[i];
                  final id = g['id'] as int;
                  final name = '${g['first_name'] ?? ''} ${g['last_name'] ?? ''}'.trim();
                  final selected = _manualGuestIds.contains(id);
                  return CheckboxListTile(
                    value: selected,
                    title: Text(name.isEmpty ? 'Guest #$id' : name),
                    subtitle: Text((g['email'] as String?) ?? (g['phone'] as String?) ?? 'No contact info', style: const TextStyle(fontSize: 12)),
                    activeColor: AppTheme.udoGreen,
                    onChanged: (v) => setSheetState(() {
                      if (v == true) {
                        _manualGuestIds.add(id);
                      } else {
                        _manualGuestIds.remove(id);
                      }
                      _fNotYetInvited = _fVip = _fTravelling = _fHasPhone = false;
                      _fAddedAfter = null;
                    }),
                  );
                },
              )),
            ]),
          ),
        ));
      }),
    );
  }

  // ── STEP 2: DESIGN ─────────────────────────────────────────────────────────

  Future<void> _pickAndImportAsset() async {
    final result = await FilePicker.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    );
    final picked = result?.files.single;
    if (picked == null || picked.bytes == null || !mounted) return;
    setState(() => _importingAsset = true);
    final ok = await ref.read(invitationProvider.notifier).importAsset(picked.bytes!, picked.name);
    if (!mounted) return;
    setState(() => _importingAsset = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Couldn't import that file. Try again."),
        backgroundColor: AppTheme.udoCrimson,
      ));
    }
  }

  Future<void> _removeImportedAsset() async {
    setState(() => _removingImport = true);
    final ok = await ref.read(invitationProvider.notifier).removeImportedAsset();
    if (!mounted) return;
    setState(() => _removingImport = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Couldn't remove the import. Try again."),
        backgroundColor: AppTheme.udoCrimson,
      ));
    }
  }

  Widget _buildDesignStep(InvitationState invState) {
    final importedUrl = invState.invitation?['imported_asset_url'] as String?;
    final importedType = invState.invitation?['imported_asset_type'] as String?;

    if (importedUrl != null && importedUrl.isNotEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Your imported design', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('This is used instead of a template for Wording and Preview.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        const SizedBox(height: 16),
        ImportedInvitationPreview(assetUrl: importedUrl, assetType: importedType),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: _importingAsset ? null : _pickAndImportAsset,
            icon: _importingAsset
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.upload_outlined, size: 16),
            label: Text(_importingAsset ? 'Uploading...' : 'Replace file'),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.udoBorder), foregroundColor: AppTheme.udoTextPrimary),
          )),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(
            onPressed: _removingImport ? null : _removeImportedAsset,
            icon: _removingImport
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.undo, size: 16),
            label: Text(_removingImport ? 'Removing...' : 'Use a template instead'),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.udoCrimson), foregroundColor: AppTheme.udoCrimson),
          )),
        ]),
      ]);
    }

    final selected = templateById(_templateId);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Choose a design', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      const Text('Pick a template, or import an invitation you already had designed.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: _importingAsset ? null : _pickAndImportAsset,
        icon: _importingAsset
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.upload_outlined, size: 16),
        label: Text(_importingAsset ? 'Uploading...' : 'Import an invitation I already designed'),
        style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 46), side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
      ),
      const SizedBox(height: 16),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85),
        itemCount: invitationTemplates.length,
        itemBuilder: (_, i) {
          final t = invitationTemplates[i];
          final isSelected = t.id == selected.id;
          return GestureDetector(
            onTap: () => setState(() => _templateId = t.id),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? t.accent.withValues(alpha: 0.08) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? t.accent : AppTheme.udoBorder, width: isSelected ? 2 : 1),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 60, height: 78, decoration: BoxDecoration(color: t.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.udoBorder)), child: Center(child: Icon(t.motif, color: t.accent, size: 30))),
                const SizedBox(height: 8),
                Text(t.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? t.accent : AppTheme.udoTextPrimary)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(t.description, style: const TextStyle(fontSize: 10, color: AppTheme.udoTextSecondary), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis)),
              ]),
            ),
          );
        },
      ),
    ]);
  }

  // ── STEP 3: WORDING ────────────────────────────────────────────────────────

  Widget _buildWordingStep(InvitationState invState) {
    final importedUrl = invState.invitation?['imported_asset_url'] as String?;
    final importedType = invState.invitation?['imported_asset_type'] as String?;

    if (importedUrl != null && importedUrl.isNotEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Wording', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text("You're using an imported design — there's no wording to edit here.", style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        const SizedBox(height: 16),
        ImportedInvitationPreview(assetUrl: importedUrl, assetType: importedType),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _removingImport ? null : _removeImportedAsset,
          icon: const Icon(Icons.undo, size: 16),
          label: Text(_removingImport ? 'Removing...' : 'Remove import & use a template instead'),
        ),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Edit Invitation Wording', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      const Text('Tap any section to edit. Your changes appear in real time.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
      const SizedBox(height: 16),
      Stack(children: [
        InvitationPreviewCard(
          template: templateById(_templateId),
          coupleNames: _titleLine.text,
          introText: _introText.text,
          mainWording: _mainWording.text,
          dateText: _dateText.text,
          venueText: _venueText.text,
          rsvpDeadlineText: _rsvpDeadlineText.text,
        ),
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () => _goTo(1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.edit_outlined, size: 13, color: AppTheme.udoTextSecondary),
                SizedBox(width: 4),
                Text('Edit design', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.udoTextSecondary)),
              ]),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 20),
      _wordingRow('Couple names', _titleLine, icon: Icons.badge_outlined, hint: "Leave blank to use your wedding's saved names"),
      _wordingRow('Tagline', _introText, icon: Icons.short_text, hint: 'e.g. Together with their families', presets: introPresets),
      _wordingRow('Invitation message', _mainWording, icon: Icons.mail_outline, hint: 'e.g. invite you to celebrate their wedding', maxLines: 3),
      _wordingRow('Event date', _dateText, icon: Icons.calendar_today_outlined, hint: 'Leave blank to use your wedding date'),
      _wordingRow('Venue', _venueText, icon: Icons.place_outlined, hint: 'Leave blank to use your wedding venue'),
      _wordingRow('RSVP deadline', _rsvpDeadlineText, icon: Icons.event_busy_outlined, hint: 'e.g. September 10, 2026'),
    ]);
  }

  Widget _wordingRow(
    String label,
    TextEditingController controller, {
    required IconData icon,
    String? hint,
    int maxLines = 1,
    Map<String, String>? presets,
  }) {
    final value = controller.text.trim();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
      child: ListTile(
        leading: Icon(icon, size: 18, color: AppTheme.udoTextSecondary),
        title: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text(
          value.isEmpty ? (hint ?? 'Tap to add') : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: value.isEmpty ? AppTheme.udoTextSecondary : AppTheme.udoTextPrimary),
        ),
        trailing: const Icon(Icons.chevron_right, size: 18, color: AppTheme.udoTextSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        onTap: () => _editWordingField(label, controller, hint: hint, maxLines: maxLines, presets: presets),
      ),
    );
  }

  void _editWordingField(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    Map<String, String>? presets,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
                TextButton(onPressed: () => Navigator.pop(sheetContext), child: const Text('Done')),
              ]),
              const SizedBox(height: 12),
              if (presets != null) ...[
                Wrap(spacing: 6, runSpacing: 6, children: presets.entries.map((e) => ActionChip(
                  label: Text(e.key, style: const TextStyle(fontSize: 11)),
                  onPressed: () => setState(() => controller.text = e.value),
                )).toList()),
                const SizedBox(height: 10),
              ],
              TextField(
                controller: controller,
                maxLines: maxLines,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13),
                  filled: true,
                  fillColor: AppTheme.udoCardFill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── STEP 4: PREVIEW ────────────────────────────────────────────────────────

  Widget _buildPreviewStep(InvitationState invState) {
    final config = ref.watch(experienceProvider).config;
    final links = invState.guestLinks ?? [];
    final firstLink = links.firstWhere((l) => l['link'] != null, orElse: () => const {})['link'] as String?;
    final importedUrl = invState.invitation?['imported_asset_url'] as String?;
    final importedType = invState.invitation?['imported_asset_type'] as String?;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      const Text('See exactly what your guest will see — this opens their real guest portal.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
      const SizedBox(height: 16),
      if (importedUrl != null && importedUrl.isNotEmpty)
        ImportedInvitationPreview(assetUrl: importedUrl, assetType: importedType)
      else
        InvitationPreviewCard(
          template: templateById(_templateId),
          coupleNames: _titleLine.text,
          introText: _introText.text,
          mainWording: _mainWording.text,
          dateText: _dateText.text,
          venueText: _venueText.text,
          rsvpDeadlineText: _rsvpDeadlineText.text,
        ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: (invState.isLoadingGuestLinks || firstLink == null) ? null : () => launchUrl(Uri.parse(firstLink), mode: LaunchMode.externalApplication),
        icon: const Icon(Icons.open_in_new, size: 16),
        label: Text(invState.isLoadingGuestLinks ? 'Preparing preview...' : (firstLink == null ? 'No recipient with a link yet' : 'Preview as guest')),
        style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 46), side: const BorderSide(color: AppTheme.udoGreen), foregroundColor: AppTheme.udoGreen),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('What your guest can do on their portal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: _guestPortalToggles.map((t) {
            final enabled = config[t.$1] == true;
            return Chip(
              label: Text(t.$2, style: TextStyle(fontSize: 11, color: enabled ? AppTheme.udoGreen : AppTheme.udoTextSecondary)),
              avatar: Icon(enabled ? Icons.check_circle : Icons.cancel_outlined, size: 14, color: enabled ? AppTheme.udoGreen : AppTheme.udoTextSecondary),
              backgroundColor: enabled ? AppTheme.udoGreen.withValues(alpha: 0.08) : AppTheme.udoCardFill,
            );
          }).toList()),
        ]),
      ),
    ]);
  }

  // ── STEP 5: SEND ───────────────────────────────────────────────────────────

  Widget _buildSendStep(InvitationState invState) {
    final campaign = invState.campaign;
    final status = campaign?['status'] as String?;
    final alreadySent = status == 'sent' || status == 'sending';
    final breakdown = invState.campaignPreview?['contact_breakdown'] as Map<String, dynamic>?;
    final recipientCount = invState.campaignPreview?['recipient_count'] as int? ?? 0;

    if (alreadySent) return _buildPostSendStatus(invState);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Delivery channel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, children: [
        ChoiceChip(label: Text('Email (${breakdown?['with_email'] ?? 0})'), selected: _channel == 'email', onSelected: (_) => setState(() => _channel = 'email')),
        ChoiceChip(label: Text('SMS (${breakdown?['with_phone'] ?? 0})'), selected: _channel == 'sms', onSelected: (_) => setState(() => _channel = 'sms')),
        ChoiceChip(label: Text('WhatsApp (${breakdown?['with_phone'] ?? 0})'), selected: _channel == 'whatsapp', onSelected: (_) => setState(() => _channel = 'whatsapp')),
      ]),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: (invState.guestLinks ?? []).isEmpty ? null : () => _showCopyLinksSheet(context, invState.guestLinks!),
        icon: const Icon(Icons.link, size: 16),
        label: const Text('Copy individual guest links'),
        style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44), side: const BorderSide(color: AppTheme.udoBorder), foregroundColor: AppTheme.udoTextPrimary),
      ),
      const SizedBox(height: 20),
      const Text('When to send', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      RadioListTile<bool>(
        value: false, groupValue: _scheduleLater, onChanged: (v) => setState(() => _scheduleLater = false),
        title: const Text('Send now'), activeColor: AppTheme.udoGreen, contentPadding: EdgeInsets.zero,
      ),
      RadioListTile<bool>(
        value: true, groupValue: _scheduleLater, onChanged: (v) => setState(() => _scheduleLater = true),
        title: const Text('Schedule for later'), activeColor: AppTheme.udoGreen, contentPadding: EdgeInsets.zero,
      ),
      if (_scheduleLater) OutlinedButton(
        onPressed: _pickScheduleDateTime,
        style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44), side: const BorderSide(color: AppTheme.udoBorder)),
        child: Text(_scheduledAt == null ? 'Choose date & time' : _scheduledAt.toString()),
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFEAF4EE), borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${invState.campaignPreview?['sample_subject'] ?? ''}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('${invState.campaignPreview?['sample_body'] ?? ''}', style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary, height: 1.4)),
        ]),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: (_sending || recipientCount == 0) ? null : _send,
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
        child: _sending
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(_scheduleLater ? 'Schedule $recipientCount invitations' : 'Send $recipientCount invitations'),
      ),
    ]);
  }

  Widget _buildPostSendStatus(InvitationState invState) {
    final summary = invState.campaign?['delivery_summary'] as Map<String, dynamic>?;
    final counts = summary?['counts'] as Map<String, dynamic>? ?? {};
    final successful = (counts['sent'] ?? 0) + (counts['delivered'] ?? 0) + (counts['opened'] ?? 0);
    final failed = (summary?['failed_count'] as int?) ?? 0;
    final status = invState.campaign?['status'] as String?;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(status == 'sending' ? Icons.hourglass_top : Icons.check_circle, color: AppTheme.udoGreen),
        const SizedBox(width: 8),
        Text(status == 'sending' ? 'Sending...' : 'Sent', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.udoBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$successful sent successfully', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.udoGreen)),
          if (failed > 0) Text('$failed could not be delivered', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.udoCrimson)),
        ]),
      ),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: OutlinedButton(
          onPressed: () => ref.read(invitationProvider.notifier).refreshCampaignStatus(),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.udoBorder)),
          child: const Text('Refresh status'),
        )),
        if (failed > 0) ...[
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton(
            onPressed: invState.isRetrying ? null : () => ref.read(invitationProvider.notifier).retryFailedDeliveries(),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.udoCrimson, foregroundColor: Colors.white),
            child: invState.isRetrying ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Retry failed'),
          )),
        ],
      ]),
      const SizedBox(height: 12),
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Return to Invitations')),
    ]);
  }

  Future<void> _pickScheduleDateTime() async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730)));
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (!mounted) return;
    setState(() => _scheduledAt = DateTime(date.year, date.month, date.day, time?.hour ?? 10, time?.minute ?? 0));
  }

  void _showCopyLinksSheet(BuildContext context, List<Map<String, dynamic>> links) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Guest links', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const Divider(),
            Expanded(child: ListView.builder(
              itemCount: links.length,
              itemBuilder: (_, i) {
                final l = links[i];
                final link = l['link'] as String?;
                return ListTile(
                  title: Text(l['name'] as String? ?? 'Guest'),
                  subtitle: link != null ? Text(link, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis) : const Text('No token yet', style: TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary)),
                  trailing: link == null ? null : IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied')));
                    },
                  ),
                );
              },
            )),
          ]),
        ),
      )),
    );
  }

  // ── BOTTOM NAV BAR ─────────────────────────────────────────────────────────

  Widget _buildBottomBar(InvitationState invState) {
    final alreadySent = (invState.campaign?['status'] as String?) == 'sent' || (invState.campaign?['status'] as String?) == 'sending';
    if (_step == 4 && alreadySent) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppTheme.udoBorder))),
      child: SafeArea(top: false, child: Row(children: [
        if (_step > 0) Expanded(child: OutlinedButton(
          onPressed: () => setState(() => _step -= 1),
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 46), side: const BorderSide(color: AppTheme.udoBorder)),
          child: const Text('Back'),
        )),
        if (_step > 0) const SizedBox(width: 10),
        if (_step < 4) Expanded(flex: 2, child: ElevatedButton(
          onPressed: invState.isCampaignSaving || _wordingSaving ? null : () => _handleContinue(),
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 46), backgroundColor: AppTheme.udoGreen, foregroundColor: Colors.white),
          child: (invState.isCampaignSaving || _wordingSaving)
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(_step == 3 ? 'Continue to send' : 'Continue'),
        )),
      ])),
    );
  }

  Future<void> _handleContinue() async {
    if (_step == 2) {
      final ok = await _saveWording();
      if (!ok) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Couldn't save your wording. Try again."), backgroundColor: AppTheme.udoCrimson));
        return;
      }
    }
    _goTo(_step + 1);
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  final ValueChanged<int> onTap;
  const _StepIndicator({required this.step, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: List.generate(_stepTitles.length, (i) {
          final done = i < step;
          final active = i == step;
          return Expanded(child: GestureDetector(
            onTap: () => onTap(i),
            child: Column(children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: done ? AppTheme.udoGreen : (active ? AppTheme.udoCrimson : AppTheme.udoCardFill),
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text('${i + 1}', style: TextStyle(fontSize: 12, color: active ? Colors.white : AppTheme.udoTextSecondary)),
              ),
              const SizedBox(height: 4),
              Text(_stepTitles[i], style: TextStyle(fontSize: 10, color: active ? AppTheme.udoCrimson : AppTheme.udoTextSecondary, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
            ]),
          ));
        })),
      );
}

// ── INVITATION EDITOR (Settings) ────────────────────────────────────────────
//
// Reached via the "Settings" action on the Invitations hero card. Purely an
// editor for how the invitation looks and reads (design, colors, wording) —
// no recipients/send steps, unlike InvitationWizardScreen above.

const _colorSchemes = [
  ('#285301', 'Classic Green'),
  ('#D45D78', 'Rose'),
  ('#1F2937', 'Charcoal'),
  ('#92400E', 'Terracotta'),
  ('#1E3A8A', 'Royal Blue'),
  ('#9D174D', 'Berry'),
];

Color _hexToColor(String hex) {
  final cleaned = hex.replaceFirst('#', '').padLeft(6, '0');
  return Color(int.parse('FF$cleaned', radix: 16));
}

class InvitationEditorScreen extends ConsumerStatefulWidget {
  const InvitationEditorScreen({super.key});

  @override
  ConsumerState<InvitationEditorScreen> createState() => _InvitationEditorScreenState();
}

class _InvitationEditorScreenState extends ConsumerState<InvitationEditorScreen> {
  late final TextEditingController _titleLine;
  late final TextEditingController _introText;
  late final TextEditingController _mainWording;
  late final TextEditingController _dateText;
  late final TextEditingController _venueText;
  late final TextEditingController _rsvpDeadlineText;
  String? _templateId;
  String _themeColor = _colorSchemes.first.$1;
  bool _seeded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleLine = TextEditingController();
    _introText = TextEditingController();
    _mainWording = TextEditingController();
    _dateText = TextEditingController();
    _venueText = TextEditingController();
    _rsvpDeadlineText = TextEditingController();
    for (final c in [_titleLine, _introText, _mainWording, _dateText, _venueText, _rsvpDeadlineText]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_titleLine, _introText, _mainWording, _dateText, _venueText, _rsvpDeadlineText]) {
      c.dispose();
    }
    super.dispose();
  }

  void _seedIfNeeded(Map<String, dynamic>? invitation, Map<String, dynamic> experienceConfig) {
    if (_seeded) return;
    _seeded = true;
    _titleLine.text = invitation?['title_line'] as String? ?? '';
    _introText.text = invitation?['optional_quote'] as String? ?? '';
    _mainWording.text = invitation?['invitation_text'] as String? ?? '';
    _dateText.text = invitation?['date_text'] as String? ?? '';
    _venueText.text = invitation?['venue_text'] as String? ?? '';
    _rsvpDeadlineText.text = invitation?['rsvp_deadline_text'] as String? ?? '';
    _templateId = invitation?['template_id'] as String?;
    final savedColor = experienceConfig['theme_color'] as String?;
    if (savedColor != null && savedColor.isNotEmpty) _themeColor = savedColor;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final invOk = await ref.read(invitationProvider.notifier).save(
          titleLine: _titleLine.text.trim(),
          invitationText: _mainWording.text.trim(),
          dateText: _dateText.text.trim(),
          venueText: _venueText.text.trim(),
          optionalQuote: _introText.text.trim(),
          rsvpDeadlineText: _rsvpDeadlineText.text.trim(),
          templateId: _templateId,
        );
    final colorOk = await ref.read(experienceProvider.notifier).saveThemeColor(_themeColor);
    if (!mounted) return;
    setState(() => _saving = false);
    if (invOk && colorOk) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Couldn't save all changes. Try again."),
        backgroundColor: AppTheme.udoCrimson,
      ));
    }
  }

  Widget _field(String label, TextEditingController controller, {String? hint, int maxLines = 1}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
          ],
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13),
              filled: true,
              fillColor: AppTheme.udoCardFill,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final invState = ref.watch(invitationProvider);
    final expState = ref.watch(experienceProvider);
    if (invState.isLoading || expState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.udoGreen)));
    }
    _seedIfNeeded(invState.invitation, expState.config);

    final baseTemplate = templateById(_templateId);
    final previewTemplate = InvitationTemplate(
      baseTemplate.id, baseTemplate.name, baseTemplate.description,
      _hexToColor(_themeColor), baseTemplate.background,
      baseTemplate.motif, baseTemplate.frame, baseTemplate.headlineFont,
      uppercaseHeadline: baseTemplate.uppercaseHeadline,
    );

    return Scaffold(
      backgroundColor: AppTheme.udoCardFill,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.udoTextPrimary,
        title: const Text('Invitation Editor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        InvitationPreviewCard(
          template: previewTemplate,
          coupleNames: _titleLine.text,
          introText: _introText.text,
          mainWording: _mainWording.text,
          dateText: _dateText.text,
          venueText: _venueText.text,
          rsvpDeadlineText: _rsvpDeadlineText.text,
        ),
        const SizedBox(height: 24),
        const Text('Design', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        InvitationTemplateStrip(
          templates: invitationTemplates,
          selected: baseTemplate,
          onTap: (t) => setState(() => _templateId = t.id),
        ),
        const SizedBox(height: 24),
        const Text('Color scheme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('This is the color guests see on your real invitation and RSVP page.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        const SizedBox(height: 12),
        Wrap(spacing: 14, runSpacing: 14, children: [
          for (final scheme in _colorSchemes)
            GestureDetector(
              onTap: () => setState(() => _themeColor = scheme.$1),
              child: Column(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _hexToColor(scheme.$1),
                    shape: BoxShape.circle,
                    border: _themeColor.toLowerCase() == scheme.$1.toLowerCase()
                        ? Border.all(color: AppTheme.udoTextPrimary, width: 3)
                        : null,
                  ),
                  child: _themeColor.toLowerCase() == scheme.$1.toLowerCase()
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
                const SizedBox(height: 4),
                Text(scheme.$2, style: const TextStyle(fontSize: 10, color: AppTheme.udoTextSecondary)),
              ]),
            ),
        ]),
        const SizedBox(height: 24),
        const Text('Wording', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('These are the real words your guests will see — nothing here is a placeholder.', style: TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary)),
        const SizedBox(height: 16),
        _field('Couple names', _titleLine, hint: "Leave blank to use your wedding's saved names"),
        const SizedBox(height: 14),
        const Text('Introduction', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: introPresets.entries.map((e) => ActionChip(
          label: Text(e.key, style: const TextStyle(fontSize: 11)),
          onPressed: () => setState(() => _introText.text = e.value),
        )).toList()),
        const SizedBox(height: 8),
        _field('', _introText, hint: 'e.g. Together with their families'),
        const SizedBox(height: 14),
        _field('Main wording', _mainWording, hint: 'e.g. invite you to celebrate their wedding', maxLines: 3),
        const SizedBox(height: 14),
        _field('Wedding date', _dateText, hint: 'Leave blank to use your wedding date'),
        const SizedBox(height: 14),
        _field('Venue', _venueText, hint: 'Leave blank to use your wedding venue'),
        const SizedBox(height: 14),
        _field('RSVP deadline', _rsvpDeadlineText, hint: 'e.g. September 10, 2026'),
        const SizedBox(height: 20),
      ]),
    );
  }
}
