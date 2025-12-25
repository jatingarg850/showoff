import 'dart:io';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class VideoAudioMergeService {
  static final VideoAudioMergeService _instance =
      VideoAudioMergeService._internal();

  late FlutterFFmpeg _flutterFFmpeg;

  factory VideoAudioMergeService() {
    return _instance;
  }

  VideoAudioMergeService._internal() {
    _flutterFFmpeg = FlutterFFmpeg();
  }

  /// Merge video with audio file
  /// Returns the path to the merged video file
  Future<String> mergeVideoWithAudio({
    required String videoPath,
    required String audioPath,
    String? outputFileName,
  }) async {
    try {
      print('🎬 Starting video-audio merge...');
      print('  - Video: $videoPath');
      print('  - Audio: $audioPath');

      // Validate input files exist
      final videoFile = File(videoPath);
      final audioFile = File(audioPath);

      if (!await videoFile.exists()) {
        throw Exception('Video file not found: $videoPath');
      }

      if (!await audioFile.exists()) {
        throw Exception('Audio file not found: $audioPath');
      }

      // Get temporary directory for output
      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/${outputFileName ?? 'merged_${DateTime.now().millisecondsSinceEpoch}.mp4'}';

      print('  - Output: $outputPath');

      // FFmpeg command to merge video and audio
      // -i video input
      // -i audio input
      // -c:v copy (copy video codec without re-encoding for speed)
      // -c:a aac (encode audio as AAC)
      // -shortest (use shortest stream length)
      final command =
          '-i "$videoPath" -i "$audioPath" -c:v copy -c:a aac -shortest "$outputPath"';

      print('🎬 Running FFmpeg command: $command');

      final result = await _flutterFFmpeg.execute(command);

      if (result == 0) {
        print('✅ Video-audio merge completed successfully');
        print('  - Output file: $outputPath');

        // Verify output file exists and has size
        final outputFile = File(outputPath);
        if (await outputFile.exists()) {
          final fileSize = await outputFile.length();
          print(
            '  - File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
          );
          return outputPath;
        } else {
          throw Exception('Output file was not created');
        }
      } else {
        throw Exception('FFmpeg merge failed with code: $result');
      }
    } catch (e) {
      print('❌ Error merging video and audio: $e');
      rethrow;
    }
  }

  /// Download audio from URL and merge with video
  /// Returns the path to the merged video file
  Future<String> mergeVideoWithAudioUrl({
    required String videoPath,
    required String audioUrl,
    String? outputFileName,
  }) async {
    try {
      print('🎵 Downloading audio from URL...');
      print('  - URL: $audioUrl');

      // Download audio file
      final tempDir = await getTemporaryDirectory();
      final audioFileName =
          'audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final audioPath = '${tempDir.path}/$audioFileName';

      final response = await http.get(Uri.parse(audioUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to download audio: ${response.statusCode}');
      }

      // Save audio file
      final audioFile = File(audioPath);
      await audioFile.writeAsBytes(response.bodyBytes);

      print('✅ Audio downloaded: $audioPath');
      print(
        '  - Size: ${(response.bodyBytes.length / 1024 / 1024).toStringAsFixed(2)} MB',
      );

      // Merge video with downloaded audio
      final mergedPath = await mergeVideoWithAudio(
        videoPath: videoPath,
        audioPath: audioPath,
        outputFileName: outputFileName,
      );

      // Clean up temporary audio file
      try {
        await audioFile.delete();
        print('🧹 Cleaned up temporary audio file');
      } catch (e) {
        print('⚠️ Error cleaning up audio file: $e');
      }

      return mergedPath;
    } catch (e) {
      print('❌ Error merging video with audio URL: $e');
      rethrow;
    }
  }

  /// Get FFmpeg version
  Future<String> getFFmpegVersion() async {
    try {
      // FlutterFFmpeg doesn't have getFFmpegVersion method
      // Just return a placeholder
      return 'FFmpeg available';
    } catch (e) {
      print('Error getting FFmpeg version: $e');
      return 'Unknown';
    }
  }

  /// Cancel ongoing FFmpeg operation
  Future<void> cancel() async {
    try {
      await _flutterFFmpeg.cancel();
      print('🛑 FFmpeg operation cancelled');
    } catch (e) {
      print('Error cancelling FFmpeg: $e');
    }
  }
}
