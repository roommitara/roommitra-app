import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

class Amenity {
  final String id;
  final String label;
  final IconData icon;
  const Amenity(this.id, this.label, this.icon);
}

const List<Amenity> allAmenities = [
  Amenity('wifi', 'WiFi', Icons.wifi),
  Amenity('ac', 'AC', Icons.ac_unit),
  Amenity('bed', 'बेड', Icons.bed),
  Amenity('wardrobe', 'वार्डरोब', Icons.checkroom),
  Amenity('water', 'पानी', Icons.water_drop),
  Amenity('parking', 'पार्किंग', Icons.local_parking),
  Amenity('balcony', 'बालकनी', Icons.balcony),
  Amenity('food', 'खाना', Icons.restaurant),
  Amenity('electricity', 'बिजली', Icons.bolt),
  Amenity('tv', 'TV', Icons.tv),
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
  final String title;
  final String area;
  final String city;
  final String type; // PG, 1RK, 1BHK, 2BHK, 3BHK+
  final String kind; // PG, फ्लैट, रूम, हॉस्टल
  final int rooms;
  final int price;
  final String typeLabel;
  final String bathLabel;
  final int sqft;
  final String floor;
  final String desc;
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

  const Listing({
    required this.id,
    required this.title,
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
    required this.desc,
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
  });

  /// क्या इस कमरे की असली मैप लोकेशन सेव है?
  bool get hasLocation => lat != null && lng != null;
}

/// नमूना (डेमो) कमरे। इलाकों के नाम सिर्फ उदाहरण हैं।
/// इनमें जानबूझकर lat/lng नहीं डाले गए, क्योंकि नकली लोकेशन नहीं दिखानी।
/// असली लिस्टिंग Supabase जुड़ने के बाद मकान मालिक खुद डालेंगे।
const List<Listing> sampleListings = [
  Listing(
    id: 'n1',
    title: '1BHK रूम (फर्निश्ड)',
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

  void toggleFavorite(String id) {
    if (!favorites.add(id)) {
      favorites.remove(id);
    }
    notifyListeners();
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
    showMsg(context,
        'यह डेमो कमरा है, इसमें अभी मालिक का नंबर नहीं है। जाँच के लिए data.dart में demoPhone में अपना नंबर डालें।');
    return;
  }
  final Uri uri;
  if (whatsapp) {
    final text = Uri.encodeComponent(
        'नमस्ते, मैंने RoomMitra पर आपकी लिस्टिंग "${l.title}" देखी है। क्या यह अभी उपलब्ध है?');
    uri = Uri.parse('https://wa.me/91$phone?text=$text');
  } else {
    uri = Uri.parse('tel:+91$phone');
  }
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    showMsg(context, whatsapp ? 'WhatsApp नहीं खुल सका' : 'फोन ऐप नहीं खुल सका');
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
    showMsg(context, 'इस कमरे की मैप लोकेशन अभी सेव नहीं है');
    return;
  }
  try {
    final ok = await launchUrl(
      mapsDirectionsUrl(l.lat!, l.lng!),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      showMsg(context, 'Google Maps नहीं खुल सका');
    }
  } catch (_) {
    if (context.mounted) showMsg(context, 'Google Maps नहीं खुल सका');
  }
}
