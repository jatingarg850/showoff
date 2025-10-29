import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'comments_screen.dart';
import 'gift_screen.dart';
import 'user_profile_screen.dart';
import 'search_screen.dart';
import 'messages_screen.dart';
import 'notification_screen.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'config/api_config.dart';

class ReelScreen
    extends
        StatefulWidget {
  final String?
  initialPostId;

  const ReelScreen({
    super.key,
    this.initialPostId,
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
  final PageController
  _pageController = PageController();

  List<
    Map<
      String,
      dynamic
    >
  >
  _posts = [];
  bool
  _isLoading = true;
  int
  _currentIndex = 0;
  String?
  _currentUserId;
  final Map<
    String,
    bool
  >
  _followStatus = {};

  // Video controllers
  final Map<
    int,
    VideoPlayerController?
  >
  _videoControllers = {};
  final Map<
    int,
    bool
  >
  _videoInitialized = {};

  @override
  void
  initState() {
    super.initState();
    _loadCurrentUser();
    _loadFeed();
  }

  Future<
    void
  >
  _loadCurrentUser() async {
    try {
      final user = await StorageService.getUser();
      if (user !=
          null) {
        setState(
          () {
            _currentUserId =
                user['_id'] ??
                user['id'];
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error loading current user: $e',
      );
    }
  }

  Future<
    void
  >
  _loadFeed() async {
    try {
      final response = await ApiService.getFeed(
        page: 1,
        limit: 20,
      );

      if (response['success']) {
        final posts =
            List<
              Map<
                String,
                dynamic
              >
            >.from(
              response['data'],
            );

        // Load stats for each post
        for (
          int i = 0;
          i <
              posts.length;
          i++
        ) {
          try {
            final statsResponse = await ApiService.getPostStats(
              posts[i]['_id'],
            );
            if (statsResponse['success']) {
              posts[i]['stats'] = statsResponse['data'];
            }
          } catch (
            e
          ) {
            print(
              'Error loading stats: $e',
            );
          }
        }

        setState(
          () {
            _posts = posts;
            _isLoading = false;
          },
        );

        // Check follow status for each post
        for (final post in posts) {
          final userId =
              post['user']?['_id'] ??
              post['user']?['id'];
          if (userId !=
              null) {
            _checkFollowStatus(
              userId,
            );
          }
        }

        // Find initial post index if provided
        int initialIndex = 0;
        if (widget.initialPostId !=
            null) {
          final index = _posts.indexWhere(
            (
              post,
            ) =>
                post['_id'] ==
                widget.initialPostId,
          );
          if (index !=
              -1) {
            initialIndex = index;
          }
        }

        // Initialize video at the correct index
        if (_posts.isNotEmpty) {
          // Jump to the initial post if specified
          if (initialIndex >
              0) {
            WidgetsBinding.instance.addPostFrameCallback(
              (
                _,
              ) {
                _pageController.jumpToPage(
                  initialIndex,
                );
              },
            );
          }
          _initializeVideoController(
            initialIndex,
          );
          _trackView(
            _posts[0]['_id'],
          );
        }
      }
    } catch (
      e
    ) {
      print(
        'Error loading feed: $e',
      );
      setState(
        () => _isLoading = false,
      );
    }
  }

  Future<
    void
  >
  _initializeVideoController(
    int index,
  ) async {
    if (_posts.isEmpty ||
        index >=
            _posts.length)
      return;

    final mediaUrl = _posts[index]['mediaUrl'];
    if (mediaUrl ==
            null ||
        mediaUrl.isEmpty)
      return;

    // Dispose existing controller
    _videoControllers[index]?.dispose();

    try {
      String videoUrl = mediaUrl;
      if (mediaUrl.startsWith(
        '/uploads',
      )) {
        videoUrl = '${ApiConfig.baseUrl}$mediaUrl';
      }

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(
          videoUrl,
        ),
      );
      _videoControllers[index] = controller;

      await controller.initialize();
      controller.setLooping(
        true,
      );

      if (mounted) {
        setState(
          () {
            _videoInitialized[index] = true;
          },
        );

        if (index ==
            _currentIndex) {
          controller.play();
        }
      }
    } catch (
      e
    ) {
      print(
        'Error initializing video $index: $e',
      );
      if (mounted) {
        setState(
          () {
            _videoInitialized[index] = false;
          },
        );
      }
    }
  }

  void
  _onPageChanged(
    int index,
  ) {
    setState(
      () {
        _currentIndex = index;
      },
    );

    // Pause all other videos
    _videoControllers.forEach(
      (
        key,
        controller,
      ) {
        if (key !=
            index) {
          controller?.pause();
        }
      },
    );

    // Play current video
    if (_videoInitialized[index] ==
        true) {
      _videoControllers[index]?.play();
    } else {
      _initializeVideoController(
        index,
      );
    }

    // Preload next video
    if (index +
            1 <
        _posts.length) {
      _initializeVideoController(
        index +
            1,
      );
    }

    // Track view
    if (_posts.isNotEmpty &&
        index <
            _posts.length) {
      _trackView(
        _posts[index]['_id'],
      );
    }
  }

  Future<
    void
  >
  _trackView(
    String postId,
  ) async {
    try {
      // Track view - using existing method
      await ApiService.toggleLike(
        postId,
      );
    } catch (
      e
    ) {
      print(
        'Error tracking view: $e',
      );
    }
  }

  Future<
    void
  >
  _toggleLike(
    String postId,
    int index,
  ) async {
    try {
      final response = await ApiService.toggleLike(
        postId,
      );
      if (response['success'] &&
          mounted) {
        // Reload stats to get accurate counts
        await _reloadPostStats(
          postId,
          index,
        );
      }
    } catch (
      e
    ) {
      print(
        'Error toggling like: $e',
      );
    }
  }

  Future<
    void
  >
  _reloadPostStats(
    String postId,
    int index,
  ) async {
    try {
      final statsResponse = await ApiService.getPostStats(
        postId,
      );
      if (statsResponse['success'] &&
          mounted) {
        setState(
          () {
            if (_posts[index]['stats'] ==
                null) {
              _posts[index]['stats'] = {};
            }
            _posts[index]['stats'] = statsResponse['data'];
            // Also update the post-level counts
            _posts[index]['likesCount'] = statsResponse['data']['likesCount'];
            _posts[index]['commentsCount'] = statsResponse['data']['commentsCount'];
            _posts[index]['sharesCount'] = statsResponse['data']['sharesCount'];
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error reloading stats: $e',
      );
    }
  }

  Future<
    void
  >
  _toggleBookmark(
    String postId,
    int index,
  ) async {
    try {
      final response = await ApiService.toggleBookmark(
        postId,
      );
      if (response['success'] &&
          mounted) {
        // Reload stats to get accurate counts
        await _reloadPostStats(
          postId,
          index,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              response['data']['isBookmarked']
                  ? 'Saved!'
                  : 'Removed from saved',
            ),
            duration: const Duration(
              seconds: 1,
            ),
          ),
        );
      }
    } catch (
      e
    ) {
      print(
        'Error toggling bookmark: $e',
      );
    }
  }

  Future<
    void
  >
  _sharePost(
    String postId,
    int index,
  ) async {
    try {
      final response = await ApiService.sharePost(
        postId,
      );
      if (response['success'] &&
          mounted) {
        // Reload stats to get accurate counts
        await _reloadPostStats(
          postId,
          index,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Shared!',
            ),
            duration: Duration(
              seconds: 1,
            ),
          ),
        );
      }
    } catch (
      e
    ) {
      print(
        'Error sharing post: $e',
      );
    }
  }

  Future<
    void
  >
  _checkFollowStatus(
    String userId,
  ) async {
    if (_currentUserId ==
            null ||
        userId ==
            _currentUserId) {
      return;
    }

    try {
      final response = await ApiService.checkFollowing(
        userId,
      );
      if (response['success'] &&
          mounted) {
        setState(
          () {
            _followStatus[userId] =
                response['isFollowing'] ??
                false;
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error checking follow status: $e',
      );
    }
  }

  Future<
    void
  >
  _toggleFollow(
    String userId,
  ) async {
    if (_currentUserId ==
            null ||
        userId ==
            _currentUserId) {
      return;
    }

    try {
      final isCurrentlyFollowing =
          _followStatus[userId] ??
          false;
      final response = isCurrentlyFollowing
          ? await ApiService.unfollowUser(
              userId,
            )
          : await ApiService.followUser(
              userId,
            );

      if (response['success'] &&
          mounted) {
        setState(
          () {
            _followStatus[userId] = !isCurrentlyFollowing;
          },
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlyFollowing
                  ? 'Unfollowed'
                  : 'Following',
            ),
            duration: const Duration(
              seconds: 1,
            ),
          ),
        );
      }
    } catch (
      e
    ) {
      print(
        'Error toggling follow: $e',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Follow feature not available',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  bool
  _shouldShowFollowButton(
    Map<
      String,
      dynamic
    >
    user,
  ) {
    final userId =
        user['_id'] ??
        user['id'];

    // Don't show if it's the current user's post
    if (_currentUserId !=
            null &&
        userId ==
            _currentUserId) {
      return false;
    }

    // Don't show if already following
    if (_followStatus[userId] ==
        true) {
      return false;
    }

    return true;
  }

  @override
  void
  dispose() {
    _pageController.dispose();
    _videoControllers.forEach(
      (
        key,
        controller,
      ) {
        controller?.dispose();
      },
    );
    _videoControllers.clear();
    super.dispose();
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (_posts.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.video_library_outlined,
                size: 80,
                color: Colors.white54,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'No Reels Yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Be the first to upload a reel!',
                style: TextStyle(
                  color: Colors.white.withOpacity(
                    0.7,
                  ),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: _onPageChanged,
        itemCount: _posts.length,
        itemBuilder:
            (
              context,
              index,
            ) {
              final post = _posts[index];
              final user =
                  post['user'] ??
                  {};
              final stats =
                  post['stats'] ??
                  {};

              return Stack(
                children: [
                  // Video Player
                  _buildVideoPlayer(
                    index,
                  ),

                  // Top Bar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(
                                  0.3,
                                ),
                                borderRadius: BorderRadius.circular(
                                  20,
                                ),
                              ),
                              child: const Text(
                                '00:30',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage(
                                    'assets/reel/up.png',
                                  ),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: BorderRadius.circular(
                                  30,
                                ),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Image.asset(
                                      'assets/upreel/search.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (
                                                context,
                                              ) => SearchScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Image.asset(
                                      'assets/upreel/coment.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (
                                                context,
                                              ) => MessagesScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Image.asset(
                                      'assets/upreel/notbell.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (
                                                context,
                                              ) => NotificationScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Right Side Actions
                  Positioned(
                    right: 8,
                    bottom: 250,
                    child: Container(
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/reel/side.png',
                          ),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(
                          35,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLikeButton(
                            stats['isLiked'] ??
                                false,
                            stats['likesCount']?.toString() ??
                                '0',
                            () => _toggleLike(
                              post['_id'],
                              index,
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          _buildActionButton(
                            'assets/sidereel/comment.png',
                            stats['commentsCount']?.toString() ??
                                '0',
                            () async {
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder:
                                    (
                                      context,
                                    ) => CommentsScreen(
                                      postId: post['_id'],
                                    ),
                              );
                              // Reload stats after comments modal closes
                              await _reloadPostStats(
                                post['_id'],
                                index,
                              );
                            },
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          _buildBookmarkButton(
                            stats['isBookmarked'] ??
                                false,
                            stats['bookmarksCount']?.toString() ??
                                '0',
                            () => _toggleBookmark(
                              post['_id'],
                              index,
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          _buildActionButton(
                            'assets/sidereel/share.png',
                            stats['sharesCount']?.toString() ??
                                '0',
                            () => _sharePost(
                              post['_id'],
                              index,
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          _buildActionButton(
                            'assets/sidereel/gift.png',
                            '',
                            () async {
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder:
                                    (
                                      context,
                                    ) => GiftScreen(
                                      recipientId:
                                          post['user']?['_id'] ??
                                          '',
                                      recipientName:
                                          post['user']?['username'] ??
                                          'user',
                                    ),
                              );
                              // Reload stats after gift modal closes
                              await _reloadPostStats(
                                post['_id'],
                                index,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom User Info
                  Positioned(
                    left: 16,
                    right: 80,
                    bottom: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      context,
                                    ) => UserProfileScreen(
                                      userInfo: user,
                                    ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child:
                                      user['profilePicture'] !=
                                          null
                                      ? Image.network(
                                          ApiService.getImageUrl(
                                            user['profilePicture'],
                                          ),
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
                                                );
                                              },
                                        )
                                      : const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(
                                user['username'] ??
                                    'user',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              if (_shouldShowFollowButton(
                                user,
                              ))
                                GestureDetector(
                                  onTap: () => _toggleFollow(
                                    user['_id'] ??
                                        user['id'],
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(
                                            0xFF701CF5,
                                          ),
                                          Color(
                                            0xFF3E98E4,
                                          ),
                                        ],
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          post['caption'] ??
                              '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
      ),
    );
  }

  Widget
  _buildVideoPlayer(
    int index,
  ) {
    if (_videoInitialized[index] ==
            true &&
        _videoControllers[index] !=
            null) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoControllers[index]!.value.size.width,
            height: _videoControllers[index]!.value.size.height,
            child: VideoPlayer(
              _videoControllers[index]!,
            ),
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget
  _buildActionButton(
    String imagePath,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: 28,
            height: 28,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(
              height: 2,
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget
  _buildLikeButton(
    bool isLiked,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLiked
                ? Icons.favorite
                : Icons.favorite_border,
            color: isLiked
                ? Colors.red
                : Colors.white,
            size: 28,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(
              height: 2,
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget
  _buildBookmarkButton(
    bool isBookmarked,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBookmarked
                ? Icons.bookmark
                : Icons.bookmark_border,
            color: isBookmarked
                ? Colors.yellow
                : Colors.white,
            size: 28,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(
              height: 2,
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
