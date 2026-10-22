import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data.dart';
import 'strings.dart';

/// फोन पर असली (push) नोटिफिकेशन: ऐप बंद हो तब भी आता है।
/// यह फोन का टोकन और चुना हुआ शहर सर्वर में रखता है (सिर्फ register_device फ़ंक्शन से)।
/// कोई भी गड़बड़ हो तो ऐप चलता रहता है, बस push नहीं आएगा।
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  bool _started = false;
  String? _token;
  String? _lastSent;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      await Firebase.initializeApp();
      final fm = FirebaseMessaging.instance;
      await fm.requestPermission();
      _token = await fm.getToken();
      fm.onTokenRefresh.listen((t) {
        _token = t;
        sync();
      });
      appState.addListener(sync);
      AppLang.notifier.addListener(sync);
      Supabase.instance.client.auth.onAuthStateChange.listen((_) => sync());
      await sync();
    } catch (e) {
      debugPrint('Push start failed: $e');
    }
  }

  /// टोकन + शहर + भाषा सर्वर पर भेजो (बदलने पर ही)
  Future<void> sync() async {
    try {
      final token = _token;
      final user = Supabase.instance.client.auth.currentUser;
      if (token == null || user == null) return;
      final lang = AppLang.isHindi ? 'hi' : 'en';
      final key = '${user.id}|$token|${appState.city}|$lang';
      if (key == _lastSent) return;
      await Supabase.instance.client.rpc('register_device', params: {
        'p_token': token,
        'p_city': appState.city,
        'p_lang': lang,
      });
      _lastSent = key;
    } catch (e) {
      debugPrint('Push sync failed: $e');
    }
  }

  /// एडमिन के कमरा मंज़ूर करने पर: उस शहर के यूज़र्स को push भेजवाओ
  static Future<void> notifyNewRoom(String listingId) async {
    try {
      await Supabase.instance.client.functions
          .invoke('push-new-room', body: {'listing_id': listingId});
    } catch (e) {
      debugPrint('notifyNewRoom failed: $e');
    }
  }
}
