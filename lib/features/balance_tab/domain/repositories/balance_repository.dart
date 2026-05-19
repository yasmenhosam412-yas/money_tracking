import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/balance_tab/domain/entities/balance_summary.dart';

abstract class BalanceRepository {
  Future<Either<Failure, BalanceSummary>> getBalance({
    required DateTime reference,
    bool filterByDay = false,
  });
}
