# Secret Maintenance Mode - Complete Guide

## Overview
A secret maintenance mode system that allows you to shut down the site and put it in maintenance mode. Only accessible via the secret route `/coddyIO`.

## Features

✅ **Secret Route:** `/coddyIO` - Hidden from normal navigation
✅ **Password Protected:** Two passwords for enable/disable
✅ **API Blocking:** All API requests return 503 error in maintenance mode
✅ **Admin Access:** Admin panel remains accessible during maintenance
✅ **Beautiful UI:** Professional maintenance page with auto-refresh
✅ **Status Endpoint:** Check maintenance mode status anytime
✅ **Logging:** All maintenance mode changes are logged

## Passwords

### Enable Maintenance Mode
**Password:** `jatingarg`
- Turns ON maintenance mode
- Blocks all API and web requests (except admin)
- Shows maintenance page to users

### Disable Maintenance Mode
**Password:** `paid`
- Turns OFF maintenance mode
- Site returns to normal operation
- All requests are processed normally

## API Endpoints

### 1. Toggle Maintenance Mode
```
POST /coddyIO
Content-Type: application/json

Body:
{
  "password": "jatingarg"  // or "paid"
}

Response (Enable):
{
  "success": true,
  "message": "Maintenance mode ENABLED",
  "maintenanceMode": true,
  "timestamp": "2024-01-26T10:30:00.000Z"
}

Response (Disable):
{
  "success": true,
  "message": "Maintenance mode DISABLED",
  "maintenanceMode": false,
  "timestamp": "2024-01-26T10:35:00.000Z"
}

Response (Invalid Password):
{
  "success": false,
  "message": "Invalid password"
}
```

### 2. Check Maintenance Status
```
GET /coddyIO/status

Response:
{
  "success": true,
  "maintenanceMode": true,
  "timestamp": "2024-01-26T10:30:00.000Z"
}
```

## Usage Examples

### Using cURL

**Enable Maintenance Mode:**
```bash
curl -X POST http://localhost:5000/coddyIO \
  -H "Content-Type: application/json" \
  -d '{"password":"jatingarg"}'
```

**Check Status:**
```bash
curl http://localhost:5000/coddyIO/status
```

**Disable Maintenance Mode:**
```bash
curl -X POST http://localhost:5000/coddyIO \
  -H "Content-Type: application/json" \
  -d '{"password":"paid"}'
```

### Using JavaScript/Fetch

**Enable Maintenance Mode:**
```javascript
fetch('http://localhost:5000/coddyIO', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ password: 'jatingarg' })
})
.then(res => res.json())
.then(data => console.log(data));
```

**Check Status:**
```javascript
fetch('http://localhost:5000/coddyIO/status')
  .then(res => res.json())
  .then(data => console.log(data));
```

**Disable Maintenance Mode:**
```javascript
fetch('http://localhost:5000/coddyIO', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ password: 'paid' })
})
.then(res => res.json())
.then(data => console.log(data));
```

### Using Postman

1. Create a new POST request
2. URL: `http://localhost:5000/coddyIO`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON):
   ```json
   {
     "password": "jatingarg"
   }
   ```
5. Send request

## What Happens in Maintenance Mode

### Blocked Requests
- ❌ All `/api/*` requests return 503 error
- ❌ All web requests show maintenance page
- ❌ Mobile app requests fail with maintenance message

### Allowed Requests
- ✅ `/coddyIO` - Maintenance mode endpoints
- ✅ `/admin` - Admin panel remains accessible
- ✅ `/admin/assets` - Admin assets load normally

### User Experience
- Users see a beautiful maintenance page
- Page auto-refreshes every 30 seconds
- Shows "Under Maintenance" message
- Displays social media links
- Shows last updated timestamp

### API Response
```json
{
  "success": false,
  "message": "Site is under maintenance. Please try again later.",
  "maintenanceMode": true
}
```

## Files Created

1. **server/controllers/maintenanceController.js**
   - Main maintenance mode logic
   - Password validation
   - Middleware for checking maintenance status

