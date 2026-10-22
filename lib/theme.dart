import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ऐप की थीम: काली (dark) या सफ़ेद (light)। चुनी हुई थीम फोन में याद रहती है।
class AppTheme {
  /// true = काली थीम। पहली बार काली ही रहती है।
  static final ValueNotifier<bool> dark = ValueNotifier<bool>(true);

  static bool get isDark => dark.value;

  static Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getBool('dark_mode');
      if (v != null) dark.value = v;
    } catch (_) {}
  }

  static Future<void> setDark(bool v) async {
    dark.value = v;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool('dark_mode', v);
    } catch (_) {}
  }
}

/// रंग थीम के हिसाब से बदलते हैं, इसलिए ये const नहीं, getter हैं।
class AppColors {
  static bool get _d => AppTheme.isDark;

  // जेट ब्लैक #0A0A0A + सेरुलियन ब्लू #007BA7
  static Color get primary =>
      _d ? const Color(0xFF1596C4) : const Color(0xFF007BA7);
  static Color get primaryDark =>
      _d ? const Color(0xFF0A4A63) : const Color(0xFF005A7A);
  static Color get accent => const Color(0xFF35C6F4);
  static Color get tint =>
      _d ? const Color(0xFF0F2A36) : const Color(0xFFE3F3F9);
  static Color get tintLight =>
      _d ? const Color(0xFF111B21) : const Color(0xFFF2FAFD);
  static Color get text =>
      _d ? const Color(0xFFEAF4F8) : const Color(0xFF0A0A0A);
  static Color get muted =>
      _d ? const Color(0xFF98A7AE) : const Color(0xFF5F6F77);
  static Color get border =>
      _d ? const Color(0xFF26353D) : const Color(0xFFD5E5EC);
  static Color get danger =>
      _d ? const Color(0xFFFF6B6B) : const Color(0xFFD64545);

  /// पूरे स्क्रीन का बैकग्राउंड
  static Color get bg =>
      _d ? const Color(0xFF0A0A0A) : const Color(0xFFFFFFFF);

  /// कार्ड, डिब्बे, डायलॉग की सतह
  static Color get surface =>
      _d ? const Color(0xFF15191C) : const Color(0xFFFFFFFF);
}

ThemeData buildAppTheme() {
  final d = AppTheme.isDark;
  return ThemeData(
    useMaterial3: true,
    brightness: d ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF007BA7),
      brightness: d ? Brightness.dark : Brightness.light,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    canvasColor: AppColors.surface,
    dialogBackgroundColor: AppColors.surface,
    cardColor: AppColors.surface,
    dividerColor: AppColors.border,
  );
}
