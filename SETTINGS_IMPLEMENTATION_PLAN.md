# Settings Implementation Plan

## Current Status Analysis

### 1. My Account Screen ❌ NOT WORKING
- **Issues**: Static data, no API integration
- **Needs**:
  - Load user data from API
  - Update profile (name, email, phone, bio)
  - Upload profile picture
  - Change password functionality
  - Account verification
  - Download user data
  - Real account statistics

### 2. Payment Settings Screen ✅ PARTIALLY WORKING
- **Working**: Card management, billing info display
- **Needs**: Better error handling, edit billing info dialog

### 3. Notification Settings Screen ❌ NOT WORKING
- **Issues**: No backend persistence
- **Needs**:
  - Save notification preferences to backend
  - Load preferences from API
  - Real-time updates

### 4. Subscription Screen ❌ NOT WORKING
- **Issues**: Static UI only
- **Needs**:
  - Load subscription plans from backend
  - Current subscription status
  - Payment integration
  - Subscription management

### 5. Referrals Screen ✅ PARTIALLY WORKING
- **Working**: Shows referral code from user data
- **Needs**:
  - Real referral statistics
  - Share functionality
  - Transaction history integration

### 6. Privacy & Safety Screen ❌ NOT WORKING
- **Issues**: No backend persistence
- **Needs**:
  - Save privacy settings to backend
  - Load settings from API
  - Change password integration
  - Account deletion

## Implementation Priority

1. **My Account Screen** - Most critical
2. **Notification Settings** - User experience
3. **Privacy & Safety** - Security
4. **Subscription Screen** - Revenue
5. **Referrals** - Growth

## Backend Requirements

### New API Endpoints Needed:
- `PUT /api/profile/update` - Update profile info
- `POST /api/profile/change-password` - Change password
- `GET /api/profile/settings` - Get user settings
- `PUT /api/profile/settings` - Update settings
- `POST /api/profile/verify` - Request verification
- `GET /api/profile/data-export` - Export user data
- `DELETE /api/profile/account` - Delete account
- `GET /api/subscriptions/plans` - Get subscription plans
- `POST /api/subscriptions/subscribe` - Subscribe to plan
- `GET /api/subscriptions/current` - Get current subscription
