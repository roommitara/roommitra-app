import 'package:flutter/foundation.dart';

/// ऐप की भाषा: 'hi' = हिंदी, 'en' = English
class AppLang {
  static final ValueNotifier<String> notifier = ValueNotifier<String>('hi');

  static bool get isHindi => notifier.value == 'hi';

  static void toggle() {
    notifier.value = isHindi ? 'en' : 'hi';
  }
}

/// t('हिंदी टेक्स्ट', 'English text') - चुनी हुई भाषा का टेक्स्ट देता है
String t(String hi, String en) => AppLang.isHindi ? hi : en;
