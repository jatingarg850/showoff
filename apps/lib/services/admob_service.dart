import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdMobService {
  static String? _rewardedAdUnitId;
  static RewardedAd? _rewardedAd;
  static bool _isAdLoading = false;

  static String get rewardedAdUnitId {
    if (_rewardedAdUnitId != null) {
      return _rewardedAdUnitId!;
    }

    // Use test Ad Unit IDs for development
    // Replace with production IDs when deploying to Play Store
    if (Platform.isAndroid) {
      _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      _rewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    } else {
      _rewardedAdUnitId = '';
    }
    return _rewardedAdUnitId!;
  }

  /// Initialize AdMob
  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      debugPrint('✅ AdMob initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing AdMob: $e');
    }
  }

  /// Load rewarded ad in background
  static Future<void> preloadRewardedAd() async {
    if (_isAdLoading || _rewardedAd != null) {
      return;
    }

    _isAdLoading = true;
    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isAdLoading = false;
            debugPrint('✅ Rewarded ad preloaded successfully');
          },
          onAdFailedToLoad: (error) {
            _isAdLoading = false;
            debugPrint('❌ Rewarded ad failed to load: $error');
          },
        ),
      );
    } catch (e) {
      _isAdLoading = false;
      debugPrint('❌ Error preloading rewarded ad: $e');
    }
  }

  /// Show rewarded ad with proper callback handling
  static Future<bool> showRewardedAd() async {
    try {
      // If no preloaded ad, load one now
      if (_rewardedAd == null) {
        debugPrint('📺 No preloaded ad, loading now...');
        await _loadAndShowRewardedAd();
      } else {
        debugPrint('📺 Showing preloaded ad...');
        await _showAd(_rewardedAd!);
      }

      // Preload next ad for future use
      Future.delayed(const Duration(seconds: 1), () {
        preloadRewardedAd();
      });

      return true;
    } catch (e) {
      debugPrint('❌ Error showing rewarded ad: $e');
      return false;
    }
  }

  /// Load and show rewarded ad
  static Future<void> _loadAndShowRewardedAd() async {
    try {
      RewardedAd? rewardedAd;
      bool adLoaded = false;

      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            rewardedAd = ad;
            adLoaded = true;
            debugPrint('✅ Rewarded ad loaded');
          },
          onAdFailedToLoad: (error) {
            adLoaded = true; // Mark as done even if failed
            debugPrint('❌ Rewarded ad failed to load: $error');
          },
        ),
      );

      // Wait for ad to load (max 10 seconds)
      int waitTime = 0;
      while (!adLoaded && waitTime < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        waitTime++;
      }

      if (rewardedAd != null) {
        await _showAd(rewardedAd!);
      } else {
        debugPrint('⚠️ Ad failed to load within timeout');
      }
    } catch (e) {
      debugPrint('❌ Error in _loadAndShowRewardedAd: $e');
    }
  }

  /// Show ad with proper callbacks
  static Future<void> _showAd(RewardedAd ad) async {
    try {
      bool adCompleted = false;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('📺 Ad shown');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('📺 Ad dismissed');
          ad.dispose();
          _rewardedAd = null;
          adCompleted = true;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('❌ Ad failed to show: $error');
          ad.dispose();
          _rewardedAd = null;
          adCompleted = true;
        },
        onAdImpression: (ad) {
          debugPrint('👁️ Ad impression');
        },
      );

      await ad.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('🎁 User earned reward: ${reward.amount} ${reward.type}');
        },
      );

      // Wait for ad to complete (max 120 seconds)
      int waitTime = 0;
      while (!adCompleted && waitTime < 120) {
        await Future.delayed(const Duration(seconds: 1));
        waitTime++;
      }

      if (waitTime >= 120) {
        debugPrint('⚠️ Ad completion timeout');
        ad.dispose();
        _rewardedAd = null;
      }
    } catch (e) {
      debugPrint('❌ Error showing ad: $e');
    }
  }

  /// Dispose of any loaded ads
  static void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
