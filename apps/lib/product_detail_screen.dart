import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'services/api_service.dart';
import 'services/currency_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? _product;
  bool _isLoading = true;
  String? selectedSize;
  int selectedColorIndex = 0;
  int quantity = 1;
  bool isFavorite = false;

  // Currency data
  String _currencySymbol = '₹';
  double _exchangeRate = 1.0;
  String _currencyCode = 'INR';

  @override
  void initState() {
    super.initState();
    _initCurrency();
    _loadProduct();
  }

  Future<void> _initCurrency() async {
    try {
      final symbol = await CurrencyService.getCurrencySymbol();
      final rates = await CurrencyService.getExchangeRates();
      final currency = await CurrencyService.getUserCurrency();

      setState(() {
        _currencySymbol = symbol;
        _currencyCode = currency;
        _exchangeRate = rates[currency] ?? 1.0;
      });
    } catch (e) {
      debugPrint('Error initializing currency: $e');
    }
  }

  Future<void> _loadProduct() async {
    try {
      final response = await ApiService.getProduct(widget.productId);
      if (response['success']) {
        setState(() {
          _product = response['data'];
          if (_product!['sizes'] != null &&
              (_product!['sizes'] as List).isNotEmpty) {
            selectedSize = _product!['sizes'][0];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addToCart() async {
    if (_product == null) {
      return;
    }

    try {
      final response = await ApiService.addToCart(
        productId: widget.productId,
        quantity: quantity,
        size: selectedSize,
        color:
            _product!['colors'] != null &&
                (_product!['colors'] as List).isNotEmpty
            ? _product!['colors'][selectedColorIndex]['name']
            : null,
      );

      if (response['success'] && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to cart!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Ultra-responsive breakpoints
    final isXSmall = screenWidth < 320;
    final isSmall = screenWidth >= 320 && screenWidth < 375;
    final isMedium = screenWidth >= 375 && screenWidth < 600;
    final isLarge = screenWidth >= 600 && screenWidth < 900;

    // Calculate responsive values based on screen width
    double getResponsiveValue(
      double xs,
      double small,
      double medium,
      double large,
      double xlarge,
    ) {
      if (isXSmall) return xs;
      if (isSmall) return small;
      if (isMedium) return medium;
      if (isLarge) return large;
      return xlarge;
    }

    // Responsive dimensions
    final horizontalPadding = getResponsiveValue(8, 12, 16, 20, 24);
    final verticalSpacing = getResponsiveValue(6, 8, 12, 16, 20);
    final titleFontSize = getResponsiveValue(16, 18, 20, 22, 24);
    final labelFontSize = getResponsiveValue(11, 12, 13, 14, 15);
    final descriptionFontSize = getResponsiveValue(11, 12, 13, 14, 15);
    final buttonHeight = getResponsiveValue(40, 44, 48, 52, 56);
    final buttonFontSize = getResponsiveValue(11, 12, 13, 14, 15);
    final navButtonSize = getResponsiveValue(28, 32, 36, 40, 44);
    final navIconSize = getResponsiveValue(14, 16, 18, 20, 22);
    final quantityButtonSize = getResponsiveValue(24, 28, 30, 32, 36);
    final quantityContainerHeight = getResponsiveValue(24, 28, 30, 32, 36);
    final colorCircleSize = getResponsiveValue(28, 32, 34, 36, 40);
    final ratingIconSize = getResponsiveValue(12, 14, 16, 18, 20);
    final sizeButtonPaddingH = getResponsiveValue(8, 10, 12, 14, 16);
    final sizeButtonPaddingV = getResponsiveValue(4, 6, 8, 10, 12);
    final borderRadius = getResponsiveValue(6, 8, 10, 12, 14);

    // Image flex ratio based on orientation and screen size
    final imageFlexRatio = !isPortrait
        ? 1
        : (isXSmall || isSmall ? 2 : (isMedium ? 2.5 : 3));
    final detailsFlexRatio = !isPortrait
        ? 1
        : (isXSmall || isSmall ? 3 : (isMedium ? 2.5 : 2));

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: Text('Product not found')),
      );
    }

    // Landscape layout
    if (!isPortrait) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Row(
            children: [
              // Image section
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      child: _buildImageCarousel(),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _buildNavButton(
                        Icons.arrow_back,
                        navButtonSize,
                        navIconSize,
                        () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildNavButton(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        navButtonSize,
                        navIconSize,
                        () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                        color: isFavorite
                            ? Colors.red
                            : const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
              ),
              // Details section
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: SingleChildScrollView(
                    child: _buildDetailsContent(
                      horizontalPadding,
                      verticalSpacing,
                      titleFontSize,
                      labelFontSize,
                      descriptionFontSize,
                      buttonHeight,
                      buttonFontSize,
                      quantityButtonSize,
                      quantityContainerHeight,
                      colorCircleSize,
                      ratingIconSize,
                      sizeButtonPaddingH,
                      sizeButtonPaddingV,
                      borderRadius,
                      isXSmall,
                      isSmall,
                      isMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Portrait layout
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Product Image Section
          Expanded(
            flex: imageFlexRatio.toInt(),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  child: _buildImageCarousel(),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNavButton(
                          Icons.arrow_back,
                          navButtonSize,
                          navIconSize,
                          () => Navigator.pop(context),
                        ),
                        _buildNavButton(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          navButtonSize,
                          navIconSize,
                          () {
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                          },
                          color: isFavorite
                              ? Colors.red
                              : const Color(0xFF8B5CF6),
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
            flex: detailsFlexRatio.toInt(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(horizontalPadding),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: _buildDetailsContent(
                  horizontalPadding,
                  verticalSpacing,
                  titleFontSize,
                  labelFontSize,
                  descriptionFontSize,
                  buttonHeight,
                  buttonFontSize,
                  quantityButtonSize,
                  quantityContainerHeight,
                  colorCircleSize,
                  ratingIconSize,
                  sizeButtonPaddingH,
                  sizeButtonPaddingV,
                  borderRadius,
                  isXSmall,
                  isSmall,
                  isMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return _product!['images'] != null &&
            (_product!['images'] as List).isNotEmpty
        ? PageView.builder(
            itemCount: (_product!['images'] as List).length,
            itemBuilder: (context, index) {
              return Image.network(
                ApiService.getImageUrl(_product!['images'][index]),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.shopping_bag,
                        size: MediaQuery.of(context).size.width * 0.2,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              );
            },
          )
        : Container(
            color: Colors.grey[300],
            child: Center(
              child: Icon(
                Icons.shopping_bag,
                size: MediaQuery.of(context).size.width * 0.2,
                color: Colors.grey,
              ),
            ),
          );
  }

  Widget _buildNavButton(
    IconData icon,
    double size,
    double iconSize,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? Colors.black, size: iconSize),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildDetailsContent(
    double horizontalPadding,
    double verticalSpacing,
    double titleFontSize,
    double labelFontSize,
    double descriptionFontSize,
    double buttonHeight,
    double buttonFontSize,
    double quantityButtonSize,
    double quantityContainerHeight,
    double colorCircleSize,
    double ratingIconSize,
    double sizeButtonPaddingH,
    double sizeButtonPaddingV,
    double borderRadius,
    bool isXSmall,
    bool isSmall,
    bool isMedium,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name and quantity
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _product!['name'] ?? 'Product',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: verticalSpacing),
            // Quantity selector
            Row(
              children: [
                Container(
                  width: quantityButtonSize,
                  height: quantityContainerHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.remove, size: quantityButtonSize * 0.4),
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() {
                          quantity--;
                        });
                      }
                    },
                  ),
                ),
                Container(
                  width: quantityButtonSize + 8,
                  height: quantityContainerHeight,
                  alignment: Alignment.center,
                  child: Text(
                    quantity.toString(),
                    style: TextStyle(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: quantityButtonSize,
                  height: quantityContainerHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.add, size: quantityButtonSize * 0.4),
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: verticalSpacing),

        // Rating
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: ratingIconSize),
            SizedBox(width: verticalSpacing * 0.5),
            Text(
              _product!['rating']?.toStringAsFixed(1) ?? '0.0',
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: verticalSpacing * 0.5),
            Flexible(
              child: Text(
                '(${_product!['reviewCount'] ?? 0} reviews)',
                style: TextStyle(
                  fontSize: labelFontSize,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        SizedBox(height: verticalSpacing * 1.5),

        // Description
        Text(
          _product!['description'] ?? 'No description available',
          style: TextStyle(
            fontSize: descriptionFontSize,
            color: Colors.grey[600],
            height: 1.4,
          ),
          maxLines: isXSmall ? 2 : (isSmall ? 2 : 3),
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: verticalSpacing * 2),

        // Size and Color selection
        if (screenWidth < 600)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSizeSection(
                labelFontSize,
                sizeButtonPaddingH,
                sizeButtonPaddingV,
                borderRadius,
              ),
              SizedBox(height: verticalSpacing * 1.5),
              _buildColorSection(labelFontSize, colorCircleSize, borderRadius),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSizeSection(
                  labelFontSize,
                  sizeButtonPaddingH,
                  sizeButtonPaddingV,
                  borderRadius,
                ),
              ),
              SizedBox(width: verticalSpacing * 2),
              Expanded(
                child: _buildColorSection(
                  labelFontSize,
                  colorCircleSize,
                  borderRadius,
                ),
              ),
            ],
          ),

        SizedBox(height: verticalSpacing * 2),

        // Add to Cart button
        Container(
          width: double.infinity,
          height: buttonHeight,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: ElevatedButton(
            onPressed: _addToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: buttonFontSize + 2,
                ),
                SizedBox(width: verticalSpacing),
                Flexible(
                  child: Text(
                    'Add to Cart | ${_getProductPrice(_product!, quantity)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSection(
    double labelFontSize,
    double paddingH,
    double paddingV,
    double borderRadius,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Size',
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: paddingV),
        Wrap(
          spacing: paddingH,
          runSpacing: paddingV,
          children: (_product!['sizes'] as List? ?? []).map<Widget>((size) {
            final sizeStr = size.toString();
            final isSelected = selectedSize == sizeStr;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedSize = sizeStr;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: paddingH,
                  vertical: paddingV,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF8B5CF6)
                        : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  sizeStr,
                  style: TextStyle(
                    fontSize: labelFontSize - 1,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSection(
    double labelFontSize,
    double colorCircleSize,
    double borderRadius,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: colorCircleSize * 0.25),
        Wrap(
          spacing: colorCircleSize * 0.3,
          runSpacing: colorCircleSize * 0.3,
          children: (_product!['colors'] as List? ?? [])
              .asMap()
              .entries
              .map<Widget>((entry) {
                final index = entry.key;
                final colorData = entry.value;
                final hexCode = colorData['hexCode'] ?? '#808080';
                final color = Color(
                  int.parse(hexCode.substring(1), radix: 16) + 0xFF000000,
                );
                final isSelected = selectedColorIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColorIndex = index;
                    });
                  },
                  child: Container(
                    width: colorCircleSize,
                    height: colorCircleSize,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF8B5CF6)
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: colorCircleSize * 0.5,
                          )
                        : null,
                  ),
                );
              })
              .toList(),
        ),
      ],
    );
  }

  String _getProductPrice(Map<String, dynamic> product, int quantity) {
    final basePrice = (product['price'] ?? 0.0).toDouble();
    final cashAmount = (basePrice * 0.5) * quantity;
    final localAmount = cashAmount * _exchangeRate;
    final coinAmount = CurrencyService.getCoinAmount(localAmount);

    String formattedPrice;
    if (_currencyCode == 'JPY') {
      formattedPrice = '$_currencySymbol${localAmount.toStringAsFixed(0)}';
    } else {
      formattedPrice = '$_currencySymbol${localAmount.toStringAsFixed(2)}';
    }

    return '$formattedPrice + $coinAmount coins';
  }
}
