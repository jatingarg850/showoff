import 'dart:io';

class ApiConfig {
  // Change this to your server URL

  // For local development:
  // - Android Emulator: use 192.168.0.122
  // - iOS Simulator: use localhost
  // - Real Device: use your computer's IP address

  // Automatic platform detection http://144.91.77.89:3000/api
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Android Emulator - use 10.0.2.2 to access host machine's localhost
      return 'http://144.91.77.89:3000/api';
    } else if (Platform.isIOS) {
      // iOS Simulator
      return 'http://144.91.77.89:3000/api';
    } else {
      // Web, Desktop, or fallback
      return 'http://localhost:3000/api';
    }
  }

  // Manual override for real devices (uncomment and set your computer's IP)
  // static const String baseUrl = 'http://192.168.1.100:3000/api'; // Real Device

  // For production (uncomment when deploying)
  // static const String baseUrl = 'https://your-domain.com/api';

  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // WebSocket URL (without /api suffix)
  static String get wsUrl {
    if (Platform.isAndroid) {
      return 'http://192.168.0.122:3000';
    } else if (Platform.isIOS) {
      return 'http://localhost:3000';
    } else {
      return 'http://localhost:3000';
    }
  }
}
