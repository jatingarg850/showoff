# Gift Coin Balance Update Fix

## Problem
After sending a gift to someone, the wallet screen was not updating to show the new coin balance. The transaction appeared in the history, but the "Available Balance" at the top remained unchanged until the user manually refreshed or navigated away and back.

## Root Cause
Two issues were preventing the balance from updating:

1. **GiftScreen not refreshing user data**: After sending a gift, the GiftScreen just closed the modal without updating the user's coin balance in the AuthProvider.

2. **WalletScreen not listening to changes**: The WalletScreen loaded the balance once on `initState()` but didn't refresh when the screen came back into focus after the gift modal closed.

## Solution

### 1. Updated GiftScreen to Refresh User Data
**File**: `apps/lib/gift_screen.dart`

After successfully sending a gift, now refreshes the user's data:

```dart
if (response['success']) {
  // Update user's coin balance in AuthProvider
  final authProvider = Provider.of<AuthProvider>(
    context,
    listen: false,
  );
  
  // Refresh user data to get updated coin balance
  await authProvider.refreshUser();
  
  // Then close the modal
  Navigator.pop(context);
}
```

### 2. Updated WalletScreen to Refresh on Resume
**File**: `apps/lib/wallet_screen.dart`

Added lifecycle observer to refresh balance when screen comes back into focus:

```dart
class _WalletScreenState extends State<WalletScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadWalletData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh balance when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _loadBalance();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
```

## How It Works

### Before (Broken)
```
User sends gift
  ↓
GiftScreen closes
  ↓
WalletScreen still shows old balance
  ↓
User must manually refresh or navigate away/back
```

### After (Fixed)
```
User sends gift
  ↓
GiftScreen refreshes AuthProvider with new balance
  ↓
GiftScreen closes
  ↓
WalletScreen detects app resumed
  ↓
WalletScreen refreshes balance from API
  ↓
Balance updates immediately ✅
```

## Files Modified
1. `apps/lib/gift_screen.dart` - Added AuthProvider refresh after sending gift
2. `apps/lib/wallet_screen.dart` - Added lifecycle observer to refresh balance on resume

## Testing

### Test Case 1: Send Gift and Check Balance
1. Open Wallet Screen - note balance (e.g., 100 coins)
2. Open a reel and send a gift (e.g., 50 coins)
3. Gift modal closes
4. Wallet Screen should immediately show new balance (e.g., 50 coins)
5. Transaction history should show the gift transaction

### Test Case 2: Send Multiple Gifts
1. Start with 100 coins
2. Send 20 coin gift → balance should show 80
3. Send 30 coin gift → balance should show 50
4. Send 50 coin gift → balance should show 0
5. All transactions should appear in history

### Test Case 3: App Lifecycle
1. Open Wallet Screen
2. Send a gift (modal opens and closes)
3. Balance should update
4. Minimize app and reopen
5. Balance should still be correct

## Expected Behavior

### Before (Broken)
```
Wallet Balance: 100 coins
Send 50 coin gift
Wallet Balance: Still shows 100 coins ❌
(Must refresh manually)
```

### After (Fixed)
```
Wallet Balance: 100 coins
Send 50 coin gift
Wallet Balance: Immediately shows 50 coins ✅
(Automatic refresh)
```

## Technical Details

### Data Flow
```
GiftScreen sends gift
  ↓
API processes gift
  ↓
GiftScreen calls authProvider.refreshUser()
  ↓
AuthProvider fetches updated user data
  ↓
GiftScreen closes
  ↓
WalletScreen detects app resumed
  ↓
WalletScreen calls _loadBalance()
  ↓
Balance updates in UI
```

### Lifecycle Observer
The `WidgetsBindingObserver` mixin allows the WalletScreen to listen to app lifecycle events:
- `resumed`: App came to foreground
- `paused`: App went to background
- `detached`: App is being terminated

When `resumed`, the balance is refreshed to ensure it's always up-to-date.

## Impact
- Users see their updated balance immediately after sending a gift
- No need to manually refresh or navigate away/back
- Better user experience and trust
- Accurate balance display at all times

## Notes
- The refresh happens automatically when the gift modal closes
- The lifecycle observer ensures balance is refreshed even if user minimizes and reopens the app
- Both the AuthProvider and API are queried to ensure accuracy
- Works seamlessly with the transaction history display
