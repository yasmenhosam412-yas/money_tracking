import 'package:equatable/equatable.dart';

enum BalanceActivityType { income, expense }

class BalanceActivity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final BalanceActivityType type;

  const BalanceActivity({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });

  @override
  List<Object> get props => [id, title, amount, date, type];
}
