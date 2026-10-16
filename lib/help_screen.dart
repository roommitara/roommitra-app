import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'theme.dart';

/// यहाँ अपना सपोर्ट नंबर (10 अंक, जैसे '9876543210') और ईमेल लिखें।
/// खाली रहने पर संपर्क के बटन सिर्फ एक संदेश दिखाएँगे।
const String supportPhone = '';
const String supportEmail = '';

class _Faq {
  final String cat; // tenant, owner, safety
  final String q;
  final String a;
  const _Faq(this.cat, this.q, this.a);
}

const List<_Faq> _faqs = [
  _Faq(
    'tenant',
    'RoomMitra पर कमरा कैसे खोजें?',
    'होम या खोजें टैब में अपना शहर चुनें, फिर कमरे का प्रकार (PG, 1RK, 1BHK आदि) और बजट के हिसाब से फ़िल्टर लगाएँ। किसी भी कमरे पर टैप करके उसकी पूरी जानकारी और फोटो देख सकते हैं।',
  ),
  _Faq(
    'tenant',
    'मकान मालिक से कैसे संपर्क करूँ?',
    'कमरे की डिटेल स्क्रीन के नीचे "कॉल करें" और "WhatsApp करें" बटन हैं। चाहें तो मालिक की प्रोफाइल से "संदेश भेजें" दबाकर ऐप में ही चैट भी कर सकते हैं।',
  ),
  _Faq(
    'tenant',
    'क्या ऐप के ज़रिए किराया या डिपॉजिट देना होगा?',
    'नहीं। RoomMitra पर कोई ऑनलाइन पेमेंट नहीं होता। किराया और सिक्योरिटी डिपॉजिट आप सीधे मकान मालिक से तय करें, और कमरा खुद देखने के बाद ही कोई लेन-देन करें।',
  ),
  _Faq(
    'tenant',
    'विज़िट बुक करने का क्या मतलब है?',
    'कमरा देखने जाने के लिए आप दिन और समय चुनकर मालिक को अनुरोध भेजते हैं। इसमें कोई भुगतान नहीं है, सिर्फ विज़िट का समय तय होता है।',
  ),
  _Faq(
    'tenant',
    'पसंदीदा कमरे कैसे सेव करूँ?',
    'किसी भी कमरे की फोटो पर दिल का निशान दबाएँ। सेव किए हुए सभी कमरे नीचे के "पसंदीदा" टैब में मिलेंगे। निशान दोबारा दबाने पर कमरा हट जाता है।',
  ),
  _Faq(
    'owner',
    'अपना कमरा कैसे लिस्ट करूँ?',
    'नीचे बीच के "लिस्ट करें" बटन को दबाएँ। 6 आसान चरणों में कमरे की जानकारी, किराया, फोटो (कम से कम 5), सुविधाएँ और पता भरें। लिस्टिंग बिल्कुल फ्री है।',
  ),
  _Faq(
    'owner',
    'मेरी लिस्टिंग तुरंत क्यों नहीं दिखती?',
    'नई लिस्टिंग पहले "जाँच में" रहती है। एडमिन उसे देखकर मंज़ूर करता है, उसके बाद ही वह सबको दिखती है। मालिक खुद अपनी लिस्टिंग को मंज़ूर नहीं कर सकता।',
  ),
  _Faq(
    'owner',
    'लिस्टिंग बदलना, हटाना या बंद करना कैसे होगा?',
    'प्रोफाइल टैब में "मेरी लिस्टिंग" खोलें। हर लिस्टिंग पर "बदलें" और "हटाएं" के बटन हैं। कमरा भर जाए तो स्विच से लिस्टिंग को निष्क्रिय कर दें, तब वह किसी को नहीं दिखेगी।',
  ),
  _Faq(
    'owner',
    'Verified बैज कैसे मिलता है?',
    'Verified बैज एडमिन अपनी जाँच के बाद हाथ से देता है। ऐप में आधार या कोई दस्तावेज़ नहीं माँगा जाता।',
  ),
  _Faq(
    'owner',
    'मेरा पूरा पता और फोन नंबर कौन देख सकता है?',
    'पूरा पता और फोन नंबर सुरक्षित रखे जाते हैं। किरायेदारों को सिर्फ इलाके का नाम दिखता है। संपर्क के लिए कॉल और WhatsApp के बटन दिए गए हैं।',
  ),
  _Faq(
    'safety',
    'फर्जी लिस्टिंग की रिपोर्ट कैसे करूँ?',
    'कमरे की डिटेल स्क्रीन में ऊपर तीन बिंदुओं वाले मेन्यू से "नकली लिस्टिंग रिपोर्ट करें" चुनें। श्रेणी चुनकर रिपोर्ट भेजें। हमारी टीम जाँच करती है और गलत लिस्टिंग हटाती है।',
  ),
  _Faq(
    'safety',
    'किराये का कमरा लेते समय किन बातों का ध्यान रखें?',
    'कमरा खुद जाकर देखें। एडवांस पैसे या डिपॉजिट कमरा देखने और बात पक्की होने के बाद ही दें, और रसीद या लिखित सहमति ज़रूर लें। जो मालिक बिना कमरा दिखाए पैसे माँगे, उससे सावधान रहें।',
  ),
  _Faq(
    'safety',
    'अगर कोई पैसे माँगे या धोखा दे तो क्या करूँ?',
    'पैसे न दें और तुरंत उस लिस्टिंग या यूज़र की रिपोर्ट करें। ज़रूरत लगे तो अपने नज़दीकी पुलिस स्टेशन या साइबर हेल्पलाइन 1930 से भी संपर्क करें।',
  ),
  _Faq(
    'safety',
    'झूठी रिपोर्ट करने पर क्या होता है?',
    'हर रिपोर्ट की जाँच होती है। जान-बूझकर झूठी रिपोर्ट करने पर आपके अकाउंट पर कार्रवाई हो सकती है।',
  ),
];

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  static const List<MapEntry<String, String>> _cats = [
    MapEntry('all', 'सभी'),
    MapEntry('tenant', 'किरायेदार'),
    MapEntry('owner', 'मकान मालिक'),
    MapEntry('safety', 'सुरक्षा'),
  ];

  final TextEditingController _q = TextEditingController();
  String _cat = 'all';
  final Set<String> _open = <String>{};

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _launch(String url, String failMsg) async {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && mounted) showMsg(context, failMsg);
  }

  void _whatsapp() {
    if (supportPhone.length != 10) {
      showMsg(context,
          'सपोर्ट नंबर अभी जोड़ा नहीं गया है। help_screen.dart में supportPhone में नंबर डालें।');
      return;
    }
    final text = Uri.encodeComponent('नमस्ते, मुझे RoomMitra ऐप में मदद चाहिए।');
    _launch('https://wa.me/91$supportPhone?text=$text', 'WhatsApp नहीं खुल सका');
  }

  void _email() {
    if (supportEmail.isEmpty) {
      showMsg(context,
          'सपोर्ट ईमेल अभी जोड़ा नहीं गया है। help_screen.dart में supportEmail में ईमेल डालें।');
      return;
    }
    final subject = Uri.encodeComponent('RoomMitra सहायता');
    _launch('mailto:$supportEmail?subject=$subject', 'ईमेल ऐप नहीं खुल सका');
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
          const Icon(Icons.help_outline, color: Colors.white, size: 26),
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
      child: const Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.support_agent, color: Colors.white, size: 30),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'सहायता और सपोर्ट',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
                SizedBox(height: 2),
                Text(
                  'अक्सर पूछे जाने वाले सवालों के जवाब यहाँ मिलेंगे।',
                  style: TextStyle(
                      fontSize: 12.5, height: 1.3, color: AppColors.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.primary, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _q,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14.5, color: AppColors.text),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'अपना सवाल खोजें...',
                hintStyle: TextStyle(fontSize: 14.5, color: AppColors.muted),
              ),
            ),
          ),
          if (_q.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _q.clear();
                setState(() {});
              },
              child: const Icon(Icons.close, size: 20, color: AppColors.muted),
            ),
        ],
      ),
    );
  }

  Widget _catRow() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = _cats[i];
          final sel = c.key == _cat;
          return GestureDetector(
            onTap: () => setState(() => _cat = c.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.tint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                c.value,
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

  Widget _faqTile(_Faq f) {
    final open = _open.contains(f.q);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: open ? AppColors.primary : AppColors.border,
            width: open ? 1.3 : 1),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                if (open) {
                  _open.remove(f.q);
                } else {
                  _open.add(f.q);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      f.q,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          color: AppColors.text),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (open)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text(
                f.a,
                style: const TextStyle(
                    fontSize: 13.5, height: 1.5, color: AppColors.text),
              ),
            ),
        ],
      ),
    );
  }

  Widget _contactBtn(IconData icon, String label, VoidCallback onTap,
      {bool filled = false}) {
    return Expanded(
      child: SizedBox(
        height: 48,
        child: filled
            ? ElevatedButton.icon(
                onPressed: onTap,
                icon: Icon(icon, size: 20),
                label: Text(label),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              )
            : OutlinedButton.icon(
                onPressed: onTap,
                icon: Icon(icon, size: 20),
                label: Text(label),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
      ),
    );
  }

  Widget _contactCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.headset_mic, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'जवाब नहीं मिला? हमसे संपर्क करें',
                  style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'अपनी समस्या लिखकर भेजें, हम जल्द से जल्द जवाब देंगे।',
            style: TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.text),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _contactBtn(Icons.chat, 'WhatsApp', _whatsapp, filled: true),
              const SizedBox(width: 10),
              _contactBtn(Icons.email, 'ईमेल', _email),
            ],
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 52, color: AppColors.muted),
          SizedBox(height: 10),
          Text(
            'कोई सवाल नहीं मिला। दूसरा शब्द आज़माएँ।',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.5, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _q.text.trim().toLowerCase();
    final list = _faqs.where((f) {
      if (_cat != 'all' && f.cat != _cat) return false;
      if (q.isEmpty) return true;
      return f.q.toLowerCase().contains(q) || f.a.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF9),
      body: Column(
        children: [
          _topBar(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                  16, 14, 16, 16 + MediaQuery.of(context).padding.bottom),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                _headerCard(),
                const SizedBox(height: 12),
                _searchBox(),
                const SizedBox(height: 12),
                _catRow(),
                const SizedBox(height: 14),
                if (list.isEmpty) _empty() else ...list.map(_faqTile),
                const SizedBox(height: 6),
                _contactCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
