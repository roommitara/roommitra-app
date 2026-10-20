import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'strings.dart';

/// जाँच के लिए: यहाँ अपना 10 अंकों का मोबाइल नंबर डालें (जैसे '9876543210'),
/// ताकि "कॉल करें" और "WhatsApp करें" बटन आपके नंबर पर खुलें।
/// खाली छोड़ने पर बटन सिर्फ एक संदेश दिखाएँगे।
const String demoPhone = '';

const List<String> allCities = ['Nahan', 'Paonta Sahib', 'Rajgarh', 'Kala Amb'];

const Map<String, String> cityHindi = {
  'Nahan': 'नाहन',
  'Paonta Sahib': 'पांवटा साहिब',
  'Rajgarh': 'राजगढ़',
  'Kala Amb': 'काला अंब',
};

/// शहर का नाम चुनी हुई भाषा में: हिंदी में नाहन, English में Nahan
String cityName(String c) => AppLang.isHindi ? (cityHindi[c] ?? c) : c;

/// लिस्टिंग की श्रेणी (category)। code ही Supabase के room_listings.kind में सेव होता है।
class ListingCategory {
  final String code;
  final String _hi;
  final String _en;
  final IconData icon;
  const ListingCategory(this.code, this._hi, this._en, this.icon);

  /// चुनी हुई भाषा में नाम
  String get label => t(_hi, _en);
}

const List<ListingCategory> listingCategories = [
  ListingCategory('pg_hostel', 'PG / हॉस्टल', 'PG / Hostel', Icons.home_rounded),
  ListingCategory('single_room', 'सिंगल रूम', 'Single Room', Icons.single_bed),
  ListingCategory('double_room', 'डबल रूम', 'Double Room', Icons.king_bed),
  ListingCategory('flat', 'फ्लैट', 'Flat', Icons.apartment),
  ListingCategory('shop', 'दुकान', 'Shop', Icons.storefront),
  ListingCategory('sharing', 'शेयरिंग (रूम पार्टनर)', 'Sharing (room partner)',
      Icons.people),
  ListingCategory('girls_boys', 'लड़कियाँ / लड़के', 'Girls / Boys', Icons.groups),
];

/// श्रेणी का नाम (code से)। पुराने डेमो कमरों की हिंदी values वैसी ही वापस आती हैं।
String categoryLabel(String code) {
  for (final c in listingCategories) {
    if (c.code == code) return c.label;
  }
  return code;
}

/// Supabase के room_type की जाँच (CHECK) के हिसाब से सही वैल्यू:
/// single_room, shared_room, 1rk, 1bhk, 2bhk, 3bhk_plus, pg_bed, other
String roomTypeFor(String code, int rooms) {
  switch (code) {
    case 'pg_hostel':
      return 'pg_bed';
    case 'single_room':
      return 'single_room';
    case 'sharing':
      return 'shared_room';
    case 'flat':
      if (rooms <= 1) return '1bhk';
      if (rooms == 2) return '2bhk';
      return '3bhk_plus';
    default:
      return 'other';
  }
}

class Amenity {
  final String id;
  final String _hi;
  final String _en;
  final IconData icon;
  const Amenity(this.id, this._hi, this._en, this.icon);

  /// चुनी हुई भाषा में नाम
  String get label => t(_hi, _en);
}

const List<Amenity> allAmenities = [
  Amenity('wifi', 'WiFi', 'WiFi', Icons.wifi),
  Amenity('ac', 'AC', 'AC', Icons.ac_unit),
  Amenity('bed', 'बेड', 'Bed', Icons.bed),
  Amenity('wardrobe', 'वार्डरोब', 'Wardrobe', Icons.checkroom),
  Amenity('water', 'पानी', 'Water', Icons.water_drop),
  Amenity('parking', 'पार्किंग', 'Parking', Icons.local_parking),
  Amenity('balcony', 'बालकनी', 'Balcony', Icons.balcony),
  Amenity('food', 'खाना', 'Food', Icons.restaurant),
  Amenity('electricity', 'बिजली', 'Electricity', Icons.bolt),
  Amenity('tv', 'TV', 'TV', Icons.tv),
];

