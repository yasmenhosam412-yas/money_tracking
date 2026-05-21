import 'dart:async';

import 'package:flutter/material.dart';
import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:imrpo/core/services/app_lock_service.dart';
import 'package:imrpo/core/services/bill_reminder_preferences.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/features/bill_reminders/data/bill_reminder_store.dart';
import 'package:imrpo/features/bill_reminders/data/repositories/bill_reminder_repository_impl.dart';
import 'package:imrpo/core/services/bill_reminder_debug_log.dart';
import 'package:imrpo/core/services/bill_reminder_notification_service.dart';

/// Re-syncs scheduled bill notifications when the app resumes.
class BillReminderGate extends StatefulWidget {
  final Widget child;

  const BillReminderGate({super.key, required this.child});

  @override
  State<BillReminderGate> createState() => _BillReminderGateState();
}

class _BillReminderGateState extends State<BillReminderGate>
    with WidgetsBindingObserver {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleSync();
    }
  }

  void _scheduleSync() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _syncNotifications();
    });
  }

  Future<void> _syncNotifications() async {
    billReminderLog('gate: sync start');
    final prefs = getIt<BillReminderPreferences>();
    if (!prefs.enabled) {
      billReminderLog('gate: SKIP — disabled');
      return;
    }
    if (!SupabaseAuthHelper.isSignedIn) {
      billReminderLog('gate: SKIP — not signed in');
      return;
    }

    final lock = getIt<AppLockService>();
    if (lock.isEnabled && lock.isLocked) {
      billReminderLog('gate: SKIP — app locked');
      return;
    }

    try {
      final repo = BillReminderRepositoryImpl(store: BillReminderStore());
      final result = await repo.getAll();
      result.fold(
        (failure) => billReminderLog('gate: load failed ${failure.error}'),
        (reminders) async {
          billReminderLog('gate: repair sync ${reminders.length} reminder(s)');
          await BillReminderNotificationService.instance.rescheduleAll(
            reminders,
            mode: BillReminderScheduleMode.repair,
          );
        },
      );
    } catch (e, st) {
      billReminderLogError('gate: sync failed', e, st);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
