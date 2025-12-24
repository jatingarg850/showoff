# User Earnings Visibility Implementation

## Overview
This implementation adds detailed user earnings visibility to the admin panel at `http://localhost:3000/admin/users`. When clicking on a user, admins can now view a comprehensive earnings breakdown showing all sources of income.

## Features Implemented

### 1. **Detailed Earnings Breakdown**
The admin panel now displays earnings from all sources:
- **Video Uploads**: Earnings from uploading videos and view-based rewards
- **Content Sharing**: Earnings from votes and content engagement
- **Spin Wheel**: Earnings from spinning the reward wheel
- **Rewarded Ads**: Earnings from watching rewarded advertisements
- **Referrals**: Earnings from successful referrals
- **Competitions**: Earnings from SYT competitions and contests
- **Gifts Received**: Earnings from receiving gifts from other users
- **Other**: Any miscellaneous earnings

### 2. **Key Statistics**
For each user, the following statistics are displayed:
- **Total Earnings**: Lifetime total coins earned
- **Current Balance**: Current coin balance in wallet
- **Withdrawable Balance**: Coins available for withdrawal
- **Average Daily Earnings**: Average coins earned per day since signup
- **Total Withdrawn**: Total coins withdrawn to date
- **Withdrawal Count**: Number of withdrawal requests made
- **Transaction Count**: Total number of transactions

### 3. **Visual Dashboard**
The earnings modal includes:
- User profile information with avatar
- Color-coded earnings cards for each source
- Key statistics displayed in gradient cards
- Recent transaction history (last 20 transactions)
- Withdrawal history with status tracking
- Earnings trend data (last 30 days)

### 4. **Transaction History**
Detailed transaction log showing:
- Transaction type (upload_reward, ad_watch, spin_wheel, etc.)
- Amount earned/spent
- Balance after transaction
- Exact date and time

### 5. **Withdrawal Tracking**
Complete withdrawal history including:
- Withdrawal amount in coins
- Payment method (bank transfer, UPI, PayPal, etc.)
- Current status (pending, processing, completed, rejected)
- Withdrawal date

## Technical Implementation

### Backend Changes

#### 1. Enhanced `getUserEarnings` Controller
**File**: `server/controllers/adminController.js`

The function now:
- Aggregates transactions by type to calculate earnings from each source
- Maps transaction types to earnings categories
- Calculates statistics like average daily earnings
- Retrieves withdrawal history
- Returns comprehensive earnings data

```javascript
// Earnings categories mapped from transaction types:
- upload_reward, view_reward → videoUploadEarnings
- ad_watch → rewardedAdEarnings
- spin_wheel → wheelSpinEarnings
- referral → referralEarnings
- competition_prize → competitionEarnings
- gift_received → giftEarnings
- vote_received → contentSharingEarnings
- other types → otherEarnings
```

#### 2. API Endpoint
**Route**: `GET /api/admin/users/:id/earnings`

**Response Structure**:
```json
{
  "success": true,
  "data": {
    "user": {
      "_id": "user_id",
      "username": "username",
      "displayName": "Display Name",
      "profilePicture": "url",
      "coinBalance": 5000,
      "totalCoinsEarned": 10000,
      "withdrawableBalance": 4500
    },
    "earnings": {
      "videoUploadEarnings": 3000,
      "contentSharingEarnings": 1500,
      "wheelSpinEarnings": 2000,
      "rewardedAdEarnings": 1500,
      "referralEarnings": 1000,
      "competitionEarnings": 500,
      "giftEarnings": 500,
      "otherEarnings": 0,
      "totalEarnings": 10000
    },
    "stats": {
      "totalEarnings": 10000,
      "currentBalance": 5000,
      "withdrawableBalance": 4500,
      "totalWithdrawn": 5000,
      "averageDailyEarnings": 45.5,
      "transactionCount": 150,
      "withdrawalCount": 2
    },
    "recentTransactions": [...],
    "withdrawalHistory": [...],
    "earningsByDate": [...]
  }
}
```

