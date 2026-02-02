# SYT Share Coins Award Fix - Transaction Type Error

## Problem
When sharing an SYT entry, the share was recorded but the coin reward failed with error:
```
Share recorded but failed to award coins. Please try again.
```

## Root Cause
The `shareSYTEntry` controller was trying to create a Transaction record with type `'share_reward'`, but this transaction type was not defined in the Transaction model's enum list. MongoDB validation rejected the transaction creation because `'share_reward'` was not an allowed value.

## Solution

### Updated Transaction Model
**File**: `server/models/Transaction.js`

Added missing transaction types to the enum list:

**Changes**:
1. Added `'share_reward'` - for SYT entry share rewards
2. Added `'withdrawal_refund'` - for withdrawal rejections (was already being used but not in enum)

**Before**:
```javascript
enum: [
  'upload_reward',
  'view_reward',
  'ad_watch',
  'video_ad_reward',
  'referral',
  'referral_bonus',
  'spin_wheel',
  'vote_cast',
  'vote_received',
  'gift_received',
  'gift_sent',
  'competition_prize',
  'withdrawal',
  'purchase',
  'subscription',
  'profile_completion',
  'add_money',
  'welcome_bonus',
  'admin_credit',
  'admin_debit'
  // ❌ Missing 'share_reward' and 'withdrawal_refund'
]
```

**After**:
```javascript
enum: [
  'upload_reward',
  'view_reward',
  'ad_watch',
  'video_ad_reward',
  'referral',
  'referral_bonus',
  'spin_wheel',
  'vote_cast',
  'vote_received',
  'gift_received',
  'gift_sent',
  'competition_prize',
  'withdrawal',
  'purchase',
  'subscription',
  'profile_completion',
  'add_money',
  'welcome_bonus',
  'admin_credit',
  'admin_debit',
  'share_reward',        // ✅ Added for SYT share rewards
  'withdrawal_refund'    // ✅ Added for withdrawal rejections
]
```

## How It Works Now

1. **User Shares SYT Entry**: Clicks share button on SYT reel
2. **Share Record Created**: Share document saved with `sytEntry` reference
3. **Entry Share Count Updated**: Incremented by 1
4. **Transaction Created**: Transaction record with type `'share_reward'` is now valid
5. **Coins Awarded**: 5 coins added to user's wallet
6. **Success Response**: User receives confirmation with coin amount

## Testing

### Manual Test Steps
1. Open SYT Reel Screen
2. Find a competition entry
3. Click the share button (arrow icon)
4. Select share method (native share dialog)
5. Verify:
   - ✅ No error message
   - ✅ Success notification: "✅ Shared! +5 coins earned"
   - ✅ Coins added to wallet
   - ✅ Share count increments

### Expected Behavior
- ✅ SYT entries can be shared successfully
- ✅ User receives exactly 5 coins per share
- ✅ Daily share limit enforced (50 shares/day)
- ✅ Transaction record created with correct type
- ✅ Share count displayed on reel

## Files Modified
1. `server/models/Transaction.js` - Added `'share_reward'` and `'withdrawal_refund'` to enum

## Related Code
- `server/controllers/sytController.js` - `shareSYTEntry` endpoint (line 969)
- `server/models/Share.js` - Share model (supports both posts and SYT entries)
- `apps/lib/syt_reel_screen.dart` - Frontend share implementation

## Notes
- The fix is minimal and focused on the root cause
- No app code changes needed
- Backward compatible with existing transactions
- Both transaction types are now properly tracked in the database
