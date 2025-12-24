# Admin Panel - User Earnings Quick Guide

## Accessing User Earnings

### Step 1: Login to Admin Panel
- URL: `http://localhost:3000/admin`
- Email: `admin@showofflife.com`
- Password: `admin123`

### Step 2: Navigate to Users
- Click "User Management" in the sidebar
- Or go directly to: `http://localhost:3000/admin/users`

### Step 3: View User Earnings
- Find the user in the list
- Click the **purple chart icon** (📊) in the Actions column
- The earnings modal will open

## Understanding the Earnings Dashboard

### Key Metrics (Top Cards)

| Metric | Description |
|--------|-------------|
| **Total Earnings** | Lifetime total coins earned by the user |
| **Current Balance** | Coins currently in user's wallet |
| **Withdrawable** | Coins available for withdrawal |
| **Avg Daily** | Average coins earned per day since signup |

### Earnings by Source

| Source | Description |
|--------|-------------|
| **Video Uploads** | Coins from uploading videos and view-based rewards |
| **Content Sharing** | Coins from votes and content engagement |
| **Spin Wheel** | Coins from spinning the reward wheel |
| **Rewarded Ads** | Coins from watching rewarded advertisements |
| **Referrals** | Coins from successful referrals |
| **Competitions** | Coins from SYT competitions and contests |
| **Gifts Received** | Coins from receiving gifts from other users |
| **Other** | Miscellaneous earnings |

### Withdrawal Statistics

- **Total Withdrawn**: Total coins withdrawn to date
- **Withdrawal Count**: Number of withdrawal requests made

## Reading the Transaction History

Each transaction shows:
- **Type**: What action earned/spent the coins
- **Amount**: Number of coins (+ for earnings, - for spending)
- **Balance After**: User's balance after the transaction
- **Date**: When the transaction occurred

### Transaction Types

| Type | Meaning |
|------|---------|
| UPLOAD_REWARD | Coins earned from uploading content |
| VIEW_REWARD | Coins earned from video views |
| AD_WATCH | Coins earned from watching ads |
| SPIN_WHEEL | Coins earned from wheel spins |
| REFERRAL | Coins earned from referrals |
| COMPETITION_PRIZE | Coins earned from competitions |
| GIFT_RECEIVED | Coins received as gifts |
| VOTE_RECEIVED | Coins from receiving votes |
| WITHDRAWAL | Coins withdrawn |
| PURCHASE | Coins spent on purchases |

## Withdrawal History

Each withdrawal shows:
- **Amount**: Coins withdrawn
- **Method**: How it was withdrawn (Bank Transfer, UPI, PayPal, etc.)
- **Status**: Current status
  - 🟡 **PENDING**: Awaiting processing
  - 🔵 **PROCESSING**: Being processed
  - 🟢 **COMPLETED**: Successfully withdrawn
  - 🔴 **REJECTED**: Withdrawal rejected

## Common Tasks

### Check if User is Earning
1. Open user earnings
2. Look at "Total Earnings" - should be > 0
3. Check "Recent Transactions" for activity
4. Look at "Avg Daily" to see earning rate

### Verify Withdrawal Request
1. Open user earnings
2. Scroll to "Withdrawal History"
3. Check status of withdrawal
4. Note the amount and method

### Identify Top Earning Sources
1. Open user earnings
2. Look at the earnings cards
3. The largest numbers show primary income sources
4. Use this to understand user behavior

### Track User Activity
1. Open user earnings
2. Check "Recent Transactions"
3. Look at dates and types
4. Identify patterns in earning behavior

## Tips & Tricks

### 💡 Quick Analysis
- **High Balance, Low Earnings**: User may have withdrawn recently
- **High Earnings, Low Balance**: User may be spending coins
- **No Recent Transactions**: User may be inactive
- **Many Withdrawals**: User is actively monetizing

### 🔍 Fraud Detection
- Unusual earning patterns (too high too fast)
- Repeated small transactions (potential gaming)
- Withdrawals immediately after earnings (potential fraud)
- Multiple accounts with similar patterns

### 📊 Performance Metrics
- **Earnings per Day**: Total Earnings ÷ Days Since Signup
- **Withdrawal Rate**: Total Withdrawn ÷ Total Earnings
- **Active Days**: Count of days with transactions
- **Average Transaction**: Total Earnings ÷ Transaction Count

## Troubleshooting

### Earnings Modal Won't Open
- Check browser console (F12) for errors
- Verify you're logged in as admin
- Try refreshing the page
- Check internet connection

### Numbers Look Wrong
- Verify user has transactions in the system
- Check if transactions are recent
- Look at transaction history to verify
- Contact support if discrepancy persists

### Can't Find User
- Use the search box at the top
- Filter by status if needed
- Check pagination at the bottom
- Verify username spelling

## Related Actions

From the user earnings view, you can also:
- **View User Details**: Click the eye icon to see full profile
- **Manage Coins**: Add or subtract coins manually
- **Verify User**: Mark user as verified
- **Suspend User**: Temporarily disable account
- **Delete User**: Permanently remove user (use with caution)

## Support

For issues or questions:
1. Check the transaction history for clues
2. Review the earnings breakdown
3. Compare with other similar users
4. Contact the development team if needed

---

**Last Updated**: December 2024
**Version**: 1.0
