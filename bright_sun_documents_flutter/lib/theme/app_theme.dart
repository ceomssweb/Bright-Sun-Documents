import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF0D7377);
  static const Color primaryLight = Color(0xFF14A3A8);
  static const Color primaryDark = Color(0xFF095456);
  static const Color secondary = Color(0xFFFF6B35);
  static const Color tertiary = Color(0xFF323232);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceCard = Colors.white;
  static const Color surfaceDim = Color(0xFFEEF0F2);

  static Color getPaymentColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return success;
      case 'pending':
        return warning;
      case 'partial':
        return info;
      case 'not paid':
        return error;
      default:
        return Colors.grey;
    }
  }

  static Color getDocStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ready for processing':
        return const Color(0xFF7B1FA2);
      case 'in progress':
        return const Color(0xFF1565C0);
      case 'under review':
        return warning;
      case 'completed':
        return success;
      case 'delivered':
        return const Color(0xFF00695C);
      case 'on hold':
        return Colors.grey;
      case 'cancelled':
        return error;
      default:
        return Colors.grey;
    }
  }

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        error: error,
      ),
      scaffoldBackgroundColor: surface,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: tertiary,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(color: primary, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade600),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
      chipTheme: ChipThemeData(
        selectedColor: primary.withAlpha(30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(primary.withAlpha(15)),
        headingTextStyle: const TextStyle(color: tertiary, fontWeight: FontWeight.w700, fontSize: 13),
        dataTextStyle: const TextStyle(fontSize: 13, color: tertiary),
        headingRowHeight: 48,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 56,
      ),
      dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1, space: 24),
      dialogTheme: DialogThemeData(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: tertiary),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: tertiary),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
        headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: primary),
        headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: tertiary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: tertiary),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: tertiary),
        bodyLarge: TextStyle(fontSize: 15, color: tertiary, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: tertiary, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, color: Color(0xFF666666), height: 1.5),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
