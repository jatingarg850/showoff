import 'package:flutter/material.dart';
import 'preview_screen.dart';
import 'thumbnail_selector_screen.dart';
import 'services/file_persistence_service.dart';

class UploadContentScreen extends StatefulWidget {
  final String selectedPath; // 'reels' or 'SYT'
  final String? mediaPath; // Path to captured photo/video
  final bool isVideo; // Whether the media is a video
  final String? backgroundMusicId; // Background music ID
  final Function(String caption, List<String> hashtags)? onCaptionComplete;
  final VoidCallback? onBack;

  const UploadContentScreen({
    super.key,
    required this.selectedPath,
    this.mediaPath,
    this.isVideo = false,
    this.backgroundMusicId,
    this.onCaptionComplete,
    this.onBack,
  });

  @override
  State<UploadContentScreen> createState() => _UploadContentScreenState();
}

class _UploadContentScreenState extends State<UploadContentScreen> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF701CF5), Color(0xFF3E98E4)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            'Upload your content',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // Caption Section
            const Text(
              'Caption',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            // Caption Text Area
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF701CF5), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _captionController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Write something about yourself',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),

            const Spacer(),

            // Preview Button
            Center(
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
                    // Validate caption
                    if (_captionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please add a caption'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    // Validate video file exists before proceeding
                    if (widget.isVideo && widget.mediaPath != null) {
                      final fileExists =
                          await FilePersistenceService.videoFileExists(
                            widget.mediaPath!,
                          );
                      if (!fileExists) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Video file not found. Please record again.',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }
                    }

                    // Extract hashtags from caption
                    final hashtags = _extractHashtags(_captionController.text);

                    // Use callback if provided (new flow), otherwise navigate (old flow)
                    if (widget.onCaptionComplete != null) {
                      widget.onCaptionComplete!(
                        _captionController.text,
                        hashtags,
                      );
                    } else {
                      // For videos, go to thumbnail selector first
                      if (widget.isVideo) {
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ThumbnailSelectorScreen(
                                videoPath: widget.mediaPath!,
                                selectedPath: widget.selectedPath,
                                caption: _captionController.text,
                                hashtags: hashtags,
                                backgroundMusicId: widget.backgroundMusicId,
                              ),
                            ),
                          );
                        }
                      } else {
                        // For images, go directly to preview
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PreviewScreen(
                                selectedPath: widget.selectedPath,
                                mediaPath: widget.mediaPath,
                                category: null,
                                caption: _captionController.text,
                                isVideo: widget.isVideo,
                                backgroundMusicId: widget.backgroundMusicId,
                              ),
                            ),
                          );
                        }
                      }
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
                    'Preview',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Extract hashtags from caption text
  List<String> _extractHashtags(String text) {
    final RegExp hashtagRegex = RegExp(r'#\w+');
    final matches = hashtagRegex.allMatches(text);
    return matches.map((m) => m.group(0)!).toList();
  }
}
