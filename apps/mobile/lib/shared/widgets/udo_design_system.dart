import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UdoDesign {
  static const bg = Color(0xFFF8F8F5);
  static const card = Color(0xFFFFFFFF);
  static const plan = Color(0xFF2E4A42);
  static const gold = Color(0xFFC9A46A);
  static const budget = Color(0xFF24344D);
  static const guests = Color(0xFF5A4B58);
  static const live = Color(0xFF295E61);
  static const stone = Color(0xFFEAE4DB);
  static const text = Color(0xFF1C1917);
  static const muted = Color(0xFF9A9088);
  static const sub = Color(0xFF6B6159);
  static const sage = Color(0xFF8A9E8A);
  static const rose = Color(0xFFC9867A);
  static const amber = Color(0xFFD4924A);
  static const blue = Color(0xFF7A9EC9);
  static const border = stone;

  static TextStyle serif({
    double size = 28,
    FontWeight weight = FontWeight.w400,
    Color color = text,
    double height = 1.1,
  }) =>
      GoogleFonts.dmSerifDisplay(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = text,
    double height = 1.35,
  }) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
}

class UdoBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? background;

  const UdoBadge({
    super.key,
    required this.label,
    this.color = UdoDesign.plan,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: UdoDesign.sans(
            size: 12, weight: FontWeight.w600, color: color, height: 1),
      ),
    );
  }
}

class UdoCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final double radius;
  final BorderSide border;

  const UdoCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.color = UdoDesign.card,
    this.radius = 24,
    this.border = const BorderSide(color: UdoDesign.border),
  });

  @override
  State<UdoCard> createState() => _UdoCardState();
}

class _UdoCardState extends State<UdoCard> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      scale: _pressed ? 0.985 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: widget.margin,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.fromBorderSide(widget.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _pressed ? 0.04 : 0.06),
              blurRadius: _pressed ? 4 : 10,
              offset: Offset(0, _pressed ? 1 : 2),
            ),
          ],
        ),
        child: Padding(padding: widget.padding, child: widget.child),
      ),
    );

    if (widget.onTap == null) return content;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: content,
    );
  }
}

class UdoSectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final String? subtitle;
  final VoidCallback? onAction;

  const UdoSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.subtitle,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: subtitle == null ? 14 : 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(title,
                style: UdoDesign.sans(size: 18, weight: FontWeight.w700)),
          ),
          if (action != null)
            TextButton.icon(
              onPressed: onAction,
              iconAlignment: IconAlignment.end,
              label: Text(action!,
                  style: UdoDesign.sans(
                      size: 13,
                      weight: FontWeight.w600,
                      color: UdoDesign.muted)),
              icon: const Icon(Icons.chevron_right,
                  size: 18, color: UdoDesign.muted),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
            ),
        ]),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(subtitle!,
              style: UdoDesign.sans(
                  size: 13, color: UdoDesign.muted, height: 1.4)),
        ],
      ]),
    );
  }
}

class UdoRingProgress extends StatelessWidget {
  final double value;
  final double size;
  final Color color;
  final Widget? center;

  const UdoRingProgress({
    super.key,
    required this.value,
    this.size = 76,
    this.color = UdoDesign.sage,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(alignment: Alignment.center, children: [
        CustomPaint(
          size: Size.square(size),
          painter: _RingPainter(value: clamped, color: color),
        ),
        if (center != null) center!,
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;

  const _RingPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = math.max(4.0, size.width * 0.072);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = UdoDesign.stone;
    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = color;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      value * math.pi * 2,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
