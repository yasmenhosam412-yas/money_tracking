import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imrpo/features/expenses_tab/data/models/expense_model.dart';
import 'package:imrpo/features/expenses_tab/domain/usecases/add_expense_usecase.dart';
import 'package:imrpo/features/expenses_tab/domain/usecases/delete_all_expenses_usecase.dart';
import 'package:imrpo/features/expenses_tab/domain/usecases/delete_expense_usecase.dart';
import 'package:imrpo/features/expenses_tab/domain/usecases/get_all_expenses_usecase.dart';
import 'package:imrpo/features/expenses_tab/domain/usecases/delete_expenses_by_category_usecase.dart';
import 'package:imrpo/features/expenses_tab/domain/usecases/rename_expense_category_usecase.dart';
import 'package:imrpo/features/expenses_tab/domain/usecases/update_expense_usecase.dart';
part 'expenses_tab_event.dart';
part 'expenses_tab_state.dart';

class ExpensesTabBloc extends Bloc<ExpensesTabEvent, ExpensesTabState> {
  final AddExpenseUsecase addExpenseUsecase;
  final UpdateExpenseUsecase updateExpenseUsecase;
  final DeleteExpenseUsecase deleteExpenseUsecase;
  final DeleteAllExpensesUsecase deleteAllExpensesUsecase;
  final GetAllExpensesUsecase getAllExpensesUsecase;
  final RenameExpenseCategoryUsecase renameExpenseCategoryUsecase;
  final DeleteExpensesByCategoryUsecase deleteExpensesByCategoryUsecase;

  ExpensesTabBloc({
    required this.addExpenseUsecase,
    required this.updateExpenseUsecase,
    required this.deleteExpenseUsecase,
    required this.deleteAllExpensesUsecase,
    required this.getAllExpensesUsecase,
    required this.renameExpenseCategoryUsecase,
    required this.deleteExpensesByCategoryUsecase,
  }) : super(const ExpensesTabState()) {
    on<LoadExpensesEvent>(_onLoad);
    on<ResetExpensesTabEvent>(_onReset);
    on<AddExpenseEvent>(_onAdd);
    on<UpdateExpenseEvent>(_onUpdate);
    on<DeleteExpenseEvent>(_onDelete);
    on<ClearAllExpensesEvent>(_onClearAll);
    on<RenameExpenseCategoryEvent>(_onRenameCategory);
    on<DeleteExpensesByCategoryEvent>(_onDeleteByCategory);
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
      incomeSource: event.incomeSource,
    );
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(
        state.copyWith(
          error: result.fold((l) => l.error, (_) => ''),
          status: ExpensesTabStatus.errorAdd,
        ),
      );
      return;
    }
    await _reloadExpensesAfterMutation(
      emit,
      loadFailureStatus: ExpensesTabStatus.errorAdd,
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
      incomeSource: event.incomeSource,
    );
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(
        state.copyWith(
          error: result.fold((l) => l.error, (_) => ''),
          status: ExpensesTabStatus.errorUpdate,
        ),
      );
      return;
    }
    await _reloadExpensesAfterMutation(
      emit,
      loadFailureStatus: ExpensesTabStatus.errorUpdate,
    );
  }

  /// Refreshes the list after add/update so callers get [errorAdd]/[errorUpdate]
  /// if the refresh fails (not [errorAll], which the add sheet does not handle).
  Future<void> _reloadExpensesAfterMutation(
    Emitter<ExpensesTabState> emit, {
    required ExpensesTabStatus loadFailureStatus,
  }) async {
    final reload = await getAllExpensesUsecase();
    if (emit.isDone) return;
    reload.fold(
      (failure) {
        emit(
          state.copyWith(
            error: failure.error,
            status: loadFailureStatus,
          ),
        );
      },
      (expenses) {
        emit(
          state.copyWith(
            status: ExpensesTabStatus.loaded,
            expenses: expenses,
            deletingExpenseId: '',
            error: '',
          ),
        );
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

  Future<void> _onClearAll(
    ClearAllExpensesEvent event,
    Emitter<ExpensesTabState> emit,
  ) async {
    final previousExpenses = state.expenses;
    emit(
      state.copyWith(
        status: ExpensesTabStatus.loadingClearAll,
        expenses: const [],
        deletingExpenseId: '',
      ),
    );

    final result = await deleteAllExpensesUsecase();
    if (emit.isDone) return;

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ExpensesTabStatus.errorClearAll,
            expenses: previousExpenses,
            error: failure.error,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            status: ExpensesTabStatus.loaded,
            expenses: const [],
            deletingExpenseId: '',
            error: '',
          ),
        );
      },
    );
  }

  Future<void> _onRenameCategory(
    RenameExpenseCategoryEvent event,
    Emitter<ExpensesTabState> emit,
  ) async {
    emit(state.copyWith(status: ExpensesTabStatus.loadingCategory, error: ''));
    final result = await renameExpenseCategoryUsecase(
      fromCategory: event.fromCategory,
      toCategory: event.toCategory,
    );
    final failure = result.fold((l) => l, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(
          status: ExpensesTabStatus.errorCategory,
          error: failure.error,
        ),
      );
      return;
    }
    await _reloadAfterCategoryChange(emit);
  }

  Future<void> _onDeleteByCategory(
    DeleteExpensesByCategoryEvent event,
    Emitter<ExpensesTabState> emit,
  ) async {
    emit(state.copyWith(status: ExpensesTabStatus.loadingCategory, error: ''));
    final result = await deleteExpensesByCategoryUsecase(event.category);
    final failure = result.fold((l) => l, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(
          status: ExpensesTabStatus.errorCategory,
          error: failure.error,
        ),
      );
      return;
    }
    await _reloadAfterCategoryChange(emit);
  }

  Future<void> _reloadAfterCategoryChange(
    Emitter<ExpensesTabState> emit,
  ) async {
    final result = await getAllExpensesUsecase();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ExpensesTabStatus.errorCategory,
            error: failure.error,
          ),
        );
      },
      (expenses) {
        emit(
          state.copyWith(
            status: ExpensesTabStatus.loaded,
            expenses: expenses,
            error: '',
          ),
        );
      },
    );
  }
}
