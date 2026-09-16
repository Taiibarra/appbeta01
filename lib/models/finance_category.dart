import 'package:flutter/material.dart';

enum FinanceCategory {
  salario,
  freelance,
  inversion,
  otroIngreso,
  comida,
  transporte,
  vivienda,
  entretenimiento,
  salud,
  educacion,
  ahorro,
  suscripciones,
  otroGasto,
}

extension FinanceCategoryX on FinanceCategory {
  bool get isIncome =>
      this == FinanceCategory.salario ||
      this == FinanceCategory.freelance ||
      this == FinanceCategory.inversion ||
      this == FinanceCategory.otroIngreso;

  String get label {
    switch (this) {
      case FinanceCategory.salario:
        return 'Salario';
      case FinanceCategory.freelance:
        return 'Freelance';
      case FinanceCategory.inversion:
        return 'Inversiones';
      case FinanceCategory.otroIngreso:
        return 'Otro ingreso';
      case FinanceCategory.comida:
        return 'Comida';
      case FinanceCategory.transporte:
        return 'Transporte';
      case FinanceCategory.vivienda:
        return 'Vivienda';
      case FinanceCategory.entretenimiento:
        return 'Entretenimiento';
      case FinanceCategory.salud:
        return 'Salud';
      case FinanceCategory.educacion:
        return 'Educación';
      case FinanceCategory.ahorro:
        return 'Ahorro';
      case FinanceCategory.suscripciones:
        return 'Suscripciones';
      case FinanceCategory.otroGasto:
        return 'Otro gasto';
    }
  }

  IconData get icon {
    switch (this) {
      case FinanceCategory.salario:
        return Icons.work_rounded;
      case FinanceCategory.freelance:
        return Icons.laptop_mac_rounded;
      case FinanceCategory.inversion:
        return Icons.trending_up_rounded;
      case FinanceCategory.otroIngreso:
        return Icons.add_card_rounded;
      case FinanceCategory.comida:
        return Icons.restaurant_rounded;
      case FinanceCategory.transporte:
        return Icons.directions_car_filled_rounded;
      case FinanceCategory.vivienda:
        return Icons.home_rounded;
      case FinanceCategory.entretenimiento:
        return Icons.movie_rounded;
      case FinanceCategory.salud:
        return Icons.favorite_rounded;
      case FinanceCategory.educacion:
        return Icons.school_rounded;
      case FinanceCategory.ahorro:
        return Icons.savings_rounded;
      case FinanceCategory.suscripciones:
        return Icons.autorenew_rounded;
      case FinanceCategory.otroGasto:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case FinanceCategory.salario:
      case FinanceCategory.freelance:
      case FinanceCategory.inversion:
      case FinanceCategory.otroIngreso:
        return const Color(0xFF3DDC97);
      case FinanceCategory.comida:
        return const Color(0xFFFF9F5A);
      case FinanceCategory.transporte:
        return const Color(0xFF5AC8FA);
      case FinanceCategory.vivienda:
        return const Color(0xFFB988FF);
      case FinanceCategory.entretenimiento:
        return const Color(0xFFFF6FA5);
      case FinanceCategory.salud:
        return const Color(0xFFFF6B6B);
      case FinanceCategory.educacion:
        return const Color(0xFF5AD1D1);
      case FinanceCategory.ahorro:
        return const Color(0xFF3DDC97);
      case FinanceCategory.suscripciones:
        return const Color(0xFFE0C25B);
      case FinanceCategory.otroGasto:
        return const Color(0xFF9BA1AC);
    }
  }

  static List<FinanceCategory> get incomeCategories => FinanceCategory.values
      .where((c) => c.isIncome)
      .toList(growable: false);

  static List<FinanceCategory> get expenseCategories => FinanceCategory.values
      .where((c) => !c.isIncome)
      .toList(growable: false);
}
