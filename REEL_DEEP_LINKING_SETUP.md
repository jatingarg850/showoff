# Reel Deep Linking Setup

## Overview
This document explains how reel sharing with deep linking works in the ShowOff.life app.

## How It Works

### 1. Share Flow
When a user taps the share button on a reel:
1. App generates a deep link: `https://showofflife.app/reel/{postId}`
2. Share text includes the deep link along with Play Store link
3. User shares via WhatsApp, Instagram, etc.

### 2. Link Click Flow
When someone clicks the shared link:

**On Mobile (App Installed):**
1. Link opens in browser
2. Server renders a page with meta tags and deep link redirect
3. Page automatically redirects to `showofflife://reel/{postId}`
4. Android Intent Filter catches the deep link
5. App opens and navigates to the specific reel

**On Mobile (App Not Installed):**
1. Link opens in browser
2. Server renders a page with meta tags
3. User sees "Open in ShowOff.life" button
4. If they click it, redirects to Play Store
5. After installing, they can click the link again

**On Desktop/Web:**
1. Link opens in browser
2. Server renders a page with social media meta tags
3. Shows preview of the reel
4. User can download the app from the page

## Server Setup

### Route: `/reel/:postId`
- **File**: `server/server.js`
- **Handler**: Fetches post details and renders deep-link-reel.ejs
- **Response**: HTML page with:
  - Open Graph meta tags (for social sharing preview)
  - Twitter Card meta tags
  - Deep link redirect
  - Fallback to Play Store

### Templates
- **deep-link-reel.ejs**: Success page with reel preview
- **deep-link-error.ejs**: Error page if reel not found

## Flutter App Setup

### Dependencies
- `uni_links: ^0.0.2` - Handles deep link listening

### Configuration

#### AndroidManifest.xml
Added intent filters to MainActivity:
```xml
<!-- Handle showofflife:// scheme -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="showofflife" android:host="reel" />
</intent-filter>

<!-- Handle https://showofflife.app/reel/* -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="showofflife.app" android:pathPrefix="/reel/" />
</intent-filter>
```

#### main.dart
- Listens for deep links using `uni_links`
- Parses deep link format: `showofflife://reel/{postId}`
- Navigates to MainScreen with `initialPostId` parameter
- Handles both initial deep link and incoming deep links

### Deep Link Handling
```dart
void _handleDeepLink(String link) {
  // Parse: showofflife://reel/postId
  if (link.contains('reel/')) {
    final postId = link.split('reel/').last;
    // Navigate to reel
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MainScreen(
          initialIndex: 0,
          initialPostId: postId,
        ),
      ),
      (route) => false,
    );
  }
}
```

## Testing

### Test on Android Emulator
1. Share a reel - it will generate: `https://10.0.2.2:3000/reel/{postId}`
2. Click the link in browser
3. App should open and navigate to the reel

### Test on Physical Device
1. Share a reel - it will generate: `https://showofflife.app/reel/{postId}`
2. Click the link in browser
3. App should open and navigate to the reel

### Test Without App Installed
1. Click a shared reel link
2. Should see "Open in ShowOff.life" button
3. Clicking it redirects to Play Store

## Share Link Format

The share link includes:
- **Deep link**: `https://showofflife.app/reel/{postId}`
- **Creator**: `@{username}`
- **Caption**: Reel caption (if available)
- **Play Store link**: For users without the app
- **Hashtags**: #ShowOffLife #Reels #Viral

Example:
```
Check out this amazing reel by @john_doe on ShowOff.life! 🎬

This is an awesome reel caption

🔗 Watch now: https://showofflife.app/reel/507f1f77bcf86cd799439011

📱 Download the app:
https://play.google.com/store/apps/details?id=com.showofflife.app

#ShowOffLife #Reels #Viral
```

## Future Enhancements

1. **iOS Support**: Add URL schemes for iOS
2. **Web Preview**: Enhance the web preview page with video thumbnail
3. **Analytics**: Track deep link clicks and conversions
4. **Referral Tracking**: Add referral code to deep links
5. **Social Media Optimization**: Add more meta tags for better previews

## Troubleshooting

### Deep link not opening app
- Ensure AndroidManifest.xml has correct intent filters
- Check that `uni_links` package is properly installed
- Verify deep link format matches the handler

### App opens but doesn't navigate to reel
- Check that `initialPostId` is being passed to MainScreen
- Verify reel ID is valid in the database
- Check ReelScreen handles `initialPostId` parameter

### Server page not loading
- Ensure `/reel/:postId` route is added to server.js
- Check that EJS templates exist in views folder
- Verify Post model can be queried by ID

## Files Modified

### Server
- `server/server.js` - Added `/reel/:postId` route
- `server/views/deep-link-reel.ejs` - Created
- `server/views/deep-link-error.ejs` - Created

### Flutter App
- `apps/lib/main.dart` - Added deep link listener
- `apps/pubspec.yaml` - Added uni_links dependency
- `apps/android/app/src/main/AndroidManifest.xml` - Added intent filters
- `apps/lib/main_screen.dart` - Already supports initialPostId parameter
- `apps/lib/reel_screen.dart` - Already supports initialPostId parameter
