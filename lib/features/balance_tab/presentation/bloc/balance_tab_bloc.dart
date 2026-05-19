import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imrpo/features/balance_tab/domain/entities/balance_activity.dart';
import 'package:imrpo/features/balance_tab/domain/usecases/get_balance_usecase.dart';

part 'balance_tab_event.dart';
part 'balance_tab_state.dart';

class BalanceTabBloc extends Bloc<BalanceTabEvent, BalanceTabState> {
  final GetBalanceUsecase getBalanceUsecase;

  BalanceTabBloc({required this.getBalanceUsecase})
      : super(const BalanceTabInitial()) {
    on<LoadBalanceEvent>(_onLoad);
    on<ResetBalanceTabEvent>(_onReset);
  }

  void _onReset(ResetBalanceTabEvent event, Emitter<BalanceTabState> emit) {
    emit(const BalanceTabInitial());
  }

  Future<void> _onLoad(
    LoadBalanceEvent event,
    Emitter<BalanceTabState> emit,
  ) async {
    final current = state;
    if (current is BalanceTabLoaded &&
        current.status == BalanceTabStatus.loading &&
        !current.hasData) {
      return;
    }
    if (current is BalanceTabLoaded && current.hasData) {
      emit(current.copyWith(status: BalanceTabStatus.loading, error: ''));
    } else {
      emit(
        const BalanceTabLoaded(
          monthlyIncome: 0,
          monthlyExpenses: 0,
          activities: [],
          status: BalanceTabStatus.loading,
        ),
      );
    }

    final result = await getBalanceUsecase(
      reference: event.reference,
      filterByDay: event.filterByDay,
    );

    result.fold(
      (failure) {
        final previous = state;
        if (previous is BalanceTabLoaded && previous.hasData) {
          emit(
            previous.copyWith(
              status: BalanceTabStatus.error,
              error: failure.error,
            ),
          );
        } else {
          emit(
            BalanceTabLoaded(
              monthlyIncome: 0,
              monthlyExpenses: 0,
              activities: const [],
              status: BalanceTabStatus.error,
              error: failure.error,
            ),
          );
        }
      },
      (summary) {
        emit(
          BalanceTabLoaded(
            monthlyIncome: summary.monthlyIncome,
            monthlyExpenses: summary.monthlyExpenses,
            activities: summary.activities,
            status: BalanceTabStatus.loaded,
          ),
        );
      },
    );
  }
}
