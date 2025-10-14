import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'community_screen.dart';

class ProfileScreen
    extends
        StatelessWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Profile header section
            Padding(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Column(
                children: [
                  // Profile picture and stats row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile picture
                      Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange,
                                  Colors.yellow,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Image.asset(
                              'assets/setup/coins.png',
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {
                                    return const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 45,
                                    );
                                  },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 40,
                      ),

                      // Stats - properly aligned
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn(
                              '200',
                              'Subscribers',
                            ),
                            _buildStatColumn(
                              '16k',
                              'Followers',
                            ),
                            _buildStatColumn(
                              '978',
                              'Following',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // Name and buttons row - properly aligned
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Sathon',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),

                      const Spacer(),

                      // Follow button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: const Text(
                          'Follow',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      // Edit button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      // Settings button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                    context,
                                  ) => const SettingsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(
                            8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // Bio text - left aligned
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Hi, How are you doing?Hi, How are you doing?Hi, How are you doing?Hi, How are you doing?Hi, How are you doing?Hi, How are you.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // Purple action buttons
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(
                            0xFF701CF5,
                          ),
                          Color(
                            0xFF701CF5,
                          ),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButtonWithImage(
                          'assets/profile/achievement.png',
                        ),
                        _buildActionButtonWithImage(
                          'assets/profile/store.png',
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      context,
                                    ) => const CommunityScreen(),
                              ),
                            );
                          },
                          child: _buildActionButtonWithImage(
                            'assets/profile/community.png',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // Tab bar - centered
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTab(
                        'Reels',
                        true,
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      _buildTab(
                        'Arena',
                        false,
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      _buildTab(
                        'Likes',
                        false,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: 9,
                  itemBuilder:
                      (
                        context,
                        index,
                      ) {
                        return Container(
                          decoration: BoxDecoration(
                            color: _getGridItemColor(
                              index,
                            ),
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        );
                      },
                ),
              ),
            ),

            const SizedBox(
              height: 100,
            ), // Space for navbar
          ],
        ),
      ),
    );
  }

  Widget
  _buildStatColumn(
    String number,
    String label,
  ) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget
  _buildActionButtonWithImage(
    String imagePath,
  ) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.2,
        ),
        borderRadius: BorderRadius.circular(
          15,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          12,
        ),
        child: Image.asset(
          imagePath,
          width: 36,
          height: 36,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget
  _buildTab(
    String title,
    bool isActive,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive
                ? Colors.black
                : Colors.grey,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        if (isActive)
          Container(
            width: 30,
            height: 2,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(
                1,
              ),
            ),
          ),
      ],
    );
  }

  Color
  _getGridItemColor(
    int index,
  ) {
    // Different colors for grid items to match the screenshot
    final colors = [
      Colors.black,
      const Color(
        0xFF8B4513,
      ), // Brown
      const Color(
        0xFF1E90FF,
      ), // Blue
      const Color(
        0xFF32CD32,
      ), // Green
      const Color(
        0xFFFF8C00,
      ), // Orange
      Colors.grey,
      const Color(
        0xFF8B5CF6,
      ), // Purple
      const Color(
        0xFF20B2AA,
      ), // Teal
      const Color(
        0xFF4169E1,
      ), // Royal Blue
    ];
    return colors[index %
        colors.length];
  }
}
