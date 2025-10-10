import 'package:flutter/material.dart';

class CommentsScreen
    extends
        StatefulWidget {
  const CommentsScreen({
    super.key,
  });

  @override
  State<
    CommentsScreen
  >
  createState() => _CommentsScreenState();
}

class _CommentsScreenState
    extends
        State<
          CommentsScreen
        > {
  final TextEditingController
  _commentController = TextEditingController();

  final List<
    Comment
  >
  comments = [
    Comment(
      username: 'Emmy',
      comment: 'The eagle is really big wow!!😍',
      timeAgo: '2h',
      profileColor: Colors.grey[300]!,
    ),
    Comment(
      username: 'Mirror',
      comment: 'The wings are really long',
      timeAgo: '6h',
      profileColor: Colors.grey[400]!,
    ),
    Comment(
      username: 'John',
      comment: 'The eagle is bald',
      timeAgo: '7h',
      profileColor: Colors.brown[300]!,
    ),
    Comment(
      username: 'Mouse',
      comment: 'It is a predator',
      timeAgo: '9h',
      profileColor: Colors.orange[300]!,
    ),
    Comment(
      username: 'Sathon',
      comment: 'The wings are really long',
      timeAgo: '10h',
      profileColor: Colors.grey[600]!,
    ),
  ];

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Container(
      height:
          MediaQuery.of(
            context,
          ).size.height *
          0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            20,
          ),
          topRight: Radius.circular(
            20,
          ),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(
              top: 8,
            ),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(
                2,
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(
              16,
            ),
            child: Text(
              '30 Comments',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // Comments list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              itemCount: comments.length,
              itemBuilder:
                  (
                    context,
                    index,
                  ) {
                    final comment = comments[index];
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile picture
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: comment.profileColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          // Comment content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Username
                                Text(
                                  comment.username,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                // Comment text
                                Text(
                                  comment.comment,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Time ago
                          Text(
                            comment.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
            ),
          ),

          // Gradient line separator
          Container(
            height: 2,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(
                    0xFF701CF5,
                  ),
                  Color(
                    0xFF74B9FF,
                  ),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),

          // Comment input
          Container(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              32,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Profile picture for current user
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                // Text input
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(
                        25,
                      ),
                    ),
                    child: TextField(
                      controller: _commentController,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        hintText: 'Write something here',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                // Send button
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(
                          0xFF701CF5,
                        ),
                        Color(
                          0xFF74B9FF,
                        ),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/comment/sent.png',
                      width: 20,
                      height: 20,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                // Image attachment button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/comment/image.png',
                      width: 20,
                      height: 20,
                      color: Colors.grey[600],
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

  @override
  void
  dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

class Comment {
  final String
  username;
  final String
  comment;
  final String
  timeAgo;
  final Color
  profileColor;

  Comment({
    required this.username,
    required this.comment,
    required this.timeAgo,
    required this.profileColor,
  });
}
