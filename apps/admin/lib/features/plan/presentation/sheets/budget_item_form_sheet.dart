import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/plan_models.dart';
import '../providers/plan_provider.dart';

class BudgetItemFormSheet extends ConsumerStatefulWidget {
  const BudgetItemFormSheet({super.key, this.item});
  final BudgetItem? item;

  static Future<void> show(BuildContext context, {BudgetItem? item}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BudgetItemFormSheet(item: item),
    );
  }

  @override
  ConsumerState<BudgetItemFormSheet> createState() =>
      _BudgetItemFormSheetState();
}

class _BudgetItemFormSheetState
    extends ConsumerState<BudgetItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _budgetedCtrl;
  late final TextEditingController _paidCtrl;
  late final TextEditingController _notesCtrl;
  late String _category;
  bool _saving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final b = widget.item;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _budgetedCtrl = TextEditingController(
        text: b != null && b.budgetedAmount > 0
            ? b.budgetedAmount.toStringAsFixed(0)
            : '');
    _paidCtrl = TextEditingController(
        text: b != null && b.paidAmount > 0
            ? b.paidAmount.toStringAsFixed(0)
            : '');
    _notesCtrl = TextEditingController(text: b?.notes ?? '');
    _category = b?.category ?? kBudgetCategories.first;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _budgetedCtrl.dispose();
    _paidCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = BudgetItem(
      id: widget.item?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      category: _category,
      budgetedAmount: double.tryParse(_budgetedCtrl.text) ?? 0.0,
      paidAmount: double.tryParse(_paidCtrl.text) ?? 0.0,
      notes: _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
    );

    final notifier = ref.read(planNotifierProvider.notifier);
    if (_isEdit) {
      await notifier.updateBudgetItem(item);
    } else {
      await notifier.addBudgetItem(item);
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
                        _isEdit ? 'Edit Expense' : 'Add Expense',
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

                  _Label('Description'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleCtrl,
                    autofocus: !_isEdit,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _dec('e.g. Venue hire fee'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Description is required'
                            : null,
                  ),
                  const SizedBox(height: 14),

                  _Label('Category'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: _dec(''),
                    isExpanded: true,
                    items: kBudgetCategories
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _category = v ?? _category),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _Label('Budgeted amount'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _budgetedCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: _dec('0'),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
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
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: _dec('0'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _Label('Notes (optional)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _dec('Any additional notes…'),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestGreen,
                        foregroundColor: AppColors.white,
                        shape: const RoundedRectangleBorder(
                            borderRadius: AppSpacing.borderMd),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(_isEdit
                              ? 'Save changes'
                              : 'Add expense'),
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
        borderSide: const BorderSide(color: AppColors.forestGreen),
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
