# Sign-In OTP Testing Guide

## Quick Test Steps

### 1. Start the Server
```bash
cd server
npm start
```

### 2. Run the Flutter App
```bash
cd apps
flutter run
```

### 3. Test Phone Sign-In with OTP

#### Step 1: Navigate to Sign-In
- Tap "Sign In" on welcome screen
- Select "Sign In with Phone"

#### Step 2: Enter Phone Number
- Select country (e.g., United States +1)
- Enter phone number (e.g., 9876543210)
- Tap "Send Code"
- Should see loading spinner
- OTP screen should appear

#### Step 3: Enter OTP
- Check server logs for OTP code (in development mode)
- Or check your phone/email for OTP
- Enter 6-digit OTP
- Tap "Continue"
- Should verify with backend and navigate to MainScreen

#### Step 4: Verify Success
- Should be logged in and see MainScreen
- Check server logs for successful verification

## Expected Server Logs

### When Sending OTP
```
╔════════════════════════════════════════╗
║          🔐 SENDING OTP               ║
╠════════════════════════════════════════╣
║  Phone/Email: +19876543210            ║
╚════════════════════════════════════════╝
📱 Sending OTP to phone: +1 9876543210
✅ OTP sent via AuthKey.io SMS
║  OTP Code:    123456                  ║
║  LogID:       abc123def456            ║
```

### When Verifying OTP
```
╔════════════════════════════════════════╗
║       🔍 VERIFYING OTP                ║
╠════════════════════════════════════════╣
║  Phone/Email: +19876543210            ║
║  Entered OTP: 123456                  ║
║  Attempts:    0/3                     ║
╚════════════════════════════════════════╝
🔍 Verifying OTP locally
   Stored OTP: 123456
   Entered OTP: 123456
✅ OTP verified locally - MATCH!

╔════════════════════════════════════════╗
║       ✅ OTP VERIFIED SUCCESS         ║
╠════════════════════════════════════════╣
║  Phone/Email: +19876543210            ║
╚════════════════════════════════════════╝
```

## Troubleshooting

### Issue: "Failed to send OTP"
- Check server is running
- Check network connection
- Check AuthKey.io credentials in `.env`
- Check phone number format

### Issue: "Invalid OTP"
- Make sure you entered the correct OTP
- Check OTP hasn't expired (10 minutes)
- Try resending OTP
- Check server logs for actual OTP code

### Issue: App crashes after OTP verification
- Check Flutter logs for errors
- Make sure MainScreen exists and is properly configured
- Check for any missing dependencies

### Issue: OTP not being sent to phone
- Check AuthKey.io credentials
- Check phone number format (should be without +)
- Check country code is correct
- Check AuthKey.io account has SMS credits

## Development Mode

In development mode, the OTP is returned in the API response:
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "identifier": "+19876543210",
    "expiresIn": 600,
    "otp": "123456"
  }
}
```

This makes testing easier without needing to receive actual SMS.

## Production Mode

In production mode, the OTP is NOT returned in the response for security:
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "identifier": "+19876543210",
    "expiresIn": 600
  }
}
```

Users must receive the OTP via SMS or email.

## Resend OTP

- Click "Resend" button after 20 seconds
- Should send new OTP to backend
- Timer resets to 20 seconds
- Previous OTP becomes invalid

## Use Another Number

- Click "Use another number" to go back
- Can enter different phone number
- Will send new OTP to new number
