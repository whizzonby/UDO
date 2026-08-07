import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

// ── STATE ──────────────────────────────────────────────────────────────────────

class AiAssistantState {
  final bool isLoading;
  final bool isSending;
  final List<Map<String, dynamic>> messages;
  final int usageUsed;
  final int? usageLimit;
  final bool limitReached;
  final String? error;

  const AiAssistantState({
    this.isLoading = false,
    this.isSending = false,
    this.messages = const [],
    this.usageUsed = 0,
    this.usageLimit,
    this.limitReached = false,
    this.error,
  });

  AiAssistantState copyWith({
    bool? isLoading,
    bool? isSending,
    List<Map<String, dynamic>>? messages,
    int? usageUsed,
    int? usageLimit,
    bool? limitReached,
    String? error,
  }) =>
      AiAssistantState(
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        messages: messages ?? this.messages,
        usageUsed: usageUsed ?? this.usageUsed,
        usageLimit: usageLimit ?? this.usageLimit,
        limitReached: limitReached ?? this.limitReached,
        error: error,
      );
}

// ── NOTIFIER ───────────────────────────────────────────────────────────────────

class AiAssistantNotifier extends StateNotifier<AiAssistantState> {
  final ApiClient _api;

  AiAssistantNotifier(this._api) : super(const AiAssistantState(isLoading: true)) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get('/ai-assistant') as Map<String, dynamic>;
      final logs = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      final usage = res['usage'] as Map<String, dynamic>? ?? {};
      final used = (usage['used'] as num?)?.toInt() ?? 0;
      final limit = (usage['limit'] as num?)?.toInt();
      state = state.copyWith(
        isLoading: false,
        messages: _toMessages(logs),
        usageUsed: used,
        usageLimit: limit,
        limitReached: limit != null && used >= limit,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Returns null on success, or an error message to show inline. A 402
  /// (plan limit reached) sets [AiAssistantState.limitReached] instead of a
  /// generic error, so the UI can show an upgrade prompt.
  Future<String?> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return null;

    final optimisticUser = {
      'id': null,
      'prompt': trimmed,
      'response': null,
      'created_at': DateTime.now().toIso8601String(),
    };
    state = state.copyWith(
      isSending: true,
      error: null,
      messages: [...state.messages, optimisticUser],
    );

    try {
      final res = await _api.post('/ai-assistant/chat', data: {'message': trimmed})
          as Map<String, dynamic>;
      final log = res['data'] as Map<String, dynamic>;
      final usage = res['usage'] as Map<String, dynamic>? ?? {};
      final used = (usage['used'] as num?)?.toInt() ?? state.usageUsed;
      final limit = (usage['limit'] as num?)?.toInt() ?? state.usageLimit;
      final messages = [...state.messages];
      messages[messages.length - 1] = log;
      state = state.copyWith(
        isSending: false,
        messages: messages,
        usageUsed: used,
        usageLimit: limit,
        limitReached: limit != null && used >= limit,
      );
      return null;
    } catch (e) {
      final message = e.toString();
      final isLimitError = message.contains('plan limit') || message.contains('402');
      // Drop the optimistic message that never got a real reply.
      final messages = [...state.messages]..removeLast();
      state = state.copyWith(
        isSending: false,
        messages: messages,
        limitReached: isLimitError ? true : state.limitReached,
      );
      return isLimitError
          ? "You've used all your AI assistant questions for this month."
          : message;
    }
  }

  List<Map<String, dynamic>> _toMessages(List<Map<String, dynamic>> logs) => logs;
}

// ── PROVIDER ───────────────────────────────────────────────────────────────────

final aiAssistantProvider =
    StateNotifierProvider<AiAssistantNotifier, AiAssistantState>((ref) {
  return AiAssistantNotifier(ref.read(apiClientProvider));
});
