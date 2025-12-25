# Background Music & Video Preview Fix

## Issues Identified

### 1. Video File Not Persisting Properly
**Problem:** Video is recorded to cache directory but not properly copied to persistent storage
**Error:** `Cannot open file, path /data/user/0/com.showofflife.app/cache/video_...jpg`

**Root Cause:** 
- Camera records to temporary cache
- FilePersistenceService.persistVideoFile() should copy to app documents
- But the path might still be pointing to cache

**Solution:**
- Ensure video is persisted before passing to upload screen
- Add retry logic if persistence fails
- Validate file exists before using

### 2. Background Music Not Displaying on Preview
**Problem:** User selects music but it doesn't show on preview screen
**Expected:** Badge showing "Background Music Added" with music icon

**Root Cause:**
- backgroundMusicId is being passed through the flow
- But preview screen wasn't displaying it

**Solution:**
- Added music badge to preview screen
- Shows when backgroundMusicId is not null
- Displays music icon and "Background Music Added" text

---

## Changes Made

### 1. Preview Screen Updates (`apps/lib/preview_screen.dart`)

#### Added Music Badge Display
```dart
// Background Music Badge (NEW)
if (widget.backgroundMusicId != null)
  Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFF701CF5).withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.music_note,
          color: Colors.white,
          size: 16,
        ),
        const SizedBox(width: 6),
        const Text(
          'Background Music Added',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  ),
```

#### Improved Video Initialization
- Added detailed logging
- Better error messages
- File existence check before initialization
- File size validation

### 2. Camera Screen Verification
- Video is persisted via `FilePersistenceService.persistVideoFile()`
- Path is passed to UploadContentScreen
- UploadContentScreen validates file exists

### 3. Upload Content Screen Verification
- Validates video file exists before proceeding
- Shows error if file not found
- Passes path to ThumbnailSelectorScreen or PreviewScreen

---

## Complete Flow

### Step 1: Record Video
```
CameraScreen
  ↓
  _stopVideoRecording()
  ↓
  FilePersistenceService.persistVideoFile(video.path)
  ↓
  Returns: /data/user/0/com.showofflife.app/app_videos/video_TIMESTAMP.mp4
  ↓
  Navigate to UploadContentScreen with persisted path
```

### Step 2: Add Caption & Select Music
```
UploadContentScreen
  ↓
  User enters caption
  ↓
  User clicks "Preview" or "Select Thumbnail"
  ↓
  Validates video file exists
  ↓
  If video: Navigate to ThumbnailSelectorScreen
  If image: Navigate to PreviewScreen
```

### Step 3: Select Thumbnail (for videos)
```
ThumbnailSelectorScreen
  ↓
  User selects thumbnail frame
  ↓
  Navigate to PreviewScreen with:
    - videoPath (persisted path)
    - thumbnailPath (selected frame)
    - backgroundMusicId (from camera screen)
```

### Step 4: Preview with Music Badge
```
PreviewScreen
  ↓
  Display video from persisted path
  ↓
  Show music badge if backgroundMusicId exists
  ↓
  Show caption, category, username
  ↓
  User clicks "Upload"
  ↓
  Upload with musicId reference
```

---

## Testing Checklist

### Video Persistence
- [ ] Record video in camera
- [ ] Check if file exists in app documents directory
- [ ] Verify file size is correct
- [ ] Verify file can be played

### Music Display
- [ ] Select music in music selection screen
- [ ] Verify backgroundMusicId is passed through flow
- [ ] Check preview screen shows music badge
- [ ] Verify music badge displays correctly

### Upload with Music
- [ ] Upload video with music
- [ ] Check post in database has backgroundMusic reference
- [ ] Verify music ID is saved correctly

---

## File Paths

| Component | File |
|-----------|------|
| Camera Screen | `apps/lib/camera_screen.dart` |
| Upload Content Screen | `apps/lib/upload_content_screen.dart` |
| Thumbnail Selector | `apps/lib/thumbnail_selector_screen.dart` |
| Preview Screen | `apps/lib/preview_screen.dart` |
| File Persistence | `apps/lib/services/file_persistence_service.dart` |

---

## Debugging

### Check Video File Exists
```dart
final file = File(videoPath);
final exists = await file.exists();
print('File exists: $exists');
```

### Check File Size
```dart
final fileSizeMB = await FilePersistenceService.getVideoFileSizeMB(videoPath);
print('File size: ${fileSizeMB.toStringAsFixed(2)} MB');
```

### Check Music ID
```dart
print('Background Music ID: ${widget.backgroundMusicId}');
```

### Check Database
```javascript
// Check post with music
db.posts.findOne({backgroundMusic: {$exists: true}})

// Check SYT entry with music
db.sytentries.findOne({backgroundMusic: {$exists: true}})
```

---

## Next Steps

1. ✅ Added music badge to preview screen
2. ✅ Improved video initialization with better error handling
3. ✅ Added detailed logging
4. Test complete flow end-to-end
5. Monitor logs during testing
6. Verify files are persisted correctly
7. Verify music is saved with posts
