import 'package:flutter/material.dart';

import '../../../../shared/widgets/udo_design_system.dart';

const authAccent = Color(0xFF2E4A42);

class AuthExperienceShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final String eyebrow;
  final Widget child;
  final Widget? leading;
  final Widget? footer;

  const AuthExperienceShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    required this.child,
    this.leading,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UdoDesign.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) leading!,
              SizedBox(height: leading == null ? 26 : 18),
              const AuthMark(),
              const SizedBox(height: 22),
              Text(eyebrow.toUpperCase(),
                  style: UdoDesign.sans(
                      size: 11,
                      weight: FontWeight.w700,
                      color: UdoDesign.gold)),
              const SizedBox(height: 8),
              Text(title,
                  style: UdoDesign.serif(size: 42, color: UdoDesign.text)),
              const SizedBox(height: 8),
              Text(subtitle,
                  style: UdoDesign.sans(
                      size: 15, color: UdoDesign.sub, height: 1.45)),
              const SizedBox(height: 26),
              UdoCard(
                radius: 24,
                padding: const EdgeInsets.all(20),
                child: child,
              ),
              if (footer != null) ...[
                const SizedBox(height: 24),
                Center(child: footer!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AuthMark extends StatelessWidget {
  const AuthMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: UdoDesign.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.favorite, color: authAccent, size: 28),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Udo', style: UdoDesign.serif(size: 26)),
            Text('Wedding operating system',
                style: UdoDesign.sans(size: 11, color: UdoDesign.muted)),
          ],
        ),
      ],
    );
  }
}

class AuthBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const AuthBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: UdoDesign.text,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: UdoDesign.border),
        ),
      ),
      icon: const Icon(Icons.arrow_back),
    );
  }
}
