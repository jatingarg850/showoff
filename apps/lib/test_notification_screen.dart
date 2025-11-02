import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/push_notification_service.dart';
import 'services/api_service.dart';

class TestNotificationScreen
    extends
        StatefulWidget {
  const TestNotificationScreen({
    super.key,
  });

  @override
  State<
    TestNotificationScreen
  >
  createState() => _TestNotificationScreenState();
}

class _TestNotificationScreenState
    extends
        State<
          TestNotificationScreen
        > {
  bool
  _isLoading = false;

  Future<
    void
  >
  _testLocalNotification() async {
    await PushNotificationService.instance.showNotification(
      title: '🧪 Test Notification',
      body: 'This is a test push notification!',
      payload: 'test:notification',
    );
  }

  Future<
    void
  >
  _testLikeNotification() async {
    await PushNotificationService.instance.showLikeNotification(
      username: 'john_doe',
      postId: 'test_post_123',
    );
  }

  Future<
    void
  >
  _testCommentNotification() async {
    await PushNotificationService.instance.showCommentNotification(
      username: 'jane_smith',
      comment: 'Amazing reel! Love the creativity 🔥',
      postId: 'test_post_123',
    );
  }

  Future<
    void
  >
  _testFollowNotification() async {
    await PushNotificationService.instance.showFollowNotification(
      username: 'mike_wilson',
      userId: 'test_user_456',
    );
  }

  Future<
    void
  >
  _testAchievementNotification() async {
    await PushNotificationService.instance.showAchievementNotification(
      title: 'Rising Star',
      description: 'You reached 1000 likes on your reels!',
    );
  }

  Future<
    void
  >
  _createServerNotification(
    String type,
  ) async {
    setState(
      () {
        _isLoading = true;
      },
    );

    try {
      final response = await ApiService.createTestNotification(
        type,
      );
      if (response['success']) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${response['message']}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(
          response['message'],
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
            '❌ Error: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(
        () {
          _isLoading = false;
        },
      );
    }
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Test Notifications',
        ),
        backgroundColor: const Color(
          0xFF701CF5,
        ),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Local Push Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(
                  0xFF701CF5,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),

            ElevatedButton.icon(
              onPressed: _testLocalNotification,
              icon: const Icon(
                Icons.notifications,
              ),
              label: const Text(
                'Test Basic Notification',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            ElevatedButton.icon(
              onPressed: _testLikeNotification,
              icon: const Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              label: const Text(
                'Test Like Notification',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            ElevatedButton.icon(
              onPressed: _testCommentNotification,
              icon: const Icon(
                Icons.comment,
              ),
              label: const Text(
                'Test Comment Notification',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            ElevatedButton.icon(
              onPressed: _testFollowNotification,
              icon: const Icon(
                Icons.person_add,
              ),
              label: const Text(
                'Test Follow Notification',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            ElevatedButton.icon(
              onPressed: _testAchievementNotification,
              icon: const Icon(
                Icons.emoji_events,
                color: Colors.amber,
              ),
              label: const Text(
                'Test Achievement Notification',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            const Text(
              'Server-Generated Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(
                  0xFF701CF5,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else ...[
              ElevatedButton.icon(
                onPressed: () => _createServerNotification(
                  'create',
                ),
                icon: const Icon(
                  Icons.auto_awesome,
                ),
                label: const Text(
                  'Create Test Notifications',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF701CF5,
                  ),
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              ElevatedButton.icon(
                onPressed: () => _createServerNotification(
                  'like',
                ),
                icon: const Icon(
                  Icons.favorite,
                ),
                label: const Text(
                  'Trigger Like Notification',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              ElevatedButton.icon(
                onPressed: () => _createServerNotification(
                  'comment',
                ),
                icon: const Icon(
                  Icons.comment,
                ),
                label: const Text(
                  'Trigger Comment Notification',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              ElevatedButton.icon(
                onPressed: () => _createServerNotification(
                  'follow',
                ),
                icon: const Icon(
                  Icons.person_add,
                ),
                label: const Text(
                  'Trigger Follow Notification',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],

            const Spacer(),

            const Text(
              'Note: Server notifications will appear both as push notifications and in the notification screen.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to add test notification methods to ApiService
extension TestNotificationApi
    on
        ApiService {
  static Future<
    Map<
      String,
      dynamic
    >
  >
  createTestNotification(
    String type,
  ) async {
    final response = await http.post(
      Uri.parse(
        '${ApiService.baseUrl}/notifications/test/$type',
      ),
      headers: await ApiService._getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }

  static Future<
    Map<
      String,
      dynamic
    >
  >
  createDirectTestNotification() async {
    final response = await http.post(
      Uri.parse(
        '${ApiService.baseUrl}/notifications/test/direct',
      ),
      headers: await ApiService._getHeaders(),
    );
    return jsonDecode(
      response.body,
    );
  }
}
