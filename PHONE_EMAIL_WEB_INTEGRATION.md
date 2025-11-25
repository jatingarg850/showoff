# Phone.email Web Integration Guide

## Overview
This guide covers the **web-based** Sign in with Phone button integration using Phone.email. This is different from the Flutter app integration and is designed for websites and web applications.

## 🎯 What's Implemented

### 1. Demo Page ✅
- **Location:** `server/public/phone-login-demo.html`
- **URL:** http://localhost:3000/phone-login-demo
- Beautiful, responsive UI with Phone.email button
- Real-time verification status display
- Automatic token storage

### 2. Backend Endpoint ✅
- **Route:** `POST /api/auth/phone-email-verify`
- **Controller:** `phoneEmailVerify` in `authController.js`
- Fetches verified phone data from Phone.email JSON URL
- Creates or logs in user automatically
- Returns JWT token for authentication

### 3. User Flow ✅
```
User clicks button → Phone.email popup → Enter phone → Verify OTP 
→ Callback to your site → Backend fetches data → User logged in
```

## 🚀 Quick Start

### Step 1: Start Your Server
```bash
cd server
npm start
```

### Step 2: Open Demo Page
Navigate to: http://localhost:3000/phone-login-demo

### Step 3: Test Phone Login
1. Click "Sign in with Phone" button
2. Enter phone number: `+91 9811226924`
3. Enter OTP received on phone
4. See verification success!

## 📋 Integration Steps for Your Website

### Frontend Integration (HTML/JS)

Add this code to your HTML page:

```html
<!-- Phone.email Sign In Button -->
<div class="pe_signin_button" data-client-id="16687983578815655151">
    <script src="https://www.phone.email/sign_in_button_v1.js" async></script>
</div>

<script>
// Callback function called after successful verification
function phoneEmailListener(userObj) {
    console.log('Phone verified:', userObj);
    
    // Send user_json_url to your backend
    fetch('/api/auth/phone-email-verify', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            user_json_url: userObj.user_json_url
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Store token
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

### Backend Integration (Already Done!)

The backend endpoint is already implemented:

**Endpoint:** `POST /api/auth/phone-email-verify`

**Request Body:**
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
    "firstName": "John",
    "lastName": "Doe",
    "coinBalance": 50,
    "isPhoneVerified": true
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## 🔧 How It Works

### Step 1: User Clicks Button
The Phone.email button opens a popup where users enter their phone number.

### Step 2: OTP Verification
Phone.email sends an OTP to the user's phone and verifies it.

### Step 3: Callback with JSON URL
After successful verification, Phone.email calls `phoneEmailListener()` with a `user_json_url`.

### Step 4: Backend Fetches Data
Your backend fetches the JSON file from the URL:
```javascript
// Example JSON data from Phone.email
{
  "user_country_code": "+91",
  "user_phone_number": "9811226924",
  "user_first_name": "John",
  "user_last_name": "Doe"
}
```

### Step 5: User Authentication
Backend creates/logs in the user and returns a JWT token.

## 🎨 Customizing the Button

You can customize the button appearance in your Phone.email dashboard:
- Button text
- Button color
- Button size
- Logo display

Visit: https://admin.phone.email → Button Settings

## 🔐 Security Best Practices

### ✅ DO:
- Always fetch user data from backend (never trust frontend data)
- Use HTTPS in production
- Validate the JSON URL format
- Implement rate limiting on the verification endpoint
- Store tokens securely (httpOnly cookies recommended)
- Add CSRF protection

### ❌ DON'T:
- Don't expose API keys in frontend code
- Don't skip backend verification
- Don't trust user_json_url without validation
- Don't store sensitive data in localStorage

## 📱 React Integration Example

```jsx
import React, { useEffect } from 'react';

function PhoneLogin() {
  useEffect(() => {
    // Define callback function
    window.phoneEmailListener = async (userObj) => {
      try {
        const response = await fetch('/api/auth/phone-email-verify', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ user_json_url: userObj.user_json_url })
        });
        
        const data = await response.json();
        
        if (data.success) {
          localStorage.setItem('authToken', data.token);
          window.location.href = '/dashboard';
        }
      } catch (error) {
        console.error('Login error:', error);
      }
    };
  }, []);

  return (
    <div>
      <h1>Sign In</h1>
      <div 
        className="pe_signin_button" 
        data-client-id="16687983578815655151"
      >
        <script 
          src="https://www.phone.email/sign_in_button_v1.js" 
          async 
        />
      </div>
    </div>
  );
}

