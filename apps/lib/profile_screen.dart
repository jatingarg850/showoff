import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_screen.dart';
import 'community_screen.dart';
import 'store_screen.dart';
import 'achievements_screen.dart';
import 'edit_profile_screen.dart';
import 'main_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'services/api_service.dart';

class ProfileScreen
    extends
        StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<
    ProfileScreen
  >
  createState() => _ProfileScreenState();
}

class _ProfileScreenState
    extends
        State<
          ProfileScreen
        > {
  List<
    Map<
      String,
      dynamic
    >
  >
  _posts = [];
  bool
  _isLoading = true;

  @override
  void
  initState() {
    super.initState();
    _loadUserData();
  }

  Future<
    void
  >
  _loadUserData() async {
    final authProvider =
        Provider.of<
          AuthProvider
        >(
          context,
          listen: false,
        );
    final profileProvider =
        Provider.of<
          ProfileProvider
        >(
          context,
          listen: false,
        );

    await authProvider.refreshUser();
    await profileProvider.getStats();

    // Debug: Check user data
    print(
      'User data: ${authProvider.user}',
    );
    print(
      'Profile picture: ${authProvider.user?['profilePicture']}',
    );

    // Load user posts
    if (authProvider.user !=
        null) {
      try {
        final userId =
            authProvider.user!['_id'] ??
            authProvider.user!['id'] ??
            '';
        if (userId.isNotEmpty) {
          final response = await ApiService.getUserPosts(
            userId,
          );
          if (response['success']) {
            setState(
              () {
                _posts =
                    List<
                      Map<
                        String,
                        dynamic
                      >
                    >.from(
                      response['data'] ??
                          [],
                    );
                _isLoading = false;
              },
            );
          } else {
            setState(
              () => _isLoading = false,
            );
          }
        } else {
          setState(
            () => _isLoading = false,
          );
        }
      } catch (
        e
      ) {
        print(
          'Error loading posts: $e',
        );
        setState(
          () => _isLoading = false,
        );
      }
    } else {
      setState(
        () => _isLoading = false,
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
      body: SafeArea(
        child:
            Consumer<
              AuthProvider
            >(
              builder:
                  (
                    context,
                    authProvider,
                    _,
                  ) {
                    if (authProvider.user ==
                            null ||
                        _isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final user = authProvider.user!;

                    return Column(
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
                                      child:
                                          user['profilePicture'] !=
                                                  null &&
                                              user['profilePicture'].isNotEmpty
                                          ? Image.network(
                                              ApiService.getImageUrl(
                                                user['profilePicture'],
                                              ),
                                              width: 90,
                                              height: 90,
                                              fit: BoxFit.cover,
                                              loadingBuilder:
                                                  (
                                                    context,
                                                    child,
                                                    loadingProgress,
                                                  ) {
                                                    if (loadingProgress ==
                                                        null)
                                                      return child;
                                                    return const Center(
                                                      child: CircularProgressIndicator(),
                                                    );
                                                  },
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    print(
                                                      'Error loading profile picture: $error',
                                                    );
                                                    print(
                                                      'URL: ${ApiService.getImageUrl(user['profilePicture'])}',
                                                    );
                                                    return Container(
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
                                                      child: const Icon(
                                                        Icons.person,
                                                        color: Colors.white,
                                                        size: 45,
                                                      ),
                                                    );
                                                  },
                                            )
                                          : Container(
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
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 45,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 40,
                                  ),

                                  // Stats - properly aligned
                                  Expanded(
                                    child:
                                        Consumer<
                                          ProfileProvider
                                        >(
                                          builder:
                                              (
                                                context,
                                                profileProvider,
                                                _,
                                              ) {
                                                final stats = profileProvider.stats;
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    _buildStatColumn(
                                                      stats?['postsCount']?.toString() ??
                                                          '0',
                                                      'Posts',
                                                    ),
                                                    _buildStatColumn(
                                                      stats?['followersCount']?.toString() ??
                                                          '0',
                                                      'Followers',
                                                    ),
                                                    _buildStatColumn(
                                                      stats?['followingCount']?.toString() ??
                                                          '0',
                                                      'Following',
                                                    ),
                                                  ],
                                                );
                                              },
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
                                  Text(
                                    user['displayName'] ??
                                        'User',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),

                                  const Spacer(),

                                  // Edit button
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (
                                                context,
                                              ) => const EditProfileScreen(),
                                        ),
                                      ).then(
                                        (
                                          _,
                                        ) => _loadUserData(),
                                      );
                                    },
                                    child: Container(
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
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  user['bio'] ??
                                      'No bio yet',
                                  style: const TextStyle(
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
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (
                                                  context,
                                                ) => const AchievementsScreen(),
                                          ),
                                        );
                                      },
                                      child: _buildActionButtonWithImage(
                                        'assets/profile/achievement.png',
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (
                                                  context,
                                                ) => const StoreScreen(),
                                          ),
                                        );
                                      },
                                      child: _buildActionButtonWithImage(
                                        'assets/profile/store.png',
                                      ),
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
                                    'SYT',
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
                            child: _posts.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No posts yet',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 1,
                                    ),
                                    itemCount: _posts.length,
                                    itemBuilder:
                                        (
                                          context,
                                          index,
                                        ) {
                                          final post = _posts[index];
                                          return GestureDetector(
                                            onTap: () {
                                              // Navigate to main screen with reel tab and specific post
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => MainScreen(
                                                        initialIndex: 0,
                                                        initialPostId: post['_id'],
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: _getGridItemColor(
                                                  index,
                                                ),
                                                borderRadius: BorderRadius.circular(
                                                  12,
                                                ),
                                                image:
                                                    post['thumbnailUrl'] !=
                                                        null
                                                    ? DecorationImage(
                                                        image: NetworkImage(
                                                          ApiService.getImageUrl(
                                                            post['thumbnailUrl'],
                                                          ),
                                                        ),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : null,
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.play_arrow,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                  ),
                          ),
                        ),

                        // Space for navbar
                        const SizedBox(
                          height: 100,
                        ),
                      ],
                    );
                  },
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
    return SizedBox(
      width: 90,
      height: 90,
      child: Image.asset(
        imagePath,
        width: 90,
        height: 90,
        color: Colors.white,
        fit: BoxFit.contain,
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
