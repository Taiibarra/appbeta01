import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the "óxido industrial" look: warm near-black,
/// bone text, a single oxide-rust accent, thin single-color borders
/// instead of shadows, and condensed uppercase display type.
class AppColors {
  AppColors._();

  static const background = Color(0xFF17140F);
  static const surface = Color(0xFF1B1710);
  static const surfaceRaised = Color(0xFF211C14);
  static const border = Color(0xFF3A3327);
  static const borderAccent = Color(0xFFB5502E);

  static const textPrimary = Color(0xFFEDE3D3);
  static const textSecondary = Color(0xFFA79A88);
  static const textMuted = Color(0xFF7D7266);

  static const rust = Color(0xFFB5502E);
  static const rustLight = Color(0xFFD97B58);
  static const olive = Color(0xFF8A9A6B);
  static const danger = Color(0xFFC23B2B);

  // Legacy aliases kept so screens written against the previous
  // palette (mood/category colors, etc.) keep resolving sensibly.
  static const mint = olive;
  static const indigo = rustLight;
  static const coral = danger;
  static const amber = rustLight;
  static const sky = rustLight;
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final display = GoogleFonts.barlowCondensedTextTheme(base.textTheme);
  final body = GoogleFonts.barlowTextTheme(base.textTheme);

  final textTheme = body.copyWith(
    displayLarge: display.displayLarge?.copyWith(color: AppColors.textPrimary),
    displayMedium: display.displayMedium?.copyWith(color: AppColors.textPrimary),
    headlineLarge: display.headlineLarge?.copyWith(color: AppColors.textPrimary),
    headlineMedium: display.headlineMedium?.copyWith(
        color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    headlineSmall: display.headlineSmall?.copyWith(
        color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    titleLarge: display.titleLarge?.copyWith(
        color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    titleMedium: body.titleMedium?.copyWith(
        color: AppColors.textPrimary, fontWeight: FontWeight.w600),
    titleSmall: body.titleSmall?.copyWith(color: AppColors.textPrimary),
    bodyLarge: body.bodyLarge?.copyWith(color: AppColors.textPrimary),
    bodyMedium: body.bodyMedium?.copyWith(color: AppColors.textSecondary),
    bodySmall: body.bodySmall?.copyWith(color: AppColors.textMuted),
    labelLarge: body.labelLarge?.copyWith(color: AppColors.textPrimary),
  );

  final colorScheme = const ColorScheme.dark(
    brightness: Brightness.dark,
    primary: AppColors.rust,
    onPrimary: AppColors.textPrimary,
    secondary: AppColors.rustLight,
    onSecondary: Color(0xFF231A12),
    error: AppColors.danger,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    fontFamily: GoogleFonts.barlow().fontFamily,
    splashFactory: InkRipple.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: AppColors.textPrimary,
      titleTextStyle: display.headlineSmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 24,
        letterSpacing: 0.3,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.rust,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.rust,
        foregroundColor: AppColors.textPrimary,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.textPrimary),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
    ),
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceRaised,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: AppColors.rust, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.rust,
      inactiveTrackColor: AppColors.border,
      thumbColor: AppColors.rust,
      overlayColor: AppColors.rust.withValues(alpha: 0.15),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.rust,
      linearTrackColor: AppColors.border,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surfaceRaised,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceRaised,
      shape: RoundedRectangleBorder(side: BorderSide(color: AppColors.border)),
    ),
  );
}
