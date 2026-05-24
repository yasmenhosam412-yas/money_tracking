import 'package:equatable/equatable.dart';

class ZakatInput extends Equatable {
  final double cash;
  final double goldGrams;
  final double silverGrams;
  final double investments;
  final double businessGoods;
  final double receivables;
  final double debts;
  final double goldPricePerGram;
  final double silverPricePerGram;

  const ZakatInput({
    this.cash = 0,
    this.goldGrams = 0,
    this.silverGrams = 0,
    this.investments = 0,
    this.businessGoods = 0,
    this.receivables = 0,
    this.debts = 0,
    this.goldPricePerGram = 0,
    this.silverPricePerGram = 0,
  });

  double get goldValue => goldGrams * goldPricePerGram;

  double get silverValue => silverGrams * silverPricePerGram;

  @override
  List<Object> get props => [
        cash,
        goldGrams,
        silverGrams,
        investments,
        businessGoods,
        receivables,
        debts,
        goldPricePerGram,
        silverPricePerGram,
      ];
}
