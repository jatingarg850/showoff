import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String
  _tokenKey = 'auth_token';
  static const String
  _userKey = 'user_data';

  // Token management
  static Future<
    void
  >
  saveToken(
    String token,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _tokenKey,
      token,
    );
  }

  static Future<
    String?
  >
  getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      _tokenKey,
    );
  }

  static Future<
    void
  >
  removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
      _tokenKey,
    );
  }

  // User data management
  static Future<
    void
  >
  saveUser(
    Map<
      String,
      dynamic
    >
    user,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _userKey,
      jsonEncode(
        user,
      ),
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >?
  >
  getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(
      _userKey,
    );
    if (userString !=
        null) {
      return jsonDecode(
        userString,
      );
    }
    return null;
  }

  static Future<
    void
  >
  removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
      _userKey,
    );
  }

  // Clear all data (logout)
  static Future<
    void
  >
  clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if user is logged in
  static Future<
    bool
  >
  isLoggedIn() async {
    final token = await getToken();
    return token !=
        null;
  }

  // Generic string storage
  static Future<
    void
  >
  saveString(
    String key,
    String value,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      value,
    );
  }

  static Future<
    String?
  >
  getString(
    String key,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      key,
    );
  }

  static Future<
    void
  >
  remove(
    String key,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
      key,
    );
  }
}
