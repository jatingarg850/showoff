import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'main_screen.dart';
import 'services/api_service.dart';
import 'services/wasabi_service.dart';
import 'services/storage_service.dart';

class PreviewScreen extends StatefulWidget {
  final String selectedPath;
  final String? mediaPath;
  final String? category;
  final String caption;
  final bool isVideo;
  final String? thumbnailPath;
  final List<String> hashtags;

  const PreviewScreen({
    super.key,
    required this.selectedPath,
    this.mediaPath,
    this.category,
    required this.caption,
    this.isVideo = false,
    this.thumbnailPath,
    this.hashtags = const [],
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
    if (widget.isVideo && widget.mediaPath != null) {
      _initializeVideo();
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
      _videoController = VideoPlayerController.file(File(widget.mediaPath!));
      await _videoController!.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
      _videoController!.setLooping(true);
      _videoController!.play();
    } catch (e) {
      debugPrint('Error initializing video: $e');
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
                // Competition badge
                if (widget.selectedPath == 'SYT')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
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
                    final mediaFile = File(widget.mediaPath!);

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

                      final response = await ApiService.submitSYTEntry(
                        videoFile: mediaFile,
                        thumbnailFile: thumbnailFile,
                        title: widget.caption.isEmpty
                            ? 'My Talent'
                            : widget.caption,
                        category: widget.category ?? 'other',
                        competitionType: 'weekly', // Default to weekly
                        description: widget.caption,
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
                      String mediaUrl;
                      String mediaType;
                      String? thumbnailUrl;

                      if (widget.isVideo) {
                        mediaUrl = await wasabiService.uploadVideo(mediaFile);
                        mediaType = 'video';

                        // Upload thumbnail if available
                        if (widget.thumbnailPath != null) {
                          final thumbnailFile = File(widget.thumbnailPath!);
                          thumbnailUrl = await wasabiService.uploadImage(
                            thumbnailFile,
                          );
                        }
                      } else {
                        mediaUrl = await wasabiService.uploadImage(mediaFile);
                        mediaType = 'image';
                      }

                      // Create post with uploaded URL
                      final response = await ApiService.createPostWithUrl(
                        mediaUrl: mediaUrl,
                        mediaType: mediaType,
                        thumbnailUrl: thumbnailUrl,
                        caption: widget.caption,
                        hashtags: widget.hashtags.isNotEmpty
                            ? widget.hashtags
                            : hashtags,
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
                        throw Exception(response['message'] ?? 'Upload failed');
                      }
                    }

                    // Navigate based on upload type
                    if (!mounted) return;

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
