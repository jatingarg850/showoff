import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

class AdService {
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // Replace with your actual Android Ad Unit ID
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    } else if (Platform.isIOS) {
      // Replace with your actual iOS Ad Unit ID
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Load an interstitial ad
  static Future<InterstitialAd?> loadInterstitialAd() async {
    final completer = Completer<InterstitialAd?>();

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Interstitial ad loaded successfully');
          if (!completer.isCompleted) {
            completer.complete(ad);
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Interstitial ad failed to load: $error');
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      ),
    );

    // Wait for the ad to load with a timeout
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('⏱️ Ad load timeout after 10 seconds');
        return null;
      },
    );
  }

  // Show interstitial ad
  static void showInterstitialAd(
    InterstitialAd? ad, {
    VoidCallback? onAdDismissed,
  }) {
    if (ad == null) {
      debugPrint('❌ Cannot show ad: ad is null');
      return; // Don't call callback - ad wasn't shown
    }

    try {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('✅ Ad dismissed by user');
          ad.dispose();
          onAdDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('❌ Failed to show interstitial ad: $error');
          ad.dispose();
          // Don't call callback - ad failed to show
        },
      );

      ad.show();
      debugPrint('✅ Ad shown successfully');
    } catch (e) {
      debugPrint('❌ Exception while showing ad: $e');
      ad.dispose();
      // Don't call callback - ad failed to show
    }
  }
}
