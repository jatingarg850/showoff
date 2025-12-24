# Rewarded Ads Management System - Complete Guide

## Overview
This comprehensive guide covers the complete rewarded ads management system that allows admins to manage up to 5 rewarded ads with dynamic rotation, tracking, and monetization capabilities.

## System Architecture

### Components

1. **Admin Panel** - Web interface for managing ads
2. **Backend API** - RESTful endpoints for ad management and serving
3. **Mobile App** - Flutter app that fetches and displays ads
4. **Database** - MongoDB storage for ad configuration and metrics

## Admin Panel Features

### Access the Admin Panel
- URL: `http://localhost:3000/admin/rewarded-ads`
- Login: `admin@showofflife.com` / `admin123`

### Dashboard Overview

The admin panel displays:

1. **Statistics Cards**
   - Total Impressions: Number of times ads were shown
   - Total Clicks: Number of ad clicks
   - Total Conversions: Number of completed conversions
   - Total Served: Total ad serves

2. **Ad Management Cards** (5 ads total)
   Each ad card shows:
   - Ad Number (1-5)
   - Status (Active/Inactive)
   - Provider (AdMob, Custom, Third-party)
   - Reward Coins
   - Rotation Order
   - Ad Link (truncated)
   - Performance Metrics:
     - Impressions
     - Click-Through Rate (CTR)
     - Clicks
     - Conversion Rate

### Managing Individual Ads

#### Edit Ad
1. Click the **Edit** button on any ad card
2. Update the following fields:
   - **Ad Link**: URL where the ad points to
   - **Ad Provider**: Select from AdMob, Custom, or Third-party
   - **Reward Coins**: Number of coins users earn (1-1000)
   - **Rotation Order**: Priority order for ad rotation (0-100)
   - **Active**: Toggle to enable/disable the ad

3. Click **Save Changes**

#### Enable/Disable Ad
- Click **Enable** to activate an inactive ad
- Click **Disable** to deactivate an active ad

#### Reset Statistics
- Click **Reset** to clear all metrics for an ad
- Useful for testing or starting fresh

## Backend API Endpoints

### Admin Endpoints (Requires Authentication)

#### Get All Ads
```
GET /api/admin/rewarded-ads
Response: Array of all rewarded ads with metrics
```

#### Get Single Ad
```
GET /api/admin/rewarded-ads/:adNumber
Response: Single ad configuration
```

#### Update Ad
```
PUT /api/admin/rewarded-ads/:adNumber
Body: {
  "adLink": "https://example.com/ad",
  "adProvider": "admob|custom|third-party",
  "rewardCoins": 10,
  "isActive": true
}
Response: Updated ad object
```

#### Reset Ad Statistics
```
POST /api/admin/rewarded-ads/:adNumber/reset-stats
Response: Ad with reset metrics
```

### Public Endpoints (For Mobile App)

#### Get Active Ads
```
GET /api/ads
Response: Array of active ads sorted by rotation order
Note: Automatically increments impressions and servedCount
```

#### Track Ad Click
```
POST /api/ads/:adNumber/click
Response: Success message
```

#### Track Ad Conversion
```
POST /api/ads/:adNumber/conversion
Response: Success message
```

## Mobile App Integration

### How It Works

1. **Ad Fetching**
   - App calls `/api/ads` endpoint
   - Backend returns active ads sorted by rotation order
   - Impressions are automatically tracked

2. **Ad Display**
   - App displays ads in AdSelectionScreen
   - Each ad shows title, description, reward coins, and icon
   - Ads are fetched from backend (with fallback to defaults)

3. **Ad Watching**
   - User taps an ad
   - App tracks click via `/api/ads/:adNumber/click`
   - AdMob rewarded ad is shown
   - On completion, app tracks conversion via `/api/ads/:adNumber/conversion`
   - Backend awards coins to user

4. **Caching**
   - Ads are cached for 1 hour
   - Cache is cleared on app refresh
   - Automatic refresh on app resume

### Updated Files

**New Service**: `apps/lib/services/rewarded_ad_service.dart`
- Handles ad fetching and caching
- Tracks clicks and conversions
- Provides fallback to default ads

**Updated Screen**: `apps/lib/ad_selection_screen.dart`
- Fetches ads from backend
- Displays dynamic ad list
- Handles loading states
- Tracks user interactions

## Ad Configuration Best Practices

### Rotation Strategy

1. **Rotation Order**
   - Lower numbers = higher priority
   - Set different rotation orders for different ads
   - Example: Ad 1 (order 1), Ad 2 (order 2), Ad 3 (order 3)

2. **Active/Inactive**
   - Keep only relevant ads active
   - Disable underperforming ads
   - Test new ads before full rollout

