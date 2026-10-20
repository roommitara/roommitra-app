import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data.dart';
import 'detail_screen.dart' show DetailScreen;
import 'home_screen.dart' show RoomMitraLogo;
import 'strings.dart';
import 'theme.dart';

/// डेमो: सिर्फ इस फोन में जोड़ी गई लिस्टिंग (ऑनलाइन सेव नहीं होतीं)।
/// असली लिस्टिंग नीचे MyRealListingsStore में Supabase से आती हैं।
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

  /// English रूप (खाली हो तो मूल टेक्स्ट ही दिखता है)
  String titleEn;
  String descEn;

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
    this.titleEn = '',
    this.descEn = '',
  });

  /// चुनी हुई भाषा में टाइटल
  String get displayTitle =>
      (AppLang.isHindi || titleEn.isEmpty) ? title : titleEn;

  /// चुनी हुई भाषा में विवरण
  String get displayDesc => (AppLang.isHindi || descEn.isEmpty) ? desc : descEn;
}

final ValueNotifier<List<MyListing>> myListings =
    ValueNotifier<List<MyListing>>(<MyListing>[]);

void _refresh() {
  myListings.value = List<MyListing>.of(myListings.value);
}

/// साइन-इन मालिक की अपनी असली लिस्टिंग (Supabase room_listings से)
class MyRealListingsStore extends ChangeNotifier {
  List<Listing> items = <Listing>[];
  bool loading = false;
  bool loaded = false;
  bool notSignedIn = false;
  String? error;
  String? _uid;

  Future<void> load() async {
    if (loading) return;
    final user = Supabase.instance.client.auth.currentUser;
    // दूसरे अकाउंट की पुरानी लिस्टिंग न दिखें
    if (_uid != user?.id) {
      _uid = user?.id;
      items = <Listing>[];
      loaded = false;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      if (user == null) {
        notSignedIn = true;
        items = <Listing>[];
        loaded = true;
      } else {
        notSignedIn = false;
        final rows = await Supabase.instance.client
            .from('room_listings')
            .select(
                'id, owner_id, title, description, city, locality, monthly_rent, photo_urls, amenities, is_available, status')
            .eq('owner_id', user.id);
        final list = <Listing>[];
        var i = 0;
        for (final r in rows) {
          list.add(Listing.fromRow(Map<String, dynamic>.from(r), i));
          i++;
        }
        items = list;
        loaded = true;
      }
    } catch (e) {
      error = t('आपकी लिस्टिंग लोड नहीं हो सकीं। इंटरनेट जाँचकर फिर कोशिश करें।',
          'Could not load your listings. Check your internet and try again.');
    }
    loading = false;
    notifyListeners();
  }
}

