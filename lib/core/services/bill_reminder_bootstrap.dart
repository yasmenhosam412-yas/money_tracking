import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:imrpo/core/services/bill_reminder_debug_log.dart';
import 'package:imrpo/core/services/bill_reminder_notification_service.dart';
import 'package:imrpo/core/services/bill_reminder_preferences.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/features/bill_reminders/data/bill_reminder_store.dart';
import 'package:imrpo/features/bill_reminders/data/repositories/bill_reminder_repository_impl.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

Future<void> configureBillReminderTimezone() async {
  tz_data.initializeTimeZones();
  try {
    final name = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(name));
    billReminderLog('timezone: set to $name → ${tz.local.name}');
  } catch (e) {
    billReminderLog('timezone: device lookup failed ($e), fallback Africa/Cairo');
    try {
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
      billReminderLog('timezone: fallback ${tz.local.name}');
    } catch (e2) {
      billReminderLogError('timezone: fallback failed', e2);
    }
  }
}

Future<void> bootstrapBillReminders() async {
  billReminderLog('bootstrap: start');
  await configureBillReminderTimezone();
  await getIt<BillReminderPreferences>().load();
  final prefs = getIt<BillReminderPreferences>();
  billReminderLog('bootstrap: prefs enabled=${prefs.enabled}');

  await BillReminderNotificationService.instance.initialize();

  if (!SupabaseAuthHelper.isSignedIn) {
    billReminderLog('bootstrap: SKIP — not signed in');
    return;
  }
  if (!prefs.enabled) {
    billReminderLog('bootstrap: SKIP — reminders disabled');
    return;
  }

  final repo = BillReminderRepositoryImpl(store: BillReminderStore());
  final result = await repo.getAll();
  result.fold(
    (failure) => billReminderLog('bootstrap: load failed ${failure.error}'),
    (list) async {
      billReminderLog('bootstrap: loaded ${list.length} reminder(s)');
      await BillReminderNotificationService.instance.rescheduleAll(
        list,
        mode: BillReminderScheduleMode.repair,
      );
    },
  );
  billReminderLog('bootstrap: end');
}
