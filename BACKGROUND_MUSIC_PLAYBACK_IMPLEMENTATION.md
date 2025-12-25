# Background Music Playback Implementation

## ✅ Complete Implementation

The background music playback system has been fully implemented with the following components:

---

## 📦 Dependencies Added

**pubspec.yaml**
```yaml
just_audio: ^0.9.36
```

This is the most popular and reliable audio player for Flutter with support for:
- Network streaming
- Local file playback
- Volume control
- Looping
- Seeking
- Multiple audio formats

---

## 🎵 Background Music Service

**File:** `apps/lib/services/background_music_service.dart`

### Features:
- Singleton pattern for single instance
- Play background music from URL
- Stop/Pause/Resume controls
- Volume control (0.0 to 1.0)
- Auto-looping when music ends
- Stream listeners for state changes
- Comprehensive error handling
- Detailed logging

### Key Methods:
```dart
// Play music
await musicService.playBackgroundMusic(audioUrl, musicId);

// Stop music
await musicService.stopBackgroundMusic();

// Pause music
await musicService.pauseBackgroundMusic();

// Resume music
await musicService.resumeBackgroundMusic();

// Set volume (0.0 to 1.0)
await musicService.setVolume(0.5);

// Check if playing
bool isPlaying = musicService.isPlaying();

// Get current music ID
String? musicId = musicService.getCurrentMusicId();
```

---

## 🎬 Preview Screen Integration

**File:** `apps/lib/preview_screen.dart`

### Changes Made:

1. **Import Background Music Service**
   ```dart
   import 'services/background_music_service.dart';
   ```

2. **Load Music in initState**
   ```dart
   if (widget.backgroundMusicId != null) {
     _loadBackgroundMusic();
   }
   ```

3. **New Method: _loadBackgroundMusic()**
   - Fetches music details from API
   - Gets audio URL
   - Plays background music
   - Handles errors gracefully

4. **Stop Music in dispose()**
   ```dart
   final musicService = BackgroundMusicService();
   await musicService.stopBackgroundMusic();
   ```

---

## 🔌 API Service Update

**File:** `apps/lib/services/api_service.dart`

### New Method: getMusic()
```dart
static Future<Map<String, dynamic>> getMusic(String musicId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/music/$musicId'),
    headers: await _getHeaders(),
  );
  // Returns music details including audioUrl
}
```

---

## 🔄 Complete Flow

### Step 1: User Selects Music
```
MusicSelectionScreen
  ↓
  User selects music
  ↓
  backgroundMusicId passed to CameraScreen
```

### Step 2: Video Recording
```
CameraScreen
  ↓
  User records video
  ↓
  backgroundMusicId passed to UploadContentScreen
```

### Step 3: Preview with Music
```
PreviewScreen
  ↓
  initState() called
  ↓
  _loadBackgroundMusic() called
  ↓
  Fetch music details from API
  ↓
  Get audioUrl from music document
  ↓
  BackgroundMusicService.playBackgroundMusic(audioUrl, musicId)
  ↓
  Music plays at 50% volume
  ↓
  Video plays simultaneously
  ↓
  User hears both video and music
```

### Step 4: Upload
```
User clicks "Upload"
  ↓
  dispose() called
  ↓
  Background music stopped
  ↓
  Video uploaded with musicId reference
```

---

## 🎚️ Audio Configuration

### Volume Levels
- **Background Music:** 50% (0.5)
- **Video Audio:** 100% (1.0)
- **Result:** Balanced mix of both

### Looping
- Music loops automatically when it ends
- Continues playing until user uploads or navigates away

### Format Support
- MP3
- WAV
- AAC
- OGG
- FLAC
- And more

---

## 🧪 Testing Checklist

### Setup
- [ ] Run `flutter pub get` to install just_audio
- [ ] Rebuild app

### Music Playback
- [ ] Record video
- [ ] Select music from list
- [ ] Go to preview screen
- [ ] Verify music badge shows
- [ ] Verify music plays in background
- [ ] Verify video audio also plays
- [ ] Verify both are audible together

