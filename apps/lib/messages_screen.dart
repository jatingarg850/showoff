import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'chat_screen.dart';
import 'services/api_service.dart';

class MessagesScreen
    extends
        StatefulWidget {
  const MessagesScreen({
    super.key,
  });

  @override
  State<
    MessagesScreen
  >
  createState() => _MessagesScreenState();
}

class _MessagesScreenState
    extends
        State<
          MessagesScreen
        > {
  List<
    Map<
      String,
      dynamic
    >
  >
  _conversations = [];
  bool
  _isLoading = true;

  @override
  void
  initState() {
    super.initState();
    _loadConversations();
  }

  Future<
    void
  >
  _loadConversations() async {
    try {
      final response = await ApiService.getConversations();
      if (response['success'] &&
          mounted) {
        setState(
          () {
            _conversations =
                List<
                  Map<
                    String,
                    dynamic
                  >
                >.from(
                  response['data'] ??
                      [],
                );
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
        'Error loading conversations: $e',
      );
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
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
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
            )
          : _conversations.isEmpty
          ? _buildEmptyState()
          : _buildConversationsList(),
    );
  }

  Widget
  _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'Start a conversation by searching for users',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => SearchScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.search,
            ),
            label: const Text(
              'Find People',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(
                0xFF701CF5,
              ),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildConversationsList() {
    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.builder(
        itemCount: _conversations.length,
        itemBuilder:
            (
              context,
              index,
            ) {
              final conversation = _conversations[index];
              final otherUser =
                  conversation['otherUser'] ??
                  {};
              final lastMessage =
                  conversation['lastMessage'] ??
                  {};

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(
                    0xFF701CF5,
                  ),
                  backgroundImage:
                      otherUser['profilePicture'] !=
                          null
                      ? NetworkImage(
                          ApiService.getImageUrl(
                            otherUser['profilePicture'],
                          ),
                        )
                      : null,
                  child:
                      otherUser['profilePicture'] ==
                          null
                      ? Text(
                          (otherUser['displayName'] ??
                                  otherUser['username'] ??
                                  'U')
                              .toString()
                              .substring(
                                0,
                                1,
                              )
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  otherUser['displayName'] ??
                      otherUser['username'] ??
                      'Unknown User',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  lastMessage['content'] ??
                      'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(
                        lastMessage['createdAt'],
                      ),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    if (conversation['unreadCount'] !=
                            null &&
                        conversation['unreadCount'] >
                            0)
                      Container(
                        margin: const EdgeInsets.only(
                          top: 4,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF701CF5,
                          ),
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Text(
                          conversation['unreadCount'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (
                            context,
                          ) => ChatScreen(
                            userId:
                                otherUser['_id'] ??
                                otherUser['id'] ??
                                '',
                            username:
                                otherUser['username'] ??
                                '',
                            displayName:
                                otherUser['displayName'] ??
                                otherUser['username'] ??
                                'User',
                            isVerified:
                                otherUser['isVerified'] ??
                                false,
                            profilePicture: otherUser['profilePicture'],
                          ),
                    ),
                  ).then(
                    (
                      _,
                    ) {
                      // Refresh conversations when returning from chat
                      _loadConversations();
                    },
                  );
                },
              );
            },
      ),
    );
  }

  String
  _formatTime(
    String? timestamp,
  ) {
    if (timestamp ==
        null)
      return '';

    try {
      final dateTime = DateTime.parse(
        timestamp,
      );
      final now = DateTime.now();
      final difference = now.difference(
        dateTime,
      );

      if (difference.inDays >
          0) {
        return '${difference.inDays}d';
      } else if (difference.inHours >
          0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes >
          0) {
        return '${difference.inMinutes}m';
      } else {
        return 'now';
      }
    } catch (
      e
    ) {
      return '';
    }
  }
}
