# Wasabi S3 Configuration Guide

## Current Status
❌ **Profile pictures are saving locally** because Wasabi credentials are not configured.

## How to Fix: Configure Wasabi S3

### Step 1: Get Wasabi Credentials

1. **Sign up for Wasabi** at https://wasabi.com/
   - Create a free account (1TB free for 30 days)
   
2. **Create a Bucket**:
   - Go to Wasabi Console → Buckets
   - Click "Create Bucket"
   - Choose a bucket name (e.g., `showoff-life-media`)
   - Select region (e.g., `ap-southeast-1` for Singapore)
   - Set bucket to **Public** (for profile pictures to be accessible)
   
3. **Get Access Keys**:
   - Go to Wasabi Console → Access Keys
   - Click "Create New Access Key"
   - Save both:
     - Access Key ID
     - Secret Access Key

### Step 2: Update `.env` File

Open `server/.env` and replace the placeholder values:

```env
# Wasabi S3 Configuration
WASABI_ACCESS_KEY_ID=YOUR_ACTUAL_ACCESS_KEY_HERE
WASABI_SECRET_ACCESS_KEY=YOUR_ACTUAL_SECRET_KEY_HERE
WASABI_BUCKET_NAME=showoff-life-media
WASABI_REGION=ap-southeast-1
WASABI_ENDPOINT=https://s3.ap-southeast-1.wasabisys.com
```

**Important**: Replace:
- `YOUR_ACTUAL_ACCESS_KEY_HERE` with your real Wasabi Access Key ID
- `YOUR_ACTUAL_SECRET_KEY_HERE` with your real Wasabi Secret Access Key
- `showoff-life-media` with your actual bucket name
- `ap-southeast-1` with your chosen region

### Step 3: Make Bucket Public

To allow profile pictures to be accessible:

1. Go to your bucket in Wasabi Console
2. Click on "Policies"
3. Add this bucket policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/*"
    }
  ]
}
```

Replace `YOUR_BUCKET_NAME` with your actual bucket name.

### Step 4: Restart Server

After updating `.env`:

```bash
cd server
npm start
```

You should see:
```
✅ Wasabi S3 Configuration:
   - Bucket: showoff-life-media
   - Region: ap-southeast-1
   - Endpoint: https://showoff-life-media.s3.ap-southeast-1.wasabisys.com
✅ Using Wasabi S3 for file uploads
```

## Verification

### Test Upload
1. Open the app
2. Go to Edit Profile
3. Upload a profile picture
4. Check the console logs - you should see Wasabi S3 upload messages
5. The image URL should start with `https://showoff-life-media.s3.ap-southeast-1.wasabisys.com/`

### Check Wasabi Console
1. Go to your bucket in Wasabi Console
2. You should see uploaded files in the `images/` folder

## Troubleshooting

### Issue: Still saving locally
**Solution**: Make sure:
- `.env` values don't contain `your_` prefix
- Server was restarted after updating `.env`
- Wasabi credentials are correct

### Issue: Upload fails with 403 error
**Solution**: 
- Check Access Key permissions in Wasabi Console
- Ensure bucket policy allows uploads

### Issue: Images not loading
**Solution**:
- Make sure bucket is public
- Check bucket policy is correctly set
- Verify CORS settings in Wasabi Console

## Alternative: Use Local Storage (Development Only)

If you want to continue using local storage for development:

1. Keep the placeholder values in `.env`
2. Files will save to `server/uploads/`
3. Images will be served from `http://localhost:3000/uploads/`

**Note**: This is NOT recommended for production as files will be lost when server restarts or scales.

## Cost Estimate

Wasabi Pricing:
- **Storage**: $5.99/TB/month
- **No egress fees** (unlike AWS S3)
- **Free tier**: 1TB for 30 days

For a social media app:
- 10,000 users × 1MB profile picture = 10GB = ~$0.06/month
- 1,000 videos × 50MB = 50GB = ~$0.30/month

Very affordable! 🎉

## Next Steps

1. ✅ Sign up for Wasabi
2. ✅ Create bucket
3. ✅ Get access keys
4. ✅ Update `.env` file
5. ✅ Restart server
6. ✅ Test upload
7. ✅ Verify in Wasabi Console

Once configured, all profile pictures, videos, and media will automatically upload to Wasabi S3!
