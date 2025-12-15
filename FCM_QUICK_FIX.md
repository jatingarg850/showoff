# FCM Quick Fix - 3 Steps

## Problem
```
❌ FCM error: Invalid JWT Signature
```

## Solution

### Step 1: Download Firebase Key
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select ShowOff.life project
3. Settings ⚙️ → Project Settings → Service Accounts
4. Click "Generate New Private Key"
5. JSON file downloads

### Step 2: Add to Server
1. Copy downloaded JSON file
2. Rename to: `firebase-service-account.json`
3. Place in: `server/` folder

### Step 3: Restart Server
```bash
npm start
```

**Expected output:**
```
✅ Firebase Admin initialized successfully
```

## Verify It Works

### Check Logs
```
✅ FCM sent to user 693fea1dbd0b31693bb4dc02 (login method: phone)
✅ FCM sent to user 692c533cf1eabe2640278b48 (login method: email)
✅ FCM sent to user 692c5a7af1eabe2640279111 (login method: gmail)
```

### Test Notification
1. Login (phone, email, or Gmail)
2. Trigger action (like, comment, follow)
3. Check if notification appears

## Works For All Login Methods
- ✅ Phone + OTP
- ✅ Email + OTP
- ✅ Gmail OAuth

## Security
```bash
echo "firebase-service-account.json" >> .gitignore
```

Done! FCM now works for all login methods.
