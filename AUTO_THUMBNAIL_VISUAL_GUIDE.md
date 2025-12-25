# Auto Thumbnail Generator - Visual Guide

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    UPLOAD FLOWS                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐  ┌──────────────────┐               │
│  │  Regular Reel    │  │   SYT Entry      │               │
│  │    Upload        │  │    Upload        │               │
│  └────────┬─────────┘  └────────┬─────────┘               │
│           │                     │                         │
│           └──────────┬──────────┘                         │
│                      ↓                                    │
│           ┌──────────────────────┐                       │
│           │  Preview Screen      │                       │
│           │  (ThumbnailService)  │                       │
│           └──────────┬───────────┘                       │
│                      ↓                                    │
│           ┌──────────────────────┐                       │
│           │ Check Thumbnail      │                       │
│           │ Provided?            │                       │
│           └──────────┬───────────┘                       │
│                      │                                    │
│          ┌───────────┴───────────┐                       │
│          ↓                       ↓                       │
│    ┌──────────────┐      ┌──────────────────┐           │
│    │   YES        │      │      NO          │           │
│    │ Use Custom   │      │ AUTO-GENERATE    │           │
│    │ Thumbnail    │      │ Thumbnail        │           │
│    └──────┬───────┘      └────────┬─────────┘           │
│           │                       │                     │
│           │                       ↓                     │
│           │              ┌──────────────────┐           │
│           │              │ Extract Frame    │           │
│           │              │ (0ms = start)    │           │
│           │              └────────┬─────────┘           │
│           │                       │                     │
│           │                       ↓                     │
│           │              ┌──────────────────┐           │
│           │              │ Generate JPEG    │           │
│           │              │ 640x480, Q75     │           │
│           │              └────────┬─────────┘           │
│           │                       │                     │
│           └───────────┬───────────┘                     │
│                       ↓                                 │
│              ┌──────────────────┐                      │
│              │ Upload to S3     │                      │
│              │ (Wasabi)         │                      │
│              └────────┬─────────┘                      │
│                       ↓                                │
│              ┌──────────────────┐                      │
│              │ Cleanup Temp     │                      │
│              │ Files            │                      │
│              └────────┬─────────┘                      │
│                       ↓                                │
│              ┌──────────────────┐                      │
│              │ Create Post/     │                      │
│              │ Entry with URLs  │                      │
│              └──────────────────┘                      │
│                                                        │
└────────────────────────────────────────────────────────┘
```

## Regular Reel Upload Flow

```
┌─────────────────────────────────────────────────────────┐
│                 REGULAR REEL UPLOAD                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. Camera/Gallery                                      │
│     └─ User selects video                              │
│                                                         │
│  2. Upload Content Screen                              │
│     └─ Add caption, hashtags                           │
│                                                         │
│  3. Thumbnail Selector Screen (Optional)               │
│     └─ User can select custom thumbnail                │
│                                                         │
│  4. Preview Screen                                      │
│     ├─ Video uploaded to Wasabi S3                     │
│     │  └─ mediaUrl = https://s3.../videos/uuid.mp4    │
│     │                                                   │
│     ├─ Check for custom thumbnail                      │
│     │  ├─ If YES: Upload to S3                         │
│     │  │  └─ thumbnailUrl = https://s3.../images/...  │
│     │  │                                                │
│     │  └─ If NO: AUTO-GENERATE                         │
│     │     ├─ Extract first frame (0ms)                 │
│     │     ├─ Generate JPEG (640x480, Q75)              │
│     │     ├─ Upload to S3                              │
│     │     │  └─ thumbnailUrl = https://s3.../images/..│
│     │     └─ Cleanup temp file                         │
│     │                                                   │
│     └─ Create Post                                      │
│        ├─ mediaUrl: https://s3.../videos/uuid.mp4      │
│        ├─ thumbnailUrl: https://s3.../images/uuid.jpg  │
│        ├─ caption: "User caption"                       │
│        └─ hashtags: ["tag1", "tag2"]                    │
│                                                         │
│  5. Success                                             │
│     └─ Post appears in feed with thumbnail             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## SYT Entry Upload Flow

