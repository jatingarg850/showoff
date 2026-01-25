import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/razorpay_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _currentPlanId;
  Map<String, dynamic>? _activePlan;
  List<Map<String, dynamic>> _availablePlans = [];
  String _userEmail = 'user@showoff.life';
  String _userPhone = '9999999999';
  int _userCoinBalance = 0;
  String _selectedPaymentMethod = 'razorpay'; // 'razorpay' or 'coins'

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
    _loadData();
  }

  @override
  void dispose() {
    RazorpayService.instance.clearCallbacks();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAvailablePlans(),
      _loadCurrentSubscription(),
      _loadUserInfo(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAvailablePlans() async {
    try {
      final response = await ApiService.getSubscriptionPlans();
      if (response['success'] && response['data'] != null) {
        if (mounted) {
          setState(() {
            _availablePlans = List<Map<String, dynamic>>.from(response['data']);
          });
        }
      }
    } catch (e) {
      print('Error loading plans: $e');
    }
  }

  void _initializeRazorpay() async {
    await RazorpayService.instance.initialize();
    RazorpayService.instance.setCallbacks(
      onSuccess: (message) {
        if (mounted) setState(() => _isProcessing = false);
        _showSuccessDialog(message);
        _loadCurrentSubscription();
      },
      onError: (error) {
        if (mounted) setState(() => _isProcessing = false);
        _showErrorDialog(error);
      },
    );
  }

  Future<void> _loadUserInfo() async {
    try {
      final response = await ApiService.getMe();
      if (response['success'] && response['data'] != null) {
        if (mounted) {
          setState(() {
            _userEmail = response['data']['email'] ?? 'user@showoff.life';
            _userPhone = response['data']['phone'] ?? '9999999999';
            _userCoinBalance = response['data']['coinBalance'] ?? 0;
          });
        }
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  Future<void> _loadCurrentSubscription() async {
    try {
      final response = await ApiService.getMySubscription();
      if (response['success'] && response['data'] != null) {
        if (mounted) {
          setState(() {
            _currentPlanId = response['data']['plan']?['_id'];
            _activePlan = response['data'];
          });
        }
      }
    } catch (e) {
      print('No active subscription: $e');
    }
  }

  Future<void> _initiatePayment(String planId, double amount) async {
    if (mounted) setState(() => _isProcessing = true);

    // If coin payment is selected, use coin payment
    if (_selectedPaymentMethod == 'coins') {
      await _processCoinPayment(planId);
      return;
    }

    // Otherwise, use Razorpay
    try {
      print('🔄 Creating subscription order for amount: ₹$amount');
      final orderResponse = await ApiService.createRazorpayOrderForSubscription(
        amount: amount,
      );

      print('📦 Order Response: $orderResponse');

      if (orderResponse['success'] && orderResponse['data'] != null) {
        final orderId = orderResponse['data']['id'];
        final orderAmount =
            orderResponse['data']['amount']; // Amount from server (in paise)

        print('✅ Order created - ID: $orderId, Amount: $orderAmount paise');

        if (orderId == null || orderId.toString().isEmpty) {
          if (mounted) setState(() => _isProcessing = false);
          _showErrorDialog('Invalid order ID received from server');
          return;
        }

        // Use the amount from the order response (already in paise)
        final amountToUse = orderAmount != null
            ? (orderAmount is int
                  ? orderAmount.toDouble()
                  : orderAmount as double)
            : (amount * 100).toDouble();

        RazorpayService.instance.startPayment(
          orderId: orderId,
          amount: amountToUse,
          description: 'ShowOff Premium Subscription - ₹$amount/month',
          userEmail: _userEmail,
          userPhone: _userPhone,
          paymentType: 'subscription',
        );
      } else {
        if (mounted) setState(() => _isProcessing = false);
        final errorMsg = orderResponse['message'] ?? 'Failed to create order';
        print('❌ Order creation failed: $errorMsg');
        _showErrorDialog(errorMsg);
      }
    } catch (e) {
      print('❌ Exception during payment: $e');
      if (mounted) setState(() => _isProcessing = false);
      _showErrorDialog('Error: $e');
    }
  }

  Future<void> _processCoinPayment(String planId) async {
    try {
      print('💰 Processing coin payment for plan: $planId');

      final response = await ApiService.subscribeWithCoins(planId: planId);

      if (response['success']) {
        if (mounted) setState(() => _isProcessing = false);
        _showSuccessDialog(
          'Subscription activated successfully!\n\nYou spent ${response['coinsSpent']} coins.\nRemaining coins: ${response['remainingCoins']}',
        );
        _loadCurrentSubscription();
      } else {
        if (mounted) setState(() => _isProcessing = false);
        final errorMsg =
            response['message'] ?? 'Failed to process coin payment';
        print('❌ Coin payment failed: $errorMsg');
        _showErrorDialog(errorMsg);
      }
    } catch (e) {
      print('❌ Exception during coin payment: $e');
      if (mounted) setState(() => _isProcessing = false);
      _showErrorDialog('Error: $e');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Expanded(child: Text('Success!', style: TextStyle(fontSize: 18))),
          ],
        ),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.error, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Expanded(child: Text('Error', style: TextStyle(fontSize: 18))),
          ],
        ),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    final isSubscribed = _currentPlanId != null;

    // Get Pro plan from loaded plans
    final proPlan = _availablePlans.firstWhere(
      (plan) => plan['tier'] == 'pro',
      orElse: () => {
        '_id': 'pro',
        'name': 'Pro',
        'price': {'monthly': 2499},
        'features': {'verifiedBadge': true, 'adFree': true, 'coinBonus': 500},
      },
    );

    final planId = proPlan['_id'] ?? 'pro';
    final planPrice = (proPlan['price']?['monthly'] ?? 2499).toDouble();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      const Text(
                        'Get Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unlock exclusive features and enjoy an ad-free experience',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF8B5CF6),
                                width: 3,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'PRO',
                                style: TextStyle(
                                  color: Color(0xFF8B5CF6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (isSubscribed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'FINAL',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Single plan only',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: '₹2,499',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B5CF6),
                              ),
                            ),
                            TextSpan(
                              text: '/month',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildBenefit('Verified profile (Blue tick)'),
                      _buildBenefit('100% ad-free'),
                      _buildBenefit('Payment allowed via earned coins'),
                      const SizedBox(height: 24),
                      // Payment method selection
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(
                                  () => _selectedPaymentMethod = 'razorpay',
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _selectedPaymentMethod == 'razorpay'
                                      ? const Color(
                                          0xFF8B5CF6,
                                        ).withValues(alpha: 0.1)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedPaymentMethod == 'razorpay'
                                        ? const Color(0xFF8B5CF6)
                                        : Colors.grey[300]!,
                                    width: _selectedPaymentMethod == 'razorpay'
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.payment,
                                      color:
                                          _selectedPaymentMethod == 'razorpay'
                                          ? const Color(0xFF8B5CF6)
                                          : Colors.grey,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Razorpay',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Text(
                                      '₹2,499',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(
                                  () => _selectedPaymentMethod = 'coins',
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _selectedPaymentMethod == 'coins'
                                      ? const Color(
                                          0xFF8B5CF6,
                                        ).withValues(alpha: 0.1)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedPaymentMethod == 'coins'
                                        ? const Color(0xFF8B5CF6)
                                        : Colors.grey[300]!,
                                    width: _selectedPaymentMethod == 'coins'
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.monetization_on,
                                      color: _selectedPaymentMethod == 'coins'
                                          ? const Color(0xFF8B5CF6)
                                          : Colors.grey,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Coins',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$_userCoinBalance available',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _userCoinBalance >= 2499
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isSubscribed || _isProcessing
                              ? null
                              : () {
                                  // Check if user has enough coins for coin payment
                                  if (_selectedPaymentMethod == 'coins' &&
                                      _userCoinBalance < 2499) {
                                    _showErrorDialog(
                                      'Insufficient coins!\n\nYou need 2,499 coins but have $_userCoinBalance coins.\n\nPlease add money or use Razorpay payment.',
                                    );
                                    return;
                                  }
                                  _initiatePayment(planId, planPrice);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSubscribed
                                ? Colors.grey
                                : const Color(0xFF8B5CF6),
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  isSubscribed
                                      ? 'Active Subscription'
                                      : _selectedPaymentMethod == 'coins'
                                      ? 'Subscribe with ${2499} Coins'
                                      : 'Subscribe Now',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      if (isSubscribed &&
                          _activePlan != null &&
                          _activePlan!['endDate'] != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Expires: ${_formatDate(_activePlan!['endDate'] as String?)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Text(
                    'By placing this order, you agree to the Terms of Service and Privacy Policy. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFF10B981), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
