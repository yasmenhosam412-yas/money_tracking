import 'package:flutter_test/flutter_test.dart';
import 'package:imrpo/features/bill_reminders/domain/bill_reminder_day_helper.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
  });

  tz.TZDateTime cairo(int y, int m, int d, int h, int min) =>
      tz.TZDateTime(tz.local, y, m, d, h, min);

  test('nextDueDate picks later today when time not passed', () {
    final now = cairo(2026, 5, 21, 10, 0);
    final due = BillReminderDayHelper.nextDueDate(
      dayOfMonth: 21,
      hour: 14,
      minute: 5,
      now: now,
    );
    expect(due, cairo(2026, 5, 21, 14, 5));
  });

  test('nextNotifyAt keeps same cycle when notify just passed', () {
    final now = cairo(2026, 5, 21, 14, 3);
    final due = cairo(2026, 5, 22, 14, 0);
    final notify = BillReminderDayHelper.nextNotifyAt(
      due: due,
      leadDays: 1,
      dayOfMonth: 22,
      hour: 14,
      minute: 0,
      now: now,
    );
    expect(notify, cairo(2026, 5, 21, 14, 0));
    expect(notify.isAfter(now), isFalse);
    expect(due.isAfter(now), isTrue);
  });

  test('daysUntilDue for remind 1 day before', () {
    final notify = cairo(2026, 5, 21, 14, 0);
    final due = cairo(2026, 5, 22, 14, 0);
    expect(BillReminderDayHelper.daysUntilDue(notify, due), 1);
  });
}
