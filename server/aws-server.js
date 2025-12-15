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

// Create HTTPS server (with self-signed cert or proper cert)
let httpsServer = null;
try {
  const privateKey = fs.readFileSync('/etc/ssl/private/server.key', 'utf8');
  const certificate = fs.readFileSync('/etc/ssl/certs/server.crt', 'utf8');
  httpsServer = https.createServer({ key: privateKey, cert: certificate }, app);
} catch (err) {
  console.log('⚠️  HTTPS certificates not found. HTTPS will not be available.');
  console.log('   To enable HTTPS, place certificates at:');
  console.log('   - /etc/ssl/private/server.key');
  console.log('   - /etc/ssl/certs/server.crt');
}

// Socket.IO for both HTTP and HTTPS
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

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString(),
    protocol: req.protocol.toUpperCase(),
    websocket: { enabled: true, activeConnections: 0 }
  });
});

// API endpoint
app.get('/api', (req, res) => {
  res.json({ 
    message: 'ShowOff.life API is running',
    protocol: req.protocol.toUpperCase()
  });
});

// WebSocket connection for HTTP
ioHttp.on('connection', (socket) => {
  console.log('[HTTP] User connected:', socket.id);
  socket.on('disconnect', () => {
    console.log('[HTTP] User disconnected:', socket.id);
  });
});

// WebSocket connection for HTTPS
if (ioHttps) {
  ioHttps.on('connection', (socket) => {
    console.log('[HTTPS] User connected:', socket.id);
    socket.on('disconnect', () => {
      console.log('[HTTPS] User disconnected:', socket.id);
    });
  });
}

// Start HTTP server on all network interfaces
httpServer.listen(HTTP_PORT, '0.0.0.0', () => {
  console.log(`✅ HTTP Server running on port ${HTTP_PORT}`);
  console.log(`📍 HTTP Health check: http://3.110.103.187:${HTTP_PORT}/health`);
  console.log(`📍 HTTP API: http://3.110.103.187:${HTTP_PORT}/api`);
});

// Start HTTPS server if certificates are available
if (httpsServer) {
  httpsServer.listen(HTTPS_PORT, '0.0.0.0', () => {
    console.log(`✅ HTTPS Server running on port ${HTTPS_PORT}`);
    console.log(`📍 HTTPS Health check: https://3.110.103.187:${HTTPS_PORT}/health`);
    console.log(`📍 HTTPS API: https://3.110.103.187:${HTTPS_PORT}/api`);
  });
}
