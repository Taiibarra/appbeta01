const _legacyIncomeCategoryIds = {'salario', 'freelance', 'inversion', 'otroIngreso'};

class Transaction {
  final String id;
  final String categoryId;
  final bool isIncome;
  final double amount;
  final String note;
  final DateTime date;

  Transaction({
    required this.id,
    required this.categoryId,
    required this.isIncome,
    required this.amount,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': categoryId,
        'isIncome': isIncome,
        'amount': amount,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final categoryId = json['category'] as String;
    return Transaction(
      id: json['id'] as String,
      categoryId: categoryId,
      // Older saves predate the isIncome field — fall back to the
      // built-in category id to infer it.
      isIncome: json['isIncome'] as bool? ?? _legacyIncomeCategoryIds.contains(categoryId),
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
    );
  }
}
