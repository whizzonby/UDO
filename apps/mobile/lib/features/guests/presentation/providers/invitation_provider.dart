import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class InvitationState {
  final bool isLoading;
  final bool isSaving;
  final bool isPublishing;
  final Map<String, dynamic>? invitation;
  final Map<String, dynamic>? wedding;
  final String? error;

  const InvitationState({
    this.isLoading = false,
    this.isSaving = false,
    this.isPublishing = false,
    this.invitation,
    this.wedding,
    this.error,
  });

  InvitationState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isPublishing,
    Map<String, dynamic>? invitation,
    Map<String, dynamic>? wedding,
    String? error,
  }) =>
      InvitationState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        isPublishing: isPublishing ?? this.isPublishing,
        invitation: invitation ?? this.invitation,
        wedding: wedding ?? this.wedding,
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
    String? templateId,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final res = await _api.patch('/invitation', data: {
        if (titleLine != null) 'title_line': titleLine,
        if (invitationText != null) 'invitation_text': invitationText,
        if (dateText != null) 'date_text': dateText,
        if (venueText != null) 'venue_text': venueText,
        if (templateId != null) 'template_id': templateId,
      }) as Map<String, dynamic>;
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

  Future<void> refresh() => _load();
}

final invitationProvider = StateNotifierProvider<InvitationNotifier, InvitationState>((ref) {
  return InvitationNotifier(ref.read(apiClientProvider));
});
