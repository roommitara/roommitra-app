import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = 'https://ckaycemogddeyfpfeqes.supabase.co';
// यह पब्लिक key है, ऐप में रखना सुरक्षित है।
const String supabaseAnonKey =
    'sb_publishable_xZWpXsR0WJHxK-3LOFO9Wg_66EXeEeq';

class OtpService {
  static SupabaseClient get _client => Supabase.instance.client;

  static String _full(String phone10) => '+91$phone10';

  /// OTP भेजता है। login_screen इसके 'requestId' को पकड़ता है,
  /// इसलिए यहाँ फोन नंबर ही requestId की तरह लौटाते हैं।
  static Future<Map<String, dynamic>> sendOtp(String phone10) async {
    try {
      await _client.auth.signInWithOtp(
        phone: _full(phone10),
        shouldCreateUser: true,
      );
      return {'success': true, 'requestId': phone10};
    } on AuthException catch (e) {
      throw Exception(_friendly(e.message));
    } catch (_) {
      throw Exception('इंटरनेट या सर्वर की समस्या है। थोड़ी देर बाद कोशिश करें।');
    }
  }

  /// OTP जाँचता है और असली लॉगिन सेशन बनाता है।
  static Future<bool> verifyOtp({
    required String requestId,
    required String otpCode,
  }) async {
    try {
      final res = await _client.auth.verifyOTP(
        phone: _full(requestId),
        token: otpCode,
        type: OtpType.sms,
      );
      return res.session != null;
    } on AuthException catch (e) {
      final m = e.message.toLowerCase();
      if (m.contains('invalid') || m.contains('expired') || m.contains('token')) {
        return false;
      }
      throw Exception(_friendly(e.message));
    } catch (_) {
      throw Exception('इंटरनेट या सर्वर की समस्या है। थोड़ी देर बाद कोशिश करें।');
    }
  }

  static Future<void> signOut() => _client.auth.signOut();

  static String _friendly(String m) {
    final s = m.toLowerCase();
    if (s.contains('rate') || s.contains('seconds') || s.contains('too many')) {
      return 'बहुत जल्दी-जल्दी कोशिश हुई। कुछ देर रुककर दोबारा करें।';
    }
    if (s.contains('sms') || s.contains('hook')) {
      return 'SMS भेजा नहीं जा सका। थोड़ी देर बाद कोशिश करें।';
    }
    return 'लॉगिन में समस्या आई। दोबारा कोशिश करें।';
  }
}
