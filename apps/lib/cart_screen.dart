import 'package:flutter/material.dart';

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
  List<
    CartItem
  >
  cartItems = [
    CartItem(
      name: 'Modern light clothes',
      description: 'Dress modern',
      price: 212.99,
      quantity: 4,
      image: 'assets/cart/item1.jpg',
    ),
    CartItem(
      name: 'Modern light clothes',
      description: 'Dress modern',
      price: 162.99,
      quantity: 1,
      image: 'assets/cart/item2.jpg',
    ),
  ];

  @override
  Widget
  build(
    BuildContext context,
  ) {
    double totalAmount = cartItems.fold(
      0,
      (
        sum,
        item,
      ) =>
          sum +
          (item.price *
              item.quantity),
    );

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
          'Store',
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cart Items
                  ...cartItems.asMap().entries.map(
                    (
                      entry,
                    ) {
                      int index = entry.key;
                      CartItem item = entry.value;
                      return _buildCartItem(
                        item,
                        index,
                      );
                    },
                  ).toList(),

                  const SizedBox(
                    height: 32,
                  ),

                  // Shipping Information
                  const Text(
                    'Shipping Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // Payment Method Card
                  Container(
                    padding: const EdgeInsets.all(
                      16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1A1F71,
                            ),
                            borderRadius: BorderRadius.circular(
                              4,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'VISA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        const Expanded(
                          child: Text(
                            '**** **** **** 2143',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 200,
                  ), // Space for summary
                ],
              ),
            ),
          ),

          // Bottom Summary
          Container(
            padding: const EdgeInsets.all(
              20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(
                    alpha: 0.1,
                  ),
                  blurRadius: 10,
                  offset: const Offset(
                    0,
                    -2,
                  ),
                ),
              ],
            ),
            child: Column(
              children: [
                // Summary rows
                _buildSummaryRow(
                  'Total (9 items)',
                  '\$${totalAmount.toStringAsFixed(2)}',
                ),
                const SizedBox(
                  height: 8,
                ),
                _buildSummaryRow(
                  'Shipping Fee',
                  '\$0.00',
                ),
                const SizedBox(
                  height: 8,
                ),
                _buildSummaryRow(
                  'Discount',
                  '\$0.00',
                ),

                const SizedBox(
                  height: 16,
                ),

                const Divider(
                  color: Colors.grey,
                ),

                const SizedBox(
                  height: 16,
                ),

                // Sub Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sub Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '\$${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 24,
                ),

                // Pay Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(
                          0xFF8B5CF6,
                        ),
                        Color(
                          0xFF7C3AED,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle payment
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          28,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Pay',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

  Widget
  _buildCartItem(
    CartItem item,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                12,
              ),
              child: Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
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
                            item.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // More options
                    const Icon(
                      Icons.more_horiz,
                      color: Colors.grey,
                    ),
                  ],
                ),

                const SizedBox(
                  height: 12,
                ),

                // Price and Quantity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    // Quantity Controls
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.remove,
                              size: 16,
                            ),
                            onPressed: () {
                              if (item.quantity >
                                  1) {
                                setState(
                                  () {
                                    cartItems[index].quantity--;
                                  },
                                );
                              }
                            },
                          ),
                        ),

                        Container(
                          width: 40,
                          height: 32,
                          alignment: Alignment.center,
                          child: Text(
                            item.quantity.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.add,
                              size: 16,
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  cartItems[index].quantity++;
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildSummaryRow(
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class CartItem {
  final String
  name;
  final String
  description;
  final double
  price;
  int
  quantity;
  final String
  image;

  CartItem({
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.image,
  });
}
