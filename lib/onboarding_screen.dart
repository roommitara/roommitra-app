import 'package:flutter/material.dart';
import 'theme.dart';

class _Pg {
  final String small;
  final String title;
  final String body;
  final IconData icon;
  final bool art;
  const _Pg(this.small, this.title, this.body, this.icon, {this.art = false});
}

const List<_Pg> _pages = [
  _Pg(
    'नमस्कार!',
    'आपका स्वागत है',
    'RoomMitra में आपको आसानी से किराए के कमरे, फ्लैट और घर मिलेंगे। चाहे आप किरायेदार हों या मकान मालिक - हम हैं आपके साथ।',
    Icons.home_rounded,
    art: true,
  ),
  _Pg(
    'हजारों विकल्प',
    'अपने बजट में कमरा खोजें',
    'शहर, किराया, कमरों की संख्या और सुविधाओं के फ़िल्टर लगाकर अपनी पसंद का कमरा चुनें। फोटो देखें और पसंदीदा में सेव करें।',
    Icons.manage_search,
  ),
  _Pg(
    'अपने शहर में ढूँढें',
    'नाहन से शुरुआत',
    'हम नाहन से शुरू कर रहे हैं। नाहन, पांवटा साहिब, सोलन और शिमला में कमरे खोजें, और जल्द ही और शहर जुड़ेंगे।',
    Icons.location_on,
  ),
  _Pg(
    'सुरक्षित और भरोसेमंद',
    'जाँचे हुए कमरे',
    'हर लिस्टिंग एडमिन की जाँच के बाद ही दिखती है। Verified बैज वाले मालिक देखें, और कुछ गलत लगे तो तुरंत रिपोर्ट करें।',
    Icons.verified_user,
  ),
  _Pg(
    'सीधा संपर्क मालिक से',
    'कोई दलाल नहीं, कोई ऑनलाइन पेमेंट नहीं',
    'मकान मालिक को सीधे कॉल या WhatsApp करें, कमरा देखने का समय चुनें। किराया और डिपॉजिट आप आपस में तय करते हैं।',
    Icons.call,
  ),
];

class OnboardingScreen extends StatefulWidget {
  /// स्किप, आखिरी बटन या "लॉगिन करें" दबाने पर चलेगा
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pc = PageController();
  int _i = 0;

  bool get _last => _i == _pages.length - 1;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() {
    if (_last) {
      widget.onFinish();
    } else {
      _pc.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _logo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.tint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.home_rounded,
              color: AppColors.primary, size: 30),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                      text: 'Room',
                      style: TextStyle(color: AppColors.primary)),
                  TextSpan(
                      text: 'Mitra',
                      style: TextStyle(color: Color(0xFF3BAA4B))),
                ],
              ),
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            Text(
              'कमरा ढूँढना हुआ आसान',
              style: TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _topRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          _logo(),
          const Spacer(),
          if (!_last)
            GestureDetector(
              onTap: widget.onFinish,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'स्किप करें',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward,
                        size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String text) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.tint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11.5, height: 1.25, color: AppColors.text),
          ),
        ],
      ),
    );
  }

  Widget _iconArt(IconData icon) {
    return SizedBox(
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              color: AppColors.tintLight,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.tint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 80, color: AppColors.primary),
          ),
          Positioned(
            right: 40,
            top: 24,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 20, color: Colors.white),
            ),
          ),
          Positioned(
            left: 44,
            bottom: 30,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _page(int idx) {
    final p = _pages[idx];
    final first = idx == 0;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.small,
            style: TextStyle(
              fontSize: first ? 26 : 16,
              fontWeight: first ? FontWeight.w800 : FontWeight.w700,
              color: first ? AppColors.text : AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            p.title,
            style: TextStyle(
                fontSize: 28,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            p.body,
            style: TextStyle(
                fontSize: 15, height: 1.6, color: AppColors.text),
          ),
          const SizedBox(height: 14),
          if (p.art)
            Center(
              child: Image.asset(
                'assets/onboard_art.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            )
          else
            Center(child: _iconArt(p.icon)),
          if (first) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _feature(Icons.search, 'हजारों\nविकल्प'),
                _feature(Icons.location_on, 'अपने शहर में\nढूँढें'),
                _feature(Icons.verified_user, 'सुरक्षित और\nभरोसेमंद'),
                _feature(Icons.person_outline, 'सीधा संपर्क\nमालिक से'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (k) {
        final on = k == _i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: on ? 24 : 9,
          height: 9,
          decoration: BoxDecoration(
            color: on ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _topRow(),
            Expanded(
              child: PageView.builder(
                controller: _pc,
                itemCount: _pages.length,
                onPageChanged: (v) => setState(() => _i = v),
                itemBuilder: (context, k) => _page(k),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_last ? 'शुरू करें' : 'आगे बढ़ें'),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward, size: 22),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: widget.onFinish,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                            color: AppColors.primary, width: 1.2),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('पहले से खाता है? लॉगिन करें'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _dots(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
