import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../welcome_screen.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class BioScreen extends StatefulWidget {
  final String username;
  final String displayName;
  final List<String> interests;

  const BioScreen({
    super.key,
    required this.username,
    required this.displayName,
    required this.interests,
  });

  @override
  State<BioScreen> createState() => _BioScreenState();
}

class _BioScreenState extends State<BioScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();
  String? _referralError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 1.0, // 100% progress (4 of 4 steps)
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF701CF5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Title
            const Text(
              'Bio',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            // Underline
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF701CF5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Subtitle
            const Text(
              'Say something about yourself',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 32),

            // About you label
            const Text(
              'About you',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            // Bio text area
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF701CF5), // Purple
                    Color(0xFF3E98E4), // Blue
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(2), // Border width
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _bioController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: 'Write something about yourself',
                    hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Referral code section
            const Text(
              'Referral Code (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Have a referral code? Enter it to earn 20 coins!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 12),

            // Referral code input
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF701CF5), Color(0xFF3E98E4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _referralCodeController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter referral code',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    errorText: _referralError,
                    errorStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                  onChanged: (value) {
                    if (_referralError != null) {
                      setState(() {
                        _referralError = null;
                      });
                    }
                  },
                ),
              ),
            ),

            const Spacer(),

            // Continue button
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(bottom: 40),
              decoration: BoxDecoration(
                color: const Color(0xFF701CF5),
                borderRadius: BorderRadius.circular(28),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (_bioController.text.trim().isEmpty) return;

                  final profileProvider = Provider.of<ProfileProvider>(
                    context,
                    listen: false,
                  );
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF701CF5),
                        ),
                      ),
                    ),
                  );

                  // Update profile with all collected data
                  final success = await profileProvider.updateProfile(
                    username: widget.username,
                    displayName: widget.displayName,
                    bio: _bioController.text.trim(),
                    interests: widget.interests,
                  );

                  if (!mounted) return;

                  if (success) {
                    // Apply referral code if provided
                    int bonusCoins = 50; // Profile completion bonus
                    if (_referralCodeController.text.trim().isNotEmpty) {
                      final referralResponse =
                          await ApiService.applyReferralCode(
                            _referralCodeController.text.trim().toUpperCase(),
                          );
                      if (referralResponse['success']) {
                        bonusCoins += 20; // Add referral bonus
                      }
                    }

                    Navigator.pop(context); // Close loading

                    // Refresh user data
                    await authProvider.refreshUser();
                    _showCongratulationsPopup(bonusCoins);
                  } else {
                    Navigator.pop(context); // Close loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(profileProvider.error ?? 'Update failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCongratulationsPopup(int bonusCoins) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 450,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),

                // Coins image with +50 positioned below and to the right
                SizedBox(
                  width: 140,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Coin image with blue border
                      Positioned(
                        top: 0,
                        left: 25,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF3E98E4),
                              width: 3,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/setup/coins.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Bonus coins text positioned to the bottom right of the coin
                      Positioned(
                        bottom: 20,
                        right: 0,
                        child: Text(
                          '+$bonusCoins',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Congratulations title
                const Text(
                  'Congratulations',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 16),

                // Description text
                Text(
                  bonusCoins > 50
                      ? 'You have earned +$bonusCoins coins! (+50 for profile completion + 20 referral bonus)'
                      : 'You have earned +$bonusCoins coins for completing your profile!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                // Continue button
                Container(
                  width: double.infinity,
                  height: 56,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF701CF5),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close bottom sheet
                      // Navigate to welcome screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }
}