### Frontend Changes

#### 1. Updated Admin Users View
**File**: `server/views/admin/users.ejs`

Added:
- New "View Earnings" button (purple icon) in user actions
- Earnings modal with comprehensive UI
- JavaScript function `viewEarnings()` to fetch and display earnings data
- Function `closeEarningsModal()` to close the modal

#### 2. Earnings Modal UI
The modal displays:
- User profile header with avatar
- 4 key metric cards (Total Earnings, Current Balance, Withdrawable, Avg Daily)
- 8 earnings source cards with color-coded borders
- Withdrawal statistics
- Recent transactions table
- Withdrawal history table

## How to Use

### For Admins

1. **Navigate to User Management**
   - Go to `http://localhost:3000/admin/users`
   - Login with credentials: `admin@showofflife.com` / `admin123`

2. **View User Earnings**
   - Find the user in the list
   - Click the purple chart icon (📊) in the Actions column
   - The earnings modal will open with detailed breakdown

3. **Analyze Earnings**
   - View total earnings and current balance
   - See breakdown by source
   - Check recent transactions
   - Review withdrawal history

### For Developers

#### Testing the Endpoint
```bash
# Using curl
curl -X GET http://localhost:3000/api/admin/users/{userId}/earnings \
  -H "Authorization: Bearer {admin_token}"

# Using the test file
node test_user_earnings.js
```

#### Customizing Earnings Categories
To add new earnings sources:

1. Add transaction type to `Transaction.js` schema
2. Update the mapping in `getUserEarnings()` function
3. Add new earnings field to the response
4. Update the modal UI to display the new category

## Database Queries

### Transaction Aggregation
The implementation uses MongoDB aggregation to:
- Group transactions by type
- Sum amounts for each type
- Calculate daily earnings trends
- Filter by date ranges

### Performance Optimization
- Indexes on `user` and `createdAt` fields for fast queries
- Limits on transaction history (last 20 for display)
- Efficient aggregation pipelines

## Security Considerations

1. **Admin-Only Access**: Endpoint requires admin authentication
2. **User Privacy**: Only admins can view detailed earnings
3. **Data Validation**: All inputs are validated
4. **Error Handling**: Comprehensive error messages without exposing sensitive data

## Future Enhancements

1. **Export Earnings Report**: Generate PDF/CSV reports
2. **Earnings Forecasting**: Predict future earnings based on trends
3. **Fraud Detection**: Flag suspicious earning patterns
4. **Earnings Comparison**: Compare user earnings with platform averages
5. **Custom Date Ranges**: Allow filtering by specific date ranges
6. **Earnings Goals**: Set and track earning targets
7. **Performance Metrics**: Show earnings per view, per upload, etc.

## Troubleshooting

### Earnings Not Showing
- Verify user has transactions in the database
- Check that transaction types are correctly mapped
- Ensure admin is properly authenticated

### Modal Not Opening
- Check browser console for JavaScript errors
- Verify API endpoint is accessible
- Check admin session is valid

### Incorrect Earnings Totals
- Verify transaction records in database
- Check transaction type mappings
- Review aggregation pipeline logic

## Files Modified

1. `server/controllers/adminController.js` - Enhanced getUserEarnings function
2. `server/views/admin/users.ejs` - Added earnings button and modal

## Files Created

1. `test_user_earnings.js` - Test script for earnings endpoint
2. `USER_EARNINGS_IMPLEMENTATION.md` - This documentation

## API Endpoints

### Get User Earnings
- **Route**: `GET /api/admin/users/:id/earnings`
- **Auth**: Admin only (session or JWT)
- **Response**: Detailed earnings breakdown with statistics

### Get Top Earners
- **Route**: `GET /api/admin/top-earners`
- **Auth**: Admin only
- **Response**: List of top earning users with earnings breakdown

## Notes

- All earnings are calculated from transaction records
- The system supports multiple earning sources
- Earnings are tracked in real-time as transactions occur
- Historical data is preserved for audit trails
- Withdrawal tracking is integrated with earnings display
