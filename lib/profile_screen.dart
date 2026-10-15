import 'package:flutter/material.dart';
import 'data.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'messages_screen.dart';
import 'my_listings_screen.dart';
import 'theme.dart';

class _MenuItem {
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.title, this.sub, this.onTap);
}

class ProfileScreen extends StatelessWidget {
  /// मेरी लिस्टिंग से "नई लिस्टिंग जोड़ें" दबाने पर चलेगा
  final VoidCallback onAdd;
  const ProfileScreen({super.key, required this.onAdd});

  Widget _topBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding:
          EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 12),
      child: const Row(
        children: [
          RoomMitraLogo(),
          Spacer(),
          Icon(Icons.settings, color: Colors.white, size: 26),
        ],
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'डेमो उपयोगकर्ता',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.verified, color: AppColors.primary, size: 20),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text('+91 98765 43210',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.text)),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.email, size: 16, color: AppColors.primary),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text('demo@example.com',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: 13, color: AppColors.text)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    Widget cell(IconData icon, String k, String v) {
      return Expanded(
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(k,
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            const SizedBox(height: 2),
            Text(
              v,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'मेरी जानकारी',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              cell(Icons.person, 'पूरा नाम', 'डेमो उपयोगकर्ता'),
              cell(Icons.phone, 'मोबाइल', '98765 43210'),
              cell(Icons.location_on, 'शहर', cityHindi[appState.city] ?? ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuRow(_MenuItem m, {bool last = false}) {
    return InkWell(
      onTap: m.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.tint,
                shape: BoxShape.circle,
              ),
              child: Icon(m.icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.title,
                    style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    m.sub,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.text),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('लॉगआउट'),
        content: const Text(
          'यह अभी डेमो है। असली लॉगिन और लॉगआउट Supabase जुड़ने पर काम करेगा।',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ठीक है'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItem>[
      _MenuItem(
        Icons.home_work,
        'मेरी लिस्टिंग',
        'मालिक डैशबोर्ड: बदलें, हटाएं, सक्रिय/निष्क्रिय करें',
        () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MyListingsScreen(onAdd: onAdd),
            ),
          );
        },
      ),
      _MenuItem(
        Icons.chat_bubble,
        'मेरे संदेश',
        'मकान मालिकों और किरायेदारों से चैट',
        () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const MessagesScreen(),
            ),
          );
        },
      ),
      _MenuItem(
        Icons.manage_accounts,
        'प्रोफाइल अपडेट करें',
        'अपनी जानकारी और फोटो अपडेट करें',
        () => showMsg(context, 'प्रोफाइल अपडेट Supabase जुड़ने पर आएगा'),
      ),
      _MenuItem(
        Icons.shield,
        'सुरक्षा और गोपनीयता',
        'लॉगिन और डेटा सुरक्षा सेटिंग्स',
        () => showMsg(context, 'यह हिस्सा बाद में जुड़ेगा'),
      ),
      _MenuItem(
        Icons.notifications,
        'नोटिफिकेशन सेटिंग',
        'मैसेज, नए कमरे के नोटिफिकेशन',
        () => showMsg(context, 'यह हिस्सा बाद में जुड़ेगा'),
      ),
      _MenuItem(
        Icons.help,
        'सहायता और सपोर्ट',
        'FAQ, हेल्प सेंटर और संपर्क करें',
        () => showMsg(context, 'यह हिस्सा बाद में जुड़ेगा'),
      ),
      _MenuItem(
        Icons.description,
        'नियम और शर्तें',
        'ऐप की शर्तें और गोपनीयता नीति',
        () => showMsg(context, 'यह हिस्सा बाद में जुड़ेगा'),
      ),
      _MenuItem(
        Icons.logout,
        'लॉगआउट',
        'अपने खाते से बाहर जाएँ',
        () => _logout(context),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF9),
      body: Column(
        children: [
          _topBar(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              children: [
                _headerCard(),
                const SizedBox(height: 12),
                _infoCard(),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        _menuRow(items[i], last: i == items.length - 1),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.tint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.favorite,
                          color: AppColors.primary, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'RoomMitra का उपयोग करने के लिए धन्यवाद!',
                          style: TextStyle(
                              fontSize: 12.5, color: AppColors.text),
                        ),
                      ),
                      Text('v1.0.0',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
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
}
