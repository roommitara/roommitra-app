import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ऐप की भाषा: 'hi' = हिंदी, 'en' = English
class AppLang {
  static final ValueNotifier<String> notifier = ValueNotifier<String>('hi');

  static bool get isHindi => notifier.value == 'hi';

  static void toggle() {
    notifier.value = isHindi ? 'en' : 'hi';
    _save();
  }

  /// ऐप खुलते समय पिछली चुनी भाषा वापस लाओ
  static Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getString('app_lang');
      if (v == 'hi' || v == 'en') notifier.value = v!;
    } catch (_) {}
  }

  static Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('app_lang', notifier.value);
    } catch (_) {}
  }
}

/// t('हिंदी टेक्स्ट', 'English text') - चुनी हुई भाषा का टेक्स्ट देता है
String t(String hi, String en) => AppLang.isHindi ? hi : en;