```
┌─────────────────────────────────────────────────────────┐
│                  SYT ENTRY UPLOAD                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. Camera/Gallery                                      │
│     └─ User selects video                              │
│                                                         │
│  2. Upload Content Screen                              │
│     └─ Add title, description, category                │
│                                                         │
│  3. Thumbnail Selector Screen (Optional)               │
│     └─ User can select custom thumbnail                │
│                                                         │
│  4. Preview Screen                                      │
│     ├─ Prepare multipart request                       │
│     │  ├─ video: File(videoPath)                       │
│     │  └─ thumbnail: ?                                 │
│     │                                                   │
│     ├─ Check for custom thumbnail                      │
│     │  ├─ If YES: Add to request                       │
│     │  │  └─ thumbnail: File(customThumbnailPath)      │
│     │  │                                                │
│     │  └─ If NO: AUTO-GENERATE                         │
│     │     ├─ Extract first frame (0ms)                 │
│     │     ├─ Generate JPEG (640x480, Q75)              │
│     │     ├─ Add to request                            │
│     │     │  └─ thumbnail: File(generatedPath)         │
│     │     └─ Schedule cleanup (2s delay)               │
│     │                                                   │
│     └─ Submit to Backend                               │
│        ├─ POST /api/syt/submit                         │
│        ├─ video: File                                  │
│        ├─ thumbnail: File (auto or custom)             │
│        ├─ title: "Entry title"                         │
│        ├─ category: "Dance"                            │
│        └─ competitionType: "weekly"                    │
│                                                         │
│  5. Backend Processing                                  │
│     ├─ Upload video to S3                              │
│     ├─ Upload thumbnail to S3                          │
│     └─ Create SYT Entry with URLs                      │
│                                                         │
│  6. Success                                             │
│     └─ Entry appears in leaderboard with thumbnail     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Thumbnail Generation Process

```
┌──────────────────────────────────────────────────────┐
│         THUMBNAIL GENERATION PROCESS                 │
├──────────────────────────────────────────────────────┤
│                                                      │
│  Input: Video File                                   │
│  ├─ Path: /path/to/video.mp4                        │
│  ├─ Duration: 30 seconds                            │
│  └─ Format: MP4                                      │
│                                                      │
│  ↓                                                   │
│                                                      │
│  ThumbnailService.generateThumbnail()               │
│  ├─ videoPath: /path/to/video.mp4                   │
│  ├─ maxWidth: 640                                    │
│  ├─ maxHeight: 480                                   │
│  ├─ quality: 75                                      │
│  └─ timeMs: 0 (first frame)                          │
│                                                      │
│  ↓                                                   │
│                                                      │
│  VideoThumbnail.thumbnailFile()                     │
│  ├─ Extract frame at 0ms                            │
│  ├─ Resize to 640x480                               │
│  ├─ Compress to JPEG (Q75)                          │
│  └─ Save to temp directory                          │
│                                                      │
│  ↓                                                   │
│                                                      │
│  Output: Thumbnail File                              │
│  ├─ Path: /tmp/uuid.jpg                             │
│  ├─ Size: ~50-100 KB                                │
│  ├─ Format: JPEG                                     │
│  ├─ Dimensions: 640x480                             │
│  └─ Quality: 75/100                                 │
│                                                      │
│  ↓                                                   │
│                                                      │
│  Upload to S3                                        │
│  ├─ WasabiService.uploadImage()                     │
│  ├─ Destination: /images/uuid.jpg                   │
│  └─ URL: https://s3.../images/uuid.jpg              │
│                                                      │
│  ↓                                                   │
│                                                      │
│  Cleanup                                             │
│  └─ Delete /tmp/uuid.jpg                            │
│                                                      │
└──────────────────────────────────────────────────────┘
```

## Error Handling Flow

```
┌──────────────────────────────────────────────────────┐
│           ERROR HANDLING FLOW                        │
├──────────────────────────────────────────────────────┤
│                                                      │
│  Try: Generate Thumbnail                            │
│  │                                                   │
│  ├─ Success ✓                                        │
│  │  └─ Use generated thumbnail                      │
│  │                                                   │
│  └─ Error ✗                                          │
│     ├─ Log warning                                   │
│     ├─ Print error message                          │
│     └─ Continue WITHOUT thumbnail                   │
│        ├─ Upload video anyway                       │
│        ├─ Post/Entry created                        │
│        └─ Backend can generate server-side          │
│                                                      │
│  Result: Upload always succeeds                      │
│  ├─ With thumbnail (ideal)                          │
│  ├─ Without thumbnail (acceptable)                  │
│  └─ Never fails due to thumbnail                    │
│                                                      │
└──────────────────────────────────────────────────────┘
```

## File Organization

```
apps/lib/
├─ services/
│  ├─ thumbnail_service.dart          ← NEW
│  ├─ api_service.dart                ← MODIFIED
│  ├─ wasabi_service.dart
│  └─ storage_service.dart
│
├─ preview_screen.dart                ← MODIFIED
├─ upload_content_screen.dart
├─ thumbnail_selector_screen.dart
└─ camera_screen.dart

