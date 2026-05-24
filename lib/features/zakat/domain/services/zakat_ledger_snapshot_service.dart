import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/features/balance_tab/domain/usecases/get_balance_usecase.dart';
import 'package:imrpo/features/plans_tab/domain/usecases/get_all_plans_usecase.dart';

/// Suggests cash and savings amounts from the current ledger.
class ZakatLedgerSnapshotService {
  Future<({double cash, double savings})> load() async {
    var cash = 0.0;
    var savings = 0.0;

    final balanceResult = await getIt<GetBalanceUsecase>()(
      reference: DateTime.now(),
      includeAllDates: true,
    );
    balanceResult.fold((_) {}, (summary) {
      final net = summary.monthlyIncome - summary.monthlyExpenses;
      if (net > 0) cash = net;
    });

    final plansResult = await getIt<GetAllPlansUsecase>()();
    plansResult.fold((_) {}, (plans) {
      for (final plan in plans) {
        savings += plan.savedAmount;
      }
    });

    return (cash: cash, savings: savings);
  }
}
