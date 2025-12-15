# 🌍 ShowOff.life Deployment Locations

## 📍 Where Your Server is Deployed

### **AWS EC2 Instance**

| Property | Value |
|----------|-------|
| **Instance Name** | showoff-server |
| **Instance ID** | i-04dcb82f3e2050956 |
| **Instance Type** | t2.micro |
| **State** | ✅ Running |
| **Public IPv4** | 3.110.103.187 |
| **Region** | ap-south-1 (Mumbai) |
| **Availability Zone** | ap-south-1a |
| **Status Check** | ✅ 2/2 checks passed |
| **Alarm Status** | ✅ No alarms |

---

## 🌐 Server Access URLs

### **Local Development (Your Machine)**
```
API:        http://localhost:3000/api
Health:     http://localhost:3000/health
WebSocket:  ws://localhost:3000
```

### **AWS Production (EC2)**
```
API:        http://3.110.103.187:3000/api
Health:     http://3.110.103.187:3000/health
WebSocket:  ws://3.110.103.187:3000
```

---

## 📊 Deployment Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    AWS EC2 Instance                      │
│              (ap-south-1 / Mumbai Region)                │
│                                                          │
│  Instance: showoff-server (t2.micro)                    │
│  IP: 3.110.103.187                                      │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │         Node.js Server (Port 3000)               │   │
│  │  ┌────────────────────────────────────────────┐  │   │
│  │  │  Express API                               │  │   │
│  │  │  - Authentication                          │  │   │
│  │  │  - Posts & Reels                           │  │   │
│  │  │  - User Management                         │  │   │
│  │  │  - Payments                                │  │   │
│  │  │  - WebSocket                               │  │   │
│  │  └────────────────────────────────────────────┘  │   │
│  │                                                   │   │
│  │  ┌────────────────────────────────────────────┐  │   │
│  │  │  PM2 Process Manager                       │  │   │
│  │  │  - Auto-restart on crash                   │  │   │
│  │  │  - Auto-startup on reboot                  │  │   │
│  │  │  - Process monitoring                      │  │   │
│  │  └────────────────────────────────────────────┘  │   │
│  │                                                   │   │
│  │  ┌────────────────────────────────────────────┐  │   │
│  │  │  Nginx Reverse Proxy                       │  │   │
│  │  │  - Port 80 → 3000                          │  │   │
│  │  │  - WebSocket support                       │  │   │
│  │  └────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  Connected Services:                                    │
│  ✅ MongoDB Atlas (Cloud Database)                      │
│  ✅ Wasabi S3 (File Storage)                            │
│  ✅ Razorpay (Payment Gateway)                          │
│  ✅ Stripe (Payment Gateway)                            │
│  ✅ Phone.Email (OTP Service)                           │
│  ✅ AuthKey (SMS Service)                               │
│                                                          │
└─────────────────────────────────────────────────────────┘
         │
         ▼
    ┌─────────────────────────────────────────────────────┐
    │         Flutter Mobile App                          │
    │  (Android, iOS, Web)                                │
    │                                                     │
    │  Connects to: 3.110.103.187:3000                   │
    └─────────────────────────────────────────────────────┘
```

---

## 🔧 Server Configuration

### **Operating System**
- **OS:** Amazon Linux 2023
- **Kernel:** 6.1 HVM

### **Software Stack**
- **Runtime:** Node.js 18.20.8
- **Package Manager:** npm 10.8.2
- **Process Manager:** PM2
- **Web Server:** Nginx 1.28.0
- **Database:** MongoDB Atlas (Cloud)
- **Storage:** Wasabi S3

### **Services Running**
- ✅ Node.js Express Server (Port 3000)
- ✅ Nginx Reverse Proxy (Port 80)
- ✅ PM2 Daemon
- ✅ WebSocket Server
- ✅ MongoDB Connection
- ✅ S3 Storage Connection

---

## 📈 Instance Metrics

| Metric | Value |
|--------|-------|
| **CPU Utilization** | 0% |
| **Memory Usage** | 104.9 MB |
| **Network In** | Minimal |
| **Network Out** | Minimal |
| **Status Checks** | ✅ 2/2 Passed |
| **Uptime** | Running |

---

## 🔐 Security Configuration

### **Security Group: showoff-sg**
| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22 | SSH | Your IP | Remote access |
| 80 | HTTP | 0.0.0.0/0 | Web traffic |
| 443 | HTTPS | 0.0.0.0/0 | Secure traffic |
| 3000 | TCP | 0.0.0.0/0 | Node.js server |

### **Key Pair**
- **Name:** showoff-key
- **Type:** RSA
- **Format:** .pem
- **Location:** C:\Users\coddy\showoff-key.pem

---

## 📱 Flutter App Configuration

### **Current Configuration (Local Testing)**
```dart
// apps/lib/config/api_config.dart

