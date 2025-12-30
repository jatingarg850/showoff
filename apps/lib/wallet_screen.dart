import 'package:flutter/material.dart';
import 'spin_wheel_screen.dart';
import 'enhanced_add_money_screen.dart';
import 'withdrawal_screen.dart';
import 'transaction_history_screen.dart';
import 'ad_selection_screen.dart';
import 'services/api_service.dart';
import 'services/admob_service.dart';
import 'services/currency_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with WidgetsBindingObserver {
  int _coinBalance = 0;
  int _withdrawableBalance = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];
  String _currencySymbol = '₹';
  String _userCurrency = 'INR';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCurrency();
    _loadWalletData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh balance when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _loadBalance();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeCurrency() async {
    try {
      final symbol = await CurrencyService.getCurrencySymbol();
      final currency = await CurrencyService.getUserCurrency();
      if (mounted) {
        setState(() {
          _currencySymbol = symbol;
          _userCurrency = currency;
        });
      }
    } catch (e) {
      // Use default USD
    }
  }

  Future<void> _loadWalletData() async {
    await Future.wait([_loadBalance(), _loadTransactions()]);
  }

  Future<void> _loadBalance() async {
    try {
      final response = await ApiService.getCoinBalance();
      if (response['success'] && mounted) {
        setState(() {
          _coinBalance = response['data']['coinBalance'] ?? 0;
          _withdrawableBalance = response['data']['withdrawableBalance'] ?? 0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading balance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final response = await ApiService.getTransactions(limit: 10);
      if (response['success'] && mounted) {
        setState(() {
          _transactions = List<Map<String, dynamic>>.from(response['data']);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _watchAd() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Load and show AdMob rewarded ad
      final adWatched = await AdMobService.showRewardedAd();

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (!adWatched) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ad not available or not watched completely'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Call backend to award coins
      final response = await ApiService.watchAd();
      if (response['success'] && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Earned ${response['coinsEarned']} coins!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        _loadBalance();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to watch ad'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatTransactionType(String type) {
    switch (type) {
      case 'ad_watch':
        return 'Ads';
      case 'spin_wheel':
        return 'Spin Wheel';
      case 'gift_received':
        return 'Gift Received';
      case 'gift_sent':
        return 'Gift Sent';
      case 'post_like':
        return 'Post Like';
      case 'post_share':
        return 'Shares';
      case 'post_upload':
        return 'Uploads';
      case 'withdrawal':
        return 'Withdrawal';
      case 'top_up':
        return 'Topped up Wallet';
      case 'add_money':
        return 'Money Added';
      case 'purchase':
        return 'Coin Purchase';
      case 'upload_reward':
        return 'Upload Reward';
      case 'view_reward':
        return 'View Reward';
      case 'welcome_bonus':
        return 'Welcome Bonus';
      case 'profile_completion':
        return 'Welcome Bonus'; // Merge with welcome bonus
      case 'referral_bonus':
        return 'Referral Bonus';
      case 'daily_login':
        return 'Daily Login';
      default:
        // Remove underscores and capitalize words
        return type
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  String _formatDateTime(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);
      final dateStr =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
      final timeStr =
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
      return '$dateStr  $timeStr';
    } catch (e) {
      return '';
    }
  }

  Future<double> _coinsToLocalCurrency(int coins) async {
    // 1 coin = 1 INR
    final inrAmount = coins.toDouble();
    // Convert INR to local currency
    return await CurrencyService.convertFromINR(
      inrAmount,
    ); // INR is the base currency
  }

  Future<String> _formatCoinBalance(int coins) async {
    final localAmount = await _coinsToLocalCurrency(coins);
    if (_userCurrency == 'JPY') {
      return '$_currencySymbol${localAmount.toStringAsFixed(0)}';
    } else {
      return '$_currencySymbol${localAmount.toStringAsFixed(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  colors: [Color(0xFF701CF5), Color(0xFF701CF5)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                    const SizedBox(height: 20),

                    // Balance amount with coin icon
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _coinBalance.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Image.asset(
                                'assets/setup/coins.png',
                                width: 32,
                                height: 32,
                              ),
                            ],
                          ),
                    const SizedBox(height: 8),

                    // Local currency equivalent
                    _isLoading
                        ? const SizedBox.shrink()
                        : FutureBuilder<String>(
                            future: _formatCoinBalance(_coinBalance),
                            builder: (context, snapshot) {
                              return Text(
                                '=${snapshot.data ?? '...'}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 30),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SpinWheelScreen(),
                              ),
                            );
                          },
                          child: _buildActionButtonWithImage(
                            'assets/wallet_screen/spinthewheel.png',
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EnhancedAddMoneyScreen(),
                              ),
                            );
                            // Refresh balance if money was added
                            if (result == true) {
                              _loadBalance();
                            }
                          },
                          child: _buildActionButtonWithImage(
                            'assets/wallet_screen/add.png',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WithdrawalScreen(),
                              ),
                            );
                          },
                          child: _buildActionButtonWithImage(
                            'assets/wallet_screen/monetization.png',
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdSelectionScreen(),
                              ),
                            );
                            // Refresh balance if ad was watched
                            if (result == true) {
                              _loadBalance();
                            }
                          },
                          child: _buildActionButtonWithImage(
                            'assets/wallet_screen/ads.png',
                          ),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Transaction history header
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TransactionHistoryScreen(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transaction history',
                            style: TextStyle(
                              color: Color(0xFF8B5CF6),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Transaction list
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _transactions.isEmpty
                          ? Center(
                              child: Text(
                                'No transactions yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = _transactions[index];
                                final amount = transaction['amount'] ?? 0;
                                final isPositive = amount > 0;
                                return _buildTransactionItem(
                                  _formatTransactionType(
                                    transaction['type'] ?? '',
                                  ),
                                  _formatDateTime(transaction['createdAt']),
                                  '${isPositive ? '+' : ''}$amount',
                                  isPositive,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Add bottom padding to account for floating nav bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonWithImage(String imagePath) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Image.asset(
          imagePath,
          color: Colors.white,
          width: 24,
          height: 24,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String dateTime,
    String amount,
    bool isPositive,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                const SizedBox(height: 4),
                Text(
                  dateTime,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 4),
              Image.asset('assets/setup/coins.png', width: 16, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
