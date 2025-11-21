import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'set_password_screen.dart';

class PrivacySafetyScreen
    extends
        StatefulWidget {
  const PrivacySafetyScreen({
    super.key,
  });

  @override
  State<
    PrivacySafetyScreen
  >
  createState() => _PrivacySafetyScreenState();
}

class _PrivacySafetyScreenState
    extends
        State<
          PrivacySafetyScreen
        > {
  bool
  profileVisibility = true;
  bool
  dataSharing = false;
  bool
  locationTracking = false;
  bool
  twoFactorAuth = false;
  bool
  _isLoading = true;
  bool
  _isSaving = false;

  @override
  void
  initState() {
    super.initState();
    _loadSettings();
  }

  Future<
    void
  >
  _loadSettings() async {
    try {
      final user = await StorageService.getUser();
      if (user !=
          null) {
        setState(
          () {
            profileVisibility =
                user['profileVisibility'] ??
                true;
            dataSharing =
                user['dataSharing'] ??
                false;
            locationTracking =
                user['locationTracking'] ??
                false;
            twoFactorAuth =
                user['twoFactorAuth'] ??
                false;
            _isLoading = false;
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error loading settings: $e',
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
  _saveSettings() async {
    setState(
      () {
        _isSaving = true;
      },
    );

    try {
      final response = await ApiService.updatePrivacySettings(
        profileVisibility: profileVisibility,
        dataSharing: dataSharing,
        locationTracking: locationTracking,
        twoFactorAuth: twoFactorAuth,
      );

      if (response['success']) {
        // Update local storage
        final user = await StorageService.getUser();
        if (user !=
            null) {
          user['profileVisibility'] = profileVisibility;
          user['dataSharing'] = dataSharing;
          user['locationTracking'] = locationTracking;
          user['twoFactorAuth'] = twoFactorAuth;
          await StorageService.saveUser(
            user,
          );
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Settings saved successfully',
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
                  'Failed to save settings',
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
            'Privacy and Safety',
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
          'Privacy and Safety',
          style: TextStyle(
            color: Color(
              0xFF8B5CF6,
            ),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            _buildPrivacyItem(
              Icons.visibility,
              'Profile Visibility',
              'Make your profile visible to other users',
              profileVisibility,
              (
                value,
              ) {
                setState(
                  () => profileVisibility = value,
                );
                _saveSettings();
              },
            ),

            _buildPrivacyItem(
              Icons.share,
              'Data Sharing',
              'Allow sharing of anonymized data for analytics',
              dataSharing,
              (
                value,
              ) {
                setState(
                  () => dataSharing = value,
                );
                _saveSettings();
              },
            ),

            _buildPrivacyItem(
              Icons.location_on,
              'Location Tracking',
              'Allow location-based features and recommendations',
              locationTracking,
              (
                value,
              ) {
                setState(
                  () => locationTracking = value,
                );
                _saveSettings();
              },
            ),

            const SizedBox(
              height: 32,
            ),

            const Text(
              'Security Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            _buildPrivacyItem(
              Icons.security,
              'Two-Factor Authentication',
              'Add an extra layer of security to your account',
              twoFactorAuth,
              (
                value,
              ) {
                setState(
                  () => twoFactorAuth = value,
                );
                _saveSettings();
              },
            ),

            const SizedBox(
              height: 24,
            ),

            _buildActionButton(
              Icons.lock_reset,
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

            _buildActionButton(
              Icons.delete_forever,
              'Delete Account',
              'Permanently delete your account and all data',
              () {
                _showDeleteAccountDialog();
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
                color: const Color(
                  0xFFE9D5FF,
                ),
                borderRadius: BorderRadius.circular(
                  12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Privacy Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'We take your privacy seriously. Your personal information is encrypted and stored securely. We never share your data with third parties without your explicit consent.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
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
  _buildPrivacyItem(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(
      bool,
    )
    onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
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
                  const Color(
                    0xFF8B5CF6,
                  ).withValues(
                    alpha: 0.1,
                  ),
              borderRadius: BorderRadius.circular(
                8,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(
              0xFF8B5CF6,
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildActionButton(
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

  void
  _showDeleteAccountDialog() {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (
            BuildContext dialogContext,
          ) {
            return AlertDialog(
              title: const Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
                    style: TextStyle(
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Text(
                    'Enter your password to confirm:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(
                    dialogContext,
                  ),
                  child: const Text(
                    'Cancel',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final password = passwordController.text.trim();
                    if (password.isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter your password',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                    );
                    await _deleteAccount(
                      password,
                    );
                  },
                  child: const Text(
                    'Delete',
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

  Future<
    void
  >
  _deleteAccount(
    String password,
  ) async {
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

    try {
      final response = await ApiService.deleteAccount(
        password,
      );

      Navigator.pop(
        context,
      ); // Close loading dialog

      if (response['success']) {
        // Clear local storage
        await StorageService.clearAll();

        // Update auth provider
        final authProvider =
            Provider.of<
              AuthProvider
            >(
              context,
              listen: false,
            );
        authProvider.logout();

        // Show success message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Account deleted successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login screen
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(
          '/login',
          (
            route,
          ) => false,
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ??
                  'Failed to delete account',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (
      e
    ) {
      Navigator.pop(
        context,
      ); // Close loading dialog
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
}