static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000/api';  // Android Emulator
  } else if (Platform.isIOS) {
    return 'http://localhost:3000/api';  // iOS Simulator
  } else {
    return 'http://localhost:3000/api';  // Web/Desktop
  }
}

static String get wsUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000';
  } else if (Platform.isIOS) {
    return 'http://localhost:3000';
  } else {
    return 'http://localhost:3000';
  }
}
```

### **For AWS Production**
```dart
static String get baseUrl {
  return 'http://3.110.103.187:3000/api';
}

static String get wsUrl {
  return 'http://3.110.103.187:3000';
}
```

---

## 🚀 How to Access Your Server

### **From AWS Console**
1. Go to EC2 → Instances
2. Find "showoff-server" instance
3. Copy Public IPv4: **3.110.103.187**
4. Access at: http://3.110.103.187:3000

### **From Terminal**
```bash
# SSH into instance
ssh -i C:\Users\coddy\showoff-key.pem ec2-user@3.110.103.187

# View logs
pm2 logs showoff-api

# Check status
pm2 list
```

### **From Flutter App**
- Update config with server IP
- Run app
- App connects to 3.110.103.187:3000

---

## 📊 Deployment Summary

| Component | Location | Status |
|-----------|----------|--------|
| **Server** | AWS EC2 (ap-south-1) | ✅ Running |
| **Database** | MongoDB Atlas (Cloud) | ✅ Connected |
| **Storage** | Wasabi S3 | ✅ Connected |
| **Process Manager** | PM2 (EC2) | ✅ Running |
| **Web Server** | Nginx (EC2) | ✅ Running |
| **Flutter App** | Local Machine | ✅ Ready |

---

## 🎯 Two Deployment Options

### **Option 1: Local Development**
- **Server:** Your local machine (localhost:3000)
- **Use for:** Testing and development
- **Flutter Config:** localhost:3000
- **Best for:** Development & debugging

### **Option 2: AWS Production**
- **Server:** AWS EC2 (3.110.103.187:3000)
- **Use for:** Production deployment
- **Flutter Config:** 3.110.103.187:3000
- **Best for:** Real users & mobile devices

---

## 📍 AWS Region Details

| Property | Value |
|----------|-------|
| **Region** | ap-south-1 (Asia Pacific - Mumbai) |
| **Availability Zone** | ap-south-1a |
| **Latency** | Low for India users |
| **Cost** | Minimal (t2.micro free tier) |

---

## 🔄 Deployment Flow

```
1. Your Local Machine
   ├─ Node.js Server (localhost:3000)
   ├─ Flutter App (Testing)
   └─ PM2 Process Manager

2. AWS EC2 Instance
   ├─ IP: 3.110.103.187
   ├─ Node.js Server (Port 3000)
   ├─ Nginx Reverse Proxy (Port 80)
   ├─ PM2 Auto-startup
   └─ Connected to MongoDB Atlas & Wasabi S3

3. Mobile Device
   └─ Flutter App connects to 3.110.103.187:3000
```

---

## ✅ Deployment Checklist

- [x] AWS EC2 instance created
- [x] Security group configured
- [x] Node.js installed
- [x] PM2 installed and configured
- [x] Nginx installed and configured
- [x] Server running on port 3000
- [x] MongoDB connected
- [x] Wasabi S3 connected
- [x] Auto-startup enabled
- [x] Flutter app configured
- [ ] Flutter app tested
- [ ] Deployed to Play Store

---

## 🎉 Your Server is Live!

**Local:** http://localhost:3000
**AWS:** http://3.110.103.187:3000

Both servers are running and ready to serve your Flutter app!

---

## 📞 Quick Reference

```bash
# SSH into AWS instance
ssh -i C:\Users\coddy\showoff-key.pem ec2-user@3.110.103.187

# View server logs
pm2 logs showoff-api

# Restart server
pm2 restart showoff-api

# Check server status
pm2 list

# Test health endpoint
curl http://3.110.103.187:3000/health
```

---

**Your ShowOff.life server is deployed and ready!** 🚀
