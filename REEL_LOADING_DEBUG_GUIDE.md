# Reel Loading Debug Guide

## Issue
Reels are not loading in the app.

## Root Cause Analysis
The issue was likely caused by:
1. Silent API failures not being logged
2. Ad settings loading potentially blocking the feed load
3. Lack of debug logging to identify where the failure occurs

## Fixes Applied

### 1. Fixed Ad Settings Loading (`apps/lib/reel_screen.dart`)
**Before:**
```dart
_loadAdSettings();  // Not awaited, could fail silently
```

**After:**
```dart
try {
  await _loadAdSettings();  // Properly awaited with error handling
} catch (e) {
  debugPrint('Error loading ad settings: $e');
}
```

**Why:** Ensures ad settings loading doesn't block feed loading and errors are caught.

### 2. Added Debug Logging to Feed Loading (`apps/lib/reel_screen.dart`)
Added comprehensive debug logs to identify where the loading fails:
- `📺 Feed response: $response` - Logs the full API response
- `❌ Feed API failed: ${response['message']}` - Logs API errors
- `📺 Loaded ${posts.length} posts` - Confirms posts were fetched
- `❌ Error loading feed: $e` - Logs any exceptions

### 3. Fixed Missing Import (`apps/lib/services/api_service.dart`)
Added `import 'package:flutter/foundation.dart'` for debugPrint support.

## How to Diagnose

### Check the Logs
1. Run the app with `flutter run -v` to see verbose logs
2. Look for these patterns:
   - `📺 Feed response:` - Shows what the API returned
   - `❌ Feed API failed:` - Shows API errors
   - `❌ Error loading feed:` - Shows exceptions
   - `✅ Ad settings loaded:` - Shows ad settings were loaded

### Common Issues and Solutions

**Issue: "Feed API failed: Unauthorized"**
- **Cause:** User not authenticated or token expired
- **Solution:** Check if user is logged in, refresh token

**Issue: "Feed API failed: Not Found"**
- **Cause:** API endpoint doesn't exist or wrong URL
- **Solution:** Verify API_CONFIG.baseUrl is correct

**Issue: "Error loading feed: Connection refused"**
- **Cause:** Server is not running or unreachable
- **Solution:** Start the server and verify network connectivity

**Issue: "Loaded 0 posts"**
- **Cause:** No posts in database or feed is empty
- **Solution:** Create some test posts first

**Issue: "No Reels Yet" screen shows**
- **Cause:** Feed loaded successfully but is empty
- **Solution:** Click "Retry" button or create posts

## Testing Checklist

- [ ] App starts without crashing
- [ ] Loading spinner appears briefly
- [ ] Reels load and display
- [ ] Videos play when tapped
- [ ] Can scroll between reels
- [ ] Ad settings load without errors
- [ ] Ads show after configured number of reels
- [ ] Check console logs for any error messages

## Files Modified
1. `apps/lib/reel_screen.dart` - Added debug logging and fixed ad settings loading
2. `apps/lib