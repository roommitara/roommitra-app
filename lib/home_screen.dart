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