export default PhoneLogin;
```

## 🧪 Testing

### Test with Demo Page
1. Start server: `npm start`
2. Open: http://localhost:3000/phone-login-demo
3. Click button and verify phone

### Test with Postman
```
POST http://localhost:3000/api/auth/phone-email-verify
Content-Type: application/json

{
  "user_json_url": "https://user.phone.email/user_test123.json"
}
```

### Test with curl
```bash
curl -X POST http://localhost:3000/api/auth/phone-email-verify \
  -H "Content-Type: application/json" \
  -d '{"user_json_url":"https://user.phone.email/user_test123.json"}'
```

## 🌐 Production Deployment

### Environment Variables
Add to your `.env`:
```env
NODE_ENV=production
JWT_SECRET=your-super-secret-jwt-key
PHONE_EMAIL_CLIENT_ID=16687983578815655151
```

### Update Client ID
Replace the client ID in your HTML:
```html
<div class="pe_signin_button" data-client-id="YOUR_PRODUCTION_CLIENT_ID">
```

### Enable HTTPS
Phone.email requires HTTPS in production for security.

### Configure CORS
Update CORS settings in `server.js`:
```javascript
app.use(cors({
  origin: ['https://yourdomain.com'],
  credentials: true
}));
```

## 📊 Monitoring & Analytics

### Track Phone Logins
Add analytics to your callback:
```javascript
function phoneEmailListener(userObj) {
  // Track event
  gtag('event', 'phone_login', {
    'event_category': 'authentication',
    'event_label': 'phone_email'
  });
  
  // Continue with verification...
}
```

### Monitor Backend
Check logs for verification attempts:
```bash
# View logs
tail -f server.log | grep "Phone.email"
```

## 🆚 Comparison: Web vs Flutter Integration

| Feature | Web Integration | Flutter Integration |
|---------|----------------|---------------------|
| **UI** | Phone.email hosted button | Custom Flutter UI |
| **OTP Delivery** | Phone.email handles | Phone.email API |
| **Verification** | Automatic popup | Manual API calls |
| **Customization** | Limited (dashboard) | Full control |
| **Best For** | Websites, quick setup | Mobile apps, custom UX |

## 🔗 Your Credentials

```
Client ID: 16687983578815655151
API Key: I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf
Test Phone: +91 9811226924
Admin Dashboard: https://admin.phone.email
```

## 📚 Additional Resources

- **Phone.email Docs:** https://docs.phone.email
- **Admin Dashboard:** https://admin.phone.email
- **Support:** support@phone.email
- **Demo Page:** http://localhost:3000/phone-login-demo

## 🐛 Troubleshooting

### Button Not Showing
- Check if script is loaded: `console.log(window.PhoneEmail)`
- Verify client ID is correct
- Check browser console for errors

### Callback Not Firing
- Ensure `phoneEmailListener` is defined globally
- Check function name spelling (case-sensitive)
- Verify no JavaScript errors on page

### Backend Error
- Check server logs: `npm start`
- Verify endpoint URL is correct
- Test with Postman first

### User Not Created
- Check MongoDB connection
- Verify User model has required fields
- Check server logs for errors

## ✅ Integration Checklist

- [x] Backend endpoint created (`/api/auth/phone-email-verify`)
- [x] Demo page created (`/phone-login-demo`)
- [x] User creation/login logic implemented
- [x] JWT token generation working
- [x] Phone verification status tracked
- [ ] Add to your production website
- [ ] Test with real users
- [ ] Configure production client ID
- [ ] Enable HTTPS
- [ ] Add analytics tracking
- [ ] Set up monitoring

## 🎉 Summary

You now have a complete Phone.email web integration! The system:
- ✅ Displays a professional sign-in button
- ✅ Handles phone verification automatically
- ✅ Creates/logs in users securely
- ✅ Returns JWT tokens for authentication
- ✅ Works with your existing user system

**Next Steps:**
1. Test the demo page: http://localhost:3000/phone-login-demo
2. Integrate the button into your website
3. Customize the button appearance
4. Deploy to production with HTTPS

Need help? Check the troubleshooting section or contact Phone.email support!
