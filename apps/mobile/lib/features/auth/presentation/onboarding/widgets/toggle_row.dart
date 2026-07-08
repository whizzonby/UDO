import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onInfoTap;

  const ToggleRow({super.key, required this.label, required this.value, required this.onChanged, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.udoLightBlush,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.udoPastelCrimson.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.udoGreen))),
                if (onInfoTap != null)
                  IconButton(
                    onPressed: onInfoTap,
                    icon: const Icon(Icons.info_outline, size: 17, color: AppTheme.udoCrimson),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.udoGreen,
            thumbColor: WidgetStateProperty.all(Colors.white),
          ),
        ],
      ),
    );
  }
}
