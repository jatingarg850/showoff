import 'package:flutter/material.dart';

class CommunityChatScreen
    extends
        StatelessWidget {
  final String
  communityName;

  const CommunityChatScreen({
    super.key,
    required this.communityName,
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
              communityName,
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
                child: const Text(
                  '2 January 2023',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),

          // Messages
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              children: [
                _buildMessage(
                  name: 'Donam Turner',
                  message: '👋 Hi, Everyone, Let\'s Catch a Movie this Weekend.',
                  time: '09:34 PM',
                  isCurrentUser: false,
                  avatarColor: Colors.brown,
                ),

                _buildMessage(
                  name: 'Diman',
                  message: 'Saturday or Sunday?',
                  time: '09:35 PM',
                  isCurrentUser: false,
                  avatarColor: Colors.brown,
                ),

                _buildMessage(
                  name: '',
                  message: 'How about having dinner at 8 pm and catching a movie at 10?',
                  time: '09:36 PM',
                  isCurrentUser: true,
                ),

                _buildMessage(
                  name: 'Kinms',
                  message: 'Sounds Good!',
                  time: '09:37 PM',
                  isCurrentUser: false,
                  avatarColor: Colors.blue,
                ),

                _buildMessage(
                  name: '',
                  message: 'Then I will find a Movie and Book the Tickets.',
                  time: '09:38 PM',
                  isCurrentUser: true,
                ),

                _buildMessage(
                  name: 'Mikana',
                  message: '👍',
                  time: '09:38 PM',
                  isCurrentUser: false,
                  avatarColor: Colors.brown,
                  isEmoji: true,
                ),
              ],
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
                  color: Colors.grey.withValues(
                    alpha: 0.1,
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(
                        24,
                      ),
                    ),
                    child: const Text(
                      'Type something...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.attach_file,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(
                      0xFF8B5CF6,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 24,
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
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser &&
              name.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 4,
              ),
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          Row(
            mainAxisAlignment: isCurrentUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isCurrentUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                        avatarColor ??
                        Colors.grey,
                    shape: BoxShape.circle,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: isEmoji
                        ? 12
                        : 16,
                    vertical: isEmoji
                        ? 8
                        : 12,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? const Color(
                            0xFF8B5CF6,
                          )
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(
                      20,
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
                          : 16,
                    ),
                  ),
                ),
              ),

              if (isCurrentUser) ...[
                const SizedBox(
                  width: 8,
                ),
                const Icon(
                  Icons.done_all,
                  color: Color(
                    0xFF8B5CF6,
                  ),
                  size: 16,
                ),
              ],
            ],
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            time,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
