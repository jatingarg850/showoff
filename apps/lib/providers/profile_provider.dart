import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileProvider
    with
        ChangeNotifier {
  bool
  _isLoading = false;
  String?
  _error;
  Map<
    String,
    dynamic
  >?
  _stats;

  bool
  get isLoading => _isLoading;
  String?
  get error => _error;
  Map<
    String,
    dynamic
  >?
  get stats => _stats;

  // Update profile
  Future<
    bool
  >
  updateProfile({
    String? username,
    String? displayName,
    String? bio,
    List<
      String
    >?
    interests,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.updateProfile(
        username: username,
        displayName: displayName,
        bio: bio,
        interests: interests,
      );

      _isLoading = false;
      if (response['success']) {
        notifyListeners();
        return true;
      } else {
        _error = response['message'];
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

  // Upload profile picture
  Future<
    bool
  >
  uploadProfilePicture(
    File imageFile,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.uploadProfilePicture(
        imageFile,
      );

      _isLoading = false;
      if (response['success']) {
        notifyListeners();
        return true;
      } else {
        _error = response['message'];
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

  // Get stats
  Future<
    void
  >
  getStats() async {
    try {
      final response = await ApiService.getMyStats();
      if (response['success']) {
        _stats = response['data'];
        notifyListeners();
      }
    } catch (
      e
    ) {
      print(
        'Error getting stats: $e',
      );
    }
  }
}
