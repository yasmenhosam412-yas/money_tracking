import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/features/expenses_tab/presentation/bloc/expenses_tab_bloc.dart';
import 'package:imrpo/l10n/app_localizations.dart';

Future<void> showExpenseSheet(
  BuildContext context, {
  required Widget sheet,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: BlocProvider.value(
        value: context.read<ExpensesTabBloc>(),
        child: sheet,
      ),
    ),
  );

  if (!context.mounted || result == null) return;

  final message = switch (result) {
    'added' => l10n.expenseAddedSuccess,
    'updated' => l10n.expenseUpdatedSuccess,
    _ => null,
  };
  if (message != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
