import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

class RoomItem {
  final String title;
  final String area;
  final int price;
  final int rooms;
  final String bath;
  final String tag;
  const RoomItem(
      this.title, this.area, this.price, this.rooms, this.bath, this.tag);
}

const List<RoomItem> featuredRooms = [
  RoomItem('1 RK Room for Rent', 'Kothrud, Pune', 7500, 1, 'साझा बाथरूम',
      'छात्रों के लिए बेहतर'),
  RoomItem('PG Room (Boys)', 'Hadapsar, Pune', 5500, 1, 'साझा बाथरूम',
      'Food Included'),
  RoomItem('Single Room (With AC)', 'Viman Nagar, Pune', 7000, 1,
      'अटैच बाथरूम', 'AC Room'),
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
        const SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.home_outlined, color: Colors.white, size: 48),
              Positioned(
                bottom: 4,
                child: Icon(Icons.eco, color: AppColors.accent, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
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
  String _city = 'Pune';
  final Set<String> _fav = {};

  static const List<_Cat> _cats = [
    _Cat(Icons.home_rounded, 'सभी प्रकार'),
    _Cat(Icons.bed, 'PG / हॉस्टल'),
    _Cat(Icons.apartment, 'फ्लैट'),
    _Cat(Icons.meeting_room, 'रूम / शेयरिंग'),
  ];

  static const List<_City> _cities = [
    _City('Pune', Icons.fort, Color(0xFF8FB7D9), Color(0xFFC9A57C)),
    _City('Mumbai', Icons.account_balance, Color(0xFF9DBFD8), Color(0xFFB9A58C)),
    _City('Bangalore', Icons.location_city, Color(0xFF7FB0DC), Color(0xFF9CC6A0)),
    _City('Delhi', Icons.museum, Color(0xFFF2B27A), Color(0xFFE08E5A)),
  ];

  Widget _header(double top) {
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
      padding: EdgeInsets.fromLTRB(20, top + 14, 20, 30),
      child: Stack(
        children: [
          const Positioned(
            right: 40,
            top: 0,
            child: Icon(Icons.cottage, size: 90, color: Color(0x1AFFFFFF)),
          ),
          Row(
            children: [
              const RoomMitraLogo(),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('नोटिफिकेशन स्क्रीन अगले चरणों में जुड़ेगी'),
                    ),
                  );
                },
                child: const Icon(Icons.notifications_none,
                    color: Colors.white, size: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cityChip() {
    return PopupMenuButton<String>(
      onSelected: (c) => setState(() => _city = c),
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
              _city,
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
        child: const Row(
          children: [
            Icon(Icons.search, color: AppColors.primary, size: 26),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'किराए का कमरा, PG, फ्लैट खोजें...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.muted, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categories() {
    return Row(
      children: List.generate(_cats.length, (i) {
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
                    _cats[i].icon,
                    size: 32,
                    color: sel ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _cats[i].label,
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
                    const Row(
                      children: [
                        Icon(Icons.home_outlined,
                            color: AppColors.accent, size: 30),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'मकान मालिक हैं?',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'अपनी प्रॉपर्टी लिस्ट करें और\nसीधे किरायेदार पाएं',
                      style: TextStyle(color: Colors.white, fontSize: 13),
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('अब लिस्ट करें',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 13)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
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
          child: const Row(
            children: [
              Text(
                'सभी देखें',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
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

  Widget _roomCard(RoomItem r, double w) {
    final key = r.title + r.area;
    final fav = _fav.contains(key);
    return Container(
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
              Container(
                height: 112,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE9D9BE), Color(0xFFCFE3D6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.bed_rounded,
                    size: 54, color: Color(0xFF8FB39C)),
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
                    '₹${formatPrice(r.price)}/माह',
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
                  onTap: () {
                    setState(() {
                      if (fav) {
                        _fav.remove(key);
                      } else {
                        _fav.add(key);
                      }
                    });
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0x66FFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      fav ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: fav ? AppColors.danger : Colors.white,
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
                  r.title,
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
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: AppColors.muted),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        r.area,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
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
                    _stat(Icons.bed_outlined, '${r.rooms} Room'),
                    _stat(Icons.bathtub_outlined, r.bath),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.tint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    r.tag,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomRow(double w) {
    return SizedBox(
      height: 272,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 6),
        clipBehavior: Clip.none,
        itemCount: featuredRooms.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _roomCard(featuredRooms[i], w),
      ),
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
          final sel = c.name == _city;
          return GestureDetector(
            onTap: () => setState(() => _city = c.name),
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
                      Text(
                        c.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text),
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            color: AppColors.primaryDark,
            child: Column(
              children: [
                _header(top),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(26)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _cityChip(),
                          const Spacer(),
                          GestureDetector(
                            onTap: widget.onSearchTap,
                            child: const Icon(Icons.tune,
                                size: 30, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _searchBar(),
                      const SizedBox(height: 20),
                      _categories(),
                      const SizedBox(height: 20),
                      _banner(),
                      const SizedBox(height: 22),
                      _sectionHeader('Featured Rooms'),
                      const SizedBox(height: 8),
                      _roomRow(cardW),
                      const SizedBox(height: 14),
                      _sectionHeader('लोकप्रिय शहर'),
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
  }
}
