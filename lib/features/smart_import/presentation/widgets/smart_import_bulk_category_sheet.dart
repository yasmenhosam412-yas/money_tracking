import 'package:flutter/material.dart';
import 'package:imrpo/core/l10n/l10n_entity_strings.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:imrpo/l10n/app_localizations.dart';

class BulkImportCategories {
  final String? expenseCategory;
  final String? incomeSource;

  const BulkImportCategories({
    this.expenseCategory,
    this.incomeSource,
  });
}

Future<BulkImportCategories?> showSmartImportBulkCategorySheet(
  BuildContext context, {
  required bool needsExpenseCategory,
  required bool needsIncomeSource,
}) {
  return showModalBottomSheet<BulkImportCategories>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _SmartImportBulkCategorySheet(
      needsExpenseCategory: needsExpenseCategory,
      needsIncomeSource: needsIncomeSource,
    ),
  );
}

class _SmartImportBulkCategorySheet extends StatefulWidget {
  final bool needsExpenseCategory;
  final bool needsIncomeSource;

  const _SmartImportBulkCategorySheet({
    required this.needsExpenseCategory,
    required this.needsIncomeSource,
  });

  @override
  State<_SmartImportBulkCategorySheet> createState() =>
      _SmartImportBulkCategorySheetState();
}

class _SmartImportBulkCategorySheetState
    extends State<_SmartImportBulkCategorySheet> {
  static const _expenseOther = 'Other';
  static const _expenseCategories = [
    'Food',
    'Rent',
    'Transport',
    'Shopping',
    'Bills',
    _expenseOther,
  ];

  static const _incomeSuggested = [
    'Salary',
    'Rents',
    'Visa Card',
    'Cash',
    'Freelance',
    'Business',
    'Investment',
  ];

  String _expenseCategory = 'Bills';
  final _expenseOtherController = TextEditingController();
  final _incomeSourceController = TextEditingController(text: 'Other');

  bool get _isExpenseOther => _expenseCategory == _expenseOther;

  @override
  void dispose() {
    _expenseOtherController.dispose();
    _incomeSourceController.dispose();
    super.dispose();
  }

  String? _resolvedExpenseCategory() {
    if (!_isExpenseOther) return _expenseCategory;
    final custom = _expenseOtherController.text.trim();
    return custom.isEmpty ? null : custom;
  }

  String? _resolvedIncomeSource() {
    final source = _incomeSourceController.text.trim();
    return source.isEmpty ? null : source;
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    String? expense;
    String? income;

    if (widget.needsExpenseCategory) {
      expense = _resolvedExpenseCategory();
      if (expense == null) {
        _showError(l10n.errorEnterCategoryName);
        return;
      }
    }
    if (widget.needsIncomeSource) {
      income = _resolvedIncomeSource();
      if (income == null) {
        _showError(l10n.errorEnterCategoryName);
        return;
      }
    }

    Navigator.of(context).pop(
      BulkImportCategories(
        expenseCategory: expense,
        incomeSource: income,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                l10n.smartImportBulkCategorySheetTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.smartImportBulkCategorySheetHint,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textColor.withValues(alpha: 0.6),
                  height: 1.35,
                ),
              ),
              if (widget.needsExpenseCategory) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.smartImportBulkExpenseCategory,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _expenseCategories.map((cat) {
                    final selected = _expenseCategory == cat;
                    return ChoiceChip(
                      label: Text(localizeExpenseCategory(l10n, cat)),
                      selected: selected,
                      onSelected: (_) => setState(() => _expenseCategory = cat),
                      selectedColor: AppColors.expense,
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
                if (_isExpenseOther) ...[
                  const SizedBox(height: 12),
                  CustomFormField(
                    label: l10n.otherCategoryField,
                    hint: l10n.otherCategoryHint,
                    controller: _expenseOtherController,
                    obscure: false,
                    icon: Icons.category_outlined,
                  ),
                ],
              ],
              if (widget.needsIncomeSource) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.smartImportBulkIncomeSource,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 10),
                CustomFormField(
                  label: l10n.incomeSourceField,
                  hint: l10n.hintIncomeSource,
                  controller: _incomeSourceController,
                  obscure: false,
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _incomeSuggested.map((source) {
                    return ActionChip(
                      label: Text(localizeIncomeCategory(l10n, source)),
                      onPressed: () {
                        setState(() => _incomeSourceController.text = source);
                      },
                      backgroundColor: AppColors.incomeLight,
                      labelStyle: const TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.smartImportBulkApplyAndImport,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
