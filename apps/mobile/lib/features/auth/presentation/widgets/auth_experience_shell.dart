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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(children: [
                if (leading != null) ...[leading!, const SizedBox(width: 12)],
                const Expanded(child: AuthMark()),
              ]),
              const SizedBox(height: 18),
              Text(eyebrow.toUpperCase(),
                  style: UdoDesign.sans(
                      size: 11,
                      weight: FontWeight.w700,
                      color: UdoDesign.gold)),
              const SizedBox(height: 6),
              Text(title,
                  style: UdoDesign.serif(size: 30, color: UdoDesign.text)),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: UdoDesign.sans(
                      size: 14, color: UdoDesign.sub, height: 1.4)),
              const SizedBox(height: 18),
              UdoCard(
                radius: 24,
                padding: const EdgeInsets.all(18),
                child: child,
              ),
              if (footer != null) ...[
                const SizedBox(height: 18),
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: UdoDesign.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.favorite, color: authAccent, size: 22),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Udo', style: UdoDesign.serif(size: 22)),
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
