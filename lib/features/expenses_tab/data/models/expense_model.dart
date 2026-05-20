import 'package:imrpo/features/expenses_tab/domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.title,
    required super.category,
    required super.amount,
    required super.date,
    super.incomeSource,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    final rawSource = map['income_source'];
    final String? incomeSource;
    if (rawSource is String) {
      final t = rawSource.trim();
      incomeSource = t.isEmpty ? null : t;
    } else {
      incomeSource = null;
    }
    return ExpenseModel(
      id: map['expense_id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      incomeSource: incomeSource,
    );
  }
}
