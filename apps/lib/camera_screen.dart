import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'upload_content_screen.dart';
import 'services/file_persistence_service.dart';

class CameraScreen extends StatefulWidget {
  final String selectedPath; // 'reels' or 'SYT'
  final String? backgroundMusicId;
  final Function(String mediaPath, bool isVideo)? onRecordingComplete;
  final VoidCallback? onSkip;

  const CameraScreen({
    super.key,
    required this.selectedPath,
    this.backgroundMusicId,
    this.onRecordingComplete,
    this.onSkip,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool isRecording = false;
  FlashMode _flashMode = FlashMode.off;
  bool isFrontCamera = false;
  bool _isCameraInitialized = false;

  // Check if this is selfie challenge mode
  bool get _isSelfieMode => widget.selectedPath == 'selfie_challenge';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    final cameraPermission = await Permission.camera.request();
    if (cameraPermission != PermissionStatus.granted) {
      // Handle permission denied
      return;
    }

    // Get available cameras
    _cameras = await availableCameras();
    if (_cameras!.isEmpty) return;

    // Initialize camera controller
    _cameraController = CameraController(
      _cameras![isFrontCamera ? 1 : 0],
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      return;
    }

    setState(() {
      isFrontCamera = !isFrontCamera;
      _isCameraInitialized = false;
    });

    await _cameraController?.dispose();

    _cameraController = CameraController(
      _cameras![isFrontCamera ? 1 : 0],
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Error switching camera: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) {
      return;
    }

    setState(() {
      _flashMode = _flashMode == FlashMode.off
          ? FlashMode.torch
          : FlashMode.off;
    });

    await _cameraController!.setFlashMode(_flashMode);
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();

      // Haptic feedback
      HapticFeedback.mediumImpact();

      // Use callback if provided (new flow), otherwise navigate (old flow)
      if (widget.onRecordingComplete != null) {
        widget.onRecordingComplete!(image.path, false);
      } else if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadContentScreen(
              selectedPath: widget.selectedPath,
              mediaPath: image.path,
              isVideo: false,
              backgroundMusicId: widget.backgroundMusicId,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _startVideoRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        isRecording = true;
      });

      // Haptic feedback
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error starting video recording: $e');
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_cameraController == null || !isRecording) {
      return;
    }

