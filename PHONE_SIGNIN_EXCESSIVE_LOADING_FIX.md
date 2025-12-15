# Phone Sign-In Excessive Loading Fix

## Problem
After signing in with phone OTP, the profile screen was loading excessively (showing loading spinner repeatedly). The user was not properly authenticated, causing the app to keep trying to load user data.

## Root Cause
The signin OTP flow had two critical issues:

1. **No User Authentication**: After OTP verification, the app navigated to MainScreen without actually logging in the user. The `verifyOTP` endpoint only verified the OTP - it didn't create a session or return a token.

2. **Missing User Data**: Without a token and user data saved, the app couldn't identify the user, so it kept trying to load profile data, causing excessive loading.

## Solution

### 1. Created New Backend Endpoint: `/api/auth/signin-phone-otp`
**File**: `server/controllers/authController.js`

New endpoint that:
- Verifies the phone number is valid
- Finds existing user by phone number OR creates new user
- Generates JWT token
- Returns user data and token

```javascript
exports.signInPhoneOTP = async (req, res) => {
  // 1. Find or create user with phone number
  // 2. Update last login
  // 3. Generate JWT token
  // 4. Return user data + token
}
```

### 2. Updated Flutter OTP Screen
**File**: `apps/lib/auth/otp_screen.dart`

Changed the signin flow to:
1. **Step 1**: Verify OTP with backend (`/api/auth/verify-otp`)
2. **Step 2**: Sign in with phone OTP (`/api/auth/signin-phone-otp`)
3. **Step 3**: Save token and user data to local storage
4. **Step 4**: Navigate to MainScreen

```dart
// Before (broken)
verifyOTP() → MainScreen (not authenticated)

// After (fixed)
verifyOTP() → signInPhoneOTP() → Save token → MainScreen (authenticated)
```

### 3. Updated Routes
**File**: `server/routes/authRoutes.js`

Added new route:
```javascript
router.post('/signin-phone-otp', signInPhoneOTP);
```

## Flow Comparison

### Before (Broken)
```
SignInPhoneScreen
  ↓ Send OTP
OTPScreen
  ↓ Verify OTP
verifyOTP endpoint (only verifies, no token)
  ↓ Navigate to MainScreen
MainScreen (user not authenticated)
  ↓ Try to load profile
ProfileScreen keeps loading (no user data)
```

### After (Fixed)
```
SignInPhoneScreen
  ↓ Send OTP
OTPScreen
  ↓ Verify OTP + Sign in
verifyOTP endpoint (verify OTP)
  ↓
signInPhoneOTP endpoint (create/find user, return token)
  ↓ Save token + user data
MainScreen (user authenticated)
  ↓ Load profile with user data
ProfileScreen loads normally
```

## Files Modified

1. **Backend**:
   - `server/controllers/authController.js` - Added `signInPhoneOTP` endpoint
   - `server/routes/authRoutes.js` - Added route for new endpoint

2. **Frontend**:
   - `apps/lib/auth/otp_screen.dart` - Updated `_verifySignInOTP()` to:
     - Call both `verifyOTP` and `signInPhoneOTP`
     - Save token and user data
     - Properly authenticate user

## Testing

1. Go to Sign In → Phone
2. Enter phone number and click "Send Code"
3. Enter OTP
4. Click "Continue"
5. Should see success message
6. Should navigate to MainScreen
7. Profile screen should load normally (no excessive loading)
8. User should be properly authenticated

## Expected Behavior

- Profile screen loads once and displays user data
- No loading spinner loops
- User can navigate between screens normally
- User data persists across app restarts

## Technical Details

### New Endpoint Response
```json
{
  "success": true,
  "message": "Phone OTP sign-in successful",
  "data": {
    "user": {
      "id": "user_id",
      "username": "username",
      "displayName": "Display Name",
      "phone": "9876543210",
      "email": "email@example.com",
      "profilePicture": "url",
      "bio": "bio",
      "coinBalance": 100,
      "isVerified": false,
      "isPhoneVerified": true,
      "accountStatus": "active"
    },
    "token": "jwt_token_here"
  }
}
```

### User Creation Logic
- If user exists with phone number: Use existing user
- If user doesn't exist: Create new user with:
  - Username: `user_XXXX` (last 4 digits of phone)
  - Display Name: `User XXXX` (last 4 digits of phone)
  - Phone verified: true
  - Welcome bonus: 50 coins

## Notes
- Phone signin now creates user account automatically (no separate registration needed)
- User can update profile details after signin
- Token is saved to local storage for future API calls
- User data is cached locally for offline access
