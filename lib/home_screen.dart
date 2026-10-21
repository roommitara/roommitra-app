import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'detail_screen.dart';
import 'location_service.dart';
import 'messages_screen.dart';
import 'nearby_rooms.dart';
import 'notifications_screen.dart';
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
  const _City(this.name, this.icon, this.c1, this.c2);
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onListTap;
  final VoidCallback onSearchTap;
  const HomeScreen({
    super.key,
    required this.onListTap,
    required this.onSearchTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _skyBottom = Color(0xFFEAF5EE);

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
    _City('Nahan', Icons.location_city, Color(0xFF7FB0DC), Color(0xFF9CC6A0)),
    _City('Paonta Sahib', Icons.account_balance, Color(0xFFC9A57C),
        Color(0xFF8FB7D9)),
    _City('Rajgarh', Icons.landscape, Color(0xFF9CC6A0), Color(0xFF5E9B78)),
    _City('Kala Amb', Icons.factory, Color(0xFFF2B27A), Color(0xFFE08E5A)),
  ];

  Widget _badge(int count) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Color(0xFFE53935),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _messageIcon() {
    return ListenableBuilder(
      listenable: conversations,
      builder: (context, _) {
        final unread = conversations.value
            .where((c) => c.status == 'inbox')
            .fold<int>(0, (s, c) => s + c.unread);
        return GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MessagesScreen(),
              ),
            );
            if (mounted) setState(() {});
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline,
                  color: AppColors.primaryDark, size: 28),
              if (unread > 0)
                Positioned(right: -6, top: -6, child: _badge(unread)),
            ],
          ),
        );
      },
    );
  }

  Widget _notifIcon() {
    final unread = demoNotifications.where((n) => n.unread).length;
    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const NotificationsScreen(),
          ),
        );
        if (mounted) setState(() {});
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none,
              color: AppColors.primaryDark, size: 30),
          if (unread > 0) Positioned(right: -4, top: -4, child: _badge(unread)),
        ],
      ),
    );
  }

  Widget _cityChip() {
    return PopupMenuButton<String>(
      onSelected: appState.setCity,
      itemBuilder: (_) => _cities
          .map((c) => PopupMenuItem(value: c.name, child: Text(c.name)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xEFFFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 22, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              appState.city,
              style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                size: 22, color: AppColors.primaryDark),
          ],
        ),
      ),
    );
  }

  Widget _header(double top) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCFE6F5), _skyBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: w * 0.62,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
              ).createShader(rect),
              child: Image.asset(
                'assets/header_bg.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 14, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const RoomMitraLogo(dark: true),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 14),
                _cityChip(),
              ],
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.primaryDark, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t('किराए का कमरा, PG, फ्लैट खोजें...',
                    'Search rental room, PG, flat...'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 15),
              ),
            ),
            const Icon(Icons.tune, size: 26, color: AppColors.primaryDark),
          ],
        ),
      ),
    );
  }

  /// बड़ा टाइल (पहली लाइन के 3)
  Widget _bigTile(IconData icon, Color bg, Color fg, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: widget.onSearchTap,
        child: Container(
          height: 104,
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: fg),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: fg),
                    ),
                  ),
                  Icon(Icons.arrow_forward, size: 16, color: fg),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// छोटा टाइल (दूसरी लाइन के 4)
  Widget _smallTile(IconData icon, Color bg, Color fg, String label,
      {String? sub}) {
    return Expanded(
      child: GestureDetector(
        onTap: widget.onSearchTap,
        child: Container(
          height: 104,
          padding: const EdgeInsets.fromLTRB(8, 10, 6, 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 30, color: fg),
              const Spacer(),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w800, color: fg),
              ),
              if (sub != null)
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5, color: fg),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward, size: 14, color: fg),
              ),
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
            _bigTile(Icons.home_rounded, const Color(0xFFE3F3EA),
                const Color(0xFF1B7A43), t('PG / हॉस्टल', 'PG / Hostel')),
            const SizedBox(width: 10),
            _bigTile(Icons.single_bed, const Color(0xFFE3F0FD),
                const Color(0xFF1F5FA8), t('सिंगल रूम', 'Single Room')),
            const SizedBox(width: 10),
            _bigTile(Icons.king_bed, const Color(0xFFFFF0E0),
                const Color(0xFFE67E22), t('डबल रूम', 'Double Room')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _smallTile(Icons.apartment, const Color(0xFFEDE8FB),
                const Color(0xFF5B3FA8), t('फ्लैट', 'Flat')),
            const SizedBox(width: 8),
            _smallTile(Icons.storefront, const Color(0xFFFFF0E0),
                const Color(0xFFE67E22), t('दुकान', 'Shop')),
            const SizedBox(width: 8),
            _smallTile(Icons.people, const Color(0xFFFCE8F6),
                const Color(0xFF8E3A9E), t('शेयरिंग', 'Sharing'),
                sub: t('(लड़का / लड़की)', '(Male / Female)')),
            const SizedBox(width: 8),
            _smallTile(Icons.groups, const Color(0xFFE0F5F3),
                const Color(0xFF1E8E86), t('लड़कियाँ / लड़के', 'Girls / Boys')),
          ],
        ),
      ],
    );
  }

  /// "Find Your Perfect Room in <शहर>" वाला बैनर
  Widget _exploreBanner() {
    final city = AppLang.isHindi
        ? (cityHindi[appState.city] ?? appState.city)
        : appState.city;
    return Container(
      clipBehavior: Clip.hardEdge,
      constraints: const BoxConstraints(minHeight: 150),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5EC), Color(0xFFD3EBDB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 170,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
                stops: [0.0, 0.5],
              ).createShader(rect),
              child: Image.asset(
                'assets/room1.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 120, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.home_rounded,
                        color: AppColors.primary, size: 30),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t('$city में अपना परफेक्ट कमरा खोजें',
                            'Find Your Perfect Room in $city'),
                        style: const TextStyle(
                            fontSize: 18,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  t('सुरक्षित | किफायती | सत्यापित लिस्टिंग',
                      'Safe | Affordable | Verified Listings'),
                  style: const TextStyle(
                      fontSize: 11.5, height: 1.3, color: AppColors.text),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: widget.onSearchTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t('कमरे देखें', 'Explore Rooms'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// मकान मालिक वाला बैनर (पहले जैसा)
  Widget _banner() {
    return Container(
      clipBehavior: Clip.hardEdge,
      constraints: const BoxConstraints(minHeight: 150),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF062F1E), Color(0xFF0B4A2C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 190,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
                stops: [0.0, 0.55],
              ).createShader(rect),
              child: Image.asset(
                'assets/banner_house.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.home_outlined,
                              color: AppColors.accent, size: 30),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              t('मकान मालिक हैं?', 'Are you a house owner?'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t('अपनी प्रॉपर्टी लिस्ट करें और\nसीधे किरायेदार पाएं',
                            'List your property and\nfind tenants directly'),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13, height: 1.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: widget.onListTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7BF03A),
                    foregroundColor: const Color(0xFF063D24),
                    elevation: 3,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t('अब लिस्ट करें', 'List now'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
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
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward,
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
            style: const TextStyle(fontSize: 12, color: AppColors.muted)),
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
          color: Colors.white,
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
                      decoration: const BoxDecoration(
                        color: Color(0x66000000),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        fav ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: fav ? const Color(0xFFFF6B6B) : Colors.white,
                      ),
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
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 15, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          l.area,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${inr(l.price)}',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 3),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          t('/माह', '/month'),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _stat(Icons.bed_outlined, '${l.rooms} Room'),
                      if (l.bathLabel.isNotEmpty)
                        _stat(Icons.bathtub_outlined, l.bathLabel),
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
            const Icon(Icons.wifi_off, size: 40, color: AppColors.muted),
            const SizedBox(height: 8),
            Text(
              listingsStore.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
            const Icon(Icons.search_off, size: 40, color: AppColors.muted),
            const SizedBox(height: 8),
            Text(
              t('इस शहर में अभी कोई कमरा नहीं है',
                  'There are no rooms in this city yet'),
              textAlign: TextAlign.center,
              style: const TextStyle(
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
                    child: Icon(c.icon, size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
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
              value: SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
              ),
              child: Scaffold(
                backgroundColor: Colors.white,
                body: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  child: Container(
                    color: _skyBottom,
                    child: Column(
                      children: [
                        _header(top),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(26)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _searchBar(),
                              const SizedBox(height: 20),
                              _categoryTiles(),
                              const SizedBox(height: 20),
                              _exploreBanner(),
                              const SizedBox(height: 24),
                              const NearbyRooms(),
                              const SizedBox(height: 12),
                              _sectionHeader(t('खास कमरे', 'Featured Rooms')),
                              const SizedBox(height: 12),
                              _roomGrid(cardW),
                              const SizedBox(height: 24),
                              _banner(),
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