    try {
      setState(() {
        isRecording = false;
      });

      // Haptic feedback
      HapticFeedback.mediumImpact();

      print('⏹️ Stopping video recording...');

      // Store the video path before stopping
      String? videoPath;

      // Add timeout to prevent hanging
      try {
        final video = await _cameraController!.stopVideoRecording().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('⚠️ Video recording stop timed out');
            throw Exception('Video recording stop timed out');
          },
        );
        videoPath = video.path;
        print('✅ Video recording stopped, path: $videoPath');
      } catch (stopError) {
        print('⚠️ Error during stop: $stopError');
        // Try to recover the video file from cache
        videoPath = await _recoverVideoFromCache();
        if (videoPath == null) {
          throw Exception(
            'Failed to stop recording and recover video: $stopError',
          );
        }
      }

      print('✅ Video recording stopped');

      // If we got the video file, persist it
      if (videoPath != null) {
        try {
          print('📹 Checking if video file exists: $videoPath');
          final videoFile = File(videoPath!);

          // Wait a bit for the file to be fully written
          await Future.delayed(const Duration(milliseconds: 500));

          final exists = await videoFile.exists();

          if (!exists) {
            print('❌ Video file not found at: $videoPath');
            // Try recovery one more time
            final recoveredPath = await _recoverVideoFromCache();
            if (recoveredPath != null) {
              videoPath = recoveredPath;
              print('✅ Recovered video from cache: $videoPath');
            } else {
              throw Exception('Video file not found: $videoPath');
            }
          }

          // Verify file has content
          final fileSize = await File(videoPath).length();
          if (fileSize == 0) {
            throw Exception('Video file is empty (0 bytes)');
          }
          print(
            '📹 Video file size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
          );

          print('📹 Persisting video file...');
          final persistedVideoPath =
              await FilePersistenceService.persistVideoFile(videoPath);
          print('✅ Video persisted to: $persistedVideoPath');

          // Use callback if provided (new flow), otherwise navigate (old flow)
          if (widget.onRecordingComplete != null) {
            widget.onRecordingComplete!(persistedVideoPath, true);
          } else if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadContentScreen(
                  selectedPath: widget.selectedPath,
                  mediaPath: persistedVideoPath,
                  isVideo: true,
                  backgroundMusicId: widget.backgroundMusicId,
                ),
              ),
            );
          }
        } catch (persistError) {
          print('❌ Error persisting video: $persistError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error saving video: $persistError'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('❌ Error stopping video recording: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving video: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Recover video file from cache directory
  Future<String?> _recoverVideoFromCache() async {
    try {
      print('📹 Attempting to recover video file from cache...');

      // Get the app's cache directory
      final cacheDir = await getTemporaryDirectory();

      if (await cacheDir.exists()) {
        final files = cacheDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.mp4'))
            .toList();

        if (files.isNotEmpty) {
          // Sort by modification time, most recent first
          files.sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
          );

          // Try each file starting with the most recent
          for (final file in files) {
            try {
              print('📹 Checking video file: ${file.path}');

              // Wait a bit for the file to be fully written
              await Future.delayed(const Duration(milliseconds: 100));

              final fileSize = await file.length();
              print(
                '📹 File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
              );

              if (fileSize > 1000) {
                // At least 1KB
                print('✅ Found valid video file: ${file.path}');
                return file.path;
              } else {
                print('⚠️ Video file too small: $fileSize bytes');
              }
            } catch (e) {
              print('⚠️ Error checking file: $e');
              continue;
            }
          }
        } else {
          print('⚠️ No MP4 files found in cache directory');
        }
      } else {
        print('⚠️ Cache directory does not exist');
      }
    } catch (e) {
      print('❌ Recovery failed: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(child: CameraPreview(_cameraController!))
          else
            // Loading or permission denied placeholder
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),

          // Top controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                // Path indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.selectedPath == 'Show'
                        ? 'Show'
                        : widget.selectedPath == 'selfie_challenge'
                        ? 'Daily Selfie'
                        : 'SYT',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Flash toggle
                GestureDetector(
                  onTap: _toggleFlash,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _flashMode == FlashMode.off
                          ? Icons.flash_off
                          : Icons.flash_on,
                      color: _flashMode == FlashMode.off
                          ? Colors.white
                          : Colors.yellow,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Side controls (right side)
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              children: [
                // Camera flip button
                GestureDetector(
                  onTap: _switchCamera,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flip_camera_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Recording/Photo mode indicator
          if (isRecording || _isSelfieMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _isSelfieMode ? Colors.blue : Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isSelfieMode ? 'PHOTO' : 'REC',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Recent photo thumbnail
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();

                    if (_isSelfieMode) {
                      // Pick image for selfie mode
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );

                      if (image != null) {
                        if (widget.onRecordingComplete != null) {
                          widget.onRecordingComplete!(image.path, false);
                        } else if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UploadContentScreen(
                                selectedPath: widget.selectedPath,
                                mediaPath: image.path,
                                isVideo: false,
                                backgroundMusicId: widget.backgroundMusicId,
                              ),
                            ),
                          );
                        }
                      }
                    } else {
                      // Pick video for reels/SYT mode
                      final XFile? video = await picker.pickVideo(
                        source: ImageSource.gallery,
                      );

                      if (video != null) {
                        if (widget.onRecordingComplete != null) {
                          widget.onRecordingComplete!(video.path, true);
                        } else if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UploadContentScreen(
                                selectedPath: widget.selectedPath,
                                mediaPath: video.path,
                                isVideo: true,
                                backgroundMusicId: widget.backgroundMusicId,
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _isSelfieMode ? Icons.photo_library : Icons.video_library,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                // Capture button
                GestureDetector(
                  onTap: () {
                    if (_isSelfieMode) {
                      debugPrint('📸 Selfie mode: Taking picture');
                      _takePicture();
                    } else {
                      if (isRecording) {
                        debugPrint('⏹️ Stopping video recording');
                        _stopVideoRecording();
                      } else {
                        debugPrint('🎥 Starting video recording');
                        _startVideoRecording();
                      }
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isRecording ? Colors.red : Colors.white,
                        width: 4,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isSelfieMode
                            ? Colors.white
                            : (isRecording ? Colors.red : Colors.white),
                        shape: _isSelfieMode
                            ? BoxShape.circle
                            : (isRecording
                                  ? BoxShape.rectangle
                                  : BoxShape.circle),
                        borderRadius: _isSelfieMode
                            ? null
                            : (isRecording ? BorderRadius.circular(8) : null),
                      ),
                    ),
                  ),
                ),

                // Camera switch button (duplicate for better UX)
                GestureDetector(
                  onTap: _switchCamera,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flip_camera_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
