import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';

class EditProfileScreen
    extends
        StatefulWidget {
  const EditProfileScreen({
    super.key,
  });

  @override
  State<
    EditProfileScreen
  >
  createState() => _EditProfileScreenState();
}

class _EditProfileScreenState
    extends
        State<
          EditProfileScreen
        > {
  final TextEditingController
  _displayNameController = TextEditingController();
  final TextEditingController
  _bioController = TextEditingController();
  final ImagePicker
  _picker = ImagePicker();

  File?
  _selectedImage;
  String?
  _currentProfilePicture;
  bool
  _isLoading = false;
  bool
  _hasChanges = false;

  @override
  void
  initState() {
    super.initState();
    _loadUserData();
  }

  void
  _loadUserData() {
    final authProvider =
        Provider.of<
          AuthProvider
        >(
          context,
          listen: false,
        );
    final user = authProvider.user;

    if (user !=
        null) {
      _displayNameController.text =
          user['displayName'] ??
          '';
      _bioController.text =
          user['bio'] ??
          '';
      _currentProfilePicture = user['profilePicture'];
    }
  }

  Future<
    void
  >
  _pickImage() async {
    try {
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
            _hasChanges = true;
          },
        );
      }
    } catch (
      e
    ) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Error picking image: $e',
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
  _removeProfilePicture() async {
    setState(
      () {
        _selectedImage = null;
        _currentProfilePicture = null;
        _hasChanges = true;
      },
    );
  }

  Future<
    void
  >
  _saveProfile() async {
    if (!_hasChanges &&
        _selectedImage ==
            null) {
      Navigator.pop(
        context,
      );
      return;
    }

    setState(
      () => _isLoading = true,
    );

    try {
      final authProvider =
          Provider.of<
            AuthProvider
          >(
            context,
            listen: false,
          );

      // Update profile picture if changed
      if (_selectedImage !=
          null) {
        final response = await ApiService.uploadProfilePicture(
          _selectedImage!,
        );
        if (!response['success']) {
          throw Exception(
            response['message'] ??
                'Failed to upload profile picture',
          );
        }
      } else if (_currentProfilePicture ==
              null &&
          authProvider.user?['profilePicture'] !=
              null) {
        // User removed profile picture - we need an API endpoint for this
        // For now, we'll just update other fields
      }

      // Update display name and bio
      final updateResponse = await ApiService.updateProfile(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (updateResponse['success']) {
        // Refresh user data
        await authProvider.refreshUser();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'Profile updated successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(
            context,
          );
        }
      } else {
        throw Exception(
          updateResponse['message'] ??
              'Failed to update profile',
        );
      }
    } catch (
      e
    ) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(
          () => _isLoading = false,
        );
      }
    }
  }

  @override
  void
  dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
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
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(
                  16.0,
                ),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Color(
                    0xFF8B5CF6,
                  ),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child:
                          _selectedImage !=
                              null
                          ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            )
                          : _currentProfilePicture !=
                                    null &&
                                _currentProfilePicture!.isNotEmpty
                          ? Image.network(
                              ApiService.getImageUrl(
                                _currentProfilePicture!,
                              ),
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.orange,
                                            Colors.yellow,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 60,
                                      ),
                                    );
                                  },
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange,
                                    Colors.yellow,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                    ),
                  ),

                  // Edit button
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF8B5CF6,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  // Remove button (only show if there's a profile picture)
                  if (_currentProfilePicture !=
                          null ||
                      _selectedImage !=
                          null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _removeProfilePicture,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              'Tap to change profile picture',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(
              height: 40,
            ),

            // Display Name Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Display Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your display name',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged:
                      (
                        value,
                      ) {
                        setState(
                          () => _hasChanges = true,
                        );
                      },
                ),
              ],
            ),

            const SizedBox(
              height: 24,
            ),

            // Bio Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextField(
                  controller: _bioController,
                  maxLines: 4,
                  maxLength: 150,
                  decoration: InputDecoration(
                    hintText: 'Tell us about yourself...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged:
                      (
                        value,
                      ) {
                        setState(
                          () => _hasChanges = true,
                        );
                      },
                ),
              ],
            ),

            const SizedBox(
              height: 40,
            ),

            // Save Button (also at bottom)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF8B5CF6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      28,
                    ),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
