import 'package:equatable/equatable.dart';

class BillReminder extends Equatable {
  static const defaultReminderHour = 9;
  static const defaultReminderMinute = 0;

  final String id;
  final String title;
  final double? amount;
  final int dayOfMonth;
  final int remindDaysBefore;
  final int reminderHour;
  final int reminderMinute;
  final bool isEnabled;

  const BillReminder({
    required this.id,
    required this.title,
    this.amount,
    required this.dayOfMonth,
    required this.remindDaysBefore,
    this.reminderHour = defaultReminderHour,
    this.reminderMinute = defaultReminderMinute,
    this.isEnabled = true,
  });

  BillReminder copyWith({
    String? id,
    String? title,
    double? amount,
    bool clearAmount = false,
    int? dayOfMonth,
    int? remindDaysBefore,
    int? reminderHour,
    int? reminderMinute,
    bool? isEnabled,
  }) {
    return BillReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: clearAmount ? null : (amount ?? this.amount),
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      remindDaysBefore: remindDaysBefore ?? this.remindDaysBefore,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        dayOfMonth,
        remindDaysBefore,
        reminderHour,
        reminderMinute,
        isEnabled,
      ];
}
