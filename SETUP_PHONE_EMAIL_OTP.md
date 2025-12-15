# Quick Setup Guide - Phone & Email OTP

## What's New
✅ **Phone OTP**: AuthKey.io SMS with template SID 29663
✅ **Email OTP**: Resend Email API with HTML template
✅ **Automatic routing**: Phone → AuthKey.io, Email → Resend

## Step 1: Get Resend API Key

1. Go to https://resend.com
2. Click "Sign Up" (free account)
3. Verify your email
4. Go to "API Keys" section
5. Click "Create API Key"
6. Copy the key (starts with `re_`)

## Step 2: Update .env File

```env
# Resend Email Service Configuration
RESEND_API_KEY=re_your_api_key_here
RESEND_FROM_EMAIL=noreply@showoff.life
```

Replace `re_your_api_key_here` with your actual Resend API key.

## Step 3: Verify Configuration

### Phone OTP (AuthKey.io)
```env
AUTHKEY_API_KEY=4e51b96379db3b83
AUTHKEY_SENDER_ID=ShowOff
AUTHKEY_TEMPLATE_ID=29663
AUTHKEY_PE_ID=1101735621000123456
```
✅ Already configured

### Email OTP (Resend)
```env
RESEND_API_KEY=re_your_api_key_here
RESEND_FROM_EMAIL=noreply@showoff.life
```
⚠️ Needs your API key

## Step 4: Test the Setup

### Test Phone OTP
```bash
node test_otp_template_format.js
```

Expected output:
```
✅ SUCCESS: OTP sent (alternative format)!
   LogID: 05f9038825fd406fbdc6f862bc617ad6
   Message: Submitted Successfully
```

### Test Email OTP
```bash
node test_resend_email_otp.js
```

Expected output:
```
✅ SUCCESS: Email OTP sent via Resend!
   Message ID: message_id_here
   OTP Code: 123456
```

### Test Complete Flow
```bash
node test_complete_otp_flow.js
```

Expected output:
```
✅ ALL TESTS PASSED
```

## Step 5: Test with API

### Send Phone OTP
```bash
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "9811226924",
    "countryCode": "91"
  }'
```

Response:
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "identifier": "919811226924",
    "expiresIn": 600,
    "logId": "05f9038825fd406fbdc6f862bc617ad6",
    "otp": "123456"
  }
}
```

### Send Email OTP
```bash
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com"
  }'
```

Response:
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "identifier": "user@example.com",
    "expiresIn": 600,
    "logId": "message_id_here",
    "otp": "123456"
  }
}
```

### Verify OTP
```bash
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "otp": "123456"
  }'
```

Response:
```json
{
  "success": true,
  "message": "OTP verified successfully"
}
```

## How It Works

### Phone OTP Flow
```
User → App → Server → AuthKey.io → SMS → User Phone
                ↓
            Store OTP in memory
                ↓
User enters OTP → Server verifies → Success/Fail
```

### Email OTP Flow
```
User → App → Server → Resend → Email → User Inbox
                ↓
            Store OTP in memory
                ↓
User enters OTP → Server verifies → Success/Fail
```

## Files Modified/Created

### New Files
- ✅ `server/services/resendService.js` - Resend email service
- ✅ `test_resend_email_otp.js` - Email OTP test
- ✅ `OTP_SYSTEM_PHONE_EMAIL_SETUP.md` - Full documentation

### Modified Files
- ✅ `server/controllers/authController.js` - Updated sendOTP to use Resend for email
- ✅ `server/.env` - Added Resend configuration

### Existing Files (No Changes)
- `server/services/authkeyService.js` - Phone OTP (already working)
- `test_otp_template_format.js` - Phone OTP test (already working)
- `test_complete_otp_flow.js` - Complete flow test (already working)

## Troubleshooting

### Email not sending
1. Check RESEND_API_KEY is set correctly
2. Verify email format is valid
3. Check Resend dashboard for errors
4. Try with a different email address

### Phone OTP not working
1. Check AUTHKEY_API_KEY is set
2. Verify phone number format (without +)
3. Check country code is correct
4. Verify template SID 29663 exists

### OTP verification fails
1. Check OTP hasn't expired (10 minutes)
2. Verify OTP matches exactly
3. Check identifier (phone/email) matches

## Next Steps

1. ✅ Set up Resend API key
2. ✅ Update .env file
3. ✅ Test phone OTP
4. ✅ Test email OTP
5. ✅ Test complete flow
6. ✅ Test with Flutter app
7. ✅ Monitor for issues
8. ✅ Deploy to production

## Support

For issues:
1. Check logs in server console
2. Review OTP_SYSTEM_PHONE_EMAIL_SETUP.md
3. Test with curl commands
4. Check API keys are correct
5. Verify email/phone format

## Production Notes

- OTP stored in memory (use Redis for production)
- 10-minute expiry (configurable)
- 3 attempt limit (configurable)
- Keep API keys in .env (never commit)
- Use HTTPS only in production
- Monitor failed OTP attempts
- Set up email domain verification in Resend
