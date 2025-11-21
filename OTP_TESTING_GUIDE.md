# OTP Integration Testing Guide

## Quick Test Instructions

### Testing Phone OTP

1. **Open the App**
   - Navigate to Sign Up screen
   - Select "Phone" option

2. **Enter Phone Number**
   - Select country code (e.g., +1 for US)
   - Enter phone number: `1234567890`
   - Tap "Continue"

3. **Check Server Console**
   - Look for log: `📱 Sending OTP to phone: +11234567890`
   - In development mode, OTP will be logged: `⚠️ Fallback OTP for +11234567890: 123456`

4. **Enter OTP**
   - OTP verification modal appears
   - Enter the 6-digit OTP from console
   - System auto-verifies when all 6 digits entered

5. **Success**
   - Green success message appears
   - Navigates to password setup screen

### Testing Email OTP

1. **Open the App**
   - Navigate to Sign Up screen
   - Select "Email" option

2. **Enter Email**
   - Enter email: `test@example.com`
   - Tap "Continue"

3. **Check Server Console**
   - Look for log: `📧 Sending OTP to email: test@example.com`
   - In development mode, OTP will be logged: `⚠️ Fallback OTP for test@example.com: 654321`

4. **Enter OTP**
   - OTP verification modal appears
   - Enter the 6-digit OTP from console
   - System auto-verifies when all 6 digits entered

5. **Success**
   - Green success message appears
   - Navigates to password setup screen

## Testing Error Cases

### Invalid OTP
1. Enter wrong OTP code
2. Screen shakes with red border
3. Error message: "Invalid OTP"
4. Attempts counter decrements (3 attempts max)
5. OTP fields clear automatically

### OTP Expiry
1. Wait for 10 minutes after OTP sent
2. Try to verify OTP
3. Error message: "OTP expired. Please request a new one."
4. Tap "Resend" to get new OTP

### Resend OTP
1. Wait for 20-second countdown
2. Tap "Resend" when enabled
3. New OTP sent
4. Timer resets to 20 seconds
5. Success message: "OTP code resent successfully"

### Duplicate User
1. Try to register with existing email/phone
2. Error message: "Email already registered" or "Phone number already registered"
3. Cannot proceed to OTP screen

## Server Logs to Watch

### Successful Flow:
```
📧 Sending OTP to email: user@example.com
✅ OTP sent successfully to user@example.com
🔍 Verifying OTP for user@example.com
✅ OTP verified successfully for user@example.com
```

### Error Flow:
```
📱 Sending OTP to phone: +11234567890
❌ Phone.email service error: Request failed
⚠️ Fallback OTP for +11234567890: 123456
🔍 Verifying OTP for +11234567890
❌ Invalid OTP for +11234567890 (Attempt 1/3)
```

## API Testing with Postman/cURL

### Send OTP (Phone)
```bash
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "1234567890",
    "countryCode": "+1"
  }'
```

### Send OTP (Email)
```bash
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com"
  }'
```

### Verify OTP (Phone)
```bash
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "1234567890",
    "countryCode": "+1",
    "otp": "123456"
  }'
```

### Verify OTP (Email)
```bash
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "otp": "654321"
  }'
```

## Expected Responses

### Send OTP Success:
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "identifier": "+11234567890",
    "expiresIn": 600
  }
}
```

### Verify OTP Success:
```json
{
  "success": true,
  "message": "OTP verified successfully",
  "data": { ... }
}
```

### Error Response:
```json
{
  "success": false,
  "message": "Invalid OTP",
  "attemptsLeft": 2
}
```

## Development Mode Features

### Fallback OTP System:
- ✅ Generates local OTP when phone.email unavailable
- ✅ Logs OTP to console for testing
- ✅ Returns OTP in API response (dev only)
- ✅ Full verification flow works

### Console Output:
```
⚠️ Fallback OTP for test@example.com: 123456
```

### API Response (Dev Only):
```json
{
  "success": true,
  "message": "OTP sent successfully (fallback mode)",
  "otp": "123456"
}
```

## Troubleshooting

### OTP Not Appearing in Console:
- Check server is running: `npm run dev`
- Verify NODE_ENV is set to 'development'
- Check for error messages in console

### Verification Always Fails:
- Ensure OTP matches exactly (6 digits)
- Check OTP hasn't expired (10 minutes)
- Verify attempts haven't exceeded (3 max)
- Check server logs for errors

### Modal Not Opening:
- Check network connection
- Verify API endpoint is reachable
- Check for JavaScript errors in console
- Ensure OTP was sent successfully

## Production Testing

### With Real phone.email Service:
1. Ensure API credentials are correct
2. Test with real phone numbers
3. Test with real email addresses
4. Verify OTP delivery time
5. Check spam folders for emails
6. Test international phone numbers

### Monitoring:
- Watch server logs for errors
- Monitor OTP delivery success rate
- Track verification success rate
- Monitor API response times

## Test Checklist

- [ ] Phone OTP send
- [ ] Phone OTP verify (correct)
- [ ] Phone OTP verify (incorrect)
- [ ] Phone OTP resend
- [ ] Phone OTP expiry
- [ ] Email OTP send
- [ ] Email OTP verify (correct)
- [ ] Email OTP verify (incorrect)
- [ ] Email OTP resend
- [ ] Email OTP expiry
- [ ] Duplicate user check
- [ ] Invalid email format
- [ ] Max attempts exceeded
- [ ] Network error handling
- [ ] UI animations (shake on error)
- [ ] Timer countdown
- [ ] Auto-focus on OTP fields
- [ ] Auto-verify on complete

## Success Criteria

✅ OTP sent successfully (phone & email)
✅ OTP received and logged in console
✅ OTP verification works correctly
✅ Error handling displays proper messages
✅ Resend functionality works
✅ Timer countdown works
✅ UI animations work smoothly
✅ Navigation flows correctly
✅ Server logs show proper status

---

**Ready to test! Start the app and follow the steps above.** 🚀
