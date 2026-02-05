# Firebase Push Notifications with App Logo

## Overview
The Firebase push notification system has been updated to display the app logo (launcher_icon) in all notifications. The implementation now supports both small icons and large icons with optional image attachments.

## Changes Made

### 1. Push Notification Service (`apps/lib/services/push_notification_service.dart`)

#### Icon Configuration
Changed from generic `@mipmap/ic_launcher` to app's actual logo:

```dart
// Android initialization settings - use app logo
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/launcher_icon');
```

#### Notification Details with Logo
Updated notification display to include both small and large icons:

```dart
final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'showoff_notifications',
      'ShowOff.life Notifications',
      channelDescription: 'Notifications for likes, comments, and follows',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/launcher_icon',  // Small icon (notification bar)
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),  // Large icon
      color: const Color(0xFF9C27B0),  // Purple brand color
      styleInformation: imageUrl != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(imageUrl),
              contentTitle: title,
              summaryText: body,
              largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
            )
          : null,
    );
```

#### Updated Notification Methods
All notification methods now support optional image URLs:

```dart
// Example: Like notification with optional image
Future<void> showLikeNotification({
  required String username,
  required String postId,
  String? imageUrl,  // Optional image
}) async {
  await showNotification(
    title: '❤️ New Like',
    body: '$username liked your Show',
    payload: 'like:$postId',
    imageUrl: imageUrl,
  );
}
```

### 2. Android Manifest Configuration
The AndroidManifest.xml already has proper FCM configuration:

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

## Notification Types with Logo

All notification types now display the app logo:

### 1. Like Notification
```dart
await PushNotificationService.instance.showLikeNotification(
  username: 'John Doe',
  postId: '12345',
  imageUrl: 'path/to/image.jpg', // Optional
);
```
**Display**: App logo + "❤️ New Like" + "John Doe liked your Show"

### 2. Comment Notification
```dart
await PushNotificationService.instance.showCommentNotification(
  username: 'Jane Smith',
  comment: 'Great content!',
  postId: '12345',
  imageUrl: 'path/to/image.jpg', // Optional
);
```
**Display**: App logo + "💬 New Comment" + "Jane Smith: Great content!"

### 3. Follow Notification
```dart
await PushNotificationService.instance.showFollowNotification(
  username: 'Alex Johnson',
  userId: '67890',
  imageUrl: 'path/to/image.jpg', // Optional
);
```
**Display**: App logo + "👤 New Follower" + "Alex Johnson started following you"

### 4. Achievement Notification
```dart
await PushNotificationService.instance.showAchievementNotification(
  title: 'First Post',
  description: 'You posted your first Show!',
  imageUrl: 'path/to/image.jpg', // Optional
);
```
**Display**: App logo + "🏆 Achievement Unlocked!" + "First Post: You posted your first Show!"

### 5. Gift Notification
```dart
await PushNotificationService.instance.showGiftNotification(
  username: 'Mike Brown',
  amount: 5,
  giftType: 'coins',
  imageUrl: 'path/to/image.jpg', // Optional
);
```
**Display**: App logo + "🎁 Gift Received" + "Mike Brown sent you 5 coins"

### 6. Vote Notification
```dart
await PushNotificationService.instance.showVoteNotification(
  username: 'Sarah Wilson',
  entryId: '54321',
  imageUrl: 'path/to/image.jpg', // Optional
);
```
**Display**: App logo + "🗳️ New Vote" + "Sarah Wilson voted for your SYT entry"

### 7. System Notification
```dart
await PushNotificationService.instance.showSystemNotification(
  title: 'Maintenance',
  message: 'App will be down for maintenance at 2 AM',
  imageUrl: 'path/to/image.jpg', // Optional
);
```
**Display**: App logo + "📢 Maintenance" + "App will be down for maintenance at 2 AM"

## Icon Display Locations

### Small Icon (Notification Bar)
- **Location**: Top-left of notification in status bar
- **Size**: 24x24 dp (automatically scaled)
- **Icon**: `@mipmap/launcher_icon`
- **Color**: Applied from `android:color/holo_purple`

### Large Icon (Notification Drawer)
- **Location**: Left side of notification in drawer
- **Size**: 64x64 dp (automatically scaled)
- **Icon**: `@mipmap/launcher_icon`
- **Display**: When notification is expanded

### Big Picture (Optional)
- **Location**: Full width of notification
- **Size**: 256x256 dp (automatically scaled)
- **Image**: Custom image URL (if provided)
- **Display**: When notification is expanded and image is available

## Firebase Cloud Messaging Integration

