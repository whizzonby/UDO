import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/udo_logo.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
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
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = ref.read(apiClientProvider);
      await dio.post('/auth/forgot-password', data: {'email': email});
      if (mounted) setState(() => _sent = true);
    } on DioException catch (e) {
      setState(() => _error = e.response?.data?['message'] as String? ??
          'Something went wrong. Please try again.');
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.grey700),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _sent ? _SuccessView(email: _emailCtrl.text.trim()) : _FormView(
            emailCtrl: _emailCtrl,
            loading: _loading,
            error: _error,
            onSubmit: _submit,
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  const _FormView({
    required this.emailCtrl,
    required this.loading,
    required this.error,
    required this.onSubmit,
  });
  final TextEditingController emailCtrl;
  final bool loading;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Center(child: UdoLogo(size: 36)),
        const SizedBox(height: 36),
        Text('Reset password', style: AppTypography.displaySmall),
        const SizedBox(height: 8),
        Text(
          "Enter your email and we'll send you a link to reset your password.",
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          onFieldSubmitted: (_) => onSubmit(),
          decoration: const InputDecoration(
            hintText: 'Email address',
            prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: AppSpacing.borderMd,
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(error!,
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: AppColors.error)),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Send reset link',
          isLoading: loading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_outlined,
              size: 38, color: AppColors.teal),
        ),
        const SizedBox(height: 24),
        Text('Check your email', style: AppTypography.displaySmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(
          "We've sent a password reset link to\n$email",
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'The link expires in 60 minutes.',
          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey400),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        TextButton(
          onPressed: () => context.pop(),
          child: Text('Back to sign in',
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dustyRose)),
        ),
      ],
    );
  }
}
