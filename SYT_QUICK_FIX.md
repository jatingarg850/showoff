# SYT Entries Not Showing - Quick Fix

## Problem
Uploaded SYT reel but talent screen is empty.

## Quick Solution

### Option 1: Automatic Fix (Recommended)
```bash
node auto_fix_syt.js
```
This will automatically:
- ✅ Create competition if needed
- ✅ Fix period ID mismatches
- ✅ Approve and activate entries
- ✅ Verify everything works

### Option 2: Manual Fix

**Step 1: Check what's wrong**
```bash
node check_syt_database.js
```

**Step 2: Create competition**
1. Go to http://localhost:5000/admin/login
2. Login: admin@showofflife.com / admin123
3. Click "Talent/SYT"
4. Click "Create Competition"
5. Fill form and save

**Step 3: Restart Flutter app**

## Test It Works
```bash
node test_syt_entries.js
```

Should show: `✅ SUCCESS: Entries are being returned!`

## Still Not Working?

Run diagnostic and share output:
```bash
node check_syt_database.js > diagnosis.txt
```

## Files Created
- `auto_fix_syt.js` - Automatic fix script
- `check_syt_database.js` - Diagnostic tool
- `test_syt_entries.js` - API tester
- `SYT_ENTRIES_FIX_SUMMARY.md` - Detailed guide
