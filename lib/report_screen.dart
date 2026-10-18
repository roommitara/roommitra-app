import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'notifications_screen.dart';
import 'strings.dart';
import 'theme.dart';

class _ReportType {
  final IconData icon;
  final Color color;
  final String title;
  final String titleEn;
  final String sub;
  final String subEn;
  const _ReportType(
      this.icon, this.color, this.title, this.titleEn, this.sub, this.subEn);

  String get tTitle => t(title, titleEn);
  String get tSub => t(sub, subEn);
}

const List<_ReportType> _types = [
  _ReportType(
      Icons.person_search,
      Color(0xFFE53935),
      'फर्जी लिस्टिंग की रिपोर्ट करें',
      'Report a fake listing',
      'अगर कोई प्रॉपर्टी असली नहीं है या फोटो/जानकारी गलत है।',
      'If a property is not real or the photos/details are wrong.'),
  _ReportType(
      Icons.currency_rupee,
      Color(0xFFF2A81D),
      'धोखाधड़ी / पैसे की मांग',
      'Fraud / demand for money',
      'अगर कोई एडवांस या ज्यादा पैसे की मांग कर रहा है।',
      'If someone is asking for advance or extra money.'),
  _ReportType(
      Icons.person,
      Color(0xFF2F6FE4),
      'गलत जानकारी',
      'Wrong information',
      'अगर प्रॉपर्टी विवरण, लोकेशन या मालिक की जानकारी गलत है।',
      'If the property details, location or owner information is wrong.'),
  _ReportType(
      Icons.gpp_maybe,
      Color(0xFF7E57C2),
      'असुरक्षित माहौल',
      'Unsafe environment',
      'अगर आपको जगह, मकान मालिक या किसी परिस्थिति से खतरा महसूस हो।',
      'If you feel unsafe because of the place, the owner or a situation.'),
  _ReportType(
      Icons.chat_bubble,
      Color(0xFF00796B),
      'किसी से बदतमीजी / दुर्व्यवहार',
      'Rude behavior / abuse',
      'अगर कोई यूज़र, मालिक या एजेंट अपमानजनक व्यवहार करे।',
      'If a user, owner or agent behaves in an insulting way.'),
  _ReportType(
      Icons.more_horiz,
      Color(0xFF546E7A),
      'अन्य समस्या',
      'Other problem',
      'ऊपर दी गई श्रेणियों में से कोई और समस्या हो तो यहाँ बताएं।',
      'If you have any other problem not listed above, tell us here.'),
];

class ReportScreen extends StatefulWidget {
  final Listing? listing;
  const ReportScreen({super.key, this.listing});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int? _sel;
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
          const Icon(Icons.verified_user, size: 28, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    t('आपकी सुरक्षा, हमारी प्राथमिकता',
                        'Your safety, our priority'),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text)),
                const SizedBox(height: 2),
                Text(
                    t('फर्जी लिस्टिंग, धोखाधड़ी या किसी भी समस्या की तुरंत रिपोर्ट करें।',
                        'Report fake listings, fraud or any problem right away.'),
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.text)),
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
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text)),
                  const SizedBox(height: 2),
                  Text(rt.tSub,
                      style: const TextStyle(
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
              decoration: const BoxDecoration(
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
                style: const TextStyle(
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
              const Icon(Icons.campaign, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    t('रिपोर्ट कैसे काम करती है?', 'How does a report work?'),
                    style: const TextStyle(
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

  void _submit() {
    if (_sel == null) {
      showMsg(context,
          t('कृपया पहले एक श्रेणी चुनें', 'Please choose a category first'));
      return;
    }
    final rt = _types[_sel!];
    demoNotifications.insert(
      0,
      NotifItem(
        kind: NotifKind.safety,
        title: t('रिपोर्ट दर्ज हुई', 'Report submitted'),
        body: t(
            '"${rt.title}" की आपकी रिपोर्ट मिल गई है। हमारी टीम जाँच कर रही है।',
            'We have received your report for "${rt.titleEn}". Our team is reviewing it.'),
        time: t('अभी', 'Just now'),
        unread: true,
      ),
    );
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(t('रिपोर्ट दर्ज हो गई', 'Report submitted')),
            ),
          ],
        ),
        content: Text(t(
            'धन्यवाद! हमारी टीम आपकी रिपोर्ट की जाँच करेगी और आपको अपडेट देगी।',
            'Thank you! Our team will review your report and update you.')),
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
        backgroundColor: Colors.white,
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
                              child: Image.asset(l.image,
                                  width: 56, height: 46, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      t('इस लिस्टिंग के बारे में',
                                          'About this listing'),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.muted)),
                                  Text(l.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
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
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text)),
                    const SizedBox(height: 2),
                    Text(
                        t('कृपया नीचे दी गई श्रेणियों में से चुनें कि आप किस बारे में रिपोर्ट करना चाहते हैं।',
                            'Please choose from the categories below what you want to report about.'),
                        style: const TextStyle(
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
                          hintStyle: const TextStyle(
                              fontSize: 13.5, color: AppColors.muted),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.primary),
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
                        color: const Color(0xFFFFEDEC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF5C2C0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppColors.danger, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t('ध्यान दें:', 'Note:'),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.text)),
                                Text(
                                    t('झूठी रिपोर्ट करने पर आपके अकाउंट पर कार्रवाई की जा सकती है।',
                                        'Action may be taken on your account for false reports.'),
                                    style: const TextStyle(
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
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(
                  14, 8, 14, 10 + MediaQuery.of(context).padding.bottom),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.verified_user, size: 20),
                  label: Text(t('रिपोर्ट सबमिट करें', 'Submit report'),
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
