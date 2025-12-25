# Music Selection Feature - Testing Guide

## Quick Test Steps

### 1. Upload Music to Admin Panel
1. Go to Admin Panel → Music Management
2. Click "Upload Music"
3. Select an MP3/WAV/AAC/OGG file (max 50MB)
4. Fill in:
   - Title
   - Artist
   - Genre (pop, rock, jazz, classical, electronic)
   - Mood (happy, sad, energetic, calm, romantic)
5. Click "Upload"
6. Click "Approve" to make it available for users

### 2. Test Music Selection in Reel Upload

#### Step 1: Navigate to Upload
1. Open app
2. Tap "+" button or navigate to upload
3. Select "Show" (Reels) or "SYT"

#### Step 2: Music Selection Screen
1. **Music Selection Screen should appear** (this was the bug fix)
2. You should see:
   - Genre filter dropdown
   - Mood filter dropdown
   - List of approved music tracks
   - "Continue with Selected Music" button
   - "Skip Music" button

#### Step 3: Select Music
1. (Optional) Filter by genre or mood
2. Tap on a music track to select it
3. Selected track should show:
   - Purple border
   - Checkmark in circle
4. Tap "Continue with Selected Music"

#### Step 4: Record/Upload
1. Camera screen appears
2. Record video or select from gallery
3. Add caption
4. Select thumbnail (auto-generated or custom)
5. Preview and upload

#### Step 5: Verify Music Saved
1. After upload, check database:
   ```
   db.posts.findOne({_id: ObjectId("...")})
   // Should have: backgroundMusic: "music_id_here"
   ```

### 3. Test Skip Music Option
1. Go through steps 1-2 above
2. Tap "Skip Music" button
3. Should proceed to camera without music
4. Upload should complete without music reference

### 4. Test Music Filters
1. In Music Selection Screen:
   - Select Genre: "Pop" → Should show only pop music
   - Select Mood: "Happy" → Should show only happy mood music
   - Select both → Should show intersection
   - Select "All Genres" / "All Moods" → Should show all

## Expected Behavior

### Music Selection Screen
- ✅ Appears after selecting path (reels/SYT)
- ✅ Shows list of approved music
- ✅ Allows filtering by genre and mood
- ✅ Allows selecting a track
- ✅ Shows selected track with visual indicator
- ✅ Allows skipping music
- ✅ Passes selected music ID through entire upload flow

### Upload Flow
- ✅ Music ID is passed from MusicSelectionScreen → CameraScreen
- ✅ Music ID is passed from CameraScreen → UploadContentScreen
- ✅ Music ID is passed from UploadContentScreen → ThumbnailSelectorScreen
- ✅ Music ID is passed from ThumbnailSelectorScreen → PreviewScreen
- ✅ Music ID is sent to backend in upload request
- ✅ Music ID is saved in Post/SYTEntry document

### Database
- ✅ Post document has `backgroundMusic` field with music ID
- ✅ SYTEntry document has `backgroundMusic` field with music ID
- ✅ Music can be queried and displayed when viewing posts

## Troubleshooting

### Music Selection Screen Not Appearing
- **Check**: Is `path_selection_screen.dart` importing `MusicSelectionScreen`?
- **Check**: Is the navigation button calling `MusicSelectionScreen` instead of `CameraScreen`?
- **Fix**: Verify the import and navigation code in `path_selection_screen.dart`

### No Music Tracks Showing
- **Check**: Are there approved music tracks in the database?
- **Check**: Is the `/music/approved` endpoint working?
- **Test**: Call endpoint directly: `GET /api/music/approved`
- **Fix**: Upload and approve music in admin panel first

### Music Not Saving with Post
- **Check**: Is `backgroundMusicId` being passed through all screens?
- **Check**: Is the backend receiving `musicId` in request body?
- **Check**: Is the Post model saving `backgroundMusic` field?
- **Test**: Check database for `backgroundMusic` field in post document

### Upload Fails After Selecting Music
- **Check**: Browser console for errors
- **Check**: Server logs for API errors
- **Check**: Network tab to see request/response
- **Fix**: Verify all parameters are being passed correctly

## Files to Check

If issues occur, verify these files:
1. `apps/lib/path_selection_screen.dart` - Navigation to MusicSelectionScreen
2. `apps/lib/music_selection_screen.dart` - Music selection UI
3. `apps/lib/camera_screen.dart` - Passes backgroundMusicId
4. `apps/lib/upload_content_screen.dart` - Passes backgroundMusicId
5. `apps/lib/thumbnail_selector_screen.dart` - Passes backgroundMusicId
6. `apps/lib/preview_screen.dart` - Sends musicId to API
7. `apps/lib/services/api_service.dart` - API methods
8. `server/controllers/musicController.js` - Backend music endpoints
9. `server/controllers/postController.js` - Post creation with music

## Success Indicators

✅ Music selection screen appears in upload flow
✅ Can select music from list
✅ Can filter by genre/mood
✅ Can skip music
✅ Upload completes successfully
✅ Music ID saved in database
✅ Music displays when viewing posts
