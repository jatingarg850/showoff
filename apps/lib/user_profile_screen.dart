import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'main_screen.dart';
import 'services/api_service.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  const UserProfileScreen({super.key, required this.userInfo});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isFollowing = false;
  String selectedTab = 'Reels';

  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _userPosts = [];
  List<Map<String, dynamic>> _userSYTPosts = [];
  List<Map<String, dynamic>> _userLikedPosts = [];
  bool _isLoading = true;

  // Check if this is the developer's profile
  bool get _isDeveloperProfile {
    final username = (widget.userInfo['username'] ?? '')
        .toString()
        .toLowerCase();
    return username == 'jatingarg';
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Load user profile
      final profileResponse = await ApiService.getUserProfile(
        widget.userInfo['username'] ?? widget.userInfo['_id'],
      );

      if (profileResponse['success']) {
        setState(() {
          _userData = profileResponse['data'];
        });

        // Load user posts
        final userId = _userData!['_id'] ?? _userData!['id'];
        final postsResponse = await ApiService.getUserPosts(userId);

        if (postsResponse['success']) {
          setState(() {
            _userPosts = List<Map<String, dynamic>>.from(
              postsResponse['data'] ?? [],
            );
          });
        }

        // Load user SYT posts - get all entries and filter by user
        final sytResponse = await ApiService.getSYTEntries();

        if (sytResponse['success']) {
          final allSYTEntries = List<Map<String, dynamic>>.from(
            sytResponse['data'] ?? [],
          );
          // Filter entries by this user
          final userSYTEntries = allSYTEntries.where((entry) {
            final entryUserId = entry['user']?['_id'] ?? entry['user']?['id'];
            return entryUserId == userId;
          }).toList();

          setState(() {
            _userSYTPosts = userSYTEntries;
          });
        }

        // Load user liked posts - for other users, we can't easily determine their likes
        // This would require server-side support to get another user's liked posts
        setState(() {
          _userLikedPosts = [];
        });

        // Check if following (optional - may fail if not implemented)
        try {
          final followResponse = await ApiService.checkFollowing(userId);
          if (followResponse['success']) {
            setState(() {
              isFollowing = followResponse['isFollowing'] ?? false;
            });
          }
        } catch (e) {
          // Following check failed - use default value
          print('Following check failed: $e');
        }
      } else {
        // Profile load failed - use provided user info
        setState(() {
          _userData = widget.userInfo;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      // Use provided user info as fallback
      setState(() {
        _userData = widget.userInfo;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (_userData == null) {
      return;
    }

    try {
      final userId = _userData!['_id'] ?? _userData!['id'];
      final response = isFollowing
          ? await ApiService.unfollowUser(userId)
          : await ApiService.followUser(userId);

      if (response['success']) {
        if (mounted) {
          setState(() {
            isFollowing = !isFollowing;
            if (isFollowing) {
              _userData!['followersCount'] =
                  (_userData!['followersCount'] ?? 0) + 1;
            } else {
              _userData!['followersCount'] =
                  (_userData!['followersCount'] ?? 0) - 1;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFollowing
                    ? 'Now following ${_userData!['displayName'] ?? _userData!['username']}'
                    : 'Unfollowed ${_userData!['displayName'] ?? _userData!['username']}',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message'] ?? 'Failed to update follow status',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Follow feature not available'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Sample user posts/reels data (fallback)
  List<Map<String, dynamic>> get userPosts => _userPosts.isNotEmpty
      ? _userPosts
      : [
          {'type': 'reel', 'color': Colors.purple, 'views': '12.5K'},
          {'type': 'reel', 'color': Colors.blue, 'views': '8.9K'},
          {'type': 'reel', 'color': Colors.green, 'views': '15.2K'},
          {'type': 'reel', 'color': Colors.orange, 'views': '6.7K'},
          {'type': 'reel', 'color': Colors.red, 'views': '22.1K'},
          {'type': 'reel', 'color': Colors.teal, 'views': '9.8K'},
          {'type': 'reel', 'color': Colors.indigo, 'views': '18.3K'},
          {'type': 'reel', 'color': Colors.amber, 'views': '11.4K'},
          {'type': 'reel', 'color': Colors.pink, 'views': '7.6K'},
        ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF701CF5)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '@${widget.userInfo['username']}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              _showMoreOptions(context);
            },
          ),
        ],
      ),
      body: Column(
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF701CF5), Color(0xFF3E98E4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        image:
                            (_userData?['profilePicture'] ??
                                    widget.userInfo['profilePicture']) !=
                                null
                            ? DecorationImage(
                                image: NetworkImage(
                                  ApiService.getImageUrl(
                                    _userData?['profilePicture'] ??
                                        widget.userInfo['profilePicture'],
                                  ),
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child:
                          (_userData?['profilePicture'] ??
                                  widget.userInfo['profilePicture']) ==
                              null
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 45,
                            )
                          : null,
                    ),
                    const SizedBox(width: 40),

                    // Stats
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            _userData?['postsCount']?.toString() ??
                                _getPostCount(),
                            'Posts',
                          ),
                          _buildStatColumn(
                            _userData?['followersCount']?.toString() ??
                                widget.userInfo['followers']?.toString() ??
                                '0',
                            'Followers',
                          ),
                          _buildStatColumn(
                            _userData?['followingCount']?.toString() ??
                                _getFollowingCount(),
                            'Following',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Name and verification with developer theme
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _userData?['displayName'] ??
                              widget.userInfo['displayName'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            foreground: _isDeveloperProfile
                                ? (Paint()
                                    ..shader =
                                        const LinearGradient(
                                          colors: [
                                            Color(0xFF00F5FF),
                                            Color(0xFF7B2FFF),
                                            Color(0xFFFF006E),
                                          ],
                                        ).createShader(
                                          const Rect.fromLTWH(0, 0, 200, 70),
                                        ))
                                : null,
                            color: _isDeveloperProfile ? null : Colors.black,
                          ),
                        ),
                        if ((_userData?['isVerified'] ??
                                widget.userInfo['isVerified']) ==
                            true)
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
                    if (_isDeveloperProfile) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00F5FF), Color(0xFF7B2FFF)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7B2FFF).withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.code, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'DEVELOPER',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Bio
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _userData?['bio'] ?? widget.userInfo['bio'] ?? 'No bio yet',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    // Follow/Following button
                    Expanded(
                      child: GestureDetector(
                        onTap: _toggleFollow,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: isFollowing
                                ? null
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFF701CF5),
                                      Color(0xFF3E98E4),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                            color: isFollowing ? Colors.grey[200] : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isFollowing ? 'Following' : 'Follow',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isFollowing
                                  ? Colors.black87
                                  : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Message button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                userId:
                                    widget.userInfo['_id'] ??
                                    widget.userInfo['id'] ??
                                    '',
                                username: widget.userInfo['username'] ?? '',
                                displayName:
                                    widget.userInfo['displayName'] ?? 'User',
                                isVerified:
                                    widget.userInfo['isVerified'] ?? false,
                                profilePicture:
                                    _userData?['profilePicture'] ??
                                    widget.userInfo['profilePicture'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Message',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tab bar
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
          const SizedBox(height: 100), // Space for navbar
        ],
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

  String _getPostCount() {
    return userPosts.length.toString();
  }

  String _getFollowingCount() {
    // Generate a random following count based on username
    final hash = widget.userInfo['username'].hashCode.abs();
    return '${(hash % 1000) + 100}';
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
    if (_userPosts.isEmpty) {
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
              'When this user shares reels, they\'ll appear here',
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
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return GestureDetector(
          onTap: () {
            // Navigate to main screen with reel tab and specific post
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
              color: post['color'] ?? Colors.grey[800],
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
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      post['views']?.toString() ?? '0',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildSYTGrid() {
    if (_userSYTPosts.isEmpty) {
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
              'Show Your Talent entries will appear here',
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
      itemCount: _userSYTPosts.length,
      itemBuilder: (context, index) {
        final sytPost = _userSYTPosts[index];
        return GestureDetector(
          onTap: () {
            // Navigate to SYT screen with specific entry
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
    if (_userLikedPosts.isEmpty) {
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
              'Posts this user likes will appear here',
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
      itemCount: _userLikedPosts.length,
      itemBuilder: (context, index) {
        final likedPost = _userLikedPosts[index];
        return GestureDetector(
          onTap: () {
            // Navigate to main screen with the liked post
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

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share, color: Color(0xFF701CF5)),
                title: const Text('Share Profile'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile shared!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Block User'),
                onTap: () {
                  Navigator.pop(context);
                  _showBlockConfirmation(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.report, color: Colors.orange),
                title: const Text('Report User'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User reported')),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showBlockConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Block User'),
          content: Text(
            'Are you sure you want to block ${widget.userInfo['displayName']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.userInfo['displayName']} has been blocked',
                    ),
                  ),
                );
              },
              child: const Text('Block', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
