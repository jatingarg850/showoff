# SYT Deep Link Implementation - Complete Guide

## Overview
The SYT (Show Your Talent) deep link feature allows users to share specific talent competition entries via deep links. When someone clicks a shared link, the app opens directly to that specific entry in the SYT reel screen.

## Deep Link Format
```
https://showoff.life/syt/{entryId}
```

Example:
```
https://showoff.life/syt/507f1f77bcf86cd799439011
```

## How It Works

### 1. Share Button in SYT Reel Screen
**File**: `apps/lib/syt_reel_screen.dart`

When a user taps the share button on an SYT entry:

```dart
Future<void> _shareEntry(String entryId, int index) async {
  try {
    final competition = widget.competitions[index];
    final username = competition['user']?['username'] ?? 'user';
    final title = competition['title'] ?? 'Amazing talent';
    final category = competition['category'] ?? 'Talent';

    // Create deep link to specific SYT entry
    final deepLink = 'https://showoff.life/syt/$entryId';

    // Create share text with deep link
    final shareText = '''
🎭 Check out this amazing $category performance by @$username on ShowOff.life!

"$title"

Vote for them in the Show Your Talent competition! 🏆

🔗 Watch & Vote: $deepLink

📱 Download the app:
https://play.google.com/store/apps/details?id=com.showofflife.app

#ShowOffLife #SYT #ShowYourTalent #$category
''';

    // Share using share_plus
    await Share.share(
      shareText,
      subject: 'Vote for $username on ShowOff.life SYT',
    );

    // Track share on backend and grant coins
    final response = await ApiService.shareSYTEntry(entryId);
    if (response['success'] && mounted) {
      final coinsEarned = response['coinsEarned'] ?? 5;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Shared! +$coinsEarned coins earned'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      await _reloadEntryStats(index);
    }
  } catch (e) {
    debugPrint('Error sharing: $e');
  }
}
```

### 2. Deep Link Handling in Splash Screen
**File**: `apps/lib/splash_screen.dart`

The splash screen listens for deep links and parses them:

```dart
void _initializeDeepLinking() {
  try {
    _deepLinkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        if (mounted) {
          debugPrint('🔗 Deep link received: $uri');
          _handleDeepLink(uri.toString());
        }
      },
    );
  } catch (e) {
    debugPrint('Error initializing deep link listener: $e');
  }
}

Map<String, dynamic>? _parseDeepLink(String link) {
  try {
    // Handle showofflife://syt/entryId
    if (link.startsWith('showofflife://syt/')) {
      final entryId = link.replaceFirst('showofflife://syt/', '');
      return {'type': 'syt', 'entryId': entryId};
    }

    // Handle https://showoff.life/syt/entryId
    if (link.contains('/syt/')) {
      final entryId = link.split('/syt/').last.split('?').first;
      return {'type': 'syt', 'entryId': entryId};
    }

    return null;
  } catch (e) {
    debugPrint('Error parsing deep link: $e');
    return null;
  }
}

Future<void> _handleDeepLink(String link) async {
  try {
    final deepLinkData = _parseDeepLink(link);

    if (deepLinkData == null) {
      debugPrint('⚠️ Could not parse deep link: $link');
      return;
    }

    debugPrint('✅ Parsed deep link: $deepLinkData');

    if (!mounted) return;

    // Navigate based on deep link type
    if (deepLinkData['type'] == 'syt') {
      debugPrint('🎭 Navigating to SYT entry: ${deepLinkData['entryId']}');
      // Navigate to talent screen (index 1) which shows SYT entries
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainScreen(
            initialIndex: 1, // Talent screen
            sytEntryId: deepLinkData['entryId'],
          ),
        ),
      );
    }
  } catch (e) {
    debugPrint('Error handling deep link: $e');
  }
}
```

### 3. Navigation Through MainScreen
**File**: `apps/lib/main_screen.dart`

MainScreen receives the `sytEntryId` and passes it to TalentScreen:

```dart
_talentScreen = TalentScreen(
  key: const ValueKey('talent_screen'),
  sytEntryId: widget.sytEntryId,
);
```

### 4. Entry Navigation in TalentScreen
**File**: `apps/lib/talent_screen.dart`

TalentScreen now automatically navigates to the specific entry when `sytEntryId` is provided:

```dart
@override
void initState() {
  super.initState();
  _loadCompetitionInfo();
  _loadEntries();
  _checkUserWeeklySubmission();
  
  // If sytEntryId is provided (from deep link), navigate to it after entries load
  if (widget.sytEntryId != null) {
    _navigateToSYTEntry();
  }
}

Future<void> _navigateToSYTEntry() async {
  // Wait for entries to load
  int attempts = 0;
  while (_entries.isEmpty && attempts < 20) {
    await Future.delayed(const Duration(milliseconds: 100));
    attempts++;
  }

  if (!mounted) return;

  // Find the index of the entry with matching ID
  final entryIndex = _entries.indexWhere(
    (entry) => entry['_id'] == widget.sytEntryId || entry['id'] == widget.sytEntryId,
  );

  if (entryIndex != -1) {
    debugPrint('🎭 Found SYT entry at index: $entryIndex');
    
    // Navigate to SYT reel screen with the found entry
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SYTReelScreen(
          competitions: _entries,
          initialIndex: entryIndex,
        ),
      ),
    );
  } else {
    debugPrint('⚠️ SYT entry not found: ${widget.sytEntryId}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry not found'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
```

