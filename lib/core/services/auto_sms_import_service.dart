import 'package:imrpo/core/config/app_router.dart';
import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:imrpo/core/services/auto_sms_import_preferences.dart';
import 'package:imrpo/core/services/sms_bulk_import_service.dart';
import 'package:imrpo/core/services/sms_import_service.dart';
import 'package:imrpo/core/services/app_lock_service.dart';
import 'package:imrpo/core/session/user_session.dart';

class AutoSmsImportRunResult {
  final bool skipped;
  final bool permissionDenied;
  final int expenseCount;
  final int incomeCount;
  final int failed;

  const AutoSmsImportRunResult({
    this.skipped = false,
    this.permissionDenied = false,
    this.expenseCount = 0,
    this.incomeCount = 0,
    this.failed = 0,
  });

  int get added => expenseCount + incomeCount;
  bool get hasAny => added > 0;
}

/// Scans recent financial SMS and imports new rows using saved defaults.
class AutoSmsImportService {
  static const _scanPageSize = 120;
  static const _maxRawScan = 800;

  final AutoSmsImportPreferences _prefs;
  final SmsImportService _smsImport;
  final SmsBulkImportService _bulkImport;
  final AppLockService _appLock;

  bool _running = false;

  AutoSmsImportService({
    required AutoSmsImportPreferences preferences,
    required SmsImportService smsImport,
    required SmsBulkImportService bulkImport,
    required AppLockService appLock,
  })  : _prefs = preferences,
        _smsImport = smsImport,
        _bulkImport = bulkImport,
        _appLock = appLock;

  bool get isRunning => _running;

  Future<AutoSmsImportRunResult> runNow() async {
    if (_running) {
      return const AutoSmsImportRunResult(skipped: true);
    }
    if (!_prefs.enabled || !_prefs.defaultsConfigured) {
      return const AutoSmsImportRunResult(skipped: true);
    }
    if (!_smsImport.isSupported) {
      return const AutoSmsImportRunResult(skipped: true);
    }
    if (!SupabaseAuthHelper.isSignedIn) {
      return const AutoSmsImportRunResult(skipped: true);
    }
    if (_appLock.isEnabled && _appLock.isLocked) {
      return const AutoSmsImportRunResult(skipped: true);
    }

    _running = true;
    try {
      if (!await _smsImport.hasPermission()) {
        return const AutoSmsImportRunResult(permissionDenied: true);
      }

      final page = await _smsImport.loadFinancialMessagesPage(
        rawStart: 0,
        pageSize: _scanPageSize,
        maxRawScan: _maxRawScan,
      );

      final cutoff = _prefs.lastScanAt;
      final importable = page.items.where((item) {
        if (!_bulkImport.canImport(item)) return false;
        if (cutoff != null && item.date.isBefore(cutoff)) return false;
        return true;
      }).toList();

      if (importable.isEmpty) {
        await _prefs.markScanComplete();
        return const AutoSmsImportRunResult();
      }

      final result = await _bulkImport.importAll(
        importable,
        expenseCategory: _prefs.expenseCategory,
        incomeSource: _prefs.incomeSource,
        expensePaidFrom: _prefs.expensePaidFrom,
      );

      await _prefs.markScanComplete();

      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null && ctx.mounted && result.hasAny) {
        UserSession.refreshAfterAutoImport(ctx);
      }

      return AutoSmsImportRunResult(
        expenseCount: result.expenseCount,
        incomeCount: result.incomeCount,
        failed: result.failed,
      );
    } finally {
      _running = false;
    }
  }
}
