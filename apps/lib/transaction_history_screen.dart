import 'package:flutter/material.dart';

class TransactionHistoryScreen
    extends
        StatelessWidget {
  const TransactionHistoryScreen({
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
            // Header with back button and title
            Padding(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(
                      context,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  const Text(
                    'Transaction History',
                    style: TextStyle(
                      color: Color(
                        0xFF8B5CF6,
                      ),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Transaction list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
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
                    '-\$15.30',
                    false,
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
                    '+\$315.30',
                    true,
                  ),
                  _buildTransactionItem(
                    'Referral',
                    '30/09/25',
                    '12:34 AM',
                    '+\$315.30',
                    true,
                  ),
                  _buildTransactionItem(
                    'Gift',
                    '30/09/25',
                    '12:34 AM',
                    '+\$315.30',
                    true,
                  ),
                  _buildTransactionItem(
                    'Shares',
                    '30/09/25',
                    '12:34 AM',
                    '+\$315.30',
                    true,
                  ),
                  _buildTransactionItem(
                    'Ads',
                    '30/09/25',
                    '12:34 AM',
                    '+\$315.30',
                    true,
                  ),
                  _buildTransactionItem(
                    'Topped up wallet',
                    '30/09/25',
                    '12:34 AM',
                    '+\$315.30',
                    true,
                  ),
                  _buildTransactionItem(
                    'Ads',
                    '30/09/25',
                    '12:34 AM',
                    '+\$315.30',
                    true,
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
  _buildTransactionItem(
    String title,
    String date,
    String time,
    String amount,
    bool isPositive,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20,
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
