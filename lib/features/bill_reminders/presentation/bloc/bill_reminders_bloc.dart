import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imrpo/features/bill_reminders/domain/entities/bill_reminder.dart';
import 'package:imrpo/features/bill_reminders/domain/repositories/bill_reminder_repository.dart';

part 'bill_reminders_event.dart';
part 'bill_reminders_state.dart';

class BillRemindersBloc extends Bloc<BillRemindersEvent, BillRemindersState> {
  final BillReminderRepository repository;

  BillRemindersBloc({required this.repository}) : super(const BillRemindersInitial()) {
    on<LoadBillRemindersEvent>(_onLoad);
    on<SaveBillReminderEvent>(_onSave);
    on<DeleteBillReminderEvent>(_onDelete);
    on<ToggleBillReminderEvent>(_onToggle);
    on<ResetBillRemindersEvent>(_onReset);
  }

  void _onReset(ResetBillRemindersEvent event, Emitter<BillRemindersState> emit) {
    emit(const BillRemindersInitial());
  }

  Future<void> _onLoad(
    LoadBillRemindersEvent event,
    Emitter<BillRemindersState> emit,
  ) async {
    emit(const BillRemindersLoading());
    final result = await repository.getAll();
    result.fold(
      (failure) => emit(BillRemindersError(failure.error)),
      (reminders) => emit(BillRemindersLoaded(reminders: reminders)),
    );
  }

  Future<void> _onSave(
    SaveBillReminderEvent event,
    Emitter<BillRemindersState> emit,
  ) async {
    final current = state;
    if (current is BillRemindersLoaded) {
      emit(current.copyWith(isSaving: true));
    }

    final result = await repository.save(event.reminder);
    result.fold(
      (failure) {
        if (current is BillRemindersLoaded) {
          emit(current.copyWith(isSaving: false, error: failure.error));
        } else {
          emit(BillRemindersError(failure.error));
        }
      },
      (_) => add(const LoadBillRemindersEvent()),
    );
  }

  Future<void> _onDelete(
    DeleteBillReminderEvent event,
    Emitter<BillRemindersState> emit,
  ) async {
    final result = await repository.delete(event.id);
    result.fold(
      (failure) => emit(BillRemindersError(failure.error)),
      (_) => add(const LoadBillRemindersEvent()),
    );
  }

  Future<void> _onToggle(
    ToggleBillReminderEvent event,
    Emitter<BillRemindersState> emit,
  ) async {
    final current = state;
    if (current is! BillRemindersLoaded) return;

    BillReminder? target;
    for (final r in current.reminders) {
      if (r.id == event.id) {
        target = r;
        break;
      }
    }
    if (target == null) return;

    add(SaveBillReminderEvent(
      reminder: target.copyWith(isEnabled: event.enabled),
    ));
  }
}
