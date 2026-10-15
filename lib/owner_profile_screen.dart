import 'package:flutter/material.dart';
import 'data.dart';
import 'detail_screen.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'messages_screen.dart';
import 'report_screen.dart';
import 'theme.dart';

/// डेमो: मकान मालिक की जानकारी (असली डेटा Supabase जुड़ने पर आएगा)
class OwnerInfo {
  final String name;
  final List<String> listingIds;
  final double rating;
  final int ratingCount;
  final int tenants;
  final int years;
  final bool verified;
  final String about;
  const OwnerInfo({
    required this.name,
    required this.listingIds,
    required this.rating,
    required this.ratingCount,
    required this.tenants,
    required this.years,
    required this.verified,
    required this.about,
  });
}

const List<OwnerInfo> demoOwners = [
  OwnerInfo(
    name: 'राजेश तिवारी',
    listingIds: ['n1', 'n3'],
    rating: 4.5,
    ratingCount: 18,
    tenants: 18,
    years: 3,
    verified: true,
    about:
        'नमस्कार! मैं राजेश तिवारी हूँ। मैं नाहन में किराये के कमरे उपलब्ध कराता हूँ। साफ-सुथरे, सुरक्षित और आरामदायक कमरे मेरी प्राथमिकता है। छात्रों और कामकाजी लोगों के लिए बेहतर विकल्प उपलब्ध हैं। किराया और डिपॉजिट मैं सीधे किरायेदार से ही तय करता हूँ।',
  ),
  OwnerInfo(
    name: 'सुनील ठाकुर',
    listingIds: ['n2'],
    rating: 4.2,
    ratingCount: 9,
    tenants: 11,
    years: 2,
    verified: true,
    about:
        'नमस्ते! मैं सुनील ठाकुर हूँ। नाहन में लड़कों के लिए PG चलाता हूँ। खाना-रहना और साफ-सफाई का पूरा ध्यान रखा जाता है। कॉलेज और ऑफिस के पास होने से पढ़ने और काम करने वालों के लिए सुविधाजनक है।',
  ),
  OwnerInfo(
    name: 'रोहित शर्मा',
    listingIds: ['p1'],
    rating: 4.8,
    ratingCount: 28,
    tenants: 24,
    years: 2,
    verified: true,
    about:
        'नमस्कार! मैं रोहित शर्मा हूँ। पांवटा साहिब में परिवारों के लिए फर्निश्ड फ्लैट किराये पर देता हूँ। शांत और सुरक्षित माहौल मेरी पहचान है।',
  ),
];

/// किसी कमरे के मालिक की जानकारी ढूँढना
OwnerInfo ownerOf(Listing l) {
  for (final o in demoOwners) {
    if (o.listingIds.contains(l.id)) return o;
  }
  return OwnerInfo(
    name: 'मकान मालिक',
    listingIds: [l.id],
    rating: 4.0,
    ratingCount: 1,
    tenants: 1,
    years: 1,
    verified: l.verified,
    about: 'यह मकान मालिक RoomMitra पर नया है।',
  );
}

class OwnerProfileScreen extends StatefulWidget {
  /// जिस कमरे की डिटेल से यहाँ आए हैं (कॉल और रिपोर्ट इसी के लिए होंगे)
  final Listing listing;
  const OwnerProfileScreen({super.key, required this.listing});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  bool _aboutOpen = false;

  Listing get l => widget.listing;
  late final OwnerInfo o = ownerOf(widget.listing);

  List<Listing> get _ownerListings {
    final list = sampleListings
        .where((x) => o.listingIds.contains(x.id))
        .toList();
    return list.isEmpty ? <Listing>[l] : list;
  }

  Conversation _findOrCreateChat() {
    for (final c in conversations.value) {
      if (c.name == o.name) return c;
    }
    final n = DateTime.now();
    final t =
        '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
    final c = Conversation(
      id: 'owner_${o.name}',
      name: o.name,
      role: 'मकान मालिक',
      listingId: l.id,
      msgs: [
        ChatMsg('नमस्ते! मैं ${o.name} हूँ। बताइए, मैं आपकी क्या मदद कर सकता हूँ?',
            false, t),
      ],
    );
    conversations.value = [...conversations.value, c];
    return c;
  }

