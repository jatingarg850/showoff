import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import 'services/admob_service.dart';
import 'services/api_service.dart';
import 'services/ad_service.dart';
import 'services/rewarded_ad_service.dart';
import 'services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdSelectionScreen extends StatefulWidget {
  final String adType; // 'watch-ads' or 'spin-wheel'

  const AdSelectionScreen({super.key, this.adType = 'watch-ads'});

  @override
  State<AdSelectionScreen> createState() => _AdSelectionScreenState();
}

class _AdSelectionScreenState extends State<AdSelectionScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _adOptions = [];
  bool _adsLoaded = false;
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  BannerAd? _bannerAd;
  bool _bannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAds();
    // Preload ads in background
    _preloadAllAds();
    // Load banner ad
    _loadBannerAd();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _preloadAllAds() async {
    // Preload all 5 ads in background (only for watch-ads)
    if (widget.adType == 'watch-ads') {
      for (int i = 1; i <= 5; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        AdMobService.preloadRewardedAd(adNumber: i);
      }
    }
  }

  Future<void> _loadBannerAd() async {
    try {
      debugPrint('⏳ Loading banner ad...');
      final bannerAd = await AdService.loadBannerAd();
      if (bannerAd != null && mounted) {
        setState(() {
          _bannerAd = bannerAd;
          _bannerAdLoaded = true;
        });
        debugPrint('✅ Banner ad loaded and ready to display');
      } else {
        debugPrint('⚠️ Banner ad returned null');
      }
    } catch (e) {
      debugPrint('❌ Error loading banner ad: $e');
    }
  }

  Future<void> _loadAds() async {
    try {
      // First try to get default ads (always available)
      _adOptions = RewardedAdService.getDefaultAds();

      if (mounted) {
        setState(() {
          _adsLoaded = true;
        });
      }

      // Then try to refresh from server in background
      try {
        List<Map<String, dynamic>> ads = [];

        if (widget.adType == 'watch-ads') {
          // For watch ads, fetch ONLY AdMob rewarded ads (type=watch-ads)
          // Do NOT include video ads - they are separate
          final rewardedAds = await RewardedAdService.fetchRewardedAds(
            type: 'watch-ads',
          );
          ads = rewardedAds;
        } else if (widget.adType == 'spin-wheel') {
          // For spin wheel, fetch BOTH rewarded ads AND video ads with spin-wheel type
          final rewardedAds = await RewardedAdService.fetchRewardedAds(
            type: 'spin-wheel',
          );
          final videoAds = await RewardedAdService.fetchVideoAds(
            usage: 'spin-wheel',
          );
          ads = [...rewardedAds, ...videoAds];
        }

        if (ads.isNotEmpty && mounted) {
          setState(() {
            _adOptions = ads;
          });
        }
      } catch (e) {
        debugPrint('Background refresh failed, using defaults: $e');
      }
    } catch (e) {
      debugPrint('Error loading ads: $e');
      if (mounted) {
        setState(() {
          _adOptions = RewardedAdService.getDefaultAds();
          _adsLoaded = true;
        });
      }
    }
  }

  Future<void> _watchAd(Map<String, dynamic> ad) async {
    setState(() => _isLoading = true);

    try {
      final adType = ad['adType'] ?? 'rewarded';
      final adNumber = ad['adNumber'] ?? 1;
      final provider = ad['adProvider'] ?? 'admob';
      final reward = RewardedAdService.getRewardCoins(ad);

      debugPrint(
        '🎬 Watching ad: Type=$adType, Number=$adNumber (Provider: $provider, Reward: $reward coins)',
      );

      // Track ad impression
      if (adType == 'video') {
        // Track video ad view (but don't complete yet)
        await _trackVideoAdView(ad['id']);
      } else {
        // Track rewarded ad click
        await RewardedAdService.trackAdClick(adNumber);
      }

      // Show provider-specific ad
      bool adWatched = false;

      if (adType == 'video') {
        // Show video ad
        adWatched = await _showVideoAd(ad);
      } else if (provider == 'admob') {
        // Show AdMob rewarded ad with specific ad number
        adWatched = await AdMobService.showRewardedAd(adNumber: adNumber);
      } else if (provider == 'meta') {
        // For Meta, show AdMob as fallback (Meta SDK integration would go here)
        debugPrint('📱 Meta provider - using AdMob fallback');
        adWatched = await AdMobService.showRewardedAd(adNumber: adNumber);
      } else if (provider == 'custom' || provider == 'third-party') {
        // For custom providers, show AdMob as fallback
        debugPrint('🔧 Custom provider - using AdMob fallback');
        adWatched = await AdMobService.showRewardedAd(adNumber: adNumber);
      } else {
        // Default to AdMob
        adWatched = await AdMobService.showRewardedAd(adNumber: adNumber);
      }

      if (!adWatched) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ad not available. Please try again later.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Call backend to award coins (flexible reward)
      // For video ads, this endpoint handles both tracking and coin awarding
      final response = adType == 'video'
          ? await _watchVideoAd(ad['id'])
          : await ApiService.watchAd(adNumber: adNumber);

      // Track conversion for rewarded ads only (video ads already tracked in _watchVideoAd)
      if (adType != 'video') {
        await RewardedAdService.trackAdConversion(adNumber);
      }

      if (mounted) {
        setState(() => _isLoading = false);

        if (response['success']) {
          // For spin-wheel type, show success dialog with spin reward
          if (widget.adType == 'spin-wheel') {
            _showSpinRewardDialog();
          } else {
            // For watch-ads type, show success dialog with coins earned
            final coinsEarned = response['coinsEarned'] ?? reward;
            _showSuccessDialog(coinsEarned, ad['title'] ?? 'Ad');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to watch ad'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<bool> _showVideoAd(Map<String, dynamic> ad) async {
    try {
      final videoUrl = ad['videoUrl'] as String?;
      if (videoUrl == null || videoUrl.isEmpty) {
        debugPrint('❌ Video URL is empty');
        return false;
      }

      debugPrint('🎬 Loading video ad: $videoUrl');

      // Dispose previous controller if any
      _videoController?.dispose();
      _videoInitialized = false;

      // Create video controller
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      // Initialize controller
      await _videoController!.initialize();

      if (!mounted) return false;

      setState(() {
        _videoInitialized = true;
      });

      // Set video properties
      _videoController!.setLooping(false);
      _videoController!.setVolume(1.0);

      bool completed = false;
      Completer<bool> completionCompleter = Completer<bool>();

      // Add listener to detect video completion
      void onVideoStateChanged() {
        if (_videoController != null &&
            _videoController!.value.isInitialized &&
            _videoController!.value.position >=
                _videoController!.value.duration &&
            !completionCompleter.isCompleted) {
          debugPrint('✅ Video completed via listener');
          completed = true;
          completionCompleter.complete(true);
          // Auto-close dialog after video completes
          if (mounted) {
            Navigator.pop(context);
          }
        }
      }

      _videoController!.addListener(onVideoStateChanged);

      // Show video player dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(0),
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              // Video player - full screen
              if (_videoInitialized)
                SizedBox.expand(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_videoController!),
                        // Play button overlay (shows until video starts)
                        if (!_videoController!.value.isPlaying)
                          Container(
                            color: Colors.black.withValues(alpha: 0.3),
                            child: Center(
                              child: IconButton(
                                icon: const Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.white,
                                  size: 80,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _videoController!.play();
                                  });
                                },
                              ),
                            ),
                          ),
                        // Progress bar at bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: VideoProgressIndicator(
                            _videoController!,
                            allowScrubbing: false,
                            colors: VideoProgressColors(
                              playedColor: Colors.red,
                              bufferedColor: Colors.grey.withValues(alpha: 0.5),
                              backgroundColor: Colors.grey.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Loading state
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading ${ad['title'] ?? 'video'}...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              // Video info overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.9),
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad['title'] ?? 'Video Ad',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ad['description'] ?? 'Watch this video to earn rewards',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      // Start playing video
      if (_videoController != null && _videoInitialized) {
        _videoController!.play();
        debugPrint('▶️ Video started playing');

        // Wait for completion or timeout
        try {
          await Future.any([
            completionCompleter.future,
            Future.delayed(
              Duration(seconds: (ad['duration'] ?? 30) + 5),
            ), // Add 5 second buffer
          ]);
        } catch (e) {
          debugPrint('⚠️ Completion wait error: $e');
        }

        completed = true;
      }

      // Remove listener
      _videoController?.removeListener(onVideoStateChanged);

      return completed;
    } catch (e) {
      debugPrint('❌ Error showing video ad: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> _watchVideoAd(String videoAdId) async {
    try {
      final token = await StorageService.getToken();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/video-ads/$videoAdId/complete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {'success': false, 'message': 'Failed to complete video ad'};
    } catch (e) {
      debugPrint('Error completing video ad: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<void> _trackVideoAdView(String videoAdId) async {
    try {
      final token = await StorageService.getToken();
      await http.post(
        Uri.parse('${ApiService.baseUrl}/video-ads/$videoAdId/view'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      debugPrint('Error tracking video ad view: $e');
    }
  }

  void _showSuccessDialog(int coinsEarned, String adTitle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Congratulations!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'You earned $coinsEarned coins from $adTitle!',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(
                      context,
                      true,
                    ); // Return to wallet with refresh
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF701CF5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Awesome!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSpinRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.casino,
                  color: Colors.purple.shade600,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Congratulations!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'You earned 1 free spin!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context, true); // Close ad selection screen
                    // Spin wheel screen will handle the spin refill
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Spin Now!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Watch Ads & Earn',
          style: TextStyle(
            color: Color(0xFF701CF5),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: !_adsLoaded
          ? const Center(child: CircularProgressIndicator())
          : _adOptions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.ads_click, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No ads available',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF701CF5), Color(0xFF7C3AED)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Earn Coins by Watching Ads',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose an ad to watch and earn coins instantly!',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      const Text(
                        'Select an Ad',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Ad options list
                      ...List.generate(_adOptions.length, (index) {
                        final ad = _adOptions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildAdCard(ad),
                        );
                      }),
                      // Add bottom padding for banner ad
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
                // Banner ad at bottom
                if (_bannerAdLoaded && _bannerAd != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.white,
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildAdCard(Map<String, dynamic> ad) {
    // Get dynamic values from ad
    final String colorHex = ad['color'] ?? '#667eea';
    final Color cardColor = _hexToColor(colorHex);
    final String iconName = ad['icon'] ?? 'gift';
    final IconData cardIcon = _getIconFromName(iconName);
    final String title = ad['title'] ?? 'Ad ${ad['adNumber'] ?? 1}';
    final String description = ad['description'] ?? 'Watch this ad';
    final int reward = RewardedAdService.getRewardCoins(ad);
    final String provider = ad['adProvider'] ?? 'admob';
    final String adType = ad['adType'] ?? 'rewarded';
    final bool isActive = ad['isActive'] ?? true;

    return InkWell(
      onTap: isActive ? () => _watchAd(ad) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? Colors.grey.shade200 : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Icon, Title, Reward
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(cardIcon, color: cardColor, size: 32),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isActive ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                // Reward badge - only show for watch-ads, not for spin-wheel
                if (widget.adType != 'spin-wheel')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFFBBF24)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+$reward',
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // For spin-wheel, show spin icon instead
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF8B5CF6)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.casino, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Free Spin',
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Ad type and provider badges
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  // Ad type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: adType == 'video'
                          ? Colors.blue.withValues(alpha: 0.15)
                          : Colors.purple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      adType == 'video' ? '🎬 Video Ad' : '📺 Rewarded Ad',
                      style: TextStyle(
                        fontSize: 12,
                        color: adType == 'video' ? Colors.blue : Colors.purple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Provider badge (only for rewarded ads)
                  if (adType != 'video' && provider != 'admob')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Provider: ${provider.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: cardColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to convert hex color to Color
  Color _hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) {
        hexString = hexString.replaceFirst('#', '');
      }
      if (hexString.length != 6) {
        return const Color(0xFF667eea); // Default color
      }
      buffer.write('ff');
      buffer.write(hexString);
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return const Color(0xFF667eea); // Default color on error
    }
  }

  // Helper function to get icon from name
  IconData _getIconFromName(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'gift':
        return Icons.card_giftcard;
      case 'star':
        return Icons.star;
      case 'heart':
        return Icons.favorite;
      case 'fire':
        return Icons.local_fire_department;
      case 'trophy':
        return Icons.emoji_events;
      case 'coins':
        return Icons.monetization_on;
      case 'gem':
        return Icons.diamond;
      case 'crown':
        return Icons.workspace_premium;
      case 'zap':
        return Icons.flash_on;
      case 'target':
        return Icons.track_changes;
      case 'play-circle':
        return Icons.play_circle_filled;
      case 'video':
        return Icons.video_library;
      case 'hand-pointer':
        return Icons.touch_app;
      case 'clipboard':
        return Icons.assignment;
      default:
        return Icons.play_circle_filled;
    }
  }
}
