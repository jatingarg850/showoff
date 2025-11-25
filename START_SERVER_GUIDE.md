# 🚀 Server Startup Guide

## Quick Start

### 1. Start the Server

```bash
cd server
npm start
```

You should see:
```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║           ShowOff.life API Server                         ║
║                                                           ║
║   Server running on port 3000                             ║
║   Environment: development                                ║
║   WebSocket: ✅ Enabled                                   ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

### 2. Verify Server is Running

**Option 1: Browser**
```
http://localhost:3000/health
```

**Option 2: Test Script**
```bash
node test_server_health.js
```

### 3. Test Phone.email Integration

```
http://localhost:3000/phone-login-demo
```

## 🐛 Troubleshooting

### Error: "Cannot connect to server"

**Problem:** Server is not running

**Solution:**
```bash
cd server
npm start
```

### Error: "Port 3000 already in use"

**Problem:** Another process is using port 3000

**Solution (Windows):**
```bash
# Find process using port 3000
netstat -ano | findstr :3000

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F

# Or use a different port
set PORT=3001
npm start
```

### Error: "MongoDB connection failed"

**Problem:** MongoDB is not running or connection string is wrong

**Solution:**
1. Check `.env` file has correct MongoDB URI
2. Start MongoDB if running locally
3. Check MongoDB Atlas connection if using cloud

**Check .env file:**
```env
MONGODB_URI=mongodb://localhost:27017/showofflife
# or
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/dbname
```

### Error: "Module not found"

**Problem:** Dependencies not installed

**Solution:**
```bash
cd server
npm install
npm start
```

### Error: "Unexpected end of JSON input"

**Problem:** Server is returning HTML error page instead of JSON

**Possible Causes:**
1. Server crashed or not running
2. Route not registered correctly
3. Controller function has an error
4. MongoDB connection failed

**Solution:**
```bash
# Check server logs
cd server
npm start

# Look for errors in the console
# Common errors:
# - MongoDB connection failed
# - Missing environment variables
# - Port already in use
```

## ✅ Verification Checklist

Run these checks to ensure everything is working:

### 1. Server Health
```bash
node test_server_health.js
```

Expected output:
```
✅ Health endpoint: OK
✅ Endpoint exists
✅ SERVER IS HEALTHY!
```

### 2. Demo Page
```
http://localhost:3000/phone-login-demo
```

Should show:
- Sign in with Phone button
- Test credentials
- No error messages

### 3. API Endpoint
```bash
curl -X POST http://localhost:3000/api/auth/phone-email-verify \
  -H "Content-Type: application/json" \
  -d "{}"
```

Expected response:
```json
{
  "success": false,
  "message": "user_json_url is required"
}
```

This confirms the endpoint is working (400 error is expected without data).

## 🔍 Common Issues

### Issue 1: Button Shows but Callback Fails

**Symptoms:**
- Phone.email button appears
- Can enter phone and verify OTP
- Error appears after verification

**Cause:** Server endpoint issue

**Fix:**
1. Check server is running: `http://localhost:3000/health`
2. Check server logs for errors
3. Verify MongoDB connection
4. Run health check: `node test_server_health.js`

### Issue 2: Button Doesn't Appear

**Symptoms:**
- Page loads but no button
- Console shows script errors

**Cause:** Phone.email script not loading

**Fix:**
1. Check internet connection
2. Verify client ID is correct
3. Check browser console for errors
4. Try different browser

### Issue 3: Server Starts but Crashes

**Symptoms:**
- Server starts then immediately stops
- Error messages in console

**Common Causes:**
1. **MongoDB connection failed**
   - Check MongoDB is running
   - Verify connection string in `.env`

2. **Port already in use**
   - Change port or kill existing process

3. **Missing dependencies**
   - Run `npm install` in server directory

4. **Environment variables missing**
   - Check `.env` file exists
   - Verify all required variables are set

## 📋 Required Environment Variables

Create/check `server/.env`:

```env
# Server
PORT=3000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/showofflife

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production

# Phone.email (optional for backend)
PHONE_EMAIL_CLIENT_ID=16687983578815655151
PHONE_EMAIL_API_KEY=I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf

# Other services (if needed)
# AWS, Stripe, etc.
```

## 🎯 Quick Commands

### Start Server
```bash
cd server && npm start
```

### Check Health
```bash
node test_server_health.js
```

### Test Demo
```
http://localhost:3000/phone-login-demo
```

### View Logs
```bash
cd server
npm start
# Watch console output
```

### Restart Server
```bash
# Press Ctrl+C to stop
# Then run again
npm start
```

## 📞 Still Having Issues?

### Check These Files:

1. **server/server.js** - Main server file
2. **server/routes/authRoutes.js** - Auth routes
3. **server/controllers/authController.js** - Auth logic
4. **server/.env** - Environment variables
5. **server/package.json** - Dependencies

### Run Diagnostics:

```bash
# 1. Check Node version
node --version
# Should be v14 or higher

# 2. Check npm version
npm --version

# 3. Check if port 3000 is available
netstat -ano | findstr :3000

# 4. Test MongoDB connection
# (if using local MongoDB)
mongo --eval "db.version()"

# 5. Check server health
node test_server_health.js
```

## ✅ Success Indicators

When everything is working correctly:

1. **Server starts without errors**
   ```
   ✅ Server running on port 3000
   ✅ MongoDB connected
   ✅ WebSocket enabled
   ```

2. **Health check passes**
   ```
   ✅ Health endpoint: OK
   ✅ Endpoint exists
   ```

3. **Demo page loads**
   - Button appears
   - No error messages
   - Can click and test

4. **Phone verification works**
   - Button opens popup
   - Can enter phone
   - OTP is sent
   - Verification succeeds
   - User data displayed

## 🎉 Ready to Go!

Once all checks pass, you're ready to:
1. Test the phone login flow
2. Integrate into your website
3. Customize the button
4. Deploy to production

---

**Need more help?** Check the other documentation files:
- `README_PHONE_EMAIL_WEB.md` - Integration guide
- `PHONE_EMAIL_QUICK_REFERENCE.md` - Quick reference
- `PHONE_EMAIL_WEB_INTEGRATION.md` - Complete guide
