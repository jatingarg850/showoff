# Music Management System - Quick Start Guide

## 🎵 Complete System Overview

### What's Working Now

✅ **Admin Panel Music Management**
- Upload music with metadata (title, artist, genre, mood)
- Audio player with play/pause, seek, volume controls
- Approve/Reject music
- Filter by status, genre, mood
- View statistics (total, approved, pending, active)
- Delete music

✅ **User Music Selection in App**
- Browse approved music
- Filter by genre and mood
- Select music for background
- Music ID passed through entire flow

✅ **Video Upload with Music**
- Video recorded and persisted
- Music selected before recording
- Music badge shown on preview
- Music saved with post/SYT entry
- Music reference in database

---

## 🚀 Quick Start

### For Admin: Upload & Approve Music

1. **Go to Admin Panel**
   ```
   http://localhost:3000/admin/music
   ```

2. **Upload Music**
   - Click "Upload New Music" section
   - Select audio file (MP3, WAV, etc.)
   - Enter Title (required)
   - Enter Artist (required)
   - Select Genre (optional)
   - Select Mood (optional)
   - Enter Duration in seconds (optional)
   - Click "Upload Music"

3. **Listen to Music**
   - Click "Play" button on music card
   - Use player controls:
     - ⏮️ Rewind 10s
     - ⏯️ Play/Pause
     - ⏭️ Forward 10s
     - 🔊 Volume control
     - Progress bar for seeking

4. **Approve Music**
   - Click "Approve" button
   - Status changes to "✓ Approved"
   - Music now available for users

5. **Filter & Search**
   - Filter by Status: All, Approved, Pending
   - Filter by Genre: Pop, Rock, Jazz, etc.
   - Filter by Mood: Happy, Sad, Energetic, etc.

---

### For Users: Record with Music

1. **Start Recording**
   - Open app
   - Select "Reels" or "SYT"
   - Click record button

2. **Select Music**
   - After recording, music selection screen appears
   - Browse available music
   - Filter by genre/mood if needed
   - Click on music to select (shows checkmark)
   - Click "Continue with Selected Music"

3. **Preview with Music**
   - Video preview shows
   - Music badge displays: "🎵 Background Music Added"
   - Add caption
   - Click "Upload"

4. **Upload**
   - Video uploads to Wasabi S3
   - Music reference saved with post
   - Post appears in feed with music metadata

---

## 📊 API Endpoints

### Admin Routes (Protected)

```
POST   /admin/music/upload              - Upload music
GET    /admin/music                     - Get all music (with filters)
GET    /admin/music/stats               - Get statistics
GET    /admin/music/:id                 - Get single music
PUT    /admin/music/:id                 - Update music
DELETE /admin/music/:id                 - Delete music
POST   /admin/music/:id/approve         - Approve music
POST   /admin/music/:id/reject          - Reject music
```

### Public Routes (For App)

```
GET    /api/music/approved              - Get approved music
GET    /api/music/search                - Search music
GET    /api/music/:id                   - Get single music
```

### Post Creation (with music)

```
POST   /api/posts/create-with-url       - Create post with music
POST   /api/syt/submit                  - Submit SYT with music
```

---

## 🗄️ Database Schema

### Music Document
```javascript
{
  _id: ObjectId,
  title: String,
  artist: String,
  audioUrl: String,
  duration: Number,
  genre: String,
  mood: String,
  isApproved: Boolean,
  isActive: Boolean,
  uploadedBy: ObjectId,
  usageCount: Number,
  likes: Number,
  createdAt: Date,
  updatedAt: Date
}
```

### Post with Music
```javascript
{
  _id: ObjectId,
  user: ObjectId,
  type: String,
  mediaUrl: String,
  thumbnailUrl: String,
  caption: String,
  hashtags: [String],
  backgroundMusic: ObjectId,  // Reference to Music
  likesCount: Number,
  viewsCount: Number,
  createdAt: Date,
  updatedAt: Date
}
```

---

## 🔧 Troubleshooting

### Music Not Showing After Upload

**Check:**
1. Refresh admin page
2. Check browser console for errors
3. Verify file was uploaded: `ls -la server/uploads/music/`
4. Check MongoDB: `db.musics.find({})`

**Fix:**
- Clear browser cache
- Restart server
- Check server logs

### Music Not Appearing in App

**Check:**
1. Music is approved: `db.musics.findOne({_id: ObjectId("...")}).isApproved`
2. Music is active: `db.musics.findOne({_id: ObjectId("...")}).isActive`
3. API response: `curl http://localhost:3000/api/music/approved`

**Fix:**
- Approve the music in admin panel
- Check network tab in browser dev tools
- Verify API endpoint is working

### Video File Not Found Error

**Check:**
1. Video file exists: `File(videoPath).exists()`
2. File is in correct directory
3. File permissions are correct

**Fix:**
- Re-record video
- Check file persistence service logs
- Verify app has storage permissions

### Music Not Saving with Post

**Check:**
1. musicId is being sent in request
2. Post controller is receiving musicId
3. Post document has backgroundMusic field

**Fix:**
- Check network request in dev tools
- Verify post controller logs
- Check MongoDB post document

---

## 📁 File Locations

```
Admin Panel:           server/views/admin/music.ejs
Music Controller:      server/controllers/musicController.js
Music Routes:          server/routes/musicRoutes.js
Music Model:           server/models/Music.js
Post Model:            server/models/Post.js
SYT Model:             server/models/SYTEntry.js

Music Selection:       apps/lib/music_selection_screen.dart
Preview Screen:        apps/lib/preview_screen.dart
Camera Screen:         apps/lib/camera_screen.dart
Upload Content:        apps/lib/upload_content_screen.dart
API Service:           apps/lib/services/api_service.dart
File Persistence:      apps/lib/services/file_persistence_service.dart

Uploaded Files:        server/uploads/music/
```

---

## ✨ Features

- ✅ Admin upload music with metadata
- ✅ Audio player in admin panel
- ✅ Approve/Reject music
- ✅ Filter music by status, genre, mood
- ✅ Music statistics
- ✅ User music selection in app
- ✅ Music badge on preview screen
- ✅ Music reference in posts
- ✅ Music reference in SYT entries
- ✅ Approved music API for app
- ✅ Music search functionality
- ✅ Video file persistence
- ✅ Detailed error handling

---

## 🧪 Testing

### Test Upload
```bash
node test_music_upload_complete.js
```

### Manual Test Flow
1. Upload music in admin panel
2. Listen to music using player
3. Approve music
4. Record video in app
5. Select music
6. Verify music badge shows on preview
7. Upload video
8. Check post in database for music reference

---

## 📞 Support

For issues:
1. Check logs in browser console
2. Check server logs
3. Check MongoDB documents
4. Verify file paths
5. Check network requests in dev tools

---

## 🎯 Next Steps

1. Test complete flow end-to-end
2. Monitor server logs
3. Verify files are persisted
4. Verify music is saved with posts
5. Test on actual device
6. Monitor performance
7. Add music playback in video (optional)
8. Add music analytics (optional)
