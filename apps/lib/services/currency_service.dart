import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class CurrencyService {
  static const String _currencyKey = 'user_currency';
  static const String _ratesKey = 'exchange_rates';
  static const String _ratesTimestampKey = 'rates_timestamp';

  // Free exchange rate API (no key required)
  static const String _apiUrl =
      'https://api.exchangerate-api.com/v4/latest/USD';

  // Supported currencies with their symbols
  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'INR': '₹',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'AUD': 'A\$',
    'CAD': 'C\$',
    'CNY': '¥',
    'AED': 'د.إ',
    'SAR': '﷼',
  };

  // Country to currency mapping
  static const Map<String, String> countryCurrencyMap = {
    'US': 'USD',
    'IN': 'INR',
    'GB': 'GBP',
    'EU': 'EUR',
    'JP': 'JPY',
    'AU': 'AUD',
    'CA': 'CAD',
    'CN': 'CNY',
    'AE': 'AED',
    'SA': 'SAR',
  };

  /// Get user's currency (from storage or detect)
  static Future<String> getUserCurrency() async {
    try {
      final savedCurrency = await StorageService.getString(_currencyKey);
      if (savedCurrency != null && savedCurrency.isNotEmpty) {
        return savedCurrency;
      }

      // Detect currency based on location
      final detectedCurrency = await _detectCurrency();
      debugPrint('🌍 Detected currency: $detectedCurrency');
      await StorageService.saveString(_currencyKey, detectedCurrency);
      return detectedCurrency;
    } catch (e) {
      debugPrint('Error getting user currency: $e');
      return 'INR'; // Default to INR
    }
  }

  /// Detect currency based on user's location
  static Future<String> _detectCurrency() async {
    try {
      // Use IP-based geolocation (free service)
      final response = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final countryCode = data['country_code'] as String?;

        if (countryCode != null) {
          debugPrint('🌍 Detected country code: $countryCode');
          // Return currency for country
          return countryCurrencyMap[countryCode] ??
              data['currency'] as String? ??
              'INR';
        }
      }
    } catch (e) {
      debugPrint('Error detecting currency: $e');
    }

    return 'INR'; // Default to INR
  }

  /// Get exchange rates (cached for 1 hour)
  static Future<Map<String, double>> getExchangeRates() async {
    try {
      // Check cache first
      final cachedRates = await StorageService.getString(_ratesKey);
      final timestamp = await StorageService.getString(_ratesTimestampKey);

      if (cachedRates != null && timestamp != null) {
        final cacheTime = DateTime.parse(timestamp);
        final now = DateTime.now();

        // Use cache if less than 1 hour old
        if (now.difference(cacheTime).inHours < 1) {
          debugPrint('💱 Using cached exchange rates');
          return Map<String, double>.from(jsonDecode(cachedRates));
        }
      }

      // Fetch fresh rates
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = Map<String, double>.from(
          (data['rates'] as Map).map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ),
        );

        // Cache the rates
        await StorageService.saveString(_ratesKey, jsonEncode(rates));
        await StorageService.saveString(
          _ratesTimestampKey,
          DateTime.now().toIso8601String(),
        );

        debugPrint('💱 Fetched fresh exchange rates');
        return rates;
      }
    } catch (e) {
      debugPrint('Error fetching exchange rates: $e');
    }

    // Return default rates if fetch fails
    debugPrint('💱 Using default exchange rates');
    return {
      'USD': 1.0,
      'INR': 83.0,
      'EUR': 0.92,
      'GBP': 0.79,
      'JPY': 149.0,
      'AUD': 1.52,
      'CAD': 1.36,
      'CNY': 7.24,
      'AED': 3.67,
      'SAR': 3.75,
    };
  }

  /// Convert USD to user's currency
  static Future<double> convertFromUSD(double usdAmount) async {
    try {
      final currency = await getUserCurrency();
      if (currency == 'USD') return usdAmount;

      final rates = await getExchangeRates();
      final rate = rates[currency] ?? 1.0;

      debugPrint('💱 Converting $usdAmount USD to $currency at rate $rate');
      return usdAmount * rate;
    } catch (e) {
      debugPrint('Error converting currency: $e');
      return usdAmount;
    }
  }

  /// Get currency symbol for user's currency
  static Future<String> getCurrencySymbol() async {
    final currency = await getUserCurrency();
    return currencySymbols[currency] ?? '₹';
  }

  /// Format price in user's currency
  static Future<String> formatPrice(double usdPrice) async {
    try {
      final convertedPrice = await convertFromUSD(usdPrice);
      final symbol = await getCurrencySymbol();
      final currency = await getUserCurrency();

      // Format based on currency
      if (currency == 'JPY') {
        // Japanese Yen has no decimal places
        return '$symbol${convertedPrice.toStringAsFixed(0)}';
      } else {
        return '$symbol${convertedPrice.toStringAsFixed(2)}';
      }
    } catch (e) {
      print('Error formatting price: $e');
      return '\$${usdPrice.toStringAsFixed(2)}';
    }
  }

  /// Set user's currency manually
  static Future<void> setUserCurrency(String currency) async {
    await StorageService.saveString(_currencyKey, currency);
  }

  /// Clear currency cache (force refresh)
  static Future<void> clearCache() async {
    await StorageService.remove(_ratesKey);
    await StorageService.remove(_ratesTimestampKey);
  }

  /// Get coin amount (1 coin = 1 INR)
  static int getCoinAmount(double localCurrencyAmount) {
    return localCurrencyAmount.ceil();
  }
}
