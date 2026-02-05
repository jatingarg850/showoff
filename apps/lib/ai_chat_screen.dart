import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'services/ai_service.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Initialize AI Service
    _initializeAI();
    // Welcome message
    _messages.add({
      'role': 'ai',
      'message':
          'Hey there! 👋 I\'m SHOWIE, your ShowOff Life assistant! Ask me anything about the app, competitions, or how to showcase your talent! 🌟',
    });
  }

  Future<void> _initializeAI() async {
    try {
      await AIService.initialize();
      debugPrint('✅ AI Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize AI Service: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load AI features: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'message': message});
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Get chat history for context (last 10 messages)
      final chatHistory = _messages.length > 10
          ? _messages.sublist(_messages.length - 10)
          : _messages;

      final response = await AIService.sendMessage(message, chatHistory);

      setState(() {
        _messages.add({'role': 'ai', 'message': response});
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'ai',
          'message': 'Oops! Something went wrong. Please try again! 😅',
        });
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _sendQuickMessage(String message) {
    _messageController.text = message;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isMediumScreen = screenSize.width < 600;

    // Responsive padding
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final verticalPadding = isSmallScreen ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: isSmallScreen ? 36 : 40,
              height: isSmallScreen ? 36 : 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: const Color(0xFF701CF5)),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/AI/ai.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF701CF5),
                      child: Icon(
                        Icons.smart_toy,
                        color: Colors.white,
                        size: isSmallScreen ? 20 : 24,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SHOWIE',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'AI Assistant',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick action buttons
          if (_messages.length <= 1)
            Container(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Questions:',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: verticalPadding),
                  Wrap(
                    spacing: isSmallScreen ? 6 : 8,
                    runSpacing: isSmallScreen ? 6 : 8,
                    children: [
                      _buildQuickButton('How do I join SYT?', isSmallScreen),
                      _buildQuickButton('How to earn coins?', isSmallScreen),
                      _buildQuickButton(
                        'How to withdraw money?',
                        isSmallScreen,
                      ),
                      _buildQuickButton(
                        'What is the leaderboard?',
                        isSmallScreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(horizontalPadding),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator(isSmallScreen);
                }

                final message = _messages[index];
                final isAI = message['role'] == 'ai';

                return _buildMessageBubble(
                  message['message']!,
                  isAI,
                  isSmallScreen,
                  isMediumScreen,
                );
              },
            ),
          ),

          // Input area
          Container(
            padding: EdgeInsets.all(horizontalPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask SHOWIE...',
                        border: InputBorder.none,
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      maxLines: null,
                      minLines: 1,
                      maxLength: 500,
                      buildCounter:
                          (
                            context, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) => null,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 15),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF701CF5), Color(0xFF3E98E4)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: isSmallScreen ? 20 : 24,
                    ),
                    iconSize: isSmallScreen ? 20 : 24,
                    onPressed: _isTyping ? null : _sendMessage,
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String text, bool isSmallScreen) {
    return InkWell(
      onTap: () => _sendQuickMessage(text),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isSmallScreen ? 11 : 13,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    String message,
    bool isAI,
    bool isSmallScreen,
    bool isMediumScreen,
  ) {
    final maxWidth = isSmallScreen
        ? MediaQuery.of(context).size.width * 0.85
        : isMediumScreen
        ? MediaQuery.of(context).size.width * 0.80
        : MediaQuery.of(context).size.width * 0.70;

    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isAI
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (isAI) ...[
            Container(
              width: isSmallScreen ? 28 : 32,
              height: isSmallScreen ? 28 : 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: const Color(0xFF701CF5)),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/AI/ai.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF701CF5),
                      child: Icon(
                        Icons.smart_toy,
                        color: Colors.white,
                        size: isSmallScreen ? 14 : 16,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: isSmallScreen ? 6 : 8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  gradient: isAI
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF701CF5), Color(0xFF3E98E4)],
                        ),
                  color: isAI ? Colors.grey[100] : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: isAI
                    ? MarkdownBody(
                        data: message,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            color: Colors.black87,
                            fontSize: isSmallScreen ? 13 : 15,
                            height: 1.4,
                          ),
                          strong: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 13 : 15,
                          ),
                          em: TextStyle(
                            color: Colors.black87,
                            fontStyle: FontStyle.italic,
                            fontSize: isSmallScreen ? 13 : 15,
                          ),
                          listBullet: TextStyle(
                            color: Colors.black87,
                            fontSize: isSmallScreen ? 13 : 15,
                          ),
                          code: TextStyle(
                            backgroundColor: Colors.grey[200],
                            color: const Color(0xFF701CF5),
                            fontFamily: 'monospace',
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      )
                    : Text(
                        message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 13 : 15,
                          height: 1.4,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isSmallScreen ? 28 : 32,
            height: isSmallScreen ? 28 : 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: const Color(0xFF701CF5)),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/AI/ai.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF701CF5),
                    child: Icon(
                      Icons.smart_toy,
                      color: Colors.white,
                      size: isSmallScreen ? 14 : 16,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0, isSmallScreen),
                SizedBox(width: isSmallScreen ? 3 : 4),
                _buildDot(1, isSmallScreen),
                SizedBox(width: isSmallScreen ? 3 : 4),
                _buildDot(2, isSmallScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, bool isSmallScreen) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: (value + index * 0.3) % 1.0,
          child: Container(
            width: isSmallScreen ? 6 : 8,
            height: isSmallScreen ? 6 : 8,
            decoration: const BoxDecoration(
              color: Color(0xFF701CF5),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }
}
