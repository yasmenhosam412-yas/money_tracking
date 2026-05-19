import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imrpo/features/expenses_tab/data/models/expense_model.dart';
import 'package:intl/intl.dart';
import 'package:imrpo/core/services/currency_converter.dart';
import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/core/widgets/currency_amount_field.dart';
import 'package:imrpo/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:imrpo/features/expenses_tab/domain/expense_categories.dart';
import 'package:imrpo/features/expenses_tab/presentation/bloc/expenses_tab_bloc.dart';
import 'package:imrpo/core/l10n/l10n_entity_strings.dart';
import 'package:imrpo/l10n/app_localizations.dart';

class AddExpenseSheet extends StatefulWidget {
  final ExpenseModel? expense;
  final String? initialTitle;
  final double? initialAmount;
  final DateTime? initialDate;

  const AddExpenseSheet({
    super.key,
    this.expense,
    this.initialTitle,
    this.initialAmount,
    this.initialDate,
  });

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  static const _expenseColor = AppColors.expense;

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _otherCategoryController = TextEditingController();
  String _category = 'Food';
  late String _currencyCode;
  DateTime _date = DateTime.now();

  bool get _isEditing => widget.expense != null;

  static const _otherCategory = ExpenseCategories.other;

  static const _categories = ExpenseCategories.presets;

  bool get _isOtherCategory => _category == _otherCategory;

  bool _didPop = false;
  bool _awaitingSubmitResult = false;

  void _closeSheetOnSuccess() {
    if (_didPop || !mounted) return;
    _didPop = true;
    _awaitingSubmitResult = false;
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop(_isEditing ? 'updated' : 'added');
    });
  }

  bool _isSubmitting(ExpensesTabState state) =>
      _awaitingSubmitResult &&
      (state.status == ExpensesTabStatus.loadingAdd ||
          state.status == ExpensesTabStatus.loadingUpdate ||
          state.status == ExpensesTabStatus.loadingAll);

  bool _shouldReactToState(ExpensesTabState state) {
    if (!_awaitingSubmitResult) return false;
    return state.status == ExpensesTabStatus.loaded ||
        state.status == ExpensesTabStatus.errorAdd ||
        state.status == ExpensesTabStatus.errorUpdate;
  }

  @override
  void initState() {
    super.initState();
    _currencyCode = getIt<CurrencyPreferences>().displayCode;
    final expense = widget.expense;
    if (expense != null) {
      _titleController.text = expense.title;
      _amountController.text = _formatDisplayAmount(expense.amount);
      _date = expense.date;
      if (_categories.contains(expense.category)) {
        _category = expense.category;
      } else {
        _category = _otherCategory;
        _otherCategoryController.text = expense.category;
      }
    } else {
      if (widget.initialTitle != null) {
        _titleController.text = widget.initialTitle!;
      }
      if (widget.initialAmount != null) {
        _amountController.text = _formatRawAmount(widget.initialAmount!);
      }
      if (widget.initialDate != null) {
        _date = widget.initialDate!;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _otherCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ExpensesTabBloc, ExpensesTabState>(
      listenWhen: (_, current) => _shouldReactToState(current),
      listener: (context, state) {
        if (state.status == ExpensesTabStatus.errorAdd ||
            state.status == ExpensesTabStatus.errorUpdate) {
          _awaitingSubmitResult = false;
          _showError(localizeApiError(l10n, state.error));
          return;
        }
        if (state.status == ExpensesTabStatus.loaded) {
          _closeSheetOnSuccess();
        }
      },
      child: BlocBuilder<ExpensesTabBloc, ExpensesTabState>(
        buildWhen: (previous, current) =>
            _isSubmitting(previous) != _isSubmitting(current) ||
            _shouldReactToState(previous) != _shouldReactToState(current),
        builder: (context, state) {
          final isSubmitting = _isSubmitting(state);

          return PopScope(
            canPop: !isSubmitting && !_didPop,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSubmitting)
                    const LinearProgressIndicator(
                      minHeight: 3,
                      color: _expenseColor,
                      backgroundColor: Color(0xFFE8E8E8),
                    ),
                  Flexible(
                    child: AbsorbPointer(
                      absorbing: isSubmitting,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isEditing ? l10n.editExpense : l10n.addExpense,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomFormField(
                      label: l10n.titleField,
                      hint: l10n.hintExpenseTitle,
                      controller: _titleController,
                      obscure: false,
                      icon: Icons.label_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    CurrencyAmountField(
                      label: l10n.amountField,
                      controller: _amountController,
                      accentColor: _expenseColor,
                      initialCurrencyCode: _currencyCode,
                      onCurrencyChanged: (c) => _currencyCode = c.code,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.categoryField,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final selected = _category == cat;
                        return ChoiceChip(
                          label: Text(localizeExpenseCategory(l10n, cat)),
                          selected: selected,
                          onSelected: (_) => setState(() => _category = cat),
                          selectedColor: _expenseColor,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppColors.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                          backgroundColor: AppColors.surface,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }).toList(),
                    ),
                    if (_isOtherCategory) ...[
                      const SizedBox(height: 16),
                      CustomFormField(
                        label: l10n.otherCategoryField,
                        hint: l10n.otherCategoryHint,
                        controller: _otherCategoryController,
                        obscure: false,
                        icon: Icons.category_outlined,
                      ),
                    ],
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: _expenseColor.withValues(alpha: 0.9),
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _formatDate(context, _date),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColor,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textColor.withValues(alpha: 0.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _expenseColor,
                          disabledBackgroundColor:
                              _expenseColor.withValues(alpha: 0.65),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: isSubmitting ? null : _submit,
                        child: isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEditing
                                    ? l10n.updateExpense
                                    : l10n.saveExpense,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _expenseColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    final l10n = AppLocalizations.of(context)!;

    if (title.isEmpty) {
      _showError(l10n.errorEnterTitle);
      return;
    }
    if (amount == null || amount <= 0) {
      _showError(l10n.errorEnterValidAmount);
      return;
    }

    final category = _resolvedCategory();
    if (category == null) {
      _showError(l10n.errorEnterCategoryName);
      return;
    }

    final baseAmount = CurrencyConverter.toBase(amount, _currencyCode);
    final bloc = context.read<ExpensesTabBloc>();

    setState(() => _awaitingSubmitResult = true);

    if (_isEditing) {
      bloc.add(
        UpdateExpenseEvent(
          id: widget.expense!.id,
          title: title,
          category: category,
          amount: baseAmount,
          date: _date,
        ),
      );
    } else {
      bloc.add(
        AddExpenseEvent(
          title: title,
          category: category,
          amount: baseAmount,
          date: _date,
        ),
      );
    }
  }

  String _formatDisplayAmount(double baseAmount) {
    final display = CurrencyConverter.fromBase(baseAmount, _currencyCode);
    return _formatRawAmount(display);
  }

  String _formatRawAmount(double amount) {
    return amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
  }

  String? _resolvedCategory() {
    if (!_isOtherCategory) return _category;
    final custom = _otherCategoryController.text.trim();
    if (custom.isEmpty) return null;
    return custom;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(date);
  }
}
