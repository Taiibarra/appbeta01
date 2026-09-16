class Budget {
  final String categoryId;
  double monthlyLimit;

  Budget({required this.categoryId, required this.monthlyLimit});

  Map<String, dynamic> toJson() => {
        'category': categoryId,
        'monthlyLimit': monthlyLimit,
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        categoryId: json['category'] as String,
        monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
      );
}
