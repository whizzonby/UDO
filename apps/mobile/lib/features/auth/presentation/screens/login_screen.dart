import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/udo_button.dart';
import '../../../../shared/widgets/udo_text_field.dart';
import '../../../../shared/widgets/app_scaffold_messenger.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_experience_shell.dart';
import '../widgets/social_auth_buttons.dart';
import 'two_factor_verify_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailCtrl.text.trim();
    final result =
        await ref.read(authProvider.notifier).login(email, _passwordCtrl.text);
    if (!mounted || result == null) return;
    if (result.requiresTwoFactor) {
      context.push('/two-factor',
          extra: TwoFactorChallenge(
            email: email,
            token: result.twoFactorToken!,
            message: result.message!,
          ));
      return;
    }
    showAuthToast('Signed in successfully.');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isLoading = auth.status == AuthStatus.loading;

    return AuthExperienceShell(
      eyebrow: 'Welcome back',
      title: 'Sign in to Udo',
      subtitle: 'Pick up right where you left off.',
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text("Don't have an account? ",
              style: TextStyle(fontSize: 14, color: AppTheme.udoTextSecondary)),
          GestureDetector(
            onTap: () => context.go('/register'),
            child: const Text('Create one',
                style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.udoGreen,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UdoTextField(
              label: 'Email',
              hint: 'you@example.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  v == null || !v.contains('@') ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 16),
            UdoTextField(
              label: 'Password',
              hint: 'Password',
              controller: _passwordCtrl,
              obscureText: _obscure,
              validator: (v) =>
                  v == null || v.length < 6 ? 'Password too short' : null,
              suffixIcon: IconButton(
                icon: Icon(_obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: const Text('Forgot password?',
                    style: TextStyle(color: AppTheme.udoGreen, fontSize: 13)),
              ),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.udoCrimson.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.udoCrimson, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(auth.error!,
                          style: const TextStyle(
                              color: AppTheme.udoCrimsonText, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            UdoButton(
                label: 'Sign in', onPressed: _submit, isLoading: isLoading),
            const SizedBox(height: 18),
            SocialAuthButtons(isLoading: isLoading),
          ],
        ),
      ),
    );
  }
}
