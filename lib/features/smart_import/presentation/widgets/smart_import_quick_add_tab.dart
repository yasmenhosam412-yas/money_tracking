import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imrpo/core/l10n/l10n_entity_strings.dart';
import 'package:imrpo/core/models/parsed_financial_entry.dart';
import 'package:imrpo/core/services/currency_converter.dart';
import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/theme/app_decorations.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/core/widgets/currency_amount_field.dart';
import 'package:imrpo/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:imrpo/features/expenses_tab/domain/expense_categories.dart';
import 'package:imrpo/features/incomes_tab/presentation/bloc/incomes_tab_bloc.dart';
import 'package:imrpo/core/services/payment_methods_store.dart';
import 'package:imrpo/core/widgets/payment_method_chips_section.dart';
import 'package:imrpo/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

typedef QuickAddPayload = ({
  FinancialEntryType type,
  double amountInBase,
  String? title,
  DateTime date,
  String? expenseCategory,
  String? expensePaidFrom,
  String? incomeSource,
});

class SmartImportQuickAddTab extends StatefulWidget {
  final bool saving;
  final Future<void> Function(QuickAddPayload payload) onAddNow;
  final Future<void> Function(QuickAddPayload payload) onOpenFullForm;

  const SmartImportQuickAddTab({
    super.key,
    required this.saving,
    required this.onAddNow,
    required this.onOpenFullForm,
  });

  @override
  State<SmartImportQuickAddTab> createState() => _SmartImportQuickAddTabState();
}

class _SmartImportQuickAddTabState extends State<SmartImportQuickAddTab> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();

  FinancialEntryType _type = FinancialEntryType.expense;
  DateTime _date = DateTime.now();
  String _expenseCategory = 'Food';
  String _expensePaidFrom = PaymentMethodsStore.defaultPresets.first;
  String _incomeSource = PaymentMethodsStore.defaultPresets.first;
  String _currencyCode = CurrencyConverter.defaultDisplayCode;

  bool get _isExpense => _type == FinancialEntryType.expense;

  @override
  void initState() {
    super.initState();
    _currencyCode = getIt<CurrencyPreferences>().displayCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<IncomesTabBloc>().add(const LoadIncomesEvent());
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void resetForm() {
    setState(() {
      _amountController.clear();
      _titleController.clear();
      _type = FinancialEntryType.expense;
      _date = DateTime.now();
      _expenseCategory = 'Food';
      _expensePaidFrom = PaymentMethodsStore.defaultPresets.first;
      _incomeSource = PaymentMethodsStore.defaultPresets.first;
    });
  }

  void _toast(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.errorColor : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  QuickAddPayload? _buildPayload(AppLocalizations l10n) {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _toast(l10n.errorEnterValidAmount, error: true);
      return null;
    }

    final amountInBase = CurrencyConverter.toBase(amount, _currencyCode);
    final title = _titleController.text.trim();

    if (_isExpense) {
      if (_expensePaidFrom.trim().isEmpty) {
        _toast(l10n.smartImportBulkSelectPaidFrom, error: true);
        return null;
      }
      return (
        type: FinancialEntryType.expense,
        amountInBase: amountInBase,
        title: title.isEmpty ? null : title,
        date: _date,
        expenseCategory: _expenseCategory,
        expensePaidFrom: _expensePaidFrom,
        incomeSource: null,
      );
    }

    if (_incomeSource.trim().isEmpty) {
      _toast(l10n.smartImportBulkSelectIncomeSource, error: true);
      return null;
    }

    return (
      type: FinancialEntryType.income,
      amountInBase: amountInBase,
      title: title.isEmpty ? null : title,
      date: _date,
      expenseCategory: null,
      expensePaidFrom: null,
      incomeSource: _incomeSource,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit(Future<void> Function(QuickAddPayload) action) async {
    if (widget.saving) return;
    final l10n = AppLocalizations.of(context)!;
    final payload = _buildPayload(l10n);
    if (payload == null) return;
    await action(payload);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final disabled = widget.saving;
    final accent = _isExpense ? AppColors.expense : AppColors.income;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: AppDecorations.card(
            borderColor: AppColors.primary.withValues(alpha: 0.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.smartImportQuickHint,
                  style: TextStyle(
                    color: AppColors.textColor.withValues(alpha: 0.72),
                    height: 1.45,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l10n.smartImportQuickTypeLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _TypeChip(
                label: l10n.tabExpenses,
                icon: Icons.north_east_rounded,
                color: AppColors.expense,
                selected: _isExpense,
                onTap: disabled
                    ? null
                    : () => setState(() => _type = FinancialEntryType.expense),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TypeChip(
                label: l10n.tabIncomes,
                icon: Icons.south_west_rounded,
                color: AppColors.income,
                selected: !_isExpense,
                onTap: disabled
                    ? null
                    : () => setState(() => _type = FinancialEntryType.income),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        CurrencyAmountField(
          label: l10n.smartImportQuickAmountLabel,
          controller: _amountController,
          accentColor: accent,
          initialCurrencyCode: _currencyCode,
          onCurrencyChanged: (c) => _currencyCode = c.code,
        ),
        const SizedBox(height: 14),
        CustomFormField(
          controller: _titleController,
          label: l10n.titleField,
          hint: l10n.smartImportQuickTitleHint,
          icon: Icons.label_outline_rounded,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 14),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: disabled ? null : _pickDate,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: AppColors.textColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.smartImportDateField,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textColor.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          DateFormat.yMMMd(locale).format(_date),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textColor.withValues(alpha: 0.35),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isExpense) ...[
          const SizedBox(height: 20),
          Text(
            l10n.smartImportBulkExpenseCategory,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExpenseCategories.presets.map((cat) {
              final selected = _expenseCategory == cat;
              return ChoiceChip(
                label: Text(localizeExpenseCategory(l10n, cat)),
                selected: selected,
                onSelected: disabled
                    ? null
                    : (_) => setState(() => _expenseCategory = cat),
                selectedColor: AppColors.expense,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textColor,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: AppColors.surface,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          PaymentMethodChipsSection(
            label: l10n.expensePaidFromField,
            hint: l10n.smartImportBulkExpensePaidFromHint,
            selected: _expensePaidFrom,
            onSelected: disabled
                ? (_) {}
                : (src) => setState(() => _expensePaidFrom = src),
            accentColor: AppColors.expense,
            enabled: !disabled,
          ),
        ] else ...[
          const SizedBox(height: 20),
          PaymentMethodChipsSection(
            label: l10n.smartImportBulkIncomeSource,
            hint: l10n.smartImportBulkIncomeSourceHint,
            selected: _incomeSource,
            onSelected: disabled
                ? (_) {}
                : (src) => setState(() => _incomeSource = src),
            accentColor: AppColors.income,
            enabled: !disabled,
          ),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: disabled ? null : () => _submit(widget.onAddNow),
          icon: widget.saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded),
          label: Text(l10n.smartImportQuickAddNow),
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: disabled ? null : () => _submit(widget.onOpenFullForm),
          icon: const Icon(Icons.edit_note_rounded, size: 20),
          label: Text(l10n.smartImportQuickReview),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withValues(alpha: 0.14) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? color : AppColors.textColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