## Android Configuration
**File**: `apps/android/app/src/main/AndroidManifest.xml`

Deep link intent filters are configured:

```xml
<!-- Deep linking for SYT entries -->
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <!-- Handle showofflife://syt scheme -->
  <data android:scheme="showofflife" android:host="syt" />
</intent-filter>

<!-- Handle https://showoff.life/syt/* -->
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https" android:host="showoff.life" android:pathPrefix="/syt/" />
</intent-filter>
```

## Complete Flow

1. **User Shares Entry**
   - User taps share button on SYT entry
   - Share dialog opens with deep link: `https://showoff.life/syt/{entryId}`
   - User shares via WhatsApp, SMS, etc.

2. **Recipient Clicks Link**
   - Link is clicked on another device
   - Android system recognizes the deep link
   - App is launched (or brought to foreground)

3. **Deep Link Processing**
   - Splash screen receives the deep link
   - Parses the entry ID from the URL
   - Navigates to MainScreen with `sytEntryId` parameter

4. **Entry Navigation**
   - MainScreen passes `sytEntryId` to TalentScreen
   - TalentScreen loads all entries
   - Finds the matching entry by ID
   - Navigates to SYTReelScreen with the correct `initialIndex`

5. **Display Entry**
   - SYTReelScreen displays the specific entry
   - User can vote, comment, share, etc.

## Features

✅ **Share Button Integration**: One-tap sharing with pre-formatted text
✅ **Deep Link Generation**: Automatic deep link creation with entry ID
✅ **Automatic Navigation**: App opens directly to the shared entry
✅ **Entry Lookup**: Finds entry by ID even if entries are loaded dynamically
✅ **Error Handling**: Shows user-friendly message if entry not found
✅ **Coin Rewards**: Awards 5 coins per share (tracked on backend)
✅ **Multiple Formats**: Supports both `https://` and `showofflife://` schemes

## Testing

### Test on Device

1. **Share an Entry**
   - Open SYT reel screen
   - Tap share button on any entry
   - Share via WhatsApp or SMS to yourself

2. **Click the Link**
   - Click the shared link on the same device
   - App should open directly to that entry

3. **Verify Navigation**
   - Entry should be displayed in SYT reel screen
   - Entry ID should match the shared link

### Test Different Scenarios

**Scenario 1: App Not Installed**
- Link opens in browser
- Shows Play Store link to download app

**Scenario 2: App Installed, Not Running**
- Link launches app
- Navigates to specific entry

**Scenario 3: App Running in Background**
- Link brings app to foreground
- Navigates to specific entry

**Scenario 4: Entry Not Found**
- Shows "Entry not found" message
- User can browse other entries

## Files Modified

1. **apps/lib/syt_reel_screen.dart**
   - Fixed print() → debugPrint()
   - Share button already working correctly

2. **apps/lib/talent_screen.dart**
   - Added `_navigateToSYTEntry()` method
   - Added logic to handle `sytEntryId` in `initState()`
   - Fixed all print() → debugPrint()

3. **apps/lib/main_screen.dart**
   - Already passes `sytEntryId` to TalentScreen

4. **apps/lib/splash_screen.dart**
   - Already handles deep link parsing and navigation

5. **apps/android/app/src/main/AndroidManifest.xml**
   - Already configured with intent filters

## Backend Integration

The backend tracks shares via:
```
POST /api/syt/{entryId}/share
```

Response:
```json
{
  "success": true,
  "coinsEarned": 5,
  "message": "Share tracked successfully"
}
```

## Troubleshooting

### Deep Link Not Opening App
1. Check AndroidManifest.xml has correct intent filters
2. Verify app is signed with correct keystore
3. Test with `adb shell am start -a android.intent.action.VIEW -d "https://showoff.life/syt/test"`

### Entry Not Found
1. Verify entry ID is correct
2. Check entry exists in database
3. Ensure entries are loaded before navigation

### Navigation Not Working
1. Check TalentScreen receives `sytEntryId`
2. Verify entries are loaded before navigation attempt
3. Check entry ID format matches database

## Future Improvements

1. **Web Support**: Add web deep linking support
2. **iOS Support**: Configure iOS deep linking
3. **Analytics**: Track deep link clicks and conversions
4. **Fallback**: Show entry preview if app not installed
5. **Caching**: Cache entry data for faster loading

## Notes

- Deep links work with both HTTP and custom schemes
- Entry ID must be a valid MongoDB ObjectId (24 hex characters)
- Entries are loaded from the current active competition
- Share tracking is done on the backend for analytics
- Users earn 5 coins per share (configurable)
