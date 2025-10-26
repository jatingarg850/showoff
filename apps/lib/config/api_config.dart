class ApiConfig {
  // Change this to your server URL

  // For local development:
  // - Android Emulator: use 10.0.2.2
  // - iOS Simulator: use localhost
  // - Real Device: use your computer's IP address

  static const String
  baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS Simulator
  // static const String baseUrl = 'http://192.168.1.100:3000/api'; // Real Device (replace with your IP)

  // For production:
  // static const String baseUrl = 'https://your-domain.com/api';

  static const int
  connectionTimeout = 30000; // 30 seconds
  static const int
  receiveTimeout = 30000; // 30 seconds
}
