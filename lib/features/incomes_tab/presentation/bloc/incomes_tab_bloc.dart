import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imrpo/features/incomes_tab/data/models/income_model.dart';
import 'package:imrpo/features/incomes_tab/domain/usecases/add_income_usecase.dart';
import 'package:imrpo/features/incomes_tab/domain/usecases/delete_all_incomes_usecase.dart';
import 'package:imrpo/features/incomes_tab/domain/usecases/delete_income_usecase.dart';
import 'package:imrpo/features/incomes_tab/domain/usecases/delete_incomes_by_source_usecase.dart';
import 'package:imrpo/features/incomes_tab/domain/usecases/get_all_incomes_usecase.dart';
import 'package:imrpo/features/incomes_tab/domain/usecases/rename_income_source_usecase.dart';
import 'package:imrpo/features/incomes_tab/domain/usecases/update_income_usecase.dart';

part 'incomes_tab_event.dart';
part 'incomes_tab_state.dart';

class IncomesTabBloc extends Bloc<IncomesTabEvent, IncomesTabState> {
  final AddIncomeUsecase addIncomeUsecase;
  final UpdateIncomeUsecase updateIncomeUsecase;
  final DeleteIncomeUsecase deleteIncomeUsecase;
  final DeleteAllIncomesUsecase deleteAllIncomesUsecase;
  final GetAllIncomesUsecase getAllIncomesUsecase;
  final RenameIncomeSourceUsecase renameIncomeSourceUsecase;
  final DeleteIncomesBySourceUsecase deleteIncomesBySourceUsecase;

  IncomesTabBloc({
    required this.addIncomeUsecase,
    required this.updateIncomeUsecase,
    required this.deleteIncomeUsecase,
    required this.deleteAllIncomesUsecase,
    required this.getAllIncomesUsecase,
    required this.renameIncomeSourceUsecase,
    required this.deleteIncomesBySourceUsecase,
  }) : super(const IncomesTabState()) {
    on<LoadIncomesEvent>(_onLoad);
    on<ResetIncomesTabEvent>(_onReset);
    on<AddIncomeEvent>(_onAdd);
    on<UpdateIncomeEvent>(_onUpdate);
    on<DeleteIncomeEvent>(_onDelete);
    on<ClearAllIncomesEvent>(_onClearAll);
    on<RenameIncomeSourceEvent>(_onRenameSource);
    on<DeleteIncomesBySourceEvent>(_onDeleteBySource);
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
            message: '',
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
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(
        state.copyWith(
          message: result.fold((l) => l.error, (_) => ''),
          status: IncomesTabStatus.errorAdd,
        ),
      );
      return;
    }
    await _reloadIncomesAfterMutation(
      emit,
      loadFailureStatus: IncomesTabStatus.errorAdd,
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
    if (emit.isDone) return;
    if (result.isLeft()) {
      emit(
        state.copyWith(
          message: result.fold((l) => l.error, (_) => ''),
          status: IncomesTabStatus.errorUpdate,
        ),
      );
      return;
    }
    await _reloadIncomesAfterMutation(
      emit,
      loadFailureStatus: IncomesTabStatus.errorUpdate,
    );
  }

  Future<void> _reloadIncomesAfterMutation(
    Emitter<IncomesTabState> emit, {
    required IncomesTabStatus loadFailureStatus,
  }) async {
    final reload = await getAllIncomesUsecase();
    if (emit.isDone) return;
    reload.fold(
      (failure) {
        emit(
          state.copyWith(
            message: failure.error,
            status: loadFailureStatus,
          ),
        );
      },
      (incomes) {
        emit(
          state.copyWith(
            status: IncomesTabStatus.loaded,
            incomes: incomes,
            clearDeletingIncomeId: true,
            message: '',
          ),
        );
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

  Future<void> _onClearAll(
    ClearAllIncomesEvent event,
    Emitter<IncomesTabState> emit,
  ) async {
    final previousIncomes = state.incomes;
    emit(
      state.copyWith(
        status: IncomesTabStatus.loadingClearAll,
        incomes: const [],
        clearDeletingIncomeId: true,
      ),
    );

    final result = await deleteAllIncomesUsecase();
    if (emit.isDone) return;

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: IncomesTabStatus.errorClearAll,
            incomes: previousIncomes,
            message: failure.error,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            status: IncomesTabStatus.loaded,
            incomes: const [],
            clearDeletingIncomeId: true,
            message: '',
          ),
        );
      },
    );
  }

  Future<void> _onRenameSource(
    RenameIncomeSourceEvent event,
    Emitter<IncomesTabState> emit,
  ) async {
    emit(state.copyWith(status: IncomesTabStatus.loadingSource, message: ''));
    final result = await renameIncomeSourceUsecase(
      fromSource: event.fromSource,
      toSource: event.toSource,
    );
    final failure = result.fold((l) => l, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(
          status: IncomesTabStatus.errorSource,
          message: failure.error,
        ),
      );
      return;
    }
    await _reloadAfterSourceChange(emit);
  }

  Future<void> _onDeleteBySource(
    DeleteIncomesBySourceEvent event,
    Emitter<IncomesTabState> emit,
  ) async {
    emit(state.copyWith(status: IncomesTabStatus.loadingSource, message: ''));
    final result = await deleteIncomesBySourceUsecase(event.source);
    final failure = result.fold((l) => l, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(
          status: IncomesTabStatus.errorSource,
          message: failure.error,
        ),
      );
      return;
    }
    await _reloadAfterSourceChange(emit);
  }

  Future<void> _reloadAfterSourceChange(Emitter<IncomesTabState> emit) async {
    final result = await getAllIncomesUsecase();
    if (emit.isDone) return;
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: IncomesTabStatus.errorSource,
            message: failure.error,
          ),
        );
      },
      (incomes) {
        emit(
          state.copyWith(
            status: IncomesTabStatus.loaded,
            incomes: incomes,
            clearDeletingIncomeId: true,
            message: '',
          ),
        );
      },
    );
  }
}
