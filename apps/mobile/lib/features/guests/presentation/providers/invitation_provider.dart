import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class InvitationState {
  final bool isLoading;
  final bool isSaving;
  final bool isPublishing;
  final bool isCampaignSaving;
  final bool isLoadingGuestLinks;
  final bool isRetrying;
  final Map<String, dynamic>? invitation;
  final Map<String, dynamic>? wedding;
  final Map<String, dynamic>? campaignPreview;
  final Map<String, dynamic>? campaign;
  final List<Map<String, dynamic>>? guestLinks;
  final String? error;

  const InvitationState({
    this.isLoading = false,
    this.isSaving = false,
    this.isPublishing = false,
    this.isCampaignSaving = false,
    this.isLoadingGuestLinks = false,
    this.isRetrying = false,
    this.invitation,
    this.wedding,
    this.campaignPreview,
    this.campaign,
    this.guestLinks,
    this.error,
  });

  InvitationState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isPublishing,
    bool? isCampaignSaving,
    bool? isLoadingGuestLinks,
    bool? isRetrying,
    Map<String, dynamic>? invitation,
    Map<String, dynamic>? wedding,
    Map<String, dynamic>? campaignPreview,
    Map<String, dynamic>? campaign,
    List<Map<String, dynamic>>? guestLinks,
    String? error,
  }) =>
      InvitationState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        isPublishing: isPublishing ?? this.isPublishing,
        isCampaignSaving: isCampaignSaving ?? this.isCampaignSaving,
        isLoadingGuestLinks: isLoadingGuestLinks ?? this.isLoadingGuestLinks,
        isRetrying: isRetrying ?? this.isRetrying,
        invitation: invitation ?? this.invitation,
        wedding: wedding ?? this.wedding,
        campaignPreview: campaignPreview ?? this.campaignPreview,
        campaign: campaign ?? this.campaign,
        guestLinks: guestLinks ?? this.guestLinks,
        error: error,
      );
}

