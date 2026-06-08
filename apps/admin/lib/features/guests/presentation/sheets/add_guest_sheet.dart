import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../providers/guests_provider.dart';

class AddGuestSheet extends StatefulWidget {
  const AddGuestSheet({super.key, required this.ref});
  final WidgetRef ref;

  static Future<void> show(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddGuestSheet(ref: ref),
    );
  }

  @override
  State<AddGuestSheet> createState() => _AddGuestSheetState();
}

class _AddGuestSheetState extends State<AddGuestSheet> {
  final _form = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _group = TextEditingController();
  final _dietary = TextEditingController();
  String _relationship = 'mutual';
  bool _isVip = false;
  bool _plusOneAllowed = false;
  bool _saving = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _group.dispose();
    _dietary.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.ref.read(guestsListNotifierProvider.notifier).addGuest({
        'first_name': _firstName.text.trim(),
        'last_name': _lastName.text.trim(),
        if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
        if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
        if (_group.text.trim().isNotEmpty) 'group': _group.text.trim(),
        if (_dietary.text.trim().isNotEmpty)
          'dietary_requirements': _dietary.text.trim(),
        'relationship': _relationship,
        'is_vip': _isVip,
        'plus_one_allowed': _plusOneAllowed,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add guest: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: AppSpacing.borderFull,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Add guest',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        ctrl: _firstName,
                        label: 'First name',
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(ctrl: _lastName, label: 'Last name'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Field(ctrl: _email, label: 'Email', keyboard: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _Field(ctrl: _phone, label: 'Phone', keyboard: TextInputType.phone),
                const SizedBox(height: 12),
                _Field(ctrl: _group, label: 'Group (e.g. Family, Friends)'),
                const SizedBox(height: 12),
                _Field(ctrl: _dietary, label: 'Dietary requirements'),
                const SizedBox(height: 16),

                // Relationship
                DropdownButtonFormField<String>(
                  value: _relationship,
                  decoration: _inputDeco('Relationship / side'),
                  items: const [
                    DropdownMenuItem(value: 'bride_side', child: Text("Bride's side")),
                    DropdownMenuItem(value: 'groom_side', child: Text("Groom's side")),
                    DropdownMenuItem(value: 'mutual', child: Text('Mutual')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _relationship = v!),
                ),
                const SizedBox(height: 8),

                // Toggles
                SwitchListTile(
                  value: _isVip,
                  onChanged: (v) => setState(() => _isVip = v),
                  title: Text('VIP guest',
                      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.grey700)),
                  activeColor: AppColors.hotPink,
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  value: _plusOneAllowed,
                  onChanged: (v) => setState(() => _plusOneAllowed = v),
                  title: Text('Allow plus one',
                      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.grey700)),
                  activeColor: AppColors.hotPink,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.hotPink,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Add guest',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey500),
      filled: true,
      fillColor: AppColors.grey100,
      border: OutlineInputBorder(
        borderRadius: AppSpacing.borderLg,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderLg,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderLg,
        borderSide: const BorderSide(color: AppColors.hotPink),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.ctrl,
    required this.label,
    this.required = false,
    this.keyboard = TextInputType.text,
  });

  final TextEditingController ctrl;
  final String label;
  final bool required;
  final TextInputType keyboard;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.grey700),
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.dmSans(fontSize: 13, color: AppColors.grey500),
        filled: true,
        fillColor: AppColors.grey100,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderLg,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderLg,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderLg,
          borderSide: const BorderSide(color: AppColors.hotPink),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
