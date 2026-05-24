import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/features/balance_tab/domain/entities/balance_activity.dart';
import 'package:imrpo/features/balance_tab/domain/usecases/get_balance_usecase.dart';

class DailyDigestSummary {
  final int expenseCount;
  final int incomeCount;
  final double expenseTotal;
  final double incomeTotal;
  final double monthNet;

  const DailyDigestSummary({
    required this.expenseCount,
    required this.incomeCount,
    required this.expenseTotal,
    required this.incomeTotal,
    required this.monthNet,
  });

  bool get hasYesterdayActivity => expenseCount > 0 || incomeCount > 0;
}

/// Builds spending recap for the calendar day before [fireAt].
class DailyDigestSummaryService {
  Future<DailyDigestSummary?> buildForNotificationFireAt(DateTime fireAt) async {
    final summaryDay = DateTime(
      fireAt.year,
      fireAt.month,
      fireAt.day,
    ).subtract(const Duration(days: 1));

    final usecase = getIt<GetBalanceUsecase>();

    final dayResult = await usecase(
      reference: summaryDay,
      filterByDay: true,
    );
    final monthResult = await usecase(reference: fireAt, filterByDay: false);

    return dayResult.fold(
      (_) => null,
      (daySummary) => monthResult.fold(
        (_) => null,
        (monthSummary) {
          var expenseCount = 0;
          var incomeCount = 0;
          for (final activity in daySummary.activities) {
            if (activity.type == BalanceActivityType.expense) {
              expenseCount++;
            } else {
              incomeCount++;
            }
          }
          return DailyDigestSummary(
            expenseCount: expenseCount,
            incomeCount: incomeCount,
            expenseTotal: daySummary.monthlyExpenses,
            incomeTotal: daySummary.monthlyIncome,
            monthNet:
                monthSummary.monthlyIncome - monthSummary.monthlyExpenses,
          );
        },
      ),
    );
  }
}
