# Video Upload & Thumbnail Generation Fix

## Issues Fixed

### 1. **Hardcoded Username in Preview Screen**
- **Problem**: Preview screen showed hardcoded "@jatingarg" instead of actual user's name
- **Solution**: Updated `preview_screen.dart` to fetch current user from StorageService and display their actual username
- **File**: `apps/lib/preview_screen.dart`

### 2. **Auto-Thumbnail Generation**
- **Problem**: Videos uploaded without thumbnails didn't have auto-generated thumbnails
- **Solution**: 
  - Created `server/utils/thumbnailGenerator.js` with FFmpeg-based thumbnail generation
  - Updated `postController.js` to auto-generate thumbnails for videos if not provided
  - Updated `sytController.js` to auto-generate thumbnails for SYT entries if not provided
  - Thumbnails are generated at 1% of video (very beginning) and uploaded to Wasabi S3

### 3. **Wrong User's Reel Showing**
- **Problem**: Reels were showing wrong user's information
- **Solution**: Verified that:
  - `reel_screen.dart` correctly displays `user['username']` from post data
  - `postController.js` getFeed endpoint properly populates user data with `.populate('user', 'username displayName profilePicture isVerified')`
  - User data is correctly associated with each post

## Implementation Details

### Backend Changes

#### 1. New Thumbnail Generator Utility (`server/utils/thumbnailGenerator.js`)
```javascript
// Main functions:
- generateThumbnailFromUrl(videoUrl, outputPath) - Generate thumbnail using FFmpeg
- uploadThumbnailToS3(localPath, fileName) - Upload to Wasabi S3
- generateAndUploadThumbnail(videoUrl, videoId) - Complete flow
```

#### 2. Updated Post Controller (`server/controllers/postController.js`)
- `createPostWithUrl()` now auto-generates thumbnails for videos
- Thumbnail generation happens asynchronously but doesn't block post creation
- Falls back gracefully if thumbnail generation fails

#### 3. Updated SYT Controller (`server/controllers/sytController.js`)
- `submitEntry()` now auto-generates thumbnails for SYT videos
- Same fallback behavior as post controller

### Frontend Changes

#### 1. Updated Preview Screen (`apps/lib/preview_screen.dart`)
- Added `_getCurrentUser()` method to fetch current user from StorageService
- Username now displays dynamically instead of hardcoded "@jatingarg"
- Uses FutureBuilder to handle async user data fetching

## Upload Flow

1. **User Records Video** → `UploadContentScreen`
2. **Enters Caption** → `ThumbnailSelectorScreen` (for videos)
3. **Selects/Generates Thumbnail** → `PreviewScreen` (shows user's actual name)
4. **Uploads to Wasabi S3** → `WasabiService`
5. **Creates Post** → `createPostWithUrl()` endpoint
6. **Auto-generates Thumbnail** (if not provided) → Uploaded to S3
7. **Post Created** with thumbnail URL

## Thumbnail Generation Details

- **Timing**: Taken at 1% of video (very beginning)
- **Size**: 640x1080 (portrait for mobile)
- **Format**: JPEG
- **Storage**: Wasabi S3 under `thumbnails/` folder
- **Fallback**: If generation fails, post is still created without thumbnail

## Testing

### Test Video Upload with Auto-Thumbnail
1. Open app and go to upload screen
2. Record or select a video
3. Enter caption
4. Skip thumbnail selection (or don't select one)
5. Upload video
6. Verify:
   - Post is created successfully
   - Thumbnail is auto-generated and visible in feed
   - User's actual name appears in preview

### Test User Name Display
1. Upload a video as User A
2. View the reel in feed
3. Verify User A's username appears (not hardcoded name)
4. Upload as User B
5. Verify User B's username appears correctly

## Dependencies

- `fluent-ffmpeg` - For thumbnail generation (must be installed)
- `aws-sdk` - For S3 upload (already in use)

## Environment Variables Required

```
WASABI_ACCESS_KEY_ID
WASABI_SECRET_ACCESS_KEY
WASABI_ENDPOINT
WASABI_REGION
WASABI_BUCKET_NAME
```

## Performance Notes

- Thumbnail generation happens asynchronously
- Post creation doesn't wait for thumbnail generation
- Temporary files are cleaned up after upload
- Thumbnails are cached in S3 for fast loading

## Future Improvements

- Add thumbnail caching to avoid regeneration
- Allow users to customize thumbnail selection
- Add multiple thumbnail options for users to choose from
- Implement thumbnail generation queue for high-volume uploads
