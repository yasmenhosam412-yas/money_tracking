import 'package:equatable/equatable.dart';

class ZakatResult extends Equatable {
  final double totalAssets;
  final double netWealth;
  final double nisabThreshold;
  final bool meetsNisab;
  final double zakatDue;
  final double goldValue;
  final double silverValue;

  const ZakatResult({
    required this.totalAssets,
    required this.netWealth,
    required this.nisabThreshold,
    required this.meetsNisab,
    required this.zakatDue,
    this.goldValue = 0,
    this.silverValue = 0,
  });

  static const zakatRate = 0.025;
  static const goldNisabGrams = 85.0;
  static const silverNisabGrams = 595.0;

  @override
  List<Object> get props => [
        totalAssets,
        netWealth,
        nisabThreshold,
        meetsNisab,
        zakatDue,
        goldValue,
        silverValue,
      ];
}
