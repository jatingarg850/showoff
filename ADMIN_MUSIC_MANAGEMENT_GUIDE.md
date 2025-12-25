# Admin Music Management System - Complete Guide

## Overview
A complete music management system for the admin panel that allows uploading, managing, and approving music files locally on the server.

## Features

✅ **Upload Music** - Upload audio files (MP3, WAV, AAC, OGG)
✅ **Manage Metadata** - Title, artist, genre, mood, duration
✅ **Approval System** - Approve/reject pending music
✅ **Status Management** - Active/inactive toggle
✅ **Statistics** - Track usage, likes, and engagement
✅ **Filtering** - Filter by approval status, genre, mood
✅ **Pagination** - Browse music with pagination
✅ **Local Storage** - Files stored in `/server/uploads/music/`

## File Structure

### Backend Files Created

1. **`server/controllers/musicController.js`**
   - Music upload handling
   - CRUD operations
   - Approval/rejection logic
   - Statistics aggregation

2. **`server/views/admin/music.ejs`**
   - Admin UI for music management
   - Upload form
   - Music list with filters
   - Edit/delete functionality

3. **`server/routes/adminRoutes.js`** (Updated)
   - Added music API endpoints
   - `/admin/music` - GET all music
   - `/admin/music/:id` - GET single music
   - `/admin/music/upload` - POST upload
   - `/admin/music/:id` - PUT update
   - `/admin/music/:id` - DELETE
   - `/admin/music/:id/approve` - POST approve
   - `/admin/music/:id/reject` - POST reject
   - `/admin/music/stats` - GET statistics

4. **`server/routes/adminWebRoutes.js`** (Updated)
   - Added `/admin/music` web route

5. **`server/views/admin/partials/admin-sidebar.ejs`** (Updated)
   - Added Music Management link to sidebar

## API Endpoints

### Get All Music
```
GET /admin/music?page=1&limit=10&isApproved=true&genre=pop&mood=happy
```

**Query Parameters:**
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 10)
- `isApproved` - Filter by approval status (true/false)
- `isActive` - Filter by active status (true/false)
- `genre` - Filter by genre
- `mood` - Filter by mood

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "title": "Song Title",
      "artist": "Artist Name",
      "audioUrl": "/uploads/music/music-123.mp3",
      "duration": 180,
      "genre": "pop",
      "mood": "happy",
      "isApproved": true,
      "isActive": true,
      "usageCount": 42,
      "likes": 15,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "total": 100,
    "page": 1,
    "limit": 10,
    "pages": 10
  }
}
```

### Get Single Music
```
GET /admin/music/:id
```

### Upload Music
```
POST /admin/music/upload
Content-Type: multipart/form-data

Parameters:
- audio (file) - Audio file (required)
- title (string) - Song title (required)
- artist (string) - Artist name (required)
- genre (string) - Genre (optional)
- mood (string) - Mood (optional)
- duration (number) - Duration in seconds (optional)
```

### Update Music
```
PUT /admin/music/:id
Content-Type: application/json

