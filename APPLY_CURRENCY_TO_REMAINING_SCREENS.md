# Apply Currency to Remaining Screens

## For: category_products_screen.dart

### Step 1: Add state variables (after line ~40)
```dart
// Currency data
String _currencySymbol = '\$';
double _exchangeRate = 1.0;
String _currencyCode = 'USD';
```

### Step 2: Add to initState (after super.initState())
```dart
_initCurrency();
```

### Step 3: Add method (before _loadProducts)
```dart
Future<void> _initCurrency() async {
  try {
    final symbol = await CurrencyService.getCurrencySymbol();
    final rates = await CurrencyService.getExchangeRates();
    final currency = await CurrencyService.getUserCurrency();
    
    setState(() {
      _currencySymbol = symbol;
      _currencyCode = currency;
      _exchangeRate = rates[currency] ?? 1.0;
    });
  } catch (e) {
    print('Error initializing currency: $e');
  }
}
```

### Step 4: Update _getProductPrice method (around line 364)
Replace the entire method with:
```dart
String _getProductPrice(Map<String, dynamic> product) {
  final basePrice = (product['price'] ?? 0.0).toDouble();
  final cashAmount = basePrice * 0.5;
  
  // Convert to local currency
  final localAmount = cashAmount * _exchangeRate;
  final coinAmount = CurrencyService.getCoinAmount(localAmount);

  // Format based on currency
  String formattedPrice = _currencyCode == 'JPY' 
    ? '$_currencySymbol${localAmount.toStringAsFixed(0)}'
    : '$_currencySymbol${localAmount.toStringAsFixed(2)}';

  return '$formattedPrice + $coinAmount coins';
}
```

## For: cart_screen.dart

### Step 1: Add state variables (after line ~30)
```dart
// Currency data
String _currencySymbol = '\$';
double _exchangeRate = 1.0;
String _currencyCode = 'USD';
```

### Step 2: Add import at top
```dart
import 'services/currency_service.dart';
```

### Step 3: Add to initState
```dart
_initCurrency();
```

### Step 4: Add method
```dart
Future<void> _initCurrency() async {
  try {
    final symbol = await CurrencyService.getCurrencySymbol();
    final rates = await CurrencyService.getExchangeRates();
    final currency = await CurrencyService.getUserCurrency();
    
    setState(() {
      _currencySymbol = symbol;
      _currencyCode = currency;
      _exchangeRate = rates[currency] ?? 1.0;
    });
  } catch (e) {
    print('Error initializing currency: $e');
  }
}
```

### Step 5: Update _calculateTotals method
Replace the calculation part with:
```dart
void _calculateTotals() {
  _totalUPI = 0;
  _totalCoins = 0;

  final items = _cart['items'] as List? ?? [];
  
  for (var item in items) {
    final product = item['product'] ?? {};
    final quantity = (item['quantity'] ?? 1).toInt();
    final basePrice = (product['price'] ?? 0.0).toDouble();

    // 50% cash in local currency
    final cashAmount = (basePrice * 0.5) * quantity;
    _totalUPI += cashAmount * _exchangeRate;
    
    // 50% coins
    final localAmount = cashAmount * _exchangeRate;
    _totalCoins += CurrencyService.getCoinAmount(localAmount);
  }
}
```

### Step 6: Update _getItemPrice method
```dart
String _getItemPrice(Map<String, dynamic> item) {
  final product = item['product'] ?? {};
  final quantity = (item['quantity'] ?? 1).toInt();
  final basePrice = (product['price'] ?? 0.0).toDouble();

  // Calculate 50/50 split in local currency
  final cashAmount = (basePrice * 0.5) * quantity;
  final localAmount = cashAmount * _exchangeRate;
  final coinAmount = CurrencyService.getCoinAmount(localAmount);

  String formattedPrice = _currencyCode == 'JPY'
    ? '$_currencySymbol${localAmount.toStringAsFixed(0)}'
    : '$_currencySymbol${localAmount.toStringAsFixed(2)}';

  return '$formattedPrice + $coinAmount coins';
}
```

### Step 7: Update checkout section display
Replace the cash amount display with:
```dart
Text(
  '$_currencySymbol${_totalUPI.toStringAsFixed(_currencyCode == 'JPY' ? 0 : 2)}',
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF8B5CF6),
  ),
),
```

## Testing Commands

```dart
// Test Indian Rupees
await CurrencyService.setUserCurrency('INR');

// Test British Pounds  
await CurrencyService.setUserCurrency('GBP');

// Test Japanese Yen
await CurrencyService.setUserCurrency('JPY');

// Clear cache and refresh
await CurrencyService.clearCache();
```

## Expected Results

### $100 Product in Different Currencies:

| Location | Display | Cash (50%) | Coins (50%) |
|----------|---------|------------|-------------|
| USA | $50.00 + 5,000 coins | $50.00 | 5,000 |
| India | ₹4,150.00 + 415,000 coins | ₹4,150.00 | 415,000 |
| UK | £39.50 + 3,950 coins | £39.50 | 3,950 |
| Japan | ¥7,450 + 745,000 coins | ¥7,450 | 745,000 |
| UAE | د.إ183.50 + 18,350 coins | د.إ183.50 | 18,350 |

## Coin Calculation Formula

**1 local currency unit = 100 coins**

This means:
- ₹1 = 100 coins
- $1 = 100 coins
- £1 = 100 coins
- ¥1 = 100 coins

So the coin amount scales with the local currency value.

## Backend Considerations

The backend should:
1. Store prices in USD (base currency)
2. Accept currency code in payment requests
3. Convert amounts back to USD for processing
4. Store user's preferred currency in User model

## Auto-Detection Flow

1. App starts
2. Detects user's IP location
3. Maps country to currency (IN → INR, US → USD, etc.)
4. Fetches current exchange rates
5. Caches everything for 1 hour
6. All prices display in local currency
7. Payments process in local currency
8. Backend receives currency code with payment

## Manual Override

Users can change currency in settings:
```dart
// Add to settings screen
await CurrencyService.setUserCurrency('EUR');
await CurrencyService.clearCache();
// Restart app or refresh screens
```

## Error Handling

- Location detection fails → USD
- Exchange rate API fails → Cached rates
- No cache → Hardcoded fallback rates
- Invalid currency → USD

## Performance Optimization

- Currency detected once on app start
- Exchange rates cached for 1 hour
- All price calculations use cached data
- No async calls during scrolling
- Smooth 60fps performance
