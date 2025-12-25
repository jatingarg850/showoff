import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FilePersistenceService {
  static const String _videoDir = 'app_videos';
  static const String _tempDir = 'app_temp';

  /// Get the persistent app video directory
  static Future<Directory> _getVideoDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final videoDir = Directory(path.join(appDir.path, _videoDir));

    if (!await videoDir.exists()) {
      await videoDir.create(recursive: true);
    }

    return videoDir;
  }

  /// Get the temporary directory for app files
  static Future<Directory> _getTempDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final appTempDir = Directory(path.join(tempDir.path, _tempDir));

    if (!await appTempDir.exists()) {
      await appTempDir.create(recursive: true);
    }

    return appTempDir;
  }

  /// Copy video from temporary location to persistent storage
  /// Returns the new persistent file path
  static Future<String> persistVideoFile(String tempVideoPath) async {
    try {
      print('📹 Attempting to persist video from: $tempVideoPath');

      final sourceFile = File(tempVideoPath);

      // Check if source file exists
      if (!await sourceFile.exists()) {
        print('❌ Source file not found: $tempVideoPath');
        print('📹 Attempting to find alternative video file...');

        // Try to find the file in the temp directory
        final tempDir = await getTemporaryDirectory();
        final files = tempDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.mp4'))
            .toList();

        if (files.isNotEmpty) {
          // Sort by modification time, most recent first
          files.sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
          );

          final latestFile = files.first;
          print('📹 Found alternative video file: ${latestFile.path}');

          // Use the latest file instead
          return await persistVideoFile(latestFile.path);
        }

        throw Exception('Source video file not found: $tempVideoPath');
      }

      // Verify file has content
      final fileSize = await sourceFile.length();
      if (fileSize == 0) {
        throw Exception('Source video file is empty: $tempVideoPath');
      }

      print(
        '✅ Source file found, size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
      );

      // Get destination directory
      final videoDir = await _getVideoDirectory();

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'video_$timestamp.mp4';
      final destinationPath = path.join(videoDir.path, fileName);

      // Copy file to persistent location
      final destinationFile = await sourceFile.copy(destinationPath);

      print('✅ Video persisted: $destinationPath');
      return destinationFile.path;
    } catch (e) {
      print('❌ Error persisting video: $e');
      rethrow;
    }
  }

  /// Check if a video file exists and is accessible
  static Future<bool> videoFileExists(String videoPath) async {
    try {
      final file = File(videoPath);
      return await file.exists();
    } catch (e) {
      print('Error checking video file: $e');
      return false;
    }
  }

  /// Get file size in MB
  static Future<double> getVideoFileSizeMB(String videoPath) async {
    try {
      final file = File(videoPath);
      if (await file.exists()) {
        final bytes = await file.length();
        return bytes / (1024 * 1024);
      }
      return 0;
    } catch (e) {
      print('Error getting file size: $e');
      return 0;
    }
  }

  /// Delete a video file
  static Future<void> deleteVideoFile(String videoPath) async {
    try {
      final file = File(videoPath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ Deleted video file: $videoPath');
      }
    } catch (e) {
      print('Error deleting video file: $e');
    }
  }

  /// Clean up all temporary video files
  static Future<void> cleanupTempVideos() async {
    try {
      final tempDir = await _getTempDirectory();
      if (await tempDir.exists()) {
        final files = tempDir.listSync();
        for (final file in files) {
          if (file is File) {
            await file.delete();
            print('🗑️ Cleaned up temp file: ${file.path}');
          }
        }
      }
    } catch (e) {
      print('Error cleaning up temp videos: $e');
    }
  }

  /// Get list of all persisted videos
  static Future<List<String>> getPersistedVideos() async {
    try {
      final videoDir = await _getVideoDirectory();
      final files = videoDir.listSync();
      return files.whereType<File>().map((f) => f.path).toList();
    } catch (e) {
      print('Error getting persisted videos: $e');
      return [];
    }
  }

  /// Clean up old video files (keep only recent ones)
  static Future<void> cleanupOldVideos({int keepCount = 10}) async {
    try {
      final videoDir = await _getVideoDirectory();
      final files = videoDir.listSync();

      if (files.length > keepCount) {
        // Sort by modification time, oldest first
        final sortedFiles = files.whereType<File>().toList()
          ..sort(
            (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
          );

        // Delete oldest files
        final filesToDelete = sortedFiles.take(files.length - keepCount);
        for (final file in filesToDelete) {
          await file.delete();
          print('🗑️ Cleaned up old video: ${file.path}');
        }
      }
    } catch (e) {
      print('Error cleaning up old videos: $e');
    }
  }
}
