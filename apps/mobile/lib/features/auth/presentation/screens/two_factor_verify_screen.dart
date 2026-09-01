import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_scaffold_messenger.dart';
import '../../../../shared/widgets/udo_button.dart';
import '../../../../shared/widgets/udo_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_experience_shell.dart';

/// Passed via `context.push('/two-factor', extra: ...)` right after `login()`
/// returns a pending challenge — carries just enough to complete the second
/// step without touching global auth state until the code is verified.
class TwoFactorChallenge {
  final String email;
  final String token;
  final String message;

  const TwoFactorChallenge({
    required this.email,
    required this.token,
    required this.message,
  });
}

const _resendCooldownSeconds = 30;

class TwoFactorVerifyScreen extends ConsumerStatefulWidget {
  final TwoFactorChallenge challenge;
  const TwoFactorVerifyScreen({super.key, required this.challenge});

  @override
  ConsumerState<TwoFactorVerifyScreen> createState() => _TwoFactorVerifyScreenState();
}

class _TwoFactorVerifyScreenState extends ConsumerState<TwoFactorVerifyScreen> {
  final _codeCtrl = TextEditingController();
  late String _token;
  bool _verifying = false;
  bool _resending = false;
  String? _error;
  int _cooldown = _resendCooldownSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _token = widget.challenge.token;
    _startCooldown();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = _resendCooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldown <= 1) {
        timer.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _verify() async {
    if (_codeCtrl.text.trim().length != 6) {
      setState(() => _error = 'Enter the 6-digit code.');
      return;
    }
    setState(() {
      _verifying = true;
      _error = null;
    });
    final error = await ref.read(authProvider.notifier).verifyTwoFactor(
          email: widget.challenge.email,
          twoFactorToken: _token,
          code: _codeCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _verifying = false);
    if (error != null) {
      setState(() => _error = error);
    } else {
      showAuthToast('Signed in successfully.');
    }
    // On success, AuthState flips to authenticated and the router redirect
    // takes it from here — nothing else to do.
  }

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      final message = await ref.read(authProvider.notifier).resendTwoFactor(
            email: widget.challenge.email,
            twoFactorToken: _token,
          );
      if (!mounted) return;
      _startCooldown();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(humanizeError(e))));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthExperienceShell(
      eyebrow: 'Verify it\'s you',
      title: 'Enter your login code',
      subtitle: widget.challenge.message,
      footer: TextButton(
        onPressed: () => context.go('/login'),
        child: const Text('Back to sign in',
            style: TextStyle(color: AppTheme.udoTextSecondary, fontSize: 13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UdoTextField(
            label: '6-digit code',
            hint: '000000',
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.udoCrimson.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.udoCrimson, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!,
                        style: const TextStyle(color: AppTheme.udoCrimson, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          UdoButton(label: 'Verify', onPressed: _verify, isLoading: _verifying),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: (_cooldown > 0 || _resending) ? null : _resend,
              child: Text(
                _cooldown > 0 ? 'Resend code (${_cooldown}s)' : 'Resend code',
                style: const TextStyle(color: AppTheme.udoGreen, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
