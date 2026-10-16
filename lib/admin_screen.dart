import 'package:flutter/material.dart';
import 'data.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'theme.dart';

// ---------------------------------------------------------------------------
// डेमो डेटा (असली डेटा Supabase जुड़ने पर आएगा)
// ---------------------------------------------------------------------------

class AdminListing {
  final String id;
  final String title;
  final String area;
  final int price;
  final String owner;
  final String image;
  final String added;
  String status; // pending, approved, rejected
  bool badge; // Verified बैज

  AdminListing({
    required this.id,
    required this.title,
    required this.area,
    required this.price,
    required this.owner,
    required this.image,
    required this.added,
    this.status = 'pending',
    this.badge = false,
  });
}

class AdminUser {
  final String name;
  final String phone;
  final String role; // मकान मालिक / किरायेदार
  final int listings;
  bool verified;
  bool blocked;

  AdminUser({
    required this.name,
    required this.phone,
    required this.role,
    this.listings = 0,
    this.verified = false,
    this.blocked = false,
  });
}

class AdminReport {
  final String id;
  final String title;
  final String category;
  final String reporter;
  final String date;
  final String details;
  final String? listingId;
  String status; // open, resolved, dismissed

  AdminReport({
    required this.id,
    required this.title,
    required this.category,
    required this.reporter,
    required this.date,
    required this.details,
    this.listingId,
    this.status = 'open',
  });
}

final ValueNotifier<List<AdminListing>> adminListings =
    ValueNotifier<List<AdminListing>>([
  AdminListing(
    id: 'a1',
    title: '1RK कमरा (सेमी फर्निश्ड)',
    area: 'Rani Tal, Nahan',
    price: 4500,
    owner: 'रमेश यादव',
    image: 'assets/nahan1.jpg',
    added: 'आज जोड़ा गया',
  ),
  AdminListing(
    id: 'a2',
    title: 'स्टूडियो फ्लैट (फुली फर्निश्ड)',
    area: 'Paonta Chowk, Paonta Sahib',
    price: 9000,
    owner: 'स्नेहा पाटिल',
    image: 'assets/nahan2.jpg',
    added: 'आज जोड़ा गया',
  ),
  AdminListing(
    id: 'a3',
    title: '2BHK फ्लैट',
    area: 'Kala Amb',
    price: 7000,
    owner: 'विकास सिंह',
    image: 'assets/nahan3.jpg',
    added: 'आज जोड़ा गया',
  ),
  AdminListing(
    id: 'a4',
    title: 'कमरा (सिंगल बॉय के लिए)',
    area: 'Jamta Road, Nahan',
    price: 3000,
    owner: 'अमित कुमार',
    image: 'assets/nahan4.jpg',
    added: '2 दिन पहले जोड़ा गया',
    status: 'approved',
    badge: true,
  ),
  AdminListing(
    id: 'a5',
    title: 'PG (लड़कियों के लिए)',
    area: 'Sabzi Mandi, Nahan',
    price: 4000,
    owner: 'प्रदीप शर्मा',
    image: 'assets/room2.jpg',
    added: 'कल जोड़ा गया',
  ),
]);

final ValueNotifier<List<AdminUser>> adminUsers = ValueNotifier<List<AdminUser>>([
  AdminUser(
      name: 'रमेश यादव',
      phone: '+91 98xxx xx101',
      role: 'मकान मालिक',
      listings: 1),
  AdminUser(
      name: 'स्नेहा पाटिल',
      phone: '+91 97xxx xx202',
      role: 'मकान मालिक',
      listings: 1),
  AdminUser(
      name: 'विकास सिंह',
      phone: '+91 96xxx xx303',
      role: 'मकान मालिक',
      listings: 1),
  AdminUser(
      name: 'अमित कुमार',
      phone: '+91 95xxx xx404',
      role: 'मकान मालिक',
      listings: 1,
      verified: true),
  AdminUser(
      name: 'राजेश तिवारी',
      phone: '+91 94xxx xx505',
      role: 'मकान मालिक',
      listings: 2,
      verified: true),
  AdminUser(
      name: 'राहुल शर्मा', phone: '+91 93xxx xx606', role: 'किरायेदार'),
  AdminUser(
      name: 'पूजा वर्मा', phone: '+91 92xxx xx707', role: 'किरायेदार'),
]);

