import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

Future<void> showInfoSheet(BuildContext context, {required String title, required String description}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.udoBorder, borderRadius: BorderRadius.circular(100)),
            ),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontFamily: 'Playfair', fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.udoGreen)),
          const SizedBox(height: 10),
          Text(description, style: const TextStyle(fontSize: 14, color: AppTheme.udoTextSecondary, height: 1.5)),
        ],
      ),
    ),
  );
}
