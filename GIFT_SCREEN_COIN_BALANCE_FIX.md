# Gift Screen Coin Balance Fix

## Problem
The Gift Screen was displaying a hard-coded coin balance of 500 coins instead of showing the user's actual coin balance. If a user had 50 coins, the screen would still show 500 coins, which was confusing and misleading.

## Root Cause
The coin balance in the Gift Screen header was hard-coded as a string literal `'500'` instead of fetching the user's actual coin balance from the AuthProvider.

```dart
// Before (Hard-coded)
Text(
  '500',  // Always shows 500, regardless of actual balance
  style: TextStyle(...)
)
```

## Solution

### 1. Added AuthProvider Import
**File**: `apps/lib/gift_screen.dart`

Added imports to access user data:
```dart
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
```

### 2. Replaced Hard-Coded Value with Dynamic Balance
Changed the coin balance display to use `Consumer<AuthProvider>`:

```dart
// Before (Hard-coded)
Text(
  '500',
  style: TextStyle(...)
)

// After (Dynamic)
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    final coinBalance = authProvider.user?['coinBalance'] ?? 0;
    return Text(
      coinBalance.toString(),
      style: TextStyle(...)
    );
  },
)
```

## How It Works

1. **AuthProvider** stores the user's data including `coinBalance`
2. **Consumer<AuthProvider>** listens to changes in the auth provider
3. **coinBalance** is extracted from the user data
4. **Fallback to 0** if coinBalance is not available
5. **Display updates** whenever the user's coin balance changes

## Files Modified
- `apps/lib/gift_screen.dart` - Updated coin balance display to use actual user balance

## Testing

### Test Case 1: User with 50 Coins
1. Sign in with account that has 50 coins
2. Open a reel and tap gift button
3. Gift Screen should show: **50 coins** (not 500)

### Test Case 2: User with 100 Coins
1. Sign in with account that has 100 coins
2. Open a reel and tap gift button
3. Gift Screen should show: **100 coins**

### Test Case 3: User with 500+ Coins
1. Sign in with account that has 500+ coins
2. Open a reel and tap gift button
3. Gift Screen should show: **actual balance** (e.g., 750, 1000, etc.)

### Test Case 4: New User (0 Coins)
1. Sign in with new account (0 coins)
2. Open a reel and tap gift button
3. Gift Screen should show: **0 coins**

## Expected Behavior

### Before (Broken)
```
User's Actual Balance: 50 coins
Gift Screen Display: 500 coins ❌ (Incorrect)
```

### After (Fixed)
```
User's Actual Balance: 50 coins
Gift Screen Display: 50 coins ✅ (Correct)
```

## Impact
- Users now see their actual coin balance in the Gift Screen
- No more confusion about available coins
- Accurate representation of user's purchasing power
- Better user experience and trust

## Technical Details

### Data Flow
```
AuthProvider (stores user data)
    ↓
user['coinBalance']
    ↓
Consumer<AuthProvider> (listens for changes)
    ↓
Gift Screen displays actual balance
```

### Fallback Handling
If `coinBalance` is not available:
```dart
final coinBalance = authProvider.user?['coinBalance'] ?? 0;
```
Defaults to 0 coins to prevent errors.

## Notes
- The coin balance updates automatically when the user's coins change
- The display is real-time and reflects the current balance
- No need to refresh or reload the screen
- Works across all gift screen instances
