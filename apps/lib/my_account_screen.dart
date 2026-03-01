import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'set_password_screen.dart';

class MyAccountScreen
    extends
        StatefulWidget {
  const MyAccountScreen({
    super.key,
  });

  @override
  State<
    MyAccountScreen
  >
  createState() => _MyAccountScreenState();
}

class _MyAccountScreenState
    extends
        State<
          MyAccountScreen
        > {
  final TextEditingController
  _nameController = TextEditingController();
  final TextEditingController
  _emailController = TextEditingController();
  final TextEditingController
  _phoneController = TextEditingController();
  final TextEditingController
  _bioController = TextEditingController();

  bool
  _isLoading = true;
  bool
  _isSaving = false;
  File?
  _profileImage;
  String?
  _profilePictureUrl;
  Map<
    String,
    dynamic
  >?
  _userData;

  @override
  void
  initState() {
    super.initState();
    _loadUserData();
  }

  Future<
    void
  >
  _loadUserData() async {
    try {
      final user = await StorageService.getUser();
      if (user !=
          null) {
        setState(
          () {
            _userData = user;
            _nameController.text =
                user['displayName'] ??
                user['username'] ??
                '';
            _emailController.text =
                user['email'] ??
                '';
            _phoneController.text =
                user['phone'] ??
                '';
            _bioController.text =
                user['bio'] ??
                '';
            _profilePictureUrl = user['profilePicture'];
            _isLoading = false;
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error loading user data: $e',
      );
      setState(
        () {
          _isLoading = false;
        },
      );
    }
  }

  Future<
    void
  >
  _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image !=
          null) {
        setState(
          () {
            _profileImage = File(
              image.path,
            );
          },
        );
        await _uploadProfilePicture();
      }
    } catch (
      e
    ) {
      print(
        'Error picking image: $e',
      );
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
  }

  Future<
    void
  >
  _uploadProfilePicture() async {
    if (_profileImage ==
        null) {
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (
              context,
            ) => const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
      );

      final response = await ApiService.uploadProfilePicture(
        _profileImage!,
      );

      Navigator.pop(
        context,
      ); // Close loading dialog

      if (response['success']) {
        setState(
          () {
            _profilePictureUrl = response['data']['profilePicture'];
          },
        );

        // Update local storage
        final user = await StorageService.getUser();
        if (user !=
            null) {
          user['profilePicture'] = _profilePictureUrl;
          await StorageService.saveUser(
            user,
          );
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Profile picture updated!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (
      e
    ) {
      Navigator.pop(
        context,
      );
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
  }

  Future<
    void
  >
  _saveProfile() async {
    setState(
      () {
        _isSaving = true;
      },
    );

    try {
      final response = await ApiService.updateProfile(
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (response['success']) {
        // Update local storage
        final user = await StorageService.getUser();
        if (user !=
            null) {
          user['displayName'] = _nameController.text.trim();
          user['bio'] = _bioController.text.trim();
          user['phone'] = _phoneController.text.trim();
          await StorageService.saveUser(
            user,
          );
        }

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
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ??
                  'Failed to update profile',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (
      e
    ) {
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
    } finally {
      setState(
        () {
          _isSaving = false;
        },
      );
    }
  }

  Future<
    void
  >
  _downloadMyData() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (
              context,
            ) => const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Preparing your data...',
                  ),
                ],
              ),
            ),
      );

      final response = await ApiService.downloadUserData();

      Navigator.pop(
        context,
      );

      if (response['success']) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Data download link sent to your email!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (
      e
    ) {
      Navigator.pop(
        context,
      );
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
  }

  void
  _signOut() {
    final authProvider =
        Provider.of<
          AuthProvider
        >(
          context,
          listen: false,
        );
    authProvider.logout();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(
      '/login',
      (
        route,
      ) => false,
    );
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    if (_isLoading) {
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
            'My Account',
            style: TextStyle(
              color: Color(
                0xFF8B5CF6,
              ),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(
              0xFF8B5CF6,
            ),
          ),
        ),
      );
    }

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
          'My Account',
          style: TextStyle(
            color: Color(
              0xFF8B5CF6,
            ),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving
                ? null
                : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(
                        0xFF8B5CF6,
                      ),
                    ),
                  )
                : const Text(
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
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange,
                        Colors.yellow,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipOval(
                    child:
                        _profileImage !=
                            null
                        ? Image.file(
                            _profileImage!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : _profilePictureUrl !=
                              null
                        ? Image.network(
                            ApiService.getImageUrl(
                              _profilePictureUrl!,
                            ),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 60,
                                  );
                                },
                          )
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 60,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(
                        8,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(
                          0xFF8B5CF6,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 32,
            ),

            // Account Statistics
            Container(
              padding: const EdgeInsets.all(
                20,
              ),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFE9D5FF,
                ),
                borderRadius: BorderRadius.circular(
                  16,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    (_userData?['referralCount'] ??
                            0)
                        .toString(),
                    'Referrals',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[400],
                  ),
                  _buildStatColumn(
                    (_userData?['followersCount'] ??
                            0)
                        .toString(),
                    'Followers',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[400],
                  ),
                  _buildStatColumn(
                    (_userData?['followingCount'] ??
                            0)
                        .toString(),
                    'Following',
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            // Form Fields
            _buildInputField(
              'Full Name',
              _nameController,
              Icons.person,
            ),

            _buildInputField(
              'Email Address',
              _emailController,
              Icons.email,
            ),

            _buildInputField(
              'Phone Number',
              _phoneController,
              Icons.phone,
            ),

            _buildInputField(
              'Bio',
              _bioController,
              Icons.info,
              maxLines: 4,
            ),

            const SizedBox(
              height: 32,
            ),

            // Account Actions
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            _buildActionItem(
              Icons.lock,
              'Change Password',
              'Update your account password',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (
                          context,
                        ) => const SetPasswordScreen(),
                  ),
                );
              },
            ),

            _buildActionItem(
              Icons.verified_user,
              'Verify Account',
              'Verify your account for additional features',
              () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Account verification coming soon!',
                    ),
                    backgroundColor: Color(
                      0xFF8B5CF6,
                    ),
                  ),
                );
              },
            ),

            _buildActionItem(
              Icons.download,
              'Download My Data',
              'Download a copy of your account data',
              () {
                _downloadMyData();
              },
            ),

            _buildActionItem(
              Icons.logout,
              'Sign Out',
              'Sign out from your account',
              () {
                _showSignOutDialog();
              },
              isDestructive: true,
            ),

            const SizedBox(
              height: 32,
            ),

            Container(
              padding: const EdgeInsets.all(
                16,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(
                  12,
                ),
                border: Border.all(
                  color: Colors.grey[200]!,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _buildInfoRow(
                    'Username',
                    _userData?['username'] ??
                        'N/A',
                  ),
                  _buildInfoRow(
                    'Member Since',
                    _formatDate(
                      _userData?['createdAt'],
                    ),
                  ),
                  _buildInfoRow(
                    'Account Type',
                    _userData?['subscriptionTier'] ??
                        'Free',
                  ),
                  _buildInfoRow(
                    'Coin Balance',
                    '${_userData?['coinBalance'] ?? 0} coins',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget
  _buildStatColumn(
    String number,
    String label,
  ) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget
  _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(
                12,
              ),
              border: Border.all(
                color: Colors.grey[200]!,
              ),
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  icon,
                  color: const Color(
                    0xFF8B5CF6,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(
                  16,
                ),
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildActionItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          12,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            16,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(
              12,
            ),
            border: Border.all(
              color: Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(
                  8,
                ),
                decoration: BoxDecoration(
                  color:
                      (isDestructive
                              ? Colors.red
                              : const Color(
                                  0xFF8B5CF6,
                                ))
                          .withValues(
                            alpha: 0.1,
                          ),
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
                child: Icon(
                  icon,
                  color: isDestructive
                      ? Colors.red
                      : const Color(
                          0xFF8B5CF6,
                        ),
                  size: 20,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget
  _buildInfoRow(
    String label,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String
  _formatDate(
    String? dateString,
  ) {
    if (dateString ==
        null) {
      return 'N/A';
    }
    try {
      final date = DateTime.parse(
        dateString,
      );
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (
      e
    ) {
      return 'N/A';
    }
  }

  void
  _showSignOutDialog() {
    showDialog(
      context: context,
      builder:
          (
            BuildContext context,
          ) {
            return AlertDialog(
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'Are you sure you want to sign out of your account?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(
                    context,
                  ),
                  child: const Text(
                    'Cancel',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                    _signOut();
                  },
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
    );
  }

  @override
  void
  dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
