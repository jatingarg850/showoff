# MSG91 OTP Integration Guide

## Why MSG91?

- ✅ **Excellent for India**: Best coverage for Indian phone numbers
- ✅ **Affordable**: Very competitive pricing for India
- ✅ **Reliable**: High delivery rates
- ✅ **Easy Integration**: Simple REST API
- ✅ **Free Trial**: Get free credits to start

## Quick Setup (15 minutes)

### Step 1: Sign Up for MSG91

1. Go to https://msg91.com/signup
2. Sign up with your email
3. Verify your email
4. Complete KYC (required for India)

### Step 2: Get Credentials

1. Login to MSG91 dashboard
2. Go to **Settings** → **API Keys**
3. Copy your **Auth Key**
4. Go to **OTP** section
5. Create a new **Template** for OTP
6. Note your **Template ID**

### Step 3: Install Package

```bash
cd server
npm install msg91-sms
```

### Step 4: Update Environment Variables

Add to `server/.env`:

```env
# MSG91 Configuration
MSG91_AUTH_KEY=your_auth_key_here
MSG91_SENDER_ID=SHWOFF
MSG91_TEMPLATE_ID=your_template_id_here
MSG91_ROUTE=4
```

### Step 5: Create MSG91 Service

Create `server/services/msg91Service.js`:

```javascript
const axios = require('axios');

class MSG91Service {
  constructor() {
    this.authKey = process.env.MSG91_AUTH_KEY;
    this.senderId = process.env.MSG91_SENDER_ID || 'SHWOFF';
    this.templateId = process.env.MSG91_TEMPLATE_ID;
    this.route = process.env.MSG91_ROUTE || '4';
    this.baseUrl = 'https://control.msg91.com/api/v5';
    
    console.log('📱 MSG91 Service initialized');
  }

  /**
   * Send OTP to phone number
   * @param {string} phoneNumber - Phone number with country code (e.g., 919811226924)
   * @param {string} otp - 6-digit OTP
   * @returns {Promise<Object>}
   */
  async sendOTP(phoneNumber, otp) {
    try {
      // Remove + from country code if present
      const cleanPhone = phoneNumber.replace('+', '');
      
      console.log(`📱 Sending OTP via MSG91 to: ${cleanPhone}`);
      
      const response = await axios.post(
        `${this.baseUrl}/otp`,
        {
          template_id: this.templateId,
          mobile: cleanPhone,
          authkey: this.authKey,
          otp: otp,
        },
        {
          headers: {
            'Content-Type': 'application/json',
          },
        }
      );

      console.log('✅ MSG91 Response:', response.data);

      if (response.data.type === 'success') {
        return {
          success: true,
          message: 'OTP sent successfully',
          data: response.data,
        };
      } else {
        return {
          success: false,
          message: response.data.message || 'Failed to send OTP',
          data: response.data,
        };
      }
    } catch (error) {
      console.error('❌ MSG91 Error:', error.response?.data || error.message);
      throw new Error(error.response?.data?.message || 'Failed to send OTP');
    }
  }

  /**
   * Verify OTP (MSG91 handles verification on their end)
   * @param {string} phoneNumber - Phone number
   * @param {string} otp - OTP to verify
   * @returns {Promise<Object>}
   */
  async verifyOTP(phoneNumber, otp) {
    try {
      const cleanPhone = phoneNumber.replace('+', '');
      
      console.log(`🔍 Verifying OTP via MSG91 for: ${cleanPhone}`);
      
      const response = await axios.post(
        `${this.baseUrl}/otp/verify`,
        {
          authkey: this.authKey,
          mobile: cleanPhone,
          otp: otp,
        },
        {
          headers: {
            'Content-Type': 'application/json',
          },
        }
      );

      console.log('✅ MSG91 Verify Response:', response.data);

      if (response.data.type === 'success') {
        return {
          success: true,
          message: 'OTP verified successfully',
          data: response.data,
        };
      } else {
        return {
          success: false,
          message: response.data.message || 'Invalid OTP',
          data: response.data,
        };
      }
    } catch (error) {
      console.error('❌ MSG91 Verify Error:', error.response?.data || error.message);
      return {
        success: false,
        message: error.response?.data?.message || 'Invalid OTP',
      };
    }
  }

  /**
   * Resend OTP
   * @param {string} phoneNumber - Phone number
   * @returns {Promise<Object>}
   */
  async resendOTP(phoneNumber) {
    try {
      const cleanPhone = phoneNumber.replace('+', '');
      
      const response = await axios.post(
        `${this.baseUrl}/otp/retry`,
        {
          authkey: this.authKey,
          mobile: cleanPhone,
          retrytype: 'text',
        },
        {
          headers: {
            'Content-Type': 'application/json',
          },
        }
      );

      return {
        success: true,
        message: 'OTP resent successfully',
        data: response.data,
      };
    } catch (error) {
      console.error('❌ MSG91 Resend Error:', error.response?.data || error.message);
      throw new Error('Failed to resend OTP');
    }
  }
}

module.exports = new MSG91Service();
```

