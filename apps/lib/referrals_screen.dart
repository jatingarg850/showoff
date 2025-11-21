import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'referral_transaction_history_screen.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';

class ReferralsScreen
    extends
        StatefulWidget {
  const ReferralsScreen({
    super.key,
  });

  @override
  State<
    ReferralsScreen
  >
  createState() => _ReferralsScreenState();
}

class _ReferralsScreenState
    extends
        State<
          ReferralsScreen
        > {
  int
  _monthlyCoins = 0;
  int
  _lifetimeCoins = 0;
  bool
  _isLoading = true;

  @override
  void
  initState() {
    super.initState();
    _loadReferralStats();
  }

  Future<
    void
  >
  _loadReferralStats() async {
    try {
      final response = await ApiService.getTransactions();
      if (response['success']) {
        final transactions =
            List<
              Map<
                String,
                dynamic
              >
            >.from(
              response['data'] ??
                  [],
            );

        // Calculate monthly and lifetime referral coins
        final now = DateTime.now();
        final monthStart = DateTime(
          now.year,
          now.month,
          1,
        );

        int monthly = 0;
        int lifetime = 0;

        for (final transaction in transactions) {
          if (transaction['type'] ==
              'referral') {
            final amount =
                (transaction['amount'] ??
                        0)
                    as num;
            lifetime += amount.abs().toInt();

            final createdAt = DateTime.parse(
              transaction['createdAt'],
            );
            if (createdAt.isAfter(
              monthStart,
            )) {
              monthly += amount.abs().toInt();
            }
          }
        }

        setState(
          () {
            _monthlyCoins = monthly;
            _lifetimeCoins = lifetime;
            _isLoading = false;
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error loading referral stats: $e',
      );
      setState(
        () {
          _isLoading = false;
        },
      );
    }
  }

  void
  _shareReferralCode(
    String referralCode,
  ) {
    final message =
        'Join ShowOff.life and earn coins! Use my referral code: $referralCode\n\n'
        'Download the app and start earning today!\n'
        'https://showoff.life/download';

    Share.share(
      message,
      subject: 'Join ShowOff.life',
    );
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    final authProvider =
        Provider.of<
          AuthProvider
        >(
          context,
        );
    final user = authProvider.user;

    if (user ==
        null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final referralCode =
        user['referralCode'] ??
        'LOADING';
    final referralCount =
        user['referralCount'] ??
        0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(
            context,
          ),
        ),
        title: const Text(
          'Referrals & Invites',
          style: TextStyle(
            color: Color(
              0xFF8B5CF6,
            ),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),

            // Referral Code Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(
                    0xFF8B5CF6,
                  ),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(
                  25,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    referralCode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: referralCode,
                        ),
                      );
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Referral code copied to clipboard!',
                          ),
                          duration: Duration(
                            seconds: 2,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(
                        8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF8B5CF6,
                        ),
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                      ),
                      child: const Icon(
                        Icons.copy,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // Share Link Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(
                      0xFF8B5CF6,
                    ),
                    Color(
                      0xFF7C3AED,
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: ElevatedButton(
                onPressed: () => _shareReferralCode(
                  referralCode,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'SHARE LINK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // View Transaction Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(
                      0xFF8B5CF6,
                    ),
                    Color(
                      0xFF7C3AED,
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (
                            context,
                          ) => const ReferralTransactionHistoryScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                  ),
                ),
                child: const Text(
                  'VIEW TRANSACTION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            // Statistics Cards
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(
                        0xFF8B5CF6,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'TOTAL\nREFERRALS',
                          referralCount.toString(),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: _buildStatCard(
                          'MONTHLY\nCOINS',
                          _monthlyCoins.toString(),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: _buildStatCard(
                          'LIFETIME\nCOINS',
                          _lifetimeCoins.toString(),
                        ),
                      ),
                    ],
                  ),

            const SizedBox(
              height: 24,
            ),

            // Referrals Tips Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                20,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFE9D5FF,
                ),
                borderRadius: BorderRadius.circular(
                  16,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'REFERRALS TIPS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // Tip 1
                  const Text(
                    '1. Referral Rewards',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    '• Reward: 5 coins per referral\n'
                    '• Example: If you refer 10 friends, you earn 10 x 5 = 50 coins.\n'
                    '• Each successful referral earns you 5 coins instantly!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // Tip 2
                  const Text(
                    '2. How to Refer',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    '• Share your unique referral code with friends\n'
                    '• They must use your code when signing up\n'
                    '• You receive 5 coins once they complete registration\n'
                    '• No limit on how many friends you can refer!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // Tip 3
                  const Text(
                    '3. Monthly Cap',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text(
                    '• Limit: A user can earn a maximum of 50,000 coins from referrals per month.\n'
                    '• This prevents abuse while keeping the system rewarding.\n'
                    '• Display: "Monthly maximum: 50,000 coins "',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.4,
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

  Widget
  _buildStatCard(
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFFE9D5FF,
        ),
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
