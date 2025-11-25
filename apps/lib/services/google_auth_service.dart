import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Note: For Android, clientId is not needed here
    // It's configured via google-services.json or OAuth client
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google
  /// Returns user data and token on success, null on failure
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('🔐 Starting Google Sign-In...');

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ User cancelled Google Sign-In');
        return null; // User cancelled
      }

      print('✅ Google Sign-In successful: ${googleUser.email}');

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('🔑 Got authentication tokens');
      print('   ID Token: ${googleAuth.idToken?.substring(0, 30)}...');
      print('   Access Token: ${googleAuth.accessToken?.substring(0, 30)}...');

      // Send token to backend (prefer ID token, fallback to access token)
      print('📡 Sending to backend: ${ApiConfig.baseUrl}/auth/google');

      final requestBody = googleAuth.idToken != null
          ? {'idToken': googleAuth.idToken}
          : {'accessToken': googleAuth.accessToken};

      print(
        '   Using: ${googleAuth.idToken != null ? "ID Token" : "Access Token"}',
      );

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('📊 Backend response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          print('✅ Backend authentication successful');
          print('   User: ${data['data']['user']['username']}');
          print('   Token: ${data['data']['token'].substring(0, 30)}...');

          return {'user': data['data']['user'], 'token': data['data']['token']};
        } else {
          print('❌ Backend returned error: ${data['message']}');
          return null;
        }
      } else {
        print('❌ Backend error: ${response.statusCode}');
        print('   Response: ${response.body}');
        return null;
      }
    } catch (error) {
      print('❌ Google Sign-In Error: $error');
      return null;
    }
  }

  /// Sign out from Google
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print('✅ Signed out from Google');
    } catch (error) {
      print('❌ Sign out error: $error');
    }
  }

  /// Check if user is currently signed in
  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Get current Google user
  static GoogleSignInAccount? getCurrentUser() {
    return _googleSignIn.currentUser;
  }

  /// Silent sign-in (if user previously signed in)
  static Future<Map<String, dynamic>?> signInSilently() async {
    try {
      print('🔄 Attempting silent sign-in...');

      final GoogleSignInAccount? googleUser = await _googleSignIn
          .signInSilently();

      if (googleUser == null) {
        print('❌ No previous sign-in found');
        return null;
      }

      print('✅ Silent sign-in successful: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final requestBody = googleAuth.idToken != null
          ? {'idToken': googleAuth.idToken}
          : {'accessToken': googleAuth.accessToken};

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return {'user': data['data']['user'], 'token': data['data']['token']};
        }
      }

      return null;
    } catch (error) {
      print('❌ Silent sign-in error: $error');
      return null;
    }
  }
}
