# SYT Admin Panel Authentication Fix

## Issue
The admin panel was getting 401 Unauthorized errors when trying to access competition management endpoints because:
- The API routes used JWT token authentication (`protect` + `adminOnly` middleware)
- The web admin panel uses session-based authentication
- JavaScript was trying to use `localStorage.getItem('adminToken')` which doesn't exist

## Solution

### 1. Added Session-Based Admin Middleware
**File: `server/middleware/auth.js`**

Added new middleware for session-based admin authentication:
```javascript
exports.checkAdminSession = (req, res, next) => {
  if (req.session && req.session.isAdmin) {
    next();
  } else {
    return res.status(401).json({
      success: false,
      message: 'Admin session required',
    });
  }
};
```

### 2. Created Parallel Admin Routes
**File: `server/routes/sytRoutes.js`**

Added session-based routes alongside JWT routes:
```javascript
// JWT-based routes (for mobile app API)
router.get('/admin/competitions', protect, adminOnly, getCompetitions);
router.post('/admin/competitions', protect, adminOnly, createCompetition);
router.put('/admin/competitions/:id', protect, adminOnly, updateCompetition);
router.delete('/admin/competitions/:id', protect, adminOnly, deleteCompetition);

// Session-based routes (for web admin panel)
router.get('/admin-web/competitions', checkAdminSession, getCompetitions);
router.post('/admin-web/competitions', checkAdminSession, createCompetition);
router.put('/admin-web/competitions/:id', checkAdminSession, updateCompetition);
router.delete('/admin-web/competitions/:id', checkAdminSession, deleteCompetition);
```

### 3. Updated Frontend to Use Session Routes
**File: `server/views/admin/talent.ejs`**

Changed all fetch calls to:
- Use `/api/syt/admin-web/competitions` instead of `/api/syt/admin/competitions`
- Include `credentials: 'include'` to send session cookies
- Remove JWT token headers

**Before:**
```javascript
const response = await fetch('/api/syt/admin/competitions', {
    headers: { 'Authorization': 'Bearer ' + localStorage.getItem('adminToken') }
});
```

**After:**
```javascript
const response = await fetch('/api/syt/admin-web/competitions', {
    credentials: 'include'
});
```

## Testing

1. **Login to Admin Panel**
   ```
   http://localhost:5000/admin/login
   Email: admin@showofflife.com
   Password: admin123
   ```

2. **Navigate to Talent Management**
   ```
   http://localhost:5000/admin/talent
   ```

3. **Verify Competition Management Works**
   - Should see "Competition Management" section
   - Click "Create Competition" button
   - Fill in form and save
   - Competition should appear in list
   - No 401 errors in console

## Routes Summary

### For Web Admin Panel (Session Auth)
- `GET /api/syt/admin-web/competitions` - List competitions
- `POST /api/syt/admin-web/competitions` - Create competition
- `PUT /api/syt/admin-web/competitions/:id` - Update competition
- `DELETE /api/syt/admin-web/competitions/:id` - Delete competition

### For Mobile App API (JWT Auth)
- `GET /api/syt/admin/competitions` - List competitions
- `POST /api/syt/admin/competitions` - Create competition
- `PUT /api/syt/admin/competitions/:id` - Update competition
- `DELETE /api/syt/admin/competitions/:id` - Delete competition

Both sets of routes use the same controller functions, just different authentication middleware.

## Files Modified
1. `server/middleware/auth.js` - Added `checkAdminSession` middleware
2. `server/routes/sytRoutes.js` - Added session-based admin routes
3. `server/views/admin/talent.ejs` - Updated fetch calls to use session routes

## Status
✅ Authentication fixed
✅ Admin panel can now manage competitions
✅ Session-based auth working correctly
✅ No more 401 errors
