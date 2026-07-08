import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.udoLightBlush,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppTheme.udoGreen,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'Udo',
              style: TextStyle(
                fontFamily: 'Playfair',
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: AppTheme.udoGreen,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your wedding, beautifully managed.',
              style: TextStyle(fontSize: 14, color: AppTheme.udoTextSecondary),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: AppTheme.udoGreen,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
