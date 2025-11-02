# Debug Razorpay Payment Issues

## Current Issue
Getting 500 error when creating Razorpay purchase order:
```
POST /api/coins/create-purchase-order 500 844.415 ms - 17
```

## Debugging Steps

### 1. Test Razorpay Configuration

First, test if Razorpay is configured correctly:
```bash
curl -X GET http://localhost:3000/api/coins/test-razorpay \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 2. Check Server Logs

When you try to add money, check the server console for detailed logs:
- Look for "💰 Creating coin purchase order..."
- Check for any error messages
- Verify Razorpay credentials are loaded

### 3. Test with Minimal Request

Try creating a purchase order with minimal data:
```bash
curl -X POST http://localhost:3000/api/coins/create-purchase-order \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "packageId": "package_1",
    "amount": 99,
    "coins": 100
  }'
```

### 4. Test Add Money Specifically

For add money functionality:
```bash
curl -X POST http://localhost:3000/api/coins/create-purchase-order \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "packageId": "add_money",
    "amount": 100
  }'
```

## Common Issues & Solutions

### Issue 1: Missing Razorpay Credentials
**Symptoms**: "Payment gateway not configured" error
**Solution**: Check `.env` file has:
```
RAZORPAY_KEY_ID=rzp_test_RKkNoqkW7sQisX
RAZORPAY_KEY_SECRET=Dfe20218e1WYafVRRZQUH9Qx
```

### Issue 2: Invalid Razorpay Credentials
**Symptoms**: Razorpay API authentication error
**Solution**: 
1. Login to Razorpay Dashboard
2. Go to Settings → API Keys
3. Generate new test keys
4. Update `.env` file

### Issue 3: Missing Request Data
**Symptoms**: "Package ID is required" or validation errors
**Solution**: Ensure request includes:
- `packageId` (required)
- `amount` (for add_money)
- Valid package ID from the list

### Issue 4: Network/API Issues
**Symptoms**: Timeout or connection errors
**Solution**:
1. Check internet connection
2. Verify Razorpay service status
3. Try with different amounts

## Expected Server Logs (Success)

```
💰 Creating coin purchase order...
Request body: { packageId: 'add_money', amount: 100 }
User ID: 6901078b5a65292cddac98d7
✅ Selected package: { coins: 120, price: 10000 }
💰 Add money - Amount: 100 Price in paise: 10000 Coins: 120
🔄 Creating Razorpay order with options: { amount: 10000, currency: 'INR', ... }
✅ Razorpay order created: order_xxxxxxxxxxxxx
```

## Expected API Response (Success)

```json
{
  "success": true,
  "data": {
    "orderId": "order_xxxxxxxxxxxxx",
    "amount": 10000,
    "currency": "INR",
    "coins": 120,
    "packageId": "add_money"
  }
}
```

## Troubleshooting Commands

### Check if server is running:
```bash
curl http://localhost:3000/health
```

### Test authentication:
```bash
curl -X GET http://localhost:3000/api/coins/balance \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Check Razorpay test:
```bash
curl -X GET http://localhost:3000/api/coins/test-razorpay \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Next Steps

1. **Run the Razorpay test** endpoint first
2. **Check server logs** for detailed error messages
3. **Verify credentials** in Razorpay dashboard
4. **Test with minimal request** data
5. **Check network connectivity** to Razorpay

The enhanced logging will show exactly what's causing the 500 error! 🔍