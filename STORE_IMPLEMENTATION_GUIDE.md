# Store & Razorpay Integration Guide

## Overview
Complete e-commerce store implementation with Razorpay payment gateway integration for the ShowOff Life app.

## Backend Implementation

### 1. Models Created
- **Product.js** - Product catalog with pricing, sizes, colors, stock
- **Cart.js** - User shopping cart with items
- **Order.js** - Order management with Razorpay integration

### 2. Controllers Created
- **productController.js** - Product CRUD and filtering
- **cartController.js** - Cart management (add, update, remove)
- **orderController.js** - Order creation and Razorpay payment processing

### 3. Routes Added
- `/api/products` - Product endpoints
- `/api/cart` - Cart management endpoints
- `/api/orders` - Order and payment endpoints

### 4. Razorpay Integration
The backend includes complete Razorpay integration:
- Create Razorpay orders
- Verify payment signatures
- Process successful payments
- Handle payment failures

## Frontend Implementation

### API Methods Added to `api_service.dart`
All store-related API methods have been added:
- `getProducts()`, `getNewProducts()`, `getPopularProducts()`
- `getCart()`, `addToCart()`, `updateCartItem()`, `removeFromCart()`
- `createRazorpayOrder()`, `verifyPayment()`, `createOrder()`

### Screens (UI Preserved)
- **store_screen.dart** - Main store with categories
- **product_detail_screen.dart** - Product details with size/color selection
- **cart_screen.dart** - Shopping cart with checkout

## Setup Instructions

### 1. Install Razorpay Package
```bash
cd server
npm install razorpay
```

### 2. Configure Razorpay
Add your Razorpay credentials to `server/.env`:
```
RAZORPAY_KEY_ID=your_razorpay_key_id_here
RAZORPAY_KEY_SECRET=your_razorpay_secret_here
```

Get your keys from: https://dashboard.razorpay.com/app/keys

### 3. Populate Test Products
```bash
cd server
node scripts/populateProducts.js
```

This creates 10 sample products across categories (clothing, shoes, accessories).

### 4. Install Flutter Razorpay Package
Add to `apps/pubspec.yaml`:
```yaml
dependencies:
  razorpay_flutter: ^1.3.6
```

Then run:
```bash
cd apps
flutter pub get
```

### 5. Update Flutter Screens

The screens need to be updated to:
1. Load real products from API
2. Manage cart state
3. Integrate Razorpay payment flow

## Next Steps to Complete

### Store Screen Updates Needed:
1. Load products from `getNewProducts()` and `getPopularProducts()`
2. Load categories with `getProductsByCategory()`
3. Update cart total from real cart data

### Product Detail Screen Updates Needed:
1. Load product details from API
2. Implement "Add to Cart" functionality
3. Pass real product data

### Cart Screen Updates Needed:
1. Load cart from `getCart()` API
2. Update quantities with `updateCartItem()`
3. Implement Razorpay payment on "Pay" button
4. Create order after successful payment

## Razorpay Payment Flow

```dart
// 1. Create Razorpay order
final orderResponse = await ApiService.createRazorpayOrder(totalAmount);
final razorpayOrderId = orderResponse['data']['id'];

// 2. Open Razorpay checkout
var options = {
  'key': 'YOUR_RAZORPAY_KEY_ID',
  'amount': totalAmount * 100, // in paise
  'name': 'ShowOff Life',
  'order_id': razorpayOrderId,
  'prefill': {
    'contact': userPhone,
    'email': userEmail
  }
};

_razorpay.open(options);

// 3. On success, verify and create order
await ApiService.verifyPayment(
  razorpayOrderId: orderId,
  razorpayPaymentId: paymentId,
  razorpaySignature: signature,
);

await ApiService.createOrder(
  items: cartItems,
  shippingAddress: address,
  razorpayOrderId: orderId,
  razorpayPaymentId: paymentId,
  razorpaySignature: signature,
);
```

## Testing

### Test Products
The populate script creates products with:
- Various price ranges ($49.99 - $299.99)
- Different categories (clothing, shoes, accessories)
- Multiple sizes and colors
- Ratings and reviews
- Badges (new, sale, hot)

### Test Payment
Use Razorpay test mode credentials and test cards:
- Card: 4111 1111 1111 1111
- CVV: Any 3 digits
- Expiry: Any future date

## Database Schema

### Product
```javascript
{
  name, description, price, originalPrice,
  category, images, sizes, colors,
  stock, rating, reviewCount, badge
}
```

### Cart
```javascript
{
  user, 
  items: [{ product, quantity, size, color, price }]
}
```

### Order
```javascript
{
  user, orderNumber, items, totalAmount,
  paymentMethod, paymentStatus, orderStatus,
  razorpayOrderId, razorpayPaymentId, razorpaySignature,
  shippingAddress
}
```

## Security Notes

1. **Never expose Razorpay secret** - Keep it server-side only
2. **Always verify signatures** - Prevents payment tampering
3. **Validate amounts** - Check on server before creating orders
4. **Use HTTPS** - Required for payment processing

## Support

For Razorpay integration help:
- Docs: https://razorpay.com/docs/
- Flutter SDK: https://razorpay.com/docs/payments/payment-gateway/flutter-integration/

The UI is preserved exactly as designed. All backend infrastructure is ready. The final step is connecting the Flutter screens to use real data and implement the Razorpay payment flow.
