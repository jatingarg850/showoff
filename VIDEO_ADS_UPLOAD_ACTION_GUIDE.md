# Video Ads Upload - Action Guide

## Quick Fix Steps

### Step 1: Restart Server
```bash
npm start
```

### Step 2: Test Video Ad Upload
1. Go to: `http://localhost:5000/admin`
2. Login with: `admin@showofflife.com` / `admin123`
3. Navigate to: Video Ads
4. Click: "Create Video Ad"
5. Fill form:
   - Title: "Test Video"
   - Select video file (MP4)
   - Select thumbnail (JPG/PNG)
   - Reward coins: 10
6. Click: "Create"

### Step 3: Check Results
- Look for success message
- Check server logs for file upload details
- Verify video ad appears in list

## What Was Fixed

✅ **File Upload Handling**
- Better logging to see what's happening
- Proper file URL extraction
- Support for both S3 and local storage

✅ **Admin User Handling**
- Made uploadedBy optional
- Allows uploads without valid admin user
- Better error messages

✅ **Error Messages**
- More descriptive error messages
- Better debugging information
- Detailed file upload logs

## Expected Behavior

### Success Case
```
✅ Video ad created successfully
   Video URL: uploads/videos/550e8400-e29b-41d4-a716-446655440000.mp4
   Thumbnail URL: uploads/images/550e8400-e29b-41d4-a716-446655440001.png
```

### Error Cases
```
❌ Video file upload failed - no URL generated
   → Check upload middleware logs

❌ Video file is required
   → Select a video file before uploading

❌ Title is required
   → Fill in the title field
```

## Server Logs to Watch For

### Good Logs
```
📤 Video ad creation request received
📹 Video file details:
   Filename: hello.mp4
   Path: uploads/videos/550e8400-e29b-41d4-a716-446655440000.mp4
   Size: 1024000
✅ Video ad created: 507f1f77bcf86cd799439011
```

### Bad Logs
```
❌ No video file provided
❌ Video file upload failed - no URL generated
❌ Error creating video ad: ...
```

## Files Changed

- `server/routes/adminWebRoutes.js` - Better file handling
- `server/models/VideoAd.js` - Optional uploadedBy field

## Next Steps

1. Test video ad upload
2. Check server logs
3. Verify video ad appears in list
4. Test video ad in mobile app

## Support

If upload still fails:
1. Check server logs for detailed error
2. Verify file types are correct (MP4, JPG, PNG)
3. Check file sizes are reasonable
4. Verify Wasabi S3 credentials if using S3
5. Check local uploads directory exists

## Summary

Video ad uploads should now work properly. The system has better logging to help debug any issues, and the uploadedBy field is now optional so uploads work even without a valid admin user in the database.
