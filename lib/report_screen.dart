import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'strings.dart';
import 'theme.dart';

class _ReportType {
  final IconData icon;
  final Color color;
  final String reason; // Supabase room_reports.reason की वैल्यू
  final String title;
  final String titleEn;
  final String sub;
  final String subEn;
  const _ReportType(this.icon, this.color, this.reason, this.title,
      this.titleEn, this.sub, this.subEn);

  String get tTitle => t(title, titleEn);
  String get tSub => t(sub, subEn);
}

const List<_ReportType> _types = [
  _ReportType(
      Icons.person_search,
      Color(0xFFE53935),
      'fake_listing',
      'फर्जी लिस्टिंग',
      'Fake listing',
      'अगर कोई प्रॉपर्टी असली नहीं है या फोटो गलत हैं।',
      'If a property is not real or the photos are wrong.'),
  _ReportType(
      Icons.key_off,
      Color(0xFF2F6FE4),
      'already_rented',
      'पहले ही किराये पर चढ़ चुका',
      'Already rented',
      'अगर यह कमरा पहले ही किराये पर दिया जा चुका है।',
      'If this room has already been rented out.'),
  _ReportType(
      Icons.currency_rupee,
      Color(0xFFF2A81D),
      'wrong_price',
      'गलत किराया',
      'Wrong price',
      'अगर लिस्टिंग में लिखा किराया असल किराये से अलग है।',
      'If the rent shown is different from the actual rent.'),
  _ReportType(
      Icons.gpp_bad,
      Color(0xFF7E57C2),
      'scam',
      'धोखाधड़ी / पैसे की मांग',
      'Fraud / demand for money',
      'अगर कोई एडवांस या ज्यादा पैसे की मांग कर रहा है।',
      'If someone is asking for advance or extra money.'),
  _ReportType(
      Icons.report_problem,
      Color(0xFF00796B),
      'inappropriate',
      'अनुचित / असुरक्षित / दुर्व्यवहार',
      'Inappropriate / unsafe / abusive',
      'अगर कुछ अनुचित लगे, खतरा महसूस हो या कोई बदतमीजी करे।',
      'If something seems inappropriate, unsafe or someone behaves rudely.'),
  _ReportType(
      Icons.more_horiz,
      Color(0xFF546E7A),
      'other',
      'अन्य समस्या',
      'Other problem',
      'ऊपर दी गई श्रेणियों में से कोई और समस्या हो तो यहाँ बताएं।',
      'If you have any other problem not listed above, tell us here.'),
];

final RegExp _uuidRe = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

