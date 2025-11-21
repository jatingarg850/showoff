# Admin Talent/SYT Management - Complete Guide

## ✅ Implementation Complete

A comprehensive Talent/SYT (Show Your Talent) management section has been added to the admin panel.

## Features Implemented

### 1. Talent Management Page (`/admin/talent`)

**Statistics Dashboard:**
- Total Entries count
- Weekly Entries count
- Winners Declared count
- Total Coins Awarded

**Entry Management:**
- View all SYT entries in a grid layout
- Filter by competition type (Weekly/Monthly/Quarterly)
- Filter by category (Singing/Dancing/Comedy/Acting/Music/Art/Other)
- View entry details (votes, likes, views, coins earned)
- Toggle entry active/inactive status
- Declare winners (1st, 2nd, 3rd place)
- View user information

**Leaderboard:**
- Top 10 entries by votes
- Ranking display with medals (🥇🥈🥉)
- User profiles
- Engagement metrics

### 2. Backend API Endpoints

**GET /api/admin/syt**
- Get all SYT entries with filters
- Pagination support
- Statistics included

**PUT /api/admin/syt/:id/toggle**
- Activate/deactivate entries
- Moderation control

**PUT /api/admin/syt/:id/winner**
- Declare competition winners
- Automatic coin rewards:
  - 1st Place: 1000 coins
  - 2nd Place: 500 coins
  - 3rd Place: 250 coins

**DELETE /api/admin/syt/:id**
- Remove inappropriate entries
- Content moderation

### 3. Frontend Features

**Entry Cards:**
- Video thumbnail preview
- Status badges (Active/Inactive)
- Winner badges with position
- Competition type indicator
- User profile display
- Engagement metrics (votes, likes, views, coins)
- Action buttons (View, Toggle, Declare Winner)

**Filters:**
- Competition Type dropdown
- Category dropdown
- Real-time filtering

**Leaderboard Table:**
- Sortable by votes
- User information
- Quick actions

## How to Use

### Access the Talent Page

1. Login to admin panel: `http://localhost:3000/admin`
   - Email: `admin@showofflife.com`
   - Password: `admin123`

2. Click "Talent/SYT" in the sidebar

### View Entries

- All entries are displayed in a grid layout
- Each card shows:
  - Video thumbnail
  - Title and description
  - User information
  - Engagement metrics
  - Status and competition type

### Filter Entries

1. **By Competition Type:**
   - Select from dropdown: All/Weekly/Monthly/Quarterly
   
2. **By Category:**
   - Select from dropdown: All/Singing/Dancing/Comedy/etc.

### Manage Entries

**Activate/Deactivate:**
1. Click the toggle button (pause/play icon)
2. Confirm the action
3. Entry status updates immediately

**Declare Winner:**
1. Click the trophy icon button
2. Enter position (1, 2, or 3)
3. Coins are automatically awarded to the user
4. Winner badge appears on the entry

**View Entry:**
- Click "View" button to see full details

### Leaderboard

- Shows top 10 entries by votes
- Automatically updates
- Displays medals for top 3
- Shows all engagement metrics

## Prize Structure

| Position | Coins Awarded | Badge |
|----------|---------------|-------|
| 1st Place | 1000 coins | 🥇 |
| 2nd Place | 500 coins | 🥈 |
| 3rd Place | 250 coins | 🥉 |

## Competition Types

### Weekly Competition
- Period: Week 1-52 of the year
- Format: `2024-W01`
- One entry per user per week

### Monthly Competition
- Period: Month 1-12 of the year
- Format: `2024-01`
- One entry per user per month

### Quarterly Competition
- Period: Q1-Q4 of the year
- Format: `2024-Q1`
- One entry per user per quarter

## Categories

- **Singing**: Vocal performances
- **Dancing**: Dance performances
- **Comedy**: Stand-up, sketches
- **Acting**: Dramatic performances
- **Music**: Instrumental performances
- **Art**: Visual art demonstrations
- **Other**: Other talents

