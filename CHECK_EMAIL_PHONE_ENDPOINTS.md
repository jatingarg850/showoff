# Check Email and Phone Availability Endpoints

## Overview

New endpoints to check if email or phone number is already registered before sending OTP or attempting sign-up.

## Endpoints

### 1. Check Email Availability

**Endpoint**: `POST /api/auth/check-email`

**Purpose**: Check if an email address is already registered

**Request**:
```json
{
  "email": "user@example.com"
}
```

**Response (Available)**:
```json
{
  "success": true,
  "available": true,
  "message": "Email is available",
  "exists": false
}
```

**Response (Already Exists)**:
```json
{
  "success": false,
  "available": false,
  "message": "Email already registered",
  "exists": true
}
```

**Response (Invalid Format)**:
```json
{
  "success": false,
  "message": "Please provide a valid email address"
}
```

### 2. Check Phone Availability

**Endpoint**: `POST /api/auth/check-phone`

**Purpose**: Check if a phone number is already registered

**Request**:
```json
{
  "phone": "9811226924",
  "countryCode": "91"
}
```

**Response (Available)**:
```json
{
  "success": true,
  "available": true,
  "message": "Phone number is available",
  "exists": false
}
```

**Response (Already Exists)**:
```json
{
  "success": false,
  "available": false,
  "message": "Phone number already registered",
  "exists": true
}
```

**Response (Invalid Format)**:
```json
{
  "success": false,
  "message": "Please provide a valid phone number"
}
```

## Usage Flow

### Sign-Up with Email

```
1. User enters email
   ↓
2. App calls: POST /api/auth/check-email
   ↓
3. If available:
   - Show "Email is available"
   - Allow user to proceed
   - Call: POST /api/auth/send-otp
   ↓
4. If already exists:
   - Show "Email already registered"
   - Suggest login instead
   - Don't send OTP
```

### Sign-Up with Phone

```
1. User enters phone number
   ↓
2. App calls: POST /api/auth/check-phone
   ↓
3. If available:
   - Show "Phone is available"
   - Allow user to proceed
   - Call: POST /api/auth/send-otp
   ↓
4. If already exists:
   - Show "Phone already registered"
   - Suggest login instead
   - Don't send OTP
```

## Implementation Details

### Email Validation
- Checks email format using regex: `/^[^\s@]+@[^\s@]+\.[^\s@]+$/`
- Converts email to lowercase for comparison
- Checks database for existing email

### Phone Validation
- Validates phone length: 7-15 digits
- Checks database for existing phone
- Requires country code

### Response Format
- `success`: Boolean indicating if request was successful
- `available`: Boolean indicating if email/phone is available
- `exists`: Boolean indicating if email/phone already exists
- `message`: Human-readable message

## Error Handling

### Email Errors
- Missing email: "Please provide an email"
- Invalid format: "Please provide a valid email address"
- Already exists: "Email already registered"

### Phone Errors
- Missing phone/country code: "Please provide phone number and country code"
- Invalid format: "Please provide a valid phone number"
- Already exists: "Phone number already registered"

## Testing

### Test Email Endpoint
```bash
curl -X POST http://localhost:3000/api/auth/check-email \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'
```

### Test Phone Endpoint
```bash
curl -X POST http://localhost:3000/api/auth/check-phone \
  -H "Content-Type: application/json" \
  -d '{"phone": "9811226924", "countryCode": "91"}'
```

### Run Test Suite
```bash
node test_check_email_phone.js
```

## Flutter Integration

### Check Email Before Sign-Up
```dart
Future<bool> checkEmailAvailability(String email) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/check-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['available']) {
        // Email is available, proceed with OTP
        return true;
      } else {
        // Email already exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        return false;
      }
    }
  } catch (e) {
    print('Error checking email: $e');
  }
  return false;
}
```

### Check Phone Before Sign-Up
```dart
Future<bool> checkPhoneAvailability(String phone, String countryCode) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/check-phone'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'countryCode': countryCode,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['available']) {
        // Phone is available, proceed with OTP
        return true;
      } else {
        // Phone already exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        return false;
      }
    }
  } catch (e) {
    print('Error checking phone: $e');
  }
  return false;
}
```

## Sign-Up Flow with Checks

### Complete Sign-Up Process

```
1. User enters email/phone
   ↓
2. App validates format locally
   ↓
3. App calls check-email or check-phone
   ↓
4. If not available:
   - Show error message
   - Suggest login
   - Stop
   ↓
5. If available:
   - Show "Available"
   - Call send-otp
   ↓
6. User receives OTP
   ↓
7. User enters OTP
   ↓
8. App calls verify-otp
   ↓
9. If verified:
   - Call register
   - Create account
   - Show success
   ↓
10. If not verified:
    - Show error
    - Allow retry
```

## Benefits

✅ **Better UX**: Users know immediately if email/phone is available
✅ **Prevent Errors**: Avoid sending OTP for existing accounts
✅ **Clear Messaging**: Users understand why they can't sign up
✅ **Suggest Login**: Can redirect existing users to login
✅ **Validation**: Catch invalid formats early
✅ **Reduce API Calls**: Check before sending OTP

## Related Endpoints

- `POST /api/auth/send-otp` - Send OTP after checking availability
- `POST /api/auth/verify-otp` - Verify OTP
- `POST /api/auth/register` - Register new user
- `POST /api/auth/check-username` - Check username availability

## Files Modified

- `server/controllers/authController.js` - Added checkEmail and checkPhone functions
- `server/routes/authRoutes.js` - Added routes for new endpoints

## Files Created

- `test_check_email_phone.js` - Test suite for new endpoints
- `CHECK_EMAIL_PHONE_ENDPOINTS.md` - This documentation

## Status

✅ **Implemented**: Both endpoints working
✅ **Tested**: Test suite ready
✅ **Documented**: Complete documentation
✅ **Ready**: Ready for Flutter integration
