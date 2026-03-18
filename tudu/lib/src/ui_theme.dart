import 'package:flutter/material.dart';

const tuduGreen = Color(0xFF2EC08E);
const tuduGreenDark = Color(0xFF20A77A);
const tuduBg = Color(0xFF24B27F);

ThemeData buildTuduTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: tuduGreen,
    brightness: Brightness.light,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: tuduBg,
    useMaterial3: true,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
