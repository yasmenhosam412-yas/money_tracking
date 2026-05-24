import 'package:imrpo/features/zakat/domain/entities/zakat_input.dart';
import 'package:imrpo/features/zakat/domain/entities/zakat_result.dart';

class ZakatCalculator {
  ZakatResult calculate(ZakatInput input) {
    final goldValue = input.goldValue;
    final silverValue = input.silverValue;

    final totalAssets = input.cash +
        goldValue +
        silverValue +
        input.investments +
        input.businessGoods +
        input.receivables;

    final netWealth =
        (totalAssets - input.debts).clamp(0.0, double.infinity).toDouble();

    final nisab = input.goldPricePerGram > 0
        ? input.goldPricePerGram * ZakatResult.goldNisabGrams
        : 0.0;

    final meetsNisab = nisab > 0 && netWealth >= nisab;
    final zakatDue = meetsNisab ? netWealth * ZakatResult.zakatRate : 0.0;

    return ZakatResult(
      totalAssets: totalAssets,
      netWealth: netWealth,
      nisabThreshold: nisab,
      meetsNisab: meetsNisab,
      zakatDue: zakatDue,
      goldValue: goldValue,
      silverValue: silverValue,
    );
  }
}
