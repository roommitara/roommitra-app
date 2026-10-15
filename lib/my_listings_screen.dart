import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'theme.dart';

/// डेमो: मालिक की अपनी लिस्टिंग (असली डेटा Supabase जुड़ने पर आएगा)
class MyListing {
  final String id;
  String title;
  String area;
  int price;
  String typeLabel;
  int sqft;
  String floor;
  String desc;
  final String image;
  final int photos;
  String status; // active, inactive, pending
  final int views;
  final int inquiries;

  MyListing({
    required this.id,
    required this.title,
    required this.area,
    required this.price,
    required this.typeLabel,
    required this.sqft,
    required this.floor,
    required this.desc,
    required this.image,
    required this.photos,
    required this.status,
    required this.views,
    required this.inquiries,
  });
}

final ValueNotifier<List<MyListing>> myListings =
    ValueNotifier<List<MyListing>>([
  MyListing(
    id: 'm1',
    title: '1BHK रूम (फर्निश्ड)',
    area: 'Rani Tal, Nahan',
    price: 6000,
    typeLabel: '1BHK',
    sqft: 450,
    floor: '2nd Floor',
    desc: 'पूरी तरह से फर्निश्ड रूम, अलमारी, वाई-फाई, पार्किंग की सुविधा। शांत और सुरक्षित लोकेशन।',
    image: 'assets/room1.jpg',
    photos: 8,
    status: 'active',
    views: 24,
    inquiries: 5,
  ),
  MyListing(
    id: 'm2',
    title: 'PG (लड़कों के लिए)',
    area: 'Jamta Road, Nahan',
    price: 3500,
    typeLabel: 'Bed (Sharing)',
    sqft: 300,
    floor: '1st Floor',
    desc: 'साफ-सुथरा PG, 24x7 पानी, वाई-फाई, खाना-रहना की सुविधा। कॉलेज और ऑफिस के पास।',
    image: 'assets/room2.jpg',
    photos: 6,
    status: 'active',
    views: 18,
    inquiries: 2,
  ),
  MyListing(
    id: 'm3',
    title: '1RK रूम (सेमी फर्निश्ड)',
    area: 'Sabzi Mandi, Nahan',
    price: 4500,
    typeLabel: '1RK',
    sqft: 250,
    floor: '1st Floor',
    desc: 'सेमी फर्निश्ड रूम, किचन, बाथरूम, बालकनी। बजट फ्रेंडली और अच्छी लोकेशन।',
    image: 'assets/room1.jpg',
    photos: 5,
    status: 'pending',
    views: 0,
    inquiries: 0,
  ),
]);

void _refresh() {
  myListings.value = List<MyListing>.of(myListings.value);
}

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
        EdgeInsets.fromLTRB(4, MediaQuery.of(context).padding.top + 6, 12, 10),
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
      ],
    ),
  );
}

