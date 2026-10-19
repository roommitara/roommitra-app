import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// listing सबमिट करते समय जो गड़बड़ हो सकती है उसका कोड
/// login | upload | limit | save
class ListingError implements Exception {
  final String code;
  const ListingError(this.code);
  @override
  String toString() => 'ListingError($code)';
}

class ListingService {
  static const String _bucket = 'room-photos';

  /// नई लिस्टिंग: पहले फोटो अपलोड, फिर listing (status = pending),
  /// फिर पूरा पता और फोन room_listing_private में।
  static Future<void> submit({
    required String category,
    required String roomType,
    required String title,
    required String description,
    required String city,
    required String locality,
    required int rooms,
    required int monthlyRent,
    required int securityDeposit,
    required int? sqft,
    required String floorLabel,
    required List<String> amenities,
    required List<String> suitableFor,
    required bool girlsOnly,
    required bool commercial,
    required String fullAddress,
    required String phone,
    required List<XFile> photos,
  }) async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) throw const ListingError('login');

    // 1) फोटो अपलोड: room-photos/<मेरी user id>/<फोल्डर>/<नंबर>.jpg
    final folder = DateTime.now().millisecondsSinceEpoch.toString();
    final storage = client.storage.from(_bucket);
    final paths = <String>[];
    try {
      for (var i = 0; i < photos.length; i++) {
        final name = photos[i].name.toLowerCase();
        final isPng = name.endsWith('.png');
        final ext = isPng ? 'png' : 'jpg';
        final path = '$uid/$folder/$i.$ext';
        final bytes = await photos[i].readAsBytes();
        await storage.uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: isPng ? 'image/png' : 'image/jpeg',
            upsert: false,
          ),
        );
        paths.add(path);
      }
    } catch (_) {
      await _cleanup(paths);
      throw const ListingError('upload');
    }

    // 2) listing (हमेशा pending, verified/featured सर्वर खुद false रखता है)
    String listingId;
    try {
      final row = await client
          .from('room_listings')
          .insert({
            'owner_id': uid,
            'title': title,
            'description': description,
            'city': city,
            'locality': locality,
            'room_type': roomType,
            'kind': category,
            'rooms': rooms,
            'monthly_rent': monthlyRent,
            'security_deposit': securityDeposit,
            'sqft': sqft,
            'floor_label': floorLabel.isEmpty ? null : floorLabel,
            'amenities': amenities,
            'suitable_for': suitableFor,
            'girls_only': girlsOnly,
            'commercial': commercial,
            'photo_urls': paths,
            'status': 'pending',
          })
          .select('id')
          .single();
      listingId = row['id'].toString();
    } catch (e) {
      await _cleanup(paths);
      final msg = e.toString();
      if (msg.contains('Listing limit reached')) {
        throw const ListingError('limit');
      }
      throw const ListingError('save');
    }

    // 3) पूरा पता और फोन: सिर्फ मालिक/एडमिन को दिखता है
    try {
      await client.from('room_listing_private').insert({
        'listing_id': listingId,
        'owner_id': uid,
        'full_address': fullAddress,
        'owner_contact_phone': phone,
      });
    } catch (_) {
      // अधूरी listing न रहे: listing हटाओ और फोटो भी
      try {
        await client.from('room_listings').delete().eq('id', listingId);
      } catch (_) {}
      await _cleanup(paths);
      throw const ListingError('save');
    }
  }

  static Future<void> _cleanup(List<String> paths) async {
    if (paths.isEmpty) return;
    try {
      await Supabase.instance.client.storage.from(_bucket).remove(paths);
    } catch (_) {}
  }
}
