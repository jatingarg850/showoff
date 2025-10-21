import 'package:flutter/material.dart';

class NotificationScreen
    extends
        StatefulWidget {
  const NotificationScreen({
    super.key,
  });

  @override
  State<
    NotificationScreen
  >
  createState() => _NotificationScreenState();
}

class _NotificationScreenState
    extends
        State<
          NotificationScreen
        > {
  List<
    Map<
      String,
      dynamic
    >
  >
  notifications = [
    {
      'type': 'like',
      'username': 'maria_dance',
      'displayName': 'Maria Rodriguez',
      'message': 'liked your reel',
      'time': '2 minutes ago',
      'isRead': false,
      'avatar': 'assets/profile/avatar1.png',
    },
    {
      'type': 'comment',
      'username': 'alex_mountain',
      'displayName': 'Alex Johnson',
      'message': 'commented on your reel: "Amazing shot! 🔥"',
      'time': '5 minutes ago',
      'isRead': false,
      'avatar': 'assets/profile/avatar2.png',
    },
    {
      'type': 'follow',
      'username': 'sathon_bird',
      'displayName': 'Sathon Wildlife',
      'message': 'started following you',
      'time': '1 hour ago',
      'isRead': true,
      'avatar': 'assets/profile/avatar3.png',
    },
    {
      'type': 'like',
      'username': 'yada_tech',
      'displayName': 'Yada Tech',
      'message': 'liked your reel',
      'time': '2 hours ago',
      'isRead': true,
      'avatar': 'assets/profile/avatar4.png',
    },
    {
      'type': 'mention',
      'username': 'emma_art',
      'displayName': 'Emma Creative',
      'message': 'mentioned you in a comment',
      'time': '3 hours ago',
      'isRead': true,
      'avatar': 'assets/profile/avatar5.png',
    },
    {
      'type': 'share',
      'username': 'james_fitness',
      'displayName': 'James Strong',
      'message': 'shared your reel',
      'time': '5 hours ago',
      'isRead': true,
      'avatar': 'assets/profile/avatar6.png',
    },
    {
      'type': 'achievement',
      'username': 'system',
      'displayName': 'ShowOff.life',
      'message': 'Your reel reached 10K views! 🎉',
      'time': '1 day ago',
      'isRead': true,
      'avatar': 'assets/appicon/image.png',
    },
    {
      'type': 'comment',
      'username': 'lisa_food',
      'displayName': 'Lisa Kitchen',
      'message': 'commented on your reel: "Love this content!"',
      'time': '2 days ago',
      'isRead': true,
      'avatar': 'assets/profile/avatar7.png',
    },
  ];

  int
  get unreadCount => notifications
      .where(
        (
          n,
        ) => !n['isRead'],
      )
      .length;

  void
  _markAsRead(
    int index,
  ) {
    setState(
      () {
        notifications[index]['isRead'] = true;
      },
    );
  }

  void
  _markAllAsRead() {
    setState(
      () {
        for (var notification in notifications) {
          notification['isRead'] = true;
        }
      },
    );
  }

  IconData
  _getNotificationIcon(
    String type,
  ) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'follow':
        return Icons.person_add;
      case 'mention':
        return Icons.alternate_email;
      case 'share':
        return Icons.share;
      case 'achievement':
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }

  Color
  _getNotificationColor(
    String type,
  ) {
    switch (type) {
      case 'like':
        return Colors.red;
      case 'comment':
        return Colors.blue;
      case 'follow':
        return Colors.green;
      case 'mention':
        return Colors.orange;
      case 'share':
        return Colors.purple;
      case 'achievement':
        return Colors.amber;
      default:
        return const Color(
          0xFF701CF5,
        );
    }
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
        elevation: 1,
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
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (unreadCount >
              0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Color(
                    0xFF701CF5,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'When you get notifications, they\'ll show up here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Unread count header
                if (unreadCount >
                    0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(
                      16,
                    ),
                    color:
                        const Color(
                          0xFF701CF5,
                        ).withValues(
                          alpha: 0.1,
                        ),
                    child: Text(
                      '$unreadCount new notification${unreadCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Color(
                          0xFF701CF5,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                // Notifications list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    itemCount: notifications.length,
                    itemBuilder:
                        (
                          context,
                          index,
                        ) {
                          final notification = notifications[index];
                          return _buildNotificationTile(
                            notification,
                            index,
                          );
                        },
                  ),
                ),
              ],
            ),
    );
  }

  Widget
  _buildNotificationTile(
    Map<
      String,
      dynamic
    >
    notification,
    int index,
  ) {
    final isRead =
        notification['isRead']
            as bool;
    final type =
        notification['type']
            as String;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isRead
            ? Colors.white
            : const Color(
                0xFF701CF5,
              ).withValues(
                alpha: 0.05,
              ),
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: isRead
              ? Colors.grey[200]!
              : const Color(
                  0xFF701CF5,
                ).withValues(
                  alpha: 0.2,
                ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(
          16,
        ),
        onTap: () => _markAsRead(
          index,
        ),
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                    type ==
                        'achievement'
                    ? const LinearGradient(
                        colors: [
                          Colors.amber,
                          Colors.orange,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [
                          Color(
                            0xFF701CF5,
                          ),
                          Color(
                            0xFF3E98E4,
                          ),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              ),
              child: Icon(
                type ==
                        'achievement'
                    ? Icons.emoji_events
                    : Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _getNotificationColor(
                    type,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getNotificationIcon(
                    type,
                  ),
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: notification['displayName'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
              TextSpan(
                text: ' ${notification['message']}',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 4,
          ),
          child: Text(
            notification['time'],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
        trailing: !isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(
                    0xFF701CF5,
                  ),
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}
