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
        sendError: sendError ?? this.sendError,
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
      state = state.copyWith(isLoading: false, history: history);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Sends a broadcast message to the specified audience.
  /// [subject] – short title; [body] – message body; [audience] – audience key
  /// (e.g. 'all', 'confirmed', 'pending', 'vip').
  Future<bool> sendMessage({
    required String subject,
    required String body,
    required String audience,
  }) async {
    state = state.copyWith(isSending: true, sendError: null);
    try {
      final res = await _api.post('/messages', data: {
        'subject': subject,
        'body': body,
        'audience': audience,
      }) as Map<String, dynamic>;

      // Prepend the new message to history if the API returns it
      final created = res['data'];
      if (created is Map<String, dynamic>) {
        state = state.copyWith(
          isSending: false,
          history: [created, ...state.history],
        );
      } else {
        state = state.copyWith(isSending: false);
        // Refresh history so the sent item appears
        _load();
      }
      return true;
    } catch (e) {
      state = state.copyWith(isSending: false, sendError: e.toString());
      return false;
    }
  }

  Future<void> refresh() => _load();
}

// ── PROVIDER ───────────────────────────────────────────────────────────────────

final messagesProvider = StateNotifierProvider<MessagesNotifier, MessagesState>((ref) {
  return MessagesNotifier(ref.read(apiClientProvider));
});
