import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the dark, fintech-inspired look of the app.
/// Kept as static constants (rather than scattering hex codes across
/// screens) so the palette reads as one deliberate system.
class AppColors {
  AppColors._();

  static const background = Color(0xFF0A0B0F);
  static const surface = Color(0xFF14161D);
  static const surfaceRaised = Color(0xFF1B1E27);
  static const border = Color(0xFF272B36);
  static const textPrimary = Color(0xFFF3F4F8);
  static const textSecondary = Color(0xFF9BA1AC);
  static const textMuted = Color(0xFF6B707C);

  static const mint = Color(0xFF3DDC97);
  static const indigo = Color(0xFF7C8CFF);
  static const coral = Color(0xFFFF6B6B);
  static const amber = Color(0xFFE8B84B);
  static const sky = Color(0xFF5AC8FA);

  static const gradientStart = Color(0xFF171B2B);
  static const gradientEnd = Color(0xFF0F1119);
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final display = GoogleFonts.spaceGroteskTextTheme(base.textTheme);
  final body = GoogleFonts.interTextTheme(base.textTheme);

  final textTheme = body.copyWith(
    displayLarge: display.displayLarge?.copyWith(color: AppColors.textPrimary),
    displayMedium: display.displayMedium?.copyWith(color: AppColors.textPrimary),
    headlineLarge: display.headlineLarge?.copyWith(color: AppColors.textPrimary),
    headlineMedium: display.headlineMedium?.copyWith(
        color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    headlineSmall: display.headlineSmall?.copyWith(
        color: AppColors.textPrimary, fontWeight: FontWeight.w700),
    titleLarge: display.titleLarge?.copyWith(
        color: AppColors.textPrimary, fontWeight: FontWeight.w600),
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
    primary: AppColors.mint,
    onPrimary: Color(0xFF06231A),
    secondary: AppColors.indigo,
    onSecondary: Colors.white,
    error: AppColors.coral,
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
    fontFamily: GoogleFonts.inter().fontFamily,
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
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.mint,
        foregroundColor: const Color(0xFF06231A),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.mint, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.mint,
      inactiveTrackColor: AppColors.border,
      thumbColor: AppColors.mint,
      overlayColor: AppColors.mint.withValues(alpha: 0.15),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.mint,
      linearTrackColor: AppColors.border,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceRaised,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
  );
}
