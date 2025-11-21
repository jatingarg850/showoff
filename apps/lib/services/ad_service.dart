import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class AdService {
  static String
  get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // Replace with your actual Android Ad Unit ID
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    } else if (Platform.isIOS) {
      // Replace with your actual iOS Ad Unit ID
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    }
    throw UnsupportedError(
      'Unsupported platform',
    );
  }

  static String
  get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    }
    throw UnsupportedError(
      'Unsupported platform',
    );
  }

  // Load an interstitial ad
  static Future<
    InterstitialAd?
  >
  loadInterstitialAd() async {
    InterstitialAd? interstitialAd;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded:
            (
              ad,
            ) {
              interstitialAd = ad;
              print(
                'Interstitial ad loaded',
              );
            },
        onAdFailedToLoad:
            (
              error,
            ) {
              print(
                'Interstitial ad failed to load: $error',
              );
            },
      ),
    );

    return interstitialAd;
  }

  // Show interstitial ad
  static void
  showInterstitialAd(
    InterstitialAd? ad, {
    VoidCallback? onAdDismissed,
  }) {
    if (ad ==
        null) {
      print(
        'Interstitial ad is not ready yet',
      );
      onAdDismissed?.call();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent:
          (
            ad,
          ) {
            ad.dispose();
            onAdDismissed?.call();
          },
      onAdFailedToShowFullScreenContent:
          (
            ad,
            error,
          ) {
            print(
              'Failed to show interstitial ad: $error',
            );
            ad.dispose();
            onAdDismissed?.call();
          },
    );

    ad.show();
  }
}