  void _message() {
    final c = _findOrCreateChat();
    if (c.status == 'blocked') {
      showMsg(context, 'आपने इस यूज़र को ब्लॉक किया है');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ChatScreen(conv: c)),
    );
  }

  Widget _topBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding:
          EdgeInsets.fromLTRB(4, MediaQuery.of(context).padding.top + 6, 4, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: RoomMitraLogo(),
              ),
            ),
          ),
          IconButton(
            onPressed: () =>
                showMsg(context, 'शेयर करने की सुविधा बाद में जुड़ेगी'),
            icon: const Icon(Icons.share, color: Colors.white),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v == 'report') {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ReportScreen(listing: l),
                  ),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                value: 'report',
                child: Text('रिपोर्ट करें'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 86,
                height: 86,
                child: Stack(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: const BoxDecoration(
                        color: AppColors.tint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person,
                          size: 50, color: AppColors.primary),
                    ),
                    if (o.verified)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.verified,
                              size: 17, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.name,
                      style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            o.verified
                                ? 'मकान मालिक (Verified)'
                                : 'मकान मालिक',
                            style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary),
                          ),
                        ),
                        if (o.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified,
                              size: 16, color: AppColors.primary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${cityHindi[l.city] ?? l.city}, हिमाचल प्रदेश',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.text),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 17, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '${o.rating} (${o.ratingCount} रेटिंग, डेमो)',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.text),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _message,
                    icon: const Icon(Icons.chat, size: 20),
                    label: const Text('संदेश भेजें'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                          color: AppColors.primary, width: 1.2),
                      textStyle: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => contactOwner(context, l, whatsapp: false),
                    icon: const Icon(Icons.call, size: 20),
                    label: const Text('कॉल करें'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCell(IconData icon, String big, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            big,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.text),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _stats() {
    final divider = Container(width: 1, height: 44, color: AppColors.border);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.tintLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _statCell(Icons.home, '${o.listingIds.length}', 'कुल कमरे'),
          divider,
          _statCell(Icons.person, '${o.tenants}', 'कुल किरायेदार'),
          divider,
          _statCell(Icons.calendar_month, '${o.years} साल', 'से RoomMitra पर'),
          divider,
          _statCell(
              Icons.verified, o.verified ? 'हाँ' : 'नहीं', 'एडमिन सत्यापित'),
        ],
      ),
    );
  }

  Widget _aboutBlock() {
    final long = o.about.length > 120;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tintLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_circle, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'मेरे बारे में',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            o.about,
            maxLines: (_aboutOpen || !long) ? null : 3,
            overflow: (_aboutOpen || !long)
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 14, height: 1.5, color: AppColors.text),
          ),
          if (long)
            GestureDetector(
              onTap: () => setState(() => _aboutOpen = !_aboutOpen),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _aboutOpen ? 'कम पढ़ें' : 'और जानें',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                    Icon(
                      _aboutOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _checkChip(String text, bool ok) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ok ? AppColors.tint : const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.remove_circle_outline,
            size: 18,
            color: ok ? AppColors.primary : AppColors.muted,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ok ? AppColors.text : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verification() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tintLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'वेरिफिकेशन',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _checkChip('एडमिन द्वारा सत्यापित', o.verified),
              _checkChip('मोबाइल नंबर', true),
              _checkChip('प्रोफाइल फोटो', false),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Verified बैज एडमिन की जाँच के बाद ही मिलता है।',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
      ],
    );
  }

  Widget _listingCard(Listing x) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => DetailScreen(listing: x)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 92,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(x.image, fit: BoxFit.cover),
                    Positioned(
                      left: 5,
                      bottom: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0x99000000),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '1/${x.photos}',
                          style: const TextStyle(
                              fontSize: 10.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    x.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          x.area,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5, color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '₹${inr(x.price)}/माह',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      _stat(Icons.home_outlined, x.typeLabel),
                      _stat(Icons.square_foot, '${x.sqft} sq ft'),
                      _stat(Icons.apartment, x.floor),
                    ],
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

  Widget _cta() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline,
                color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'क्या आप भी किराये के कमरे की तलाश में हैं?',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
                const SizedBox(height: 2),
                Text(
                  '${o.name} से सीधे संपर्क करें और अपनी ज़रूरत बताएँ।',
                  style: const TextStyle(
                      fontSize: 12, height: 1.3, color: AppColors.text),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _message,
            icon: const Icon(Icons.chat, size: 16),
            label: const Text('संदेश'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _ownerListings;
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF9),
      body: Column(
        children: [
          _topBar(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                  16, 14, 16, 16 + MediaQuery.of(context).padding.bottom),
              children: [
                _header(),
                const SizedBox(height: 12),
                _stats(),
                const SizedBox(height: 12),
                _aboutBlock(),
                const SizedBox(height: 12),
                _verification(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.home, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'इनके द्वारा दिए गए कमरे',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text),
                      ),
                    ),
                    Text(
                      'कुल ${items.length} कमरे',
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...items.map(_listingCard),
                const SizedBox(height: 6),
                _cta(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