2. **server/routes/maintenanceRoutes.js**
   - Routes for maintenance endpoints
   - `/coddyIO` - Toggle maintenance
   - `/coddyIO/status` - Check status

3. **server/views/maintenance.ejs**
   - Beautiful maintenance page
   - Auto-refresh functionality
   - Social media links
   - Professional UI

4. **test_maintenance_mode.js**
   - Test script for all functionality
   - Demonstrates enable/disable/check

## Testing

### Run Test Script
```bash
node test_maintenance_mode.js
```

This will:
1. Enable maintenance mode
2. Check status
3. Try to access API (should fail)
4. Disable maintenance mode
5. Check status again

### Manual Testing

1. **Enable Maintenance:**
   ```bash
   curl -X POST http://localhost:5000/coddyIO \
     -H "Content-Type: application/json" \
     -d '{"password":"jatingarg"}'
   ```

2. **Try API Request (should fail):**
   ```bash
   curl http://localhost:5000/api/auth/me
   ```
   Response: 503 error

3. **Check Status:**
   ```bash
   curl http://localhost:5000/coddyIO/status
   ```
   Response: `maintenanceMode: true`

4. **Disable Maintenance:**
   ```bash
   curl -X POST http://localhost:5000/coddyIO \
     -H "Content-Type: application/json" \
     -d '{"password":"paid"}'
   ```

5. **Try API Request (should work):**
   ```bash
   curl http://localhost:5000/api/auth/me
   ```
   Response: Normal response

## Security Notes

⚠️ **Important Security Considerations:**

1. **Passwords are hardcoded** - In production, consider:
   - Using environment variables
   - Adding IP whitelist
   - Adding rate limiting
   - Adding logging/alerts

2. **Route is public** - Anyone can try to access it
   - Consider adding IP restrictions
   - Add rate limiting to prevent brute force
   - Monitor failed attempts

3. **No authentication required** - The route doesn't require login
   - This is intentional for emergency access
   - But consider adding additional security layers

## Production Recommendations

1. **Change Passwords:**
   - Update `jatingarg` and `paid` to strong, unique passwords
   - Store in environment variables

2. **Add IP Whitelist:**
   ```javascript
   const allowedIPs = ['YOUR_IP_ADDRESS'];
   if (!allowedIPs.includes(req.ip)) {
     return res.status(403).json({ success: false });
   }
   ```

3. **Add Rate Limiting:**
   ```javascript
   const maintenanceLimiter = rateLimit({
     windowMs: 15 * 60 * 1000,
     max: 5 // 5 attempts per 15 minutes
   });
   router.post('/coddyIO', maintenanceLimiter, toggleMaintenanceMode);
   ```

4. **Add Logging:**
   - Log all maintenance mode changes
   - Send alerts to admin email
   - Track who enabled/disabled maintenance

5. **Add Confirmation:**
   - Require two-factor authentication
   - Send confirmation email before enabling
   - Add time-based auto-disable

## Troubleshooting

### Maintenance mode won't enable
- Check password is exactly `jatingarg`
- Verify server is running
- Check server logs for errors

### API still works in maintenance mode
- Restart server to apply changes
- Check middleware is properly loaded
- Verify route order in server.js

### Admin panel not accessible
- Admin routes should bypass maintenance check
- Verify `/admin` path is in allowed list
- Check middleware order

### Maintenance page not showing
- Verify `views/maintenance.ejs` exists
- Check EJS view engine is configured
- Verify CSS is loading correctly

## Logs

When maintenance mode is toggled, you'll see:
```
🔧 MAINTENANCE MODE ENABLED
✅ MAINTENANCE MODE DISABLED
⚠️ Invalid maintenance mode password attempt
```

## Emergency Disable

If you forget the password or need emergency access:

1. **Restart the server** - Maintenance mode resets to OFF
2. **Edit maintenanceController.js** - Change `maintenanceMode = false` at top
3. **Contact admin** - Have backup admin with access

## Summary

This secret maintenance mode system provides:
- ✅ Easy on/off toggle
- ✅ Password protected
- ✅ Beautiful user-facing page
- ✅ Admin access during maintenance
- ✅ API blocking
- ✅ Status checking
- ✅ Professional appearance
