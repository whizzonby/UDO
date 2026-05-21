import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: (currentStep + 1) / totalSteps,
      backgroundColor: AppColors.grey200,
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.dustyRose),
      minHeight: 3,
    );
  }
}
