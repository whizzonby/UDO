import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/udo_button.dart';
import '../../../../shared/widgets/udo_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_experience_shell.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    for (final controller in [_firstCtrl, _lastCtrl, _emailCtrl, _passCtrl]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).register(
          firstName: _firstCtrl.text.trim(),
          lastName: _lastCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isLoading = auth.status == AuthStatus.loading;

    return AuthExperienceShell(
      eyebrow: 'Start the workspace',
      title: 'Build the wedding operating room',
      subtitle:
          'Create your account first. Udo will guide the workspace setup right after this.',
      leading: AuthBackButton(onTap: () => context.go('/login')),
      footer: GestureDetector(
        onTap: () => context.go('/login'),
        child: const Text.rich(
          TextSpan(children: [
            TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(color: AppTheme.udoTextSecondary)),
            TextSpan(
                text: 'Sign in',
                style: TextStyle(
                    color: AppTheme.udoGreen, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: UdoTextField(
                  label: 'First name',
                  controller: _firstCtrl,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: UdoTextField(
                  label: 'Last name',
                  controller: _lastCtrl,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
            ]),
            const SizedBox(height: 16),
            UdoTextField(
              label: 'Email',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  v == null || !v.contains('@') ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 16),
            UdoTextField(
              label: 'Password',
              controller: _passCtrl,
              obscureText: _obscure,
              hint: 'At least 8 characters',
              validator: (v) =>
                  v == null || v.length < 8 ? 'Minimum 8 characters' : null,
              suffixIcon: IconButton(
                icon: Icon(_obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.udoCrimson.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline,
                      color: AppTheme.udoCrimson, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(auth.error!,
                        style: const TextStyle(
                            color: AppTheme.udoCrimson, fontSize: 13)),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 24),
            UdoButton(
                label: 'Create account',
                onPressed: _submit,
                isLoading: isLoading),
          ],
        ),
      ),
    );
  }
}
