import 'package:flutter/material.dart';
import 'package:imrpo/core/utils/app_colors.dart';

/// Floating toast-style feedback (short-lived, not a full snackbar bar).
class AppToast {
  AppToast._();

  static void show(
    BuildContext context,
    String message, {
    bool error = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: error ? AppColors.error : AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: duration,
        ),
      );
  }

  static void error(BuildContext context, String message) =>
      show(context, message, error: true);

  static void success(BuildContext context, String message) =>
      show(context, message, error: false);
}
