import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String?
  _rewardedAdUnitId;

  static String
  get rewardedAdUnitId {
    if (_rewardedAdUnitId !=
        null) {
      return _rewardedAdUnitId!;
    }

    // Test Ad Unit IDs
    if (Platform.isAndroid) {
      _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      _rewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    } else {
      _rewardedAdUnitId = '';
    }
    return _rewardedAdUnitId!;
  }

  // Initialize AdMob
  static Future<
    void
  >
  initialize() async {
    await MobileAds.instance.initialize();
  }

  // Load and show rewarded ad
  static Future<
    bool
  >
  showRewardedAd() async {
    try {
      RewardedAd? rewardedAd;
      bool adWatched = false;

      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded:
              (
                ad,
              ) {
                rewardedAd = ad;

                // Set up callbacks
                ad.fullScreenContentCallback = FullScreenContentCallback(
                  onAdDismissedFullScreenContent:
                      (
                        ad,
                      ) {
                        ad.dispose();
                      },
                  onAdFailedToShowFullScreenContent:
                      (
                        ad,
                        error,
                      ) {
                        ad.dispose();
                      },
                );

                // Show the ad
                ad.show(
                  onUserEarnedReward:
                      (
                        ad,
                        reward,
                      ) {
                        adWatched = true;
                        print(
                          'User earned reward: ${reward.amount} ${reward.type}',
                        );
                      },
                );
              },
          onAdFailedToLoad:
              (
                error,
              ) {
                print(
                  'RewardedAd failed to load: $error',
                );
              },
        ),
      );

      // Wait for ad to complete (max 60 seconds)
      int waitTime = 0;
      while (rewardedAd ==
              null &&
          waitTime <
              60) {
        await Future.delayed(
          const Duration(
            seconds: 1,
          ),
        );
        waitTime++;
      }

      // Wait for user to watch the ad
      if (rewardedAd !=
          null) {
        waitTime = 0;
        while (!adWatched &&
            waitTime <
                120) {
          await Future.delayed(
            const Duration(
              seconds: 1,
            ),
          );
          waitTime++;
        }
      }

      return adWatched;
    } catch (
      e
    ) {
      print(
        'Error showing rewarded ad: $e',
      );
      return false;
    }
  }

  // Alternative: Load ad first, then show when ready
  static Future<
    RewardedAd?
  >
  loadRewardedAd() async {
    try {
      RewardedAd? rewardedAd;

      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded:
              (
                ad,
              ) {
                rewardedAd = ad;
              },
          onAdFailedToLoad:
              (
                error,
              ) {
                print(
                  'RewardedAd failed to load: $error',
                );
              },
        ),
      );

      // Wait for ad to load (max 10 seconds)
      int waitTime = 0;
      while (rewardedAd ==
              null &&
          waitTime <
              10) {
        await Future.delayed(
          const Duration(
            seconds: 1,
          ),
        );
        waitTime++;
      }

      return rewardedAd;
    } catch (
      e
    ) {
      print(
        'Error loading rewarded ad: $e',
      );
      return null;
    }
  }

  // Show pre-loaded ad
  static Future<
    bool
  >
  showLoadedAd(
    RewardedAd ad,
  ) async {
    bool adWatched = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent:
          (
            ad,
          ) {
            ad.dispose();
          },
      onAdFailedToShowFullScreenContent:
          (
            ad,
            error,
          ) {
            ad.dispose();
          },
    );

    await ad.show(
      onUserEarnedReward:
          (
            ad,
            reward,
          ) {
            adWatched = true;
            print(
              'User earned reward: ${reward.amount} ${reward.type}',
            );
          },
    );

    return adWatched;
  }
}
