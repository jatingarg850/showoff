import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';

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
  smsNotifications = false;
  bool
  referralNotifications = true;
  bool
  transactionNotifications = true;
  bool
  communityNotifications = false;
  bool
  marketingNotifications = false;
  bool
  _isLoading = true;

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
              null &&
          user['notificationSettings'] !=
              null) {
        final settings = user['notificationSettings'];
        setState(
          () {
            pushNotifications =
                settings['push'] ??
                true;
            emailNotifications =
                settings['email'] ??
                false;
            smsNotifications =
                settings['sms'] ??
                false;
            referralNotifications =
                settings['referral'] ??
                true;
            transactionNotifications =
                settings['transaction'] ??
                true;
            communityNotifications =
                settings['community'] ??
                false;
            marketingNotifications =
                settings['marketing'] ??
                false;
            _isLoading = false;
          },
        );
      } else {
        setState(
          () {
            _isLoading = false;
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error loading notification settings: $e',
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
    try {
      final response = await ApiService.updateNotificationSettings(
        push: pushNotifications,
        email: emailNotifications,
        sms: smsNotifications,
        referral: referralNotifications,
        transaction: transactionNotifications,
        community: communityNotifications,
        marketing: marketingNotifications,
      );

      if (response['success']) {
        // Update local storage
        final user = await StorageService.getUser();
        if (user !=
            null) {
          user['notificationSettings'] = {
            'push': pushNotifications,
            'email': emailNotifications,
            'sms': smsNotifications,
            'referral': referralNotifications,
            'transaction': transactionNotifications,
            'community': communityNotifications,
            'marketing': marketingNotifications,
          };
          await StorageService.saveUser(
            user,
          );
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Settings saved',
            ),
            backgroundColor: Colors.green,
            duration: Duration(
              seconds: 1,
            ),
          ),
        );
      }
    } catch (
      e
    ) {
      print(
        'Error saving notification settings: $e',
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
              ) {
                setState(
                  () => pushNotifications = value,
                );
                _saveSettings();
              },
            ),

            _buildNotificationItem(
              'Email Notifications',
              'Receive notifications via email',
              emailNotifications,
              (
                value,
              ) {
                setState(
                  () => emailNotifications = value,
                );
                _saveSettings();
              },
            ),

            _buildNotificationItem(
              'SMS Notifications',
              'Receive notifications via SMS',
              smsNotifications,
              (
                value,
              ) {
                setState(
                  () => smsNotifications = value,
                );
                _saveSettings();
              },
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
              ) {
                setState(
                  () => referralNotifications = value,
                );
                _saveSettings();
              },
            ),

            _buildNotificationItem(
              'Transaction Notifications',
              'Get notified about wallet transactions',
              transactionNotifications,
              (
                value,
              ) {
                setState(
                  () => transactionNotifications = value,
                );
                _saveSettings();
              },
            ),

            _buildNotificationItem(
              'Community Notifications',
              'Get notified about community activities',
              communityNotifications,
              (
                value,
              ) {
                setState(
                  () => communityNotifications = value,
                );
                _saveSettings();
              },
            ),

            _buildNotificationItem(
              'Marketing Notifications',
              'Receive promotional offers and updates',
              marketingNotifications,
              (
                value,
              ) {
                setState(
                  () => marketingNotifications = value,
                );
                _saveSettings();
              },
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
            activeThumbColor: const Color(
              0xFF8B5CF6,
            ),
          ),
        ],
      ),
    );
  }
}
