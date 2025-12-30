# Subscription Setup - Quick Start

## 1. Seed Premium Plan to Database

```bash
cd server
node scripts/seed-premium-plan.js
```

**Expected Output:**
```
✅ Connected to MongoDB
✅ Premium plan created successfully
Plan ID: [some_id]
Plan Details: { name: 'ShowOff Premium', tier: 'pro', ... }
✅ Database connection closed
```

---

## 2. Verify Backend Setup

Check that these files are updated:
- ✅ `server/controllers/subscriptionController.js` - Has `verifySubscriptionPayment()` method
- ✅ `server/routes/subscriptionRoutes.js` - Has `/verify-payment` route
- ✅ `server/models/Subscription.js` - Has SubscriptionPlan and UserSubscription models

---

## 3. Verify Frontend Setup

Check that these files exist:
- ✅ `apps/lib/subscription_screen.dart` - Updated with single plan UI
- ✅ `apps/lib/services/subscription_service.dart` - New helper service
- ✅ `apps/lib/services/api_service.dart` - Has `verifySubscriptionPayment()` method
- ✅ `apps/lib/services/ad_service.dart` - Updated with ad-free check

---

## 4. Test Subscription Flow

### On Device/Emulator:

1. **Navigate to Subscription Screen**
   - Open app settings/menu
   - Find "Premium" or "Subscription" option
   - Should see single plan: "₹2,499/month"

2. **Click Subscribe**
   - Button should say "Subscribe Now"
   - Should open Razorpay payment UI

3. **Complete Test Payment**
   - Use Razorpay test card: `4111 1111 1111 1111`
   - Any future expiry date
   - Any CVV (e.g., 123)
   - Any OTP (e.g., 123456)

4. **Verify Success**
   - Should see "Success!" dialog
   - Subscription screen should show "Active Subscription"
   - Expiry date should display

---

## 5. Verify Benefits Working

### Verified Badge (Blue Tick)
- Check user profile
- Should see blue verified icon next to name
- User model should have `isVerified: true`

### Ad-Free Access
- Navigate to any screen with ads
- Ads should NOT appear
- Check logs: should see "⏭️ Skipping ad load - user has ad-free subscription"

### Coin Payments
- Go to any payment screen
- Should see option to "Pay with Coins"
- Can use earned coins for payments

---

## 6. Database Verification

### Check Premium Plan Created:
```javascript
// In MongoDB
db.subscriptionplans.findOne({ tier: 'pro' })

// Should return:
{
  _id: ObjectId(...),
  name: "ShowOff Premium",
  tier: "pro",
  price: { monthly: 2499, yearly: 24990 },
  currency: "INR",
  features: { verifiedBadge: true, adFree: true, ... },
  isActive: true,
  highlightedFeatures: [
    "Verified profile (Blue tick)",
    "100% ad-free",
    "Payment allowed via earned coins"
  ]
}
```

### Check User Subscription:
```javascript
// After payment
db.usersubscriptions.findOne({ user: ObjectId(...) })

// Should return:
{
  _id: ObjectId(...),
  user: ObjectId(...),
  plan: ObjectId(...),
  status: "active",
  billingCycle: "monthly",
  startDate: ISODate(...),
  endDate: ISODate(...),
  amountPaid: 2499,
  paymentMethod: "razorpay",
  transactionId: "pay_xxx"
}
```

### Check User Updated:
```javascript
// After payment
db.users.findOne({ _id: ObjectId(...) })

// Should have:
{
  subscriptionTier: "pro",
  subscriptionExpiry: ISODate(...),
  isVerified: true
}
```

---

## 7. Troubleshooting

### Issue: "Premium plan not found"
**Solution:** Run seed script again
```bash
node server/scripts/seed-premium-plan.js
```

### Issue: "Invalid payment signature"
**Solution:** Check Razorpay credentials in `.env`
```
RAZORPAY_KEY_ID=rzp_test_RKkNoqkW7sQisX
RAZORPAY_KEY_SECRET=Dfe20218e1WYafVRRZQUH9Qx
```

### Issue: Ads still showing after subscription
**Solution:** 
1. Clear app cache
2. Restart app
3. Check `SubscriptionService.instance.isAdFree()` returns true

### Issue: Subscription not showing as active
**Solution:**
1. Check user has `subscriptionTier: 'pro'`
2. Check `subscriptionExpiry` is in future
3. Call `SubscriptionService.instance.refreshSubscription()`

---

## 8. Production Checklist

Before deploying to production:

- [ ] Update Razorpay keys to production keys
- [ ] Test with real payment
- [ ] Verify all three benefits working
- [ ] Check subscription renewal logic
- [ ] Set up monitoring for failed payments
- [ ] Create admin dashboard for subscriptions
- [ ] Set up email notifications for expiry
- [ ] Test subscription cancellation
- [ ] Verify transaction records created
- [ ] Check analytics for subscription metrics

---

## 9. Key Files Reference

| File | Purpose |
|------|---------|
| `apps/lib/subscription_screen.dart` | Main subscription UI |
| `apps/lib/services/subscription_service.dart` | Subscription status helper |
| `apps/lib/services/api_service.dart` | API calls |
| `apps/lib/services/ad_service.dart` | Ad management with subscription check |
| `server/controllers/subscriptionController.js` | Backend logic |
| `server/routes/subscriptionRoutes.js` | API routes |
| `server/models/Subscription.js` | Database schemas |
| `server/scripts/seed-premium-plan.js` | Database seeding |

---

## 10. Support Commands

### Check Subscription Status
```dart
final subscription = await SubscriptionService.instance.getSubscriptionDetails();
print('Subscription: $subscription');
```

### Check Remaining Days
```dart
final days = await SubscriptionService.instance.getRemainingDays();
print('Days remaining: $days');
```

### Refresh Subscription
```dart
await SubscriptionService.instance.refreshSubscription();
```

### Check Ad-Free Status
```dart
final isAdFree = await SubscriptionService.instance.isAdFree();
print('Ad-free: $isAdFree');
```

---

## Done! 🎉

Your subscription system is now ready to use. Users can:
1. Subscribe for ₹2,499/month
2. Get verified badge (blue tick)
3. Enjoy ad-free experience
4. Pay with earned coins

