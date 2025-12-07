import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData pastelTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF8F2FF),
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
  );
}
