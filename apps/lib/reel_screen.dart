import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:share_plus/share_plus.dart';
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
  ReelScreenState createState() => ReelScreenState();
}

// Make state public so MainScreen can access it
class ReelScreenState extends State<ReelScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin, RouteAware {
  final PageController _pageController = PageController();

  // Track if screen is currently visible
  bool _isScreenVisible = true;

  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  String? _currentUserId;
  final Map<String, bool> _followStatus = {};
  bool _isAdFree = false; // Track if user has ad-free subscription

  // Lazy loading variables
  int _currentPage = 1;
  bool _hasMorePosts = true;
  bool _isLoadingMore = false;
  static const int _postsPerPage =
      3; // Load only 3 posts at a time to reduce memory usage

  // Static cache for feed data (persists across widget rebuilds)
  static List<Map<String, dynamic>>? _cachedPosts;
  static bool _hasFetchedData = false;

  // Keep state alive when navigating away
  @override
  bool get wantKeepAlive => true;

  // Video controllers
  final Map<int, VideoPlayerController?> _videoControllers = {};
  final Map<int, bool> _videoInitialized = {};
  final Map<int, bool> _videoFullyLoaded = {}; // Track if video is 100% loaded
  final Map<int, DateTime> _lastPlayAttempt = {};

  // 🚀 OPTIMIZATION: Cache manager for reel videos (permanent cache for looping)
  // Increased to store more videos for smooth looping without network interruption
  static final _cacheManager = CacheManager(
    Config(
      'reelVideoCache',
      stalePeriod: const Duration(days: 7), // Keep cached for 7 days
      maxNrOfCacheObjects: 5, // Store up to 5 videos for looping
    ),
  );

  // Temporary cache manager for next reel preloading (longer expiry for looping)
  // This cache is for videos being preloaded ahead of time
  static final _tempCacheManager = CacheManager(
    Config(
      'reelTempCache',
      stalePeriod: const Duration(
        hours: 1,
      ), // Keep for 1 hour (longer for looping)
      maxNrOfCacheObjects: 3, // Store up to 3 videos for preloading
    ),
  );

  // Track which videos are being preloaded
  final Set<int> _preloadingVideos = {};
  final Map<int, DateTime> _cacheTimestamps = {};

