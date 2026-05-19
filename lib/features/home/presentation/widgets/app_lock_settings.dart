import 'package:flutter/material.dart';
import 'package:imrpo/core/services/app_lock_service.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/features/home/presentation/widgets/app_lock_setup_sheet.dart';
import 'package:imrpo/l10n/app_localizations.dart';

Future<void> enableAppLock(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final lock = getIt<AppLockService>();

  final pin = await showAppLockPinSheet(
    context,
    title: l10n.appLockCreatePinTitle,
    subtitle: l10n.appLockCreatePinSubtitle,
  );
  if (!context.mounted || pin == null) return;

  final confirmed = await showAppLockPinSheet(
    context,
    title: l10n.appLockConfirmPinTitle,
    subtitle: l10n.appLockConfirmPinSubtitle,
    isConfirmation: true,
    expectedPin: pin,
    dismissible: false,
  );
  if (!context.mounted || confirmed == null) return;

  final ok = await lock.enableLock(confirmed);
  if (!context.mounted) return;

  if (!ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.appLockEnableFailed),
        backgroundColor: AppColors.errorColor,
      ),
    );
    return;
  }

  if (lock.canUseBiometrics) {
    final useBio = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.appLockBiometricPromptTitle),
        content: Text(l10n.appLockBiometricPromptMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.enable),
          ),
        ],
      ),
    );

    if (useBio == true && context.mounted) {
      await lock.setBiometricEnabled(
        true,
        localizedReason: l10n.appLockBiometricReason,
      );
    }
  }

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.appLockEnabledSuccess)),
  );
}

Future<void> disableAppLock(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final lock = getIt<AppLockService>();

  final pin = await showAppLockPinSheet(
    context,
    title: l10n.appLockEnterPinTitle,
    subtitle: l10n.appLockEnterPinSubtitle,
  );
  if (!context.mounted || pin == null) return;

  final ok = await lock.disableLock(pin);
  if (!context.mounted) return;

  if (!ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.appLockWrongPin),
        backgroundColor: AppColors.errorColor,
      ),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.appLockDisabledSuccess)),
  );
}

Future<void> changeAppLockPin(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final lock = getIt<AppLockService>();

  final current = await showAppLockPinSheet(
    context,
    title: l10n.appLockEnterPinTitle,
    subtitle: l10n.appLockEnterPinSubtitle,
  );
  if (!context.mounted || current == null) return;

  if (!await lock.verifyPin(current)) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.appLockWrongPin),
        backgroundColor: AppColors.errorColor,
      ),
    );
    return;
  }

  if (!context.mounted) return;

  final newPin = await showAppLockPinSheet(
    context,
    title: l10n.appLockCreatePinTitle,
    subtitle: l10n.appLockCreatePinSubtitle,
  );
  if (!context.mounted || newPin == null) return;

  final confirmed = await showAppLockPinSheet(
    context,
    title: l10n.appLockConfirmPinTitle,
    subtitle: l10n.appLockConfirmPinSubtitle,
    isConfirmation: true,
    expectedPin: newPin,
    dismissible: false,
  );
  if (!context.mounted || confirmed == null) return;

  final ok = await lock.changePin(currentPin: current, newPin: confirmed);
  if (!context.mounted) return;

  if (!ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.appLockChangePinFailed),
        backgroundColor: AppColors.errorColor,
      ),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.appLockChangePinSuccess)),
  );
}

Future<void> toggleAppLockBiometric(
  BuildContext context, {
  required bool enabled,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final lock = getIt<AppLockService>();

  final ok = await lock.setBiometricEnabled(
    enabled,
    localizedReason: l10n.appLockBiometricReason,
  );
  if (!context.mounted) return;

  if (!ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.appLockBiometricFailed),
        backgroundColor: AppColors.errorColor,
      ),
    );
  }
}
