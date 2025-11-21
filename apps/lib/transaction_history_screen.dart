import 'package:flutter/material.dart';
import 'services/api_service.dart';

class TransactionHistoryScreen
    extends
        StatefulWidget {
  const TransactionHistoryScreen({
    super.key,
  });

  @override
  State<
    TransactionHistoryScreen
  >
  createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends
        State<
          TransactionHistoryScreen
        > {
  List<
    Map<
      String,
      dynamic
    >
  >
  _transactions = [];
  bool
  _isLoading = true;
  final int
  _currentPage = 1;

  @override
  void
  initState() {
    super.initState();
    _loadTransactions();
  }

  Future<
    void
  >
  _loadTransactions() async {
    try {
      final response = await ApiService.getTransactions(
        page: _currentPage,
        limit: 20,
      );
      if (response['success']) {
        setState(
          () {
            _transactions =
                List<
                  Map<
                    String,
                    dynamic
                  >
                >.from(
                  response['data'],
                );
            _isLoading = false;
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error loading transactions: $e',
      );
      setState(
        () => _isLoading = false,
      );
    }
  }

  String
  _getTransactionIcon(
    String type,
  ) {
    switch (type) {
      case 'upload_reward':
        return '📤';
      case 'view_reward':
        return '👁️';
      case 'ad_watch':
        return '📺';
      case 'referral':
        return '👥';
      case 'spin_wheel':
        return '🎡';
      case 'vote_received':
        return '👍';
      case 'gift_received':
        return '🎁';
      case 'gift_sent':
        return '💝';
      case 'competition_prize':
        return '🏆';
      case 'withdrawal':
        return '💰';
      case 'profile_completion':
        return '✅';
      default:
        return '💰';
    }
  }

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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<
                              Color
                            >(
                              Color(
                                0xFF8B5CF6,
                              ),
                            ),
                      ),
                    )
                  : _transactions.isEmpty
                  ? const Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      itemCount: _transactions.length,
                      itemBuilder:
                          (
                            context,
                            index,
                          ) {
                            final transaction = _transactions[index];
                            final isPositive =
                                transaction['amount'] >
                                0;
                            final date = DateTime.parse(
                              transaction['createdAt'],
                            );
                            final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
                            final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                            return _buildTransactionItem(
                              '${_getTransactionIcon(transaction['type'])} ${transaction['description']}',
                              dateStr,
                              timeStr,
                              '${isPositive ? '+' : ''}${transaction['amount']} coins',
                              isPositive,
                            );
                          },
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
    // Keep existing _buildTransactionItem implementation
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(
          12,
        ),
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
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  '$date • $time',
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
              fontWeight: FontWeight.bold,
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
