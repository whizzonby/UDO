import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/udo_design_system.dart';

/// How each template frames the invitation — beyond just a color, this is
/// what makes "Classic Ivory" actually look different from "Modern Minimal"
/// rather than the same layout tinted a different color.
enum InvitationFrame { double_, thin, none, thick }

class InvitationTemplate {
  final String id, name, description;
  final Color accent, background;
  final IconData motif;
  final InvitationFrame frame;
  final TextStyle Function({required double size, required Color color}) headlineFont;
  final bool uppercaseHeadline;

  InvitationTemplate(
    this.id,
    this.name,
    this.description,
    this.accent,
    this.background,
    this.motif,
    this.frame,
    this.headlineFont, {
    this.uppercaseHeadline = false,
  });
}

final invitationTemplates = [
  InvitationTemplate(
    'classic-ivory',
    'Classic Ivory',
    'Elegant serif design with gold accents',
    const Color(0xFF285301),
    const Color(0xFFFAF6F0),
    Icons.auto_awesome,
    InvitationFrame.double_,
    ({required size, required color}) => GoogleFonts.playfairDisplay(fontSize: size, color: color, fontWeight: FontWeight.w500),
  ),
  InvitationTemplate(
    'garden-romance',
    'Garden Romance',
    'Floral watercolour style, soft pinks',
    const Color(0xFFD45D78),
    const Color(0xFFFCEEF2),
    Icons.local_florist_outlined,
    InvitationFrame.thin,
    ({required size, required color}) => GoogleFonts.greatVibes(fontSize: size * 1.5, color: color),
  ),
  InvitationTemplate(
    'modern-minimal',
    'Modern Minimal',
    'Clean lines, contemporary typography',
    const Color(0xFF1F2937),
    const Color(0xFFF7F7F7),
    Icons.remove,
    InvitationFrame.none,
    ({required size, required color}) => GoogleFonts.montserrat(fontSize: size * 0.85, color: color, fontWeight: FontWeight.w700, letterSpacing: 2),
    uppercaseHeadline: true,
  ),
  InvitationTemplate(
    'rustic-warmth',
    'Rustic Warmth',
    'Earthy tones with botanical elements',
    const Color(0xFF92400E),
    const Color(0xFFFAF3E8),
    Icons.eco_outlined,
    InvitationFrame.thick,
    ({required size, required color}) => GoogleFonts.merriweather(fontSize: size * 0.9, color: color, fontWeight: FontWeight.w700),
  ),
  InvitationTemplate(
    'royal-blue',
    'Royal Blue',
    'Deep navy with silver foiling effect',
    const Color(0xFF1E3A8A),
    const Color(0xFFEEF2FA),
    Icons.star_border_purple500_outlined,
    InvitationFrame.double_,
    ({required size, required color}) => GoogleFonts.cormorantGaramond(fontSize: size * 1.15, color: color, fontWeight: FontWeight.w600, letterSpacing: 1),
  ),
  InvitationTemplate(
    'blush-berry',
    'Blush & Berry',
    'Romantic blush with berry accents',
    const Color(0xFF9D174D),
    const Color(0xFFFBEEF3),
    Icons.favorite_border,
    InvitationFrame.thin,
    ({required size, required color}) => GoogleFonts.dancingScript(fontSize: size * 1.4, color: color, fontWeight: FontWeight.w700),
  ),
];

InvitationTemplate templateById(String? id) =>
    invitationTemplates.firstWhere((t) => t.id == id, orElse: () => invitationTemplates.first);

/// 5 real suggested phrases for the invitation's introduction line — the
/// user picks one to fill the field, or writes their own. Not a generator,
/// just fewer blank-page moments; matches 5 of the doc's 10 named
/// "cultural wording" presets.
const introPresets = <String, String>{
  'Couple hosting': "We can't wait to celebrate with you",
  'Families hosting': 'Together with their families',
  'Parents hosting': 'Together with their parents',
  'Formal': 'Request the honour of your presence',
  'Informal': "We're tying the knot and want you there",
};

/// The real invitation preview — used both by the Invitations tab's passive
/// preview and by the wizard's Design/Wording/Preview steps. Every line is
/// driven by a real field with an honest fallback; nothing here is
/// hardcoded to a fixed phrase the user can never actually change.
class InvitationPreviewCard extends StatelessWidget {
  final InvitationTemplate template;
  final String coupleNames;
  final String introText;
  final String mainWording;
  final String dateText;
  final String venueText;
  final String? rsvpDeadlineText;