final MyRealListingsStore myRealListings = MyRealListingsStore();

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
  String? _busyId;

  @override
  void initState() {
    super.initState();
    myRealListings.load();
  }

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('नमस्ते, मकान मालिक', 'Hello, house owner'),
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
                const SizedBox(height: 3),
                Text(
                  t('आपका मालिक डैशबोर्ड', 'Your owner dashboard'),
                  style:
                      const TextStyle(fontSize: 12.5, color: AppColors.text),
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

  Widget _stats(List<Listing> items) {
    final live =
        items.where((l) => l.status == 'approved' && l.isAvailable).length;
    final rented = items.where((l) => l.status == 'rented').length;
    final pending = items.where((l) => l.status == 'pending').length;
    return Row(
      children: [
        _statTile(Icons.home, '${items.length}',
            t('कुल लिस्टिंग', 'Total listings')),
        const SizedBox(width: 8),
        _statTile(Icons.check_circle_outline, '$live',
            t('सार्वजनिक', 'Live')),
        const SizedBox(width: 8),
        _statTile(Icons.key, '$rented', t('किराये पर चढ़ी', 'Rented')),
        const SizedBox(width: 8),
        _statTile(Icons.hourglass_empty, '$pending', t('लंबित', 'Pending')),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // असली लिस्टिंग (Supabase)
  // ---------------------------------------------------------------------

  Widget _realStatusChip(Listing l) {
    Color bg;
    String text;
    switch (l.status) {
      case 'approved':
        if (l.isAvailable) {
          bg = AppColors.primary;
          text = t('सार्वजनिक (सक्रिय)', 'Live');
        } else {
          bg = AppColors.muted;
          text = t('अनुपलब्ध', 'Unavailable');
        }
        break;
      case 'pending':
        bg = const Color(0xFF8A5A00);
        text = t('अप्रूवल के लिए लंबित', 'Pending approval');
        break;
      case 'rented':
        bg = AppColors.primaryDark;
        text = t('किराये पर चढ़ गया', 'Rented');
        break;
      case 'rejected':
        bg = AppColors.danger;
        text = t('अस्वीकृत', 'Rejected');
        break;
      case 'hidden':
        bg = AppColors.muted;
        text = t('छिपी हुई', 'Hidden');
        break;
      case 'draft':
        bg = AppColors.muted;
        text = t('ड्राफ्ट', 'Draft');
        break;
      default:
        bg = AppColors.muted;
        text = l.status;
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

  String _statusNote(Listing l) {
    switch (l.status) {
      case 'pending':
        return t(
            'एडमिन की मंज़ूरी का इंतज़ार है। मंज़ूरी तक यह सार्वजनिक नहीं दिखेगी।',
            'Waiting for admin approval. It will not be public until approved.');
      case 'rejected':
        return t('यह लिस्टिंग मंज़ूर नहीं हुई, इसलिए सार्वजनिक नहीं है।',
            'This listing was not approved, so it is not public.');
      case 'hidden':
        return t('यह लिस्टिंग अभी छिपी हुई है, सार्वजनिक नहीं दिख रही।',
            'This listing is currently hidden and not shown publicly.');
      case 'draft':
        return t('यह ड्राफ्ट है, अभी सार्वजनिक नहीं।',
            'This is a draft and is not public yet.');
      case 'rented':
        return t('यह कमरा किराये पर चढ़ चुका है, सार्वजनिक सूची में नहीं दिखता।',
            'This room is rented and is not shown in public listings.');
      default:
        return '';
    }
  }

  Future<bool> _confirm(String title, String body, String yes) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title),
        content: Text(body, style: const TextStyle(height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t('रहने दें', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(yes),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _changeRental(Listing l, {required bool rented}) async {
    final ok = rented
        ? await _confirm(
            t('किराये पर चढ़ गया?', 'Mark as rented?'),
            t('"${l.title}" को "किराये पर चढ़ गया" चिह्नित करें? यह कमरा सार्वजनिक सूची से हट जाएगा।',
                'Mark "${l.title}" as rented? This room will be removed from the public listings.'),
            t('हाँ, चढ़ गया', 'Yes, rented'))
        : await _confirm(
            t('फिर से लिस्ट करें?', 'List again?'),
            t('यह कमरा फिर से मंज़ूरी (pending) में जाएगा। मंज़ूरी मिलने तक यह सार्वजनिक नहीं दिखेगा।',
                'This room will go back to pending approval. It will not be public until it is approved.'),
            t('फिर से लिस्ट करें', 'List again'));
    if (!ok || !mounted) return;

    setState(() => _busyId = l.id);
    String? err;
    try {
      await Supabase.instance.client.rpc(
        'set_listing_rental_status',
        params: {'p_listing': l.id, 'p_rented': rented},
      );
    } on PostgrestException catch (e) {
      err = e.message;
    } catch (_) {
      err = t('इंटरनेट जाँचकर फिर कोशिश करें',
          'Check your internet and try again');
    }
    if (err == null) {
      await myRealListings.load();
      await listingsStore.load();
    }
    if (!mounted) return;
    setState(() => _busyId = null);

    if (err != null) {
      showMsg(context,
          '${t('बदलाव नहीं हो सका', 'Could not make the change')}: $err');
      return;
    }
    final after = myRealListings.items.where((x) => x.id == l.id).toList();
    final status = after.isEmpty ? '' : after.first.status;
    if (rented && status == 'rented') {
      showMsg(
          context,
          t('लिस्टिंग "किराये पर चढ़ गया" चिह्नित हो गई। अब यह सार्वजनिक सूची में नहीं दिखेगी।',
              'Listing marked as rented. It will no longer show in public listings.'));
    } else if (!rented && status == 'pending') {
      showMsg(
          context,
          t('लिस्टिंग फिर से लिस्ट हुई। यह मंज़ूरी (pending) में गई है, मंज़ूरी तक सार्वजनिक नहीं दिखेगी।',
              'Listing listed again. It is now pending approval and will not be public until approved.'));
    } else {
      showMsg(context, t('बदलाव सेव हो गया', 'Change saved'));
    }
  }

  Future<void> _deleteReal(Listing l) async {
    final ok = await _confirm(
        t('लिस्टिंग हटाएं?', 'Delete listing?'),
        t('"${l.title}" हमेशा के लिए हट जाएगी। यह वापस नहीं आएगी।',
            '"${l.title}" will be deleted permanently. It cannot be restored.'),
        t('हाँ, हटाएं', 'Yes, delete'));
    if (!ok || !mounted) return;
    setState(() => _busyId = l.id);
    String? err;
    try {
      await Supabase.instance.client
          .from('room_listings')
          .delete()
          .eq('id', l.id);
    } on PostgrestException catch (e) {
      err = e.message;
    } catch (_) {
      err = t('इंटरनेट जाँचकर फिर कोशिश करें',
          'Check your internet and try again');
    }
    if (err == null) {
      await myRealListings.load();
      await listingsStore.load();
    }
    if (!mounted) return;
    setState(() => _busyId = null);
    showMsg(
        context,
        err == null
            ? t('लिस्टिंग हटा दी गई', 'Listing deleted')
            : '${t('हट नहीं सकी', 'Could not delete')}: $err');
  }

  Widget _realCard(Listing l) {
    final busy = _busyId == l.id;
    final canMarkRented = l.status == 'approved' && l.isAvailable;
    final canRelist = l.status == 'rented';
    final note = _statusNote(l);
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
                      ListingImage(listing: l, fit: BoxFit.cover),
                      if (l.photoUrls.isNotEmpty)
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
                                  t('${l.photoUrls.length} फोटो',
                                      '${l.photoUrls.length} photos'),
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
                      l.title,
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
                            l.area,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12.5, color: AppColors.primary),
                          ),
                        ),
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
                            '₹${inr(l.price)}${t('/माह', '/month')}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary),
                          ),
                        ),
                        _realStatusChip(l),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              note,
              style: const TextStyle(
                  fontSize: 12.5, height: 1.35, color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 10),
          if (busy)
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                const SizedBox(width: 10),
                Text(
                  t('बदल रहे हैं...', 'Updating...'),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text),
                ),
              ],
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _actionBtn(Icons.visibility_outlined, t('देखें', 'View'), () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DetailScreen(listing: l),
                    ),
                  );
                }),
                if (canMarkRented)
                  _actionBtn(
                      Icons.key,
                      t('किराये पर चढ़ गया', 'Mark as Rented'),
                      () => _changeRental(l, rented: true)),
                if (canRelist)
                  _actionBtn(
                      Icons.replay,
                      t('फिर से लिस्ट करें', 'List again'),
                      () => _changeRental(l, rented: false)),
                _actionBtn(Icons.delete_outline, t('हटाएं', 'Delete'),
                    () => _deleteReal(l),
                    color: AppColors.danger),
              ],
            ),
        ],
      ),
    );
  }

  Widget _realSection() {
    final s = myRealListings;
    if (!s.loaded && s.error == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!s.loaded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 30),
        child: Column(
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppColors.muted),
            const SizedBox(height: 10),
            Text(
              s.error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: s.loading ? null : s.load,
              child: Text(t('फिर कोशिश करें', 'Try again')),
            ),
          ],
        ),
      );
    }
    if (s.notSignedIn) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
        child: Text(
          t('अपनी लिस्टिंग देखने के लिए पहले लॉगिन करें।',
              'Please log in first to see your listings.'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14.5, color: AppColors.muted),
        ),
      );
    }
    if (s.items.isEmpty) return _empty();
    return Column(children: s.items.map(_realCard).toList());
  }

  // ---------------------------------------------------------------------
  // डेमो लिस्टिंग (सिर्फ इस फोन में)
  // ---------------------------------------------------------------------

  Widget _statusChip(String status) {
    Color bg;
    String text;
    if (status == 'active') {
      bg = AppColors.primary;
      text = t('सक्रिय', 'Active');
    } else if (status == 'inactive') {
      bg = AppColors.muted;
      text = t('निष्क्रिय', 'Inactive');
    } else {
      bg = const Color(0xFF8A5A00);
      text = t('अप्रूवल के लिए लंबित', 'Pending approval');
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
        title: Text(t('लिस्टिंग हटाएं?', 'Delete listing?')),
        content: Text(
          t('"${m.displayTitle}" हमेशा के लिए हट जाएगी। यह वापस नहीं आएगी।',
              '"${m.displayTitle}" will be deleted permanently. It cannot be restored.'),
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t('रहने दें', 'Keep it')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t('हटाएं', 'Delete'),
                style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      myListings.value =
          myListings.value.where((x) => x.id != m.id).toList();
      if (mounted) {
        showMsg(context, t('लिस्टिंग हटा दी गई', 'Listing deleted'));
      }
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
                                t('${m.photos} फोटो', '${m.photos} photos'),
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
                      m.displayTitle,
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
                            '₹${inr(m.price)}${t('/माह', '/month')}',
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
              _actionBtn(Icons.edit, t('बदलें', 'Edit'), () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EditListingScreen(item: m),
                  ),
                );
              }),
              _actionBtn(Icons.photo_library, t('फोटो', 'Photos'), () {
                showMsg(
                    context,
                    t('फोटो अपडेट की सुविधा Supabase जुड़ने पर आएगी',
                        'Photo update will be available once Supabase is connected'));
              }),
              GestureDetector(
                onTap: pending
                    ? () => showMsg(
                        context,
                        t('एडमिन के approve करने के बाद ही लिस्टिंग सक्रिय होगी',
                            'The listing will become active only after the admin approves it'))
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
                        active ? t('सक्रिय', 'Active') : t('निष्क्रिय', 'Inactive'),
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
              _actionBtn(
                  Icons.delete_outline, t('हटाएं', 'Delete'), () => _confirmDelete(m),
                  color: AppColors.danger),
            ],
          ),
        ],
      ),
    );
  }

  Widget _demoSection(List<MyListing> demo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8C77A)),
          ),
          child: Text(
            t('डेमो लिस्टिंग: ये अभी सिर्फ इस फोन में हैं, ऑनलाइन सेव नहीं हुईं और दूसरों को नहीं दिखेंगी।',
                'Demo listings: these exist only on this phone, are not saved online and are not visible to others.'),
            style: const TextStyle(
                fontSize: 12.5, height: 1.35, color: AppColors.text),
          ),
        ),
        const SizedBox(height: 10),
        ...demo.map(_card),
      ],
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        children: [
          const Icon(Icons.home_work_outlined,
              size: 64, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(
            t('अभी कोई लिस्टिंग नहीं है', 'No listings yet'),
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.text),
          ),
          const SizedBox(height: 6),
          Text(
            t('नीचे के बटन से अपना पहला कमरा जोड़ें।',
                'Add your first room using the button below.'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, lang, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF9),
      body: Column(
        children: [
          _topBar(context),
          Expanded(
            child: ListenableBuilder(
              listenable: Listenable.merge([myRealListings, myListings]),
              builder: (context, _) {
                final real = myRealListings.items;
                final demo = myListings.value;
                return RefreshIndicator(
                  onRefresh: () => myRealListings.load(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    children: [
                      _ownerCard(),
                      const SizedBox(height: 12),
                      _stats(real),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.home,
                              color: AppColors.primary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            t('मेरी लिस्टिंग (${real.length})',
                                'My listings (${real.length})'),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _realSection(),
                      if (demo.isNotEmpty) _demoSection(demo),
                    ],
                  ),
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
                label: Text(t('नई लिस्टिंग जोड़ें', 'Add new listing')),
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
// लिस्टिंग बदलने का फॉर्म (सिर्फ डेमो लिस्टिंग के लिए)
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
    _title = TextEditingController(text: m.displayTitle);
    _area = TextEditingController(text: m.area);
    _rent = TextEditingController(text: '${m.price}');
    _sqft = TextEditingController(text: '${m.sqft}');
    _floor = TextEditingController(text: m.floor);
    _desc = TextEditingController(text: m.displayDesc);
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
      showMsg(context, t('लिस्टिंग का शीर्षक लिखें', 'Enter the listing title'));
      return;
    }
    if (_area.text.trim().isEmpty) {
      showMsg(context, t('इलाका/एरिया लिखें', 'Enter the area/locality'));
      return;
    }
    if (rent < 500) {
      showMsg(
          context,
          t('सही किराया लिखें (कम से कम ₹500)',
              'Enter a valid rent (at least ₹500)'));
      return;
    }
    if (_desc.text.trim().length < 10) {
      showMsg(
          context,
          t('विवरण कम से कम 10 अक्षर का लिखें',
              'Write a description of at least 10 characters'));
      return;
    }
    final m = widget.item;
    m.title = _title.text.trim();
    m.titleEn = '';
    m.area = _area.text.trim();
    m.price = rent;
    m.sqft = int.tryParse(_sqft.text.trim()) ?? m.sqft;
    m.floor = _floor.text.trim().isEmpty ? m.floor : _floor.text.trim();
    m.desc = _desc.text.trim();
    m.descEn = '';
    _refresh();
    showMsg(context, t('बदलाव सेव हो गए', 'Changes saved'));
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
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, lang, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
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
                    Row(
                      children: [
                        const Icon(Icons.edit,
                            color: AppColors.primary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          t('लिस्टिंग बदलें', 'Edit listing'),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _field(t('शीर्षक', 'Title'), _title),
                    _field(t('इलाका/एरिया', 'Area/Locality'), _area,
                        maxLength: 60),
                    _field(t('किराया (₹ प्रति माह)', 'Rent (₹ per month)'),
                        _rent,
                        keyboard: TextInputType.number,
                        maxLength: 6,
                        digitsOnly: true),
                    _field(t('एरिया (sq ft)', 'Area (sq ft)'), _sqft,
                        keyboard: TextInputType.number,
                        maxLength: 5,
                        digitsOnly: true),
                    _field(t('मंज़िल', 'Floor'), _floor, maxLength: 20),
                    _field(t('विवरण', 'Description'), _desc,
                        maxLength: 500, maxLines: 4),
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
                label: Text(t('बदलाव सेव करें', 'Save changes')),
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
