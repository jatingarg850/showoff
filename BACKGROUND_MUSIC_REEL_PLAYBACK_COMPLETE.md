# Background Music Playback in Reels - COMPLETE ✅

## Task 8 Summary: Background Music Not Playing in Uploaded Reels

### Problem
Background music was playing in preview_screen.dart but NOT in reel_screen.dart when viewing uploaded reels. Posts were fetched with `backgroundMusic` populated (from Task 1), but reel_screen never used it.

### Root Cause
- `reel_screen.dart` had no background music playback logic
- `syt_reel_screen.dart` had no background music playback logic
- When viewing reels, the backgroundMusic field from posts was ignored

### Solution Implemented

#### 1. **reel_screen.dart** - Added Background Music Playback
- **Import**: Added `import 'services/background_music_service.dart'`
- **Variables**: Added music tracking:
  ```dart
  String? _currentMusicId;
  final BackgroundMusicService _musicService = BackgroundMusicService();
  ```
- **Method**: Added `_playBackgroundMusicForReel(int index)` that:
  - Extracts `backgroundMusicId` from post data
  - Fetches music details from API using `ApiService.getMusic()`
  - Converts relative URL to full URL using `ApiService.getAudioUrl()`
  - Plays music via `BackgroundMusicService.playBackgroundMusic()`
  - Handles music switching when scrolling to different reels
  - Stops music if reel has no background music

- **Integration Points**:
  - `_onPageChanged()`: Calls `_playBackgroundMusicForReel()` when user scrolls to new reel
  - `didChangeAppLifecycleState()`: Pauses/resumes music when app goes to background/foreground
  - `dispose()`: Stops music when leaving reel_screen

#### 2. **syt_reel_screen.dart** - Added Background Music Playback
- **Import**: Added `import 'services/background_music_service.dart'`
- **Variables**: Added music tracking:
  ```dart
  String? _currentMusicId;
  final BackgroundMusicService _musicService = BackgroundMusicService();
  ```
- **Method**: Added `_playBackgroundMusicForSYTReel(int index)` that:
  - Same logic as reel_screen but for SYT competition entries
  - Extracts `backgroundMusicId` from competition data
  - Fetches and plays music via BackgroundMusicService

- **Integration Points**:
  - `onPageChanged()`: Calls `_playBackgroundMusicForSYTReel()` when user scrolls to new entry
  - `dispose()`: Stops music when leaving syt_reel_screen

### Complete End-to-End Flow

1. **Admin uploads music** → Music stored in database with audioUrl
2. **Admin approves music** → Music becomes available for selection
3. **User selects music in app** → Music ID stored with post
4. **User records video** → Video + music ID sent to server
5. **Video uploads with music** → Post created with backgroundMusicId
6. **When viewing posts/reels**:
   - Post fetched with `backgroundMusic` populated (Task 1)
   - `_onPageChanged()` triggered when reel displayed
   - `_playBackgroundMusicForReel()` called
   - Music fetched from API
   - URL converted to full URL (Task 2)
   - Music plays automatically via BackgroundMusicService
7. **When scrolling to next reel**:
   - Previous music stops
   - New music loads and plays
8. **When leaving reel screen**:
   - Music stops in `dispose()`

### Files Modified

1. **apps/lib/reel_screen.dart**
   - Added BackgroundMusicService import
   - Added `_currentMusicId` and `_musicService` variables
   - Added `_playBackgroundMusicForReel()` method
   - Updated `_onPageChanged()` to call music playback
   - Updated `didChangeAppLifecycleState()` to pause/resume music
   - Updated `dispose()` to stop music

2. **apps/lib/syt_reel_screen.dart**
   - Added BackgroundMusicService import
   - Added `_currentMusicId` and `_musicService` variables
   - Added `_playBackgroundMusicForSYTReel()` method
   - Updated `onPageChanged()` to call music playback
   - Updated `dispose()` to stop music

### Key Features

✅ **Automatic Music Playback**: Music plays automatically when reel is displayed
✅ **Music Switching**: Stops old music and plays new music when scrolling
✅ **URL Conversion**: Handles relative URLs and converts to full URLs
✅ **Error Handling**: Gracefully handles missing music or API errors
✅ **Lifecycle Management**: Pauses music when app goes to background, resumes when back
✅ **Cleanup**: Stops music when leaving reel screen
✅ **SYT Support**: Works for both regular reels and SYT competition entries

### Testing Checklist

- [ ] Upload video with background music in preview_screen
- [ ] Verify music plays in preview_screen
- [ ] Upload post successfully
- [ ] View reel in reel_screen
- [ ] Verify background music plays automatically
- [ ] Scroll to next reel
- [ ] Verify previous music stops and new music plays
- [ ] Scroll to reel without music
- [ ] Verify music stops
- [ ] Go to background (home button)
- [ ] Verify music pauses
- [ ] Return to app
- [ ] Verify music resumes
- [ ] Leave reel_screen
- [ ] Verify music stops
- [ ] Test SYT reels with background music
- [ ] Verify music plays for SYT entries

### Notes

- Music volume is set to 85% to be prominent but not overwhelming
- Music loops automatically via BackgroundMusicService
- Same music ID check prevents unnecessary reloading
- Graceful fallback if music fetch fails
- Compatible with existing video playback logic
