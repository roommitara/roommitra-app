import 'package:flutter/material.dart';
import 'strings.dart';
import 'theme.dart';

/// लिस्टिंग भेजने के बाद दिखने वाली सुंदर "सफल" स्क्रीन
class ListingSuccessScreen extends StatelessWidget {
  const ListingSuccessScreen({super.key});

  Widget _step(IconData icon, String title, String sub, bool done) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: done ? AppColors.primary : AppColors.tint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                size: 24, color: done ? Colors.white : AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text)),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 12.5, height: 1.35, color: AppColors.muted)),
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
      builder: (context, lang, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7FCF9),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                padding: EdgeInsets.fromLTRB(
                    24, MediaQuery.of(context).padding.top + 36, 24, 32),
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      builder: (context, v, child) =>
                          Transform.scale(scale: v, child: child),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 64, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      t('लिस्टिंग भेज दी गई!', 'Listing submitted!'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t('धन्यवाद! आपकी प्रॉपर्टी अब जाँच के लिए हमारे पास है।',
                          'Thank you! Your property is now with us for review.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('आगे क्या होगा?', 'What happens next?'),
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text),
                      ),
                      const SizedBox(height: 12),
                      _step(
                          Icons.send,
                          t('लिस्टिंग भेजी गई', 'Listing sent'),
                          t('आपकी जानकारी और फोटो सुरक्षित सेव हो गईं।',
                              'Your details and photos have been saved safely.'),
                          true),
                      _step(
                          Icons.fact_check,
                          t('एडमिन जाँच', 'Admin review'),
                          t('हमारी टीम लिस्टिंग की जाँच करेगी। अभी यह "जाँच में" है।',
                              'Our team will check the listing. It is currently "under review".'),
                          false),
                      _step(
                          Icons.visibility,
                          t('सबको दिखेगी', 'Visible to everyone'),
                          t('approve होते ही किरायेदार इसे देख और आपसे संपर्क कर सकेंगे।',
                              'Once approved, tenants can see it and contact you.'),
                          false),
                      const SizedBox(height: 4),
                      Text(
                        t('आप "प्रोफ़ाइल → मेरी लिस्टिंग" में स्थिति देख सकते हैं।',
                            'You can check the status in "Profile → My listings".'),
                        style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                    20, 10, 20, 12 + MediaQuery.of(context).padding.bottom),
                color: Colors.white,
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.home_rounded, size: 22),
                    label: Text(t('होम पर जाएँ', 'Go to home')),
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
      },
    );
  }
}