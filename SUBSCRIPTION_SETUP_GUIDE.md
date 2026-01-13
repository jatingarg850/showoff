# Subscription System Setup Guide

## Overview
The subscription system is now fully implemented and working. Follow these steps to get it running.

## Prerequisites
- Node.js and npm installed
- MongoDB running and connected
- Razorpay account with API keys configured in `.env`

## Setup Steps

### 1. Seed Subscription Plans (CRITICAL)
Run this command to create subscription plans in the database:

```bash
node server/scripts/seedSubscriptionPlans.js
```

**Expected Output:**
```
✅ Connected to MongoDB
🗑️  Cleared existing plans
✅ Created 4 subscription plans
  - Free (free): ₹0/month
  - Basic (basic): ₹499/month
  - Pro (pro): ₹2499/month
  - VIP (vip): ₹4999/month

✅ Subscription plans seeded successfully!
```

### 2. Verify Database
Check that plans were created:

```bash
# In MongoDB shell or MongoDB Compass
db.subscriptionplans.find()
```

You should see 4 plans with tiers: free, basic, pro, vip

### 3. Test the Subscription Flow

#### Frontend (Flutter App)
1. Navigate to the Subscription screen
2. The app will load available plans from the backend
3. Click "Subscribe Now" to initiate payment
4. Complete Razorpay payment
5. Subscription should activate automatically

#### Backend Verification
Check that subscription was created:

```bash
# In MongoDB shell
db.usersubscriptions.findOne({ status: 'active' })
```

### 4. Verify User Subscription Status
Check that user has subscription tier and verified badge:

```bash
# In MongoDB shell
db.users.findOne({ _id: ObjectId("user_id") })
# Should show: subscriptionTier: "pro", isVerified: true
```

## API Endpoints

### Public Endpoints
- `GET /api/subscriptions/plans` - Get all active subscription plans

### Protected Endpoints (Requires Authentication)
- `POST /api/subscriptions/create-order` - Create Razorpay order
- `POST /api/subscriptions/verify-payment` - Verify payment and activate subscription
- `GET /api/subscriptions/my-subscription` - Get user's active subscription
- `PUT /api/subscriptions/cancel` - Cancel user's subscription

### Admin Endpoints
- `GET /api/admin/subscriptions/plans` - Get all plans with subscriber counts
- `POST /api/admin/subscriptions/plans` - Create new plan
- `PUT /api/admin/subscriptions/plans/:id` - Update plan
- `DELETE /api/admin/subscriptions/plans/:id` - Delete plan
- `GET /api/admin/subscriptions` - Get all subscriptions with stats
- `PUT /api/admin/subscriptions/:id/cancel` - Cancel subscription (admin)

## Subscription Plans

### Free Plan
- Price: ₹0/month
- Features:
  - 3 uploads per day
  - 1GB storage
  - SYT participation
  - No verified badge
  - Ads enabled

### Basic Plan
- Price: ₹499/month
- Features:
  - 10 uploads per day
  - 10GB storage
  - Priority support
  - 100 bonus coins
  - 1.2x upload reward multiplier
  - No verified badge
  - Ads enabled

### Pro Plan (Recommended)
- Price: ₹2,499/month
- Features:
  - 50 uploads per day
  - 100GB storage
  - Verified badge (Blue tick)
  - Ad-free experience
  - Custom profile
  - Analytics access
  - 500 bonus coins
  - 1.5x upload reward multiplier
  - Priority support

### VIP Plan
- Price: ₹4,999/month
- Features:
  - 100 uploads per day
  - 500GB storage
  - Verified badge (Blue tick)
  - Ad-free experience
  - Custom profile
  - Advanced analytics
  - 1000 bonus coins
  - 2x upload reward multiplier
  - VIP support

## Troubleshooting

### Issue: "Plan not found" error
**Solution:** Run the seed script to create plans
```bash
node server/scripts/seedSubscriptionPlans.js
```

### Issue: Payment verification fails
**Solution:** 
1. Verify Razorpay API keys in `.env`
2. Check that planId is being sent from frontend
3. Ensure plan exists in database

### Issue: Subscription not showing as active
**Solution:**
1. Check UserSubscription collection for the record
2. Verify user's subscriptionTier was updated
3. Check transaction logs for errors

### Issue: User not getting verified badge
**Solution:**
1. Verify `isVerified` field is being set to true
2. Check User model has `isVerified` field
3. Refresh user data after subscription

## Testing Checklist

- [ ] Subscription plans are seeded in database
- [ ] Frontend loads plans successfully
- [ ] Payment flow completes without errors
- [ ] Subscription is created in database
- [ ] User gets verified badge
- [ ] User subscription tier is updated
- [ ] Transaction record is created
- [ ] Subscription cache is cleared after payment
- [ ] User can view active subscription
- [ ] User can cancel subscription

## Next Steps

1. **Monitor Subscriptions:** Use admin panel to view subscription stats
2. **Handle Renewals:** Implement auto-renewal logic (currently manual)
3. **Add Promo Codes:** Implement discount codes for subscriptions
4. **Email Notifications:** Send subscription confirmation emails
5. **Webhook Integration:** Handle Razorpay webhooks for reliability

## Support

For issues or questions, check:
- Backend logs: `server/logs/`
- MongoDB collections: `subscriptionplans`, `usersubscriptions`
- Razorpay dashboard: https://dashboard.razorpay.com
