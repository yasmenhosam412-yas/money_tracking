part of 'bill_reminders_bloc.dart';

sealed class BillRemindersState extends Equatable {
  const BillRemindersState();

  @override
  List<Object?> get props => [];
}

class BillRemindersInitial extends BillRemindersState {
  const BillRemindersInitial();
}

class BillRemindersLoading extends BillRemindersState {
  const BillRemindersLoading();
}

class BillRemindersLoaded extends BillRemindersState {
  final List<BillReminder> reminders;
  final bool isSaving;
  final String? error;

  const BillRemindersLoaded({
    required this.reminders,
    this.isSaving = false,
    this.error,
  });

  BillRemindersLoaded copyWith({
    List<BillReminder>? reminders,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return BillRemindersLoaded(
      reminders: reminders ?? this.reminders,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [reminders, isSaving, error];
}

class BillRemindersError extends BillRemindersState {
  final String message;

  const BillRemindersError(this.message);

  @override
  List<Object?> get props => [message];
}
