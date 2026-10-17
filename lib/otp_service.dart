import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpService {
  static const String _baseUrl =
      'https://ckaycemogddeyfpfeqes.supabase.co/functions/v1/roommitara-otp';

  /// Supabase की पब्लिक (anon) key। यह सीक्रेट नहीं है और ऐप में रखना सुरक्षित है।
  /// StartMessaging की API key यहाँ कभी मत डालना, वह सिर्फ Supabase के अंदर रहती है।
  static const String _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNrYXljZW1vZ2RkZXlmcGZlcWVzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE4Njc3ODYsImV4cCI6MjEwNzQ0Mzc4Nn0.-PCtwPySSZzyKv-ZAI7bF367pBuUSlFGgN79SyBrD3w';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
      };

  static Map<String, dynamic> _decode(http.Response r) {
    try {
      final d = jsonDecode(r.body);
      if (d is Map<String, dynamic>) return d;
    } catch (_) {}
    return <String, dynamic>{};
  }

  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: _headers,
          body: jsonEncode({
            'action': 'send',
            'phone': '+91${phone.trim()}',
          }),
        )
        .timeout(const Duration(seconds: 20));

    final data = _decode(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['error'] ?? 'OTP भेजा नहीं जा सका');
    }

    return data;
  }

  static Future<bool> verifyOtp({
    required String requestId,
    required String otpCode,
  }) async {
    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: _headers,
          body: jsonEncode({
            'action': 'verify',
            'requestId': requestId,
            'otpCode': otpCode,
          }),
        )
        .timeout(const Duration(seconds: 20));

    final data = _decode(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['error'] ?? 'OTP सत्यापित नहीं हुआ');
    }

    return data['verified'] == true;
  }
}
