import 'dart:async';

import 'package:flutter/material.dart';
import 'package:imrpo/core/services/app_lock_service.dart';
import 'package:imrpo/core/services/auto_sms_import_preferences.dart';
import 'package:imrpo/core/services/auto_sms_import_service.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/l10n/app_localizations.dart';

/// Runs auto SMS import when the app resumes (if enabled in settings).
class AutoSmsImportGate extends StatefulWidget {
  final Widget child;

  const AutoSmsImportGate({super.key, required this.child});

  @override
  State<AutoSmsImportGate> createState() => _AutoSmsImportGateState();
}

class _AutoSmsImportGateState extends State<AutoSmsImportGate>
    with WidgetsBindingObserver {
  Timer? _resumeDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleScan());
  }

  @override
  void dispose() {
    _resumeDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleScan();
    }
  }

  void _scheduleScan() {
    final prefs = getIt<AutoSmsImportPreferences>();
    if (!prefs.enabled) return;

    _resumeDebounce?.cancel();
    _resumeDebounce = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _runScan();
    });
  }

  Future<void> _runScan() async {
    final lock = getIt<AppLockService>();
    if (lock.isEnabled && lock.isLocked) return;

    final result = await getIt<AutoSmsImportService>().runNow();
    if (!mounted || !result.hasAny) return;

    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.autoSmsImportAddedSnack(
            result.incomeCount,
            result.expenseCount,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