### Reward Coins

1. **Pricing Strategy**
   - Standard: 10 coins per ad
   - Premium: 15-20 coins for high-value ads
   - Promotional: 5 coins for testing

2. **Daily Limits** (Enforced by backend)
   - Free users: 5 ads/day
   - Basic: 10 ads/day
   - Pro: 15 ads/day
   - VIP: 50 ads/day

### Ad Providers

1. **AdMob**
   - Google's native ad network
   - Best for monetization
   - Requires AdMob account setup

2. **Custom**
   - Your own ad campaigns
   - Direct advertiser relationships
   - Full control over content

3. **Third-party**
   - Other ad networks
   - Programmatic ads
   - Multiple revenue streams

## Monitoring & Analytics

### Key Metrics

1. **Impressions**
   - Total times ad was shown
   - Indicates reach

2. **Click-Through Rate (CTR)**
   - Clicks ÷ Impressions × 100
   - Indicates ad relevance
   - Target: 2-5% for good performance

3. **Conversions**
   - Completed ad watches
   - Indicates user engagement
   - Target: 80%+ of clicks

4. **Conversion Rate**
   - Conversions ÷ Clicks × 100
   - Indicates completion rate

### Performance Optimization

1. **Low CTR**
   - Update ad link
   - Change ad provider
   - Adjust rotation order

2. **Low Conversion Rate**
   - Check ad quality
   - Verify ad link works
   - Test with different providers

3. **High Impressions, Low Clicks**
   - Ad may not be relevant
   - Consider disabling
   - Try different content

## Database Schema

### RewardedAd Model

```javascript
{
  adNumber: Number (1-5, unique),
  adLink: String (required),
  adProvider: String (admob|custom|third-party),
  rewardCoins: Number (default: 10),
  isActive: Boolean (default: true),
  impressions: Number (default: 0),
  clicks: Number (default: 0),
  conversions: Number (default: 0),
  rotationOrder: Number (default: 0),
  lastServedAt: Date,
  servedCount: Number (default: 0),
  createdAt: Date,
  updatedAt: Date
}
```

## Troubleshooting

### Ads Not Showing in App

1. **Check Backend**
   - Verify server is running
   - Check `/api/ads` endpoint
   - Ensure ads are active

2. **Check App**
   - Verify RewardedAdService is imported
   - Check network connectivity
   - Review app logs

3. **Check Cache**
   - Clear app cache
   - Force refresh ads
   - Restart app

### Coins Not Awarded

1. **Check Backend**
   - Verify `/api/coins/watch-ad` endpoint
   - Check user authentication
   - Review transaction logs

2. **Check Daily Limit**
   - User may have reached daily limit
   - Check subscription tier
   - Verify cooldown period

### Incorrect Metrics

1. **Reset Statistics**
   - Use admin panel reset button
   - Clears all metrics for ad
   - Useful for testing

2. **Check Database**
   - Verify RewardedAd records
   - Check for duplicate entries
   - Review update timestamps

## Security Considerations

1. **Admin Authentication**
   - Only admins can manage ads
   - Session-based authentication
   - JWT token validation

2. **Public Endpoints**
   - No authentication required for ad serving
   - Rate limiting recommended
   - IP-based restrictions optional

3. **Data Validation**
   - URL validation for ad links
   - Coin amount limits
   - Provider enum validation

## Future Enhancements

1. **A/B Testing**
   - Test different ad variations
   - Compare performance metrics
   - Automatic winner selection

2. **Geo-Targeting**
   - Serve different ads by region
   - Localized content
   - Regional monetization

3. **User Segmentation**
   - Target ads by user tier
   - Personalized ad rotation
   - Behavioral targeting

4. **Advanced Analytics**
   - Revenue tracking
   - User lifetime value
   - Cohort analysis

5. **Automated Optimization**
   - ML-based rotation
   - Dynamic reward adjustment
   - Performance-based enabling/disabling

## Support & Maintenance

### Regular Tasks

1. **Daily**
   - Monitor ad performance
   - Check for errors
   - Review user feedback

2. **Weekly**
   - Analyze metrics
   - Optimize rotation
   - Update underperforming ads

3. **Monthly**
   - Review revenue
   - Plan new campaigns
   - Test new providers

### Backup & Recovery

1. **Database Backups**
   - Regular MongoDB backups
   - Store in secure location
   - Test recovery procedures

2. **Configuration Backups**
   - Export ad configurations
   - Version control
   - Document changes

## Contact & Support

For issues or questions:
1. Check this documentation
2. Review admin panel logs
3. Check backend server logs
4. Contact development team

---

**Last Updated**: December 2024
**Version**: 1.0
**Status**: Production Ready
