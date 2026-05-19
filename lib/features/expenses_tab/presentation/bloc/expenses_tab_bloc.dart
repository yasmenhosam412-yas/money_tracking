import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imrpo/features/expenses_tab/data/models/expense_model.dart';
import 'package:imrpo/features/expenses_tab/domain/usecases/add_expense_usecase.dart';
import 'package:imrpo/features/expenses_tab/domain/usecases/delete_expense_usecase.dart';
import 'package:imrpo/features/expenses_tab/domain/usecases/get_all_expenses_usecase.dart';
import 'package:imrpo/features/expenses_tab/domain/usecases/update_expense_usecase.dart';
part 'expenses_tab_event.dart';
part 'expenses_tab_state.dart';

class ExpensesTabBloc extends Bloc<ExpensesTabEvent, ExpensesTabState> {
  final AddExpenseUsecase addExpenseUsecase;
  final UpdateExpenseUsecase updateExpenseUsecase;
  final DeleteExpenseUsecase deleteExpenseUsecase;
  final GetAllExpensesUsecase getAllExpensesUsecase;
  ExpensesTabBloc({
    required this.addExpenseUsecase,
    required this.updateExpenseUsecase,
    required this.deleteExpenseUsecase,
    required this.getAllExpensesUsecase,
  }) : super(const ExpensesTabState()) {
    on<LoadExpensesEvent>(_onLoad);
    on<ResetExpensesTabEvent>(_onReset);
    on<AddExpenseEvent>(_onAdd);
    on<UpdateExpenseEvent>(_onUpdate);
    on<DeleteExpenseEvent>(_onDelete);
  }

  void _onReset(ResetExpensesTabEvent event, Emitter<ExpensesTabState> emit) {
    emit(const ExpensesTabState());
  }

  Future<void> _onLoad(
    LoadExpensesEvent event,
    Emitter<ExpensesTabState> emit,
  ) async {
    if (!event.force && state.status == ExpensesTabStatus.loadingAll) return;

    emit(
      state.copyWith(
        status: ExpensesTabStatus.loadingAll,
        deletingExpenseId: '',
      ),
    );
    final result = await getAllExpensesUsecase();
    result.fold(
      (l) {
        emit(
          state.copyWith(error: l.error, status: ExpensesTabStatus.errorAll),
        );
      },
      (r) {
        emit(
          state.copyWith(
            status: ExpensesTabStatus.loaded,
            expenses: r,
            deletingExpenseId: "",
          ),
        );
      },
    );
  }

  Future<void> _onAdd(
    AddExpenseEvent event,
    Emitter<ExpensesTabState> emit,
  ) async {
    emit(state.copyWith(status: ExpensesTabStatus.loadingAdd));
    final result = await addExpenseUsecase(
      event.title,
      event.category,
      event.amount,
      event.date,
    );
    result.fold(
      (l) {
        emit(
          state.copyWith(error: l.error, status: ExpensesTabStatus.errorAdd),
        );
      },
      (r) {
        add(LoadExpensesEvent());
      },
    );
  }

  Future<void> _onUpdate(
    UpdateExpenseEvent event,
    Emitter<ExpensesTabState> emit,
  ) async {
    emit(state.copyWith(status: ExpensesTabStatus.loadingUpdate));
    final result = await updateExpenseUsecase(
      event.id,
      event.title,
      event.category,
      event.amount,
      event.date,
    );
    result.fold(
      (l) {
        emit(
          state.copyWith(error: l.error, status: ExpensesTabStatus.errorUpdate),
        );
      },
      (r) {
        add(LoadExpensesEvent());
      },
    );
  }

  Future<void> _onDelete(
    DeleteExpenseEvent event,
    Emitter<ExpensesTabState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ExpensesTabStatus.loadingDelete,
        deletingExpenseId: event.id,
      ),
    );

    final result = await deleteExpenseUsecase(event.id);
    if (emit.isDone) return;

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (_) => throw StateError('unreachable'));
      emit(
        state.copyWith(
          error: failure.error,
          status: ExpensesTabStatus.errorDelete,
          deletingExpenseId: '',
        ),
      );
      return;
    }

    final updatedExpenses =
        state.expenses.where((expense) => expense.id != event.id).toList();

    emit(
      state.copyWith(
        status: ExpensesTabStatus.loaded,
        expenses: updatedExpenses,
        deletingExpenseId: '',
        error: '',
      ),
    );

    add(const LoadExpensesEvent(force: true));
  }
}
