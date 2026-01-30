# Maintenance Mode - Quick Reference

## Quick Commands

### Enable Maintenance Mode
```bash
curl -X POST http://localhost:5000/coddyIO \
  -H "Content-Type: application/json" \
  -d '{"password":"jatingarg"}'
```

### Check Status
```bash
curl http://localhost:5000/coddyIO/status
```

### Disable Maintenance Mode
```bash
curl -X POST http://localhost:5000/coddyIO \
  -H "Content-Type: application/json" \
  -d '{"password":"paid"}'
```

## Passwords

| Action | Password |
|--------|----------|
| Enable | `jatingarg` |
| Disable | `paid` |

## What Gets Blocked

| Route | Status |
|-------|--------|
| `/api/*` | ❌ Blocked (503) |
| `/admin` | ✅ Allowed |
| `/coddyIO` | ✅ Allowed |
| Web pages | ❌ Blocked (maintenance page) |

## Response Examples

### Enable Success
```json
{
  "success": true,
  "message": "Maintenance mode ENABLED",
  "maintenanceMode": true,
  "timestamp": "2024-01-26T10:30:00.000Z"
}
```

### API Request During Maintenance
```json
{
  "success": false,
  "message": "Site is under maintenance. Please try again later.",
  "maintenanceMode": true
}
```

### Invalid Password
```json
{
  "success": false,
  "message": "Invalid password"
}
```

## Files

- `server/controllers/maintenanceController.js` - Logic
- `server/routes/maintenanceRoutes.js` - Routes
- `server/views/maintenance.ejs` - UI Page
- `test_maintenance_mode.js` - Test script

## Test It

```bash
node test_maintenance_mode.js
```

## Emergency Reset

Restart server - maintenance mode resets to OFF automatically.
