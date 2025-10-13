import 'package:flutter/material.dart';

class ProfileScreen
    extends
        StatelessWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            20,
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),

              // Profile header
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Icon(
                    Icons.settings,
                    color: Colors.grey,
                    size: 24,
                  ),
                ],
              ),

              const SizedBox(
                height: 30,
              ),

              // Profile picture and info
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(
                          0xFF701CF5,
                        ),
                        width: 3,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Text(
                    '@james9898',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Text(
                    'Content Creator',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 30,
              ),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    'Posts',
                    '127',
                  ),
                  _buildStatItem(
                    'Followers',
                    '2.5K',
                  ),
                  _buildStatItem(
                    'Following',
                    '180',
                  ),
                ],
              ),

              const SizedBox(
                height: 30,
              ),

              // Profile options
              Expanded(
                child: ListView(
                  children: [
                    _buildProfileOption(
                      Icons.person,
                      'Edit Profile',
                    ),
                    _buildProfileOption(
                      Icons.notifications,
                      'Notifications',
                    ),
                    _buildProfileOption(
                      Icons.privacy_tip,
                      'Privacy',
                    ),
                    _buildProfileOption(
                      Icons.help,
                      'Help & Support',
                    ),
                    _buildProfileOption(
                      Icons.info,
                      'About',
                    ),
                    _buildProfileOption(
                      Icons.logout,
                      'Logout',
                      isLogout: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget
  _buildStatItem(
    String label,
    String value,
  ) {
    return Column(
      children: [
        Text(
          value,
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
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget
  _buildProfileOption(
    IconData icon,
    String title, {
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout
              ? Colors.red
              : const Color(
                  0xFF701CF5,
                ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: isLogout
                ? Colors.red
                : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
        onTap: () {
          // Handle option tap
        },
      ),
    );
  }
}
