import 'package:timezone/timezone.dart' as tz;

/// Day-of-month helpers for recurring bill reminders.
class BillReminderDayHelper {
  BillReminderDayHelper._();

  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  /// [desiredDay] may be 1–31; uses the last day when the month is shorter.
  static int effectiveDay(int year, int month, int desiredDay) {
    final last = daysInMonth(year, month);
    return desiredDay.clamp(1, last);
  }

  static int clampStoredDay(int day) => day.clamp(1, 31);

  /// Next bill due date (day-of-month + time) strictly after [now].
  static tz.TZDateTime nextDueDate({
    required int dayOfMonth,
    required int hour,
    required int minute,
    required tz.TZDateTime now,
  }) {
    var year = now.year;
    var month = now.month;
    var day = effectiveDay(year, month, dayOfMonth);
    var due = tz.TZDateTime(tz.local, year, month, day, hour, minute);

    for (var i = 0; i < 24 && !due.isAfter(now); i++) {
      if (month == 12) {
        year += 1;
        month = 1;
      } else {
        month += 1;
      }
      day = effectiveDay(year, month, dayOfMonth);
      due = tz.TZDateTime(tz.local, year, month, day, hour, minute);
    }
    return due;
  }

  /// Next reminder fire time: [leadDays] before [due], in the future.
  static tz.TZDateTime nextNotifyAt({
    required tz.TZDateTime due,
    required int leadDays,
    required int dayOfMonth,
    required int hour,
    required int minute,
    required tz.TZDateTime now,
  }) {
    final lead = leadDays.clamp(0, 14);
    var currentDue = due;
    var notify = currentDue.subtract(Duration(days: lead));

    for (var i = 0; i < 24 && !notify.isAfter(now); i++) {
      // Due still ahead — keep this cycle; caller may catch up (e.g. missed by minutes).
      if (currentDue.isAfter(now)) return notify;

      var year = currentDue.year;
      var month = currentDue.month;
      if (month == 12) {
        year += 1;
        month = 1;
      } else {
        month += 1;
      }
      final day = effectiveDay(year, month, dayOfMonth);
      currentDue = tz.TZDateTime(tz.local, year, month, day, hour, minute);
      notify = currentDue.subtract(Duration(days: lead));
    }
    return notify;
  }

  static int daysUntilDue(tz.TZDateTime notifyAt, tz.TZDateTime due) {
    final notifyDate = DateTime(notifyAt.year, notifyAt.month, notifyAt.day);
    final dueDate = DateTime(due.year, due.month, due.day);
    return dueDate.difference(notifyDate).inDays;
  }
}
