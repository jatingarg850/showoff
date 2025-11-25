import 'dart:convert';
import 'package:http/http.dart' as http;

/// Test script to send OTP using Phone.email API
///
/// Client ID: 16687983578815655151
/// API Key: I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf
/// Test Phone: +919811226924

void main() async {
  print('🚀 Testing Phone.email OTP Integration\n');

  const String clientId = '16687983578815655151';
  const String apiKey = 'I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf';
  const String phoneNumber = '+919811226924';

  print('📱 Sending OTP to: $phoneNumber');
  print('🔑 Using Client ID: $clientId\n');

  try {
    // Send OTP request
    final response = await http.post(
      Uri.parse('https://api.phone.email/auth/v1/otp'),
      headers: {
        'Content-Type': 'application/json',
        'X-Client-Id': clientId,
        'X-API-Key': apiKey,
      },
      body: jsonEncode({'phone_number': phoneNumber}),
    );

    print('📡 Response Status: ${response.statusCode}');
    print('📄 Response Body: ${response.body}\n');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('✅ SUCCESS! OTP sent successfully');
      print('📨 Session ID: ${data['session_id'] ?? 'N/A'}');
      print('⏰ Expires in: ${data['expires_in'] ?? 'N/A'} seconds');
      print('\n💡 Check your phone for the OTP code!');
    } else {
      print('❌ FAILED to send OTP');
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('❌ ERROR: $e');
  }
}
