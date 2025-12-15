class ApiConfig {
  // AWS Production Server - Supports both HTTP and HTTPS

  // Primary: HTTP (Port 80 via Nginx)
  static const String baseUrlHttp = 'http://10.0.2.2:3000/api';
  static const String wsUrlHttp = 'http://10.0.2.2:3000';

  // Secondary: HTTPS (Port 443 via Nginx with SSL)
  static const String baseUrlHttps = 'https://3.110.103.187/api';
  static const String wsUrlHttps = 'https://3.110.103.187';

  // Use HTTP by default (more compatible with mobile)
  // Switch to HTTPS when SSL certificate is properly configured
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
