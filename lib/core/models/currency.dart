import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  final String code;
  final String name;
  final String symbol;
  /// How many USD equal 1 unit of this currency.
  final double rateToUsd;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.rateToUsd,
  });

  @override
  List<Object> get props => [code, name, symbol, rateToUsd];
}
