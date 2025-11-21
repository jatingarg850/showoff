# Phone.Email OTP Integration

## Overview
ShowOff Life uses phone.email service for OTP (One-Time Password) authentication for both phone numbers and email addresses.

## Configuration

### Environment Variables
Add these to `server/.env`:

```env
PHONE_EMAIL_CLIENT_ID=16687983578815655151
PHONE_EMAIL_API_KEY=I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf
```

### Service Details
- **Provider**: phone.email
- **API Base URL**: `api.phone.email`
- **Client ID**: `16687983578815655151`
- **API Key**: `I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf`

## Implementation

### Service Location
`server/services/phoneEmailService.js`

### Available Methods

#### 1. Send Phone OTP
```javascript
const phoneEmailService = require('./services/phoneEmailService');

// Send OTP to phone number (with country code)
const response = await phoneEmailService.sendPhoneOTP('+1234567890');
```

#### 2. Send Email OTP
```javascript
// Send OTP to email
const response = await phoneEmailService.sendEmailOTP('user@example.com');
```

#### 3. Verify OTP
```javascript
// Verify OTP (works for both phone and email)
const response = await phoneEmailService.verifyOTP('+1234567890', '123456');
// or
const response = await phoneEmailService.verifyOTP('user@example.com', '123456');
```

#### 4. Resend OTP
```javascript
// Automatically detects if identifier is phone or email
const response = await phoneEmailService.resendOTP('+1234567890');
// or
const response = await phoneEmailService.resendOTP('user@example.com');
```

## API Endpoints

### Send OTP
**Endpoint**: `POST /api/auth/send-otp`

**Request Body**:
```json
{
  "email": "user@example.com",
  // OR
  "phone": "1234567890",
  "countryCode": "+1"
}
```

**Response**:
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "identifier": "user@example.com"
}
```

### Verify OTP
**Endpoint**: `POST /api/auth/verify-otp`

**Request Body**:
```json
{
  "identifier": "user@example.com",
  "otp": "123456",
  "username": "johndoe",
  "displayName": "John Doe",
  "referralCode": "ABC123" // optional
}
```

**Response**:
```json
{
  "success": true,
  "message": "OTP verified successfully",
  "token": "jwt_token_here",
  "user": {
    "_id": "user_id",
    "username": "johndoe",
    "email": "user@example.com",
    "isVerified": true
  }
}
```

## Integration Flow

### 1. User Registration/Login Flow

```
User enters phone/email
        ↓
App calls /api/auth/send-otp
        ↓
Server calls phone.email API
        ↓
User receives OTP via SMS/Email
        ↓
User enters OTP
        ↓
App calls /api/auth/verify-otp
        ↓
Server verifies with phone.email
        ↓
User authenticated & JWT token issued
```

### 2. Implementation in Auth Controller

Location: `server/controllers/authController.js`

**Send OTP**:
```javascript
exports.sendOTP = async (req, res) => {
  const { email, phone, countryCode } = req.body;
  
  let otpResponse;
  if (email) {
    otpResponse = await phoneEmailService.sendEmailOTP(email);
  } else {
    const fullPhone = `${countryCode}${phone}`;
    otpResponse = await phoneEmailService.sendPhoneOTP(fullPhone);
  }
  
  // Handle response...
};
```

**Verify OTP**:
```javascript
exports.verifyOTP = async (req, res) => {
  const { identifier, otp } = req.body;
  
  const verifyResponse = await phoneEmailService.verifyOTP(identifier, otp);
  
  if (verifyResponse.success) {
    // Create/update user
    // Generate JWT token
    // Return user data
  }
};
```

## Error Handling

### Common Errors

1. **Invalid OTP**
```json
{
  "success": false,
  "message": "Invalid OTP"
}
```

2. **OTP Expired**
```json
{
  "success": false,
  "message": "OTP has expired"
}
```

3. **Too Many Attempts**
```json
{
  "success": false,
  "message": "Too many failed attempts. Please try again later."
}
```

4. **Service Error**
```json
{
  "success": false,
  "message": "Failed to send OTP. Please try again."
}
```

## Fallback Mechanism

The system includes a fallback for development:
- If phone.email service fails, a local OTP is generated
- Local OTP is stored in memory (use Redis in production)
- Useful for testing without consuming API credits

## Security Features

1. **Rate Limiting**: Max 5 OTP requests per identifier per hour
2. **Attempt Tracking**: Max 3 verification attempts per OTP
3. **Expiration**: OTPs expire after 10 minutes
4. **Secure Storage**: OTPs stored with timestamps and attempt counts

## Testing

### Test Phone OTP
```bash
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "1234567890",
    "countryCode": "+1"
  }'
```

### Test Email OTP
```bash
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com"
  }'
```

### Test Verify OTP
```bash
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "test@example.com",
    "otp": "123456",
    "username": "testuser",
    "displayName": "Test User"
  }'
```

## Production Considerations

1. **Environment Variables**: Always use `.env` for credentials
2. **Redis**: Replace in-memory OTP storage with Redis
3. **Monitoring**: Log OTP send/verify attempts
4. **Rate Limiting**: Implement stricter rate limits
5. **IP Tracking**: Track requests by IP to prevent abuse
6. **Backup Service**: Have a backup OTP provider

## Phone.Email API Documentation

Official Docs: https://phone.email/docs

### API Endpoints Used

1. **Send OTP**: `POST https://api.phone.email/v1/otp/send`
2. **Verify OTP**: `POST https://api.phone.email/v1/otp/verify`

### Headers Required
```
Content-Type: application/json
Authorization: Bearer {API_KEY}
```

## Support

For issues with phone.email service:
- Email: support@phone.email
- Docs: https://phone.email/docs
- Dashboard: https://phone.email/dashboard

---

**Status**: ✅ Fully Integrated and Working
**Last Updated**: 2024
