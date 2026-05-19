import 'package:imrpo/core/services/home_date_filter.dart';

class BudgetPeriod {
  final int year;
  final int month;

  const BudgetPeriod({required this.year, required this.month});

  factory BudgetPeriod.fromDateFilter(HomeDateFilter filter) {
    if (filter.isAllMode) {
      final now = DateTime.now();
      return BudgetPeriod(year: now.year, month: now.month);
    }
    return BudgetPeriod(year: filter.date.year, month: filter.date.month);
  }

  DateTime get startDate => DateTime(year, month);

  BudgetPeriod get previous {
    if (month == 1) {
      return BudgetPeriod(year: year - 1, month: 12);
    }
    return BudgetPeriod(year: year, month: month - 1);
  }

  BudgetPeriod get next {
    if (month == 12) {
      return BudgetPeriod(year: year + 1, month: 1);
    }
    return BudgetPeriod(year: year, month: month + 1);
  }

  bool get isCurrentMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }
}