  // 🚀 OPTIMIZATION: Track like button state to prevent rapid clicking
  final Map<String, DateTime> _lastLikeClick = {}; // postId -> last click time
  static const int _likeDebounceMs =
      500; // Prevent clicking more than once per 500ms

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
      _isScreenVisible = false;
      _pauseCurrentVideo();
    }
    // Resume video when app comes back to foreground
    else if (state == AppLifecycleState.resumed) {
      _isScreenVisible = true;
      // Reload feed if posts are empty (fixes black screen on app restart)
      if (_posts.isEmpty && !_isLoading) {
        print('App resumed with no posts, reloading feed...');
        _loadFeed();
      } else if (_videoInitialized[_currentIndex] == true) {
        _videoControllers[_currentIndex]?.play();
      }
    }
  }

  void _pauseCurrentVideo() {
    _videoControllers[_currentIndex]?.pause();
    print('⏸️ Video paused');
  }

  void _resumeCurrentVideo() {
    // Only resume if screen is visible
    if (_isScreenVisible && _videoInitialized[_currentIndex] == true) {
      _videoControllers[_currentIndex]?.play();
      print('▶️ Video resumed');
    }
  }

  // Public methods for MainScreen to control video playback
  void pauseVideo() {
    print('🔇🔇🔇 PAUSE VIDEO CALLED FROM MAIN SCREEN');
    _isScreenVisible = false;

    // Pause all videos and mute them
    _videoControllers.forEach((key, controller) {
      if (controller != null) {
        controller.pause();
        controller.setVolume(0.0); // Mute the video
        print('🔇 Paused and muted video $key');
      }
    });
  }

  void resumeVideo() {
    print('🔊🔊🔊 RESUME VIDEO CALLED FROM MAIN SCREEN');
    _isScreenVisible = true;

    // Unmute and resume current video
    final controller = _videoControllers[_currentIndex];
    if (controller != null && _videoInitialized[_currentIndex] == true) {
      controller.setVolume(1.0); // Unmute
      controller.play();
      print('🔊 Resumed and unmuted video $_currentIndex');
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

    // Check if we already have cached data
    if (_hasFetchedData && _cachedPosts != null && _cachedPosts!.isNotEmpty) {
      print('✅ Using cached feed data (${_cachedPosts!.length} posts)');
      setState(() {
        _posts = _cachedPosts!;
        _isLoading = false;
      });

      // Initialize first video only
      if (_posts.isNotEmpty) {
        _initializeVideoController(0);
        _trackView(_posts[0]['_id']);

        // Load stats only for first 3 posts (current + next 2)
        final postsToLoadStats = _posts.take(3).toList();
        _loadStatsInBackground(postsToLoadStats);

        // Check follow status only for first 3 posts
        for (final post in postsToLoadStats) {
          final userId = post['user']?['_id'] ?? post['user']?['id'];
          if (userId != null) {
            _checkFollowStatus(userId);
          }
        }
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 Lazy loading: Fetching first $_postsPerPage posts...');
      final response = await ApiService.getFeed(page: 1, limit: _postsPerPage);
      print('Feed response: ${response['success']}');

      if (!mounted) return;

      if (response['success']) {
        final posts = List<Map<String, dynamic>>.from(response['data']);
        print('✅ Loaded ${posts.length} posts (lazy loading)');

        // 🚀 OPTIMIZATION: Batch fetch pre-signed URLs for all videos
        await _batchFetchPresignedUrls(posts);

        // Cache the data
        _cachedPosts = posts;
        _hasFetchedData = true;
        _hasMorePosts = posts.length >= _postsPerPage;

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

          // Load stats only for first 3 posts (non-blocking)
          final postsToLoadStats = posts.take(3).toList();
          _loadStatsInBackground(postsToLoadStats);

          // Check follow status only for first 3 posts (non-blocking)
          for (final post in postsToLoadStats) {
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
            _hasMorePosts = false;
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

  // Load more posts when user scrolls near the end
  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMorePosts || !mounted) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      print('🔄 Loading more posts (page $_currentPage)...');

      final response = await ApiService.getFeed(
        page: _currentPage,
        limit: _postsPerPage,
      );

      if (!mounted) return;

      if (response['success']) {
        final newPosts = List<Map<String, dynamic>>.from(response['data']);
        print('✅ Loaded ${newPosts.length} more posts');

        if (newPosts.isNotEmpty) {
          setState(() {
            _posts.addAll(newPosts);
            _cachedPosts = _posts;
            _hasMorePosts = newPosts.length >= _postsPerPage;
            _isLoadingMore = false;
          });

          // Load stats for new posts (non-blocking)
          _loadStatsInBackground(newPosts);

          // Check follow status for new posts (non-blocking)
          for (final post in newPosts) {
            final userId = post['user']?['_id'] ?? post['user']?['id'];
            if (userId != null) {
              _checkFollowStatus(userId);
            }
          }
        } else {
          setState(() {
            _hasMorePosts = false;
            _isLoadingMore = false;
          });
        }
      } else {
        setState(() {
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Error loading more posts: $e');
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  // 🚀 Batch fetch pre-signed URLs for faster video loading
  Future<void> _batchFetchPresignedUrls(
    List<Map<String, dynamic>> posts,
  ) async {
    try {
      // Extract video URLs that need pre-signed URLs
      final videoUrls = posts
          .where(
            (post) =>
                post['mediaUrl'] != null &&
                post['mediaUrl'].toString().contains('wasabisys.com'),
          )
          .map((post) => post['mediaUrl'].toString())
          .toList();

      if (videoUrls.isEmpty) {
        print('No Wasabi videos to optimize');
        return;
      }

      print('🚀 Batch fetching ${videoUrls.length} pre-signed URLs...');
      final response = await ApiService.getPresignedUrlsBatch(videoUrls);

      if (response['success'] == true && response['data'] != null) {
        final presignedData = response['data'] as List;
        print('✅ Got ${presignedData.length} pre-signed URLs');

        // Update posts with pre-signed URLs
        for (final item in presignedData) {
          if (item['presignedUrl'] != null && item['originalUrl'] != null) {
            final originalUrl = item['originalUrl'];
            final presignedUrl = item['presignedUrl'];

            // Find and update the post
            for (final post in posts) {
              if (post['mediaUrl'] == originalUrl) {
                post['_presignedUrl'] = presignedUrl;
                break;
              }
            }
          }
        }
        print('✅ Updated posts with pre-signed URLs for instant loading');
      }
    } catch (e) {
      print('⚠️ Batch pre-signed URL fetch failed: $e');
      // Continue without pre-signed URLs
    }
  }

  // Load stats in background without blocking UI
  Future<void> _loadStatsInBackground(List<Map<String, dynamic>> posts) async {
    // 🚀 OPTIMIZATION: Skip posts that already have stats (from feed response)
    final postsNeedingStats = posts
        .where((post) => post['stats'] == null)
        .toList();

    if (postsNeedingStats.isEmpty) {
      print('✅ All posts already have stats (from feed response)');
      return;
    }

    print('📊 Loading stats for ${postsNeedingStats.length} posts...');

    // Load stats in parallel for better performance
    final futures = postsNeedingStats.map((post) async {
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

      // 🚀 OPTIMIZATION: Use pre-signed URL if already fetched (batch)
      if (_posts[index]['_presignedUrl'] != null) {
        videoUrl = _posts[index]['_presignedUrl'];
        print('✅ Using cached pre-signed URL for video $index');
      }
      // Fallback: Get pre-signed URL individually if not in batch
      else if (videoUrl.contains('wasabisys.com')) {
        print('🔄 Getting pre-signed URL for video $index...');
        try {
          final presignedResponse = await ApiService.getPresignedUrl(videoUrl);
          if (presignedResponse['success'] == true &&
              presignedResponse['data'] != null) {
            videoUrl = presignedResponse['data']['presignedUrl'];
            _posts[index]['_presignedUrl'] = videoUrl; // Cache it
            print('✅ Using pre-signed URL for video $index');
          }
        } catch (e) {
          print('⚠️ Pre-signed URL failed, using direct URL: $e');
        }
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
                mixWithOthers: true,
                allowBackgroundPlayback: false,
              ),
            );
          } else {
            // Not cached yet, use network and cache in background
            print('First reel not cached, loading from network');
            controller = VideoPlayerController.networkUrl(
              Uri.parse(videoUrl),
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: true,
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
              mixWithOthers: true,
              allowBackgroundPlayback: false,
            ),
          );
        }
      } else {
        // For other videos, check both caches (permanent first, then temp)
        try {
          // 🚀 OPTIMIZATION: Check permanent cache first for looping videos
          var fileInfo = await _cacheManager.getFileFromCache(videoUrl);

          if (fileInfo == null) {
            // Not in permanent cache, check temp cache (from preloading)
            fileInfo = await _tempCacheManager.getFileFromCache(videoUrl);
            if (fileInfo != null) {
              print('Video $index loaded from temp cache (preloaded)');
            }
          } else {
            print('Video $index loaded from permanent cache (looping)');
          }

          if (fileInfo != null) {
            // Use cached file
            controller = VideoPlayerController.file(
              fileInfo.file,
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: true,
                allowBackgroundPlayback: false,
              ),
            );
          } else {
            // Not in any cache, use network and cache for looping
            print('Video $index loading from network (will cache for looping)');
            controller = VideoPlayerController.networkUrl(
              Uri.parse(videoUrl),
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: true,
                allowBackgroundPlayback: false,
              ),
            );

            // 🚀 OPTIMIZATION: Cache to permanent cache for smooth looping
            _cacheManager
                .downloadFile(videoUrl)
                .then((_) {
                  print('Video $index cached to permanent cache for looping');
                })
                .catchError((e) {
                  print('Cache error for video $index: $e');
                });
          }
        } catch (e) {
          print('Cache check error for video $index: $e, using network');
          controller = VideoPlayerController.networkUrl(
            Uri.parse(videoUrl),
            videoPlayerOptions: VideoPlayerOptions(
              mixWithOthers: true,
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

            // INSTANT PLAY: Video is ready when buffered to just 10%
            // This gives near-instant playback from Wasabi
            if (bufferedEnd.inMilliseconds >= duration.inMilliseconds * 0.1) {
              if (_videoFullyLoaded[index] != true && mounted) {
                setState(() {
                  _videoFullyLoaded[index] = true;
                });
                print(
                  'Video $index ready to play (${(bufferedEnd.inMilliseconds / duration.inMilliseconds * 100).toStringAsFixed(0)}% buffered)',
                );

                // Auto-play from start if this is the current video
                if (index == _currentIndex && mounted) {
                  controller.setVolume(1.0);
                  controller.seekTo(Duration.zero);
                  controller.play();
                  print('🔊 Auto-playing video $index with volume 1.0');
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
          controller.setVolume(1.0);
          print('🔊 Auto-resuming video $index with volume 1.0');
          controller.play().catchError((e) {
            print('Auto-resume failed: $e');
          });
        }
      });

      await controller.initialize();
      controller.setLooping(true);
      controller.setPlaybackSpeed(1.0);

      // Set volume to ensure audio works
      controller.setVolume(1.0);
      print('🔊 Audio enabled for video $index (volume: 1.0)');

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

    // ULTRA FAST: Only wait 3 seconds max, start playing with minimal buffer
    final maxWaitTime = DateTime.now().add(const Duration(seconds: 3));

    while (DateTime.now().isBefore(maxWaitTime)) {
      final buffered = controller.value.buffered;

      if (buffered.isNotEmpty) {
        final lastBufferedRange = buffered.last;
        final bufferedEnd = lastBufferedRange.end;

        // INSTANT PLAY: Start playing when just 10% is buffered (ultra fast)
        // Video will continue buffering in background while playing
        // This gives near-instant playback for Wasabi videos
        if (bufferedEnd.inMilliseconds >= duration.inMilliseconds * 0.1) {
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
            controller.setVolume(1.0);
            await controller.seekTo(Duration.zero);
            await controller.play();
            print('🔊 Playing video $index with volume 1.0');
          }
          return;
        }
      }

      // Check every 50ms for faster response
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Timeout after 3 seconds - mark as ready and play anyway
    print('Video $index buffer timeout (3s), playing anyway');
    if (mounted) {
      setState(() {
        _videoFullyLoaded[index] = true;
      });

      // Play even if not fully buffered
      if (index == _currentIndex) {
        controller.setVolume(1.0);
        await controller.seekTo(Duration.zero);
        await controller.play();
        print('🔊 Playing video $index (timeout) with volume 1.0');
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

    // Lazy loading: Load more posts when approaching the end
    if (index >= _posts.length - 2 && _hasMorePosts && !_isLoadingMore) {
      print('📥 Approaching end, loading more posts...');
      _loadMorePosts();
    }

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
        // Ensure volume is set before playing
        controller.setVolume(1.0);
        print('🔊 Setting volume to 1.0 for video $index');

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

    // Smart preloading: Load only next video (reduced to save memory)
    if (index + 1 < _posts.length) {
      if (_videoInitialized[index + 1] != true) {
        _initializeVideoController(index + 1);
      }

      // Load stats for next post if not loaded
      _loadStatsForPost(index + 1);
    }

    // Load stats for previous post if exists
    if (index > 0) {
      _loadStatsForPost(index - 1);
    }

    // Aggressive cleanup - run on every page change to prevent OOM
    _cleanupOldCache(index);

    // Track view
    if (_posts.isNotEmpty && index < _posts.length) {
      _trackView(_posts[index]['_id']);
    }
  }

  // Load stats for a single post (lazy loading)
  Future<void> _loadStatsForPost(int index) async {
    if (index < 0 || index >= _posts.length) return;

    final post = _posts[index];

    // Skip if stats already loaded
    if (post['stats'] != null) return;

    try {
      final statsResponse = await ApiService.getPostStats(post['_id']);
      if (statsResponse['success'] && mounted) {
        setState(() {
          _posts[index]['stats'] = statsResponse['data'];
        });
      }
    } catch (e) {
      print('Error loading stats for post $index: $e');
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

  // Clean up cached videos that are more than 2 positions behind current (aggressive cleanup)
  // 🚀 OPTIMIZATION: Clean up cached videos intelligently (keep current for looping)
  void _cleanupOldCache(int currentIndex) {
    final keysToRemove = <int>[];

    // Dispose video controllers that are far from current position
    // But KEEP current video for smooth looping
    _videoControllers.forEach((index, controller) {
      // Keep current video (for looping), previous, and next 2 videos
      final shouldKeep = index >= currentIndex - 1 && index <= currentIndex + 2;

      if (!shouldKeep && controller != null) {
        print('🗑️ Disposing video controller $index (memory cleanup)');
        controller.dispose();
        _videoControllers[index] = null;
        _videoInitialized[index] = false;
        _videoFullyLoaded[index] = false;
      }
    });

    _cacheTimestamps.forEach((index, timestamp) {
      // Remove if more than 3 positions behind (more lenient for looping)
      final isFarBehind = index < currentIndex - 3;
      // Remove if older than 10 minutes (longer expiry for looping)
      final isExpired = DateTime.now().difference(timestamp).inMinutes > 10;

      if (isFarBehind || isExpired) {
        keysToRemove.add(index);
      }
    });

    for (final index in keysToRemove) {
      _cacheTimestamps.remove(index);
      print('🗑️ Cleaned up cache for video $index');
    }

    // 🚀 OPTIMIZATION: Don't clear temp cache too frequently (only every 10 videos)
    // This prevents interrupting looping videos
    if (currentIndex % 10 == 0) {
      _tempCacheManager
          .emptyCache()
          .then((_) {
            print('🗑️ Temp cache cleaned up (less frequently for looping)');
          })
          .catchError((e) {
            print('Error cleaning temp cache: $e');
          });
    }
  }

  Future<void> _trackView(String postId) async {
    try {
      // Track view - increment view count
      await ApiService.incrementView(postId);
    } catch (e) {
      print('Error tracking view: $e');
    }
  }

  Future<void> _toggleLike(String postId, int index) async {
    if (index < 0 || index >= _posts.length) return;

    // 🚀 OPTIMIZATION: Debounce - prevent rapid clicking
    final lastClick = _lastLikeClick[postId];
    if (lastClick != null &&
        DateTime.now().difference(lastClick).inMilliseconds < _likeDebounceMs) {
      print('⏱️ Like click ignored - debounced (${_likeDebounceMs}ms)');
      return;
    }
    _lastLikeClick[postId] = DateTime.now();

    try {
      // 🚀 OPTIMIZATION: Optimistic UI update - show like immediately
      final currentStats = _posts[index]['stats'] ?? {};
      final wasLiked = currentStats['isLiked'] ?? false;
      final currentLikesCount = currentStats['likesCount'] ?? 0;

      // Update UI immediately (optimistic update)
      setState(() {
        if (_posts[index]['stats'] == null) {
          _posts[index]['stats'] = {};
        }
        _posts[index]['stats']['isLiked'] = !wasLiked;
        _posts[index]['stats']['likesCount'] = wasLiked
            ? currentLikesCount - 1
            : currentLikesCount + 1;
      });

      print(
        '❤️ Like toggled optimistically: ${!wasLiked ? "liked" : "unliked"}',
      );

      // Send request to server in background (non-blocking, fire and forget)
      ApiService.toggleLike(postId)
          .then((response) {
            if (response['success'] && mounted) {
              // Server confirmed - reload stats to get accurate counts
              _reloadPostStats(postId, index).then((_) {
                print('✅ Like confirmed by server');
              });
            } else {
              // Server failed - revert UI
              if (mounted) {
                setState(() {
                  _posts[index]['stats']['isLiked'] = wasLiked;
                  _posts[index]['stats']['likesCount'] = currentLikesCount;
                });
                print('❌ Like reverted - server error');
              }
            }
          })
          .catchError((e) {
            print('❌ Like error: $e');
            // Revert on error
            if (index < _posts.length && mounted) {
              setState(() {
                _posts[index]['stats']['isLiked'] = wasLiked;
                _posts[index]['stats']['likesCount'] = currentLikesCount;
              });
            }
          });
    } catch (e) {
      print('Error toggling like: $e');
      // Revert on error
      if (index < _posts.length && mounted) {
        final currentStats = _posts[index]['stats'] ?? {};
        final wasLiked = currentStats['isLiked'] ?? false;
        setState(() {
          _posts[index]['stats']['isLiked'] = !wasLiked;
        });
      }
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
      final post = _posts[index];
      final username = post['user']?['username'] ?? 'user';
      final caption = post['caption'] ?? '';

      // Create deep link to specific reel
      final deepLink = 'https://showofflife.app/reel/$postId';

      // Create share text with deep link and Play Store link
      final shareText =
          '''
Check out this amazing reel by @$username on ShowOff.life! 🎬

${caption.isNotEmpty ? '$caption\n\n' : ''}🔗 Watch now: $deepLink

📱 Download the app:
https://play.google.com/store/apps/details?id=com.showofflife.app

#ShowOffLife #Reels #Viral
''';

      // Share using share_plus
      await Share.share(
        shareText,
        subject: 'Check out this reel on ShowOff.life',
      );

      // Track share on backend
      final response = await ApiService.sharePost(postId);
      if (response['success'] && mounted) {
        // Reload stats to get accurate counts
        await _reloadPostStats(postId, index);
      }
    } catch (e) {
      print('Error sharing post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    print('🗑️ Disposing ReelScreen - cleaning up all resources');

    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();

    // Dispose all video controllers
    _videoControllers.forEach((key, controller) {
      if (controller != null) {
        print('🗑️ Disposing video controller $key');
        controller.dispose();
      }
    });
    _videoControllers.clear();
    _videoInitialized.clear();
    _videoFullyLoaded.clear();
    _lastPlayAttempt.clear();
    _preloadingVideos.clear();
    _cacheTimestamps.clear();
    _interstitialAd?.dispose();

    // Clean up both caches on dispose
    _tempCacheManager.emptyCache().catchError((e) {
      print('Error cleaning temp cache on dispose: $e');
    });

    _cacheManager.emptyCache().catchError((e) {
      print('Error cleaning permanent cache on dispose: $e');
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return VisibilityDetector(
      key: const Key('reel-screen-visibility'),
      onVisibilityChanged: (info) {
        print(
          '👁️ Reel visibility changed: ${(info.visibleFraction * 100).toInt()}%',
        );

        // Update visibility state
        final wasVisible = _isScreenVisible;

        // Pause immediately if ANY visibility is lost
        if (info.visibleFraction < 1.0) {
          _isScreenVisible = false;
          print('🔇 Reel screen not fully visible - pausing video');
          _pauseCurrentVideo();
        }
        // Resume only when fully visible
        else if (info.visibleFraction == 1.0 && !wasVisible) {
          _isScreenVisible = true;
          print('🔊 Reel screen fully visible - resuming video');
          _resumeCurrentVideo();
        }
      },
      child: _buildScreenContent(),
    );
  }

  Widget _buildScreenContent() {
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
                                  // Pause video before navigating to prevent resource conflicts
                                  _pauseCurrentVideo();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchScreen(),
                                    ),
                                  ).then((_) {
                                    // Resume video when returning
                                    if (mounted && _isScreenVisible) {
                                      _resumeCurrentVideo();
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: Image.asset(
                                  'assets/upreel/coment.png',
                                  width: 24,
                                  height: 24,
                                ),
                                onPressed: () {
                                  // Pause video before navigating to prevent resource conflicts
                                  _pauseCurrentVideo();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MessagesScreen(),
                                    ),
                                  ).then((_) {
                                    // Resume video when returning
                                    if (mounted && _isScreenVisible) {
                                      _resumeCurrentVideo();
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: Image.asset(
                                  'assets/upreel/notbell.png',
                                  width: 24,
                                  height: 24,
                                ),
                                onPressed: () {
                                  // Pause video before navigating to prevent resource conflicts
                                  _pauseCurrentVideo();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NotificationScreen(),
                                    ),
                                  ).then((_) {
                                    // Resume video when returning
                                    if (mounted && _isScreenVisible) {
                                      _resumeCurrentVideo();
                                    }
                                  });
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
                bottom:
                    MediaQuery.of(context).size.height *
                    0.15, // Responsive: 15% from bottom
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
                  child: SingleChildScrollView(
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
                            // Pause video before showing modal to prevent resource conflicts
                            _pauseCurrentVideo();
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  CommentsScreen(postId: post['_id']),
                            );
                            // Reload stats after comments modal closes
                            await _reloadPostStats(post['_id'], index);
                            // Resume video after modal closes
                            if (mounted && _isScreenVisible) {
                              _resumeCurrentVideo();
                            }
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
                            // Pause video before showing modal to prevent resource conflicts
                            _pauseCurrentVideo();
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
                            // Resume video after modal closes
                            if (mounted && _isScreenVisible) {
                              _resumeCurrentVideo();
                            }
                          },
                        ),
                      ],
                    ),
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
                        // Pause video before navigating to prevent resource conflicts
                        _pauseCurrentVideo();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProfileScreen(userInfo: user),
                          ),
                        ).then((_) {
                          // Resume video when returning
                          if (mounted && _isScreenVisible) {
                            _resumeCurrentVideo();
                          }
                        });
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
