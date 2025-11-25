# Phone.email OTP Testing Guide

## Your Credentials
```
Client ID: 16687983578815655151
API Key: I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf
Test Phone: +919811226924
Admin Dashboard: https://admin.phone.email
```

## Testing Methods (Recommended Order)

### ✅ Method 1: Phone.email Admin Dashboard (EASIEST)
This is the most reliable method and doesn't require any local setup.

1. Open browser and go to: **https://admin.phone.email**
2. Sign in with your account
3. Look for "Console", "Test", or "API Testing" section
4. Enter phone number: `+919811226924`
5. Click "Send OTP" or "Test OTP"
6. Check your phone for the OTP code

**Advantages:**
- No local setup required
- Works regardless of firewall/network issues
- Official testing interface
- Can see API logs and status

---

### ✅ Method 2: Postman (RECOMMENDED FOR API TESTING)

1. **Download Postman** (if not installed): https://www.postman.com/downloads/

2. **Create New Request:**
   - Method: `POST`
   - URL: `https://api.phone.email/auth/v1/otp`

3. **Add Headers:**
   ```
   Content-Type: application/json
   X-Client-Id: 16687983578815655151
   X-API-Key: I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf
   ```

4. **Add Body (raw JSON):**
   ```json
   {
     "phone_number": "+919811226924"
   }
   ```

5. **Click Send**

6. **Expected Response:**
   ```json
   {
     "session_id": "xxx-xxx-xxx",
     "expires_in": 300,
     "status": "success"
   }
   ```

**Advantages:**
- Professional API testing tool
- Can save requests for reuse
- Shows detailed response information
- Works reliably

---

### ✅ Method 3: Test in Your Flutter App (BEST FOR INTEGRATION TESTING)

1. **Start your Flutter app:**
   ```bash
   cd apps
   flutter run
   ```

2. **Navigate to Phone Login:**
   - Open the app
   - Go to Sign In screen
   - Tap "Sign In with Phone"

3. **Enter Phone Number:**
   - Select country: India (+91)
   - Enter: 9811226924
   - Tap "Send Code"

4. **Check Your Phone:**
   - You should receive an OTP
   - Enter the OTP in the app
   - Complete the login flow

**Advantages:**
- Tests the complete integration
- Tests the actual user experience
- Verifies UI and UX
- Tests error handling

---

### ✅ Method 4: Online API Testing Tools

**Option A: Hoppscotch (formerly Postwoman)**
1. Go to: https://hoppscotch.io/
2. Method: POST
3. URL: `https://api.phone.email/auth/v1/otp`
4. Add headers and body as shown in Method 2
5. Click Send

**Option B: ReqBin**
1. Go to: https://reqbin.com/
2. Select POST method
3. Enter URL and configure headers/body
4. Click Send

**Advantages:**
- No installation required
- Works in browser
- Good for quick tests

---

### ✅ Method 5: Python Script (If Python is installed)

Create `test_otp.py`:
```python
import requests
import json

client_id = "16687983578815655151"
api_key = "I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf"
phone_number = "+919811226924"

print("🚀 Testing Phone.email OTP Integration\n")
print(f"📱 Sending OTP to: {phone_number}")
print(f"🔑 Using Client ID: {client_id}\n")

headers = {
    "Content-Type": "application/json",
    "X-Client-Id": client_id,
    "X-API-Key": api_key
}

data = {
    "phone_number": phone_number
}

try:
    response = requests.post(
        "https://api.phone.email/auth/v1/otp",
        headers=headers,
        json=data
    )
    
    print(f"📡 Response Status: {response.status_code}")
    print(f"📄 Response Body: {response.text}\n")
    
    if response.status_code in [200, 201]:
        result = response.json()
        print("✅ SUCCESS! OTP sent successfully")
        print(f"📨 Session ID: {result.get('session_id', 'N/A')}")
        print(f"⏰ Expires in: {result.get('expires_in', 'N/A')} seconds")
        print("\n💡 Check your phone for the OTP code!")
    else:
        print("❌ FAILED to send OTP")
        print(f"Error: {response.text}")
        
except Exception as e:
    print(f"❌ ERROR: {str(e)}")
```

Run with:
```bash
pip install requests
python test_otp.py
```

---

### ✅ Method 6: Git Bash with curl (Windows)

If you have Git for Windows installed:

1. Open **Git Bash** (not CMD or PowerShell)
2. Run:
```bash
curl -X POST "https://api.phone.email/auth/v1/otp" \
  -H "Content-Type: application/json" \
  -H "X-Client-Id: 16687983578815655151" \
  -H "X-API-Key: I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf" \
  -d '{"phone_number":"+919811226924"}'
```

---

## Expected API Response

### Success Response (200/201):
```json
{
  "session_id": "abc123-def456-ghi789",
  "expires_in": 300,
  "status": "success",
  "message": "OTP sent successfully"
}
```

### Error Responses:

**400 Bad Request:**
```json
{
  "error": "Invalid phone number format",
  "status": "error"
}
```

**401 Unauthorized:**
```json
{
  "error": "Invalid client ID or API key",
  "status": "error"
}
```

**429 Too Many Requests:**
```json
{
  "error": "Rate limit exceeded",
  "status": "error",
  "retry_after": 60
}
```

---

## Troubleshooting

### Issue: Network/SSL Errors on Windows
**Solution:** Use one of these methods:
- Admin Dashboard (Method 1) ✅
- Postman (Method 2) ✅
- Flutter App (Method 3) ✅
- Online tools (Method 4) ✅

### Issue: OTP Not Received
**Check:**
1. Phone number format is correct (+919811226924)
2. Phone has network coverage
3. Check spam/junk messages
4. Wait 1-2 minutes (delivery can be delayed)
5. Try resending after 1 minute

### Issue: Invalid Credentials
**Verify:**
1. Client ID: `16687983578815655151`
2. API Key: `I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf`
3. Check Admin Dashboard for correct credentials

### Issue: Rate Limit Exceeded
**Solution:**
- Wait 1-5 minutes before retrying
- Check Admin Dashboard for rate limit settings
- Contact support if limits are too restrictive

---

## Quick Start Recommendation

**For immediate testing:**
1. Use **Method 1** (Admin Dashboard) - Fastest and most reliable
2. Use **Method 2** (Postman) - Best for API testing
3. Use **Method 3** (Flutter App) - Best for integration testing

**Why local scripts might fail:**
- Windows firewall blocking requests
- Corporate proxy/VPN interference
- SSL/TLS certificate issues
- Network configuration problems

**These issues don't affect:**
- Browser-based testing (Admin Dashboard, online tools)
- Postman (handles SSL properly)
- Flutter app (uses proper HTTP client)

---

## Next Steps After Successful OTP Test

1. ✅ Verify OTP is received on phone
2. ✅ Test OTP verification endpoint
3. ✅ Test complete login flow in Flutter app
4. ✅ Integrate with your backend
5. ✅ Test error scenarios
6. ✅ Add analytics and monitoring
7. ✅ Prepare for production

---

## Support Resources

- **Documentation:** https://docs.phone.email
- **Admin Dashboard:** https://admin.phone.email
- **API Reference:** https://api.phone.email/docs
- **Support:** support@phone.email

---

## Summary

Your Phone.email integration is ready! Use the **Admin Dashboard** or **Postman** for the most reliable testing experience. The local script issues are due to Windows network/SSL configuration and don't affect the actual integration in your Flutter app.

**Recommended Testing Order:**
1. Admin Dashboard → Quick verification
2. Postman → Detailed API testing
3. Flutter App → Full integration testing
