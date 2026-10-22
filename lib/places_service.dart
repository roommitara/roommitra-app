import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// सर्च में दिखने वाली एक जगह
class PlaceHit {
  final String id;
  final String text;
  const PlaceHit(this.id, this.text);
}

/// किसी जगह की जानकारी (लोकेशन + पता)
class PlaceInfo {
  final double lat;
  final double lng;
  final String address;
  final String name;
  const PlaceInfo(this.lat, this.lng, this.address, this.name);
}

/// पिन की जगह से निकला पता
class ReverseInfo {
  final String address;
  final String city;
  final String locality;
  const ReverseInfo(this.address, this.city, this.locality);
}

/// शहर का एक इलाका (Google के नाम)
class AreaItem {
  final String name;
  final double lat;
  final double lng;
  const AreaItem(this.name, this.lat, this.lng);
}

/// Google Places/Geocoding सीधे ऐप से नहीं, हमारे सुरक्षित सर्वर फ़ंक्शन (places-proxy) से चलते हैं,
/// ताकि चाबी ऐप में न रहे।
class PlacesService {
  static SupabaseClient get _db => Supabase.instance.client;

  static Future<Map<String, dynamic>?> _call(Map<String, dynamic> body) async {
    try {
      final r = await _db.functions.invoke('places-proxy', body: body);
      final d = r.data;
      if (d is Map<String, dynamic>) return d;
    } catch (e) {
      debugPrint('places-proxy failed: $e');
    }
    return null;
  }

  static Future<List<PlaceHit>> autocomplete(
      String q, String city, String session) async {
    final d = await _call(
        {'action': 'autocomplete', 'q': q, 'city': city, 'session': session});
    final items = (d?['items'] as List?) ?? const [];
    return items
        .map((e) => PlaceHit('${e['id']}', '${e['text']}'))
        .where((p) => p.id.isNotEmpty)
        .toList();
  }

  static Future<PlaceInfo?> details(String id, String session) async {
    final d = await _call({'action': 'details', 'id': id, 'session': session});
    if (d == null || d['lat'] == null) return null;
    return PlaceInfo((d['lat'] as num).toDouble(), (d['lng'] as num).toDouble(),
        '${d['address'] ?? ''}', '${d['name'] ?? ''}');
  }

  static Future<ReverseInfo?> reverse(double lat, double lng) async {
    final d = await _call({'action': 'reverse', 'lat': lat, 'lng': lng});
    if (d == null) return null;
    return ReverseInfo(
        '${d['address'] ?? ''}', '${d['city'] ?? ''}', '${d['locality'] ?? ''}');
  }

  static final Map<String, List<AreaItem>> _areaCache = {};

  /// शहर के इलाकों की लिस्ट: पहले सर्वर की सेव की हुई, खाली हो तो Google से एक बार मँगवाकर
  static Future<List<AreaItem>> areas(String city) async {
    final c = _areaCache[city];
    if (c != null && c.isNotEmpty) return c;
    Future<List<AreaItem>> read() async {
      final rows = await _db
          .from('city_areas')
          .select('name, lat, lng')
          .eq('city', city)
          .order('name');
      return (rows as List)
          .map((r) => AreaItem(
              '${r['name']}', (r['lat'] as num).toDouble(), (r['lng'] as num).toDouble()))
          .toList();
    }

    try {
      var list = await read();
      if (list.isEmpty) {
        await _call({'action': 'areas', 'city': city});
        list = await read();
      }
      if (list.isNotEmpty) _areaCache[city] = list;
      return list;
    } catch (e) {
      debugPrint('areas failed: $e');
      return const [];
    }
  }
}
