# Quick Start - Admin Ads Management

## What Changed?
The admin panel now supports full customization of all 5 rewarded ads with:
- Custom titles
- Descriptions
- Font Awesome icons
- Custom colors (with color picker)

## How to Use

### 1. Access Admin Panel
```
http://your-server/admin/rewarded-ads
```

### 2. Edit an Ad
- Click "Edit" button on any ad card
- Modal opens with all fields

### 3. Customize Fields

| Field | Type | Example | Notes |
|-------|------|---------|-------|
| Title | Text | "Watch & Earn" | Required |
| Description | Text | "Watch this ad to earn coins" | Required |
| Ad Link | URL | https://example.com/ad | Required |
| Provider | Select | admob, custom, third-party | Required |
| Icon | Text | gift, star, heart, fire | Font Awesome name |
| Color | Color Picker | #667eea | Hex code format |
| Reward Coins | Number | 10 | 1-1000 |
| Active | Checkbox | ✓ | Enable/disable ad |

### 4. Save Changes
- Click "Save Changes"
- Page reloads with updated ad

## Icon Examples
```
gift      - Gift box
star      - Star
heart     - Heart
fire      - Fire
trophy    - Trophy
coins     - Coins
gem       - Gem
crown     - Crown
zap       - Lightning
target    - Target
```

## Color Recommendations
```
#667eea   - Purple (Primary)
#10b981   - Green (Success)
#f59e0b   - Amber (Warning)
#ef4444   - Red (Danger)
#06b6d4   - Cyan (Info)
#8b5cf6   - Violet
#ec4899   - Pink
#f97316   - Orange
```

## API Endpoint

### Update Ad
```bash
curl -X PUT http://localhost:5000/api/admin/rewarded-ads/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Watch & Earn",
    "description": "Watch this video ad to earn 10 coins",
    "adLink": "https://example.com/ad",
    "adProvider": "admob",
    "icon": "star",
    "color": "#fbbf24",
    "rewardCoins": 10,
    "isActive": true
  }'
```

## Features

✅ Edit all 5 ads independently
✅ Color picker with hex input
✅ Font Awesome icon support
✅ Form validation
✅ Enable/disable ads
✅ Reset statistics
✅ Backward compatible

## Troubleshooting

### Color picker not working?
- Make sure to use valid hex code format: #RRGGBB
- Example: #667eea (not 667eea or rgb(102, 126, 234))

### Icon not showing?
- Use Font Awesome icon names (without "fa-" prefix)
- Example: "gift" (not "fa-gift")
- Check Font Awesome documentation for available icons

### Changes not saving?
- Check browser console for errors
- Verify you're logged in as admin
- Check server logs for API errors

## Files Modified
- `server/models/RewardedAd.js` - Database schema
- `server/controllers/adminController.js` - API logic
- `server/views/admin/rewarded-ads.ejs` - UI template

## Restart Required
After deployment, restart the server:
```bash
npm restart
# or
pm2 restart server
```

## Testing
1. Edit Ad 1 with custom title and color
2. Save and reload page
3. Verify changes persisted
4. Edit all 5 ads with different configurations
5. Test enable/disable functionality
6. Test reset statistics

## Support
For detailed information, see:
- `ADMIN_ADS_ENHANCEMENT_COMPLETE.md` - Full documentation
- `SESSION_SUMMARY_ADMIN_MUSIC_FIX.md` - Session summary
