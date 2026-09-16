import 'finance_category.dart';

class Transaction {
  final String id;
  final FinanceCategory category;
  final double amount;
  final String note;
  final DateTime date;

  Transaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.note = '',
  });

  bool get isIncome => category.isIncome;

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'amount': amount,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        category: FinanceCategory.values.byName(json['category'] as String),
        amount: (json['amount'] as num).toDouble(),
        note: json['note'] as String? ?? '',
        date: DateTime.parse(json['date'] as String),
      );
}
