import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class RegistryState {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final Map<String, dynamic> summary;
  final String? error;

  const RegistryState(
      {this.isLoading = false,
      this.items = const [],
      this.summary = const {},
      this.error});

  RegistryState copyWith(
          {bool? isLoading,
          List<Map<String, dynamic>>? items,
          Map<String, dynamic>? summary,
          String? error}) =>
      RegistryState(
          isLoading: isLoading ?? this.isLoading,
          items: items ?? this.items,
          summary: summary ?? this.summary,
          error: error ?? this.error);
}

class RegistryNotifier extends StateNotifier<RegistryState> {
  final ApiClient _api;
  RegistryNotifier(this._api) : super(const RegistryState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    try {
      final itemsRes = await _api.get('/registry') as Map<String, dynamic>;
      final summaryRes =
          await _api.get('/registry/summary') as Map<String, dynamic>;
      final items =
          (itemsRes['data'] as List? ?? []).cast<Map<String, dynamic>>();
      final summary = summaryRes['data'] is Map
          ? Map<String, dynamic>.from(summaryRes['data'] as Map)
          : <String, dynamic>{};
      state = state.copyWith(isLoading: false, items: items, summary: summary);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addItem(Map<String, dynamic> data) async {
    try {
      final type = data['type'] as String? ?? 'item';
      final price = data['price'];
      final description = data['description'] ?? data['note'];
      final payload = {
        'name': data['name'] ?? '',
        'type': type,
        if (data['url'] != null) 'store_url': data['url'],
        if (data['store_url'] != null) 'store_url': data['store_url'],
        if (data['store'] != null) 'store_name': data['store'],
        if (data['category'] != null) 'category': data['category'],
        if (description != null) 'description': description,
        if (price != null) (type == 'cash_fund' ? 'fund_goal' : 'price'): price,
      };
      final res =
          await _api.post('/registry', data: payload) as Map<String, dynamic>;
      state = state.copyWith(
          items: [...state.items, res['data'] as Map<String, dynamic>]);
      await refresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Logs a gift received outside the online registry flow — e.g. cash
  /// handed over in an envelope — against a cash-fund item's raised total.
  Future<bool> recordContribution({
    required int itemId,
    required String contributorName,
    required double amount,
    String? message,
  }) async {
    try {
      await _api.post('/registry/$itemId/contributions', data: {
        'contributor_name': contributorName,
        'amount': amount,
        'payment_status': 'completed',
        if (message != null && message.trim().isNotEmpty)
          'message': message.trim(),
      });
      await refresh();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> markThanked(int contributionId, {String? channel}) async {
    try {
      await _api
          .post('/registry/contributions/$contributionId/thank-you', data: {
        if (channel != null) 'channel': channel,
      });
      await refresh();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Sends a real thank-you message through the same per-guest dispatch
  /// infrastructure invitations use, then marks the contribution thanked so
  /// the tracker and the real send stay in sync.
  Future<bool> sendThankYouMessage({
    required int contributionId,
    required int guestId,
    required String channel,
    required String subject,
    required String body,
  }) async {
    try {
      final created = await _api.post('/messages', data: {
        'subject': subject,
        'body': body,
        'channel': channel,
        'message_type': 'thank_you',
        'audience_filter': {
          'guest_ids': [guestId]
        },
      }) as Map<String, dynamic>;
      final messageId = (created['data'] as Map)['id'];
      await _api.post('/messages/$messageId/send');
      await markThanked(contributionId, channel: channel);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Bulk-sets which registry items are shown on the guest link — mirrors
  /// LogisticsNotifier's updateTransportVisibility()/
  /// updateAccommodationVisibility() for the "Registry" guest-portal picker.
  Future<bool> updateVisibility(List<int> visibleIds) async {
    try {
      final res = await _api.patch('/registry-visibility',
          data: {'visible_ids': visibleIds}) as Map<String, dynamic>;
      final updated =
          (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      state = state.copyWith(items: updated, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> refresh() => _load();
}

final registryProvider =
    StateNotifierProvider<RegistryNotifier, RegistryState>((ref) {
  return RegistryNotifier(ref.read(apiClientProvider));
});
