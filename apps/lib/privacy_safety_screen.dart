import 'package:flutter/material.dart';

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
  twoFactorAuth = true;

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
              ) => setState(
                () => profileVisibility = value,
              ),
            ),

            _buildPrivacyItem(
              Icons.share,
              'Data Sharing',
              'Allow sharing of anonymized data for analytics',
              dataSharing,
              (
                value,
              ) => setState(
                () => dataSharing = value,
              ),
            ),

            _buildPrivacyItem(
              Icons.location_on,
              'Location Tracking',
              'Allow location-based features and recommendations',
              locationTracking,
              (
                value,
              ) => setState(
                () => locationTracking = value,
              ),
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
              ) => setState(
                () => twoFactorAuth = value,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            _buildActionButton(
              Icons.lock_reset,
              'Change Password',
              'Update your account password',
              () {
                // Handle change password
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
    showDialog(
      context: context,
      builder:
          (
            BuildContext context,
          ) {
            return AlertDialog(
              title: const Text(
                'Delete Account',
              ),
              content: const Text(
                'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
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
                    // Handle account deletion
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            );
          },
    );
  }
}
