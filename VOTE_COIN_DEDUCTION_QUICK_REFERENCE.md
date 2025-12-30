# Vote Coin Deduction - Quick Reference

## What Changed

### User Voting Flow
```
Before: Click vote → Vote recorded
After:  Click vote → Check coins → Deduct 1 coin → Award creator 1 coin → Vote recorded
```

## Key Points

### Voter Perspective
- **Cost**: 1 coin per vote
- **Limit**: 1 vote per entry per 24 hours
- **Feedback**: Success/error message shown
- **Balance**: Coins deducted immediately

### Creator Perspective
- **Reward**: 1 coin per vote received
- **Notification**: Vote notification sent
- **Earnings**: Coins added to balance
- **Tracking**: Vote count updated

## Error Messages

| Scenario | Message |
|----------|---------|
| Success | ✅ Vote recorded! -1 coin deducted |
| No coins | Insufficient coins to vote. You need at least 1 coin to vote. |
| Already voted | You can vote again in X hours |
| Entry not found | Unable to vote: Entry ID not found |
| Network error | Error voting: [error details] |

## API Response

### Success (200)
```json
{
  "success": true,
  "message": "Vote recorded successfully",
  "votesCount": 45,
  "coinsDeducted": 1,
  "coinsAwarded": 1
}
```

### Error (400)
```json
{
  "success": false,
  "message": "Insufficient coins to vote...",
  "requiredCoins": 1,
  "currentCoins": 0
}
```

## Transaction Types

| Type | Amount | Who | Description |
|------|--------|-----|-------------|
| vote_cast | -1 | Voter | User spending coin to vote |
| vote_received | +1 | Creator | Creator receiving coin from vote |

## Testing

### Test 1: Successful Vote
```
1. User: 100 coins
2. Vote
3. User: 99 coins ✅
4. Creator: +1 coin ✅
```

### Test 2: Insufficient Coins
```
1. User: 0 coins
2. Vote
3. Error shown ✅
4. No coins deducted ✅
```

### Test 3: Already Voted
```
1. Voted 2 hours ago
2. Vote again
3. Error: "You can vote again in 22 hours" ✅
```

## Files Changed

| File | Change |
|------|--------|
| `server/controllers/sytController.js` | Added coin deduction logic |
| `apps/lib/syt_reel_screen.dart` | Added user feedback messages |

## Coin Flow Diagram

```
User (100 coins)
    ↓
    Click Vote
    ↓
    Check Balance (≥1 coin?)
    ↓ YES
    Deduct 1 coin
    ↓
User (99 coins) ← Creator (51 coins)
                    ↑
                Award 1 coin
                    ↑
                Vote Recorded
```

## Important Notes

1. **Coins are deducted immediately** - No refunds if vote fails
2. **24-hour limit still applies** - Can only vote once per entry per day
3. **Zero-sum transaction** - 1 coin moved, not created
4. **Transaction tracked** - All votes recorded in database
5. **Error handling** - Graceful errors if coin deduction fails

## Monitoring

### Check Vote Transactions
```javascript
// Find all vote transactions today
db.transactions.find({
  type: { $in: ['vote_cast', 'vote_received'] },
  createdAt: { $gte: new Date(Date.now() - 24*60*60*1000) }
})
```

### Check User Coin Balance
```javascript
// Find users with low coins
db.users.find({ coinBalance: { $lt: 5 } })
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Vote fails silently | Check user coin balance |
| Coins not deducted | Check transaction logs |
| Error message not showing | Check network connection |
| Creator not receiving coin | Check vote was recorded |

## Rollback (if needed)

To disable coin deduction:
1. Comment out `deductCoins()` call in `sytController.js`
2. Remove coin check
3. Redeploy

## Future Enhancements

- [ ] Variable coin costs
- [ ] Voting rewards
- [ ] Vote multipliers
- [ ] Vote analytics
- [ ] Bulk voting discounts

## Support

For issues or questions:
1. Check transaction logs
2. Verify user coin balance
3. Check API response
4. Review error messages
