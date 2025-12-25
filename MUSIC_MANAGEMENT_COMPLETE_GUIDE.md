# Complete Music Management System Guide

## System Overview

The music management system has three main flows:

1. **Admin Upload & Approval** - Admin uploads music and approves it
2. **User Selection** - Users select approved music in the app
3. **Video Upload with Music** - Videos are uploaded with selected background music

---

## Part 1: Admin Music Management

### Upload Music

**URL:** `POST /admin/music/upload`

**Steps:**
1. Admin goes to `http://localhost:3000/admin/music`
2. Fills the "Upload New Music" form:
   - Audio File (required) - MP3, WAV, etc.
   - Title (required) - Song name
   - Artist (required) - Artist name
   - Genre (optional) - Pop, Rock, Jazz, etc.
   - Mood (optional) - Happy, Sad, Energetic, etc.
   - Duration (optional) - In seconds
3. Clicks "Upload Music" button
4. Music is saved to database with `isApproved: false` status

**What happens:**
- File is stored in `server/uploads/music/` directory
- Music document is created in MongoDB
- Music appears in the grid with "⏳ Pending" status

### View & Filter Music

**URL:** `GET /admin/music?page=1&limit=10&isApproved=&genre=&mood=`

**Features:**
- View all uploaded music in a grid
- Filter by:
  - Status (All, Approved, Pending)
  - Genre (Pop, Rock, Jazz, Classical, Electronic, Other)
  - Mood (Happy, Sad, Energetic, Calm, Romantic, Other)
- Pagination support
- Stats showing: Total, Approved, Pending, Active counts

### Listen to Music

**Feature:** Play button on each music card

**Steps:**
1. Click "Play" button on any music card
2. Audio player opens at bottom-right
3. Controls:
   - Play/Pause
   - Rewind 10 seconds
   - Forward 10 seconds
   - Progress bar with seeking
   - Volume control
   - Time display

### Approve Music

**URL:** `POST /admin/music/{id}/approve`

**Steps:**
1. Listen to the music using the player
2. Click "Approve" button on the music card
3. Music status changes to "✓ Approved"
4. Music becomes available for users in the app

### Delete Music

**URL:** `DELETE /admin/music/{id}`

**Steps:**
1. Click "Delete" button on music card
2. Confirm deletion
3. Music is removed from database and file system

---

## Part 2: User Music Selection in App

### Get Approved Music

**URL:** `GET /api/music/approved?page=1&limit=50&genre=&mood=`

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
      "audioUrl": "/uploads/music/music-123.mp3",
      "isApproved": true,
      "isActive": true
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

### Music Selection Screen

**File:** `apps/lib/music_selection_screen.dart`

**Flow:**
1. User records video in camera
2. Redirected to music selection screen
3. Can filter by Genre and Mood
4. Selects a music track (shows checkmark)
5. Clicks "Continue with Selected Music"
6. Passes `backgroundMusicId` to camera screen

---

## Part 3: Video Upload with Background Music

### Preview Screen

**File:** `apps/lib/preview_screen.dart`

**Features:**
- Shows video preview with selected music
- Displays caption and hashtags
- Shows category (for SYT)
- Upload button

### Upload with Music

**URL:** `POST /api/posts/create` or `/api/syt/submit`

**Request includes:**
```json
{
  "mediaUrl": "https://s3.../video.mp4",
  "mediaType": "video",
  "caption": "My awesome video",
  "hashtags": ["fun", "dance"],
  "musicId": "music_id",
  "thumbnailUrl": "https://s3.../thumbnail.jpg"
}
```

**Post Model:**
```javascript
{
  user: ObjectId,
  type: "video",
  mediaUrl: "https://...",
  thumbnailUrl: "https://...",
  caption: "...",
  hashtags: ["..."],
  backgroundMusic: ObjectId,  // Reference to Music document
  likesCount: 0,
  commentsCount: 0,
  viewsCount: 0,
  coinsEarned: 0,
  isActive: true,
  visibility: "public",
  createdAt: Date,
  updatedAt: Date
}
```

---

## Database Schema

### Music Collection

