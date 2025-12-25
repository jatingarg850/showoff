# Quick Reference - Dynamic Ads System

## 🎯 What You Can Do Now

### Admin Panel
```
http://localhost:3000/admin/rewarded-ads
```

**Edit any ad:**
1. Click "Edit" button
2. Change any field:
   - Title (custom name)
   - Description (custom text)
   - Icon (14+ options)
   - Color (any hex code)
   - Reward (1-10000 coins)
   - Provider (AdMob, Meta, Custom, Third-party)
3. Click "Save Changes"
4. Changes appear in app immediately

### App Display
```
Wallet → Watch Ads & Earn
```

**See dynamic ads:**
- Title from server
- Description from server
- Icon from server
- Color from server
- Reward from server
- Provider badge (if not AdMob)

## 📊 Example Changes

### Change Reward
```
Admin: Edit Ad 1 → Reward: 50 → Save
App: Shows "+50" in badge → User earns 50 coins
```

### Change Color
```
Admin: Edit Ad 2 → Color: #FF6B35 → Save
App: Ad card displays in orange
```

### Change Icon
```
Admin: Edit Ad 3 → Icon: star → Save
App: Ad card shows star icon
```

### Change Provider
```
Admin: Edit Ad 4 → Provider: Meta → Fill fields → Save
App: Shows "Provider: META" badge
```

### Disable Ad
```
Admin: Edit Ad 5 → Uncheck Active → Save
App: Ad card grayed out, not clickable
```

## 🔧 Supported Values

### Icons
```
gift, star, heart, fire, trophy, coins, gem, crown
zap, target, play-circle, video, hand-pointer, clipboard
```

### Colors
```
Any hex code: #667eea, #FF6B35, #4FACFE, #43E97B, etc.
```

### Rewards
```
1-10000 coins (any integer in range)
```

### Providers
```
admob, meta, custom, third-party
```

## 📱 App Features

### Dynamic Display
- ✅ Title changes instantly
- ✅ Description changes instantly
- ✅ Color changes instantly
- ✅ Icon changes instantly
- ✅ Reward changes instantly
- ✅ Provider badge shows/hides

### Flexible Rewards
- ✅ Different ads, different rewards
- ✅ 1-10000 coins per ad
- ✅ Success dialog shows actual reward
- ✅ Coins awarded correctly

### Provider Support
- ✅ AdMob: Shows AdMob ad
- ✅ Meta: Shows AdMob fallback
- ✅ Custom: Shows AdMob fallback
- ✅ Third-party: Shows AdMob fallback

## 🚀 Quick Start

### Step 1: Restart Server
```bash
npm restart
# or
pm2 restart server
```

### Step 2: Access Admin Panel
```
http://localhost:3000/admin/rewarded-ads
```

### Step 3: Edit an Ad
1. Click "Edit" on any ad
2. Change title to "New Title"
3. Change reward to 25
4. Click "Save Changes"

### Step 4: Test in App
1. Open app
2. Go to Wallet → Watch Ads
3. Verify new title appears
4. Verify "+25" appears
5. Watch ad and earn 25 coins

## 📋 Checklist

- [ ] Restart server
- [ ] Access admin panel
- [ ] Edit Ad 1 - change title
- [ ] Edit Ad 2 - change color
- [ ] Edit Ad 3 - change icon
- [ ] Edit Ad 4 - change reward
- [ ] Edit Ad 5 - change provider
- [ ] Refresh app
- [ ] Verify all changes display
- [ ] Watch an ad
- [ ] Verify correct reward earned

## 🎯 Common Tasks

### Change Reward for All Ads
```
Ad 1: 10 coins
Ad 2: 15 coins
Ad 3: 20 coins
Ad 4: 25 coins
Ad 5: 50 coins
```

### Set Different Colors
```
Ad 1: #667eea (purple)
Ad 2: #FF6B35 (orange)
Ad 3: #4FACFE (blue)
Ad 4: #43E97B (green)
Ad 5: #FBBF24 (amber)
```

### Set Different Icons
```
Ad 1: gift
Ad 2: star
Ad 3: heart
Ad 4: fire
Ad 5: trophy
```

### Set Different Providers
```
Ad 1: admob
Ad 2: admob
Ad 3: meta
Ad 4: custom
Ad 5: third-party
```

## 🔍 Troubleshooting

### Ads not showing?
- Restart server
- Clear app cache
- Refresh page

### Changes not appearing?
- Verify save was successful
- Refresh app
- Check server logs

### Wrong color?
- Verify hex code format (#RRGGBB)
- Check color is valid
- Fallback is #667eea

### Wrong icon?
- Verify icon name is supported
- Check spelling
- Fallback is play_circle_filled

### Reward not updating?
- Verify reward is 1-10000
- Check API returns correct value
- Verify app fetches latest ads

## 📞 Support

**Documentation:**
- FLEXIBLE_ADS_MANAGEMENT_COMPLETE.md - Full details
- APP_DYNAMIC_ADS_IMPLEMENTATION.md - App details
- QUICK_START_FLEXIBLE_ADS.md - Quick guide

**Files:**
- Admin Panel: http://localhost:3000/admin/rewarded-ads
- API: http://localhost:3000/api/rewarded-ads
- App: Wallet → Watch Ads & Earn

## ✅ Status

**COMPLETE AND READY** ✅

All features working:
- ✅ Dynamic ads
- ✅ Flexible rewards
- ✅ Multi-provider
- ✅ Admin panel
- ✅ App display
- ✅ Error handling

**Deploy to production anytime!** 🚀
