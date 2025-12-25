# Music Selection Integration - Complete Implementation

## Overview
Successfully integrated background music selection into the reel upload flow. Users can now select from admin-uploaded music when creating reels or SYT entries.

## Implementation Summary

### Frontend Changes (Flutter)

#### 1. **MusicSelectionScreen** (`apps/lib/music_selection_screen.dart`)
- New screen for users to browse and select background music
- Features:
  - Filter by genre and mood
  - Display approved music with artist, duration, and metadata
  - Selection UI with visual feedback
  - Two action buttons: "Continue with Selected Music" and "Skip Music"
- Calls `ApiService.getApprovedMusic()` to fetch approved music from server

#### 2. **API Service** (`apps/lib/services/api_service.dart`)
- Added `getApprovedMusic()` method to fetch approved music
  - Supports filtering by genre and mood
  - Pagination support (page, limit)
  - Returns music list with metadata
- Updated `submitSYTEntry()` to accept `backgroundMusicId` parameter
- `createPostWithUrl()` already supported `musicId` parameter

#### 3. **Camera Screen** (`apps/lib/camera_screen.dart`)
- Added `backgroundMusicId` parameter to constructor
- Passes `backgroundMusicId` through all navigation paths:
  - Picture capture
  - Video recording
  - Gallery picker (both image and video)

#### 4. **Upload Content Screen** (`apps/lib/upload_content_screen.dart`)
- Added `backgroundMusicId` parameter
- Passes it to both:
  - `ThumbnailSelectorScreen` (for videos)
  - `PreviewScreen` (for images)

#### 5. **Thumbnail Selector Screen** (`apps/lib/thumbnail_selector_screen.dart`)
- Added `backgroundMusicId` parameter
- Passes it to `PreviewScreen` when navigating

#### 6. **Preview Screen** (`apps/lib/preview_screen.dart`)
- Added `backgroundMusicId` parameter
- Passes it to:
  - `ApiService.createPostWithUrl()` as `musicId`
  - `ApiService.submitSYTEntry()` as `backgroundMusicId`

#### 7. **Path Selection Screen** (`apps/lib/path_selection_screen.dart`)
- Updated to navigate to `MusicSelectionScreen` instead of directly to `CameraScreen`
- Import updated to use `MusicSelectionScreen`

### Backend Changes (Node.js)

#### 1. **Music Controller** (`server/controllers/musicController.js`)
- Added `getApprovedMusic()` method
  - Filters for `isApproved: true` and `isActive: true`
  - Supports genre and mood filtering
  - Returns paginated results

#### 2. **Music Routes** (`server/routes/adminRoutes.js`)
- Added route: `GET /music/approved` → `getApprovedMusic()`
- Endpoint accessible to all users (no auth required for approved music)

#### 3. **Post Model** (`server/models/Post.js`)
- Added `backgroundMusic` field (ObjectId reference to Music model)
- Allows posts to be associated with background music

#### 4. **SYT Entry Model** (`server/models/SYTEntry.js`)
- Added `backgroundMusic` field (ObjectId reference to Music model)
- Allows SYT entries to be associated with background music

#### 5. **Post Controller** (`server/controllers/postController.js`)
- Updated `createPostWithUrl()` to save `backgroundMusic` field
- Maps `musicId` from request body to `backgroundMusic` in database

#### 6. **SYT Controller** (`server/controllers/sytController.js`)
- Updated `submitEntry()` to accept `backgroundMusicId` parameter
- Saves `backgroundMusic` field when creating SYT entry

## User Flow

### For Regular Reels:
1. User selects "Reels" from path selection
2. Navigates to `MusicSelectionScreen`
3. Browses and selects music (or skips)
4. Proceeds to `CameraScreen` with selected music ID
5. Records/captures content
6. Uploads to `UploadContentScreen`
7. Previews in `PreviewScreen`
8. Uploads post with music metadata

### For SYT Entries:
1. User selects "SYT" from path selection
2. Navigates to `MusicSelectionScreen`
3. Browses and selects music (or skips)
4. Proceeds to `CameraScreen` with selected music ID
5. Records content
6. Uploads to `UploadContentScreen`
7. Selects thumbnail in `ThumbnailSelectorScreen`
8. Previews in `PreviewScreen`
9. Submits SYT entry with music metadata

## API Endpoints

### Get Approved Music
```
GET /api/music/approved?page=1&limit=50&genre=pop&mood=happy
```
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "_id": "music_id",
      "title": "Song Title",
      "artist": "Artist Name",
      "genre": "pop",
      "mood": "happy",
      "duration": 180,
      "audioUrl": "/uploads/music/music-file.mp3"
    }
  ],
  "pagination": {
    "total": 50,
    "page": 1,
    "limit": 50,
    "pages": 1
  }
}
```

### Create Post with Music
```
POST /api/posts/create-with-url
Body: {
  "mediaUrl": "...",
  "mediaType": "video",
  "musicId": "music_id",
  ...
}
```

### Submit SYT Entry with Music
```
POST /api/syt/submit
Body (multipart):
  - video: file
  - thumbnail: file
  - title: string
  - category: string
  - competitionType: string
  - backgroundMusicId: string
```

## Database Schema Updates

### Post Model
```javascript
backgroundMusic: {
  type: mongoose.Schema.Types.ObjectId,
  ref: 'Music'
}
```

### SYT Entry Model
```javascript
backgroundMusic: {
  type: mongoose.Schema.Types.ObjectId,
  ref: 'Music'
}
```

## Testing Checklist

- [ ] Admin can upload music via admin panel
- [ ] Admin can approve/reject music
- [ ] Users can see approved music in MusicSelectionScreen
- [ ] Music filtering by genre works
- [ ] Music filtering by mood works
- [ ] Users can select music and proceed to camera
- [ ] Users can skip music and proceed to camera
- [ ] Selected music ID is passed through entire upload flow
- [ ] Posts are created with music metadata
- [ ] SYT entries are created with music metadata
- [ ] Music is properly saved in database
- [ ] Music can be retrieved with posts/SYT entries

## Files Modified

### Frontend
- `apps/lib/music_selection_screen.dart` (NEW)
- `apps/lib/camera_screen.dart`
- `apps/lib/upload_content_screen.dart`
- `apps/lib/thumbnail_selector_screen.dart`
- `apps/lib/preview_screen.dart`
- `apps/lib/path_selection_screen.dart`
- `apps/lib/services/api_service.dart`

### Backend
- `server/controllers/musicController.js`
- `server/controllers/postController.js`
- `server/controllers/sytController.js`
- `server/models/Post.js`
- `server/models/SYTEntry.js`
- `server/routes/adminRoutes.js`

## Next Steps

1. Test the complete flow end-to-end
2. Verify music metadata is properly stored and retrieved
3. Add music playback UI in post/SYT entry display screens
4. Consider adding music preview functionality
5. Add analytics for music usage
6. Implement music recommendations based on user preferences

## Notes

- Music selection is optional - users can skip and upload without music
- Only approved music is shown to users
- Music filtering is case-sensitive (ensure consistent genre/mood values)
- Music files are stored locally in `/server/uploads/music/`
- Consider implementing S3/Wasabi storage for music files in production
