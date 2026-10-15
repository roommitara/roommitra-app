import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'theme.dart';

enum NotifKind { message, room, booking, safety, read, offer, views, update }

class NotifItem {
  final NotifKind kind;
  final String title;
  final String body;
  final String? extra;
  final IconData? extraIcon;
  final String time;
  bool unread;

  NotifItem({
    required this.kind,
    required this.title,
    required this.body,
    this.extra,
    this.extraIcon,
    required this.time,
    this.unread = false,
  });
}

final List<NotifItem> demoNotifications = [
  NotifItem(
    kind: NotifKind.message,
    title: 'नया संदेश',
    body: 'राहुल शर्मा ने आपको संदेश भेजा है: "क्या यह कमरा अभी भी खाली है?"',
    time: '10:24 AM',
    unread: true,
  ),
  NotifItem(
    kind: NotifKind.room,
    title: 'नई लिस्टिंग',
    body: '2BHK फ्लैट (सेमी फर्निश्ड) का नया लिस्टिंग पोस्ट किया गया है।',
    extra: 'चौगान, नाहन',
    extraIcon: Icons.location_on,
    time: '09:12 AM',
    unread: true,
  ),
  NotifItem(
    kind: NotifKind.booking,
    title: 'बुकिंग अनुरोध',
    body: 'अमित यादव ने आपके कमरे को देखने के लिए अनुरोध भेजा है।',
    extra: '16 अक्टूबर 2026, 11:00 AM',
    extraIcon: Icons.event,
    time: '08:45 AM',
    unread: true,
  ),
  NotifItem(
    kind: NotifKind.read,
    title: 'संदेश पढ़ा गया',
    body: 'सीमा पवार ने आपका संदेश पढ़ लिया है।\n"जी हाँ, यह कमरा अभी उपलब्ध है।"',
    time: '07:30 AM',
  ),
  NotifItem(
    kind: NotifKind.safety,
    title: 'सुरक्षा अलर्ट',
    body: 'कृपया ध्यान दें: हाल ही में एक फर्जी लिस्टिंग की रिपोर्ट की गई है। हम इसकी जाँच कर रहे हैं।',
    time: 'कल 07:15 PM',
  ),
  NotifItem(
    kind: NotifKind.offer,
    title: 'स्पेशल ऑफर',
    body: 'आज के लिए खास! अपने कमरे की लिस्टिंग करें और जल्दी किरायेदार पाएं।',
    time: 'कल 12:20 PM',
  ),
  NotifItem(
    kind: NotifKind.views,
    title: 'आपका कमरा देखा गया',
    body: 'आपकी लिस्टिंग 1RK फ्लैट को आज 12 बार देखा गया है।',
    extra: 'व्यू डिटेल देखें',
    time: 'कल 10:05 AM',
  ),
  NotifItem(
    kind: NotifKind.update,
    title: 'ऐप अपडेट',
    body: 'RoomMitra का नया वर्ज़न अब उपलब्ध है। बेहतर अनुभव के लिए अभी अपडेट करें।',
    time: '12 अक्टूबर 2026',
  ),
];

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _tab = 0;

  static const _tabs = ['सभी', 'मैसेज', 'नए कमरे', 'बुकिंग', 'सुरक्षा'];
  static const _tabIcons = [
    Icons.notifications,
    Icons.chat_bubble_outline,
    Icons.home,
    Icons.event,
    Icons.shield,
  ];

  bool _inTab(NotifItem n, int tab) {
    switch (tab) {
      case 1:
        return n.kind == NotifKind.message || n.kind == NotifKind.read;
      case 2:
        return n.kind == NotifKind.room;
      case 3:
        return n.kind == NotifKind.booking;
      case 4:
        return n.kind == NotifKind.safety;
      default:
        return true;
    }
  }

  int _unread(int tab) =>
      demoNotifications.where((n) => n.unread && _inTab(n, tab)).length;

  IconData _icon(NotifKind k) {
    switch (k) {
      case NotifKind.message:
        return Icons.chat_bubble;
      case NotifKind.room:
        return Icons.home;
      case NotifKind.booking:
        return Icons.event;
      case NotifKind.read:
        return Icons.mail;
      case NotifKind.safety:
        return Icons.shield;
      case NotifKind.offer:
        return Icons.percent;
      case NotifKind.views:
        return Icons.visibility;
      case NotifKind.update:
        return Icons.campaign;
    }
  }

  Color _iconBg(NotifKind k) {
    switch (k) {
      case NotifKind.read:
        return const Color(0xFF2F6FE4);
      case NotifKind.safety:
        return const Color(0xFFF2A81D);
      case NotifKind.update:
        return AppColors.tint;
      default:
        return AppColors.primary;
    }
  }

  Color _iconFg(NotifKind k) =>
      k == NotifKind.update ? AppColors.primary : Colors.white;

  void _markAllRead() {
    setState(() {
      for (final n in demoNotifications) {
        n.unread = false;
      }
    });
    showMsg(context, 'सभी नोटिफिकेशन पढ़े हुए हो गए');
  }

  Widget _header(double top) {
    final total = _unread(0);
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(4, top + 8, 8, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const RoomMitraLogo(),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: _markAllRead,
                icon: const Icon(Icons.notifications_none,
                    color: Colors.white, size: 28),
              ),
              if (total > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: Text('$total',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v == 0) {
                _markAllRead();
              } else {
                setState(() => demoNotifications.clear());
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 0, child: Text('सभी को पढ़ा हुआ करें')),
              PopupMenuItem(value: 1, child: Text('सभी नोटिफिकेशन हटाएं')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _titleRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('नोटिफिकेशन',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text)),
                SizedBox(height: 2),
                Text('आपके सभी अपडेट एक ही जगह पर',
                    style: TextStyle(fontSize: 13, color: AppColors.muted)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showMsg(context, 'नोटिफिकेशन सेटिंग जल्द जुड़ेगी'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.tint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings, size: 17, color: AppColors.primary),
                  SizedBox(width: 5),
                  Text('सेटिंग',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text)),
                  Icon(Icons.chevron_right, size: 18, color: AppColors.text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabRow() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final sel = _tab == i;
          final cnt = i == 2 || i == 3 || i == 4 ? 0 : _unread(i);
          return GestureDetector(
            onTap: () => setState(() => _tab = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: sel ? AppColors.primaryDark : AppColors.tint,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: sel ? AppColors.primaryDark : AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(_tabIcons[i],
                      size: 19,
                      color: sel ? Colors.white : AppColors.primary),
                  const SizedBox(width: 7),
                  Text(_tabs[i],
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : AppColors.text)),
                  if (cnt > 0) ...[
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                      child: Text('$cnt',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _card(NotifItem n) {
    return GestureDetector(
      onTap: () {
        setState(() => n.unread = false);
        showMsg(context, '${n.title} — डिटेल अगले चरण में जुड़ेगी');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: n.unread ? AppColors.tint : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _iconBg(n.kind),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon(n.kind), color: _iconFg(n.kind), size: 24),
                ),
                if (n.unread)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(n.title,
                            style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text)),
                      ),
                      Text(n.time,
                          style: const TextStyle(
                              fontSize: 11.5, color: AppColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(n.body,
                      style: const TextStyle(
                          fontSize: 13, height: 1.35, color: AppColors.muted)),
                  if (n.extra != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (n.extraIcon != null) ...[
                          Icon(n.extraIcon, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                        ],
                        Text(n.extra!,
                            style: TextStyle(
                                fontSize: 12.5,
                                color: n.extraIcon == null
                                    ? AppColors.primary
                                    : AppColors.muted,
                                fontWeight: n.extraIcon == null
                                    ? FontWeight.w700
                                    : FontWeight.w400)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 12, left: 4),
              child: Icon(Icons.chevron_right, color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final items = demoNotifications.where((n) => _inTab(n, _tab)).toList();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _header(top),
            _titleRow(),
            _tabRow(),
            const SizedBox(height: 10),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text('कोई नोटिफिकेशन नहीं है',
                          style: TextStyle(
                              fontSize: 15, color: AppColors.muted)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _card(items[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
