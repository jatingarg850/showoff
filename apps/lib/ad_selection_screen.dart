import 'package:flutter/material.dart';
import 'services/admob_service.dart';
import 'services/api_service.dart';
import 'services/rewarded_ad_service.dart';

class AdSelectionScreen extends StatefulWidget {
  const AdSelectionScreen({super.key});

  @override
  State<AdSelectionScreen> createState() => _AdSelectionScreenState();
}

class _AdSelectionScreenState extends State<AdSelectionScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _adOptions = [];
  bool _adsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  Future<void> _loadAds() async {
    try {
      final ads = await RewardedAdService.getAds();
      if (mounted) {
        setState(() {
          _adOptions = ads;
          _adsLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading ads: $e');
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
      // Track ad impression
      await RewardedAdService.trackAdClick(ad['adNumber'] ?? 1);

      // Show AdMob rewarded ad
      final adWatched = await AdMobService.showRewardedAd();

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

      // Track conversion
      await RewardedAdService.trackAdConversion(ad['adNumber'] ?? 1);

      // Call backend to award coins
      final response = await ApiService.watchAd();

      if (mounted) {
        setState(() => _isLoading = false);

        if (response['success']) {
          // Show success dialog
          _showSuccessDialog(
            response['coinsEarned'] ?? ad['rewardCoins'] ?? 10,
          );
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

  void _showSuccessDialog(int coinsEarned) {
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
                'You earned $coinsEarned coins!',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
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
          : SingleChildScrollView(
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
                ],
              ),
            ),
    );
  }

  Widget _buildAdCard(Map<String, dynamic> ad) {
    // Get default color if not provided
    final Color cardColor = ad['color'] ?? const Color(0xFF701CF5);
    final IconData cardIcon = ad['icon'] ?? Icons.play_circle_filled;
    final String title = ad['title'] ?? 'Ad ${ad['adNumber'] ?? 1}';
    final String description = ad['description'] ?? 'Watch this ad';
    final int reward = ad['rewardCoins'] ?? ad['reward'] ?? 10;
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
        child: Row(
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

            // Reward badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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
}
