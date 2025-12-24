import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class RewardedAdService {
  static List<Map<String, dynamic>> _cachedAds = [];
  static DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(hours: 1);

  /// Fetch rewarded ads from backend
  static Future<List<Map<String, dynamic>>> fetchRewardedAds() async {
    try {
      // Check if cache is still valid
      if (_cachedAds.isNotEmpty && _lastFetchTime != null) {
        if (DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
          return _cachedAds;
        }
      }

      // Fetch from backend
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/ads'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] && data['data'] != null) {
          _cachedAds = List<Map<String, dynamic>>.from(data['data']);
          _lastFetchTime = DateTime.now();
          return _cachedAds;
        }
      }

      return [];
    } catch (e) {
      print('Error fetching ads: $e');
      return _cachedAds; // Return cached ads if fetch fails
    }
  }

  /// Get ads with fallback to hardcoded defaults
  static Future<List<Map<String, dynamic>>> getAds() async {
    final ads = await fetchRewardedAds();

    if (ads.isEmpty) {
      // Return default ads if no ads from backend
      return getDefaultAds();
    }

    return ads;
  }

  /// Get default ads (fallback) - PUBLIC METHOD
  static List<Map<String, dynamic>> getDefaultAds() {
    return [
      {
        'id': '1',
        'adNumber': 1,
        'title': 'Ad 1',
        'description': 'Watch video ad',
        'reward': 10,
        'icon': Icons.play_circle_filled,
        'color': const Color(0xFF701CF5),
        'adProvider': 'admob',
        'isActive': true,
      },
      {
        'id': '2',
        'adNumber': 2,
        'title': 'Ad 2',
        'description': 'Watch sponsored content',
        'reward': 10,
        'icon': Icons.video_library,
        'color': const Color(0xFFFF6B35),
        'adProvider': 'admob',
        'isActive': true,
      },
      {
        'id': '3',
        'adNumber': 3,
        'title': 'Ad 3',
        'description': 'Interactive ad',
        'reward': 10,
        'icon': Icons.touch_app,
        'color': const Color(0xFF4FACFE),
        'adProvider': 'admob',
        'isActive': true,
      },
      {
        'id': '4',
        'adNumber': 4,
        'title': 'Ad 4',
        'description': 'Rewarded survey',
        'reward': 10,
        'icon': Icons.quiz,
        'color': const Color(0xFF43E97B),
        'adProvider': 'admob',
        'isActive': true,
      },
      {
        'id': '5',
        'adNumber': 5,
        'title': 'Ad 5',
        'description': 'Premium ad',
        'reward': 10,
        'icon': Icons.star,
        'color': const Color(0xFFFBBF24),
        'adProvider': 'admob',
        'isActive': true,
      },
    ];
  }

  /// Track ad click
  static Future<bool> trackAdClick(int adNumber) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/ads/$adNumber/click'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error tracking ad click: $e');
      return false;
    }
  }

  /// Track ad conversion
  static Future<bool> trackAdConversion(int adNumber) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/ads/$adNumber/conversion'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error tracking ad conversion: $e');
      return false;
    }
  }

  /// Clear cache
  static void clearCache() {
    _cachedAds = [];
    _lastFetchTime = null;
  }

  /// Refresh ads from backend
  static Future<List<Map<String, dynamic>>> refreshAds() async {
    clearCache();
    return fetchRewardedAds();
  }
}
