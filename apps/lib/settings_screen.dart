import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'subscription_screen.dart';
import 'referrals_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_safety_screen.dart';
import 'terms_conditions_screen.dart';
import 'about_app_screen.dart';
import 'help_support_screen.dart';
import 'payment_settings_screen.dart';
import 'my_account_screen.dart';
import 'providers/auth_provider.dart';
import 'onboarding_screen.dart';

class SettingsScreen
    extends
        StatelessWidget {
  const SettingsScreen({
    super.key,
  });

  void
  _showLogoutDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder:
          (
            BuildContext context,
          ) {
            return AlertDialog(
              title: const Text(
                'Logout',
              ),
              content: const Text(
                'Are you sure you want to logout?',
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
                  onPressed: () async {
                    final authProvider =
                        Provider.of<
                          AuthProvider
                        >(
                          context,
                          listen: false,
                        );
                    await authProvider.logout();

                    if (!context.mounted) return;

                    Navigator.of(
                      context,
                    ).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder:
                            (
                              _,
                            ) => const OnboardingScreen(),
                      ),
                      (
                        route,
                      ) => false,
                    );
                  },
                  child: const Text(
                    'Logout',
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const MyAccountScreen(),
                ),
              );
            },
          ),
          _buildSettingsItem(
            icon: Icons.credit_card_outlined,
            title: 'Payment Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const PaymentSettingsScreen(),
                ),
              );
            },
          ),
          _buildSettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notification',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          _buildSettingsItem(
            icon: Icons.wb_sunny_outlined,
            title: 'Subscriptions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const SubscriptionScreen(),
                ),
              );
            },
          ),
          _buildSettingsItem(
            icon: Icons.shield_outlined,
            title: 'Privacy and Safety',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const PrivacySafetyScreen(),
                ),
              );
            },
          ),
          _buildSettingsItem(
            icon: Icons.card_giftcard_outlined,
            title: 'Referrals & Invites',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const ReferralsScreen(),
                ),
              );
            },
          ),
          _buildSettingsItem(
            icon: Icons.text_snippet_outlined,
            title: 'Terms & Condition',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const TermsConditionsScreen(),
                ),
              );
            },
          ),
          _buildSettingsItem(
            icon: Icons.info_outline,
            title: 'About App',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const AboutAppScreen(),
                ),
              );
            },
          ),
          _buildSettingsItem(
            icon: Icons.help_outline,
            title: 'Help and support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const HelpSupportScreen(),
                ),
              );
            },
          ),
          const SizedBox(
            height: 20,
          ),
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Sign Out',
            isSignOut: true,
            onTap: () => _showLogoutDialog(
              context,
            ),
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