When sending notifications from Firebase Console or backend:

### Payload Format
```json
{
  "notification": {
    "title": "❤️ New Like",
    "body": "John Doe liked your Show"
  },
  "data": {
    "type": "like",
    "postId": "12345",
    "imageUrl": "https://example.com/image.jpg"
  }
}
```

### Backend Implementation
```javascript
// Example: Node.js backend sending notification
const message = {
  notification: {
    title: '❤️ New Like',
    body: 'John Doe liked your Show',
  },
  data: {
    type: 'like',
    postId: '12345',
    imageUrl: 'https://example.com/image.jpg',
  },
  android: {
    priority: 'high',
    notification: {
      icon: '@mipmap/launcher_icon',
      color: '#9C27B0',
    },
  },
  token: userFCMToken,
};

await admin.messaging().send(message);
```

## Notification Appearance

### Android 12+ (Material You)
- App logo displayed with adaptive icon support
- Notification color: Purple (#9C27B0)
- Large icon shown in expanded view
- Big picture image (if provided) shown in expanded view

### Android 11 and Below
- App logo displayed as-is
- Notification color: Purple (#9C27B0)
- Large icon shown in notification drawer
- Big picture image (if provided) shown in expanded view

## Debugging

### Console Logs
- `✅ Push notification service initialized` - Service ready
- `✅ Push notification sent: [title]` - Notification sent successfully
- `❌ Error showing notification: [error]` - Error occurred
- `Notification tapped with payload: [payload]` - User tapped notification

### Testing Notifications

#### Local Testing
```dart
// Test like notification with logo
await PushNotificationService.instance.showLikeNotification(
  username: 'Test User',
  postId: 'test123',
);
```

#### Firebase Console Testing
1. Go to Firebase Console
2. Select your project
3. Go to Cloud Messaging
4. Click "Send your first message"
5. Enter notification details
6. Select target device
7. Send

## Icon Requirements

### Launcher Icon
- **File**: `apps/android/app/src/main/res/mipmap/launcher_icon.png`
- **Sizes**: 
  - mdpi: 48x48 px
  - hdpi: 72x72 px
  - xhdpi: 96x96 px
  - xxhdpi: 144x144 px
  - xxxhdpi: 192x192 px
- **Format**: PNG with transparency
- **Color**: Should work on both light and dark backgrounds

### Notification Icon (Optional)
- **File**: `apps/android/app/src/main/res/drawable/ic_notification.png`
- **Size**: 24x24 px
- **Format**: PNG with transparency
- **Color**: White or light color (system applies tint)

## Best Practices

1. **Always Use App Logo**: Ensures brand consistency
2. **Provide Images When Relevant**: Use `imageUrl` for posts, profiles, etc.
3. **Keep Titles Short**: Max 50 characters recommended
4. **Keep Body Short**: Max 150 characters recommended
5. **Use Emojis**: Makes notifications more engaging
6. **Test on Real Device**: Emulator may not show all features
7. **Check Permissions**: Ensure notification permission is granted

## Troubleshooting

### Logo Not Showing
1. Verify `launcher_icon` exists in mipmap folders
2. Check AndroidManifest.xml configuration
3. Ensure app has notification permission
4. Try clearing app cache and reinstalling

### Wrong Color
1. Check `android:color/holo_purple` is defined
2. Verify color value in AndroidManifest.xml
3. Try using explicit color code instead

### Image Not Showing
1. Verify image URL is accessible
2. Check image format (PNG, JPG supported)
3. Ensure image size is reasonable (< 1MB)
4. Test with different image URLs

## Files Modified

1. **apps/lib/services/push_notification_service.dart**
   - Changed icon from `@mipmap/ic_launcher` to `@mipmap/launcher_icon`
   - Added `largeIcon` configuration
   - Added `BigPictureStyleInformation` for image support
   - Updated all notification methods to support `imageUrl` parameter
   - Changed `print()` to `debugPrint()`

2. **apps/android/app/src/main/AndroidManifest.xml**
   - Already configured with proper FCM settings
   - No changes needed

## Next Steps

1. **Test Notifications**: Send test notifications from Firebase Console
2. **Monitor Delivery**: Check Firebase Analytics for notification metrics
3. **Optimize Images**: Ensure images are properly sized and compressed
4. **User Testing**: Get feedback on notification appearance
5. **Analytics**: Track notification engagement and click-through rates

## Support

For issues or questions:
- Check Firebase Console for delivery status
- Review console logs for error messages
- Verify icon files exist in mipmap folders
- Test on real Android device
- Check notification permissions are granted
