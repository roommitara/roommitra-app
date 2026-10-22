import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// एक नोटिफिकेशन (Supabase की notifications टेबल की एक पंक्ति)
class AppNotification {
  final String id;
  final String kind;
  final String titleHi;
  final String titleEn;
  final String bodyHi;
  final String bodyEn;
  final String? listingId;
  bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.kind,
    required this.titleHi,
    required this.titleEn,
    required this.bodyHi,
    required this.bodyEn,
    required this.listingId,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromRow(Map<String, dynamic> r) {
    return AppNotification(
      id: r['id'].toString(),
      kind: (r['kind'] ?? 'info').toString(),
      titleHi: (r['title_hi'] ?? '').toString(),
      titleEn: (r['title_en'] ?? '').toString(),
      bodyHi: (r['body_hi'] ?? '').toString(),
      bodyEn: (r['body_en'] ?? '').toString(),
      listingId: r['listing_id']?.toString(),
      isRead: r['is_read'] == true,
      createdAt:
          DateTime.tryParse((r['created_at'] ?? '').toString())?.toLocal() ??
              DateTime.now(),
    );
  }
}

/// नोटिफिकेशन लाना, न पढ़े गिनना और नया आते ही अपने आप ताज़ा करना।
/// सुरक्षा: सिर्फ अपने नोटिफिकेशन पढ़े/बदले जा सकते हैं (सर्वर की RLS)।
class NotificationService extends ChangeNotifier {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  List<AppNotification> items = <AppNotification>[];
  bool loading = false;
  bool loaded = false;
  String? error;
  RealtimeChannel? _channel;
  String? _uid;

  int get unread => items.where((n) => !n.isRead).length;

  SupabaseClient get _db => Supabase.instance.client;

  /// लॉगिन खाता बदलने पर पुराना हटाओ, नया लाओ और नए आने वालों की सुनवाई शुरू करो
  Future<void> start() async {
    final user = _db.auth.currentUser;
    if (user == null) {
      await stop();
      return;
    }
    if (_uid != user.id) {
      await stop();
      _uid = user.id;
      _listen(user.id);
    }
    await load();
  }

  void _listen(String uid) {
    try {
      _channel = _db
          .channel('notifications-$uid')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: uid,
            ),
            callback: (_) => load(),
          )
          .subscribe();
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      final ch = _channel;
      if (ch != null) await _db.removeChannel(ch);
    } catch (_) {}
    _channel = null;
    _uid = null;
    items = <AppNotification>[];
    loaded = false;
    error = null;
    notifyListeners();
  }

  Future<void> load() async {
    final user = _db.auth.currentUser;
    if (user == null) return;
    loading = true;
    notifyListeners();
    try {
      final rows = await _db
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(100);
      items = List<Map<String, dynamic>>.from(rows as List)
          .map(AppNotification.fromRow)
          .toList();
      error = null;
      loaded = true;
    } catch (_) {
      error = 'load';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> markRead(AppNotification n) async {
    if (n.isRead) return;
    n.isRead = true;
    notifyListeners();
    try {
      await _db.from('notifications').update({'is_read': true}).eq('id', n.id);
    } catch (_) {
      n.isRead = false;
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    final user = _db.auth.currentUser;
    if (user == null) return;
    final prev = items.where((n) => !n.isRead).toList();
    for (final n in prev) {
      n.isRead = true;
    }
    notifyListeners();
    try {
      await _db
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);
    } catch (_) {
      for (final n in prev) {
        n.isRead = false;
      }
      notifyListeners();
    }
  }

  Future<void> delete(AppNotification n) async {
    final idx = items.indexOf(n);
    items.remove(n);
    notifyListeners();
    try {
      await _db.from('notifications').delete().eq('id', n.id);
    } catch (_) {
      if (idx >= 0 && idx <= items.length) items.insert(idx, n);
      notifyListeners();
    }
  }
}
