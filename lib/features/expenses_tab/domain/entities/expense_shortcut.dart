/// User-defined one-tap expense template (amount stored in app base currency).
class ExpenseShortcut {
  final String id;
  /// Shown on the quick chip.
  final String displayLabel;
  /// Saved as expense title.
  final String expenseTitle;
  final String category;
  final String? incomeSource;
  final double amountBase;

  const ExpenseShortcut({
    required this.id,
    required this.displayLabel,
    required this.expenseTitle,
    required this.category,
    this.incomeSource,
    required this.amountBase,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayLabel': displayLabel,
        'expenseTitle': expenseTitle,
        'category': category,
        'incomeSource': incomeSource,
        'amountBase': amountBase,
      };

  factory ExpenseShortcut.fromJson(Map<String, dynamic> json) {
    return ExpenseShortcut(
      id: json['id'] as String,
      displayLabel: json['displayLabel'] as String,
      expenseTitle: json['expenseTitle'] as String? ??
          json['title'] as String? ??
          '',
      category: json['category'] as String,
      incomeSource: json['incomeSource'] as String?,
      amountBase: (json['amountBase'] as num).toDouble(),
    );
  }

  ExpenseShortcut copyWith({
    String? id,
    String? displayLabel,
    String? expenseTitle,
    String? category,
    String? incomeSource,
    double? amountBase,
  }) {
    return ExpenseShortcut(
      id: id ?? this.id,
      displayLabel: displayLabel ?? this.displayLabel,
      expenseTitle: expenseTitle ?? this.expenseTitle,
      category: category ?? this.category,
      incomeSource: incomeSource ?? this.incomeSource,
      amountBase: amountBase ?? this.amountBase,
    );
  }
}
