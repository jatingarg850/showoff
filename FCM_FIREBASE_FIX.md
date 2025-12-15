# FCM Firebase Fix - Invalid JWT Signature Error

## Problem
FCM notifications failing with error:
```
❌ FCM error: Credential implementation provided to initializeApp() via the "credential" property failed to fetch a valid Google OAuth2 access token with the following error: "invalid_grant: Invalid JWT Signature."
```

## Root Cause
The Firebase service account JSON file is missing or has invalid credentials.

## Solution

### Step 1: Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (ShowOff.life)
3. Click ⚙️ Settings → Project Settings
4. Go to "Service Accounts" tab
5. Click "Generate New Private Key"
6. A JSON file will download (e.g., `showoff-life-firebase-adminsdk-xxxxx.json`)

### Step 2: Add to Server

1. Copy the downloaded JSON file to: `server/firebase-service-account.json`
2. The file should contain:
```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "xxxxx",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com",
  "client_id": "xxxxx",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/..."
}
```

### Step 3: Verify File Location
```
server/
├── firebase-service-account.json  ← Should be here
├── controllers/
├── models/
├── utils/
│   └── fcmService.js
└── ...
```

### Step 4: Restart Server
```bash
npm start
```

You should see:
```
✅ Firebase Admin initialized
```

## Testing FCM

### Test 1: Send Notification via API
```bash
curl -X POST http://localhost:3000/api/notifications/test \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"userId": "USER_ID", "title": "Test", "message": "FCM Test"}'
```

### Test 2: Check Server Logs
Look for:
```
✅ FCM notification sent to user 693fea1dbd0b31693bb4dc02
```

NOT:
```
❌ FCM error for user 692c533cf1eabe2640278b48: Credential implementation...
```

## Troubleshooting

### Issue: "firebase-service-account.json not found"
**Solution**: Download the file from Firebase Console and place it in `server/` folder

### Issue: "Invalid JWT Signature"
**Solution**: 
1. The key file might be revoked
2. Generate a new one from Firebase Console
3. Replace the old file

### Issue: "Server time not properly synced"
**Solution**: 
1. Check server time: `date`
2. Sync time: `ntpdate -s time.nist.gov` (Linux/Mac)
3. Or use Windows Time Sync

### Issue: FCM still not working after fix
**Solution**:
1. Verify file is in correct location: `server/firebase-service-account.json`
2. Check file permissions: `chmod 644 server/firebase-service-account.json`
3. Restart server: `npm start`
4. Check logs for "✅ Firebase Admin initialized"

## FCM Works For All Login Methods

Once Firebase is properly configured, FCM will work for:
- ✅ Phone number login
- ✅ Email login
- ✅ Gmail login

The FCM token is stored in the User model and used regardless of login method.

## Important Notes

⚠️ **Security**: Never commit `firebase-service-account.json` to Git
- Add to `.gitignore`: `echo "firebase-service-account.json" >> .gitignore`

⚠️ **Backup**: Keep the JSON file safe
- Store in secure location
- Don't share with anyone

✅ **Regenerate**: If compromised
- Go to Firebase Console
- Delete old key
- Generate new one
- Update server file

## Next Steps

1. Download Firebase service account key
2. Place in `server/firebase-service-account.json`
3. Restart server
4. Test FCM notifications
5. Verify all login methods work with FCM
