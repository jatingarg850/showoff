# Network Configuration - Quick Reference

## 🎯 Current Setup

Your app is configured with **automatic platform detection**!

## 📱 URLs by Platform

| Platform | What to Use | Example |
|----------|-------------|---------|
| **Android Emulator** | `192.168.0.122` | `http://192.168.0.122:3000` |
| **iOS Simulator** | `localhost` | `http://localhost:3000` |
| **Real Android Device** | Your Computer IP | `http://192.168.1.100:3000` |
| **Real iOS Device** | Your Computer IP | `http://192.168.1.100:3000` |
| **Web Browser** | `localhost` | `http://localhost:3000` |

## 🚀 Quick Start

### 1. Start Server
```bash
cd server
npm run dev
```

### 2. Run App
```bash
cd apps
flutter run
```

### 3. It Just Works! ✨
The app automatically detects your platform and uses the correct URL.

## 🔧 For Real Devices

### Find Your Computer's IP

**Windows:**
```cmd
ipconfig
```
Look for "IPv4 Address" (e.g., 192.168.1.100)

**Mac/Linux:**
```bash
ifconfig | grep "inet "
```
or
```bash
ip addr show
```

### Update Configuration

Edit `apps/lib/config/api_config.dart`:

```dart
static String get baseUrl {
  // For real device testing, uncomment and use your IP:
  return 'http://192.168.1.100:3000/api'; // Your IP here
  
  // Comment out auto-detection:
  // if (Platform.isAndroid) {
  //   return 'http://192.168.0.122:3000/api';
  // }
}
```

### Requirements
- ✅ Phone and computer on same WiFi
- ✅ Firewall allows port 3000
- ✅ Server running on computer

## 🐛 Troubleshooting

### Can't Connect?

1. **Check server is running:**
   ```bash
   curl http://localhost:3000/health
   ```

2. **Verify correct URL:**
   - Emulator: `192.168.0.122`
   - Real device: Your computer's IP
   - Same WiFi network

3. **Check firewall:**
   - Allow port 3000
   - Temporarily disable to test

### Still Not Working?

**Use ngrok for testing:**
```bash
ngrok http 3000
```
Then use the ngrok URL in your config.

## 📝 Configuration Files

| File | Purpose |
|------|---------|
| `apps/lib/config/api_config.dart` | Main configuration |
| `apps/lib/services/api_service.dart` | HTTP requests |
| `apps/lib/services/websocket_service.dart` | Real-time updates |

## 🌐 Special IPs

| IP | What It Means |
|----|---------------|
| `192.168.0.122` | Android Emulator → Host machine |
| `127.0.0.1` | Localhost (same device) |
| `localhost` | Same as 127.0.0.1 |
| `0.0.0.0` | All network interfaces |
| `192.168.x.x` | Local network IP |

## ✅ Verification Checklist

- [ ] Server running on port 3000
- [ ] MongoDB connected
- [ ] Correct URL for your platform
- [ ] Same WiFi (for real devices)
- [ ] Firewall allows port 3000
- [ ] App can reach `/health` endpoint

## 🎓 Learn More

See `ANDROID_EMULATOR_SETUP.md` for detailed documentation.
