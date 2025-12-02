# Referral Code in Bio Setup - Implementation

## Overview
Implemented referral code functionality in the bio/account setup screen. Users can enter a referral code during signup to earn 20 coins for both the referrer and the new user.

## Features Implemented

### 1. Referral Code Input Field
- Added optional referral code field in bio setup screen
- Text automatically converts to uppercase
- Shows helpful hint: "Have a referral code? Enter it to earn 20 coins!"
- Validates code on submission

### 2. Coin Rewards
- **New User (Referee):** Earns 20 coins when using valid referral code
- **Referrer:** Earns 20 coins when someone uses their code
- **Profile Completion:** Still earns 50 coins for completing profile
- **Total Possible:** 70 coins (50 + 20) if using referral code

### 3. Backend API
- New endpoint: `POST /api/profile/apply-referral`
- Validates referral code
- Awards coins to both users
- Prevents duplicate usage
- Prevents self-referral

## Implementation Details

### Backend Changes

#### 1. Profile Controller (`server/controllers/profileController.js`)
Added new method `applyReferralCode`:
- Validates referral code exists
- Checks if user already used a code
- Prevents self-referral
- Awards 20 coins to both users
- Updates referral count for referrer

#### 2. Profile Routes (`server/routes/profileRoutes.js`)
Added new route:
```javascript
router.post('/apply-referral', protect, applyReferralCode);
```

### Frontend Changes

#### 1. API Service (`apps/lib/services/api_service.dart`)
Added new method:
```dart
static Future<Map<String, dynamic>> applyReferralCode(String referralCode)
```

#### 2. Bio Screen (`apps/lib/account_setup/bio_screen.dart`)
- Added referral code text field
- Added validation logic
- Updated congratulations popup to show total coins
- Displays different message if referral bonus earned

## User Flow

### 1. Account Setup
1. User completes username, display name, interests
2. User reaches bio screen (final step)
3. User enters bio
4. User optionally enters referral code
5. User taps Continue

### 2. Validation & Rewards
1. Profile is updated (50 coins awarded)
2. If referral code provided:
   - Code is validated
   - If valid: 20 coins awarded to both users
   - If invalid: Silently ignored (no error shown)
3. Congratulations popup shows total coins earned

### 3. Congratulations Popup
- Shows "+50" if no referral code
- Shows "+70" if referral code used
- Message explains breakdown:
  - "+70 coins! (+50 for profile completion + 20 referral bonus)"

## API Endpoint

### Apply Referral Code
```
POST /api/profile/apply-referral
Headers: Authorization: Bearer {token}
Body: { "referralCode": "ABC123" }
```

**Success Response:**
```json
{
  "success": true,
  "message": "Referral code applied successfully! You both earned 20 coins.",
  "data": {
    "coinsEarned": 20,
    "newBalance": 70,
    "referrerUsername": "john_doe"
  }
}
```

**Error Responses:**
```json
// Invalid code
{
  "success": false,
  "message": "Invalid referral code"
}

// Already used
{
  "success": false,
  "message": "You have already used a referral code"
}

// Self-referral
{
  "success": false,
  "message": "You cannot use your own referral code"
}
```

## Validation Rules

### Backend Validation:
1. ✅ Referral code must exist
2. ✅ User hasn't used a code before
3. ✅ User can't use their own code
4. ✅ Code is case-insensitive (converted to uppercase)

### Frontend Behavior:
- Optional field (can be left empty)
- Auto-converts to uppercase
- No validation until submission
- Errors handled gracefully (no popup)

## Database Changes

### User Model Fields Used:
- `referralCode` - User's own referral code
- `referredBy` - ID of user who referred them
- `referralCount` - Number of successful referrals
- `coinBalance` - Updated with bonus coins

### Transaction Records:
Both users get transaction records:
- Type: `referral_bonus`
- Amount: 20 coins
- Description includes username

## Testing Instructions

### Test Successful Referral:
1. Create User A (gets referral code automatically)
2. Note User A's referral code (visible in Settings → Referrals)
3. Create User B
4. During User B's bio setup, enter User A's code
5. Complete setup
6. Verify:
   - User B sees "+70 coins" in popup
   - User A's balance increased by 20
   - User B's balance is 70 (50 + 20)

### Test Invalid Code:
1. Create new user
2. Enter invalid code like "INVALID123"
3. Complete setup
4. Verify:
   - User sees "+50 coins" (referral ignored)
   - No error message shown
   - Profile still completes successfully

### Test Self-Referral:
1. User tries to use their own code
2. Backend rejects it
3. User gets 50 coins only

### Test Duplicate Usage:
1. User already used a code
2. Tries to use another code
3. Backend rejects it
4. Original referral remains

## UI/UX Design

### Referral Code Field:
- Purple gradient border (matches app theme)
- White background
- Uppercase text input
- Placeholder: "Enter referral code"
- Label: "Referral Code (Optional)"
- Hint: "Have a referral code? Enter it to earn 20 coins!"

### Congratulations Popup:
- Dynamic coin amount display
- Conditional message based on bonus
- Maintains existing design
- Clear breakdown of earnings

## Error Handling

### Silent Failures:
- Invalid codes don't show errors
- User still completes profile
- Only valid codes award bonus
- Prevents user frustration

### Logged Errors:
- Backend logs all validation failures
- Console shows API responses
- Helps debugging

## Benefits

### For Users:
- ✅ Easy to use (optional field)
- ✅ Instant rewards (20 coins)
- ✅ No friction if code invalid
- ✅ Clear reward messaging

### For App Growth:
- ✅ Incentivizes referrals
- ✅ Tracks referral success
- ✅ Rewards both parties
- ✅ Viral growth mechanism

### For Referrers:
- ✅ Earn coins for inviting friends
- ✅ Unlimited referrals
- ✅ Automatic tracking
- ✅ Visible referral count

## Files Modified

### Backend:
1. `server/controllers/profileController.js` - Added applyReferralCode method
2. `server/routes/profileRoutes.js` - Added route

### Frontend:
1. `apps/lib/services/api_service.dart` - Added API method
2. `apps/lib/account_setup/bio_screen.dart` - Added UI and logic

## Future Enhancements

Potential improvements:
- Real-time code validation
- Show referrer's name when entering code
- Referral leaderboard
- Tiered referral rewards
- Referral milestones (10, 50, 100 referrals)
- Special badges for top referrers

## Success Metrics

Track these metrics:
- Referral code usage rate
- Average coins earned per user
- Referral conversion rate
- Top referrers
- Referral growth over time

## Related Features

- Referrals Screen (Settings → Referrals & Invites)
- Share Referral Code functionality
- Coin system and transactions
- Profile completion bonus

## Conclusion

The referral code system is now fully integrated into the account setup flow. Users can optionally enter a referral code during signup to earn bonus coins, creating a win-win situation for both new users and referrers.
