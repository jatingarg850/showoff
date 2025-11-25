# Android Emulator Network Configuration

## ✅ Configuration Complete

Your Flutter app is now configured to work with Android Emulator automatically!

## How It Works

### Automatic Platform Detection

The app now automatically detects the platform and uses the correct URL:

| Platform | API URL | WebSocket URL |
|----------|---------|---------------|
| **Android Emulator** | `http://192.168.0.122:3000/api` | `http://192.168.0.122:3000` |
| **iOS Simulator** | `http://localhost:3000/api` | `http://localhost:3000` |
| **Web/Desktop** | `http://localhost:3000/api` | `http://localhost:3000` |

### Special Android Emulator IP

**`192.168.0.122`** is a special alias in Android Emulator that maps to your host machine's `127.0.0.1` (localhost).

## Files Updated

### 1. `apps/lib/config/api_config.dart`
- Added automatic platform detection
- Uses `192.168.0.122` for Android
- Uses `localhost` for iOS/Web
- Centralized WebSocket URL configuration

### 2. `apps/lib/services/websocket_service.dart`
- Now uses centralized `ApiConfig.wsUrl`
- Automatically adapts to platform

### 3. `apps/lib/services/api_service.dart`
- Already uses `ApiConfig.baseUrl`
- Works automatically with platform detection

## Testing

### 1. Start the Server
```bash
cd server
npm run dev
```

Server should be running on `http://localhost:3000`

### 2. Run on Android Emulator
```bash
cd apps
flutter run
```

The app will automatically connect to `http://192.168.0.122:3000`

### 3. Verify Connection
- Check server logs for incoming requests
- Test login/registration
- Check if data loads properly

## For Real Android Devices

If testing on a physical Android device:

### Option 1: Use Your Computer's IP (Recommended)

1. Find your computer's IP address:
   - **Windows**: `ipconfig` (look for IPv4 Address)
   - **Mac/Linux**: `ifconfig` or `ip addr`

2. Update `apps/lib/config/api_config.dart`:
   ```dart
   static String get baseUrl {
     // Uncomment and use your IP for real devices
     return 'http://192.168.1.100:3000/api'; // Replace with your IP
     
     // Comment out the platform detection
     // if (Platform.isAndroid) {
     //   return 'http://192.168.0.122:3000/api';
     // }
   }
   ```

3. Make sure your phone and computer are on the same WiFi network

4. Allow firewall access to port 3000 on your computer

### Option 2: Use ngrok (For Remote Testing)

1. Install ngrok: https://ngrok.com/download

2. Start ngrok tunnel:
   ```bash
   ngrok http 3000
   ```

3. Use the ngrok URL in your config:
   ```dart
   static const String baseUrl = 'https://abc123.ngrok.io/api';
   ```

## Troubleshooting

### Connection Refused / Network Error

**Problem**: App can't connect to server

**Solutions**:
1. Verify server is running: `http://localhost:3000/health`
2. Check if using correct IP for your platform
3. Disable firewall temporarily to test
4. For real devices, ensure same WiFi network

### Server Running but App Shows Errors

**Problem**: Server is accessible but API calls fail

**Solutions**:
1. Check server logs for errors
2. Verify API endpoints are correct
3. Check CORS settings in server
4. Ensure MongoDB is connected

### WebSocket Not Connecting

**Problem**: Real-time features not working

**Solutions**:
1. Check WebSocket URL matches API URL (without `/api`)
2. Verify authentication token is valid
3. Check server WebSocket configuration
4. Look for WebSocket errors in app logs

### Images/Videos Not Loading

**Problem**: Media files show broken images

**Solutions**:
1. Check Wasabi S3 configuration in server `.env`
2. Verify media URLs are absolute (include full domain)
3. Check CORS settings for media domain
4. Test media URLs directly in browser

## Quick Reference

### Current Configuration

```dart
// Android Emulator
API: http://192.168.0.122:3000/api
WebSocket: http://192.168.0.122:3000

// iOS Simulator  
API: http://localhost:3000/api
WebSocket: http://localhost:3000

// Real Device (example)
API: http://192.168.1.100:3000/api
WebSocket: http://192.168.1.100:3000
```

### Server Health Check

Test if server is accessible:
```bash
# From computer
curl http://localhost:3000/health

# From Android Emulator (using adb shell)
adb shell
curl http://192.168.0.122:3000/health
```

### Common Ports

- **3000**: Node.js server (API + WebSocket)
- **27017**: MongoDB (local)
- **5000**: Alternative server port (if configured)

## Production Deployment

When deploying to production:

1. Update `api_config.dart`:
   ```dart
   static const String baseUrl = 'https://api.showofflife.com/api';
   static const String wsUrl = 'https://api.showofflife.com';
   ```

2. Ensure HTTPS is enabled

3. Configure proper CORS settings

4. Update environment variables

5. Test thoroughly before release

## Additional Resources

- [Android Emulator Networking](https://developer.android.com/studio/run/emulator-networking)
- [Flutter HTTP Requests](https://docs.flutter.dev/cookbook/networking/fetch-data)
- [Socket.IO Client](https://pub.dev/packages/socket_io_client)

## Status

✅ Android Emulator: Configured (`192.168.0.122`)
✅ iOS Simulator: Configured (`localhost`)
✅ Platform Auto-Detection: Enabled
✅ WebSocket: Configured
✅ API Service: Configured
⚠️ Real Device: Manual configuration required (see above)
⚠️ Production: Update URLs before deployment
