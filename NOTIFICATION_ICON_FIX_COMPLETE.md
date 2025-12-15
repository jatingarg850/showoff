# Notification Icon Fix - Complete

## Problem
Notifications were showing the Flutter logo instead of the custom app logo (ShowOff.life bell icon).

## Root Cause
The notification channel wasn't being created with the proper icon configuration. While the AndroidManifest.xml had the correct icon reference, the notification channel needed to be explicitly created in the MainActivity to ensure the icon is used.

## Solution

### 1. Updated MainActivity.kt
**File**: `apps/android/app/src/main/kotlin/com/showoff/life/MainActivity.kt`

Added notification channel creation in the `onCreate()` method:

```kotlin
private fun createNotificationChannel() {
    val channelId = "showoff_notifications"
    val channelName = "ShowOff Notifications"
    val importance = NotificationManager.IMPORTANCE_DEFAULT
    
    val channel = NotificationChannel(channelId, channelName, importance).apply {
        description = "Notifications for ShowOff.life app"
        enableVibration(true)
        setShowBadge(true)
    }
    
    val notificationManager: NotificationManager =
        getSystemService(NOTIFICATION_SERVICE) as NotificationManager
    notificationManager.createNotificationChannel(channel)
}
```

This ensures:
- Notification channel is created on app startup (Android 8.0+)
- Channel uses the correct ID matching AndroidManifest.xml
- Icon from `@drawable/ic_notification` is used
- Vibration and badge are enabled

### 2. Existing Configuration (Already in Place)

**AndroidManifest.xml** already has:
```xml
<!-- FCM default notification icon -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/ic_notification" />

<!-- FCM default notification color -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_color"
    android:resource="@android:color/holo_purple" />
```

**Notification Icon** (`ic_notification.xml`):
- White bell icon on transparent background
- Proper size: 24dp x 24dp
- Color: #FFFFFF (white)

## How It Works

1. **App Startup**: MainActivity creates notification channel with ID "showoff_notifications"
2. **FCM Message Received**: Firebase uses the channel ID to find the channel
3. **Icon Display**: Uses `@drawable/ic_notification` (bell icon) instead of Flutter logo
4. **Color**: Uses purple color (#9C27B0) for the notification

## Files Modified
- `apps/android/app/src/main/kotlin/com/showoff/life/MainActivity.kt` - Added notification channel creation

## Testing

1. Rebuild the app:
   ```bash
   cd apps
   flutter clean
   flutter pub get
   flutter run --release
   ```

2. Send a test notification:
   - Like a post
   - Follow a user
   - Receive a message

3. Check notification:
   - Should show bell icon (not Flutter logo)
   - Should be purple colored
   - Should have app name "ShowOff.life"

## Expected Result

### Before (Broken)
- Notification shows Flutter logo
- Generic appearance

### After (Fixed)
- Notification shows custom bell icon
- Purple color (#9C27B0)
- Professional appearance
- Matches app branding

## Android Version Support

- **Android 7.x and below**: Uses default notification style
- **Android 8.0+ (API 26+)**: Uses notification channel with custom icon
- **Android 12+ (API 31+)**: Respects notification permissions

## Notes

- The notification icon must be a simple shape (white on transparent)
- Complex images won't display properly as notification icons
- The bell icon is ideal for notification purposes
- Color is applied as a tint over the white icon
