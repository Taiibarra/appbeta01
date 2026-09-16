class FixedMoneyItem {
  final String id;
  String label;
  double amount;

  /// "yyyy-MM" of the last calendar month this item was deposited/charged
  /// into the real transaction ledger. Null means it has never fired yet.
  String? lastAppliedMonth;

  FixedMoneyItem({
    required this.id,
    required this.label,
    required this.amount,
    this.lastAppliedMonth,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'amount': amount,
        'lastAppliedMonth': lastAppliedMonth,
      };

  factory FixedMoneyItem.fromJson(Map<String, dynamic> json) => FixedMoneyItem(
        id: json['id'] as String,
        label: json['label'] as String,
        amount: (json['amount'] as num).toDouble(),
        lastAppliedMonth: json['lastAppliedMonth'] as String?,
      );
}
