# Local Server - Quick Start Guide

## ✅ Status: READY TO USE

The local server is fully functional with AuthKey.io OTP integration.

---

## Start the Server

```bash
cd server
npm start
```

**Output:**
```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║           ShowOff.life API Server                         ║
║                                                           ║
║   Server running on port 3000                          ║
║   Environment: development                             ║
║   WebSocket: ✅ Enabled                                   ║
║                                                           ║
║   API Documentation: http://localhost:3000/            ║
║   Health Check: http://localhost:3000/health           ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

## Test OTP System

```bash
node test_otp_localhost.js
```

**Expected Output:**
```
✅ OTP sent successfully!
🔐 OTP Code: 659147
✅ OTP verified successfully!
🎉 User can now be registered
```

---

## API Endpoints

### Health Check
```
GET http://localhost:3000/health
```

### Send OTP
```
POST http://localh