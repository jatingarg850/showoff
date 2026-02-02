import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdMobService {
  static final Map<int, RewardedAd?> _rewardedAds = {};
  static final Map<int, bool> _isAdLoading = {};

  // Test Ad Unit IDs (Google's official test ads)
  static const String _androidTestAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _iosTestAdUnitId =
      'ca-app-pub-3940256099942544/1712485313';

  /// Get ad unit ID for a specific ad number
  static String getRewardedAdUnitId(int adNumber) {
    // Use test Ad Unit IDs for development
    // Replace with production IDs when deploying to Play Store
    if (Platform.isAndroid) {
      return _androidTestAdUnitId;
    } else if (Platform.isIOS) {
      return _iosTestAdUnitId;
    }
    return _androidTestAdUnitId;
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

  /// Load rewarded ad in background for a specific ad number
  static Future<void> preloadRewardedAd({int adNumber = 1}) async {
    if (_isAdLoading[adNumber] == true || _rewardedAds[adNumber] != null) {
      debugPrint('⏭️ Ad $adNumber already loading or loaded');
      return;
    }

    _isAdLoading[adNumber] = true;
    try {
      final adUnitId = getRewardedAdUnitId(adNumber);
      debugPrint('📥 Preloading ad $adNumber with unit: $adUnitId');

      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAds[adNumber] = ad;
            _isAdLoading[adNumber] = false;
            debugPrint('✅ Rewarded ad $adNumber preloaded successfully');
          },
          onAdFailedToLoad: (error) {
            _isAdLoading[adNumber] = false;
            debugPrint('❌ Rewarded ad $adNumber failed to load: $error');
          },
        ),
      );
    } catch (e) {
      _isAdLoading[adNumber] = false;
      debugPrint('❌ Error preloading rewarded ad $adNumber: $e');
    }
  }

  /// Show rewarded ad with proper callback handling for a specific ad number
  /// Returns true only if ad was actually watched/completed
  static Future<bool> showRewardedAd({int adNumber = 1}) async {
    try {
      debugPrint('🎬 Attempting to show ad $adNumber');

      bool adWatched = false;

      // If no preloaded ad, load one now
      if (_rewardedAds[adNumber] == null) {
        debugPrint('📺 No preloaded ad $adNumber, loading now...');
        adWatched = await _loadAndShowRewardedAd(adNumber);
      } else {
        debugPrint('📺 Showing preloaded ad $adNumber...');
        adWatched = await _showAd(_rewardedAds[adNumber]!, adNumber);
      }

      // Preload next ad for future use
      Future.delayed(const Duration(seconds: 1), () {
        preloadRewardedAd(adNumber: adNumber);
      });

      return adWatched;
    } catch (e) {
      debugPrint('❌ Error showing rewarded ad $adNumber: $e');
      return false;
    }
  }

  /// Load and show rewarded ad for a specific ad number
  /// Returns true only if ad was actually watched/completed
  static Future<bool> _loadAndShowRewardedAd(int adNumber) async {
    try {
      RewardedAd? rewardedAd;
      bool adLoaded = false;

      final adUnitId = getRewardedAdUnitId(adNumber);
      debugPrint('📥 Loading ad $adNumber with unit: $adUnitId');

      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            rewardedAd = ad;
            adLoaded = true;
            debugPrint('✅ Rewarded ad $adNumber loaded');
          },
          onAdFailedToLoad: (error) {
            adLoaded = true; // Mark as done even if failed
            debugPrint('❌ Rewarded ad $adNumber failed to load: $error');
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
        debugPrint('📺 Showing loaded ad $adNumber');
        return await _showAd(rewardedAd!, adNumber);
      } else {
        debugPrint('⚠️ Ad $adNumber failed to load within timeout');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error in _loadAndShowRewardedAd for ad $adNumber: $e');
      return false;
    }
  }

  /// Show ad with proper callbacks for a specific ad number
  /// Returns true only if ad was actually watched/completed
  static Future<bool> _showAd(RewardedAd ad, int adNumber) async {
    try {
      bool adCompleted = false;
      bool adWatched = false;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('📺 Ad $adNumber shown');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('📺 Ad $adNumber dismissed');
          ad.dispose();
          _rewardedAds[adNumber] = null;
          adCompleted = true;
          // Only mark as watched if user didn't skip immediately
          // (we check this via the reward callback)
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('❌ Ad $adNumber failed to show: $error');
          ad.dispose();
          _rewardedAds[adNumber] = null;
          adCompleted = true;
        },
        onAdImpression: (ad) {
          debugPrint('👁️ Ad $adNumber impression');
        },
      );

      await ad.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint(
            '🎁 User earned reward from ad $adNumber: ${reward.amount} ${reward.type}',
          );
          adWatched = true; // Mark as watched only when reward is earned
        },
      );

      // Wait for ad to complete (max 120 seconds)
      int waitTime = 0;
      while (!adCompleted && waitTime < 120) {
        await Future.delayed(const Duration(seconds: 1));
        waitTime++;
      }

      if (waitTime >= 120) {
        debugPrint('⚠️ Ad $adNumber completion timeout');
        ad.dispose();
        _rewardedAds[adNumber] = null;
      }

      debugPrint('✅ Ad $adNumber watched: $adWatched');
      return adWatched;
    } catch (e) {
      debugPrint('❌ Error showing ad $adNumber: $e');
      return false;
    }
  }

  /// Dispose of any loaded ads
  static void dispose() {
    for (var ad in _rewardedAds.values) {
      ad?.dispose();
    }
    _rewardedAds.clear();
    _isAdLoading.clear();
    debugPrint('🧹 AdMob ads disposed');
  }
}
