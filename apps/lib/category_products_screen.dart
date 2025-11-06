import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'product_detail_screen.dart';

class CategoryProductsScreen
    extends
        StatefulWidget {
  final String
  category;
  final String
  categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.category,
    required this.categoryName,
  });

  @override
  State<
    CategoryProductsScreen
  >
  createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState
    extends
        State<
          CategoryProductsScreen
        > {
  List<
    Map<
      String,
      dynamic
    >
  >
  _products = [];
  bool
  _isLoading = true;

  @override
  void
  initState() {
    super.initState();
    _loadProducts();
  }

  Future<
    void
  >
  _loadProducts() async {
    try {
      final response = await ApiService.getProductsByCategory(
        widget.category,
      );
      if (response['success']) {
        setState(
          () {
            _products =
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
      setState(
        () {
          _isLoading = false;
        },
      );
    }
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
        title: Text(
          widget.categoryName,
          style: const TextStyle(
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
          : _products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    'No products found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(
                16,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _products.length,
              itemBuilder:
                  (
                    context,
                    index,
                  ) {
                    final product = _products[index];
                    return _buildProductCard(
                      product,
                    );
                  },
            ),
    );
  }

  Widget
  _buildProductCard(
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
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(
                      12,
                    ),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(
                      12,
                    ),
                  ),
                  child:
                      product['images'] !=
                              null &&
                          (product['images']
                                  as List)
                              .isNotEmpty
                      ? Image.network(
                          ApiService.getImageUrl(
                            product['images'][0],
                          ),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder:
                              (
                                context,
                                error,
                                stackTrace,
                              ) {
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
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ??
                          'Product',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      product['description'] ??
                          '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getProductPrice(
                            product,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(
                              0xFF8B5CF6,
                            ),
                          ),
                        ),
                        if (product['badge'] !=
                                null &&
                            product['badge'].isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getBadgeColor(
                                product['badge'],
                              ),
                              borderRadius: BorderRadius.circular(
                                8,
                              ),
                            ),
                            child: Text(
                              product['badge'].toUpperCase(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  String
  _getProductPrice(
    Map<
      String,
      dynamic
    >
    product,
  ) {
    final paymentType =
        product['paymentType'] ??
        'upi';
    if (paymentType ==
        'coins') {
      final coinPrice =
          product['coinPrice'] ??
          (product['price'] *
                  10)
              .ceil();
      return '$coinPrice coins';
    } else {
      return '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}';
    }
  }

  Color
  _getBadgeColor(
    String badge,
  ) {
    switch (badge.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'sale':
        return Colors.red;
      case 'hot':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