{
  "title": "New Title",
  "artist": "New Artist",
  "genre": "rock",
  "mood": "energetic",
  "isApproved": true,
  "isActive": true
}
```

### Delete Music
```
DELETE /admin/music/:id
```

### Approve Music
```
POST /admin/music/:id/approve
```

### Reject Music
```
POST /admin/music/:id/reject
```

### Get Music Statistics
```
GET /admin/music/stats
```

**Response:**
```json
{
  "success": true,
  "data": {
    "total": 100,
    "approved": 85,
    "pending": 15,
    "active": 80,
    "genreStats": [
      { "_id": "pop", "count": 30 },
      { "_id": "rock", "count": 25 }
    ],
    "moodStats": [
      { "_id": "happy", "count": 40 },
      { "_id": "calm", "count": 35 }
    ]
  }
}
```

## Admin Panel Usage

### Accessing Music Management
1. Go to `/admin/music` in your browser
2. Must be logged in as admin
3. Dashboard shows statistics:
   - Total Music
   - Approved
   - Pending Approval
   - Active

### Uploading Music
1. Click "+ Upload Music" button
2. Select audio file (MP3, WAV, AAC, OGG)
3. Enter title and artist (required)
4. Select genre and mood (optional)
5. Enter duration in seconds (optional)
6. Click "Upload"

### Managing Music
- **Edit** - Click "Edit" to modify metadata and approval status
- **Approve** - Click "Approve" to approve pending music
- **Delete** - Click "Delete" to remove music (also deletes file)

### Filtering
- Filter by approval status (Approved/Pending)
- Filter by genre (Pop, Rock, Jazz, Classical, Electronic, Other)
- Filter by mood (Happy, Sad, Energetic, Calm, Romantic, Other)

## File Storage

### Upload Directory
```
server/uploads/music/
```

### File Naming
Files are named with pattern: `music-{timestamp}-{random}.{extension}`

Example: `music-1704067200000-123456789.mp3`

### File Limits
- Maximum file size: 50MB
- Allowed formats: MP3, WAV, AAC, OGG

## Database Schema

### Music Model
```javascript
{
  title: String (required),
  artist: String (required),
  audioUrl: String (required),
  duration: Number (in seconds),
  genre: String,
  mood: String (enum: happy, sad, energetic, calm, romantic, other),
  coverUrl: String,
  isActive: Boolean (default: true),
  isApproved: Boolean (default: false),
  uploadedBy: ObjectId (ref: User),
  usageCount: Number (default: 0),
  likes: Number (default: 0),
  createdAt: Date,
  updatedAt: Date
}
```

## Genres Supported
- Pop
- Rock
- Jazz
- Classical
- Electronic
- Other

## Moods Supported
- Happy
- Sad
- Energetic
- Calm
- Romantic
- Other

## Security Features

✅ **Admin Authentication** - Session-based authentication
✅ **File Validation** - Only audio files allowed
✅ **File Size Limit** - 50MB maximum
✅ **MIME Type Check** - Validates audio MIME types
✅ **File Cleanup** - Deletes files when music is deleted
✅ **Error Handling** - Graceful error handling with cleanup

## Error Handling

### Common Errors

**No audio file provided**
```json
{
  "success": false,
  "message": "No audio file provided"
}
```

**Invalid file type**
```json
{
  "success": false,
  "message": "Only audio files are allowed"
}
```

**File too large**
```json
{
  "success": false,
  "message": "File size exceeds 50MB limit"
}
```

**Music not found**
```json
{
  "success": false,
  "message": "Music not found"
}
```

## Performance Optimization

- **Indexing** - Indexed on `isActive`, `isApproved`, `genre`, `mood`
- **Pagination** - Default 10 items per page
- **Lazy Loading** - Music loaded on demand
- **Caching** - Statistics cached in UI

## Testing

### Test Upload
```bash
curl -X POST http://localhost:5000/admin/music/upload \
  -F "audio=@song.mp3" \
  -F "title=Test Song" \
  -F "artist=Test Artist" \
  -F "genre=pop" \
  -F "mood=happy" \
  -F "duration=180"
```

### Test Get All
```bash
curl http://localhost:5000/admin/music?page=1&limit=10
```

### Test Approve
```bash
curl -X POST http://localhost:5000/admin/music/{id}/approve
```

## Troubleshooting

### Music files not uploading
- Check `/server/uploads/music/` directory exists
- Verify file permissions (755 for directory)
- Check file size (max 50MB)
- Verify MIME type is audio

### Admin panel not loading
- Check admin authentication
- Verify session is active
- Check browser console for errors

### Files not deleting
- Check file permissions
- Verify file path is correct
- Check disk space

## Future Enhancements

- [ ] Audio preview player
- [ ] Batch upload
- [ ] Music search
- [ ] Playlist management
- [ ] Audio metadata extraction
- [ ] Waveform visualization
- [ ] Music recommendations
- [ ] Licensing management
- [ ] Analytics dashboard
- [ ] Export/import functionality

## Support

For issues or questions, check:
1. Server logs in console
2. Browser console for client-side errors
3. File permissions in `/server/uploads/music/`
4. Database connection status
