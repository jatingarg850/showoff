# 🚀 SHOWIE Quick Start Guide

## What is SHOWIE?
SHOWIE is your ShowOff Life AI assistant powered by Google's Gemini AI. It helps users understand app features, competitions, and how to earn coins.

## How It Works

```
User taps AI button → Opens chat → Sends message → Gemini responds
```

**Architecture**: Client-side (Flutter app calls Gemini API directly)

## Setup Status: ✅ COMPLETE

### Configured Components
- ✅ API Key: `AIzaSyCoFlnT5VNn-mMLNAVQ6CHkejWAGjIe9AA`
- ✅ Model: `gemini-pro`
- ✅ Package: `google_generative_ai: ^0.4.7`
- ✅ UI: Chat screen with typing indicators
- ✅ Error Handling: Timeout, network, API errors
- ✅ Permissions: Internet access enabled

## Testing (3 Steps)

1. **Run the app**
   ```bash
   cd apps
   flutter run
   ```

2. **Navigate**: Home → Talent Screen

3. **Test**: Tap AI button → Send "Hey"

## Expected Result
- Typing indicator shows
- Response in 2-5 seconds
- SHOWIE greets and offers help

## Troubleshooting

### "Oops! I'm having a moment"

**Quick Fixes:**
1. Check internet connection
2. Verify API key at: https://aistudio.google.com/app/apikey
3. Enable Gemini API in Google Cloud Console
4. Check logs: `flutter logs`

### Common Issues

| Issue | Solution |
|-------|----------|
| No response | Check internet, verify API key active |
| Timeout | Increase timeout or check network speed |
| 404 Error | Enable Gemini API in Cloud Console |
| Quota exceeded | Check usage limits in Cloud Console |

## Key Files

```
apps/lib/
├── ai_chat_screen.dart          # Chat UI
├── services/
│   └── ai_service.dart          # Gemini API integration
└── talent_screen.dart           # AI button entry point
```

## API Key Location

**Primary**: `apps/lib/services/ai_service.dart` (line 5)
```dart
static const String _apiKey = 'AIzaSyCoFlnT5VNn-mMLNAVQ6CHkejWAGjIe9AA';
```

**Reference**: `server/.env` (documentation only)

## What SHOWIE Knows

- ✅ Show Your Talent (SYT) competitions
- ✅ Coin system and earnings
- ✅ Gifting and live streaming
- ✅ Leaderboards and rankings
- ✅ Profile verification
- ✅ Wallet and withdrawals
- ✅ KYC process
- ✅ App navigation

## Performance

- **Response Time**: 2-5 seconds
- **Timeout**: 30 seconds
- **Context**: Last 10 messages
- **Max Tokens**: 1024

## Resources

- **Google AI Studio**: https://aistudio.google.com/
- **API Docs**: https://ai.google.dev/docs
- **Cloud Console**: https://console.cloud.google.com/
- **Package**: https://pub.dev/packages/google_generative_ai

## Need Help?

1. Check `SHOWIE_SETUP_COMPLETE.md` for detailed setup
2. Review `SHOWIE_ARCHITECTURE.md` for architecture details
3. Check Flutter logs for error messages
4. Verify API key status in Google Cloud Console

---

**🎉 SHOWIE is ready to assist your users!**
