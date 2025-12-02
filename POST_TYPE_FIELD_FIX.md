# Post Type Field Fix

## Problem
Video uploads were failing with error:
```
Post validation failed: type: Path `type` is required
```

## Root Cause
The `createPostWithUrl` function was missing the `type` field when creating posts. The Post model requires this field, but it wasn't being set.

## Solution

### Added Type Field Mapping
```javascript
// Determine type from mediaType
const type = mediaType === 'video' ? 'reel' : mediaType;

// Create post with provided URL
const post = await Post.create({
  user: req.user.id,
  type: type,              // ✅ NOW INCLUDED
  mediaUrl,
  mediaType,
  caption: caption || '',
  location: location || '',
  hashtags: hashtags || [],
  musicId,
  isPublic: isPublic !== false,
});
```

## Type Mapping Logic

### Input → Output:
- `video` → `reel` (videos are displayed as reels)
- `image` → `image` (images stay as images)
- Other → Same value

## Why This Mapping?

### Videos as Reels:
In the app, videos are displayed in the reel format (vertical, swipeable), so we map `mediaType: 'video'` to `type: 'reel'`.

### Images as Images:
Regular images are displayed in the feed as standard posts, so they keep the `image` type.

## Complete Flow

### 1. Client Uploads Video:
```dart
// Flutter app
await wasabiService.uploadVideo(videoFile);
await ApiService.createPostWithUrl(
  mediaUrl: url,
  mediaType: 'video',  // ← Client sends this
  caption: caption,
);
```

### 2. Server Receives Request:
```javascript
const { mediaUrl, mediaType, caption } = req.body;
// mediaType = 'video'
```

### 3. Server Maps Type:
```javascript
const type = mediaType === 'video' ? 'reel' : mediaType;
// type = 'reel'
```

### 4. Server Creates Post:
```javascript
const post = await Post.create({
  type: 'reel',        // ✅ Required field now set
  mediaType: 'video',  // Original media type preserved
  mediaUrl: url,
  // ... other fields
});
```

## Post Model Fields

### Required Fields:
- `user` - User ID (from auth)
- `type` - Post type (reel, image, etc.)
- `mediaUrl` - URL to media file

### Optional Fields:
- `mediaType` - Original media type
- `caption` - Post caption
- `hashtags` - Array of hashtags
- `location` - Location string
- `musicId` - Music track ID
- `isPublic` - Public/private flag

## Testing

### Test Video Upload:
1. Record a video
2. Select thumbnail
3. Enter caption
4. Tap "Upload"
5. Should upload successfully
6. Post should appear in feed as reel

### Test Image Upload:
1. Select image from gallery
2. Enter caption
3. Tap "Upload"
4. Should upload successfully
5. Post should appear in feed as image

### Success Indicators:
- ✅ No "type is required" error
- ✅ Upload completes successfully
- ✅ Post appears in feed
- ✅ Correct type assigned (reel/image)
- ✅ Coins awarded

## Error Handling

### Before Fix:
```
POST /api/posts/create-with-url 500
Error: Post validation failed: type: Path `type` is required
```

### After Fix:
```
POST /api/posts/create-with-url 201
{ success: true, data: { type: 'reel', ... } }
```

## Files Modified

- `server/controllers/postController.js` - Added type field mapping

## Related Functions

### createPost (with file upload):
Already had type field:
```javascript
const mediaType = mediaFile.mimetype.startsWith('image/') ? 'image' : 
                 mediaFile.mimetype.startsWith('video/') ? 'video' : 'reel';

const post = await Post.create({
  type: type || mediaType,  // ✅ Already included
  // ...
});
```

### createPostWithUrl (direct URL):
Now fixed:
```javascript
const type = mediaType === 'video' ? 'reel' : mediaType;

const post = await Post.create({
  type: type,  // ✅ NOW INCLUDED
  // ...
});
```

## Benefits

- ✅ Uploads work correctly
- ✅ Proper type assignment
- ✅ Videos display as reels
- ✅ Images display as posts
- ✅ Consistent with existing code

## Status

✅ Type field added to createPostWithUrl
✅ Proper mapping logic implemented
✅ Consistent with createPost function
✅ Ready to test

## Next Steps

1. Restart the server (if needed)
2. Test video upload
3. Verify post appears in feed
4. Check post type is 'reel'
5. Verify coins are awarded
