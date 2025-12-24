# Phone Sign-In Flow Fix

## Problem
When trying to sign in with phone, the app was showing "Phone number already registered" error, preventing existing users from signing in.

## Root Cause
The `sendOTP` endpoint was checking if the phone number already exists and rejecting it. This logic was correct for signup (to prevent duplicate registrations) but wrong for signin (where we WANT the phone to exist).

Additionally, phone numbers weren't being normalized consistently:
- Frontend sends: `9811226924` (just digits)
- Backend stores: `9811226924` (just digits)
- But queries were inconsistent, sometimes including country code

## Solution
Implemented consistent phone number normalization across all endpoints:

### 1. **Removed "already exists" check from `sendOTP`**
   - OTP should be sent regardless of whether user exists
   - This allows both signup and signin flows to work
   - Duplicate registration is prevented in the `register` endpoint instead

### 2. **Normalized phone numbers everywhere**
   - All phone numbers are stored as digits only (no + or spaces)
   - All phone lookups normalize the input before querying
   - Consistent format: `9811226924` (just digits)

### 3. **Updated endpoints**
   - `sendOTP`: Removed duplicate check, added normalization
   - `register`: Added normalization, kept duplicate check
   - `signInPhoneOTP`: Added normalization for phone lookup
   - `checkPhone`: Added normalization for availability check

## Files Modified
- `server/controllers/authController.js`
  - `sendOTP()` - Removed duplicate check, added normalization
  - `register()` - Added normalization
  - `signInPhoneOTP()` - Added normalization
  - `checkPhone()` - Added normalization

## Flow After Fix

### Sign Up Flow
1. User enters phone: `9811226924`
2. Frontend sends: `phone: "9811226924"`, `countryCode: "+91"`
3. Backend `sendOTP`: Normalizes to `9811226924`, sends OTP (no duplicate check)
4. User verifies OTP
5. Backend `register`: Normalizes phone, checks for duplicates, creates user
6. User is registered ✓

### Sign In Flow
1. User enters phone: `9811226924`
2. Frontend sends: `phone: "9811226924"`, `countryCode: "+91"`
3. Backend `sendOTP`: Normalizes to `9811226924`, sends OTP (no duplicate check)
4. User verifies OTP
5. Backend `signInPhoneOTP`: Normalizes phone to `9811226924`, finds user, returns token
6. User is signed in ✓

## Testing
1. Sign up with a new phone number
2. Sign in with the same phone number (should work now)
3. Try to sign up again with same phone (should show "already registered")
