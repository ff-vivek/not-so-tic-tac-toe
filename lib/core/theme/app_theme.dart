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
    useMaterial3: true,
  );

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFFF1FAEE),
    textTheme: base.textTheme.apply(
      displayColor: primaryColor,
      bodyColor: primaryColor,
      fontFamily: 'NotoSans',
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'NotoSans',
        ),
      ),
    ),
  );
}

ThemeData buildDarkAppTheme() {
  const primaryColor = Color(0xFF99C1DE);
  const accentColor = Color(0xFFFF6B6B);

  final base = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: accentColor,
      brightness: Brightness.dark,
      background: const Color(0xFF0E1116),
      surface: const Color(0xFF141922),
    ),
    useMaterial3: true,
  );

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF0E1116),
    textTheme: base.textTheme.apply(fontFamily: 'NotoSans'),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'NotoSans'),
      ),
    ),
  );
}
