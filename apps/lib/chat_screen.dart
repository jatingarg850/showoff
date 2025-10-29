import 'package:flutter/material.dart';
import 'dart:async';
import 'services/api_service.dart';
import 'user_profile_screen.dart';

class ChatScreen
    extends
        StatefulWidget {
  final String
  userId;
  final String
  username;
  final String
  displayName;
  final bool
  isVerified;
  final String?
  profilePicture;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.displayName,
    this.isVerified = false,
    this.profilePicture,
  });

  @override
  State<
    ChatScreen
  >
  createState() => _ChatScreenState();
}

class _ChatScreenState
    extends
        State<
          ChatScreen
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
  messages = [];
  bool
  _isLoading = true;
  bool
  _isSending = false;
  Timer?
  _pollTimer;
  String?
  _currentUserId;

  @override
  void
  initState() {
    super.initState();
    print(
      'ChatScreen profilePicture: ${widget.profilePicture}',
    );
    _loadMessages();
    _startPolling();
  }

  void
  _startPolling() {
    // Poll for new messages every 2 seconds
    _pollTimer = Timer.periodic(
      const Duration(
        seconds: 2,
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

  Future<
    void
  >
  _loadMessages({
    bool silent = false,
  }) async {
    if (!silent) {
      setState(
        () {
          _isLoading = true;
        },
      );
    }

    try {
      final response = await ApiService.getMessages(
        widget.userId,
      );

      if (response['success'] &&
          mounted) {
        final List<
          dynamic
        >
        messageData =
            response['data'] ??
            [];

        setState(
          () {
            messages = messageData.map(
              (
                msg,
              ) {
                final senderId =
                    msg['sender']['_id'] ??
                    msg['sender']['id'];
                return {
                  'text': msg['text'],
                  'isMe':
                      senderId !=
                      widget.userId,
                  'time': _formatTime(
                    msg['createdAt'],
                  ),
                  'isRead':
                      msg['isRead'] ??
                      false,
                };
              },
            ).toList();
            _isLoading = false;
          },
        );

        if (!silent) {
          _scrollToBottom();
        }
      }
    } catch (
      e
    ) {
      if (mounted &&
          !silent) {
        setState(
          () {
            _isLoading = false;
          },
        );
      }
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
          : (date.hour ==
                    0
                ? 12
                : date.hour);
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
  _sendMessage() async {
    if (_messageController.text.trim().isEmpty ||
        _isSending)
      return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(
      () {
        _isSending = true;
      },
    );

    try {
      final response = await ApiService.sendMessage(
        widget.userId,
        messageText,
      );

      if (response['success']) {
        await _loadMessages(
          silent: true,
        );
        _scrollToBottom();
      }
    } catch (
      e
    ) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send message: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(
          () {
            _isSending = false;
          },
        );
      }
    }
  }

  String
  _formatCurrentTime() {
    final now = DateTime.now();
    final hour =
        now.hour >
            12
        ? now.hour -
              12
        : now.hour;
    final minute = now.minute.toString().padLeft(
      2,
      '0',
    );
    final period =
        now.hour >=
            12
        ? 'PM'
        : 'AM';
    return '$hour:$minute $period';
  }

  void
  _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
      (
        _,
      ) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(
              milliseconds: 300,
            ),
            curve: Curves.easeOut,
          );
        }
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
        title: GestureDetector(
          onTap: () {
            // Navigate to user profile
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (
                      context,
                    ) => UserProfileScreen(
                      userInfo: {
                        '_id': widget.userId,
                        'id': widget.userId,
                        'username': widget.username,
                        'displayName': widget.displayName,
                        'isVerified': widget.isVerified,
                        'profilePicture': widget.profilePicture,
                      },
                    ),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
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
                  image:
                      widget.profilePicture !=
                              null &&
                          widget.profilePicture!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(
                            widget.profilePicture!.startsWith(
                                  'http',
                                )
                                ? widget.profilePicture!
                                : ApiService.getImageUrl(
                                    widget.profilePicture!,
                                  ),
                          ),
                          fit: BoxFit.cover,
                          onError:
                              (
                                exception,
                                stackTrace,
                              ) {
                                print(
                                  'Error loading profile picture: $exception',
                                );
                                print(
                                  'Profile picture URL: ${widget.profilePicture}',
                                );
                              },
                        )
                      : null,
                ),
                child:
                    widget.profilePicture ==
                            null ||
                        widget.profilePicture!.isEmpty
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        if (widget.isVerified)
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 4,
                            ),
                            child: Icon(
                              Icons.verified,
                              size: 16,
                              color: Color(
                                0xFF701CF5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '@${widget.username}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(
                16,
              ),
              itemCount: messages.length,
              itemBuilder:
                  (
                    context,
                    index,
                  ) {
                    final message = messages[index];
                    return _buildMessageBubble(
                      message,
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
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(
                        25,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted:
                          (
                            _,
                          ) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(
                            0xFF701CF5,
                          ),
                          Color(
                            0xFF3E98E4,
                          ),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
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
  _buildMessageBubble(
    Map<
      String,
      dynamic
    >
    message,
  ) {
    final isMe =
        message['isMe']
            as bool;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
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
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color(
                        0xFF701CF5,
                      )
                    : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(
                    20,
                  ),
                  topRight: const Radius.circular(
                    20,
                  ),
                  bottomLeft: Radius.circular(
                    isMe
                        ? 20
                        : 4,
                  ),
                  bottomRight: Radius.circular(
                    isMe
                        ? 4
                        : 20,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'],
                    style: TextStyle(
                      color: isMe
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message['time'],
                        style: TextStyle(
                          color: isMe
                              ? Colors.white70
                              : Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(
                          width: 4,
                        ),
                        Icon(
                          message['isRead']
                              ? Icons.done_all
                              : Icons.done,
                          size: 14,
                          color: message['isRead']
                              ? Colors.blue[300]
                              : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe)
            const SizedBox(
              width: 40,
            ),
        ],
      ),
    );
  }
}
