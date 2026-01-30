# SYT Reel Screen Share Reward - 5 Coins Implementation

## Overview
Implemented coin rewards for sharing SYT (Show Your Talent) entries. Users now earn 5 coins each time they share an entry, with a daily limit of 50 shares.

## Changes Made

### 1. Frontend - API Service (apps/lib/services/api_service.dart)
Added new method `shareSYTEntry()` to call the SYT-specific share endpoint:

```dart
static Future<Map<String, dynamic>> shareSYTEntry(
  String entryId, {
  String shareType = 'link',
}) async {
  final response = await _httpClient.post(
    Uri.parse('$baseUrl/syt/$entryId/share'),
    headers: await _getHeaders(),
    body: jsonEncode({'shareType': shareType}),
  );
  return jsonDecode(response.body);
}
```

**Why:** The previous implementation was calling `/posts/$postId/share` which is for regular posts, not SYT entries. The new method calls the correct `/syt/$entryId/share` endpoint.

### 2. Frontend - SYT Reel Screen (apps/lib/syt_reel_screen.dart)
Updated `_shareEntry()` method to:
- Call `ApiService.shareSYTEntry()` instead of `ApiService.sharePost()`
- Display coin reward notification showing "+5 coins earned"
- Handle error cases (daily limit reached, etc.)
- Show user-friendly messages

```dart
// Track share on backend and grant coins
final response = await ApiService.shareSYTEntry(entryId);
if (response['success'] && mounted) {
  // Show coin reward notification
  final coinsEarned = response['coinsEarned'] ?? 5;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('✅ Shared! +$coinsEarned coins earned'),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );
  await _reloadEntryStats(index);
}
```

### 3. Backend - Already Implemented
The backend endpoint `/api/syt/:id/share` was already fully implemented with:
- ✅ 5 coin reward per share
- ✅ Daily limit of 50 shares per user
- ✅ Transaction tracking
- ✅ Share count increment
- ✅ Proper response with `coinsEarned` field

## How It Works

1. **User taps share button** on SYT reel screen
2. **Share dialog opens** with pre-formatted text and deep link
3. **User shares** via WhatsApp, Instagram, etc.
4. **App calls backend** `/api/syt/:entryId/share` endpoint
5. **Backend processes**:
   - Checks daily share limit (50 per day)
   - Adds 5 coins to user's wallet
   - Creates transaction record
   - Increments share count
6. **Frontend shows** green notification: "✅ Shared! +5 coins earned"
7. **Stats reload** to reflect updated share count

## Coin Reward Details
- **Reward per share**: 5 coins
- **Daily limit**: 50 shares per user
- **Resets**: Daily at midnight
- **Transaction type**: `share_reward`
- **Tracked in**: User's transaction history

## Error Handling
- **Daily limit reached**: Shows error message with current count
- **Network error**: Shows generic error message
- **Server error**: Shows appropriate error from backend

## Files Modified
1. `apps/lib/services/api_service.dart` - Added `shareSYTEntry()` method
2. `apps/lib/syt_reel_screen.dart` - Updated `_shareEntry()` method

## Testing
To verify the implementation:
1. Open SYT reel screen
2. Tap share button on any entry
3. Share via any platform
4. Verify green notification shows "+5 coins earned"
5. Check user's coin balance increased by 5
6. Verify transaction appears in history
7. Test daily limit (share 50 times, 51st should fail)

## Related Features
- **Vote reward**: 1 coin per vote (24-hour cooldown)
- **Upload reward**: 10 coins per approved entry
- **Daily limit**: Prevents abuse
- **Transaction tracking**: All coin activities logged
