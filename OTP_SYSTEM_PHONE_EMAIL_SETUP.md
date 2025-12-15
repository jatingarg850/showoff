# OTP System Setup - Phone (AuthKey.io) + Email (Resend)

## Overview
- **Phone OTP**: Sent via AuthKey.io SMS API with template SID 29663
- **Email OTP**: Sent via Resend Email API with HTML template

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User Request                             │
│              POST /api/auth/send-otp                        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ├─ Phone? ──→ AuthKey.io SMS API
                     │             (Template SID 29663)
                     │
                     └─ Email? ──→ Resend Email API
                                  (HTML Template)
```

## Phone OTP Setup (AuthKey.io)

### Configuration
```env
AUTHKEY_API_KEY=4e51b96379db3b83
AUTHKEY_SENDER_ID=ShowOff
AUTHKEY_TEMPLATE_ID=29663
AUTHKEY_PE_ID=1101735621000123456
```

### Template Details
- **Template SID**: 29663
- **Template Text**: `Use {#otp#} as your OTP to access your {#company#}`
- **Variables**:
  - `{#otp#}` - 6-digit OTP code
  - `{#company#}` - "ShowOff"

### API Request
```
GET https://api.authkey.io/request?
  authkey=4e51b96379db3b83&
  mobile=9811226924&
  country_code=91&
  sid=29663&
  otp=123456&
  company=ShowOff
```

### Response
```json
{
  "LogID": "05f9038825fd406fbdc6f862bc617ad6",
  "Message": "Submitted Successfully"
}
```

### Flow
1. User requests OTP for phone
2. Server generates 6-digit OTP locally
3. Server sends to AuthKey.io with template variables
4. AuthKey.io replaces `{#otp#}` and `{#company#}` in template
5. SMS sent to user: "Use 123456 as your OTP to access your ShowOff"
6. User receives SMS with OTP
7. User enters OTP in app
8. Server verifies OTP matches stored value

## Email OTP Setup (Resend)

### Configuration
```env
RESEND_API_KEY=re_your_resend_api_key_here
RESEND_FROM_EMAIL=noreply@showoff.life
```

### Getting Resend API Key
1. Go to https://resend.com
2. Sign up for free account
3. Go to API Keys section
4. Create new API key
5. Copy the key (starts with `re_`)
6. Add to `.env` file

### Email Template
- **From**: noreply@showoff.life
- **Subject**: Your ShowOff.life OTP
- **Format**: HTML with styled OTP display
- **Variables**:
  - OTP code (6 digits)
  - Company name (ShowOff)

### API Request
```
POST https://api.resend.com/emails
Authorization: Bearer re_your_resend_api_key_here
Content-Type: application/json

{
  "from": "noreply@showoff.life",
  "to": "user@example.com",
  "subject": "Your ShowOff.life OTP",
  "html": "<html>...</html>",
  "text": "Your ShowOff.life OTP is 123456..."
}
```

### Response
```json
{
  "id": "message_id_here",
  "from": "noreply@showoff.life",
  "to": "user@example.com",
  "created_at": "2025-12-15T10:30:00.000Z"
}
```

### Flow
1. User requests OTP for email
2. Server generates 6-digit OTP locally
3. Server sends to Resend with HTML template
4. Resend sends email to user
5. User receives email with styled OTP display
6. User enters OTP in app
7. Server verifies OTP matches stored value

## Implementation Files

### Services
- `server/services/authkeyService.js` - Phone OTP via AuthKey.io
- `server/services/resendService.js` - Email OTP via Resend

### Controllers
- `server/controllers/authController.js` - sendOTP and verifyOTP endpoints

### Configuration
- `server/.env` - API keys and settings

## Code Flow

### sendOTP Endpoint
```javascript
exports.sendOTP = async (req, res) => {
  const { phone, email, countryCode } = req.body;
  
  if (email) {
    // Use Resend for email OTP
    const result = await resendService.sendEmailOTP(email);
    // Store OTP in memory for verification
    otpStore.set(identifier, {
      otp: result.otp,
      messageId: result.messageId,
      expiresAt: Date.now() + 10 * 60 * 1000
    });
  } else {
    // Use AuthKey.io for phone OTP
    const result = await authKeyService.sendOTP(phone, countryCode);
    // Store OTP in memory for verification
    otpStore.set(identifier, {
      otp: result.otp,
      logId: result.logId,
      expiresAt: Date.now() + 10 * 60 * 1000
    });
  }
};
```

### verifyOTP Endpoint
```javascript
exports.verifyOTP = async (req, res) => {
  const { phone, email, countryCode, otp } = req.body;
  
  const identifier = email || `${countryCode}${phone}`;
  const storedSession = otpStore.get(identifier);
  
  // Verify OTP matches stored value
  if (storedSession.otp === otp) {
    // OTP verified successfully
    otpStore.delete(identifier);
    // Proceed with registration/login
  } else {
    // Invalid OTP
  }
};
```

## Testing

### Test Phone OTP
```bash
node test_otp_template_format.js
```

### Test Email OTP
```bash
node test_resend_email_otp.js
```

### Test Complete Flow
```bash
node test_complete_otp_flow.js
```

## API Endpoints

### Send OTP
```
POST /api/auth/send-otp
Content-Type: application/json

{
  "phone": "9811226924",
  "countryCode": "91"
}
```

Or for email:
```
POST /api/auth/send-otp
Content-Type: application/json

{
  "email": "user@example.com"
}
```

### Verify OTP
```
POST /api/auth/verify-otp
Content-Type: application/json

{
  "phone": "9811226924",
  "countryCode": "91",
  "otp": "123456"
}
```

Or for email:
```
POST /api/auth/verify-otp
Content-Type: application/json

{
  "email": "user@example.com",
  "otp": "123456"
}
```

## Troubleshooting

### Phone OTP Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| "Country Code is required" | Missing country_code | Add `country_code: "91"` |
| OTP not received | Template not configured | Verify template SID 29663 in AuthKey console |
| Wrong message format | Using old endpoint | Use `api.authkey.io/request` |

### Email OTP Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| "Resend API key not configured" | Missing API key | Add RESEND_API_KEY to .env |
| Email not received | Invalid from email | Verify RESEND_FROM_EMAIL is correct |
| 401 Unauthorized | Invalid API key | Check API key in .env |
| 422 Unprocessable Entity | Invalid email format | Verify email address is valid |

## Security Notes

1. **OTP Storage**: Currently stored in memory (Map). For production, use Redis or database
2. **OTP Expiry**: 10 minutes (configurable)
3. **Attempt Limit**: 3 failed attempts before blocking
4. **API Keys**: Keep in .env, never commit to git
5. **HTTPS Only**: Always use HTTPS in production

## Production Checklist

- [ ] Move OTP storage from memory to Redis/database
- [ ] Implement rate limiting on send-otp endpoint
- [ ] Add email verification for Resend (domain verification)
- [ ] Set up monitoring for failed OTP attempts
- [ ] Configure HTTPS for all API calls
- [ ] Add logging for audit trail
- [ ] Test with real phone numbers and emails
- [ ] Set up backup email service (fallback)
- [ ] Configure SMS fallback for email failures

## Related Files
- `server/services/authkeyService.js` - Phone OTP service
- `server/services/resendService.js` - Email OTP service
- `server/controllers/authController.js` - OTP endpoints
- `server/.env` - Configuration
- `test_otp_template_format.js` - Phone OTP test
- `test_resend_email_otp.js` - Email OTP test
- `test_complete_otp_flow.js` - Complete flow test
