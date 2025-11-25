import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_screen.dart';
import 'enhanced_community_screen.dart';
import 'store_screen.dart';
import 'achievements_screen.dart';
import 'edit_profile_screen.dart';
import 'main_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _sytPosts = [];
  List<Map<String, dynamic>> _likedPosts = [];
  bool _isLoading = true;
  String selectedTab = 'Reels';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadLikedPosts() async {
    try {
      print('Loading liked posts...');
      // Get multiple pages of feed to find liked posts
      List<Map<String, dynamic>> allLikedPosts = [];

      for (int page = 1; page <= 5; page++) {
        // Check first 5 pages
        final feedResponse = await ApiService.getFeed(page: page, limit: 20);
        if (feedResponse['success']) {
          final posts = List<Map<String, dynamic>>.from(
            feedResponse['data'] ?? [],
          );

          // Check each post's like status
          for (final post in posts) {
            try {
              final statsResponse = await ApiService.getPostStats(post['_id']);
              if (statsResponse['success'] &&
                  statsResponse['data']['isLiked'] == true) {
                allLikedPosts.add(post);
                print('Found liked post: ${post['_id']}');
              }
            } catch (e) {
              print('Error checking post stats for ${post['_id']}: $e');
            }
          }

          if (posts.length < 20) {
            break; // No more posts
          }
        } else {
          break;
        }
      }

      setState(() {
        _likedPosts = allLikedPosts;
      });

      print('Total liked posts found: ${_likedPosts.length}');
    } catch (e) {
      print('Error loading liked posts: $e');
      setState(() {
        _likedPosts = [];
      });
    }
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    await authProvider.refreshUser();
    await profileProvider.getStats();

    // Debug: Check user data
    print('User data: ${authProvider.user}');
    print('Profile picture: ${authProvider.user?['profilePicture']}');

    // Load user posts
    if (authProvider.user != null) {
      try {
        final userId =
            authProvider.user!['_id'] ?? authProvider.user!['id'] ?? '';
        if (userId.isNotEmpty) {
          // Load regular posts
          final response = await ApiService.getUserPosts(userId);
          if (response['success']) {
            setState(() {
              _posts = List<Map<String, dynamic>>.from(response['data'] ?? []);
            });
          }

          // Load SYT posts
          final sytResponse = await ApiService.getSYTEntries();
          if (sytResponse['success']) {
            final allSYTEntries = List<Map<String, dynamic>>.from(
              sytResponse['data'] ?? [],
            );
            final userSYTEntries = allSYTEntries.where((entry) {
              final entryUserId = entry['user']?['_id'] ?? entry['user']?['id'];
              return entryUserId == userId;
            }).toList();

            setState(() {
              _sytPosts = userSYTEntries;
            });
          }

          // Load liked posts - get feed and filter liked ones
          await _loadLikedPosts();

          setState(() => _isLoading = false);
        } else {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        print('Error loading posts: $e');
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.user == null || _isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = authProvider.user!;

            return Column(
              children: [
                // Profile header section
                Padding(
                  padding: const EdgeInsets.all(20),
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
                                  user['profilePicture'] != null &&
                                      user['profilePicture'].isNotEmpty
                                  ? Image.network(
                                      ApiService.getImageUrl(
                                        user['profilePicture'],
                                      ),
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                      errorBuilder: (context, error, stackTrace) {
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

                          const SizedBox(width: 40),

                          // Stats - properly aligned
                          Expanded(
                            child: Consumer<ProfileProvider>(
                              builder: (context, profileProvider, _) {
                                final stats = profileProvider.stats;
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatColumn(
                                      stats?['postsCount']?.toString() ?? '0',
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

                      const SizedBox(height: 20),

                      // Name and buttons row - properly aligned
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user['displayName'] ?? 'User',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (user['isVerified'] == true)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Icon(
                                        Icons.verified,
                                        size: 20,
                                        color: Color(0xFF701CF5),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${user['username'] ?? 'user'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Edit button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
                                ),
                              ).then((_) => _loadUserData());
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
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

                          const SizedBox(width: 12),

                          // Settings button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
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

                      const SizedBox(height: 16),

                      // Bio text - left aligned
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          user['bio'] ?? 'No bio yet',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Purple action buttons
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF701CF5), Color(0xFF701CF5)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AchievementsScreen(),
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
                                    builder: (context) => const StoreScreen(),
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
                                    builder: (context) =>
                                        const EnhancedCommunityScreen(),
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

                      const SizedBox(height: 20),

                      // Tab bar - centered
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTab('Reels'),
                          const SizedBox(width: 30),
                          _buildTab('SYT'),
                          const SizedBox(width: 30),
                          _buildTab('Likes'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildTabContent(),
                  ),
                ),

                // Space for navbar
                const SizedBox(height: 100),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatColumn(String number, String label) {
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
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildActionButtonWithImage(String imagePath) {
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

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 'Reels':
        return _buildReelsGrid();
      case 'SYT':
        return _buildSYTGrid();
      case 'Likes':
        return _buildLikesGrid();
      default:
        return _buildReelsGrid();
    }
  }

  Widget _buildReelsGrid() {
    if (_posts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No reels yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your reels will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MainScreen(initialIndex: 0, initialPostId: post['_id']),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: _getGridItemColor(index),
              borderRadius: BorderRadius.circular(12),
              image: post['thumbnailUrl'] != null
                  ? DecorationImage(
                      image: NetworkImage(
                        ApiService.getImageUrl(post['thumbnailUrl']),
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: const Center(
              child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSYTGrid() {
    if (_sytPosts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No SYT entries yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your Show Your Talent entries will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _sytPosts.length,
      itemBuilder: (context, index) {
        final sytPost = _sytPosts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(
                  initialIndex: 1, // SYT tab
                  initialPostId: sytPost['_id'],
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(12),
              image: sytPost['thumbnailUrl'] != null
                  ? DecorationImage(
                      image: NetworkImage(
                        ApiService.getImageUrl(sytPost['thumbnailUrl']),
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                // SYT badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF701CF5), Color(0xFF3E98E4)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'SYT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Center(
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
                ),
                // Vote count
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.thumb_up,
                          color: Colors.white,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          sytPost['votesCount']?.toString() ?? '0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLikesGrid() {
    if (_likedPosts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No liked posts yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Posts you like will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _likedPosts.length,
      itemBuilder: (context, index) {
        final likedPost = _likedPosts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(
                  initialIndex: 0, // Reels tab
                  initialPostId: likedPost['_id'],
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.pink[100],
              borderRadius: BorderRadius.circular(12),
              image: likedPost['thumbnailUrl'] != null
                  ? DecorationImage(
                      image: NetworkImage(
                        ApiService.getImageUrl(likedPost['thumbnailUrl']),
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                // Liked badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
                const Center(
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
                ),
                // Like count
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.pink,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          likedPost['likesCount']?.toString() ?? '0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(String title) {
    final isActive = selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = title;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          if (isActive)
            Container(
              width: 30,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  Color _getGridItemColor(int index) {
    // Different colors for grid items to match the screenshot
    final colors = [
      Colors.black,
      const Color(0xFF8B4513), // Brown
      const Color(0xFF1E90FF), // Blue
      const Color(0xFF32CD32), // Green
      const Color(0xFFFF8C00), // Orange
      Colors.grey,
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF20B2AA), // Teal
      const Color(0xFF4169E1), // Royal Blue
    ];
    return colors[index % colors.length];
  }
}