class MyListingsScreen extends StatefulWidget {
  /// "नई लिस्टिंग जोड़ें" दबाने पर चलेगा
  final VoidCallback onAdd;
  const MyListingsScreen({super.key, required this.onAdd});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  Widget _ownerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'नमस्ते, मकान मालिक',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
                SizedBox(height: 3),
                Text(
                  'आपका मालिक डैशबोर्ड',
                  style: TextStyle(fontSize: 12.5, color: AppColors.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(IconData icon, String number, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 4),
            Text(
              number,
              style: const TextStyle(
                  fontSize: 20,
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
      ),
    );
  }

  Widget _stats(List<MyListing> items) {
    final active = items.where((m) => m.status == 'active').length;
    final views = items.fold<int>(0, (s, m) => s + m.views);
    final inq = items.fold<int>(0, (s, m) => s + m.inquiries);
    return Row(
      children: [
        _statTile(Icons.home, '${items.length}', 'कुल लिस्टिंग'),
        const SizedBox(width: 8),
        _statTile(Icons.check_circle_outline, '$active', 'सक्रिय'),
        const SizedBox(width: 8),
        _statTile(Icons.visibility, '$views', 'कुल व्यूज़'),
        const SizedBox(width: 8),
        _statTile(Icons.chat_bubble_outline, '$inq', 'पूछताछ'),
      ],
    );
  }

  Widget _statusChip(String status) {
    Color bg;
    String text;
    if (status == 'active') {
      bg = AppColors.primary;
      text = 'सक्रिय';
    } else if (status == 'inactive') {
      bg = AppColors.muted;
      text = 'निष्क्रिय';
    } else {
      bg = const Color(0xFF8A5A00);
      text = 'अप्रूवल के लिए लंबित';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
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

  Future<void> _confirmDelete(MyListing m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('लिस्टिंग हटाएं?'),
        content: Text(
          '"${m.title}" हमेशा के लिए हट जाएगी। यह वापस नहीं आएगी।',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('रहने दें'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('हटाएं',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      myListings.value =
          myListings.value.where((x) => x.id != m.id).toList();
      if (mounted) showMsg(context, 'लिस्टिंग हटा दी गई');
    }
  }

  void _toggleActive(MyListing m, bool on) {
    m.status = on ? 'active' : 'inactive';
    _refresh();
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap,
      {Color color = AppColors.primary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(MyListing m) {
    final pending = m.status == 'pending';
    final active = m.status == 'active';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 108,
                height: 118,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(m.image, fit: BoxFit.cover),
                      Positioned(
                        left: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0x99000000),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.photo_camera,
                                  size: 13, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                '${m.photos} फोटो',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
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
                      m.title,
                      maxLines: 2,
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
                            m.area,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12.5, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        _stat(Icons.home_outlined, m.typeLabel),
                        _stat(Icons.square_foot, '${m.sqft} sq ft'),
                        _stat(Icons.apartment, m.floor),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.tint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '₹${inr(m.price)}/माह',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary),
                          ),
                        ),
                        _statusChip(m.status),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _actionBtn(Icons.edit, 'बदलें', () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EditListingScreen(item: m),
                  ),
                );
              }),
              _actionBtn(Icons.photo_library, 'फोटो', () {
                showMsg(context, 'फोटो अपडेट की सुविधा Supabase जुड़ने पर आएगी');
              }),
              GestureDetector(
                onTap: pending
                    ? () => showMsg(context,
                        'एडमिन के approve करने के बाद ही लिस्टिंग सक्रिय होगी')
                    : null,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.only(left: 10, right: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        active ? 'सक्रिय' : 'निष्क्रिय',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text),
                      ),
                      Switch(
                        value: active,
                        onChanged:
                            pending ? null : (v) => _toggleActive(m, v),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
              ),
              _actionBtn(Icons.delete_outline, 'हटाएं', () => _confirmDelete(m),
                  color: AppColors.danger),
            ],
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        children: [
          Icon(Icons.home_work_outlined, size: 64, color: AppColors.muted),
          SizedBox(height: 12),
          Text(
            'अभी कोई लिस्टिंग नहीं है',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.text),
          ),
          SizedBox(height: 6),
          Text(
            'नीचे के बटन से अपना पहला कमरा जोड़ें।',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF9),
      body: Column(
        children: [
          _topBar(context),
          Expanded(
            child: ListenableBuilder(
              listenable: myListings,
              builder: (context, _) {
                final items = myListings.value;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  children: [
                    _ownerCard(),
                    const SizedBox(height: 12),
                    _stats(items),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.home,
                            color: AppColors.primary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'मेरी लिस्टिंग (${items.length})',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (items.isEmpty) _empty(),
                    ...items.map(_card),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, -2)),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onAdd();
                },
                icon: const Icon(Icons.add_circle_outline, size: 22),
                label: const Text('नई लिस्टिंग जोड़ें'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// लिस्टिंग बदलने का फॉर्म
// ---------------------------------------------------------------------------

class EditListingScreen extends StatefulWidget {
  final MyListing item;
  const EditListingScreen({super.key, required this.item});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  late final TextEditingController _title;
  late final TextEditingController _area;
  late final TextEditingController _rent;
  late final TextEditingController _sqft;
  late final TextEditingController _floor;
  late final TextEditingController _desc;

  @override
  void initState() {
    super.initState();
    final m = widget.item;
    _title = TextEditingController(text: m.title);
    _area = TextEditingController(text: m.area);
    _rent = TextEditingController(text: '${m.price}');
    _sqft = TextEditingController(text: '${m.sqft}');
    _floor = TextEditingController(text: m.floor);
    _desc = TextEditingController(text: m.desc);
  }

  @override
  void dispose() {
    for (final c in [_title, _area, _rent, _sqft, _floor, _desc]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final rent = int.tryParse(_rent.text.trim()) ?? 0;
    if (_title.text.trim().length < 3) {
      showMsg(context, 'लिस्टिंग का शीर्षक लिखें');
      return;
    }
    if (_area.text.trim().isEmpty) {
      showMsg(context, 'इलाका/एरिया लिखें');
      return;
    }
    if (rent < 500) {
      showMsg(context, 'सही किराया लिखें (कम से कम ₹500)');
      return;
    }
    if (_desc.text.trim().length < 10) {
      showMsg(context, 'विवरण कम से कम 10 अक्षर का लिखें');
      return;
    }
    final m = widget.item;
    m.title = _title.text.trim();
    m.area = _area.text.trim();
    m.price = rent;
    m.sqft = int.tryParse(_sqft.text.trim()) ?? m.sqft;
    m.floor = _floor.text.trim().isEmpty ? m.floor : _floor.text.trim();
    m.desc = _desc.text.trim();
    _refresh();
    showMsg(context, 'बदलाव सेव हो गए');
    Navigator.of(context).pop();
  }

  InputDecoration _deco(String hint) {
    OutlineInputBorder b(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: AppColors.muted),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: b(AppColors.border),
      focusedBorder: b(AppColors.primary),
      border: b(AppColors.border),
    );
  }

  Widget _field(String label, TextEditingController c,
      {TextInputType? keyboard,
      int maxLength = 60,
      int maxLines = 1,
      bool digitsOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text),
            ),
          ),
          TextField(
            controller: c,
            keyboardType: keyboard,
            maxLength: maxLength,
            maxLines: maxLines,
            inputFormatters:
                digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
            style: const TextStyle(fontSize: 15, color: AppColors.text),
            decoration: _deco(''),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF9),
      body: Column(
        children: [
          _topBar(context),
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.edit, color: AppColors.primary, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'लिस्टिंग बदलें',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _field('शीर्षक', _title),
                    _field('इलाका/एरिया', _area, maxLength: 60),
                    _field('किराया (₹ प्रति माह)', _rent,
                        keyboard: TextInputType.number,
                        maxLength: 6,
                        digitsOnly: true),
                    _field('एरिया (sq ft)', _sqft,
                        keyboard: TextInputType.number,
                        maxLength: 5,
                        digitsOnly: true),
                    _field('मंज़िल', _floor, maxLength: 20),
                    _field('विवरण', _desc, maxLength: 500, maxLines: 4),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 10, 16, 10 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, -2)),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check, size: 22),
                label: const Text('बदलाव सेव करें'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
