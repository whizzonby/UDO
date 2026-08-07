import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/auth_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/udo_button.dart';
import '../../../../shared/widgets/udo_design_system.dart';
import '../../../../shared/widgets/udo_text_field.dart';
import '../widgets/auth_experience_shell.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authServiceProvider)
          .forgotPassword(_emailCtrl.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthExperienceShell(
      eyebrow: 'Account recovery',
      title: 'Reset access without losing momentum',
      subtitle:
          'Enter the email on your account and Udo will send a secure reset link.',
      leading: AuthBackButton(onTap: () => context.pop()),
      child: _sent ? _sentState(context) : _formState(),
    );
  }

  Widget _sentState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.udoGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppTheme.udoGreen.withValues(alpha: 0.28)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.mark_email_read_outlined,
                  color: AppTheme.udoGreen, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Check ${_emailCtrl.text.trim()} for a link to reset your password.',
                  style: UdoDesign.sans(
                      size: 14, color: AppTheme.udoGreen, height: 1.45),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        UdoButton(
            label: 'Back to sign in', onPressed: () => context.go('/login')),
      ],
    );
  }

  Widget _formState() {
    return Form(
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
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style:
                    const TextStyle(color: AppTheme.udoCrimson, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          UdoButton(
              label: 'Send reset link',
              onPressed: _submit,
              isLoading: _loading),
        ],
      ),
    );
  }
}
