import 'package:flutter/material.dart';
import 'comments_screen.dart';
import 'gift_screen.dart';

class ReelScreen
    extends
        StatefulWidget {
  const ReelScreen({
    super.key,
  });

  @override
  State<
    ReelScreen
  >
  createState() => _ReelScreenState();
}

class _ReelScreenState
    extends
        State<
          ReelScreen
        > {
  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background video/image placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[800]!,
                  Colors.grey[600]!,
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.white54,
                size: 80,
              ),
            ),
          ),

          // Top bar
          Positioned(
            top:
                MediaQuery.of(
                  context,
                ).padding.top +
                10,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(
                  25,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Right side action buttons in rounded container
          Positioned(
            right: 12,
            top:
                MediaQuery.of(
                  context,
                ).size.height *
                0.35,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.6,
                ),
                borderRadius: BorderRadius.circular(
                  30,
                ),
              ),
              child: Column(
                children: [
                  // Like button
                  Column(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 28,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        '8976',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // Comment button
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder:
                            (
                              context,
                            ) => const CommentsScreen(),
                      );
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          '4576',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // Save/Bookmark button
                  Column(
                    children: [
                      Icon(
                        Icons.bookmark_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        '200',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // Share button
                  Column(
                    children: [
                      Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        '200',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // Gift button
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder:
                            (
                              context,
                            ) => const GiftScreen(),
                      );
                    },
                    child: Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom user info
          Positioned(
            left: 16,
            right: 80,
            bottom: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info row
                Row(
                  children: [
                    // Profile picture placeholder
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        color: Colors.grey[400],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),

                    // Username
                    const Text(
                      'Sathon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),

                    // Follow button with purple gradient
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(
                              0xFF6C5CE7,
                            ),
                            Color(
                              0xFF8B7ED8,
                            ),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: const Text(
                        'Follow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 12,
                ),

                // Description
                const Text(
                  'A bird flying in the sky soaring high in the sky scouting for its prey....😍',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // Floating action button (top right of bottom nav)
          Positioned(
            right: 20,
            bottom: 110,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.2,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // Floating bottom navigation bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF6C5CE7,
                ),
                borderRadius: BorderRadius.circular(
                  25,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.15,
                    ),
                    blurRadius: 20,
                    offset: const Offset(
                      0,
                      8,
                    ),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reels icon (active) with white circle
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(
                          8,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Color(
                            0xFF6C5CE7,
                          ),
                          size: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Container(
                        width: 24,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Gift icon
                  const Icon(
                    Icons.card_giftcard_outlined,
                    color: Colors.white,
                    size: 26,
                  ),

                  // Add/Plus icon
                  const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30,
                  ),

                  // Folder icon
                  const Icon(
                    Icons.folder_outlined,
                    color: Colors.white,
                    size: 26,
                  ),

                  // Profile icon
                  const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 26,
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
