import 'package:flutter_test/flutter_test.dart';
import 'package:imrpo/features/zakat/domain/entities/zakat_input.dart';
import 'package:imrpo/features/zakat/domain/services/zakat_calculator.dart';

void main() {
  final calculator = ZakatCalculator();

  test('returns zero zakat when below nisab', () {
    final result = calculator.calculate(
      const ZakatInput(
        cash: 10000,
        goldPricePerGram: 4000,
      ),
    );
    expect(result.meetsNisab, isFalse);
    expect(result.zakatDue, 0);
  });

  test('calculates 2.5% when at or above nisab', () {
    final result = calculator.calculate(
      const ZakatInput(
        cash: 500000,
        goldPricePerGram: 4000,
      ),
    );
    expect(result.nisabThreshold, 340000);
    expect(result.meetsNisab, isTrue);
    expect(result.zakatDue, 12500);
  });

  test('subtracts debts from zakatable wealth', () {
    final result = calculator.calculate(
      const ZakatInput(
        cash: 600000,
        debts: 200000,
        goldPricePerGram: 4000,
      ),
    );
    expect(result.netWealth, 400000);
    expect(result.zakatDue, 10000);
  });

  test('values gold and silver from grams times price', () {
    final result = calculator.calculate(
      const ZakatInput(
        goldGrams: 10,
        silverGrams: 100,
        goldPricePerGram: 4000,
        silverPricePerGram: 50,
      ),
    );
    expect(result.goldValue, 40000);
    expect(result.silverValue, 5000);
    expect(result.totalAssets, 45000);
  });
}