/// भारतीय तरीके से अंक लिखना: 12000 -> 12,000 और 100000 -> 1,00,000
String inr(int n) {
  final s = n.toString();
  if (s.length <= 3) return s;
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

class Listing {
  final String id;
  final String _title;
  final String _titleEn;
  final String area;
  final String city;
  final String type; // PG, 1RK, 1BHK, 2BHK, 3BHK+
  final String kind; // श्रेणी: pg_hostel, single_room... (डेमो में: PG, फ्लैट, रूम, हॉस्टल)
  final int rooms;
  final int price;
  final String typeLabel;
  final String bathLabel;
  final int sqft;
  final String floor;
  final String _desc;
  final String _descEn;
  final Set<String> amenities;
  final String image;
  final int photos;
  final bool verified;
  final bool directOwner;
  final bool safeWomen;
  final bool girlsOnly;
  final bool immediate;
  final bool commercial;
  final String phone;
  final int order;

  /// मालिक ने मैप पर जो जगह चुनी (खाली हो तो लोकेशन सेट नहीं है)
  final double? lat;
  final double? lng;

  /// इलाके का नाम (जैसे Rani Tal) और पूरा पता
  final String locality;
  final String address;

  /// Supabase से आए असली कमरों के लिए (डेमो कमरों में ये खाली रहते हैं)
  final String ownerId;
  final String status;
  final bool isAvailable;
  final List<String> photoUrls;

  const Listing({
    required this.id,
    required String title,
    String titleEn = '',
    required this.area,
    required this.city,
    required this.type,
    required this.kind,
    required this.rooms,
    required this.price,
    required this.typeLabel,
    required this.bathLabel,
    required this.sqft,
    required this.floor,
    required String desc,
    String descEn = '',
    required this.amenities,
    required this.image,
    required this.photos,
    this.verified = false,
    this.directOwner = false,
    this.safeWomen = false,
    this.girlsOnly = false,
    this.immediate = false,
    this.commercial = false,
    this.phone = '',
    this.order = 0,
    this.lat,
    this.lng,
    this.locality = '',
    this.address = '',
    this.ownerId = '',
    this.status = 'approved',
    this.isAvailable = true,
    this.photoUrls = const <String>[],
  })  : _title = title,
        _titleEn = titleEn,
        _desc = desc,
        _descEn = descEn;

  /// Supabase की room_listings पंक्ति से कमरा बनाना
  factory Listing.fromRow(Map<String, dynamic> r, int index) {
    final storage = Supabase.instance.client.storage.from('room-photos');
    final urls = <String>[];
    final rawPhotos = r['photo_urls'];
    if (rawPhotos is List) {
      for (final p in rawPhotos) {
        final s = p?.toString() ?? '';
        if (s.isEmpty) continue;
        urls.add(s.startsWith('http') ? s : storage.getPublicUrl(s));
      }
    }
    final am = <String>{};
    final rawAm = r['amenities'];
    if (rawAm is List) {
      for (final a in rawAm) {
        if (a != null) am.add(a.toString());
      }
    }
    final city = (r['city'] ?? '').toString();
    final locality = (r['locality'] ?? '').toString();
    final rent = r['monthly_rent'];
    final roomsRaw = r['rooms'];
    final bathRaw = r['bathrooms'];
    final sqftRaw = r['sqft'];
    final latRaw = r['lat'];
    final lngRaw = r['lng'];
    final kindRaw = (r['kind'] ?? '').toString();
    final bath = bathRaw is num ? bathRaw.toInt() : 0;
    return Listing(
      id: r['id'].toString(),
      title: (r['title'] ?? '').toString(),
      area: locality.isEmpty ? city : '$locality, $city',
      city: city,
      type: (r['room_type'] ?? 'Room').toString(),
      kind: kindRaw.isEmpty ? 'रूम' : kindRaw,
      rooms: roomsRaw is num ? roomsRaw.toInt() : 1,
      price: rent is num ? rent.toInt() : 0,
      typeLabel: 'Room',
      bathLabel: bath > 0 ? '$bath Bathroom' : '',
      sqft: sqftRaw is num ? sqftRaw.toInt() : 0,
      floor: (r['floor_label'] ?? '').toString(),
      desc: (r['description'] ?? '').toString(),
      amenities: am,
      image: 'assets/room1.jpg',
      photos: urls.isEmpty ? 1 : urls.length,
      verified: r['verified'] == true,
      directOwner: r['direct_owner'] == true,
      safeWomen: r['safe_women'] == true,
      girlsOnly: r['girls_only'] == true,
      immediate: r['immediate'] == true,
      commercial: r['commercial'] == true,
      order: index,
      lat: latRaw is num ? latRaw.toDouble() : null,
      lng: lngRaw is num ? lngRaw.toDouble() : null,
      locality: locality,
      ownerId: (r['owner_id'] ?? '').toString(),
      status: (r['status'] ?? '').toString(),
      isAvailable: r['is_available'] == true,
      photoUrls: urls,
    );
  }

  /// चुनी हुई भाषा में टाइटल (English न हो तो मूल टाइटल)
  String get title => (AppLang.isHindi || _titleEn.isEmpty) ? _title : _titleEn;

  /// चुनी हुई भाषा में विवरण (English न हो तो मूल विवरण)
  String get desc => (AppLang.isHindi || _descEn.isEmpty) ? _desc : _descEn;

  /// प्रकार का नाम चुनी हुई भाषा में (kind की असली वैल्यू फ़िल्टर के लिए वैसी ही रहती है)
  String get kindLabel {
    switch (kind) {
      case 'फ्लैट':
        return t('फ्लैट', 'Flat');
      case 'रूम':
        return t('रूम', 'Room');
      case 'हॉस्टल':
        return t('हॉस्टल', 'Hostel');
      default:
        return categoryLabel(kind);
    }
  }

  /// क्या इस कमरे की असली मैप लोकेशन सेव है?
  bool get hasLocation => lat != null && lng != null;
}

/// कमरे की मुख्य फोटो: नेटवर्क फोटो हो तो वह, वरना (या न खुले तो) asset फोटो
class ListingImage extends StatelessWidget {
  final Listing listing;
  final BoxFit fit;
  final double? width;
  final double? height;
  const ListingImage({
    super.key,
    required this.listing,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(listing.image,
        fit: fit, width: width, height: height);
    if (listing.photoUrls.isEmpty) return fallback;
    return Image.network(
      listing.photoUrls.first,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

/// नमूना (डेमो) कमरे। इलाकों के नाम सिर्फ उदाहरण हैं।
/// इनमें जानबूझकर lat/lng नहीं डाले गए, क्योंकि नकली लोकेशन नहीं दिखानी।
/// असली लिस्टिंग Supabase जुड़ने के बाद मकान मालिक खुद डालेंगे।
const List<Listing> sampleListings = [
  Listing(
    id: 'n1',
    title: '1BHK रूम (फर्निश्ड)',
    titleEn: '1BHK Room (Furnished)',
    area: 'Rani Tal, Nahan',
    city: 'Nahan',
    type: '1BHK',
    kind: 'फ्लैट',
    rooms: 1,
    price: 6000,
    typeLabel: '1BHK',
    bathLabel: '1 Bathroom',
    sqft: 450,
    floor: '2nd Floor',
    desc: 'पूरी तरह से फर्निश्ड रूम, अलमारी, वाई-फाई, पार्किंग की सुविधा। शांत और सुरक्षित लोकेशन।',
    descEn:
        'Fully furnished room with wardrobe, WiFi and parking. Quiet and safe location.',
    amenities: {'wifi', 'bed', 'wardrobe', 'water', 'parking', 'electricity'},
    image: 'assets/room1.jpg',
    photos: 8,
    verified: true,
    directOwner: true,
    immediate: true,
    order: 4,
    locality: 'Rani Tal',
  ),
  Listing(
    id: 'n2',
    title: 'PG (लड़कों के लिए)',
    titleEn: 'PG (for boys)',
    area: 'Jamta Road, Nahan',
    city: 'Nahan',
    type: 'PG',
    kind: 'PG',
    rooms: 1,
    price: 3500,
    typeLabel: 'Bed (Sharing)',
    bathLabel: '1 Bathroom',
    sqft: 300,
    floor: '1st Floor',
    desc: 'साफ-सुथरा PG, 24x7 पानी, वाई-फाई, खाना-रहना की सुविधा। कॉलेज और ऑफिस के पास।',
    descEn:
        'Clean PG with 24x7 water, WiFi, and food and stay facility. Close to college and offices.',
    amenities: {'wifi', 'bed', 'water', 'food', 'electricity'},
    image: 'assets/room2.jpg',
    photos: 6,
    verified: true,
    immediate: true,
    order: 3,
    locality: 'Jamta Road',
  ),
  Listing(
    id: 'n3',
    title: '1RK रूम (सेमी फर्निश्ड)',
    titleEn: '1RK Room (Semi-furnished)',
    area: 'Sabzi Mandi, Nahan',
    city: 'Nahan',
    type: '1RK',
    kind: 'रूम',
    rooms: 1,
    price: 4500,
    typeLabel: '1RK',
    bathLabel: '1 Bathroom',
    sqft: 250,
    floor: '1st Floor',
    desc: 'सेमी फर्निश्ड रूम, किचन, बाथरूम, बालकनी। बजट फ्रेंडली और अच्छी लोकेशन।',
    descEn:
        'Semi-furnished room with kitchen, bathroom and balcony. Budget friendly with a good location.',
    amenities: {'water', 'electricity', 'balcony'},
    image: 'assets/room1.jpg',
    photos: 5,
    directOwner: true,
    order: 2,
    locality: 'Sabzi Mandi',
  ),
  Listing(
    id: 'p1',
    title: '2BHK फ्लैट (फर्निश्ड)',
    titleEn: '2BHK Flat (Furnished)',
    area: 'Paonta Chowk, Paonta Sahib',
    city: 'Paonta Sahib',
    type: '2BHK',
    kind: 'फ्लैट',
    rooms: 2,
    price: 12000,
    typeLabel: '2BHK',
    bathLabel: '2 Bathroom',
    sqft: 850,
    floor: '3rd Floor',
    desc: 'फुली फर्निश्ड, मॉड्यूलर किचन, AC, सोसायटी में पार्किंग। परिवार के लिए बेहतरीन विकल्प।',
    descEn:
        'Fully furnished, modular kitchen, AC, parking in the society. An excellent choice for families.',
    amenities: {
      'wifi',
      'ac',
      'bed',
      'wardrobe',
      'water',
      'parking',
      'balcony',
      'tv',
      'electricity'
    },
    image: 'assets/room2.jpg',
    photos: 7,
    verified: true,
    safeWomen: true,
    immediate: true,
    order: 1,
    locality: 'Paonta Chowk',
  ),
];

/// Supabase से आए असली (approved + उपलब्ध) कमरे।
/// RLS अपना काम करती है: हम सिर्फ वही माँगते हैं जो सबको दिखना चाहिए।
class ListingsStore extends ChangeNotifier {
  List<Listing> items = <Listing>[];
  bool loading = false;
  bool loaded = false;
  String? error;

  Future<void> load() async {
    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final rows = await Supabase.instance.client
          .from('room_listings')
          .select('id, owner_id, title, description, city, locality, '
              'monthly_rent, photo_urls, amenities, is_available, status, '
              'room_type, kind, rooms, bathrooms, sqft, floor_label, lat, lng, '
              'verified, direct_owner, safe_women, girls_only, immediate, '
              'commercial')
          .eq('status', 'approved')
          .eq('is_available', true);
      final list = <Listing>[];
      var i = 0;
      for (final r in rows) {
        list.add(Listing.fromRow(Map<String, dynamic>.from(r), i));
        i++;
      }
      items = list;
      loaded = true;
    } catch (e) {
      error = t('कमरे लोड नहीं हो सके। इंटरनेट जाँचकर फिर कोशिश करें।',
          'Could not load rooms. Check your internet and try again.');
    }
    loading = false;
    notifyListeners();
  }
}

final ListingsStore listingsStore = ListingsStore();

/// फ़िल्टर वाली स्क्रीन के सभी विकल्प
class Filters {
  int minPrice;
  int maxPrice; // 25000 का मतलब "25,000+" यानी ऊपरी सीमा नहीं
  String locality;
  int distanceKm; // दूरी अभी लागू नहीं होती (लोकेशन जुड़ने पर होगी)
  int rooms; // 0 = कोई भी, 4 = 4+
  String? kind;
  Set<String> amenities;
  bool verifiedOnly;
  bool safeWomen;
  bool directOwner;
  bool girlsOnly;
  bool immediate;
  bool commercial;

  Filters({
    this.minPrice = 1000,
    this.maxPrice = 25000,
    this.locality = '',
    this.distanceKm = 5,
    this.rooms = 0,
    this.kind,
    Set<String>? amenities,
    this.verifiedOnly = false,
    this.safeWomen = false,
    this.directOwner = false,
    this.girlsOnly = false,
    this.immediate = false,
    this.commercial = false,
  }) : amenities = amenities ?? <String>{};

  Filters copy() {
    return Filters(
      minPrice: minPrice,
      maxPrice: maxPrice,
      locality: locality,
      distanceKm: distanceKm,
      rooms: rooms,
      kind: kind,
      amenities: Set<String>.from(amenities),
      verifiedOnly: verifiedOnly,
      safeWomen: safeWomen,
      directOwner: directOwner,
      girlsOnly: girlsOnly,
      immediate: immediate,
      commercial: commercial,
    );
  }

  int get activeCount {
    var n = 0;
    if (minPrice > 1000 || maxPrice < 25000) n++;
    if (locality.trim().isNotEmpty) n++;
    if (rooms != 0) n++;
    if (kind != null) n++;
    n += amenities.length;
    if (verifiedOnly) n++;
    if (safeWomen) n++;
    if (directOwner) n++;
    if (girlsOnly) n++;
    if (immediate) n++;
    if (commercial) n++;
    return n;
  }

  bool get isDefault => activeCount == 0;

  bool matches(Listing l) {
    if (l.price < minPrice) return false;
    if (maxPrice < 25000 && l.price > maxPrice) return false;
    final loc = locality.trim().toLowerCase();
    if (loc.isNotEmpty &&
        !l.area.toLowerCase().contains(loc) &&
        !l.locality.toLowerCase().contains(loc) &&
        !l.address.toLowerCase().contains(loc)) {
      return false;
    }
    if (rooms != 0) {
      if (rooms >= 4) {
        if (l.rooms < 4) return false;
      } else if (l.rooms != rooms) {
        return false;
      }
    }
    if (kind != null && l.kind != kind) return false;
    for (final a in amenities) {
      if (!l.amenities.contains(a)) return false;
    }
    if (verifiedOnly && !l.verified) return false;
    if (safeWomen && !l.safeWomen) return false;
    if (directOwner && !l.directOwner) return false;
    if (girlsOnly && !l.girlsOnly) return false;
    if (immediate && !l.immediate) return false;
    if (commercial && !l.commercial) return false;
    return true;
  }
}

/// पूरे ऐप में साझा जानकारी: चुना हुआ शहर और पसंदीदा कमरे
class AppState extends ChangeNotifier {
  String city = 'Nahan';
  final Set<String> favorites = <String>{};

  void setCity(String c) {
    city = c;
    notifyListeners();
  }

  bool isFav(String id) => favorites.contains(id);

  static final RegExp _uuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

  String? _favUser;

  /// साइन-इन उपयोगकर्ता के असली पसंदीदा सर्वर से लाओ
  Future<void> loadFavorites() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (_favUser != null) {
          favorites.removeWhere(_uuid.hasMatch);
          _favUser = null;
          notifyListeners();
        }
        return;
      }
      final rows = await Supabase.instance.client
          .from('room_favorites')
          .select('listing_id')
          .eq('user_id', user.id);
      favorites.removeWhere(_uuid.hasMatch);
      for (final r in rows) {
        favorites.add(r['listing_id'].toString());
      }
      _favUser = user.id;
      notifyListeners();
    } catch (_) {
      // इंटरनेट न हो तो जो है वही रहने दो
    }
  }

  void toggleFavorite(String id) {
    final added = favorites.add(id);
    if (!added) {
      favorites.remove(id);
    }
    notifyListeners();
    _saveFavorite(id, added);
  }

  Future<void> _saveFavorite(String id, bool added) async {
    if (!_uuid.hasMatch(id)) return; // डेमो कमरे सिर्फ फोन में
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      if (added) {
        await Supabase.instance.client
            .from('room_favorites')
            .upsert({'user_id': user.id, 'listing_id': id},
                ignoreDuplicates: true);
      } else {
        await Supabase.instance.client
            .from('room_favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('listing_id', id);
      }
    } catch (_) {
      // सर्वर में सेव न हो पाया तो पलटो, ताकि दिल सच दिखाए
      if (added) {
        favorites.remove(id);
      } else {
        favorites.add(id);
      }
      notifyListeners();
    }
  }
}

final AppState appState = AppState();

void showMsg(BuildContext context, String text) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(content: Text(text)));
}

