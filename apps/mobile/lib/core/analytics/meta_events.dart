import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fail-safe wrapper around Meta (Facebook) App Events.
///
/// The native SDK auto-logs installs and sessions from the platform config
/// (`ios/Runner/Info.plist`, `android/app/src/main/AndroidManifest.xml`). This
/// layer adds the conversion events a Meta ad campaign optimises against:
///
///   * `fb_mobile_complete_registration` — once per user, any sign-up method
///   * `fb_mobile_purchase`              — the $45 lifetime unlock, after the
///                                          backend has verified the receipt
///   * `onboarding_completed`            — custom funnel event
///
/// Every call is best-effort: analytics must never break a user flow, so all
/// failures are swallowed (surfaced only via `debugPrint` in debug builds).
class MetaEvents {
  MetaEvents._();

  static final MetaEvents instance = MetaEvents._();

  final FacebookAppEvents _fb = FacebookAppEvents();

  Future<void> _safe(String label, Future<void> Function() body) async {
    try {
      await body();
    } catch (e) {
      if (kDebugMode) debugPrint('[MetaEvents] $label failed: $e');
    }
  }

  /// Associate later events with this user id (an opaque integer, not PII) so
  /// Meta can match conversions back to the ad click. Call after every
  /// successful sign-in.
  Future<void> identify(int userId) =>
      _safe('identify', () => _fb.setUserID(userId.toString()));

  /// Drop the user association and any advanced-matching data. Call on logout
  /// and account deletion.
  Future<void> reset() => _safe('reset', () async {
        await _fb.clearUserID();
        await _fb.clearUserData();
      });

  /// Fires `fb_mobile_complete_registration` at most once per [userId] on this
  /// device. Safe to call after every sign-in regardless of whether the account
  /// is new — the backend doesn't report new-vs-returning, and Meta wants this
  /// event deduplicated.
  ///
  /// [method] is `'email'`, `'google'` or `'apple'` — Meta breaks the
  /// registration report down by it.
  Future<void> registrationCompleted({
    required int userId,
    required String method,
  }) {
    return _safe('registrationCompleted', () async {
      final prefs = await SharedPreferences.getInstance();
      final key = 'meta_reg_logged_$userId';
      if (prefs.getBool(key) ?? false) return;
      await _fb.logCompletedRegistration(registrationMethod: method);
      await prefs.setBool(key, true);
    });
  }

  /// The lifetime unlock was purchased and verified by the backend. Not called
  /// for restores (those aren't new revenue).
  Future<void> purchaseCompleted({
    required double amount,
    required String currency,
    String? transactionId,
  }) {
    return _safe(
      'purchaseCompleted',
      () => _fb.logPurchase(
        amount: amount,
        currency: currency,
        parameters: {
          if (transactionId != null)
            FacebookAppEvents.paramNameOrderId: transactionId,
        },
      ),
    );
  }

  /// Custom funnel event: the user finished onboarding (their wedding is set
  /// up). Useful as a Meta custom-conversion between install and purchase.
  Future<void> onboardingCompleted() => _safe(
        'onboardingCompleted',
        () => _fb.logEvent(name: 'onboarding_completed'),
      );

  /// Fired right before a sign-up/sign-in network call is made, so the
  /// funnel has a denominator to compare `registrationCompleted` against —
  /// without this there is no way to tell "never tried" from "tried and
  /// failed" from download-to-signup drop-off reports.
  Future<void> registrationAttempted({required String method}) => _safe(
        'registrationAttempted',
        () => _fb.logEvent(
          name: 'registration_attempted',
          parameters: {'method': method},
        ),
      );

  /// The sign-up/sign-in call failed. [reason] is truncated to keep it a
  /// short classifier tag (e.g. exception type), never raw error text that
  /// could contain user input.
  Future<void> registrationFailed({
    required String method,
    required String reason,
  }) =>
      _safe(
        'registrationFailed',
        () => _fb.logEvent(
          name: 'registration_failed',
          parameters: {
            'method': method,
            'reason': reason.length > 100 ? reason.substring(0, 100) : reason,
          },
        ),
      );

  /// Custom funnel event: the user reached onboarding step [index] (0-based)
  /// of [totalSteps]. Lets the funnel be broken down step-by-step instead of
  /// only knowing "started" vs "completed".
  Future<void> onboardingStepViewed({
    required int index,
    required int totalSteps,
  }) =>
      _safe(
        'onboardingStepViewed',
        () => _fb.logEvent(
          name: 'onboarding_step_viewed',
          parameters: {'step_index': index, 'total_steps': totalSteps},
        ),
      );

  /// The onboarding screen was left (navigated away / app backgrounded and
  /// never returned) before [onboardingCompleted] fired. [lastIndex] is the
  /// last step the user was on.
  Future<void> onboardingAbandoned({
    required int lastIndex,
    required int totalSteps,
  }) =>
      _safe(
        'onboardingAbandoned',
        () => _fb.logEvent(
          name: 'onboarding_abandoned',
          parameters: {'last_index': lastIndex, 'total_steps': totalSteps},
        ),
      );
}
