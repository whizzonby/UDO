import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

enum SocialProvider { google, apple, facebook }

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  final SocialProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.grey700,
          side: const BorderSide(color: AppColors.grey300, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderLg,
          ),
          backgroundColor: AppColors.white,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _providerIcon(),
                  const SizedBox(width: 10),
                  Text(
                    _providerLabel(),
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _providerIcon() {
    switch (provider) {
      case SocialProvider.google:
        return _GoogleIcon();
      case SocialProvider.apple:
        return const Icon(Icons.apple, size: 22, color: AppColors.black);
      case SocialProvider.facebook:
        return _FacebookIcon();
    }
  }

  String _providerLabel() {
    switch (provider) {
      case SocialProvider.google:
        return 'Continue with Google';
      case SocialProvider.apple:
        return 'Continue with Apple';
      case SocialProvider.facebook:
        return 'Continue with Facebook';
    }
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.width / 2;
    final r = size.width / 2;

    // Simplified Google 'G' icon using colored arcs
    final paint = Paint()..style = PaintingStyle.fill;

    // Blue arc (top-right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: Offset(c, c), radius: r),
        -1.57, 1.57, true, paint);

    // Red arc (bottom-left)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: Offset(c, c), radius: r),
        3.14, 1.57, true, paint);

    // Yellow arc (bottom-right)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: Offset(c, c), radius: r),
        1.57, 1.57, true, paint);

    // Green arc (top-left)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: Offset(c, c), radius: r),
        -3.14, 1.57, true, paint);

    // White center circle
    paint.color = Colors.white;
    canvas.drawCircle(Offset(c, c), r * 0.5, paint);

    // White cutout for right side of G
    paint.color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(c, c - r * 0.2, r + 2, r * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FacebookIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xFF1877F2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'f',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