/// मालिक को फोन या WhatsApp करना
Future<void> contactOwner(BuildContext context, Listing l,
    {required bool whatsapp}) async {
  final phone = l.phone.isNotEmpty ? l.phone : demoPhone;
  if (phone.length != 10) {
    showMsg(
        context,
        t('यह डेमो कमरा है, इसमें अभी मालिक का नंबर नहीं है। जाँच के लिए data.dart में demoPhone में अपना नंबर डालें।',
            'This is a demo room and has no owner number yet. To test, put your number in demoPhone in data.dart.'));
    return;
  }
  final Uri uri;
  if (whatsapp) {
    final text = Uri.encodeComponent(t(
        'नमस्ते, मैंने RoomMitra पर आपकी लिस्टिंग "${l.title}" देखी है। क्या यह अभी उपलब्ध है?',
        'Hello, I saw your listing "${l.title}" on RoomMitra. Is it still available?'));
    uri = Uri.parse('https://wa.me/91$phone?text=$text');
  } else {
    uri = Uri.parse('tel:+91$phone');
  }
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    showMsg(
        context,
        whatsapp
            ? t('WhatsApp नहीं खुल सका', 'Could not open WhatsApp')
            : t('फोन ऐप नहीं खुल सका', 'Could not open the phone app'));
  }
}

/// Google Maps का रास्ता-लिंक। शुरुआत की जगह Google Maps खुद किरायेदार की
/// मौजूदा लोकेशन से लेता है, हम उसे कहीं सेव या शेयर नहीं करते।
Uri mapsDirectionsUrl(double lat, double lng) {
  return Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
}

/// किसी कमरे तक का रास्ता Google Maps में खोलना
Future<void> openDirections(BuildContext context, Listing l) async {
  if (!l.hasLocation) {
    showMsg(
        context,
        t('इस कमरे की मैप लोकेशन अभी सेव नहीं है',
            "This room's map location is not saved yet"));
    return;
  }
  try {
    final ok = await launchUrl(
      mapsDirectionsUrl(l.lat!, l.lng!),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      showMsg(context, t('Google Maps नहीं खुल सका', 'Could not open Google Maps'));
    }
  } catch (_) {
    if (context.mounted) {
      showMsg(context, t('Google Maps नहीं खुल सका', 'Could not open Google Maps'));
    }
  }
}
