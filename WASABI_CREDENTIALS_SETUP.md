# Wasabi S3 Credentials Setup Guide

## Current Status

The app is currently using **local storage** for file uploads because Wasabi credentials are not configured.

## How to Configure Wasabi S3

### Step 1: Get Your Wasabi Credentials

1. Go to https://console.wasabisys.com
2. Log in to your account
3. Navigate to **Access Keys** section
4. Create a new access key or use existing one
5. Copy the **Access Key ID** and **Secret Access Key**

### Step 2: Find Your Bucket Information

1. In Wasabi console, go to **Buckets**
2. Note your bucket name (e.g., `showofforiginal`)
3. Note the bucket region (e.g., `ap-southeast-1`)

### Step 3: Update .env File

Edit `server/.env` and replace the placeholder values:

```env
# Wasabi S3 Configuration
WASABI_ACCESS_KEY_ID=YOUR_ACTUAL_ACCESS_KEY_HERE
WASABI_SECRET_ACCESS_KEY=YOUR_ACTUAL_SECRET_KEY_HERE
WASABI_BUCKET_NAME=your_bucket_name
WASABI_REGION=ap-southeast-1
WASABI_ENDPOINT=https://s3.ap-southeast-1.wasabisys.com
```

**Example with real values:**
```env
WASABI_ACCESS_KEY_ID=LZ4Q3024I5KUQPLT9FDO
WASABI_SECRET_ACCESS_KEY=tzMQuJKnHQXjCeis6ZKZb5HNjDFGsXi4KsG6A5C4
WASABI_BUCKET_NAME=showofforiginal
WASABI_REGION=ap-southeast-1
WASABI_ENDPOINT=https://s3.ap-southeast-1.wasabisys.com
```

### Step 4: Restart Server

After updating the .env file:
```bash
# Stop the server (Ctrl+C)
# Start it again
npm start
```

### Step 5: Test Upload

The server will automatically:
- ✅ Detect valid Wasabi credentials
- ✅ Use Wasabi S3 for uploads
- ✅ Log "Using Wasabi S3 for file uploads"

## Current Behavior (Without Wasabi)

### ✅ What Works:
- All file uploads work perfectly
- Files saved to `server/uploads/` directory
- Images in `server/uploads/images/`
- Videos in `server/uploads/videos/`
- Files served via Express static middleware
- URLs: `http://localhost:3000/uploads/images/filename.jpg`

### 📁 Local Storage Structure:
```
server/
  uploads/
    images/
      uuid-filename.jpg
      uuid-filename.png
    videos/
      uuid-filename.mp4
```

## Benefits of Wasabi S3

### With Wasabi (Recommended for Production):
- ✅ Cloud storage (no server disk usage)
- ✅ CDN-like performance
- ✅ Scalable storage
- ✅ Automatic backups
- ✅ Global accessibility
- ✅ Professional URLs

### With Local Storage (Current - Good for Development):
- ✅ No external dependencies
- ✅ Free (no storage costs)
- ✅ Fast local access
- ✅ Easy debugging
- ⚠️ Limited by server disk space
- ⚠️ Files lost if server resets

## Testing Wasabi Connection

After configuring credentials, test the connection:

```bash
cd server
node scripts/testWasabi.js
```

Expected output:
```
✅ Successfully connected to Wasabi!
✅ Test file uploaded successfully!
```

## Troubleshooting

### Error: InvalidAccessKeyId
- Check your Access Key ID is correct
- Ensure no extra spaces in .env file
- Verify key is active in Wasabi console

### Error: SignatureDoesNotMatch
- Check your Secret Access Key is correct
- Ensure no extra spaces or line breaks

### Error: NoSuchBucket
- Verify bucket name is correct
- Check bucket exists in Wasabi console
- Ensure bucket is in the correct region

### Error: PermanentRedirect
- This is now fixed with bucket-specific endpoint
- Server automatically constructs correct URL

## Current Configuration

The system is smart and will:
1. Check if Wasabi credentials are configured
2. If yes → Use Wasabi S3
3. If no → Use local storage
4. Log which method is being used

**No functionality is lost either way!**

## Recommendation

- **Development**: Local storage is fine (current setup)
- **Production**: Configure Wasabi S3 for better scalability

Your app works perfectly with both options! 🎉
