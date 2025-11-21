const axios = require('axios');

class PhoneEmailService {
  constructor() {
    this.clientId = process.env.PHONE_EMAIL_CLIENT_ID || '16687983578815655151';
    this.apiKey = process.env.PHONE_EMAIL_API_KEY || 'I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf';
    // Phone.email uses their main domain for API, not a separate api subdomain
    this.baseUrl = 'https://www.phone.email';
    
    // Create axios instance with better error handling and TLS configuration
    this.axiosInstance = axios.create({
      baseURL: this.baseUrl,
      timeout: 15000, // 15 second timeout
      headers: {
        'Content-Type': 'application/json',
      },
      // Add TLS/SSL configuration to handle connection issues
      httpsAgent: new (require('https').Agent)({
        rejectUnauthorized: true,
        keepAlive: true,
      }),
    });
    
    console.log('📞 Phone.Email Service initialized');
    console.log('   - Client ID:', this.clientId);
    console.log('   - Base URL:', this.baseUrl);
  }

  /**
   * Send OTP to phone number
   * @param {string} phoneNumber - Phone number with country code (e.g., +919811226924)
   * @returns {Promise<Object>} Response with OTP details
   */
  async sendPhoneOTP(phoneNumber) {
    try {
      console.log(`📞 Attempting to send OTP via Phone.email to: ${phoneNumber}`);
      
      // Phone.email API endpoint for sending OTP
      const response = await this.axiosInstance.post('/send_otp_v1.php', {
        client_id: this.clientId,
        phone_number: phoneNumber,
      });

      // Only log if it's actual JSON response, not HTML
      if (response.data && typeof response.data === 'object') {
        console.log('✅ Phone.email responded (service may be limited)');
      }
      
      return {
        success: true,
        data: response.data,
        message: 'OTP sent successfully',
      };
    } catch (error) {
      console.error('❌ Phone OTP send error:', error.code || error.message);
      
      if (error.response) {
        // Server responded with error
        console.error('   Response status:', error.response.status);
        console.error('   Response data:', error.response.data);
        return {
          success: false,
          message: error.response.data?.message || 'Failed to send OTP',
          error: error.response.data,
        };
      } else if (error.request) {
        // Request made but no response (network/TLS error)
        console.error('   No response received from Phone.email service');
        console.error('   This could be due to network issues or TLS connection problems');
        throw new Error('No response from OTP service. Please check your internet connection.');
      } else {
        // Error setting up request
        throw new Error('Failed to send OTP: ' + error.message);
      }
    }
  }

  /**
   * Send OTP to email
   * @param {string} email - Email address
   * @returns {Promise<Object>} Response with OTP details
   */
  async sendEmailOTP(email) {
    try {
      console.log(`📧 Attempting to send OTP via Phone.email to: ${email}`);
      
      // Phone.email API endpoint for sending email OTP
      const response = await this.axiosInstance.post('/send_otp_v1.php', {
        client_id: this.clientId,
        email: email,
      });

      // Only log if it's actual JSON response, not HTML
      if (response.data && typeof response.data === 'object') {
        console.log('✅ Phone.email responded (service may be limited)');
      }
      
      return {
        success: true,
        data: response.data,
        message: 'OTP sent successfully',
      };
    } catch (error) {
      console.error('❌ Email OTP send error:', error.code || error.message);
      
      if (error.response) {
        // Server responded with error
        console.error('   Response status:', error.response.status);
        console.error('   Response data:', error.response.data);
        return {
          success: false,
          message: error.response.data?.message || 'Failed to send OTP',
          error: error.response.data,
        };
      } else if (error.request) {
        // Request made but no response (network/TLS error)
        console.error('   No response received from Phone.email service');
        throw new Error('No response from OTP service. Please check your internet connection.');
      } else {
        // Error setting up request
        throw new Error('Failed to send OTP: ' + error.message);
      }
    }
  }

  /**
   * Verify OTP
   * @param {string} identifier - Phone number or email
   * @param {string} otp - OTP code
   * @returns {Promise<Object>} Verification result
   */
  async verifyOTP(identifier, otp) {
    try {
      console.log(`🔍 Attempting to verify OTP via Phone.email for: ${identifier}`);
      
      // Phone.email API endpoint for verifying OTP
      const response = await this.axiosInstance.post('/verify_otp_v1.php', {
        client_id: this.clientId,
        phone_number: identifier.includes('@') ? undefined : identifier,
        email: identifier.includes('@') ? identifier : undefined,
        otp: otp,
      });

      // Only log if it's actual JSON response, not HTML
      if (response.data && typeof response.data === 'object') {
        console.log('✅ Phone.email verification responded');
      }
      
      return {
        success: true,
        data: response.data,
        message: 'OTP verified successfully',
      };
    } catch (error) {
      console.error('❌ OTP verify error:', error.code || error.message);
      
      if (error.response) {
        // Server responded with error
        console.error('   Response status:', error.response.status);
        console.error('   Response data:', error.response.data);
        return {
          success: false,
          message: error.response.data?.message || 'Invalid OTP',
          error: error.response.data,
        };
      } else if (error.request) {
        // Request made but no response
        console.error('   No response received from Phone.email service');
        throw new Error('No response from OTP service. Please check your internet connection.');
      } else {
        // Error setting up request
        throw new Error('Failed to verify OTP: ' + error.message);
      }
    }
  }

  /**
   * Resend OTP
   * @param {string} identifier - Phone number or email
   * @returns {Promise<Object>} Response with OTP details
   */
  async resendOTP(identifier) {
    // Determine if identifier is email or phone
    const isEmail = identifier.includes('@');
    
    if (isEmail) {
      return this.sendEmailOTP(identifier);
    } else {
      return this.sendPhoneOTP(identifier);
    }
  }
}

module.exports = new PhoneEmailService();
