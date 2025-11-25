# 📱 AuthKey.io SMS/OTP Integration Guide

## Overview

Your application now uses **AuthKey.io** for sending SMS OTP (One-Time Password) for phone number verification. This replaces the previous Phone.email OTP system with a more robust 2FA solution.

## 🎯 What's Implemented

### ✅ Features

1. **SMS OTP Sending** - Send 6-digit OTP via SMS using AuthKey.io 2FA API
2. **OTP Verification** - Verify OTP using AuthKey.io verification API
3. **Template Support** - Use pre-configured message templates
4. **DLT Compliance** - Support for Indian DLT (Distributed Ledger Technology) requirements
5. **Fallback System** - Falls back to local OTP in development if service unavailable
6. **Multi-Channel** - Support for SMS, Voice, and Email (via templates)

### 📁 Files Created/Modified

**New Files:**
- `server/services/authkeyService.js` - AuthKey.io service wrapper

**Modified Files:**
- `server/controllers/authController.js` - Updated sendOTP and verifyOTP functions
- `server/.env` - Added AuthKey.io credentials

## 🚀 Setup Instructions

### Step 1: Get AuthKey.io Credentials

1. **Sign up** at https://console.authkey.io
2. **Get your API Key:**
   - Go to Dashboard
   - Find your AUTHKEY (API Key)
   - Copy it

3. **Create SMS Template:**
   - Go to "Templates" section
   - Click "Create Template"
   - Choose "SMS" channel
   - Enter template content:
     ```
     Your OTP for ShowOff Life is {#2fa#}. Valid for 10 minutes. Do not share this code.
     ```
   - Note: `{#2fa#}` is a special variable for system-generated OTP
   - Save and note the **Template SID**

4. **Get Sender ID:**
   - Go to "Sender IDs" section
   - Create or note your approved Sender ID
   - For India: Must be 6 characters (e.g., "SHWOFF")

5. **DLT Setup (For India Only):**
   - Go to "DLT Setup" menu
   - Upload DLT template CSV or enter details manually
   - Note your **PE ID** (Principal Entity ID)
   - Note your **DLT Template ID**

### Step 2: Configure Environment Variables

Edit `server/.env` file:

```env
# AuthKey.io SMS/OTP Service Configuration
AUTHKEY_API_KEY=your_actual_authkey_here
AUTHKEY_SENDER_ID=SHWOFF
AUTHKEY_TEMPLATE_ID=1234
AUTHKEY_PE_ID=1234567890123456789
```

**Example with real values:**
```env
AUTHKEY_API_KEY=a1b2c3d4e5f6g7h8i9j0
AUTHKEY_SENDER_ID=SHWOFF
AUTHKEY_TEMPLATE_ID=5678
AUTHKEY_PE_ID=1201234567890123456
```

### Step 3: Restart Server

```bash
cd server
npm start
```

### Step 4: Test OTP Sending

**Using API:**
```bash
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "9811226924",
    "countryCode": "91"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "identifier": "919811226924",
    "expiresIn": 600,
    "logId": "28bf7375bb54540ba03a4eb873d4da44"
  }
}
```

### Step 5: Test OTP Verification

```bash
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "9811226924",
    "countryCode": "91",
    "otp": "123456"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "OTP verified successfully"
}
```

## 🔧 How It Works

### Sending OTP Flow

```
1. User enters phone number
   ↓
2. App calls POST /api/auth/send-otp
   ↓
3. Backend calls AuthKey.io 2FA API
   ↓
4. AuthKey.io generates OTP and sends SMS
   ↓
5. AuthKey.io returns LogID
   ↓
6. Backend stores LogID with expiry
   ↓
7. User receives SMS with OTP
```

### Verifying OTP Flow

```
1. User enters OTP
   ↓
2. App calls POST /api/auth/verify-otp
   ↓
3. Backend retrieves stored LogID
   ↓
4. Backend calls AuthKey.io verification API
   ↓
5. AuthKey.io validates OTP against LogID
   ↓
6. Returns success/failure
   ↓
7. Backend deletes session on success
```

## 📡 API Endpoints

### Send OTP

**Endpoint:** `POST /api/auth/send-otp`

**Request:**
```json
{
  "phone": "9811226924",
  "countryCode": "91"
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "identifier": "919811226924",
    "expiresIn": 600,
    "logId": "28bf7375bb54540ba03a4eb873d4da44",
    "otp": "123456"  // Only in development mode
  }
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "Phone number already registered"
}
```

### Verify OTP

**Endpoint:** `POST /api/auth/verify-otp`

**Request:**
```json
{
  "phone": "9811226924",
  "countryCode": "91",
  "otp": "123456"
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "OTP verified successfully"
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "Invalid OTP",
  "attemptsLeft": 2
}
```

## 🔐 Security Features

### ✅ Implemented

1. **OTP Expiration** - OTPs expire after 10 minutes
2. **Attempt Limiting** - Maximum 3 verification attempts per OTP
3. **LogID Tracking** - Each OTP session has unique LogID
4. **Secure Verification** - OTP verified via AuthKey.io API, not stored locally
5. **Duplicate Prevention** - Checks if phone already registered
6. **HTTPS Only** - All API calls use HTTPS

### 🔒 Best Practices

1. **Never log OTP in production** - Remove console.log statements
2. **Use Redis for storage** - Replace in-memory Map with Redis
3. **Rate limiting** - Limit OTP requests per phone number
4. **CAPTCHA** - Add CAPTCHA to prevent automated abuse
5. **Monitor usage** - Track OTP sending patterns for fraud detection

## 🌍 International SMS

