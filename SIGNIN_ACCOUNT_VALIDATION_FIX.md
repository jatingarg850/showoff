# Sign-In Account Validation Fix

## Problem
Previously, users could sign in with phone/email even if they didn't have an account. The system would automatically create an account for them, which is not the desired behavior. Users should only be able to sign in if they already have an account.

## Solution

### 1. Phone Sign-In (OTP)
**File**: `server/controllers/authController.js`

Updated `signInPhoneOTP` endpoint to:
- Check if user exists with the phone number
- If user NOT found: Return error with code `ACCOUNT_NOT_FOUND`
- If user found: Sign in and return token

```javascript
// Before: Created new user if not found
// After: Return error if user not found
if (!user) {
  return res.status(404).json({
    success: false,
    message: 'Account not found. Please sign up first.',
    code: 'ACCOUNT_NOT_FOUND',
  });
}
```

### 2. Phone Sign-In Frontend
**File**: `apps/lib/auth/otp_screen.dart`

Updated OTP screen to:
- Check for `ACCOUNT_NOT_FOUND` error code
- Show dialog asking user to sign up
- Provide options to go back or navigate to signup

```dart
if (signInData['code'] == 'ACCOUNT_NOT_FOUND') {
  // Show dialog with options to go back or sign up
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Account Not Found'),
      content: const Text(
        'No account found with this phone number. Please sign up first.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Go Back'),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/signup'),
          child: const Text('Sign Up'),
        ),
      ],
    ),
  );
}
```

### 3. Email Sign-In (Password)
**File**: `server/controllers/authController.js` (login endpoint)

Already secure - returns "Invalid credentials" if:
- User not found
- Password incorrect

This doesn't reveal whether the email exists (security best practice).

## Flow Comparison

### Phone Sign-In

#### Before (Broken)
```
Enter phone → Verify OTP → Auto-create account → Sign in
```

#### After (Fixed)
```
Enter phone → Verify OTP → Check if account exists
  ├─ Account exists → Sign in
  └─ Account NOT found → Show dialog → Redirect to signup
```

### Email Sign-In

#### Before & After (Already Secure)
```
Enter email + password → Check if user exists
  ├─ User exists + password correct → Sign in
  └─ User not found OR password wrong → "Invalid credentials" error
```

## User Experience

### Phone Sign-In with Non-Existent Account
1. User enters phone number
2. User enters OTP
3. App shows dialog: "Account Not Found. Please sign up first."
4. User can:
   - Click "Go Back" to try another phone number
   - Click "Sign Up" to create new account

### Email Sign-In with Non-Existent Account
1. User enters email and password
2. App shows error: "Invalid credentials"
3. User can:
   - Try another email/password
   - Click "Forgot password?" to reset
   - Go back and sign up

## Files Modified

1. **Backend**:
   - `server/controllers/authController.js` - Updated `signInPhoneOTP` to check if user exists

2. **Frontend**:
   - `apps/lib/auth/otp_screen.dart` - Added account not found dialog and signup redirect

## Testing

### Phone Sign-In (Account Not Found)
1. Go to Sign In → Phone
2. Enter phone number that doesn't have an account
3. Enter OTP
4. Should see dialog: "Account Not Found"
5. Click "Sign Up" should navigate to signup screen

### Phone Sign-In (Account Exists)
1. Go to Sign In → Phone
2. Enter phone number that has an account
3. Enter OTP
4. Should sign in successfully

### Email Sign-In (Account Not Found)
1. Go to Sign In → Email
2. Enter email that doesn't have an account
3. Enter any password
4. Should see error: "Invalid credentials"

### Email Sign-In (Account Exists)
1. Go to Sign In → Email
2. Enter email that has an account
3. Enter correct password
4. Should sign in successfully

## Security Notes

- Phone signin now requires pre-existing account (no auto-registration)
- Email signin already required pre-existing account
- Email signin doesn't reveal if email exists (returns same error for missing user or wrong password)
- Phone signin explicitly tells user to sign up (acceptable UX for phone-based auth)

## API Response Codes

### Phone Sign-In Success
```json
{
  "success": true,
  "message": "Phone OTP sign-in successful",
  "data": { "user": {...}, "token": "..." }
}
```

### Phone Sign-In - Account Not Found
```json
{
  "success": false,
  "message": "Account not found. Please sign up first.",
  "code": "ACCOUNT_NOT_FOUND"
}
```

### Email Sign-In - Invalid Credentials
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```