class InvitationNotifier extends StateNotifier<InvitationState> {
  final ApiClient _api;
  InvitationNotifier(this._api) : super(const InvitationState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Only /invitation and /wedding are actually rendered by this screen —
      // deliberately not batched with /invitation/campaigns (gated behind
      // manage_guests, unlike this endpoint) in the same Future.wait, since a
      // failure there would previously blank this entire screen for no
      // visible reason, even though nothing here reads campaign data.
      final results = await Future.wait([
        _api.get('/invitation'),
        _api.get('/wedding'),
      ]);
      final invitation = (results[0] as Map<String, dynamic>)['data'] as Map<String, dynamic>?;
      final wedding = results[1] as Map<String, dynamic>;
      state = state.copyWith(isLoading: false, invitation: invitation, wedding: wedding);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> save({
    String? titleLine,
    String? invitationText,
    String? dateText,
    String? venueText,
    String? optionalQuote,
    String? rsvpDeadlineText,
    String? templateId,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final res = await _api.patch('/invitation', data: {
        if (titleLine != null) 'title_line': titleLine,
        if (invitationText != null) 'invitation_text': invitationText,
        if (dateText != null) 'date_text': dateText,
        if (venueText != null) 'venue_text': venueText,
        if (optionalQuote != null) 'optional_quote': optionalQuote,
        if (rsvpDeadlineText != null) 'rsvp_deadline_text': rsvpDeadlineText,
        if (templateId != null) 'template_id': templateId,
      }) as Map<String, dynamic>;
      state = state.copyWith(isSaving: false, invitation: res['data'] as Map<String, dynamic>?);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  /// Uploads an invitation the couple already designed elsewhere (image or
  /// PDF) so it can be used in place of the in-app template for
  /// Design/Wording/Preview — see InvitationController::importAsset.
  Future<bool> importAsset(List<int> bytes, String filename) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final res = await _api.post('/invitation/import', data: formData) as Map<String, dynamic>;
      state = state.copyWith(isSaving: false, invitation: res['data'] as Map<String, dynamic>?);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> removeImportedAsset() async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final res = await _api.delete('/invitation/import') as Map<String, dynamic>;
      state = state.copyWith(isSaving: false, invitation: res['data'] as Map<String, dynamic>?);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> publish() async {
    state = state.copyWith(isPublishing: true, error: null);
    try {
      final res = await _api.post('/invitation/publish') as Map<String, dynamic>;
      state = state.copyWith(isPublishing: false, invitation: res['data'] as Map<String, dynamic>?);
      return true;
    } catch (e) {
      state = state.copyWith(isPublishing: false, error: e.toString());
      return false;
    }
  }

  /// Starts a fresh campaign draft — called when the wizard opens, so each
  /// "Send invitations" session creates its own new campaign rather than
  /// silently resuming a previously sent one.
  void resetCampaignDraft() {
    state = InvitationState(
      invitation: state.invitation,
      wedding: state.wedding,
      campaign: null,
      campaignPreview: null,
      guestLinks: null,
    );
  }

  Future<Map<String, dynamic>?> previewAudience(
    Map<String, dynamic> filter, {
    String subject = '',
    String body = '',
  }) async {
    state = state.copyWith(isCampaignSaving: true, error: null);
    try {
      final res = await _api.post('/invitation/campaigns/preview', data: {
        'audience_filter': filter,
        if (subject.isNotEmpty) 'subject': subject,
        if (body.isNotEmpty) 'body': body,
      }) as Map<String, dynamic>;
      final preview = Map<String, dynamic>.from(res['data'] as Map);
      state = state.copyWith(isCampaignSaving: false, campaignPreview: preview);
      return preview;
    } catch (e) {
      state = state.copyWith(isCampaignSaving: false, error: e.toString());
      return null;
    }
  }

  /// Creates the campaign as a draft on first call, then PATCHes the same
  /// draft on every subsequent call as the user moves through the wizard —
  /// so Recipients/Design/Wording/Send all edit one real `Message` row
  /// instead of leaving orphaned drafts behind.
  Future<bool> saveDraft({
    required String campaignName,
    required String subject,
    required String body,
    required String channel,
    required Map<String, dynamic> filter,
    String campaignType = 'invitation',
    String? templateId,
    DateTime? scheduledAt,
  }) async {
    state = state.copyWith(isCampaignSaving: true, error: null);
    final payload = {
      'campaign_name': campaignName,
      'campaign_type': campaignType,
      'template_id': templateId,
      'subject': subject,
      'body': body,
      'channel': channel,
      'audience_filter': filter,
      if (scheduledAt != null) 'scheduled_at': scheduledAt.toIso8601String(),
    };
    try {
      final existingId = state.campaign?['id'];
      final Map<String, dynamic> res;
      if (existingId == null) {
        res = await _api.post('/invitation/campaigns', data: payload) as Map<String, dynamic>;
      } else {
        res = await _api.patch('/invitation/campaigns/$existingId', data: payload) as Map<String, dynamic>;
      }
      final campaign = Map<String, dynamic>.from(res['data'] as Map);
      final preview = res['preview'] != null ? Map<String, dynamic>.from(res['preview'] as Map) : state.campaignPreview;
      state = state.copyWith(isCampaignSaving: false, campaign: campaign, campaignPreview: preview);
      return true;
    } catch (e) {
      state = state.copyWith(isCampaignSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> sendCampaign() async {
    final campaignId = state.campaign?['id'];
    if (campaignId == null) return false;
    state = state.copyWith(isCampaignSaving: true, error: null);
    try {
      final res = await _api.post('/invitation/campaigns/$campaignId/send', data: {'force': true}) as Map<String, dynamic>;
      final campaign = Map<String, dynamic>.from(res['data'] as Map);
      state = state.copyWith(isCampaignSaving: false, campaign: campaign);
      return true;
    } catch (e) {
      state = state.copyWith(isCampaignSaving: false, error: e.toString());
      return false;
    }
  }

  Future<void> refreshCampaignStatus() async {
    final campaignId = state.campaign?['id'];
    if (campaignId == null) return;
    try {
      final res = await _api.get('/invitation/campaigns/$campaignId') as Map<String, dynamic>;
      final campaign = Map<String, dynamic>.from(res['data'] as Map);
      state = state.copyWith(campaign: campaign);
    } catch (_) {
      // Best-effort refresh — keep showing the last known status on failure.
    }
  }

  Future<void> fetchGuestLinks() async {
    final campaignId = state.campaign?['id'];
    if (campaignId == null) return;
    state = state.copyWith(isLoadingGuestLinks: true, error: null);
    try {
      final res = await _api.get('/invitation/campaigns/$campaignId/guest-links') as Map<String, dynamic>;
      final links = (res['data'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      state = state.copyWith(isLoadingGuestLinks: false, guestLinks: links);
    } catch (e) {
      state = state.copyWith(isLoadingGuestLinks: false, error: e.toString());
    }
  }

  Future<bool> retryFailedDeliveries() async {
    final campaignId = state.campaign?['id'];
    if (campaignId == null) return false;
    state = state.copyWith(isRetrying: true, error: null);
    try {
      await _api.post('/messages/$campaignId/retry-failed');
      await refreshCampaignStatus();
      state = state.copyWith(isRetrying: false);
      return true;
    } catch (e) {
      state = state.copyWith(isRetrying: false, error: e.toString());
      return false;
    }
  }

  Future<void> refresh() => _load();
}

final invitationProvider = StateNotifierProvider<InvitationNotifier, InvitationState>((ref) {
  return InvitationNotifier(ref.read(apiClientProvider));
});
