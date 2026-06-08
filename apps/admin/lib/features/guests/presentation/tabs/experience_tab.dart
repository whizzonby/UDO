import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/experience_provider.dart';

class ExperienceTab extends ConsumerWidget {
  const ExperienceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(experienceNotifierProvider);

    if (state.status == ExperienceStatus.loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.pinkGradientStart));
    }

    if (state.status == ExperienceStatus.error || state.config == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: AppColors.grey400, size: 40),
          const SizedBox(height: 12),
          Text(state.error ?? 'Failed to load',
              style: GoogleFonts.dmSans(color: AppColors.grey500)),
          TextButton(
            onPressed: () =>
                ref.read(experienceNotifierProvider.notifier).refresh(),
            child: const Text('Retry'),
          ),
        ]),
      );
    }

    final config = state.config!;
    final isSaving = state.status == ExperienceStatus.saving;
    final notifier = ref.read(experienceNotifierProvider.notifier);

    return RefreshIndicator(
      color: AppColors.pinkGradientStart,
      onRefresh: () => ref.read(experienceNotifierProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ── Publish status card ────────────────────────────────────────
          _PublishCard(
            isPublished: config.isPublished,
            isBusy: isSaving,
            onToggle: () => notifier.togglePublished(),
          ),
          const SizedBox(height: 12),

          // ── Guest link ────────────────────────────────────────────────
          _GuestLinkCard(token: null),
          const SizedBox(height: 12),

          // ── Welcome message ───────────────────────────────────────────
          _WelcomeMessageCard(
            initial: config.welcomeMessage ?? '',
            isBusy: isSaving,
            onSave: (msg) => notifier.updateWelcomeMessage(msg),
          ),
          const SizedBox(height: 12),

          // ── Sections ──────────────────────────────────────────────────
          _SectionsCard(
            sections: config.sectionsEnabled.map(
              (k, v) => MapEntry(k, v == true),
            ),
            isBusy: isSaving,
            onToggle: (key, val) => notifier.toggleSection(key, val),
          ),
          const SizedBox(height: 12),

          // ── Theme accent color ─────────────────────────────────────────
          _ThemeCard(
            currentHex: config.themeAccentColor,
            isBusy: isSaving,
            onColorPick: (hex) => notifier.updateAccentColor(hex),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PublishCard extends StatelessWidget {
  const _PublishCard({
    required this.isPublished,
    required this.isBusy,
    required this.onToggle,
  });

  final bool isPublished;
  final bool isBusy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isPublished
            ? const LinearGradient(
                colors: [AppColors.pinkGradientStart, AppColors.pinkGradientEnd],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isPublished ? null : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isPublished ? null : Border.all(color: AppColors.grey200),
      ),
      child: Row(children: [
        Icon(
          isPublished ? Icons.public_rounded : Icons.public_off_rounded,
          color: isPublished ? Colors.white : AppColors.grey400,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              isPublished ? 'Live' : 'Draft',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isPublished ? Colors.white : AppColors.grey700,
              ),
            ),
            Text(
              isPublished
                  ? 'Your guest page is live and accessible.'
                  : 'Not visible to guests yet. Toggle to publish.',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: isPublished
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppColors.grey500,
              ),
            ),
          ]),
        ),
        const SizedBox(width: 12),
        isBusy
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : Switch.adaptive(
                value: isPublished,
                onChanged: (_) => onToggle(),
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withValues(alpha: 0.4),
                inactiveThumbColor: AppColors.grey400,
                inactiveTrackColor: AppColors.grey200,
              ),
      ]),
    );
  }
}

class _GuestLinkCard extends StatelessWidget {
  const _GuestLinkCard({required this.token});

  final String? token;

  @override
  Widget build(BuildContext context) {
    final url = token != null && token!.isNotEmpty
        ? 'https://udo.app/g/$token'
        : 'https://udo.app/g/your-link';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Guest page link',
            style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.teal)),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
            child: Text(url,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.grey700,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Link copied',
                      style: GoogleFonts.dmSans(fontSize: 13)),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.teal,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Copy',
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _WelcomeMessageCard extends StatefulWidget {
  const _WelcomeMessageCard({
    required this.initial,
    required this.isBusy,
    required this.onSave,
  });

  final String initial;
  final bool isBusy;
  final ValueChanged<String> onSave;

  @override
  State<_WelcomeMessageCard> createState() => _WelcomeMessageCardState();
}