final ValueNotifier<List<AdminReport>> adminReports =
    ValueNotifier<List<AdminReport>>([
  AdminReport(
    id: 'r1',
    title: 'फर्जी लिस्टिंग की शिकायत',
    category: 'फर्जी लिस्टिंग',
    reporter: 'राहुल कुमार',
    date: '15 अक्टूबर',
    details:
        'फोटो इंटरनेट से ली हुई लगती हैं। मालिक ने कमरा दिखाने से मना कर दिया।',
    listingId: 'a2',
  ),
  AdminReport(
    id: 'r2',
    title: 'मकान मालिक का व्यवहार ठीक नहीं',
    category: 'बदतमीज़ी / दुर्व्यवहार',
    reporter: 'सोनम वर्मा',
    date: '14 अक्टूबर',
    details: 'फोन पर बात करते समय मालिक ने बदतमीज़ी की।',
    status: 'resolved',
  ),
  AdminReport(
    id: 'r3',
    title: 'गलत लोकेशन दिखाई गई',
    category: 'गलत जानकारी',
    reporter: 'अजय सिंह',
    date: '13 अक्टूबर',
    details: 'लिस्टिंग में जो इलाका लिखा है, कमरा वहाँ नहीं है।',
    listingId: 'a3',
  ),
  AdminReport(
    id: 'r4',
    title: 'एडवांस पैसे माँगे गए',
    category: 'धोखाधड़ी / पैसे की माँग',
    reporter: 'पूजा शर्मा',
    date: '12 अक्टूबर',
    details: 'कमरा देखने से पहले ही मालिक ने एडवांस माँगा।',
    status: 'resolved',
  ),
  AdminReport(
    id: 'r5',
    title: 'फोटो असली नहीं है',
    category: 'फर्जी लिस्टिंग',
    reporter: 'विनोद यादव',
    date: '11 अक्टूबर',
    details: 'कमरा फोटो से बिल्कुल अलग है।',
    listingId: 'a1',
  ),
]);

void _touch<T>(ValueNotifier<List<T>> n) {
  n.value = List<T>.of(n.value);
}

AdminListing? _findListing(String? id) {
  if (id == null) return null;
  for (final a in adminListings.value) {
    if (a.id == id) return a;
  }
  return null;
}

const List<String> _months = [
  'जनवरी',
  'फरवरी',
  'मार्च',
  'अप्रैल',
  'मई',
  'जून',
  'जुलाई',
  'अगस्त',
  'सितंबर',
  'अक्टूबर',
  'नवंबर',
  'दिसंबर',
];
const List<String> _weekdays = [
  'सोमवार',
  'मंगलवार',
  'बुधवार',
  'गुरुवार',
  'शुक्रवार',
  'शनिवार',
  'रविवार',
];

class _St {
  final String text;
  final Color bg;
  final Color fg;
  const _St(this.text, this.bg, this.fg);
}

const Color _amberBg = Color(0xFFFFF1D6);
const Color _amberFg = Color(0xFF8A5A00);

_St _listingSt(String s) {
  if (s == 'approved') {
    return const _St('मंज़ूर', AppColors.tint, AppColors.primary);
  }
  if (s == 'rejected') {
    return const _St('अस्वीकृत', Color(0xFFFBE4E4), AppColors.danger);
  }
  return const _St('जाँच में', _amberBg, _amberFg);
}

_St _reportSt(String s) {
  if (s == 'resolved') {
    return const _St('हल हो गई', AppColors.tint, AppColors.primary);
  }
  if (s == 'dismissed') {
    return const _St('खारिज', Color(0xFFEDEDED), AppColors.muted);
  }
  return const _St('जाँच में', _amberBg, _amberFg);
}

