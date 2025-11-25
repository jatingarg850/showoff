# 📱 Phone.email Web Integration - README

## 🎯 Overview

This integration adds **Sign in with Phone** functionality to your website using Phone.email's web button. Users can verify their phone number with a simple popup and OTP, then get automatically logged into your system.

## ✨ Features

- 🔐 **One-Click Phone Verification** - Users verify phone with popup + OTP
- 🚀 **Auto User Creation** - New users created automatically
- 🎫 **JWT Authentication** - Secure token-based auth
- 💰 **Welcome Bonus** - 50 coins for new users
- 📱 **Global Coverage** - Works with phone numbers worldwide
- 🎨 **Customizable Button** - Customize via admin dashboard
- ⚡ **Fast Integration** - 5 minutes to implement

## 🚀 Quick Start

### 1. Start Server
```bash
cd server
npm start
```

### 2. Open Demo
```
http://localhost:3000/phone-login-demo
```

### 3. Test Login
- Click "Sign in with Phone"
- Enter: +91 9811226924
- Verify with OTP
- Done! ✅

## 📋 Integration Steps

### Step 1: Add Button to Your HTML

```html
<!-- Add this where you want the sign-in button -->
<div class="pe_signin_button" data-client-id="16687983578815655151">
    <script src="https://www.phone.email/sign_in_button_v1.js" async></script>
</div>
```

### Step 2: Add Callback Function

```html
<script>
function phoneEmailListener(userObj) {
    // This is called after successful phone verification
    fetch('/api/auth/phone-email-verify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
            user_json_url: userObj.user_json_url 
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Store auth token
            localStorage.setItem('authToken', data.token);
            
            // Redirect to dashboard
            window.location.href = '/dashboard';
        } else {
            alert('Login failed: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Connection error. Please try again.');
    });
}
</script>
```

### Step 3: That's It!

The backend is already set up and will:
- ✅ Fetch verified phone data
- ✅ Create or login user
- ✅ Generate JWT token
- ✅ Award welcome bonus
- ✅ Return user data

## 🔧 Backend Endpoint

**Already Implemented:** `POST /api/auth/phone-email-verify`

**Request:**
```json
{
  "user_json_url": "https://user.phone.email/user_abc123.json"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Phone verified and user authenticated successfully",
  "user": {
    "userId": "507f1f77bcf86cd799439011",
    "username": "user_226924",
    "displayName": "John Doe",
    "phoneNumber": "9811226924",
    "countryCode": "+91",
    "coinBalance": 50,
    "isPhoneVerified": true
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## 📁 Files

### Created Files
- `server/public/phone-login-demo.html` - Demo page
- `server/controllers/authController.js` - Backend logic (updated)
- `server/routes/authRoutes.js` - API route (updated)
- `test_phone_email_web.js` - Test script
- `test_phone_email_web.bat` - Windows test script

### Documentation
- `PHONE_EMAIL_WEB_INTEGRATION.md` - Complete guide
- `PHONE_EMAIL_QUICK_REFERENCE.md` - Quick reference
- `PHONE_EMAIL_INTEGRATION_COMPLETE.md` - Summary
- `README_PHONE_EMAIL_WEB.md` - This file

## 🧪 Testing

### Method 1: Demo Page (Recommended)
```
http://localhost:3000/phone-login-demo
```

### Method 2: Test Script
```bash
node test_phone_email_web.js
```

### Method 3: Windows Batch
```bash
test_phone_email_web.bat
```

### Method 4: curl
```bash
curl -X POST http://localhost:3000/api/auth/phone-email-verify \
  -H "Content-Type: application/json" \
  -d '{"user_json_url":"https://user.phone.email/user_test.json"}'
```

## 🎨 Customization

### Button Appearance
1. Go to: https://admin.phone.email
2. Navigate to: Button Settings
3. Customize:
   - Button text
   - Colors
   - Size
   - Logo display

### Callback Behavior
Modify `phoneEmailListener()` to:
- Show custom success messages
- Redirect to different pages
- Track analytics events
- Update UI elements
- Store additional data

## 🔐 Security

### ✅ Implemented
- Backend verification of phone data
- JWT token authentication
- Secure user creation
- Phone verification tracking
- Rate limiting

### 🔜 Production Recommendations
- Enable HTTPS (required by Phone.email)
- Add CSRF protection
- Use httpOnly cookies for tokens
- Implement additional rate limiting
- Add request validation
- Set up monitoring and alerts

## 📊 User Flow

```
1. User clicks "Sign in with Phone" button
   ↓
2. Phone.email popup opens
   ↓
3. User enters phone number
   ↓
4. User receives and enters OTP
   ↓
5. Phone.email verifies OTP
   ↓
6. Callback with user_json_url
   ↓
7. Frontend sends URL to backend
   ↓
8. Backend fetches verified data
   ↓
9. User created/logged in
   ↓
10. JWT token returned
   ↓
11. User redirected to dashboard
```

## 🌐 Production Deployment

### 1. Environment Variables
```env
NODE_ENV=production
JWT_SECRET=your-super-secret-key
PHONE_EMAIL_CLIENT_ID=16687983578815655151
```

### 2. Enable HTTPS
Phone.email requires HTTPS in production for security.

### 3. Update CORS
```javascript
app.use(cors({
  origin: ['https://yourdomain.com'],
  credentials: true
}));
```

### 4. Update Client ID
If you have a different production client ID, update it in your HTML.

## 🆘 Troubleshooting

### Button Not Showing
**Problem:** Button doesn't appear on page

**Solutions:**
- Verify client ID is correct
- Check if script is loading (Network tab)
- Look for JavaScript errors in console
- Ensure div has correct class name

### Callback Not Firing
**Problem:** `phoneEmailListener` not called

**Solutions:**
- Ensure function is defined globally (not in module)
- Check function name spelling (case-sensitive)
- Verify no JavaScript errors blocking execution
- Test in different browser

### Backend Error
**Problem:** API returns error

**Solutions:**
- Check server is running: `npm start`
- Verify MongoDB connection
- Check server logs for details
- Test endpoint with Postman

### User Not Created
**Problem:** User not appearing in database

**Solutions:**
- Check User model schema
- Verify all required fields
- Check database connection
- Look for validation errors in logs

## 📞 Support

- **Phone.email Docs:** https://docs.phone.email
- **Admin Dashboard:** https://admin.phone.email
- **Support Email:** support@phone.email
- **Demo Page:** http://localhost:3000/phone-login-demo

## 📚 Additional Resources

### Documentation Files
- `PHONE_EMAIL_WEB_INTEGRATION.md` - Detailed integration guide
- `PHONE_EMAIL_QUICK_REFERENCE.md` - Quick reference card
- `PHONE_EMAIL_INTEGRATION_COMPLETE.md` - Complete summary

### Test Files
- `test_phone_email_web.js` - Node.js test script
- `test_phone_email_web.bat` - Windows batch test

### Demo Files
- `server/public/phone-login-demo.html` - Working demo page

## 🎉 Success!

Your Phone.email web integration is complete and ready to use!

**Next Steps:**
1. ✅ Test the demo page
2. ✅ Integrate into your website
3. ✅ Customize button appearance
4. ✅ Test with real users
5. ✅ Deploy to production

**Questions?** Check the documentation or contact support!

---

**Integration Date:** November 24, 2025
**Status:** ✅ Ready for Production
**Version:** 1.0.0
