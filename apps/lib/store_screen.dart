import 'package:flutter/material.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'category_products_screen.dart';
import 'services/api_service.dart';
import 'services/currency_service.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  List<Map<String, dynamic>> _newProducts = [];
  List<Map<String, dynamic>> _popularProducts = [];
  Map<String, dynamic> _cart = {};
  Map<String, int> _categories = {};
  bool _isLoading = true;

  // Currency data
  String _currencySymbol = '₹';
  double _exchangeRate = 1.0;
  String _currencyCode = 'INR';

  @override
  void initState() {
    super.initState();
    _initCurrency();
    _loadData();
  }

  Future<void> _initCurrency() async {
    try {
      // Get user's currency (defaults to INR if not set)
      final currency = await CurrencyService.getUserCurrency();
      debugPrint('💱 User currency: $currency');

      // Get currency symbol
      final symbol = CurrencyService.currencySymbols[currency] ?? '₹';
      debugPrint('💱 Currency symbol: $symbol');

      // Get exchange rates
      final rates = await CurrencyService.getExchangeRates();
      final rate = rates[currency] ?? 1.0;
      debugPrint('💱 Exchange rate for $currency: $rate');

      setState(() {
        _currencySymbol = symbol;
        _currencyCode = currency;
        _exchangeRate = rate;
      });
    } catch (e) {
      debugPrint('Error initializing currency: $e');
      // Fallback to INR
      setState(() {
        _currencySymbol = '₹';
        _currencyCode = 'INR';
        _exchangeRate = 1.0;
      });
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadNewProducts(),
      _loadPopularProducts(),
      _loadCart(),
      _loadCategories(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadNewProducts() async {
    try {
      final response = await ApiService.getNewProducts();
      if (response['success']) {
        setState(() {
          _newProducts = List<Map<String, dynamic>>.from(response['data']);
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadPopularProducts() async {
    try {
      final response = await ApiService.getPopularProducts();
      if (response['success']) {
        setState(() {
          _popularProducts = List<Map<String, dynamic>>.from(response['data']);
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadCart() async {
    try {
      final response = await ApiService.getCart();
      if (response['success']) {
        setState(() {
          _cart = response['data'] ?? {};
        });
      }
    } catch (e) {
      // Handle error silently - cart might be empty or user not logged in
      setState(() {
        _cart = {};
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ApiService.getCategories();
      if (response['success']) {
        setState(() {
          _categories = Map<String, int>.from(response['data']);
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  double _getCartTotal() {
    if (_cart['items'] == null) {
      return 0;
    }
    double total = 0;
    // Calculate total as 50% cash + 50% coins value
    for (var item in _cart['items']) {
      final product = item['product'] ?? {};
      final basePrice = (product['price'] ?? 0.0).toDouble();
      final quantity = (item['quantity'] ?? 1).toInt();
      // Show only the cash portion (50%) in cart total, converted to local currency
      final cashAmount = (basePrice * 0.5) * quantity;
      total += cashAmount * _exchangeRate;
    }
    return total;
  }

  int _getCartItemCount() {
    if (_cart['items'] == null) {
      return 0;
    }
    int count = 0;
    for (var item in _cart['items']) {
      count += (item['quantity'] ?? 0) as int;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Store',
          style: TextStyle(
            color: Color(0xFF8B5CF6),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoading) ...[
                  const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ] else ...[
                  // New Items Section - only show if there are new products
                  if (_newProducts.isNotEmpty) ...[
                    _buildSectionHeader('New Items'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _newProducts.length,
                        itemBuilder: (context, index) {
                          final product = _newProducts[index];
                          return _buildNewItemCard(context, product);
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Most Popular Section - only show if there are popular products
                  if (_popularProducts.isNotEmpty) ...[
                    _buildSectionHeader('Most Popular'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _popularProducts.length,
                        itemBuilder: (context, index) {
                          final product = _popularProducts[index];
                          return _buildPopularItemCard(context, product);
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Categories Section - only show if there are categories with products
                  if (_categories.isNotEmpty) ...[
                    _buildSectionHeader('Categories'),
                    const SizedBox(height: 16),
                    _buildCategoriesGrid(),
                    const SizedBox(height: 32),
                  ],

                  // Show message if no products at all
                  if (_newProducts.isEmpty &&
                      _popularProducts.isEmpty &&
                      _categories.isEmpty) ...[
                    const SizedBox(height: 100),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.store_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Store Coming Soon',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Products will be available soon!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 120),
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
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                ).then((_) => _loadCart());
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'View Cart (${_getCartItemCount()}) | ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$_currencySymbol${_getCartTotal().toStringAsFixed(_currencyCode == 'JPY' ? 0 : 2)}',
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

  Widget _buildSectionHeader(String title) {
    // Determine which category to show based on title
    String? categoryKey;
    if (title == 'New Items') {
      categoryKey = 'new';
    } else if (title == 'Most Popular') {
      categoryKey = 'popular';
    }

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
        GestureDetector(
          onTap: categoryKey != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryProductsScreen(
                        category: categoryKey!,
                        categoryName: title,
                      ),
                    ),
                  );
                }
              : null,
          child: Row(
            children: [
              Text(
                'See All',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5CF6),
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
        ),
      ],
    );
  }

  Widget _buildNewItemCard(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailScreen(productId: product['_id']),
          ),
        ).then((_) => _loadCart());
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    product['images'] != null &&
                        (product['images'] as List).isNotEmpty
                    ? Image.network(
                        ApiService.getImageUrl(product['images'][0]),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.shopping_bag,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
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
            const SizedBox(height: 4),
            Text(
              product['name'] ?? 'Product',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            Text(
              product['description'] ?? '',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getProductPrice(product),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Colors.amber],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '50/50',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularItemCard(
    BuildContext context,
    Map<String, dynamic> product,
  ) {
    final badge = product['badge'] ?? '';
    Color badgeColor = Colors.grey;
    if (badge == 'new') {
      badgeColor = Colors.blue;
    }
    if (badge == 'sale') {
      badgeColor = Colors.red;
    }
    if (badge == 'hot') {
      badgeColor = Colors.orange;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailScreen(productId: product['_id']),
          ),
        ).then((_) => _loadCart());
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    product['images'] != null &&
                        (product['images'] as List).isNotEmpty
                    ? Image.network(
                        ApiService.getImageUrl(product['images'][0]),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.shopping_bag,
                                size: 30,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getProductPrice(product),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Colors.amber],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '50/50',
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Color(0xFF8B5CF6),
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    if (badge.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(8),
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

  Widget _buildCategoriesGrid() {
    final categoryList = _categories.entries.toList();
    final categoryColors = [
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.red,
      Colors.teal,
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: categoryList.length,
      itemBuilder: (context, index) {
        final category = categoryList[index];
        final color = categoryColors[index % categoryColors.length];
        return _buildCategoryCard(
          _formatCategoryName(category.key),
          category.value.toString(),
          color,
          category.key,
        );
      },
    );
  }

  String _formatCategoryName(String category) {
    return category
        .split('')
        .map((char) {
          return category.indexOf(char) == 0 ? char.toUpperCase() : char;
        })
        .join('');
  }

  String _getProductPrice(Map<String, dynamic> product) {
    // ALWAYS show 50% cash + 50% coins for ALL products
    final basePrice = (product['price'] ?? 0.0).toDouble();
    final cashAmount = basePrice * 0.5;

    // Convert to user's local currency using cached rate
    final localAmount = cashAmount * _exchangeRate;

    // Calculate coins (1 coin = 1 INR)
    final coinAmount = CurrencyService.getCoinAmount(localAmount);

    // Format based on currency
    String formattedPrice;
    if (_currencyCode == 'JPY') {
      formattedPrice = '$_currencySymbol${localAmount.toStringAsFixed(0)}';
    } else {
      formattedPrice = '$_currencySymbol${localAmount.toStringAsFixed(2)}';
    }

    return '$formattedPrice + $coinAmount coins';
  }

  Widget _buildCategoryCard(
    String title,
    String count,
    Color color,
    String categoryKey,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to category products
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsScreen(
              category: categoryKey,
              categoryName: title,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Category icon
            Positioned(
              top: 12,
              right: 12,
              child: Icon(
                _getCategoryIcon(categoryKey),
                color: color,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'clothing':
        return Icons.checkroom;
      case 'shoes':
        return Icons.sports_soccer;
      case 'accessories':
        return Icons.watch;
      default:
        return Icons.category;
    }
  }
}
