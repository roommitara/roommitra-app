import 'push_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data.dart';
import 'strings.dart';
import 'theme.dart';

/// असली एडमिन पैनल: नए कमरे जाँचना (Approve/Reject) और रिपोर्ट देखना।
/// सुरक्षा: यह स्क्रीन सिर्फ तब खुलती है जब सर्वर का is_admin() true दे।
/// असली रोक सर्वर (RLS + trigger) पर है, यहाँ सिर्फ बटन हैं।
class AdminReviewScreen extends StatefulWidget {
  const AdminReviewScreen({super.key});

  @override
  State<AdminReviewScreen> createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends State<AdminReviewScreen> {
  SupabaseClient get _db => Supabase.instance.client;

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _pending = [];
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _live = [];
  Map<String, Map<String, dynamic>> _reportedListings = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pending = await _db
          .from('room_listings')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: true);
      final live = await _db
          .from('room_listings')
          .select()
          .inFilter('status', ['approved', 'hidden', 'rented'])
          .order('created_at', ascending: false)
          .limit(100);
      final reports = await _db
          .from('room_reports')
          .select()
          .eq('status', 'open')
          .order('created_at', ascending: false);

      final reportList = List<Map<String, dynamic>>.from(reports as List);
      final ids = reportList
          .map((r) => r['listing_id'].toString())
          .toSet()
          .toList();
      final Map<String, Map<String, dynamic>> byId = {};
      if (ids.isNotEmpty) {
        final rows =
            await _db.from('room_listings').select().inFilter('id', ids);
        for (final r in List<Map<String, dynamic>>.from(rows as List)) {
          byId[r['id'].toString()] = r;
        }
      }
      if (!mounted) return;
      setState(() {
        _pending = List<Map<String, dynamic>>.from(pending as List);
        _reports = reportList;
        _live = List<Map<String, dynamic>>.from(live as List);
        _reportedListings = byId;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = t('लोड नहीं हो पाया। इंटरनेट देखकर फिर कोशिश करें।',
            'Could not load. Check internet and try again.');
        _loading = false;
      });
    }
  }

  Future<bool> _confirm(String title, String body) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(t('रद्द करें', 'Cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(t('हाँ', 'Yes'))),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _setStatus(String listingId, String status) async {
    try {
      await _db
          .from('room_listings')
          .update({'status': status}).eq('id', listingId);
      if (status == 'approved') PushService.notifyNewRoom(listingId);
      if (!mounted) return;
      showMsg(context, t('हो गया', 'Done'));
      listingsStore.load();
      _load();
    } catch (e) {
      if (!mounted) return;
      showMsg(context,
          t('नहीं हो पाया। शायद आप एडमिन नहीं हैं।', 'Failed. Maybe you are not admin.'));
    }
  }

  Future<void> _deleteListing(String id) async {
    try {
      await _db.from('room_listings').delete().eq('id', id);
      if (!mounted) return;
      showMsg(context, t('कमरा हटा दिया', 'Room deleted'));
      listingsStore.load();
      _load();
    } catch (e) {
      if (!mounted) return;
      showMsg(context, t('नहीं हो पाया', 'Failed'));
    }
  }

  Future<void> _closeReport(String reportId, String status) async {
    try {
      await _db.from('room_reports').update({'status': status}).eq('id', reportId);
      if (!mounted) return;
      _load();
    } catch (e) {
      if (!mounted) return;
      showMsg(context, t('नहीं हो पाया', 'Failed'));
    }
  }

  String _reasonLabel(String r) {
    switch (r) {
      case 'fake_listing':
        return t('फर्जी कमरा', 'Fake listing');
      case 'already_rented':
        return t('पहले ही किराये पर जा चुका', 'Already rented');
      case 'wrong_price':
        return t('गलत किराया', 'Wrong price');
      case 'scam':
        return t('धोखाधड़ी', 'Scam');
      case 'inappropriate':
        return t('आपत्तिजनक', 'Inappropriate');
      default:
        return t('अन्य', 'Other');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, _, __) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: AppColors.tintLight,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              title: Text(t('एडमिन पैनल', 'Admin panel')),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _load,
                ),
              ],
              bottom: TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: t('नए कमरे (${_pending.length})',
                      'New rooms (${_pending.length})')),
                  Tab(text: t('रिपोर्ट (${_reports.length})',
                      'Reports (${_reports.length})')),
                  Tab(text: t('सभी कमरे (${_live.length})',
                      'All rooms (${_live.length})')),
                ],
              ),
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _message(_error!, retry: true)
                    : TabBarView(
                        children: [_pendingTab(), _reportsTab(), _liveTab()],
                      ),
          ),
        );
      },
    );
  }

  Widget _message(String text, {bool retry = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 15)),
            if (retry) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: _load, child: Text(t('फिर कोशिश करें', 'Retry'))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pendingTab() {
    if (_pending.isEmpty) {
      return _message(t('कोई नया कमरा जाँच के लिए नहीं है 🎉',
          'No new rooms waiting for review 🎉'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: _pending.length,
        itemBuilder: (c, i) => _listingCard(_pending[i]),
      ),
    );
  }

  Widget _listingCard(Map<String, dynamic> r,
      {bool showReview = true, List<Widget> extra = const []}) {
    final photos = (r['photo_urls'] is List)
        ? List<String>.from((r['photo_urls'] as List).map((e) => e.toString()))
        : <String>[];
    final id = r['id'].toString();
    final amenities = (r['amenities'] is List)
        ? (r['amenities'] as List).join(', ')
        : '';
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.border)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photos.isNotEmpty)
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: photos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (c, i) => GestureDetector(
                    onTap: () => _viewPhoto(photos[i]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(photos[i],
                          width: 140,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 140,
                              height: 110,
                              color: AppColors.tint,
                              child: const Icon(Icons.broken_image))),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Text((r['title'] ?? '').toString(),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text)),
            const SizedBox(height: 4),
            Text(
                '₹${r['monthly_rent']} / ${t('महीना', 'month')}  •  ${r['locality'] ?? ''} ${r['city'] ?? ''}',
                style: TextStyle(color: AppColors.primaryDark)),
            const SizedBox(height: 4),
            Text(
                '${t('प्रकार', 'Type')}: ${r['room_type'] ?? r['kind'] ?? ''}  •  ${t('फोटो', 'Photos')}: ${photos.length}  •  ${r['lat'] != null ? t('मैप पिन ✓', 'Map pin ✓') : t('मैप पिन ✗', 'Map pin ✗')}',
                style: TextStyle(color: AppColors.muted, fontSize: 13)),
            if (amenities.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(amenities,
                  style:
                      TextStyle(color: AppColors.muted, fontSize: 13)),
            ],
            if ((r['description'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(r['description'].toString(),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13)),
            ],
            ...extra,
            const SizedBox(height: 10),
            if (showReview)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger),
                      icon: const Icon(Icons.close),
                      label: Text(t('मना करें', 'Reject')),
                      onPressed: () async {
                        if (await _confirm(
                            t('कमरा रिजेक्ट करें?', 'Reject this room?'),
                            t('मालिक को यह कमरा नहीं दिखेगा।',
                                'It will not be shown publicly.'))) {
                          _setStatus(id, 'rejected');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white),
                      icon: const Icon(Icons.check),
                      label: Text(t('मंज़ूर करें', 'Approve')),
                      onPressed: () async {
                        if (await _confirm(
                            t('कमरा मंज़ूर करें?', 'Approve this room?'),
                            t('यह सबको दिखने लगेगा।',
                                'It will become visible to everyone.'))) {
                          _setStatus(id, 'approved');
                        }
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _viewPhoto(String url) {
    showDialog<void>(
      context: context,
      builder: (c) => Dialog(
        child: InteractiveViewer(child: Image.network(url)),
      ),
    );
  }

  Widget _liveTab() {
    if (_live.isEmpty) {
      return _message(t('अभी कोई कमरा नहीं है', 'No rooms yet'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: _live.length,
        itemBuilder: (c, i) {
          final r = _live[i];
          final id = r['id'].toString();
          final status = (r['status'] ?? '').toString();
          return _listingCard(r, showReview: false, extra: [
            const SizedBox(height: 8),
            Text('${t('स्थिति', 'Status')}: $status',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              if (status == 'approved')
                OutlinedButton(
                  onPressed: () async {
                    if (await _confirm(t('कमरा छिपाएँ?', 'Hide this room?'),
                        t('यह सबको दिखना बंद हो जाएगा।',
                            'It will stop showing to everyone.'))) {
                      _setStatus(id, 'hidden');
                    }
                  },
                  child: Text(t('छिपाएँ', 'Hide')),
                ),
              if (status == 'hidden')
                OutlinedButton(
                  onPressed: () => _setStatus(id, 'approved'),
                  child: Text(t('फिर से दिखाएँ', 'Show again')),
                ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger),
                onPressed: () async {
                  if (await _confirm(
                      t('कमरा हमेशा के लिए हटाएँ?', 'Delete this room forever?'),
                      t('यह वापस नहीं आएगा।', 'This cannot be undone.'))) {
                    _deleteListing(id);
                  }
                },
                child: Text(t('हटाएँ', 'Delete')),
              ),
            ]),
          ]);
        },
      ),
    );
  }

  Widget _reportsTab() {
    if (_reports.isEmpty) {
      return _message(t('कोई खुली रिपोर्ट नहीं है', 'No open reports'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _reports.length,
      itemBuilder: (c, i) {
        final rep = _reports[i];
        final listing = _reportedListings[rep['listing_id'].toString()];
        final lid = rep['listing_id'].toString();
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: AppColors.border)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.flag, color: AppColors.danger, size: 18),
                  const SizedBox(width: 6),
                  Text(_reasonLabel((rep['reason'] ?? '').toString()),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger)),
                ]),
                if ((rep['details'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(rep['details'].toString()),
                ],
                const SizedBox(height: 8),
                Text(
                    listing == null
                        ? t('कमरा नहीं मिला', 'Room not found')
                        : '${listing['title']}  (${listing['status']})',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.text)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  OutlinedButton(
                    onPressed: () => _closeReport(
                        rep['id'].toString(), 'dismissed'),
                    child: Text(t('रिपोर्ट गलत है', 'Dismiss')),
                  ),
                  OutlinedButton(
                    onPressed: () => _closeReport(
                        rep['id'].toString(), 'resolved'),
                    child: Text(t('निपटा दी', 'Resolved')),
                  ),
                  if (listing != null && listing['status'] != 'hidden')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white),
                      onPressed: () async {
                        if (await _confirm(
                            t('कमरा छिपाएँ?', 'Hide this room?'),
                            t('यह कमरा लिस्ट से हट जाएगा।',
                                'The room will be removed from listings.'))) {
                          await _setStatus(lid, 'hidden');
                          _closeReport(rep['id'].toString(), 'resolved');
                        }
                      },
                      child: Text(t('कमरा छिपाएँ', 'Hide room')),
                    ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }
}
