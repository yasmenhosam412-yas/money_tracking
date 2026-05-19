import 'package:imrpo/features/incomes_tab/domain/entities/income.dart';

class IncomeModel extends Income {
  const IncomeModel({
    required super.id,
    required super.title,
    required super.category,
    required super.amount,
    required super.date,
  });

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['income_id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
    );
  }
}