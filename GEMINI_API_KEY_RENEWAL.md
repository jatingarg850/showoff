# Gemini API Key Renewal Guide

## Issue
```
🔴 AI Service Error: API key expired. Please renew the API key.
🔴 Error Type: InvalidApiKey
```

## Solution: Generate New API Key

### Step 1: Go to Google AI Studio
1. Visit: https://aistudio.google.com/app/apikey
2. Sign in with your Google account

### Step 2: Create New API Key
1. Click **"Create API Key"** button
2. Select your project (or create a new one)
3. Copy the generated API key

### Step 3: Update Your Configuration

#### Option A: Update in Flutter App (Recommended for Development)
Edit `apps/lib/services/ai_service.dart`:
```dart
static const String _apiKey = 'YOUR_NEW_API_KEY_HERE';
```

#### Option B: Update in Backend .env
Edit `server/.env`:
```
GEMINI_API_KEY=YOUR_NEW_API_KEY_HERE
```

### Step 4: Rebuild the App
```bash
flutter clean
flutter pub get
flutter run
```

## Quick Steps (Copy-Paste)

1. **Go to**: https://aistudio.google.com/app/apikey
2. **Click**: "Create API Key"
3. **Copy** the key
4. **Replace** in `apps/lib/services/ai_service.dart` line 4:
   ```dart
   static const String _apiKey = 'P