# Sign-In OTP Fix - Complete

## Problem
Sign-in OTP was not working properly. When users tried to sign in with phone OTP, the app would:
1. Navigate to OTP screen without sending OTP to backend
2. Accept any OTP code without verification
3. Directly navigate to MainScreen without authenticating the user

## Root Cause
The `OTPScreen` widget had two issues:
1. **No OTP sending**: When navigating from `SignInPhoneScreen` to `OTPScreen`, the OTP was never sent to the backend
2. **No OTP verification**: When user entered OTP, it was never verified with the backend - the app just navigated to MainScreen

This was different from the signup flow which properly:
1. Sends OTP via `ApiService.sendOTP()`
2. Verifies OTP via `ApiService.verifyOTP()`
3. Only proceeds after successful verification

## Solution

### 1. Updated `SignInPhoneScreen` (apps/lib/auth/signin_phone_screen.dart)
- Added `ApiService` import
- Modified "Send Code" button to:
  - Show loading dialog
  - Call `ApiService.sendOTP()` to send OTP to backend
  - Only navigate to `OTPScreen` if OTP sent successfully
  - Show error if OTP sending fails

### 2. Updated `OTPScreen` (apps/lib/auth/otp_screen.dart)
- Added `ApiService` import
- Added `_verifySignInOTP()` method that:
  - Extracts phone number and country code from the phoneNumber string
  - Shows loading dialog
  - Calls `ApiService.verifyOTP()` to verify OTP with backend
  - Only navigates to MainScreen if OTP verified successfully
  - Shows error and clears OTP fields if verification fails
- Updated "Continue" button to:
  - Call `_verifySignInOTP()` for signin flow
  - Properly handle async verification
- Enhanced `_resendOTP()` method to:
  - Actually send OTP to backend (not just reset timer)
  - Extract phone and country code properly
  - Show success/error messages

## Flow Comparison

### Before (Broken)
```
SignInPhoneScreen
  ↓ (no OTP sent)
OTPScreen
  ↓ (any OTP accepted)
MainScreen (not authenticated)
```

### After (Fixed)
```
SignInPhoneScreen
  ↓ (sends OTP via API)
OTPScreen
  ↓ (verifies OTP via API)
MainScreen (authenticated)
```

## Testing
To test the fix:
1. Go to Sign In → Phone
2. Enter phone number and click "Send Code"
3. Should see loading, then OTP screen appears
4. Enter the OTP code (check server logs or development mode for code)
5. Click "Continue"
6. Should verify with backend and navigate to MainScreen

## Files Modified
- `apps/lib/auth/signin_phone_screen.dart` - Added OTP sending before navigation
- `apps/lib/auth/otp_screen.dart` - Added OTP verification for signin flow

## Notes
- Email signin still uses password-based login (not OTP)
- Phone signin now uses OTP verification (same as signup)
- Both signup and signin OTP flows now use the same backend endpoints
- Resend OTP now properly sends to backend instead of just resetting timer
