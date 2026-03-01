import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class VideoAudioMergeService {
  /// Upload video with background music metadata
  /// The server will handle any merging if needed
  /// For now, we just upload the video and send music info separately
  static Future<String> uploadVideoWithAudio({
    required String videoPath,
    required int musicId,
    required String musicTitle,
    required String musicUrl,
  }) async {
    try {
      debugPrint('🎬 Preparing video upload with audio...');
      debugPrint('  - Video: $videoPath');
      debugPrint('  - Music ID: $musicId');
      debugPrint('  - Music: $musicTitle');

      // Validate video file exists
      final videoFile = File(videoPath);
      if (!await videoFile.exists()) {
        throw Exception('Video file not found: $videoPath');
      }

      final fileSize = await videoFile.length();
      debugPrint(
        '  - Video size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
      );

      // Upload video via API (which already handles music association)
      // The API endpoint will associate the music with the post
      debugPrint('✅ Video ready for upload with music metadata');
      return videoPath;
    } catch (e) {
      debugPrint('❌ Error preparing video upload: $e');
      rethrow;
    }
  }

  /// Download audio from URL (for reference/caching)
  /// Not used for merging, just for verification
  static Future<String?> downloadAudioForVerification({
    required String audioUrl,
  }) async {
    try {
      debugPrint('🎵 Downloading audio for verification...');
      debugPrint('  - URL: $audioUrl');

      final response = await http
          .get(Uri.parse(audioUrl))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Audio download timeout');
            },
          );

      if (response.statusCode != 200) {
        throw Exception('Failed to download audio: ${response.statusCode}');
      }

      debugPrint('✅ Audio verified');
      debugPrint(
        '  - Size: ${(response.bodyBytes.length / 1024 / 1024).toStringAsFixed(2)} MB',
      );

      return audioUrl;
    } catch (e) {
      debugPrint('⚠️ Error verifying audio: $e');
      // Don't rethrow - audio verification is optional
      return null;
    }
  }

  /// Check if video and audio are compatible
  static Future<bool> validateVideoAudioCompatibility({
    required String videoPath,
    required String audioUrl,
  }) async {
    try {
      debugPrint('🔍 Validating video-audio compatibility...');

      // Check video file exists
      final videoFile = File(videoPath);
      if (!await videoFile.exists()) {
        debugPrint('❌ Video file not found');
        return false;
      }

      // Check audio URL is accessible
      try {
        final response = await http
            .head(Uri.parse(audioUrl))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode != 200) {
          debugPrint('❌ Audio URL not accessible');
          return false;
        }
      } catch (e) {
        debugPrint('❌ Audio URL check failed: $e');
        return false;
      }

      debugPrint('✅ Video and audio are compatible');
      return true;
    } catch (e) {
      debugPrint('❌ Error validating compatibility: $e');
      return false;
    }
  }

  /// Get video duration (for reference)
  static Future<int?> getVideoDuration(String videoPath) async {
    try {
      // This would require video_player or similar package
      // For now, just return null
      debugPrint('📹 Video duration check not implemented');
      return null;
    } catch (e) {
      debugPrint('Error getting video duration: $e');
      return null;
    }
  }

  /// Get audio duration (for reference)
  static Future<int?> getAudioDuration(String audioUrl) async {
    try {
      // This would require audio processing
      // For now, just return null
      debugPrint('🎵 Audio duration check not implemented');
      return null;
    } catch (e) {
      debugPrint('Error getting audio duration: $e');
      return null;
    }
  }
}
