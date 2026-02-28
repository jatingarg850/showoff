# Referral System - Quick Start Guide

## For Users

### Share Your Referral Code
1. Open app → Settings → Referrals & Invites
2. Tap "SHARE LINK" button
3. Share the message with your referral code
4. Earn 20 coins for each friend who signs up

### Use a Referral Code
1. Click referral link from friend
2. Go through signup process
3. Referral code will be pre-filled
4. Complete signup
5. Earn 20 coins + 50 profile bonus = 70 coins total

## For Developers

### Test Referral System

**Test 1: Share Code**
```
1. Go to Referrals screen
2. Tap "SHARE LINK"
3. Verify message includes code and app link
```

**Test 2: Deep Link**
```
1. Generate link: https://showoff.life/ref/{CODE}
2. Click link
3. Should navigate to signup with code pre-filled
```

**Test 3: Complete Flow**
```
1. Click referral link
2. Sign up with email/phone
3. Complete all steps
4. Verify both users got 20 coins
5. Check referral count incremented
```

### Key Files
- Frontend: `apps/lib/referrals_screen.dart`
- Backend: `server/controllers/authController.js`
- API: `POST /api/auth/register` with `referralCode`

### Rewards
- New user: 20 coins (referral) + 50 coins (profile) = 70 coins
- Referrer: 20 coins per successful referral

### Validation
- One code per user
- No self-referrals
- Code must exist
- No duplicate usage

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Code not pre-filled | Check if referral code passed through signup flow |
| Coins not awarded | Verify transaction created, check coin balance |
| Deep link not working | Verify format: `https://showoff.life/ref/{CODE}` |
| Can't use code | Check if already used, not own code, code exists |

## API Reference

### Register with Referral
```bash
POST /api/auth/register
Content-Type: application/json

{
  "username": "newuser",
  "displayName": "New User",
  "password": "password123",
  "email": "user@example.com",
  "referralCode": "USERA123",
  "termsAccepted": true
}
```

### Apply Referral (Post-Signup)
```bash
POST /api/profile/apply-referral
Authorization: Bearer {token}
Content-Type: application/json

{
  "referralCode": "USERA123"
}
```

## Status
✅ All systems working
✅ All code passes diagnostics
✅ Ready for production
