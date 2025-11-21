import 'package:phone_email_auth/phone_email_auth.dart';
import '../config/phone_email_config.dart';

/// Service for handling Phone Email Authentication
class PhoneAuthService {
  static bool
  _isInitialized = false;

  /// Initialize the Phone Email plugin
  static void
  initialize() {
    if (!_isInitialized) {
      PhoneEmail.initializeApp(
        clientId: PhoneEmailConfig.clientId,
      );
      _isInitialized = true;
    }
  }

  /// Get user information from access token
  static Future<
    PhoneEmailUserModel?
  >
  getUserInfo(
    String accessToken,
  ) async {
    PhoneEmailUserModel? userData;

    await PhoneEmail.getUserInfo(
      accessToken: accessToken,
      clientId: PhoneEmailConfig.clientId,
      onSuccess:
          (
            data,
          ) {
            userData = data;
          },
    );

    return userData;
  }
}
