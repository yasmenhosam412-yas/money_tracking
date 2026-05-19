import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imrpo/features/budgets/domain/entities/budget.dart';
import 'package:imrpo/features/budgets/domain/usecases/delete_budget_usecase.dart';
import 'package:imrpo/features/budgets/domain/usecases/get_budgets_usecase.dart';
import 'package:imrpo/features/budgets/domain/usecases/upsert_budget_usecase.dart';

part 'budgets_event.dart';
part 'budgets_state.dart';

class BudgetsBloc extends Bloc<BudgetsEvent, BudgetsState> {
  final GetBudgetsUsecase getBudgetsUsecase;
  final UpsertBudgetUsecase upsertBudgetUsecase;
  final DeleteBudgetUsecase deleteBudgetUsecase;

  BudgetsBloc({
    required this.getBudgetsUsecase,
    required this.upsertBudgetUsecase,
    required this.deleteBudgetUsecase,
  }) : super(const BudgetsState()) {
    on<ResetBudgetsEvent>(_onReset);
    on<LoadBudgetsEvent>(_onLoad);
    on<UpsertBudgetEvent>(_onUpsert);
    on<DeleteBudgetEvent>(_onDelete);
  }

  void _onReset(ResetBudgetsEvent event, Emitter<BudgetsState> emit) {
    emit(const BudgetsState());
  }

  Future<void> _onLoad(
    LoadBudgetsEvent event,
    Emitter<BudgetsState> emit,
  ) async {
    if (!event.force &&
        state.status == BudgetsStatus.loading &&
        state.year == event.year &&
        state.month == event.month) {
      return;
    }

    emit(
      state.copyWith(
        status: BudgetsStatus.loading,
        year: event.year,
        month: event.month,
        clearError: true,
      ),
    );

    final result = await getBudgetsUsecase(year: event.year, month: event.month);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: BudgetsStatus.error,
            error: failure.error,
            year: event.year,
            month: event.month,
          ),
        );
      },
      (budgets) {
        emit(
          state.copyWith(
            status: BudgetsStatus.loaded,
            budgets: budgets,
            year: event.year,
            month: event.month,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _onUpsert(
    UpsertBudgetEvent event,
    Emitter<BudgetsState> emit,
  ) async {
    emit(state.copyWith(status: BudgetsStatus.saving, clearError: true));

    final result = await upsertBudgetUsecase(
      category: event.category,
      amount: event.amount,
      year: event.year,
      month: event.month,
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: BudgetsStatus.error,
            error: failure.error,
          ),
        );
      },
      (_) async {
        await _reloadBudgets(emit, year: event.year, month: event.month);
      },
    );
  }

  Future<void> _onDelete(
    DeleteBudgetEvent event,
    Emitter<BudgetsState> emit,
  ) async {
    if (state.year == null || state.month == null) return;

    emit(state.copyWith(status: BudgetsStatus.saving, clearError: true));

    final result = await deleteBudgetUsecase(event.budgetId);

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: BudgetsStatus.error,
            error: failure.error,
          ),
        );
      },
      (_) async {
        await _reloadBudgets(
          emit,
          year: state.year!,
          month: state.month!,
        );
      },
    );
  }

  Future<void> _reloadBudgets(
    Emitter<BudgetsState> emit, {
    required int year,
    required int month,
  }) async {
    final result = await getBudgetsUsecase(year: year, month: month);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: BudgetsStatus.error,
            error: failure.error,
            year: year,
            month: month,
          ),
        );
      },
      (budgets) {
        emit(
          state.copyWith(
            status: BudgetsStatus.loaded,
            budgets: budgets,
            year: year,
            month: month,
            clearError: true,
          ),
        );
      },
    );
  }
}
