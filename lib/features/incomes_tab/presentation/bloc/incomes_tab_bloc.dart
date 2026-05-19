import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imrpo/features/incomes_tab/data/models/income_model.dart';
import 'package:imrpo/features/incomes_tab/domain/usecases/add_income_usecase.dart';
import 'package:imrpo/features/incomes_tab/domain/usecases/delete_income_usecase.dart';
import 'package:imrpo/features/incomes_tab/domain/usecases/get_all_incomes_usecase.dart';
import 'package:imrpo/features/incomes_tab/domain/usecases/update_income_usecase.dart';

part 'incomes_tab_event.dart';
part 'incomes_tab_state.dart';

class IncomesTabBloc extends Bloc<IncomesTabEvent, IncomesTabState> {
  final AddIncomeUsecase addIncomeUsecase;
  final UpdateIncomeUsecase updateIncomeUsecase;
  final DeleteIncomeUsecase deleteIncomeUsecase;
  final GetAllIncomesUsecase getAllIncomesUsecase;

  IncomesTabBloc({
    required this.addIncomeUsecase,
    required this.updateIncomeUsecase,
    required this.deleteIncomeUsecase,
    required this.getAllIncomesUsecase,
  }) : super(const IncomesTabState()) {
    on<LoadIncomesEvent>(_onLoad);
    on<ResetIncomesTabEvent>(_onReset);
    on<AddIncomeEvent>(_onAdd);
    on<UpdateIncomeEvent>(_onUpdate);
    on<DeleteIncomeEvent>(_onDelete);
  }

  void _onReset(ResetIncomesTabEvent event, Emitter<IncomesTabState> emit) {
    emit(const IncomesTabState());
  }

  Future<void> _onLoad(
    LoadIncomesEvent event,
    Emitter<IncomesTabState> emit,
  ) async {
    if (!event.force && state.status == IncomesTabStatus.loadingAll) return;

    emit(
      state.copyWith(
        status: IncomesTabStatus.loadingAll,
        clearDeletingIncomeId: true,
      ),
    );

    final result = await getAllIncomesUsecase();

    result.fold(
      (l) {
        emit(
          state.copyWith(
            status: IncomesTabStatus.errorAll,
            message: l.error,
          ),
        );
      },
      (r) {
        emit(
          state.copyWith(
            status: IncomesTabStatus.loaded,
            incomes: r,
            clearDeletingIncomeId: true,
          ),
        );
      },
    );
  }

  Future<void> _onAdd(
    AddIncomeEvent event,
    Emitter<IncomesTabState> emit,
  ) async {
    emit(state.copyWith(status: IncomesTabStatus.loadingAdd));

    final result = await addIncomeUsecase(
      event.title,
      event.amount,
      event.date,
      event.category,
    );

    result.fold(
      (l) {
        emit(
          state.copyWith(
            status: IncomesTabStatus.errorAdd,
            message: l.error,
          ),
        );
      },
      (_) {
        emit(state.copyWith(status: IncomesTabStatus.loaded));
        add(const LoadIncomesEvent());
      },
    );
  }

  Future<void> _onUpdate(
    UpdateIncomeEvent event,
    Emitter<IncomesTabState> emit,
  ) async {
    emit(state.copyWith(status: IncomesTabStatus.loadingUpdate));

    final result = await updateIncomeUsecase(
      event.id,
      event.title,
      event.amount,
      event.date,
      event.category,
    );

    result.fold(
      (l) {
        emit(
          state.copyWith(
            status: IncomesTabStatus.errorUpdate,
            message: l.error,
          ),
        );
      },
      (_) {
        emit(state.copyWith(status: IncomesTabStatus.loaded));
        add(const LoadIncomesEvent());
      },
    );
  }

  Future<void> _onDelete(
    DeleteIncomeEvent event,
    Emitter<IncomesTabState> emit,
  ) async {
    emit(
      state.copyWith(
        status: IncomesTabStatus.loadingDelete,
        deletingIncomeId: event.id,
      ),
    );

    final result = await deleteIncomeUsecase(event.id);
    if (emit.isDone) return;

    if (result.isLeft()) {
      final failure = result.fold((l) => l, (_) => throw StateError('unreachable'));
      emit(
        state.copyWith(
          status: IncomesTabStatus.errorDelete,
          message: failure.error,
          clearDeletingIncomeId: true,
        ),
      );
      return;
    }

    final updatedIncomes =
        state.incomes.where((income) => income.id != event.id).toList();

    emit(
      state.copyWith(
        status: IncomesTabStatus.loaded,
        incomes: updatedIncomes,
        clearDeletingIncomeId: true,
        message: '',
      ),
    );

    add(const LoadIncomesEvent(force: true));
  }
}