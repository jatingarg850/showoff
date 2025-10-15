import 'package:flutter/material.dart';

class NotificationSettingsScreen
    extends
        StatefulWidget {
  const NotificationSettingsScreen({
    super.key,
  });

  @override
  State<
    NotificationSettingsScreen
  >
  createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends
        State<
          NotificationSettingsScreen
        > {
  bool
  pushNotifications = true;
  bool
  emailNotifications = false;
  bool
  smsNotifications = true;
  bool
  referralNotifications = true;
  bool
  transactionNotifications = true;
  bool
  communityNotifications = false;
  bool
  marketingNotifications = false;

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
          'Notification',
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
              'General Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            _buildNotificationItem(
              'Push Notifications',
              'Receive notifications on your device',
              pushNotifications,
              (
                value,
              ) => setState(
                () => pushNotifications = value,
              ),
            ),

            _buildNotificationItem(
              'Email Notifications',
              'Receive notifications via email',
              emailNotifications,
              (
                value,
              ) => setState(
                () => emailNotifications = value,
              ),
            ),

            _buildNotificationItem(
              'SMS Notifications',
              'Receive notifications via SMS',
              smsNotifications,
              (
                value,
              ) => setState(
                () => smsNotifications = value,
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            const Text(
              'Activity Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            _buildNotificationItem(
              'Referral Notifications',
              'Get notified when someone uses your referral code',
              referralNotifications,
              (
                value,
              ) => setState(
                () => referralNotifications = value,
              ),
            ),

            _buildNotificationItem(
              'Transaction Notifications',
              'Get notified about wallet transactions',
              transactionNotifications,
              (
                value,
              ) => setState(
                () => transactionNotifications = value,
              ),
            ),

            _buildNotificationItem(
              'Community Notifications',
              'Get notified about community activities',
              communityNotifications,
              (
                value,
              ) => setState(
                () => communityNotifications = value,
              ),
            ),

            _buildNotificationItem(
              'Marketing Notifications',
              'Receive promotional offers and updates',
              marketingNotifications,
              (
                value,
              ) => setState(
                () => marketingNotifications = value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget
  _buildNotificationItem(
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
            activeColor: const Color(
              0xFF8B5CF6,
            ),
          ),
        ],
      ),
    );
  }
}
