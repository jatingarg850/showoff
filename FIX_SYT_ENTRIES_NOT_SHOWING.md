# Fix: SYT Entries Not Showing in Talent Screen

## Problem
After uploading an SYT reel, the talent screen shows "Already Submitted This Week" but the entries grid is empty.

## Root Cause
The `getEntries` controller was using the old `getCurrentPeriod()` function which calculates period IDs based on week numbers (e.g., "2024-W47"). However, the new competition system uses custom `periodId` from CompetitionSettings (e.g., "weekly-2024-11-25").

**Mismatch Example:**
- Entry saved with: `competitionPeriod: "weekly-2024-11-25"` (from active competition)
- Query looking for: `competitionPeriod: "2024-W47"` (from getCurrentPeriod calculation)
- Result: No match, empty array returned

## Solution

### 1. Updated `getEntries` Controller
**File: `server/controllers/sytController.js`**

Changed from calculating period to fetching active competition:

```javascript
// OLD CODE (WRONG)
if (filter === 'weekly') {
  query.competitionType = 'weekly';
  query.competitionPeriod = getCurrentPeriod('weekly'); // Calculates "2024-W47"
}

// NEW CODE (CORRECT)
if (filter === 'weekly' || filter === 'monthly' || filter === 'quarterly') {
  const competition = await getCurrentCompetition(filter);
  if (competition) {
    query.competitionType = filter;
    query.competitionPeriod = competition.periodId; // Uses actual competition periodId
  } else {
    return res.status(200).json({
      success: true,
      data: [],
      message: `No active ${filter} competition`,
    });
  }
}
```

### 2. Updated `getLeaderboard` Controller
Applied the same fix to ensure leaderboard shows correct entries.

## Testing

### Step 1: Check if Competition Exists
```bash
node test_syt_entries.js
```

This will show:
- Current competition status
- Number of entries found
- Sample entry data

### Step 2: Create Competition (if needed)
1. Go to `http://localhost:5000/admin/login`
2. Login with admin credentials
3. Navigate to "Talent/SYT" section
4. Click "Create Competition"
5. Fill in:
   - Type: Weekly
   - Title: "Weekly Talent Show"
   - Start Date: Today
   - End Date: 7 days from now
   - Prizes: 1000/500/250 coins
6. Save

### Step 3: Verify in Flutter App
1. Restart the Flutter app
2. Navigate to Talent screen
3. Entries should now appear in the grid

## Common Issues

### Issue 1: Still No Entries After Fix
**Cause:** No active competition exists

**Solution:**
```bash
# Check database for competitions
mongo
use showoff_db
db.competitionsettings.find().pretty()

# Check for entries
db.sytentries.find().pretty()
```

If no competition exists, create one via admin panel.

### Issue 2: Entries Exist But Wrong Period
**Cause:** Entries were created before competition was set up

**Solution:** Update existing entries to match competition periodId:
```javascript
// In MongoDB
db.sytentries.updateMany(
  { competitionType: 'weekly' },
  { $set: { competitionPeriod: 'weekly-2024-11-25' } } // Use actual competition periodId
)
```

### Issue 3: Entries Not Approved
**Cause:** `isApproved: false` on entries

**Solution:**
```javascript
// In MongoDB
db.sytentries.updateMany(
  { isApproved: false },
  { $set: { isApproved: true } }
)
```

## Verification Checklist

✅ Competition exists in database
✅ Competition is active (current date between startDate and endDate)
✅ Entries have matching competitionPeriod
✅ Entries have isActive: true
✅ Entries have isApproved: true
✅ Backend returns entries in API response
✅ Flutter app displays entries in grid

## API Endpoints

### Get Entries
```
GET /api/syt/entries?filter=weekly
Response: {
  success: true,
  data: [
    {
      _id: "...",
      title: "My Talent",
      competitionType: "weekly",
      competitionPeriod: "weekly-2024-11-25",
      user: { username: "...", ... },
      votesCount: 0,
      likesCount: 0,
      ...
    }
  ]
}
```

### Get Current Competition
```
GET /api/syt/current-competition?type=weekly
Response: {
  success: true,
  data: {
    hasActiveCompetition: true,
    competition: {
      id: "...",
      title: "Weekly Talent Show",
      type: "weekly",
      startDate: "2024-11-25T00:00:00.000Z",
      endDate: "2024-12-02T00:00:00.000Z",
      periodId: "weekly-2024-11-25"
    }
  }
}
```

## Files Modified
1. `server/controllers/sytController.js` - Updated getEntries and getLeaderboard
2. `test_syt_entries.js` - Created test script

## Next Steps
1. Run test script to verify entries are returned
2. Create competition if none exists
3. Restart Flutter app to see entries
4. If still not working, check database directly
