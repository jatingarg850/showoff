import 'api_service.dart';

class SubscriptionService {
  static SubscriptionService? _instance;
  static SubscriptionService get instance =>
      _instance ??= SubscriptionService._();

  SubscriptionService._();

  // Cache subscription data
  Map<String, dynamic>? _cachedSubscription;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final subscription = await _getSubscription();
      if (subscription == null) return false;

      final endDate = subscription['endDate'];
      if (endDate == null) return false;

      final expiryDate = DateTime.parse(endDate);
      return expiryDate.isAfter(DateTime.now());
    } catch (e) {
      print('Error checking subscription: $e');
      return false;
    }
  }

  // Check if user is verified (has active subscription)
  Future<bool> isVerified() async {
    return hasActiveSubscription();
  }

  // Check if user has ad-free access
  Future<bool> isAdFree() async {
    return hasActiveSubscription();
  }

  // Check if user can pay with coins
  Future<bool> canPayWithCoins() async {
    return hasActiveSubscription();
  }

  // Get subscription details
  Future<Map<String, dynamic>?> getSubscriptionDetails() async {
    return _getSubscription();
  }

  // Get remaining days in subscription
  Future<int?> getRemainingDays() async {
    try {
      final subscription = await _getSubscription();
      if (subscription == null) return null;

      final endDate = subscription['endDate'];
      if (endDate == null) return null;

      final expiryDate = DateTime.parse(endDate);
      final now = DateTime.now();

      if (expiryDate.isBefore(now)) return 0;

      return expiryDate.difference(now).inDays;
    } catch (e) {
      print('Error calculating remaining days: $e');
      return null;
    }
  }

  // Internal method to get subscription with caching
  Future<Map<String, dynamic>?> _getSubscription() async {
    try {
      // Check cache
      if (_cachedSubscription != null && _cacheTime != null) {
        if (DateTime.now().difference(_cacheTime!).inMinutes <
            _cacheDuration.inMinutes) {
          return _cachedSubscription;
        }
      }

      // Fetch from API
      final response = await ApiService.getMySubscription();
      if (response['success'] && response['data'] != null) {
        _cachedSubscription = response['data'];
        _cacheTime = DateTime.now();
        return _cachedSubscription;
      }

      return null;
    } catch (e) {
      print('Error fetching subscription: $e');
      return null;
    }
  }

  // Clear cache
  void clearCache() {
    _cachedSubscription = null;
    _cacheTime = null;
  }

  // Refresh subscription data
  Future<void> refreshSubscription() async {
    clearCache();
    await _getSubscription();
  }
}
