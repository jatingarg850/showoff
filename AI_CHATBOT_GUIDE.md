# SHOWIE - AI Chatbot Integration Guide

## Overview
SHOWIE is an AI-powered assistant integrated into the ShowOff Life app using Google's Gemini API. Users can chat with SHOWIE to learn about app features, get help, and receive guidance.

## Features Implemented

### 1. AI Service (`apps/lib/services/ai_service.dart`)
- **Gemini API Integration**: Uses `google_generative_ai` package
- **API Key**: AIzaSyCoFlnT5VNn-mMLNAVQ6CHkejWAGjIe9AA
- **Model**: gemini-pro
- **System Prompt**: Comprehensive knowledge about ShowOff Life app features
- **Context-Aware**: Maintains conversation history for better responses

### 2. AI Chat Screen (`apps/lib/ai_chat_screen.dart`)
- **Beautiful UI**: Gradient design matching app theme
- **Chat Interface**: Message bubbles with user/AI distinction
- **Quick Questions**: Pre-defined questions for easy start
- **Typing Indicator**: Animated dots while AI is thinking
- **Scrollable History**: Full conversation history
- **Avatar Display**: Shows SHOWIE's face from `assets/AI/ai.jpg`

### 3. Talent Screen Integration (`apps/lib/talent_screen.dart`)
- **AI Button**: Added as the first button in the top-right header
- **Gradient Icon**: Purple-blue gradient circle with robot icon
- **Easy Access**: One tap to open AI chat from talent screen

## SHOWIE's Knowledge Base

SHOWIE knows about:
- **SYT Competitions**: Weekly talent competitions, categories, how to participate
- **Coin System**: Earning, spending, withdrawing coins
- **Gifting**: Sending virtual gifts to creators
- **Leaderboard**: Rankings and competition standings
- **Live Streaming**: Going live and interacting with audience
- **Profile Features**: Verification, KYC, subscriptions
- **Wallet & Withdrawals**: Managing earnings, bank transfers, Web3 wallets
- **Content Creation**: Posting reels, photos, videos

## How to Use

### For Users:
1. Open the Talent Screen (Show Your Talent)
2. Tap the gradient AI button (robot icon) in the top-right corner
3. Start chatting with SHOWIE!
4. Use quick questions or type your own

### Example Questions:
- "How do I join SYT?"
- "How can I earn coins?"
- "How do I withdraw my money?"
- "What is the leaderboard?"
- "How do I get verified?"
- "Tell me about live streaming"

## Setup Requirements

### 1. Add AI Avatar Image
Place your AI avatar image at: `apps/assets/AI/ai.jpg`
- Format: JPG
- Recommended size: 512x512 or higher
- Square format

### 2. Dependencies (Already Added)
```yaml
dependencies:
  google_generative_ai: ^0.4.0
```

### 3. Assets Configuration (Already Added)
```yaml
flutter:
  assets:
    - assets/AI/
```

## API Configuration

The Gemini API key is configured in `apps/lib/services/ai_service.dart`:
```dart
static const String _apiKey = 'AIzaSyCoFlnT5VNn-mMLNAVQ6CHkejWAGjIe9AA';
```

**Note**: For production, consider moving this to environment variables or secure storage.

## Customization

### Modify SHOWIE's Personality
Edit the `systemPrompt` in `apps/lib/services/ai_service.dart` to change:
- Tone and personality
- Knowledge base
- Response style
- Feature descriptions

### Update UI Theme
Modify colors in `apps/lib/ai_chat_screen.dart`:
- Gradient colors: `Color(0xFF701CF5)` and `Color(0xFF3E98E4)`
- Message bubble styles
- Button designs

### Add More Quick Questions
Edit the quick questions list in `ai_chat_screen.dart`:
```dart
_buildQuickButton('Your question here'),
```

## Technical Details

### AI Service Features:
- **Temperature**: 0.9 (creative responses)
- **Max Tokens**: 1024 (medium-length responses)
- **Context Window**: Last 10 messages for conversation context
- **Error Handling**: Graceful fallbacks for API failures

### Performance:
- Async/await for non-blocking UI
- Typing indicators for better UX
- Auto-scroll to latest messages
- Efficient message history management

## Testing

1. **Run the app**: `flutter run`
2. **Navigate to Talent Screen**
3. **Tap AI button** (gradient robot icon)
4. **Test conversations**:
   - Try quick questions
   - Ask custom questions
   - Test conversation context
   - Verify error handling

## Troubleshooting

### AI Button Not Showing
- Check if `ai_chat_screen.dart` is imported in `talent_screen.dart`
- Verify assets are properly configured in `pubspec.yaml`

### API Errors
- Verify API key is valid
- Check internet connection
- Review error messages in console

### Image Not Loading
- Ensure `ai.jpg` exists in `apps/assets/AI/`
- Check file name is exactly `ai.jpg` (lowercase)
- Verify assets path in `pubspec.yaml`

## Future Enhancements

Potential improvements:
1. **Voice Input**: Add speech-to-text for voice queries
2. **Multi-language**: Support multiple languages
3. **Personalization**: Learn user preferences over time
4. **Rich Media**: Send images, videos in chat
5. **Proactive Tips**: Suggest features based on user behavior
6. **Analytics**: Track common questions and improve responses

## Security Notes

- API key is currently hardcoded (suitable for demo)
- For production: Use environment variables or secure key management
- Consider rate limiting to prevent API abuse
- Implement user authentication for personalized responses

## Support

For issues or questions about SHOWIE:
1. Check console logs for error messages
2. Verify API key validity
3. Test with simple questions first
4. Review system prompt for knowledge gaps

---

**SHOWIE is ready to help users discover and enjoy ShowOff Life! 🌟**
