import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

// ── STATE ──────────────────────────────────────────────────────────────────────

class MessagesState {
  final bool isLoading;
  final bool isSending;
  final List<Map<String, dynamic>> history;
  final String? error;
  final String? sendError;

  const MessagesState({
    this.isLoading = false,
    this.isSending = false,
    this.history = const [],
    this.error,
    this.sendError,
  });

  MessagesState copyWith({
    bool? isLoading,
    bool? isSending,
    List<Map<String, dynamic>>? history,
    String? error,
    String? sendError,
  }) =>
      MessagesState(
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        history: history ?? this.history,
        error: error ?? this.error,
        sendError: sendError,
      );
}

// ── NOTIFIER ───────────────────────────────────────────────────────────────────

class MessagesNotifier extends StateNotifier<MessagesState> {
  final ApiClient _api;

  MessagesNotifier(this._api) : super(const MessagesState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _api.get('/messages') as Map<String, dynamic>;
      final history = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      history.sort((a, b) => (b['created_at'] ?? '')
          .toString()
          .compareTo((a['created_at'] ?? '').toString()));
      state = state.copyWith(isLoading: false, history: history);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Maps a preset audience key to the real `audience_filter` shape the
  /// backend understands ({} means "everyone", no key filters).
  Map<String, dynamic> _filterFor(String audience) {
    switch (audience) {
      case 'confirmed':
        return {'attending_status': 'yes'};
      case 'pending':
        return {'attending_status': 'pending'};
      case 'vip':
        return {'vip_flag': true};
      case 'wedding_party':
        return {'guest_group': 'wedding_party'};
      default:
        return {};
    }
  }

  /// Creates the message, then immediately sends it — a draft alone never
  /// reaches anyone, delivery only happens via the /send endpoint.
  Future<bool> sendMessage({
    required String subject,
    required String body,
    required String audience,
    required String channel,
    List<int>? guestIds,
    Map<String, dynamic>? audienceFilter,
  }) async {
    state = state.copyWith(isSending: true, sendError: null);
    try {
      final filter = audienceFilter ??
          (guestIds != null && guestIds.isNotEmpty
              ? {'guest_ids': guestIds}
              : _filterFor(audience));
      final createRes = await _api.post('/messages', data: {
        'subject': subject,
        'body': body,
        'channel': channel,
        'audience_filter': filter,
      }) as Map<String, dynamic>;
      final created = createRes['data'] as Map<String, dynamic>;

      final sendRes = await _api.post('/messages/${created['id']}/send')
          as Map<String, dynamic>;
      final sent = sendRes['data'] as Map<String, dynamic>;

      state =
          state.copyWith(isSending: false, history: [sent, ...state.history]);
      return true;
    } catch (e) {
      state = state.copyWith(isSending: false, sendError: e.toString());
      return false;
    }
  }

  Future<void> refresh() => _load();
}

// ── PROVIDER ───────────────────────────────────────────────────────────────────

final messagesProvider =
    StateNotifierProvider<MessagesNotifier, MessagesState>((ref) {
  return MessagesNotifier(ref.read(apiClientProvider));
});
