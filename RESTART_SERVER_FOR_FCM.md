# 🚀 Restart Server for FCM

## Quick Action

### Step 1: Stop Current Server
Press `Ctrl+C` in the terminal where server is running

### Step 2: Restart Server
```bash
cd server
npm start
```

### Step 3: Verify FCM Initialized
Look for this in logs:
```
✅ Firebase Admin initialized successfully
   Project: showofflife-life
```

## If You See This:
```
✅ Firebase Admin initialized successfully
   Project: showofflife-life
```
✅ **FCM is ready!**

## If You See This:
```
❌ Firebase Admin initialization failed: firebase-service-account.json not found
```
❌ **Check file location**: `server/firebase-service-account.json`

## Test FCM

1. **Login to app** (phone, email, or Gmail)
2. **Trigger action** (like post, follow user, send message)
3. **Check server logs** for:
```
✅ FCM sent to user 693fea1dbd0b31693bb4dc02 (login method: phone)
```

## Done!
FCM now works for all login methods (phone, email, Gmail)