## Entry Information

Each entry displays:
- **Video**: Uploaded performance
- **Thumbnail**: Video preview image
- **Title**: Entry title (max 200 chars)
- **Description**: Entry description (max 1000 chars)
- **User**: Creator information
- **Votes**: Number of votes received
- **Likes**: Number of likes
- **Views**: Number of views
- **Coins Earned**: Coins from votes
- **Status**: Active/Inactive
- **Winner Status**: If declared winner

## Admin Actions

### Toggle Entry Status
```javascript
PUT /api/admin/syt/:id/toggle
```
- Activates or deactivates an entry
- Inactive entries are hidden from users
- Use for moderation

### Declare Winner
```javascript
PUT /api/admin/syt/:id/winner
Body: { position: 1 } // 1, 2, or 3
```
- Marks entry as winner
- Awards prize coins automatically
- Updates user's coin balance
- Creates transaction record

### Delete Entry
```javascript
DELETE /api/admin/syt/:id
```
- Permanently removes entry
- Use for policy violations
- Cannot be undone

## Statistics

The dashboard shows:
- **Total Entries**: All-time entry count
- **Weekly Entries**: Current week submissions
- **Winners**: Total winners declared
- **Coins Awarded**: Total prize coins distributed

## Database Schema

```javascript
{
  user: ObjectId,
  videoUrl: String,
  thumbnailUrl: String,
  title: String,
  description: String,
  category: String,
  competitionType: String,
  competitionPeriod: String,
  votesCount: Number,
  viewsCount: Number,
  likesCount: Number,
  commentsCount: Number,
  coinsEarned: Number,
  isWinner: Boolean,
  winnerPosition: Number,
  prizeCoins: Number,
  isActive: Boolean,
  isApproved: Boolean
}
```

## Files Created/Modified

### New Files:
- `server/views/admin/talent.ejs` - Talent management page

### Modified Files:
- `server/controllers/adminController.js` - Added SYT management functions
- `server/routes/adminRoutes.js` - Added API routes
- `server/routes/adminWebRoutes.js` - Added web route
- `server/views/admin/partials/admin-sidebar.ejs` - Added Talent link

## API Response Examples

### Get Entries
```json
{
  "success": true,
  "data": [...entries],
  "stats": {
    "totalEntries": 150,
    "weeklyEntries": 25,
    "winners": 12,
    "totalCoinsAwarded": 15000
  },
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 150,
    "pages": 3
  }
}
```

### Declare Winner
```json
{
  "success": true,
  "message": "Winner declared! 1000 coins awarded.",
  "data": {
    "_id": "...",
    "isWinner": true,
    "winnerPosition": 1,
    "prizeCoins": 1000
  }
}
```

## Best Practices

1. **Review Before Declaring Winners**: Watch entries before declaring winners
2. **Fair Competition**: Ensure all entries follow guidelines
3. **Timely Moderation**: Review new entries regularly
4. **Clear Communication**: Announce winners to users
5. **Monitor Engagement**: Track votes and views for suspicious activity

## Troubleshooting

### Entries Not Showing
- Check if entries exist in database
- Verify filters are not too restrictive
- Check MongoDB connection

### Winner Declaration Fails
- Ensure position is 1, 2, or 3
- Check if entry exists
- Verify user has sufficient data

### Videos Not Playing
- Check Wasabi S3 configuration
- Verify video URLs are accessible
- Check CORS settings

## Future Enhancements

Potential improvements:
- Bulk winner declaration
- Export leaderboard data
- Email notifications to winners
- Automated winner selection
- Fraud detection for votes
- Entry analytics dashboard
- Category-wise leaderboards
- Historical competition data

## Support

For issues or questions:
1. Check server logs
2. Verify database connection
3. Test API endpoints directly
4. Review entry data in MongoDB

---

**Status**: ✅ Fully Implemented and Ready to Use
**Access**: http://localhost:3000/admin/talent
