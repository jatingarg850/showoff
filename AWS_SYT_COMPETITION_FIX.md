# AWS SYT Competition E11000 Error Fix

## Problem
When trying to create a new SYT competition in AWS, you get:
```
E11000 duplicate key error collection: showoff.competitionsettings index: type_1 dup key: { type: "weekly" }
```

## Root Cause
The AWS MongoDB database has an old unique index on the `type` field that prevents multiple competitions of the same type. This index needs to be removed.

## Solution

### Step 1: SSH into AWS Server
```bash
ssh -i your-key.pem ubuntu@your-aws-ip
```

### Step 2: Navigate to Server Directory
```bash
cd ~/showoff/server
```

### Step 3: Run the Fix Script
```bash
node fix_aws_index.js
```

Expected output:
```
🔗 Connecting to MongoDB...
✅ Connected to MongoDB

📋 Current indexes:
   1. _id_: {"_id":1}
   2. type_1: {"type":1}
   3. type_1_isActive_1: {"type":1,"isActive":1}
   ...

🔄 Attempting to remove unique index on type...
✅ Successfully dropped unique index on type field

📋 Indexes after fix:
   1. _id_: {"_id":1}
   2. type_1_isActive_1: {"type":1,"isActive":1}
   ...

✅ Index fix completed successfully!
```

### Step 4: Restart the Server
```bash
pm2 restart showoff-server
```

### Step 5: Verify
Check the logs:
```bash
pm2 logs showoff-server
```

You should see the server starting without E11000 errors.

## Testing

1. Go to AWS admin panel: `https://your-aws-domain/admin/talent`
2. Click "Create Competition"
3. Fill in the form:
   - Competition Type: Weekly
   - Title: Test Competition
   - Start Date: Today
   - End Date: 7 days from today
4. Click "Save Competition"

It should now work without the E11000 error.

## What This Fixes

- ✅ Allows multiple competitions of the same type (as long as dates don't overlap)
- ✅ Enables creating new weekly/monthly/quarterly competitions
- ✅ Maintains data integrity with date-based validation

## Important Notes

- The fix only removes the old unique index
- The model already has proper validation to prevent overlapping competitions
- You can now create multiple competitions of the same type with different date ranges
- Only one competition per type can be active at a time (enforced by application logic)

## If You Still Get Errors

1. Check if the index was actually removed:
   ```bash
   node -e "require('dotenv').config(); const mongoose = require('mongoose'); (async () => { await mongoose.connect(process.env.MONGODB_URI); const indexes = await mongoose.connection.db.collection('competitionsettings').listIndexes().toArray(); console.log(JSON.stringify(indexes, null, 2)); await mongoose.connection.close(); })();"
   ```

2. If `type_1` index still exists, manually drop it:
   ```bash
   node -e "require('dotenv').config(); const mongoose = require('mongoose'); (async () => { await mongoose.connect(process.env.MONGODB_URI); await mongoose.connection.db.collection('competitionsettings').dropIndex('type_1'); console.log('Index dropped'); await mongoose.connection.close(); })();"
   ```

3. Restart the server again:
   ```bash
   pm2 restart showoff-server
   ```
