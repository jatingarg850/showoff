import 'package:flutter/material.dart';
import 'spin_wheel_screen.dart';

class WalletScreen
    extends
        StatelessWidget {
  const WalletScreen({
    super.key,
  });

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Purple gradient header
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(
                      0xFF701CF5,
                    ),
                    Color(
                      0xFF701CF5,
                    ),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(
                    30,
                  ),
                  bottomRight: Radius.circular(
                    30,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Available Balance title
                    const Text(
                      'Available Balance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // Balance amount with coin icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '1345',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Image.asset(
                          'assets/setup/coins.png',
                          width: 32,
                          height: 32,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    // USD equivalent
                    const Text(
                      '=\$600',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      context,
                                    ) => const SpinWheelScreen(),
                              ),
                            );
                          },
                          child: _buildActionButtonWithImage(
                            'assets/wallet_screen/spinthewheel.png',
                          ),
                        ),
                        _buildActionButtonWithImage(
                          'assets/wallet_screen/add.png',
                        ),
                        _buildActionButtonWithImage(
                          'assets/wallet_screen/monetization.png',
                        ),
                        _buildActionButtonWithImage(
                          'assets/wallet_screen/ads.png',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Transaction history section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(
                  20,
                ),
                child: Column(
                  children: [
                    // Transaction history header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transaction history',
                          style: TextStyle(
                            color: Color(
                              0xFF8B5CF6,
                            ),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // Transaction list
                    Expanded(
                      child: ListView(
                        children: [
                          _buildTransactionItem(
                            'Shares',
                            '30/09/25',
                            '12:34 AM',
                            '+\$15.30',
                            true,
                          ),
                          _buildTransactionItem(
                            'Uploads',
                            '30/09/25',
                            '12:34 AM',
                            '-\$15.30',
                            false,
                          ),
                          _buildTransactionItem(
                            'Withdrawal',
                            '30/09/25',
                            '12:34 AM',
                            '-\$25.30',
                            false,
                          ),
                          _buildTransactionItem(
                            'Gift Recieved',
                            '30/09/25',
                            '12:34 AM',
                            '+\$215.30',
                            true,
                          ),
                          _buildTransactionItem(
                            'Topped up Wallet',
                            '30/09/25',
                            '12:34 AM',
                            '+\$15.30',
                            true,
                          ),
                          _buildTransactionItem(
                            'Withdrawal',
                            '30/09/25',
                            '12:34 AM',
                            '-\$15.30',
                            false,
                          ),
                          _buildTransactionItem(
                            'Ads',
                            '30/09/25',
                            '12:34 AM',
                            '+\$15.30',
                            true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Add bottom padding to account for floating nav bar
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  Widget
  _buildActionButtonWithImage(
    String imagePath,
  ) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.2,
        ),
        borderRadius: BorderRadius.circular(
          15,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Image.asset(
          imagePath,
          color: Colors.white,
          width: 24,
          height: 24,
        ),
      ),
    );
  }

  Widget
  _buildTransactionItem(
    String title,
    String date,
    String time,
    String amount,
    bool isPositive,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  '$date  $time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isPositive
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
