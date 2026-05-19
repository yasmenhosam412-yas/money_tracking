import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final String category;
  final double amount;
  final int year;
  final int month;

  const Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.year,
    required this.month,
  });

  @override
  List<Object> get props => [id, category, amount, year, month];
}
