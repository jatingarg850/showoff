# Referral Reward System - Analysis & Solution

## Current Issues Identified

### Issue 1: No Referral Code Input During Signup
**Problem**: Users cannot enter a referral code during the signup/onboarding process
- Signup screens (email, phone) don't have a referral code input field
- Onboarding screen doesn't mention referral codes
- Users can only apply referral codes AFTER account creation via `/profile/apply-referral` endpoint

**Impact**: 
- New users miss out on 20 coins during signup
- Referral program is not discoverable during onboarding
- Friction in the referral flow

### Issue 2: Referral Code Not Passed During Registration
**Problem**: Even if a user has a referral code, it's not being passed to the registration API
- `set_password_screen.dart` calls `authProvider.register()` without `referralCode` parameter
- The parameter exists in the auth provider but is never populated
- Registration happens without referral code

**Impact**:
- Referral rewards are never awarded during signup
- Users must manually apply referral code after signup (extra step)

### Issue 3: Inconsistent Reward Logic
**Problem**: Two different reward systems exist:
1. **During Registration** (`authController.js`):
   - Only REFERRER gets coins (5 or 50 depending on count)
   - NEW USER gets NO coins
   - Uses `REFERRAL_COINS_FIRST_100` and `REFERRAL_COINS_AFTER` from env

2. **After Registration** (`profileController.js`):
   - Both users get 20 coins each
   - Uses hardcoded value of 20
   - Different transaction type: `referral_bonus` vs `referral`

**Impact**:
- Inconsistent user experience
- Different rewards depending on when referral is applied
- Confusion about reward amounts

### Issue 4: Environment Variables Mismatch
**Problem**: Env variables don't match the intended behavior
```
REFERRAL_COINS_FIRST_100=5      # Only 5 coins for first 100 referrals
REFERRAL_COINS_AFTER=5          # Only 5