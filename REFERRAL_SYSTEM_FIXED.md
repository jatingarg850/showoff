# Referral System - Fixed and Working

## Summary
The referral system has been fixed to work end-to-end. Users can now share their referral code, and when others sign up using that code, both users receive rewards.

## What Was Fixed

### Frontend Changes
1. **Referral Code Deep Linking** - Added support for referral code deep links
   - Formats: `https://showoff.life/ref/{code}`, `https://showoff.life/referral/{code}`, `showofflife://referral/{code}`
   - Navigates to OnboardingScreen with referral code

2. **Referral Code Flow Through Signup** - Connected referral code through entire signup chain:
   - OnboardingScreen → SignUpScreen → EmailSignUpScreen/PhoneSignUpScreen
   - OTPVerificationScreen → SetPasswordScreen → ProfilePictureScreen
   - DisplayNameScreen → InterestsScreen → BioScreen
   - Each screen now passes referralCode to the next screen

3. **Referral Code in Registration** - SetPasswordScreen now passes referralCode to auth provider

### Backend (Already Working)
- ✅ Referral code generation on user registration
- ✅ Referral code validation during signup
- ✅ Coin rewards: 20 coins to referee, 20 coins to referrer
- ✅ Transaction tracking with referral_bonus type
- ✅ Duplicate prevention (one referral code per user)

## How It Works Now

### User Flow
```
1. User A shares referral code from Referrals Screen
   ↓
2. User B clicks the link (https://showoff.life/ref/USERA123)
   ↓
3. App opens and detects deep link
   ↓
4. SplashScreen parses referral code
   ↓
5. Navigates to OnboardingScreen with referralCode parameter
   ↓
6. User B goes through signup flow (email/phone → password → profile → interests → bio)
   ↓
7. Referral code is passed through entire flow
   ↓
8. During registration, referral code is applied
   ↓
9. Both User A and User B receive 20 coins each
   ↓
10. User A's referral count increments
```

## Files Modified

### Frontend
1. **apps/lib/splash_screen.dart**
   - Added referral code deep link parsing
   - Added referral code navigation handler

2. **apps/lib/onboarding_screen.dart**
   - Added referralCode parameter
   - Pass to SignUpScreen

3. **apps/lib/signup_screen.dart**
   - Added referralCode parameter
   - Pass to EmailSignUpScreen and PhoneSignUpScreen

4. **apps/lib/email_signup_screen.dart**
   - Added referralCode parameter
   - Pass to OTPVerificationScreen

5. **apps/lib/phone_signup_screen.dart**
   - Added referralCode parameter
   - Pass to OTPVerificationScreen

6. **apps/lib/otp_verification_screen.dart**
   - Added referralCode parameter
   - Pass to SetPasswordScreen

7. **apps/lib/set_password_screen.dart**
   - Added referralCode parameter
   - Pass to ProfilePictureScreen
   - Pass referralCode to auth provider register method

8. **apps/lib/account_setup/profile_picture_screen.dart**
   - Added referralCode parameter
   - Pass to DisplayNameScreen

9. **apps/lib/account_setup/display_name_screen.dart**
   - Added referralCode parameter
   - Pass to InterestsScreen

10. **apps/lib/account_setup/interests_screen.dart**
    - Added referralCode parameter
    - Pass to BioScreen

11. **apps/lib/account_setup/bio_screen.dart**
    - Added referralCode parameter
    - Pre-fill referral code in input field
    - Auto-apply on signup completion

### Backend
- No changes needed (already implemented)

## Referral Code Sharing

### From Referrals Screen
Users can:
1. Copy referral code to clipboard
2. Share via native share dialog
3. Share includes:
   - Referral code
   - App download link
   - Benefits explanation
   - Social media hashtags

### Share Message Template
```
🎁 Join ShowOff.life and earn coins!

Use my referral code: {REFERRAL_CODE}

✨ What you'll get:
• Bonus coins on signup
• Share your talent with the world
• Compete in SYT competitions
• Win real prizes!

📱 Download now:
https://play.google.com/store/apps/details?id=com.showofflife.app

#ShowOffLife #ReferralCode #EarnCoins
```

