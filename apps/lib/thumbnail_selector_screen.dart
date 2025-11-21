import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'preview_screen.dart';

class ThumbnailSelectorScreen
    extends
        StatefulWidget {
  final String
  videoPath;
  final String
  selectedPath;
  final String
  caption;
  final List<
    String
  >
  hashtags;

  const ThumbnailSelectorScreen({
    super.key,
    required this.videoPath,
    required this.selectedPath,
    required this.caption,
    required this.hashtags,
  });

  @override
  State<
    ThumbnailSelectorScreen
  >
  createState() => _ThumbnailSelectorScreenState();
}

class _ThumbnailSelectorScreenState
    extends
        State<
          ThumbnailSelectorScreen
        > {
  VideoPlayerController?
  _videoController;
  final List<
    String
  >
  _thumbnailPaths = [];
  String?
  _selectedThumbnail;
  bool
  _isLoading = true;
  bool
  _isGenerating = false;

  @override
  void
  initState() {
    super.initState();
    _initializeVideo();
    _generateThumbnails();
  }

  Future<
    void
  >
  _initializeVideo() async {
    _videoController = VideoPlayerController.file(
      File(
        widget.videoPath,
      ),
    );
    await _videoController!.initialize();
    setState(
      () {},
    );
  }

  Future<
    void
  >
  _generateThumbnails() async {
    setState(
      () => _isGenerating = true,
    );

    try {
      final duration = await _getVideoDuration();

      // Generate 6 thumbnails at different timestamps
      final timestamps = [
        0,
        (duration *
                0.2)
            .toInt(),
        (duration *
                0.4)
            .toInt(),
        (duration *
                0.6)
            .toInt(),
        (duration *
                0.8)
            .toInt(),
        duration -
            1000, // Last frame (1 second before end)
      ];

      for (
        int i = 0;
        i <
            timestamps.length;
        i++
      ) {
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: widget.videoPath,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 640,
          quality: 75,
          timeMs: timestamps[i],
        );

        if (thumbnailPath !=
            null) {
          _thumbnailPaths.add(
            thumbnailPath,
          );
        }
      }

      // Auto-select the first thumbnail
      if (_thumbnailPaths.isNotEmpty) {
        _selectedThumbnail = _thumbnailPaths[0];
      }
    } catch (
      e
    ) {
      print(
        'Error generating thumbnails: $e',
      );
    }

    setState(
      () {
        _isLoading = false;
        _isGenerating = false;
      },
    );
  }

  Future<
    int
  >
  _getVideoDuration() async {
    if (_videoController !=
            null &&
        _videoController!.value.isInitialized) {
      return _videoController!.value.duration.inMilliseconds;
    }
    return 10000; // Default 10 seconds
  }

  Future<
    void
  >
  _captureCurrentFrame() async {
    if (_videoController ==
            null ||
        !_videoController!.value.isInitialized) {
      return;
    }

    setState(
      () => _isGenerating = true,
    );

    try {
      final currentPosition = _videoController!.value.position.inMilliseconds;

      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: widget.videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 640,
        quality: 75,
        timeMs: currentPosition,
      );

      if (thumbnailPath !=
          null) {
        setState(
          () {
            _thumbnailPaths.insert(
              0,
              thumbnailPath,
            );
            _selectedThumbnail = thumbnailPath;
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error capturing frame: $e',
      );
    }

    setState(
      () => _isGenerating = false,
    );
  }

  void
  _proceedToPreview() {
    if (_selectedThumbnail ==
        null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a thumbnail',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (
              context,
            ) => PreviewScreen(
              selectedPath: widget.selectedPath,
              mediaPath: widget.videoPath,
              caption: widget.caption,
              hashtags: widget.hashtags,
              isVideo: true,
              thumbnailPath: _selectedThumbnail,
            ),
      ),
    );
  }

  @override
  void
  dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
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
        title: ShaderMask(
          shaderCallback:
              (
                bounds,
              ) =>
                  const LinearGradient(
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
                  ).createShader(
                    bounds,
                  ),
          child: const Text(
            'Select Thumbnail',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Video preview
                if (_videoController !=
                        null &&
                    _videoController!.value.isInitialized)
                  Container(
                    height: 300,
                    color: Colors.black,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(
                            _videoController!,
                          ),
                        ),
                        // Play/Pause button
                        IconButton(
                          icon: Icon(
                            _videoController!.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            size: 64,
                            color: Colors.white.withOpacity(
                              0.8,
                            ),
                          ),
                          onPressed: () {
                            setState(
                              () {
                                _videoController!.value.isPlaying
                                    ? _videoController!.pause()
                                    : _videoController!.play();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                // Video progress bar
                if (_videoController !=
                        null &&
                    _videoController!.value.isInitialized)
                  VideoProgressIndicator(
                    _videoController!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Color(
                        0xFF701CF5,
                      ),
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.black12,
                    ),
                  ),

                const SizedBox(
                  height: 16,
                ),

                // Capture current frame button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating
                        ? null
                        : _captureCurrentFrame,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                          ),
                    label: Text(
                      _isGenerating
                          ? 'Capturing...'
                          : 'Capture Current Frame',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF701CF5,
                      ),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(
                        double.infinity,
                        48,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Text(
                    'Or select from auto-generated thumbnails:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                // Thumbnail grid
                Expanded(
                  child: _thumbnailPaths.isEmpty
                      ? const Center(
                          child: Text(
                            'No thumbnails available',
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _thumbnailPaths.length,
                          itemBuilder:
                              (
                                context,
                                index,
                              ) {
                                final thumbnailPath = _thumbnailPaths[index];
                                final isSelected =
                                    _selectedThumbnail ==
                                    thumbnailPath;

                                return GestureDetector(
                                  onTap: () {
                                    setState(
                                      () {
                                        _selectedThumbnail = thumbnailPath;
                                      },
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(
                                                0xFF701CF5,
                                              )
                                            : Colors.grey.shade300,
                                        width: isSelected
                                            ? 3
                                            : 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.file(
                                            File(
                                              thumbnailPath,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                          if (isSelected)
                                            Container(
                                              color:
                                                  const Color(
                                                    0xFF701CF5,
                                                  ).withOpacity(
                                                    0.3,
                                                  ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                  size: 32,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                        ),
                ),

                // Continue button
                Padding(
                  padding: const EdgeInsets.all(
                    20,
                  ),
                  child: ElevatedButton(
                    onPressed: _proceedToPreview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF701CF5,
                      ),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(
                        double.infinity,
                        56,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
