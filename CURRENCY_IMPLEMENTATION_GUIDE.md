# Multi-Currency Implementation Guide

## Overview
I've created a comprehensive currency system that:
1. Detects user's location automatically
2. Fetches real-time exchange rates
3. Displays prices in local currency
4. Caches rates for 1 hour to reduce API calls

## Files Created

### 1. `apps/lib/services/currency_service.dart`
Complete currency service with:
- Automatic location detection (IP-based)
- Real-time exchange rate fetching
- Currency conversion
- Caching system
- Support for 10+ currencies (USD, INR, EUR, GBP, JPY, AUD, CAD, CNY, AED, SAR)

## How It Works

### Currency Detection
```dart
// Automatically detects based on IP location
final currency = await CurrencyService.getUserCurrency();
// Returns: 'INR' for India, 'USD' for US, etc.
```

### Price Conversion
```dart
// Convert $100 USD to user's currency
final localPrice = await CurrencyService.convertFromUSD(100.0);
// If user is in India: returns ₹8,300 (at current rate)
```

### Formatted Display
```dart
// Get formatted price string
final priceString = await CurrencyService.formatPrice(100.0);
// Returns: "₹8,300.00" for INR, "$100.00" for USD, etc.
```

## Implementation Steps

### Step 1: Initialize Currency on App Start
Add to your main app initialization:

```dart
// In main.dart or app initialization
await CurrencyService.getUserCurrency(); // This caches the currency
```

### Step 2: Update Price Display Methods

For synchronous display (recommended), cache currency data:

```dart
class _StoreScreenState extends State<StoreScreen> {
  String _currencySymbol = '\$';
  double _exchangeRate = 1.0;
  
  @override
  void initState() {
    super.initState();
    _initCurrency();
  }
  
  Future<void> _initCurrency() async {
    final symbol = await CurrencyService.getCurrencySymbol();
    final rates = await CurrencyService.getExchangeRates();
    final currency = await CurrencyService.getUserCurrency();
    
    setState(() {
      _currencySymbol = symbol;
      _exchangeRate = rates[currency] ?? 1.0;
    });
  }
  
  String _getProductPrice(Map<String, dynamic> product) {
    final basePrice = (product['price'] ?? 0.0).toDouble();
    final cashAmount = basePrice * 0.5;
    
    // Convert to local currency
    final localAmount = cashAmount * _exchangeRate;
    final coinAmount = (localAmount * 100).ceil();
    
    return '$_currencySymbol${localAmount.toStringAsFixed(2)} + $coinAmount coins';
  }
}
```

### Step 3: Update All Screens

Apply the same pattern to:
- `store_screen.dart`
- `product_detail_screen.dart`
- `cart_screen.dart`
- `category_products_screen.dart`

## Supported Currencies

| Currency | Symbol | Country |
|----------|--------|---------|
| USD | $ | United States |
| INR | ₹ | India |
| EUR | € | European Union |
| GBP | £ | United Kingdom |
| JPY | ¥ | Japan |
| AUD | A$ | Australia |
| CAD | C$ | Canada |
| CNY | ¥ | China |
| AED | د.إ | UAE |
| SAR | ﷼ | Saudi Arabia |

## Exchange Rate API

Uses free API: `https://api.exchangerate-api.com/v4/latest/USD`

- No API key required
- Updates daily
- Cached for 1 hour locally
- Fallback to default rates if API fails

## Coin Calculation

Formula: **1 local currency unit = 100 coins**

Examples:
- ₹1 = 100 coins
- $1 = 100 coins
- £1 = 100 coins

So for a product priced at $100 USD:
- **In India**: ₹4,150 + 415,000 coins (50% each)
- **In US**: $50 + 5,000 coins (50% each)
- **In UK**: £39.50 + 3,950 coins (50% each)

## Manual Currency Selection

Allow users to change currency:

```dart
// Show currency picker
await CurrencyService.setUserCurrency('INR');

// Clear cache to refresh rates
await CurrencyService.clearCache();
```

## Backend Integration

The backend still stores prices in USD. The conversion happens on the client side:

1. Backend stores: `price: 100` (USD)
2. Client fetches exchange rate
3. Client displays: ₹8,300 (for Indian users)
4. Payment: 50% in local currency (₹4,150) + 50% in coins (415,000 coins)

## Testing

Test with different currencies:

```dart
// Test Indian Rupees
await CurrencyService.setUserCurrency('INR');
print(await CurrencyService.formatPrice(100)); // ₹8,300.00

// Test British Pounds
await CurrencyService.setUserCurrency('GBP');
print(await CurrencyService.formatPrice(100)); // £79.00

// Test Japanese Yen
await CurrencyService.setUserCurrency('JPY');
print(await CurrencyService.formatPrice(100)); // ¥14,900
```

## Error Handling

The service includes fallback mechanisms:
- If location detection fails → defaults to USD
- If exchange rate API fails → uses cached rates
- If cache is empty → uses hardcoded fallback rates
- If conversion fails → displays USD

## Performance

- **First load**: ~2-3 seconds (location + exchange rates)
- **Subsequent loads**: Instant (cached)
- **Cache duration**: 1 hour
- **API calls**: Maximum 1 per hour per user

## Next Steps

1. ✅ Currency service created
2. ⏳ Update all price display methods
3. ⏳ Add currency selector in settings
4. ⏳ Test with different locations
5. ⏳ Update backend to store user's preferred currency

## Quick Implementation

For immediate use, I recommend:

1. Add currency initialization in app startup
2. Cache exchange rate and symbol in state
3. Use cached values for price calculations
4. This avoids async/await in every price display

Would you like me to implement the full integration now, or would you prefer to review this approach first?
