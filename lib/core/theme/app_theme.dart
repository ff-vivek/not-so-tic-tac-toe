import 'package:flutter/material.dart';

/// Centralized app theme so UI layers can stay consistent across features.
ThemeData buildAppTheme() {
  const primaryColor = Color(0xFF1D3557);
  const accentColor = Color(0xFFE63946);

  final base = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: accentColor,
      background: const Color(0xFFF1FAEE),
      surface: Colors.white,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFFF1FAEE),
    textTheme: base.textTheme.apply(
      displayColor: primaryColor,
      bodyColor: primaryColor,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}