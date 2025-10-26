import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'services/api_service.dart';

class UserProfileScreen
    extends
        StatefulWidget {
  final Map<
    String,
    dynamic
  >
  userInfo;

  const UserProfileScreen({
    super.key,
    required this.userInfo,
  });

  @override
  State<
    UserProfileScreen
  >
  createState() => _UserProfileScreenState();
}

class _UserProfileScreenState
    extends
        State<
          UserProfileScreen
        > {
  bool
  isFollowing = false;
  String
  selectedTab = 'Reels';

  Map<
    String,
    dynamic
  >?
  _userData;
  List<
    Map<
      String,
      dynamic
    >
  >
  _userPosts = [];
  bool
  _isLoading = true;

  @override
  void
  initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<
    void
  >
  _loadUserProfile() async {
    try {
      // Load user profile
      final profileResponse = await ApiService.getUserProfile(
        widget.userInfo['username'],
      );
      if (profileResponse['success']) {
        setState(
          () {
            _userData = profileResponse['data'];
          },
        );

        // Load user posts
        final postsResponse = await ApiService.getUserPosts(
          _userData!['id'],
        );
        if (postsResponse['success']) {
          setState(
            () {
              _userPosts =
                  List<
                    Map<
                      String,
                      dynamic
                    >
                  >.from(
                    postsResponse['data'],
                  );
            },
          );
        }

        // Check if following
        final followResponse = await ApiService.checkFollowing(
          _userData!['id'],
        );
        if (followResponse['success']) {
          setState(
            () {
              isFollowing = followResponse['isFollowing'];
              _isLoading = false;
            },
          );
        }
      }
    } catch (
      e
    ) {
      print(
        'Error loading profile: $e',
      );
      setState(
        () {
          _isLoading = false;
          _userData = widget.userInfo;
        },
      );
    }
  }

  Future<
    void
  >
  _toggleFollow() async {
    if (_userData ==
        null)
      return;

    try {
      final response = isFollowing
          ? await ApiService.unfollowUser(
              _userData!['id'],
            )
          : await ApiService.followUser(
              _userData!['id'],
            );

      if (response['success']) {
        setState(
          () {
            isFollowing = !isFollowing;
            if (isFollowing) {
              _userData!['followersCount'] =
                  (_userData!['followersCount'] ??
                      0) +
                  1;
            } else {
              _userData!['followersCount'] =
                  (_userData!['followersCount'] ??
                      0) -
                  1;
            }
          },
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              isFollowing
                  ? 'Now following ${_userData!['displayName']}'
                  : 'Unfollowed ${_userData!['displayName']}',
            ),
            duration: const Duration(
              seconds: 2,
            ),
          ),
        );
      }
    } catch (
      e
    ) {
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

  // Sample user posts/reels data (fallback)
  List<
    Map<
      String,
      dynamic
    >
  >
  get userPosts => _userPosts.isNotEmpty
      ? _userPosts
      : [
          {
            'type': 'reel',
            'color': Colors.purple,
            'views': '12.5K',
          },
          {
            'type': 'reel',
            'color': Colors.blue,
            'views': '8.9K',
          },
          {
            'type': 'reel',
            'color': Colors.green,
            'views': '15.2K',
          },
          {
            'type': 'reel',
            'color': Colors.orange,
            'views': '6.7K',
          },
          {
            'type': 'reel',
            'color': Colors.red,
            'views': '22.1K',
          },
          {
            'type': 'reel',
            'color': Colors.teal,
            'views': '9.8K',
          },
          {
            'type': 'reel',
            'color': Colors.indigo,
            'views': '18.3K',
          },
          {
            'type': 'reel',
            'color': Colors.amber,
            'views': '11.4K',
          },
          {
            'type': 'reel',
            'color': Colors.pink,
            'views': '7.6K',
          },
        ];

  @override
  Widget
  build(
    BuildContext context,
  ) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<
                  Color
                >(
                  Color(
                    0xFF701CF5,
                  ),
                ),
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
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(
            context,
          ),
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
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            onPressed: () {
              _showMoreOptions(
                context,
              );
            },
          ),
        ],
      ),
      body: Column(
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(
                              0xFF701CF5,
                            ),
                            Color(
                              0xFF3E98E4,
                            ),
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
                    const SizedBox(
                      width: 40,
                    ),

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
                const SizedBox(
                  height: 20,
                ),

                // Name and verification
                Row(
                  children: [
                    Text(
                      _userData?['displayName'] ??
                          widget.userInfo['displayName'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if ((_userData?['isVerified'] ??
                            widget.userInfo['isVerified']) ==
                        true)
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 8,
                        ),
                        child: Icon(
                          Icons.verified,
                          size: 20,
                          color: Color(
                            0xFF701CF5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),

                // Bio
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _userData?['bio'] ??
                        widget.userInfo['bio'] ??
                        'No bio yet',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                // Action buttons
                Row(
                  children: [
                    // Follow/Following button
                    Expanded(
                      child: GestureDetector(
                        onTap: _toggleFollow,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: isFollowing
                                ? null
                                : const LinearGradient(
                                    colors: [
                                      Color(
                                        0xFF701CF5,
                                      ),
                                      Color(
                                        0xFF3E98E4,
                                      ),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                            color: isFollowing
                                ? Colors.grey[200]
                                : null,
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: Text(
                            isFollowing
                                ? 'Following'
                                : 'Follow',
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
                    const SizedBox(
                      width: 12,
                    ),

                    // Message button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                    context,
                                  ) => ChatScreen(
                                    userId:
                                        widget.userInfo['_id'] ??
                                        widget.userInfo['id'] ??
                                        '',
                                    username:
                                        widget.userInfo['username'] ??
                                        '',
                                    displayName:
                                        widget.userInfo['displayName'] ??
                                        'User',
                                    isVerified:
                                        widget.userInfo['isVerified'] ??
                                        false,
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
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
                const SizedBox(
                  height: 20,
                ),

                // Tab bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTab(
                      'Reels',
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    _buildTab(
                      'SYT',
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    _buildTab(
                      'Likes',
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
                itemCount: userPosts.length,
                itemBuilder:
                    (
                      context,
                      index,
                    ) {
                      final post = userPosts[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: post['color'],
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 30,
                              ),
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
                                  color: Colors.black.withValues(
                                    alpha: 0.7,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    4,
                                  ),
                                ),
                                child: Text(
                                  post['views'],
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
  _buildTab(
    String title,
  ) {
    final isActive =
        selectedTab ==
        title;
    return GestureDetector(
      onTap: () {
        setState(
          () {
            selectedTab = title;
          },
        );
      },
      child: Column(
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
      ),
    );
  }

  String
  _getPostCount() {
    return userPosts.length.toString();
  }

  String
  _getFollowingCount() {
    // Generate a random following count based on username
    final hash = widget.userInfo['username'].hashCode.abs();
    return '${(hash % 1000) + 100}';
  }

  void
  _showMoreOptions(
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            20,
          ),
        ),
      ),
      builder:
          (
            BuildContext context,
          ) {
            return Container(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.share,
                      color: Color(
                        0xFF701CF5,
                      ),
                    ),
                    title: const Text(
                      'Share Profile',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                      );
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Profile shared!',
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.block,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Block User',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                      );
                      _showBlockConfirmation(
                        context,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.report,
                      color: Colors.orange,
                    ),
                    title: const Text(
                      'Report User',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                      );
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'User reported',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            );
          },
    );
  }

  void
  _showBlockConfirmation(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder:
          (
            BuildContext context,
          ) {
            return AlertDialog(
              title: const Text(
                'Block User',
              ),
              content: Text(
                'Are you sure you want to block ${widget.userInfo['displayName']}?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(
                    context,
                  ),
                  child: const Text(
                    'Cancel',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${widget.userInfo['displayName']} has been blocked',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Block',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            );
          },
    );
  }
}
