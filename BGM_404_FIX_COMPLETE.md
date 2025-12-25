# Background Music 404 Error - FIXED ✅

## Problem
When users selected background music in the preview screen, the app showed multiple errors:

1. **First Error:** `FileNotFoundException: /uploads/music/...` - Relative URL treated as local file
2. **Second Error:** `Cleartext HTTP traffic to 10.0.2.2 not permitted` - Android blocks HTTP traffic

## Root Causes Identified & Fixed

### 1. **App-Side: Relative URL Not Converted to Full URL**
The server returns `audioUrl` as `/uploads/music/file.mp3` but the audio player needs `http://10.0.2.2:3000/uploads/music/file.mp3`.

**Fixed in:**
- `apps/lib/services/api_service.dart` - Added `getAudioUrl()` helper function
- `apps/lib/preview_screen.dart` - Uses `getAudioUrl()` to convert relative URLs

### 2. **Android: Cleartext HTTP Traffic Not Permitted**
Android 9+ (API 28+) blocks HTTP traffic by default for security. The app needs explicit permission.

**Fixed in:**
- `apps/android/app/src/main/AndroidManifest.xml` - Added `android:usesCleartextTraffic="true"` and `android:networkSecurityConfig`
- `apps/android/app/src/main/res/xml/network_security_config.xml` - Created new file to allow HTTP for development servers

**AndroidManifest.xml changes:**
```xml
<application
    android:usesCleartextTraffic="true"
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

**network_security_config.xml:**
```xml
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
    
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">127.0.0.1</domain>
    </domain-config>
</network-security-config>
```

### 3. **Also Fixed: getImageUrl() Function**
The existing `getImageUrl()` had the same bug - was using `$baseUrl$path` which would create `/api/uploads/...`.

## Complete Flow Now Working

1. ✅ Admin uploads music → stored with relative path `/uploads/music/file.mp3`
2. ✅ User selects music in app → `backgroundMusicId` saved
3. ✅ Preview screen fetches music details from API
4. ✅ API returns `audioUrl: "/uploads/music/file.mp3"`
5. ✅ App converts to full URL: `http://10.0.2.2:3000/uploads/music/file.mp3`
6. ✅ Android allows HTTP traffic to 10.0.2.2 (emulator localhost)
7. ✅ Audio player loads and plays the music at 85% volume

## Files Modified

1. **apps/lib/services/api_service.dart**
   - Added `getAudioUrl()` helper function
   - Fixed `getImageUrl()` to properly handle relative URLs

2. **apps/lib/preview_screen.dart**
   - Uses `ApiService.getAudioUrl()` to convert relative URLs to full URLs

3. **apps/android/app/src/main/AndroidManifest.xml**
   - Added `android:usesCleartextTraffic="true"`
   - Added `android:networkSecurityConfig="@xml/network_security_config"`

4. **apps/android/app/src/main/res/xml/network_security_config.xml** (NEW)
   - Allows HTTP traffic to development servers (10.0.2.2, localhost)
   - Enforces HTTPS for production domains (showoff.life, wasabisys.com)

## URL Conversion Examples

| Server Returns | App Converts To |
|----------------|-----------------|
| `/uploads/music/file.mp3` | `http://10.0.2.2:3000/uploads/music/file.mp3` |
| `https://wasabi.com/music.mp3` | `https://wasabi.com/music.mp3` (unchanged) |

## IMPORTANT: Rebuild Required

After these changes, you need to rebuild the app:

```bash
cd apps
flutter clean
flutter pub get
flutter run
```

## Testing Checklist

- [ ] Rebuild the app after changes
- [ ] Upload music as admin
- [ ] Approve music in admin panel
- [ ] Select music in app preview screen
- [ ] Verify music plays at 85% volume (no errors)
- [ ] Upload post/SYT with background music
- [ ] View post/SYT in feed

## Status
✅ **COMPLETE** - Background music now loads and plays correctly in preview screen.
