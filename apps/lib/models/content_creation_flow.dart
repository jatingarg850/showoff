/// Unified content creation flow model
/// Handles the sequential flow: Record → Caption → Music → Thumbnail → Preview → Upload
class ContentCreationFlow {
  // Step 1: Recording
  String? mediaPath;
  bool isVideo = false;
  String selectedPath = ''; // 'reels', 'SYT', 'selfie_challenge'
  String? sytCategory;

  // Step 2: Caption
  String caption = '';
  List<String> hashtags = [];

  // Step 3: Music Selection
  String? backgroundMusicId;
  Map<String, dynamic>? selectedMusic;

  // Step 4: Thumbnail Selection
  String? thumbnailPath;

  // Step 5: Preview (all data combined)
  // All above data is used

  // Step 6: Upload
  bool isUploading = false;
  String? uploadError;

  ContentCreationFlow({required this.selectedPath, this.sytCategory});

  /// Check if we can proceed to next step
  bool canProceedToCaption() => mediaPath != null && mediaPath!.isNotEmpty;

  bool canProceedToMusic() => caption.isNotEmpty;

  bool canProceedToThumbnail() => backgroundMusicId != null || !isVideo;

  bool canProceedToPreview() => thumbnailPath != null || !isVideo;

  bool canUpload() => mediaPath != null && caption.isNotEmpty;

  /// Reset flow for new content
  void reset() {
    mediaPath = null;
    isVideo = false;
    caption = '';
    hashtags = [];
    backgroundMusicId = null;
    selectedMusic = null;
    thumbnailPath = null;
    isUploading = false;
    uploadError = null;
  }

  /// Get current step number (1-6)
  int getCurrentStep() {
    if (mediaPath == null) return 1; // Recording
    if (caption.isEmpty) return 2; // Caption
    if (backgroundMusicId == null && isVideo) return 3; // Music
    if (thumbnailPath == null && isVideo) return 4; // Thumbnail
    return 5; // Preview
  }

  /// Get step name
  String getStepName(int step) {
    switch (step) {
      case 1:
        return 'Record';
      case 2:
        return 'Caption';
      case 3:
        return 'Music';
      case 4:
        return 'Thumbnail';
      case 5:
        return 'Preview';
      case 6:
        return 'Upload';
      default:
        return 'Unknown';
    }
  }
}
