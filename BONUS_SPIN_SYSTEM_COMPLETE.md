# Bonus Spin System - Complete Implementation

## Problem
Users were not receiving bonus spins after watching video ads. The backend was returning `spinsRemaining: 0` even after completing a video ad.

## Root Cause
The `getSpinStatus` endpoint was only checking if the user had spun today, without accounting for bonus spins earned from ads. There was no database field to track bonus spins.

## Solution Implemented

### 1. Added bonusSpins Field to User Model
**File**: `server/models/User.js`

```javascript
bonusSpins: {
  type: Number,
  default: 0,
}
```

Tracks the number of bonus spins earned from watching video ads.

### 2. Updated getSpinStatus Endpoint
**File**: `server/controllers/spinWheelController.js`

Now calculates total spins as:
- 1 daily spin (if user hasn't spun today)
- Plus any bonus spins from ads

```javascript
const totalSpins = (canSpin ? 1 : 0) + (user.bonusSpins || 0);
```

Returns:
- `spinsRemaining`: Total spins available
- `bonusSpins`: Number of bonus spins from ads

### 3. Updated spinWheel Endpoint
**File**: `server/controllers/spinWheelController.js`

Now properly handles both daily and bonus spins:
- Checks if user has any spins available (daily or bonus)
- Uses daily spin first, then bonus spins
- Decrements `bonusSpins` when a bonus spin is used
- Only sets `lastSpinDate` when using daily spin

### 4. Updated Video Ad Completion
**File**: `server/controllers/videoAdController.js`

For spin-wheel video ads:
- Adds 1 bonus spin to user: `user.bonusSpins += 1`
- Returns `bonusSpinAwarded: true` and `bonusSpinsTotal`
- Does NOT award coins (only spins)

For watch-ads video ads:
- Awards coins as normal (unchanged)

## Flow After Fix

1. User watches video ad on Spin Wheel
2. Video completes
3. Backend adds 1 bonus spin: `user.bonusSpins += 1`
4. Success dialog shows "You earned 1 free spin!"
5. User clicks "Spin Now!"
6. Mobile app calls `getSpinStatus`
7. Backend returns `spinsRemaining: 1` (bonus spin)
8. User can now spin the wheel
9. Backend decrements `bonusSpins` after spin
10. User wins coins

## Database Changes

Added field to User model:
```javascript
bonusSpins: {
  type: Number,
  default: 0,
}
```

Existing users will have `bonusSpins: 0` by default.

## API Responses

### GET /api/spin-wheel/status
```json
{
  "success": true,
  "data": {
    "canSpin": true,
    "lastSpinDate": "2024-01-21T00:00:00Z",
    "spinsRemaining": 2,
    "bonusSpins": 1
  }
}
```

### POST /api/video-ads/:id/complete (spin-wheel)
```json
{
  "success": true,
  "message": "Video ad completed - bonus spin awarded",
  "coinsEarned": 0,
  "newBalance": 500,
  "bonusSpinAwarded": true,
  "bonusSpinsTotal": 1
}
```

## Files Modified
- `server/models/User.js` - Added bonusSpins field
- `server/controllers/spinWheelController.js` - Updated getSpinStatus and spinWheel
- `server/controllers/videoAdController.js` - Updated trackVideoAdCompletion
- `apps/lib/spin_wheel_screen.dart` - Refreshes spin status from backend

## Testing Checklist
- [ ] Watch video ad on Spin Wheel
- [ ] Video completes and shows success dialog
- [ ] Click "Spin Now!"
- [ ] Spin status shows 1 bonus spin
- [ ] Can spin the wheel with bonus spin
- [ ] After spinning, bonus spin is decremented
- [ ] Multiple bonus spins can be earned
- [ ] Daily spin still works (1 free spin per day)
- [ ] Watch ads still awards coins (not spins)

## Notes
- Bonus spins are tracked server-side in the database
- Daily spin limit (1 per day) is still enforced
- Users can earn unlimited bonus spins from ads
- Bonus spins are used after daily spin is exhausted
- System is now fully server-side validated
