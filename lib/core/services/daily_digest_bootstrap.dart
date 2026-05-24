import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:imrpo/core/services/bill_reminder_debug_log.dart';
import 'package:imrpo/core/services/daily_digest_notification_service.dart';
import 'package:imrpo/core/services/daily_digest_preferences.dart';
import 'package:imrpo/core/services/service_locator.dart';

Future<void> bootstrapDailyDigest() async {
  billReminderLog('dailyDigest bootstrap: start');
  await getIt<DailyDigestPreferences>().load();
  final prefs = getIt<DailyDigestPreferences>();

  await DailyDigestNotificationService.instance.initialize();

  if (!SupabaseAuthHelper.isSignedIn) {
    billReminderLog('dailyDigest bootstrap: SKIP — not signed in');
    return;
  }
  if (!prefs.enabled) {
    billReminderLog('dailyDigest bootstrap: SKIP — disabled');
    return;
  }

  await DailyDigestNotificationService.instance.reschedule(
    mode: DailyDigestScheduleMode.repair,
  );
  billReminderLog('dailyDigest bootstrap: end');
}
