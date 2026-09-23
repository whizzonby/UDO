import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_scaffold_messenger.dart';
import '../providers/auth_provider.dart';

/// "or" divider + Continue with Google (+ Apple on iOS). Shared by the login
/// and register screens — both paths hit the same backend endpoint, which
/// creates the account when it doesn't exist yet.
class SocialAuthButtons extends ConsumerWidget {
  final bool isLoading;
  final String toastMessage;

  const SocialAuthButtons({
    super.key,
    required this.isLoading,
    this.toastMessage = 'Signed in successfully.',
  });

  Future<void> _run(BuildContext context, Future<void> Function() signIn) async {
    // A successful sign-in navigates away and disposes this widget, so grab
    // the container (which outlives it) before awaiting instead of `ref`.
    final container = ProviderScope.containerOf(context, listen: false);
    await signIn();
    if (container.read(authProvider).status == AuthStatus.authenticated) {
      showAuthToast(toastMessage);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(authProvider.notifier);
    return Column(
      children: [
        const Row(children: [
          Expanded(child: Divider(color: Color(0xFFEAE4DB))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('or',
                style:
                    TextStyle(color: AppTheme.udoTextSecondary, fontSize: 12)),
          ),
          Expanded(child: Divider(color: Color(0xFFEAE4DB))),
        ]),
        const SizedBox(height: 16),
        _SocialButton(
          icon: const SizedBox(width: 20, height: 20, child: _GoogleLogo()),
          label: 'Continue with Google',
          onTap: isLoading ? null : () => _run(context, notifier.loginWithGoogle),
        ),
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ...[
          const SizedBox(height: 12),
          _SocialButton(
            icon: const Icon(Icons.apple, size: 24, color: Colors.white),
            label: 'Continue with Apple',
            onTap: isLoading ? null : () => _run(context, notifier.loginWithApple),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            borderColor: Colors.black,
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.foregroundColor = AppTheme.udoTextPrimary,
    this.borderColor = AppTheme.udoBorder,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size(double.infinity, 52),
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: foregroundColor)),
        ],
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  static const _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#4285F4" d="M45.12 24.5c0-1.56-.14-3.06-.4-4.5H24v8.51h11.84c-.51 2.75-2.06 5.08-4.39 6.64v5.52h7.11c4.16-3.83 6.56-9.47 6.56-16.17z"/>
  <path fill="#34A853" d="M24 46c5.94 0 10.92-1.97 14.56-5.33l-7.11-5.52c-1.97 1.32-4.49 2.11-7.45 2.11-5.73 0-10.58-3.87-12.31-9.07H4.34v5.7C7.96 41.07 15.4 46 24 46z"/>
  <path fill="#FBBC05" d="M11.69 28.19c-.44-1.32-.69-2.73-.69-4.19s.25-2.87.69-4.19v-5.7H4.34C2.98 16.9 2.19 20.34 2.19 24s.79 7.1 2.15 9.89l7.35-5.7z"/>
  <path fill="#EA4335" d="M24 10.75c3.23 0 6.13 1.11 8.41 3.29l6.31-6.31C34.91 4.18 29.93 2 24 2 15.4 2 7.96 6.93 4.34 14.11l7.35 5.7c1.73-5.2 6.58-9.06 12.31-9.06z"/>
</svg>
''';

  @override
  Widget build(BuildContext context) => SvgPicture.string(_svg);
}
