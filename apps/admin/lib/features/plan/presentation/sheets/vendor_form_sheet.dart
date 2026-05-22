import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/plan_models.dart';
import '../providers/plan_provider.dart';

class VendorFormSheet extends ConsumerStatefulWidget {
  const VendorFormSheet({super.key, this.vendor});
  final Vendor? vendor;

  static Future<void> show(BuildContext context, {Vendor? vendor}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VendorFormSheet(vendor: vendor),
    );
  }

  @override
  ConsumerState<VendorFormSheet> createState() =>
      _VendorFormSheetState();
}

class _VendorFormSheetState extends ConsumerState<VendorFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _contactNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _contractCtrl;
  late final TextEditingController _paidCtrl;
  late final TextEditingController _notesCtrl;
  late String _category;
  late VendorStatus _status;
  bool _saving = false;

  bool get _isEdit => widget.vendor != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vendor;
    _nameCtrl = TextEditingController(text: v?.name ?? '');
    _contactNameCtrl = TextEditingController(text: v?.contactName ?? '');
    _phoneCtrl = TextEditingController(text: v?.contactPhone ?? '');
    _emailCtrl = TextEditingController(text: v?.contactEmail ?? '');
    _contractCtrl = TextEditingController(
        text: v != null && v.contractAmount > 0
            ? v.contractAmount.toStringAsFixed(0)
            : '');
    _paidCtrl = TextEditingController(
        text: v != null && v.paidAmount > 0
            ? v.paidAmount.toStringAsFixed(0)
            : '');
    _notesCtrl = TextEditingController(text: v?.notes ?? '');
    _category = v?.category ?? kVendorCategories.first;
    _status = v?.status ?? VendorStatus.potential;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _contractCtrl.dispose();
    _paidCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final vendor = Vendor(
      id: widget.vendor?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      category: _category,
      status: _status,
      contactName: _contactNameCtrl.text.trim().isEmpty
          ? null
          : _contactNameCtrl.text.trim(),
      contactPhone:
          _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      contactEmail:
          _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      contractAmount: double.tryParse(_contractCtrl.text) ?? 0.0,
      paidAmount: double.tryParse(_paidCtrl.text) ?? 0.0,
      notes: _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
    );

    final notifier = ref.read(planNotifierProvider.notifier);
    if (_isEdit) {
      await notifier.updateVendor(vendor);
    } else {
      await notifier.addVendor(vendor);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: AppSpacing.borderFull,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        _isEdit ? 'Edit Vendor' : 'Add Vendor',
                        style: AppTypography.headingMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.grey400),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _Label('Vendor / business name'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameCtrl,
                    autofocus: !_isEdit,
                    textCapitalization: TextCapitalization.words,
                    decoration:
                        _dec('e.g. Bloom & Co. Florals'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Label('Category'),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _category,
                              decoration: _dec(''),
                              isExpanded: true,
                              items: kVendorCategories
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (v) => setState(
                                  () => _category = v ?? _category),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Status
                  _Label('Status'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: VendorStatus.values.map((s) {
                      final isSelected = _status == s;
                      final color = _statusColor(s);
                      return GestureDetector(
                        onTap: () => setState(() => _status = s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.1)
                                : AppColors.grey100,
                            borderRadius: AppSpacing.borderFull,
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            s.label,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? color
                                  : AppColors.grey500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  Text('Contact (optional)',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.grey500)),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _contactNameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _dec('Contact name'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: _dec('Phone number'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _dec('Email address'),
                  ),
                  const SizedBox(height: 16),

                  Text('Financials (optional)',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.grey500)),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _Label('Contract amount'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _contractCtrl,
                              keyboardType:
                                  TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly,
                              ],
                              decoration: _dec('0'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _Label('Amount paid'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _paidCtrl,
                              keyboardType:
                                  TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly,
                              ],
                              decoration: _dec('0'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: AppColors.white,
                        shape: const RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderMd),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2))
                          : Text(
                              _isEdit ? 'Save changes' : 'Add vendor'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(VendorStatus s) => switch (s) {
        VendorStatus.potential => AppColors.grey400,
        VendorStatus.booked => const Color(0xFFF59E0B),
        VendorStatus.confirmed => AppColors.teal,
        VendorStatus.cancelled => AppColors.dustyRose,
      };
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.labelSmall.copyWith(color: AppColors.grey500),
    );
  }
}

InputDecoration _dec(String hint) => InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.dmSans(fontSize: 14, color: AppColors.grey400),
      border: OutlineInputBorder(
        borderRadius: AppSpacing.borderMd,
        borderSide: const BorderSide(color: AppColors.grey300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderMd,
        borderSide: const BorderSide(color: AppColors.grey300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderMd,
        borderSide: const BorderSide(color: AppColors.teal),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderMd,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderMd,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
