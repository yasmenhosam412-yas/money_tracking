import 'package:flutter/material.dart';
import 'package:imrpo/core/services/auto_sms_import_preferences.dart';
import 'package:imrpo/core/services/auto_sms_import_service.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/services/sms_import_service.dart';
import 'package:imrpo/core/session/user_session.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/features/smart_import/presentation/widgets/smart_import_bulk_category_sheet.dart';
import 'package:imrpo/l10n/app_localizations.dart';

Future<bool> configureAutoSmsImportDefaults(BuildContext context) async {
  final prefs = getIt<AutoSmsImportPreferences>();
  final l10n = AppLocalizations.of(context)!;

  final categories = await showSmartImportBulkCategorySheet(
    context,
    needsExpenseCategory: true,
    needsIncomeSource: true,
    initialExpenseCategory: prefs.expenseCategory,
    initialIncomeSource: prefs.incomeSource,
    initialExpensePaidFrom: prefs.expensePaidFrom,
    sheetTitle: l10n.settingsAutoSmsImportDefaultsTitle,
    sheetHint: l10n.settingsAutoSmsImportDefaultsHint,
  );

  if (categories == null) return false;
  if (categories.expenseCategory == null ||
      categories.incomeSource == null ||
      categories.expensePaidFrom == null) {
    return false;
  }

  await prefs.setDefaults(
    expenseCategory: categories.expenseCategory!,
    incomeSource: categories.incomeSource!,
    expensePaidFrom: categories.expensePaidFrom!,
  );
  return true;
}

Future<void> setAutoSmsImportEnabled(
  BuildContext context, {
  required bool enabled,
}) async {
  final prefs = getIt<AutoSmsImportPreferences>();
  final sms = getIt<SmsImportService>();
  final l10n = AppLocalizations.of(context)!;

  if (!enabled) {
    await prefs.setEnabled(false);
    return;
  }

  final granted = await sms.requestPermission();
  if (!granted) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.settingsAutoSmsImportPermissionDenied),
        backgroundColor: AppColors.errorColor,
      ),
    );
    return;
  }

  if (!prefs.defaultsConfigured) {
    if (!context.mounted) return;
    final configured = await configureAutoSmsImportDefaults(context);
    if (!configured || !context.mounted) return;
  }

  await prefs.setEnabled(true, markScanFromNow: true);

  if (!context.mounted) return;

  final result = await getIt<AutoSmsImportService>().runNow();
  if (!context.mounted) return;

  UserSession.refreshAfterAutoImport(context);

  if (result.hasAny) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.autoSmsImportAddedSnack(
            result.incomeCount,
            result.expenseCount,
          ),
        ),
      ),
    );
  } else if (!result.skipped && !result.permissionDenied) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsAutoSmsImportEnabled)),
    );
  }
}
