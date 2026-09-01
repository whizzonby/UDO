import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';

class SupportState {
  final bool isLoading;
  final bool isSubmitting;
  final List<Map<String, dynamic>> tickets;
  final String? error;

  const SupportState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.tickets = const [],
    this.error,
  });

  SupportState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<Map<String, dynamic>>? tickets,
    String? error,
  }) =>
      SupportState(
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        tickets: tickets ?? this.tickets,
        error: error,
      );
}

class SupportNotifier extends StateNotifier<SupportState> {
  final ApiClient _api;

  SupportNotifier(this._api) : super(const SupportState());

  Future<void> loadTickets() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.get('/support-tickets');
      final raw = res is Map ? res['data'] : res;
      final tickets = (raw as List? ?? [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      state = state.copyWith(isLoading: false, tickets: tickets, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: humanizeError(e));
    }
  }

  Future<bool> submitTicket({
    required String subject,
    required String body,
    required String priority,
    String channel = 'in_app',
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final res = await _api.post('/support-tickets', data: {
        'subject': subject,
        'body': body,
        'priority': priority,
        'channel': channel,
      });
      final raw = res is Map ? res['data'] : res;
      final ticket = Map<String, dynamic>.from(raw as Map);
      state = state.copyWith(
        isSubmitting: false,
        tickets: [ticket, ...state.tickets],
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: humanizeError(e));
      return false;
    }
  }
}

final supportProvider =
    StateNotifierProvider<SupportNotifier, SupportState>((ref) {
  return SupportNotifier(ref.read(apiClientProvider));
});