class _WelcomeMessageCardState extends State<_WelcomeMessageCard> {
  late final TextEditingController _ctrl;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
    _ctrl.addListener(() => setState(() => _dirty = _ctrl.text != widget.initial));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome message',
            style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700)),
        const SizedBox(height: 4),
        Text('Shown at the top of your guest page.',
            style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.grey500)),
        const SizedBox(height: 10),
        TextField(
          controller: _ctrl,
          maxLines: 3,
          maxLength: 1000,
          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey700),
          decoration: InputDecoration(
            hintText: 'Write a warm message to your guests…',
            hintStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey400),
            filled: true,
            fillColor: AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        if (_dirty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.isBusy ? null : () {
                widget.onSave(_ctrl.text);
                setState(() => _dirty = false);
              },
              child: Text(
                widget.isBusy ? 'Saving…' : 'Save',
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pinkGradientStart),
              ),
            ),
          ),
      ]),
    );
  }
}

class _SectionsCard extends StatelessWidget {
  const _SectionsCard({
    required this.sections,
    required this.isBusy,
    required this.onToggle,
  });

  final Map<String, bool> sections;
  final bool isBusy;
  final void Function(String key, bool val) onToggle;

  static const _labels = {
    'rsvp': ('RSVP', Icons.how_to_reg_rounded),
    'schedule': ('Schedule & agenda', Icons.schedule_rounded),
    'venue': ('Venue & travel', Icons.location_on_rounded),
    'gallery': ('Gallery', Icons.photo_library_rounded),
    'registry': ('Registry', Icons.card_giftcard_rounded),
    'photo_upload': ('Photo upload', Icons.add_a_photo_rounded),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
          child: Row(children: [
            Text('Page sections',
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700)),
            const Spacer(),
            Text('Toggle to show/hide',
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppColors.grey500)),
          ]),
        ),
        ...(_labels.entries.map((e) {
          final key = e.key;
          final (label, icon) = e.value;
          final enabled = sections[key] ?? true;
          return _SectionRow(
            icon: icon,
            label: label,
            enabled: enabled,
            isBusy: isBusy,
            onToggle: (val) => onToggle(key, val),
          );
        })),
        const SizedBox(height: 4),
      ]),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.isBusy,
    required this.onToggle,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final bool isBusy;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.pinkGradientStart.withValues(alpha: 0.1)
                : AppColors.grey100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 16,
              color: enabled ? AppColors.pinkGradientStart : AppColors.grey400),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: enabled ? AppColors.grey700 : AppColors.grey400)),
        ),
        Switch.adaptive(
          value: enabled,
          onChanged: isBusy ? null : onToggle,
          activeColor: AppColors.pinkGradientStart,
          inactiveThumbColor: AppColors.grey400,
          inactiveTrackColor: AppColors.grey200,
        ),
      ]),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.currentHex,
    required this.isBusy,
    required this.onColorPick,
  });

  final String currentHex;
  final bool isBusy;
  final ValueChanged<String> onColorPick;

  static const _presets = [
    ('#FF4D8C', 'Bloom'),
    ('#D4006A', 'Magenta'),
    ('#00897B', 'Sage'),
    ('#5C6BC0', 'Indigo'),
    ('#F59E0B', 'Gold'),
    ('#333333', 'Noir'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Accent colour',
            style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700)),
        const SizedBox(height: 4),
        Text('Used for buttons and highlights on your guest page.',
            style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.grey500)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _presets.map((p) {
            final (hex, name) = p;
            final isSelected = currentHex.toUpperCase() == hex.toUpperCase();
            final color = _hexColor(hex);
            return GestureDetector(
              onTap: isBusy ? null : () => onColorPick(hex),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: AppColors.grey700, width: 2.5)
                        : null,
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6)]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18)
                      : null,
                ),
                const SizedBox(height: 4),
                Text(name,
                    style: GoogleFonts.dmSans(
                        fontSize: 10, color: AppColors.grey500)),
              ]),
            );
          }).toList(),
        ),
      ]),
    );
  }

  Color _hexColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
