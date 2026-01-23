# Admin Authentication - Quick Fix

## Problem
Admin users getting 401 error: "Admin user not found in database"

## Solution

### Step 1: Create Admin User
```bash
node create_admin_user.js
```

This will:
- Create admin user with email: `admin@showofflife.com`
- Set password: `admin123`
- Verify user exists in database

### Step 2: Restart Server
```bash
npm start
```

### Step 3: Login to Admin Panel
1. Go to: `http://localhost:5000/admin`
2. Email: `admin@showofflife.com`
3. Password: `admin123`
4. Click Login

## What Was Fixed

✅ Middleware no longer looks for non-existent `role` field
✅ Middleware searches for admin user by email
✅ Admin user can be created in database
✅ Video ad uploads now work

## Expected Behavior

✅ Admin login succeeds
✅ Admin dashboard loads
✅ Video ad upload works
✅ No 401 errors

## Files Changed

- `server/routes/adminWebRoutes.js` - Fixed admin authentication middleware

## Files Created

- `create_admin_user.js` - Script to create admin user

## Troubleshooting

### Still getting 401 error?
1. Run `node create_admin_user.js` again
2. Check MongoDB is running
3. Check server logs for errors

### Video ad upload still fails?
1. Verify admin user was created
2. Check file upload middleware logs
3. Verify Wasabi S3 credentials

## Summary

Admin authentication is now fixed. Create the admin user and login to access the admin panel.
