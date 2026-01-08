import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/razorpay_service.dart';

class EnhancedAddMoneyScreen extends StatefulWidget {
  const EnhancedAddMoneyScreen({super.key});

  @override
  State<EnhancedAddMoneyScreen> createState() => _EnhancedAddMoneyScreenState();
}

class _EnhancedAddMoneyScreenState extends State<EnhancedAddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedAmount = '';
  String _selectedGateway = 'razorpay'; // Default to Razorpay
  bool _isLoading = false;

  final List<String> _stripeQuickAmounts = ['1', '5', '10', '20', '50', '100'];

  final List<String> _razorpayQuickAmounts = [
    '10',
    '20',
    '50',
    '100',
    '200',
    '500',
  ];

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
  }

  @override
  void dispose() {
    _amountController.dispose();
    RazorpayService.instance.clearCallbacks();
    super.dispose();
  }

  void _initializeRazorpay() {
    RazorpayService.instance.initialize();
    RazorpayService.instance.setCallbacks(
      onSuccess: (message) {
        setState(() {
          _isLoading = false;
        });
        _showSuccessDialog(message);
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(error);
      },
      onExternalWallet: (message) {
        print('External wallet: $message');
      },
    );
  }

  void _selectAmount(String amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount;
    });
  }

  Future<void> _processPayment() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError('Please enter an amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    if (amount < 10) {
      _showError('Minimum amount is ₹10');
      return;
    }

    if (amount > 100000) {
      _showError('Maximum amount is ₹1,00,000');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedGateway == 'stripe') {
        await _processStripePayment(amount);
      } else {
        await _processRazorpayPayment(amount);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Payment failed: $e');
    }
  }

  Future<void> _processStripePayment(double amount) async {
    // Create payment intent
    final intentResponse = await ApiService.createStripePaymentIntent(
      amount: amount,
      currency: 'usd',
    );

    if (!intentResponse['success']) {
      throw Exception(
        intentResponse['message'] ?? 'Failed to create payment intent',
      );
    }

    // In a real app, you would integrate with Stripe SDK here
    // For demo purposes, we'll simulate a successful payment
    await Future.delayed(const Duration(seconds: 2));

    // Simulate successful payment
    final confirmResponse = await ApiService.addMoney(
      amount: amount,
      gateway: 'stripe',
      paymentData: {
        'paymentIntentId': intentResponse['data']['paymentIntentId'],
      },
    );

    if (confirmResponse['success']) {
      _showSuccessDialog(
        'Payment successful! ${confirmResponse['coinsAdded']} coins added to your account.',
      );
    } else {
      throw Exception(
        confirmResponse['message'] ?? 'Payment confirmation failed',
      );
    }
  }

  Future<void> _processRazorpayPayment(double amount) async {
    try {
      print('🚀 Starting Razorpay payment for amount: ₹$amount');

      // Create order on backend
      final orderResponse = await ApiService.createRazorpayOrderForAddMoney(
        amount: amount,
      );

      if (!orderResponse['success']) {
        throw Exception(orderResponse['message'] ?? 'Failed to create order');
      }

      final orderId = orderResponse['data']['orderId'];
      final orderAmountInPaise =
          orderResponse['data']['amount']; // Backend returns amount in paise
      final orderAmountInRupees =
          orderAmountInPaise / 100; // Convert for display only

      print('📊 DEBUG - User entered: ₹$amount');
      print('📊 DEBUG - Backend returned amount in paise: $orderAmountInPaise');
      print(
        '📊 DEBUG - Converted to rupees for display: ₹$orderAmountInRupees',
      );
      print('📊 DEBUG - Sending to Razorpay: $orderAmountInPaise paise');
      print('✅ Order created: $orderId for ₹$orderAmountInRupees');

      // Start Razorpay payment
      await RazorpayService.instance.startPayment(
        orderId: orderId,
        amount: orderAmountInPaise
            .toDouble(), // Send amount in paise to RazorpayService
        description: 'Add ₹${amount.toStringAsFixed(0)} to ShowOff.life wallet',
        userEmail: 'user@showoff.life', // You can get this from user profile
        userPhone: '9999999999', // You can get this from user profile
      );

      // Note: Payment success/failure will be handled by RazorpayService callbacks
      // The _isLoading state will be updated in the callbacks
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('❌ Razorpay payment error: $e');
      _showError('Failed to start payment: $e');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: Color(0xFF8B5CF6),
            ),
            SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text(
              'Continue',
              style: TextStyle(color: Color(0xFF8B5CF6)),
            ),
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
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Payment Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button and title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Add Money',
                    style: TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Payment Gateway Selection
              const Text(
                'Select Payment Gateway',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGateway = 'stripe';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedGateway == 'stripe'
                              ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: _selectedGateway == 'stripe'
                              ? Border.all(
                                  color: const Color(0xFF8B5CF6),
                                  width: 2,
                                )
                              : Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF635BFF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                child: Text(
                                  'stripe',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Stripe',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _selectedGateway == 'stripe'
                                    ? const Color(0xFF8B5CF6)
                                    : Colors.black,
                              ),
                            ),
                            const Text(
                              'USD',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGateway = 'razorpay';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedGateway == 'razorpay'
                              ? const Color(0xFF8B5CF6).withValues(alpha: 0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: _selectedGateway == 'razorpay'
                              ? Border.all(
                                  color: const Color(0xFF8B5CF6),
                                  width: 2,
                                )
                              : Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3395FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                child: Text(
                                  'razorpay',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Razorpay',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _selectedGateway == 'razorpay'
                                    ? const Color(0xFF8B5CF6)
                                    : Colors.black,
                              ),
                            ),
                            const Text(
                              'INR',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Amount label
              Text(
                'Amount (${_selectedGateway == 'stripe' ? 'USD' : 'INR'})',
                style: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              // Amount input field
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter Amount',
                  prefixText: _selectedGateway == 'stripe' ? '\$ ' : '₹ ',
                  prefixStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),

              const SizedBox(height: 20),

              // Quick amount buttons
              Row(
                children:
                    (_selectedGateway == 'stripe'
                            ? _stripeQuickAmounts
                            : _razorpayQuickAmounts)
                        .map((amount) {
                          final isSelected = _selectedAmount == amount;
                          final displayAmount = _selectedGateway == 'stripe'
                              ? '\$$amount'
                              : '₹$amount';
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: GestureDetector(
                                onTap: () => _selectAmount(amount),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(
                                            0xFF8B5CF6,
                                          ).withValues(alpha: 0.1)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? Border.all(
                                            color: const Color(0xFF8B5CF6),
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      displayAmount,
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFF8B5CF6)
                                            : Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        })
                        .toList(),
              ),

              const SizedBox(height: 16),

              // Conversion info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedGateway == 'stripe'
                            ? '1 USD = 83 Coins'
                            : '1 INR = 1 Coin',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Add Money button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedGateway == 'razorpay'
                        ? const Color(0xFF3395FF)
                        : const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Processing Payment...',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_selectedGateway == 'razorpay') ...[
                              Icon(Icons.payment, size: 20),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              _amountController.text.isNotEmpty
                                  ? 'Pay ₹${_amountController.text} via ${_selectedGateway == 'razorpay' ? 'Razorpay' : 'Stripe'}'
                                  : 'Enter Amount to Continue',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
