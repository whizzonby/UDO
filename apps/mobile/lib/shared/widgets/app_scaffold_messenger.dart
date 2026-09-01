import 'package:flutter/material.dart';

/// Root-level messenger key so auth screens can show a confirmation toast
/// (e.g. "Signed in successfully") that survives the immediate post-auth
/// router redirect to /onboarding or /home — a SnackBar anchored to the
/// screen's own Scaffold would be torn down mid-animation by that redirect.
final appScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void showAuthToast(String message) {
  appScaffoldMessengerKey.currentState
    ?..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}
