part of 'incomes_tab_bloc.dart';

enum IncomesTabStatus {
  initial,
  loadingAdd,
  loadingDelete,
  loadingClearAll,
  loadingUpdate,
  loadingAll,
  loaded,
  errorAdd,
  errorDelete,
  errorClearAll,
  errorUpdate,
  errorAll,
  loadingSource,
  errorSource,
}

class IncomesTabState extends Equatable {
  final IncomesTabStatus status;
  final String message;
  final List<IncomeModel> incomes;
  final String? deletingIncomeId;

  const IncomesTabState({
    this.status = IncomesTabStatus.initial,
    this.message = '',
    this.incomes = const [],
    this.deletingIncomeId,
  });

  IncomesTabState copyWith({
    IncomesTabStatus? status,
    String? message,
    List<IncomeModel>? incomes,
    String? deletingIncomeId,
    bool clearDeletingIncomeId = false,
  }) {
    return IncomesTabState(
      status: status ?? this.status,
      message: message ?? this.message,
      incomes: incomes ?? this.incomes,
      deletingIncomeId: clearDeletingIncomeId
          ? null
          : (deletingIncomeId ?? this.deletingIncomeId),
    );
  }

  @override
  List<Object?> get props => [status, message, incomes, deletingIncomeId];
}
