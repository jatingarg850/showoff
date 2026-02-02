# Competition Creation Fix - E11000 Duplicate Key Error

## Problem
When trying to create a new competition in the admin panel, the system returned a 500 error:
```
E11000 duplicate key error collection: showoff/competitionsettings index: type_1 dup key { type: 1 }
```

## Root Cause
The `CompetitionSettings` model had a `unique: true` constraint on the `type` field, which meant only one competition per type (weekly, monthly, quarterly, custom) could exist in the database. When trying to create a second competition of the same type, MongoDB rejected it due to the unique constraint violation.

## Solution

### 1. Updated Model Schema
**File**: `server/models/CompetitionSettings.js`

Removed the `unique: true` constraint from the `type` field:
```javascript
// BEFORE:
type: {
  type: String,
  enum: ['weekly', 'monthly', 'quarterly', 'custom'],
  required: true,
  unique: true,  // ❌ This was causing the issue
}

// AFTER:
type: {
  type: String,
  enum: ['weekly', 'monthly', 'quarterly', 'custom'],
  required: true,
}
```

The overlapping date check in the `createCompetition` controller already prevents conflicts:
```javascript
const overlapping = await CompetitionSettings.findOne({
  type,
  isActive: true,
  $or: [
    { startDate: { $lte: end }, endDate: { $gte: start } },
  ],
});
```

### 2. Dropped Existing Unique Index
**File**: `server/scripts/fix-competition-index.js`

Created and ran a migration script to drop the existing unique index from the database:
```bash
node server/scripts/fix-competition-index.js
```

**Results**:
- ✅ Dropped unique index `type_1`
- ✅ Kept composite indexes for queries:
  - `type_1_isActive_1` - for finding active competitions
  - `startDate_1_endDate_1` - for date range queries
  - `periodId_1` - for period lookups

## How It Works Now

1. **Create Competition**: Admin fills in competition details (type, title, dates, prizes)
2. **Validation**: Backend checks:
   - Required fields present
   - End date > Start date
   - No overlapping active competitions of same type
3. **Create**: If all validations pass, competition is created
4. **Multiple Competitions**: Can now have multiple competitions of the same type as long as they don't overlap

## Testing

### Manual Test Steps
1. Go to Admin Panel → Competitions
2. Click "Create Competition"
3. Fill in details:
   - Type: Weekly
   - Title: Test Competition 1
   - Start Date: 2026-02-01
   - End Date: 2026-02-08
4. Click "Save Competition"
5. Create another competition with same type but different dates:
   - Type: Weekly
   - Title: Test Competition 2
   - Start Date: 2026-02-15
   - End Date: 2026-02-22
6. Both should be created successfully

### Expected Behavior
- ✅ First competition created successfully
- ✅ Second competition with same type but different dates created successfully
- ❌ Overlapping competition with same type rejected with proper error message

## Files Modified
1. `server/models/CompetitionSettings.js` - Removed unique constraint
2. `server/scripts/fix-competition-index.js` - Created migration script to drop index

## Notes
- The overlapping date check ensures data integrity
- Multiple competitions of same type can exist as long as they don't overlap
- All existing indexes are preserved for query performance
- No app code changes needed - backend handles the fix
