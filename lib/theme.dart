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

  static Color get primary =>
      _d ? const Color(0xFF1FA067) : const Color(0xFF0B5D3B);
  static Color get primaryDark =>
      _d ? const Color(0xFF2DB87C) : const Color(0xFF07442B);
  static Color get accent => const Color(0xFF6FE23C);
  static Color get tint =>
      _d ? const Color(0xFF1C3A2C) : const Color(0xFFE6F4EC);
  static Color get tintLight =>
      _d ? const Color(0xFF16241D) : const Color(0xFFF3FAF6);
  static Color get text =>
      _d ? const Color(0xFFE8F2EC) : const Color(0xFF10261C);
  static Color get muted =>
      _d ? const Color(0xFF9DB0A6) : const Color(0xFF6B7C74);
  static Color get border =>
      _d ? const Color(0xFF2C4136) : const Color(0xFFD9E8DF);
  static Color get danger =>
      _d ? const Color(0xFFFF6B6B) : const Color(0xFFD64545);

  /// पूरे स्क्रीन का बैकग्राउंड
  static Color get bg =>
      _d ? const Color(0xFF0E1511) : const Color(0xFFFFFFFF);

  /// कार्ड, डिब्बे, डायलॉग की सतह
  static Color get surface =>
      _d ? const Color(0xFF17211B) : const Color(0xFFFFFFFF);
}

ThemeData buildAppTheme() {
  final d = AppTheme.isDark;
  return ThemeData(
    useMaterial3: true,
    brightness: d ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0B5D3B),
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
