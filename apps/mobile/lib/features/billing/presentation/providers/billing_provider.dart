import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class BillingState {
  final bool isLoading;
  final bool isPurchasing;
  final bool storeAvailable;
  final ProductDetails? product;
  final String? error;

  const BillingState({
    this.isLoading = true,
    this.isPurchasing = false,
    this.storeAvailable = false,
    this.product,
    this.error,
  });

  BillingState copyWith({
    bool? isLoading,
    bool? isPurchasing,
    bool? storeAvailable,
    ProductDetails? product,
    String? error,
  }) =>
      BillingState(
        isLoading: isLoading ?? this.isLoading,
        isPurchasing: isPurchasing ?? this.isPurchasing,
        storeAvailable: storeAvailable ?? this.storeAvailable,
        product: product ?? this.product,
        error: error,
      );
}

/// Drives the native purchase flow (StoreKit / Play Billing) for the $45
/// lifetime unlock, and hands the resulting receipt/purchase token to the
/// backend's PurchaseVerificationService before treating anything as paid.
class BillingNotifier extends StateNotifier<BillingState> {
  final ApiClient _api;
  final Ref _ref;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  BillingNotifier(this._api, this._ref) : super(const BillingState()) {
    _init();
  }

  Future<void> _init() async {
    if (kIsWeb) {
      state = state.copyWith(isLoading: false, storeAvailable: false);
      return;
    }

    _subscription = _iap.purchaseStream.listen(_handlePurchaseUpdates, onError: (_) {});

    final available = await _iap.isAvailable();
    if (!available) {
      state = state.copyWith(isLoading: false, storeAvailable: false);
      return;
    }

    final response = await _iap.queryProductDetails({AppConstants.lifetimeProductId});
    state = state.copyWith(
      isLoading: false,
      storeAvailable: true,
      product: response.productDetails.isNotEmpty ? response.productDetails.first : null,
      error: response.productDetails.isEmpty ? 'Lifetime access is not set up in the store yet.' : null,
    );
  }

  Future<void> buyLifetime() async {
    final product = state.product;
    if (product == null) return;
    state = state.copyWith(isPurchasing: true, error: null);
    try {
      await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
    } catch (e) {
      state = state.copyWith(isPurchasing: false, error: e.toString());
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isPurchasing: true, error: null);
    try {
      await _iap.restorePurchases();
    } catch (e) {
      state = state.copyWith(isPurchasing: false, error: e.toString());
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          state = state.copyWith(isPurchasing: true);
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyWithBackend(purchase);
        case PurchaseStatus.error:
          state = state.copyWith(isPurchasing: false, error: purchase.error?.message ?? 'Purchase failed.');
        case PurchaseStatus.canceled:
          state = state.copyWith(isPurchasing: false);
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _verifyWithBackend(PurchaseDetails purchase) async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      final result = await _api.post('/billing/verify-purchase', data: {
        'platform': platform,
        'product_id': purchase.productID,
        if (platform == 'ios') 'receipt_data': purchase.verificationData.serverVerificationData,
        if (platform == 'android') 'purchase_token': purchase.verificationData.serverVerificationData,
      });

      final data = result is Map && result['data'] is Map ? Map<String, dynamic>.from(result['data'] as Map) : {};
      if (data['configured'] != true) {
        state = state.copyWith(isPurchasing: false, error: "Purchases aren't enabled on the server yet.");
        return;
      }

      await _ref.read(authProvider.notifier).refreshUser();
      state = state.copyWith(isPurchasing: false, error: null);
    } catch (e) {
      state = state.copyWith(isPurchasing: false, error: e.toString());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final billingProvider = StateNotifierProvider<BillingNotifier, BillingState>((ref) {
  return BillingNotifier(ref.read(apiClientProvider), ref);
});
