import 'package:flutter/material.dart';
import 'services/api_service.dart';

class CartScreen
    extends
        StatefulWidget {
  const CartScreen({
    super.key,
  });

  @override
  State<
    CartScreen
  >
  createState() => _CartScreenState();
}

class _CartScreenState
    extends
        State<
          CartScreen
        > {
  Map<
    String,
    dynamic
  >
  _cart = {};
  bool
  _isLoading = true;
  double
  _totalUPI = 0;
  int
  _totalCoins = 0;

  @override
  void
  initState() {
    super.initState();
    _loadCart();
  }

  Future<
    void
  >
  _loadCart() async {
    try {
      final response = await ApiService.getCart();
      if (response['success']) {
        setState(
          () {
            _cart =
                response['data'] ??
                {};
            _isLoading = false;
          },
        );
        _calculateTotals();
      }
    } catch (
      e
    ) {
      setState(
        () {
          _isLoading = false;
        },
      );
    }
  }

  void
  _calculateTotals() {
    _totalUPI = 0;
    _totalCoins = 0;

    final items =
        _cart['items']
            as List? ??
        [];
    for (var item in items) {
      final paymentType =
          item['paymentType'] ??
          'upi';
      final quantity =
          item['quantity'] ??
          1;

      if (paymentType ==
          'coins') {
        _totalCoins +=
            ((item['coinPrice'] ??
                        0) *
                    quantity)
                as int;
      } else {
        _totalUPI +=
            (item['price'] ??
                0) *
            quantity;
      }
    }
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    final items =
        _cart['items']
            as List? ??
        [];

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
          'Shopping Cart',
          style: TextStyle(
            color: Color(
              0xFF8B5CF6,
            ),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(
                      16,
                    ),
                    itemCount: items.length,
                    itemBuilder:
                        (
                          context,
                          index,
                        ) {
                          final item = items[index];
                          return _buildCartItem(
                            item,
                          );
                        },
                  ),
                ),
                _buildCheckoutSection(),
              ],
            ),
    );
  }

  Widget
  _buildCartItem(
    Map<
      String,
      dynamic
    >
    item,
  ) {
    final product =
        item['product'] ??
        {};
    final paymentType =
        item['paymentType'] ??
        'upi';
    final quantity =
        item['quantity'] ??
        1;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          12,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.1,
            ),
            blurRadius: 8,
            offset: const Offset(
              0,
              2,
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(
                8,
              ),
            ),
            child: const Icon(
              Icons.shopping_bag,
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ??
                      'Product',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Text(
                      _getItemPrice(
                        item,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(
                          0xFF8B5CF6,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    if (paymentType ==
                        'coins')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(
                            4,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              'COINS',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  'Quantity: $quantity',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(
        20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.1,
            ),
            blurRadius: 8,
            offset: const Offset(
              0,
              -2,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_totalCoins >
              0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 20,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Coin Payment:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$_totalCoins coins',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
          ],
          if (_totalUPI >
              0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.payment,
                      color: Color(
                        0xFF8B5CF6,
                      ),
                      size: 20,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'UPI Payment:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${_totalUPI.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(
                      0xFF8B5CF6,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
          ],
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF8B5CF6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    25,
                  ),
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String
  _getItemPrice(
    Map<
      String,
      dynamic
    >
    item,
  ) {
    final paymentType =
        item['paymentType'] ??
        'upi';
    final quantity =
        item['quantity'] ??
        1;

    if (paymentType ==
        'coins') {
      final coinPrice =
          (item['coinPrice'] ??
              0) *
          quantity;
      return '$coinPrice coins';
    } else {
      final price =
          (item['price'] ??
              0) *
          quantity;
      return '\$${price.toStringAsFixed(2)}';
    }
  }

  void
  _checkout() async {
    try {
      final response = await ApiService.checkout();
      if (response['success']) {
        // Show checkout summary dialog
        _showCheckoutDialog(
          response['data'],
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ??
                  'Checkout failed',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (
      e
    ) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void
  _showCheckoutDialog(
    Map<
      String,
      dynamic
    >
    checkoutData,
  ) {
    showDialog(
      context: context,
      builder:
          (
            context,
          ) => AlertDialog(
            title: const Text(
              'Checkout Summary',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (checkoutData['totalCoins'] >
                    0) ...[
                  Text(
                    'Coins: ${checkoutData['totalCoins']} coins',
                  ),
                  Text(
                    'Your Balance: ${checkoutData['userCoinBalance']} coins',
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
                if (checkoutData['totalUPI'] !=
                    '0.00') ...[
                  Text(
                    'UPI Payment: \$${checkoutData['totalUPI']}',
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
                Text(
                  checkoutData['canProceed']
                      ? 'Ready to proceed with payment'
                      : 'Insufficient coins',
                  style: TextStyle(
                    color: checkoutData['canProceed']
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                ),
                child: const Text(
                  'Cancel',
                ),
              ),
              if (checkoutData['canProceed'])
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                    _processPayment();
                  },
                  child: const Text(
                    'Confirm Payment',
                  ),
                ),
            ],
          ),
    );
  }

  void
  _processPayment() async {
    try {
      final response = await ApiService.processPayment(
        paymentMethod: 'mixed',
        razorpayPaymentId: 'dummy_payment_id', // In real app, get from Razorpay
      );

      if (response['success']) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment successful!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadCart(); // Refresh cart
      }
    } catch (
      e
    ) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Payment failed: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
