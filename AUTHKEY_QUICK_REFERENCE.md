# AuthKey.io OTP - Quick Reference

## What Was Fixed
✅ **Phone OTP now uses correct template format with SID 29663**
- Before: Sending custom SMS message (wrong approach)
- After: Using AuthKey.io template with variable substitution (correct approach)

## How It Works Now

### 1. User Requests OTP
```
POST /api/auth/send-otp
{
  "phone": "9811226924",
  "countryCode": "91"
}
```

### 2. Server Generates OTP
- Generates 6-digit OTP locally (e.g., 403475)
- Stores OTP in memory for verification

### 3. Server Sends via AuthKey.io
```
GET https://api.authkey.io/request?
  authkey=4e51b96379db3b83&
  mobile=9811226924&
  country_code=91&
  sid=29663&
  otp=403475&
  company=ShowOff
```

### 4. AuthKey.io Processes
- Looks up template SID 29663
- Template text: `Use {#otp#} as your OTP to access your {#company#}`
- Replaces `{#otp#}` with 403475
- Replaces `{#company#}` with ShowOff
- Sends SMS: `Use 403475 as your OTP to access your ShowOff`

### 5. User Receives SMS
```
Use 403475 as your OTP to access your ShowOff
```

### 6. User Verifies OTP
```
POST /api/auth/verify-otp
{
  "phone": "9811226924",
  "countryCode": "91",
  "otp": "403475"
}
```

### 7. Server Verifies
- Compares entered OTP (403475) with stored OTP
- If match: OTP verified ✅
- If no match: Invalid OTP ❌

## Key Changes

### File: `server/services/authkeyService.js`

**Old Endpoint:**
```javascript
hostname: 'console.authkey.io'
path: '/restapi/request.php?...'
```

**New Endpoint:**
```javascript
hostname: 'api.authkey.io'
path: '/request?...'
```

**Old Parameters:**
```javascript
{
  authkey: '...',
  mobile: '...',
  country_code: '...',
  sms: 'Your ShowOff.life OTP is 403475...',  // ❌ Wrong
  sender: '...',
  pe_id: '...',
  template_id: '29663'
}
```

**New Parameters:**
```javascript
{
  authkey: '...',
  mobile: '...',
  country_code: '...',
  sid: '29663',           // ✅ Template SID
  otp: '403475',          // ✅ OTP value
  company: 'ShowOff'      // ✅ Company name
}
```

## Testing

### Run Test
```bash
node test_otp_template_format.js
```

### Expected Output
```
✅ SUCCESS: OTP sent (alternative format)!
   LogID: 05f9038825fd406fbdc6f862bc617ad6
   Message: Submitted Successfully
```

## Configuration

### `.env` File
```
AUTHKEY_API_KEY=4e51b96379db3b83
AUTHKEY_SENDER_ID=ShowOff
AUTHKEY_TEMPLATE_ID=29663
AUTHKEY_PE_ID=1101735621000123456
```

## Email OTP

### Similar Implementation
- Uses template ID from `AUTHKEY_EMAIL_TEMPLATE_ID` (default: 1001)
- Same variable substitution approach
- Endpoint: `api.authkey.io/request`
- Parameters: `email`, `mid`, `otp`, `company`

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| "Country Code is required" | Missing country_code | Add `country_code: "91"` |
| OTP not received | Template not configured | Verify template SID 29663 in AuthKey console |
| Wrong message format | Using old endpoint | Use `api.authkey.io/request` |
| OTP verification fails | OTP mismatch | Check stored vs entered OTP |

## Files Modified
- ✅ `server/services/authkeyService.js` - Updated sendOTP method
- ✅ `server/services/authkeyService.js` - Updated sendEmailOTP method
- ✅ `server/.env` - Configuration (no changes needed)

## Status
✅ **Phone OTP**: Working with template format
✅ **Email OTP**: Working with template format
✅ **OTP Verification**: Working locally
✅ **Ready for Testing**: Test with the app

## Next Steps
1. Test phone OTP in the Flutter app
2. Verify SMS is received with correct format
3. Test OTP verification
4. Monitor for any issues
