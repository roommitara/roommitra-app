import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'theme.dart';

/// ऐप का डाउनलोड लिंक। अभी कोई पक्का लिंक नहीं है।
/// Play Store पर ऐप आ जाए तो यहाँ '' के बीच में उसका लिंक डाल देना।
const String appShareLink = '';

String inviteMessage() {
  final b = StringBuffer()
    ..writeln('नमस्ते! मैं RoomMitra ऐप इस्तेमाल कर रहा/रही हूँ।')
    ..writeln('नाहन और आसपास के शहरों में किराये का कमरा, PG या फ्लैट ढूँढना और')
    ..writeln('सीधे मकान मालिक से बात करना अब आसान है।');
  if (appShareLink.isNotEmpty) {
    b
      ..writeln()
      ..writeln('ऐप यहाँ से लो: $appShareLink');
  }
  return b.toString().trim();
}

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  Future<void> _whatsapp(BuildContext context) async {
    final uri =
        Uri.parse('https://wa.me/?text=${Uri.encodeComponent(inviteMessage())}');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        showMsg(context, 'WhatsApp नहीं खुल सका');
      }
    } catch (_) {
      if (context.mounted) showMsg(context, 'WhatsApp नहीं खुल सका');
    }
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: inviteMessage()));
    if (context.mounted) {
      showMsg(context, 'मैसेज कॉपी हो गया, अब कहीं भी paste कर सकते हो');
    }
  }

  Widget _step(IconData icon, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                color: AppColors.tint, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text)),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
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
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                          color: AppColors.tint, shape: BoxShape.circle),
                      child: const Icon(Icons.group_add,
                          size: 50, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),
                    const Text('दोस्तों को बुलाएँ',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text)),
                    const SizedBox(height: 6),
                    const Text(
                      'जिसे कमरा चाहिए या जिसे कमरा किराये पर देना है, उसे RoomMitra भेजें।',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13.5, height: 1.4, color: AppColors.muted),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.tintLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  size: 20, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('भेजा जाने वाला मैसेज',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.text)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(inviteMessage(),
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  height: 1.45,
                                  color: AppColors.text)),
                          if (appShareLink.isEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                                'डाउनलोड लिंक अभी नहीं है। ऐप Play Store पर आने के बाद यह मैसेज में जुड़ जाएगा।',
                                style: TextStyle(
                                    fontSize: 11.5, color: AppColors.muted)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _whatsapp(context),
                        icon: const Icon(Icons.chat, size: 20),
                        label: const Text('WhatsApp पर भेजें',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => _copy(context),
                        icon: const Icon(Icons.copy, size: 20),
                        label: const Text('मैसेज कॉपी करें',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                              color: AppColors.primary, width: 1.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('यह कैसे काम करता है?',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text)),
                    ),
                    const SizedBox(height: 12),
                    _step(Icons.send, 'मैसेज भेजें',
                        'WhatsApp या किसी भी ऐप से दोस्त को भेजें।'),
                    _step(Icons.download, 'दोस्त ऐप इंस्टॉल करे',
                        'वह RoomMitra डाउनलोड करके लॉगिन करे।'),
                    _step(Icons.home_work, 'कमरा ढूँढे या लिस्ट करे',
                        'सीधे मकान मालिक से बात, कोई दलाल नहीं।'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
