import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider
    with
        ChangeNotifier {
  Map<
    String,
    dynamic
  >?
  _user;
  bool
  _isLoading = false;
  String?
  _error;

  Map<
    String,
    dynamic
  >?
  get user => _user;
  bool
  get isLoading => _isLoading;
  String?
  get error => _error;
  bool
  get isAuthenticated =>
      _user !=
      null;

  // Initialize - check if user is logged in
  Future<
    void
  >
  initialize() async {
    _user = await StorageService.getUser();
    notifyListeners();
  }

  // Register
  Future<
    bool
  >
  register({
    required String username,
    required String displayName,
    required String password,
    String? email,
    String? phone,
    String? referralCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.register(
        username: username,
        displayName: displayName,
        password: password,
        email: email,
        phone: phone,
        referralCode: referralCode,
      );

      if (response['success']) {
        _user = response['data']['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (
      e
    ) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<
    bool
  >
  login({
    required String emailOrPhone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.login(
        emailOrPhone: emailOrPhone,
        password: password,
      );

      if (response['success']) {
        _user = response['data']['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (
      e
    ) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<
    void
  >
  logout() async {
    await StorageService.clearAll();
    _user = null;
    notifyListeners();
  }

  // Update user data
  void
  updateUser(
    Map<
      String,
      dynamic
    >
    userData,
  ) {
    _user = userData;
    StorageService.saveUser(
      userData,
    );
    notifyListeners();
  }

  // Refresh user data
  Future<
    void
  >
  refreshUser() async {
    try {
      final response = await ApiService.getMe();
      if (response['success']) {
        _user = response['data'];
        await StorageService.saveUser(
          _user!,
        );
        notifyListeners();
      }
    } catch (
      e
    ) {
      print(
        'Error refreshing user: $e',
      );
    }
  }
}
