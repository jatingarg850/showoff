import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'comments_screen.dart';
import 'gift_screen.dart';
import 'services/api_service.dart';

class SYTReelScreen
    extends
        StatefulWidget {
  final List<
    Map<
      String,
      dynamic
    >
  >
  competitions;
  final int
  initialIndex;

  const SYTReelScreen({
    super.key,
    required this.competitions,
    this.initialIndex = 0,
  });

  @override
  State<
    SYTReelScreen
  >
  createState() => _SYTReelScreenState();
}

class _SYTReelScreenState
    extends
        State<
          SYTReelScreen
        >
    with
        TickerProviderStateMixin {
  late PageController
  _pageController;

  late AnimationController
  _fadeController;
  late Animation<
    double
  >
  _fadeAnimation;

  int
  _currentIndex = 0;

  // Track liked, voted and saved states for each reel
  final Map<
    int,
    bool
  >
  _likedReels = {};
  final Map<
    int,
    bool
  >
  _votedReels = {};
  final Map<
    int,
    bool
  >
  _savedReels = {};
  final Map<
    int,
    int?
  >
  _hoursUntilNextVote = {};

  // Video controllers for each reel
  final Map<
    int,
    VideoPlayerController?
  >
  _videoControllers = {};

  @override
  void
  initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    // Initialize PageController with initial page
    _pageController = PageController(
      initialPage: widget.initialIndex,
    );

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(
        milliseconds: 300,
      ),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation =
        Tween<
              double
            >(
              begin: 0.0,
              end: 1.0,
            )
            .animate(
              CurvedAnimation(
                parent: _fadeController,
                curve: Curves.easeInOut,
              ),
            );

    // Start initial animations
    _fadeController.forward();

    // Load real stats for entries
    _loadEntriesStats();

    // Initialize video for current page
    _initializeVideoForIndex(
      _currentIndex,
    );
  }

  Future<
    void
  >
  _loadEntriesStats() async {
    print(
      'Loading stats for entries...',
    );
    // Load stats for the current entry and nearby entries
    for (
      int i = 0;
      i <
          widget.competitions.length;
      i++
    ) {
      if (i >=
              _currentIndex -
                  1 &&
          i <=
              _currentIndex +
                  1) {
        print(
          'Loading stats for entry $i',
        );
        await _reloadEntryStats(
          i,
        );
      }
    }
  }

  @override
  void
  dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    // Dispose all video controllers
    for (final controller in _videoControllers.values) {
      controller?.dispose();
    }
    super.dispose();
  }

  Future<
    void
  >
  _initializeVideoForIndex(
    int index,
  ) async {
    if (index <
            0 ||
        index >=
            widget.competitions.length) {
      return;
    }

    final competition = widget.competitions[index];
    final videoUrl = competition['videoUrl'];

    if (videoUrl ==
        null) {
      return;
    }

    // Dispose previous controller if exists
    if (_videoControllers[index] !=
        null) {
      await _videoControllers[index]!.pause();
      return;
    }

    try {
      final fullUrl = ApiService.getImageUrl(
        videoUrl,
      );
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(
          fullUrl,
        ),
      );

      await controller.initialize();
      controller.setLooping(
        true,
      );
      await controller.play();

      if (mounted) {
        setState(
          () {
            _videoControllers[index] = controller;
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error initializing video: $e',
      );
    }
  }

  void
  _pauseAllVideos() {
    for (final controller in _videoControllers.values) {
      controller?.pause();
    }
  }

  void
  _playVideoAtIndex(
    int index,
  ) {
    _pauseAllVideos();
    if (_videoControllers[index] !=
        null) {
      _videoControllers[index]!.play();
    } else {
      _initializeVideoForIndex(
        index,
      );
    }
  }

  Future<
    void
  >
  _voteForEntry(
    Map<
      String,
      dynamic
    >
    reel,
    int index,
  ) async {
    // Check if already voted - just return silently, the colored icon shows the state
    if (_votedReels[index] ==
        true) {
      return;
    }

    try {
      // Get the entry ID from the competition data
      final competition = widget.competitions[index];
      final entryId = competition['entryId'];

      if (entryId ==
          null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to vote: Entry ID not found',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await ApiService.voteSYTEntry(
        entryId,
      );

      if (response['success']) {
        print(
          'Vote successful! Setting _votedReels[$index] = true',
        );
        setState(
          () {
            _votedReels[index] = true;
            // Update vote count
            final currentVotes =
                int.tryParse(
                  widget.competitions[index]['likes'] ??
                      '0',
                ) ??
                0;
            widget.competitions[index]['likes'] =
                (currentVotes +
                        1)
                    .toString();
            print(
              'Updated vote count to: ${widget.competitions[index]['likes']}',
            );
            print(
              '_votedReels[$index] is now: ${_votedReels[index]}',
            );
          },
        );

        HapticFeedback.mediumImpact();

        // Don't reload stats immediately - the voted state is already set correctly
        // Stats will be reloaded on next page change or app restart
      } else {
        print(
          'Vote failed: ${response['message']}',
        );
        // Vote failed (already voted) - reload stats to get accurate state
        await _reloadEntryStats(
          index,
        );
      }
    } catch (
      e
    ) {
      // Silently handle errors - the UI state shows whether voting is available
      print(
        'Vote error: $e',
      );
    }
  }

  Future<
    void
  >
  _toggleBookmark(
    String entryId,
    int index,
  ) async {
    try {
      final response = await ApiService.toggleSYTBookmark(
        entryId,
      );
      if (response['success'] &&
          mounted) {
        setState(
          () {
            _savedReels[index] = response['data']['isBookmarked'];
          },
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
  _shareEntry(
    String entryId,
    int index,
  ) async {
    try {
      final response = await ApiService.sharePost(
        entryId,
      );
      if (response['success'] &&
          mounted) {
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
        await _reloadEntryStats(
          index,
        );
      }
    } catch (
      e
    ) {
      print(
        'Error sharing: $e',
      );
    }
  }

  Future<
    void
  >
  _reloadEntryStats(
    int index,
  ) async {
    try {
      final reel = widget.competitions[index];
      final entryId =
          reel['_id'] ??
          reel['entryId'];
      if (entryId !=
          null) {
        final statsResponse = await ApiService.getSYTEntryStats(
          entryId,
        );
        if (statsResponse['success'] &&
            mounted) {
          print(
            'Stats loaded for entry $index:',
          );
          print(
            '  hasVoted: ${statsResponse['data']['hasVoted']}',
          );
          print(
            '  likesCount: ${statsResponse['data']['likesCount']}',
          );
          print(
            '  hoursUntilNextVote: ${statsResponse['data']['hoursUntilNextVote']}',
          );

          setState(
            () {
              widget.competitions[index]['likes'] =
                  statsResponse['data']['likesCount']?.toString() ??
                  '0';
              widget.competitions[index]['comments'] =
                  statsResponse['data']['commentsCount']?.toString() ??
                  '0';
              _likedReels[index] =
                  statsResponse['data']['isLiked'] ??
                  false;
              _votedReels[index] =
                  statsResponse['data']['hasVoted'] ??
                  false;
              _savedReels[index] =
                  statsResponse['data']['isBookmarked'] ??
                  false;
              _hoursUntilNextVote[index] = statsResponse['data']['hoursUntilNextVote'];

              print(
                '  _votedReels[$index] set to: ${_votedReels[index]}',
              );
            },
          );
        }
      }
    } catch (
      e
    ) {
      print(
        'Error reloading stats: $e',
      );
    }
  }

  // Convert competition data to reel format
  Map<
    String,
    dynamic
  >
  _convertToReelData(
    Map<
      String,
      dynamic
    >
    competition,
  ) {
    // Use real data from backend, not calculated values
    return {
      'username':
          competition['username'] ??
          '@user',
      'description':
          competition['description'] ??
          (competition['title'] !=
                  null
              ? '${competition['title']} - ${competition['category']} 🎭'
              : 'Competing in ${competition['category']} - Show Your Talent! 🎭'),
      'likes':
          competition['likes'] ??
          competition['votesCount']?.toString() ??
          '0',
      'comments':
          competition['comments'] ??
          competition['commentsCount']?.toString() ??
          '0',
      'shares':
          competition['shares'] ??
          competition['sharesCount']?.toString() ??
          '0',
      'bookmarks':
          competition['bookmarks'] ??
          competition['bookmarksCount']?.toString() ??
          '0',
      'isAd': false,
      'duration': '00:30',
      'category':
          competition['category'] ??
          'Other',
      'gradient': competition['gradient'],
      'entryId':
          competition['entryId'] ??
          competition['_id'],
      'user': competition['user'],
      '_id':
          competition['_id'] ??
          competition['entryId'],
      'userId': competition['user']?['_id'],
    };
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        onPageChanged:
            (
              index,
            ) {
              setState(
                () {
                  _currentIndex = index;
                },
              );

              // Trigger animations on page change
              _fadeController.reset();
              _fadeController.forward();

              // Play video at current index
              _playVideoAtIndex(
                index,
              );

              // Load stats for nearby entries
              _reloadEntryStats(
                index,
              );
              if (index +
                      1 <
                  widget.competitions.length) {
                _reloadEntryStats(
                  index +
                      1,
                );
              }
            },
        itemCount: widget.competitions.length,
        itemBuilder:
            (
              context,
              index,
            ) {
              final competition = widget.competitions[index];
              final reelData = _convertToReelData(
                competition,
              );

              return AnimatedBuilder(
                animation: _pageController,
                builder:
                    (
                      context,
                      child,
                    ) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value =
                            _pageController.page! -
                            index;
                        value =
                            (1 -
                                    (value.abs() *
                                        0.3))
                                .clamp(
                                  0.0,
                                  1.0,
                                );
                      }

                      return Transform.scale(
                        scale: Curves.easeOut.transform(
                          value,
                        ),
                        child: Opacity(
                          opacity: value,
                          child: _buildReelItem(
                            reelData,
                            index,
                          ),
                        ),
                      );
                    },
              );
            },
      ),
    );
  }

  Widget
  _buildReelItem(
    Map<
      String,
      dynamic
    >
    reel,
    int index,
  ) {
    final videoController = _videoControllers[index];
    final hasVideo =
        videoController !=
            null &&
        videoController.value.isInitialized;

    return Stack(
      children: [
        // Video player or gradient background
        if (hasVideo)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: videoController.value.size.width,
                height: videoController.value.size.height,
                child: VideoPlayer(
                  videoController,
                ),
              ),
            ),
          )
        else
          // Animated background with competition gradient (fallback)
          AnimatedContainer(
            duration: const Duration(
              milliseconds: 500,
            ),
            curve: Curves.easeInOut,
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    reel['gradient']
                        as List<
                          Color
                        >,
              ),
            ),
            child: Center(
              child: const CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),

        // Tap to play/pause
        GestureDetector(
          onTap: () {
            if (hasVideo) {
              setState(
                () {
                  if (videoController.value.isPlaying) {
                    videoController.pause();
                  } else {
                    videoController.play();
                  }
                },
              );
            }
          },
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        // Play/Pause indicator
        if (hasVideo &&
            !videoController.value.isPlaying)
          Center(
            child: Container(
              padding: const EdgeInsets.all(
                20,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.5,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),

        // Top bar with SYT branding
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
              borderRadius: BorderRadius.circular(
                25,
              ),
              color: Colors.black.withValues(
                alpha: 0.7,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 20,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'SYT Competition',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Back button
        Positioned(
          top:
              MediaQuery.of(
                context,
              ).padding.top +
              20,
          left: 20,
          child: GestureDetector(
            onTap: () => Navigator.pop(
              context,
            ),
            child: Container(
              padding: const EdgeInsets.all(
                8,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.6,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),

        // Duration indicator (top left)
        Positioned(
          top:
              MediaQuery.of(
                context,
              ).padding.top +
              20,
          left: 70,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(
                alpha: 0.6,
              ),
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: Text(
              reel['duration'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Right side action buttons with vote button
        Positioned(
          right: 12,
          top:
              MediaQuery.of(
                context,
              ).size.height *
              0.35,
          child:
              TweenAnimationBuilder<
                Offset
              >(
                duration: const Duration(
                  milliseconds: 800,
                ),
                tween: Tween(
                  begin: const Offset(
                    1,
                    0,
                  ),
                  end: Offset.zero,
                ),
                curve: Curves.elasticOut,
                builder:
                    (
                      context,
                      offset,
                      child,
                    ) {
                      return Transform.translate(
                        offset:
                            offset *
                            100,
                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 400,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              30,
                            ),
                            color: Colors.black.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Like button (regular like functionality)
                              _buildActionButton(
                                'assets/sidereel/like.png',
                                reel['likes'],
                                _likedReels[index] ==
                                        true
                                    ? Colors.red
                                    : Colors.white,
                                onTap: () async {
                                  final entryId =
                                      reel['_id'] ??
                                      reel['entryId'];
                                  if (entryId !=
                                      null) {
                                    try {
                                      final response = await ApiService.toggleSYTLike(
                                        entryId,
                                      );
                                      if (response['success'] &&
                                          mounted) {
                                        setState(
                                          () {
                                            _likedReels[index] = response['data']['isLiked'];
                                            // Update the likes count in the reel data
                                            widget.competitions[index]['likes'] = response['data']['likesCount'].toString();
                                          },
                                        );
                                        HapticFeedback.lightImpact();
                                      }
                                    } catch (
                                      e
                                    ) {
                                      print(
                                        'Error toggling like: $e',
                                      );
                                    }
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              // Vote button (separate voting functionality)
                              _buildVoteButton(
                                reel,
                                index,
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              _buildActionButton(
                                'assets/sidereel/comment.png',
                                reel['comments'] ??
                                    '0',
                                Colors.white,
                                onTap: () async {
                                  final entryId =
                                      reel['_id'] ??
                                      reel['entryId'];
                                  if (entryId !=
                                      null) {
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder:
                                          (
                                            context,
                                          ) => CommentsScreen(
                                            postId: entryId,
                                          ),
                                    );
                                    // Reload entry stats after comments
                                    _reloadEntryStats(
                                      index,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              _buildActionButton(
                                'assets/sidereel/saved.png',
                                reel['bookmarks'] ??
                                    '0',
                                _savedReels[index] ==
                                        true
                                    ? Colors.yellow
                                    : Colors.white,
                                onTap: () async {
                                  final entryId =
                                      reel['_id'] ??
                                      reel['entryId'];
                                  if (entryId !=
                                      null) {
                                    await _toggleBookmark(
                                      entryId,
                                      index,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              _buildActionButton(
                                'assets/sidereel/share.png',
                                reel['shares'] ??
                                    '0',
                                Colors.white,
                                onTap: () async {
                                  final entryId =
                                      reel['_id'] ??
                                      reel['entryId'];
                                  if (entryId !=
                                      null) {
                                    await _shareEntry(
                                      entryId,
                                      index,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              GestureDetector(
                                onTap: () async {
                                  final userId =
                                      reel['user']?['_id'] ??
                                      reel['userId'];
                                  final username =
                                      reel['user']?['username'] ??
                                      reel['username'] ??
                                      'User';
                                  if (userId !=
                                      null) {
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder:
                                          (
                                            context,
                                          ) => GiftScreen(
                                            recipientId: userId,
                                            recipientName: username,
                                          ),
                                    );
                                  }
                                },
                                child: Image.asset(
                                  'assets/sidereel/gift.png',
                                  width: 28,
                                  height: 28,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
              ),
        ),

        // Bottom user info with SYT competition details
        Positioned(
          left: 16,
          right: 80,
          bottom: 120,
          child:
              TweenAnimationBuilder<
                Offset
              >(
                duration: const Duration(
                  milliseconds: 600,
                ),
                tween: Tween(
                  begin: const Offset(
                    0,
                    1,
                  ),
                  end: Offset.zero,
                ),
                curve: Curves.easeOutBack,
                builder:
                    (
                      context,
                      offset,
                      child,
                    ) {
                      return Transform.translate(
                        offset:
                            offset *
                            50,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User info row
                              Row(
                                children: [
                                  // Profile picture
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      gradient: LinearGradient(
                                        colors:
                                            reel['gradient']
                                                as List<
                                                  Color
                                                >,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
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
                                  Text(
                                    reel['username'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),

                                  // SYT Competition badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.amber,
                                          Colors.orange,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        15,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.emoji_events,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          'SYT',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              // Description with competition info
                              TweenAnimationBuilder<
                                double
                              >(
                                duration: const Duration(
                                  milliseconds: 1000,
                                ),
                                tween: Tween(
                                  begin: 0.0,
                                  end: 1.0,
                                ),
                                builder:
                                    (
                                      context,
                                      value,
                                      child,
                                    ) {
                                      final description =
                                          reel['description']
                                              as String;
                                      final runes = description.runes.toList();
                                      final displayLength =
                                          (runes.length *
                                                  value)
                                              .round();
                                      final safeText =
                                          displayLength >=
                                              runes.length
                                          ? description
                                          : String.fromCharCodes(
                                              runes.take(
                                                displayLength,
                                              ),
                                            );

                                      return Text(
                                        safeText,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          height: 1.3,
                                        ),
                                      );
                                    },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
              ),
        ),

        // Floating action button
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
      ],
    );
  }

  Widget
  _buildActionButton(
    String imagePath,
    String count,
    Color iconColor, {
    VoidCallback? onTap,
    bool isVote = false,
  }) {
    return TweenAnimationBuilder<
      double
    >(
      duration: const Duration(
        milliseconds: 400,
      ),
      tween: Tween(
        begin: 0.0,
        end: 1.0,
      ),
      builder:
          (
            context,
            value,
            child,
          ) {
            return Transform.scale(
              scale:
                  0.8 +
                  (0.2 *
                      value),
              child: GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  padding: const EdgeInsets.all(
                    8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<
                        double
                      >(
                        duration: const Duration(
                          milliseconds: 300,
                        ),
                        tween: Tween(
                          begin: 0.0,
                          end: 1.0,
                        ),
                        builder:
                            (
                              context,
                              iconValue,
                              child,
                            ) {
                              return Transform.rotate(
                                angle:
                                    (1 -
                                        iconValue) *
                                    0.2,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      imagePath,
                                      width: 28,
                                      height: 28,
                                      color: iconColor,
                                    ),
                                    if (isVote &&
                                        iconColor ==
                                            Colors.amber)
                                      const Icon(
                                        Icons.how_to_vote,
                                        size: 28,
                                        color: Colors.amber,
                                      ),
                                  ],
                                ),
                              );
                            },
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          count,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
    );
  }

  Widget
  _buildVoteButton(
    Map<
      String,
      dynamic
    >
    reel,
    int index,
  ) {
    final hasVoted =
        _votedReels[index] ==
        true;
    final voteCount =
        int.tryParse(
          reel['likes'].toString(),
        ) ??
        0;
    final displayVotes = hasVoted
        ? '${voteCount + 1}'
        : '$voteCount';

    return TweenAnimationBuilder<
      double
    >(
      duration: const Duration(
        milliseconds: 400,
      ),
      tween: Tween(
        begin: 0.0,
        end: 1.0,
      ),
      builder:
          (
            context,
            value,
            child,
          ) {
            return Transform.scale(
              scale:
                  0.8 +
                  (0.2 *
                      value),
              child: GestureDetector(
                onTap: () => _voteForEntry(
                  reel,
                  index,
                ),
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  padding: const EdgeInsets.all(
                    8,
                  ),
                  decoration: BoxDecoration(
                    color: hasVoted
                        ? Colors.amber.withValues(
                            alpha: 0.2,
                          )
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<
                        double
                      >(
                        duration: const Duration(
                          milliseconds: 300,
                        ),
                        tween: Tween(
                          begin: 0.0,
                          end: 1.0,
                        ),
                        builder:
                            (
                              context,
                              iconValue,
                              child,
                            ) {
                              return Transform.rotate(
                                angle:
                                    (1 -
                                        iconValue) *
                                    0.2,
                                child: Icon(
                                  hasVoted
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 32,
                                  color: hasVoted
                                      ? Colors.amber
                                      : Colors.white,
                                ),
                              );
                            },
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          displayVotes,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        'VOTE',
                        style: TextStyle(
                          color: hasVoted
                              ? Colors.amber
                              : Colors.white70,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
    );
  }
}
