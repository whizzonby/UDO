import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
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

  AiAssistantNotifier(this._api)
      : super(const AiAssistantState(isLoading: true)) {
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
      state = state.copyWith(isLoading: false, error: humanizeError(e));
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
      // OpenAI calls can legitimately take longer than the app's default
      // 30s timeout (the backend retries up to ~180s worst case) — without
      // this override, a slow-but-successful reply looks like a failure,
      // the optimistic message vanishes, and a manual resend burns a
      // second unit of the plan's monthly quota for what the user thinks
      // was a single question. The idempotency key lets the backend treat
      // an accidental double-send of the exact same request as a no-op.
      final res = await _api.post(
        '/ai-assistant/chat',
        data: {'message': trimmed},
        receiveTimeout: const Duration(seconds: 185),
        headers: {
          'Idempotency-Key':
              'ai-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}',
        },
      ) as Map<String, dynamic>;
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
      final message = humanizeError(e);
      final isLimitError = (e is ServerException && e.statusCode == 402) ||
          message.toLowerCase().contains('plan limit') ||
          message.contains('402');
      // Drop the optimistic message that never got a real reply.
      final messages = [...state.messages]..removeLast();
      state = state.copyWith(
        isSending: false,
        messages: messages,
        limitReached: isLimitError ? true : state.limitReached,
        error: isLimitError
            ? "You've used all your Udo AI questions for this month."
            : message,
      );
      return isLimitError
          ? "You've used all your Udo AI questions for this month."
          : message;
    }
  }

  List<Map<String, dynamic>> _toMessages(List<Map<String, dynamic>> logs) =>
      logs;
}

// ── PROVIDER ───────────────────────────────────────────────────────────────────

final aiAssistantProvider =
    StateNotifierProvider<AiAssistantNotifier, AiAssistantState>((ref) {
  return AiAssistantNotifier(ref.read(apiClientProvider));
});
