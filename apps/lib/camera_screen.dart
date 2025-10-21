import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'upload_content_screen.dart';

class CameraScreen
    extends
        StatefulWidget {
  final String
  selectedPath; // 'reels' or 'SYT'

  const CameraScreen({
    super.key,
    required this.selectedPath,
  });

  @override
  State<
    CameraScreen
  >
  createState() => _CameraScreenState();
}

class _CameraScreenState
    extends
        State<
          CameraScreen
        > {
  CameraController?
  _cameraController;
  List<
    CameraDescription
  >?
  _cameras;
  bool
  isRecording = false;
  FlashMode
  _flashMode = FlashMode.off;
  bool
  isFrontCamera = false;
  bool
  _isCameraInitialized = false;
  String?
  _lastImagePath;
  bool
  _isVideoMode = false;

  @override
  void
  initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void
  dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _initializeCamera() async {
    // Request camera permission
    final cameraPermission = await Permission.camera.request();
    if (cameraPermission !=
        PermissionStatus.granted) {
      // Handle permission denied
      return;
    }

    // Get available cameras
    _cameras = await availableCameras();
    if (_cameras!.isEmpty) return;

    // Initialize camera controller
    _cameraController = CameraController(
      _cameras![isFrontCamera
          ? 1
          : 0],
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _cameraController!.initialize();
      setState(
        () {
          _isCameraInitialized = true;
        },
      );
    } catch (
      e
    ) {
      debugPrint(
        'Error initializing camera: $e',
      );
    }
  }

  Future<
    void
  >
  _switchCamera() async {
    if (_cameras ==
            null ||
        _cameras!.length <
            2) {
      return;
    }

    setState(
      () {
        isFrontCamera = !isFrontCamera;
        _isCameraInitialized = false;
      },
    );

    await _cameraController?.dispose();

    _cameraController = CameraController(
      _cameras![isFrontCamera
          ? 1
          : 0],
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _cameraController!.initialize();
      setState(
        () {
          _isCameraInitialized = true;
        },
      );
    } catch (
      e
    ) {
      debugPrint(
        'Error switching camera: $e',
      );
    }
  }

  Future<
    void
  >
  _toggleFlash() async {
    if (_cameraController ==
        null) {
      return;
    }

    setState(
      () {
        _flashMode =
            _flashMode ==
                FlashMode.off
            ? FlashMode.torch
            : FlashMode.off;
      },
    );

    await _cameraController!.setFlashMode(
      _flashMode,
    );
  }

  Future<
    void
  >
  _takePicture() async {
    if (_cameraController ==
            null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      setState(
        () {
          _lastImagePath = image.path;
        },
      );

      // Haptic feedback
      HapticFeedback.mediumImpact();

      // Navigate to upload screen with the captured image
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (
                  context,
                ) => UploadContentScreen(
                  selectedPath: widget.selectedPath,
                  mediaPath: image.path,
                  isVideo: false,
                ),
          ),
        );
      }
    } catch (
      e
    ) {
      debugPrint(
        'Error taking picture: $e',
      );
    }
  }

  Future<
    void
  >
  _startVideoRecording() async {
    if (_cameraController ==
            null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      await _cameraController!.startVideoRecording();
      setState(
        () {
          isRecording = true;
        },
      );

      // Haptic feedback
      HapticFeedback.mediumImpact();
    } catch (
      e
    ) {
      debugPrint(
        'Error starting video recording: $e',
      );
    }
  }

  Future<
    void
  >
  _stopVideoRecording() async {
    if (_cameraController ==
            null ||
        !isRecording) {
      return;
    }

    try {
      final XFile video = await _cameraController!.stopVideoRecording();
      setState(
        () {
          isRecording = false;
        },
      );

      // Haptic feedback
      HapticFeedback.mediumImpact();

      // Navigate to upload screen with the recorded video
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (
                  context,
                ) => UploadContentScreen(
                  selectedPath: widget.selectedPath,
                  mediaPath: video.path,
                  isVideo: true,
                ),
          ),
        );
      }
    } catch (
      e
    ) {
      debugPrint(
        'Error stopping video recording: $e',
      );
      setState(
        () {
          isRecording = false;
        },
      );
    }
  }

  void
  _toggleRecordingMode() {
    setState(
      () {
        _isVideoMode = !_isVideoMode;
      },
    );
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          if (_isCameraInitialized &&
              _cameraController !=
                  null)
            Positioned.fill(
              child: CameraPreview(
                _cameraController!,
              ),
            )
          else
            // Loading or permission denied placeholder
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Top controls
          Positioned(
            top:
                MediaQuery.of(
                  context,
                ).padding.top +
                20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close button
                GestureDetector(
                  onTap: () => Navigator.pop(
                    context,
                  ),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                        alpha: 0.5,
                      ),
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
                    color: Colors.black.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    widget.selectedPath ==
                            'reels'
                        ? 'Reels'
                        : widget.selectedPath ==
                              'selfie_challenge'
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
                      color: Colors.black.withValues(
                        alpha: 0.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _flashMode ==
                              FlashMode.off
                          ? Icons.flash_off
                          : Icons.flash_on,
                      color:
                          _flashMode ==
                              FlashMode.off
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
            top:
                MediaQuery.of(
                  context,
                ).size.height *
                0.4,
            child: Column(
              children: [
                // Camera flip button
                GestureDetector(
                  onTap: _switchCamera,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                        alpha: 0.5,
                      ),
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

          // Recording indicator
          if (isRecording)
            Positioned(
              top:
                  MediaQuery.of(
                    context,
                  ).padding.top +
                  60,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
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
                    const SizedBox(
                      width: 6,
                    ),
                    const Text(
                      'REC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Mode toggle (Photo/Video)
          Positioned(
            bottom:
                MediaQuery.of(
                  context,
                ).padding.bottom +
                120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(
                      25,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_isVideoMode) _toggleRecordingMode();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: !_isVideoMode
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            'Photo',
                            style: TextStyle(
                              color: !_isVideoMode
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (!_isVideoMode) _toggleRecordingMode();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _isVideoMode
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            'Video',
                            style: TextStyle(
                              color: _isVideoMode
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom controls
          Positioned(
            bottom:
                MediaQuery.of(
                  context,
                ).padding.bottom +
                40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Recent photo thumbnail
                GestureDetector(
                  onTap: () {
                    // Open gallery or show recent photos
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: 0.3,
                        ),
                        width: 1,
                      ),
                    ),
                    child:
                        _lastImagePath !=
                            null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                            child: Image.file(
                              File(
                                _lastImagePath!,
                              ),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                ),

                // Capture button
                GestureDetector(
                  onTap: _isVideoMode
                      ? (isRecording
                            ? _stopVideoRecording
                            : _startVideoRecording)
                      : _takePicture,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isRecording
                            ? Colors.red
                            : Colors.white,
                        width: 4,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(
                        8,
                      ),
                      decoration: BoxDecoration(
                        color: _isVideoMode
                            ? (isRecording
                                  ? Colors.red
                                  : Colors.white)
                            : Colors.white,
                        shape:
                            _isVideoMode &&
                                isRecording
                            ? BoxShape.rectangle
                            : BoxShape.circle,
                        borderRadius:
                            _isVideoMode &&
                                isRecording
                            ? BorderRadius.circular(
                                8,
                              )
                            : null,
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
                      color: Colors.white.withValues(
                        alpha: 0.2,
                      ),
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
