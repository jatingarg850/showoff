import 'package:flutter/material.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'services/api_service.dart';

class StoreScreen
    extends
        StatefulWidget {
  const StoreScreen({
    super.key,
  });

  @override
  State<
    StoreScreen
  >
  createState() => _StoreScreenState();
}

class _StoreScreenState
    extends
        State<
          StoreScreen
        > {
  List<
    Map<
      String,
      dynamic
    >
  >
  _newProducts = [];
  List<
    Map<
      String,
      dynamic
    >
  >
  _popularProducts = [];
  Map<
    String,
    dynamic
  >
  _cart = {};
  bool
  _isLoading = true;

  @override
  void
  initState() {
    super.initState();
    _loadData();
  }

  Future<
    void
  >
  _loadData() async {
    await Future.wait(
      [
        _loadNewProducts(),
        _loadPopularProducts(),
        _loadCart(),
      ],
    );
    setState(
      () => _isLoading = false,
    );
  }

  Future<
    void
  >
  _loadNewProducts() async {
    try {
      final response = await ApiService.getNewProducts();
      if (response['success']) {
        setState(
          () {
            _newProducts =
                List<
                  Map<
                    String,
                    dynamic
                  >
                >.from(
                  response['data'],
                );
          },
        );
      }
    } catch (
      e
    ) {
      // Handle error silently
    }
  }

  Future<
    void
  >
  _loadPopularProducts() async {
    try {
      final response = await ApiService.getPopularProducts();
      if (response['success']) {
        setState(
          () {
            _popularProducts =
                List<
                  Map<
                    String,
                    dynamic
                  >
                >.from(
                  response['data'],
                );
          },
        );
      }
    } catch (
      e
    ) {
      // Handle error silently
    }
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
            _cart = response['data'];
          },
        );
      }
    } catch (
      e
    ) {
      // Handle error silently
    }
  }

  double
  _getCartTotal() {
    if (_cart['items'] ==
        null)
      return 0;
    double total = 0;
    for (var item in _cart['items']) {
      total +=
          (item['price'] ??
              0) *
          (item['quantity'] ??
              1);
    }
    return total;
  }

  int
  _getCartItemCount() {
    if (_cart['items'] ==
        null)
      return 0;
    int count = 0;
    for (var item in _cart['items']) {
      count +=
          (item['quantity'] ??
                  0)
              as int;
    }
    return count;
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // New Items Section
                _buildSectionHeader(
                  'New Items',
                ),
                const SizedBox(
                  height: 16,
                ),
                _isLoading
                    ? const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox(
                        height: 200,
                        child: _newProducts.isEmpty
                            ? Center(
                                child: Text(
                                  'No new products',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _newProducts.length,
                                itemBuilder:
                                    (
                                      context,
                                      index,
                                    ) {
                                      final product = _newProducts[index];
                                      return _buildNewItemCard(
                                        context,
                                        product,
                                      );
                                    },
                              ),
                      ),
                const SizedBox(
                  height: 32,
                ),

                // Most Popular Section
                _buildSectionHeader(
                  'Most Popular',
                ),
                const SizedBox(
                  height: 16,
                ),
                _isLoading
                    ? const SizedBox(
                        height: 140,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SizedBox(
                        height: 140,
                        child: _popularProducts.isEmpty
                            ? Center(
                                child: Text(
                                  'No popular products',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _popularProducts.length,
                                itemBuilder:
                                    (
                                      context,
                                      index,
                                    ) {
                                      final product = _popularProducts[index];
                                      return _buildPopularItemCard(
                                        context,
                                        product,
                                      );
                                    },
                              ),
                      ),
                const SizedBox(
                  height: 32,
                ),

                // Categories Section
                _buildSectionHeader(
                  'Categories',
                ),
                const SizedBox(
                  height: 16,
                ),
                _buildCategoriesGrid(),
                const SizedBox(
                  height: 120,
                ),
              ],
            ),
          ),

          // Floating action buttons
          Positioned(
            right: 20,
            bottom: 180,
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(
                      0xFF8B5CF6,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(
                      0xFF8B5CF6,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Bottom cart bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (
                          context,
                        ) => const CartScreen(),
                  ),
                ).then(
                  (
                    _,
                  ) => _loadCart(),
                );
              },
              child: Container(
                height: 60,
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
                    30,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Text(
                        'View Cart (${_getCartItemCount()}) | ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${_getCartTotal().toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildSectionHeader(
    String title,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Row(
          children: [
            Text(
              'See All',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(
                  0xFF8B5CF6,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget
  _buildNewItemCard(
    BuildContext context,
    Map<
      String,
      dynamic
    >
    product,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (
                  context,
                ) => ProductDetailScreen(
                  productId: product['_id'],
                ),
          ),
        ).then(
          (
            _,
          ) => _loadCart(),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(
          right: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
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
                      Icons.shopping_bag,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              product['description'] ??
                  '',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget
  _buildPopularItemCard(
    BuildContext context,
    Map<
      String,
      dynamic
    >
    product,
  ) {
    final badge =
        product['badge'] ??
        '';
    Color badgeColor = Colors.grey;
    if (badge ==
        'new')
      badgeColor = Colors.blue;
    if (badge ==
        'sale')
      badgeColor = Colors.red;
    if (badge ==
        'hot')
      badgeColor = Colors.orange;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (
                  context,
                ) => ProductDetailScreen(
                  productId: product['_id'],
                ),
          ),
        ).then(
          (
            _,
          ) => _loadCart(),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(
          right: 16,
        ),
        child: Column(
          children: [
            Container(
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
                      Icons.shopping_bag,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${product['price']?.toStringAsFixed(0) ?? '0'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Color(
                        0xFF8B5CF6,
                      ),
                      size: 12,
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    if (badge.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(
                            8,
                          ),
                        ),
                        child: Text(
                          badge.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget
  _buildCategoriesGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCategoryCard(
                'Clothing',
                '109',
                Colors.orange,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: _buildCategoryCard(
                'Shoes',
                '',
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          children: [
            Expanded(
              child: _buildCategoryCard(
                '',
                '',
                Colors.purple,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: _buildCategoryCard(
                '',
                '',
                Colors.brown,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget
  _buildCategoryCard(
    String title,
    String count,
    Color color,
  ) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: color.withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                16,
              ),
              gradient: LinearGradient(
                colors: [
                  color.withValues(
                    alpha: 0.2,
                  ),
                  color.withValues(
                    alpha: 0.1,
                  ),
                ],
              ),
            ),
          ),
          if (title.isNotEmpty)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  if (count.isNotEmpty)
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 14,
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
}
