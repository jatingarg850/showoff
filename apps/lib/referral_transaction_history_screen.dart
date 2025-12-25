import 'package:flutter/material.dart';

class ReferralTransactionHistoryScreen extends StatefulWidget {
  const ReferralTransactionHistoryScreen({super.key});

  @override
  State<ReferralTransactionHistoryScreen> createState() =>
      _ReferralTransactionHistoryScreenState();
}

class _ReferralTransactionHistoryScreenState
    extends State<ReferralTransactionHistoryScreen> {
  int selectedTab = 0; // 0 for Monthly, 1 for Lifetime

  final List<ReferralTransactionItem> transactions = [
    ReferralTransactionItem(
      username: '@johnn',
      date: '30/09/25',
      time: '12:34 AM',
      amount: 20.33,
    ),
    ReferralTransactionItem(
      username: '@Rrttr',
      date: '30/09/25',
      time: '12:34 AM',
      amount: 20.33,
    ),
    ReferralTransactionItem(
      username: '@Rredd',
      date: '30/09/25',
      time: '12:34 AM',
      amount: 20.33,
    ),
    ReferralTransactionItem(
      username: '@Rdss',
      date: '30/09/25',
      time: '12:34 AM',
      amount: 20.33,
    ),
    ReferralTransactionItem(
      username: '@Ffgtt',
      date: '30/09/25',
      time: '12:34 AM',
      amount: 20.33,
    ),
    ReferralTransactionItem(
      username: '@Erew',
      date: '30/09/25',
      time: '12:34 AM',
      amount: 20.33,
    ),
    ReferralTransactionItem(
      username: '@Rttff',
      date: '30/09/25',
      time: '12:34 AM',
      amount: 20.33,
    ),
    ReferralTransactionItem(
      username: '@Gvgv',
      date: '30/09/25',
      time: '12:34 AM',
      amount: 20.33,
    ),
    ReferralTransactionItem(
      username: '@Vffdd',
      date: '30/09/25',
      time: '12:34 AM',
      amount: 20.33,
    ),
  ];

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
          'Transaction History',
          style: TextStyle(
            color: Color(0xFF8B5CF6),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildTab('Monthly', 0),
                const SizedBox(width: 32),
                _buildTab('Lifetime', 1),
              ],
            ),
          ),

          // Statistics Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Left side - Statistics
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Referrals',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '40',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 40),

                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey[300],
                              ),

                              const SizedBox(width: 40),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Coins Earned',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '2300',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right side - Coin Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/setup/coins.png',
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.monetization_on,
                              color: Colors.amber,
                              size: 40,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.046, // 2300/50000
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      '2300/50000 Coins this month',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Transaction List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return _buildReferralTransactionItem(transactions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReferralTransactionItem(ReferralTransactionItem transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Profile Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.grey, size: 20),
          ),

          const SizedBox(width: 12),

          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.date}  ${transaction.time}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '+₹${transaction.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class ReferralTransactionItem {
  final String username;
  final String date;
  final String time;
  final double amount;

  ReferralTransactionItem({
    required this.username,
    required this.date,
    required this.time,
    required this.amount,
  });
}
