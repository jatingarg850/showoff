import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'providers/notification_provider.dart';

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
  final ScrollController
  _scrollController = ScrollController();

  @override
  void
  initState() {
    super.initState();
    // Load notifications when screen opens
    WidgetsBinding.instance.addPostFrameCallback(
      (
        _,
      ) {
        context
            .read<
              NotificationProvider
            >()
            .loadNotifications();
      },
    );
  }

  @override
  void
  dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void
  _showErrorSnackbar(
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<
    void
  >
  _markAsRead(
    String id,
  ) async {
    await context
        .read<
          NotificationProvider
        >()
        .markAsRead(
          id,
        );
  }

  Future<
    void
  >
  _markAllAsRead() async {
    await context
        .read<
          NotificationProvider
        >()
        .markAllAsRead();
  }

  Future<
    void
  >
  _deleteNotification(
    String id,
  ) async {
    await context
        .read<
          NotificationProvider
        >()
        .deleteNotification(
          id,
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
      case 'gift':
        return Icons.card_giftcard;
      case 'vote':
        return Icons.how_to_vote;
      case 'system':
        return Icons.info;
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
      case 'gift':
        return Colors.pink;
      case 'vote':
        return Colors.indigo;
      case 'system':
        return Colors.grey;
      default:
        return const Color(
          0xFF701CF5,
        );
    }
  }

  String
  _formatTimeAgo(
    String? dateString,
  ) {
    if (dateString ==
        null)
      return 'Just now';

    try {
      final date = DateTime.parse(
        dateString,
      );
      final now = DateTime.now();
      final difference = now.difference(
        date,
      );

      if (difference.inMinutes <
          1) {
        return 'Just now';
      } else if (difference.inMinutes <
          60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours <
          24) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inDays <
          7) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else {
        return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() > 1 ? 's' : ''} ago';
      }
    } catch (
      e
    ) {
      return 'Recently';
    }
  }

  void
  _handleNotificationTap(
    Map<
      String,
      dynamic
    >
    notification,
  ) {
    final type =
        notification['type']
            as String? ??
        '';
    final data =
        notification['data']
            as Map<
              String,
              dynamic
            >? ??
        {};

    // Mark as read when tapped
    if (!(notification['isRead'] ??
        false)) {
      _markAsRead(
        notification['_id'],
      );
    }

    // Handle different notification types
    switch (type) {
      case 'like':
      case 'comment':
      case 'share':
        if (data['postId'] !=
            null) {
          // Navigate to post
          // Navigator.push(context, MaterialPageRoute(builder: (context) => PostScreen(postId: data['postId'])));
          print(
            'Navigate to post: ${data['postId']}',
          );
        }
        break;
      case 'follow':
        // Navigate to user profile
        final sender =
            notification['sender']
                as Map<
                  String,
                  dynamic
                >?;
        if (sender?['_id'] !=
            null) {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen(userId: sender['_id'])));
          print(
            'Navigate to user profile: ${sender?['_id']}',
          );
        }
        break;
      case 'vote':
        if (data['sytEntryId'] !=
            null) {
          // Navigate to SYT entry
          // Navigator.push(context, MaterialPageRoute(builder: (context) => SYTScreen(entryId: data['sytEntryId'])));
          print(
            'Navigate to SYT entry: ${data['sytEntryId']}',
          );
        }
        break;
      case 'gift':
        // Show gift details or navigate to wallet
        print(
          'Gift received: ${data['amount']} coins',
        );
        break;
      case 'achievement':
        // Show achievement details
        print(
          'Achievement unlocked: ${notification['title']}',
        );
        break;
      default:
        break;
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
        title:
            Consumer<
              NotificationProvider
            >(
              builder:
                  (
                    context,
                    provider,
                    child,
                  ) {
                    return Row(
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (provider.unreadCount >
                            0) ...[
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                            child: Text(
                              provider.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
            ),
        actions: [
          Consumer<
            NotificationProvider
          >(
            builder:
                (
                  context,
                  provider,
                  child,
                ) {
                  if (provider.unreadCount >
                      0) {
                    return TextButton(
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
                    );
                  }
                  return const SizedBox.shrink();
                },
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
            ),
            onPressed: () => context
                .read<
                  NotificationProvider
                >()
                .loadNotifications(),
          ),
        ],
      ),
      body:
          Consumer<
            NotificationProvider
          >(
            builder:
                (
                  context,
                  provider,
                  child,
                ) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<
                              Color
                            >(
                              Color(
                                0xFF701CF5,
                              ),
                            ),
                      ),
                    );
                  }

                  if (provider.notifications.isEmpty) {
                    return Center(
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
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadNotifications(),
                    child: Column(
                      children: [
                        // Unread count header
                        if (provider.unreadCount >
                            0)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(
                              16,
                            ),
                            color:
                                const Color(
                                  0xFF701CF5,
                                ).withOpacity(
                                  0.1,
                                ),
                            child: Text(
                              '${provider.unreadCount} new notification${provider.unreadCount > 1 ? 's' : ''}',
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
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            itemCount: provider.notifications.length,
                            itemBuilder:
                                (
                                  context,
                                  index,
                                ) {
                                  final notification = provider.notifications[index];
                                  return _buildNotificationTile(
                                    notification,
                                  );
                                },
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
  ) {
    final isRead =
        notification['isRead']
            as bool? ??
        false;
    final type =
        notification['type']
            as String? ??
        'system';
    final sender =
        notification['sender']
            as Map<
              String,
              dynamic
            >?;
    final senderName =
        sender?['displayName'] ??
        sender?['username'] ??
        'System';
    final senderAvatar = sender?['profilePicture'];
    final message =
        notification['message']
            as String? ??
        '';
    final createdAt =
        notification['createdAt']
            as String?;
    final timeAgo = _formatTimeAgo(
      createdAt,
    );

    return Dismissible(
      key: Key(
        notification['_id'] ??
            '',
      ),
      direction: DismissDirection.endToStart,
      onDismissed:
          (
            direction,
          ) {
            _deleteNotification(
              notification['_id'],
            );
          },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(
          right: 20,
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(
            12,
          ),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isRead
              ? Colors.white
              : const Color(
                  0xFF701CF5,
                ).withOpacity(
                  0.05,
                ),
          borderRadius: BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color: isRead
                ? Colors.grey[200]!
                : const Color(
                    0xFF701CF5,
                  ).withOpacity(
                    0.2,
                  ),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(
            16,
          ),
          onTap: () => _handleNotificationTap(
            notification,
          ),
          leading: Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _getNotificationColor(
                        type,
                      ).withOpacity(
                        0.1,
                      ),
                ),
                child:
                    senderAvatar !=
                            null &&
                        senderAvatar.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          ApiService.getImageUrl(
                            senderAvatar,
                          ),
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          errorBuilder:
                              (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return Icon(
                                  _getNotificationIcon(
                                    type,
                                  ),
                                  color: _getNotificationColor(
                                    type,
                                  ),
                                  size: 24,
                                );
                              },
                        ),
                      )
                    : Icon(
                        type ==
                                    'achievement' ||
                                type ==
                                    'system'
                            ? Icons.emoji_events
                            : Icons.person,
                        color:
                            type ==
                                    'achievement' ||
                                type ==
                                    'system'
                            ? Colors.amber
                            : _getNotificationColor(
                                type,
                              ),
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
          title: Text.rich(
            TextSpan(
              children:
                  type !=
                      'system'
                  ? [
                      TextSpan(
                        text: senderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: ' $message',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ]
                  : [
                      TextSpan(
                        text:
                            notification['title'] ??
                            message,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      if (notification['title'] !=
                              null &&
                          message.isNotEmpty)
                        TextSpan(
                          text: '\n$message',
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
              timeAgo,
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
      ),
    );
  }
}
