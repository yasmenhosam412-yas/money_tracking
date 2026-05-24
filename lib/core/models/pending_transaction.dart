enum PendingTransactionKind { expense, income }

class PendingTransaction {
  static const idPrefix = 'offline:';

  final String localId;
  final PendingTransactionKind kind;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String? incomeSource;
  final String? entryCurrency;
  final double? entryAmount;
  final String? associationId;
  final DateTime createdAt;

  const PendingTransaction({
    required this.localId,
    required this.kind,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.incomeSource,
    this.entryCurrency,
    this.entryAmount,
    this.associationId,
    required this.createdAt,
  });

  String get publicId => '$idPrefix$localId';

  static bool isOfflinePublicId(String id) => id.startsWith(idPrefix);

  static String localIdFromPublic(String publicId) =>
      publicId.substring(idPrefix.length);

  Map<String, dynamic> toJson() => {
        'localId': localId,
        'kind': kind.name,
        'title': title,
        'category': category,
        'amount': amount,
        'date': date.toIso8601String(),
        'incomeSource': incomeSource,
        'entryCurrency': entryCurrency,
        'entryAmount': entryAmount,
        'associationId': associationId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PendingTransaction.fromJson(Map<String, dynamic> json) {
    return PendingTransaction(
      localId: json['localId'] as String,
      kind: PendingTransactionKind.values.byName(json['kind'] as String),
      title: json['title'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      incomeSource: json['incomeSource'] as String?,
      entryCurrency: json['entryCurrency'] as String?,
      entryAmount: (json['entryAmount'] as num?)?.toDouble(),
      associationId: json['associationId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
