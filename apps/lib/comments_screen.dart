import 'package:flutter/material.dart';
import 'services/api_service.dart';

class CommentsScreen
    extends
        StatefulWidget {
  final String
  postId;

  const CommentsScreen({
    super.key,
    required this.postId,
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

  List<
    Map<
      String,
      dynamic
    >
  >
  _comments = [];
  bool
  _isLoading = true;

  @override
  void
  initState() {
    super.initState();
    _loadComments();
  }

  Future<
    void
  >
  _loadComments() async {
    try {
      final response = await ApiService.getComments(
        widget.postId,
      );
      if (response['success']) {
        setState(
          () {
            _comments =
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
      }
    } catch (
      e
    ) {
      print(
        'Error loading comments: $e',
      );
      setState(
        () => _isLoading = false,
      );
    }
  }

  Future<
    void
  >
  _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final response = await ApiService.addComment(
        widget.postId,
        _commentController.text.trim(),
      );

      if (response['success'] &&
          mounted) {
        _commentController.clear();
        _loadComments(); // Refresh comments
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Comment added!',
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
      if (mounted) {
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
  }

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
              '${_comments.length} Comment${_comments.length != 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // Comments list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _comments.isEmpty
                ? Center(
                    child: Text(
                      'No comments yet. Be the first!',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemCount: _comments.length,
                    itemBuilder:
                        (
                          context,
                          index,
                        ) {
                          final comment = _comments[index];
                          final user =
                              comment['user'] ??
                              {};
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
                                    color: Colors.grey[600],
                                    shape: BoxShape.circle,
                                  ),
                                  child:
                                      user['profilePicture'] !=
                                          null
                                      ? ClipOval(
                                          child: Image.network(
                                            ApiService.getImageUrl(
                                              user['profilePicture'],
                                            ),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => const Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                          ),
                                        )
                                      : const Icon(
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
                                        user['username'] ??
                                            'Unknown',
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
                                        comment['text'] ??
                                            '',
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
                                  _formatTimeAgo(
                                    comment['createdAt'],
                                  ),
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
                GestureDetector(
                  onTap: _addComment,
                  child: Container(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String
  _formatTimeAgo(
    String? dateString,
  ) {
    if (dateString ==
        null)
      return '';

    try {
      final date = DateTime.parse(
        dateString,
      );
      final now = DateTime.now();
      final difference = now.difference(
        date,
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

  @override
  void
  dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
