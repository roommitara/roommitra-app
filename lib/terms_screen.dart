import 'package:flutter/material.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'theme.dart';

class _Sec {
  final String title;
  final String body;
  const _Sec(this.title, this.body);
}

const List<_Sec> _terms = [
  _Sec(
    'RoomMitra क्या है',
    'RoomMitra एक प्लेटफॉर्म है जो मकान मालिकों और किरायेदारों को सीधे जोड़ता है। हम कमरे किराये पर नहीं देते और न ही मकान मालिक या किरायेदार के बीच होने वाले किसी समझौते के पक्ष हैं।',
  ),
  _Sec(
    'कोई ऑनलाइन पेमेंट नहीं',
    'ऐप में किराया, डिपॉजिट या किसी भी तरह का भुगतान नहीं होता। सारा लेन-देन मकान मालिक और किरायेदार आपस में सीधे तय करते हैं। कमरा खुद देखने और बात पक्की होने के बाद ही पैसे दें।',
  ),
  _Sec(
    'खाता और लॉगिन',
    'ऐप इस्तेमाल करने के लिए आपको Google या ईमेल से लॉगिन करना होगा। आपकी दी हुई जानकारी सही होनी चाहिए। अपने खाते की सुरक्षा की ज़िम्मेदारी आपकी है।',
  ),
  _Sec(
    'मकान मालिक के नियम',
    'सिर्फ असली कमरे लिस्ट करें, जो आपके अपने हों या जिन्हें किराये पर देने का आपको अधिकार हो। किराया, पता, सुविधाएँ और फोटो सही और अपनी ली हुई होनी चाहिए। कमरा भर जाए तो लिस्टिंग निष्क्रिय या डिलीट कर दें।',
  ),
  _Sec(
    'लिस्टिंग की जाँच',
    'नई लिस्टिंग पहले जाँच में रहती है और एडमिन के मंज़ूर करने पर ही सबको दिखती है। हम किसी भी लिस्टिंग को बिना बताए अस्वीकार या हटा सकते हैं, खासकर अगर वह नकली, भ्रामक या नियमों के खिलाफ हो।',
  ),
  _Sec(
    'Verified बैज',
    'Verified बैज एडमिन अपनी जाँच के बाद हाथ से देता है। यह बैज किसी तरह की गारंटी नहीं है, इसलिए कमरा देखे बिना और बातचीत किए बिना सिर्फ बैज देखकर भरोसा न करें।',
  ),
  _Sec(
    'क्या मना है',
    'नकली या दूसरे की फोटो वाली लिस्टिंग, धोखाधड़ी, एडवांस के बहाने पैसे माँगना, गाली-गलौज या परेशान करना, और किसी की जानकारी का गलत इस्तेमाल करना सख्त मना है। ऐसा करने पर खाता बंद किया जा सकता है।',
  ),
  _Sec(
    'रिपोर्ट करना',
    'कोई लिस्टिंग या यूज़र गलत लगे तो ऐप से रिपोर्ट करें। हम रिपोर्ट की जाँच करते हैं। जान-बूझकर झूठी रिपोर्ट करने पर आपके खाते पर कार्रवाई हो सकती है।',
  ),
  _Sec(
    'हमारी ज़िम्मेदारी की सीमा',
    'लिस्टिंग की जानकारी मकान मालिक देते हैं और हम उसकी पूरी सटीकता की गारंटी नहीं दे सकते। किरायेदार और मकान मालिक के बीच किसी विवाद या नुकसान के लिए RoomMitra ज़िम्मेदार नहीं होगा।',
  ),
  _Sec(
    'नियमों में बदलाव',
    'हम ये नियम समय-समय पर बदल सकते हैं। बदलाव के बाद ऐप इस्तेमाल करते रहने का मतलब है कि आप नए नियम मानते हैं।',
  ),
];

const List<_Sec> _privacy = [
  _Sec(
    'हम कौन सी जानकारी लेते हैं',
    'आपका नाम, मोबाइल नंबर, ईमेल, शहर, लिस्टिंग की जानकारी और फोटो, आपके पसंदीदा कमरे और आपकी की हुई रिपोर्ट। मकान मालिक अपना पूरा पता भी देते हैं।',
  ),
  _Sec(
    'जानकारी का इस्तेमाल',
    'यह जानकारी सिर्फ ऐप चलाने के लिए इस्तेमाल होती है: लिस्टिंग दिखाना, किरायेदार और मालिक को जोड़ना, रिपोर्ट की जाँच और ऐप को सुरक्षित रखना।',
  ),
  _Sec(
    'पता और फोन नंबर',
    'मकान मालिक का पूरा पता और फोन नंबर सुरक्षित रखा जाता है। किरायेदारों को सिर्फ इलाके का नाम दिखता है, और संपर्क कॉल या WhatsApp के बटन से होता है।',
  ),
  _Sec(
    'जानकारी साझा करना',
    'हम आपकी जानकारी बेचते नहीं हैं। सिर्फ ऐप चलाने के लिए ज़रूरी सेवाओं (जैसे डेटा सेव करने वाली सर्विस) के साथ वह रखी जाती है, या कानून के तहत माँगे जाने पर दी जा सकती है।',
  ),
  _Sec(
    'फोटो',
    'लिस्टिंग में डाली गई फोटो सार्वजनिक रूप से दिखती हैं, इसलिए ऐसी फोटो न डालें जिनमें आपके निजी दस्तावेज़ या परिवार के लोग दिखते हों।',
  ),
  _Sec(
    'आपका अधिकार',
    'आप अपनी लिस्टिंग कभी भी बदल या हटा सकते हैं। अपना खाता और उससे जुड़ी जानकारी हटवाने के लिए सहायता और सपोर्ट के ज़रिए हमसे संपर्क करें।',
  ),
  _Sec(
    'बच्चे',
    'यह ऐप 18 साल से कम उम्र के लोगों के लिए नहीं है।',
  ),
  _Sec(
    'नीति में बदलाव',
    'ऐप में नई सुविधाएँ जुड़ने पर हम यह नीति बदल सकते हैं। ताज़ा नीति हमेशा इसी स्क्रीन पर मिलेगी।',
  ),
];

class TermsScreen extends StatefulWidget {
  /// 0 = नियम और शर्तें, 1 = गोपनीयता नीति
  final int initialTab;
  const TermsScreen({super.key, this.initialTab = 0});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  late int _tab = widget.initialTab;

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
          const Icon(Icons.description, color: Colors.white, size: 26),
        ],
      ),
    );
  }

  Widget _tabBtn(int i, IconData icon, String label) {
    final sel = _tab == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = i),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: sel ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 19, color: sel ? Colors.white : AppColors.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(int n, _Sec s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.tint,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$n',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
                const SizedBox(height: 6),
                Text(
                  s.body,
                  style: const TextStyle(
                      fontSize: 13.5, height: 1.5, color: AppColors.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _tab == 0 ? _terms : _privacy;
    final title = _tab == 0 ? 'नियम और शर्तें' : 'गोपनीयता नीति';
    final sub = _tab == 0
        ? 'RoomMitra इस्तेमाल करने से पहले ये नियम पढ़ें।'
        : 'आपकी जानकारी हमारे पास कैसे सुरक्षित रहती है।';
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
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.tint,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      _tabBtn(0, Icons.gavel, 'नियम और शर्तें'),
                      _tabBtn(1, Icons.privacy_tip, 'गोपनीयता नीति'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < list.length; i++) _section(i + 1, list[i]),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'RoomMitra · संस्करण 1.0',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
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