class ReportScreen extends StatefulWidget {
  final Listing? listing;
  const ReportScreen({super.key, this.listing});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int? _sel;
  bool _sending = false;
  final TextEditingController _details = TextEditingController();

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Widget _topBar() {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(4, top + 8, 12, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const RoomMitraLogo(),
        ],
      ),
    );
  }

  Widget _safetyBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user, size: 28, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    t('आपकी सुरक्षा, हमारी प्राथमिकता',
                        'Your safety, our priority'),
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text)),
                const SizedBox(height: 2),
                Text(
                    t('फर्जी लिस्टिंग, धोखाधड़ी या किसी भी समस्या की तुरंत रिपोर्ट करें।',
                        'Report fake listings, fraud or any problem right away.'),
                    style:
                        TextStyle(fontSize: 12, color: AppColors.text)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.shield,
              size: 46, color: AppColors.primary.withOpacity(0.85)),
        ],
      ),
    );
  }

  Widget _typeTile(int i) {
    final rt = _types[i];
    final sel = _sel == i;
    return GestureDetector(
      onTap: () => setState(() => _sel = i),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: sel ? AppColors.tint : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: sel ? AppColors.primary : AppColors.border,
              width: sel ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration:
                  BoxDecoration(color: rt.color, shape: BoxShape.circle),
              child: Icon(rt.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rt.tTitle,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text)),
                  const SizedBox(height: 2),
                  Text(rt.tSub,
                      style: TextStyle(
                          fontSize: 12, height: 1.3, color: AppColors.muted)),
                ],
              ),
            ),
            Icon(
              sel ? Icons.check_circle : Icons.chevron_right,
              color: sel ? AppColors.primary : AppColors.text,
            ),
          ],
        ),
      ),
    );
  }

  Widget _howItWorks() {
    Widget step(int n, String label) {
      return Expanded(
        child: Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: Center(
                child: Text('$n',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 5),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10.5, height: 1.25, color: AppColors.text)),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tintLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.campaign, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    t('रिपोर्ट कैसे काम करती है?', 'How does a report work?'),
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              step(1, t('आपकी रिपोर्ट दर्ज होती है', 'Your report is recorded')),
              step(2, t('हमारी टीम जाँच करती है', 'Our team reviews it')),
              step(
                  3,
                  t('गलत/फर्जी लिस्टिंग हटाई जाती है',
                      'Wrong/fake listings are removed')),
              step(4, t('आपको अपडेट दिया जाता है', 'You get an update')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_sending) return;
    if (_sel == null) {
      showMsg(context,
          t('कृपया पहले एक श्रेणी चुनें', 'Please choose a category first'));
      return;
    }
    final l = widget.listing;
    if (l == null) {
      showMsg(
          context,
          t('रिपोर्ट किसी कमरे की डिटेल स्क्रीन से ही भेजी जा सकती है।',
              'A report can only be sent from a room details screen.'));
      return;
    }
    if (!_uuidRe.hasMatch(l.id)) {
      showMsg(
          context,
          t('यह डेमो कमरा है, इसकी रिपोर्ट सेव नहीं हो सकती।',
              'This is a demo room, its report cannot be saved.'));
      return;
    }
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      showMsg(
          context,
          t('रिपोर्ट करने के लिए पहले लॉगिन करें।',
              'Please log in first to send a report.'));
      return;
    }

    final rt = _types[_sel!];
    setState(() => _sending = true);
    try {
      final existing = await client
          .from('room_reports')
          .select('id')
          .eq('listing_id', l.id)
          .eq('reporter_id', user.id)
          .limit(1);
      if (existing.isNotEmpty) {
        if (!mounted) return;
        setState(() => _sending = false);
        showMsg(
            context,
            t('आप इस कमरे की रिपोर्ट पहले ही कर चुके हैं। हमारी टीम जाँच कर रही है।',
                'You have already reported this room. Our team is reviewing it.'));
        return;
      }

      final text = _details.text.trim();
      await client.from('room_reports').insert({
        'listing_id': l.id,
        'reporter_id': user.id,
        'reason': rt.reason,
        'details': text.isEmpty ? null : text,
        'status': 'open',
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      if (e.code == '23505') {
        showMsg(
            context,
            t('आप इस कमरे की रिपोर्ट पहले ही कर चुके हैं।',
                'You have already reported this room.'));
      } else if (e.code == '42501') {
        showMsg(
            context,
            t('आपको यह रिपोर्ट भेजने की अनुमति नहीं है। दोबारा लॉगिन करके देखें।',
                'You are not allowed to send this report. Try logging in again.'));
      } else {
        showMsg(
            context,
            t('रिपोर्ट भेजी नहीं जा सकी। कुछ देर बाद फिर कोशिश करें।',
                'Could not send the report. Please try again later.'));
      }
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      showMsg(
          context,
          t('रिपोर्ट भेजी नहीं जा सकी। इंटरनेट जाँचकर फिर कोशिश करें।',
              'Could not send the report. Check your internet and try again.'));
      return;
    }

    if (!mounted) return;
    setState(() => _sending = false);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(t('रिपोर्ट दर्ज हो गई', 'Report submitted')),
            ),
          ],
        ),
        content: Text(t(
            'धन्यवाद! हमारी टीम आपकी रिपोर्ट की जाँच करेगी।',
            'Thank you! Our team will review your report.')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(t('ठीक है', 'OK')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _safetyBanner(),
                    if (l != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ListingImage(
                                  listing: l,
                                  width: 56,
                                  height: 46,
                                  fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      t('इस लिस्टिंग के बारे में',
                                          'About this listing'),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.muted)),
                                  Text(l.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.text)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(t('समस्या की रिपोर्ट करें', 'Report a problem'),
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text)),
                    const SizedBox(height: 2),
                    Text(
                        t('कृपया नीचे दी गई श्रेणियों में से चुनें कि आप किस बारे में रिपोर्ट करना चाहते हैं।',
                            'Please choose from the categories below what you want to report about.'),
                        style: TextStyle(
                            fontSize: 12.5, color: AppColors.muted)),
                    const SizedBox(height: 12),
                    ...List.generate(_types.length, _typeTile),
                    if (_sel != null) ...[
                      const SizedBox(height: 2),
                      TextField(
                        controller: _details,
                        maxLines: 3,
                        maxLength: 300,
                        decoration: InputDecoration(
                          hintText: t(
                              'समस्या के बारे में थोड़ा बताएं (वैकल्पिक)',
                              'Tell us a little about the problem (optional)'),
                          hintStyle: TextStyle(
                              fontSize: 13.5, color: AppColors.muted),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    _howItWorks(),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.isDark ? const Color(0xFF3A1D1D) : const Color(0xFFFFEDEC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.isDark ? const Color(0xFF6B2E2E) : const Color(0xFFF5C2C0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: AppColors.danger, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t('ध्यान दें:', 'Note:'),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.text)),
                                Text(
                                    t('झूठी रिपोर्ट करने पर आपके अकाउंट पर कार्रवाई की जा सकती है।',
                                        'Action may be taken on your account for false reports.'),
                                    style: TextStyle(
                                        fontSize: 12, color: AppColors.text)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.fromLTRB(
                  14, 8, 14, 10 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _sending ? null : _submit,
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.verified_user, size: 20),
                  label: Text(
                      _sending
                          ? t('भेजी जा रही है...', 'Sending...')
                          : t('रिपोर्ट सबमिट करें', 'Submit report'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
