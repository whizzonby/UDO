import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../registry/presentation/screens/registry_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: AppColors.white,
        title: Text(
          'More',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.grey700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('GIFTING'),
          _MenuTile(
            icon: Icons.card_giftcard_rounded,
            iconColor: AppColors.pinkGradientStart,
            iconBg: AppColors.blushLight,
            title: 'Registry',
            subtitle: 'Gifts, cash fund & thank-yous',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegistryScreen()),
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader('APP'),
          _MenuTile(
            icon: Icons.settings_outlined,
            iconColor: AppColors.grey600,
            iconBg: AppColors.grey200,
            title: 'Settings',
            subtitle: 'Wedding details, account, notifications',
            onTap: () {},
            badge: null,
            trailing: _ComingSoonBadge(),
          ),
          _MenuTile(
            icon: Icons.help_outline_rounded,
            iconColor: AppColors.teal,
            iconBg: const Color(0xFFE8F7F5),
            title: 'Help & Support',
            subtitle: 'FAQs, contact us',
            onTap: () {},
            trailing: _ComingSoonBadge(),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Udo',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.grey300,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'v1.0.0',
              style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.grey300),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.grey500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.trailing,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? badge;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Row(children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          if (badge != null) ...[const SizedBox(width: 6), badge!],
        ]),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.grey500),
        ),
        trailing: trailing ??
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.grey400, size: 20),
      ),
    );
  }
}

class _ComingSoonBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Soon',
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.grey500,
        ),
      ),
    );
  }
}
