# Terms & Conditions Checkbox Integration - Signup Flow

## Overview
Successfully integrated a compulsory Terms & Conditions checkbox into the password/account setup screen during the signup flow. Users must now accept the T&C before they can create an account.

## Changes Made

### 1. Flutter Frontend - SetPasswordScreen (`apps/lib/set_password_screen.dart`)

#### Added State Variable
```dart
bool _termsAccepted = false;
```

#### Updated _canProceed Getter
Added `_termsAccepted` to the condition - button is now disabled until checkbox is ticked:
```dart
bool get _canProceed =>
    _isPasswordValid &&
    _doPasswordsMatch &&
    _confirmPasswordController.text.isNotEmpty &&
    _termsAccepted;
```

#### Added T&C Checkbox UI
Inserted before the Spacer widget:
- Checkbox with purple accent color (0xFF701CF5)
- Clickable text label "I agree to the Terms & Conditions"
- Tapping either checkbox or text toggles the state
- Checkbox is required to enable the Continue button

#### Updated Register Call
Passes `termsAccepted: _termsAccepted` to the register method:
```dart
final success = await authProvider.register(
  username: tempUsername,
  displayName: 'User',
  password: _passwordController.text,
  email: widget.email,
  phone: widget.phone != null ? '${widget.countryCode}${widget.phone}' : null,
  termsAccepted: _termsAccepted,
);
```

### 2. Flutter AuthProvider (`apps/lib/providers/auth_provider.dart`)

#### Updated register() Method
Added `termsAccepted` parameter:
```dart
Future<bool> register({
  required String username,
  required String displayName,
  required String password,
  String? email,
  String? phone,
  String? referralCode,
  bool termsAccepted = false,
}) async {
  // ... passes termsAccepted to ApiService.register()
}
```

### 3. Flutter ApiService (`apps/lib/services/api_service.dart`)

#### Updated register() Method
Added `termsAccepted` parameter and includes it in the request body:
```dart
static Future<Map<String, dynamic>> register({
  required String username,
  required String displayName,
  required String password,
  String? email,
  String? phone,
  String? referralCode,
  bool termsAccepted = false,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/register'),
    headers: await _getHeaders(),
    body: jsonEncode({
      'username': username,
      'displayName': displayName,
      'password': password,
      'termsAccepted': termsAccepted,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (referralCode != null) 'referralCode': referralCode,
    }),
  );
  // ...
}
```

### 4. Backend - AuthController (`server/controllers/authController.js`)

#### Updated register() Endpoint
- Extracts `termsAccepted` from request body
- Validates that user accepted T&C before account creation
- Returns 400 error if T&C not accepted
- Sets T&C fields on user creation:
  - `termsAndConditionsAccepted: true`
  - `termsAndConditionsVersion: 1`
  - `termsAndConditionsAcceptedAt: new Date()`

```javascript
exports.register = async (req, res) => {
  try {
    const { email, phone, password, username, displayName, referralCode, termsAccepted } = req.body;

    // Check if user accepted terms and conditions
    if (!termsAccepted) {
      return res.status(400).json({
        success: false,
        message: 'You must accept the Terms & Conditions to create an account',
      });
    }
    // ... rest of registration logic
    
    const user = await User.create({
      email,
      phone: normalizedPhone,
      password,
      username: username.toLowerCase(),
      displayName,
      referralCode: generateReferralCode(username),
      termsAndConditionsAccepted: true,
      termsAndConditionsVersion: 1,
      termsAndConditionsAcceptedAt: new Date(),
    });
  }
};
```

## User Experience Flow

1. **Phone/Email Signup** → User enters phone or email
2. **OTP Verification** → User verifies OTP
3. **Password Setup** → User sets password and **MUST** check T&C checkbox
4. **Account Creation** → Backend validates T&C acceptance and creates account
5. **Profile Setup** → User proceeds to profile picture setup

## Key Features

✅ **Compulsory Checkbox** - Continue button disabled until checkbox is ticked
✅ **Backend Validation** - Server rejects registration if T&C not accepted
✅ **Database Tracking** - T&C acceptance recorded with timestamp and version
✅ **User-Friendly** - Checkbox text is clickable for better UX
✅ **Consistent Styling** - Uses app's purple gradient theme (0xFF701CF5)
✅ **Error Handling** - Clear error message if user tries to skip T&C

## Database Fields Used

From User model (`server/models/User.js`):
- `termsAndConditionsAccepted` (Boolean) - Whether user accepted T&C
- `termsAndConditionsVersion` (Number) - Version of T&C accepted (currently 1)
- `termsAndConditionsAcceptedAt` (Date) - Timestamp of acceptance

## Testing Checklist

- [ ] Checkbox appears on password setup screen
- [ ] Continue button is disabled when checkbox is unchecked
- [ ] Continue button is enabled when checkbox is checked
- [ ] Tapping checkbox toggles state
- [ ] Tapping text label toggles checkbox state
- [ ] Registration fails with error if T&C not accepted
- [ ] Registration succeeds when T&C is accepted
- [ ] Database records T&C acceptance with timestamp
- [ ] Works for both phone and email signup flows
- [ ] Works for Google OAuth signup (if integrated)

## Integration Points

This implementation integrates with:
1. **Existing T&C System** - Uses T&C content from admin panel
2. **Phone Signup Flow** - `phone_signup_screen.dart` → OTP → Password → Account
3. **Email Signup Flow** - `email_signup_screen.dart` → OTP → Password → Account
4. **Auth Provider** - Manages registration state and user data
5. **API Service** - Handles HTTP communication with backend
6. **User Model** - Stores T&C acceptance data

## Future Enhancements

- Add link to view full T&C from checkbox screen
- Support multiple T&C versions with migration logic
- Add T&C acceptance to Google OAuth flow
- Add T&C re-acceptance for updated versions
- Admin dashboard to track T&C acceptance rates
