# Share Functionality Implementation

## Overview
Implemented complete share functionality for Reels, SYT (Show Your Talent) entries, and Referral codes with proper Play Store links.

## What Was Implemented

### 1. Reel Share Functionality
**File:** `apps/lib/reel_screen.dart`

Users can now share reels to external apps (WhatsApp, Instagram, Facebook, etc.) with:
- Username mention
- Caption
- Play Store download link
- Relevant hashtags

**Share Message Format:**
```
Check out this amazing reel by @username on ShowOff.life! 🎬

[Caption if available]

Download the app: https://play.google.com/store/apps/details?id=com.showofflife.app

#ShowOffLife #Reels #Viral
```

### 2. SYT Share Functionality
**File:** `apps/lib/syt_reel_screen.dart`

Users can share SYT competition entries with:
- Performer username
- Entry title
- Category (Dance, Music, Art, etc.)
- Call to action to vote
- Play Store link

**Share Message Format:**
```
🎭 Check out this amazing [Category] performance by @username on ShowOff.life!

"[Entry Title]"

Vote for them in the Show Your Talent competition! 🏆

Download the app: https://play.google.com/store/apps/details?id=com.showofflife.app

#ShowOffLife #SYT #ShowYourTalent #[Category]
```

### 3. Referral Share Functionality
**File:** `apps/lib/referrals_screen.dart`

Users can share their referral code with:
- Personalized referral code
- Benefits list
- Play Store link
- Engaging emojis

**Share Message Format:**
```
🎁 Join ShowOff.life and earn coins!

Use my referral code: [CODE]

✨ What you'll get:
• Bonus coins on signup
• Share your talent with the world
• Compete in SYT competitions
• Win real prizes!

📱 Download now:
https://play.google.com/store/apps/details?id=com.showofflife.app

#ShowOffLife #ReferralCode #EarnCoins
```

## Technical Implementation

### Dependencies Used
- **share_plus: ^10.1.2** - Already installed in pubspec.yaml
- Native share dialog on Android/iOS

### Backend Integration
All share actions are tracked on the backend:
- API call to `/api/posts/:postId/share`
- Share count incremented
- Stats reloaded to show updated counts

### Share Flow
1. User taps share button
2. App creates formatted share message
3. Native share dialog opens
4. User selects app to share to (WhatsApp, Instagram, etc.)
5. Backend tracks the share
6. Share count updates in UI

## Files Modified

### 1. apps/lib/reel_screen.dart
- Added `import 'package:share_plus/share_plus.dart';`
- Updated `_sharePost()` method to use Share.share()
- Added formatted share message with Play Store link
- Maintained backend tracking

### 2. apps/lib/syt_reel_screen.dart
- Added `import 'package:share_plus/share_plus.dart';`
- Updated `_shareEntry()` method to use Share.share()
- Added formatted share message for SYT entries
- Maintained backend tracking

### 3. apps/lib/referrals_screen.dart
- Updated `_shareReferralCode()` method
- Enhanced share message with benefits list
- Updated Play Store link
- Added engaging emojis and formatting

## Testing Instructions

### Test Reel Share:
1. Open the app
2. Go to Reels tab
3. Tap the share button on any reel
4. Verify share dialog opens
5. Share to WhatsApp/Instagram
6. Verify message contains:
   - Username
   - Caption
   - Play Store link
   - Hashtags

### Test SYT Share:
1. Go to SYT tab
2. View any competition entry
3. Tap the share button
4. Verify share dialog opens
5. Share to any app
6. Verify message contains:
   - Performer name
   - Entry title
   - Category
   - Vote call-to-action
   - Play Store link

### Test Referral Share:
1. Go to Profile → Settings → Referrals & Invites
2. Tap "Invite Friends" button
3. Verify share dialog opens
4. Share to any app
5. Verify message contains:
   - Referral code
   - Benefits list
   - Play Store link
   - Emojis

## Share Button Locations

### Reels:
- Right side action buttons
- Share icon with count
- Located below comment button

### SYT:
- Right side action buttons
- Share icon with count
- Located below bookmark button

### Referral:
- Settings → Referrals & Invites
- "Invite Friends" button
- Below referral code display

## Backend API

### Share Endpoint:
```
POST /api/posts/:postId/share
Headers: Authorization: Bearer {token}
Body: { "shareType": "link" }
Response: { "success": true }
```

### Stats Update:
After sharing, the app reloads post stats to show updated share count.

## Benefits

### For Users:
- ✅ Easy sharing to any app
- ✅ Professional share messages
- ✅ Direct Play Store links
- ✅ Helps grow their audience

### For App:
- ✅ Viral growth through shares
- ✅ Play Store link in every share
- ✅ Tracked share metrics
- ✅ Professional branding

### For Content Creators:
- ✅ Promote their content
- ✅ Get more views/votes
- ✅ Build their following
- ✅ Increase engagement

## Share Analytics

The backend tracks:
- Total shares per post
- Share count displayed in UI
- Share trends over time
- Most shared content

## Success Indicators

When working correctly:
- ✅ Share button opens native share dialog
- ✅ Message is pre-formatted with all details
- ✅ Play Store link is included
- ✅ Share count increments after sharing
- ✅ Works on all platforms (WhatsApp, Instagram, Facebook, etc.)

## Common Share Destinations

Users can share to:
- WhatsApp
- Instagram Stories/DMs
- Facebook
- Twitter/X
- Telegram
- SMS
- Email
- Copy to clipboard
- Any app that accepts text sharing

## Future Enhancements

Potential improvements:
- Add video/image sharing (not just text)
- Deep links to specific content
- Share to Instagram Stories with sticker
- Custom share images/thumbnails
- Share analytics dashboard
- Reward users for sharing

## Play Store Link

All shares include:
```
https://play.google.com/store/apps/details?id=com.showofflife.app
```

This is the official ShowOff.life app on Google Play Store.

## Related Documentation

- `share_plus` package: https://pub.dev/packages/share_plus
- Android Share Intent: https://developer.android.com/training/sharing/send
- iOS Share Sheet: https://developer.apple.com/design/human-interface-guidelines/sharing

## Conclusion

The share functionality is now fully implemented and working across all major features (Reels, SYT, Referrals). Users can easily share content to grow the platform and their own audience.
