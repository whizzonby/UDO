import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class MultiSelectChips extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final void Function(String) onToggle;
  final int? maxSelections;

  const MultiSelectChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.maxSelections,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        final atLimit = maxSelections != null && selected.length >= maxSelections! && !isSelected;
        return GestureDetector(
          onTap: atLimit ? null : () => onToggle(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.udoGreen.withOpacity(0.12) : Colors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isSelected ? AppTheme.udoGreen : (atLimit ? AppTheme.udoBorder.withOpacity(0.5) : AppTheme.udoBorder),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check, size: 14, color: AppTheme.udoGreen),
                  const SizedBox(width: 6),
                ],
                Text(
                  option,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppTheme.udoGreen
                        : (atLimit ? AppTheme.udoTextSecondary.withOpacity(0.5) : AppTheme.udoTextPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
