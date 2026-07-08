import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class SelectableCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool dense;
  final bool centered;

  const SelectableCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.dense = false,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: dense ? 12 : 16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.udoGreen : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppTheme.udoGreen : AppTheme.udoBorder),
        ),
        child: Row(
          mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                textAlign: centered ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  fontSize: dense ? 13 : 14,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppTheme.udoTextPrimary,
                ),
              ),
            ),
            if (selected && !centered) const Icon(Icons.check, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
