import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/plan_models.dart';
import '../providers/plan_provider.dart';

class TaskFormSheet extends ConsumerStatefulWidget {
  const TaskFormSheet({super.key, this.task});
  final PlanTask? task;

  static Future<void> show(BuildContext context, {PlanTask? task}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormSheet(task: task),
    );
  }

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;
  late String _category;
  late TaskPriority _priority;
  DateTime? _dueDate;
  bool _saving = false;

  bool get _isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    _notesCtrl = TextEditingController(text: widget.task?.notes ?? '');
    _category = widget.task?.category ?? kTaskCategories.first;
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final task = PlanTask(
      id: widget.task?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      category: _category,
      priority: _priority,
      isComplete: widget.task?.isComplete ?? false,
      dueDate: _dueDate,
      notes: _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
    );

    final notifier = ref.read(planNotifierProvider.notifier);
    if (_isEdit) {
      await notifier.updateTask(task);
    } else {
      await notifier.addTask(task);
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
                        _isEdit ? 'Edit Task' : 'New Task',
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

                  // Title
                  _FieldLabel('Task title'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleCtrl,
                    autofocus: !_isEdit,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _inputDec('e.g. Confirm florist deposit'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Title is required'
                            : null,
                  ),
                  const SizedBox(height: 14),

                  // Category
                  _FieldLabel('Category'),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: _inputDec(''),
                    items: kTaskCategories
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _category = v ?? _category),
                  ),
                  const SizedBox(height: 14),

                  // Priority
                  _FieldLabel('Priority'),
                  const SizedBox(height: 8),
                  Row(
                    children: TaskPriority.values.map((p) {
                      final isSelected = _priority == p;
                      final color = _priorityColor(p);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _priority = p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withValues(alpha: 0.1)
                                  : AppColors.grey100,
                              borderRadius: AppSpacing.borderMd,
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : Colors.transparent,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _priorityLabel(p),
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? color
                                      : AppColors.grey500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Due date
                  _FieldLabel('Due date (optional)'),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ??
                            DateTime.now()
                                .add(const Duration(days: 7)),
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 365)),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 730)),
                      );
                      if (picked != null) {
                        setState(() => _dueDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: AppColors.grey300),
                        borderRadius: AppSpacing.borderMd,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 16, color: AppColors.grey400),
                          const SizedBox(width: 8),
                          Text(
                            _dueDate != null
                                ? DateFormat('d MMMM yyyy')
                                    .format(_dueDate!)
                                : 'No due date',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: _dueDate != null
                                  ? AppColors.grey700
                                  : AppColors.grey400,
                            ),
                          ),
                          const Spacer(),
                          if (_dueDate != null)
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _dueDate = null),
                              child: const Icon(Icons.close_rounded,
                                  size: 16, color: AppColors.grey400),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Notes
                  _FieldLabel('Notes (optional)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration:
                        _inputDec('Add any notes or details…'),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.hotPink,
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
                          : Text(_isEdit ? 'Save changes' : 'Add task'),
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

  Color _priorityColor(TaskPriority p) => switch (p) {
        TaskPriority.high => AppColors.error,
        TaskPriority.medium => const Color(0xFFF59E0B),
        TaskPriority.low => AppColors.grey400,
      };

  String _priorityLabel(TaskPriority p) => switch (p) {
        TaskPriority.high => 'High',
        TaskPriority.medium => 'Medium',
        TaskPriority.low => 'Low',
      };
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.labelSmall.copyWith(color: AppColors.grey500),
    );
  }
}

InputDecoration _inputDec(String hint) => InputDecoration(
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
        borderSide: const BorderSide(color: AppColors.hotPink),
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
