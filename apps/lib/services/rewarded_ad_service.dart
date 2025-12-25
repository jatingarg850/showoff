import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class RewardedAdService {
  /// Fetch rewarded ads from backend (NO CACHING - always fresh from server)
  static Future<List<Map<String, dynamic>>> fetchRewardedAds() async {
    try {
      // Always fetch fresh data from server
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/rewarded-ads'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching ads: $e');
      // Return default ads if fetch fails
      return getDefaultAds();
    }
  }

  /// Get ads - always fetches fresh from server
  static Future<List<Map<String, dynamic>>> getAds() async {
    return await fetchRewardedAds();
  }

  /// Get default ads (fallback) - PUBLIC METHOD
  static List<Map<String, dynamic>> getDefaultAds() {
    return [
      {
        'id': '1',
        'adNumber': 1,
        'title': 'Watch & Earn',
        'description': 'Watch video ad to earn coins',
        'rewardCoins': 10,
        'icon': 'play-circle',
        'color': '#701CF5',
        'adProvider': 'admob',
        'isActive': true,
      },
      {
        'id': '2',
        'adNumber': 2,
        'title': 'Sponsored Content',
        'description': 'Watch sponsored content',
        'rewardCoins': 10,
        'icon': 'video',
        'color': '#FF6B35',
        'adProvider': 'admob',
        'isActive': true,
      },
      {
        'id': '3',
        'adNumber': 3,
        'title': 'Interactive Ad',
        'description': 'Interactive ad experience',
        'rewardCoins': 10,
        'icon': 'hand-pointer',
        'color': '#4FACFE',
        'adProvider': 'meta',
        'isActive': true,
      },
      {
        'id': '4',
        'adNumber': 4,
        'title': 'Quick Survey',
        'description': 'Complete a quick survey',
        'rewardCoins': 15,
        'icon': 'clipboard',
        'color': '#43E97B',
        'adProvider': 'custom',
        'isActive': true,
      },
      {
        'id': '5',
        'adNumber': 5,
        'title': 'Premium Offer',
        'description': 'Exclusive premium offer',
        'rewardCoins': 20,
        'icon': 'star',
        'color': '#FBBF24',
        'adProvider': 'third-party',
        'isActive': true,
      },
    ];
  }

  /// Get provider-specific configuration
  static Map<String, dynamic>? getProviderConfig(
    Map<String, dynamic> ad,
    String provider,
  ) {
    final providerConfig = ad['providerConfig'] as Map<String, dynamic>?;
    if (providerConfig == null) return null;

    switch (provider) {
      case 'admob':
        return providerConfig['admob'] as Map<String, dynamic>?;
      case 'meta':
        return providerConfig['meta'] as Map<String, dynamic>?;
      case 'custom':
        return providerConfig['custom'] as Map<String, dynamic>?;
      case 'third-party':
        return providerConfig['thirdParty'] as Map<String, dynamic>?;
      default:
        return null;
    }
  }

  /// Get reward coins for an ad (flexible rewards)
  static int getRewardCoins(Map<String, dynamic> ad) {
    return ad['rewardCoins'] as int? ?? 10;
  }

  /// Track ad click
  static Future<bool> trackAdClick(int adNumber) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/rewarded-ads/$adNumber/click'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error tracking ad click: $e');
      return false;
    }
  }

  /// Track ad conversion
  static Future<bool> trackAdConversion(int adNumber) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/rewarded-ads/$adNumber/conversion'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error tracking ad conversion: $e');
      return false;
    }
  }

  /// Clear cache (no-op since we don't cache anymore)
  static void clearCache() {
    // No caching, so nothing to clear
  }

  /// Refresh ads from backend (always fresh)
  static Future<List<Map<String, dynamic>>> refreshAds() async {
    return await fetchRewardedAds();
  }
}
