import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data.dart';
import 'home_screen.dart' show RoomMitraLogo;
import 'strings.dart';
import 'theme.dart';

/// ऐप का डाउनलोड लिंक। अभी कोई पक्का लिंक नहीं है।
/// Play Store पर ऐप आ जाए तो यहाँ '' के बीच में उसका लिंक डाल देना।
const String appShareLink = '';

String inviteMessage() {
  final b = StringBuffer()
    ..writeln(t('नमस्ते! मैं RoomMitra ऐप इस्तेमाल कर रहा/रही हूँ।',
        'Hello! I am using the RoomMitra app.'))
    ..writeln(t('नाहन और आसपास के शहरों में किराये का कमरा, PG या फ्लैट ढूँढना और',
        'Finding a rented room, PG or flat in Nahan and nearby towns, and'))
    ..writeln(t('सीधे मकान मालिक से बात करना अब आसान है।',
        'talking directly to the owner is now easy.'));
  if (appShareLink.isNotEmpty) {
    b
      ..writeln()
      ..writeln(t('ऐप यहाँ से लो: $appShareLink', 'Get the app here: $appShareLink'));
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
        showMsg(context, t('WhatsApp नहीं खुल सका', 'Could not open WhatsApp'));
      }
    } catch (_) {
      if (context.mounted) showMsg(context, t('WhatsApp नहीं खुल सका', 'Could not open WhatsApp'));
    }
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: inviteMessage()));
    if (context.mounted) {
      showMsg(context,
          t('मैसेज कॉपी हो गया, अब कहीं भी paste कर सकते हो',
              'Message copied, you can paste it anywhere'));
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
            decoration: BoxDecoration(
                color: AppColors.tint, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text)),
                Text(sub,
                    style: TextStyle(
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
    return ValueListenableBuilder<String>(
      valueListenable: AppLang.notifier,
      builder: (context, _, __) => _page(context),
    );
  }

  Widget _page(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.bg,
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
                      decoration: BoxDecoration(
                          color: AppColors.tint, shape: BoxShape.circle),
                      child: Icon(Icons.group_add,
                          size: 50, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),
                    Text(t('दोस्तों को बुलाएँ', 'Invite friends'),
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text)),
                    const SizedBox(height: 6),
                    Text(
                      t('जिसे कमरा चाहिए या जिसे कमरा किराये पर देना है, उसे RoomMitra भेजें।',
                          'Send RoomMitra to anyone who needs a room or wants to rent one out.'),
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
                          Row(
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  size: 20, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(t('भेजा जाने वाला मैसेज', 'Message to be sent'),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.text)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(inviteMessage(),
                              style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.45,
                                  color: AppColors.text)),
                          if (appShareLink.isEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                                t('डाउनलोड लिंक अभी नहीं है। ऐप Play Store पर आने के बाद यह मैसेज में जुड़ जाएगा।',
                                    'No download link yet. It will be added to the message once the app is on the Play Store.'),
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
                        label: Text(t('WhatsApp पर भेजें', 'Send on WhatsApp'),
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
                        label: Text(t('मैसेज कॉपी करें', 'Copy message'),
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                              color: AppColors.primary, width: 1.2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(t('यह कैसे काम करता है?', 'How does it work?'),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text)),
                    ),
                    const SizedBox(height: 12),
                    _step(Icons.send, t('मैसेज भेजें', 'Send the message'),
                        t('WhatsApp या किसी भी ऐप से दोस्त को भेजें।',
                            'Send it to a friend via WhatsApp or any app.')),
                    _step(Icons.download, t('दोस्त ऐप इंस्टॉल करे', 'Friend installs the app'),
                        t('वह RoomMitra डाउनलोड करके लॉगिन करे।',
                            'They download RoomMitra and log in.')),
                    _step(Icons.home_work, t('कमरा ढूँढे या लिस्ट करे', 'Find or list a room'),
                        t('सीधे मकान मालिक से बात, कोई दलाल नहीं।',
                            'Talk directly to the owner, no broker.')),
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
