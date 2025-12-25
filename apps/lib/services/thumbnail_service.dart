import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class ThumbnailService {
  static final ThumbnailService _instance = ThumbnailService._internal();

  factory ThumbnailService() => _instance;

  ThumbnailService._internal();

  /// Generate thumbnail from video file
  /// Returns the path to the generated thumbnail image
  /// Returns null if generation fails
  Future<String?> generateThumbnail({
    required String videoPath,
    int maxWidth = 640,
    int maxHeight = 480,
    int quality = 75,
    int timeMs = 0, // Frame at 0ms (start of video)
  }) async {
    try {
      print('🎬 Generating thumbnail from: $videoPath');

      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
        timeMs: timeMs,
      );

      if (thumbnailPath != null && File(thumbnailPath).existsSync()) {
        print('✅ Thumbnail generated successfully: $thumbnailPath');
        return thumbnailPath;
      } else {
        print('⚠️ Thumbnail generation returned null or file not found');
        return null;
      }
    } catch (e) {
      print('❌ Error generating thumbnail: $e');
      return null;
    }
  }

  /// Generate multiple thumbnails at different timestamps
  /// Useful for letting user choose from multiple frames
  Future<List<String>> generateMultipleThumbnails({
    required String videoPath,
    List<int> timeMs = const [0, 1000, 2000, 3000],
    int maxWidth = 320,
    int maxHeight = 240,
    int quality = 70,
  }) async {
    try {
      print('🎬 Generating ${timeMs.length} thumbnails from: $videoPath');

      final List<String> thumbnails = [];

      for (int i = 0; i < timeMs.length; i++) {
        try {
          final thumbnailPath = await VideoThumbnail.thumbnailFile(
            video: videoPath,
            thumbnailPath: (await getTemporaryDirectory()).path,
            imageFormat: ImageFormat.JPEG,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            quality: quality,
            timeMs: timeMs[i],
          );

          if (thumbnailPath != null && File(thumbnailPath).existsSync()) {
            thumbnails.add(thumbnailPath);
            print('✅ Thumbnail $i generated: $thumbnailPath');
          }
        } catch (e) {
          print('⚠️ Failed to generate thumbnail at ${timeMs[i]}ms: $e');
          continue;
        }
      }

      print('✅ Generated ${thumbnails.length} thumbnails');
      return thumbnails;
    } catch (e) {
      print('❌ Error generating multiple thumbnails: $e');
      return [];
    }
  }

  /// Get video duration in milliseconds
  Future<int?> getVideoDuration(String videoPath) async {
    try {
      // VideoThumbnail doesn't directly return duration
      // You may need to use a different package like video_player to get duration
      return null;
    } catch (e) {
      print('Error getting video duration: $e');
      return null;
    }
  }

  /// Clean up temporary thumbnail files
  Future<void> cleanupThumbnails(List<String> thumbnailPaths) async {
    try {
      for (final path in thumbnailPaths) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          print('🗑️ Deleted temporary thumbnail: $path');
        }
      }
    } catch (e) {
      print('Error cleaning up thumbnails: $e');
    }
  }

  /// Clean up single thumbnail
  Future<void> cleanupThumbnail(String thumbnailPath) async {
    try {
      final file = File(thumbnailPath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ Deleted temporary thumbnail: $thumbnailPath');
      }
    } catch (e) {
      print('Error cleaning up thumbnail: $e');
    }
  }
}
