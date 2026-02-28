import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'comments_screen.dart';
import 'gift_screen.dart';
import 'services/api_service.dart';
import 'services/background_music_service.dart';
import 'config/api_config.dart';

class SYTReelScreen extends StatefulWidget {
  final List<Map<String, dynamic>> competitions;
  final int initialIndex;

  const SYTReelScreen({
    super.key,
    required this.competitions,
    this.initialIndex = 0,
  });

  @override
  State<SYTReelScreen> createState() => _SYTReelScreenState();
}

class _SYTReelScreenState extends State<SYTReelScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late PageController _pageController;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _currentIndex = 0;
  bool _isDisposed = false; // Track if screen is being disposed
  bool _isScreenVisible = true; // Track if screen is visible

  // Track liked, voted and saved states for each reel
  final Map<int, bool> _likedReels = {};
  final Map<int, bool> _votedReels = {};
  final Map<int, bool> _savedReels = {};
  final Map<int, int?> _hoursUntilNextVote = {};

  // Video controllers for each reel
  final Map<int, VideoPlayerController?> _videoControllers = {};
  final Map<int, bool> _videoInitialized = {};
  final Map<int, bool> _videoReady = {};

  // Cache manager for videos
  static final _cacheManager = CacheManager(
    Config(
      'sytReelVideoCache',
      stalePeriod: const Duration(days: 3),
      maxNrOfCacheObjects: 10,
    ),
  );

  // Background music tracking
  String? _currentMusicId;
  final BackgroundMusicService _musicService = BackgroundMusicService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _currentIndex = widget.initialIndex;

    // Initialize PageController with initial page
    _pageController = PageController(initialPage: widget.initialIndex);

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start initial animations
    _fadeController.forward();

    // Load real stats for entries
    _loadEntriesStats();

    // Initialize video for current page
    _initializeVideoForIndex(_currentIndex);
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
      if (widget.competitions.isNotEmpty && !_isDisposed && mounted) {
        _resumeCurrentVideo();
      }
    }
  }

  void _stopAllMedia() {
    // Stop all videos
    _pauseAllVideos();

    // Stop music
    _musicService.stopBackgroundMusic();
    _currentMusicId = null;
  }

  void _resumeCurrentVideo() {
    if (!_isScreenVisible || _isDisposed) return;

    final controller = _videoControllers[_currentIndex];
    if (controller != null && _videoReady[_currentIndex] == true) {
      try {
        controller.setVolume(1.0);
        controller.play();
      } catch (e) {
        print('Error resuming SYT video: $e');
      }
    }

    // Resume music - reload if needed
    _musicService.resumeBackgroundMusic();

    // If music was stopped, reload it for current reel
    if (_musicService.getCurrentMusicId() == null &&
        _currentIndex < widget.competitions.length) {
      _playBackgroundMusicForSYTReel(_currentIndex);
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

  Future<void> _loadEntriesStats() async {
    print('Loading stats for entries...');
    // Load stats for the current entry and nearby entries
    for (int i = 0; i < widget.competitions.length; i++) {
      if (i >= _currentIndex - 1 && i <= _currentIndex + 1) {
        print('Loading stats for entry $i');
        await _reloadEntryStats(i);
      }
    }
  }

  @override
  void dispose() {
    print('🗑️ Disposing SYTReelScreen - stopping all videos and music');
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);

    // Stop background music
    try {
      _musicService.stopBackgroundMusic();
      print('🎵 Background music stopped on dispose');
    } catch (e) {
      print('Error stopping background music: $e');
    }

    // CRITICAL: Stop all videos immediately before disposal
    for (final controller in _videoControllers.values) {
      if (controller != null) {
        try {
          controller.pause();
          controller.setVolume(0.0);
          print('🔇 Stopped SYT video before disposal');
        } catch (e) {
          print('Error stopping SYT video: $e');
        }
      }
    }

    _fadeController.dispose();
    _pageController.dispose();

    // Dispose all video controllers
    for (final controller in _videoControllers.values) {
      try {
        controller?.dispose();
      } catch (e) {
        print('Error disposing SYT video controller: $e');
      }
    }
    super.dispose();
  }

  /// Get video URL for playback
  /// Supports both HLS (.m3u8) and MP4 formats
  /// Server will return HLS URLs when available, otherwise MP4
  String _getVideoUrl(String videoUrl) {
    // If already HLS, return as-is
    if (videoUrl.endsWith('.m3u8')) {
      print('🎬 Using HLS URL: $videoUrl');
      return videoUrl;
    }

    // For MP4 files, return as-is
    if (videoUrl.endsWith('.mp4') || videoUrl.contains('wasabisys.com')) {
      print('🎬 Using MP4 URL: $videoUrl');
      return videoUrl;
    }

    // Default: return original URL
    print('🎬 Using video URL: $videoUrl');
    return videoUrl;
  }

  /// Handle video state changes for buffering detection
  void _onVideoStateChanged(VideoPlayerController controller, int index) {
    if (!controller.value.isInitialized) return;

    final buffered = controller.value.buffered;
    final duration = controller.value.duration;

    if (buffered.isNotEmpty && duration.inMilliseconds > 0) {
      final bufferedEnd = buffered.last.end;
      // Ready when 5% buffered (faster playback start for HLS)
      if (bufferedEnd.inMilliseconds >= duration.inMilliseconds * 0.05) {
        if (_videoReady[index] != true && mounted) {
          setState(() {
            _videoReady[index] = true;
          });

          // Auto-play if current and not scrolling
          if (index == _currentIndex && !_isDisposed) {
            _playVideoAtIndex(index);
          }
        }
      }
    }
  }

  Future<void> _initializeVideoForIndex(int index) async {
    // CRITICAL: Check if screen is disposed before starting initialization
    if (_isDisposed || !mounted) {
      print(
        '⚠️ SYT screen disposed, skipping video initialization for index $index',
      );
      return;
    }

    if (index < 0 || index >= widget.competitions.length) {
      return;
    }

    // Already initialized
    if (_videoControllers[index] != null) {
      return;
    }

    final competition = widget.competitions[index];
    final videoUrl = competition['videoUrl'];

    if (videoUrl == null || videoUrl.isEmpty) {
      return;
    }

    try {
      String fullUrl = videoUrl;

      // Convert relative URLs to full URLs
      if (videoUrl.startsWith('/uploads')) {
        fullUrl = '${ApiConfig.baseUrl}$videoUrl';
      } else if (!videoUrl.startsWith('http')) {
        fullUrl = ApiService.getImageUrl(videoUrl);
      }

      // Use pre-signed URL if available for Wasabi storage
      if (competition['_presignedUrl'] != null) {
        fullUrl = competition['_presignedUrl'];
      } else if (fullUrl.contains('wasabisys.com')) {
        try {
          final presignedResponse = await ApiService.getPresignedUrl(fullUrl);
          if (presignedResponse['success'] == true &&
              presignedResponse['data'] != null) {
            fullUrl = presignedResponse['data']['presignedUrl'];
            widget.competitions[index]['_presignedUrl'] = fullUrl;
          }
        } catch (e) {
          print('Pre-signed URL failed: $e');
        }
      }

      // Get video URL for playback (supports both HLS and MP4)
      fullUrl = _getVideoUrl(fullUrl);
      print('🎬 Video URL for SYT video $index: $fullUrl');

      // Try to use cached file first
      VideoPlayerController controller;
      try {
        final fileInfo = await _cacheManager.getFileFromCache(fullUrl);
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
            Uri.parse(fullUrl),
            videoPlayerOptions: VideoPlayerOptions(
              mixWithOthers: true,
              allowBackgroundPlayback: false,
            ),
          );
          // Cache in background
          _cacheManager.downloadFile(fullUrl).then((_) {}).catchError((e) {
            print('Cache error: $e');
          });
        }
      } catch (e) {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(fullUrl),
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

      // CRITICAL: Check if screen is disposed after initialization
      if (_isDisposed || !mounted) {
        print(
          '⚠️ SYT screen disposed after initialization, stopping video $index',
        );
        controller.pause();
        controller.setVolume(0.0);
        return;
      }

      controller.setLooping(true);
      controller.setVolume(index == _currentIndex ? 1.0 : 0.0);

      if (mounted) {
        setState(() {
          _videoInitialized[index] = true;
        });
      }

      // Auto-play if this is the current video and ready
      if (index == _currentIndex && _videoReady[index] == true) {
        _playVideoAtIndex(index);
      }
    } catch (e) {
      print('Error initializing SYT video $index: $e');
      if (mounted) {
        setState(() {
          _videoInitialized[index] = false;
          _videoReady[index] = false;
        });
      }
    }
  }

  void _pauseAllVideos() {
    for (final controller in _videoControllers.values) {
      if (controller != null) {
        try {
          controller.pause();
          controller.setVolume(0.0);
        } catch (e) {
          print('Error pausing video: $e');
        }
      }
    }
  }

  // Clean up controllers far from current position
  void _cleanupDistantControllers(int currentIndex) {
    final keysToRemove = <int>[];

    _videoControllers.forEach((index, controller) {
      // Keep current, previous, and next 3 (for faster preloading)
      final shouldKeep = index >= currentIndex - 1 && index <= currentIndex + 3;

      if (!shouldKeep && controller != null) {
        try {
          controller.dispose();
        } catch (e) {
          print('Error disposing controller $index: $e');
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

  void _playVideoAtIndex(int index) {
    // CRITICAL: Check if screen is disposed before playing
    if (_isDisposed || !mounted) {
      print('⚠️ SYT screen disposed, skipping video play for index $index');
      return;
    }

    _pauseAllVideos();
    if (_videoControllers[index] != null) {
      try {
        _videoControllers[index]!.setVolume(1.0);
        _videoControllers[index]!.play();
      } catch (e) {
        print('Error playing video: $e');
      }
    } else {
      _initializeVideoForIndex(index);
    }
  }

  Future<void> _voteForEntry(Map<String, dynamic> reel, int index) async {
    // Check if already voted - just return silently, the colored icon shows the state
    if (_votedReels[index] == true) {
      return;
    }

    try {
      // Get the entry ID from the competition data
      final competition = widget.competitions[index];
      final entryId = competition['entryId'];

      if (entryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to vote: Entry ID not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await ApiService.voteSYTEntry(entryId);

      if (response['success']) {
        print('Vote successful! Setting _votedReels[$index] = true');
        setState(() {
          _votedReels[index] = true;
          // Update vote count (separate from likes)
          final currentVotes =
              int.tryParse(widget.competitions[index]['votes'] ?? '0') ?? 0;
          widget.competitions[index]['votes'] = (currentVotes + 1).toString();
          print(
            'Updated vote count to: ${widget.competitions[index]['votes']}',
          );
          print('_votedReels[$index] is now: ${_votedReels[index]}');
        });

        HapticFeedback.mediumImpact();

        // Show success message with coin deduction info
        final coinsDeducted = response['coinsDeducted'] ?? 1;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Vote recorded! -$coinsDeducted coin${coinsDeducted > 1 ? 's' : ''} deducted',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Don't reload stats immediately - the voted state is already set correctly
        // Stats will be reloaded on next page change or app restart
      } else {
        print('Vote failed: ${response['message']}');

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Vote failed'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Vote failed (already voted or insufficient coins) - reload stats to get accurate state
        await _reloadEntryStats(index);
      }
    } catch (e) {
      // Show error message
      print('Vote error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error voting: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _toggleBookmark(String entryId, int index) async {
    try {
      final response = await ApiService.toggleSYTBookmark(entryId);
      if (response['success'] && mounted) {
        setState(() {
          _savedReels[index] = response['data']['isBookmarked'];
        });
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

  Future<void> _reloadEntryStats(int index) async {
    try {
      final reel = widget.competitions[index];
      final entryId = reel['_id'] ?? reel['entryId'];
      if (entryId != null) {
        final statsResponse = await ApiService.getSYTEntryStats(entryId);
        if (statsResponse['success'] && mounted) {
          print('Stats loaded for entry $index:');
          print('  hasVoted: ${statsResponse['data']['hasVoted']}');
          print('  likesCount: ${statsResponse['data']['likesCount']}');
          print(
            '  hoursUntilNextVote: ${statsResponse['data']['hoursUntilNextVote']}',
          );

          setState(() {
            widget.competitions[index]['likes'] =
                statsResponse['data']['likesCount']?.toString() ?? '0';
            widget.competitions[index]['comments'] =
                statsResponse['data']['commentsCount']?.toString() ?? '0';
            _likedReels[index] = statsResponse['data']['isLiked'] ?? false;
            _votedReels[index] = statsResponse['data']['hasVoted'] ?? false;
            _savedReels[index] = statsResponse['data']['isBookmarked'] ?? false;
            _hoursUntilNextVote[index] =
                statsResponse['data']['hoursUntilNextVote'];

            print('  _votedReels[$index] set to: ${_votedReels[index]}');
          });
        }
      }
    } catch (e) {
      print('Error reloading stats: $e');
    }
  }

  // Load and play background music for current SYT reel
  Future<void> _playBackgroundMusicForSYTReel(int index) async {
    try {
      if (index < 0 || index >= widget.competitions.length) {
        return;
      }

      final competition = widget.competitions[index];
      final backgroundMusicId =
          competition['backgroundMusic']?['_id'] ??
          competition['backgroundMusic']?['id'] ??
          competition['backgroundMusicId'];

      // If no music, stop current music
      if (backgroundMusicId == null || backgroundMusicId.isEmpty) {
        if (_currentMusicId != null) {
          print('🎵 No background music for this SYT reel, stopping music');
          await _musicService.stopBackgroundMusic();
          _currentMusicId = null;
        }
        return;
      }

      // If same music is already playing, don't reload
      if (_currentMusicId == backgroundMusicId) {
        print('🎵 Same music already playing, skipping reload');
        return;
      }

      print('🎵 Loading background music for SYT reel: $backgroundMusicId');

      // Fetch music details from API
      final response = await ApiService.getMusic(backgroundMusicId);

      if (response['success']) {
        final musicData = response['data'];
        final rawAudioUrl = musicData['audioUrl'];

        if (rawAudioUrl == null || rawAudioUrl.isEmpty) {
          print('❌ Audio URL is empty or null');
          await _musicService.stopBackgroundMusic();
          _currentMusicId = null;
          return;
        }

        // Convert relative URL to full URL using ApiService helper
        final audioUrl = ApiService.getAudioUrl(rawAudioUrl);
        print('🎵 Playing background music: $audioUrl');

        // Play background music
        await _musicService.playBackgroundMusic(audioUrl, backgroundMusicId);
        _currentMusicId = backgroundMusicId;

        print('✅ Background music loaded and playing for SYT reel');
      } else {
        print('❌ Failed to fetch music: ${response['message']}');
        await _musicService.stopBackgroundMusic();
        _currentMusicId = null;
      }
    } catch (e) {
      print('❌ Error loading background music: $e');
      try {
        await _musicService.stopBackgroundMusic();
      } catch (stopError) {
        print('Error stopping music: $stopError');
      }
      _currentMusicId = null;
    }
  }

  // Convert competition data to reel format
  Map<String, dynamic> _convertToReelData(Map<String, dynamic> competition) {
    // Use real data from backend, not calculated values
    return {
      'username': competition['username'] ?? '@user',
      'description':
          competition['description'] ??
          (competition['title'] != null
              ? '${competition['title']} - ${competition['category']} 🎭'
              : 'Competing in ${competition['category']} - Show Your Talent! 🎭'),
      'likes':
          competition['likesCount']?.toString() ?? competition['likes'] ?? '0',
      'votes': competition['votesCount']?.toString() ?? '0',
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
      'category': competition['category'] ?? 'Other',
      'gradient': competition['gradient'],
      'entryId': competition['entryId'] ?? competition['_id'],
      'user': competition['user'],
      '_id': competition['_id'] ?? competition['entryId'],
      'userId': competition['user']?['_id'],
      'thumbnailUrl': competition['thumbnailUrl'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Trigger animations on page change
          _fadeController.reset();
          _fadeController.forward();

          // Pause previous video
          _pauseAllVideos();

          // Play video at current index if ready
          if (_videoReady[index] == true) {
            _playVideoAtIndex(index);
          } else if (_videoInitialized[index] != true) {
            _initializeVideoForIndex(index);
          }

          // Preload next 3 videos (instead of just 1) for faster scrolling
          for (int i = 1; i <= 3; i++) {
            if (index + i < widget.competitions.length &&
                _videoControllers[index + i] == null) {
              _initializeVideoForIndex(index + i);
            }
          }

          // Preload previous video
          if (index > 0 && _videoControllers[index - 1] == null) {
            _initializeVideoForIndex(index - 1);
          }

          // Clean up distant controllers
          _cleanupDistantControllers(index);

          // Load stats for nearby entries
          _reloadEntryStats(index);
          if (index + 1 < widget.competitions.length) {
            _reloadEntryStats(index + 1);
          }

          // 🎵 Background music playback
          if (index < widget.competitions.length) {
            _playBackgroundMusicForSYTReel(index);
          }
        },
        itemCount: widget.competitions.length,
        itemBuilder: (context, index) {
          final competition = widget.competitions[index];
          final reelData = _convertToReelData(competition);

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              }

              return Transform.scale(
                scale: Curves.easeOut.transform(value),
                child: Opacity(
                  opacity: value,
                  child: _buildReelItem(reelData, index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildReelItem(Map<String, dynamic> reel, int index) {
    final videoController = _videoControllers[index];
    final hasVideo =
        videoController != null && videoController.value.isInitialized;
    var thumbnailUrl = reel['thumbnailUrl'];

    // Convert relative thumbnail URLs to full URLs
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      if (thumbnailUrl.startsWith('/uploads')) {
        thumbnailUrl = '${ApiConfig.baseUrl}$thumbnailUrl';
      } else if (!thumbnailUrl.startsWith('http')) {
        thumbnailUrl = ApiService.getImageUrl(thumbnailUrl);
      }
    }

    return Stack(
      children: [
        // Video player or thumbnail/gradient background
        if (hasVideo)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: videoController.value.size.width,
                height: videoController.value.size.height,
                child: VideoPlayer(videoController),
              ),
            ),
          )
        else if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
          // Show thumbnail while buffering
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.network(
                thumbnailUrl,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to gradient if thumbnail fails to load
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: reel['gradient'] as List<Color>,
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        else
          // Animated background with competition gradient (fallback)
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: reel['gradient'] as List<Color>,
              ),
            ),
          ),

        // Loading indicator overlay (only show if video is not ready and no thumbnail)
        if (!hasVideo && (thumbnailUrl == null || thumbnailUrl.isEmpty))
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(color: Colors.white),
            ),
          ),

        // Tap to play/pause
        GestureDetector(
          onTap: () {
            if (hasVideo) {
              setState(() {
                if (videoController.value.isPlaying) {
                  videoController.pause();
                } else {
                  videoController.play();
                }
              });
            }
          },
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        // Play/Pause indicator
        if (hasVideo && !videoController.value.isPlaying)
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
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
          top: MediaQuery.of(context).padding.top + 10,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.black.withValues(alpha: 0.7),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                SizedBox(width: 8),
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
          top: MediaQuery.of(context).padding.top + 20,
          left: 20,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
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
        // Duration indicator removed

        // Right side action buttons with vote button
        Positioned(
          right: 12,
          top: MediaQuery.of(context).size.height * 0.35,
          child: TweenAnimationBuilder<Offset>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: const Offset(1, 0), end: Offset.zero),
            curve: Curves.elasticOut,
            builder: (context, offset, child) {
              return Transform.translate(
                offset: offset * 100,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                  child: Column(
                    children: [
                      // Like button (regular like functionality)
                      _buildActionButton(
                        'assets/sidereel/like.png',
                        reel['likes'],
                        _likedReels[index] == true ? Colors.red : Colors.white,
                        onTap: () async {
                          final entryId = reel['_id'] ?? reel['entryId'];
                          if (entryId != null) {
                            try {
                              final response = await ApiService.toggleSYTLike(
                                entryId,
                              );
                              if (response['success'] && mounted) {
                                setState(() {
                                  _likedReels[index] =
                                      response['data']['isLiked'];
                                  // Update the likes count in the reel data
                                  widget.competitions[index]['likes'] =
                                      response['data']['likesCount'].toString();
                                });
                                HapticFeedback.lightImpact();
                              }
                            } catch (e) {
                              print('Error toggling like: $e');
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Vote button (separate voting functionality)
                      _buildVoteButton(reel, index),
                      const SizedBox(height: 20),

                      _buildActionButton(
                        'assets/sidereel/comment.png',
                        reel['comments'] ?? '0',
                        Colors.white,
                        onTap: () async {
                          final entryId = reel['_id'] ?? reel['entryId'];
                          if (entryId != null) {
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) =>
                                  CommentsScreen(postId: entryId),
                            );
                            // Reload entry stats after comments
                            _reloadEntryStats(index);
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildActionButton(
                        'assets/sidereel/saved.png',
                        reel['bookmarks'] ?? '0',
                        _savedReels[index] == true
                            ? Colors.yellow
                            : Colors.white,
                        onTap: () async {
                          final entryId = reel['_id'] ?? reel['entryId'];
                          if (entryId != null) {
                            await _toggleBookmark(entryId, index);
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () async {
                          final userId = reel['user']?['_id'] ?? reel['userId'];
                          final username =
                              reel['user']?['username'] ??
                              reel['username'] ??
                              'User';
                          if (userId != null) {
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => GiftScreen(
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
          child: TweenAnimationBuilder<Offset>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
            curve: Curves.easeOutBack,
            builder: (context, offset, child) {
              return Transform.translate(
                offset: offset * 50,
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
                              border: Border.all(color: Colors.white, width: 2),
                              gradient: LinearGradient(
                                colors: reel['gradient'] as List<Color>,
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
                          const SizedBox(width: 12),

                          // Username and badge (wrapped in Expanded to prevent overflow)
                          Expanded(
                            child: Row(
                              children: [
                                // Username
                                Flexible(
                                  child: Text(
                                    reel['username'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // SYT Competition badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.amber, Colors.orange],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.emoji_events,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        'SYT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Description with competition info
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1000),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          final description = reel['description'] as String;
                          final runes = description.runes.toList();
                          final displayLength = (runes.length * value).round();
                          final safeText = displayLength >= runes.length
                              ? description
                              : String.fromCharCodes(runes.take(displayLength));

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
      ],
    );
  }

  Widget _buildActionButton(
    String imagePath,
    String count,
    Color iconColor, {
    VoidCallback? onTap,
    bool isVote = false,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, iconValue, child) {
                      return Transform.rotate(
                        angle: (1 - iconValue) * 0.2,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              imagePath,
                              width: 28,
                              height: 28,
                              color: iconColor,
                            ),
                            if (isVote && iconColor == Colors.amber)
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
                  const SizedBox(height: 4),
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

  Widget _buildVoteButton(Map<String, dynamic> reel, int index) {
    final hasVoted = _votedReels[index] == true;
    final voteCount = int.tryParse(reel['votes']?.toString() ?? '0') ?? 0;
    final displayVotes = hasVoted ? '${voteCount + 1}' : '$voteCount';

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: GestureDetector(
            onTap: () => _voteForEntry(reel, index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasVoted
                    ? Colors.amber.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, iconValue, child) {
                      return Transform.rotate(
                        angle: (1 - iconValue) * 0.2,
                        child: Icon(
                          Icons.touch_app,
                          size: 32,
                          color: hasVoted ? Colors.amber : Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
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
                  const SizedBox(height: 2),
                  Text(
                    'VOTE',
                    style: TextStyle(
                      color: hasVoted ? Colors.amber : Colors.white70,
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
