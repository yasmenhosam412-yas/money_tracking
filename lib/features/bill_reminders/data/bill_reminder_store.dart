import 'dart:convert';

import 'package:imrpo/features/bill_reminders/domain/bill_reminder_day_helper.dart';
import 'package:imrpo/features/bill_reminders/domain/entities/bill_reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local storage for bill reminders (per signed-in user key).
class BillReminderStore {
  static const _keyPrefix = 'bill_reminders_v1_';

  Future<List<BillReminder>> loadAll(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_keyPrefix$userId');
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => _fromMap(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => a.dayOfMonth.compareTo(b.dayOfMonth));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(String userId, List<BillReminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(reminders.map(_toMap).toList());
    await prefs.setString('$_keyPrefix$userId', encoded);
  }

  Future<void> clear(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$userId');
  }

  Map<String, dynamic> _toMap(BillReminder r) => {
        'id': r.id,
        'title': r.title,
        'amount': r.amount,
        'day_of_month': r.dayOfMonth,
        'remind_days_before': r.remindDaysBefore,
        'reminder_hour': r.reminderHour,
        'reminder_minute': r.reminderMinute,
        'is_enabled': r.isEnabled,
      };

  BillReminder _fromMap(Map<String, dynamic> map) {
    return BillReminder(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble(),
      dayOfMonth: BillReminderDayHelper.clampStoredDay(
        (map['day_of_month'] as num?)?.toInt() ?? 1,
      ),
      remindDaysBefore: (map['remind_days_before'] as num?)?.toInt() ?? 1,
      reminderHour: (map['reminder_hour'] as num?)?.toInt().clamp(0, 23) ??
          BillReminder.defaultReminderHour,
      reminderMinute: (map['reminder_minute'] as num?)?.toInt().clamp(0, 59) ??
          BillReminder.defaultReminderMinute,
      isEnabled: map['is_enabled'] != false,
    );
  }
}
