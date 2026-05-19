import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:imrpo/core/services/currency_converter.dart';
import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/core/widgets/currency_amount_field.dart';
import 'package:imrpo/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:imrpo/features/incomes_tab/domain/entities/income.dart';
import 'package:imrpo/features/incomes_tab/presentation/bloc/incomes_tab_bloc.dart';
import 'package:imrpo/core/l10n/l10n_entity_strings.dart';
import 'package:imrpo/l10n/app_localizations.dart';

class AddIncomeSheet extends StatefulWidget {
  final Income? income;

  const AddIncomeSheet({super.key, this.income});

  @override
  State<AddIncomeSheet> createState() => _AddIncomeSheetState();
}

class _AddIncomeSheetState extends State<AddIncomeSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _otherCategoryController = TextEditingController();
  String _category = 'Work';
  late String _currencyCode;
  DateTime _date = DateTime.now();

  static const _otherCategory = 'Other';

  bool get _isEditing => widget.income != null;

  @override
  void initState() {
    super.initState();
    _currencyCode = getIt<CurrencyPreferences>().displayCode;
    final income = widget.income;
    if (income != null) {
      _titleController.text = income.title;
      _amountController.text = _formatDisplayAmount(income.amount);
      _date = income.date;
      if (_categories.contains(income.category)) {
        _category = income.category;
      } else {
        _category = _otherCategory;
        _otherCategoryController.text = income.category;
      }
    }
  }

  static const _categories = [
    'Work',
    'Freelance',
    'Business',
    'Investment',
    _otherCategory,
  ];

  bool get _isOtherCategory => _category == _otherCategory;

  bool _didPop = false;

  void _closeSheetOnSuccess() {
    if (_didPop) return;
    _didPop = true;
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop(_isEditing ? 'updated' : 'added');
    });
  }

  bool _isSubmitting(IncomesTabState state) =>
      state.status == IncomesTabStatus.loadingAdd ||
      state.status == IncomesTabStatus.loadingUpdate;

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

    return BlocListener<IncomesTabBloc, IncomesTabState>(
      listenWhen: (previous, current) {
        final finishedSubmit =
            (previous.status == IncomesTabStatus.loadingAdd ||
                previous.status == IncomesTabStatus.loadingUpdate) &&
            current.status == IncomesTabStatus.loaded;
        final failedSubmit =
            current.status == IncomesTabStatus.errorAdd ||
            current.status == IncomesTabStatus.errorUpdate;
        return finishedSubmit || failedSubmit;
      },
      listener: (context, state) {
        if (state.status == IncomesTabStatus.errorAdd ||
            state.status == IncomesTabStatus.errorUpdate) {
          _showError(localizeApiError(l10n, state.message));
          return;
        }
        _closeSheetOnSuccess();
      },
      child: BlocBuilder<IncomesTabBloc, IncomesTabState>(
        buildWhen: (previous, current) =>
            _isSubmitting(previous) != _isSubmitting(current),
        builder: (context, state) {
          return PopScope(
            canPop: !_isSubmitting(state),
            child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
              _isEditing ? l10n.editIncome : l10n.addIncome,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 24),
            CustomFormField(
              label: l10n.titleField,
              hint: l10n.hintIncomeTitle,
              controller: _titleController,
              obscure: false,
              icon: Icons.label_outline_rounded,
            ),
            const SizedBox(height: 16),
            CurrencyAmountField(
              label: l10n.amountField,
              controller: _amountController,
              accentColor: AppColors.income,
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
                  label: Text(localizeIncomeCategory(l10n, cat)),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = cat),
                  selectedColor: AppColors.income,
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
                      color: AppColors.income.withValues(alpha: 0.8),
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
            BlocBuilder<IncomesTabBloc, IncomesTabState>(
              builder: (context, state) {
                final isSubmitting =
                    state.status == IncomesTabStatus.loadingAdd ||
                    state.status == IncomesTabStatus.loadingUpdate;

                return SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.income,
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
                            _isEditing ? l10n.updateIncome : l10n.saveIncome,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
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
            colorScheme: ColorScheme.light(
              primary: AppColors.income,
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

    if (title.isEmpty) {
      _showError(AppLocalizations.of(context)!.errorEnterTitle);
      return;
    }
    if (amount == null || amount <= 0) {
      _showError(AppLocalizations.of(context)!.errorEnterValidAmount);
      return;
    }

    final baseAmount = CurrencyConverter.toBase(amount, _currencyCode);
    final category = _resolvedCategory();

    final bloc = context.read<IncomesTabBloc>();
    if (_isEditing) {
      bloc.add(
        UpdateIncomeEvent(
          id: widget.income!.id,
          title: title,
          category: category ?? 'Other',
          amount: baseAmount,
          date: _date,
        ),
      );
    } else {
      bloc.add(
        AddIncomeEvent(
          title: title,
          category: category ?? 'Other',
          amount: baseAmount,
          date: _date,
        ),
      );
    }
  }

  String _formatDisplayAmount(double baseAmount) {
    final display = CurrencyConverter.fromBase(baseAmount, _currencyCode);
    return display == display.roundToDouble()
        ? display.toInt().toString()
        : display.toStringAsFixed(2);
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
