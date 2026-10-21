import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'detail_screen.dart';
import 'location_service.dart';
import 'nearby_rooms.dart';
import 'strings.dart';
import 'theme.dart';

class RoomItem {
  final String title;
  final String area;
  final int price;
  final int rooms;
  final String bath;
  final String tag;
  final String image;
  const RoomItem(this.title, this.area, this.price, this.rooms, this.bath,
      this.tag, this.image);
}

const List<RoomItem> featuredRooms = [
  RoomItem('1 RK Room for Rent', 'Nahan, Sirmour', 4500, 1, 'साझा बाथरूम',
      'छात्रों के लिए बेहतर', 'assets/room1.jpg'),
  RoomItem('PG Room (Boys)', 'Nahan, Sirmour', 3500, 1, 'साझा बाथरूम',
      'Food Included', 'assets/room2.jpg'),
];

String formatPrice(int p) {
  final s = p.toString();
  if (s.length > 3) {
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }
  return s;
}

class RoomMitraLogo extends StatelessWidget {
  /// dark = true: हल्के बैकग्राउंड (होम स्क्रीन) के लिए गहरे रंग के अक्षर
  final bool dark;
  const RoomMitraLogo({super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/logo.png',
            width: 52,
            height: 52,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                      text: 'Room',
                      style: TextStyle(
                          color: dark ? AppColors.primaryDark : Colors.white)),
                  TextSpan(
                      text: 'Mitra',
                      style: TextStyle(
                          color: dark ? AppColors.primary : AppColors.accent)),
                ],
              ),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            // यह टैगलाइन हर भाषा में हिंदी ही रहती है
            Text(
              'कमरा ढूँढना हुआ आसान।',
              style: TextStyle(
                  color: dark ? AppColors.text : Colors.white, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _City {
  final String name;
  final IconData icon;
  final Color c1;
  final Color c2;
  final String image;
  const _City(this.name, this.icon, this.c1, this.c2, this.image);
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onListTap;
  final VoidCallback onSearchTap;
  final VoidCallback? onProfileTap;
  const HomeScreen({
    super.key,
    required this.onListTap,
    required this.onSearchTap,
    this.onProfileTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerPc = PageController();
  int _bannerI = 0;

  @override
  void dispose() {
    _bannerPc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    appState.loadFavorites();
    if (!listingsStore.loaded) {
      listingsStore.load();
    }
    // ऐप खुलते ही लोकेशन की इजाज़त माँगो (सिर्फ पहली बार) और नज़दीकी कमरे निकालो
    if (NearbyService.instance.status == NearbyStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NearbyService.instance.refresh(ask: true);
      });
    }
  }

  static const List<_City> _cities = [
    _City('Nahan', Icons.location_city, Color(0xFF7FB0DC), Color(0xFF9CC6A0),
        'assets/city_nahan.jpg'),
    _City('Paonta Sahib', Icons.account_balance, Color(0xFFC9A57C),
        Color(0xFF8FB7D9), 'assets/city_paonta.jpg'),
    _City('Solan', Icons.landscape, Color(0xFF9CC6A0), Color(0xFF5E9B78),
        'assets/city_solan.jpg'),
    _City('Shimla', Icons.terrain, Color(0xFF8FB7D9), Color(0xFF5B8DB8),
        'assets/city_shimla.jpg'),
  ];

  Widget _header(double top) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16, top + 12, 16, 12),
      child: Row(
        children: [
          const Flexible(child: RoomMitraLogo(dark: true)),
          const SizedBox(width: 8),
          const Spacer(),
          GestureDetector(
            onTap: AppLang.toggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.tint,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language,
                      size: 20, color: AppColors.primaryDark),
                  const SizedBox(width: 6),
                  Text(
                    AppLang.isHindi ? 'English' : 'हिंदी',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          PopupMenuButton<String>(
            tooltip: t('शहर चुनें', 'Choose city'),
            onSelected: appState.setCity,
            itemBuilder: (_) => _cities
                .map((c) => PopupMenuItem(
                    value: c.name,
                    child: Row(
                      children: [
                        Icon(
                            c.name == appState.city
                                ? Icons.check_circle
                                : Icons.location_on_outlined,
                            size: 20,
                            color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(AppLang.isHindi
                            ? (cityHindi[c.name] ?? c.name)
                            : c.name),
                      ],
                    )))
                .toList(),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryDark, width: 2),
              ),
              child: Icon(Icons.location_on,
                  color: AppColors.primaryDark, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return GestureDetector(
      onTap: widget.onSearchTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.primaryDark, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t('कमरा, PG, फ्लैट, दुकान खोजें...',
                    'Search for rooms, PG, flats, shops...'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.muted, fontSize: 15),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.tune,
                  size: 22, color: AppColors.primaryDark),
            ),
          ],
        ),
      ),
    );
  }

  void _openWith(Filters f) {
    searchPreset.value = f;
    widget.onSearchTap();
  }

  Widget _tile(IconData icon, Color bg, Color fg, String label, String kind) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _openWith(Filters(kind: kind)),
        child: Container(
          height: 92,
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: fg),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 11.5,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderCard(IconData icon, Color bg, Color fg, String title,
      String sub, Filters preset) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _openWith(preset),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text)),
                    Text(sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11.5, color: AppColors.muted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: fg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryTiles() {
    return Column(
      children: [
        Row(
          children: [
            _tile(Icons.single_bed, const Color(0xFFE3F3EA),
                const Color(0xFF1B7A43), t('सिंगल\nरूम', 'Single\nRoom'),
                'single_room'),
            const SizedBox(width: 8),
            _tile(Icons.king_bed, const Color(0xFFE3F0FD),
                const Color(0xFF1F5FA8), t('डबल\nरूम', 'Double\nRoom'),
                'double_room'),
            const SizedBox(width: 8),
            _tile(Icons.apartment, const Color(0xFFFFF0E0),
                const Color(0xFFE67E22), t('PG /\nहॉस्टल', 'PG /\nHostel'),
                'pg_hostel'),
            const SizedBox(width: 8),
            _tile(Icons.home_rounded, const Color(0xFFEDE8FB),
                const Color(0xFF5B3FA8), t('फ्लैट', 'Flat'),
                'flat'),
            const SizedBox(width: 8),
            _tile(Icons.storefront, const Color(0xFFFCE8F6),
                const Color(0xFFD6336C), t('दुकान', 'Shop'),
                'shop'),
            const SizedBox(width: 8),
            _tile(Icons.people, const Color(0xFFE0F5F3),
                const Color(0xFF1E8E86), t('शेयरिंग', 'Sharing'),
                'sharing'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _genderCard(Icons.female, const Color(0xFFFCEFF8),
                const Color(0xFFD6336C), t('लड़कियाँ', 'Girls'),
                t('सिर्फ लड़कियों के लिए', 'Only for Female'),
                Filters(girlsOnly: true)),
            const SizedBox(width: 10),
            _genderCard(Icons.male, const Color(0xFFEAF3FD),
                const Color(0xFF1F5FA8), t('लड़के', 'Boys'),
                t('सिर्फ लड़कों के लिए', 'Only for Male'),
                Filters(boysOnly: true)),
          ],
        ),
      ],
    );
  }

  Widget _bannerCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView(
            controller: _bannerPc,
            onPageChanged: (i) => setState(() => _bannerI = i),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _findSlide(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _addPropertySlide(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _noBrokerSlide(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final on = i == _bannerI;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: on ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: on ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  static const Color _lime = Color(0xFF7BF03A);

  Widget _feature(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _lime, width: 1.4),
            ),
            child: Icon(icon, size: 16, color: _lime),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  /// तीनों स्लाइड का एक जैसा डिज़ाइन: गहरा हरा बैकग्राउंड, दाईं तरफ फोटो
  Widget _slide({
    required String line1,
    required String line2,
    String? accent,
    Widget? middle,
    required String btn,
    required VoidCallback onTap,
    required String image,
    bool solidButton = false,
  }) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF062F1E), Color(0xFF0B4A2C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 200,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
                stops: [0.0, 0.6],
              ).createShader(rect),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.home_rounded, color: _lime, size: 34),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '$line1\n'),
                            TextSpan(
                                text: line2,
                                style: const TextStyle(color: Colors.white)),
                            if (accent != null)
                              TextSpan(
                                  text: ' $accent',
                                  style: const TextStyle(color: _lime)),
                          ],
                        ),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            height: 1.15,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                if (middle != null) middle,
                Align(
                  alignment: Alignment.centerLeft,
                  child: solidButton
                      ? ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _lime,
                            foregroundColor: const Color(0xFF063D24),
                            elevation: 3,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(btn,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14)),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        )
                      : OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0x33000000),
                            side: const BorderSide(color: _lime, width: 1.6),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(btn,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14)),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _findSlide() {
    final city = AppLang.isHindi
        ? (cityHindi[appState.city] ?? appState.city)
        : appState.city;
    return _slide(
      line1: t('अपना परफेक्ट', 'Find Your Perfect'),
      line2: t('कमरा खोजें', 'Room in'),
      accent: city,
      middle: Row(
        children: [
          _feature(Icons.verified_user_outlined,
              t('सुरक्षित\nलिस्टिंग', 'Safe\nListings')),
          _feature(Icons.verified_outlined,
              t('जाँचे हुए\nमालिक', 'Verified\nOwners')),
          _feature(Icons.bolt, t('सीधा\nसंपर्क', 'Quick\nConnect')),
        ],
      ),
      btn: t('कमरे देखें', 'Explore Rooms'),
      onTap: widget.onSearchTap,
      image: 'assets/room1.jpg',
    );
  }

  Widget _addPropertySlide() {
    return _slide(
      line1: t('अपनी प्रॉपर्टी', 'Add Your'),
      line2: t('जोड़ें', 'Property'),
      accent: t('फ्री में', 'for free'),
      middle: Text(
        t('मकान मालिक हैं? कमरा लिस्ट करें और\nसीधे किरायेदार पाएं',
            'House owner? List your room and\nfind tenants directly'),
        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
      ),
      btn: t('प्रॉपर्टी जोड़ें', 'Add Property'),
      onTap: widget.onListTap,
      image: 'assets/banner_house.jpg',
      solidButton: true,
    );
  }

  Widget _noBrokerSlide() {
    return _slide(
      line1: t('कोई दलाल नहीं,', 'No Broker,'),
      line2: t('कोई', 'No'),
      accent: t('कमीशन', 'Commission'),
      middle: Text(
        t('कॉल या WhatsApp से सीधे मकान मालिक\nसे बात करें',
            'Talk directly to owners by call\nor WhatsApp'),
        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
      ),
      btn: t('कमरे देखें', 'See Rooms'),
      onTap: widget.onSearchTap,
      image: 'assets/room2.jpg',
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark),
          ),
        ),
        InkWell(
          onTap: widget.onSearchTap,
          child: Row(
            children: [
              Text(
                t('सभी देखें', 'See all'),
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward,
                  size: 16, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.muted),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(fontSize: 12, color: AppColors.muted)),
      ],
    );
  }

  String _tagFor(Listing l) {
    if (l.verified) return t('सत्यापित', 'Verified');
    if (l.immediate) return t('तुरंत उपलब्ध', 'Available now');
    if (l.directOwner) return t('मालिक से सीधे', 'Direct from owner');
    return l.kindLabel;
  }

  void _openDetail(Listing l) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(listing: l),
      ),
    );
  }

  Widget _roomCard(Listing l, double w) {
    final fav = appState.isFav(l.id);
    return GestureDetector(
      onTap: () => _openDetail(l),
      child: Container(
        width: w,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ListingImage(
                  listing: l,
                  height: 112,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (l.verified) ...[
                          const Icon(Icons.verified,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          _tagFor(l),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: () => appState.toggleFavorite(l.id),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        fav ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: fav ? const Color(0xFFE53935) : AppColors.text,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '₹${inr(l.price)} ${t('/माह', '/month')}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 15, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          l.area,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13, color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      ...allAmenities
                          .where((a) => l.amenities.contains(a.id))
                          .take(3)
                          .map((a) => _stat(a.icon, a.label)),
                      if (l.amenities.isEmpty)
                        _stat(Icons.bed_outlined, '${l.rooms} Room'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tintLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _roomGrid(double w) {
    // पहली बार लोड हो रहा है
    if (!listingsStore.loaded && listingsStore.error == null) {
      return const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    // लोड नहीं हो सका
    if (!listingsStore.loaded && listingsStore.error != null) {
      return _infoBox(
        Column(
          children: [
            Icon(Icons.wifi_off, size: 40, color: AppColors.muted),
            const SizedBox(height: 8),
            Text(
              listingsStore.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: listingsStore.loading ? null : listingsStore.load,
              child: Text(t('फिर कोशिश करें', 'Try again')),
            ),
          ],
        ),
      );
    }
    final rooms = listingsStore.items
        .where((l) =>
            l.city == appState.city &&
            l.status == 'approved' &&
            l.isAvailable)
        .take(6)
        .toList();
    if (rooms.isEmpty) {
      return _infoBox(
        Column(
          children: [
            Icon(Icons.search_off, size: 40, color: AppColors.muted),
            const SizedBox(height: 8),
            Text(
              t('इस शहर में अभी कोई कमरा नहीं है',
                  'There are no rooms in this city yet'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted),
            ),
          ],
        ),
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 14,
      children: rooms.map((l) => _roomCard(l, w)).toList(),
    );
  }

  Widget _cityRow() {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _cities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final c = _cities[i];
          final sel = c.name == appState.city;
          return GestureDetector(
            onTap: () => appState.setCity(c.name),
            child: SizedBox(
              width: 112,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 72,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                      gradient: LinearGradient(
                        colors: [c.c1, c.c2],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        c.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) =>
                            Icon(c.icon, size: 36, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final cardW = (MediaQuery.of(context).size.width - 32 - 12) / 2;
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, lang, _) {
        return ListenableBuilder(
          listenable: Listenable.merge([appState, listingsStore]),
          builder: (context, _) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: (AppTheme.isDark
                      ? SystemUiOverlayStyle.light
                      : SystemUiOverlayStyle.dark)
                  .copyWith(
                statusBarColor: Colors.transparent,
              ),
              child: Scaffold(
                backgroundColor: AppColors.bg,
                body: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  child: Container(
                    color: AppColors.surface,
                    child: Column(
                      children: [
                        _header(top),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                          color: AppColors.surface,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _searchBar(),
                              const SizedBox(height: 18),
                              _categoryTiles(),
                              const SizedBox(height: 18),
                              _bannerCarousel(),
                              const SizedBox(height: 22),
                              NearbyRooms(onSeeAll: widget.onSearchTap),
                              const SizedBox(height: 12),
                              _sectionHeader(
                                  t('हाल की लिस्टिंग', 'Recent Listings')),
                              const SizedBox(height: 12),
                              _roomGrid(cardW),
                              const SizedBox(height: 24),
                              _sectionHeader(
                                  t('लोकप्रिय शहर', 'Popular cities')),
                              const SizedBox(height: 12),
                              _cityRow(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
