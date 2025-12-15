require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const https = require('https');
const fs = require('fs');
const socketIo = require('socket.io');

const app = express();

// Create HTTP server
const httpServer = http.createServer(app);

// Create HTTPS server
let httpsServer = null;
try {
  const privateKey = fs.readFileSync('/etc/ssl/private/server.key', 'utf8');
  const certificate = fs.readFileSync('/etc/ssl/certs/server.crt', 'utf8');
  httpsServer = https.createServer({ key: privateKey, cert: certificate }, app);
} catch (err) {
  console.log('⚠️  HTTPS certificates not found. HTTPS will not be available.');
}

// Socket.IO
const ioHttp = socketIo(httpServer, {
  cors: { origin: '*', methods: ['GET', 'POST'] }
});

let ioHttps = null;
if (httpsServer) {
  ioHttps = socketIo(httpsServer, {
    cors: { origin: '*', methods: ['GET', 'POST'] }
  });
}

const HTTP_PORT = process.env.HTTP_PORT || 3000;
const HTTPS_PORT = process.env.HTTPS_PORT || 3443;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// In-memory OTP storage
const otpStore = new Map();

// Helper: Generate 6-digit OTP
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Helper: Send SMS via AuthKey.io
async function sendSMSViaAuthKey(phone, countryCode, message) {
  return new Promise((resolve, reject) => {
    const authKey = process.env.AUTHKEY_API_KEY;
    if (!authKey) {
      return reject(new Error('AuthKey API key not configured'));
    }

    const postData = JSON.stringify({
      country_code: countryCode,
      mobile: phone,
      sms: message,
      sender: process.env.AUTHKEY_SENDER_ID || 'SHOWOFF',
      pe_id: process.env.AUTHKEY_PE_ID,
      template_id: process.env.AUTHKEY_TEMPLATE_ID
    });

    const options = {
      hostname: 'console.authkey.io',
      port: 443,
      path: '/restapi/requestjson.php',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${Buffer.from(authKey).toString('base64')}`,
        'Content-Length': postData.length
      }
    };

    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          
          if (response.LogID || response.status === 'success') {
            resolve({
              success: true,
              logId: response.LogID || response.logid || 'local_' + Date.now(),
              message: response.Message || 'SMS sent successfully'
            });
          } else {
            reject(new Error(response.Message || response.message || 'Failed to send SMS'));
          }
        } catch (error) {
          reject(new Error('Invalid response from SMS service'));
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.write(postData);
    req.end();
  });
}

// Health check
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString(),
    protocol: req.protocol.toUpperCase(),
    websocket: { enabled: true }
  });
});

// API status
app.get('/api', (req, res) => {
  res.json({ 
    message: 'ShowOff.life OTP API is running',
    protocol: req.protocol.toUpperCase()
  });
});

// Send OTP
app.post('/api/auth/send-otp', async (req, res) => {
  try {
    const { phone, countryCode } = req.body;

    if (!phone || !countryCode) {
      return res.status(400).json({
        success: false,
        message: 'Phone and country code are required'
      });
    }

    const identifier = `${countryCode}${phone}`;
    
    console.log('╔════════════════════════════════════════╗');
    console.log('║          🔐 SENDING OTP               ║');
    console.log('╠════════════════════════════════════════╣');
    console.log(`║  Phone: +${countryCode} ${phone.padEnd(18)} ║`);

    // Generate OTP
    const otp = generateOTP();
    console.log(`║  Generated OTP: ${otp.padEnd(18)} ║`);

    // Create message
    const message = `Your ShowOff.life OTP is ${otp}. Do not share this code with anyone. Valid for 10 minutes.`;

    try {
      // Send via AuthKey.io
      const result = await sendSMSViaAuthKey(phone, countryCode, message);
      
      // Store OTP
      otpStore.set(identifier, {
        otp: otp,
        logId: result.logId,
        expiresAt: Date.now() + 10 * 60 * 1000,
        attempts: 0,
        createdAt: Date.now()
      });

      console.log('✅ OTP sent via AuthKey.io');
      console.log(`║  LogID: ${result.logId.substring(0, 20).padEnd(20)} ║`);
      console.log('╚════════════════════════════════════════╝');

      res.status(200).json({
        success: true,
        message: 'OTP sent successfully',
        data: {
          identifier,
          expiresIn: 600,
          logId: result.logId,
          otp: otp // For testing/development
        }
      });
    } catch (error) {
      console.error('❌ Error sending SMS:', error.message);
      
      // Fallback: Store OTP locally
      otpStore.set(identifier, {
        otp: otp,
        logId: 'local_' + Date.now(),
        expiresAt: Date.now() + 10 * 60 * 1000,
        attempts: 0,
        createdAt: Date.now()
      });

      console.log('⚠️  Using fallback (SMS service error)');
      console.log('╚════════════════════════════════════════╝');

      res.status(200).json({
        success: true,
        message: 'OTP generated (SMS service unavailable)',
        data: {
          identifier,
          expiresIn: 600,
          otp: otp
        }
      });
    }
  } catch (error) {
    console.error('❌ Send OTP error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to send OTP'
    });
  }
});

// Verify OTP
app.post('/api/auth/verify-otp', (req, res) => {
  try {
    const { phone, countryCode, otp } = req.body;

    if (!phone || !countryCode || !otp) {
      return res.status(400).json({
        success: false,
        message: 'Phone, country code, and OTP are required'
      });
    }

    const identifier = `${countryCode}${phone}`;
    const session = otpStore.get(identifier);

    console.log('╔════════════════════════════════════════╗');
    console.log('║       🔍 VERIFYING OTP                ║');
    console.log('╠════════════════════════════════════════╣');
    console.log(`║  Phone: +${countryCode} ${phone.padEnd(18)} ║`);
    console.log(`║  Entered OTP: ${otp.padEnd(23)} ║`);

    if (!session) {
      console.log('║  Status: Not found                     ║');
      console.log('╚════════════════════════════════════════╝');
      return res.status(400).json({
        success: false,
        message: 'OTP session not found. Please request a new OTP.'
      });
    }

    // Check expiry
    if (Date.now() > session.expiresAt) {
      otpStore.delete(identifier);
      console.log('║  Status: Expired                       ║');
      console.log('╚════════════════════════════════════════╝');
      return res.status(400).json({
        success: false,
        message: 'OTP expired. Please request a new OTP.'
      });
    }

    // Check attempts
    if (session.attempts >= 3) {
      otpStore.delete(identifier);
      console.log('║  Status: Too many attempts            ║');
      console.log('╚════════════════════════════════════════╝');
      return res.status(400).json({
        success: false,
        message: 'Too many failed attempts. Please request a new OTP.'
      });
    }

    // Verify OTP
    if (session.otp === otp) {
      otpStore.delete(identifier);
      console.log('║  Status: ✅ VERIFIED                  ║');
      console.log('╚════════════════════════════════════════╝');
      
      res.status(200).json({
        success: true,
        message: 'OTP verified successfully'
      });
    } else {
      session.attempts += 1;
      console.log(`║  Status: ❌ Invalid (${session.attempts}/3)        ║`);
      console.log('╚════════════════════════════════════════╝');
      
      res.status(400).json({
        success: false,
        message: 'Invalid OTP',
        attemptsLeft: 3 - session.attempts
      });
    }
  } catch (error) {
    console.error('❌ Verify OTP error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to verify OTP'
    });
  }
});

// WebSocket
ioHttp.on('connection', (socket) => {
  console.log('[HTTP] User connected:', socket.id);
  socket.on('disconnect', () => {
    console.log('[HTTP] User disconnected:', socket.id);
  });
});

if (ioHttps) {
  ioHttps.on('connection', (socket) => {
    console.log('[HTTPS] User connected:', socket.id);
    socket.on('disconnect', () => {
      console.log('[HTTPS] User disconnected:', socket.id);
    });
  });
}

// Start servers
httpServer.listen(HTTP_PORT, '0.0.0.0', () => {
  console.log(`✅ HTTP Server running on port ${HTTP_PORT}`);
  console.log(`📍 Health: http://3.110.103.187:${HTTP_PORT}/health`);
  console.log(`📍 Send OTP: POST http://3.110.103.187:${HTTP_PORT}/api/auth/send-otp`);
  console.log(`📍 Verify OTP: POST http://3.110.103.187:${HTTP_PORT}/api/auth/verify-otp`);
});

if (httpsServer) {
  httpsServer.listen(HTTPS_PORT, '0.0.0.0', () => {
    console.log(`✅ HTTPS Server running on port ${HTTPS_PORT}`);
    console.log(`📍 Health: https://3.110.103.187:${HTTPS_PORT}/health`);
  });
}
