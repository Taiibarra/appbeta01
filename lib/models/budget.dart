import 'finance_category.dart';

class Budget {
  final FinanceCategory category;
  double monthlyLimit;

  Budget({required this.category, required this.monthlyLimit});

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'monthlyLimit': monthlyLimit,
      };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        category: FinanceCategory.values.byName(json['category'] as String),
        monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
      );
}
