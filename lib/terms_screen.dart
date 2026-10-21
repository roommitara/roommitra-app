import 'package:flutter/material.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'strings.dart';
import 'theme.dart';

/// लॉन्च की तारीख यहाँ लिखें (जैसे '1 नवंबर 2026')।
/// खाली रहने पर तारीख की लाइन नहीं दिखेगी।
const String termsEffectiveDate = '';

class _Sec {
  final String title;
  final String titleEn;
  final String body;
  final String bodyEn;
  const _Sec(this.title, this.titleEn, this.body, this.bodyEn);

  String get tTitle => t(title, titleEn);
  String get tBody => t(body, bodyEn);
}

const List<_Sec> _terms = [
  _Sec(
    'RoomMitra के बारे में',
    'About RoomMitra',
    'RoomMitra एक डिजिटल प्लेटफॉर्म है जो कमरा देने वाले मकान मालिकों और कमरा ढूँढने वालों को आपस में जोड़ता है। प्रॉपर्टी लिस्टिंग, फोटो, वीडियो और संपर्क जानकारी के ज़रिए यूज़र किराये का आवास ढूँढ और लिस्ट कर सकते हैं।',
    'RoomMitra is a digital platform that connects room owners and room seekers. Through property listings, photos, videos and contact details, users can find and list rental accommodation.',
  ),
  _Sec(
    'यूज़र रजिस्ट्रेशन',
    'User Registration',
    '• यूज़र को सही जानकारी देनी होगी।\n• खाते की सुरक्षा के लिए मोबाइल OTP वेरिफिकेशन का इस्तेमाल किया जा सकता है।\n• नकली खाते बनाना या दूसरे यूज़र की पहचान का गलत इस्तेमाल करना मना है।',
    '• Users must provide accurate information.\n• Mobile OTP verification may be used for account security.\n• Creating fake accounts or misusing another user\'s identity is prohibited.',
  ),
  _Sec(
    'प्रॉपर्टी लिस्टिंग',
    'Property Listings',
    'प्रॉपर्टी लिस्ट करने वाले यूज़र को:\n• प्रॉपर्टी लिस्ट करने का अधिकार होना चाहिए।\n• सही किराया, डिपॉजिट, लोकेशन और सुविधाएँ देनी होंगी।\n• असली प्रॉपर्टी की फोटो और वीडियो अपलोड करने होंगे।\n• उपलब्धता की जानकारी अपडेट रखनी होगी।\n• भ्रामक या धोखाधड़ी वाली लिस्टिंग प्रकाशित नहीं करनी होगी।\n\nRoomMitra संदिग्ध लिस्टिंग की समीक्षा कर सकता है, उन्हें सीमित कर सकता है या हटा सकता है।',
    'Users who list a property must:\n• Have the right to list the property.\n• Provide accurate rent, deposit, location and amenities.\n• Upload photos and videos of the actual property.\n• Keep availability up to date.\n• Not publish misleading or fraudulent listings.\n\nRoomMitra may review, restrict or remove suspicious listings.',
  ),
  _Sec(
    'किराये का लेन-देन',
    'Rental Transactions',
    '• RoomMitra मकान मालिकों और संभावित किरायेदारों को आपस में जोड़ता है।\n• किराया, सिक्योरिटी डिपॉजिट, एग्रीमेंट और किरायेदारी की शर्तें मकान मालिक और किरायेदार सीधे तय करेंगे।\n• RoomMitra फिलहाल किराया या सिक्योरिटी डिपॉजिट नहीं लेता।\n• पेमेंट करने से पहले किरायेदार को मकान मालिक, प्रॉपर्टी और पेमेंट की जानकारी जाँच लेनी चाहिए।\n• किसी भी किराये के समझौते की अंतिम शर्तें मकान मालिक और किरायेदार की आपसी सहमति पर निर्भर करेंगी।',
    '• RoomMitra connects owners and prospective tenants.\n• Rent, security deposit, agreement and tenancy conditions will be decided directly by the owner and the tenant.\n• RoomMitra does not currently collect rent or security deposit.\n• Before making any payment, the tenant should verify the owner, the property and the payment details.\n• The final conditions of any rental arrangement depend on the agreement between the owner and the tenant.',
  ),
  _Sec(
    'प्लेटफॉर्म की ज़िम्मेदारियाँ',
    'Platform Responsibilities',
    'RoomMitra एक किराये के मार्केटप्लेस के रूप में काम करता है। हर लिस्टिंग की सटीकता, प्रॉपर्टी की हालत, मालिकाना हक और उपलब्धता की स्वतंत्र जाँच की गारंटी नहीं दी जाती।\n\nइसका मतलब यह नहीं है कि RoomMitra अपनी लागू कानूनी ज़िम्मेदारियों से मुक्त है। प्लेटफॉर्म अपनी कानूनी ज़िम्मेदारियों का पालन करेगा।',
    'RoomMitra works as a rental marketplace. There is no guarantee of independent verification of the accuracy of each listing, the condition of the property, ownership or availability.\n\nThis does not mean that RoomMitra is exempt from its applicable legal obligations. The platform will comply with its legal responsibilities.',
  ),
  _Sec(
    'मना की गई गतिविधियाँ',
    'Prohibited Activities',
    'यूज़र को इन गतिविधियों की अनुमति नहीं है:\n• नकली प्रॉपर्टी लिस्टिंग या भ्रामक फोटो अपलोड करना।\n• पैसे की धोखाधड़ी वाली माँग करना।\n• स्पैम करना या परेशान करना।\n• बिना अधिकार के किसी और की प्रॉपर्टी लिस्ट करना।\n• गैरकानूनी कामों के लिए प्लेटफॉर्म का इस्तेमाल करना।\n\nउल्लंघन पर लिस्टिंग हटाई जा सकती है या खाता निलंबित किया जा सकता है।',
    'Users are not permitted to:\n• Upload fake property listings or misleading photos.\n• Make fraudulent payment requests.\n• Spam or harass others.\n• List someone else\'s property without authorization.\n• Use the platform for illegal activities.\n\nViolations may result in listing removal or account suspension.',
  ),
  _Sec(
    'खाता हटाना',
    'Account Deletion',
    'यूज़र अपना खाता हटाने का अनुरोध कर सकते हैं। लागू कानूनी ज़रूरतों के अनुसार कुछ रिकॉर्ड सीमित समय तक रखे जा सकते हैं।',
    'Users can request deletion of their account. As per applicable legal requirements, some records may be retained for a limited time.',
  ),
  _Sec(
    'शर्तों में बदलाव',
    'Changes to Terms',
    'RoomMitra इन शर्तों को अपडेट कर सकता है। महत्वपूर्ण बदलाव होने पर यूज़र को उचित सूचना दी जाएगी।',
    'RoomMitra may update these Terms. Users will be given appropriate notice of any material changes.',
  ),
  _Sec(
    'संपर्क और शिकायत',
    'Contact and Complaints',
    'प्लेटफॉर्म: RoomMitra\nस्थान: नाहन, हिमाचल प्रदेश, भारत\nसपोर्ट ईमेल: roommitara@gmail.com\nशिकायत के लिए संपर्क: 7559772533',
    'Platform: RoomMitra\nLocation: Nahan, Himachal Pradesh, India\nSupport Email: roommitara@gmail.com\nGrievance Contact: 7559772533',
  ),
];

