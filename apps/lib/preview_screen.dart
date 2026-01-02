import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'main_screen.dart';
import 'services/api_service.dart';
import 'services/wasabi_service.dart';
import 'services/storage_service.dart';
import 'services/thumbnail_service.dart';
import 'services/file_persistence_service.dart';
import 'services/background_music_service.dart';
import 'services/video_audio_merge_service.dart';
import 'services/video_compression_service.dart';

class PreviewScreen extends StatefulWidget {
  final String selectedPath;
  final String? mediaPath;
  final String? category;
  final String caption;
  final bool isVideo;
  final String? thumbnailPath;
  final List<String> hashtags;
  final String? backgroundMusicId;
  final VoidCallback? onUploadComplete;
  final VoidCallback? onBack;

  const PreviewScreen({
    super.key,
    required this.selectedPath,
    this.mediaPath,
    this.category,
    required this.caption,
    this.isVideo = false,
    this.thumbnailPath,
    this.hashtags = const [],
    this.backgroundMusicId,
    this.onUploadComplete,
    this.onBack,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    print('🎬 PreviewScreen initialized');
    print('  - selectedPath: ${widget.selectedPath}');
    print('  - mediaPath: ${widget.mediaPath}');
    print('  - isVideo: ${widget.isVideo}');
    print('  - backgroundMusicId: ${widget.backgroundMusicId}');

    if (widget.isVideo && widget.mediaPath != null) {
      _initializeVideo();
    }

    // Load background music if selected
    if (widget.backgroundMusicId != null) {
      _loadBackgroundMusic();
    }
  }

  Future<Map<String, dynamic>> _getCurrentUser() async {
    try {
      final user = await StorageService.getUser();
      return user ?? {'username': 'user'};
    } catch (e) {
      return {'username': 'user'};
    }
  }

  Future<void> _initializeVideo() async {
    try {
      print('🎬 Initializing video...');
      print('  - Path: ${widget.mediaPath}');

      // Check if file exists
      final file = File(widget.mediaPath!);
      final exists = await file.exists();
      print('  - File exists: $exists');

      if (!exists) {
        print('❌ Video file not found at: ${widget.mediaPath}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Video file not found: ${widget.mediaPath}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      // Get file size
      final fileSizeMB = await FilePersistenceService.getVideoFileSizeMB(
        widget.mediaPath!,
      );
      print('📹 Video file size: ${fileSizeMB.toStringAsFixed(2)} MB');

      // Initialize video controller
      _videoController = VideoPlayerController.file(file);
      await _videoController!.initialize();

      setState(() {
        _isVideoInitialized = true;
      });

      _videoController!.setLooping(true);
      _videoController!.play();
      print('✅ Video initialized and playing');
    } catch (e) {
      print('❌ Error initializing video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading video: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadBackgroundMusic() async {
    try {
      print('🎵 Loading background music: ${widget.backgroundMusicId}');

      // Fetch music details from API
      final response = await ApiService.getMusic(widget.backgroundMusicId!);

      print('🎵 Music Response: $response');

      if (response['success']) {
        final musicData = response['data'];

        print('🎵 Music Data: $musicData');

        final rawAudioUrl = musicData['audioUrl'];

        if (rawAudioUrl == null || rawAudioUrl.isEmpty) {
          print('❌ Audio URL is empty or null');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Music audio URL not found'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        // Convert relative URL to full URL using ApiService helper
        final audioUrl = ApiService.getAudioUrl(rawAudioUrl);
        print('🎵 Final Music URL: $audioUrl');

        // Play background music
        final musicService = BackgroundMusicService();
        await musicService.playBackgroundMusic(
          audioUrl,
          widget.backgroundMusicId!,
        );

        print('✅ Background music loaded and playing');
      } else {
        print('❌ Failed to fetch music: ${response['message']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading music: ${response['message']}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error loading background music: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading background music: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showRewardDialog(Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎉 Reward Earned!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF701CF5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '+${reward['coins']}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF701CF5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You earned ${reward['coins']} coins for uploading!',
              textAlign: TextAlign.center,
            ),
            if (reward['bonusAwarded'] == true)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '🎁 Bonus included!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();

    // Stop background music
    try {
      final musicService = BackgroundMusicService();
      musicService.stopBackgroundMusic();
      print('🎵 Background music stopped on dispose');
    } catch (e) {
      print('Error stopping background music: $e');
    }

    // Clean up temporary files when leaving preview screen
    if (widget.isVideo && widget.mediaPath != null) {
      // Don't delete the persisted video - it will be used for upload
      // Only clean up if user navigates back without uploading
      print('🧹 Preview screen disposed');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF701CF5), Color(0xFF3E98E4)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            'Preview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Background media
          if (widget.mediaPath != null)
            Positioned.fill(
              child: widget.isVideo
                  ? (_isVideoInitialized && _videoController != null
                        ? AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          )
                        : Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ))
                  : Image.file(File(widget.mediaPath!), fit: BoxFit.cover),
            )
          else
            // Placeholder if no media
            Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.image, size: 100, color: Colors.white54),
              ),
            ),

          // Black gradient overlay for bottom content
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),

          // Overlay content
          Positioned(
            left: 20,
            right: 20,
            bottom: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Background Music Badge (NEW)
                if (widget.backgroundMusicId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF701CF5).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Background Music Added',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Competition badge
                if (widget.selectedPath == 'SYT')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'In competition',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Category badge
                if (widget.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF701CF5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      widget.category!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Username (from current user)
                FutureBuilder<Map<String, dynamic>>(
                  future: _getCurrentUser(),
                  builder: (context, snapshot) {
                    final username = snapshot.data?['username'] ?? 'user';
                    return Row(
                      children: [
                        Text(
                          '@$username',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 8),

                // Follow button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF701CF5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Follow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Caption
                if (widget.caption.isNotEmpty)
                  Text(
                    widget.caption,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Upload button
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF701CF5), Color(0xFF74B9FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (widget.mediaPath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No media selected'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (!mounted) return;
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF701CF5),
                        ),
                      ),
                    ),
                  );

                  try {
                    // Verify media file exists
                    final mediaFile = File(widget.mediaPath!);
                    if (!await mediaFile.exists()) {
                      throw Exception(
                        'Media file not found: ${widget.mediaPath}',
                      );
                    }

                    // Extract hashtags from caption
                    final hashtags = widget.caption
                        .split(' ')
                        .where((word) => word.startsWith('#'))
                        .map((tag) => tag.substring(1))
                        .toList();

                    // Upload based on path (SYT, selfie challenge, or regular post)
                    if (widget.selectedPath == 'selfie_challenge') {
                      // Submit daily selfie
                      final response = await ApiService.submitDailySelfie(
                        mediaFile,
                      );

                      if (!mounted) return;
                      navigator.pop(); // Close loading

                      if (response['success']) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Daily selfie submitted successfully! 📸',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        throw Exception(
                          response['message'] ?? 'Selfie upload failed',
                        );
                      }
                    } else if (widget.selectedPath == 'SYT') {
                      // Submit SYT entry with thumbnail
                      File? thumbnailFile;
                      if (widget.thumbnailPath != null) {
                        thumbnailFile = File(widget.thumbnailPath!);
                      }

                      print('📤 Submitting SYT entry with:');
                      print(
                        '  - title: ${widget.caption.isEmpty ? "My Talent" : widget.caption}',
                      );
                      print('  - category: ${widget.category ?? "other"}');
                      print('  - competitionType: weekly');
                      print('  - description: ${widget.caption}');
                      print(
                        '  - backgroundMusicId: ${widget.backgroundMusicId}',
                      );

                      // CRITICAL: Merge video with background music if selected
                      File fileToUpload = mediaFile;
                      if (widget.isVideo && widget.backgroundMusicId != null) {
                        try {
                          print(
                            '🎬 Preparing SYT video with background music...',
                          );

                          // Fetch music details to verify audio URL
                          final musicResponse = await ApiService.getMusic(
                            widget.backgroundMusicId!,
                          );

                          if (musicResponse['success']) {
                            final musicData = musicResponse['data'];
                            final rawAudioUrl = musicData['audioUrl'];

                            if (rawAudioUrl != null && rawAudioUrl.isNotEmpty) {
                              final audioUrl = ApiService.getAudioUrl(
                                rawAudioUrl,
                              );
                              print('🎵 Audio URL: $audioUrl');

                              // Verify audio is accessible
                              await VideoAudioMergeService.downloadAudioForVerification(
                                audioUrl: audioUrl,
                              );

                              // Upload video as-is with music metadata
                              fileToUpload = File(widget.mediaPath!);
                              print('✅ SYT video ready with music metadata');
                              print('  - Video file: ${widget.mediaPath}');
                              print(
                                '  - Music ID: ${widget.backgroundMusicId}',
                              );
                            } else {
                              print(
                                '⚠️ Audio URL not found, uploading SYT video without music',
                              );
                            }
                          } else {
                            print(
                              '⚠️ Failed to fetch music, uploading SYT video without music',
                            );
                          }
                        } catch (e) {
                          print('⚠️ Error merging SYT video with audio: $e');
                          print('  - Continuing with original video');
                          // Continue with original video if merge fails
                        }
                      }

                      final response = await ApiService.submitSYTEntry(
                        videoFile: fileToUpload,
                        thumbnailFile: thumbnailFile,
                        title: widget.caption.isEmpty
                            ? 'My Talent'
                            : widget.caption,
                        category: widget.category ?? 'other',
                        competitionType: 'weekly', // Default to weekly
                        description: widget.caption,
                        backgroundMusicId: widget.backgroundMusicId,
                      );

                      if (!mounted) return;
                      navigator.pop(); // Close loading

                      if (response['success']) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('SYT entry submitted successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        throw Exception(response['message'] ?? 'Upload failed');
                      }
                    } else {
                      // Upload directly to Wasabi S3
                      final wasabiService = WasabiService();
                      final thumbnailService = ThumbnailService();
                      String mediaUrl;
                      String mediaType;
                      String? thumbnailUrl;
                      File fileToUpload =
                          mediaFile; // Initialize with original file

                      if (widget.isVideo) {
                        // CRITICAL: Merge video with background music if selected
                        if (widget.backgroundMusicId != null) {
                          try {
                            print(
                              '🎬 Preparing video with background music...',
                            );

                            // Fetch music details to verify audio URL
                            final musicResponse = await ApiService.getMusic(
                              widget.backgroundMusicId!,
                            );

                            if (musicResponse['success']) {
                              final musicData = musicResponse['data'];
                              final rawAudioUrl = musicData['audioUrl'];

                              if (rawAudioUrl != null &&
                                  rawAudioUrl.isNotEmpty) {
                                final audioUrl = ApiService.getAudioUrl(
                                  rawAudioUrl,
                                );
                                print('🎵 Audio URL: $audioUrl');

                                // Verify audio is accessible
                                await VideoAudioMergeService.downloadAudioForVerification(
                                  audioUrl: audioUrl,
                                );

                                // Upload video as-is with music metadata
                                fileToUpload = File(widget.mediaPath!);
                                print('✅ Video ready with music metadata');
                                print('  - Video file: ${widget.mediaPath}');
                                print(
                                  '  - Music ID: ${widget.backgroundMusicId}',
                                );
                              } else {
                                print(
                                  '⚠️ Audio URL not found, uploading video without music',
                                );
                              }
                            } else {
                              print(
                                '⚠️ Failed to fetch music, uploading video without music',
                              );
                            }
                          } catch (e) {
                            print('⚠️ Error preparing video with audio: $e');
                            print('  - Continuing with original video');
                            // Continue with original video if preparation fails
                          }
                        }

                        // Compress video to 720p and 24fps before uploading
                        print('🎬 Compressing video to 720p and 24fps...');
                        try {
                          final compressedPath =
                              await VideoCompressionService.compressVideo(
                                fileToUpload.path,
                              );
                          fileToUpload = File(compressedPath);
                          print('✅ Video compressed successfully');
                          print('  - Compressed path: $compressedPath');
                        } catch (e) {
                          print('⚠️ Video compression failed: $e');
                          print('  - Uploading original video');
                          // Continue with original video if compression fails
                          // fileToUpload is already set to original
                        }

                        mediaUrl = await wasabiService.uploadVideo(
                          fileToUpload,
                        );
                        mediaType = 'video';

                        // Use provided thumbnail or auto-generate
                        if (widget.thumbnailPath != null) {
                          // Use user-selected thumbnail
                          final thumbnailFile = File(widget.thumbnailPath!);

                          // Check if thumbnail file exists before uploading
                          if (await thumbnailFile.exists()) {
                            try {
                              thumbnailUrl = await wasabiService.uploadImage(
                                thumbnailFile,
                              );
                              print('✅ Using user-selected thumbnail');
                            } catch (e) {
                              print(
                                '⚠️ Error uploading user-selected thumbnail: $e',
                              );
                              // Fall back to auto-generate
                            }
                          } else {
                            print(
                              '⚠️ User-selected thumbnail file not found: ${widget.thumbnailPath}',
                            );
                          }
                        }

                        // Auto-generate thumbnail if no thumbnail URL yet
                        if (thumbnailUrl == null) {
                          print('🎬 Auto-generating thumbnail for video...');
                          try {
                            final generatedThumbnailPath =
                                await thumbnailService.generateThumbnail(
                                  videoPath: widget.mediaPath!,
                                  maxWidth: 640,
                                  maxHeight: 480,
                                  quality: 75,
                                  timeMs: 0, // First frame
                                );

                            if (generatedThumbnailPath != null) {
                              final thumbnailFile = File(
                                generatedThumbnailPath,
                              );

                              if (await thumbnailFile.exists()) {
                                thumbnailUrl = await wasabiService.uploadImage(
                                  thumbnailFile,
                                );
                                print('✅ Auto-generated thumbnail uploaded');

                                // Clean up temporary thumbnail
                                await thumbnailService.cleanupThumbnail(
                                  generatedThumbnailPath,
                                );
                              } else {
                                print('⚠️ Generated thumbnail file not found');
                              }
                            } else {
                              print(
                                '⚠️ Failed to auto-generate thumbnail, continuing without',
                              );
                            }
                          } catch (e) {
                            print('⚠️ Error auto-generating thumbnail: $e');
                            // Continue without thumbnail if generation fails
                          }
                        }
                      } else {
                        mediaUrl = await wasabiService.uploadImage(mediaFile);
                        mediaType = 'image';
                      }

                      // Create post with uploaded URL
                      print('📤 Creating post with:');
                      print('  - mediaUrl: $mediaUrl');
                      print('  - mediaType: $mediaType');
                      print('  - thumbnailUrl: $thumbnailUrl');
                      print('  - caption: ${widget.caption}');
                      print('  - musicId: ${widget.backgroundMusicId}');
                      print('  - isPublic: true');

                      final response = await ApiService.createPostWithUrl(
                        mediaUrl: mediaUrl,
                        mediaType: mediaType,
                        thumbnailUrl: thumbnailUrl,
                        caption: widget.caption,
                        hashtags: widget.hashtags.isNotEmpty
                            ? widget.hashtags
                            : hashtags,
                        musicId: widget.backgroundMusicId,
                        isPublic: true,
                      );

                      if (!mounted) return;
                      navigator.pop(); // Close loading

                      if (response['success']) {
                        // Show reward if any
                        if (response['reward'] != null &&
                            response['reward']['awarded']) {
                          _showRewardDialog(response['reward']);
                        } else {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Post uploaded successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        final errorMsg = response['message'] ?? 'Upload failed';
                        print('❌ Post creation failed: $errorMsg');
                        throw Exception(errorMsg);
                      }
                    }

                    // Navigate based on upload type
                    if (!mounted) return;

                    // Cleanup thumbnail if it was user-selected
                    if (widget.thumbnailPath != null) {
                      try {
                        final thumbnailService = ThumbnailService();
                        await thumbnailService.cleanupThumbnail(
                          widget.thumbnailPath!,
                        );
                      } catch (e) {
                        debugPrint('Error cleaning up thumbnail: $e');
                      }
                    }

                    if (widget.selectedPath == 'selfie_challenge') {
                      // For selfie challenge, go back to daily selfie screen
                      navigator.popUntil(
                        (route) =>
                            route.settings.name == '/daily_selfie' ||
                            route.isFirst,
                      );
                    } else {
                      // For other uploads, go to main screen
                      navigator.popUntil((route) => route.isFirst);
                      navigator.pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => MainScreen(
                            initialIndex: widget.selectedPath == 'SYT' ? 1 : 0,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    navigator.pop(); // Close loading

                    // Cleanup thumbnail on error too
                    if (widget.thumbnailPath != null) {
                      try {
                        final thumbnailService = ThumbnailService();
                        await thumbnailService.cleanupThumbnail(
                          widget.thumbnailPath!,
                        );
                      } catch (cleanupError) {
                        debugPrint(
                          'Error cleaning up thumbnail: $cleanupError',
                        );
                      }
                    }

                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Upload failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'Upload',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