### Volume Control
- [ ] Music plays at 50% volume
- [ ] Video audio is at 100%
- [ ] Mix is balanced

### Music Looping
- [ ] If music is shorter than video, it loops
- [ ] Looping is seamless

### Stop/Cleanup
- [ ] Navigate back from preview
- [ ] Music stops playing
- [ ] No audio continues after leaving

### Upload
- [ ] Click upload
- [ ] Music stops
- [ ] Video uploads with musicId
- [ ] Post saved with music reference

---

## 🔧 Troubleshooting

### Music Not Playing

**Check:**
1. Music ID is being passed correctly
2. API endpoint returns valid audioUrl
3. Audio URL is accessible
4. Network connection is working

**Debug:**
```dart
// Check logs
print('🎵 Loading background music: ${widget.backgroundMusicId}');
print('🎵 Music URL: $audioUrl');
print('✅ Background music loaded and playing');
```

### Audio Not Audible

**Check:**
1. Device volume is not muted
2. Volume is set to 0.5 (50%)
3. Audio URL is valid
4. File format is supported

**Fix:**
- Increase volume in BackgroundMusicService
- Check audio file format
- Verify URL is accessible

### Music Stops Unexpectedly

**Check:**
1. Network connection is stable
2. Audio file is not corrupted
3. Device has enough memory

**Fix:**
- Check network logs
- Verify audio file
- Monitor memory usage

### Music Doesn't Loop

**Check:**
1. processingStateStream listener is working
2. seek(Duration.zero) is called
3. play() is called after seek

**Fix:**
- Check BackgroundMusicService logs
- Verify audio player state

---

## 📊 Database Verification

### Music Document
```javascript
{
  _id: ObjectId,
  title: "Song Title",
  artist: "Artist Name",
  audioUrl: "/uploads/music/music-123.mp3",  // This is used for playback
  duration: 180,
  isApproved: true,
  isActive: true
}
```

### Post with Music
```javascript
{
  _id: ObjectId,
  backgroundMusic: ObjectId,  // Reference to Music
  mediaUrl: "https://s3.../video.mp4",
  createdAt: Date
}
```

---

## 🎯 Key Features

✅ **Playback**
- Play music from URL
- Auto-looping
- Seamless mixing with video audio

✅ **Control**
- Play/Pause/Resume
- Volume control
- Stop on dispose

✅ **Error Handling**
- Network errors
- Invalid URLs
- Missing files
- Graceful fallback

✅ **Logging**
- Detailed debug information
- State tracking
- Error messages

✅ **Performance**
- Singleton pattern
- Efficient resource usage
- Proper cleanup

---

## 📁 Files Modified/Created

| File | Changes |
|------|---------|
| `apps/pubspec.yaml` | Added just_audio dependency |
| `apps/lib/services/background_music_service.dart` | NEW - Audio playback service |
| `apps/lib/preview_screen.dart` | Added music loading and playback |
| `apps/lib/services/api_service.dart` | Added getMusic() method |

---

## 🚀 Deployment

1. **Update Dependencies**
   ```bash
   flutter pub get
   ```

2. **Rebuild App**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Test Flow**
   - Record video
   - Select music
   - Verify playback
   - Upload

---

## 📝 Notes

- Music plays at 50% volume to not overpower video audio
- Music loops automatically if shorter than video
- Music stops when user leaves preview screen
- All errors are handled gracefully
- Comprehensive logging for debugging

---

## ✨ Summary

The background music playback system is now fully implemented and integrated with:

✅ Music selection in app
✅ Music badge on preview
✅ Background music playback
✅ Video audio mixing
✅ Proper cleanup
✅ Error handling
✅ Comprehensive logging

The system is ready for testing and deployment!

---

**Status**: ✅ COMPLETE & READY FOR TESTING

**Last Updated**: December 25, 2025

**Version**: 1.0