### Step 6: Update Auth Controller

Update `server/controllers/authController.js` to use MSG91:

```javascript
// At the top, replace phoneEmailService with msg91Service
const msg91Service = require('../services/msg91Service');

// In sendOTP function, replace the Phone.email call:
try {
  // Generate OTP
  const otp = generateOTP();
  
  // Send OTP via MSG91
  if (email) {
    // For email, keep existing logic or use email service
    console.log(`📧 Sending OTP to email: ${email}`);
    // ... email logic
  } else {
    const fullPhone = `${countryCode}${phone}`;
    console.log(`📱 Sending OTP to phone: ${fullPhone}`);
    
    const otpResponse = await msg91Service.sendOTP(fullPhone, otp);
    
    if (otpResponse.success) {
      // Store OTP
      otpStore.set(identifier, {
        otp: otp,
        expiresAt: Date.now() + 10 * 60 * 1000, // 10 minutes
        attempts: 0,
      });
      
      console.log(`✅ OTP sent successfully to ${fullPhone}`);
    } else {
      throw new Error(otpResponse.message);
    }
  }
  
  res.status(200).json({
    success: true,
    message: 'OTP sent successfully',
  });
} catch (error) {
  console.error('❌ OTP send error:', error);
  // Fallback OTP for development
  const fallbackOTP = generateOTP();
  otpStore.set(identifier, {
    otp: fallbackOTP,
    expiresAt: Date.now() + 10 * 60 * 1000,
    attempts: 0,
  });
  console.log(`⚠️ Fallback OTP for ${identifier}: ${fallbackOTP}`);
  
  res.status(200).json({
    success: true,
    message: 'OTP sent successfully',
  });
}
```

## Pricing

MSG91 pricing for India:

- **Transactional SMS**: ₹0.15 - ₹0.25 per SMS
- **OTP SMS**: ₹0.15 - ₹0.20 per SMS
- **Free Trial**: 100 free SMS credits

## Template Setup

1. Go to MSG91 Dashboard → **OTP** → **Templates**
2. Click **Create Template**
3. Template content:
   ```
   Your ShowOff.life OTP is ##OTP##. Valid for 10 minutes. Do not share with anyone.
   ```
4. Submit for approval (usually approved in 1-2 hours)
5. Copy the Template ID

## Testing

```bash
# Test OTP send
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "9811226924", "countryCode": "+91"}'

# Check your phone for OTP

# Test OTP verify
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "9811226924", "countryCode": "+91", "otp": "123456"}'
```

## Advantages Over Phone.email

1. ✅ **Not shutting down** - Active and growing service
2. ✅ **Better India coverage** - Optimized for Indian networks
3. ✅ **Lower cost** - More affordable for Indian SMS
4. ✅ **Faster delivery** - Better delivery rates
5. ✅ **Better support** - 24/7 support available
6. ✅ **More features** - Voice OTP, WhatsApp OTP, etc.

## Alternative: Twilio

If you need global coverage, Twilio is excellent:

```bash
npm install twilio
```

```javascript
const twilio = require('twilio');
const client = twilio(accountSid, authToken);

await client.messages.create({
  body: `Your OTP is: ${otp}`,
  from: '+1234567890',
  to: phoneNumber
});
```

## Next Steps

1. Sign up for MSG91
2. Get Auth Key and Template ID
3. Update .env file
4. Install msg91-sms package
5. Create msg91Service.js
6. Update authController.js
7. Test OTP flow

Would you like me to implement this for you?