  const InvitationPreviewCard({
    super.key,
    required this.template,
    required this.coupleNames,
    required this.introText,
    required this.mainWording,
    required this.dateText,
    required this.venueText,
    this.rsvpDeadlineText,
  });

  @override
  Widget build(BuildContext context) {
    final headlineText = coupleNames.isEmpty ? 'Your names here' : coupleNames;
    final headline = Text(
      template.uppercaseHeadline ? headlineText.toUpperCase() : headlineText,
      style: template.headlineFont(size: 24, color: template.accent),
      textAlign: TextAlign.center,
    );

    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: template.background,
        borderRadius: BorderRadius.circular(12),
        border: template.frame == InvitationFrame.thick
            ? Border.all(color: template.accent.withValues(alpha: 0.6), width: 3)
            : template.frame == InvitationFrame.thin
                ? Border.all(color: template.accent.withValues(alpha: 0.3))
                : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        if (template.frame != InvitationFrame.none) ...[
          Icon(template.motif, color: template.accent, size: 22),
          const SizedBox(height: 10),
        ],
        headline,
        if (template.uppercaseHeadline) ...[
          const SizedBox(height: 8),
          Container(width: 40, height: 2, color: template.accent.withValues(alpha: 0.5)),
        ],
        const SizedBox(height: 4),
          Text(
            introText.isEmpty ? 'Together with their families' : introText,
            style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            mainWording.isEmpty ? 'invite you to celebrate their wedding' : mainWording,
            style: const TextStyle(fontSize: 13, color: AppTheme.udoTextSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(dateText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          if (venueText.isNotEmpty) Text(venueText, style: const TextStyle(fontSize: 12, color: AppTheme.udoTextSecondary), textAlign: TextAlign.center),
          if ((rsvpDeadlineText ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('RSVP by $rsvpDeadlineText', style: const TextStyle(fontSize: 11, color: AppTheme.udoTextSecondary, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
          ],
      ]),
    );

    if (template.frame != InvitationFrame.double_) return card;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: template.accent.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: card,
    );
  }
}

/// Horizontal template picker — shared by the Invitations tab's passive
/// Template Studio strip and the invitation editor's Design section.
class InvitationTemplateStrip extends StatelessWidget {
  final List<InvitationTemplate> templates;
  final InvitationTemplate selected;
  final ValueChanged<InvitationTemplate> onTap;

  const InvitationTemplateStrip({
    super.key,
    required this.templates,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final template = templates[index];
          final active = template.id == selected.id;
          return SizedBox(
            width: 112,
            child: UdoCard(
              onTap: () => onTap(template),
              padding: const EdgeInsets.all(12),
              color: active
                  ? template.accent.withValues(alpha: 0.08)
                  : UdoDesign.card,
              border: BorderSide(
                  color: active ? template.accent : UdoDesign.border),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Aa', style: template.headlineFont(size: 22, color: template.accent)),
                    const SizedBox(height: 4),
                    Icon(template.motif, color: template.accent, size: 16),
                    const SizedBox(height: 8),
                    Text(template.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: UdoDesign.sans(
                            size: 11,
                            weight: FontWeight.w800,
                            color: active ? template.accent : UdoDesign.text)),
                  ]),
            ),
          );
        },
      ),
    );
  }
}

/// Renders an invitation the couple uploaded themselves (already designed
/// elsewhere) in place of the templated [InvitationPreviewCard] — used by
/// the wizard's Design/Wording/Preview steps once an import is active.
class ImportedInvitationPreview extends StatelessWidget {
  final String assetUrl;
  final String? assetType;

  const ImportedInvitationPreview({super.key, required this.assetUrl, this.assetType});

  String get _resolvedUrl =>
      assetUrl.startsWith('/storage/') ? '${AppConstants.apiOrigin}$assetUrl' : assetUrl;

  @override
  Widget build(BuildContext context) {
    if (assetType == 'pdf') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: UdoDesign.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: UdoDesign.border),
        ),
        child: Column(children: [
          const Icon(Icons.picture_as_pdf_outlined, size: 40, color: AppTheme.udoCrimson),
          const SizedBox(height: 10),
          const Text('Imported PDF invitation',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => launchUrl(Uri.parse(_resolvedUrl), mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Open PDF'),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.udoBorder)),
          ),
        ]),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        _resolvedUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          color: UdoDesign.card,
          child: const Center(
              child: Icon(Icons.broken_image_outlined, color: UdoDesign.muted, size: 32)),
        ),
      ),
    );
  }
}
