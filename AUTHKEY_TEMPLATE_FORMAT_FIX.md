# AuthKey.io OTP Template Format Fix

## Summary
Fixed the AuthKey.io SMS OTP implementation to use the correct template format with SID 29663 and query parameters instead of custom SMS messages.

## What Was Changed

### Before (Incorrect)
- Endpoint: `console.authkey.io/restapi/request.php`
- Method: Sending full SMS message in `sms` parameter
- Parameters: `authkey`, `mobile`, `country_code`, `sms`, `sender`, `pe_id`, `template_id`
- Issue: AuthKey.io was not using the template, just sending the raw message

### After (Correct)
- Endpoint: `api.authkey.io/request`
- Method: Using template SID with variable substitution
- Parameters: `authkey`, `mobile`, `country_code`, `sid`, `otp`, `company`
- Benefit: AuthKey.io template handles message formatting and variable replacement

## Template Configuration

### Template SID: 29663
- **Template Text**: `Use {#otp#} as your OTP to access your {#company#}`
- **Variables**:
  - `{#otp#}` - Replaced with the 6-digit OTP code
  - `{#company#}` - Replaced with "ShowOff"

### API Request Format
```
https://api.authkey.io/request?authkey=YOUR_AUTHKEY&mobile=9811226924&country_code=91&sid=29663&otp=123456&company=ShowOff
```

## Implementation Details

### File: `server/services/authkeyService.js`

#### Method: `sendOTP(mobile, countryCode)`
```javascript
// Generate OTP locally
const otp = this.generateOTP();

// Build query parameters with template variables
const params = new URLSearchParams({
  authkey: this.authKey,
  mobile: mobile,
  country_code: countryCode,
  sid: this.templateId,        // Template SID 29663
  otp: otp,                     // Will replace {#otp#}
  company: 'ShowOff'            // Will replace {#company#}
});

// Send to api.authkey.io (not console.authkey.io)
const path = `/request?${params.toString()}`;
```

#### Response Handling
```javascript
if (response.LogID && response.Message === 'Submitted Successfully') {
  // Success - OTP sent with template format
  resolve({
    success: true,
    logId: response.LogID,
    otp: otp,
    message: response.Message
  });
}
```

## Configuration

### Environment Variables (`.env`)
```
AUTHKEY_API_KEY=4e51b96379db3b83
AUTHKEY_SENDER_ID=ShowOff
AUTHKEY_TEMPLATE_ID=29663
AUTHKEY_PE_ID=1101735621000123456
```

## Testing

### Test File: `test_otp_template_format.js`
Run the test to verify the template format works:
```bash
node test_otp_template_format.js
```

### Expected Response
```json
{
  "LogID": "05f9038825fd406fbdc6f862bc617ad6",
  "Message": "Submitted Successfully"
}
```

### OTP Verification
1. OTP is generated locally (6 digits)
2. OTP is sent via AuthKey.io template
3. OTP is stored in memory for verification
4. User enters OTP in app
5. OTP is verified against stored value

## Benefits

1. **Correct Template Usage**: Uses AuthKey.io's template system as intended
2. **Variable Substitution**: AuthKey.io handles message formatting
3. **Consistent Format**: All OTPs follow the same template format
4. **Better Delivery**: Template-based messages have better delivery rates
5. **Professional Appearance**: Message is consistent and professional

## Email OTP

### File: `server/services/authkeyService.js`

#### Method: `sendEmailOTP(email)`
Similar implementation for email using template ID from `AUTHKEY_EMAIL_TEMPLATE_ID` (default: 1001)

```javascript
const params = new URLSearchParams({
  authkey: this.authKey,
  email: email,
  mid: process.env.AUTHKEY_EMAIL_TEMPLATE_ID || '1001',
  otp: otp,
  company: 'ShowOff'
});
```

## Troubleshooting

### Issue: "Country Code is required"
- **Cause**: Missing or incorrect country code format
- **Solution**: Ensure `country_code` parameter is included (e.g., "91" for India)

### Issue: OTP not received
- **Cause**: Template not configured correctly in AuthKey.io console
- **Solution**: Verify template SID 29663 exists and contains `{#otp#}` and `{#company#}` variables

### Issue: Wrong message format
- **Cause**: Using old endpoint or custom SMS message
- **Solution**: Use `api.authkey.io/request` with `sid` parameter

## Related Files
- `server/services/authkeyService.js` - AuthKey service implementation
- `server/controllers/authController.js` - OTP endpoints
- `server/.env` - Configuration
- `test_otp_template_format.js` - Test file
- `test_otp_localhost.js` - Integration test

## Next Steps
1. Test phone OTP with the app
2. Verify email OTP template configuration
3. Monitor delivery rates
4. Adjust template if needed
