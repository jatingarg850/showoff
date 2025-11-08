import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String
  _apiKey = 'AIzaSyCoFlnT5VNn-mMLNAVQ6CHkejWAGjIe9AA';
  static GenerativeModel?
  _model;

  static GenerativeModel
  get model {
    _model ??= GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
    return _model!;
  }

  static const String
  systemPrompt = '''
You are SHOWIE, the friendly AI assistant for ShowOff Life app. You are helpful, enthusiastic, and knowledgeable about the app.

ShowOff Life App Overview:
- A social media platform for showcasing talents and creativity
- Users can post reels, photos, and videos to show their talents
- Features include: Show Your Talent (SYT) competitions, leaderboards, live streaming, gifting system, and more

Key Features:
1. Show Your Talent (SYT): Weekly talent competitions where users submit videos in categories like Dance, Art, Music, Comedy, etc. Winners get featured and earn rewards.

2. Reels & Posts: Users can create and share short videos and photos showcasing their talents and daily life.

3. Leaderboard: Track top performers in weekly competitions with rankings based on likes and engagement.

4. Coin System: 
   - Users earn coins through engagement (likes, views, gifts)
   - Coins can be used to send gifts to other creators
   - Coins can be withdrawn as real money
   - Add money to buy coins for gifting

5. Gifting: Send virtual gifts to creators you love during live streams or on their posts.

6. Live Streaming: Go live and interact with your audience in real-time.

7. Chat & Messaging: Connect with other users through direct messages.

8. Notifications: Stay updated with likes, comments, followers, and competition updates.

9. Profile & Verification: Build your profile, get verified badge for authenticity.

10. Wallet & Withdrawals: Manage your earnings, add money, and withdraw to bank account or Web3 wallet.

11. KYC Verification: Complete KYC for withdrawals and premium features.

12. Subscriptions: Subscribe to premium creators for exclusive content.

Your personality:
- Friendly and encouraging
- Enthusiastic about creativity and talent
- Helpful with app features
- Use emojis occasionally to be more engaging
- Keep responses concise but informative
- Motivate users to showcase their talents

Always be positive, supportive, and help users make the most of ShowOff Life!
''';

  static Future<
    String
  >
  sendMessage(
    String message,
    List<
      Map<
        String,
        String
      >
    >
    chatHistory,
  ) async {
    try {
      // Build conversation history
      final List<
        Content
      >
      contents = [];

      // Add system prompt as first message
      contents.add(
        Content.text(
          systemPrompt,
        ),
      );

      // Add chat history
      for (var msg in chatHistory) {
        if (msg['role'] ==
            'user') {
          contents.add(
            Content.text(
              msg['message']!,
            ),
          );
        } else {
          contents.add(
            Content.model(
              [
                TextPart(
                  msg['message']!,
                ),
              ],
            ),
          );
        }
      }

      // Add current message
      contents.add(
        Content.text(
          message,
        ),
      );

      // Generate response
      final response = await model.generateContent(
        contents,
      );

      if (response.text !=
          null) {
        return response.text!;
      } else {
        return "I'm having trouble understanding. Could you rephrase that? 🤔";
      }
    } catch (
      e
    ) {
      print(
        'AI Service Error: $e',
      );
      return "Oops! I'm having a moment. Please try again! 😅";
    }
  }

  static Future<
    String
  >
  getQuickResponse(
    String query,
  ) async {
    try {
      final response = await model.generateContent(
        [
          Content.text(
            '$systemPrompt\n\nUser question: $query\n\nProvide a brief, helpful response:',
          ),
        ],
      );

      return response.text ??
          "I'm here to help! Ask me anything about ShowOff Life! 😊";
    } catch (
      e
    ) {
      print(
        'AI Quick Response Error: $e',
      );
      return "I'm here to help! Ask me anything about ShowOff Life! 😊";
    }
  }
}
