import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/expense_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/expense_model.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../utils/smart_features.dart';
import '../../core/validation/validators/amount_validator.dart';
import '../../core/validation/validation_result.dart';
import '../../core/validation/widgets/validated_text_field.dart';

/// A screen for adding or editing financial transactions (expenses or allowance).
class AddExpenseScreen extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddExpenseScreen({super.key, this.expenseToEdit});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _amountCtrl     = TextEditingController();
  final _titleCtrl      = TextEditingController();
  final _noteCtrl       = TextEditingController();

  String  _type            = 'expense';
  String? _selectedCategory;
  String? _suggestedCategory;
  DateTime _selectedDate   = DateTime.now();
  String  _paymentMethod   = 'Cash';
  bool    _isSaving        = false;

  bool get _isEdit => widget.expenseToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e = widget.expenseToEdit!;
      _amountCtrl.text     = (e.amount / 100).toStringAsFixed(2);
      _titleCtrl.text      = e.title;
      _noteCtrl.text       = e.note ?? '';
      _type                = e.type;
      _selectedCategory    = e.category;
      _selectedDate        = e.date;
      _paymentMethod       = e.paymentMethod ?? 'Cash';
    } else {
      _loadLastCategory();
    }
    _titleCtrl.addListener(_onTitleChanged);
  }

  Future<void> _loadLastCategory() async {
    final last = await SmartFeatures.getLastCategory(_type);
    if (last != null && mounted) setState(() => _selectedCategory = last);
  }

  void _onTitleChanged() {
    final suggestion = SmartFeatures.suggestCategory(_titleCtrl.text, _type);
    if (suggestion != null && suggestion != _suggestedCategory) {
      setState(() => _suggestedCategory = suggestion);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      SmartFeatures.errorVibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    final clean  = _amountCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '');
    final parsed = double.tryParse(clean) ?? 0.0;
    final cents  = (parsed * 100).toInt();

    if (!_isEdit) {
      final provider = context.read<ExpenseProvider>();
      final dup = SmartFeatures.findDuplicate(
        provider.expenses,
        title: _titleCtrl.text.trim(),
        amountCents: cents,
        type: _type,
        date: _selectedDate,
      );
      if (dup != null) {
        final confirmed = await _showDuplicateWarning(dup);
        if (!confirmed) return;
      }
    }

    setState(() => _isSaving = true);

    final expense = Expense(
      id: widget.expenseToEdit?.id,
      title: _titleCtrl.text.trim(),
      amount: cents,
      category: _selectedCategory!,
      date: _selectedDate,
      type: _type,
      note: _noteCtrl.text.trim(),
      paymentMethod: _paymentMethod,
      createdAt: widget.expenseToEdit?.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      final provider = context.read<ExpenseProvider>();
      if (_isEdit) {
        await provider.updateExpense(expense);
      } else {
        await provider.addExpense(expense);
      }

      await SmartFeatures.saveLastCategory(_type, _selectedCategory!);
      SmartFeatures.successVibrate();

      if (mounted) Navigator.pop(context);
    } catch (e) {
      SmartFeatures.errorVibrate();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _showDuplicateWarning(Expense duplicate) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text('Possible Duplicate'),
        ]),
        content: Text(
          'A similar transaction "${duplicate.title}" for the same amount was added recently.\n\nDo you still want to add it?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add Anyway')),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _type == 'expense';
    final color = isExpense ? AppColors.expense : AppColors.income;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Transaction' : 'Add Transaction', style: AppStyles.heading3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveTransaction,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeToggle(color),
              const SizedBox(height: 24),

              const Text('Amount', style: AppStyles.heading3),
              const SizedBox(height: 12),
              _buildAmountField(color),
              const SizedBox(height: 20),

              const Text('Title', style: AppStyles.heading3),
              const SizedBox(height: 12),
              _buildTitleField(),

              if (_suggestedCategory != null && _selectedCategory != _suggestedCategory)
                _buildSuggestionBanner(),

              const SizedBox(height: 20),

              const Text('Category', style: AppStyles.heading3),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildDatePicker()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPaymentMethod()),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _noteCtrl,
                decoration: AppStyles.inputDecoration(
                  labelText: 'Note (optional)',
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isSaving ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isEdit ? 'Update Transaction' : 'Save Transaction',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: ['expense', 'income'].map((t) {
          final selected = _type == t;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                SmartFeatures.lightTap();
                setState(() {
                  _type = t;
                  _selectedCategory = null;
                  _suggestedCategory = null;
                });
                _loadLastCategory();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? (t == 'expense' ? AppColors.expense : AppColors.income) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  t == 'expense' ? 'Expense' : 'Allowance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.bold, fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAmountField(Color color) {
    return GestureDetector(
      onDoubleTap: () {
        SmartFeatures.mediumTap();
        _amountCtrl.clear();
      },
      child: ValidatedTextField(
        controller: _amountCtrl,
        label: 'Amount',
        icon: Icons.attach_money,
        validator: AmountValidator.validate,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        hint: '100 (double tap to clear)',
      ),
    );
  }

  Widget _buildTitleField() {
    return ValidatedTextField(
      controller: _titleCtrl,
      label: 'Title',
      icon: Icons.edit_note_rounded,
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return ValidationResult.invalid("Title cannot be empty");
        }
        if (val.length > 50) {
          return ValidationResult.invalid("Title is too long (max 50 chars)");
        }
        return ValidationResult.valid();
      },
      hint: 'Monthly Allowance',
    );
  }

  Widget _buildSuggestionBanner() {
    return GestureDetector(
      onTap: () {
        SmartFeatures.lightTap();
        setState(() => _selectedCategory = _suggestedCategory);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Suggested: $_suggestedCategory',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
            const Text('Tap to apply', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final cats = context.watch<CategoryProvider>().categories
        .where((c) => c.type.name == _type).toList();

    if (cats.isEmpty) return const Text("No categories found.");

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: cats.length,
        itemBuilder: (context, i) {
          final cat = cats[i];
          final selected = _selectedCategory == cat.name;
          return GestureDetector(
            onTap: () {
              SmartFeatures.lightTap();
              setState(() => _selectedCategory = cat.name);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              margin: const EdgeInsets.only(right: 12, top: 5, bottom: 5),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.grey.shade200, width: 2),
                boxShadow: selected ? AppColors.primaryShadow : AppStyles.cardShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(cat.name,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : AppColors.textPrimary),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        SmartFeatures.lightTap();
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null && mounted) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date', style: AppStyles.caption),
            const SizedBox(height: 5),
            Row(children: [
              const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(DateFormat('dd MMM').format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Method', style: AppStyles.caption),
          const SizedBox(height: 5),
          DropdownButton<String>(
            value: _paymentMethod,
            isDense: true,
            underline: const SizedBox(),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
            items: ['Cash', 'Card', 'UPI', 'Bank'].map((v) =>
              DropdownMenuItem(value: v,
                child: Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))).toList(),
            onChanged: (val) {
              SmartFeatures.lightTap();
              setState(() => _paymentMethod = val!);
            },
          ),
        ],
      ),
    );
  }
}
