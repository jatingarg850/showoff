# FCM Setup - Works for All Login Methods (Phone, Email, Gmail)

## Overview
FCM (Firebase Cloud Messaging) now works for all login methods:
- ✅ Phone number login
- ✅ Email login  
- ✅ Gmail login

The system gracefully handles Firebase initialization errors without crashing the app.

## Current Status

### Error Seen
```
❌ FCM error: Credential implementation provided to initializeApp() via the "credential" property failed to fetch a valid Google OAuth2 access token with the following error: "invalid_grant: Invalid JWT Signature."
```

### Root Cause
Firebase service account credentials are missing or invalid.

## Solution: Setup Firebase Service Account

### Step 1: Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (ShowOff.life)
3. Click ⚙️ **Settings** → **Project Settings**
4. Go to **"Service Accounts"** tab
5. Click **"Generate New Private Key"** button
6. A JSON file will download automatically

### Step 2: Add to Server

1. Copy the downloaded JSON file
2. Rename it to: `firebase-service-account.json`
3. Place it in the `server/` folder

**File structure should be:**
```
server/
├── firebase-service-account.json  ← Place here
├── controllers/
├── models/
├── utils/
│   └── fcmService.js
├── start-server.js
└── ...
```

### Step 3: Verify File Contents

The JSON file should contain:
```json
{
  "type": "service_account",
  "project_id": "showoff-life-xxxxx",
  "private_key_id": "xxxxx",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@showoff-life-xxxxx.iam.gserviceaccount.com",
  "client_id": "xxxxx",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/..."
}
```

### Step 4: Restart Server

```bash
npm start
```

**Expected output:**
```
✅ Firebase Admin initialized successfully
   Project: showoff-life-xxxxx
```

## How FCM Works for All Login Methods

### Phone Login
1. User logs in with phone number
2. OTP verified via AuthKey.io
3. User account created/updated
4. FCM token stored in database
5. ✅ Notifications sent via FCM

### Email Login
1. User logs in with email
2. OTP verified via Resend
3. User account created/updated
4. FCM token stored in database
5. ✅ Notifications sent via FCM

### Gmail Login
1. User logs in with Google OAuth
2. Google credentials verified
3. User account created/updated
4. FCM token stored in database
5. ✅ Notifications sent via FCM

**Key Point**: FCM token is stored regardless of login method, so notifications work for all.

## Testing FCM

### Test 1: Check Server Logs

After restarting server, look for:
```
✅ Firebase Admin initialized successfully
```

NOT:
```
❌ Firebase Admin initialization failed
```

### Test 2: Send Test Notification

1. Login to app (any method: phone, email, or Gmail)
2. Trigger an action that sends notification (like, comment, follow)
3. Check server logs for:
```
✅ FCM sent to user 693fea1dbd0b31693bb4dc02 (login method: phone)
✅ FCM sent to user 692c533cf1eabe2640278b48 (login method: email)
✅ FCM sent to user 692c5a7af1eabe2640279111 (login method: gmail)
```

### Test 3: Verify Notifications Received

1. Open app
2. Go to background (minimize app)
3. Trigger notification from another user
4. Check if notification appears in system tray

## Troubleshooting

### Issue: "firebase-service-account.json not found"
```
❌ Firebase initialization failed: firebase-service-account.json not found
   Location: /path/to/server/firebase-service-account.json
```

**Solution**:
1. Download file from Firebase Console
2. Place in `server/` folder
3. Restart server

### Issue: "Invalid JWT Signature"
```
❌ Firebase initialization failed: Invalid JWT Signature
   Cause: Invalid JWT Signature - credentials may be revoked or corrupted
   Fix: Generate new service account key from Firebase Console
```

**Solution**:
1. Go to Firebase Console
2. Delete old service account key
3. Generate new one
4. Replace file in `server/` folder
5. Restart server

### Issue: "Invalid JSON format"
```
❌ Firebase initialization failed: Invalid JSON
   Cause: Invalid JSON format
   Fix: Ensure the file is valid JSON
```

**Solution**:
1. Download fresh file from Firebase Console
2. Ensure it's valid JSON (no extra characters)
3. Place in `server/` folder
4. Restart server

### Issue: FCM Still Not Working

**Checklist**:
- [ ] File is in `server/firebase-service-account.json`
- [ ] File contains valid JSON
- [ ] Server restarted after adding file
- [ ] Check logs for "✅ Firebase Admin initialized"
- [ ] User has opened app (to get FCM token)
- [ ] User is logged in (phone, email, or Gmail)

## Important Security Notes

⚠️ **Never commit to Git**
```bash
echo "firebase-service-account.json" >> .gitignore
```

⚠️ **Keep file safe**
- Don't share with anyone
- Store in secure location
- Backup in safe place

⚠️ **Regenerate if compromised**
- Go to Firebase Console
- Delete old key
- Generate new one
- Update server file

## FCM Features

### Notifications Sent For:
- ✅ New likes on posts
- ✅ New comments
- ✅ New followers
- ✅ Messages
- ✅ Admin notifications
- ✅ Custom notifications

### Works When:
- ✅ App is open
- ✅ App is in background
- ✅ App is closed
- ✅ Device is locked

### Works For All Login Methods:
- ✅ Phone number + OTP
- ✅ Email + OTP
- ✅ Gmail OAuth

## Next Steps

1. Download Firebase service account key
2. Place in `server/firebase-service-account.json`
3. Restart server
4. Verify "✅ Firebase Admin initialized" in logs
5. Test notifications with all login methods
6. Monitor logs for FCM success messages

## Support

If FCM still doesn't work:
1. Check server logs for error messages
2. Verify file location and contents
3. Ensure Firebase project is active
4. Check Firebase Console for any issues
5. Regenerate service account key if needed
