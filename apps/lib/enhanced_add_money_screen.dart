import 'package:flutter/material.dart';
import 'services/api_service.dart';

class EnhancedAddMoneyScreen
    extends
        StatefulWidget {
  const EnhancedAddMoneyScreen({
    super.key,
  });

  @override
  State<
    EnhancedAddMoneyScreen
  >
  createState() => _EnhancedAddMoneyScreenState();
}

class _EnhancedAddMoneyScreenState
    extends
        State<
          EnhancedAddMoneyScreen
        > {
  final TextEditingController
  _amountController = TextEditingController();
  String
  _selectedAmount = '';
  String
  _selectedGateway = 'stripe'; // Default to Stripe
  bool
  _isLoading = false;

  final List<
    String
  >
  _quickAmounts = [
    '20',
    '50',
    '100',
    '200',
  ];

  @override
  void
  dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void
  _selectAmount(
    String amount,
  ) {
    setState(
      () {
        _selectedAmount = amount;
        _amountController.text = amount;
      },
    );
  }

  Future<
    void
  >
  _processPayment() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError(
        'Please enter an amount',
      );
      return;
    }

    final amount = double.tryParse(
      amountText,
    );
    if (amount ==
            null ||
        amount <=
            0) {
      _showError(
        'Please enter a valid amount',
      );
      return;
    }

    setState(
      () {
        _isLoading = true;
      },
    );

    try {
      if (_selectedGateway ==
          'stripe') {
        await _processStripePayment(
          amount,
        );
      } else {
        await _processRazorpayPayment(
          amount,
        );
      }
    } catch (
      e
    ) {
      _showError(
        'Payment failed: $e',
      );
    } finally {
      setState(
        () {
          _isLoading = false;
        },
      );
    }
  }

  Future<
    void
  >
  _processStripePayment(
    double amount,
  ) async {
    // Create payment intent
    final intentResponse = await ApiService.createStripePaymentIntent(
      amount: amount,
      currency: 'usd',
    );

    if (!intentResponse['success']) {
      throw Exception(
        intentResponse['message'] ??
            'Failed to create payment intent',
      );
    }

    // In a real app, you would integrate with Stripe SDK here
    // For demo purposes, we'll simulate a successful payment
    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );

    // Simulate successful payment
    final confirmResponse = await ApiService.addMoney(
      amount: amount,
      gateway: 'stripe',
      paymentData: {
        'paymentIntentId': intentResponse['data']['paymentIntentId'],
      },
    );

    if (confirmResponse['success']) {
      _showSuccess(
        confirmResponse['coinsAdded'],
        amount,
        'Stripe',
      );
    } else {
      throw Exception(
        confirmResponse['message'] ??
            'Payment confirmation failed',
      );
    }
  }

  Future<
    void
  >
  _processRazorpayPayment(
    double amount,
  ) async {
    // Create Razorpay order
    final orderResponse = await ApiService.createRazorpayOrderForAddMoney(
      amount: amount,
    );

    if (!orderResponse['success']) {
      throw Exception(
        orderResponse['message'] ??
            'Failed to create order',
      );
    }

    // In a real app, you would integrate with Razorpay SDK here
    // For demo purposes, we'll simulate a successful payment
    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );

    // Simulate successful payment
    final confirmResponse = await ApiService.addMoney(
      amount: amount,
      gateway: 'razorpay',
      paymentData: {
        'razorpayOrderId': orderResponse['data']['orderId'],
        'razorpayPaymentId': 'pay_demo_${DateTime.now().millisecondsSinceEpoch}',
        'razorpaySignature': 'demo_signature',
      },
    );

    if (confirmResponse['success']) {
      _showSuccess(
        confirmResponse['coinsAdded'],
        amount,
        'Razorpay',
      );
    } else {
      throw Exception(
        confirmResponse['message'] ??
            'Payment confirmation failed',
      );
    }
  }

  void
  _showSuccess(
    int coins,
    double amount,
    String gateway,
  ) {
    showDialog(
      context: context,
      builder:
          (
            context,
          ) => AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Success!',
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment successful via $gateway',
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'Amount: ${_selectedGateway == 'stripe' ? '\$' : '₹'}${amount.toStringAsFixed(2)}',
                ),
                Text(
                  'Coins added: $coins',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pop();
                  Navigator.of(
                    context,
                  ).pop(
                    true,
                  ); // Return true to indicate success
                },
                child: const Text(
                  'OK',
                ),
              ),
            ],
          ),
    );
  }

  void
  _showError(
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button and title
              Row(
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
                    'Add Money',
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

              const SizedBox(
                height: 30,
              ),

              // Payment Gateway Selection
              const Text(
                'Select Payment Gateway',
                style: TextStyle(
                  color: Color(
                    0xFF8B5CF6,
                  ),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(
                          () {
                            _selectedGateway = 'stripe';
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(
                          16,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _selectedGateway ==
                                  'stripe'
                              ? const Color(
                                  0xFF8B5CF6,
                                ).withOpacity(
                                  0.1,
                                )
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                          border:
                              _selectedGateway ==
                                  'stripe'
                              ? Border.all(
                                  color: const Color(
                                    0xFF8B5CF6,
                                  ),
                                  width: 2,
                                )
                              : Border.all(
                                  color: Colors.grey[300]!,
                                ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF635BFF,
                                ),
                                borderRadius: BorderRadius.circular(
                                  4,
                                ),
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
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Stripe',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    _selectedGateway ==
                                        'stripe'
                                    ? const Color(
                                        0xFF8B5CF6,
                                      )
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
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(
                          () {
                            _selectedGateway = 'razorpay';
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(
                          16,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _selectedGateway ==
                                  'razorpay'
                              ? const Color(
                                  0xFF8B5CF6,
                                ).withOpacity(
                                  0.1,
                                )
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                          border:
                              _selectedGateway ==
                                  'razorpay'
                              ? Border.all(
                                  color: const Color(
                                    0xFF8B5CF6,
                                  ),
                                  width: 2,
                                )
                              : Border.all(
                                  color: Colors.grey[300]!,
                                ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF3395FF,
                                ),
                                borderRadius: BorderRadius.circular(
                                  4,
                                ),
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
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Razorpay',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    _selectedGateway ==
                                        'razorpay'
                                    ? const Color(
                                        0xFF8B5CF6,
                                      )
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

              const SizedBox(
                height: 30,
              ),

              // Amount label
              Text(
                'Amount (${_selectedGateway == 'stripe' ? 'USD' : 'INR'})',
                style: const TextStyle(
                  color: Color(
                    0xFF8B5CF6,
                  ),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // Amount input field
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter Amount',
                  prefixText:
                      _selectedGateway ==
                          'stripe'
                      ? '\$ '
                      : '₹ ',
                  prefixStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // Quick amount buttons
              Row(
                children: _quickAmounts.map(
                  (
                    amount,
                  ) {
                    final isSelected =
                        _selectedAmount ==
                        amount;
                    final displayAmount =
                        _selectedGateway ==
                            'stripe'
                        ? '\$$amount'
                        : '₹$amount';
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        child: GestureDetector(
                          onTap: () => _selectAmount(
                            amount,
                          ),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(
                                      0xFF8B5CF6,
                                    ).withOpacity(
                                      0.1,
                                    )
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(
                                        0xFF8B5CF6,
                                      ),
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                displayAmount,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(
                                          0xFF8B5CF6,
                                        )
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
                  },
                ).toList(),
              ),

              const SizedBox(
                height: 16,
              ),

              // Conversion info
              Container(
                padding: const EdgeInsets.all(
                  12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                  border: Border.all(
                    color: Colors.blue[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[600],
                      size: 16,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        _selectedGateway ==
                                'stripe'
                            ? '1 USD = 100 Coins'
                            : '1 INR = 1.2 Coins',
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
                  onPressed: _isLoading
                      ? null
                      : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF8B5CF6,
                    ),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<
                                  Color
                                >(
                                  Colors.white,
                                ),
                          ),
                        )
                      : Text(
                          'Add Money via ${_selectedGateway == 'stripe' ? 'Stripe' : 'Razorpay'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