```javascript
{
  _id: ObjectId,
  title: String (required),
  artist: String (required),
  audioUrl: String (required),
  duration: Number (seconds),
  genre: String (default: "other"),
  mood: String (enum: happy, sad, energetic, calm, romantic, other),
  coverUrl: String (optional),
  isActive: Boolean (default: true),
  isApproved: Boolean (default: false),
  uploadedBy: ObjectId (ref: User),
  usageCount: Number (default: 0),
  likes: Number (default: 0),
  createdAt: Date,
  updatedAt: Date
}
```

### Post Collection (with music)

```javascript
{
  _id: ObjectId,
  user: ObjectId (ref: User),
  type: String (image, video, reel),
  mediaUrl: String,
  thumbnailUrl: String,
  caption: String,
  hashtags: [String],
  backgroundMusic: ObjectId (ref: Music),  // NEW FIELD
  likesCount: Number,
  commentsCount: Number,
  sharesCount: Number,
  viewsCount: Number,
  coinsEarned: Number,
  isActive: Boolean,
  isReported: Boolean,
  reportCount: Number,
  visibility: String (public, private, followers),
  createdAt: Date,
  updatedAt: Date
}
```

---

## API Endpoints

### Admin Routes (Protected)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/admin/music/upload` | Upload new music |
| GET | `/admin/music` | Get all music with filters |
| GET | `/admin/music/stats` | Get music statistics |
| GET | `/admin/music/:id` | Get single music |
| PUT | `/admin/music/:id` | Update music |
| DELETE | `/admin/music/:id` | Delete music |
| POST | `/admin/music/:id/approve` | Approve music |
| POST | `/admin/music/:id/reject` | Reject music |

### Public Routes (For App)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/music/approved` | Get approved music |
| GET | `/api/music/search` | Search music |
| GET | `/api/music/:id` | Get single music |

---

## Troubleshooting

### Music Not Showing After Upload

**Check:**
1. Music file was uploaded successfully (check `/server/uploads/music/` directory)
2. Music document exists in MongoDB
3. Refresh the admin page
4. Check browser console for errors

**Debug:**
```bash
# Check if music files exist
ls -la server/uploads/music/

# Check MongoDB
db.musics.find({})
```

### Music Not Appearing in App

**Check:**
1. Music is approved (`isApproved: true`)
2. Music is active (`isActive: true`)
3. App is calling `/api/music/approved` endpoint
4. Network request is successful

### Audio Player Not Working

**Check:**
1. Audio file path is correct
2. File exists in `/uploads/music/` directory
3. Browser allows audio playback
4. CORS headers are correct

---

## Testing

### Test Upload
```bash
node test_music_upload_complete.js
```

### Manual Testing

1. **Upload Music:**
   - Go to `http://localhost:3000/admin/music`
   - Upload a test audio file
   - Verify it appears in the grid

2. **Play Music:**
   - Click "Play" button
   - Verify audio player opens
   - Test play/pause, seek, volume

3. **Approve Music:**
   - Click "Approve" button
   - Verify status changes to "✓ Approved"

4. **Test in App:**
   - Record a video
   - Select music from list
   - Verify music ID is passed to preview
   - Upload video with music

---

## File Locations

- **Admin Panel:** `server/views/admin/music.ejs`
- **Music Controller:** `server/controllers/musicController.js`
- **Music Routes:** `server/routes/musicRoutes.js` & `server/routes/adminRoutes.js`
- **Music Model:** `server/models/Music.js`
- **Post Model:** `server/models/Post.js`
- **Music Selection Screen:** `apps/lib/music_selection_screen.dart`
- **Preview Screen:** `apps/lib/preview_screen.dart`
- **API Service:** `apps/lib/services/api_service.dart`
- **Uploaded Files:** `server/uploads/music/`

---

## Next Steps

1. ✅ Admin uploads music
2. ✅ Admin listens and approves
3. ✅ Users select music in app
4. ✅ Music shows in preview
5. ✅ Video uploads with music reference
6. 🔄 Implement music playback in video preview (optional)
7. 🔄 Add music analytics (most used, trending)
8. 🔄 Add music recommendations based on category
