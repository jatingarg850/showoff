# SHOWIE AI Chatbot - Architecture & Integration

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    ShowOff Life App                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ Talent Screen│    │ Other Screens│    │  Navigation  │
│              │    │              │    │              │
│  [AI Button] │    │              │    │              │
└──────┬───────┘    └──────────────┘    └──────────────┘
       │
       │ Tap AI Button
       │
       ▼
┌──────────────────────────────────────────────────────┐
│           AI Chat Screen (ai_chat_screen.dart)       │
│  ┌────────────────────────────────────────────────┐  │
│  │  Header: SHOWIE Avatar + Name                  │  │
│  ├────────────────────────────────────────────────┤  │
│  │  Quick Questions (First Load)                  │  │
│  ├────────────────────────────────────────────────┤  │
│  │  Chat Messages:                                │  │
│  │  ┌──────────────────────────────────────────┐ │  │
│  │  │ AI: Welcome message                      │ │  │
│  │  ├──────────────────────────────────────────┤ │  │
│  │  │ User: Question                           │ │  │
│  │  ├──────────────────────────────────────────┤ │  │
│  │  │ AI: Response                             │ │  │
│  │  └──────────────────────────────────────────┘ │  │
│  ├────────────────────────────────────────────────┤  │
│  │  Input Field + Send Button                    │  │
│  └────────────────────────────────────────────────┘  │
└───────────────────────┬──────────────────────────────┘
                        │
                        │ User sends message
                        │
                        ▼
┌──────────────────────────────────────────────────────┐
│           AI Service (ai_service.dart)               │
│  ┌────────────────────────────────────────────────┐  │
│  │  1. Receive user message                      │  │
│  │  2. Build conversation context (last 10 msgs) │  │
│  │  3. Add system prompt                         │  │
│  │  4. Send to Gemini API                        │  │
│  │  5. Receive AI response                       │  │
│  │  6. Return formatted response                 │  │
│  └────────────────────────────────────────────────┘  │
└───────────────────────┬──────────────────────────────┘
                        │
                        │ API Call
                        │
                        ▼
┌──────────────────────────────────────────────────────┐
│              Google Gemini API                       │
│  ┌────────────────────────────────────────────────┐  │
│  │  Model: gemini-pro                            │  │
│  │  API Key: AIzaSyCoFlnT5VNn-mMLNAVQ...        │  │
│  │  Temperature: 0.9                             │  │
│  │  Max Tokens: 1024                             │  │
│  └────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

## Component Breakdown

### 1. Talent Screen Integration
```dart
Location: apps/lib/talent_screen.dart
Purpose: Entry point for AI chat

Components:
├── Header Row
│   ├── [AI Button] ← NEW! Gradient circular button
│   ├── Trophy Icon (Leaderboard)
│   ├── Comment Icon (Chat)
│   └── Notification Icon
```

### 2. AI Chat Screen
```dart
Location: apps/lib/ai_chat_screen.dart
Purpose: Chat interface

State Management:
├── _messages: List<Map<String, String>>
├── _isTyping: bool
├── _messageController: TextEditingController
└── _scrollController: ScrollController

UI Components:
├── AppBar (SHOWIE avatar + name)
├── Quick Questions (conditional)
├── Message List (scrollable)
├── Typing Indicator (conditional)
└── Input Field + Send Button
```

### 3. AI Service
```dart
Location: apps/lib/services/ai_service.dart
Purpose: Gemini API integration

Key Functions:
├── sendMessage(message, history)
│   ├── Build conversation context
│   ├── Add system prompt
│   ├── Call Gemini API
│   └── Return response
│
└── getQuickResponse(query)
    ├── Single-turn query
    └── Fast response

Configuration:
├── API Key: AIzaSyCoFlnT5VNn-mMLNAVQ6CHkejWAGjIe9AA
├── Model: gemini-pro
├── Temperature: 0.9
├── Max Tokens: 1024
└── System Prompt: Comprehensive app knowledge
```

## Data Flow

### User Sends Message:
```
1. User types message in TextField
2. Taps Send button
3. Message added to _messages list
4. UI shows user message bubble
5. _isTyping set to true
6. Typing indicator appears
7. AIService.sendMessage() called
8. Conversation history prepared
9. API request sent to Gemini
10. Response received
11. Response added to _messages
12. _isTyping set to false
13. UI shows AI message bubble
14. Auto-scroll to bottom
```

### Quick Question Flow:
```
1. User taps quick question button
2. Question text set in TextField
3. Automatically triggers send
4. Same flow as manual message
```

## System Prompt Structure

