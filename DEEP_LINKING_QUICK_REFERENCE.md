# Deep Linking Quick Reference

## What Was Fixed
Deep links now navigate directly to the correct screen with the specific content, instead of going through intermediate screens.

## How It Works

### SYT Reel Deep Link
```
User shares SYT reel
    ↓
Deep link: https://showoff.life/syt/{entryId}
    ↓
App receives link
    ↓
SplashScreen fetches entry data
    ↓
Navigate directly to SYTReelScreen
    ↓
User sees the specific reel
```

### Regular Reel Deep Link
```
User shares regular reel
    ↓
Deep link: https://showoff.life/reel/{postId}
    ↓
App receives link
    ↓
SplashScreen fetches post data
    ↓
Navigate directly to ReelScreen
    ↓
User sees the specific reel
```

## Code Changes Summary

### 1. SplashScreen (apps/lib/splash_screen.dart)
- Added imports for ReelScreen, SYTReelScreen, and ApiService
- Updated `_handleDeepLink()` to:
  - Fetch entry/post data before navigating
  - Navigate directly to the correct screen
  - Fallback to MainScreen if fetch fails

### 2. ApiService (apps/lib/services/api_service.dart)
- Added `getSingleSYTEntry(entryId)` method
- Calls `GET /api/syt/entry/{entryId}` endpoint

### 3. Backend
- No changes needed (endpoints already exist)
- `GET /api/syt/entry/:id` - returns single SYT entry
- `GET /api/posts/:id` - returns single post

## Testing

### Test SYT Deep Link
1. Open SYT reel screen
2. Tap share button
3. Share the link
4. Click the link (or paste in browser and open with app)
5. Should navigate directly to SYTReelScreen with that reel

### Test Regular Reel Deep Link
1. Open reel screen
2. Tap share button
3. Share the link
4. Click the link (or paste in browser and open with app)
5. Should navigate directly to ReelScreen with that reel

## Troubleshooting

### Deep link not working
- Check if app is installed
- Verify deep link format: `https://showoff.life/syt/{entryId}` or `https://showoff.life/reel/{postId}`
- Check if entry/post ID is valid
- Check app logs for errors

### Wrong screen opens
- Verify the deep link type (syt vs reel)
- Check if entry/post exists in database
- Check if user is authenticated

### Entry/post not found
- Verify the ID is correct
- Check if entry/post is approved and active
- Check if user has permission to view

## Files Modified
1. `apps/lib/splash_screen.dart` - Deep link handler
2. `apps/lib/services/api_service.dart` - API method for fetching single entry

## Files Not Modified (Already Correct)
1. `apps/lib/syt_reel_screen.dart` - Share function already uses correct deep link
2. `apps/lib/reel_screen.dart` - Share function already uses correct deep link
3. `server/routes/sytRoutes.js` - Endpoints already exist
4. `server/controllers/sytController.js` - getSingleEntry already implemented
