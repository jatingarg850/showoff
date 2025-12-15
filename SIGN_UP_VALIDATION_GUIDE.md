# Sign-Up Validation Guide - Check Email and Phone

## Overview

Users now get immediate feedback when trying to sign up with an email or phone number that's already registered.

## New Endpoints

### Check Email
```
POST /api/auth/check-email
{
  "email": "user@example.com"
}
```

### Check Phone
```
POST /api/auth/check-phone
{
  "phone": "9811226924",
  "countryCode": "91"
}
```

## Sign-Up Flow

### Step 1: User Enters Email/Phone
```
User enters email or phone number
```

### Step 2: App Validates Format
```
- Email: Must contain @ and domain
- Phone: Must be 7-15 digits
```

### Step 3: App Checks Availability
```
POST /api/auth/check-email or check-phone
```

### Step 4: Show Result to User

**If Available**:
```
✅ "Email/Phone is available"
→ Allow user to proceed
→ Send OTP
```

**If Already Exists**:
```
❌ "Email/Phone already registered"
→ Show login button
→ Don't send OTP
```

**If Invalid Format**:
```
❌ "Please provide a valid email/phone"
→ Show error message
→ Ask user to correct
```

## API Responses

### Email Available
```json
{
  "success": true,
  "available": true,
  "message": "Email is available",
  "exists": false
}
```

### Email Already Exists
```json
{
  "success": false,
  "available": false,
  "message": "Email already registered",
  "exists": true
}
```

### Phone Available
```json
{
  "success": true,
  "available": true,
  "message": "Phone number is available",
  "exists": false
}
```

### Phone Already Exists
```json
{
  "success": false,
  "available": false,
  "message": "Phone number already registered",
  "exists": true
}
```

## Flutter Implementation

### Check Email Before OTP
```dart
Future<void> checkEmailAndSendOTP(String email) async {
  try {
    // Step 1: Check if email is available
    final checkResponse = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/check-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final checkData = jsonDecode(checkResponse.body);

    if (!checkData['available']) {
      // Email already exists
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(checkData['message']),
          backgroundColor: Colors.red,
        ),
      );
      // Show login button
      return;
    }

    // Step 2: Email is available, send OTP
    final otpResponse = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final otpData = jsonDecode(otpResponse.body);

    if (otpData['success']) {
      // OTP sent successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent to $email')),
      );
      // Navigate to OTP verification screen
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### Check Phone Before OTP
```dart
Future<void> checkPhoneAndSendOTP(String phone, String countryCode) async {
  try {
    // Step 1: Check if phone is available
    final checkResponse = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/check-phone'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'countryCode': countryCode,
      }),
    );

    final checkData = jsonDecode(checkResponse.body);

    if (!checkData['available']) {
      // Phone already exists
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(checkData['message']),
          backgroundColor: Colors.red,
        ),
      );
      // Show login button
      return;
    }

    // Step 2: Phone is available, send OTP
    final otpResponse = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'countryCode': countryCode,
      }),
    );

    final otpData = jsonDecode(otpResponse.body);

    if (otpData['success']) {
      // OTP sent successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent to +$countryCode$phone')),
      );
      // Navigate to OTP verification screen
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

## Testing

### Test Email Endpoint
```bash
# Email is available
curl -X POST http://localhost:3000/api/auth/check-email \
  -H "Content-Type: application/json" \
  -d '{"email": "newuser@example.com"}'

# Email already exists (if user exists)
curl -X POST http://localhost:3000/api/auth/check-email \
  -H "Content-Type: application/json" \
  -d '{"email": "existing@example.com"}'

# Invalid email format
curl -X POST http://localhost:3000/api/auth/check-email \
  -H "Content-Type: application/json" \
  -d '{"email": "invalid-email"}'
```

### Test Phone Endpoint
```bash
# Phone is available
curl -X POST http://localhost:3000/api/auth/check-phone \
  -H "Content-Type: application/json" \
  -d '{"phone": "9999999999", "countryCode": "91"}'

# Phone already exists (if user exists)
curl -X POST http://localhost:3000/api/auth/check-phone \
  -H "Content-Type: application/json" \
  -d '{"phone": "9811226924", "countryCode": "91"}'

# Invalid phone format
curl -X POST http://localhost:3000/api/auth/check-phone \
  -H "Content-Type: application/json" \
  -d '{"phone": "123", "countryCode": "91"}'
```

### Run Test Suite
```bash
node test_check_email_phone.js
```

## Benefits

✅ **Immediate Feedback**: Users know right away if email/phone is available
✅ **Better UX**: No wasted OTP sends for existing accounts
✅ **Clear Messaging**: Users understand why they can't sign up
✅ **Suggest Login**: Can redirect existing users to login
✅ **Validation**: Catch invalid formats early
✅ **Reduce API Calls**: Check before sending OTP

## Error Messages

### Email Errors
| Error | Message |
|-------|---------|
| Missing | "Please provide an email" |
| Invalid Format | "Please provide a valid email address" |
| Already Exists | "Email already registered" |

### Phone Errors
| Error | Message |
|-------|---------|
| Missing | "Please provide phone number and country code" |
| Invalid Format | "Please provide a valid phone number" |
| Already Exists | "Phone number already registered" |

## Complete Sign-Up Flow

```
┌─────────────────────────────────────────┐
│  User Opens Sign-Up Screen              │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  User Enters Email or Phone             │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  App Validates Format                   │
│  - Email: Must have @                   │
│  - Phone: 7-15 digits                   │
└────────────────┬────────────────────────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
    Invalid           Valid
        │                 │
        ▼                 ▼
   Show Error      Check Availability
        │          (check-email/phone)
        │                 │
        │        ┌────────┴────────┐
        │        │                 │
        │        ▼                 ▼
        │    Available         Exists
        │        │                 │
        │        ▼                 ▼
        │    Send OTP         Show Error
        │        │             "Already
        │        │              Registered"
        │        │                 │
        │        │            Show Login
        │        │            Button
        │        │
        └────────┴─────────────────┘
                 │
                 ▼
        ┌─────────────────────────────────────────┐
        │  User Receives OTP                      │
        │  (SMS or Email)                         │
        └────────────────┬────────────────────────┘
                         │
                         ▼
        ┌─────────────────────────────────────────┐
        │  User Enters OTP                        │
        └────────────────┬────────────────────────┘
                         │
                         ▼
        ┌─────────────────────────────────────────┐
        │  Verify OTP                             │
        └────────────────┬────────────────────────┘
                         │
                ┌────────┴────────┐
                │                 │
                ▼                 ▼
            Valid              Invalid
                │                 │
                ▼                 ▼
            Register          Show Error
            Account           "Invalid OTP"
                │                 │
                ▼                 ▼
            Success           Retry
            Message
```

## Files Modified

- `server/controllers/authController.js` - Added checkEmail and checkPhone
- `server/routes/authRoutes.js` - Added new routes

## Files Created

- `test_check_email_phone.js` - Test suite
- `CHECK_EMAIL_PHONE_ENDPOINTS.md` - Detailed documentation
- `SIGN_UP_VALIDATION_GUIDE.md` - This guide

## Status

✅ **Implemented**: Both endpoints working
✅ **Tested**: Test suite ready
✅ **Documented**: Complete documentation
✅ **Ready**: Ready for Flutter integration
