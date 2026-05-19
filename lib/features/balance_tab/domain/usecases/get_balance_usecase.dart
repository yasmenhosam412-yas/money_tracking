import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/balance_tab/domain/entities/balance_summary.dart';
import 'package:imrpo/features/balance_tab/domain/repositories/balance_repository.dart';

class GetBalanceUsecase {
  final BalanceRepository balanceRepository;

  GetBalanceUsecase({required this.balanceRepository});

  Future<Either<Failure, BalanceSummary>> call({
    required DateTime reference,
    bool filterByDay = false,
    bool includeAllDates = false,
  }) {
    return balanceRepository.getBalance(
      reference: reference,
      filterByDay: filterByDay,
      includeAllDates: includeAllDates,
    );
  }
}
