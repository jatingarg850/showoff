import 'package:flutter/material.dart';

class SettingsScreen
    extends
        StatelessWidget {
  const SettingsScreen({
    super.key,
  });

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
          'Settings',
          style: TextStyle(
            color: Color(
              0xFF8B5CF6,
            ),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(
          20,
        ),
        children: [
          _buildSettingsItem(
            icon: Icons.person_outline,
            title: 'My Account',
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: Icons.credit_card_outlined,
            title: 'Payment Settings',
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notification',
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: Icons.wb_sunny_outlined,
            title: 'Subscriptions',
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: Icons.shield_outlined,
            title: 'Privacy and Safety',
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: Icons.card_giftcard_outlined,
            title: 'Referrals & Invites',
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: Icons.text_snippet_outlined,
            title: 'Terms & Condition',
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: Icons.info_outline,
            title: 'About App',
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: Icons.help_outline,
            title: 'Help and support',
            onTap: () {},
          ),
          const SizedBox(
            height: 20,
          ),
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Sign Out',
            isSignOut: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget
  _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSignOut = false,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 4,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSignOut
                    ? Colors.red
                    : Colors.black,
                size: 24,
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSignOut
                        ? Colors.red
                        : Colors.black,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
