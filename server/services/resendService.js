/**
 * Resend Email Service
 * Handles email OTP sending via Resend API
 */

const https = require('https');

class ResendService {
  constructor() {
    this.apiKey = process.env.RESEND_API_KEY;
    this.fromEmail = process.env.RESEND_FROM_EMAIL || 'noreply@showoff.life';
    this.baseUrl = 'api.resend.com';
  }

  /**
   * Generate 6-digit OTP
   */
  generateOTP() {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  /**
   * Send OTP via Email using Resend
   * @param {string} email - Email address
   * @returns {Promise<{success: boolean, messageId: string, otp: string, message: string}>}
   */
  async sendEmailOTP(email) {
    return new Promise((resolve, reject) => {
      if (!this.apiKey) {
        return reject(new Error('Resend API key not configured'));
      }

      // Generate OTP locally
      const otp = this.generateOTP();

      console.log('📧 Sending OTP via Email (Resend)');
      console.log('   Email:', email);
      console.log('   Generated OTP:', otp);
      console.log('   API Key:', this.apiKey ? '✅ Configured' : '❌ Missing');

      // Create email HTML body with OTP
      const emailSubject = 'Your ShowOff.life OTP';
      const emailHtml = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; border-radius: 8px 8px 0 0; text-align: center;">
            <h1 style="color: white; margin: 0;">ShowOff.life</h1>
          </div>
          <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px;">
            <p style="color: #333; font-size: 16px; margin-bottom: 20px;">
              Hello,
            </p>
            <p style="color: #333; font-size: 16px; margin-bottom: 30px;">
              Your ShowOff.life OTP is:
            </p>
            <div style="background: white; border: 2px solid #667eea; border-radius: 8px; padding: 20px; text-align: center; margin-bottom: 30px;">
              <p style="font-size: 32px; font-weight: bold; color: #667eea; margin: 0; letter-spacing: 5px;">
                ${otp}
              </p>
            </div>
            <p style="color: #666; font-size: 14px; margin-bottom: 10px;">
              This OTP is valid for 10 minutes.
            </p>
            <p style="color: #666; font-size: 14px; margin-bottom: 20px;">
              Do not share this code with anyone.
            </p>
            <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
            <p style="color: #999; font-size: 12px; text-align: center;">
              If you didn't request this OTP, please ignore this email.
            </p>
          </div>
        </div>
      `;

      const emailText = `Your ShowOff.life OTP is ${otp}. Do not share this code with anyone. Valid for 10 minutes.`;

      // Prepare request body
      const requestBody = JSON.stringify({
        from: this.fromEmail,
        to: email,
        subject: emailSubject,
        html: emailHtml,
        text: emailText
      });

      const options = {
        hostname: this.baseUrl,
        port: 443,
        path: '/emails',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(requestBody),
          'Authorization': `Bearer ${this.apiKey}`
        }
      };

      console.log('   Endpoint: api.resend.com/emails');
      console.log('   Method: POST');
      console.log('   From:', this.fromEmail);
      console.log('   To:', email);
      console.log('   Subject:', emailSubject);

      const req = https.request(options, (res) => {
        let data = '';

        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', () => {
          try {
            const response = JSON.parse(data);

            console.log('✅ Resend Response:', response);
            console.log('   Status Code:', res.statusCode);

            // Check for success
            if (res.statusCode === 200 && response.id) {
              // Success - Email sent with OTP
              resolve({
                success: true,
                messageId: response.id,
                otp: otp, // Return OTP for verification
                message: 'Email sent successfully',
              });
            } else if (response.message) {
              // Error response
              console.error('❌ Resend Error Response:', response);
              reject(new Error(response.message || 'Failed to send email'));
            } else {
              console.error('❌ Resend Error Response:', response);
              reject(new Error('Failed to send email'));
            }
          } catch (error) {
            console.error('❌ Failed to parse Resend response:', error);
            console.error('   Response data:', data);
            reject(new Error('Invalid response from email service'));
          }
        });
      });

      req.on('error', (error) => {
        console.error('❌ Resend API Error:', error);
        reject(error);
      });

      req.write(requestBody);
      req.end();
    });
  }

  /**
   * Send custom email via Resend
   * @param {string} email - Email address
   * @param {string} subject - Email subject
   * @param {string} html - Email HTML body
   * @param {string} text - Email text body
   * @returns {Promise<{success: boolean, messageId: string, message: string}>}
   */
  async sendEmail(email, subject, html, text) {
    return new Promise((resolve, reject) => {
      if (!this.apiKey) {
        return reject(new Error('Resend API key not configured'));
      }

      const requestBody = JSON.stringify({
        from: this.fromEmail,
        to: email,
        subject: subject,
        html: html,
        text: text
      });

      const options = {
        hostname: this.baseUrl,
        port: 443,
        path: '/emails',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(requestBody),
          'Authorization': `Bearer ${this.apiKey}`
        }
      };

      console.log('📧 Sending Email via Resend');
      console.log('   To:', email);
      console.log('   Subject:', subject);

      const req = https.request(options, (res) => {
        let data = '';

        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', () => {
          try {
            const response = JSON.parse(data);

            if (res.statusCode === 200 && response.id) {
              resolve({
                success: true,
                messageId: response.id,
                message: 'Email sent successfully'
              });
            } else {
              reject(new Error(response.message || 'Failed to send email'));
            }
          } catch (error) {
            reject(new Error('Invalid response from email service'));
          }
        });
      });

      req.on('error', reject);

      req.write(requestBody);
      req.end();
    });
  }
}

module.exports = new ResendService();