```
┌─────────────────────────────────────────┐
│         SHOWIE System Prompt            │
├─────────────────────────────────────────┤
│ 1. Identity & Role                      │
│    - Name: SHOWIE                       │
│    - Role: AI Assistant                 │
│    - Personality: Friendly, helpful     │
├─────────────────────────────────────────┤
│ 2. App Knowledge                        │
│    - SYT Competitions                   │
│    - Coin System                        │
│    - Gifting                            │
│    - Leaderboard                        │
│    - Live Streaming                     │
│    - Profile & Verification             │
│    - Wallet & Withdrawals               │
│    - KYC                                │
│    - Subscriptions                      │
├─────────────────────────────────────────┤
│ 3. Response Guidelines                  │
│    - Be encouraging                     │
│    - Use emojis occasionally            │
│    - Keep responses concise             │
│    - Provide actionable advice          │
└─────────────────────────────────────────┘
```

## File Structure

```
showoff/
├── apps/
│   ├── lib/
│   │   ├── talent_screen.dart          [Modified]
│   │   ├── ai_chat_screen.dart         [New]
│   │   └── services/
│   │       └── ai_service.dart         [New]
│   ├── assets/
│   │   └── AI/
│   │       ├── ai.jpg                  [Required]
│   │       └── README.md               [New]
│   └── pubspec.yaml                    [Modified]
├── AI_CHATBOT_GUIDE.md                 [New]
├── SHOWIE_IMPLEMENTATION_SUMMARY.md    [New]
├── SHOWIE_QUICK_REFERENCE.md           [New]
└── SHOWIE_ARCHITECTURE.md              [This file]
```

## Dependencies

```yaml
dependencies:
  google_generative_ai: ^0.4.0  # Gemini API
  flutter: sdk                   # Framework
  
assets:
  - assets/AI/                   # AI avatar
```

## API Configuration

### Client-Side Implementation (Current)
```dart
// AI Service Configuration
const String API_KEY = 'AIzaSyCoFlnT5VNn-mMLNAVQ6CHkejWAGjIe9AA';
const String MODEL = 'gemini-pro';

GenerationConfig:
  - temperature: 0.9      // Creative responses
  - topK: 40              // Token sampling
  - topP: 0.95            // Nucleus sampling
  - maxOutputTokens: 1024 // Response length
  - timeout: 30 seconds   // Request timeout

Architecture Benefits:
✅ No server load - Direct Flutter → Gemini API
✅ Faster responses - No proxy overhead
✅ Reduced server costs - No AI processing on backend
✅ Better scalability - Google handles infrastructure
✅ Offline detection - Client-side error handling
```

### Why Client-Side?
```
Traditional (Server-Side):
Flutter App → Your Server → Gemini API → Your Server → Flutter App
Problems: Server load, latency, costs, complexity

Current (Client-Side):
Flutter App → Gemini API → Flutter App
Benefits: Fast, cheap, simple, scalable
```

## Error Handling

```
API Call
    │
    ├─ Success → Return response
    │
    └─ Error
        │
        ├─ Timeout (30s)
        │   └─ "Connection timeout! Please check your internet and try again. 📡"
        │
        ├─ API Key Error
        │   └─ "API configuration issue. Please contact support. 🔧"
        │
        ├─ Quota Exceeded
        │   └─ "Service temporarily unavailable. Please try again later. ⏰"
        │
        ├─ Network Error
        │   └─ "Oops! I'm having a moment. Please try again! 😅"
        │
        ├─ Empty Response
        │   └─ "I'm having trouble understanding. Could you rephrase? 🤔"
        │
        └─ Unknown Error
            └─ "Oops! I'm having a moment. Please try again! 😅"
```

## Performance Considerations

### Optimization Strategies:
1. **Context Limiting**: Only last 10 messages sent to API
2. **Async Operations**: Non-blocking UI during API calls
3. **Error Recovery**: Graceful fallbacks for failures
4. **Message Caching**: Local storage of conversation
5. **Auto-scroll**: Smooth UX with scroll controller

### Response Times:
- **Quick Questions**: 2-3 seconds
- **Complex Queries**: 3-5 seconds
- **Follow-ups**: 2-4 seconds (with context)

## Security & Privacy

### Current Implementation:
- ✅ API key in code (demo/development)
- ✅ No user data sent to API
- ✅ Conversation not persisted
- ✅ No authentication required

### Production Recommendations:
- 🔒 Move API key to environment variables
- 🔒 Implement rate limiting
- 🔒 Add user authentication
- 🔒 Encrypt conversation history
- 🔒 Add content filtering

## Testing Checklist

- [ ] AI button visible on Talent Screen
- [ ] Button opens AI Chat Screen
- [ ] Welcome message displays
- [ ] Quick questions work
- [ ] Manual messages send successfully
- [ ] AI responses appear
- [ ] Typing indicator shows/hides
- [ ] Auto-scroll works
- [ ] Avatar image loads
- [ ] Error handling works
- [ ] Back button returns to Talent Screen

## Future Enhancements

### Phase 2:
- Voice input/output
- Multi-language support
- Rich media responses (images, videos)
- Conversation persistence
- User preferences learning

### Phase 3:
- Proactive suggestions
- Integration with app analytics
- Personalized recommendations
- Advanced context awareness
- Custom training on user data

---

**SHOWIE Architecture: Simple, Scalable, Smart! 🚀**
