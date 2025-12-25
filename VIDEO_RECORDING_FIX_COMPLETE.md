# Video Recording and Music Selection Flow - Complete Fix

## Problem Identified
The app was experiencing a critical issue where recorded videos were being deleted before playback:
```
FileNotFoundException: /data/user/0/com.showofflife.app/cache/REC6179482581647665882.mp4: open failed: ENOENT (No such file or directory)
```

### Root Cause
1. Videos were recorded to a temporary cache location managed by the camera plugin
2. The temporary file path was passed through multiple screens (UploadContentScreen → ThumbnailSelectorScreen → PreviewScreen)
3. Between recording and playback, the OS or camera plugin would clean up the temporary file
4. When PreviewScreen tried to initialize the video player, the file no longer existed

## Solution Implemented

### 1. Created File Persistence Service
**File**: `apps/lib/services/file_persistence_service.dart`

This service provides:
- **persistVideoFile()** - Copies video from temporary location to persistent app storage
- **videoFileExists()** - Validates video file exists before playback
- **getVideoFileSizeMB()** - Gets file size for debugging
- **deleteVideoFile()** - Safely deletes video files
- **cleanupTempVideos()** - Cleans up temporary files
- **getPersistedVideos()** - Lists all persisted videos
- **cleanupOldVideos()** - Maintains storage by removing old videos

### 2. Updated Camera Screen
**File**: `apps/lib/camera_screen.dart`

Changes:
- Added import for `FilePersistenceService`
- Modified `_stopVideoRecording()` to immediately persist video after recording
- Video is copied from temporary cache to persistent app documents directory
- Added error handling with user feedback if persistence fails

**Key Code**:
```dart
final persistedVideoPath = await FilePersistenceService.persistVideoFile(video.path);
Navigator.push(..., mediaPath: persistedVideoPath, ...);
```

### 3. Enhanced Preview Screen
**File**: `apps/lib/preview_screen.dart`

Changes:
- Added import for `FilePersistenceService`
- Enhanced `_initializeVideo()` with file validation
- Checks if video file exists before attempting playback
- Logs file size for debugging
- Shows user-friendly error message if file is missing
- Improved error handling with SnackBar feedback

**Key Code**:
```dart
final fileExists = await FilePersistenceService.videoFileExists(widget.mediaPath!);
if (!fileExists) {
  throw Exception('Video file not found at: ${widget.mediaPath}');
}
```

### 4. Added Validation to Upload Content Screen
**File**: `apps/lib/upload_content_screen.dart`

Changes:
- Added import for `FilePersistenceService`
- Added file validation before navigating to thumbnail selector
- Prevents user from proceeding if video file is missing
- Shows error message if file validation fails

**Key Code**:
```dart
final fileExists = await FilePersistenceService.videoFileExists(widget.mediaPath!);
if (!fileExists) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Video file not found. Please record again.'))
  );
  return;
}
```

## Flow After Fix

```
CameraScreen (records video)
  ↓
_stopVideoRecording() 
  ↓
FilePersistenceService.persistVideoFile() 
  ↓ (copies to persistent storage)
UploadContentScreen (caption entry)
  ↓ (validates file exists)
ThumbnailSelectorScreen (generates thumbnails)
  ↓ (generates 4 thumbnails from persisted video)
PreviewScreen (plays video)
  ↓ (validates file exists before playback)
✅ Video plays successfully
  ↓
Upload to Wasabi S3
```

## Storage Structure

Videos are now stored in:
```
/data/data/com.showofflife.app/files/app_videos/
  ├── video_1702345678901.mp4
  ├── video_1702345679234.mp4
  └── video_1702345679567.mp4
```

This location is:
- Persistent across app sessions
- Not subject to OS garbage collection
- Managed by the app's file persistence service
- Automatically cleaned up when old videos are removed

## Music Selection Integration

The music selection flow remains unchanged and works correctly:
- User selects music in `MusicSelectionScreen`
- `backgroundMusicId` is passed through all screens
- Music is applied during upload in `PreviewScreen`
- Music selection is preserved throughout the entire flow

## Error Handling

The fix includes comprehensive error handling:
1. **File Validation** - Checks file exists before each operation
2. **User Feedback** - Shows SnackBar messages for errors
3. **Logging** - Detailed console logs for debugging
4. **Graceful Degradation** - App doesn't crash if file is missing

## Testing Checklist

- [x] Record video successfully
- [x] Video persists to app storage
- [x] Navigate through UploadContentScreen
- [x] Generate thumbnails from persisted video
- [x] Play video in PreviewScreen
- [x] Upload video with music selection
- [x] Verify file cleanup after upload
- [x] Test error scenarios (missing files)

## Performance Impact

- **Minimal**: Video copy happens once after recording
- **Storage**: Videos stored in app documents directory (managed by OS)
- **Cleanup**: Old videos automatically removed to prevent storage bloat

## Future Improvements

1. Add video compression before persistence
2. Implement background upload with progress tracking
3. Add video editing capabilities before upload
4. Implement video caching for faster playback
5. Add storage quota management

## Files Modified

1. `apps/lib/services/file_persistence_service.dart` - NEW
2. `apps/lib/camera_screen.dart` - UPDATED
3. `apps/lib/preview_screen.dart` - UPDATED
4. `apps/lib/upload_content_screen.dart` - UPDATED

## Deployment Notes

- No database changes required
- No API changes required
- Backward compatible with existing uploads
- Requires `path_provider` package (already in pubspec.yaml)
