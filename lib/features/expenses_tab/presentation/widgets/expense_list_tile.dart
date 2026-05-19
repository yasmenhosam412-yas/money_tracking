import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imrpo/features/expenses_tab/data/models/expense_model.dart';
import 'package:imrpo/features/expenses_tab/presentation/bloc/expenses_tab_bloc.dart';
import 'package:intl/intl.dart';
import 'package:imrpo/core/theme/app_decorations.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/core/utils/money_format.dart';
import 'package:imrpo/core/l10n/l10n_entity_strings.dart';
import 'package:imrpo/l10n/app_localizations.dart';

class ExpenseListTile extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ExpenseListTile({
    super.key,
    required this.expense,
    this.onTap,
    this.onDelete,
  });

  static const _expenseColor = AppColors.expense;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final category = localizeExpenseCategory(l10n, expense.category);
    final title = localizeDemoTitle(l10n, expense.title);
    final showTitleSubtitle =
        title.trim().toLowerCase() != category.trim().toLowerCase();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: AppDecorations.card(
            borderColor: AppColors.expense.withValues(alpha: 0.15),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: _expenseColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  color: _expenseColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      showTitleSubtitle
                          ? '$title · ${_formatDate(context, expense.date)}'
                          : _formatDate(context, expense.date),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textColor.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '-${Money.format(expense.amount)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _expenseColor,
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                BlocConsumer<ExpensesTabBloc, ExpensesTabState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    final isDeleting =
                        state.status == ExpensesTabStatus.loadingDelete &&
                        state.deletingExpenseId == expense.id;
                    return IconButton(
                      onPressed: isDeleting ? null : onDelete,
                      icon: isDeleting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: _expenseColor,
                              ),
                            )
                          : Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: AppColors.textColor.withValues(
                                alpha: 0.35,
                              ),
                            ),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.MMMd(locale).format(date);
  }
}
