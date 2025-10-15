import 'package:flutter/material.dart';
import 'product_detail_screen.dart';

class StoreScreen
    extends
        StatelessWidget {
  const StoreScreen({
    super.key,
  });

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
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder:
                        (
                          context,
                          index,
                        ) {
                          final items = [
                            {
                              'price': '\$17.00',
                              'image': 'assets/store/item1.jpg',
                            },
                            {
                              'price': '\$32.00',
                              'image': 'assets/store/item2.jpg',
                            },
                            {
                              'price': '\$21.00',
                              'image': 'assets/store/item3.jpg',
                            },
                          ];
                          return _buildNewItemCard(
                            context,
                            items[index]['price']!,
                            items[index]['image']!,
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
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder:
                        (
                          context,
                          index,
                        ) {
                          final badges = [
                            'New',
                            'Sale',
                            'Hot',
                            '',
                          ];
                          final colors = [
                            Colors.blue,
                            Colors.red,
                            Colors.orange,
                            Colors.grey,
                          ];
                          return _buildPopularItemCard(
                            context,
                            '1780',
                            badges[index],
                            colors[index],
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
                ), // Space for bottom cart
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
                    const Text(
                      'Add to Cart | ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      '\$162.99',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      '\$190.99',
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
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
    String price,
    String imagePath,
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
                  productName: 'Light Dress Bless',
                  price: price,
                ),
          ),
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
                      Icons.person,
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
            const Text(
              'Lorem ipsum dolor sit amet consectetur.',
              style: TextStyle(
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
              price,
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
    String price,
    String badge,
    Color badgeColor,
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
                  productName: 'Light Dress Bless',
                  price: '\$$price',
                ),
          ),
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
                      Icons.person,
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
                  price,
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
                          badge,
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
          // Background pattern/image placeholder
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

          // Content
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
