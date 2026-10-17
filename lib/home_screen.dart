import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'detail_screen.dart';
import 'messages_screen.dart';
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
  const RoomMitraLogo({super.key});

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
              const TextSpan(
                children: [
                  TextSpan(text: 'Room', style: TextStyle(color: Colors.white)),
                  TextSpan(
                      text: 'Mitra', style: TextStyle(color: AppColors.accent)),
                ],
              ),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            // यह टैगलाइन हर भाषा में हिंदी ही रहती है
            const Text(
              'कमरा ढूँढना हुआ आसान।',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _Cat {
  final IconData icon;
  final String label;
  const _Cat(this.icon, this.label);
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
  int _cat = 0;

  List<_Cat> get _cats => [
        _Cat(Icons.home_rounded, t('सभी प्रकार', 'All types')),
        _Cat(Icons.bed, t('PG / हॉस्टल', 'PG / Hostel')),
        _Cat(Icons.apartment, t('फ्लैट', 'Flat')),
        _Cat(Icons.meeting_room, t('रूम / शेयरिंग', 'Room / Sharing')),
      ];

  static const List<_City> _cities = [
    _City('Nahan', Icons.location_city, Color(0xFF7FB0DC), Color(0xFF9CC6A0)),
    _City('Paonta Sahib', Icons.account_balance, Color(0xFFC9A57C),
        Color(0xFF8FB7D9)),
    _City('Rajgarh', Icons.landscape, Color(0xFF9CC6A0), Color(0xFF5E9B78)),
    _City('Kala Amb', Icons.factory, Color(0xFFF2B27A), Color(0xFFE08E5A)),
  ];

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
                  color: Colors.white, size: 28),
              if (unread > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _header(double top) {
    final w = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
              child: Image.asset('assets/header_bg.jpg', fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 14, 20, 30),
            child: Row(
              children: [
                const RoomMitraLogo(),
                const Spacer(),
                _messageIcon(),
                const SizedBox(width: 16),
                GestureDetector(
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
                          color: Colors.white, size: 30),
                      if (demoNotifications.any((n) => n.unread))
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53935),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${demoNotifications.where((n) => n.unread).length}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
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

  Widget _cityChip() {
    return PopupMenuButton<String>(
      onSelected: appState.setCity,
      itemBuilder: (_) => _cities
          .map((c) => PopupMenuItem(value: c.name, child: Text(c.name)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.tint,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              appState.city,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return GestureDetector(
      onTap: widget.onSearchTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border, width: 1.4),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.primary, size: 26),
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
          ],
        ),
      ),
    );
  }

  Widget _categories() {
    final cats = _cats;
    return Row(
      children: List.generate(cats.length, (i) {
        final sel = i == _cat;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _cat = i),
            child: Column(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.tint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cats[i].icon,
                    size: 32,
                    color: sel ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cats[i].label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _banner() {
    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF083F28), Color(0xFF1E6B3F)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 0,
            top: 0,
            child: Icon(Icons.home, size: 90, color: Color(0x22FFFFFF)),
          ),
          Row(
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
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13),
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
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                color: AppColors.text),
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
    return l.kind;
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
                Image.asset(
                  l.image,
                  height: 112,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹${inr(l.price)}${t('/माह', '/month')}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
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
