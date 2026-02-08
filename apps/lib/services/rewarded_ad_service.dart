import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class RewardedAdService {
  /// Fetch rewarded ads from backend with optional type filter
  static Future<List<Map<String, dynamic>>> fetchRewardedAds({
    String? type,
  }) async {
    try {
      String url = '${ApiService.baseUrl}/rewarded-ads';
      if (type != null) {
        url += '?type=$type';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching rewarded ads: $e');
      return [];
    }
  }

  /// Fetch video ads from backend with optional usage filter
  static Future<List<Map<String, dynamic>>> fetchVideoAds({
    String? usage,
  }) async {
    try {
      String url = '${ApiService.baseUrl}/video-ads';
      if (usage != null) {
        url += '?usage=$usage';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] && data['data'] != null) {
          // Convert video ads to compatible format
          return List<Map<String, dynamic>>.from(
            (data['data'] as List).map(
              (ad) => {
                'id': ad['id'],
                'title': ad['title'],
                'description': ad['description'],
                'rewardCoins': ad['rewardCoins'],
                'icon': ad['icon'],
                'color': ad['color'],
                'isActive': ad['isActive'],
                'adType': 'video',
                'videoUrl': ad['videoUrl'],
                'thumbnailUrl':
                    ad['thumbnailUrl'] ?? '', // Use empty string if null
                'duration': ad['duration'],
              },
            ),
          );
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching video ads: $e');
      return [];
    }
  }

  /// Fetch all ads (both rewarded and video) - for backward compatibility
  static Future<List<Map<String, dynamic>>> fetchAllAds() async {
    try {
      final rewardedAds = await fetchRewardedAds();
      final videoAds = await fetchVideoAds();

      // Combine both lists
      return [...rewardedAds, ...videoAds];
    } catch (e) {
      debugPrint('Error fetching all ads: $e');
      return getDefaultAds();
    }
  }

  /// Get ads - always fetches fresh from server (both rewarded and video)
  static Future<List<Map<String, dynamic>>> getAds() async {
    return await fetchAllAds();
  }

  /// Get default ads (fallback) - PUBLIC METHOD
  static List<Map<String, dynamic>> getDefaultAds() {
    return [
      {
        'id': '1',
        'adNumber': 1,
        'title': 'Quick Video Ad',
        'description': 'Watch a 15-30 second video ad',
        'rewardCoins': 5,
        'icon': 'play-circle',
        'color': '#701CF5',
        'adProvider': 'admob',
        'adType': 'rewarded',
        'isActive': true,
        'providerConfig': {
          'admob': {
            'adUnitId': 'ca-app-pub-3940256099942544/5224354917',
            'appId': 'ca-app-pub-3940256099942544~3347511713',
          },
        },
      },
      {
        'id': '2',
        'adNumber': 2,
        'title': 'Product Demo',
        'description': 'Watch product demonstration video',
        'rewardCoins': 5,
        'icon': 'video',
        'color': '#FF6B35',
        'adProvider': 'admob',
        'adType': 'rewarded',
        'isActive': true,
        'providerConfig': {
          'admob': {
            'adUnitId': 'ca-app-pub-3940256099942544/5224354917',
            'appId': 'ca-app-pub-3940256099942544~3347511713',
          },
        },
      },
      {
        'id': '3',
        'adNumber': 3,
        'title': 'Interactive Quiz',
        'description': 'Answer quick questions & earn',
        'rewardCoins': 5,
        'icon': 'hand-pointer',
        'color': '#4FACFE',
        'adProvider': 'admob',
        'adType': 'rewarded',
        'isActive': true,
        'providerConfig': {
          'admob': {
            'adUnitId': 'ca-app-pub-3940256099942544/5224354917',
            'appId': 'ca-app-pub-3940256099942544~3347511713',
          },
        },
      },
      {
        'id': '4',
        'adNumber': 4,
        'title': 'Survey Rewards',
        'description': 'Complete a quick survey',
        'rewardCoins': 5,
        'icon': 'clipboard',
        'color': '#43E97B',
        'adProvider': 'admob',
        'adType': 'rewarded',
        'isActive': true,
        'providerConfig': {
          'admob': {
            'adUnitId': 'ca-app-pub-3940256099942544/5224354917',
            'appId': 'ca-app-pub-3940256099942544~3347511713',
          },
        },
      },
      {
        'id': '5',
        'adNumber': 5,
        'title': 'Premium Offer',
        'description': 'Exclusive premium content',
        'rewardCoins': 5,
        'icon': 'star',
        'color': '#FBBF24',
        'adProvider': 'admob',
        'adType': 'rewarded',
        'isActive': true,
        'providerConfig': {
          'admob': {
            'adUnitId': 'ca-app-pub-3244693086681200/6601730347',
            'appId': 'ca-app-pub-3244693086681200~5375559724',
          },
        },
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