AuthKey.io supports international SMS. Just change the country code:

**Example (USA):**
```json
{
  "phone": "5551234567",
  "countryCode": "1"
}
```

**Example (UK):**
```json
{
  "phone": "7911123456",
  "countryCode": "44"
}
```

## 📊 AuthKey.io Features

### 2FA API

- System-generated OTP
- Automatic SMS delivery
- LogID-based verification
- No OTP storage needed

### Template API

- Custom message templates
- Dynamic variables
- Multi-language support
- Template versioning

### Event API

- Combine multiple templates
- Parallel sending (SMS + Voice)
- Fallback channels
- Shorter API calls

### Multi-Channel

- **SMS** - Text message delivery
- **Voice** - Voice call with OTP
- **Email** - Email delivery
- **WhatsApp** - WhatsApp messages (if enabled)

## 🧪 Testing

### Development Mode

In development, if AuthKey.io service fails:
- Falls back to local OTP generation
- OTP printed in console
- OTP included in API response

**Console Output:**
```
╔════════════════════════════════════════╗
║          🔐 SENDING OTP               ║
╠════════════════════════════════════════╣
║  Phone/Email: 919811226924            ║
╚════════════════════════════════════════╝
📱 Sending OTP to phone: +91 9811226924
✅ OTP sent via AuthKey.io
║  LogID:       28bf7375bb54540ba03a4  ║
╚════════════════════════════════════════╝
```

### Production Mode

In production:
- No fallback to local OTP
- OTP not included in response
- OTP not logged to console
- Service failure returns error

## 🐛 Troubleshooting

### Error: "AuthKey API key not configured"

**Solution:** Add AUTHKEY_API_KEY to .env file

```env
AUTHKEY_API_KEY=your_actual_key_here
```

### Error: "AuthKey Template ID not configured"

**Solution:** Add AUTHKEY_TEMPLATE_ID to .env file

```env
AUTHKEY_TEMPLATE_ID=1234
```

### Error: "Failed to send OTP"

**Possible Causes:**
1. Invalid API key
2. Insufficient balance
3. Invalid phone number format
4. Template not approved
5. DLT issues (India only)

**Solution:**
1. Check API key is correct
2. Check account balance on console.authkey.io
3. Verify phone number format (without +)
4. Ensure template is approved
5. Verify DLT setup (India)

### Error: "Invalid OTP"

**Possible Causes:**
1. Wrong OTP entered
2. OTP expired (>10 minutes)
3. Too many attempts (>3)
4. LogID mismatch

**Solution:**
1. Request new OTP
2. Verify within 10 minutes
3. Limit verification attempts
4. Check LogID is stored correctly

### SMS Not Received

**Possible Causes:**
1. Phone number incorrect
2. Network issues
3. DLT not configured (India)
4. Sender ID not approved
5. Template not approved

**Solution:**
1. Verify phone number format
2. Check network connectivity
3. Complete DLT setup (India)
4. Get sender ID approved
5. Get template approved

## 📈 Monitoring

### Check Logs

Server logs show:
- OTP sending attempts
- AuthKey.io responses
- Verification attempts
- Success/failure rates

### AuthKey.io Dashboard

Monitor on console.authkey.io:
- SMS delivery status
- Failed deliveries
- Account balance
- Usage statistics
- Delivery reports

## 💰 Pricing

AuthKey.io charges per SMS sent. Check current pricing at:
https://console.authkey.io/pricing

**Typical Costs (India):**
- Transactional SMS: ₹0.15 - ₹0.25 per SMS
- Promotional SMS: ₹0.10 - ₹0.20 per SMS
- Voice OTP: ₹0.30 - ₹0.50 per call

## 🔄 Migration from Phone.email

### What Changed

**Before (Phone.email):**
- Used for web button integration
- Auto user creation
- No OTP verification API

**After (AuthKey.io):**
- Used for SMS OTP sending
- Proper 2FA verification
- LogID-based tracking

**Note:** Phone.email web button integration still works for web-based phone verification!

### Coexistence

Both services can coexist:
- **AuthKey.io** - For traditional OTP flow (send OTP → verify OTP → register)
- **Phone.email** - For web button integration (auto user creation)

## 📚 Additional Resources

- **AuthKey.io Docs:** https://docs.authkey.io
- **Console:** https://console.authkey.io
- **Support:** support@authkey.io
- **API Reference:** https://docs.authkey.io/api-reference

## ✅ Checklist

Before going to production:

- [ ] Get AuthKey.io account
- [ ] Create SMS template with {#2fa#} variable
- [ ] Get template approved
- [ ] Configure sender ID
- [ ] Complete DLT setup (India)
- [ ] Add credentials to .env
- [ ] Test OTP sending
- [ ] Test OTP verification
- [ ] Remove console.log statements
- [ ] Implement Redis for OTP storage
- [ ] Add rate limiting
- [ ] Add CAPTCHA
- [ ] Monitor usage
- [ ] Set up alerts for failures

## 🎉 Summary

Your application now has:

✅ **Professional SMS OTP** via AuthKey.io
✅ **2FA Verification** with LogID tracking
✅ **DLT Compliance** for India
✅ **Fallback System** for development
✅ **Multi-Channel Support** (SMS/Voice/Email)
✅ **Secure Verification** via API
✅ **International Support** for global SMS

**Next Steps:**
1. Get AuthKey.io credentials
2. Configure .env file
3. Test OTP flow
4. Deploy to production

---

**Last Updated:** November 25, 2025
**Status:** ✅ Ready for Configuration
**Service:** AuthKey.io 2FA API