const List<_Sec> _privacy = [
  _Sec(
    'हम कौन सी जानकारी लेते हैं',
    'What information we collect',
    'आपका नाम, मोबाइल नंबर, ईमेल, शहर, लिस्टिंग की जानकारी और फोटो, आपके पसंदीदा कमरे और आपकी की हुई रिपोर्ट। मकान मालिक अपना पूरा पता भी देते हैं।',
    'Your name, mobile number, email, city, listing details and photos, your favorite rooms and the reports you make. Owners also provide their full address.',
  ),
  _Sec(
    'जानकारी का इस्तेमाल',
    'How we use the information',
    'यह जानकारी सिर्फ ऐप चलाने के लिए इस्तेमाल होती है: लिस्टिंग दिखाना, किरायेदार और मालिक को जोड़ना, रिपोर्ट की जाँच और ऐप को सुरक्षित रखना।',
    'This information is used only to run the app: showing listings, connecting tenants and owners, reviewing reports and keeping the app safe.',
  ),
  _Sec(
    'पता और फोन नंबर',
    'Address and phone number',
    'मकान मालिक का पूरा पता और फोन नंबर सुरक्षित रखा जाता है। किरायेदारों को सिर्फ इलाके का नाम दिखता है, और संपर्क कॉल या WhatsApp के बटन से होता है।',
    'The owner\'s full address and phone number are kept safe. Tenants see only the area name, and contact happens through the Call or WhatsApp buttons.',
  ),
  _Sec(
    'जानकारी साझा करना',
    'Sharing information',
    'हम आपकी जानकारी बेचते नहीं हैं। सिर्फ ऐप चलाने के लिए ज़रूरी सेवाओं (जैसे डेटा सेव करने वाली सर्विस) के साथ वह रखी जाती है, या कानून के तहत माँगे जाने पर दी जा सकती है।',
    'We do not sell your information. It is kept only with services needed to run the app (such as the data storage service), or may be given when required by law.',
  ),
  _Sec(
    'फोटो',
    'Photos',
    'लिस्टिंग में डाली गई फोटो सार्वजनिक रूप से दिखती हैं, इसलिए ऐसी फोटो न डालें जिनमें आपके निजी दस्तावेज़ या परिवार के लोग दिखते हों।',
    'Photos added to a listing are publicly visible, so do not upload photos that show your personal documents or family members.',
  ),
  _Sec(
    'आपका अधिकार',
    'Your rights',
    'आप अपनी लिस्टिंग कभी भी बदल या हटा सकते हैं। अपना खाता और उससे जुड़ी जानकारी हटवाने के लिए सहायता और सपोर्ट के ज़रिए हमसे संपर्क करें।',
    'You can edit or delete your listing at any time. To delete your account and related information, contact us through Help & Support.',
  ),
  _Sec(
    'बच्चे',
    'Children',
    'यह ऐप 18 साल से कम उम्र के लोगों के लिए नहीं है।',
    'This app is not meant for people under 18 years of age.',
  ),
  _Sec(
    'नीति में बदलाव',
    'Changes to the policy',
    'ऐप में नई सुविधाएँ जुड़ने पर हम यह नीति बदल सकते हैं। ताज़ा नीति हमेशा इसी स्क्रीन पर मिलेगी।',
    'We may change this policy when new features are added to the app. The latest policy will always be on this screen.',
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
      decoration: BoxDecoration(
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
        color: AppColors.surface,
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
            decoration: BoxDecoration(
              color: AppColors.tint,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$n',
              style: TextStyle(
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
                  s.tTitle,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
                const SizedBox(height: 6),
                Text(
                  s.tBody,
                  style: TextStyle(
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
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, _, __) {
        final list = _tab == 0 ? _terms : _privacy;
        final title = _tab == 0
            ? t('नियम और शर्तें', 'Terms & Conditions')
            : t('गोपनीयता नीति', 'Privacy Policy');
        final sub = _tab == 0
            ? t('RoomMitra इस्तेमाल करने से पहले ये नियम पढ़ें।',
                'Please read these terms before using RoomMitra.')
            : t('आपकी जानकारी हमारे पास कैसे सुरक्षित रहती है।',
                'How your information is kept safe with us.');
        return Scaffold(
          backgroundColor: AppColors.bg,
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
                          _tabBtn(0, Icons.gavel,
                              t('नियम और शर्तें', 'Terms & Conditions')),
                          _tabBtn(1, Icons.privacy_tip,
                              t('गोपनीयता नीति', 'Privacy Policy')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style:
                          TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                    if (_tab == 0 && termsEffectiveDate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${t('लागू होने की तारीख', 'Effective date')}: $termsEffectiveDate',
                        style: TextStyle(
                            fontSize: 12.5, color: AppColors.muted),
                      ),
                    ],
                    const SizedBox(height: 12),
                    for (var i = 0; i < list.length; i++)
                      _section(i + 1, list[i]),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        t('RoomMitra · संस्करण 1.0', 'RoomMitra · Version 1.0'),
                        style: TextStyle(
                            fontSize: 12, color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
