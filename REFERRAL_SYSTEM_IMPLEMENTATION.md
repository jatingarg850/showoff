# Referral System Implementation Guide

## Overview
The referral system allows users to share their referral code and earn rewards when others sign up using their code. Both the referrer and referee get bonus coins.

## What's Implemented

### Backend (Already Complete)
- ✅ User model with referral fields (referralCode, referredBy, referralCount, referralCoinsEarned)
- ✅ Referral code generation on user registration
- ✅ Apply referral code endpoint: `POST /api/profile/apply-referral`
- ✅ Coin rewards: 20 coins to referee, 20 coins to referrer
- ✅ Transaction tracking with referral_bonus type
- ✅ Referral code validation and duplicate prevention

### Frontend (Partially Complete)
- ✅ Referrals screen showing referral code and statistics
- ✅ Referral transaction history screen
- ✅ Bio screen with referral code input
- ✅ Share functionality for referral codes
- ✅ API service method for applying referral codes
- ⚠️ Deep linking for referral codes (partially implemented)
- ⚠️ Referral code pre-filling in signup flow (needs completion)

## Deep Linking for Referral Codes

### Supported Formats
```
https://showoff.life/ref/{referralCode}
https://showoff.life/referral/{referralCode}
showofflife://referral/{referralCode}
```

### Example
```
https://showoff.life/ref/JOHN1A2B3C
```

### How It Works
1. User shares referral code via share button
2. Recipient clicks the link
3. App opens and detects deep link
4. SplashScreen parses the referral code
5. Navigates to OnboardingScreen with referral code
6. User signs up and referral code is pre-filled in BioScreen
7. On signup completion, referral code is applied automatically
8. Both users receive 20 coins each

## Signup Flow with Referral Code

```
Deep Link (https://showoff.life/ref/{code})
    ↓
SplashScreen._handleDeepLink()
    ↓
OnboardingScreen(referralCode: code)
    ↓
SignUpScreen(referralCode: code)
    ↓
EmailSignUpScreen/PhoneSignUpScreen(referralCode: code)
    ↓
DisplayNameScreen(referralCode: code)
    ↓
InterestsScreen(referralCode: code)
    ↓
BioScreen(referralCode: code)
    ↓
Pre-filled referral code in input field
    ↓
User completes signup
    ↓
ApiService.applyReferralCode() called
    ↓
Both users receive 20 coins
```

## Files Modified

### Frontend
1. **apps/lib/splash_screen.dart**
   - Added referral code deep link parsing
   - Added referral code navigation handler

2. **apps/lib/onboarding_screen.dart**
   - Added referralCode parameter
   - Pass referral code to SignUpScreen

3. **apps/lib/signup_screen.dart**
   - Added referralCode parameter
   - Pass referral code to EmailSignUpScreen and PhoneSignUpScreen

4. **apps/lib/account_setup/bio_screen.dart**
   - Added referralCode parameter
   - Pre-fill referral code in input field
   - Auto-apply referral code on signup

### Backend
- No changes needed (already implemented)

## Referral Code Sharing

### From Referrals Screen
```dart
void _shareReferralCode(String referralCode) {
  final message = '''
🎁 Join ShowOff.life and earn coins!

Use my referral code: $referralCode

✨ What you'll get:
• Bonus coins on signup
• Share your talent with the world
• Compete in SYT competitions
• Win real prizes!

📱 Download now:
https://play.google.com/store/apps/details?id=com.showofflife.app

#ShowOffLife #ReferralCode #EarnCoins
''';

  Share.share(message, subject: 'Join ShowOff.life - Use code $referralCode');
}
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

- [ ] Share referral code from Referrals screen
- [ ] Click referral link → opens OnboardingScreen
- [ ] Referral code pre-filled in BioScreen
- [ ] Complete signup with referral code
- [ ] Both users receive 20 coins
- [ ] Referral count increments for referrer
- [ ] Transaction history shows referral bonus
- [ ] Cannot use own referral code
- [ ] Cannot use referral code twice
- [ ] Invalid referral code shows error

## API Endpoints

### Apply Referral Code
```
POST /api/profile/apply-referral
Headers: Authorization: Bearer {token}
Body: {
  "referralCode": "JOHN1A2B3C"
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

## Future Enhancements

1. **Tiered Rewards**: Increase rewards after certain number of referrals
2. **Referral Analytics**: Track referral source and conversion metrics
3. **Referral Leaderboard**: Show top referrers
4. **Referral Bonuses**: Special bonuses for milestone referrals (10, 50, 100)
5. **Referral Expiry**: Referral codes expire after certain period
6. **Referral Limits**: Limit number of referrals per user per day/month

## Troubleshooting

### Referral code not pre-filled
- Check if referral code is passed through signup flow
- Verify BioScreen receives referralCode parameter
- Check if initState is called in BioScreen

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

## Support

For issues or questions about the referral system, check:
1. Server logs for API errors
2. Flutter console for deep link parsing errors
3. Transaction history for coin award tracking
4. User profile for referral count and coins
