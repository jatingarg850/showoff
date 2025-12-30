import 'package:flutter/material.dart';
import 'models/content_creation_flow.dart';
import 'camera_screen.dart';
import 'upload_content_screen.dart';
import 'music_selection_screen.dart';
import 'thumbnail_selector_screen.dart';
import 'preview_screen.dart';

/// Unified content creation flow screen
/// Manages the sequential flow: Record → Caption → Music → Thumbnail → Preview → Upload
class ContentCreationFlowScreen extends StatefulWidget {
  final String selectedPath; // 'reels', 'SYT', 'selfie_challenge'
  final String? sytCategory; // Category for SYT

  const ContentCreationFlowScreen({
    super.key,
    required this.selectedPath,
    this.sytCategory,
  });

  @override
  State<ContentCreationFlowScreen> createState() =>
      _ContentCreationFlowScreenState();
}

class _ContentCreationFlowScreenState extends State<ContentCreationFlowScreen> {
  late ContentCreationFlow _flow;
  late PageController _pageController;
  int _currentStep = 1; // 1-6

  @override
  void initState() {
    super.initState();
    _flow = ContentCreationFlow(
      selectedPath: widget.selectedPath,
      sytCategory: widget.sytCategory,
    );
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Navigate to next step
  void _nextStep() {
    if (_currentStep < 6) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigate to previous step
  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Handle recording completion
  void _onRecordingComplete(String mediaPath, bool isVideo) {
    if (mediaPath.isEmpty) {
      debugPrint('❌ Recording failed: empty mediaPath');
      return;
    }
    _flow.mediaPath = mediaPath;
    _flow.isVideo = isVideo;
    debugPrint('✅ Recording complete: $mediaPath (isVideo: $isVideo)');
    _nextStep();
  }

  /// Handle caption completion
  void _onCaptionComplete(String caption, List<String> hashtags) {
    if (caption.trim().isEmpty) {
      debugPrint('❌ Caption validation failed: empty caption');
      return;
    }
    _flow.caption = caption;
    _flow.hashtags = hashtags;
    debugPrint('✅ Caption complete: $caption');
    _nextStep();
  }

  /// Handle music selection
  void _onMusicSelected(String? musicId, Map<String, dynamic>? music) {
    _flow.backgroundMusicId = musicId;
    _flow.selectedMusic = music;
    debugPrint('✅ Music selected: $musicId');
    _nextStep();
  }

  /// Handle thumbnail selection
  void _onThumbnailSelected(String thumbnailPath) {
    if (thumbnailPath.isEmpty) {
      debugPrint('❌ Thumbnail validation failed: empty path');
      return;
    }
    _flow.thumbnailPath = thumbnailPath;
    debugPrint('✅ Thumbnail selected: $thumbnailPath');
    _nextStep();
  }

  /// Handle upload completion
  void _onUploadComplete() {
    debugPrint('✅ Upload complete');
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _previousStep,
              )
            : null,
        title: Text(
          'Step $_currentStep: ${_flow.getStepName(_currentStep)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        onPageChanged: (index) {
          setState(() => _currentStep = index + 1);
        },
        children: [
          // Step 1: Recording
          _buildRecordingStep(),

          // Step 2: Caption
          _buildCaptionStep(),

          // Step 3: Music Selection
          _buildMusicStep(),

          // Step 4: Thumbnail Selection
          _buildThumbnailStep(),

          // Step 5: Preview
          _buildPreviewStep(),

          // Step 6: Upload (handled in preview)
        ],
      ),
    );
  }

  /// Step 1: Recording
  Widget _buildRecordingStep() {
    return CameraScreen(
      selectedPath: _flow.selectedPath,
      backgroundMusicId: _flow.backgroundMusicId,
      onRecordingComplete: _onRecordingComplete,
      onSkip: _nextStep,
    );
  }

  /// Step 2: Caption
  Widget _buildCaptionStep() {
    debugPrint('📝 Building caption step with callback');
    return UploadContentScreen(
      selectedPath: _flow.selectedPath,
      mediaPath: _flow.mediaPath,
      isVideo: _flow.isVideo,
      backgroundMusicId: _flow.backgroundMusicId,
      onCaptionComplete: (caption, hashtags) {
        debugPrint('✅ Caption complete callback triggered');
        _onCaptionComplete(caption, hashtags);
      },
      onBack: _previousStep,
    );
  }

  /// Step 3: Music Selection
  Widget _buildMusicStep() {
    debugPrint('🎵 Building music selection step');
    return MusicSelectionScreen(
      selectedPath: _flow.selectedPath,
      category: _flow.sytCategory,
      onMusicSelected: (musicId, music) {
        debugPrint('✅ Music selected callback triggered: $musicId');
        _onMusicSelected(musicId, music);
      },
      onSkip: () {
        debugPrint('⏭️ Music selection skipped');
        _nextStep();
      },
      onBack: _previousStep,
    );
  }

  /// Step 4: Thumbnail Selection
  Widget _buildThumbnailStep() {
    debugPrint('🖼️ Building thumbnail selection step');
    if (!_flow.isVideo) {
      // Skip thumbnail for photos - use callback instead of auto-advance
      debugPrint('⏭️ Skipping thumbnail for photos');
      return _buildPhotoSkipScreen();
    }

    return ThumbnailSelectorScreen(
      videoPath: _flow.mediaPath!,
      selectedPath: _flow.selectedPath,
      caption: _flow.caption,
      hashtags: _flow.hashtags,
      backgroundMusicId: _flow.backgroundMusicId,
      onThumbnailSelected: (thumbnailPath) {
        debugPrint('✅ Thumbnail selected callback triggered: $thumbnailPath');
        _onThumbnailSelected(thumbnailPath);
      },
      onBack: _previousStep,
    );
  }

  /// Show a simple screen for photo uploads (skip thumbnail)
  Widget _buildPhotoSkipScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 20),
          const Text(
            'Photo Ready',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'No thumbnail needed for photos',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              debugPrint('⏭️ Photo skip - proceeding to preview');
              _nextStep();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF701CF5),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: const Text(
              'Continue to Preview',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 5: Preview
  Widget _buildPreviewStep() {
    debugPrint('👁️ Building preview step');

    // Validate required data before showing preview
    if (_flow.mediaPath == null || _flow.mediaPath!.isEmpty) {
      debugPrint('❌ Preview validation failed: mediaPath is null or empty');
      return _buildValidationErrorScreen(
        'Media file not found',
        'Please record again',
      );
    }

    if (_flow.caption.isEmpty) {
      debugPrint('❌ Preview validation failed: caption is empty');
      return _buildValidationErrorScreen(
        'Caption required',
        'Please add a caption',
      );
    }

    debugPrint('✅ Preview validation passed');
    debugPrint('   - mediaPath: ${_flow.mediaPath}');
    debugPrint('   - caption: ${_flow.caption}');
    debugPrint('   - isVideo: ${_flow.isVideo}');
    debugPrint('   - backgroundMusicId: ${_flow.backgroundMusicId}');

    return PreviewScreen(
      selectedPath: _flow.selectedPath,
      mediaPath: _flow.mediaPath,
      category: _flow.sytCategory,
      caption: _flow.caption,
      isVideo: _flow.isVideo,
      thumbnailPath: _flow.thumbnailPath,
      hashtags: _flow.hashtags,
      backgroundMusicId: _flow.backgroundMusicId,
      onUploadComplete: _onUploadComplete,
      onBack: _previousStep,
    );
  }

  /// Show validation error screen
  Widget _buildValidationErrorScreen(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _previousStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF701CF5),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: const Text(
              'Go Back',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
