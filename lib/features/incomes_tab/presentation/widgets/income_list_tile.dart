import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imrpo/features/incomes_tab/presentation/bloc/incomes_tab_bloc.dart';
import 'package:intl/intl.dart';
import 'package:imrpo/core/theme/app_decorations.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/core/utils/money_format.dart';
import 'package:imrpo/features/incomes_tab/domain/entities/income.dart';
import 'package:imrpo/core/l10n/l10n_entity_strings.dart';
import 'package:imrpo/l10n/app_localizations.dart';

class IncomeListTile extends StatelessWidget {
  final Income income;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const IncomeListTile({
    super.key,
    required this.income,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cat = localizeIncomeCategory(l10n, income.category);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: AppDecorations.card(
            borderColor: AppColors.income.withValues(alpha: 0.15),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.incomeLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  color: AppColors.income,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizeDemoTitle(l10n, income.title),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$cat · ${_formatDate(context, income.date)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textColor.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '+${Money.format(income.amount)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.income,
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                BlocBuilder<IncomesTabBloc, IncomesTabState>(
                  buildWhen: (previous, current) =>
                      previous.deletingIncomeId != current.deletingIncomeId ||
                      previous.status != current.status,
                  builder: (context, state) {
                    final isDeleting =
                        state.status == IncomesTabStatus.loadingDelete &&
                        state.deletingIncomeId == income.id;

                    return IconButton(
                      onPressed: isDeleting ? null : onDelete,
                      icon: isDeleting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.income,
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
