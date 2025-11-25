# Phone.email Integration - Quick Reference

## 🚀 Quick Start

### Test Demo Page
```bash
cd server
npm start
# Open: http://localhost:3000/phone-login-demo
```

## 📋 Your Credentials
```
Client ID: 16687983578815655151
API Key: I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf
Test Phone: +91 9811226924
Dashboard: https://admin.phone.email
```

## 🔧 Two Integration Methods

### Method 1: Web Button (HTML/JS)
**Best for:** Websites, web apps, quick setup

**Add to HTML:**
```html
<div class="pe_signin_button" data-client-id="16687983578815655151">
    <script src="https://www.phone.email/sign_in_button_v1.js" async></script>
</div>

<script>
function phoneEmailListener(userObj) {
    fetch('/api/auth/phone-email-verify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ user_json_url: userObj.user_json_url })
    })
    .then(res => res.json())
    .then(data => {
        localStorage.setItem('authToken', data.token);
        window.location.href = '/dashboard';
    });
}
</script>
```

**Backend Endpoint:** `POST /api/auth/phone-email-verify` ✅ Already implemented!

---

### Method 2: Flutter App (Direct API)
**Best for:** Mobile apps, custom UI

**Already implemented in:**
- `apps/lib/auth/signin_phone_screen.dart`
- `apps/lib/services/phone_auth_service.dart`

**Backend Endpoint:** `POST /api/auth/phone-login` ✅ Already implemented!

## 📡 API Endpoints

### Web Button Verification
```
POST /api/auth/phone-email-verify

Body:
{
  "user_json_url": "https://user.phone.email/user_abc123.json"
}

Response:
{
  "success": true,
  "user": { ... },
  "token": "eyJhbGc..."
}
```

### Flutter App Login
```
POST /api/auth/phone-login

Body:
{
  "phoneNumber": "9811226924",
  "countryCode": "+91",
  "firstName": "John",
  "lastName": "Doe"
}

Response:
{
  "success": true,
  "data": {
    "user": { ... },
    "token": "eyJhbGc..."
  }
}
```

## 🎯 What Happens Automatically

When a user verifies their phone:
1. ✅ User account created (if new)
2. ✅ Phone number verified and stored
3. ✅ JWT token generated
4. ✅ 50 coins welcome bonus awarded
5. ✅ Username auto-generated
6. ✅ Last login timestamp updated

## 📁 Files Created

### Web Integration
- `server/public/phone-login-demo.html` - Demo page
- `server/controllers/authController.js` - `phoneEmailVerify()` function
- `server/routes/authRoutes.js` - Route added
- `PHONE_EMAIL_WEB_INTEGRATION.md` - Full guide

### Flutter Integration (Already Exists)
- `apps/lib/auth/signin_phone_screen.dart`
- `apps/lib/auth/otp_screen.dart`
- `apps/lib/services/phone_auth_service.dart`
- `apps/lib/config/phone_email_config.dart`

## 🧪 Testing

### Test Web Button
1. Open: http://localhost:3000/phone-login-demo
2. Click "Sign in with Phone"
3. Enter: +91 9811226924
4. Verify OTP

### Test Flutter App
```bash
cd apps
flutter run
# Navigate to: Sign In → Sign In with Phone
```

### Test API with curl
```bash
curl -X POST http://localhost:3000/api/auth/phone-email-verify \
  -H "Content-Type: application/json" \
  -d '{"user_json_url":"https://user.phone.email/user_test.json"}'
```

## 🎨 Customize Button

Visit: https://admin.phone.email → Button Settings
- Change button text
- Modify colors
- Adjust size
- Toggle logo

## 🔐 Security Checklist

- [x] Backend fetches user data (not frontend)
- [x] JWT tokens for authentication
- [x] Phone verification status tracked
- [ ] Enable HTTPS in production
- [ ] Add rate limiting
- [ ] Implement CSRF protection
- [ ] Use httpOnly cookies

## 📊 User Flow

```
┌─────────────┐
│ User clicks │
│   button    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Phone.email │
│   popup     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Enter phone │
│ & verify OTP│
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Callback   │
│ with JSON   │
│     URL     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Backend    │
│  fetches    │
│    data     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ User logged │
│     in!     │
└─────────────┘
```

## 🆘 Common Issues

### Button not showing
→ Check client ID, verify script loaded

### Callback not firing
→ Ensure `phoneEmailListener` is global

### Backend error
→ Check server logs, verify MongoDB connection

### User not created
→ Check User model, verify required fields

## 📞 Support

- **Docs:** https://docs.phone.email
- **Dashboard:** https://admin.phone.email
- **Email:** support@phone.email
- **Demo:** http://localhost:3000/phone-login-demo

## 🎉 You're All Set!

Both integration methods are ready:
- ✅ Web button integration (HTML/JS)
- ✅ Flutter app integration (Mobile)
- ✅ Backend endpoints working
- ✅ User creation automated
- ✅ JWT authentication enabled

**Start testing now:** http://localhost:3000/phone-login-demo
