import 'package:flutter/material.dart';

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
  _nameController = TextEditingController(
    text: 'Sathon',
  );
  final TextEditingController
  _emailController = TextEditingController(
    text: 'sathon@example.com',
  );
  final TextEditingController
  _phoneController = TextEditingController(
    text: '+1 (555) 123-4567',
  );
  final TextEditingController
  _bioController = TextEditingController(
    text: 'Hi, How are you doing?Hi, How are you doing?Hi, How are you doing?Hi, How are you doing?Hi, How are you doing?Hi, How are you.',
  );

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
            onPressed: () {
              // Handle save changes
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Profile updated successfully!',
                  ),
                  backgroundColor: Color(
                    0xFF8B5CF6,
                  ),
                ),
              );
            },
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
                    child: Image.asset(
                      'assets/setup/coins.png',
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
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
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
                    '200',
                    'Subscribers',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[400],
                  ),
                  _buildStatColumn(
                    '16k',
                    'Followers',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[400],
                  ),
                  _buildStatColumn(
                    '978',
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
                // Handle change password
              },
            ),

            _buildActionItem(
              Icons.verified_user,
              'Verify Account',
              'Verify your account for additional features',
              () {
                // Handle verify account
              },
            ),

            _buildActionItem(
              Icons.download,
              'Download My Data',
              'Download a copy of your account data',
              () {
                // Handle download data
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
                    'Account ID',
                    'USR123456789',
                  ),
                  _buildInfoRow(
                    'Member Since',
                    'January 2025',
                  ),
                  _buildInfoRow(
                    'Account Type',
                    'Basic',
                  ),
                  _buildInfoRow(
                    'Last Login',
                    'Today, 9:41 AM',
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
                    // Handle sign out
                  },
                  child: const Text(
                    'Sign Out',
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
