class ApiConfig {
  // Local Development Server - Android Emulator
  // Use 10.0.2.2 instead of localhost for Android emulator
  static const String baseUrlHttp = 'https://showoff.life/api';
  static const String wsUrlHttp = 'https://showoff.life/';

  // For physical device, use your machine IP (e.g., 192.168.x.x)
  // static const String baseUrlHttp = 'http://192.168.x.x:3000/api';
  // static const String wsUrlHttp = 'http://192.168.x.x:3000/';

  // AWS Production Server (commented out)
  // static const String baseUrlHttps = 'https://www.showoff.life/api';
  // static const String wsUrlHttps = 'https://www.showoff.life/';

  // Use emulator address by default
  static String get baseUrl => baseUrlHttp;
  static String get wsUrl => wsUrlHttp;

  // Alternative: Use HTTPS
  // static String get baseUrl => baseUrlHttps;
  // static String get wsUrl => wsUrlHttps;

  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // For Android: Allow cleartext (HTTP) traffic
  // Add to android/app/src/main/AndroidManifest.xml:
  // android:usesCleartextTraffic="true"
}
