import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum HomeDateFilterMode { month, day }

/// Shared date filter for home tabs (incomes, expenses, balance).
class HomeDateFilter extends ChangeNotifier {
  DateTime _date = _dateOnly(DateTime.now());
  HomeDateFilterMode _mode = HomeDateFilterMode.month;

  DateTime get date => _date;
  HomeDateFilterMode get mode => _mode;

  bool get isMonthMode => _mode == HomeDateFilterMode.month;
  bool get isDayMode => _mode == HomeDateFilterMode.day;

  bool get isTodaySelected =>
      _isSameDay(_date, DateTime.now()) && _mode == HomeDateFilterMode.day;

  bool get isCurrentMonthSelected =>
      _date.year == DateTime.now().year &&
      _date.month == DateTime.now().month &&
      _mode == HomeDateFilterMode.month;

  bool get isFiltered => !isTodaySelected && !isCurrentMonthSelected;

  void apply({
    required DateTime date,
    required HomeDateFilterMode mode,
  }) {
    _date = _dateOnly(date);
    _mode = mode;
    notifyListeners();
  }

  void reset() {
    _date = _dateOnly(DateTime.now());
    _mode = HomeDateFilterMode.month;
    notifyListeners();
  }

  bool matches(DateTime value) {
    if (_mode == HomeDateFilterMode.month) {
      return value.year == _date.year && value.month == _date.month;
    }
    return _isSameDay(value, _date);
  }

  String headerLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    if (_mode == HomeDateFilterMode.month) {
      return DateFormat.yMMMM(locale).format(_date);
    }
    return DateFormat.MMMd(locale).format(_date);
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
