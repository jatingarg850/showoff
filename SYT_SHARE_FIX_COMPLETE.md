# SYT Share Fix - "post is required" Error

## Problem
When trying to share an SYT reel from the SYT reel screen, the app showed an error:
```
Share validation failed: post. Path 'post' is required.
```

## Root Cause
The Share model was designed only for regular posts and had a required `post` field. When the SYT share endpoint tried to create a Share record with `sytEntry` instead of `post`, MongoDB validation failed because the `post` field was missing.

## Solution

### Updated Share Model
**File**: `server/models/Share.js`

Made the Share model flexible to support both posts and SYT entries:

**Changes**:
1. Made `post` field optional (removed `required: true`)
2. Added new optional `sytEntry` field for SYT entries
3. Added pre-save validation to ensure either `post` or `sytEntry` is provided (but not both)
4. Added indexes for both post and sytEntry queries

**Before**:
```javascript
post: {
  type: mongoose.Schema.Types.ObjectId,
  ref: 'Post',
  required: true,  // ❌ This was causing the issue
}
```

**After**:
```javascript
post: {
  type: mongoose.Schema.Types.ObjectId,
  ref: 'Post',
},
sytEntry: {
  type: mongoose.Schema.Types.ObjectId,
  ref: 'SYTEntry',
},

// Validation: Either post or sytEntry must be provided
shareSchema.pre('save', function(next) {
  if (!this.post && !this.sytEntry) {
    next(new Error('Either post or sytEntry must be provided'));
  } else if (this.post && this.sytEntry) {
    next(new Error('Cannot share both post and sytEntry at the same time'));
  } else {
    next();
  }
});
```

## How It Works Now

1. **User Shares SYT Entry**: Clicks share button on SYT reel
2. **App Calls API**: `POST /api/syt/:id/share` with `shareType: 'link'`
3. **Backend Creates Share Record**: Creates Share document with `sytEntry` field (no `post` field)
4. **Validation Passes**: Pre-save hook validates that `sytEntry` is provided
5. **Coins Awarded**: User receives 5 coins for sharing
6. **Success**: Share count incremented and user notified

## Testing

### Manual Test Steps
1. Open SYT Reel Screen
2. Find a competition entry
3. Click the share button (arrow icon)
4. Select share method (native share dialog)
5. Verify:
   - ✅ Share dialog appears
   - ✅ No error message
   - ✅ User receives 5 coins
   - ✅ Share count increments

### Expected Behavior
- ✅ SYT entries can be shared successfully
- ✅ Regular posts can still be shared (backward compatible)
- ✅ User receives 5 coins per share
- ✅ Daily share limit enforced (50 shares/day)
- ✅ Share count displayed on reel

## Files Modified
1. `server/models/Share.js` - Made post optional, added sytEntry field, added validation

## Notes
- The fix is backward compatible - regular post shares still work
- Both post and SYT entry shares use the same Share model
- Pre-save validation ensures data integrity
- Indexes optimized for both post and sytEntry queries
- No app code changes needed - backend handles the fix

## Related Endpoints
- `POST /api/syt/:id/share` - Share SYT entry (awards 5 coins)
- `POST /api/posts/:id/share` - Share regular post (existing functionality)
