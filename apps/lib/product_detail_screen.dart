import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'services/api_service.dart';

class ProductDetailScreen
    extends
        StatefulWidget {
  final String
  productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<
    ProductDetailScreen
  >
  createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends
        State<
          ProductDetailScreen
        > {
  Map<
    String,
    dynamic
  >?
  _product;
  bool
  _isLoading = true;
  String?
  selectedSize;
  int
  selectedColorIndex = 0;
  int
  quantity = 1;
  bool
  isFavorite = false;

  @override
  void
  initState() {
    super.initState();
    _loadProduct();
  }

  Future<
    void
  >
  _loadProduct() async {
    try {
      final response = await ApiService.getProduct(
        widget.productId,
      );
      if (response['success']) {
        setState(
          () {
            _product = response['data'];
            if (_product!['sizes'] !=
                    null &&
                (_product!['sizes']
                        as List)
                    .isNotEmpty) {
              selectedSize = _product!['sizes'][0];
            }
            _isLoading = false;
          },
        );
      }
    } catch (
      e
    ) {
      setState(
        () => _isLoading = false,
      );
    }
  }

  Future<
    void
  >
  _addToCart() async {
    if (_product ==
        null)
      return;

    try {
      final response = await ApiService.addToCart(
        productId: widget.productId,
        quantity: quantity,
        size: selectedSize,
        color:
            _product!['colors'] !=
                    null &&
                (_product!['colors']
                        as List)
                    .isNotEmpty
            ? _product!['colors'][selectedColorIndex]['name']
            : null,
      );

      if (response['success'] &&
          mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Added to cart!',
            ),
            backgroundColor: Colors.green,
            duration: Duration(
              seconds: 1,
            ),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (
                  context,
                ) => const CartScreen(),
          ),
        );
      }
    } catch (
      e
    ) {
      if (mounted) {
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
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_product ==
        null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: Text(
            'Product not found',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Product Image Section
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                // Top navigation
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.9,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(
                              context,
                            ),
                          ),
                        ),

                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.9,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.red
                                  : const Color(
                                      0xFF8B5CF6,
                                    ),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  isFavorite = !isFavorite;
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product Details Section
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(
                24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    24,
                  ),
                  topRight: Radius.circular(
                    24,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name and quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _product!['name'] ??
                              'Product',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      // Quantity selector
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
                                if (quantity >
                                    1) {
                                  setState(
                                    () {
                                      quantity--;
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
                              quantity.toString(),
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
                                    quantity++;
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        _product!['rating']?.toStringAsFixed(
                              1,
                            ) ??
                            '0.0',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        '(${_product!['reviewCount'] ?? 0} reviews)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // Description
                  Text(
                    _product!['description'] ??
                        'No description available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // Size and Color selection
                  Row(
                    children: [
                      // Size selection
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Choose Size',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              children:
                                  (_product!['sizes']
                                              as List? ??
                                          [])
                                      .map<
                                        Widget
                                      >(
                                        (
                                          size,
                                        ) {
                                          final sizeStr = size.toString();
                                          final isSelected =
                                              selectedSize ==
                                              sizeStr;
                                          return GestureDetector(
                                            onTap: () {
                                              setState(
                                                () {
                                                  selectedSize = sizeStr;
                                                },
                                              );
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                right: 12,
                                              ),
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? const Color(
                                                        0xFF8B5CF6,
                                                      )
                                                    : Colors.grey[100],
                                                borderRadius: BorderRadius.circular(
                                                  12,
                                                ),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? const Color(
                                                          0xFF8B5CF6,
                                                        )
                                                      : Colors.grey[300]!,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  sizeStr,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                      .toList(),
                            ),
                          ],
                        ),
                      ),

                      // Color selection
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Color',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children:
                                (_product!['colors']
                                            as List? ??
                                        [])
                                    .asMap()
                                    .entries
                                    .map<
                                      Widget
                                    >(
                                      (
                                        entry,
                                      ) {
                                        final index = entry.key;
                                        final colorData = entry.value;
                                        final hexCode =
                                            colorData['hexCode'] ??
                                            '#808080';
                                        final color = Color(
                                          int.parse(
                                                hexCode.substring(
                                                  1,
                                                ),
                                                radix: 16,
                                              ) +
                                              0xFF000000,
                                        );
                                        final isSelected =
                                            selectedColorIndex ==
                                            index;

                                        return GestureDetector(
                                          onTap: () {
                                            setState(
                                              () {
                                                selectedColorIndex = index;
                                              },
                                            );
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              right: 12,
                                            ),
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(
                                                        0xFF8B5CF6,
                                                      )
                                                    : Colors.transparent,
                                                width: 2,
                                              ),
                                            ),
                                            child: isSelected
                                                ? const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 16,
                                                  )
                                                : null,
                                          ),
                                        );
                                      },
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Add to Cart button
                  Container(
                    width: double.infinity,
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
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            30,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          const Text(
                            'Add to Cart | ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '\$${(_product!['price'] * quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_product!['originalPrice'] !=
                              null) ...[
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              '\$${(_product!['originalPrice'] * quantity).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
