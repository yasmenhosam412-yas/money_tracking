import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;

  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  @override
  List<Object> get props => [id, title, category, amount, date];
}
