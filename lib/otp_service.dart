import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpService {
  static const String _baseUrl =
      'https://ckaycemogddeyfpfeqes.supabase.co/functions/v1/roommitara-otp';

  static const String _anonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
      },
      body: jsonEncode({
        'action': 'send',
        'phone': '+91${phone.trim()}',
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['error'] ?? 'OTP भेजा नहीं जा सका');
    }

    return data;
  }

  static Future<bool> verifyOtp({
    required String requestId,
    required String otpCode,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'apikey': _anonKey,
        'Authorization': 'Bearer $_anonKey',
      },
      body: jsonEncode({
        'action': 'verify',
        'requestId': requestId,
        'otpCode': otpCode,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['error'] ?? 'OTP सत्यापित नहीं हुआ');
    }

    return data['verified'] == true;
  }
}
