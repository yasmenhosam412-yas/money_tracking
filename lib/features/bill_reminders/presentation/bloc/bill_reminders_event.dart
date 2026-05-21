part of 'bill_reminders_bloc.dart';

sealed class BillRemindersEvent extends Equatable {
  const BillRemindersEvent();

  @override
  List<Object?> get props => [];
}

class LoadBillRemindersEvent extends BillRemindersEvent {
  const LoadBillRemindersEvent();
}

class SaveBillReminderEvent extends BillRemindersEvent {
  final BillReminder reminder;

  const SaveBillReminderEvent({required this.reminder});

  @override
  List<Object?> get props => [reminder];
}

class DeleteBillReminderEvent extends BillRemindersEvent {
  final String id;

  const DeleteBillReminderEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class ToggleBillReminderEvent extends BillRemindersEvent {
  final String id;
  final bool enabled;

  const ToggleBillReminderEvent({required this.id, required this.enabled});

  @override
  List<Object?> get props => [id, enabled];
}

class ResetBillRemindersEvent extends BillRemindersEvent {
  const ResetBillRemindersEvent();
}
