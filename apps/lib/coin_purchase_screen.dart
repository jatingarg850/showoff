import 'package:flutter/material.dart';
import 'services/api_service.dart';

class CoinPurchaseScreen
    extends
        StatefulWidget {
  const CoinPurchaseScreen({
    super.key,
  });

  @override
  State<
    CoinPurchaseScreen
  >
  createState() => _CoinPurchaseScreenState();
}

class _CoinPurchaseScreenState
    extends
        State<
          CoinPurchaseScreen
        > {
  bool
  _isLoading = false;
  int
  _currentBalance = 0;

  final List<
    Map<
      String,
      dynamic
    >
  >
  _coinPackages = [
    {
      'id': 'package_1',
      'coins': 100,
      'price': 0.99,
      'originalPrice': 1.99,
      'discount': '50% OFF',
      'popular': false,
    },
    {
      'id': 'package_2',
      'coins': 500,
      'price': 4.99,
      'originalPrice': 9.99,
      'discount': '50% OFF',
      'popular': false,
    },
    {
      'id': 'package_3',
      'coins': 1000,
      'price': 9.99,
      'originalPrice': 19.99,
      'discount': '50% OFF',
      'popular': true,
    },
    {
      'id': 'package_4',
      'coins': 2500,
      'price': 19.99,
      'originalPrice': 39.99,
      'discount': '50% OFF',
      'popular': false,
    },
    {
      'id': 'package_5',
      'coins': 5000,
      'price': 49.99,
      'originalPrice': 99.99,
      'discount': '50% OFF',
      'popular': false,
    },
    {
      'id': 'package_6',
      'coins': 10000,
      'price': 99.99,
      'originalPrice': 199.99,
      'discount': '50% OFF',
      'popular': false,
    },
  ];

  @override
  void
  initState() {
    super.initState();
    _loadBalance();
  }

  Future<
    void
  >
  _loadBalance() async {
    try {
      final response = await ApiService.getCoinBalance();
      if (response['success']) {
        setState(
          () {
            _currentBalance =
                response['data']['coinBalance'] ??
                0;
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error loading balance: $e',
      );
    }
  }

  Future<
    void
  >
  _purchaseCoins(
    Map<
      String,
      dynamic
    >
    package,
  ) async {
    setState(
      () {
        _isLoading = true;
      },
    );

    try {
      // Create purchase order
      final orderResponse = await ApiService.createCoinPurchaseOrder(
        packageId: package['id'],
        amount:
            (package['price'] *
                    100)
                .round(), // Convert to paise
        coins: package['coins'],
      );

      if (orderResponse['success']) {
        // In a real app, you would integrate with Razorpay SDK here
        // For demo purposes, we'll simulate a successful payment
        await _simulatePayment(
          orderResponse['data'],
          package,
        );
      } else {
        _showError(
          orderResponse['message'] ??
              'Failed to create order',
        );
      }
    } catch (
      e
    ) {
      _showError(
        'Error: $e',
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
  _simulatePayment(
    Map<
      String,
      dynamic
    >
    orderData,
    Map<
      String,
      dynamic
    >
    package,
  ) async {
    // Simulate payment processing
    await Future.delayed(
      const Duration(
        seconds: 2,
      ),
    );

    // Simulate successful payment
    final purchaseResponse = await ApiService.purchaseCoins(
      razorpayOrderId: orderData['orderId'],
      razorpayPaymentId: 'pay_demo_${DateTime.now().millisecondsSinceEpoch}',
      razorpaySignature: 'demo_signature',
      packageId: package['id'],
    );

    if (purchaseResponse['success']) {
      _showSuccess(
        package['coins'],
      );
      _loadBalance(); // Refresh balance
    } else {
      _showError(
        purchaseResponse['message'] ??
            'Payment failed',
      );
    }
  }

  void
  _showSuccess(
    int coins,
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
            content: Text(
              'You have successfully purchased $coins coins!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).pop(),
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
          'Buy Coins',
          style: TextStyle(
            color: Color(
              0xFF8B5CF6,
            ),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Current Balance
          Container(
            margin: const EdgeInsets.all(
              20,
            ),
            padding: const EdgeInsets.all(
              20,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(
                    0xFF8B5CF6,
                  ),
                  Color(
                    0xFF3B82F6,
                  ),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                16,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(
                  width: 16,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$_currentBalance Coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Coin Packages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              itemCount: _coinPackages.length,
              itemBuilder:
                  (
                    context,
                    index,
                  ) {
                    final package = _coinPackages[index];
                    return _buildCoinPackage(
                      package,
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildCoinPackage(
    Map<
      String,
      dynamic
    >
    package,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: package['popular']
              ? const Color(
                  0xFF8B5CF6,
                )
              : Colors.grey[300]!,
          width: package['popular']
              ? 2
              : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.05,
            ),
            blurRadius: 10,
            offset: const Offset(
              0,
              2,
            ),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Popular badge
          if (package['popular'])
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  color: Color(
                    0xFF8B5CF6,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(
                      16,
                    ),
                    bottomLeft: Radius.circular(
                      16,
                    ),
                  ),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(
              20,
            ),
            child: Row(
              children: [
                // Coin icon and amount
                Container(
                  padding: const EdgeInsets.all(
                    16,
                  ),
                  decoration: BoxDecoration(
                    color:
                        const Color(
                          0xFF8B5CF6,
                        ).withOpacity(
                          0.1,
                        ),
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Color(
                          0xFF8B5CF6,
                        ),
                        size: 32,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        '${package['coins']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(
                            0xFF8B5CF6,
                          ),
                        ),
                      ),
                      const Text(
                        'Coins',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(
                            0xFF8B5CF6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 20,
                ),

                // Package details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '\$${package['price'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            '\$${package['originalPrice'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(
                            4,
                          ),
                        ),
                        child: Text(
                          package['discount'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Best value for ${package['coins']} coins',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Buy button
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _purchaseCoins(
                          package,
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF8B5CF6,
                    ),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
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
                      : const Text(
                          'Buy',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
