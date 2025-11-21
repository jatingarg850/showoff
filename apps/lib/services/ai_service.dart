import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String
  _apiKey = 'AIzaSyCoFlnT5VNn-mMLNAVQ6CHkejWAGjIe9AA';
  static GenerativeModel?
  _model;

  static GenerativeModel
  get model {
    _model ??= GenerativeModel(
      model: 'gemini-2.5-flash',
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
      print(
        '🟢 Starting AI request for message: $message',
      );

      // Simple single-turn approach with system context
      final prompt = '$systemPrompt\n\nUser: $message\n\nSHOWIE:';

      print(
        '🟢 Calling Gemini API...',
      );

      final response = await model
          .generateContent(
            [
              Content.text(
                prompt,
              ),
            ],
          )
          .timeout(
            const Duration(
              seconds: 30,
            ),
            onTimeout: () {
              throw Exception(
                'Request timeout',
              );
            },
          );

      print(
        '🟢 Response received from Gemini',
      );

      if (response.text !=
              null &&
          response.text!.isNotEmpty) {
        print(
          '🟢 Response text: ${response.text}',
        );
        return response.text!;
      } else {
        print(
          '🔴 Empty response from API',
        );
        return "I'm having trouble understanding. Could you rephrase that? 🤔";
      }
    } catch (
      e
    ) {
      print(
        '🔴 AI Service Error: $e',
      );
      print(
        '🔴 Error Type: ${e.runtimeType}',
      );

      final errorString = e.toString().toLowerCase();

      if (errorString.contains(
        'timeout',
      )) {
        return "Connection timeout! Please check your internet and try again. 📡";
      } else if (errorString.contains(
            'api',
          ) &&
          errorString.contains(
            'key',
          )) {
        return "API key issue. Please contact support. 🔧";
      } else if (errorString.contains(
            'quota',
          ) ||
          errorString.contains(
            'limit',
          )) {
        return "Service temporarily unavailable. Please try again later. ⏰";
      } else if (errorString.contains(
            'network',
          ) ||
          errorString.contains(
            'connection',
          )) {
        return "Network error! Please check your internet connection. 🌐";
      }

      // Return actual error for debugging
      return "Debug Error: ${e.toString()}";
    }
  }

  static Future<
    String
  >
  getQuickResponse(
    String query,
  ) async {
    return sendMessage(
      query,
      [],
    );
  }
}
