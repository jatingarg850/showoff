import 'package:flutter/material.dart';
import 'community_chat_screen.dart';

class CommunityScreen
    extends
        StatelessWidget {
  const CommunityScreen({
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
          'Community',
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
          // Scrollable content
          ListView(
            padding: const EdgeInsets.all(
              20,
            ),
            children: [
              _buildCommunityCard(
                context,
                title: 'Building digital skills: How to maximize the current market.',
                members: '6.5k',
                category: 'Arts',
                backgroundImage: 'assets/community/arts_bg.jpg',
                categoryColor: const Color(
                  0xFF8B5CF6,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              _buildCommunityCard(
                context,
                title: 'Building digital skills: How to maximize the current market.',
                members: '6.5k',
                category: 'Dance',
                backgroundImage: 'assets/community/dance_bg.jpg',
                categoryColor: const Color(
                  0xFF8B5CF6,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              _buildCommunityCard(
                context,
                title: 'Building digital skills: How to maximize the current market.',
                members: '6.5k',
                category: 'Drama',
                backgroundImage: 'assets/community/drama_bg.jpg',
                categoryColor: const Color(
                  0xFF8B5CF6,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              _buildCommunityCard(
                context,
                title: 'Building digital skills: How to maximize the current market.',
                members: '6.5k',
                category: 'Drama',
                backgroundImage: 'assets/community/drama2_bg.jpg',
                categoryColor: const Color(
                  0xFF8B5CF6,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              _buildCommunityCard(
                context,
                title: '',
                members: '',
                category: '',
                backgroundImage: 'assets/community/dark_bg.jpg',
                categoryColor: Colors.transparent,
                isLastCard: true,
              ),
              const SizedBox(
                height: 100,
              ), // Extra space for floating buttons
            ],
          ),

          // Fixed floating action buttons
          Positioned(
            right: 20,
            bottom: 120,
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
                GestureDetector(
                  onTap: () => _showCreateGroupBottomSheet(
                    context,
                  ),
                  child: Container(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void
  _showCreateGroupBottomSheet(
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (
            context,
          ) => Container(
            height:
                MediaQuery.of(
                  context,
                ).size.height *
                0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  20,
                ),
                topRight: Radius.circular(
                  20,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(
                          2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // Title
                  const Text(
                    'Group details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(
                    height: 32,
                  ),

                  // Group category
                  const Text(
                    'Group category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(
                          0xFF8B5CF6,
                        ),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Choose a group category',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(
                            0xFF8B5CF6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // Group Name
                  const Text(
                    'Group Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(
                          0xFF8B5CF6,
                        ),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Group name',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // Group Banner
                  const Text(
                    'Group Banner',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(
                          0xFF8B5CF6,
                        ),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Upload group Banner',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Create button
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
                            0xFF8B5CF6,
                          ),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        28,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );
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
                        'Create',
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
          ),
    );
  }

  Widget
  _buildCommunityCard(
    BuildContext context, {
    required String title,
    required String members,
    required String category,
    required String backgroundImage,
    required Color categoryColor,
    bool isLastCard = false,
  }) {
    return Container(
      height: isLastCard
          ? 120
          : 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          16,
        ),
        color: Colors.grey[300], // Fallback color
      ),
      child: Stack(
        children: [
          // Background with overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                16,
              ),
              color: isLastCard
                  ? const Color(
                      0xFF2D3748,
                    )
                  : Colors.grey[600],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  16,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(
                      alpha: 0.3,
                    ),
                    Colors.black.withValues(
                      alpha: 0.7,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          if (!isLastCard)
            Padding(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),

                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // Bottom row with members and category
                  Row(
                    children: [
                      // Members count
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            members,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        width: 20,
                      ),

                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(
                            8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.apps,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Join button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                    context,
                                  ) => CommunityChatScreen(
                                    communityName: category.isNotEmpty
                                        ? category
                                        : 'Best Friends',
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: const Text(
                            'Join',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
}
