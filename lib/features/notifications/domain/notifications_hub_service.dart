import 'package:imrpo/core/services/bill_reminder_preferences.dart';
import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/daily_digest_preferences.dart';
import 'package:imrpo/core/services/daily_digest_summary_service.dart';
import 'package:imrpo/core/services/locale_preferences.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/utils/daily_digest_body_formatter.dart';
import 'package:imrpo/features/bill_reminders/domain/bill_reminder_day_helper.dart';
import 'package:imrpo/features/bill_reminders/domain/entities/bill_reminder.dart';
import 'package:imrpo/features/bill_reminders/domain/repositories/bill_reminder_repository.dart';
import 'package:imrpo/features/notifications/domain/scheduled_notification_item.dart';
import 'package:imrpo/l10n/app_localizations.dart';
import 'package:imrpo/core/utils/locale_date_format.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationsHubService {
  final DailyDigestSummaryService _digestSummaryService =
      DailyDigestSummaryService();

  Future<List<ScheduledNotificationItem>> loadUpcoming(
    AppLocalizations l10n,
  ) async {
    final items = <ScheduledNotificationItem>[];
    final now = tz.TZDateTime.now(tz.local);
    final money = getIt<CurrencyPreferences>();
    final locale = getIt<LocalePreferences>().locale.toString();

    final billPrefs = getIt<BillReminderPreferences>();
    if (billPrefs.enabled) {
      final result = await getIt<BillReminderRepository>().getAll();
      result.fold((_) {}, (reminders) {
        for (final reminder in reminders.where((r) => r.isEnabled)) {
          final item = _billReminderItem(l10n, money, locale, reminder, now);
          if (item != null) items.add(item);
        }
      });
    }

    final digestPrefs = getIt<DailyDigestPreferences>();
    if (digestPrefs.enabled) {
      final fireAt = _nextDailyDigestFireAt(digestPrefs.hour, digestPrefs.minute);
      if (fireAt.isAfter(now)) {
        final localFire = fireAt.toLocal();
        final summary =
            await _digestSummaryService.buildForNotificationFireAt(localFire);
        items.add(
          ScheduledNotificationItem(
            kind: ScheduledNotificationKind.dailyDigest,
            scheduledAt: localFire,
            title: l10n.dailyDigestNotificationTitle,
            subtitle: l10n.notificationsScheduledDigestSubtitle(
              _formatDateTime(localFire, locale),
            ),
            description: formatDailyDigestNotificationBody(l10n, money, summary),
          ),
        );
      }
    }

    items.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return items;
  }

  /// Notifications whose scheduled time has passed (last 30 days).
  Future<List<ScheduledNotificationItem>> loadRecentlyFired(
    AppLocalizations l10n, {
    Duration lookback = const Duration(days: 30),
  }) async {
    final items = <ScheduledNotificationItem>[];
    final now = tz.TZDateTime.now(tz.local);
    final cutoff = now.subtract(lookback);
    final money = getIt<CurrencyPreferences>();
    final locale = getIt<LocalePreferences>().locale.toString();

    final billPrefs = getIt<BillReminderPreferences>();
    if (billPrefs.enabled) {
      final result = await getIt<BillReminderRepository>().getAll();
      result.fold((_) {}, (reminders) {
        for (final reminder in reminders.where((r) => r.isEnabled)) {
          final item = _billReminderItem(
            l10n,
            money,
            locale,
            reminder,
            now,
            includeIfFired: true,
            notBefore: cutoff,
          );
          if (item != null) items.add(item);
        }
      });
    }

    final digestPrefs = getIt<DailyDigestPreferences>();
    if (digestPrefs.enabled) {
      final hour = digestPrefs.hour.clamp(0, 23);
      final minute = digestPrefs.minute.clamp(0, 59);
      var fireAt = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (!fireAt.isAfter(now) && fireAt.isAfter(cutoff)) {
        final localFire = fireAt.toLocal();
        final summary = await _digestSummaryService
            .buildForNotificationFireAt(localFire);
        items.add(
          ScheduledNotificationItem(
            kind: ScheduledNotificationKind.dailyDigest,
            scheduledAt: localFire,
            title: l10n.dailyDigestNotificationTitle,
            subtitle: l10n.notificationsScheduledDigestSubtitle(
              _formatDateTime(localFire, locale),
            ),
            description: formatDailyDigestNotificationBody(l10n, money, summary),
          ),
        );
      }
    }

    items.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
    return items;
  }

  ScheduledNotificationItem? _billReminderItem(
    AppLocalizations l10n,
    CurrencyPreferences money,
    String locale,
    BillReminder reminder,
    tz.TZDateTime now, {
    bool includeIfFired = false,
    tz.TZDateTime? notBefore,
  }) {
    final hour = reminder.reminderHour.clamp(0, 23);
    final minute = reminder.reminderMinute.clamp(0, 59);
    final day = BillReminderDayHelper.clampStoredDay(reminder.dayOfMonth);
    final lead = reminder.remindDaysBefore.clamp(0, 14);

    final due = BillReminderDayHelper.nextDueDate(
      dayOfMonth: day,
      hour: hour,
      minute: minute,
      now: now,
    );
    var notifyAt = BillReminderDayHelper.nextNotifyAt(
      due: due,
      leadDays: lead,
      dayOfMonth: day,
      hour: hour,
      minute: minute,
      now: now,
    );

    if (!notifyAt.isAfter(now) && due.isAfter(now)) {
      notifyAt = now.add(const Duration(minutes: 1));
    }

    final isFired = !notifyAt.isAfter(now);
    if (isFired) {
      if (!includeIfFired) return null;
      if (notBefore != null && !notifyAt.isAfter(notBefore)) return null;
    } else if (includeIfFired) {
      return null;
    }

    final daysUntil = BillReminderDayHelper.daysUntilDue(notifyAt, due);
    final amountLabel = reminder.amount != null
        ? money.formatBase(reminder.amount!)
        : null;

    final duePart = daysUntil <= 0
        ? (amountLabel != null
            ? l10n.billReminderNotificationDueTodayWithAmount(amountLabel)
            : l10n.billReminderNotificationDueTodayPlain)
        : (amountLabel != null
            ? l10n.billReminderNotificationDueInDaysWithAmount(
                daysUntil,
                amountLabel,
              )
            : l10n.billReminderNotificationDueInDaysPlain(daysUntil));

    return ScheduledNotificationItem(
      kind: ScheduledNotificationKind.billReminder,
      scheduledAt: notifyAt.toLocal(),
      title: l10n.billReminderNotificationTitle(reminder.title),
      subtitle: l10n.notificationsScheduledBillSubtitle(
        _formatDateTime(notifyAt.toLocal(), locale),
        duePart,
      ),
      description: duePart,
      reminderId: reminder.id,
    );
  }

  tz.TZDateTime _nextDailyDigestFireAt(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var fireAt = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour.clamp(0, 23),
      minute.clamp(0, 59),
    );
    if (!fireAt.isAfter(now)) {
      fireAt = fireAt.add(const Duration(days: 1));
    }
    return fireAt;
  }

  String _formatDateTime(DateTime dateTime, String locale) {
    return LocaleDateFormat.yMMMdAddJm(dateTime, locale);
  }
}
