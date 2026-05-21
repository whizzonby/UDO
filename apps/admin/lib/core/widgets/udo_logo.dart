import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class UdoLogo extends StatelessWidget {
  const UdoLogo({
    super.key,
    this.size = 48,
    this.color = AppColors.forestGreen,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'udo',
      style: GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -1,
        height: 1,
      ),
    );
  }
}
