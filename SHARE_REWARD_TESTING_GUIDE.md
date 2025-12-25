# Share Reward System - Testing Guide

## Quick Test Steps

### Test 1: Basic Share Reward
1. Open app and navigate to Reel Screen
2. Find any reel
3. Click the Share button (share icon)
4. Select any share method (WhatsApp, SMS, Email, etc.)
5. Complete the share action
6. **Expected**: See notification "+5 coins earned for sharing! 🎉"
7. **Verify**: Check wallet balance increased by 5 coins

### Test 2: Multiple Shares
1. Share 3 different reels
2. **Expected**: Each share shows "+5 coins earned for sharing! 🎉"
3. **Verify**: Wallet balance increased by 15 coins total

### Test 3: Share Count Increment
1. Note the share count on a reel (e.g., "42 shares")
2. Click share button
3. Complete share action
4. **Expected**: Share count increases to 43
5. **Verify**: Notification shows coin reward

### Test 4: Transaction History
1. Share a reel
2. Navigate to Wallet/Earnings screen
3. Check Transaction History
4. **Expected**: See transaction with:
   - Type: "share_reward"
   - Amount: 5 coins
   - Description: "Share reward for post"

### Test 5: Error Handling
1. Turn off internet connection
2. Try to share a reel
3. **Expected**: Share still completes (native share works offline)
4. Turn on internet
5. **Expected**: Coin reward is awarded when connection restored

### Test 6: Notification Appearance
1. Share a reel
2. **Expected**: Purple notification appears at bottom
3. **Expected**: Shows coin icon + message
4. **Expected**: Notification disappears after 3 seconds

## Expected Behavior

### Success Case
```
User Action: Click Share → Select WhatsApp → Send
    ↓
Native share dialog opens and closes
    ↓
Backend records share
    ↓
Backend adds 5 coins
    ↓
App receives response
    ↓
Purple notification appears: "💰 +5 coins earned for sharing! 🎉"
    ↓
Wallet balance updates
    ↓
Transaction appears in history
```

### Error Case (Network Fails)
```
User Action: Click Share → Select WhatsApp → Send
    ↓
Native share dialog opens and closes
    ↓
Backend fails to record share
    ↓
App shows error: "Failed to share"
    ↓
No coins awarded
    ↓
User can retry
```

## Console Output to Look For

### Server Logs
```
✅ Share reward: 5 coins added to user 507f1f77bcf86cd799439011
```

### Client Logs
```
🎬 Sharing post: 507f1f77bcf86cd799439012
```

## Verification Checklist

- [ ] Notification appears with correct message
- [ ] Notification has purple background (0xFF701CF5)
- [ ] Notification has coin icon
- [ ] Notification disappears after 3 seconds
- [ ] Wallet balance increases by 5 coins
- [ ] Transaction history shows share_reward entry
- [ ] Share count increments on post
- [ ] Multiple shares accumulate coins correctly
- [ ] Works with different share methods
- [ ] Graceful error handling if network fails

## Database Verification

### Check User Coins
```javascript
// In MongoDB
db.users.findOne({_id: ObjectId("...")})
// Look for:
// - coinBalance: should increase by 5
// - totalCoinsEarned: should increase by 5
```

### Check Transaction Record
```javascript
// In MongoDB
db.transactions.findOne({type: "share_reward"})
// Should show:
// {
//   user: ObjectId("..."),
//   type: "share_reward",
//   amount: 5,
//   balanceAfter: [new balance],
//   description: "Share reward for post"
// }
```

### Check Share Record
```javascript
// In MongoDB
db.shares.findOne({})
// Should show:
// {
//   user: ObjectId("..."),
//   post: ObjectId("..."),
//   shareType: "link"
// }
```

## Common Issues & Solutions

### Issue: Notification doesn't appear
**Solution**: 
- Check if `coinsAwarded` is in API response
- Verify mounted state before showing snackbar
- Check if another snackbar is blocking it

### Issue: Coins not added to wallet
**Solution**:
- Check server logs for coin reward errors
- Verify User model is accessible
- Check Transaction model is working
- Verify user is authenticated

### Issue: Share count doesn't increment
**Solution**:
- Check if Share record is being created
- Verify post.sharesCount is being saved
- Check if stats reload is working

### Issue: Multiple notifications appear
**Solution**:
- Check if share is being called multiple times
- Verify Share.share() is only called once
- Check for duplicate event listeners

## Performance Testing

### Test Share Speed
1. Share a reel
2. Measure time from click to notification
3. **Expected**: < 2 seconds for notification to appear

### Test Concurrent Shares
1. Rapidly click share on multiple reels
2. **Expected**: All shares complete successfully
3. **Expected**: All coins awarded correctly

### Test with Large Wallet
1. User with 100,000+ coins
2. Share a reel
3. **Expected**: Coins still add correctly
4. **Expected**: No overflow or calculation errors

## Regression Testing

After implementing share rewards, verify:
- [ ] Regular post upload still works
- [ ] Like functionality still works
- [ ] Comment functionality still works
- [ ] View tracking still works
- [ ] Bookmark functionality still works
- [ ] Follow functionality still works
- [ ] Wallet display still works
- [ ] Transaction history still works

## User Acceptance Testing

### Scenario 1: New User
1. Create new account
2. Share a reel
3. **Expected**: See "+5 coins earned for sharing! 🎉"
4. **Expected**: Wallet shows 5 coins

### Scenario 2: Active User
1. User with existing coins
2. Share a reel
3. **Expected**: Coins increase correctly
4. **Expected**: Notification shows correct amount

### Scenario 3: Multiple Shares
1. User shares 10 reels
2. **Expected**: 50 coins earned total
3. **Expected**: All transactions recorded
4. **Expected**: Wallet balance correct

## Deployment Checklist

Before deploying to production:
- [ ] Test all scenarios above
- [ ] Verify database migrations (if any)
- [ ] Check server logs for errors
- [ ] Verify API response format
- [ ] Test with different user roles
- [ ] Test with different devices
- [ ] Test with different network conditions
- [ ] Verify transaction history accuracy
- [ ] Check coin balance calculations
- [ ] Verify no duplicate rewards
