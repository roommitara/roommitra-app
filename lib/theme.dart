import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0B5D3B);
  static const primaryDark = Color(0xFF07442B);
  static const accent = Color(0xFF6FE23C);
  static const tint = Color(0xFFE6F4EC);
  static const tintLight = Color(0xFFF3FAF6);
  static const text = Color(0xFF10261C);
  static const muted = Color(0xFF6B7C74);
  static const border = Color(0xFFD9E8DF);
  static const danger = Color(0xFFD64545);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: Colors.white,
  );
}
