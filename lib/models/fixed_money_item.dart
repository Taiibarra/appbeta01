class FixedMoneyItem {
  final String id;
  String label;
  double amount;

  FixedMoneyItem({required this.id, required this.label, required this.amount});

  Map<String, dynamic> toJson() => {'id': id, 'label': label, 'amount': amount};

  factory FixedMoneyItem.fromJson(Map<String, dynamic> json) => FixedMoneyItem(
        id: json['id'] as String,
        label: json['label'] as String,
        amount: (json['amount'] as num).toDouble(),
      );
}
