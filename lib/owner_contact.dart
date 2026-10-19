import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data.dart';
import 'strings.dart';

/// असली कमरे के मालिक को कॉल / WhatsApp करना।
/// नंबर सीधे ऐप में नहीं रखा जाता: Supabase का get_owner_contact फ़ंक्शन
/// सिर्फ लॉगिन किए हुए यूज़र को और सिर्फ approved + उपलब्ध कमरे का नंबर देता है।
Future<void> contactRealOwner(BuildContext context, Listing l,
    {required bool whatsapp}) async {
  final client = Supabase.instance.client;
  if (client.auth.currentUser == null) {
    showMsg(
        context,
        t('मालिक से संपर्क करने के लिए पहले लॉगिन करें',
            'Please log in to contact the owner'));
    return;
  }

  Map<String, dynamic>? row;
  try {
    final res =
        await client.rpc('get_owner_contact', params: {'p_listing': l.id});
    if (res is List && res.isNotEmpty) {
      row = Map<String, dynamic>.from(res.first as Map);
    } else if (res is Map) {
      row = Map<String, dynamic>.from(res);
    }
  } catch (_) {
    if (!context.mounted) return;
    showMsg(
        context,
        t('मालिक का नंबर नहीं मिल सका। इंटरनेट जाँचकर दोबारा कोशिश करें',
            'Could not get the owner contact. Check your internet and try again'));
    return;
  }
  if (!context.mounted) return;

  if (row == null) {
    showMsg(
        context,
        t('यह कमरा अभी उपलब्ध नहीं है या संपर्क जानकारी नहीं मिली',
            'This room is not available right now or contact details were not found'));
    return;
  }

  final phone = _last10(row['phone']);
  final wa = _last10(row['whatsapp']);
  // WhatsApp नंबर न भरा हो तो कॉलिंग नंबर पर ही WhatsApp खोलो
  final number = whatsapp ? (wa.isNotEmpty ? wa : phone) : phone;
  if (number.length != 10) {
    showMsg(
        context,
        t('मालिक ने अभी नंबर नहीं दिया है',
            'The owner has not provided a number yet'));
    return;
  }

  final Uri uri;
  if (whatsapp) {
    final text = Uri.encodeComponent(t(
        'नमस्ते, मैंने RoomMitra पर आपकी लिस्टिंग "${l.title}" देखी है। क्या यह अभी उपलब्ध है?',
        'Hello, I saw your listing "${l.title}" on RoomMitra. Is it still available?'));
    uri = Uri.parse('https://wa.me/91$number?text=$text');
  } else {
    uri = Uri.parse('tel:+91$number');
  }

  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      showMsg(
          context,
          whatsapp
              ? t('WhatsApp नहीं खुल सका', 'Could not open WhatsApp')
              : t('फोन ऐप नहीं खुल सका', 'Could not open the phone app'));
    }
  } catch (_) {
    if (context.mounted) {
      showMsg(
          context,
          whatsapp
              ? t('WhatsApp नहीं खुल सका', 'Could not open WhatsApp')
              : t('फोन ऐप नहीं खुल सका', 'Could not open the phone app'));
    }
  }
}

/// सिर्फ अंक रखो और आख़िरी 10 लो (+91 या 0 लगा हो तो हट जाए)
String _last10(dynamic v) {
  final d = (v ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
  if (d.length > 10) return d.substring(d.length - 10);
  return d;
}
