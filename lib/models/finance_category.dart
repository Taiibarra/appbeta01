import 'package:flutter/material.dart';

/// A small curated icon palette both built-in and user-created
/// categories pick from. Persisting a string key instead of an
/// IconData keeps storage simple and stable across app updates.
const Map<String, IconData> categoryIconPalette = {
  'trabajo': Icons.work_rounded,
  'freelance': Icons.laptop_mac_rounded,
  'inversion': Icons.trending_up_rounded,
  'ingreso': Icons.add_card_rounded,
  'comida': Icons.restaurant_rounded,
  'transporte': Icons.directions_car_filled_rounded,
  'vivienda': Icons.home_rounded,
  'entretenimiento': Icons.movie_rounded,
  'salud': Icons.favorite_rounded,
  'educacion': Icons.school_rounded,
  'ahorro': Icons.savings_rounded,
  'suscripciones': Icons.autorenew_rounded,
  'otro': Icons.more_horiz_rounded,
  'cigarros': Icons.smoking_rooms_rounded,
  'alcohol': Icons.local_bar_rounded,
  'juegos': Icons.sports_esports_rounded,
  'mascota': Icons.pets_rounded,
  'fiesta': Icons.celebration_rounded,
  'regalo': Icons.card_giftcard_rounded,
  'compras': Icons.shopping_bag_rounded,
  'bienestar': Icons.spa_rounded,
  'viaje': Icons.flight_takeoff_rounded,
  'cafe': Icons.local_cafe_rounded,
  'musica': Icons.music_note_rounded,
  'deporte': Icons.sports_soccer_rounded,
};

const List<Color> categoryColorPalette = [
  Color(0xFFB5502E),
  Color(0xFFD97B58),
  Color(0xFF8A9A6B),
  Color(0xFFC23B2B),
  Color(0xFF5AC8FA),
  Color(0xFFB988FF),
  Color(0xFFFF6FA5),
  Color(0xFFE0C25B),
];

/// A spending/income category. Built-ins are compile-time constants;
/// custom ones are created by the user at runtime and persisted —
/// both are the same shape so the rest of the app treats them alike.
class SpendCategory {
  final String id;
  final String label;
  final String iconKey;
  final Color color;
  final bool isIncome;
  final bool isEssential;
  final bool isCustom;

  const SpendCategory({
    required this.id,
    required this.label,
    required this.iconKey,
    required this.color,
    required this.isIncome,
    this.isEssential = false,
    this.isCustom = false,
  });

  IconData get icon => categoryIconPalette[iconKey] ?? Icons.more_horiz_rounded;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'iconKey': iconKey,
        'colorValue': color.toARGB32(),
        'isIncome': isIncome,
        'isEssential': isEssential,
      };

  factory SpendCategory.fromJson(Map<String, dynamic> json) => SpendCategory(
        id: json['id'] as String,
        label: json['label'] as String,
        iconKey: json['iconKey'] as String,
        color: Color(json['colorValue'] as int),
        isIncome: json['isIncome'] as bool? ?? false,
        isEssential: json['isEssential'] as bool? ?? false,
        isCustom: true,
      );
}

const List<SpendCategory> builtinCategories = [
  SpendCategory(
      id: 'salario',
      label: 'Salario',
      iconKey: 'trabajo',
      color: Color(0xFF8A9A6B),
      isIncome: true,
      isEssential: true),
  SpendCategory(
      id: 'freelance',
      label: 'Freelance',
      iconKey: 'freelance',
      color: Color(0xFF8A9A6B),
      isIncome: true,
      isEssential: true),
  SpendCategory(
      id: 'inversion',
      label: 'Inversiones',
      iconKey: 'inversion',
      color: Color(0xFF8A9A6B),
      isIncome: true,
      isEssential: true),
  SpendCategory(
      id: 'otroIngreso',
      label: 'Otro ingreso',
      iconKey: 'ingreso',
      color: Color(0xFF8A9A6B),
      isIncome: true,
      isEssential: true),
  SpendCategory(
      id: 'comida',
      label: 'Comida',
      iconKey: 'comida',
      color: Color(0xFFD97B58),
      isIncome: false,
      isEssential: true),
  SpendCategory(
      id: 'transporte',
      label: 'Transporte',
      iconKey: 'transporte',
      color: Color(0xFF5AC8FA),
      isIncome: false,
      isEssential: true),
  SpendCategory(
      id: 'vivienda',
      label: 'Vivienda',
      iconKey: 'vivienda',
      color: Color(0xFFB988FF),
      isIncome: false,
      isEssential: true),
  SpendCategory(
      id: 'entretenimiento',
      label: 'Entretenimiento',
      iconKey: 'entretenimiento',
      color: Color(0xFFFF6FA5),
      isIncome: false,
      isEssential: false),
  SpendCategory(
      id: 'salud',
      label: 'Salud',
      iconKey: 'salud',
      color: Color(0xFFC23B2B),
      isIncome: false,
      isEssential: true),
  SpendCategory(
      id: 'educacion',
      label: 'Educación',
      iconKey: 'educacion',
      color: Color(0xFF5AC8FA),
      isIncome: false,
      isEssential: true),
  SpendCategory(
      id: 'ahorro',
      label: 'Ahorro',
      iconKey: 'ahorro',
      color: Color(0xFF8A9A6B),
      isIncome: false,
      isEssential: true),
  SpendCategory(
      id: 'suscripciones',
      label: 'Suscripciones',
      iconKey: 'suscripciones',
      color: Color(0xFFE0C25B),
      isIncome: false,
      isEssential: false),
  SpendCategory(
      id: 'otroGasto',
      label: 'Otro gasto',
      iconKey: 'otro',
      color: Color(0xFFB5502E),
      isIncome: false,
      isEssential: false),
];
