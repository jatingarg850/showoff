import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'comments_screen.dart';
import 'gift_screen.dart';
import 'content_creation_flow_screen.dart';
import 'user_profile_screen.dart';
import 'search_screen.dart';
import 'messages_screen.dart';
import 'notification_screen.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'services/ad_service.dart';
import 'services/background_music_service.dart';
import 'config/api_config.dart';

class ReelScreen extends StatefulWidget {
  final String? initialPostId;

  const ReelScreen({super.key, this.initialPostId});

  @override
  ReelScreenState createState() => ReelScreenState();
}

class ReelScreenState extends State<ReelScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  // Page controller for vertical scrolling like Instagram
  late PageController _pageController;

  // State tracking
  bool _isScreenVisible = true;
  bool _isDisposed = false;
  bool _isScrolling = false;

  // Posts data
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  String? _currentPostId; // Track current post by ID, not index
  String? _currentUserId;
  final Map<String, bool> _followStatus = {};
  bool _isAdFree = false;

  // Lazy loading
  int _currentPage = 1;
  bool _hasMorePosts = true;
  bool _isLoadingMore = false;
  static const int _postsPerPage = 5;

  // Static cache for feed data
  static List<Map<String, dynamic>>? _cachedPosts;
  static bool _hasFetchedData = false;

  @override
  bool get wantKeepAlive => true;

  // Video controllers - only keep 3 at a time (current, prev, next)
  final Map<int, VideoPlayerController?> _videoControllers = {};
  final Map<int, bool> _videoInitialized = {};
  final Map<int, bool> _videoReady = {};

  // Cache manager for videos
  static final _cacheManager = CacheManager(
    Config(
      'reelVideoCache',
      stalePeriod: const Duration(days: 3),
      maxNrOfCacheObjects: 10,
    ),
  );

  // Like debounce
  final Map<String, DateTime> _lastLikeClick = {};
  static const int _likeDebounceMs = 500;

  // Ads
  InterstitialAd? _interstitialAd;
  int _reelsSinceLastAd = 0;
  int _adFrequency =
      6; // Default: show ad after every 6 reels (configurable from admin)
  bool _adsEnabled = true; // Can be disabled from admin panel
  bool _isFirstPageChange =
      true; // Track first page change to avoid counting initial load

  // Background music - Instagram style
  final BackgroundMusicService _musicService = BackgroundMusicService();
  String? _currentMusicId;
  Timer? _musicLoadTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _loadCurrentUser();
    _checkSubscriptionStatus();
    _loadFeed();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _isScreenVisible = false;
      _stopAllMedia();
    } else if (state == AppLifecycleState.resumed) {
      _isScreenVisible = true;
      if (_posts.isEmpty && !_isLoading) {
        _loadFeed();
      } else {
        _resumeCurrentVideo();
      }
    }
  }

  void _stopAllMedia() {
    // Stop all videos
    _videoControllers.forEach((key, controller) {
      if (controller != null) {
        try {
          controller.pause();
          controller.setVolume(0.0);
        } catch (e) {
          debugPrint('Error stopping video $key: $e');
        }
      }
    });

    // Stop music
    _musicService.stopBackgroundMusic();
    _currentMusicId = null;
  }

  void _pauseCurrentVideo() {
    final controller = _videoControllers[_currentIndex];
    if (controller != null) {
      try {
        controller.pause();
        controller.setVolume(0.0);
      } catch (e) {
        debugPrint('Error pausing video: $e');
      }
    }
  }

  void _resumeCurrentVideo() {
    if (!_isScreenVisible || _isDisposed) return;

    final controller = _videoControllers[_currentIndex];
    if (controller != null && _videoReady[_currentIndex] == true) {
      try {
        controller.setVolume(1.0);
        controller.play();
      } catch (e) {
        debugPrint('Error resuming video: $e');
      }
    }

    // Resume music - reload if needed
    _musicService.resumeBackgroundMusic();

    // If music was stopped, reload it for current reel
    if (_musicService.getCurrentMusicId() == null &&
        _currentIndex < _posts.length) {
      _loadMusicForReel(_currentIndex);
    }
  }

  // Public methods for MainScreen
  void pauseVideo() {
    _isScreenVisible = false;
    _stopAllMedia();
  }

  void stopAllVideosCompletely() {
    _isScreenVisible = false;
    _isDisposed = true;
    _stopAllMedia();
  }

  void resumeVideo() {
    _isScreenVisible = true;
    _isDisposed = false;
    _resumeCurrentVideo();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await StorageService.getUser();
      if (user != null && mounted) {
        setState(() {
          _currentUserId = user['_id'] ?? user['id'];
        });
      }
    } catch (e) {
      debugPrint('Error loading current user: $e');
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final response = await ApiService.getMySubscription();
      if (response['success'] == true && response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data']);
        final plan = data['plan'];
        if (plan != null && plan is Map) {
          final features = plan['features'];
          if (features != null && features is Map) {
            setState(() {
              _isAdFree = features['adFree'] == true;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking subscription: $e');
    }

    // Load ad settings from admin panel
    try {
      await _loadAdSettings();
    } catch (e) {
      debugPrint('Error loading ad settings: $e');
    }

    if (!_isAdFree) {
      _loadInterstitialAd();
    }
  }

  /// Load ad settings from admin panel
  Future<void> _loadAdSettings() async {
    try {
      final response = await ApiService.getAdSettings();
      debugPrint('📡 Ad settings response: $response');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (data['ads'] != null) {
          final ads = data['ads'];
          setState(() {
            _adsEnabled = ads['enabled'] ?? true;
            _adFrequency = ads['adFrequency'] ?? 6;

            // Validate ad frequency
            if (_adFrequency < 1) _adFrequency = 1;
            if (_adFrequency > 50) _adFrequency = 50;

            debugPrint(
              '✅ Ad settings loaded: enabled=$_adsEnabled, frequency=$_adFrequency',
            );
          });
        } else {
          debugPrint('⚠️ No ads object in response data');
        }
      } else {
        debugPrint('⚠️ Ad settings response not successful or no data');
      }
    } catch (e) {
      debugPrint('❌ Error loading ad settings: $e');
      // Use defaults on error
      setState(() {
        _adsEnabled = true;
        _adFrequency = 6;
      });
    }
  }

  Future<void> _loadFeed() async {
    if (!mounted) return;

    // Use cached data if available
    if (_hasFetchedData && _cachedPosts != null && _cachedPosts!.isNotEmpty) {
      setState(() {
        _posts = _cachedPosts!;
        _isLoading = false;
      });
      _initializeForIndex(_getInitialIndex());
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getFeed(page: 1, limit: _postsPerPage);
      debugPrint('📺 Feed response: $response');

      if (!response['success'] || !mounted) {
        debugPrint(
          '❌ Feed API failed: ${response['message'] ?? 'Unknown error'}',
        );
        setState(() => _isLoading = false);
        return;
      }

      final posts = List<Map<String, dynamic>>.from(response['data']);
      debugPrint('📺 Loaded ${posts.length} posts');

      await _batchFetchPresignedUrls(posts);

      _cachedPosts = posts;
      _hasFetchedData = true;
      _hasMorePosts = posts.length >= _postsPerPage;

      if (posts.isNotEmpty && mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });

        final initialIndex = _getInitialIndex();
        _initializeForIndex(initialIndex);

        // Set current post ID
        if (initialIndex < _posts.length) {
          _currentPostId = _posts[initialIndex]['_id'];
        }

        // Jump to initial post if specified
        if (widget.initialPostId != null && initialIndex > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _pageController.jumpToPage(initialIndex);
          });
        }
      } else {
        setState(() {
          _posts = posts;
          _isLoading = false;
          _hasMorePosts = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading feed: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _getInitialIndex() {
    if (widget.initialPostId != null) {
      final index = _posts.indexWhere(
        (post) => post['_id'] == widget.initialPostId,
      );
      if (index != -1) {
        print(
          '✅ Found initial post at index: $index (ID: ${widget.initialPostId})',
        );
        return index;
      }
      print(
        '⚠️ Initial post not found in feed (ID: ${widget.initialPostId}), starting from 0',
      );
    }
    return 0;
  }

  /// Get the current index of a post by its ID
  /// Returns -1 if post not found
  int _getIndexByPostId(String postId) {
    return _posts.indexWhere((post) => post['_id'] == postId);
  }

  void _initializeForIndex(int index) {
    // Initialize current video
    _initializeVideoController(index);
    _trackView(_posts[index]['_id']);

    // Preload adjacent videos
    if (index + 1 < _posts.length) {
      _initializeVideoController(index + 1);
    }
    if (index > 0) {
      _initializeVideoController(index - 1);
    }

    // Load stats for visible posts
    _loadStatsForVisiblePosts(index);

    // Load music for current reel
    _loadMusicForReel(index);
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore || !_hasMorePosts || !mounted) return;

    setState(() => _isLoadingMore = true);

    try {
      _currentPage++;
      final response = await ApiService.getFeed(
        page: _currentPage,
        limit: _postsPerPage,
      );

      if (!mounted) return;

      if (response['success']) {
        final newPosts = List<Map<String, dynamic>>.from(response['data']);

        if (newPosts.isNotEmpty) {
          await _batchFetchPresignedUrls(newPosts);

          setState(() {
            _posts.addAll(newPosts);
            _cachedPosts = _posts;
            _hasMorePosts = newPosts.length >= _postsPerPage;
            _isLoadingMore = false;
          });
        } else {
          setState(() {
            _hasMorePosts = false;
            _isLoadingMore = false;
          });
        }
      } else {
        setState(() => _isLoadingMore = false);
      }
    } catch (e) {
      debugPrint('Error loading more posts: $e');
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _batchFetchPresignedUrls(
    List<Map<String, dynamic>> posts,
  ) async {
    try {
      final videoUrls = posts
          .where(
            (post) =>
                post['mediaUrl'] != null &&
                post['mediaUrl'].toString().contains('wasabisys.com'),
          )
          .map((post) => post['mediaUrl'].toString())
          .toList();

      if (videoUrls.isEmpty) return;

      final response = await ApiService.getPresignedUrlsBatch(videoUrls);

      if (response['success'] == true && response['data'] != null) {
        final presignedData = response['data'] as List;
        for (final item in presignedData) {
          if (item['presignedUrl'] != null && item['originalUrl'] != null) {
            for (final post in posts) {
              if (post['mediaUrl'] == item['originalUrl']) {
                post['_presignedUrl'] = item['presignedUrl'];
                break;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Batch pre-signed URL fetch failed: $e');
    }
  }

  Future<void> _loadStatsForVisiblePosts(int centerIndex) async {
    final indices = [
      centerIndex - 1,
      centerIndex,
      centerIndex + 1,
    ].where((i) => i >= 0 && i < _posts.length).toList();

    for (final index in indices) {
      final post = _posts[index];
      if (post['stats'] == null) {
        _loadStatsForPost(index);
      }

      final userId = post['user']?['_id'] ?? post['user']?['id'];
      if (userId != null) {
        _checkFollowStatus(userId);
      }
    }
  }

  Future<void> _loadStatsForPost(int index) async {
    if (index < 0 || index >= _posts.length) return;

    final post = _posts[index];
    if (post['stats'] != null) return;

    try {
      final statsResponse = await ApiService.getPostStats(post['_id']);
      if (statsResponse['success'] && mounted) {
        _posts[index]['stats'] = statsResponse['data'];
        if (index == _currentIndex) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error loading stats for post $index: $e');
    }
  }

  Future<void> _loadInterstitialAd() async {
    try {
      debugPrint('⏳ Loading interstitial ad...');
      _interstitialAd = await AdService.loadInterstitialAd();
      if (_interstitialAd != null) {
        debugPrint('✅ Interstitial ad loaded successfully');
      } else {
        debugPrint('⚠️ Interstitial ad returned null');
      }
    } catch (e) {
      debugPrint('❌ Error loading interstitial ad: $e');
    }
  }

  void _showAdIfReady() {
    debugPrint(
      '🎬 Ad check: _reelsSinceLastAd=$_reelsSinceLastAd, _adFrequency=$_adFrequency',
    );
    debugPrint(
      '   _adsEnabled=$_adsEnabled, _isAdFree=$_isAdFree, _interstitialAd=$_interstitialAd',
    );

    if (_interstitialAd != null) {
      debugPrint('✅ Showing interstitial ad');
      _pauseCurrentVideo();
      AdService.showInterstitialAd(
        _interstitialAd,
        onAdDismissed: () {
          debugPrint('✅ Ad dismissed, resetting counter');
          _reelsSinceLastAd = 0;
          _interstitialAd = null;
          _loadInterstitialAd();
          _resumeCurrentVideo();
        },
      );
    } else {
      debugPrint('⏳ Ad not ready yet, loading...');
      _loadInterstitialAd();
    }
  }

  // ============ VIDEO CONTROLLER MANAGEMENT ============

  /// Convert video URL to HLS format if needed
  /// Get video URL for playback
  /// Supports both HLS (.m3u8) and MP4 formats
  /// Server will return HLS URLs when available, otherwise MP4
  String _getVideoUrl(String videoUrl) {
    // If already HLS, return as-is
    if (videoUrl.endsWith('.m3u8')) {
      debugPrint('🎬 Using HLS URL: $videoUrl');
      return videoUrl;
    }

    // For MP4 files, return as-is
    if (videoUrl.endsWith('.mp4') || videoUrl.contains('wasabisys.com')) {
      debugPrint('🎬 Using MP4 URL: $videoUrl');
      return videoUrl;
    }

    // Default: return original URL
    debugPrint('🎬 Using video URL: $videoUrl');
    return videoUrl;
  }

  Future<void> _initializeVideoController(int index) async {
    if (_isDisposed || !mounted) return;
    if (_posts.isEmpty || index >= _posts.length || index < 0) return;
    if (_videoControllers[index] != null) return; // Already initialized

    final mediaUrl = _posts[index]['mediaUrl'];
    if (mediaUrl == null || mediaUrl.isEmpty) return;

    try {
      String videoUrl = mediaUrl;
      if (mediaUrl.startsWith('/uploads')) {
        videoUrl = '${ApiConfig.baseUrl}$mediaUrl';
      }

      // Use pre-signed URL if available
      if (_posts[index]['_presignedUrl'] != null) {
        videoUrl = _posts[index]['_presignedUrl'];
      } else if (videoUrl.contains('wasabisys.com')) {
        try {
          final presignedResponse = await ApiService.getPresignedUrl(videoUrl);
          if (presignedResponse['success'] == true &&
              presignedResponse['data'] != null) {
            videoUrl = presignedResponse['data']['presignedUrl'];
            _posts[index]['_presignedUrl'] = videoUrl;
          }
        } catch (e) {
          debugPrint('Pre-signed URL failed: $e');
        }
      }

      // Get video URL for playback (supports both HLS and MP4)
      videoUrl = _getVideoUrl(videoUrl);
      debugPrint('🎬 Video URL for video $index: $videoUrl');

      // Try to use cached file first
      VideoPlayerController controller;
      try {
        final fileInfo = await _cacheManager.getFileFromCache(videoUrl);
        if (fileInfo != null) {
          controller = VideoPlayerController.file(
            fileInfo.file,
            videoPlayerOptions: VideoPlayerOptions(
              mixWithOthers: true,
              allowBackgroundPlayback: false,
            ),
          );
        } else {
          controller = VideoPlayerController.networkUrl(
            Uri.parse(videoUrl),
            videoPlayerOptions: VideoPlayerOptions(
              mixWithOthers: true,
              allowBackgroundPlayback: false,
            ),
          );
          // Cache in background
          _cacheManager.downloadFile(videoUrl).then((_) {}).catchError((e) {
            debugPrint('Cache error: $e');
          });
        }
      } catch (e) {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        );
      }

      _videoControllers[index] = controller;

      // Add listener for buffering state
      controller.addListener(() {
        if (_isDisposed || !mounted) return;
        _onVideoStateChanged(controller, index);
      });

      await controller.initialize();

      if (_isDisposed || !mounted) {
        controller.dispose();
        return;
      }

      controller.setLooping(true);
      controller.setVolume(index == _currentIndex ? 1.0 : 0.0);

      if (mounted) {
        setState(() {
          _videoInitialized[index] = true;
        });
      }

      // Auto-play if this is the current video
      if (index == _currentIndex && _isScreenVisible && !_isScrolling) {
        _playVideo(index);
      }
    } catch (e) {
      debugPrint('Error initializing video $index: $e');
      if (mounted) {
        setState(() {
          _videoInitialized[index] = false;
          _videoReady[index] = false;
        });
      }
    }
  }

  void _onVideoStateChanged(VideoPlayerController controller, int index) {
    if (!controller.value.isInitialized) return;

    final buffered = controller.value.buffered;
    final duration = controller.value.duration;

    if (buffered.isNotEmpty && duration.inMilliseconds > 0) {
      final bufferedEnd = buffered.last.end;
      // Ready when 15% buffered
      if (bufferedEnd.inMilliseconds >= duration.inMilliseconds * 0.15) {
        if (_videoReady[index] != true && mounted) {
          setState(() {
            _videoReady[index] = true;
          });

          // Auto-play if current and not scrolling
          if (index == _currentIndex &&
              _isScreenVisible &&
              !_isScrolling &&
              !_isDisposed) {
            _playVideo(index);
          }
        }
      }
    }
  }

  void _playVideo(int index) {
    final controller = _videoControllers[index];
    if (controller == null || !controller.value.isInitialized) return;

    try {
      controller.setVolume(1.0);
      controller.seekTo(Duration.zero);
      controller.play();
    } catch (e) {
      debugPrint('Error playing video $index: $e');
    }
  }

  void _pauseVideo(int index) {
    final controller = _videoControllers[index];
    if (controller == null) return;

    try {
      controller.pause();
      controller.setVolume(0.0);
    } catch (e) {
      debugPrint('Error pausing video $index: $e');
    }
  }

  // Clean up controllers far from current position
  void _cleanupDistantControllers(int currentIndex) {
    final keysToRemove = <int>[];

    _videoControllers.forEach((index, controller) {
      // Keep current, previous, and next 2
      final shouldKeep = index >= currentIndex - 1 && index <= currentIndex + 2;

      if (!shouldKeep && controller != null) {
        try {
          controller.dispose();
        } catch (e) {
          debugPrint('Error disposing controller $index: $e');
        }
        keysToRemove.add(index);
      }
    });

    for (final key in keysToRemove) {
      _videoControllers.remove(key);
      _videoInitialized.remove(key);
      _videoReady.remove(key);
    }
  }

  // ============ MUSIC HANDLING - INSTAGRAM STYLE ============

  void _loadMusicForReel(int index) {
    // Cancel any pending music load
    _musicLoadTimer?.cancel();

    // Debounce music loading - wait 200ms after scroll settles
    _musicLoadTimer = Timer(const Duration(milliseconds: 200), () {
      if (!mounted || _isDisposed) return;
      _playBackgroundMusicForReel(index);
    });
  }

  Future<void> _playBackgroundMusicForReel(int index) async {
    if (index < 0 || index >= _posts.length) return;

    try {
      final post = _posts[index];

      // Get background music ID - check multiple possible locations
      String? backgroundMusicId;

      if (post['backgroundMusic'] != null) {
        backgroundMusicId =
            post['backgroundMusic']['_id']?.toString() ??
            post['backgroundMusic']['id']?.toString();
      }

      // Fallback to backgroundMusicId field
      if (backgroundMusicId == null || backgroundMusicId.isEmpty) {
        backgroundMusicId = post['backgroundMusicId']?.toString();
      }

      // No music for this reel
      if (backgroundMusicId == null || backgroundMusicId.isEmpty) {
        debugPrint('🎵 No background music for reel $index');
        if (_currentMusicId != null) {
          await _musicService.stopBackgroundMusic();
          _currentMusicId = null;
        }
        return;
      }

      debugPrint(
        '🎵 Found background music ID: $backgroundMusicId for reel $index',
      );

      // Same music already playing
      if (_currentMusicId == backgroundMusicId) {
        debugPrint('🎵 Same music already playing, skipping');
        return;
      }

      // Stop current music first
      if (_currentMusicId != null) {
        await _musicService.stopBackgroundMusic();
      }

      // Fetch and play new music
      debugPrint('🎵 Fetching music details for ID: $backgroundMusicId');
      final response = await ApiService.getMusic(backgroundMusicId);

      if (response['success'] && mounted && !_isDisposed) {
        final musicData = response['data'];
        final rawAudioUrl = musicData['audioUrl'];

        debugPrint('🎵 Music data received, audioUrl: $rawAudioUrl');

        if (rawAudioUrl != null && rawAudioUrl.toString().isNotEmpty) {
          final audioUrl = ApiService.getAudioUrl(rawAudioUrl);
          debugPrint('🎵 Playing music from: $audioUrl');
          await _musicService.playBackgroundMusic(audioUrl, backgroundMusicId);
          _currentMusicId = backgroundMusicId;
          debugPrint('🎵 Music started playing successfully');
        } else {
          debugPrint('🎵 Audio URL is empty or null');
        }
      } else {
        debugPrint('🎵 Failed to fetch music: ${response['message']}');
      }
    } catch (e) {
      debugPrint('🎵 Error loading background music: $e');
    }
  }

  void _stopMusicImmediately() {
    _musicLoadTimer?.cancel();
    _musicService.stopBackgroundMusic();
    _currentMusicId = null;
  }

  // ============ PAGE CHANGE HANDLING ============

  void _onPageChanged(int index) {
    final previousIndex = _currentIndex;

    setState(() {
      _currentIndex = index;
      _currentPostId = _posts[index]['_id']; // Track by ID
      _isScrolling = false;
    });

    // Stop music immediately when page changes
    _stopMusicImmediately();

    // Pause previous video
    _pauseVideo(previousIndex);

    // Play current video if ready
    if (_videoReady[index] == true) {
      _playVideo(index);
    } else if (_videoInitialized[index] != true) {
      _initializeVideoController(index);
    }

    // Preload adjacent videos
    if (index + 1 < _posts.length && _videoControllers[index + 1] == null) {
      _initializeVideoController(index + 1);
    }
    if (index > 0 && _videoControllers[index - 1] == null) {
      _initializeVideoController(index - 1);
    }

    // Load more posts when approaching end
    if (index >= _posts.length - 2 && _hasMorePosts && !_isLoadingMore) {
      _loadMorePosts();
    }

    // Show ad if needed (only if ads are enabled and user is not ad-free)
    if (!_isAdFree && _adsEnabled) {
      // Skip counting the first page change (initial load)
      if (!_isFirstPageChange) {
        _reelsSinceLastAd++;
        debugPrint(
          '📺 Reel $index viewed. Reels since ad: $_reelsSinceLastAd / $_adFrequency',
        );
        if (_reelsSinceLastAd >= _adFrequency) {
          debugPrint(
            '🎬 Time to show ad! ($_reelsSinceLastAd >= $_adFrequency)',
          );
          _showAdIfReady();
        }
      } else {
        debugPrint(
          '📺 Initial reel loaded (index $index), not counting for ad',
        );
        _isFirstPageChange = false;
      }
    } else {
      if (_isAdFree) {
        debugPrint('🎁 User is ad-free, skipping ad');
      } else {
        debugPrint('🔇 Ads disabled, skipping ad');
      }
    }

    // Clean up distant controllers
    _cleanupDistantControllers(index);

    // Track view
    _trackView(_posts[index]['_id']);

    // Load stats for visible posts
    _loadStatsForVisiblePosts(index);

    // Load music after scroll settles
    _loadMusicForReel(index);
  }

  void _onScrollStart() {
    _isScrolling = true;
    _stopMusicImmediately();
  }

  Future<void> _trackView(String postId) async {
    try {
      await ApiService.incrementView(postId);
    } catch (e) {
      debugPrint('Error tracking view: $e');
    }
  }

  // ============ USER INTERACTIONS ============

  Future<void> _toggleLike(String postId, int index) async {
    if (index < 0 || index >= _posts.length) return;

    // Debounce
    final lastClick = _lastLikeClick[postId];
    if (lastClick != null &&
        DateTime.now().difference(lastClick).inMilliseconds < _likeDebounceMs) {
      return;
    }
    _lastLikeClick[postId] = DateTime.now();

    try {
      final currentStats = _posts[index]['stats'] ?? {};
      final wasLiked = currentStats['isLiked'] ?? false;
      final currentLikesCount = currentStats['likesCount'] ?? 0;

      // Optimistic update
      setState(() {
        if (_posts[index]['stats'] == null) {
          _posts[index]['stats'] = {};
        }
        _posts[index]['stats']['isLiked'] = !wasLiked;
        _posts[index]['stats']['likesCount'] = wasLiked
            ? currentLikesCount - 1
            : currentLikesCount + 1;
      });

      // Send to server
      final response = await ApiService.toggleLike(postId);
      if (response['success'] && mounted) {
        _reloadPostStats(postId, index);
      } else if (mounted) {
        // Revert on failure
        setState(() {
          _posts[index]['stats']['isLiked'] = wasLiked;
          _posts[index]['stats']['likesCount'] = currentLikesCount;
        });
      }
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  Future<void> _reloadPostStats(String postId, int index) async {
    try {
      final statsResponse = await ApiService.getPostStats(postId);
      if (statsResponse['success'] && mounted) {
        setState(() {
          _posts[index]['stats'] = statsResponse['data'];
        });
      }
    } catch (e) {
      debugPrint('Error reloading stats: $e');
    }
  }

  Future<void> _toggleBookmark(String postId, int index) async {
    try {
      final response = await ApiService.toggleBookmark(postId);
      if (response['success'] && mounted) {
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
      debugPrint('Error toggling bookmark: $e');
    }
  }

  Future<void> _sharePost(String postId, int index) async {
    try {
      final post = _posts[index];
      final username = post['user']?['username'] ?? 'user';
      final caption = post['caption'] ?? '';

      final deepLink = 'https://showoff.life/reel/$postId';
      final shareText =
          '''
Check out this amazing reel by @$username on ShowOff.life! 🎬

${caption.isNotEmpty ? '$caption\n\n' : ''}🔗 Watch now: $deepLink

📱 Download the app:
https://play.google.com/store/apps/details?id=com.showofflife.app

#ShowOffLife #Reels #Viral
''';

      await Share.share(
        shareText,
        subject: 'Check out this reel on ShowOff.life',
      );

      final response = await ApiService.sharePost(postId);
      if (response['success'] && mounted) {
        await _reloadPostStats(postId, index);

        final coinsAwarded = response['coinsAwarded'] ?? 5;
        if (coinsAwarded > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    '+$coinsAwarded coins earned for sharing! 🎉',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF701CF5),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error sharing post: $e');
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
    if (_currentUserId == null || userId == _currentUserId) return;

    try {
      final response = await ApiService.checkFollowing(userId);
      if (response['success'] && mounted) {
        setState(() {
          _followStatus[userId] = response['isFollowing'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('Error checking follow status: $e');
    }
  }

  Future<void> _toggleFollow(String userId) async {
    if (_currentUserId == null || userId == _currentUserId) return;

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
      debugPrint('Error toggling follow: $e');
    }
  }

  bool _shouldShowFollowButton(Map<String, dynamic> user) {
    final userId = user['_id'] ?? user['id'];
    if (_currentUserId != null && userId == _currentUserId) return false;
    if (_followStatus[userId] == true) return false;
    return true;
  }

  // ============ DISPOSE ============

  @override
  void dispose() {
    _isDisposed = true;
    _musicLoadTimer?.cancel();

    // Stop all media
    _stopAllMedia();

    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();

    // Dispose all video controllers
    _videoControllers.forEach((key, controller) {
      try {
        controller?.dispose();
      } catch (e) {
        debugPrint('Error disposing video controller $key: $e');
      }
    });
    _videoControllers.clear();
    _videoInitialized.clear();
    _videoReady.clear();

    _interstitialAd?.dispose();

    super.dispose();
  }

  // ============ BUILD ============

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            _onScrollStart();
          }
          return false;
        },
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          physics: const ClampingScrollPhysics(),
          onPageChanged: _onPageChanged,
          itemCount: _posts.length,
          itemBuilder: (context, index) => _buildReelItem(index),
        ),
      ),
    );
  }

  Widget _buildReelItem(int index) {
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

        // Tap to pause/play
        GestureDetector(
          onTap: () {
            final controller = _videoControllers[index];
            if (controller != null && controller.value.isInitialized) {
              if (controller.value.isPlaying) {
                controller.pause();
              } else {
                controller.play();
              }
            }
          },
          child: Container(color: Colors.transparent),
        ),

        // Top Bar
        _buildTopBar(),

        // Right Side Actions
        _buildRightActions(post, stats, index),

        // Bottom User Info
        _buildBottomInfo(post, user, index),

        // Loading more indicator
        if (_isLoadingMore && index == _posts.length - 1)
          const Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoPlayer(int index) {
    final isReady = _videoReady[index] == true;
    final controller = _videoControllers[index];
    final post = _posts[index];
    final thumbnailUrl = post['thumbnailUrl'] != null
        ? ApiService.getImageUrl(post['thumbnailUrl'])
        : null;

    if (isReady && controller != null && controller.value.isInitialized) {
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

    // Loading state - show thumbnail only (HLS handles buffering internally)
    return SizedBox.expand(
      child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
          ? Image.network(
              thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.black);
              },
            )
          : Container(color: Colors.black),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
                        _pauseCurrentVideo();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchScreen(),
                          ),
                        ).then((_) {
                          if (mounted && _isScreenVisible)
                            _resumeCurrentVideo();
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
                        _pauseCurrentVideo();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessagesScreen(),
                          ),
                        ).then((_) {
                          if (mounted && _isScreenVisible)
                            _resumeCurrentVideo();
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
                        _pauseCurrentVideo();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationScreen(),
                          ),
                        ).then((_) {
                          if (mounted && _isScreenVisible)
                            _resumeCurrentVideo();
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
    );
  }

  Widget _buildRightActions(
    Map<String, dynamic> post,
    Map<String, dynamic> stats,
    int index,
  ) {
    return Positioned(
      right: 8,
      bottom: MediaQuery.of(context).size.height * 0.15,
      child: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/reel/side.png'),
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.circular(35),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Music button - show BGM name or "Unknown"
            _buildMusicButton(
              _getMusicName(post),
              () => _showMusicDetails(post),
            ),
            const SizedBox(height: 24),

            // Like button
            _buildLikeButton(
              stats['isLiked'] ?? false,
              stats['likesCount']?.toString() ?? '0',
              () => _toggleLike(post['_id'], index),
            ),
            const SizedBox(height: 24),

            // Comment button
            _buildActionButton(
              'assets/sidereel/comment.png',
              stats['commentsCount']?.toString() ?? '0',
              () async {
                _pauseCurrentVideo();
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CommentsScreen(postId: post['_id']),
                );
                await _reloadPostStats(post['_id'], index);
                if (mounted && _isScreenVisible) _resumeCurrentVideo();
              },
            ),
            const SizedBox(height: 24),

            // Bookmark button
            _buildBookmarkButton(
              stats['isBookmarked'] ?? false,
              stats['bookmarksCount']?.toString() ?? '0',
              () => _toggleBookmark(post['_id'], index),
            ),
            const SizedBox(height: 24),

            // Share button
            _buildActionButton(
              'assets/sidereel/share.png',
              stats['sharesCount']?.toString() ?? '0',
              () => _sharePost(post['_id'], index),
            ),
            const SizedBox(height: 24),

            // Gift button
            _buildActionButton('assets/sidereel/gift.png', '', () async {
              _pauseCurrentVideo();
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => GiftScreen(
                  recipientId: post['user']?['_id'] ?? '',
                  recipientName: post['user']?['username'] ?? 'user',
                ),
              );
              await _reloadPostStats(post['_id'], index);
              if (mounted && _isScreenVisible) _resumeCurrentVideo();
            }),
            const SizedBox(height: 24),

            // Show off button - navigate to unified content creation flow
            GestureDetector(
              onTap: () {
                // Pause current video and music before navigating
                _pauseCurrentVideo();

                // Navigate to unified content creation flow for Reels
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ContentCreationFlowScreen(selectedPath: 'reels'),
                  ),
                ).then((_) {
                  // Resume video and music when returning
                  if (mounted && _isScreenVisible) {
                    _resumeCurrentVideo();
                  }
                });
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Show',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'off',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get music name from post - checks backgroundMusic first, then music field
  String _getMusicName(Map<String, dynamic> post) {
    // Check backgroundMusic first (this is the actual BGM used in the reel)
    final bgMusic = post['backgroundMusic'];
    if (bgMusic != null) {
      final name = bgMusic['name'] ?? bgMusic['title'];
      if (name != null && name.toString().isNotEmpty) {
        return name.toString();
      }
    }

    // Check legacy music field
    final music = post['music'];
    if (music != null) {
      final name = music['name'] ?? music['title'];
      if (name != null && name.toString().isNotEmpty) {
        return name.toString();
      }
    }

    // No music found
    return 'Unknown';
  }

  void _showMusicDetails(Map<String, dynamic> post) {
    // Check backgroundMusic first, then fall back to music field
    final musicData = post['backgroundMusic'] ?? post['music'];

    if (musicData == null) {
      // Show "Unknown" music dialog
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_off, color: Colors.white54, size: 40),
              SizedBox(height: 16),
              Text(
                'Unknown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'No background music info available',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.music_note, color: Colors.white, size: 40),
            const SizedBox(height: 16),
            Text(
              musicData['name'] ?? musicData['title'] ?? 'Unknown',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (musicData['artist'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'by ${musicData['artist']}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfo(
    Map<String, dynamic> post,
    Map<String, dynamic> user,
    int index,
  ) {
    return Positioned(
      left: 16,
      right: 80,
      bottom: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              _pauseCurrentVideo();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(userInfo: user),
                ),
              ).then((_) {
                if (mounted && _isScreenVisible) _resumeCurrentVideo();
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
                            ApiService.getImageUrl(user['profilePicture']),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, color: Colors.white),
                          )
                        : const Icon(Icons.person, color: Colors.white),
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
                    onTap: () => _toggleFollow(user['_id'] ?? user['id']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF701CF5), Color(0xFF3E98E4)],
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
    );
  }

  // ============ UI HELPER WIDGETS ============

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

  Widget _buildMusicButton(String musicName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.music_note, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          SizedBox(
            width: 50,
            child: Text(
              musicName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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
