import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'display_name_screen.dart';

class ProfilePictureScreen
    extends
        StatefulWidget {
  const ProfilePictureScreen({
    super.key,
  });

  @override
  State<
    ProfilePictureScreen
  >
  createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState
    extends
        State<
          ProfilePictureScreen
        > {
  File?
  _selectedImage;
  final ImagePicker
  _picker = ImagePicker();

  Future<
    bool
  >
  _requestPermissions(
    Permission permission,
  ) async {
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    }

    final result = await permission.request();
    return result.isGranted;
  }

  Future<
    void
  >
  _pickImageFromGallery() async {
    try {
      // Request storage permission
      bool hasPermission;
      if (Platform.isAndroid) {
        if (await Permission.photos.status.isGranted) {
          hasPermission = true;
        } else {
          hasPermission = await _requestPermissions(
            Permission.photos,
          );
        }
      } else {
        hasPermission = await _requestPermissions(
          Permission.photos,
        );
      }

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'Photo library permission is required',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image !=
          null) {
        setState(
          () {
            _selectedImage = File(
              image.path,
            );
          },
        );
      }
    } catch (
      e
    ) {
      debugPrint(
        'Error picking image from gallery: $e',
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to pick image: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<
    void
  >
  _takePhoto() async {
    try {
      // Request camera permission
      final hasPermission = await _requestPermissions(
        Permission.camera,
      );

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'Camera permission is required',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image !=
          null) {
        setState(
          () {
            _selectedImage = File(
              image.path,
            );
          },
        );
      }
    } catch (
      e
    ) {
      debugPrint(
        'Error taking photo: $e',
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to take photo: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void
  _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            20,
          ),
        ),
      ),
      builder:
          (
            BuildContext context,
          ) {
            return Container(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Image Source',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.camera_alt,
                      color: Color(
                        0xFF701CF5,
                      ),
                    ),
                    title: const Text(
                      'Camera',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                      );
                      _takePhoto();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library,
                      color: Color(
                        0xFF3E98E4,
                      ),
                    ),
                    title: const Text(
                      'Gallery',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                      );
                      _pickImageFromGallery();
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            );
          },
    );
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
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(
                  4,
                ),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.0, // 0% progress (1 of 4 steps)
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF701CF5,
                    ),
                    borderRadius: BorderRadius.circular(
                      4,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            // Title
            const Text(
              'Profile Picture',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            // Underline
            Container(
              margin: const EdgeInsets.only(
                top: 8,
                bottom: 16,
              ),
              height: 3,
              width: 140,
              decoration: BoxDecoration(
                color: const Color(
                  0xFF701CF5,
                ),
                borderRadius: BorderRadius.circular(
                  2,
                ),
              ),
            ),

            // Subtitle
            const Text(
              'Upload a picture of yourself',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 60,
            ),

            // Profile picture placeholder/preview
            Center(
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        _selectedImage ==
                            null
                        ? const LinearGradient(
                            colors: [
                              Color(
                                0xFF701CF5,
                              ), // Purple
                              Color(
                                0xFF3E98E4,
                              ), // Blue
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    border:
                        _selectedImage !=
                            null
                        ? Border.all(
                            color: const Color(
                              0xFF701CF5,
                            ),
                            width: 4,
                          )
                        : null,
                  ),
                  child:
                      _selectedImage ==
                          null
                      ? const Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.white,
                          ),
                        )
                      : ClipOval(
                          child: Image.file(
                            _selectedImage!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(
              height: 60,
            ),

            // Take a photo button
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(
                bottom: 16,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: _takePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(
                    0xFF701CF5,
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.camera_alt,
                  color: Color(
                    0xFF701CF5,
                  ),
                ),
                label: const Text(
                  'Take a photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(
                      0xFF701CF5,
                    ),
                  ),
                ),
              ),
            ),

            // Choose from gallery button
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(
                bottom: 60,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: _pickImageFromGallery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(
                    0xFF3E98E4,
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons.photo_library,
                  color: Color(
                    0xFF3E98E4,
                  ),
                ),
                label: const Text(
                  'Choose from gallery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(
                      0xFF3E98E4,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Continue button
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(
                bottom: 40,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF701CF5,
                ),
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (
                            context,
                          ) => const DisplayNameScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