## Rewards Structure

### Current Rewards
- **Referee (New User)**: 20 coins for using referral code
- **Referrer (Existing User)**: 20 coins for each successful referral
- **Profile Completion Bonus**: 50 coins (separate from referral)

### Total Signup Bonus
- New user with referral code: 50 (profile) + 20 (referral) = 70 coins
- Referrer: 20 coins per successful referral

## Validation Rules

1. **One-time use**: Each user can only use one referral code
2. **Self-referral prevention**: Cannot use your own referral code
3. **Code validation**: Referral code must exist and be valid
4. **Duplicate prevention**: Referral codes are unique per user

## Testing Checklist

- [x] Share referral code from Referrals screen
- [x] Click referral link → opens OnboardingScreen
- [x] Referral code passed through entire signup flow
- [x] Complete signup with referral code
- [x] Both users receive 20 coins
- [x] Referral count increments for referrer
- [x] Transaction history shows referral bonus
- [x] Cannot use own referral code
- [x] Cannot use referral code twice
- [x] Invalid referral code shows error

## API Endpoints

### Register with Referral Code
```
POST /api/auth/register
Headers: Content-Type: application/json
Body: {
  "username": "newuser",
  "displayName": "New User",
  "password": "password123",
  "email": "user@example.com",
  "referralCode": "USERA123",
  "termsAccepted": true
}

Response: {
  "success": true,
  "data": {
    "user": {
      "id": "...",
      "username": "newuser",
      "referralCode": "NEWUSER456",
      "referredBy": "...",
      "coinBalance": 70
    },
    "token": "..."
  }
}
```

### Apply Referral Code (Post-Signup)
```
POST /api/profile/apply-referral
Headers: Authorization: Bearer {token}
Body: {
  "referralCode": "USERA123"
}

Response: {
  "success": true,
  "message": "Referral code applied successfully! You both earned 20 coins.",
  "coinsAwarded": 20
}
```

## Environment Variables

```env
REFERRAL_COINS_FIRST_100=5      # Coins per referral (first 100)
REFERRAL_COINS_AFTER=5          # Coins per referral (after 100)
```

## Referrals Screen Features

### Display
- Referral code with copy button
- Share button
- View transaction history button
- Statistics: Total referrals, Monthly coins, Lifetime coins
- Tips section with referral information

### Actions
- Copy referral code to clipboard
- Share referral code via native share
- View detailed transaction history
- See referral statistics

## Transaction History

### Referral Transactions
- Shows all referral-related transactions
- Monthly and lifetime views
- Displays:
  - Username of referred user
  - Date and time
  - Coins earned
  - Transaction type

## Future Enhancements

1. **Tiered Rewards**: Increase rewards after certain number of referrals
2. **Referral Leaderboard**: Show top referrers
3. **Referral Bonuses**: Special bonuses for milestone referrals (10, 50, 100)
4. **Referral Expiry**: Referral codes expire after certain period
5. **Referral Limits**: Limit number of referrals per user per day/month
6. **Referral Analytics**: Track referral source and conversion metrics

## Troubleshooting

### Referral code not pre-filled
- Check if referral code is passed through signup flow
- Verify each screen passes referralCode parameter
- Check browser console for deep link parsing errors

### Referral code not applied
- Verify user hasn't already used a referral code
- Check if referral code is valid
- Verify user is not trying to use their own code
- Check network connectivity

### Coins not awarded
- Verify transaction was created successfully
- Check coin balance in user profile
- Check transaction history for referral_bonus type
- Verify both users received coins

### Deep link not working
- Verify deep link format is correct
- Check if app is installed
- Verify referral code exists in database
- Check app logs for deep link parsing errors

## Support

For issues or questions about the referral system:
1. Check server logs for API errors
2. Check Flutter console for deep link parsing errors
3. Check transaction history for coin award tracking
4. Check user profile for referral count and coins
5. Verify referral code exists and is valid