server/
├─ controllers/
│  ├─ postController.js               ← Already supports
│  └─ sytController.js                ← Already supports
│
├─ utils/
│  └─ thumbnailGenerator.js           ← Already supports
│
└─ middleware/
   └─ upload.js
```

## Data Flow

```
┌─────────────────────────────────────────────────────┐
│              DATA FLOW DIAGRAM                      │
├─────────────────────────────────────────────────────┤
│                                                     │
│  User Video File                                    │
│  └─ /path/to/video.mp4                             │
│     ├─ Upload to Wasabi S3                         │
│     │  └─ mediaUrl: https://s3.../videos/uuid.mp4  │
│     │                                               │
│     └─ Extract Thumbnail                           │
│        ├─ Generate JPEG                            │
│        ├─ Upload to Wasabi S3                      │
│        │  └─ thumbnailUrl: https://s3.../images/.. │
│        └─ Cleanup temp file                        │
│                                                     │
│  Database                                           │
│  ├─ Post/Entry created                             │
│  ├─ mediaUrl: https://s3.../videos/uuid.mp4        │
│  ├─ thumbnailUrl: https://s3.../images/uuid.jpg    │
│  └─ Other metadata                                 │
│                                                     │
│  Display                                            │
│  ├─ Feed/Profile/Leaderboard                       │
│  ├─ Shows thumbnail image                          │
│  ├─ Plays video on tap                             │
│  └─ Better UX with visual preview                  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Timeline

```
User Action          Time    Component
─────────────────────────────────────────────────────
Select Video         0ms     Camera/Gallery
Add Caption          +500ms  Upload Content Screen
Select Thumbnail     +1s     Thumbnail Selector
Preview              +1.5s   Preview Screen
Upload Video         +2s     Wasabi S3
Generate Thumbnail   +2.5s   ThumbnailService
Upload Thumbnail     +3.5s   Wasabi S3
Create Post          +4s     Backend
Cleanup Temp         +4.1s   ThumbnailService
Show Success         +4.5s   UI
─────────────────────────────────────────────────────
Total Time: ~4.5 seconds
```

## Summary

The auto-thumbnail generator:
- ✅ Automatically generates thumbnails from first frame
- ✅ Uploads to Wasabi S3 alongside video
- ✅ Stores URL in database
- ✅ Displays in feed/profile/leaderboard
- ✅ Improves user experience
- ✅ Handles errors gracefully
- ✅ Cleans up temporary files
- ✅ Works for both regular reels and SYT entries
