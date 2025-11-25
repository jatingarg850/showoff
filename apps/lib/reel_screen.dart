import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'comments_screen.dart';
import 'gift_screen.dart';
import 'user_profile_screen.dart';
import 'search_screen.dart';
import 'messages_screen.dart';
import 'notification_screen.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'services/ad_service.dart';
import 'config/api_config.dart';

class ReelScreen extends StatefulWidget {
  final String? initialPostId;

  const ReelScreen({super.key, this.initialPostId});

  @override
  State<ReelScreen> createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> with WidgetsBindingObserver {
  final PageController _pageController = PageController();

  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  String? _currentUserId;
  final Map<String, bool> _followStatus = {};
  bool _isAdFree = false; // Track if user has ad-free subscription

  // Video controllers
  final Map<int, VideoPlayerController?> _videoControllers = {};
  final Map<int, bool> _videoInitialized = {};
  final Map<int, bool> _videoFullyLoaded = {}; // Track if video is 100% loaded
  final Map<int, DateTime> _lastPlayAttempt = {};

  // Cache manager for first reel (permanent cache)
  static final _cacheManager = CacheManager(
    Config(
      'reelVideoCache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 5, // Cache up to 5 recent videos
    ),
  );

  // Temporary cache manager for next reel preloading (10 min expiry)
  static final _tempCacheManager = CacheManager(
    Config(
      'reelTempCache',
      stalePeriod: const Duration(minutes: 10), // Auto-delete after 10 minutes
      maxNrOfCacheObjects: 3, // Cache next 3 videos temporarily
    ),
  );

  // Track which videos are being preloaded
  final Set<int> _preloadingVideos = {};
  final Map<int, DateTime> _cacheTimestamps = {};

  // Ad related
  InterstitialAd? _interstitialAd;
  int _reelsSinceLastAd = 0;
  final int _adFrequency = 4; // Show ad every 4 reels
  bool _isLoadingAd = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentUser();
    _checkSubscriptionStatus();
    _loadFeed();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Pause video when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _videoControllers[_currentIndex]?.pause();
    }
    // Resume video when app comes back to foreground
    else if (state == AppLifecycleState.resumed) {
      // Reload feed if posts are empty (fixes black screen on app restart)
      if (_posts.isEmpty && !_isLoading) {
        print('App resumed with no posts, reloading feed...');
        _loadFeed();
      } else if (_videoInitialized[_currentIndex] == true) {
        _videoControllers[_currentIndex]?.play();
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await StorageService.getUser();
      if (user != null) {
        setState(() {
          _currentUserId = user['_id'] ?? user['id'];
        });
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final response = await ApiService.getMySubscription();

      // Check if response is successful and has data
      if (response['success'] == true && response['data'] != null) {
        try {
          // Safely convert nested maps
          final dataRaw = response['data'];
          if (dataRaw is! Map) {
            throw Exception('Invalid data format');
          }

          final data = Map<String, dynamic>.from(dataRaw);

          final planRaw = data['plan'];
          if (planRaw != null && planRaw is Map) {
            final plan = Map<String, dynamic>.from(planRaw);

            final featuresRaw = plan['features'];
            if (featuresRaw != null && featuresRaw is Map) {
              final features = Map<String, dynamic>.from(featuresRaw);

              setState(() {
                _isAdFree = features['adFree'] == true;
              });
              print('Subscription check: adFree = $_isAdFree');
            }
          }
        } catch (conversionError) {
          print('Error converting subscription data: $conversionError');
          setState(() {
            _isAdFree = false;
          });
        }
      } else {
        // No active subscription
        print('No active subscription found');
        setState(() {
          _isAdFree = false;
        });
      }
    } catch (e) {
      print('Error checking subscription: $e');
      // Default to showing ads if check fails
      setState(() {
        _isAdFree = false;
      });
    }

    // Only load ads if user is not ad-free
    if (!_isAdFree) {
      _loadInterstitialAd();
    } else {
      print('User has ad-free subscription, skipping ad load');
    }
  }

  Future<void> _loadFeed() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('Loading feed...');
      final response = await ApiService.getFeed(page: 1, limit: 20);
      print('Feed response: ${response['success']}');

      if (!mounted) return;

      if (response['success']) {
        final posts = List<Map<String, dynamic>>.from(response['data']);
        print('Loaded ${posts.length} posts');

        // Immediately show posts and initialize first video
        if (posts.isNotEmpty) {
          setState(() {
            _posts = posts;
            _isLoading = false;
          });

          // Find initial post index if provided
          int initialIndex = 0;
          if (widget.initialPostId != null) {
            final index = _posts.indexWhere(
              (post) => post['_id'] == widget.initialPostId,
            );
            if (index != -1) {
              initialIndex = index;
            }
          }

          // Initialize first video immediately
          if (initialIndex > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _pageController.jumpToPage(initialIndex);
            });
          }
          _initializeVideoController(initialIndex);
          _trackView(_posts[initialIndex]['_id']);

          // Load stats in parallel (non-blocking)
          _loadStatsInBackground(posts);

          // Check follow status for each post (non-blocking)
          for (final post in posts) {
            final userId = post['user']?['_id'] ?? post['user']?['id'];
            if (userId != null) {
              _checkFollowStatus(userId);
            }
          }
        } else {
          print('No posts found');
          setState(() {
            _posts = posts;
            _isLoading = false;
          });
        }
      } else {
        print('Feed API returned success: false');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Error loading feed: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Load stats in background without blocking UI
  Future<void> _loadStatsInBackground(List<Map<String, dynamic>> posts) async {
    // Load stats in parallel for better performance
    final futures = posts.map((post) async {
      try {
        final statsResponse = await ApiService.getPostStats(post['_id']);
        if (statsResponse['success'] && mounted) {
          // Update data without setState to avoid video stuttering
          final index = _posts.indexWhere((p) => p['_id'] == post['_id']);
          if (index != -1) {
            _posts[index]['stats'] = statsResponse['data'];

            // Only call setState for the currently visible post to update UI
            // This prevents multiple rebuilds that cause video stuttering
            if (index == _currentIndex && mounted) {
              setState(() {
                // Just trigger a rebuild for the current post
              });
            }
          }
        }
      } catch (e) {
        print('Error loading stats: $e');
      }
    }).toList();

    // Wait for all stats to load (but don't block the UI)
    await Future.wait(futures);
  }

  // Load interstitial ad
  Future<void> _loadInterstitialAd() async {
    if (_isLoadingAd) return;

    setState(() {
      _isLoadingAd = true;
    });

    try {
      _interstitialAd = await AdService.loadInterstitialAd();
      print('Interstitial ad loaded successfully');
    } catch (e) {
      print('Error loading interstitial ad: $e');
    } finally {
      setState(() {
        _isLoadingAd = false;
      });
    }
  }

  // Show ad if ready
  void _showAdIfReady() {
    if (_interstitialAd != null) {
      // Pause current video before showing ad
      _videoControllers[_currentIndex]?.pause();

      AdService.showInterstitialAd(
        _interstitialAd,
        onAdDismissed: () {
          // Reset counter and load next ad
          _reelsSinceLastAd = 0;
          _interstitialAd = null;
          _loadInterstitialAd();

          // Resume video after ad
          _videoControllers[_currentIndex]?.play();
        },
      );
    } else {
      // Ad not ready, try loading again
      _loadInterstitialAd();
    }
  }

  Future<void> _initializeVideoController(int index) async {
    if (_posts.isEmpty || index >= _posts.length) {
      return;
    }

    final mediaUrl = _posts[index]['mediaUrl'];
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return;
    }

    // Dispose existing controller
    _videoControllers[index]?.dispose();

    try {
      String videoUrl = mediaUrl;
      if (mediaUrl.startsWith('/uploads')) {
        videoUrl = '${ApiConfig.baseUrl}$mediaUrl';
      }

      VideoPlayerController controller;

      // Try to use cache for first reel (permanent cache)
      if (index == 0) {
        try {
          // Check if file is already cached
          final fileInfo = await _cacheManager.getFileFromCache(videoUrl);
          if (fileInfo != null) {
            print('First reel loaded from permanent cache (instant)');
            controller = VideoPlayerController.file(
              fileInfo.file,
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: false,
                allowBackgroundPlayback: false,
              ),
            );
          } else {
            // Not cached yet, use network and cache in background
            print('First reel not cached, loading from network');
            controller = VideoPlayerController.networkUrl(
              Uri.parse(videoUrl),
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: false,
                allowBackgroundPlayback: false,
              ),
            );
            // Cache in background (non-blocking)
            _cacheManager
                .downloadFile(videoUrl)
                .then((_) {
                  print('First reel cached for next time');
                })
                .catchError((e) {
                  print('Cache error: $e');
                });
          }
        } catch (e) {
          print('Cache check error: $e, using network');
          controller = VideoPlayerController.networkUrl(
            Uri.parse(videoUrl),
            videoPlayerOptions: VideoPlayerOptions(
              mixWithOthers: false,
              allowBackgroundPlayback: false,
            ),
          );
        }
      } else {
        // For other videos, check temp cache first (from preloading)
        try {
          final tempFileInfo = await _tempCacheManager.getFileFromCache(
            videoUrl,
          );
          if (tempFileInfo != null) {
            print('Video $index loaded from temp cache (preloaded)');
            controller = VideoPlayerController.file(
              tempFileInfo.file,
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: false,
                allowBackgroundPlayback: false,
              ),
            );
          } else {
            // Not in temp cache, use network
            print('Video $index loading from network');
            controller = VideoPlayerController.networkUrl(
              Uri.parse(videoUrl),
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: false,
                allowBackgroundPlayback: false,
              ),
            );
          }
        } catch (e) {
          print('Temp cache check error: $e, using network');
          controller = VideoPlayerController.networkUrl(
            Uri.parse(videoUrl),
            videoPlayerOptions: VideoPlayerOptions(
              mixWithOthers: false,
              allowBackgroundPlayback: false,
            ),
          );
        }
      }

      _videoControllers[index] = controller;

      // Add listener to monitor playback state and loading
      controller.addListener(() {
        if (!mounted) return;

        // Check if video has enough buffer to play smoothly
        if (controller.value.isInitialized) {
          final buffered = controller.value.buffered;
          final duration = controller.value.duration;

          if (buffered.isNotEmpty && duration.inMilliseconds > 0) {
            final lastBufferedRange = buffered.last;
            final bufferedEnd = lastBufferedRange.end;

            // Video is ready when buffered to 40% (enough for smooth playback)
            // This significantly reduces loading time while maintaining quality
            if (bufferedEnd.inMilliseconds >= duration.inMilliseconds * 0.4) {
              if (_videoFullyLoaded[index] != true && mounted) {
                setState(() {
                  _videoFullyLoaded[index] = true;
                });
                print(
                  'Video $index ready to play (${(bufferedEnd.inMilliseconds / duration.inMilliseconds * 100).toStringAsFixed(0)}% buffered)',
                );

                // Auto-play from start if this is the current video
                if (index == _currentIndex && mounted) {
                  controller.seekTo(Duration.zero);
                  controller.play();
                }
              }
            }
          }
        }

        // Auto-resume logic (only for current video and if ready)
        if (index != _currentIndex || _videoFullyLoaded[index] != true) return;

        final now = DateTime.now();
        final lastAttempt = _lastPlayAttempt[index];

        // Only try to resume if:
        // 1. Video is initialized
        // 2. Not currently playing
        // 3. Not buffering
        // 4. Not at the end
        // 5. At least 2 seconds since last play attempt (debounce)
        if (controller.value.isInitialized &&
            !controller.value.isPlaying &&
            !controller.value.isBuffering &&
            controller.value.position < controller.value.duration &&
            (lastAttempt == null ||
                now.difference(lastAttempt).inSeconds >= 2)) {
          _lastPlayAttempt[index] = DateTime.now();
          print('Auto-resuming video $index');
          controller.play().catchError((e) {
            print('Auto-resume failed: $e');
          });
        }
      });

      await controller.initialize();
      controller.setLooping(true);
      controller.setPlaybackSpeed(1.0);

      if (mounted) {
        setState(() {
          _videoInitialized[index] = true;
        });

        // Wait for video to be 100% loaded before showing/playing
        await _waitForFullLoad(controller, index);
      }
    } catch (e) {
      print('Error initializing video $index: $e');
      if (mounted) {
        setState(() {
          _videoInitialized[index] = false;
          _videoFullyLoaded[index] = false;
        });
      }
    }
  }

  // Wait for video to have enough buffer to play smoothly
  Future<void> _waitForFullLoad(
    VideoPlayerController controller,
    int index,
  ) async {
    if (!controller.value.isInitialized) return;

    final duration = controller.value.duration;
    if (duration.inMilliseconds == 0) return;

    print('Waiting for video $index to buffer...');

    // Reduced wait time to 10 seconds (much faster)
    final maxWaitTime = DateTime.now().add(const Duration(seconds: 10));

    while (DateTime.now().isBefore(maxWaitTime)) {
      final buffered = controller.value.buffered;

      if (buffered.isNotEmpty) {
        final lastBufferedRange = buffered.last;
        final bufferedEnd = lastBufferedRange.end;

        // Start playing when 40% is buffered (optimal balance of speed vs quality)
        // Video will continue buffering in background while playing
        if (bufferedEnd.inMilliseconds >= duration.inMilliseconds * 0.4) {
          if (mounted) {
            setState(() {
              _videoFullyLoaded[index] = true;
            });
          }
          print(
            'Video $index ready: ${(bufferedEnd.inMilliseconds / duration.inMilliseconds * 100).toStringAsFixed(0)}% buffered',
          );

          // Seek to start and play if this is the current video
          if (index == _currentIndex && mounted) {
            await controller.seekTo(Duration.zero);
            await controller.play();
          }
          return;
        }
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Timeout - mark as ready anyway to prevent infinite waiting
    print('Video $index buffer timeout, playing anyway');
    if (mounted) {
      setState(() {
        _videoFullyLoaded[index] = true;
      });

      // Play even if not fully buffered
      if (index == _currentIndex) {
        await controller.seekTo(Duration.zero);
        await controller.play();
      }
    }
  }

  // Get video duration as formatted string
  String _getVideoDuration(int index) {
    if (_videoInitialized[index] != true || _videoControllers[index] == null) {
      return '00:00';
    }

    final controller = _videoControllers[index]!;
    if (!controller.value.isInitialized) {
      return '00:00';
    }

    final duration = controller.value.duration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Check if we should show an ad (only if not ad-free)
    if (!_isAdFree) {
      _reelsSinceLastAd++;
      if (_reelsSinceLastAd >= _adFrequency) {
        _showAdIfReady();
      }
    }

    // Pause all other videos and reset to start
    _videoControllers.forEach((key, controller) {
      if (key != index && controller != null) {
        controller.pause();
        controller.seekTo(Duration.zero);
      }
    });

    // Play current video only if fully loaded
    if (_videoInitialized[index] == true && _videoFullyLoaded[index] == true) {
      final controller = _videoControllers[index];
      if (controller != null && controller.value.isInitialized) {
        // Always start from beginning
        controller.seekTo(Duration.zero).then((_) {
          if (mounted && _currentIndex == index) {
            _lastPlayAttempt[index] = DateTime.now();
            controller.play().catchError((error) {
              print('Error playing video: $error');
            });
          }
        });
      }
    } else if (_videoInitialized[index] != true) {
      // Initialize if not already initialized
      _initializeVideoController(index);
    }
    // If initialized but not fully loaded, wait for the listener to auto-play

    // Smart preloading: Load next video and cache it temporarily
    if (index + 1 < _posts.length) {
      if (_videoInitialized[index + 1] != true) {
        _initializeVideoController(index + 1);
      }
      // Preload and cache next video in background
      _preloadNextVideo(index + 1);
    }

    // Also preload the video after next for smoother experience
    if (index + 2 < _posts.length && _videoInitialized[index + 2] != true) {
      _preloadNextVideo(index + 2);
    }

    // Clean up old cached videos that are far behind
    _cleanupOldCache(index);

    // Track view
    if (_posts.isNotEmpty && index < _posts.length) {
      _trackView(_posts[index]['_id']);
    }
  }

  // Preload and cache next video in background
  Future<void> _preloadNextVideo(int index) async {
    if (index >= _posts.length || _preloadingVideos.contains(index)) {
      return; // Already preloading or out of bounds
    }

    final mediaUrl = _posts[index]['mediaUrl'];
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return;
    }

    _preloadingVideos.add(index);

    try {
      String videoUrl = mediaUrl;
      if (mediaUrl.startsWith('/uploads')) {
        videoUrl = '${ApiConfig.baseUrl}$mediaUrl';
      }

      print('Preloading video $index to temp cache: $videoUrl');

      // Download to temporary cache (non-blocking)
      _tempCacheManager
          .downloadFile(videoUrl)
          .then((fileInfo) {
            _cacheTimestamps[index] = DateTime.now();
            print('Video $index cached successfully (will expire in 10 min)');
          })
          .catchError((e) {
            print('Error preloading video $index: $e');
          })
          .whenComplete(() {
            _preloadingVideos.remove(index);
          });
    } catch (e) {
      print('Error starting preload for video $index: $e');
      _preloadingVideos.remove(index);
    }
  }

  // Clean up cached videos that are more than 5 positions behind current
  void _cleanupOldCache(int currentIndex) {
    final keysToRemove = <int>[];

    _cacheTimestamps.forEach((index, timestamp) {
      // Remove if more than 5 positions behind or older than 10 minutes
      final isFarBehind = index < currentIndex - 5;
      final isExpired = DateTime.now().difference(timestamp).inMinutes > 10;

      if (isFarBehind || isExpired) {
        keysToRemove.add(index);
      }
    });

    for (final index in keysToRemove) {
      _cacheTimestamps.remove(index);
      print('Cleaned up cache for video $index');
    }

    // Also clean up temp cache periodically
    if (currentIndex % 10 == 0) {
      _tempCacheManager
          .emptyCache()
          .then((_) {
            print('Temp cache cleaned up');
          })
          .catchError((e) {
            print('Error cleaning temp cache: $e');
          });
    }
  }

  Future<void> _trackView(String postId) async {
    try {
      // Track view - using existing method
      await ApiService.toggleLike(postId);
    } catch (e) {
      print('Error tracking view: $e');
    }
  }

  Future<void> _toggleLike(String postId, int index) async {
    try {
      final response = await ApiService.toggleLike(postId);
      if (response['success'] && mounted) {
        // Reload stats to get accurate counts
        await _reloadPostStats(postId, index);
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> _reloadPostStats(String postId, int index) async {
    try {
      final statsResponse = await ApiService.getPostStats(postId);
      if (statsResponse['success'] && mounted) {
        setState(() {
          if (_posts[index]['stats'] == null) {
            _posts[index]['stats'] = {};
          }
          _posts[index]['stats'] = statsResponse['data'];
          // Also update the post-level counts
          _posts[index]['likesCount'] = statsResponse['data']['likesCount'];
          _posts[index]['commentsCount'] =
              statsResponse['data']['commentsCount'];
          _posts[index]['sharesCount'] = statsResponse['data']['sharesCount'];
        });
      }
    } catch (e) {
      print('Error reloading stats: $e');
    }
  }

  Future<void> _toggleBookmark(String postId, int index) async {
    try {
      final response = await ApiService.toggleBookmark(postId);
      if (response['success'] && mounted) {
        // Reload stats to get accurate counts
        await _reloadPostStats(postId, index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['data']['isBookmarked']
                  ? 'Saved!'
                  : 'Removed from saved',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
    }
  }

  Future<void> _sharePost(String postId, int index) async {
    try {
      final response = await ApiService.sharePost(postId);
      if (response['success'] && mounted) {
        // Reload stats to get accurate counts
        await _reloadPostStats(postId, index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shared!'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error sharing post: $e');
    }
  }

  Future<void> _checkFollowStatus(String userId) async {
    if (_currentUserId == null || userId == _currentUserId) {
      return;
    }

    try {
      final response = await ApiService.checkFollowing(userId);
      if (response['success'] && mounted) {
        setState(() {
          _followStatus[userId] = response['isFollowing'] ?? false;
        });
      }
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> _toggleFollow(String userId) async {
    if (_currentUserId == null || userId == _currentUserId) {
      return;
    }

    try {
      final isCurrentlyFollowing = _followStatus[userId] ?? false;
      final response = isCurrentlyFollowing
          ? await ApiService.unfollowUser(userId)
          : await ApiService.followUser(userId);

      if (response['success'] && mounted) {
        setState(() {
          _followStatus[userId] = !isCurrentlyFollowing;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCurrentlyFollowing ? 'Unfollowed' : 'Following'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error toggling follow: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Follow feature not available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  bool _shouldShowFollowButton(Map<String, dynamic> user) {
    final userId = user['_id'] ?? user['id'];

    // Don't show if it's the current user's post
    if (_currentUserId != null && userId == _currentUserId) {
      return false;
    }

    // Don't show if already following
    if (_followStatus[userId] == true) {
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _videoControllers.forEach((key, controller) {
      controller?.dispose();
    });
    _videoControllers.clear();
    _videoInitialized.clear();
    _videoFullyLoaded.clear();
    _lastPlayAttempt.clear();
    _preloadingVideos.clear();
    _cacheTimestamps.clear();
    _interstitialAd?.dispose();

    // Clean up temp cache on dispose
    _tempCacheManager
        .emptyCache()
        .then((_) {
          print('Temp cache cleaned up on dispose');
        })
        .catchError((e) {
          print('Error cleaning temp cache on dispose: $e');
        });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
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
              const SizedBox(height: 20),
              const Text(
                'No Reels Yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Be the first to upload a reel!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _loadFeed,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF701CF5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
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
        itemBuilder: (context, index) {
          final post = _posts[index];
          final user = post['user'] != null
              ? Map<String, dynamic>.from(post['user'])
              : <String, dynamic>{};
          final stats = post['stats'] != null
              ? Map<String, dynamic>.from(post['stats'])
              : <String, dynamic>{};

          return Stack(
            children: [
              // Video Player
              _buildVideoPlayer(index),

              // Top Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getVideoDuration(index),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/reel/up.png'),
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.circular(30),
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
                                      builder: (context) => SearchScreen(),
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
                                      builder: (context) => MessagesScreen(),
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
                                      builder: (context) =>
                                          NotificationScreen(),
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
                      image: AssetImage('assets/reel/side.png'),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLikeButton(
                        stats['isLiked'] ?? false,
                        stats['likesCount']?.toString() ?? '0',
                        () => _toggleLike(post['_id'], index),
                      ),
                      const SizedBox(height: 24),
                      _buildActionButton(
                        'assets/sidereel/comment.png',
                        stats['commentsCount']?.toString() ?? '0',
                        () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) =>
                                CommentsScreen(postId: post['_id']),
                          );
                          // Reload stats after comments modal closes
                          await _reloadPostStats(post['_id'], index);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildBookmarkButton(
                        stats['isBookmarked'] ?? false,
                        stats['bookmarksCount']?.toString() ?? '0',
                        () => _toggleBookmark(post['_id'], index),
                      ),
                      const SizedBox(height: 24),
                      _buildActionButton(
                        'assets/sidereel/share.png',
                        stats['sharesCount']?.toString() ?? '0',
                        () => _sharePost(post['_id'], index),
                      ),
                      const SizedBox(height: 24),
                      _buildActionButton(
                        'assets/sidereel/gift.png',
                        '',
                        () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => GiftScreen(
                              recipientId: post['user']?['_id'] ?? '',
                              recipientName:
                                  post['user']?['username'] ?? 'user',
                            ),
                          );
                          // Reload stats after gift modal closes
                          await _reloadPostStats(post['_id'], index);
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
                            builder: (context) =>
                                UserProfileScreen(userInfo: user),
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
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: ClipOval(
                              child: user['profilePicture'] != null
                                  ? Image.network(
                                      ApiService.getImageUrl(
                                        user['profilePicture'],
                                      ),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                          const SizedBox(width: 12),
                          Text(
                            user['username'] ?? 'user',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (_shouldShowFollowButton(user))
                            GestureDetector(
                              onTap: () =>
                                  _toggleFollow(user['_id'] ?? user['id']),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF701CF5),
                                      Color(0xFF3E98E4),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
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
                    const SizedBox(height: 12),
                    Text(
                      post['caption'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
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

  Widget _buildVideoPlayer(int index) {
    final isFullyLoaded = _videoFullyLoaded[index] == true;
    final controller = _videoControllers[index];

    // Only show video when it's 100% loaded, otherwise show loading screen
    if (isFullyLoaded && controller != null && controller.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      );
    }

    // Loading screen (no buffering overlay, just clean loading)
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String imagePath,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imagePath, width: 28, height: 28),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 2),
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

  Widget _buildLikeButton(bool isLiked, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.white,
            size: 28,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 2),
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

  Widget _buildBookmarkButton(
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
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: isBookmarked ? Colors.yellow : Colors.white,
            size: 28,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 2),
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