// ---------------------------------------------------------------------------
// एडमिन स्क्रीन
// ---------------------------------------------------------------------------

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tab = 0;
  String _lFilter = 'all';
  String _uFilter = 'all';
  String _rFilter = 'all';

  void _goTab(int t, {String? listing, String? report}) {
    setState(() {
      _tab = t;
      if (listing != null) _lFilter = listing;
      if (report != null) _rFilter = report;
    });
  }

  // ----------------------------------------------------------- क्रियाएँ

  void _setStatus(AdminListing a, String s, String msg) {
    a.status = s;
    if (s != 'approved') a.badge = false;
    _touch(adminListings);
    showMsg(context, msg);
  }

  void _toggleBadge(AdminListing a) {
    a.badge = !a.badge;
    _touch(adminListings);
    showMsg(context, a.badge ? 'Verified बैज दे दिया गया' : 'बैज हटा दिया गया');
  }

  void _toggleVerify(AdminUser u) {
    u.verified = !u.verified;
    _touch(adminUsers);
    showMsg(
        context,
        u.verified
            ? '${u.name} को Verified बैज दिया गया'
            : '${u.name} का बैज हटा दिया गया');
  }

  void _toggleBlock(AdminUser u) {
    u.blocked = !u.blocked;
    _touch(adminUsers);
    showMsg(context,
        u.blocked ? '${u.name} को ब्लॉक कर दिया गया' : '${u.name} अनब्लॉक हो गए');
  }

  void _setReport(AdminReport r, String s, String msg) {
    r.status = s;
    _touch(adminReports);
    showMsg(context, msg);
  }

  void _openReport(AdminReport r) {
    final st = _reportSt(r.status);
    final listing = _findListing(r.listingId);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            18, 16, 18, 18 + MediaQuery.of(ctx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    r.title,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text),
                  ),
                ),
                const SizedBox(width: 8),
                _pill(st.text, st.bg, st.fg),
              ],
            ),
            const SizedBox(height: 10),
            _infoRow('श्रेणी', r.category),
            _infoRow('रिपोर्ट करने वाला', r.reporter),
            _infoRow('तारीख', r.date),
            if (listing != null) _infoRow('लिस्टिंग', listing.title),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.tintLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                r.details,
                style: const TextStyle(
                    fontSize: 13.5, height: 1.45, color: AppColors.text),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (r.status != 'resolved')
                  _btn(Icons.check_circle, 'हल करें', () {
                    Navigator.of(ctx).pop();
                    _setReport(r, 'resolved', 'शिकायत हल मानी गई');
                  }, filled: true),
                if (r.status == 'open')
                  _btn(Icons.close, 'खारिज करें', () {
                    Navigator.of(ctx).pop();
                    _setReport(r, 'dismissed', 'शिकायत खारिज की गई');
                  }),
                if (listing != null && listing.status != 'rejected')
                  _btn(Icons.delete_outline, 'लिस्टिंग हटाएँ', () {
                    Navigator.of(ctx).pop();
                    listing.status = 'rejected';
                    listing.badge = false;
                    _touch(adminListings);
                    _setReport(r, 'resolved', 'लिस्टिंग हटाई गई, शिकायत हल');
                  }, color: AppColors.danger),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------- छोटे विजेट

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 11.5, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _infoRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(k,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.muted)),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, String label, VoidCallback onTap,
      {bool filled = false, Color color = AppColors.primary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: filled ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String text, {VoidCallback? onAll}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: AppColors.text),
          ),
        ),
        if (onAll != null)
          GestureDetector(
            onTap: onAll,
            child: const Row(
              children: [
                Text('सभी देखें',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
              ],
            ),
          ),
      ],
    );
  }

  Widget _filterRow(List<MapEntry<String, String>> opts, String cur,
      ValueChanged<String> onPick) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: opts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final o = opts[i];
          final sel = o.key == cur;
          return GestureDetector(
            onTap: () => onPick(o.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.tint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                o.value,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: sel ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _empty(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 52, color: AppColors.muted),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14.5, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------- ऊपर की पट्टी

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x33FFFFFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text('एडमिन पैनल',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------- डैशबोर्ड

  Widget _greeting() {
    final n = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('नमस्ते, एडमिन जी!',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text)),
                SizedBox(height: 2),
                Text(
                  'यहाँ से आप लिस्टिंग, यूज़र्स और शिकायतें संभाल सकते हैं।',
                  style: TextStyle(
                      fontSize: 12, height: 1.3, color: AppColors.text),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.calendar_month,
                    size: 18, color: AppColors.primary),
                const SizedBox(height: 2),
                Text('${n.day} ${_months[n.month - 1]}',
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text)),
                Text(_weekdays[n.weekday - 1],
                    style: const TextStyle(
                        fontSize: 10.5, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String number, String sub,
      {Color tone = AppColors.primary, Color bg = AppColors.tintLight}) {
    return Expanded(
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tone,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.text)),
                  Text(number,
                      style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text)),
                  Text(sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.5, color: tone)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quick(IconData icon, String text, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.tint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text),
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboard(
      List<AdminListing> ls, List<AdminUser> us, List<AdminReport> rs) {
    final pending = ls.where((a) => a.status == 'pending').toList();
    final openR = rs.where((r) => r.status == 'open').toList();
    final verifiedOwners =
        us.where((u) => u.role == 'मकान मालिक' && u.verified).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        _greeting(),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard(Icons.home, 'कुल लिस्टिंग',
                '${sampleListings.length + ls.length}',
                '${pending.length} जाँच के लिए'),
            const SizedBox(width: 10),
            _statCard(Icons.person, 'कुल यूज़र्स', '${us.length}', 'डेमो'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _statCard(Icons.warning_amber_rounded, 'खुली शिकायतें',
                '${openR.length}', '${rs.length - openR.length} निपटाई गईं',
                tone: const Color(0xFFE59A00), bg: const Color(0xFFFFFAEE)),
            const SizedBox(width: 10),
            _statCard(Icons.verified, 'वेरिफाइड मालिक', '$verifiedOwners',
                'एडमिन द्वारा'),
          ],
        ),
        const SizedBox(height: 16),
        _sectionTitle(Icons.bolt, 'त्वरित कार्य'),
        const SizedBox(height: 10),
        Row(
          children: [
            _quick(Icons.fact_check, 'नई लिस्टिंग जाँचें',
                () => _goTab(1, listing: 'pending')),
            const SizedBox(width: 10),
            _quick(Icons.groups, 'यूज़र्स मैनेज करें', () => _goTab(2)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _quick(Icons.report, 'रिपोर्ट देखें',
                () => _goTab(3, report: 'all')),
            const SizedBox(width: 10),
            _quick(Icons.delete_sweep, 'फर्जी लिस्टिंग हटाएँ',
                () => _goTab(3, report: 'open')),
          ],
        ),
        const SizedBox(height: 18),
        _sectionTitle(Icons.home, 'जाँच के लिए लिस्टिंग',
            onAll: () => _goTab(1, listing: 'pending')),
        const SizedBox(height: 10),
        if (pending.isEmpty)
          _empty('कोई लिस्टिंग जाँच के लिए बाकी नहीं है')
        else
          ...pending.take(3).map(_listingCard),
        const SizedBox(height: 10),
        _sectionTitle(Icons.report_problem, 'हाल की शिकायतें',
            onAll: () => _goTab(3, report: 'all')),
        const SizedBox(height: 10),
        if (rs.isEmpty)
          _empty('कोई शिकायत नहीं')
        else
          ...rs.take(3).map(_reportCard),
      ],
    );
  }

  // ----------------------------------------------------------- लिस्टिंग

  Widget _listingCard(AdminListing a) {
    final st = _listingSt(a.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(a.image,
                    width: 86, height: 86, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14.5,
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
                            a.area,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.muted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '₹${inr(a.price)}/माह',
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'मालिक: ${a.owner} · ${a.added}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _pill(st.text, st.bg, st.fg),
              if (a.badge)
                _pill('Verified बैज', AppColors.primary, Colors.white),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (a.status != 'approved')
                _btn(Icons.check, 'मंज़ूर करें', () {
                  _setStatus(a, 'approved', 'लिस्टिंग मंज़ूर हो गई');
                }, filled: true),
              if (a.status != 'rejected')
                _btn(Icons.close, 'अस्वीकार', () {
                  _setStatus(a, 'rejected', 'लिस्टिंग अस्वीकृत की गई');
                }, color: AppColors.danger),
              if (a.status == 'approved')
                _btn(
                  a.badge ? Icons.remove_circle_outline : Icons.verified,
                  a.badge ? 'बैज हटाएँ' : 'Verified बैज दें',
                  () => _toggleBadge(a),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _listingsTab(List<AdminListing> ls) {
    final list =
        ls.where((a) => _lFilter == 'all' || a.status == _lFilter).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        _filterRow(const [
          MapEntry('all', 'सभी'),
          MapEntry('pending', 'जाँच में'),
          MapEntry('approved', 'मंज़ूर'),
          MapEntry('rejected', 'अस्वीकृत'),
        ], _lFilter, (k) => setState(() => _lFilter = k)),
        const SizedBox(height: 12),
        Text(
          'कुल ${list.length} लिस्टिंग',
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text),
        ),
        const SizedBox(height: 10),
        if (list.isEmpty)
          _empty('इस फ़िल्टर में कोई लिस्टिंग नहीं है')
        else
          ...list.map(_listingCard),
      ],
    );
  }

  // ----------------------------------------------------------- यूज़र्स

  Widget _userCard(AdminUser u) {
    final owner = u.role == 'मकान मालिक';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.tint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            u.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text),
                          ),
                        ),
                        if (u.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified,
                              size: 17, color: AppColors.primary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${u.phone} · ${u.role}${owner ? ' · ${u.listings} लिस्टिंग' : ''}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              if (u.blocked)
                _pill('ब्लॉक्ड', const Color(0xFFFBE4E4), AppColors.danger),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (owner)
                _btn(
                  u.verified ? Icons.remove_circle_outline : Icons.verified,
                  u.verified ? 'बैज हटाएँ' : 'Verified बैज दें',
                  () => _toggleVerify(u),
                ),
              _btn(
                u.blocked ? Icons.lock_open : Icons.block,
                u.blocked ? 'अनब्लॉक करें' : 'ब्लॉक करें',
                () => _toggleBlock(u),
                color: u.blocked ? AppColors.primary : AppColors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _usersTab(List<AdminUser> us) {
    final list = us.where((u) {
      if (_uFilter == 'owner') return u.role == 'मकान मालिक';
      if (_uFilter == 'tenant') return u.role == 'किरायेदार';
      return true;
    }).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        _filterRow(const [
          MapEntry('all', 'सभी'),
          MapEntry('owner', 'मकान मालिक'),
          MapEntry('tenant', 'किरायेदार'),
        ], _uFilter, (k) => setState(() => _uFilter = k)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.tint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Verified बैज सिर्फ एडमिन हाथ से देता है। आधार या दस्तावेज़ ऐप में नहीं लिए जाते।',
                  style: TextStyle(
                      fontSize: 12.5, height: 1.4, color: AppColors.text),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'कुल ${list.length} यूज़र्स',
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text),
        ),
        const SizedBox(height: 10),
        if (list.isEmpty) _empty('कोई यूज़र नहीं मिला') else ...list.map(_userCard),
      ],
    );
  }

  // ----------------------------------------------------------- रिपोर्ट

  Widget _reportCard(AdminReport r) {
    final st = _reportSt(r.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: st.bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.report_problem, color: st.fg, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.title,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${r.category} · ${r.reporter} · ${r.date}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _pill(st.text, st.bg, st.fg),
            ],
          ),
          const SizedBox(height: 10),
          _btn(Icons.visibility, 'विवरण देखें', () => _openReport(r)),
        ],
      ),
    );
  }

  Widget _reportsTab(List<AdminReport> rs) {
    final list =
        rs.where((r) => _rFilter == 'all' || r.status == _rFilter).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        _filterRow(const [
          MapEntry('all', 'सभी'),
          MapEntry('open', 'जाँच में'),
          MapEntry('resolved', 'हल हो गई'),
          MapEntry('dismissed', 'खारिज'),
        ], _rFilter, (k) => setState(() => _rFilter = k)),
        const SizedBox(height: 12),
        Text(
          'कुल ${list.length} शिकायतें',
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text),
        ),
        const SizedBox(height: 10),
        if (list.isEmpty)
          _empty('इस फ़िल्टर में कोई शिकायत नहीं है')
        else
          ...list.map(_reportCard),
      ],
    );
  }

  // ----------------------------------------------------------- नीचे का मेन्यू

  Widget _navBtn(int i, IconData icon, String label, {int badge = 0}) {
    final sel = _tab == i;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tab = i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon,
                    size: 26,
                    color: sel ? AppColors.primary : AppColors.muted),
                if (badge > 0)
                  Positioned(
                    right: -8,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                color: sel ? AppColors.primary : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav(int pendingCount, int openReports) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -2)),
        ],
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            _navBtn(0, Icons.dashboard, 'डैशबोर्ड'),
            _navBtn(1, Icons.list_alt, 'लिस्टिंग', badge: pendingCount),
            _navBtn(2, Icons.groups, 'यूज़र्स'),
            _navBtn(3, Icons.report, 'रिपोर्ट', badge: openReports),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF9),
      body: ListenableBuilder(
        listenable:
            Listenable.merge([adminListings, adminUsers, adminReports]),
        builder: (context, _) {
          final ls = adminListings.value;
          final us = adminUsers.value;
          final rs = adminReports.value;
          final pending = ls.where((a) => a.status == 'pending').length;
          final openR = rs.where((r) => r.status == 'open').length;
          Widget body;
          if (_tab == 0) {
            body = _dashboard(ls, us, rs);
          } else if (_tab == 1) {
            body = _listingsTab(ls);
          } else if (_tab == 2) {
            body = _usersTab(us);
          } else {
            body = _reportsTab(rs);
          }
          return Column(
            children: [
              _topBar(),
              Expanded(child: body),
              _bottomNav(pending, openR),
            ],
          );
        },
      ),
    );
  }
}
