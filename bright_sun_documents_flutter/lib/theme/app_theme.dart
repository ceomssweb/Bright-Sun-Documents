import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF5F9EA0); // cadetblue
  static const Color footerDefault = Colors.white;
  static const Color borderColor = Color(0xFFDFDDDD);

  static ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: const BorderSide(color: primaryColor),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateProperty.all(primaryColor),
          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: primaryColor),
          headlineMedium: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: primaryColor),
          headlineSmall: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: primaryColor),
          bodyLarge: TextStyle(fontSize: 14),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      );
}
