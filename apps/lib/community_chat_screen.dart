import 'package:flutter/material.dart';
import 'dart:async';
import 'services/api_service.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

class CommunityChatScreen
    extends
        StatefulWidget {
  final String
  communityName;
  final String
  groupId;

  const CommunityChatScreen({
    super.key,
    required this.communityName,
    required this.groupId,
  });

  @override
  State<
    CommunityChatScreen
  >
  createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState
    extends
        State<
          CommunityChatScreen
        > {
  final TextEditingController
  _messageController = TextEditingController();
  final ScrollController
  _scrollController = ScrollController();
  List<
    Map<
      String,
      dynamic
    >
  >
  _messages = [];
  bool
  _isLoading = true;
  Timer?
  _pollTimer;

  @override
  void
  initState() {
    super.initState();
    _loadMessages();
    // Poll for new messages every 3 seconds
    _pollTimer = Timer.periodic(
      const Duration(
        seconds: 3,
      ),
      (
        timer,
      ) {
        _loadMessages(
          silent: true,
        );
      },
    );
  }

  @override
  void
  dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _loadMessages({
    bool silent = false,
  }) async {
    try {
      if (!silent)
        setState(
          () => _isLoading = true,
        );

      final response = await ApiService.getGroupMessages(
        widget.groupId,
      );
      if (response['success'] &&
          mounted) {
        setState(
          () {
            _messages =
                List<
                  Map<
                    String,
                    dynamic
                  >
                >.from(
                  response['data'],
                );
            _isLoading = false;
          },
        );

        // Scroll to bottom after loading
        WidgetsBinding.instance.addPostFrameCallback(
          (
            _,
          ) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(
                _scrollController.position.maxScrollExtent,
              );
            }
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error loading messages: $e',
      );
      if (!silent &&
          mounted)
        setState(
          () => _isLoading = false,
        );
    }
  }

  Future<
    void
  >
  _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    try {
      final response = await ApiService.sendGroupMessage(
        widget.groupId,
        text,
      );
      if (response['success']) {
        _loadMessages(
          silent: true,
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
            'Error sending message: $e',
          ),
        ),
      );
    }
  }

  String
  _formatTime(
    String? timestamp,
  ) {
    if (timestamp ==
        null)
      return '';
    try {
      final date = DateTime.parse(
        timestamp,
      );
      final hour =
          date.hour >
              12
          ? date.hour -
                12
          : date.hour;
      final minute = date.minute.toString().padLeft(
        2,
        '0',
      );
      final period =
          date.hour >=
              12
          ? 'PM'
          : 'AM';
      return '$hour:$minute $period';
    } catch (
      e
    ) {
      return '';
    }
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    final authProvider =
        Provider.of<
          AuthProvider
        >(
          context,
          listen: false,
        );
    final currentUserId =
        authProvider.user?['_id'] ??
        '';

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
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.orange,
                    Colors.yellow,
                  ],
                ),
              ),
              child: const Center(
                child: Text(
                  '👥',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              widget.communityName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.call,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.videocam,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Date separator
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                ),
                child: Text(
                  DateTime.now().toString().split(
                    ' ',
                  )[0],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),

          // Messages
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemCount: _messages.length,
                    itemBuilder:
                        (
                          context,
                          index,
                        ) {
                          final message = _messages[index];
                          final sender =
                              message['sender'] ??
                              {};
                          final isMe =
                              sender['_id'] ==
                              currentUserId;

                          return _buildMessage(
                            name: isMe
                                ? ''
                                : (sender['displayName'] ??
                                      sender['username'] ??
                                      'User'),
                            message:
                                message['text'] ??
                                '',
                            time: _formatTime(
                              message['createdAt'],
                            ),
                            isCurrentUser: isMe,
                            avatarColor: Colors.brown,
                          );
                        },
                  ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(
              16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(
                    0.1,
                  ),
                  blurRadius: 10,
                  offset: const Offset(
                    0,
                    -2,
                  ),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type something...',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          24,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted:
                        (
                          _,
                        ) => _sendMessage(),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(
                        0xFF8B5CF6,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildMessage({
    required String name,
    required String message,
    required String time,
    required bool isCurrentUser,
    Color? avatarColor,
    bool isEmoji = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    avatarColor ??
                    Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (name.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 4,
                    ),
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? const Color(
                            0xFF8B5CF6,
                          )
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isCurrentUser
                          ? Colors.white
                          : Colors.black,
                      fontSize: isEmoji
                          ? 24
                          : 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 4,
                  ),
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
